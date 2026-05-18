# Datenschutz-Folgenabschätzung (DSFA) — Zeiterfassungsmodul

**Entwurf zum Vorlegen beim Datenschutzbeauftragten / Anwalt**
Stand: 13. Mai 2026 · Version 1.0

---

## 1. Beschreibung der Verarbeitung

### 1.1 Verarbeitungszweck
Erfassung der Arbeitszeit von Fahrern eines Amazon Delivery Service
Providers (DSP) mittels App-basierter Stempelung (Clock-in/Clock-out)
inkl. **Standort-Verifikation** über GPS-Geofence + QR-Code-Scan am
Hub-Eingang.

### 1.2 Verantwortlicher
Der jeweilige DSP-Inhaber als Arbeitgeber. CoDriver (ARION Logistics
GmbH) agiert als **Auftragsverarbeiter** gem. Art. 28 DSGVO.

### 1.3 Datenarten
Siehe `datenschutz-zeiterfassung.md` § b.

### 1.4 Betroffene Personengruppen
Fahrer mit aktivem Arbeitsverhältnis beim DSP. Anzahl Betroffener
pro DSP typischerweise 20–80.

### 1.5 Rechtsgrundlage
- Art. 6 (1) lit. b und c DSGVO
- § 26 BDSG (Beschäftigtendaten)
- § 16 ArbZG (Aufzeichnungspflicht)

---

## 2. Notwendigkeit & Verhältnismäßigkeit

### 2.1 Notwendigkeit der Standort-Verifizierung
Ohne Standort-Verifizierung wäre Stempel-Manipulation („Heim-Stempeln")
nicht aufdeckbar. Das EuGH-Urteil C-55/18 fordert ein **objektives,
verlässliches und zugängliches** System — reine Selbstauskunft des
Fahrers reicht dafür nicht.

Geo-Verifizierung ist daher **erforderlich**, aber nur in dem
mildesten möglichen Umfang umzusetzen.

### 2.2 Privacy-by-Design Maßnahmen (Art. 25 DSGVO)
| Datenmin.-Maßnahme | Umsetzung |
|---|---|
| Keine Roh-GPS-Koordinaten speichern | Server speichert nur `geofenceMatched: true/false` + `geofenceId` |
| Kein Hintergrund-Tracking | Standort-Anfrage nur im Moment des aktiven Stempelvorgangs |
| Doppel-Faktor (QR + GPS) statt nur GPS | HMAC-signierter QR-Sticker pro Hub verhindert reine GPS-Spoofing-Attacken |
| Verschlüsselung in transit + at rest | Firebase TLS 1.3, AES-256 server-seitig |
| Audit-Log jeder Änderung | Nachträgliche Korrekturen sind nachvollziehbar |
| Granulare Zugriffsrechte | Driver liest nur eigene Entries; Admin nur des eigenen DSP |
| Daten-Residenz EU | Firestore-Region `eur3` (Frankfurt + Belgien) |
| Hash-only IP | IP nur als SHA-256-Hash gespeichert, nicht im Klartext |

---

## 3. Risiken für die Rechte und Freiheiten der Betroffenen

### 3.1 Risiko-Identifikation

| # | Risiko | Wahrscheinlichkeit | Schadenshöhe |
|---|---|---|---|
| R1 | Erstellung von Bewegungsprofilen über Roh-GPS | niedrig (wird nicht gespeichert) | hoch wenn eingetreten |
| R2 | Unberechtigter Zugriff durch Dritte auf Zeit-Daten | mittel | mittel |
| R3 | Diskriminierung durch automatisierte Bewertung | sehr niedrig (keine Auto-Entscheidungen) | hoch wenn eingetreten |
| R4 | Druck zur Zustimmung im Beschäftigungsverhältnis | mittel | mittel |
| R5 | Datenverlust durch Systemfehler | niedrig | mittel |
| R6 | Übermittlung in Drittländer | sehr niedrig (EU-Hosting) | hoch wenn eingetreten |

### 3.2 Folgen bei Eintritt
- Persönlichkeitsrechte-Eingriff
- Vertrauensverlust ins Arbeitsverhältnis
- Mögliche arbeitsrechtliche Auseinandersetzungen

---

## 4. Abhilfemaßnahmen

| Risiko | Maßnahme | Verantwortlich |
|---|---|---|
| **R1** | Keine persistente lat/lng-Speicherung; transiente Verarbeitung im Cloud Function Process Memory | Entwicklung |
| **R2** | Firestore Rules + Role-based Access (Admin/Driver/Dispatcher), regelmäßige Rules-Audits | Entwicklung |
| **R3** | Compliance-Warnungen nur informativ, keine automatischen Sanktionen | Produkt-Design |
| **R4** | Verzicht auf Geofence ist möglich (manueller Stempel mit Admin-Genehmigung), Hinweis darauf in der Datenschutzerklärung | Recht + Produkt |
| **R5** | Tägliche automatische Backups via Firestore-Export, 90-Tage-Retention | Operations |
| **R6** | Firestore-Region `eur3` (Frankfurt + Belgien), Subprocessor-Liste prüfen | Vertrag |

### 4.1 Restrisiko
Nach Anwendung der Maßnahmen ist das Restrisiko **niedrig**. Die Datenverarbeitung erfolgt:
- **minimal** (kein Roh-Standort, keine Bewegungsprofile)
- **transparent** (Datenschutzerklärung erklärt jeden Datentyp)
- **kontrollierbar** (Betroffene können widersprechen und Auskunft verlangen)
- **lokal** (EU-Hosting, keine Drittland-Übermittlung)

---

## 5. Konsultation des Datenschutzbeauftragten

[Name des DSB] hat am [Datum] die DSFA gesichtet und folgende
Anmerkungen gemacht: ___

Eine Konsultation der Aufsichtsbehörde gem. Art. 36 DSGVO ist
**nicht** erforderlich, da das Restrisiko als niedrig eingestuft wird.

---

## 6. Aktualisierungs-Pflicht

Die DSFA wird mindestens **jährlich** sowie bei jeder wesentlichen
Änderung am Verarbeitungsprozess überprüft.

Wesentliche Änderungen, die eine erneute DSFA auslösen:
- Hinzufügen neuer Datenarten (z. B. biometrische Authentifizierung)
- Wechsel des Cloud-Providers
- Erweiterung des Personenkreises (z. B. nicht-angestellte Fahrer)
- Änderung der Aufbewahrungsfristen

---

## 7. Anlagen
- Anlage 1: Diagramm der Datenflüsse (zu erstellen, siehe `docs/time-tracking-plan.md` Abschnitt 1)
- Anlage 2: Liste der Empfänger und Subprocessor (zu erstellen)
- Anlage 3: Verzeichnis der Verarbeitungstätigkeiten (zu erstellen)

---

**Verantwortlich für diese DSFA**: ARION Logistics GmbH, Geschäftsführung
**Unterschrift Datum**: ____________
**DSB-Unterschrift**: ____________
