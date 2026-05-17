# 06 — Rollback-Plan

> Falls beim Cutover etwas schiefgeht — hier der Notausstieg. Geplante
> Dauer fuer kompletten Rollback: **15–30 Minuten**.

## Wann Rollback ziehen?

Klare Rollback-Trigger (in Reihenfolge der Schwere):

1. **Smoke-Test schlaegt fehl** und Ursache nicht innerhalb 15 min gefunden
2. **Datenverlust entdeckt** (z. B. fehlende Driver, Subcollections leer)
3. **Mehr als 30 % der Tester koennen sich nicht einloggen** → Hash-Migration kaputt
4. **Cloud Functions liefern 5xx-Fehler** im EU-Projekt

## Sofort-Massnahmen (T+0, innerhalb 15 min)

### Schritt 1: Wartungs-Banner zurueck ins ALTE Projekt

```bash
firebase firestore:write _system/flags \
  '{"maintenance": false}' \
  --project gaurav-arion-001-3d94a
```

### Schritt 2: DNS A-Record zurueck auf altes Hosting (👤 am Registrar)

1. Beim Registrar (Strato/IONOS/...) den A-Record fuer `dsp-codriver.de`
   zuruecksetzen auf die alte Firebase-Hosting-IP des Projekts
   `gaurav-arion-001-3d94a`.
2. TTL = 300 sollte bereits gesetzt sein → Propagation in 5–10 min.

Die alte IP kannst du in der Firebase Console (`gaurav-arion-001-3d94a`)
→ Hosting → Custom Domain → "DNS-Eintraege anzeigen" jederzeit nachschauen.

### Schritt 3: Tester benachrichtigen

```
Hallo zusammen,

bei der Umstellung gab es ein technisches Problem. Wir haben CoDRIVER
auf das alte System zurueckgerollt. Alle Daten und Funktionen sind
unveraendert.

Wir analysieren die Ursache und melden uns mit einem neuen Termin.

Sorry fuer die Stoerung!
```

### Schritt 4: Was im EU-Projekt jetzt steht

- Auth-User: importiert, koennen liegenbleiben (keine Stoerung)
- Firestore-Daten: importiert, koennen liegenbleiben
- Storage-Files: synced, koennen liegenbleiben
- Wartungs-Flag im EU: `true` lassen (verhindert versehentlichen Zugriff)

Beim erneuten Migrationsversuch wird einfach neu importiert (idempotent).

## Was bleibt erhalten?

**Im alten Projekt (live, alle Daten intakt):**
- Alle Auth-User
- Alle Firestore-Daten (unveraendert seit 20:00, da Wartungs-Flag ab dann
  Schreibzugriffe verhindert)
- Alle Storage-Files

**Im EU-Projekt (Stand zum Cutover-Versuch):**
- Importierte Auth-User (verbleiben, Login einfach nicht aktiv)
- Importierte Firestore-Daten
- Importierte Storage-Files

→ Beim naechsten Cutover-Versuch kann auf demselben Stand aufgesetzt
oder ein frischer Import gefahren werden.

## Recovery-Analyse

Nach dem Rollback systematisch durchgehen:

| Was? | Wo nachschauen? |
|---|---|
| Auth-Import-Fehler | Output von `04-import-eu.sh` + Firebase Console (NEW) → Authentication |
| Firestore-Import-Fehler | `gcloud firestore operations list --project codriver-eu` |
| Storage-Sync-Probleme | `gsutil rsync -n` (Dry-Run) zeigt Diff |
| Function-Fehler | `firebase functions:log --project codriver-eu` |
| DNS-Probleme | `dig +trace dsp-codriver.de` |
| Custom-Claims fehlen | Auth-Export enthielt `customAttributes` Feld? |

## Neuer Versuch

Wenn Ursache gefunden + behoben:

1. Migration-Scripts ggf. anpassen
2. Trockenlauf erneut: `./02b-test-single-user.sh`
3. Neuen Cutover-Termin planen
4. `01-prerequisites.md` Final-Checkliste durchgehen
5. Cutover wiederholen
