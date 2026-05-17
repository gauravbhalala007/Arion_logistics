#!/usr/bin/env bash
# migration/eu/scripts/03-export-old.sh
#
# CUTOVER-Schritt 1: Vollexport des alten Projekts.
#  - Auth-User komplett (mit Passwort-Hashes)
#  - Firestore alle Collections → GCS-Bucket
#  - Storage-Files werden NICHT exportiert, sondern in Script 04 direkt
#    von OLD nach NEW kopiert (gsutil rsync).
#
# WICHTIG: Dieses Script SETZT das Wartungs-Flag im alten Projekt,
# damit ab jetzt keine Schreibzugriffe mehr kommen.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./env.example
source "$SCRIPT_DIR/.env"

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
LOG_FILE="$SCRIPT_DIR/../exports/log-export-$TIMESTAMP.txt"
mkdir -p "$(dirname "$LOG_FILE")"

AUTH_OUT="$SCRIPT_DIR/../exports/auth-$TIMESTAMP.json"

log() { echo "[$(date '+%H:%M:%S')] $*" | tee -a "$LOG_FILE"; }

log "═══════════════════════════════════════════════════════"
log "  CUTOVER 1/4 — Export aus $OLD_PROJECT_ID"
log "═══════════════════════════════════════════════════════"

# 0) Wartungs-Flag setzen → keine neuen Schreibzugriffe von Clients
log "→ Wartungs-Flag aktivieren in $OLD_PROJECT_ID"
firebase use "$OLD_PROJECT_ID"
firebase firestore:write _system/flags \
  '{"maintenance": true, "maintenanceMessage": "Migration laeuft — bitte warten."}' \
  --project "$OLD_PROJECT_ID" 2>&1 | tee -a "$LOG_FILE" || \
    log "WARN: firestore:write nicht verfuegbar, alternativ Console nutzen"

sleep 5
log "→ Pruefen, dass keine aktiven Schreibvorgaenge mehr laufen (10s)"
sleep 10

# 1) Auth-Export
log "→ Auth-Export → $AUTH_OUT"
firebase auth:export "$AUTH_OUT" --format=json \
  --project "$OLD_PROJECT_ID" 2>&1 | tee -a "$LOG_FILE"
AUTH_COUNT=$(jq '.users | length' "$AUTH_OUT")
log "  Exportierte Auth-User: $AUTH_COUNT"

# 2) Export-Bucket sicherstellen
EXPORT_PREFIX="firestore-$TIMESTAMP"
log "→ GCS Export-Bucket: gs://$EXPORT_BUCKET (wird angelegt falls noetig)"
gcloud config set project "$OLD_PROJECT_ID" 2>&1 | tee -a "$LOG_FILE"
if ! gsutil ls -b "gs://$EXPORT_BUCKET" >/dev/null 2>&1; then
  log "  Bucket existiert nicht, erstelle in europe-west3..."
  gsutil mb -p "$OLD_PROJECT_ID" -c STANDARD -l EUROPE-WEST3 \
    "gs://$EXPORT_BUCKET" 2>&1 | tee -a "$LOG_FILE"
fi

# 3) Firestore-Export
log "→ Firestore-Export → gs://$EXPORT_BUCKET/$EXPORT_PREFIX"
OPERATION_NAME=$(gcloud firestore export \
  "gs://$EXPORT_BUCKET/$EXPORT_PREFIX" \
  --project "$OLD_PROJECT_ID" \
  --format='value(name)' 2>&1 | tee -a "$LOG_FILE" | tail -1)

log "  Operation: $OPERATION_NAME"
log "  Warte auf Abschluss..."

# Polling auf Operation-Status (kann 5-30 min dauern)
while true; do
  STATE=$(gcloud firestore operations describe "$OPERATION_NAME" \
    --project "$OLD_PROJECT_ID" \
    --format='value(metadata.operationState)' 2>/dev/null || echo "UNKNOWN")
  log "  State: $STATE"
  if [[ "$STATE" == "SUCCESSFUL" ]]; then
    log "  ✅ Firestore-Export abgeschlossen"
    break
  fi
  if [[ "$STATE" == "FAILED" ]] || [[ "$STATE" == "CANCELLED" ]]; then
    log "  ❌ Firestore-Export fehlgeschlagen ($STATE)"
    exit 1
  fi
  sleep 30
done

# 4) Pfad speichern fuer Import-Script
echo "$EXPORT_PREFIX" > "$SCRIPT_DIR/../exports/last-export-prefix.txt"
echo "$AUTH_OUT" > "$SCRIPT_DIR/../exports/last-auth-export.txt"

log ""
log "✅ Export komplett. Naechster Schritt: ./04-import-eu.sh"
log "   Export-Prefix: $EXPORT_PREFIX"
log "   Auth-File:     $AUTH_OUT"
log "   Auth-Users:    $AUTH_COUNT"
log "   Log:           $LOG_FILE"
