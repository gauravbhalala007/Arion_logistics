/* eslint-disable max-len, require-jsdoc, valid-jsdoc, object-curly-spacing, operator-linebreak, indent, no-trailing-spaces, eol-last, quotes, comma-dangle */
// firebase/functions/src/timeTracking/types.ts
//
// Datentypen für das Zeiterfassungs-Modul. Spiegelt das Datenmodell aus
// docs/time-tracking-plan.md.

export type StempelType =
  | "shift_start"
  | "pause_start"
  | "pause_end"
  | "shift_end";

export interface Geofence {
  id: string;
  centerLat: number;
  centerLng: number;
  radiusMeters: number;
}

export interface StationDoc {
  code: string;
  label: string;
  geofences: Geofence[];
  bundesland: string;
  timezone: string;
  // Wird beim Stempeln gegen den signierten QR-Token geprüft
  qrSecretVersion?: number;
}

export interface ClockInRequest {
  stationCode: string;
  lat: number;
  lng: number;
  accuracy: number;
  qrToken: string; // HMAC-signiert von Hub-Sticker
  clientTime: number; // Unix-ms vom Client (nur als Referenz)
  deviceInfo: {
    platform: "ios" | "android" | "web";
    appVersion: string;
  };
}

export interface ClockInResult {
  ok: boolean;
  shiftId: string;
  entryId: string;
  ts: number;
  warnings: string[];
}
