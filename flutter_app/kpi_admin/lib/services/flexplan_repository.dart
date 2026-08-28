// lib/services/flexplan_repository.dart
//
// Flexplan (Feature "Flex Plan"): Minijobber wählen im Monatstakt, welche
// Schichten sie übernehmen können.
//
// Datenmodell:
//   users/{dspUid}/flexplan_months/{yyyy-MM}
//     { monthKey, status: 'draft'|'open'|'closed', hourlyWage,
//       maxMonthlyEarnings, region: 'NW',
//       shifts: [ {id,name,start,end} ] }
//   Die Schichten werden EINMAL angelegt und gelten für jeden Tag des
//   Monats außer Sonntag und gesetzliche Feiertage (je Bundesland,
//   siehe utils/german_holidays.dart).
//   users/{dspUid}/flexplan_months/{yyyy-MM}/bookings/{TID}
//     { driverTransporterId, monthKey, driverName, entries: [
//         {date, shiftId, name, start, end, minutes} ], totalMinutes }
//   users/{dspUid}/flexplan_cancellations/{autoId}
//     { monthKey, date, shiftId, shiftName, start, end, minutes,
//       driverTransporterId, driverName, status: 'pending'|'approved'|
//       'rejected', requestedAt, decidedAt, decidedBy }
//
// Stundenlimit: maxMinutes = floor((maxMonthlyEarnings / hourlyWage) * 60).
// Beispiel 603 € bei 16,20 €/h → 37,2222 h → 2233 Minuten (37 h 13 min).
// Es wird in Minuten gerechnet, damit kein Fahrer durch Rundung über den
// Maximalverdienst kommt.

import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/german_holidays.dart';

// ── Stunden-/Geld-Mathematik ─────────────────────────────────────────────

/// Minuten zwischen zwei 'HH:mm'-Zeiten; Schichten über Mitternacht
/// (Ende <= Start) zählen als +24 h.
int shiftMinutes(String start, String end) {
  final s = _parseHm(start);
  final e = _parseHm(end);
  if (s == null || e == null) return 0;
  var diff = e - s;
  if (diff <= 0) diff += 24 * 60;
  return diff;
}

int? _parseHm(String raw) {
  final m = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(raw.trim());
  if (m == null) return null;
  final h = int.parse(m.group(1)!);
  final min = int.parse(m.group(2)!);
  if (h > 23 || min > 59) return null;
  return h * 60 + min;
}

/// Maximal buchbare Minuten pro Monat — abgerundet, damit der
/// Maximalverdienst nie überschritten wird.
int flexMaxMinutes({required double hourlyWage, required double maxEarnings}) {
  if (hourlyWage <= 0 || maxEarnings <= 0) return 0;
  return ((maxEarnings / hourlyWage) * 60).floor();
}

String formatMinutes(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return m == 0 ? '$h h' : '$h h ${m.toString().padLeft(2, '0')} min';
}

double earningsForMinutes(int minutes, double hourlyWage) =>
    minutes / 60.0 * hourlyWage;

// ── Modelle ──────────────────────────────────────────────────────────────

class FlexShift {
  const FlexShift({
    required this.id,
    required this.name,
    required this.start,
    required this.end,
  });

  final String id;
  final String name;
  final String start; // 'HH:mm'
  final String end; // 'HH:mm'

  int get minutes => shiftMinutes(start, end);

  Map<String, dynamic> toMap() =>
      {'id': id, 'name': name, 'start': start, 'end': end};

  static FlexShift? fromMap(dynamic raw) {
    if (raw is! Map) return null;
    final id = (raw['id'] ?? '').toString();
    final name = (raw['name'] ?? '').toString();
    final start = (raw['start'] ?? '').toString();
    final end = (raw['end'] ?? '').toString();
    if (id.isEmpty || start.isEmpty || end.isEmpty) return null;
    return FlexShift(id: id, name: name, start: start, end: end);
  }
}

class FlexMonth {
  FlexMonth({
    required this.monthKey,
    required this.status,
    required this.hourlyWage,
    required this.maxEarnings,
    required this.region,
    required this.shifts,
  });

  final String monthKey; // 'yyyy-MM'
  final String status; // draft | open | closed
  final double hourlyWage;
  final double maxEarnings;

  /// Bundesland-Code (z. B. 'NW') für die Feiertagsberechnung.
  final String region;

  /// Die einmal angelegten Schichten — gelten an jedem Werktag
  /// (Mo–Sa, kein Feiertag) des Monats.
  final List<FlexShift> shifts;

  bool get isOpen => status == 'open';
  int get maxMinutes =>
      flexMaxMinutes(hourlyWage: hourlyWage, maxEarnings: maxEarnings);

  int get year => int.tryParse(monthKey.split('-').first) ?? 2000;
  int get month =>
      int.tryParse(monthKey.split('-').length > 1 ? monthKey.split('-')[1] : '1') ??
      1;
  int get daysInMonth => DateTime(year, month + 1, 0).day;

  /// Feiertage des Monatsjahres im gewählten Bundesland
  /// (Datums-Key → Name). Lazy berechnet und gecacht.
  Map<String, String> get holidays =>
      _holidays ??= germanHolidays(year, region);
  Map<String, String>? _holidays;

  /// Grund, warum ein Tag KEINE Schichten hat: 'sunday', Feiertagsname —
  /// oder null, wenn der Tag ein Flex-Arbeitstag ist.
  String? blockedReason(DateTime date) {
    if (date.weekday == DateTime.sunday) return 'sunday';
    return holidays[FlexplanRepository.dateKeyOf(date)];
  }

  /// Schichten für ein konkretes Datum: leer an Sonntagen/Feiertagen.
  List<FlexShift> shiftsForDate(DateTime date) =>
      blockedReason(date) == null ? shifts : const <FlexShift>[];

  static FlexMonth fromDoc(String monthKey, Map<String, dynamic>? data) {
    final d = data ?? const <String, dynamic>{};
    final rawShifts = d['shifts'];
    final shifts = rawShifts is List
        ? (rawShifts.map(FlexShift.fromMap).whereType<FlexShift>().toList()
          ..sort((a, b) => a.start.compareTo(b.start)))
        : <FlexShift>[];
    double numOf(dynamic v, double fallback) =>
        v is num ? v.toDouble() : fallback;
    return FlexMonth(
      monthKey: monthKey,
      status: (d['status'] ?? 'draft').toString(),
      hourlyWage: numOf(d['hourlyWage'], 16.20),
      maxEarnings: numOf(d['maxMonthlyEarnings'], 603.0),
      region: (d['region'] ?? 'NW').toString(),
      shifts: shifts,
    );
  }
}

class FlexBookingEntry {
  const FlexBookingEntry({
    required this.date,
    required this.shiftId,
    required this.name,
    required this.start,
    required this.end,
    required this.minutes,
  });

  final String date; // 'yyyy-MM-dd'
  final String shiftId;
  final String name;
  final String start;
  final String end;
  final int minutes;

  Map<String, dynamic> toMap() => {
        'date': date,
        'shiftId': shiftId,
        'name': name,
        'start': start,
        'end': end,
        'minutes': minutes,
      };

  static FlexBookingEntry? fromMap(dynamic raw) {
    if (raw is! Map) return null;
    final date = (raw['date'] ?? '').toString();
    final shiftId = (raw['shiftId'] ?? '').toString();
    if (date.isEmpty || shiftId.isEmpty) return null;
    return FlexBookingEntry(
      date: date,
      shiftId: shiftId,
      name: (raw['name'] ?? '').toString(),
      start: (raw['start'] ?? '').toString(),
      end: (raw['end'] ?? '').toString(),
      minutes: raw['minutes'] is num ? (raw['minutes'] as num).toInt() : 0,
    );
  }
}

class FlexBooking {
  const FlexBooking({
    required this.driverTransporterId,
    required this.driverName,
    required this.entries,
  });

  final String driverTransporterId;
  final String driverName;
  final List<FlexBookingEntry> entries;

  int get totalMinutes =>
      entries.fold(0, (acc, e) => acc + e.minutes);

  static FlexBooking fromDoc(String tid, Map<String, dynamic>? data) {
    final d = data ?? const <String, dynamic>{};
    final raw = d['entries'];
    final entries = raw is List
        ? raw
            .map(FlexBookingEntry.fromMap)
            .whereType<FlexBookingEntry>()
            .toList()
        : <FlexBookingEntry>[];
    entries.sort((a, b) {
      final byDate = a.date.compareTo(b.date);
      return byDate != 0 ? byDate : a.start.compareTo(b.start);
    });
    return FlexBooking(
      driverTransporterId: tid,
      driverName: (d['driverName'] ?? '').toString(),
      entries: entries,
    );
  }
}

// ── Firestore-Zugriff ────────────────────────────────────────────────────

class FlexplanRepository {
  FlexplanRepository(this.dspUid);

  final String dspUid;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static String monthKeyOf(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}';

  static String dateKeyOf(DateTime d) =>
      '${monthKeyOf(d)}-${d.day.toString().padLeft(2, '0')}';

  DocumentReference<Map<String, dynamic>> monthRef(String monthKey) => _db
      .collection('users')
      .doc(dspUid)
      .collection('flexplan_months')
      .doc(monthKey);

  CollectionReference<Map<String, dynamic>> bookingsCol(String monthKey) =>
      monthRef(monthKey).collection('bookings');

  DocumentReference<Map<String, dynamic>> bookingRef(
    String monthKey,
    String tid,
  ) =>
      bookingsCol(monthKey).doc(tid.trim().toUpperCase());

  CollectionReference<Map<String, dynamic>> get cancellationsCol => _db
      .collection('users')
      .doc(dspUid)
      .collection('flexplan_cancellations');

  Stream<FlexMonth> watchMonth(String monthKey) => monthRef(monthKey)
      .snapshots()
      .map((snap) => FlexMonth.fromDoc(monthKey, snap.data()));

  Stream<List<FlexBooking>> watchBookings(String monthKey) =>
      bookingsCol(monthKey).snapshots().map(
            (snap) => snap.docs
                .map((d) => FlexBooking.fromDoc(d.id, d.data()))
                .toList(),
          );

  Stream<FlexBooking> watchBooking(String monthKey, String tid) =>
      bookingRef(monthKey, tid).snapshots().map(
            (snap) =>
                FlexBooking.fromDoc(tid.trim().toUpperCase(), snap.data()),
          );

  /// Offene Monate für die Fahrer-Auswahl.
  Stream<List<FlexMonth>> watchOpenMonths() => _db
      .collection('users')
      .doc(dspUid)
      .collection('flexplan_months')
      .where('status', isEqualTo: 'open')
      .snapshots()
      .map(
        (snap) => (snap.docs
            .map((d) => FlexMonth.fromDoc(d.id, d.data()))
            .toList()
          ..sort((a, b) => a.monthKey.compareTo(b.monthKey))),
      );

  /// Fahrer bucht eine Schicht — transaktional gegen das Minutenlimit
  /// geprüft, damit zwei parallele Buchungen das Limit nicht aushebeln.
  /// Wirft [StateError] mit Klartext-Code bei Verstößen.
  Future<void> bookShift({
    required String monthKey,
    required String tid,
    required String driverName,
    required String date,
    required FlexShift shift,
  }) async {
    final ref = bookingRef(monthKey, tid);
    final mRef = monthRef(monthKey);
    await _db.runTransaction((tx) async {
      final monthSnap = await tx.get(mRef);
      final month = FlexMonth.fromDoc(monthKey, monthSnap.data());
      if (!month.isOpen) throw StateError('month_closed');

      // Datum muss ein Flex-Arbeitstag sein (kein Sonntag/Feiertag) und
      // die Schicht muss (noch) zu den angelegten Schichten gehören.
      final parts = date.split('-');
      final parsed = DateTime(
        int.tryParse(parts[0]) ?? 0,
        int.tryParse(parts.length > 1 ? parts[1] : '1') ?? 1,
        int.tryParse(parts.length > 2 ? parts[2] : '1') ?? 1,
      );
      final valid = month
          .shiftsForDate(parsed)
          .any((s) => s.id == shift.id);
      if (!valid) throw StateError('shift_unavailable');

      final snap = await tx.get(ref);
      final booking =
          FlexBooking.fromDoc(tid.trim().toUpperCase(), snap.data());
      final exists = booking.entries.any(
        (e) => e.date == date && e.shiftId == shift.id,
      );
      if (exists) throw StateError('already_booked');

      final newTotal = booking.totalMinutes + shift.minutes;
      if (newTotal > month.maxMinutes) throw StateError('limit_exceeded');

      final entries = [
        ...booking.entries.map((e) => e.toMap()),
        FlexBookingEntry(
          date: date,
          shiftId: shift.id,
          name: shift.name,
          start: shift.start,
          end: shift.end,
          minutes: shift.minutes,
        ).toMap(),
      ];
      tx.set(ref, {
        'driverTransporterId': tid.trim().toUpperCase(),
        'monthKey': monthKey,
        'driverName': driverName,
        'entries': entries,
        'totalMinutes': newTotal,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Fahrer stellt eine Storno-Anfrage (selbst löschen ist nicht erlaubt).
  Future<void> requestCancellation({
    required String monthKey,
    required String tid,
    required String driverName,
    required FlexBookingEntry entry,
  }) async {
    await cancellationsCol.add({
      'monthKey': monthKey,
      'date': entry.date,
      'shiftId': entry.shiftId,
      'shiftName': entry.name,
      'start': entry.start,
      'end': entry.end,
      'minutes': entry.minutes,
      'driverTransporterId': tid.trim().toUpperCase(),
      'driverName': driverName,
      'status': 'pending',
      'requestedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Admin entscheidet eine Storno-Anfrage. Bei Genehmigung wird der
  /// Eintrag aus der Buchung entfernt.
  Future<void> decideCancellation({
    required DocumentSnapshot<Map<String, dynamic>> request,
    required bool approve,
    required String decidedBy,
  }) async {
    final data = request.data() ?? const <String, dynamic>{};
    final monthKey = (data['monthKey'] ?? '').toString();
    final tid = (data['driverTransporterId'] ?? '').toString();
    final date = (data['date'] ?? '').toString();
    final shiftId = (data['shiftId'] ?? '').toString();

    await _db.runTransaction((tx) async {
      if (approve && monthKey.isNotEmpty && tid.isNotEmpty) {
        final ref = bookingRef(monthKey, tid);
        final snap = await tx.get(ref);
        final booking = FlexBooking.fromDoc(tid, snap.data());
        final remaining = booking.entries
            .where((e) => !(e.date == date && e.shiftId == shiftId))
            .toList();
        tx.set(ref, {
          'entries': [for (final e in remaining) e.toMap()],
          'totalMinutes':
              remaining.fold<int>(0, (acc, e) => acc + e.minutes),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      tx.update(request.reference, {
        'status': approve ? 'approved' : 'rejected',
        'decidedAt': FieldValue.serverTimestamp(),
        'decidedBy': decidedBy,
      });
    });
  }
}
