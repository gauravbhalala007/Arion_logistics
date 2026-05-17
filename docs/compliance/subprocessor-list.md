# Unterauftragsverarbeiter (Subprocessor List) — CoDRIVER

**Stand:** 2026-05-17
**Version:** 1.0
**Anlage zum:** Auftragsverarbeitungsvertrag (AVV)

> Diese Liste benennt alle Unterauftragsverarbeiter, die CoDRIVER zur
> Erbringung der Plattformleistung einsetzt. Änderungen werden den
> Verantwortlichen mindestens **30 Tage vor Aktivierung** schriftlich
> (E-Mail) angekündigt. Der Verantwortliche hat das Recht, einer
> Änderung aus wichtigem Grund schriftlich zu widersprechen.

---

## Aktuelle Unterauftragsverarbeiter

### 1. Google Ireland Limited

| Feld                | Wert |
|---------------------|------|
| **Anbieter**        | Google Ireland Limited |
| **Sitz**            | Gordon House, Barrow Street, Dublin 4, Irland |
| **Konzernmutter**   | Google LLC (USA) |
| **Eingesetzte Dienste** | Firebase Authentication, Cloud Firestore, Cloud Storage for Firebase, Cloud Functions for Firebase, Firebase Hosting, Cloud Logging |
| **Verarbeitungsort** | Region `europe-west3` (Frankfurt am Main); für Firestore zusätzlich `europe-west1` (Belgien) und `europe-west4` (Niederlande) als Multi-Region-Replikate (`eur3`) |
| **Datenkategorien** | Sämtliche im Rahmen der CoDRIVER-Nutzung verarbeiteten personenbezogenen Daten (Fahrer-Stammdaten, Schichtdaten, Dokumente, Audit-Logs) |
| **Zweck**           | Bereitstellung der technischen Plattform (Datenbank, Authentifizierung, Dateispeicherung, Server-Logik, Hosting) |
| **Rechtsgrundlage Subverarbeitung** | Art. 28 Abs. 4 DSGVO i. V. m. Google Cloud Data Processing Addendum (DPA), inkl. EU-Standardvertragsklauseln (Modul 3 — Processor-to-Subprocessor) |
| **Drittlandübermittlung** | Im Regelbetrieb erfolgt **keine** Datenübermittlung in Drittländer. Theoretischer Zugriff durch Google LLC (USA) ist abgesichert durch (a) EU-Standardvertragsklauseln im Google DPA und (b) Selbstzertifizierung von Google LLC nach dem EU-US Data Privacy Framework (DPF) — Participant ID 5780 (https://www.dataprivacyframework.gov/participant/5780) |
| **AVV vorhanden**   | Ja — Google Cloud Data Processing Addendum, akzeptiert in der Firebase Console |
| **Zertifizierungen** | ISO/IEC 27001, 27017, 27018; SOC 1/2/3; PCI DSS Level 1; HIPAA |
| **Beleg / Quellen** | https://cloud.google.com/security/compliance · https://firebase.google.com/support/privacy |

---

## Geplante Subprocessor (zukünftig)

Es sind aktuell keine weiteren Unterauftragsverarbeiter geplant. Bei
zukünftiger Einbindung (z. B. E-Mail-Versand über externen Dienst, KI-API
für Übersetzungen) wird diese Liste 30 Tage vor Inbetriebnahme aktualisiert
und allen Verantwortlichen per E-Mail bekannt gegeben.

---

## Historie

| Datum       | Änderung                                | Autor |
|-------------|-----------------------------------------|-------|
| 2026-05-17  | Erstfassung — nur Google Ireland Limited als Subprocessor | CoDRIVER |
