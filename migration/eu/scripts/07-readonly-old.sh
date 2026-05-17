#!/usr/bin/env bash
# migration/eu/scripts/07-readonly-old.sh
#
# POST-CUTOVER (T+1 bis T+14): Altes Projekt komplett auf read-only setzen.
# Daten bleiben erhalten, aber keine Schreibzugriffe mehr moeglich. Falls
# beim Cutover etwas uebersehen wurde, koennen Daten verglichen werden.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
# shellcheck source=./env.example
source "$SCRIPT_DIR/.env"

LOG_FILE="$SCRIPT_DIR/../exports/log-readonly-$(date +%Y%m%d-%H%M%S).txt"
log() { echo "[$(date '+%H:%M:%S')] $*" | tee -a "$LOG_FILE"; }

log "═══════════════════════════════════════════════════════"
log "  POST-CUTOVER — $OLD_PROJECT_ID read-only"
log "═══════════════════════════════════════════════════════"

# Read-only Rules ablegen
RULES_DIR="$SCRIPT_DIR/../readonly-rules"
mkdir -p "$RULES_DIR"

cat > "$RULES_DIR/firestore.readonly.rules" <<'EOF'
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read: if request.auth != null;
      allow write: if false;
    }
  }
}
EOF

cat > "$RULES_DIR/storage.readonly.rules" <<'EOF'
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if false;
    }
  }
}
EOF

cat > "$RULES_DIR/firebase.json" <<EOF
{
  "firestore": {
    "rules": "firestore.readonly.rules"
  },
  "storage": {
    "rules": "storage.readonly.rules"
  }
}
EOF

log "→ Deploy read-only Rules nach $OLD_PROJECT_ID"
cd "$RULES_DIR"
firebase deploy --only firestore:rules,storage \
  --project "$OLD_PROJECT_ID" \
  --config "$RULES_DIR/firebase.json" 2>&1 | tee -a "$LOG_FILE"

log ""
log "✅ Altes Projekt jetzt read-only."
log "   Daten bleiben 14 Tage als Notausstieg erhalten."
log "   Nach T+14 (wenn alles stabil): ./99-final-cleanup.sh"
