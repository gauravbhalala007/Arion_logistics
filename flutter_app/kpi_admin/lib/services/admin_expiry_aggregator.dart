// lib/services/admin_expiry_aggregator.dart
//
// Aggregates document-expiry notifications across all drivers of one
// DSP admin. Used by:
//   • the notification bell in the admin app bar (total unread count)
//   • the "Drivers Hub" side menu badge (same count)
//   • the drivers-hub list sorter (closest-expiry-first ordering)
//
// Strategy: stream the admin's `drivers` subcollection, fan out a
// per-driver `notifications` query (limited to type=docExpiry), and
// merge counts client-side. This keeps the existing notification
// schema (which doesn't index `dspUid` cross-collection) untouched.

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class DriverExpiryStatus {
  final String transporterId;
  /// All unread expiry notifications for this driver.
  final int unreadCount;
  /// Minimum days-left across the driver's docs (≤0 means expired).
  final int minDaysLeft;
  /// True when at least one document is already past expiry.
  final bool hasExpired;

  const DriverExpiryStatus({
    required this.transporterId,
    required this.unreadCount,
    required this.minDaysLeft,
    required this.hasExpired,
  });
}

class AdminExpiryAggregator {
  AdminExpiryAggregator({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  /// Streams the per-driver expiry status map keyed by transporterId.
  /// Re-subscribes automatically when the driver list changes.
  Stream<Map<String, DriverExpiryStatus>> watchDriverStatuses(
    String dspUid,
  ) async* {
    final controller =
        StreamController<Map<String, DriverExpiryStatus>>.broadcast();
    final perDriver = <String, DriverExpiryStatus>{};
    final perDriverSubs = <String, StreamSubscription>{};

    StreamSubscription? driversSub;

    void emit() {
      if (!controller.isClosed) controller.add({...perDriver});
    }

    driversSub = _db
        .collection('users')
        .doc(dspUid)
        .collection('drivers')
        .snapshots()
        .listen((snap) {
      final seenIds = <String>{};
      for (final d in snap.docs) {
        final tid = d.id;
        seenIds.add(tid);
        if (perDriverSubs.containsKey(tid)) continue;

        perDriverSubs[tid] = d.reference
            .collection('notifications')
            .where('type', isEqualTo: 'docExpiry')
            .snapshots()
            .listen((nSnap) {
          int unread = 0;
          int minDays = 1 << 30;
          bool expired = false;
          for (final n in nSnap.docs) {
            final data = n.data();
            final readAt = data['readAt'];
            if (readAt == null) unread++;

            final raw = (data['expiryDate'] ?? '').toString().trim();
            final dt = _parseYmd(raw);
            if (dt != null) {
              final daysLeft = _daysBetweenUtc(DateTime.now(), dt);
              if (daysLeft <= 0) expired = true;
              if (daysLeft < minDays) minDays = daysLeft;
            }
          }
          perDriver[tid] = DriverExpiryStatus(
            transporterId: tid,
            unreadCount: unread,
            minDaysLeft: minDays == (1 << 30) ? 999 : minDays,
            hasExpired: expired,
          );
          emit();
        });
      }

      // Remove subs for drivers that disappeared.
      for (final tid
          in perDriverSubs.keys.where((k) => !seenIds.contains(k)).toList()) {
        perDriverSubs[tid]?.cancel();
        perDriverSubs.remove(tid);
        perDriver.remove(tid);
      }
      emit();
    });

    try {
      yield* controller.stream;
    } finally {
      await driversSub.cancel();
      for (final s in perDriverSubs.values) {
        await s.cancel();
      }
      await controller.close();
    }
  }

  /// Single integer stream — total unread across all drivers.
  Stream<int> watchUnreadTotal(String dspUid) {
    return watchDriverStatuses(dspUid).map(
      (m) => m.values.fold<int>(0, (s, st) => s + st.unreadCount),
    );
  }

  // Helpers — match the date format the Cloud Function emits
  // (`YYYY-MM-DD` ISO).
  static DateTime? _parseYmd(String raw) {
    if (raw.isEmpty) return null;
    final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(raw);
    if (m == null) return null;
    return DateTime.utc(
      int.parse(m.group(1)!),
      int.parse(m.group(2)!),
      int.parse(m.group(3)!),
    );
  }

  static int _daysBetweenUtc(DateTime now, DateTime target) {
    final today = DateTime.utc(now.year, now.month, now.day);
    final diff = target.difference(today).inDays;
    return diff;
  }
}
