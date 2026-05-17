# CoDRIVER — Compliance-Dokumentation

**Anbieter / Auftragsverarbeiter:**
Kreativwerk Albert Dobra (Einzelunternehmen)
Gustav-Weißkopf-Str. 12, 90768 Fürth · info@kw-agentur.de · 0170 8139442

Dieses Verzeichnis enthält die DSGVO-Compliance-Dokumente für CoDRIVER.

## Dateien

| Datei | Zweck | Adressat |
|---|---|---|
| `TOM.md` | Technische und organisatorische Maßnahmen (Art. 32 DSGVO) | Anlage zum AVV |
| `avv.md` | Auftragsverarbeitungsvertrag-Vorlage (Art. 28 DSGVO) | DSP-Kunden |
| `subprocessor-list.md` | Liste der Unterauftragsverarbeiter | Anlage zum AVV |
| `datenschutzerklaerung.md` | Datenschutzerklärung (Art. 13/14 DSGVO) | Endnutzer |

## Status

Alle Dokumente liegen als **inhaltlich vollständige Mustervorlage**
(Version 1.0, Stand 2026-05-17) vor. Vor produktiver Verwendung muss eine
**finale juristische Prüfung** durch einen Datenschutzbeauftragten oder
Fachanwalt erfolgen. Die zu vervollständigenden Stellen sind im jeweiligen
Dokument mit `_______________________________________` markiert.

## Ablage / Versionierung

- Diese Dateien sind im Git versioniert (Audit-Trail).
- Bei Änderungen die "Änderungshistorie"-Tabellen am Ende jedes Dokuments
  aktualisieren.
- Bei Änderung der Subprocessor-Liste: 30 Tage vor Aktivierung an alle
  Kunden senden.

## Verwandte technische Bausteine

- Audit-Log: `firebase/functions/src/audit/`
- DSGVO-Export + Soft-Delete: `firebase/functions/src/dsgvo/`
- Backups: `firebase/functions/src/backup/`
- Storage Security Rules: `firebase/storage.rules`
- Firestore Security Rules: `firebase/firestore.rules`
