// firebase/functions/src/audit/writeAudit.ts
//
// Helper zum Schreiben eines Audit-Eintrags. Wird sowohl von Triggern
// als auch von anderen Callables (Soft-Delete, Export, etc.) genutzt.

import {getFirestore, Timestamp} from "firebase-admin/firestore";
import {getAuth} from "firebase-admin/auth";
import * as logger from "firebase-functions/logger";

import {AuditAction, AuditEvent} from "./types";

interface WriteAuditInput {
  actorUid: string | null;
  action: AuditAction;
  collection: string;
  documentId: string;
  documentPath: string;
  dspUid?: string | null;
  changedFields?: string[];
  metadata?: Record<string, unknown>;
}

/**
 * Resolves an actor's email and role from Firebase Auth custom claims.
 * Returns null fields when the actor is a system process or unknown.
 *
 * @param {string} uid The actor's Firebase Auth UID (or null).
 * @return {Promise<object>} Object with `email` and `role` fields.
 */
async function resolveActor(uid: string | null): Promise<{
  email: string | null;
  role: string | null;
}> {
  if (!uid || uid === "system" || uid.startsWith("system_")) {
    return {email: null, role: uid};
  }
  try {
    const auth = getAuth();
    const user = await auth.getUser(uid);
    const claimedRole = (user.customClaims?.role as string | undefined) ?? null;
    return {email: user.email ?? null, role: claimedRole};
  } catch (err) {
    logger.debug("audit.resolveActor failed", {uid, err: String(err)});
    return {email: null, role: null};
  }
}

/**
 * Writes a single audit event to the `audit_log` Firestore collection.
 * Failures are logged but never thrown — audit logging must not break
 * the originating user action.
 *
 * @param {WriteAuditInput} input Event details (actor, action, target).
 * @return {Promise<void>} Resolves once the write completes.
 */
export async function writeAuditEvent(input: WriteAuditInput): Promise<void> {
  const db = getFirestore();
  const actor = await resolveActor(input.actorUid);

  const event: AuditEvent = {
    timestamp: Timestamp.now(),
    actorUid: input.actorUid ?? "anonymous",
    actorEmail: actor.email,
    actorRole: actor.role,
    action: input.action,
    collection: input.collection,
    documentId: input.documentId,
    documentPath: input.documentPath,
    dspUid: input.dspUid ?? null,
    changedFields: input.changedFields,
    metadata: input.metadata,
  };

  try {
    await db.collection("audit_log").add(event);
  } catch (err) {
    logger.error("audit.write failed", {err: String(err), event});
  }
}
