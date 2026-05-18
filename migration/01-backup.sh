#!/usr/bin/env bash
# CoDriver — Vollständiges Backup der Default-Firestore-DB
# Läuft non-blocking gegen die Produktiv-DB, kein Downtime.

set -euo pipefail

PROJECT_ID="gaurav-arion-001-3d94a"
BUCKET="codriver-backups-${PROJECT_ID}"
TIMESTAMP=$(date +%Y-%m-%d-%H%M)
PREFIX="snapshot-${TIMESTAMP}"

echo "═══════════════════════════════════════════════════════"
echo "  CoDriver Firestore-Backup"
echo "═══════════════════════════════════════════════════════"
echo "  Project: ${PROJECT_ID}"
echo "  Bucket : gs://${BUCKET}/"
echo "  Prefix : ${PREFIX}"
echo ""

# 1) Aktuelles Projekt verifizieren
ACTIVE_PROJECT=$(gcloud config get-value project 2>/dev/null || echo "")
if [ "${ACTIVE_PROJECT}" != "${PROJECT_ID}" ]; then
  echo "⚠  gcloud project ist ${ACTIVE_PROJECT}, sollte aber ${PROJECT_ID} sein."
  echo "    Setze mit: gcloud config set project ${PROJECT_ID}"
  exit 1
fi

# 2) GCS-Bucket anlegen falls nicht vorhanden
if ! gcloud storage buckets describe "gs://${BUCKET}" >/dev/null 2>&1; then
  echo "→ Erstelle Backup-Bucket gs://${BUCKET} in europe-west3..."
  gcloud storage buckets create "gs://${BUCKET}" \
    --location=europe-west3 \
    --uniform-bucket-level-access \
    --project="${PROJECT_ID}"
  echo "  ✓ Bucket erstellt"
else
  echo "→ Backup-Bucket existiert bereits, OK"
fi

# 3) Lifecycle-Policy: Backups älter als 90 Tage löschen
LIFECYCLE_FILE=$(mktemp)
cat > "${LIFECYCLE_FILE}" <<EOF
{
  "lifecycle": {
    "rule": [
      {
        "action": {"type": "Delete"},
        "condition": {"age": 90}
      }
    ]
  }
}
EOF
gcloud storage buckets update "gs://${BUCKET}" \
  --lifecycle-file="${LIFECYCLE_FILE}" >/dev/null
rm "${LIFECYCLE_FILE}"
echo "  ✓ Lifecycle-Policy (90 Tage Retention) gesetzt"

# 4) Export starten (asynchron, langläufiger Operation)
echo ""
echo "→ Starte Firestore-Export der (default)-DB..."
OPERATION=$(gcloud firestore export "gs://${BUCKET}/${PREFIX}" \
  --database="(default)" \
  --async \
  --format="value(name)" 2>&1)
echo "  Operation: ${OPERATION}"
echo ""
echo "→ Warte auf Abschluss (kann 5-15 min dauern)..."

# Polling alle 15 Sekunden
while true; do
  STATUS=$(gcloud firestore operations describe "${OPERATION}" \
    --format="value(done)" 2>/dev/null || echo "false")
  if [ "${STATUS}" = "True" ]; then
    break
  fi
  printf "."
  sleep 15
done
echo ""

# 5) Erfolg verifizieren
ERROR=$(gcloud firestore operations describe "${OPERATION}" \
  --format="value(error)" 2>/dev/null || echo "")
if [ -n "${ERROR}" ]; then
  echo "✗ Export fehlgeschlagen: ${ERROR}"
  exit 1
fi

# 6) Inhalt verifizieren
EXPORTED_OBJECTS=$(gcloud storage ls "gs://${BUCKET}/${PREFIX}/" --recursive | wc -l)
echo ""
echo "═══════════════════════════════════════════════════════"
echo "  ✓ Backup erfolgreich abgeschlossen"
echo "═══════════════════════════════════════════════════════"
echo "  Pfad:       gs://${BUCKET}/${PREFIX}/"
echo "  Dateien:    ${EXPORTED_OBJECTS}"
echo "  Console:    https://console.cloud.google.com/storage/browser/${BUCKET}/${PREFIX}"
echo ""
echo "  ► Nächster Schritt: ./02-create-eu-db.sh"
