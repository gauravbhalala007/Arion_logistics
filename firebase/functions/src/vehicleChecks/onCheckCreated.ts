/* eslint-disable max-len */
// firebase/functions/src/vehicleChecks/onCheckCreated.ts
//
// Firestore-Trigger auf
//   users/{dspUid}/drivers/{driverId}/incident_reports/{checkId}
//
// Spiegelt jeden abgeschlossenen Fahrzeug-Check als Event nach
//   users/{dspUid}/fleet_events/{eventId}
// damit er in der Events-Spalte der Fahrzeug-Detailseite (Fleet Hub)
// auftaucht. Der Fahrer selbst darf dort NICHT schreiben — die Blanket-Rule
// unter `users/{userId}` gibt `fleet_events` nur an den Admin und seine
// Dispatcher frei. Deshalb dieser Server-Spiegel.
//
// ACHTUNG: derselbe Collection-Pfad trägt auch echte Unfallmeldungen aus
// `driver_incident_report_page.dart` und `work_accident_form.dart`. Der
// Trigger steigt deshalb sofort aus, wenn `kind !== "vehicle_check"`.
//
// Im Anschluss stößt der Trigger die KI-Analyse (Stufe 2) an. Ein Fehler
// dort darf den Event-Spiegel nie zurücknehmen — deswegen strikt getrennte
// try/catch-Blöcke und keinerlei Retry-Schleife (Kosten-Guard).

import {onDocumentCreated} from "firebase-functions/v2/firestore";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";

import {
  CHECK_TYPE_LABELS,
  VEHICLE_CHECK_EVENT_TYPE,
  VEHICLE_CHECK_KIND,
  VEHICLE_CHECK_REGION,
  VehicleCheckDoc,
  formatKm,
} from "./types";
import {analyzeVehicleCheck} from "./analyzeCheck";

if (admin.apps.length === 0) {
  admin.initializeApp();
}

/**
 * Baut die Untertitel-Zeile des Fleet-Events.
 *
 * @param {VehicleCheckDoc} check Das Check-Dokument.
 * @return {string} z. B. "8 Fotos · 2 Schäden · KM 84.200 · Israfil Topi".
 */
function buildSubtitle(check: VehicleCheckDoc): string {
  const photos = check.photos?.length ?? 0;
  const damages = check.damages?.length ?? 0;
  const parts = [
    `${photos} Fotos`,
    `${damages} Schäden`,
    `KM ${formatKm(check.odometerKm ?? 0)}`,
  ];
  const name = (check.driverName ?? "").trim();
  if (name) parts.push(name);
  return parts.join(" · ");
}

export const onVehicleCheckCreated = onDocumentCreated(
  {
    document: "users/{dspUid}/drivers/{driverId}/incident_reports/{checkId}",
    region: VEHICLE_CHECK_REGION,
    // Bildanalyse lädt bis zu 9 JPEGs in den Speicher.
    memory: "1GiB",
    timeoutSeconds: 300,
  },
  async (event) => {
    const snap = event.data;
    if (!snap) return;

    const check = snap.data() as VehicleCheckDoc;
    if (check?.kind !== VEHICLE_CHECK_KIND) {
      // Echte Unfallmeldung im selben Pfad — nicht unser Fall.
      return;
    }

    const {dspUid, checkId} = event.params as {
      dspUid: string;
      driverId: string;
      checkId: string;
    };
    const db = admin.firestore();

    // ── 1. Fleet-Hub-Spiegel ────────────────────────────────────────────
    try {
      const typeLabel =
        CHECK_TYPE_LABELS[check.checkType ?? ""] ?? "Fahrzeug-Check";
      const firstPhoto = check.photos?.[0]?.url ?? "";
      await db
        .collection("users")
        .doc(dspUid)
        .collection("fleet_events")
        .doc(checkId)
        .set({
          plateKey: check.plateKey ?? "",
          plate: check.plate ?? "",
          type: VEHICLE_CHECK_EVENT_TYPE,
          title: `Fahrzeug-Check · ${typeLabel}`,
          subtitle: buildSubtitle(check),
          date: check.checkedAt ?? admin.firestore.FieldValue.serverTimestamp(),
          km: check.odometerKm ?? null,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          createdBy: check.driverUid ?? "",
          // Der Klick auf das Event öffnet damit die Check-Detailansicht.
          checkPath: snap.ref.path,
          checkId,
          driverTransporterId: check.driverTransporterId ?? "",
          driverName: check.driverName ?? "",
          damageCount: check.damages?.length ?? 0,
          photoCount: check.photos?.length ?? 0,
          fileUrl: firstPhoto,
          fileName: firstPhoto ? "vehicle-check.jpg" : "",
        });
      logger.info("vehicleCheck: fleet event mirrored", {dspUid, checkId});
    } catch (err) {
      logger.error("vehicleCheck: mirroring failed", {
        dspUid,
        checkId,
        error: `${err}`,
      });
      // Bewusst kein throw: ein fehlgeschlagener Spiegel darf nicht dazu
      // führen, dass die (teure) KI-Analyse bei jedem Retry erneut läuft.
    }

    // ── 2. KI-Analyse (Stufe 2) ─────────────────────────────────────────
    await analyzeVehicleCheck(snap.ref, check);
  },
);
