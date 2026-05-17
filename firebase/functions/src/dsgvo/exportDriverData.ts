// firebase/functions/src/dsgvo/exportDriverData.ts
//
// Callable Function: erzeugt eine ZIP-Datei mit ALLEN personenbezogenen
// Daten eines Fahrers (DSGVO Art. 20 — Datenuebertragbarkeit).
//
// Inhalte der ZIP:
//   /README.txt                  Erklaerung
//   /driver.json                 Stammdaten + Subcollections-Index
//   /subcollections/<name>.json  Jede Subcollection als JSON
//   /audit_log.json              Alle Audit-Events des Fahrers
//   /documents/<name>            Original-Dateien aus Storage
//
// Berechtigung:
//  - Driver darf seine eigenen Daten exportieren (uid == authUid)
//  - Admin/Developer des DSP darf jeden Fahrer im eigenen Scope exportieren
//
// Liefert: Signed Download-URL (1h gueltig)
// Region: europe-west3

import {onCall, HttpsError} from "firebase-functions/v2/https";
import {getFirestore} from "firebase-admin/firestore";
import {getStorage} from "firebase-admin/storage";
import * as logger from "firebase-functions/logger";
import archiver = require("archiver");
import {PassThrough} from "node:stream";

import {writeAuditEvent} from "../audit/writeAudit";

interface ExportRequest {
  dspUid?: string;
  driverId?: string;
}

interface ExportResponse {
  ok: true;
  downloadUrl: string;
  expiresAt: number;
  fileName: string;
  sizeBytes: number;
}

const SUBCOLLECTIONS_TO_EXPORT = [
  "documents",
  "academy_tests",
  "faq_training",
  "time_entries",
  "shifts",
  "time_account",
  "correction_requests",
  "absence_requests",
  "incident_reports",
];

const STORAGE_PREFIXES_FOR_DRIVER = [
  "driver_docs",
  "driver_profile_photos",
];

/**
 * Streams a storage prefix into the archive at the given destination path.
 *
 * @param {archiver.Archiver} archive Archiver instance.
 * @param {string} prefix Storage prefix to enumerate.
 * @param {string} destFolder Folder name inside the archive.
 * @return {Promise<number>} Number of files added to the archive.
 */
async function addStoragePrefix(
  archive: archiver.Archiver,
  prefix: string,
  destFolder: string,
): Promise<number> {
  const bucket = getStorage().bucket();
  const [files] = await bucket.getFiles({prefix});
  let added = 0;
  for (const file of files) {
    try {
      const [bytes] = await file.download();
      const name = file.name.split("/").pop() ?? "file";
      archive.append(bytes, {name: `${destFolder}/${name}`});
      added += 1;
    } catch (err) {
      logger.warn("dsgvoExport: file download failed", {
        path: file.name,
        err: String(err),
      });
    }
  }
  return added;
}

export const exportDriverData = onCall<
  ExportRequest,
  Promise<ExportResponse>
>(
  {
    region: "europe-west3",
    memory: "1GiB",
    timeoutSeconds: 540,
  },
  async (req) => {
    if (!req.auth) {
      throw new HttpsError("unauthenticated", "Login erforderlich.");
    }

    const dspUid = (req.data.dspUid ?? "").trim();
    const driverId = (req.data.driverId ?? "").trim();
    if (!dspUid || !driverId) {
      throw new HttpsError(
        "invalid-argument",
        "dspUid und driverId sind erforderlich.",
      );
    }

    const callerRole =
      (req.auth.token.role as string | undefined) ?? null;
    const callerDspUid =
      (req.auth.token.dspUid as string | undefined) ?? req.auth.uid;
    const callerTransporterId =
      (req.auth.token.transporterId as string | undefined) ?? null;

    const isAdmin = callerRole === "admin" || callerRole === "developer";
    const isSelfDriver =
      callerRole === "driver" &&
      callerDspUid === dspUid &&
      callerTransporterId === driverId;

    if (!isAdmin && !isSelfDriver) {
      throw new HttpsError(
        "permission-denied",
        "Du darfst nur deine eigenen Daten exportieren.",
      );
    }
    if (isAdmin && callerDspUid !== dspUid && callerRole !== "developer") {
      throw new HttpsError(
        "permission-denied",
        "Admin darf nur Fahrer im eigenen DSP-Scope exportieren.",
      );
    }

    const db = getFirestore();
    const driverRef = db
      .collection("users")
      .doc(dspUid)
      .collection("drivers")
      .doc(driverId);
    const driverSnap = await driverRef.get();
    if (!driverSnap.exists) {
      throw new HttpsError("not-found", `Fahrer ${driverId} nicht gefunden.`);
    }

    // ZIP via Streaming bauen → direkt in Storage hochladen.
    const bucket = getStorage().bucket();
    const exportPath =
      `dsgvo_exports/${dspUid}_${driverId}_${Date.now()}.zip`;
    const exportFile = bucket.file(exportPath);
    const uploadStream = exportFile.createWriteStream({
      contentType: "application/zip",
      resumable: false,
    });
    const passthrough = new PassThrough();
    passthrough.pipe(uploadStream);

    const archive = archiver("zip", {zlib: {level: 9}});
    archive.on("warning", (err) => {
      logger.warn("dsgvoExport: archiver warning", {err: String(err)});
    });
    archive.on("error", (err) => {
      logger.error("dsgvoExport: archiver error", {err: String(err)});
    });
    archive.pipe(passthrough);

    // README
    archive.append(
      "DSGVO-Datenexport (Art. 20 — Datenuebertragbarkeit)\n\n" +
        `Fahrer-ID: ${driverId}\n` +
        `DSP-UID:   ${dspUid}\n` +
        `Erstellt:  ${new Date().toISOString()}\n\n` +
        "Inhalt:\n" +
        "  driver.json              Stammdaten\n" +
        "  subcollections/*.json    Unterdaten (Shifts, Trainings, etc.)\n" +
        "  audit_log.json           Aenderungshistorie\n" +
        "  documents/               Original-Dateien aus dem Cloud-Storage\n",
      {name: "README.txt"},
    );

    // Stammdaten
    archive.append(
      JSON.stringify(driverSnap.data() ?? {}, null, 2),
      {name: "driver.json"},
    );

    // Subcollections
    for (const sub of SUBCOLLECTIONS_TO_EXPORT) {
      try {
        const subSnap = await driverRef.collection(sub).get();
        if (subSnap.empty) continue;
        const docs = subSnap.docs.map((d) => ({id: d.id, ...d.data()}));
        archive.append(JSON.stringify(docs, null, 2), {
          name: `subcollections/${sub}.json`,
        });
      } catch (err) {
        logger.warn("dsgvoExport: subcollection fetch failed", {
          sub,
          err: String(err),
        });
      }
    }

    // Audit-Log
    try {
      const auditSnap = await db
        .collection("audit_log")
        .where("collection", "==", "drivers")
        .where("documentId", "==", driverId)
        .orderBy("timestamp", "desc")
        .get();
      const events = auditSnap.docs.map((d) => ({id: d.id, ...d.data()}));
      archive.append(JSON.stringify(events, null, 2), {
        name: "audit_log.json",
      });
    } catch (err) {
      logger.warn("dsgvoExport: audit_log fetch failed", {
        err: String(err),
      });
    }

    // Storage-Files
    let docsAdded = 0;
    for (const prefix of STORAGE_PREFIXES_FOR_DRIVER) {
      docsAdded += await addStoragePrefix(
        archive,
        `${prefix}/${driverId}/`,
        `documents/${prefix}`,
      );
    }

    await archive.finalize();
    await new Promise<void>((resolve, reject) => {
      uploadStream.on("finish", resolve);
      uploadStream.on("error", reject);
    });

    const [meta] = await exportFile.getMetadata();
    const sizeBytes = Number(meta.size ?? 0);

    const expiresAtMs = Date.now() + 60 * 60 * 1000; // 1h
    const [signedUrl] = await exportFile.getSignedUrl({
      version: "v4",
      action: "read",
      expires: expiresAtMs,
    });

    const fileName = exportPath.split("/").pop() ?? "export.zip";

    await writeAuditEvent({
      actorUid: req.auth.uid,
      action: "export",
      collection: "drivers",
      documentId: driverId,
      documentPath: driverRef.path,
      dspUid,
      metadata: {
        exportPath,
        sizeBytes,
        docsAdded,
        requestedBy: req.auth.uid,
        requestedByRole: callerRole,
      },
    });

    return {
      ok: true,
      downloadUrl: signedUrl,
      expiresAt: expiresAtMs,
      fileName,
      sizeBytes,
    };
  },
);
