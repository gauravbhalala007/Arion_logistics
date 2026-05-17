# 05 — Cutover-Runbook

> Minutengenaue Choreografie fuer die EU-Migration. Geplante Dauer:
> **60–90 Minuten** sichtbares Wartungsfenster. Vorher die
> `01-prerequisites.md` komplett durchgehen!

## Vor Cutover (T-7 bis T-1)

| Tag | Aktion |
|---|---|
| T-7 | `02a-prep-eu-project.sh` ausgefuehrt → EU-Projekt hat Rules, Indexes, Functions deployed |
| T-3 | `02b-test-single-user.sh` mit einem Tester gelaufen → Login im EU-Projekt funktioniert |
| T-2 | Beta-Tester-Mail raus (Vorlage in `01-prerequisites.md`) |
| T-1 | DNS-TTL fuer `dsp-codriver.de` auf 300 Sekunden reduziert (beim Registrar) |
| T-1 | Custom Domain im EU-Projekt vorbereitet (TXT-Record verifiziert), aber A-Record steht noch auf altem Projekt |

## Cutover-Tag — Sequenz

### 19:55 — Vorbereitung
- [ ] Terminal-Tabs offen:
  - Tab 1: `cd migration/eu/scripts`
  - Tab 2: Firebase Console (altes Projekt)
  - Tab 3: Firebase Console (codriver-eu)
  - Tab 4: Domain-Registrar (Strato/IONOS Logins)
- [ ] `firebase login` aktuell, `gcloud auth login` aktuell
- [ ] Beta-Tester-Channel (Telegram/Slack/E-Mail) offen

### 20:00 — Wartungs-Banner aktivieren

```bash
firebase firestore:write _system/flags \
  '{"maintenance": true, "maintenanceMessage": "EU-Migration laeuft, ab 22:00 wieder verfuegbar."}' \
  --project gaurav-arion-001-3d94a
```

Alternativ ueber Console: Firestore → `_system/flags` → Doc bearbeiten.

→ Banner sollte fuer alle Tester sofort sichtbar werden.

### 20:05 — Export starten

```bash
./03-export-old.sh
```

Erwartete Dauer: 10–20 min (haengt vom Firestore-Volumen ab).
Output: `exports/last-export-prefix.txt` + `exports/auth-*.json`.

### 20:25 — Import starten (sobald Export fertig)

```bash
./04-import-eu.sh
```

Erwartete Dauer: 15–30 min (Firestore-Import + Storage-Rsync + Flutter-Build).

### 20:55 — DNS umstellen (👤 manueller Schritt am Registrar)

1. EU-Hosting hat bereits Custom Domain `dsp-codriver.de` zugeordnet
2. Firebase Console (`codriver-eu`) → Hosting → Custom Domain → "DNS-Eintraege anzeigen"
3. Notiere die **neue A-Record-IP** (z. B. `199.36.158.100`)
4. Beim Registrar:
   - Loesche alten A-Record
   - Setze neuen A-Record auf die Firebase-EU-IP
   - TTL bei 300s lassen

### 21:00 — Auf DNS-Propagation warten

```bash
# In Tab 1:
while true; do dig +short dsp-codriver.de; sleep 10; done
```

Sobald die neue IP erscheint → weiter.

### 21:10 — Smoke-Tests durchfuehren

Aufgabe: in **Inkognito-Tab** `https://dsp-codriver.de` aufrufen.

- [ ] Login als Admin (deine eigenen Credentials) → klappt?
- [ ] Driver-Liste zeigt alle bekannten Fahrer?
- [ ] Click auf einen Fahrer → Detail laedt, Dokumente sichtbar?
- [ ] Dokument-Download funktioniert?
- [ ] Schicht-Plan-Anzeige funktioniert?
- [ ] Test-Notiz an einem Fahrer hinzufuegen → wird gespeichert?
- [ ] Firestore Console (NEW) → `audit_log` → neuer Eintrag erscheint?
- [ ] Login als Dispatcher (Tester-Account)?
- [ ] Login als Driver (Tester-Account)?
- [ ] Driver-View laedt Schichten korrekt?
- [ ] Mobile-Browser-Test (iPhone Safari, Android Chrome)?

Falls **irgendein** Smoke-Test fehlschlaegt → siehe `06-rollback.md`.

### 21:30 — Wartungs-Banner deaktivieren

```bash
firebase firestore:write _system/flags \
  '{"maintenance": false}' \
  --project codriver-eu
```

### 21:35 — Tester benachrichtigen

Vorlage:
```
Liebe Tester,

CoDRIVER ist wieder online! Bitte einmal neu anmelden — dein Passwort
ist unveraendert. Falls dir etwas auffaellt, das nicht funktioniert,
melde dich SOFORT unter info@arion-logistics.de.

In den naechsten 14 Tagen bleibt das alte System als Notausstieg
read-only verfuegbar.

Danke fuer deine Geduld!
```

### 21:40 — Cutover dokumentieren

- Logs aus `migration/eu/exports/` archivieren
- Kurze Notiz in `migration/eu/CUTOVER-DONE.md`:
  - Cutover-Datum + Uhrzeit
  - Anzahl migrierter Auth-User
  - Anzahl Firestore-Dokumente (aus Logs)
  - Storage-GBs migriert
  - Aufgetretene Probleme + Loesungen

## Nach Cutover

| Wann | Was |
|---|---|
| T+1   | `./07-readonly-old.sh` → altes Projekt sperren |
| T+1–T+14 | Taeglich Cloud-Functions-Logs + audit_log pruefen |
| T+7   | Storage-Sync nochmal laufen lassen (falls Tester Files im OLD-Projekt-Lese-Cache hatten) |
| T+14  | Bei stabilem Betrieb: `./99-final-cleanup.sh` |
