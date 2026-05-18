/* eslint-disable max-len, require-jsdoc, valid-jsdoc, object-curly-spacing, operator-linebreak, indent, no-trailing-spaces, eol-last, quotes, comma-dangle */
// firebase/functions/src/timeTracking/clockOut.ts
//
// Pendant zu clockIn: beendet die offene Schicht, schließt offene
// Pausen, rechnet workDuration aus, prüft ArbZG-Compliance.

import {onCall, HttpsError} from "firebase-functions/v2/https";
import {getFirestore, Timestamp} from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";

import {matchGeofence} from "./geofence";
import {runMonthlyCompute} from "./computeMonthlyAccount";

const REGION = "europe-west3";

interface ClockOutRequest {
  lat: number;
  lng: number;
  accuracy: number;
  clientTime: number;
  deviceInfo?: {
    platform: "ios" | "android" | "web";
    appVersion: string;
  };
}

interface PauseSpan {
  start: Timestamp;
  end: Timestamp | null;
  durationSec: number;
}

export const clockOut = onCall<ClockOutRequest>(
  {region: REGION, cors: true},
  async (req) => {
    const uid = req.auth?.uid;
    const token = req.auth?.token;
    if (!uid || !token) throw new HttpsError("unauthenticated", "Login required");
    const role = (token.role as string | undefined) ?? "";
    if (role !== "driver") {
      throw new HttpsError("permission-denied", "Driver role required");
    }
    const adminUid = (token.dspUid as string | undefined) ?? "";
    const driverId = (token.driverId as string | undefined) ?? "";
    if (!adminUid || !driverId) {
      throw new HttpsError("failed-precondition", "Driver claims missing");
    }

    const data = req.data;
    if (typeof data.lat !== "number" || typeof data.lng !== "number") {
      throw new HttpsError("invalid-argument", "lat/lng required");
    }

    const db = getFirestore();
    const driverPath = `users/${adminUid}/drivers/${driverId}`;

    // Offene Schicht holen
    const openSnap = await db
      .collection(`${driverPath}/shifts`)
      .where("isOpen", "==", true)
      .limit(1)
      .get();
    if (openSnap.empty) {
      throw new HttpsError(
        "failed-precondition",
        "Keine laufende Schicht zum Beenden",
      );
    }
    const shiftDoc = openSnap.docs[0];
    const shift = shiftDoc.data();
    const stationCode = (shift.stationCode as string) ?? "";

    // Geofence-Check für Clock-Out (optional, hier loose: nur warnen)
    let geoMatched = false;
    let geofenceId: string | null = null;
    if (stationCode) {
      const stationSnap = await db
        .collection("users")
        .doc(adminUid)
        .collection("stations")
        .doc(stationCode)
        .get();
      if (stationSnap.exists) {
        const fences = (stationSnap.data()?.geofences ?? []) as any[];
        const geo = matchGeofence(
          data.lat,
          data.lng,
          data.accuracy ?? 0,
          fences,
        );
        geoMatched = geo.matched;
        geofenceId = geo.geofenceId;
      }
    }

    // Falls noch eine offene Pause → automatisch schließen
    const pauses = (shift.pauses ?? []) as PauseSpan[];
    const updatedPauses = pauses.map((p) => ({...p}));
    const lastOpenPause = updatedPauses.findIndex((p) => p.end === null);

    const now = Timestamp.now();

    if (lastOpenPause >= 0) {
      const p = updatedPauses[lastOpenPause];
      const start = (p.start as Timestamp).toMillis();
      p.end = now;
      p.durationSec = Math.max(0, Math.round((now.toMillis() - start) / 1000));
    }

    const startTs = (shift.startTs as Timestamp).toMillis();
    const totalDuration = Math.max(0, Math.round((now.toMillis() - startTs) / 1000));
    const pauseDuration = updatedPauses.reduce(
      (sum, p) => sum + (p.durationSec || 0),
      0,
    );
    const workDuration = Math.max(0, totalDuration - pauseDuration);

    // ArbZG-Compliance-Checks
    const warnings: string[] = [];
    const workHours = workDuration / 3600;
    const minBreakMet =
      workHours <= 6 ||
      (workHours <= 9 && pauseDuration >= 1800) ||
      (workHours > 9 && pauseDuration >= 2700);
    if (!minBreakMet) {
      warnings.push(
        workHours <= 9 ?
          "Mindestpause 30 min bei >6 h Arbeitszeit nicht erfüllt" :
          "Mindestpause 45 min bei >9 h Arbeitszeit nicht erfüllt",
      );
    }
    if (totalDuration / 3600 > 10) {
      warnings.push("Schichtdauer über 10 h (ArbZG §3)");
    }

    const entryRef = db.collection(`${driverPath}/time_entries`).doc();
    const auditRef = db
      .collection(`users/${adminUid}/time_audit_log`)
      .doc();

    const batch = db.batch();
    batch.update(shiftDoc.ref, {
      endTs: now,
      totalDuration,
      pauseDuration,
      workDuration,
      pauses: updatedPauses,
      complianceFlags: {
        minBreakMet,
        maxShiftLengthOk: totalDuration / 3600 <= 10,
        warnings,
      },
      isOpen: false,
      closedAt: now,
    });
    batch.set(entryRef, {
      type: "shift_end",
      ts: now,
      clientReportedAt: data.clientTime ?
        Timestamp.fromMillis(data.clientTime) :
        null,
      stationCode,
      location: {
        geofenceId,
        geofenceMatched: geoMatched,
        accuracy: data.accuracy ?? null,
      },
      deviceInfo: {
        platform: data.deviceInfo?.platform ?? "unknown",
        appVersion: data.deviceInfo?.appVersion ?? "",
      },
      shiftId: shiftDoc.id,
      createdAt: now,
    });
    batch.set(auditRef, {
      type: "shift_ended",
      driverId,
      shiftId: shiftDoc.id,
      entryId: entryRef.id,
      ts: now,
      actor: {uid, role: "driver"},
      details: {workDuration, warnings},
    });
    await batch.commit();

    // Zeitkonto sofort aktualisieren — der Admin sieht im Zeitkonto-Tab
    // direkt die neue Ist/Saldo-Zahl, ohne auf den 03:00-Cron zu warten.
    // Fehler werden nur geloggt; der Stempel selbst muss erfolgreich
    // zurückkommen.
    try {
      const ymNow = new Date(now.toDate())
        .toLocaleDateString("sv-SE", {timeZone: "Europe/Berlin"})
        .slice(0, 7);
      await runMonthlyCompute({forAdminUid: adminUid, forMonth: ymNow});
    } catch (e) {
      logger.warn("Auto-recompute after clockOut failed", e);
    }

    return {
      ok: true,
      shiftId: shiftDoc.id,
      entryId: entryRef.id,
      workDuration,
      warnings,
    };
  },
);
