#!/usr/bin/env bash
# migration/eu/scripts/04-import-eu.sh
#
# CUTOVER-Schritt 2: Import in das EU-Projekt.
#  - Auth-User (mit Passwoertern + Custom Claims)
#  - Firestore-Daten (alle Collections)
#  - Storage-Files via gsutil rsync (parallel)
#  - Flutter-Web neu konfigurieren auf NEW_PROJECT_ID + Build + Hosting-Deploy
#
# Voraussetzung: Script 03 ist erfolgreich gelaufen.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
# shellcheck source=./env.example
source "$SCRIPT_DIR/.env"

if [[ ! -f "$SCRIPT_DIR/../exports/last-export-prefix.txt" ]] || \
   [[ ! -f "$SCRIPT_DIR/../exports/last-auth-export.txt" ]]; then
  echo "ERROR: Export-State nicht gefunden. Lief Script 03 erfolgreich?"
  exit 1
fi

EXPORT_PREFIX=$(cat "$SCRIPT_DIR/../exports/last-export-prefix.txt")
AUTH_OUT=$(cat "$SCRIPT_DIR/../exports/last-auth-export.txt")

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
LOG_FILE="$SCRIPT_DIR/../exports/log-import-$TIMESTAMP.txt"
log() { echo "[$(date '+%H:%M:%S')] $*" | tee -a "$LOG_FILE"; }

log "═══════════════════════════════════════════════════════"
log "  CUTOVER 2/4 — Import in $NEW_PROJECT_ID"
log "═══════════════════════════════════════════════════════"
log "  Export-Prefix: $EXPORT_PREFIX"
log "  Auth-File:     $AUTH_OUT"

# 1) Auth-Import — Passwort-Hashes uebernehmen
log "→ Auth-Import in $NEW_PROJECT_ID"
firebase use "$NEW_PROJECT_ID"
firebase auth:import "$AUTH_OUT" \
  --hash-algo=scrypt \
  --rounds="${AUTH_ROUNDS:-8}" \
  --mem-cost="${AUTH_MEM_COST:-14}" \
  --hash-key="${AUTH_HASH_KEY?Bitte AUTH_HASH_KEY in .env setzen!}" \
  --salt-separator="${AUTH_SALT_SEPARATOR?Bitte AUTH_SALT_SEPARATOR in .env setzen!}" \
  --project "$NEW_PROJECT_ID" 2>&1 | tee -a "$LOG_FILE"

# 2) Firestore-Import
log "→ Firestore-Import — kann 10-30 min dauern"
gcloud config set project "$NEW_PROJECT_ID" 2>&1 | tee -a "$LOG_FILE"
OPERATION_NAME=$(gcloud firestore import \
  "gs://$EXPORT_BUCKET/$EXPORT_PREFIX" \
  --project "$NEW_PROJECT_ID" \
  --format='value(name)' 2>&1 | tee -a "$LOG_FILE" | tail -1)
log "  Operation: $OPERATION_NAME"

while true; do
  STATE=$(gcloud firestore operations describe "$OPERATION_NAME" \
    --project "$NEW_PROJECT_ID" \
    --format='value(metadata.operationState)' 2>/dev/null || echo "UNKNOWN")
  log "  State: $STATE"
  if [[ "$STATE" == "SUCCESSFUL" ]]; then
    log "  ✅ Firestore-Import abgeschlossen"
    break
  fi
  if [[ "$STATE" == "FAILED" ]] || [[ "$STATE" == "CANCELLED" ]]; then
    log "  ❌ Firestore-Import fehlgeschlagen ($STATE)"
    exit 1
  fi
  sleep 30
done

# 3) Storage-Sync (im Hintergrund, kann lange dauern)
log "→ Storage-Sync: gs://$OLD_BUCKET → gs://$NEW_BUCKET"
gsutil -m rsync -r "gs://$OLD_BUCKET" "gs://$NEW_BUCKET" 2>&1 | tee -a "$LOG_FILE"

# 4) Flutter-Web neu konfigurieren
log "→ Flutter neu konfigurieren auf $NEW_PROJECT_ID"
cd "$REPO_ROOT/flutter_app/kpi_admin"
# Backup von alter firebase_options.dart
cp lib/firebase_options.dart "lib/firebase_options.dart.backup-$TIMESTAMP"
flutterfire configure \
  --project="$NEW_PROJECT_ID" \
  --platforms=web,android,ios,macos \
  --yes 2>&1 | tee -a "$LOG_FILE"

# 5) Flutter-Web bauen + Hosting deployen
log "→ Flutter-Web bauen"
flutter build web --release 2>&1 | tee -a "$LOG_FILE"

log "→ Hosting deploy nach $NEW_PROJECT_ID"
firebase deploy --only hosting --project "$NEW_PROJECT_ID" 2>&1 | tee -a "$LOG_FILE"

log ""
log "✅ Import komplett."
log ""
log "NAECHSTE SCHRITTE:"
log "  1) Custom Domain $CUSTOM_DOMAIN im NEW project Hosting verifizieren"
log "  2) DNS A-Record am Registrar auf neue Firebase-IP umstellen"
log "  3) Warten auf DNS-Propagation (dig +short $CUSTOM_DOMAIN)"
log "  4) Smoke-Tests durchfuehren (siehe Cutover-Runbook)"
log "  5) Wartungs-Flag im NEW project deaktivieren:"
log "     firebase firestore:write _system/flags '{\"maintenance\": false}' \\"
log "       --project $NEW_PROJECT_ID"
log ""
log "Log: $LOG_FILE"
