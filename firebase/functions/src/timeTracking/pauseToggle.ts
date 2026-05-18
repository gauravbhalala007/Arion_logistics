/* eslint-disable max-len, require-jsdoc, valid-jsdoc, object-curly-spacing, operator-linebreak, indent, no-trailing-spaces, eol-last, quotes, comma-dangle */
// firebase/functions/src/timeTracking/pauseToggle.ts
//
// Pause start / Pause end — eine Funktion, sie schließt die offene
// Pause oder startet eine neue, je nach aktuellem Zustand.

import {onCall, HttpsError} from "firebase-functions/v2/https";
import {getFirestore, Timestamp} from "firebase-admin/firestore";

const REGION = "europe-west3";

interface PauseToggleResult {
  ok: boolean;
  newState: "pause_started" | "pause_ended";
  pauseDuration: number;
}

interface PauseSpan {
  start: Timestamp;
  end: Timestamp | null;
  durationSec: number;
}

export const pauseToggle = onCall<unknown, Promise<PauseToggleResult>>(
  {region: REGION, cors: true},
  async (req) => {
    const uid = req.auth?.uid;
    const token = req.auth?.token;
    if (!uid || !token) throw new HttpsError("unauthenticated", "Login required");
    if (token.role !== "driver") {
      throw new HttpsError("permission-denied", "Driver role required");
    }
    const adminUid = (token.dspUid as string | undefined) ?? "";
    const driverId = (token.driverId as string | undefined) ?? "";
    if (!adminUid || !driverId) {
      throw new HttpsError("failed-precondition", "Driver claims missing");
    }

    const db = getFirestore();
    const driverPath = `users/${adminUid}/drivers/${driverId}`;

    const openSnap = await db
      .collection(`${driverPath}/shifts`)
      .where("isOpen", "==", true)
      .limit(1)
      .get();
    if (openSnap.empty) {
      throw new HttpsError(
        "failed-precondition",
        "Keine laufende Schicht — bitte erst einstempeln",
      );
    }

    const shiftDoc = openSnap.docs[0];
    const shift = shiftDoc.data();
    const pauses = ((shift.pauses ?? []) as PauseSpan[]).map((p) => ({...p}));
    const now = Timestamp.now();
    const openIdx = pauses.findIndex((p) => p.end === null);

    const entryRef = db.collection(`${driverPath}/time_entries`).doc();
    const auditRef = db
      .collection(`users/${adminUid}/time_audit_log`)
      .doc();

    let newState: PauseToggleResult["newState"];
    let pauseDuration = 0;

    if (openIdx >= 0) {
      // Pause beenden
      const p = pauses[openIdx];
      const start = (p.start as Timestamp).toMillis();
      const durationSec = Math.max(
        0,
        Math.round((now.toMillis() - start) / 1000),
      );
      pauses[openIdx] = {...p, end: now, durationSec};
      pauseDuration = pauses.reduce((s, x) => s + (x.durationSec || 0), 0);
      newState = "pause_ended";

      const batch = db.batch();
      batch.update(shiftDoc.ref, {pauses, pauseDuration});
      batch.set(entryRef, {
        type: "pause_end",
        ts: now,
        stationCode: shift.stationCode,
        shiftId: shiftDoc.id,
        createdAt: now,
      });
      batch.set(auditRef, {
        type: "pause_ended",
        driverId,
        shiftId: shiftDoc.id,
        ts: now,
        actor: {uid, role: "driver"},
        details: {durationSec},
      });
      await batch.commit();
    } else {
      // Neue Pause starten
      pauses.push({start: now, end: null, durationSec: 0});
      newState = "pause_started";

      const batch = db.batch();
      batch.update(shiftDoc.ref, {pauses});
      batch.set(entryRef, {
        type: "pause_start",
        ts: now,
        stationCode: shift.stationCode,
        shiftId: shiftDoc.id,
        createdAt: now,
      });
      batch.set(auditRef, {
        type: "pause_started",
        driverId,
        shiftId: shiftDoc.id,
        ts: now,
        actor: {uid, role: "driver"},
      });
      await batch.commit();
    }

    return {ok: true, newState, pauseDuration};
  },
);
