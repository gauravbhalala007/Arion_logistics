#!/usr/bin/env bash
# migration/eu/scripts/02a-prep-eu-project.sh
#
# Pre-Cutover: deployt Rules, Indexes und Cloud Functions ins LEERE
# EU-Projekt. Kann beliebig oft Wochen vor dem Cutover laufen — hat
# keinen Effekt auf die Produktion im alten Projekt.
#
# Was passiert:
#   1) Firestore Rules + Indexes nach codriver-eu deployen
#   2) Storage Rules nach codriver-eu deployen
#   3) Alle Cloud Functions (audit, dsgvo, backup, timeTracking, sub-accounts)
#      ins EU-Projekt deployen (in europe-west3)
#
# Voraussetzung: firebase login, gcloud auth login, .env vorhanden.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
# shellcheck source=./env.example
source "$SCRIPT_DIR/.env"

LOG_FILE="$SCRIPT_DIR/../exports/log-prep-$(date +%Y%m%d-%H%M%S).txt"
mkdir -p "$(dirname "$LOG_FILE")"

log() {
  echo "[$(date '+%H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log "═══════════════════════════════════════════════════════"
log "  Pre-Cutover Setup → $NEW_PROJECT_ID"
log "═══════════════════════════════════════════════════════"

# Sanity-Check
if [[ -z "${NEW_PROJECT_ID:-}" ]]; then
  log "ERROR: NEW_PROJECT_ID nicht gesetzt (siehe .env)"
  exit 1
fi

cd "$REPO_ROOT/firebase"

# Aktives Projekt umschalten
log "→ firebase use $NEW_PROJECT_ID"
firebase use "$NEW_PROJECT_ID" 2>&1 | tee -a "$LOG_FILE"

# 1) Firestore Rules + Indexes
log "→ Deploy Firestore Rules + Indexes"
firebase deploy --only firestore:rules,firestore:indexes \
  --project "$NEW_PROJECT_ID" 2>&1 | tee -a "$LOG_FILE"

# 2) Storage Rules
log "→ Deploy Storage Rules"
firebase deploy --only storage \
  --project "$NEW_PROJECT_ID" 2>&1 | tee -a "$LOG_FILE"

# 3) Cloud Functions — alle inkl. neue DSGVO-Module
log "→ Build + Deploy aller Cloud Functions (in $NEW_FUNCTIONS_REGION)"
cd "$REPO_ROOT/firebase/functions"
npm run build 2>&1 | tee -a "$LOG_FILE"
cd "$REPO_ROOT/firebase"
firebase deploy --only functions \
  --project "$NEW_PROJECT_ID" \
  --force 2>&1 | tee -a "$LOG_FILE"

# 4) Artifact-Cleanup-Policy setzen (Container-Image-Bereinigung)
log "→ Artifact-Cleanup-Policy"
firebase functions:artifacts:setpolicy \
  --location "$NEW_FUNCTIONS_REGION" \
  --days 7 \
  --project "$NEW_PROJECT_ID" 2>&1 | tee -a "$LOG_FILE" || \
    log "WARN: Cleanup-Policy konnte nicht gesetzt werden (nicht kritisch)"

log ""
log "✅ Pre-Cutover Setup abgeschlossen."
log "   Naechster Schritt: ./02b-test-single-user.sh"
log "   Log: $LOG_FILE"
