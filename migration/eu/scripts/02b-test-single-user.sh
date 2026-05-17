#!/usr/bin/env bash
# migration/eu/scripts/02b-test-single-user.sh
#
# Trockenlauf: exportiert EINEN Auth-User aus dem alten Projekt und
# importiert ihn ins EU-Projekt. Damit verifizieren wir, dass
# Hash-Parameter korrekt sind und Login funktioniert.
#
# Nach erfolgreichem Test: User wieder aus EU-Projekt loeschen.
#
# Aufruf:
#   ./02b-test-single-user.sh <EMAIL_VOM_TESTUSER>

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./env.example
source "$SCRIPT_DIR/.env"

if [[ $# -lt 1 ]]; then
  echo "Aufruf: $0 <email-vom-testuser@beispiel.de>"
  echo "Tipp: nutze einen Beta-Tester-Account, der eh weiss, dass migriert wird."
  exit 1
fi

TEST_EMAIL="$1"
LOG_FILE="$SCRIPT_DIR/../exports/log-test-$(date +%Y%m%d-%H%M%S).txt"
mkdir -p "$(dirname "$LOG_FILE")"
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

log() { echo "[$(date '+%H:%M:%S')] $*" | tee -a "$LOG_FILE"; }

log "═══════════════════════════════════════════════════════"
log "  Trockenlauf — Single-User-Migration"
log "  Test-Email: $TEST_EMAIL"
log "═══════════════════════════════════════════════════════"

# 1) Vollexport aus altem Projekt (nur Auth, kein Firestore)
log "→ Auth-Export aus $OLD_PROJECT_ID"
firebase use "$OLD_PROJECT_ID"
firebase auth:export "$TMPDIR/auth-full.json" --format=json \
  --project "$OLD_PROJECT_ID" 2>&1 | tee -a "$LOG_FILE"

# 2) Nur den Test-User extrahieren via jq
log "→ Filter Test-User per jq"
jq --arg email "$TEST_EMAIL" \
   '{users: [.users[] | select(.email == $email)]}' \
   "$TMPDIR/auth-full.json" > "$TMPDIR/auth-single.json"

USER_COUNT=$(jq '.users | length' "$TMPDIR/auth-single.json")
if [[ "$USER_COUNT" -ne 1 ]]; then
  log "ERROR: Erwarte genau 1 User mit Email '$TEST_EMAIL', fand $USER_COUNT."
  exit 1
fi

USER_UID=$(jq -r '.users[0].localId' "$TMPDIR/auth-single.json")
log "→ Extrahierter User: uid=$USER_UID"

# 3) Import ins EU-Projekt
log "→ Import in $NEW_PROJECT_ID"
firebase use "$NEW_PROJECT_ID"
firebase auth:import "$TMPDIR/auth-single.json" \
  --hash-algo=scrypt \
  --rounds="${AUTH_ROUNDS:-8}" \
  --mem-cost="${AUTH_MEM_COST:-14}" \
  --hash-key="${AUTH_HASH_KEY?Bitte AUTH_HASH_KEY in .env setzen!}" \
  --salt-separator="${AUTH_SALT_SEPARATOR?Bitte AUTH_SALT_SEPARATOR in .env setzen!}" \
  --project "$NEW_PROJECT_ID" 2>&1 | tee -a "$LOG_FILE"

log ""
log "✅ Test-User importiert."
log ""
log "MANUELLER VERIFIKATIONS-SCHRITT:"
log "  1) Im Browser: Firebase Console → $NEW_PROJECT_ID → Authentication"
log "     → User $USER_UID sollte gelistet sein."
log "  2) Optional Login-Test:"
log "     a) Flutter lokal mit --dart-define=FB_PROJECT=$NEW_PROJECT_ID starten"
log "     b) Mit Email '$TEST_EMAIL' + ALTES Passwort einloggen"
log "     c) Erwartung: Login klappt -> Hash-Parameter sind korrekt"
log ""
log "DANACH AUFRAEUMEN:"
log "  firebase auth:delete $USER_UID --project $NEW_PROJECT_ID"
log ""
log "Log: $LOG_FILE"
