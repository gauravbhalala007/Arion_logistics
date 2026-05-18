/* eslint-disable max-len, require-jsdoc, valid-jsdoc, object-curly-spacing, operator-linebreak, indent, no-trailing-spaces, eol-last, quotes, comma-dangle */
// firebase/functions/src/timeTracking/clockIn.ts
//
// Cloud Function: Driver stempelt sich ein.
//
// Flow:
//  1. Auth-Check — Driver muss eingeloggt sein, role=driver
//  2. Owner-Whitelist — Account-Owner muss das Modul aktiviert haben
//  3. QR-Token verifizieren — HMAC-Match mit Hub-Secret
//  4. Geofence-Check — Server-side Haversine
//  5. Doppel-Stempeln-Schutz — keine offene Schicht parallel
//  6. Schreibe `time_entries/{auto}` + öffne `shifts/{auto}`
//  7. Audit-Log-Eintrag
//
// Alle Reads/Writes laufen gegen die zweite Firestore-Database
// `time-tracking` (eur3 / Frankfurt). Stammdaten kommen aus der
// Default-DB (nam5) — auth.token enthält die nötigen Claims, also
// kein Cross-DB-Read nötig.

import {onCall, HttpsError} from "firebase-functions/v2/https";
import {getFirestore, Timestamp} from "firebase-admin/firestore";
import * as crypto from "node:crypto";

import {ClockInRequest, ClockInResult} from "./types";
import {matchGeofence} from "./geofence";
import {parseQrToken, verifyQrSignature} from "./qrSignature";

// QR-Signatur ist optional. Wenn das Hub-Secret nicht gesetzt ist
// (env-Variable QR_HUB_SECRET fehlt) wird der QR-Path einfach übersprungen
// und nur der Geofence-Check entscheidet. So bleibt die Function ohne
// Secret-Manager-API deploybar; sobald das Feature live geht, setzt man
// das Secret als Env-Variable via `firebase functions:secrets:set`.
// Default-DB liegt schon in eur3 (Frankfurt), GDPR ist erfüllt — kein
// separater Database-Pfad nötig.
const REGION = "europe-west3";

export const clockIn = onCall<ClockInRequest, Promise<ClockInResult>>(
  {
    region: REGION,
    cors: true,
  },
  async (req) => {
    const uid = req.auth?.uid;
    const token = req.auth?.token;
    if (!uid || !token) {
      throw new HttpsError("unauthenticated", "Login required");
    }
    const role = (token.role as string | undefined) ?? "";
    if (role !== "driver") {
      throw new HttpsError("permission-denied", "Driver role required");
    }

    const adminUid = (token.dspUid as string | undefined) ?? "";
    const driverId = (token.driverId as string | undefined) ?? "";
    if (!adminUid || !driverId) {
      throw new HttpsError(
        "failed-precondition",
        "Driver claims missing — please re-login",
      );
    }

    const data = req.data;
    if (typeof data.lat !== "number" || typeof data.lng !== "number") {
      throw new HttpsError("invalid-argument", "lat/lng required as numbers");
    }

    // 1) Optional QR-Token verifizieren — falls vorhanden UND ein
    //    QR_HUB_SECRET in der Function-Env existiert, geben wir dem
    //    Eintrag einen zusätzlichen Vertrauens-Faktor. Pflicht ist's
    //    nicht, der Driver kann auch ohne QR per Swipe stempeln.
    let qrHubId: string | null = null;
    let qrVersion: number | null = null;
    if (data.qrToken) {
      const parsedQr = parseQrToken(data.qrToken);
      const qrSecret = process.env.QR_HUB_SECRET ?? "";
      if (parsedQr && qrSecret && verifyQrSignature(parsedQr, qrSecret)) {
        qrHubId = parsedQr.hubId;
        qrVersion = parsedQr.version;
      }
    }

    // 2) Stammdaten + Time-Writes laufen alle gegen die Default-DB (eur3).
    //    Multi-Station-Support: lade ALLE Stationen des Admins und prüfe
    //    jeden Geofence — der Server wählt automatisch die Station, an
    //    der der Driver gerade steht. Driver, die an mehreren Hubs
    //    aushelfen, müssen daher nicht manuell die Station wechseln.
    const db = getFirestore();
    const stationsSnap = await db
      .collection("users")
      .doc(adminUid)
      .collection("stations")
      .get();

    if (stationsSnap.empty) {
      throw new HttpsError(
        "failed-precondition",
        "Dein Admin hat noch keine Station angelegt.",
      );
    }

    // 3) Geofence-Check über alle Stationen — die erste, deren Geofence
    //    den GPS-Punkt einschließt, gewinnt.
    let matchedStationId: string | null = null;
    let matchedStation: FirebaseFirestore.DocumentData | null = null;
    let matchedGeo: ReturnType<typeof matchGeofence> | null = null;
    for (const sDoc of stationsSnap.docs) {
      const st = sDoc.data();
      const fences = (st.geofences ?? []) as Array<{
        id: string;
        centerLat: number;
        centerLng: number;
        radiusMeters: number;
      }>;
      if (!fences || fences.length === 0) continue;
      const geo = matchGeofence(
        data.lat,
        data.lng,
        data.accuracy ?? 0,
        fences,
      );
      if (geo.matched) {
        matchedStationId = sDoc.id;
        matchedStation = st;
        matchedGeo = geo;
        break;
      }
    }

    if (matchedStation == null || matchedStationId == null ||
        matchedGeo == null) {
      throw new HttpsError(
        "failed-precondition",
        "Du bist an keinem Hub-Standort. Bitte näher an einen Hub und " +
        "erneut stempeln.",
      );
    }

    const station = matchedStation;
    const geo = matchedGeo;
    const stationCode = matchedStationId;

    // 4) Time-Writes — eigene Subcollections unter dem Driver
    const driverPath = `users/${adminUid}/drivers/${driverId}`;

    // Doppel-Stempel-Schutz: gibt es schon eine offene Schicht?
    const openShifts = await db
      .collection(`${driverPath}/shifts`)
      .where("isOpen", "==", true)
      .limit(1)
      .get();
    if (!openShifts.empty) {
      throw new HttpsError(
        "already-exists",
        "Du hast bereits eine laufende Schicht. Bitte erst beenden.",
      );
    }

    // 5) Schreibe Entry + öffne Shift atomar
    const now = Timestamp.now();
    const shiftRef = db.collection(`${driverPath}/shifts`).doc();
    const entryRef = db.collection(`${driverPath}/time_entries`).doc();
    const auditRef = db
      .collection(`users/${adminUid}/time_audit_log`)
      .doc();

    const ipForHash = req.rawRequest?.ip ?? "";
    const ipHash = crypto
      .createHash("sha256")
      .update(ipForHash + adminUid)
      .digest("hex")
      .slice(0, 16);

    const shiftDate = new Date(now.toDate())
      .toLocaleDateString("sv-SE", {
        timeZone: station.timezone ?? "Europe/Berlin",
      });

    const batch = db.batch();
    batch.set(shiftRef, {
      shiftDate,
      startTs: now,
      endTs: null,
      totalDuration: 0,
      pauseDuration: 0,
      workDuration: 0,
      pauses: [],
      complianceFlags: {warnings: []},
      isOpen: true,
      stationCode,
      driverId,
      adminUid,
      createdAt: now,
    });
    batch.set(entryRef, {
      type: "shift_start",
      ts: now,
      clientReportedAt: data.clientTime ?
        Timestamp.fromMillis(data.clientTime) :
        null,
      stationCode,
      location: {
        geofenceId: geo.geofenceId,
        geofenceMatched: true,
        accuracy: data.accuracy ?? null,
      },
      deviceInfo: {
        platform: data.deviceInfo?.platform ?? "unknown",
        appVersion: data.deviceInfo?.appVersion ?? "",
        ipHash,
      },
      shiftId: shiftRef.id,
      qrHubId,
      qrVersion,
      createdAt: now,
    });
    batch.set(auditRef, {
      type: "shift_started",
      driverId,
      shiftId: shiftRef.id,
      entryId: entryRef.id,
      ts: now,
      actor: {uid, role: "driver"},
      details: {stationCode},
    });
    await batch.commit();

    return {
      ok: true,
      shiftId: shiftRef.id,
      entryId: entryRef.id,
      ts: now.toMillis(),
      warnings: [],
    };
  },
);
