#!/usr/bin/env bash
# migration/eu/scripts/99-final-cleanup.sh
#
# T+14 NACH CUTOVER: Final-Backup des alten Projekts + Anleitung zum
# Loeschen. Loescht das Projekt NICHT direkt — das muss manuell im
# Console passieren (30-Tage-Kulanzfrist von Google).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./env.example
source "$SCRIPT_DIR/.env"

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
LOG_FILE="$SCRIPT_DIR/../exports/log-cleanup-$TIMESTAMP.txt"
log() { echo "[$(date '+%H:%M:%S')] $*" | tee -a "$LOG_FILE"; }

log "═══════════════════════════════════════════════════════"
log "  FINAL-CLEANUP — Alt-Projekt nach erfolgreicher Migration"
log "═══════════════════════════════════════════════════════"
log ""

read -r -p "Bist du SICHER, dass das EU-Projekt seit >=14 Tagen stabil laeuft? (yes/no) " confirm
if [[ "$confirm" != "yes" ]]; then
  log "Abgebrochen."
  exit 0
fi

read -r -p "Hat KEIN Tester in den letzten 14 Tagen Datenverlust gemeldet? (yes/no) " confirm2
if [[ "$confirm2" != "yes" ]]; then
  log "Abgebrochen. Lieber nochmal warten."
  exit 0
fi

# 1) Final-Backup nach codriver-eu-final-backup
FINAL_BACKUP_BUCKET="${NEW_PROJECT_ID}-final-old-backup"
log "→ Final-Backup-Bucket sicherstellen: gs://$FINAL_BACKUP_BUCKET"
gcloud config set project "$NEW_PROJECT_ID"
if ! gsutil ls -b "gs://$FINAL_BACKUP_BUCKET" >/dev/null 2>&1; then
  gsutil mb -p "$NEW_PROJECT_ID" -c COLDLINE -l EUROPE-WEST3 \
    "gs://$FINAL_BACKUP_BUCKET" 2>&1 | tee -a "$LOG_FILE"
fi

# 2) Firestore-Final-Export aus altem Projekt
log "→ Firestore-Final-Export aus $OLD_PROJECT_ID"
gcloud config set project "$OLD_PROJECT_ID"
OPERATION_NAME=$(gcloud firestore export \
  "gs://$FINAL_BACKUP_BUCKET/firestore-final-$TIMESTAMP" \
  --project "$OLD_PROJECT_ID" \
  --format='value(name)' 2>&1 | tee -a "$LOG_FILE" | tail -1)

while true; do
  STATE=$(gcloud firestore operations describe "$OPERATION_NAME" \
    --project "$OLD_PROJECT_ID" \
    --format='value(metadata.operationState)' 2>/dev/null || echo "UNKNOWN")
  log "  State: $STATE"
  if [[ "$STATE" == "SUCCESSFUL" ]]; then break; fi
  if [[ "$STATE" == "FAILED" || "$STATE" == "CANCELLED" ]]; then
    log "  ❌ Backup fehlgeschlagen"
    exit 1
  fi
  sleep 30
done

# 3) Storage-Final-Copy
log "→ Storage-Final-Copy"
gsutil -m cp -r "gs://$OLD_BUCKET" \
  "gs://$FINAL_BACKUP_BUCKET/storage-final-$TIMESTAMP/" 2>&1 | tee -a "$LOG_FILE"

log ""
log "✅ Final-Backup erstellt."
log "   gs://$FINAL_BACKUP_BUCKET/firestore-final-$TIMESTAMP"
log "   gs://$FINAL_BACKUP_BUCKET/storage-final-$TIMESTAMP"
log ""
log "MANUELLER LETZTER SCHRITT (im Firebase Console):"
log "  1) https://console.firebase.google.com/project/$OLD_PROJECT_ID/settings/general/"
log "  2) Scrolle ganz nach unten → 'Diesen Firebase-Projekt loeschen'"
log "  3) Bestaetigen — Google haelt das Projekt 30 Tage in Quarantaene"
log "     (umkehrbar bis dahin), dann endgueltige Loeschung."
log ""
log "  Final-Backup im EU-Projekt bleibt 90 Tage (COLDLINE = guenstig)."
log ""
log "Log: $LOG_FILE"
