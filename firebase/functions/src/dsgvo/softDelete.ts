// firebase/functions/src/dsgvo/softDelete.ts
//
// Callable Function: Soft-Delete eines Fahrers.
// - Verschiebt das Driver-Dokument unter users/{dspUid}/drivers/{driverId}
//   in eine Schattenkopie _deleted_drivers/{driverId}
// - Setzt einen purgeAt-Timestamp (Default 6 Monate)
// - Loescht das Originaldokument
// - Storage-Files bleiben bis zum endgueltigen Purge erhalten
// - Schreibt Audit-Event
//
// Berechtigung: nur admin / developer
// Region: europe-west3

import {onCall, HttpsError} from "firebase-functions/v2/https";
import {getAuth} from "firebase-admin/auth";
import {getFirestore, Timestamp} from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";

import {writeAuditEvent} from "../audit/writeAudit";

interface SoftDeleteRequest {
  dspUid?: string;
  driverId?: string;
  reason?: string;
  retentionDays?: number;
}

interface SoftDeleteResponse {
  ok: true;
  purgeAt: number;
}

const DEFAULT_RETENTION_DAYS = 180; // 6 Monate

export const softDeleteDriver = onCall<
  SoftDeleteRequest,
  Promise<SoftDeleteResponse>
>(
  {region: "europe-west3"},
  async (req) => {
    if (!req.auth) {
      throw new HttpsError("unauthenticated", "Login erforderlich.");
    }

    const callerRole =
      (req.auth.token.role as string | undefined) ?? null;
    if (callerRole !== "admin" && callerRole !== "developer") {
      throw new HttpsError(
        "permission-denied",
        "Nur Admin/Developer dürfen Fahrer löschen.",
      );
    }

    const dspUid = (req.data.dspUid ?? "").trim();
    const driverId = (req.data.driverId ?? "").trim();
    if (!dspUid || !driverId) {
      throw new HttpsError(
        "invalid-argument",
        "dspUid und driverId sind erforderlich.",
      );
    }

    // Admins duerfen nur ihren eigenen DSP-Scope loeschen.
    const callerDspUid =
      (req.auth.token.dspUid as string | undefined) ?? req.auth.uid;
    if (callerRole === "admin" && callerDspUid !== dspUid) {
      throw new HttpsError(
        "permission-denied",
        "Admin darf nur Fahrer im eigenen DSP-Scope löschen.",
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

    const retentionDays =
      typeof req.data.retentionDays === "number" &&
      req.data.retentionDays > 0 &&
      req.data.retentionDays <= 3650 ?
        req.data.retentionDays :
        DEFAULT_RETENTION_DAYS;

    const purgeAtMs =
      Date.now() + retentionDays * 24 * 60 * 60 * 1000;
    const purgeAt = Timestamp.fromMillis(purgeAtMs);

    // Schattenkopie schreiben (mit Original-Pfad fuer eventuellen Restore).
    await db
      .collection("_deleted_drivers")
      .doc(driverId)
      .set({
        originalPath: driverRef.path,
        originalData: driverSnap.data() ?? null,
        deletedAt: Timestamp.now(),
        deletedBy: req.auth.uid,
        dspUid,
        reason: (req.data.reason ?? "").trim() || null,
        purgeAt,
      });

    // Auth-Account ebenfalls deaktivieren (Login-Sperre)
    try {
      const auth = getAuth();
      // Driver auth uid steckt typischerweise im Driver-Doc als 'authUid'
      // oder ist der driverId selbst. Wir versuchen beides.
      const data = driverSnap.data() as Record<string, unknown>;
      const authUid =
        (data.authUid as string | undefined) ??
        (data.uid as string | undefined) ??
        driverId;
      if (authUid && typeof authUid === "string") {
        await auth.updateUser(authUid, {disabled: true}).catch((err) => {
          logger.warn("softDelete: auth disable failed (non-fatal)", {
            authUid,
            err: String(err),
          });
        });
      }
    } catch (err) {
      logger.warn("softDelete: auth disable lookup failed", {
        err: String(err),
      });
    }

    // Originaldokument loeschen.
    await driverRef.delete();

    await writeAuditEvent({
      actorUid: req.auth.uid,
      action: "soft_delete",
      collection: "drivers",
      documentId: driverId,
      documentPath: driverRef.path,
      dspUid,
      metadata: {
        purgeAt: purgeAtMs,
        retentionDays,
        reason: req.data.reason ?? null,
      },
    });

    return {ok: true, purgeAt: purgeAtMs};
  },
);
