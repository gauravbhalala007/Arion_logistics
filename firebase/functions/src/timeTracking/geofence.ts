/* eslint-disable max-len, require-jsdoc, valid-jsdoc, object-curly-spacing, operator-linebreak, indent, no-trailing-spaces, eol-last, quotes, comma-dangle */
// firebase/functions/src/timeTracking/geofence.ts
//
// Geofence-Validierung mit Haversine-Distanz. Wir speichern NIE die
// rohen Koordinaten — wir prüfen nur, ob (lat,lng) innerhalb eines
// definierten Hub-Geofences liegen, und persistieren ausschließlich
// das Boolean-Ergebnis + die geofence-id. So bleibt das System
// DSGVO-konform (keine Bewegungsprofile möglich).

import {Geofence} from "./types";

export function haversineMeters(
  lat1: number,
  lng1: number,
  lat2: number,
  lng2: number,
): number {
  const R = 6371_000; // Erdradius in Metern
  const toRad = (deg: number) => (deg * Math.PI) / 180;
  const dLat = toRad(lat2 - lat1);
  const dLng = toRad(lng2 - lng1);
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLng / 2) ** 2;
  return 2 * R * Math.asin(Math.sqrt(a));
}

export interface GeofenceMatch {
  matched: boolean;
  geofenceId: string | null;
  distanceMeters: number | null;
}

export function matchGeofence(
  lat: number,
  lng: number,
  accuracy: number,
  fences: Geofence[],
): GeofenceMatch {
  if (!fences || fences.length === 0) {
    return {matched: false, geofenceId: null, distanceMeters: null};
  }
  // Großzügig: GPS-Ungenauigkeit (accuracy) wird auf den Radius angerechnet.
  // So scheitert der Stempel nicht knapp am Zaun bei schlechtem Empfang.
  let best: GeofenceMatch = {
    matched: false,
    geofenceId: null,
    distanceMeters: Infinity,
  };
  for (const f of fences) {
    const dist = haversineMeters(lat, lng, f.centerLat, f.centerLng);
    const effectiveRadius = f.radiusMeters + Math.min(accuracy ?? 0, 50);
    if (dist <= effectiveRadius && dist < (best.distanceMeters ?? Infinity)) {
      best = {matched: true, geofenceId: f.id, distanceMeters: dist};
    }
  }
  if (best.matched) return best;
  return {matched: false, geofenceId: null, distanceMeters: null};
}
