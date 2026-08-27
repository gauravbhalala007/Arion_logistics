// lib/services/shift_plan_payment_source.dart
//
// Payment Check — "Shiftplan" source.
//
// Loads SAVED shift plans (users/{adminUid}/shift_plan_drafts/{YYYY-MM-DD},
// falling back to the published users/{adminUid}/shift_plans/{YYYY-MM-DD})
// and maps them into the exact [WstData] shape the Payment Check
// reconciliation consumes. This lets the admin compare the Amazon invoice
// against the saved shift plan instead of a WST export.
//
// PRIVACY: this file only READS the admin's own Firestore subcollections —
// data that already lives in Firestore. Nothing from the Payment Check
// (invoice, WST files, results) is ever written anywhere.
//
// Mapping notes (defaults where the shift plan has no WST counterpart):
//   * Each shift block of a non-cut entry counts as ONE planned route
//     (`completed = 1`). The plan knows PLANNED tours, not driven ones.
//   * Entries flagged `lateCancel` ("Cut · Late Cancel") are EXCLUDED from
//     the route counts — Amazon pays those as separate "Late Cancel"
//     positions, not as route blocks. They are surfaced as marks instead.
//   * Ride-alongs (mentee on the same van) are NOT extra routes — they are
//     surfaced as marks only.
//   * The plan has no parcel counts, so the parcel comparison is skipped
//     (empty `packages`).
//   * Block duration labels like "9 Std." / "8 Std. 45 m" map to whole
//     hours via [parseDurationHours] (first number wins → 8), matching the
//     invoice's "Block of N Hours" granularity.

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/shift_plan.dart';
import 'payment_check_parser.dart';

/// One successfully loaded day: the plan doc plus where it came from.
class ShiftPlanDayLoad {
  final DateTime date;
  final String dateKey;
  final ShiftPlanDoc doc;

  /// `true` when the doc came from `shift_plan_drafts` (internal save),
  /// `false` when it fell back to the published `shift_plans` doc.
  final bool fromDraft;

  const ShiftPlanDayLoad({
    required this.date,
    required this.dateKey,
    required this.doc,
    required this.fromDraft,
  });

  int get driverCount => doc.entries.length;
}

/// A shift-plan marking the admin explicitly wants to see next to the
/// reconciliation result: "Cut · Late Cancel" rows and ride-alongs.
class ShiftPlanMark {
  final DateTime date;
  final String driverName;
  final String transporterId;
  final bool isLateCancel;
  final String lateCancelReason;
  final bool isRideAlong;
  final String menteeName;

  /// Compact tour summary, e.g. "Standard Parcel - LEV · 9h".
  final String serviceSummary;

  const ShiftPlanMark({
    required this.date,
    required this.driverName,
    required this.transporterId,
    required this.isLateCancel,
    required this.lateCancelReason,
    required this.isRideAlong,
    required this.menteeName,
    required this.serviceSummary,
  });
}

/// Everything the Payment Check needs from a loaded shift-plan range.
class ShiftPlanPaymentData {
  /// The plan mapped into WST shape — drop-in for [reconcile].
  final WstData wst;

  /// Cut / ride-along markings, sorted by date then driver.
  final List<ShiftPlanMark> marks;

  final List<ShiftPlanDayLoad> days;

  /// Requested day keys for which neither a draft nor a published plan
  /// (with entries) exists.
  final List<String> missingDayKeys;

  const ShiftPlanPaymentData({
    required this.wst,
    required this.marks,
    required this.days,
    required this.missingDayKeys,
  });

  int get totalDrivers =>
      days.fold<int>(0, (acc, d) => acc + d.driverCount);

  int get plannedRoutes => wst.totalRoutes;

  int get cutCount => marks.where((m) => m.isLateCancel).length;

  int get rideAlongCount => marks.where((m) => m.isRideAlong).length;
}

DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Loads every day in `[start, end]` (inclusive): draft first, published
/// fallback. Days without any usable plan are reported in
/// [ShiftPlanPaymentData.missingDayKeys]; nothing is written.
///
/// [de] controls the language of the generated day labels (shown where the
/// WST flow shows "files used").
Future<ShiftPlanPaymentData> loadShiftPlanPaymentData({
  required String adminUid,
  required DateTime start,
  required DateTime end,
  required bool de,
  FirebaseFirestore? firestore,
}) async {
  final fs = firestore ?? FirebaseFirestore.instance;
  final userDoc = fs.collection('users').doc(adminUid);

  final days = <ShiftPlanDayLoad>[];
  final missing = <String>[];

  var cursor = _dayOnly(start);
  final last = _dayOnly(end);
  while (!cursor.isAfter(last)) {
    final key = dayKey(cursor);

    ShiftPlanDoc? doc;
    var fromDraft = false;

    final draftSnap =
        await userDoc.collection('shift_plan_drafts').doc(key).get();
    if (draftSnap.exists) {
      final parsed = ShiftPlanDoc.fromDoc(draftSnap);
      if (parsed.entries.isNotEmpty) {
        doc = parsed;
        fromDraft = true;
      }
    }
    if (doc == null) {
      final pubSnap =
          await userDoc.collection('shift_plans').doc(key).get();
      if (pubSnap.exists) {
        final parsed = ShiftPlanDoc.fromDoc(pubSnap);
        if (parsed.entries.isNotEmpty) doc = parsed;
      }
    }

    if (doc == null) {
      missing.add(key);
    } else {
      days.add(ShiftPlanDayLoad(
        date: cursor,
        dateKey: key,
        doc: doc,
        fromDraft: fromDraft,
      ));
    }
    cursor = cursor.add(const Duration(days: 1));
  }

  return buildShiftPlanPaymentData(
    days: days,
    missingDayKeys: missing,
    de: de,
  );
}

/// Pure mapping step (no I/O): loaded days → [ShiftPlanPaymentData].
ShiftPlanPaymentData buildShiftPlanPaymentData({
  required List<ShiftPlanDayLoad> days,
  required List<String> missingDayKeys,
  required bool de,
}) {
  final routes = <WstRouteRow>[];
  final marks = <ShiftPlanMark>[];
  final stations = <String>{};
  final labels = <String>[];
  final warnings = <String>[];

  for (final day in days) {
    final doc = day.doc;
    if (doc.station.trim().isNotEmpty) stations.add(doc.station.trim());

    labels.add(de
        ? '${formatDay(day.date)} · '
            '${day.fromDraft ? 'Entwurf' : 'Veröffentlicht'} '
            '(${day.driverCount} Fahrer)'
        : '${formatDay(day.date, de: false)} · '
            '${day.fromDraft ? 'draft' : 'published'} '
            '(${day.driverCount} drivers)');

    for (final entry in doc.entries) {
      // Marks: Cut · Late Cancel and ride-alongs — the customer explicitly
      // wants these visible next to the reconciliation result.
      final isRideAlong =
          entry.hasMentee || entry.menteeName.trim().isNotEmpty;
      if (entry.lateCancel || isRideAlong) {
        marks.add(ShiftPlanMark(
          date: day.date,
          driverName: entry.driverName,
          transporterId: entry.transporterId,
          isLateCancel: entry.lateCancel,
          lateCancelReason: entry.lateCancelReason,
          isRideAlong: isRideAlong,
          menteeName: entry.menteeName,
          serviceSummary: entry.blocks
              .map((b) {
                final h = parseDurationHours(b.duration);
                return h == null
                    ? b.serviceType
                    : '${b.serviceType} · ${h}h';
              })
              .join(', '),
        ));
      }

      // Cut tours are not driven — Amazon pays them as "Late Cancel"
      // extras, never as route blocks. Excluding them keeps the route
      // comparison honest (a cut tour must NOT demand a paid block).
      if (entry.lateCancel) continue;

      for (final block in entry.blocks) {
        final hours = parseDurationHours(block.duration);
        final service = normText(block.serviceType);
        if (service.isEmpty || hours == null) {
          warnings.add('unmappable-block: ${day.dateKey} '
              '${entry.driverName} "${block.serviceType}" '
              '"${block.duration}"');
          continue;
        }
        routes.add(WstRouteRow(
          date: day.date,
          station: doc.station.trim(),
          serviceType: service,
          hours: hours,
          completed: 1,
        ));
      }
    }
  }

  marks.sort((a, b) {
    final c = a.date.compareTo(b.date);
    return c != 0 ? c : a.driverName.compareTo(b.driverName);
  });

  return ShiftPlanPaymentData(
    wst: WstData(
      routes: routes,
      // The plan has no parcel data → the parcel comparison is skipped.
      packages: const <WstPackageRow>[],
      filesUsed: labels,
      filesIgnored: const <String>[],
      stations: stations,
      warnings: warnings,
    ),
    marks: marks,
    days: days,
    missingDayKeys: missingDayKeys,
  );
}
