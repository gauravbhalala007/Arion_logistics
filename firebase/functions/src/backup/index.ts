// firebase/functions/src/backup/index.ts
//
// Re-Exports der Backup-Cloud-Functions.

export {
  scheduledFirestoreBackup,
  purgeOldBackups,
} from "./scheduledBackup";
