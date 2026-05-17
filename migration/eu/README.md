# EU-Migration: Cutover auf `codriver-eu`

> **Ziel:** Vollstaendige Migration der CoDRIVER-Produktion von
> `gaurav-arion-001-3d94a` (US-Region `nam5`) auf `codriver-eu`
> (EU-Region `eur3` Frankfurt) **ohne Datenverlust**.

## Phasen

| Phase | Was | Wer | Wann |
|---|---|---|---|
| **0** | EU-Projekt anlegen, Firestore/Storage in EU, Auth, Blaze | Nutzer | ✅ erledigt |
| **1** | DSGVO-Soft-Massnahmen im alten Projekt | Claude | ✅ erledigt |
| **2A** | Migration-Scripts vorbereiten | Claude | ✅ erledigt (dieses Dir) |
| **2B** | Pre-Cutover Setup im EU-Projekt (Rules, Functions, Indexes — ohne Daten) | Claude + Nutzer | jederzeit moeglich |
| **2C** | Trockenlauf: 1 Test-User aus altem Projekt ins EU-Projekt importieren | Claude + Nutzer | vor Cutover |
| **3**  | Cutover-Nacht (Wartungsfenster) | Claude + Nutzer | 1 Termin in Absprache |
| **4**  | Stabilisierung (T+0 bis T+14), Alt-Projekt loeschen | Claude + Nutzer | nach Cutover |

## Datei-Struktur

```
migration/eu/
├── README.md                  (du bist hier)
├── docs/
│   ├── 01-prerequisites.md    Was im Console + lokal vorbereitet sein muss
│   ├── 05-cutover-runbook.md  Die Nacht-Choreografie minutengenau
│   └── 06-rollback.md         Notausstieg falls etwas schief geht
├── scripts/
│   ├── env.example            Vorlage fuer eigene Config
│   ├── 02a-prep-eu-project.sh Pre-Cutover: Rules/Functions/Indexes ins EU-Projekt
│   ├── 02b-test-single-user.sh Trockenlauf mit 1 Test-User
│   ├── 03-export-old.sh       Auth + Firestore aus altem Projekt exportieren
│   ├── 04-import-eu.sh        In EU-Projekt importieren + Web neu deployen
│   ├── 07-readonly-old.sh     Altes Projekt nach Cutover read-only sperren
│   └── 99-final-cleanup.sh    Nach T+14: Alt-Projekt-Backup + Loeschung
└── exports/                   (wird zur Laufzeit befuellt — gitignore'd)
```

## Quickstart

```bash
cd migration/eu/scripts

# 1) Config anlegen (einmalig)
cp env.example .env
# .env editieren — Passwort-Hash-Parameter eintragen (siehe 01-prerequisites.md)

# 2) Pre-Cutover Setup (kann Wochen vorher passieren, ohne Effekt)
./02a-prep-eu-project.sh

# 3) Trockenlauf mit 1 User
./02b-test-single-user.sh

# 4) An Cutover-Tag (T-0): siehe docs/05-cutover-runbook.md
```

## Sicherheitsgarantien

- Alle Schritte sind **idempotent** — du kannst sie mehrfach ausfuehren.
- Das alte Projekt wird **nicht angetastet**, bis es read-only gesetzt
  wird (Schritt 7) — und auch dann bleiben alle Daten erhalten.
- Loeschung des alten Projekts erfolgt **nur** in Script 99 nach
  expliziter Bestaetigung + Final-Backup (Aufbewahrung 90 Tage).
- Bei jedem Schritt wird der aktuelle State protokolliert in
  `exports/log-YYYYMMDD.txt`.
