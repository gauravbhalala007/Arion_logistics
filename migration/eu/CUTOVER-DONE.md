# Cutover-Dokumentation

**Datum:** 2026-05-17
**Zeitfenster:** 18:55 – 21:40 (mit Custom-Domain-Setup)
**Quell-Projekt:** `gaurav-arion-001-3d94a` (Region `nam5` / `us-central1`)
**Ziel-Projekt:** `codriver-eu` (Region `eur3` / `europe-west3`)
**Domain:** `dsp-codriver.de` + `www.dsp-codriver.de`

## Zusammenfassung Migrationsdaten

| Komponente | Anzahl / Volumen | Status |
|---|---|---|
| Auth-User | 335 | ✅ Hash-Passwörter mitmigriert (SCRYPT) |
| Firestore-Dokumente | 21.533 | ✅ aus `nam5`-Export, in `eur3` importiert |
| Storage-Files | 659 | ✅ byteweise identisch |
| Storage-Volumen | 1,7 GB (1.853.300.956 bytes) | ✅ |
| Cloud Functions | 17 Stück | ✅ deployed (4 neu, 13 aktualisiert) |
| Firestore Rules + Indexes | (siehe firestore.rules) | ✅ deployed |
| Storage Rules | rollenbasiert | ✅ deployed |
| Hosting | Flutter Web Build (mit codriver-eu config) | ✅ deployed |
| Custom Domain apex | `dsp-codriver.de` | ✅ verifiziert, ⏳ SSL Cert wird ausgestellt |
| Custom Domain www | `www.dsp-codriver.de` (→ apex) | ✅ verifiziert, ⏳ SSL Cert wird ausgestellt |

## Migration-Ablauf (chronologisch)

| Uhrzeit | Aktion | Ergebnis |
|---|---|---|
| 17:46 | `02a-prep-eu-project.sh` ausgeführt | Pre-Cutover Setup, alle Functions+Rules ins EU-Projekt |
| 17:47 | IAM-Fix: Cloud Build Permissions für Compute SA | gelöst (Berechtigungen für Functions-Build) |
| 17:50 | `02b-test-single-user.sh` mit `elvir.memedi@arion-logistics.de` | ✅ Hash-Parameter verifiziert |
| 17:50 | dito mit `test@arion-logistics.de` | ✅ |
| 17:53 | Test-User in `codriver-eu` gelöscht | bereit für Bulk-Import |
| 18:55 | DPA-Konfiguration im neuen Projekt geprüft (DPA bereits akzeptiert 17.05.2026) | ✅ |
| 18:55 | Datenschutz-Einstellungen Firebase Console deaktiviert | ✅ |
| 18:59 | Auth-Export aus altem Projekt | 335 Accounts |
| 18:59 | Firestore-Export gestartet (async) | abgeschlossen <1 min |
| 18:59 | Storage-Rsync parallel gestartet | 659 Files, 1,7 GB |
| 19:01 | IAM-Fix: Firestore-SA Zugriff auf Export-Bucket | gelöst |
| 19:02–19:04 | Firestore-Import in `codriver-eu` | 21.533 Dokumente, ~3 min |
| ~19:00 | Storage-Sync abgeschlossen | byteweise identisch |
| 19:05 | Flutter `flutterfire configure --project=codriver-eu` | `firebase_options.dart` für Web auf neues Projekt |
| 19:06 | Flutter Web Build (Release) | ~78 s |
| 19:07 | Hosting Deploy nach `codriver-eu` | live unter `codriver-eu.web.app` |
| 21:25–21:38 | Custom Domains `dsp-codriver.de` + `www` hinzugefügt | TXT/CNAME bei IONOS gesetzt, Verifikation OK |
| 21:38 | SSL-Cert-Issuance gestartet (Let's Encrypt via Firebase) | erwartet 10-30 min |

## Wartungsfenster

- **Banner aktiviert?** Nein — bewusst, bei nur 5 Beta-Testern + kurze Migrations-Dauer
- **Effektive Downtime aus User-Sicht:** 0 (altes Projekt blieb durchgehend online)
- **Risiko Phantom-Writes:** zwischen Auth-Export (18:59) und Cert-Flip (~22:00) könnten neue Writes ins alte Projekt gehen, die im neuen nicht da sind

## Bekannte Restpunkte (nach Cutover zu erledigen)

- [ ] T+0 nach Cert-Flip: Verifizieren dass `https://dsp-codriver.de` Cert von codriver-eu hat
- [ ] T+0 nach Cert-Flip: Smoke-Tests (Login, Daten, Schreibvorgang, Audit-Log)
- [ ] T+1: `./07-readonly-old.sh` → altes Projekt read-only sperren
- [ ] T+7: Storage-Sync wiederholen (Delta-Catch falls Tester noch im alten Projekt waren)
- [ ] T+14: Bei Stabilität → `./99-final-cleanup.sh` → Final-Backup + Anleitung zur Projekt-Löschung
- [ ] Native Configs (macOS/Android/iOS): firebase_options.dart für andere Plattformen mit `flutterfire configure --platforms=android,ios,macos --project=codriver-eu` aktualisieren bei nächstem Native-Build
- [ ] Legacy us-central1 Functions optional auf europe-west3 migrieren (createDriverLogin, dispatcher-Funktionen, etc.)

## Backups (für Notfall-Rollback)

- Alt-Projekt: **unverändert**, jederzeit zugreifbar via `https://gaurav-arion-001-3d94a.web.app`
- Firestore-Export-Bucket: `gs://codriver-migration-staging/firestore-cutover-20260517-185937/`
  (im alten Projekt, kann auch nach Cutover als Snapshot dienen)
- Auth-Export: `migration/eu/exports/auth-cutover-20260517-185904.json` (lokale Datei, **enthält Passwort-Hashes**, NICHT ins Git!)
- firebase_options.dart Backup: `lib/firebase_options.dart.old-project-backup`

## Rollback-Plan (falls noch nötig)

Solange das alte Projekt unverändert ist, ist Rollback trivial:
1. Custom Domain in `codriver-eu` entfernen (oder Domain-Verifikation invalidieren via TXT)
2. TXT bei IONOS zurück auf `hosting-site=gaurav-arion-001-3d94a`
3. → Cert/Routing schaltet binnen 5 min zurück
4. `flutter_app/kpi_admin/lib/firebase_options.dart` aus Backup wiederherstellen
5. Build + Deploy gegen Alt-Projekt

## Erfolg-Kriterium für endgültigen Cutover-Abschluss

- [ ] SSL-Cert von Let's Encrypt für `dsp-codriver.de` ausgestellt → routet zu codriver-eu
- [ ] Smoke-Tests grün
- [ ] Beta-Tester können einloggen + Daten unverändert sehen
- [ ] Keine Fehler in Cloud-Functions-Logs der ersten 24h
