// firebase/functions/src/audit/types.ts
//
// Typdefinitionen fuer das Audit-Log (DSGVO Art. 32 — Nachweispflicht).

import {Timestamp} from "firebase-admin/firestore";

export type AuditAction =
  | "create"
  | "update"
  | "delete"
  | "soft_delete"
  | "purge"
  | "export"
  | "role_change"
  | "claim_change";

export interface AuditEvent {
  timestamp: Timestamp;
  actorUid: string;
  actorEmail: string | null;
  actorRole: string | null;
  action: AuditAction;
  collection: string;
  documentId: string;
  documentPath: string;
  // Auf welchen DSP bezogen — fuer Mandantentrennung beim Lesen
  dspUid: string | null;
  // Nur die geaenderten Feld-Namen, KEINE Werte (Datensparsamkeit)
  changedFields?: string[];
  metadata?: Record<string, unknown>;
}
