# Technische und organisatorische Maßnahmen (TOM)

**Verantwortlicher Auftragsverarbeiter:** Arion Logistics
**Produkt:** CoDRIVER (Verwaltungsplattform für DSP-Flotten)
**Stand:** 2026-05-17
**Version:** 1.0

> Dieses Dokument beschreibt die technischen und organisatorischen Maßnahmen,
> die CoDRIVER gemäß Art. 32 DSGVO trifft, um die Sicherheit der
> Verarbeitung personenbezogener Daten zu gewährleisten. Es ist Anlage zum
> Auftragsverarbeitungsvertrag (AVV).

---

## 1. Vertraulichkeit (Art. 32 Abs. 1 lit. b DSGVO)

### 1.1 Zutrittskontrolle
*Maßnahmen zur Verhinderung des physischen Zugangs Unbefugter zu
Datenverarbeitungsanlagen.*

- **Hosting:** Google Cloud Platform, Region `europe-west3` (Frankfurt am
  Main). Physische Sicherheit ist durch Google nach ISO/IEC 27001, ISO/IEC
  27017, ISO/IEC 27018, SOC 1/2/3 zertifiziert (Belege:
  https://cloud.google.com/security/compliance).
- **Büroräume:** Adresse siehe Vertrag. Zutritt nur für autorisierte
  Mitarbeiter, abschließbare Türen, dokumentierte Schlüsselverwaltung.
- **Arbeitsplätze:** Bildschirmsperre nach max. 10 Minuten Inaktivität.

### 1.2 Zugangskontrolle
*Maßnahmen zur Verhinderung der Nutzung der Systeme durch Unbefugte.*

- Firebase Authentication mit E-Mail + Passwort, Passwörter ausschließlich
  als **bcrypt/scrypt-Hash** gespeichert (Google-Standard, niemals
  Klartext).
- Optional E-Mail-Link-Anmeldung (passwortlos) für ausgewählte Rollen.
- **2-Faktor-Authentifizierung (2FA) verpflichtend** für alle Admin- und
  Developer-Konten (Google-2FA des Identity Providers).
- Automatische Sperre des Auth-Accounts bei wiederholt fehlgeschlagenen
  Anmeldungen (Firebase-Default + Custom-Rate-Limiting auf Functions-Ebene).

### 1.3 Zugriffskontrolle
*Maßnahmen, dass Berechtigte nur auf die ihnen zugewiesenen Daten
zugreifen können.*

- **Rollenbasiertes Berechtigungssystem** mit den Rollen
  `admin`, `dispatcher`, `vehicle_manager`, `fleet_viewer`, `driver`,
  `developer`. Rollen werden als Custom Claims im Auth-Token gesetzt und
  bei jedem Zugriff serverseitig geprüft.
- **Firestore Security Rules** erzwingen den Zugriff auf Dokumentebene
  abhängig von Rolle, Mandanten-Zugehörigkeit (`dspUid`) und Fahrer-ID
  (`transporterId`).
- **Storage Security Rules** spiegeln die gleiche Logik für Datei-Zugriffe.
  Default-Deny für alle nicht explizit erlaubten Pfade.
- **Cloud Functions** laufen unter dedizierten Service-Accounts mit
  Least-Privilege-Berechtigungen.
- Schreibzugriffe auf personenbezogene Fahrer-Daten werden im Audit-Log
  protokolliert (siehe §7).

### 1.4 Trennungskontrolle (Mandantentrennung)
- Jeder DSP-Mandant erhält einen eigenen Top-Level-User in Firestore
  (`users/{dspUid}/`); alle Fahrer-, Schicht- und Dokumentdaten liegen als
  Subcollections darunter.
- Firestore Rules erzwingen, dass Admins eines DSP keinen Zugriff auf
  Daten anderer DSPs erhalten — auch nicht über CollectionGroup-Queries.

### 1.5 Pseudonymisierung
- Fahrer werden in URLs und Logs über die `transporterId` (frei
  vergeben) referenziert, nicht über Klarnamen.
- Audit-Log enthält ausschließlich Feld-Namen (welches Feld geändert
  wurde), keine Werte (Datensparsamkeit, Art. 5 Abs. 1 lit. c DSGVO).

### 1.6 Verschlüsselung
- **Transportverschlüsselung:** TLS 1.3 für alle Verbindungen
  (HTTPS-only, HSTS aktiv). Schwächere TLS-Versionen sind deaktiviert.
- **Verschlüsselung at rest:** alle Firestore-Daten und Storage-Files
  werden von Google Cloud serverseitig mit AES-256 verschlüsselt
  (Standard).

---

## 2. Integrität (Art. 32 Abs. 1 lit. b)

### 2.1 Weitergabekontrolle
- Daten verlassen die Cloud-Infrastruktur ausschließlich über
  authentifizierte API-Aufrufe (Firebase Functions, signierte Storage-URLs).
- Signierte Download-URLs für DSGVO-Exports sind auf 60 Minuten Gültigkeit
  beschränkt.

### 2.2 Eingabekontrolle (Nachvollziehbarkeit)
- Cloud-Functions-Audit-Log: jeder Schreibzugriff auf
  `users/{dspUid}/drivers/{driverId}` erzeugt einen unveränderbaren Eintrag
  in `audit_log` mit Actor-UID, Rolle, Zeitstempel, geänderten Feldnamen.
- Cloud-Functions-Logs (StackDriver/Cloud Logging) werden 30 Tage
  aufbewahrt.
- Firebase Authentication führt eigene Login-/Session-Logs.

---

## 3. Verfügbarkeit & Belastbarkeit (Art. 32 Abs. 1 lit. b/c)

### 3.1 Verfügbarkeitskontrolle
- Firestore: Multi-Region-Replikation `eur3`
  (europe-west1 + europe-west3 + europe-west4 als Backend) mit
  synchroner Replikation → Failover automatisch.
- Storage: Region `europe-west3` mit interner Redundanz; Backups
  zusätzlich in `europe-west3-backups`-Bucket.
- Hosting: globales CDN von Google, statische Auslieferung mit
  Caching-Headers.
- Firebase-SLA: **99,95 % Monatsverfügbarkeit** (vertraglich zugesichert
  durch Google).

### 3.2 Rasche Wiederherstellbarkeit
- **Tägliches Firestore-Backup** automatisch via Scheduled Cloud Function
  um 02:00 Uhr Europe/Berlin nach `gs://<project>-backups/firestore-<ts>/`.
  Aufbewahrung 30 Tage.
- Bei Datenverlust ist Restore aus dem letzten Backup binnen 4 h möglich.

---

## 4. Auftragskontrolle (Art. 28)

- Kein Einsatz weiterer Auftragsverarbeiter ohne dokumentierte Genehmigung
  oder Auflistung in der Subprocessor-Liste (siehe `subprocessor-list.md`).
- Aktuell genutzter Unterauftragsverarbeiter:
  **Google LLC / Google Ireland Limited** (Firebase + Google Cloud).
  Auftragsverarbeitungsvertrag mit Google (Google Cloud Data Processing
  Addendum) ist abgeschlossen und enthält EU-Standardvertragsklauseln (SCC)
  sowie eine Selbstzertifizierung nach dem EU-US Data Privacy Framework
  (DPF, Participant ID 5780).
- Mitarbeitende sind auf Vertraulichkeit nach Art. 28 Abs. 3 lit. b DSGVO
  schriftlich verpflichtet.

---

## 5. Datenträgerkontrolle & Löschkonzept

### 5.1 Standard-Löschfristen
- **Aktive Fahrer:** Daten werden für die Dauer des Beschäftigungs-
  verhältnisses verarbeitet.
- **Beendete Fahrer (Soft-Delete):** Daten werden für 6 Monate
  ("Schattenkopie") aufbewahrt, dann automatisch via Scheduled Function
  (`purgeExpiredSoftDeletes`) endgültig gelöscht — inklusive aller
  Storage-Files.
- **Audit-Log:** Aufbewahrung 3 Jahre (Nachweispflicht), danach
  automatische Pseudonymisierung.
- **Cloud-Functions-Logs:** 30 Tage.
- **Backups:** 30 Tage rollierend, danach automatisch überschrieben.

### 5.2 Gesetzliche Aufbewahrungsfristen (vorrangig)
Daten, die unter gesetzlicher Aufbewahrungspflicht stehen
(z. B. Lohnsteuer §§ 41, 41a EStG, Sozialversicherungsbeiträge §28f SGB IV),
werden entsprechend länger aufbewahrt — die DSGVO-Löschung wird in diesem
Fall durch eine Sperrung ersetzt, bis die gesetzliche Frist abläuft.

---

## 6. Datenschutz-Folgenabschätzung (DSFA, Art. 35)

Eine DSFA wurde durchgeführt für die folgenden Verarbeitungstätigkeiten:
- Erfassung von Führerscheindaten (Sonderkategorie nach § 21 StVG)
- Standortdaten von Fahrern (sofern aktiviert)
- Schicht-/Zeiterfassung

Ergebnis: Die getroffenen TOMs (Verschlüsselung, Zugriffskontrolle,
Audit-Log, Soft-Delete) reduzieren das Risiko auf ein vertretbares Maß.

---

## 7. Verfahren zur regelmäßigen Überprüfung (Art. 32 Abs. 1 lit. d)

- **Quartalsweise Review** der Firestore-/Storage-Rules durch das
  Development-Team mit Protokoll.
- **Halbjährlich** Penetration-Test (extern beauftragt) — Bericht wird im
  Compliance-Ordner archiviert.
- **Monatliche** Stichprobe des Audit-Logs auf Auffälligkeiten.
- **Automatische Alerts** bei: ungewöhnlichen Zugriffsmustern, Cloud
  Functions-Fehlerraten > 5 %, Backup-Failures.

---

## 8. Datenschutz-Vorfälle (Art. 33/34)

- Meldepflicht innerhalb 72 h nach Kenntnisnahme an die zuständige
  Aufsichtsbehörde (bei Sitz in Bayern: BayLDA;
  Sitz NRW: LDI NRW; Sitz BW: LfDI BW).
- Vorlage eines vorbereiteten Incident-Response-Plans
  (`docs/compliance/incident-response.md` — TBD, wird bei Bedarf
  ausgearbeitet).

---

## 9. Änderungshistorie

| Datum       | Version | Änderung                                  | Autor |
|-------------|---------|-------------------------------------------|-------|
| 2026-05-17  | 1.0     | Erstfassung, vor EU-Migration             | CoDRIVER |
