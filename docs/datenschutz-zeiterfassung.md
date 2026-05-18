# Datenschutzerklärung — Zeiterfassungsmodul (Entwurf)

**Bitte vom Anwalt prüfen und in die Haupt-Datenschutzerklärung aufnehmen.**
Stand: 13. Mai 2026

---

## § X · Zeiterfassung mit Standort-Verifizierung

### a) Zweck der Verarbeitung
Beim Stempel-Vorgang („Schicht beginnen", „Schicht beenden", „Pause")
prüft CoDriver, ob sich das Endgerät des Fahrers am vereinbarten
Einsatzort (Hub) befindet. Zweck ist:
- Rechtssichere Arbeitszeit-Dokumentation gemäß **§ 16 ArbZG** und
  **EuGH-Urteil C-55/18 (Stechuhrurteil)**
- Verhinderung von Stempel-Manipulation (Anti-Fraud)
- Korrekte Vergütungs- und Sozialversicherungsabrechnung

### b) Verarbeitete Daten
Bei **jedem** Stempel-Vorgang werden folgende Daten verarbeitet:

| Datentyp | Speicherung | Aufbewahrung |
|---|---|---|
| Zeitpunkt (Server-Zeitstempel) | Ja | 2 Jahre |
| Mitarbeiter-ID (Transporter-ID) | Ja | 2 Jahre |
| Standort-Erlaubnis (ja/nein) | Ja | bis Widerruf |
| Geofence-Match (boolean) | Ja | 2 Jahre |
| Geofence-ID (z. B. „DBY5_main") | Ja | 2 Jahre |
| GPS-Genauigkeit (Meter) | Ja | 2 Jahre |
| QR-Code-Hub-ID + Versions-Nr. | Ja | 2 Jahre |
| Geräte-Plattform + App-Version | Ja | 2 Jahre |
| IP-Adresse (gehasht, SHA-256) | Ja | 2 Jahre |
| **Exakte GPS-Koordinaten (lat/lng)** | **Nein** | — |
| **Bewegungsprofil zwischen Stempelvorgängen** | **Nein** | — |
| **Hintergrund-Standort-Tracking** | **Nein** | — |

> **Wichtig**: Die exakten GPS-Koordinaten werden **nur transient** an
> den Server übertragen, um den Geofence-Check serverseitig
> durchzuführen, und **nicht persistent gespeichert**. Gespeichert wird
> ausschließlich das Ergebnis: „war innerhalb / außerhalb des Hub-Bereichs".

### c) Rechtsgrundlage
- **Art. 6 (1) lit. b DSGVO**: Erfüllung des Arbeitsvertrags
- **Art. 6 (1) lit. c DSGVO**: Rechtliche Verpflichtung (§ 16 ArbZG)
- **Art. 6 (1) lit. f DSGVO**: Berechtigtes Interesse (Anti-Fraud)
- **§ 26 BDSG**: Datenverarbeitung für Zwecke des Beschäftigungsverhältnisses

### d) Datenkategorien — Empfänger
- **Innerbetrieblich**: DSP-Admin und ggf. delegierte Dispatcher
- **Cloud-Hosting**: Firebase / Google LLC, Region `europe-west3` (Frankfurt)
- **Lohnabrechnung**: (sofern aktiviert) SD Worx und/oder ADP, jeweils
  auf Basis eigener Auftragsverarbeitungs-Verträge
- **Behörden**: Nur auf gesetzlicher Anordnung (z. B. Sozialversicherungs-
  Prüfung, Arbeitsschutzkontrolle)

### e) Datenresidenz
Sämtliche Zeit-Daten werden in der EU verarbeitet (Firebase Firestore
Multi-Region `eur3`, Standort Frankfurt + Belgien). Eine Übermittlung
in Drittländer findet **nicht** statt.

### f) Speicherdauer / Löschung
- **Einzelne Zeit-Entries**: 2 Jahre (gem. § 16 (2) ArbZG)
- **Aggregierte Monatswerte (Soll/Ist/Saldo)**: 6 Jahre (gem. § 147 AO)
- **Audit-Log (Änderungen)**: 2 Jahre
- **Korrektur-Anfragen**: 2 Jahre

Automatische Löschroutinen werden täglich von einer Scheduled
Cloud Function ausgeführt.

### g) Betroffenenrechte
Jeder Fahrer hat das Recht auf:
1. **Auskunft** (Art. 15) — Im Driver-Profil findet sich der Button
   „Meine Daten herunterladen", der einen vollständigen ZIP-Export der
   eigenen Zeit-Daten liefert.
2. **Berichtigung** (Art. 16) — Über das Korrektur-Antrag-System;
   Admin entscheidet binnen 7 Werktagen.
3. **Löschung** (Art. 17) — Nach Ende des Beschäftigungsverhältnisses
   nach Ablauf der gesetzlichen Aufbewahrungsfrist automatisch; vorher
   nur mit gesondertem Antrag und unter Wahrung gesetzlicher Pflichten.
4. **Einschränkung** (Art. 18) — Auf schriftlichen Antrag.
5. **Datenübertragbarkeit** (Art. 20) — CSV-Export im offenen Format.
6. **Widerspruch** (Art. 21) — Gegen automatisierten Geofence-Check;
   alternativ stempelt der Fahrer ohne Standort-Erlaubnis, der Admin
   genehmigt dann jeden Eintrag manuell.

### h) Freiwilligkeit
Die Erteilung der Standort-Erlaubnis ist **freiwillig**. Wird sie
verweigert, kann der Fahrer trotzdem stempeln, allerdings wird der
Vorgang als „Standort nicht bestätigt" markiert und vom Admin manuell
geprüft. Es entstehen dem Fahrer keine arbeitsrechtlichen Nachteile
aus der Verweigerung.

### i) Automatisierte Entscheidungen
Es findet **keine** automatisierte Entscheidungsfindung mit rechtlicher
Wirkung gemäß Art. 22 DSGVO statt. Compliance-Warnungen (z. B. Pausen-
Überschreitung) sind rein informativ und ziehen keine automatischen
Maßnahmen nach sich.

### j) Datenschutz-Folgenabschätzung (DSFA)
Vor Inbetriebnahme des Zeiterfassungsmoduls wurde eine DSFA gemäß
Art. 35 DSGVO erstellt. Die Bewertung des Restrisikos ist „niedrig"
aufgrund der konsequenten Datenminimierung (keine Roh-Koordinaten,
kein Hintergrund-Tracking).
