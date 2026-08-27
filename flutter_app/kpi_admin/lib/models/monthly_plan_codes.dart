// lib/models/monthly_plan_codes.dart
//
// Konfigurierbare Tagescodes des Monatsplans ("Spesen Fast Check").
//
// Gespeichert unter users/{uid}/settings/monthly_plan.dayCodes als Liste:
//   [{ code: 'A', label: '', spesen: true, spesenRate: null,
//      color: '#RRGGBB' }, ...]
//
//  * `spesenRate: null` heißt "globaler Spesensatz" (Feld `spesenRate`
//    des Settings-Dokuments); eine Zahl überschreibt ihn für diesen Code.
//  * `color: null` heißt "eingebaute Standardfarbe" — die 14 historischen
//    Codes behalten so exakt ihre bisherigen Farben. Neue Codes bekommen
//    beim Anlegen eine feste Farbe aus [kMonthlyPlanCodePalette]
//    zugewiesen und gespeichert, damit sie überall identisch aussehen.
//  * Fehlt das Feld `dayCodes` komplett (Bestandskunden), wird über
//    [defaultMonthlyPlanCodes] EXAKT der historische Zustand abgeleitet:
//    [kDefaultDayCodes]-Reihenfolge, Spesen-Flag aus
//    [kDefaultSpesenCodes], Beschriftungen aus dem bestehenden
//    `codeLabels`-Feld.
//
// WICHTIG (Bestandsschutz): Zellen der Monats-Dokumente speichern nur den
// Code-String. Codes, die in der konfigurierten Liste nicht (mehr)
// existieren, bleiben im Grid sichtbar (Farb-Fallback in der Seite),
// zählen aber nicht mehr als Spesen- oder Arbeitstag. Umbenennen oder
// Löschen eines Codes schreibt NIE Bestandsdaten um.

import 'dart:ui' show Color;

/// Historische Standard-Codes — Reihenfolge = Anzeige-Reihenfolge.
const List<String> kDefaultDayCodes = [
  'A', 'AC', 'AB', 'C', 'U', 'K', 'X', 'F', 'S', 'SA', 'Ra', 'OSM', 'P', 'N',
];

/// Historische Codes, die einen Spesen-Tag auslösen.
const Set<String> kDefaultSpesenCodes = {'A', 'AC', 'Ra', 'AB'};

/// Historische Codes, die als Arbeitstag zählen (kompakte Handy-Ansicht).
/// Konfigurierte Codes zählen als Arbeitstag, wenn sie hier stehen ODER
/// Spesen aktiv haben (neue Codes: "Spesen an" => Arbeitstag).
const Set<String> kDefaultWorkCodes = {'A', 'AC', 'C', 'Ra', 'AB', 'OSM'};

/// Farb-Palette für NEU angelegte Codes — bewusst pastellig (dunkler Text
/// bleibt lesbar) und disjunkt zu den 14 eingebauten Standardfarben.
const List<String> kMonthlyPlanCodePalette = [
  '#FCD34D', // amber
  '#67E8F9', // cyan
  '#F0ABFC', // fuchsia
  '#BEF264', // lime
  '#99F6E4', // teal light
  '#C7D2FE', // indigo light
  '#FBCFE8', // pink light
  '#FED7AA', // orange light
  '#A5F3FC', // sky light
  '#D9F99D', // green-lime light
  '#E9D5FF', // purple light
  '#FDE68A', // yellow light
];

/// Nächste freie Palettenfarbe für einen neuen Code. Sind alle Farben
/// vergeben, wird zyklisch weitergezählt (Anzahl belegter Einträge).
String nextMonthlyPlanCodeColor(Iterable<String?> usedHexes) {
  final used = {
    for (final h in usedHexes)
      if (h != null) h.toUpperCase(),
  };
  for (final c in kMonthlyPlanCodePalette) {
    if (!used.contains(c.toUpperCase())) return c;
  }
  return kMonthlyPlanCodePalette[
      used.length % kMonthlyPlanCodePalette.length];
}

/// `'#RRGGBB'` → [Color]; `null`/ungültig → `null` (Fallback der Seite).
Color? parseMonthlyPlanCodeColor(String? hex) {
  if (hex == null) return null;
  final h = hex.replaceFirst('#', '').trim();
  if (h.length != 6) return null;
  final v = int.tryParse(h, radix: 16);
  if (v == null) return null;
  return Color(0xFF000000 | v);
}

/// Ein konfigurierbarer Tagescode des Monatsplans.
class MonthlyPlanCode {
  const MonthlyPlanCode({
    required this.code,
    this.label = '',
    this.spesen = false,
    this.spesenRate,
    this.colorHex,
  });

  /// Kürzel in der Zelle (1–4 Zeichen). Groß-/Kleinschreibung bleibt
  /// erhalten, damit der historische Code „Ra" exakt weiter passt.
  final String code;

  /// Eigene Beschriftung; leer = Standardbeschriftung der Seite.
  final String label;

  /// Zählt dieser Code als Spesen-Tag?
  final bool spesen;

  /// €-Satz pro Tag NUR für diesen Code; `null` = globaler Satz.
  final double? spesenRate;

  /// `'#RRGGBB'` oder `null` (= eingebaute Standardfarbe / Fallback).
  final String? colorHex;

  Map<String, dynamic> toMap() => {
        'code': code,
        'label': label,
        'spesen': spesen,
        'spesenRate': spesenRate,
        'color': colorHex,
      };

  /// Tolerantes Einlesen — fehlende/kaputte Felder fallen auf sichere
  /// Defaults zurück, ein leerer Code liefert `null` (Eintrag ignorieren).
  static MonthlyPlanCode? fromMap(Map<dynamic, dynamic> m) {
    final code = (m['code'] ?? '').toString().trim();
    if (code.isEmpty || code.length > 4) return null;
    final rate = m['spesenRate'];
    final color = m['color'];
    return MonthlyPlanCode(
      code: code,
      label: (m['label'] ?? '').toString().trim(),
      spesen: m['spesen'] == true,
      spesenRate: rate is num && rate >= 0 ? rate.toDouble() : null,
      colorHex: color is String && color.trim().isNotEmpty
          ? color.trim()
          : null,
    );
  }
}

/// Abgeleiteter Default für Bestandskunden ohne `dayCodes`-Feld:
/// EXAKT der historische Zustand (Reihenfolge, Spesen-Flags, vorhandene
/// eigene Beschriftungen aus `codeLabels`; Satz = global, Farbe = Standard).
List<MonthlyPlanCode> defaultMonthlyPlanCodes(
    [Map<String, String> codeLabels = const {}]) {
  return [
    for (final c in kDefaultDayCodes)
      MonthlyPlanCode(
        code: c,
        label: codeLabels[c]?.trim() ?? '',
        spesen: kDefaultSpesenCodes.contains(c),
      ),
  ];
}
