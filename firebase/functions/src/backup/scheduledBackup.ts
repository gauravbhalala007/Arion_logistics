// firebase/functions/src/backup/scheduledBackup.ts
//
// Scheduled Function: erzeugt taeglich einen Firestore-Backup-Export
// nach gs://<PROJECT_ID>-backups/firestore-YYYY-MM-DDTHH-MM-SS/.
//
// Zusaetzlich loescht eine zweite Function alte Backups (>30 Tage).
//
// Voraussetzung:
//  - Storage-Bucket "<PROJECT_ID>-backups" existiert (wird beim ersten
//    Lauf automatisch erstellt, falls die Function die Rechte hat)
//  - Functions-Service-Account hat "Cloud Datastore Import Export Admin"
//    Rolle (im neuen EU-Projekt vor Deploy einrichten)
//
// Region: europe-west3 (Frankfurt)

import {onSchedule} from "firebase-functions/v2/scheduler";
import {getStorage} from "firebase-admin/storage";
import {google} from "googleapis";
import * as logger from "firebase-functions/logger";

const BACKUP_RETENTION_DAYS = 30;

/**
 * Returns the active GCP project ID at runtime.
 *
 * @return {string} The active project ID.
 */
function projectId(): string {
  return (
    process.env.GCLOUD_PROJECT ??
    process.env.GCP_PROJECT ??
    process.env.FIREBASE_CONFIG ?
      (JSON.parse(process.env.FIREBASE_CONFIG ?? "{}").projectId as string) :
      ""
  );
}

/**
 * Returns an ISO-like timestamp string usable in storage path segments.
 *
 * @return {string} Timestamp like "2026-05-17T03-00-00".
 */
function timestampLabel(): string {
  return new Date()
    .toISOString()
    .replace(/\..+$/, "")
    .replace(/:/g, "-");
}

export const scheduledFirestoreBackup = onSchedule(
  {
    schedule: "0 2 * * *",
    timeZone: "Europe/Berlin",
    region: "europe-west3",
    timeoutSeconds: 540,
    memory: "256MiB",
  },
  async () => {
    const project = projectId();
    if (!project) {
      logger.error("scheduledFirestoreBackup: projectId not resolvable");
      return;
    }

    const bucketName = `${project}-backups`;
    const outputUri =
      `gs://${bucketName}/firestore-${timestampLabel()}`;

    // Ensure backup bucket exists (idempotent).
    try {
      const bucket = getStorage().bucket(bucketName);
      const [exists] = await bucket.exists();
      if (!exists) {
        await bucket.create({location: "EUROPE-WEST3"});
        logger.info("scheduledFirestoreBackup: created backup bucket", {
          bucketName,
        });
      }
    } catch (err) {
      logger.warn("scheduledFirestoreBackup: bucket check failed", {
        bucketName,
        err: String(err),
      });
    }

    // Trigger the Firestore Admin export operation.
    const auth = new google.auth.GoogleAuth({
      scopes: ["https://www.googleapis.com/auth/datastore"],
    });
    const client = await auth.getClient();
    const firestoreAdmin = google.firestore({
      version: "v1",
      auth: client as never,
    });

    try {
      const res = await firestoreAdmin.projects.databases.exportDocuments({
        name: `projects/${project}/databases/(default)`,
        requestBody: {
          outputUriPrefix: outputUri,
          // collectionIds omitted → exports ALL collections
        },
      });
      logger.info("scheduledFirestoreBackup: export started", {
        operation: res.data.name,
        outputUri,
      });
    } catch (err) {
      logger.error("scheduledFirestoreBackup: export call failed", {
        err: String(err),
      });
      throw err;
    }
  },
);

export const purgeOldBackups = onSchedule(
  {
    schedule: "30 4 * * *",
    timeZone: "Europe/Berlin",
    region: "europe-west3",
    timeoutSeconds: 540,
    memory: "256MiB",
  },
  async () => {
    const project = projectId();
    if (!project) return;
    const bucketName = `${project}-backups`;

    const bucket = getStorage().bucket(bucketName);
    const [exists] = await bucket.exists();
    if (!exists) return;

    const [files] = await bucket.getFiles({prefix: "firestore-"});
    const cutoff =
      Date.now() - BACKUP_RETENTION_DAYS * 24 * 60 * 60 * 1000;

    let purged = 0;
    for (const file of files) {
      const meta = file.metadata;
      const createdRaw = (meta.timeCreated as string | undefined) ?? "";
      const created = createdRaw ? Date.parse(createdRaw) : NaN;
      if (Number.isFinite(created) && created < cutoff) {
        await file.delete().catch(() => undefined);
        purged += 1;
      }
    }
    logger.info("purgeOldBackups: completed", {purged});
  },
);
