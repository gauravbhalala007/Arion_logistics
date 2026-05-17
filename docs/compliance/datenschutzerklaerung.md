# Datenschutzerklärung — CoDRIVER

**Stand:** 2026-05-17
**Version:** 1.0

> Diese Datenschutzerklärung informiert die Nutzer der CoDRIVER-Plattform
> (Fahrer, Dispatcher, Admins, Bewerber) über die Verarbeitung ihrer
> personenbezogenen Daten gemäß Art. 13 / 14 DSGVO.
>
> Für die Verarbeitung von Beschäftigtendaten ist im
> Beschäftigungsverhältnis der jeweilige Arbeitgeber (DSP) der
> **Verantwortliche** gemäß Art. 4 Nr. 7 DSGVO. **Kreativwerk Albert Dobra**
> stellt als technischer Anbieter die Plattform bereit und fungiert als
> **Auftragsverarbeiter** gemäß Art. 28 DSGVO — die Verarbeitung erfolgt
> ausschließlich auf dokumentierte Weisung des Verantwortlichen.

---

## 1. Anbieter der Plattform (Auftragsverarbeiter)

**Kreativwerk Albert Dobra** (Einzelunternehmen)
Gustav-Weißkopf-Str. 12
90768 Fürth
Deutschland
E-Mail: info@kw-agentur.de
Telefon: 0170 8139442

**Datenschutzbeauftragter:**
Es ist kein Datenschutzbeauftragter benannt, da die Voraussetzungen
nach § 38 Abs. 1 BDSG nicht erfüllt sind (Einzelunternehmen ohne
Angestellte). Datenschutzanfragen erreichen den Anbieter direkt unter
**info@kw-agentur.de**.

## 1a. Verantwortlicher für Beschäftigtendaten

Verantwortlicher im Sinne von Art. 4 Nr. 7 DSGVO für die im
Beschäftigungsverhältnis verarbeiteten Daten ist der jeweilige
**Arbeitgeber (DSP-Unternehmen)** des Beschäftigten. Die Kontaktdaten
des Verantwortlichen erhältst du über deinen Arbeitgeber.

---

## 2. Welche Daten wir verarbeiten

### 2.1 Stammdaten (Pflicht für Account)
- Name, Vorname
- E-Mail-Adresse
- Rolle (Admin, Dispatcher, Fahrer, Bewerber)
- bei Fahrern: Personalnummer, Vertragsart (Voll-/Teilzeit/Minijob/etc.),
  zugeordneter DSP

### 2.2 Beschäftigungsbezogene Daten (bei Fahrern, im Auftrag des DSP)
- Adresse, Geburtsdatum, Telefonnummer
- Steuer-ID, Sozialversicherungsnummer (sofern hochgeladen)
- Personalausweis / Reisepass (Vorder- + Rückseite)
- Aufenthaltsgenehmigung
- Krankenkasseninfo
- Führerscheindaten (Fahrzeugklassen, Ablaufdatum)
- Arbeitsvertrag, Vertragszusätze
- Schicht-/Zeiterfassungsdaten, Pausen, Abwesenheiten
- Profilbild (optional)

### 2.3 Bewerber-Daten (Recruiting-Modul)
- Name, Kontaktdaten
- Lebenslauf / Zeugnisse
- Führerscheinkopie
- Sonstige durch den Bewerber freiwillig hochgeladene Unterlagen

### 2.4 System- und Nutzungsdaten
- Authentifizierungs-Tokens (Firebase Auth)
- Login-Zeitstempel
- Schreibzugriffe auf Fahrer-Daten (Audit-Log: WER hat WANN WELCHES Feld
  geändert — Werte werden NICHT gespeichert)
- Push-Notification-Token (für Benachrichtigungen)
- Anonymisierte Performance-Logs (zur Fehlerdiagnose)

Es werden **keine Standortdaten** im laufenden Betrieb verarbeitet, es sei
denn der Arbeitgeber aktiviert das optionale co:timer-Modul mit
Geofence-Validierung. In diesem Fall wird der Standort ausschließlich zum
Zeitpunkt eines Clock-In/Clock-Out abgefragt und sofort verworfen.

### 2.5 Cookies / lokaler Speicher
Die Anwendung nutzt ausschließlich **technisch notwendige** Cookies bzw.
lokalen Browser-Speicher (Authentifizierung, Sprach-Präferenz). Es werden
keine Tracking-, Werbe- oder Analyse-Cookies eingesetzt.

---

## 3. Zwecke und Rechtsgrundlagen

| Zweck | Rechtsgrundlage |
|---|---|
| Bereitstellung der Plattform, Vertragserfüllung | Art. 6 Abs. 1 lit. b DSGVO |
| Verarbeitung von Beschäftigtendaten im Beschäftigungsverhältnis | § 26 Abs. 1 BDSG |
| Erfüllung gesetzlicher Pflichten (z. B. Führerschein-Kontrolle § 21 StVG, Aufbewahrungsfristen Steuer-/Sozialrecht) | Art. 6 Abs. 1 lit. c DSGVO |
| Verarbeitung von Identitätsdokumenten (Personalausweis etc.) | § 26 Abs. 1 BDSG i. V. m. arbeitsrechtlichen Nachweispflichten |
| Audit-Log zur Sicherheits- und Nachweispflicht | Art. 6 Abs. 1 lit. f DSGVO (berechtigtes Interesse: Sicherheit) i. V. m. Art. 32 DSGVO |
| Backups | Art. 32 DSGVO (Datenverfügbarkeit) |
| Recruiting-Modul (bis Anstellung) | Art. 6 Abs. 1 lit. b DSGVO (vorvertraglich) |
| Push-Benachrichtigungen | Art. 6 Abs. 1 lit. b DSGVO bzw. Einwilligung Art. 6 Abs. 1 lit. a |
| Bei Sondereinwilligungen (z. B. Veröffentlichung Profilfoto) | Art. 6 Abs. 1 lit. a / § 26 Abs. 2 BDSG |

---

## 4. Empfänger / Auftragsverarbeiter

Wir setzen folgende Auftragsverarbeiter ein:

| Anbieter | Zweck | Standort | Schutzgarantie |
|---|---|---|---|
| **Google Ireland Limited** (Firebase / Google Cloud Platform) | Hosting, Datenbank, Authentifizierung, Cloud Functions, Storage, Logging | `europe-west3` Frankfurt am Main + Multi-Region `eur3` (EU) | Google Cloud DPA mit EU-SCC + DPF-Zertifizierung von Google LLC (USA) |

**Vollständige Subprocessor-Liste:** `subprocessor-list.md`

Eine Übermittlung an weitere Dritte (z. B. Behörden) erfolgt nur, wenn
gesetzlich vorgeschrieben (z. B. richterliche Anordnung).

---

## 5. Drittlandübermittlung

Im **Regelbetrieb** werden alle Daten ausschließlich auf Servern
**innerhalb der EU** (Frankfurt am Main bzw. `eur3` Multi-Region)
verarbeitet.

Theoretischer Zugriff durch Google LLC (USA, Konzernmutter unseres
Subprocessors Google Ireland) ist abgesichert durch:

1. **EU-Standardvertragsklauseln** im Google Cloud Data Processing Addendum
2. **Selbstzertifizierung von Google LLC** nach dem EU-US Data Privacy
   Framework (DPF), Participant ID 5780
   (https://www.dataprivacyframework.gov/participant/5780)

Diese Schutzmechanismen entsprechen Art. 45 ff. DSGVO. Sollte sich die
Rechtslage ändern (z. B. Aufhebung des DPF), prüfen wir unverzüglich
Ersatzmaßnahmen und informieren betroffene Verantwortliche.

---

## 6. Speicherdauer

| Datenkategorie | Speicherdauer |
|---|---|
| Aktive Fahrer-Daten | Für die Dauer des Beschäftigungsverhältnisses |
| Beendete Fahrer (Soft-Delete) | 6 Monate (Schattenkopie für Wiederherstellung/Nachweis), danach automatische Endlöschung |
| Gesetzliche Aufbewahrungsfristen (Steuer, Sozialvers.) | bis zu 10 Jahre — Daten werden für die Dauer der Frist gesperrt, nicht aktiv genutzt |
| Audit-Log | 3 Jahre, danach Pseudonymisierung |
| Login-/System-Logs | 30 Tage |
| Backup-Snapshots | 30 Tage rollierend |
| Bewerber-Daten (ohne Anstellung) | bis 6 Monate nach Absage |
| Push-Tokens | bis zur Abmeldung des Geräts |

---

## 7. Deine Rechte als betroffene Person

Du hast nach DSGVO folgende Rechte:

- **Auskunft** (Art. 15) — über die in der App integrierte
  **DSGVO-Export-Funktion** (1-Klick-ZIP-Export mit allen deinen Daten)
- **Berichtigung** (Art. 16) — über die Profil-Einstellungen oder per
  Anfrage an den Verantwortlichen
- **Löschung** (Art. 17) — über den Arbeitgeber (DSP) bzw. den
  Verantwortlichen. Beachte: gesetzliche Aufbewahrungspflichten können
  eine sofortige Löschung verhindern; Daten werden in diesem Fall
  gesperrt.
- **Einschränkung der Verarbeitung** (Art. 18)
- **Datenübertragbarkeit** (Art. 20) — ebenfalls über den ZIP-Export
- **Widerspruch** (Art. 21) — gegen Verarbeitung auf Grundlage
  berechtigter Interessen
- **Widerruf der Einwilligung** (Art. 7 Abs. 3) — soweit eine
  Verarbeitung auf deiner Einwilligung beruht, mit Wirkung für die Zukunft
- **Beschwerde bei einer Aufsichtsbehörde** (Art. 77) — z. B. die
  Aufsichtsbehörde am Sitz deines Arbeitgebers oder am Sitz des
  Anbieters (Bayerisches Landesamt für Datenschutzaufsicht — BayLDA,
  Ansbach)

Zur Wahrnehmung deiner Rechte kannst du dich an:
- den **Verantwortlichen** (in der Regel deinen Arbeitgeber) oder
- an den **Anbieter Kreativwerk Albert Dobra**: **info@kw-agentur.de**

wenden.

---

## 8. Automatisierte Entscheidungen, Profiling

Es findet **keine** automatisierte Entscheidung im Einzelfall einschließlich
Profiling im Sinne von Art. 22 DSGVO statt. KPI-/Scorecard-Auswertungen
sind reine Informations-Hilfsmittel für menschliche Entscheidungen.

---

## 9. Verpflichtung zur Bereitstellung

Die Bereitstellung der Pflichtangaben (Stammdaten, Identitätsdokumente,
Führerschein) ist im Rahmen des Beschäftigungsverhältnisses zwischen dir
und deinem Arbeitgeber erforderlich. Ohne diese Daten ist die Nutzung
der Plattform und die Durchführung des Arbeitsverhältnisses nicht
möglich.

Andere Angaben (z. B. Profilbild) sind freiwillig.

---

## 10. Datensicherheit

Wir treffen umfangreiche technische und organisatorische Maßnahmen zum
Schutz deiner Daten (siehe `TOM.md`), insbesondere:

- TLS 1.3-Verschlüsselung aller Verbindungen
- Verschlüsselung der Daten bei der Speicherung (AES-256)
- Rollenbasiertes Zugriffsmodell mit feingranularen Security Rules
- Audit-Log aller Schreibzugriffe auf Fahrer-Daten
- Tägliche Backups, 30 Tage Aufbewahrung
- Mandantentrennung pro DSP
- Soft-Delete mit Auto-Purge nach 6 Monaten

---

## 11. Änderungen dieser Datenschutzerklärung

Wir behalten uns vor, diese Erklärung anzupassen, um sie an geänderte
Rechtslagen oder erweiterte Funktionen anzupassen. Über wesentliche
Änderungen informieren wir per E-Mail an Admins und per In-App-Hinweis.

---

## 12. Kontakt

| Anliegen | Kontakt |
|---|---|
| Allgemeine Anfragen (Anbieter) | info@kw-agentur.de — Kreativwerk Albert Dobra |
| Datenschutz-Anfragen / Betroffenenrechte | info@kw-agentur.de bzw. dein Arbeitgeber (DSP) |
| Datenschutzvorfall melden | info@kw-agentur.de — Reaktion innerhalb 48 h |
| Beschwerde Aufsichtsbehörde | Bayerisches Landesamt für Datenschutzaufsicht (BayLDA), Promenade 18, 91522 Ansbach, https://www.lda.bayern.de |

---

## Bemerkung zur juristischen Prüfung

> **WICHTIGER HINWEIS:** Diese Datenschutzerklärung ist eine sorgfältig
> recherchierte Mustervorlage, die die Pflichtangaben aus Art. 13 / 14
> DSGVO und gängige Best-Practice (Stand: Mai 2026) abbildet. Vor der
> Veröffentlichung ist eine **Endprüfung durch einen
> Datenschutzbeauftragten oder Fachanwalt für IT-Recht** dringend
> empfohlen, insbesondere für:
>
> - präzise Firmenadresse, Datenschutzbeauftragten-Kontakt
> - branchenspezifische Aufbewahrungsfristen
> - Sonderkategorien-Behandlung (falls Krankschreibungen / Gesundheitsdaten
>   tatsächlich anfallen)
> - bei Aktivierung optionaler Module (Standortdaten, KI-Übersetzungen)
