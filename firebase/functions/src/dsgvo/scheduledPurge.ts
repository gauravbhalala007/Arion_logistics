// firebase/functions/src/dsgvo/scheduledPurge.ts
//
// Scheduled Function: laeuft taeglich um 03:00 Europe/Berlin und purged
// alle _deleted_drivers-Eintraege, deren purgeAt erreicht ist.
//
// Schritte pro Eintrag:
//  1) Storage-Files (driver_docs/{tid}, driver_profile_photos/{tid},
//     incident_reports/{dspUid}/{tid}/*) loeschen
//  2) Auth-User loeschen
//  3) Schattenkopie aus _deleted_drivers loeschen
//  4) Audit-Event 'purge' schreiben
//
// Region: europe-west3

import {onSchedule} from "firebase-functions/v2/scheduler";
import {getFirestore, Timestamp} from "firebase-admin/firestore";
import {getStorage} from "firebase-admin/storage";
import {getAuth} from "firebase-admin/auth";
import * as logger from "firebase-functions/logger";

import {writeAuditEvent} from "../audit/writeAudit";

const STORAGE_PREFIXES = [
  "driver_docs",
  "driver_profile_photos",
];

/**
 * Deletes all files under a given Storage prefix.
 *
 * @param {string} prefix Storage path prefix to enumerate and delete.
 * @return {Promise<number>} Number of files deleted.
 */
async function deletePrefix(prefix: string): Promise<number> {
  const bucket = getStorage().bucket();
  const [files] = await bucket.getFiles({prefix});
  await Promise.all(files.map((f) => f.delete().catch(() => undefined)));
  return files.length;
}

export const purgeExpiredSoftDeletes = onSchedule(
  {
    schedule: "0 3 * * *",
    timeZone: "Europe/Berlin",
    region: "europe-west3",
    timeoutSeconds: 540,
    memory: "512MiB",
  },
  async () => {
    const db = getFirestore();
    const auth = getAuth();

    const expiredSnap = await db
      .collection("_deleted_drivers")
      .where("purgeAt", "<=", Timestamp.now())
      .get();

    if (expiredSnap.empty) {
      logger.info("scheduledPurge: nothing to purge");
      return;
    }

    let purgedCount = 0;
    for (const doc of expiredSnap.docs) {
      const driverId = doc.id;
      const data = doc.data() as Record<string, unknown>;
      const dspUid = (data.dspUid as string | undefined) ?? null;
      const originalData =
        (data.originalData as Record<string, unknown> | undefined) ?? {};

      let storageFilesDeleted = 0;
      try {
        for (const prefix of STORAGE_PREFIXES) {
          storageFilesDeleted += await deletePrefix(`${prefix}/${driverId}/`);
        }
        // Incident-Reports liegen unter incident_reports/{dspUid}/{driverId}/*
        if (dspUid) {
          storageFilesDeleted += await deletePrefix(
            `incident_reports/${dspUid}/${driverId}/`,
          );
        }
      } catch (err) {
        logger.warn("scheduledPurge: storage delete failed", {
          driverId,
          err: String(err),
        });
      }

      // Auth-Account loeschen, falls noch vorhanden
      const authUid =
        (originalData.authUid as string | undefined) ??
        (originalData.uid as string | undefined) ??
        driverId;
      if (authUid && typeof authUid === "string") {
        await auth.deleteUser(authUid).catch((err) => {
          logger.debug("scheduledPurge: auth delete (likely already gone)", {
            authUid,
            err: String(err),
          });
        });
      }

      // Schattenkopie loeschen
      await doc.ref.delete();

      await writeAuditEvent({
        actorUid: "system_purge",
        action: "purge",
        collection: "drivers",
        documentId: driverId,
        documentPath: `_deleted_drivers/${driverId}`,
        dspUid,
        metadata: {
          storageFilesDeleted,
          deletedAt: data.deletedAt,
          retentionFulfilled: true,
        },
      });

      purgedCount += 1;
    }

    logger.info("scheduledPurge: completed", {purgedCount});
  },
);
