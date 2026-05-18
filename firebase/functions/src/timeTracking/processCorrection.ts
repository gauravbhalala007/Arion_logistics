/* eslint-disable max-len, require-jsdoc, valid-jsdoc, object-curly-spacing, operator-linebreak, indent, no-trailing-spaces, eol-last, quotes, comma-dangle */
// firebase/functions/src/timeTracking/processCorrection.ts
//
// Admin (oder Dispatcher des Admins) genehmigt oder lehnt einen
// Korrektur-Antrag eines Drivers ab.
//
// Bei `approve` wird der zugehörige Shift entsprechend aktualisiert
// (start/end/pauses), bei `reject` nur der Antragsstatus auf
// `rejected` gesetzt + Audit-Log. Genehmigung sollte am Ende auch
// das monatliche Aggregat neu rechnen — wir markieren das Feld
// `needsRecompute: true` auf dem Shift, der nächste Scheduled-Job
// nimmt es dann mit auf.

import {onCall, HttpsError} from "firebase-functions/v2/https";
import {getFirestore, Timestamp} from "firebase-admin/firestore";

const REGION = "europe-west3";

interface ProcessCorrectionRequest {
  driverPath: string; // "users/{adminUid}/drivers/{driverId}"
  requestId: string;
  action: "approve" | "reject";
  comment?: string;
}

export const processCorrectionRequest = onCall<ProcessCorrectionRequest>(
  {region: REGION, cors: true},
  async (req) => {
    const uid = req.auth?.uid;
    const token = req.auth?.token;
    if (!uid || !token) throw new HttpsError("unauthenticated", "Login");

    const role = (token.role as string | undefined) ?? "";
    // Driver dürfen Anträge NIE selbst entscheiden — explizit ablehnen.
    if (role === "driver") {
      throw new HttpsError("permission-denied", "Driver cannot decide");
    }

    const {driverPath, requestId, action, comment} = req.data;
    if (!driverPath || !requestId || !action) {
      throw new HttpsError("invalid-argument", "Missing fields");
    }
    if (action !== "approve" && action !== "reject") {
      throw new HttpsError("invalid-argument", "action must be approve|reject");
    }

    // Bestimme den effektiven Admin-Kontext:
    //  • Dispatcher → parentAdminUid aus Token
    //  • Alle anderen (typischer DSP-Admin) → eigene uid
    // DSP-Admins haben in dieser App üblicherweise KEIN `role`-Claim;
    // `role` wird nur von createDriverLogin / createDispatcherAccount
    // gesetzt. Daher muss der Default „uid" greifen.
    const adminUid = role === "dispatcher" ?
      ((token.parentAdminUid as string | undefined) ?? "") :
      uid;
    if (!adminUid) {
      throw new HttpsError("permission-denied", "No admin context");
    }
    if (!driverPath.startsWith(`users/${adminUid}/`)) {
      throw new HttpsError("permission-denied", "Foreign driver");
    }

    const db = getFirestore();
    const reqRef = db.collection(`${driverPath}/correction_requests`).doc(requestId);
    const reqSnap = await reqRef.get();
    if (!reqSnap.exists) {
      throw new HttpsError("not-found", "Antrag nicht gefunden");
    }
    const r = reqSnap.data() ?? {};
    if (r.status !== "pending") {
      throw new HttpsError(
        "failed-precondition",
        "Antrag bereits entschieden",
      );
    }

    const now = Timestamp.now();
    const auditRef = db.collection(`users/${adminUid}/time_audit_log`).doc();
    const batch = db.batch();

    batch.update(reqRef, {
      status: action === "approve" ? "approved" : "rejected",
      decidedAt: now,
      decidedBy: uid,
      comment: comment ?? null,
    });

    // Bei Approve: wenn ein shiftId in requestedChanges hinterlegt ist,
    // markieren wir die Schicht für Recompute. Die tatsächliche
    // Übernahme der Werte passiert in einem separaten Schritt (Phase 2).
    if (action === "approve" && r.requestedChanges) {
      const changes = r.requestedChanges as Record<string, unknown>;
      const targetShiftId = (changes.shiftId as string | undefined) ?? null;
      if (targetShiftId) {
        const shiftRef = db
          .collection(`${driverPath}/shifts`)
          .doc(targetShiftId);
        batch.set(
          shiftRef,
          {
            correction: {applied: false, requestId},
            needsRecompute: true,
            lastCorrectionAt: now,
          },
          {merge: true},
        );
      }
    }

    batch.set(auditRef, {
      type: `correction_${action}d`,
      requestId,
      driverPath,
      ts: now,
      actor: {uid, role},
      details: {comment: comment ?? null},
    });

    await batch.commit();

    return {ok: true, status: action === "approve" ? "approved" : "rejected"};
  },
);
