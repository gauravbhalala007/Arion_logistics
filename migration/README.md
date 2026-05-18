# CoDriver Multi-DB-Setup für Zeiterfassung

Sequentielles Setup:
1. **Backup-Snapshot** der bestehenden `nam5`-Default-DB (Sicherheits-Goldstandard)
2. **Zweite Firestore-Database** `time-tracking` in `eur3` (Frankfurt) anlegen
3. **Firestore-Rules + Indexes** für die neue DB
4. **Cloud Functions** für `clockIn` / `clockOut` deployen

Bestandsdaten bleiben **komplett unberührt** in `nam5`. Wenn etwas
schiefgeht, kann die `time-tracking`-DB einfach gelöscht werden ohne
Auswirkung auf den Rest.

---

## Voraussetzungen

```bash
# Falls noch nicht installiert:
brew install --cask google-cloud-sdk

# Login + Projekt setzen
gcloud auth login
gcloud config set project gaurav-arion-001-3d94a

# Firebase CLI ggf. aktualisieren
npm install -g firebase-tools@latest
firebase login
firebase use gaurav-arion-001-3d94a
```

---

## Schritt 1 — Backup-Snapshot

```bash
cd migration
./01-backup.sh
```

Was passiert:
- Legt einen neuen GCS-Bucket `codriver-backups-{projectId}` an
  (falls noch nicht existiert)
- Exportiert die komplette `(default)`-Firestore-DB nach
  `gs://codriver-backups-…/snapshot-YYYY-MM-DD-HHMM/`
- Verifiziert dass der Export-Job erfolgreich war

**Dauer**: 5-15 Minuten je nach Datenmenge. Während des Exports ist die
DB normal nutzbar (Firestore-Export ist non-blocking).

---

## Schritt 2 — Neue eur3-Database

```bash
./02-create-eu-db.sh
```

Was passiert:
- Erstellt neue Firestore-Database `time-tracking` in `eur3` (Frankfurt)
- Setzt Native-Mode (kein Datastore)
- Aktiviert PITR (Point-in-time-Recovery)
- Verifiziert dass die Datenbank existiert

**Dauer**: < 1 Minute.

**Wichtig**: Default-DB `(default)` in `nam5` bleibt unverändert.

---

## Schritt 3 — Rules + Indexes für neue DB

```bash
./03-deploy-rules.sh
```

Was passiert:
- Deployed `firestore-time.rules` gegen die `time-tracking`-Database
- Deployed `firestore-time.indexes.json`

---

## Schritt 4 — Cloud Functions deployen

```bash
cd ../firebase/functions
npm install
npm run build
firebase deploy --only functions:clockIn,functions:clockOut,functions:computeDailyShift
```

---

## Rückgängig machen (falls nötig)

Solange wir die neue DB **noch nicht** für Produktiv-Daten nutzen:

```bash
gcloud firestore databases delete time-tracking
```

Bestands-DB ist davon **nicht** betroffen.

---

## Sicherheitscheck nach Setup

```bash
# Verifizieren dass die Default-DB unverändert ist:
gcloud firestore databases describe \
  --database=(default)
# location_id sollte weiterhin „nam5" sein

# Neue DB:
gcloud firestore databases describe \
  --database=time-tracking
# location_id muss „eur3" sein
```
