# Spec: Bewerber → Driver Umwandlung (volle Datenübernahme)

**Datum:** 2026-06-05
**Status:** Approved (Design)
**App:** `flutter_app/kpi_admin/`

## Ziel

Ein Recruiting-Bewerber (`RecruitingApplication`) kann im finalen Schritt zu einem
Driver im Drivers-Hub umgewandelt werden. **Alle** Bewerberdaten — Stammdaten,
Custom-Antworten und die 5 hochgeladenen Dokumente — werden in das Driver-Profil
übernommen. Der Bewerber bleibt danach im Recruiting bestehen und wird dort als
„Als Driver übernommen" markiert.

## Ablauf (User Flow)

1. Im Bewerber-Detail (Recruiting-Panel) erscheint bei Status `hired` der Button
   **„Als Driver übernehmen"** (existiert bereits, wird erweitert).
2. Button öffnet den bestehenden `Driver hinzufügen`-Dialog, **vorausgefüllt mit
   allen Bewerberdaten** (heute nur Name/E-Mail/Telefon → künftig alles).
3. Admin prüft die Daten, vergibt **Transporter-ID + Passwort**, bestätigt.
4. Driver-Dokument wird angelegt (alle Felder, siehe Datenmodell).
5. Die **5 Dokumente** werden client-seitig von den Recruiting-Storage-URLs in die
   Driver-Storage-Pfade kopiert und als Driver-`documents`-Einträge angelegt.
6. Login wird über die bestehende Cloud Function `createDriverLogin` erstellt.
7. Der Bewerber wird mit `convertedToDriver` markiert; im Panel erscheint ein Badge
   und der Umwandeln-Button wird deaktiviert (Doppelanlage-Schutz).

## Datenmodell

Bewerberdaten werden **flach** in das Driver-Dokument geschrieben (keine
verschachtelte `recruitingProfile`-Map). Bestehende Driver-Felder werden
wiederverwendet; neue Felder werden top-level ergänzt.

```
users/{dspUid}/drivers/{tid}
  ├─ driverName        ← firstName + " " + lastName     (bestehend)
  ├─ phone             ← phoneWhatsApp                    (bestehend)
  ├─ emailPrivate      ← email (Bewerber)                 (NEU, privat)
  ├─ emailBusiness     ← "" (leer; Geschäftsmail kommt später)  (NEU)
  ├─ email             ← Login-Mail (= emailPrivate, solange keine Geschäftsmail)
  ├─ birthDate         ← birthDate                        (NEU)
  ├─ birthPlace        ← birthPlace                       (NEU)
  ├─ nationality       ← nationality                      (NEU)
  ├─ street            ← street                           (NEU)
  ├─ postalCode        ← postalCode                       (NEU)
  ├─ city              ← city                             (NEU)
  ├─ livingHereSince   ← livingHereSince                  (NEU, nullable)
  ├─ shirtSize         ← shirtSize                        (NEU)
  ├─ shoeSize          ← shoeSize                         (NEU)
  ├─ truckLicense      ← truckLicense                     (NEU)
  ├─ channel           ← channel (local|visa)             (NEU)
  ├─ customAnswers     ← customAnswers (Map, 1:1)         (NEU)
  ├─ adminNote         ← adminNote                        (NEU)
  └─ convertedFromApplication: { appId, adminUid, at }    (NEU, Audit-Link)
```

### E-Mail-Logik

- Die Bewerber-E-Mail → **`emailPrivate`**.
- Da noch keine Geschäftsmail existiert, wird `emailPrivate` gleichzeitig als
  Login-`email` verwendet (Eingabefeld im Dialog ist damit vorbelegt).
- `emailBusiness` bleibt leer und kann später nachgetragen werden. Sobald gesetzt,
  kann sie künftig zur primären Login-Mail werden (außerhalb dieser Spec).

## Dokumente (Storage)

Bewerber-Dokumente liegen unter `recruiting/{adminUid}/{appId}/{label}.{ext}`.
Driver können diesen Pfad nicht lesen (Firestore/Storage-Rules erlauben Drivern nur
`driver_docs/{tid}` und `driver_profile_photos/{tid}`). Daher werden die Dateien
beim Umwandeln **kopiert**:

| Bewerber-Label | Ziel-Pfad                          | Wirkung        |
|----------------|------------------------------------|----------------|
| `selfie`       | `driver_profile_photos/{tid}/…`    | wird Profilbild |
| `passport`     | `driver_docs/{tid}/…`              | Driver-Doc      |
| `id_back`      | `driver_docs/{tid}/…`              | Driver-Doc      |
| `license_front`| `driver_docs/{tid}/…`              | Driver-Doc      |
| `license_back` | `driver_docs/{tid}/…`              | Driver-Doc      |

**Mechanik (client-seitig, kein neuer Cloud-Function-Deploy):** Der Dialog lädt die
5 Dateien von ihren Recruiting-Download-URLs herunter und lädt sie in die
Driver-Pfade hoch. Für jedes Dokument wird ein Eintrag in der Driver-`documents`-
Subcollection erstellt (gleiche Form wie manuell hochgeladene Driver-Dokumente).
Admin besitzt für beide Pfade Lese-/Schreibrechte laut bestehender Storage-Rules.

Fehlertoleranz: Schlägt eine einzelne Datei-Kopie fehl, blockiert das **nicht** die
Driver-Anlage. Fehlgeschlagene Dokumente werden gesammelt und dem Admin als
Hinweis-Snackbar gemeldet, sodass er sie manuell nachladen kann.

## Recruiting-Panel nach Umwandlung

- Bewerber bleibt in der Liste sichtbar.
- Am Bewerber wird `convertedToDriver: { tid, at }` gespeichert.
- Detail-Ansicht zeigt Badge **„Als Driver übernommen"** + Transporter-ID.
- Der „Als Driver übernehmen"-Button wird deaktiviert (verhindert doppelte Anlage).

## Betroffene Dateien

- `lib/models/recruiting_application.dart`
  - Sicherstellen, dass alle Felder fürs Prefill verfügbar sind.
  - Neues Feld `convertedToDriver` (Map, nullable) in Modell + `fromDoc`.
- `lib/Screens/add_driver_dialog.dart`
  - Neue Prefill-Parameter für alle Bewerberfelder (statt nur Name/E-Mail/Telefon).
  - Schreibt alle Felder ins Driver-Dokument.
  - Kopiert die 5 Dokumente in Driver-Storage + Driver-`documents`-Subcollection.
- `lib/Screens/admin_recruiting_panel.dart`
  - Button übergibt vollständige Bewerberdaten an den Dialog.
  - Setzt `convertedToDriver` am Bewerber nach Erfolg.
  - Badge + Disable-Logik in der Detail-Ansicht.

## Nicht im Scope

- Geschäftsmail (`emailBusiness`) befüllen / als Login umstellen — kommt später.
- Server-seitige (Cloud Function) Dokument-Migration.
- Änderungen am Recruiting-Status-Pipeline-Modell.

## Erfolgskriterien

- Klick auf „Als Driver übernehmen" → Dialog mit allen Feldern vorbefüllt.
- Nach Bestätigung existiert ein Driver-Doc mit allen Bewerberfeldern + Login.
- Die 5 Dokumente sind im Driver-Profil sichtbar/lesbar (Selfie als Profilbild).
- Bewerber zeigt Badge „Als Driver übernommen", Button deaktiviert.
- `flutter analyze lib/` zeigt keine neuen Errors.
