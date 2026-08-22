// firebase/functions/src/vehicleChecks/types.ts
//
// Gemeinsame Typen + Konstanten der geführten Foto-Fahrzeuginspektion.
//
// Das Check-Dokument liegt unter
//   users/{dspUid}/drivers/{driverId}/incident_reports/{checkId}
// und trägt `kind: "vehicle_check"`. Warum dieser Pfad und nicht ein
// eigener: die Firestore-Rules erlauben dem Fahrer NUR in den explizit
// gelisteten Subcollections zu schreiben und dürfen (Kundenvorgabe) nicht
// angefasst werden. Details siehe
// flutter_app/kpi_admin/lib/services/vehicle_check_service.dart.

/** Marker-Feld, das einen Check von einer echten Unfallmeldung trennt. */
export const VEHICLE_CHECK_KIND = "vehicle_check";

/** Wire-Typ des gespiegelten Fleet-Hub-Events. */
export const VEHICLE_CHECK_EVENT_TYPE = "vehicle_check";

/** Region aller neuen Module (DSGVO — Frankfurt). */
export const VEHICLE_CHECK_REGION = "europe-west3";

/** Kosten-Guard: mehr Bilder gehen nie an das Modell. */
export const MAX_AI_PHOTOS = 9;

export interface CheckPhoto {
  step: string;
  url: string;
  path: string;
}

export interface CheckDamage {
  category: string;
  location: string;
  photoStep?: string;
  comment?: string;
  source?: string;
}

export interface VehicleCheckDoc {
  kind?: string;
  checkId?: string;
  dspUid?: string;
  plate?: string;
  plateKey?: string;
  checkType?: string;
  odometerKm?: number;
  photos?: CheckPhoto[];
  damages?: CheckDamage[];
  driverTransporterId?: string;
  driverName?: string;
  driverUid?: string;
  checkedAt?: FirebaseFirestore.Timestamp;
  aiStatus?: string;
}

/** DE-Label der Schritte — nur für Prompt und Event-Text. */
export const STEP_LABELS: Record<string, string> = {
  front: "Front",
  rear: "Heck",
  left: "Fahrerseite (links)",
  right: "Beifahrerseite (rechts)",
  corner_front_left: "Ecke vorne links",
  corner_rear_right: "Ecke hinten rechts",
  odometer: "Tacho / Kilometerstand",
  interior: "Innenraum",
};

export const CHECK_TYPE_LABELS: Record<string, string> = {
  shift_start: "Schichtbeginn",
  shift_end: "Schichtende",
  handover: "Übergabe",
};

/** Erlaubte Schadenskategorien (identisch zur Flutter-Enum). */
export const DAMAGE_CATEGORIES = [
  "scratch",
  "dent",
  "glass",
  "tire",
  "interior",
  "other",
] as const;

/**
 * Deutsche Tausenderpunkte, damit Event-Text und UI gleich aussehen.
 *
 * @param {number} km Kilometerstand.
 * @return {string} z. B. "84.200".
 */
export function formatKm(km: number): string {
  return new Intl.NumberFormat("de-DE").format(Math.round(km));
}
