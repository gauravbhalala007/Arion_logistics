#!/usr/bin/env bash
# CoDriver — Zweite Firestore-Database `time-tracking` in eur3 anlegen
# Bestands-DB `(default)` in nam5 bleibt unberührt.

set -euo pipefail

PROJECT_ID="gaurav-arion-001-3d94a"
DB_ID="time-tracking"
LOCATION="eur3"

echo "═══════════════════════════════════════════════════════"
echo "  CoDriver — Neue Firestore-Database anlegen"
echo "═══════════════════════════════════════════════════════"
echo "  Project : ${PROJECT_ID}"
echo "  Database: ${DB_ID}"
echo "  Location: ${LOCATION} (Frankfurt)"
echo ""

# Project verifizieren
ACTIVE_PROJECT=$(gcloud config get-value project 2>/dev/null || echo "")
if [ "${ACTIVE_PROJECT}" != "${PROJECT_ID}" ]; then
  echo "⚠  gcloud project ist ${ACTIVE_PROJECT}, sollte ${PROJECT_ID} sein."
  exit 1
fi

# Bereits vorhanden?
if gcloud firestore databases describe \
   --database="${DB_ID}" >/dev/null 2>&1; then
  echo "→ Database ${DB_ID} existiert bereits, OK"
else
  echo "→ Erstelle Database ${DB_ID}..."
  gcloud firestore databases create \
    --database="${DB_ID}" \
    --location="${LOCATION}" \
    --type=firestore-native \
    --project="${PROJECT_ID}"
  echo "  ✓ Database erstellt"
fi

# PITR (Point-in-Time-Recovery) aktivieren — gibt 7 Tage Rollback-Window
echo "→ Aktiviere PITR (Point-in-Time-Recovery)..."
gcloud firestore databases update \
  --database="${DB_ID}" \
  --enable-pitr || echo "  (PITR-Status bereits aktiv)"

# Delete-Protection aktivieren — versehentliches Löschen verhindern
echo "→ Aktiviere Delete-Protection..."
gcloud firestore databases update \
  --database="${DB_ID}" \
  --delete-protection || echo "  (Delete-Protection bereits aktiv)"

# Verifizieren
LOC=$(gcloud firestore databases describe \
  --database="${DB_ID}" \
  --format="value(locationId)")

echo ""
echo "═══════════════════════════════════════════════════════"
echo "  ✓ Database ${DB_ID} live in Location: ${LOC}"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "  Console: https://console.cloud.google.com/firestore/databases/${DB_ID}/data?project=${PROJECT_ID}"
echo ""
echo "  ► Nächster Schritt: ./03-deploy-rules.sh"
