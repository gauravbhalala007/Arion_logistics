DateTime _dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);

/// Zehrt dieser einzelne Tag Urlaubskontingent auf?
///
/// Wochenenden und die neun bundesweiten Feiertage nicht.
bool isVacationChargeableDay(DateTime value) =>
    !_isWeekend(value) && !_isGermanyPublicHoliday(value);

int vacationChargeableDays(DateTime? from, DateTime? to) {
  if (from == null || to == null) return 0;
  final start = _dateOnly(from);
  final end = _dateOnly(to);
  if (end.isBefore(start)) return 0;

  var total = 0;
  for (var day = start;
      !day.isAfter(end);
      day = day.add(const Duration(days: 1))) {
    if (_isWeekend(day) || _isGermanyPublicHoliday(day)) {
      continue;
    }
    total += 1;
  }
  return total;
}

bool _isWeekend(DateTime value) =>
    value.weekday == DateTime.saturday || value.weekday == DateTime.sunday;

/// Bundesweite deutsche Feiertage (die 9 nationalen, ohne Länder-Extras).
bool isGermanyPublicHoliday(DateTime value) => _isGermanyPublicHoliday(value);

bool _isGermanyPublicHoliday(DateTime value) {
  final date = _dateOnly(value);
  final easter = _easterSunday(date.year);

  final holidays = <DateTime>{
    DateTime(date.year, 1, 1),
    easter.subtract(const Duration(days: 2)), // Good Friday
    easter.add(const Duration(days: 1)), // Easter Monday
    DateTime(date.year, 5, 1),
    easter.add(const Duration(days: 39)), // Ascension Day
    easter.add(const Duration(days: 50)), // Whit Monday
    DateTime(date.year, 10, 3),
    DateTime(date.year, 12, 25),
    DateTime(date.year, 12, 26),
  };

  return holidays.contains(date);
}

DateTime _easterSunday(int year) {
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

/// Arbeitstage eines Monats nach deutschem Kalender.
///
/// Montag bis Freitag ohne die neun bundesweiten Feiertage — die Basis
/// für die gesetzlichen Sollstunden eines Monats (Arbeitstage × Stunden
/// pro Tag). Länder-Feiertage (z. B. Fronleichnam) sind bewusst NICHT
/// enthalten: Sie gelten nicht überall, und die Sollstunden lassen sich
/// im Zeitkonto ohnehin je Monat übersteuern.
int germanWorkdaysInMonth(int year, int month) {
  final firstOfNext = month == 12
      ? DateTime(year + 1, 1, 1)
      : DateTime(year, month + 1, 1);
  var count = 0;
  for (var day = DateTime(year, month, 1);
      day.isBefore(firstOfNext);
      day = day.add(const Duration(days: 1))) {
    if (_isWeekend(day) || _isGermanyPublicHoliday(day)) continue;
    count += 1;
  }
  return count;
}
