import 'package:cloud_firestore/cloud_firestore.dart';

/// One employment stint of a driver.
///
/// Rehires are common: a driver leaves and comes back later — sometimes with a
/// different Transporter-ID. Instead of overwriting the single legacy contract
/// fields we keep a list of periods on the driver document:
///
/// ```
/// employmentPeriods: [
///   { start: '2024-03-01', end: '2024-11-30', transporterId: 'A1B2C3' },
///   { start: '2026-06-17', end: '',           transporterId: 'A9Z8Y7' },
/// ]
/// ```
///
/// `end` is an empty string (or missing) while the contract is still running.
/// Dates are ISO `YYYY-MM-DD` strings.
///
/// The legacy single-value fields (`transporterId`,
/// `onboarding.workStartDate`, `onboarding.contractExpiry`,
/// `onboarding.contractUnlimited`) stay authoritative for every existing
/// report, filter and the wave-plan matching — they are always mirrored from
/// the current (running, else newest) period. See [employmentPeriodsMirror].
class EmploymentPeriod {
  const EmploymentPeriod({
    required this.start,
    this.end = '',
    this.transporterId = '',
  });

  /// ISO `YYYY-MM-DD`, never empty for a valid period.
  final String start;

  /// ISO `YYYY-MM-DD`, empty while the contract is running.
  final String end;

  /// Transporter-ID used during this period (may differ after a rehire).
  final String transporterId;

  bool get isOngoing => end.trim().isEmpty;

  DateTime? get startDate => parseFlexibleDate(start);
  DateTime? get endDate => parseFlexibleDate(end);

  EmploymentPeriod copyWith({
    String? start,
    String? end,
    String? transporterId,
  }) {
    return EmploymentPeriod(
      start: start ?? this.start,
      end: end ?? this.end,
      transporterId: transporterId ?? this.transporterId,
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'start': start.trim(),
        'end': end.trim(),
        'transporterId': transporterId.trim(),
      };

  static EmploymentPeriod? fromMap(Object? raw) {
    if (raw is! Map) return null;
    final map = raw.map((k, v) => MapEntry(k.toString(), v));
    final start = parseFlexibleDate(map['start']);
    if (start == null) return null;
    final end = parseFlexibleDate(map['end']);
    return EmploymentPeriod(
      start: formatIsoDate(start),
      end: end == null ? '' : formatIsoDate(end),
      transporterId: (map['transporterId'] ?? '').toString().trim(),
    );
  }

  /// True when this period covers [day] (inclusive on both ends).
  bool coversDay(DateTime day) {
    final s = startDate;
    if (s == null) return false;
    final d = DateTime(day.year, day.month, day.day);
    if (d.isBefore(DateTime(s.year, s.month, s.day))) return false;
    final e = endDate;
    if (e == null) return true;
    return !d.isAfter(DateTime(e.year, e.month, e.day));
  }

  /// True when this period overlaps the calendar month of [month].
  bool overlapsMonth(DateTime month) {
    final s = startDate;
    if (s == null) return false;
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);
    if (DateTime(s.year, s.month, s.day).isAfter(last)) return false;
    final e = endDate;
    if (e == null) return true;
    return !DateTime(e.year, e.month, e.day).isBefore(first);
  }
}

// ---------------------------------------------------------------------------
// Date helpers — tolerant readers, explicit writers
// ---------------------------------------------------------------------------

/// Parses the date formats that occur across the driver documents:
/// ISO `YYYY-MM-DD`, the legacy `dd/MM/yyyy` used by the onboarding map,
/// `dd.MM.yyyy`, plus `Timestamp` / `DateTime` values.
DateTime? parseFlexibleDate(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return DateTime(value.year, value.month, value.day);
  if (value is Timestamp) {
    final d = value.toDate();
    return DateTime(d.year, d.month, d.day);
  }
  final text = value.toString().trim();
  if (text.isEmpty) return null;

  final slash = RegExp(r'^(\d{1,2})[/.](\d{1,2})[/.](\d{4})$').firstMatch(text);
  if (slash != null) {
    final d = int.tryParse(slash.group(1)!);
    final m = int.tryParse(slash.group(2)!);
    final y = int.tryParse(slash.group(3)!);
    if (d != null && m != null && y != null) return DateTime(y, m, d);
  }
  try {
    final parsed = DateTime.parse(text);
    return DateTime(parsed.year, parsed.month, parsed.day);
  } catch (_) {
    return null;
  }
}

/// `YYYY-MM-DD` — the storage format of [EmploymentPeriod].
String formatIsoDate(DateTime date) {
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '${date.year.toString().padLeft(4, '0')}-$m-$d';
}

/// `dd/MM/yyyy` — the format the legacy `onboarding.*` date fields use.
String formatLegacyDate(DateTime date) {
  final d = date.day.toString().padLeft(2, '0');
  final m = date.month.toString().padLeft(2, '0');
  return '$d/$m/${date.year.toString().padLeft(4, '0')}';
}

/// `dd.MM.yy` — compact form for the monthly plan row.
String formatShortDate(DateTime date) {
  final d = date.day.toString().padLeft(2, '0');
  final m = date.month.toString().padLeft(2, '0');
  final y = (date.year % 100).toString().padLeft(2, '0');
  return '$d.$m.$y';
}

// ---------------------------------------------------------------------------
// Reading / deriving periods from a driver document
// ---------------------------------------------------------------------------

Map<String, dynamic> _onboardingOf(Map<String, dynamic> driverData) {
  final raw = driverData['onboarding'];
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return raw.map((k, v) => MapEntry(k.toString(), v));
  return const <String, dynamic>{};
}

/// Builds the single period that the legacy fields describe — used as a
/// fallback for every driver that has not been touched since this feature
/// shipped, so no data migration is needed.
EmploymentPeriod? legacyEmploymentPeriod(Map<String, dynamic> driverData) {
  final onboarding = _onboardingOf(driverData);
  final start = parseFlexibleDate(onboarding['workStartDate']);
  if (start == null) return null;
  final unlimited = onboarding['contractUnlimited'] == true;
  final end = unlimited ? null : parseFlexibleDate(onboarding['contractExpiry']);
  return EmploymentPeriod(
    start: formatIsoDate(start),
    end: end == null ? '' : formatIsoDate(end),
    transporterId: (driverData['transporterId'] ?? '').toString().trim(),
  );
}

/// All employment periods of a driver, oldest first.
///
/// Falls back to [legacyEmploymentPeriod] when the document has no
/// `employmentPeriods` list yet. Returns an empty list when nothing is known.
List<EmploymentPeriod> employmentPeriodsOf(Map<String, dynamic> driverData) {
  final raw = driverData['employmentPeriods'];
  final periods = <EmploymentPeriod>[];
  if (raw is List) {
    for (final entry in raw) {
      final p = EmploymentPeriod.fromMap(entry);
      if (p != null) periods.add(p);
    }
  }
  if (periods.isEmpty) {
    final legacy = legacyEmploymentPeriod(driverData);
    if (legacy != null) periods.add(legacy);
  }
  return sortEmploymentPeriods(periods);
}

/// Oldest first; ongoing periods sort last within the same start date.
List<EmploymentPeriod> sortEmploymentPeriods(List<EmploymentPeriod> periods) {
  final out = [...periods];
  out.sort((a, b) {
    final sa = a.startDate;
    final sb = b.startDate;
    if (sa == null || sb == null) return 0;
    final byStart = sa.compareTo(sb);
    if (byStart != 0) return byStart;
    if (a.isOngoing != b.isOngoing) return a.isOngoing ? 1 : -1;
    return 0;
  });
  return out;
}

/// The period that currently applies: the running one, otherwise the one that
/// started last. This is what gets mirrored into the legacy fields.
EmploymentPeriod? currentEmploymentPeriod(List<EmploymentPeriod> periods) {
  if (periods.isEmpty) return null;
  final sorted = sortEmploymentPeriods(periods);
  for (final p in sorted.reversed) {
    if (p.isOngoing) return p;
  }
  return sorted.last;
}

/// The period to show for a given calendar [month]:
/// the one overlapping it, otherwise the closest one before, otherwise the
/// closest one after. Returns null only when the driver has no period at all.
EmploymentPeriod? employmentPeriodForMonth(
  List<EmploymentPeriod> periods,
  DateTime month,
) {
  if (periods.isEmpty) return null;
  final sorted = sortEmploymentPeriods(periods);
  for (final p in sorted.reversed) {
    if (p.overlapsMonth(month)) return p;
  }
  final first = DateTime(month.year, month.month, 1);
  EmploymentPeriod? before;
  for (final p in sorted) {
    final e = p.endDate ?? p.startDate;
    if (e != null && e.isBefore(first)) before = p;
  }
  if (before != null) return before;
  return sorted.first;
}

// ---------------------------------------------------------------------------
// Writing — always together with the legacy mirror
// ---------------------------------------------------------------------------

/// Firestore update payload for [periods]. Writes the list **and** mirrors the
/// current period back into the legacy single-value fields so every existing
/// evaluation, filter and the wave-plan matching keeps working unchanged.
///
/// `transporterId` is only mirrored when the current period actually carries
/// one — clearing it could orphan wave-plan rows.
Map<String, dynamic> employmentPeriodsMirror(List<EmploymentPeriod> periods) {
  final sorted = sortEmploymentPeriods(periods);
  final update = <String, dynamic>{
    'employmentPeriods': sorted.map((p) => p.toMap()).toList(),
  };
  final current = currentEmploymentPeriod(sorted);
  if (current == null) return update;

  final onboarding = <String, dynamic>{};
  final start = current.startDate;
  if (start != null) onboarding['workStartDate'] = formatLegacyDate(start);
  final end = current.endDate;
  if (end == null) {
    onboarding['contractExpiry'] = '';
    onboarding['contractUnlimited'] = true;
  } else {
    onboarding['contractExpiry'] = formatLegacyDate(end);
    onboarding['contractUnlimited'] = false;
  }
  update['onboarding'] = onboarding;

  final tid = current.transporterId.trim();
  if (tid.isNotEmpty) update['transporterId'] = tid.toUpperCase();
  return update;
}
