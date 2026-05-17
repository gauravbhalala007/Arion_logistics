// firebase/functions/src/audit/onDriverWritten.ts
//
// Firestore-Trigger: protokolliert jeden Write (create/update/delete)
// auf users/{dspUid}/drivers/{driverId} in der audit_log Collection.
//
// Erfasst werden:
//  - WER (actor uid + email + rolle aus custom claims)
//  - WAS (action create/update/delete)
//  - WO (collection + documentPath + documentId + dspUid)
//  - WELCHE FELDER (Liste, KEINE Werte — Datensparsamkeit)
//  - WANN (server timestamp)
//
// Region: europe-west3 (Frankfurt) — fuer DSGVO-konforme Datenhaltung
// nach abgeschlossener Migration.

import {onDocumentWritten} from "firebase-functions/v2/firestore";

import {writeAuditEvent} from "./writeAudit";
import {AuditAction} from "./types";

/**
 * Computes the list of field names that differ between two snapshots.
 * Returns only field NAMES (no values) for DSGVO data minimization.
 *
 * @param {object} before Document data before the write (or undefined).
 * @param {object} after Document data after the write (or undefined).
 * @return {string[]} Names of changed top-level fields.
 */
function diffFields(
  before: Record<string, unknown> | undefined,
  after: Record<string, unknown> | undefined,
): string[] {
  if (!before && after) return Object.keys(after);
  if (before && !after) return Object.keys(before);
  if (!before || !after) return [];
  const keys = new Set([...Object.keys(before), ...Object.keys(after)]);
  const changed: string[] = [];
  for (const key of keys) {
    if (JSON.stringify(before[key]) !== JSON.stringify(after[key])) {
      changed.push(key);
    }
  }
  return changed;
}

export const onDriverDocumentWritten = onDocumentWritten(
  {
    document: "users/{dspUid}/drivers/{driverId}",
    region: "europe-west3",
  },
  async (event) => {
    const before = event.data?.before?.exists ?
      (event.data.before.data() as Record<string, unknown>) :
      undefined;
    const after = event.data?.after?.exists ?
      (event.data.after.data() as Record<string, unknown>) :
      undefined;

    let action: AuditAction = "update";
    if (!before && after) action = "create";
    else if (before && !after) action = "delete";

    // updatedBy/createdBy aus dem Dokument lesen (clientseitig gesetzt),
    // fallback auf "system" wenn die Aenderung von einem Trigger stammt.
    const actorUid =
      (after?.updatedBy as string | undefined) ??
      (before?.updatedBy as string | undefined) ??
      (after?.createdBy as string | undefined) ??
      "system";

    const dspUid = event.params.dspUid as string;
    const driverId = event.params.driverId as string;
    const documentPath = `users/${dspUid}/drivers/${driverId}`;

    await writeAuditEvent({
      actorUid,
      action,
      collection: "drivers",
      documentId: driverId,
      documentPath,
      dspUid,
      changedFields: diffFields(before, after),
    });
  },
);
