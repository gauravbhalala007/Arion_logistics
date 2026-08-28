// lib/utils/german_holidays.dart
//
// Gesetzliche Feiertage in Deutschland je Bundesland, berechnet für ein
// beliebiges Jahr (Gauß'sche Osterformel für die beweglichen Feiertage).
// Verwendet vom Flexplan: Schichten gelten an jedem Tag außer Sonntag und
// Feiertag — welcher Feiertag gilt, hängt vom gewählten Bundesland ab.
//
// Regionale Sonderfälle unterhalb der Landesebene (z. B. Augsburger
// Friedensfest, Fronleichnam nur in Teilen von SN/TH, Mariä Himmelfahrt
// nur in katholischen Gemeinden Bayerns) sind bewusst NICHT abgebildet.

/// Bundesländer: Code → Anzeigename.
const List<({String code, String name})> kGermanRegions = [
  (code: 'BW', name: 'Baden-Württemberg'),
  (code: 'BY', name: 'Bayern'),
  (code: 'BE', name: 'Berlin'),
  (code: 'BB', name: 'Brandenburg'),
  (code: 'HB', name: 'Bremen'),
  (code: 'HH', name: 'Hamburg'),
  (code: 'HE', name: 'Hessen'),
  (code: 'MV', name: 'Mecklenburg-Vorpommern'),
  (code: 'NI', name: 'Niedersachsen'),
  (code: 'NW', name: 'Nordrhein-Westfalen'),
  (code: 'RP', name: 'Rheinland-Pfalz'),
  (code: 'SL', name: 'Saarland'),
  (code: 'SN', name: 'Sachsen'),
  (code: 'ST', name: 'Sachsen-Anhalt'),
  (code: 'SH', name: 'Schleswig-Holstein'),
  (code: 'TH', name: 'Thüringen'),
];

String germanRegionName(String code) {
  for (final r in kGermanRegions) {
    if (r.code == code) return r.name;
  }
  return code;
}

/// Ostersonntag (Gregorianisch) — anonyme Gauß-Formel.
DateTime easterSunday(int year) {
  final a = year % 19;
  final b = year ~/ 100;
  final c = year % 100;
  final d = b ~/ 4;
  final e = b % 4;
  final f = (b + 8) ~/ 25;
  final g = (b - f + 1) ~/ 3;
  final h = (19 * a + b - d - g + 15) % 30;
  final i = c ~/ 4;
  final k = c % 4;
  final l = (32 + 2 * e + 2 * i - h - k) % 7;
  final m = (a + 11 * h + 22 * l) ~/ 451;
  final month = (h + l - 7 * m + 114) ~/ 31;
  final day = ((h + l - 7 * m + 114) % 31) + 1;
  return DateTime(year, month, day);
}

String _key(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

/// Gesetzliche Feiertage eines Jahres für ein Bundesland.
/// Rückgabe: Datums-Key ('yyyy-MM-dd') → Feiertagsname.
/// Unbekannter/leerer [regionCode] liefert nur die bundesweiten Feiertage.
Map<String, String> germanHolidays(int year, String regionCode) {
  final region = regionCode.trim().toUpperCase();
  final easter = easterSunday(year);
  final out = <String, String>{};

  void add(DateTime d, String name) => out[_key(d)] = name;
  bool inR(List<String> regions) => regions.contains(region);

  // Bundesweit.
  add(DateTime(year, 1, 1), 'Neujahr');
  add(easter.subtract(const Duration(days: 2)), 'Karfreitag');
  add(easter.add(const Duration(days: 1)), 'Ostermontag');
  add(DateTime(year, 5, 1), 'Tag der Arbeit');
  add(easter.add(const Duration(days: 39)), 'Christi Himmelfahrt');
  add(easter.add(const Duration(days: 50)), 'Pfingstmontag');
  add(DateTime(year, 10, 3), 'Tag der Deutschen Einheit');
  add(DateTime(year, 12, 25), '1. Weihnachtstag');
  add(DateTime(year, 12, 26), '2. Weihnachtstag');

  // Landesspezifisch.
  if (inR(['BW', 'BY', 'ST'])) {
    add(DateTime(year, 1, 6), 'Heilige Drei Könige');
  }
  if (inR(['BE', 'MV'])) {
    add(DateTime(year, 3, 8), 'Internationaler Frauentag');
  }
  if (inR(['BW', 'BY', 'HE', 'NW', 'RP', 'SL'])) {
    add(easter.add(const Duration(days: 60)), 'Fronleichnam');
  }
  if (inR(['SL'])) {
    add(DateTime(year, 8, 15), 'Mariä Himmelfahrt');
  }
  if (inR(['TH'])) {
    add(DateTime(year, 9, 20), 'Weltkindertag');
  }
  if (inR(['BB', 'HB', 'HH', 'MV', 'NI', 'SN', 'ST', 'SH', 'TH'])) {
    add(DateTime(year, 10, 31), 'Reformationstag');
  }
  if (inR(['BW', 'BY', 'NW', 'RP', 'SL'])) {
    add(DateTime(year, 11, 1), 'Allerheiligen');
  }
  if (inR(['SN'])) {
    // Buß- und Bettag: Mittwoch vor dem 23. November.
    var d = DateTime(year, 11, 22);
    while (d.weekday != DateTime.wednesday) {
      d = d.subtract(const Duration(days: 1));
    }
    add(d, 'Buß- und Bettag');
  }

  return out;
}
