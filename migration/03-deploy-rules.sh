#!/usr/bin/env bash
# Deploys Firestore Rules + Indexes für die `time-tracking`-DB.

set -euo pipefail

PROJECT_ID="gaurav-arion-001-3d94a"
DB_ID="time-tracking"

echo "═══════════════════════════════════════════════════════"
echo "  Deploye Rules + Indexes für ${DB_ID}"
echo "═══════════════════════════════════════════════════════"
echo ""

# firebase.json muss ein zweites Hosting/Firestore-Target kennen.
# Hier erzeugen wir eine temporäre Firebase-Konfiguration für DB-spezifischen Deploy.

TMP_DIR=$(mktemp -d)
cp firestore-time.rules "${TMP_DIR}/firestore.rules"
cp firestore-time.indexes.json "${TMP_DIR}/firestore.indexes.json"

cat > "${TMP_DIR}/firebase.json" <<EOF
{
  "firestore": [
    {
      "database": "${DB_ID}",
      "rules": "firestore.rules",
      "indexes": "firestore.indexes.json"
    }
  ]
}
EOF

cd "${TMP_DIR}"
firebase use "${PROJECT_ID}"
firebase deploy --only "firestore:${DB_ID}"

echo ""
echo "═══════════════════════════════════════════════════════"
echo "  ✓ Rules + Indexes deployed für ${DB_ID}"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "  Console: https://console.firebase.google.com/project/${PROJECT_ID}/firestore/${DB_ID}/rules"
echo ""
echo "  ► Nächster Schritt: Cloud Functions"
echo "    cd ../firebase/functions"
echo "    (siehe docs/time-tracking-plan.md Phase 1)"
