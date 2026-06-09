# Rechnungs-Finder

Eigenständiges, lokales Tool (**unabhängig von der CoDriver-App** — kein Firebase, kein Flutter):
Es liest deinen Kontoauszug, durchsucht mehrere E-Mail-Postfächer (IONOS / IMAP) nach den
passenden Rechnungs-PDFs und speichert sie gesammelt in einen Ordner — inklusive
Zuordnungstabelle, welche Abbuchung zu welcher Datei gehört und wo noch Belege fehlen.

## Funktionsweise

1. **Kontoauszug hochladen** — CSV-Export der Bank (empfohlen) oder PDF-Auszug (Best-Effort).
   Erkannt werden die üblichen Spalten deutscher Banken (Buchungstag, Betrag,
   Empfänger/Begünstigter, Verwendungszweck), deutsches und englisches Zahlenformat.
2. **Suche** — jedes konfigurierte Postfach wird **einmal** über den relevanten Zeitraum
   (Standard: 45 Tage vor bis 10 Tage nach den Abbuchungen) nach Mails mit PDF-Anhängen
   durchsucht. Die Zuordnung passiert danach lokal per Punktesystem:
   - Betrag der Abbuchung steht im PDF (+50) oder in der Mail (+15)
   - Empfängername passt zum Mail-Absender (+30) oder steht im PDF (+15)
   - Maildatum liegt nah am Buchungsdatum (bis +10)

   Ab 60 Punkten gilt ein Treffer als „sicher“, darunter als „bitte prüfen“.
3. **Speichern** — die PDFs werden **pro Monat in Ordner sortiert, getrennt nach
   Ausgaben und Einnahmen**, mit sprechendem Dateinamen:

   ```
   belege/
   ├── 2026-05/
   │   ├── Ausgaben/
   │   │   └── 2026-05-12_Amazon_-49,99EUR.pdf
   │   └── Einnahmen/
   │       └── 2026-05-20_Kunde_GmbH_1500,00EUR.pdf
   ├── 2026-06/
   │   └── …
   └── zuordnung.csv
   ```

   Die `zuordnung.csv` (Excel-kompatibel, Semikolon, UTF-8-BOM) listet alle Treffer
   mit Pfad **und** die Buchungen ohne Beleg, sortiert nach Datum.
   Es werden Belege für beide Richtungen gesucht: Abbuchungen (Eingangsrechnungen)
   und Gutschriften (z. B. deine Ausgangsrechnungen an Kunden).

## Einrichtung

```bash
cd rechnungs_finder
python -m venv .venv && source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install -r requirements.txt

cp config.example.yaml config.yaml
# config.yaml öffnen und Postfächer eintragen (IONOS: imap.ionos.de, Port 993)
```

> **Hinweis zu Passwörtern:** Die Zugangsdaten stehen in `config.yaml` im Klartext.
> Die Datei ist per `.gitignore` vom Repository ausgeschlossen — niemals einchecken.
> Bei IONOS funktioniert das normale Postfach-Passwort; falls du 2FA nutzt,
> in IONOS ein App-Passwort für IMAP anlegen.

## Starten

```bash
uvicorn app:app --port 8765
```

Dann im Browser öffnen: **http://127.0.0.1:8765**

## Konfiguration (`config.yaml`)

| Schlüssel | Bedeutung | Standard |
|---|---|---|
| `mailboxes[].host` / `port` | IMAP-Server | `imap.ionos.de` / `993` |
| `mailboxes[].folders` | Zu durchsuchende IMAP-Ordner | `INBOX` |
| `search.days_before` | Suchfenster vor dem Buchungsdatum | `45` |
| `search.days_after` | Suchfenster nach dem Buchungsdatum | `10` |
| `search.min_score` | Punkte, ab denen ein Treffer „sicher“ ist | `60` |
| `output.directory` | Zielordner für PDFs + `zuordnung.csv` | `./belege` |

## Grenzen / bekannte Punkte

- **PDF-Kontoauszüge** sind bank-spezifisch; der eingebaute Parser ist ein generischer
  Best-Effort (`Datum … Betrag` pro Zeile). Wenn dein Auszug nicht erkannt wird:
  CSV-Export nutzen oder den Parser in `statement_parser.py` (`parse_pdf_statement`)
  an das Layout deiner Bank anpassen.
- **Gescannte Rechnungen** (reine Bild-PDFs ohne Textebene) können nicht per Betrag
  durchsucht werden — solche Treffer stützen sich nur auf Absender und Datum.
- Rechnungen, die als **Link statt Anhang** verschickt werden (häufig bei Telekom & Co.),
  findet das Tool nicht.
- Das Tool ist für die **lokale Nutzung durch eine Person** gedacht (kein Login,
  Zustand liegt im Arbeitsspeicher des Prozesses).
