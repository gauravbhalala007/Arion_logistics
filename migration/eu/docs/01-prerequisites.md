# 01 — Voraussetzungen vor Cutover

Diese Liste pruefen, bevor Cutover gestartet wird.

## A) Im Firebase Console (OLD project, `gaurav-arion-001-3d94a`)

### A.1 Passwort-Hash-Parameter holen

Diese sind **kritisch** — ohne sie funktionieren importierte Passwoerter
nicht und alle Tester muessten "Passwort zuruecksetzen" durchlaufen.

1. Firebase Console → Projekt `gaurav-arion-001-3d94a` waehlen
2. Authentication → oben rechts das **Dreipunkt-Menue** (`⋮`) → **"Projekt-Konfiguration"**
3. Reiter **"Benutzer"** scrollen bis Abschnitt **"Passwort-Hash-Parameter"**
4. Notieren:
   - `base64_signer_key` → entspricht `AUTH_HASH_KEY` in `.env`
   - `base64_salt_separator` → entspricht `AUTH_SALT_SEPARATOR`
   - `rounds` (meist `8`) → `AUTH_ROUNDS`
   - `mem_cost` (meist `14`) → `AUTH_MEM_COST`
5. In `migration/eu/scripts/.env` eintragen (Werte in Anfuehrungszeichen).

## B) Im Firebase Console (NEW project, `codriver-eu`)

### B.1 DPA bestaetigen
- https://console.cloud.google.com/iam-admin/dpa?project=codriver-eu
- Falls Banner erscheint → akzeptieren
- Falls schon aktiv → OK

### B.2 IAM-Rolle fuer Backup-Service-Account
Damit die Backup-Function spaeter Firestore-Exports schreiben darf:

1. Google Cloud Console → IAM & Admin → IAM
2. Such den Service-Account: `<NEW_PROJECT_ID>@appspot.gserviceaccount.com`
   (App Engine default)
3. Rolle hinzufuegen: **"Cloud Datastore Import Export Admin"**
   (`roles/datastore.importExportAdmin`)
4. Speichern

### B.3 Custom Domain vorbereiten
- Firebase Console (`codriver-eu`) → Hosting → "Benutzerdefinierte Domain hinzufuegen"
- Domain eingeben: `dsp-codriver.de`
- Verifizierung per DNS-TXT-Record beim Registrar (Strato/IONOS/...)
- **WICHTIG**: A-Record noch NICHT aendern! Wird erst zum Cutover-Zeitpunkt umgehaengt.

### B.4 Email-Templates uebernehmen
- Authentication → Templates
- Absender, E-Mail-Adresse, Antwort-Adresse setzen (gleich wie altes Projekt)
- Optional: Custom Email-Action-URLs (sonst werden Firebase-Standard-URLs genutzt)

## C) Auf deinem lokalen Rechner

### C.1 CLIs aktuell

```bash
firebase --version    # >= 13.0
gcloud --version      # >= 460.0
gsutil version
jq --version          # >= 1.6 (fuer JSON-Filter)
```

Falls fehlt:
```bash
brew install firebase-cli google-cloud-sdk jq
```

### C.2 Login

```bash
firebase login
gcloud auth login
gcloud auth application-default login
```

### C.3 .env eintragen

```bash
cd migration/eu/scripts
cp env.example .env
# .env editieren — siehe A.1 fuer Hash-Werte
```

### C.4 Test: Auf neues Projekt verbinden

```bash
firebase use --add codriver-eu --alias eu
firebase projects:list | grep codriver-eu
```

Erwartung: `codriver-eu` erscheint und ist als `eu` aliased.

## D) Beta-Tester informiert

### D.1 Vorab-Information (T-2 Tage)
Vorlage:
```
Liebes CoDRIVER-Team,

am <DATUM> zwischen 20:00 und 22:00 Uhr stellen wir CoDRIVER auf
europaeische Server um (DSGVO-Konformitaet). Waehrend der Wartung ist
die App nicht erreichbar.

Nach der Umstellung musst du dich einmal neu anmelden — dein Passwort
bleibt gleich. Alle deine Daten bleiben erhalten.

Bei Problemen melde dich unter info@arion-logistics.de.

Danke fuer dein Verstaendnis!
```

### D.2 24h-vor-Erinnerung
Kurze Push-Notification an alle aktiven Nutzer.

## E) Final-Checkliste (am Cutover-Tag, vor Start)

- [ ] `.env` eingetragen + Hash-Parameter verifiziert
- [ ] `firebase login` + `gcloud auth login` aktuell
- [ ] Pre-Cutover Setup gelaufen (Script `02a-prep-eu-project.sh`)
- [ ] Trockenlauf erfolgreich (Script `02b-test-single-user.sh`)
- [ ] DNS-TTL der Domain auf 300s reduziert (24h vor Cutover beim Registrar!)
- [ ] Tester benachrichtigt
- [ ] Wartungs-Banner aktivierbar getestet (siehe Cutover-Runbook)
- [ ] Backup vom OLD project existiert (zur Sicherheit nochmal manuell)
- [ ] Du hast 2h Zeit ohne Stoerungen

Wenn alle Punkte gruen sind → ab in `docs/05-cutover-runbook.md`.
