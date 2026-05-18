// lib/services/time_tracking_firestore.dart
//
// Convenience-Pfade für das Zeiterfassungs-Modul.
//
// Architektur-Update: Die Default-Firestore-Database liegt bereits in
// `eur3` (Frankfurt), DSGVO ist erfüllt. Daher schreibt das Zeit-Modul
// in dieselbe Database wie der Rest der App. Die Pfade liegen als
// Subcollections unter `users/{adminUid}/drivers/{driverId}/...`.

import 'package:cloud_firestore/cloud_firestore.dart';

/// Liefert die Default-Firestore-Instanz (eur3). Behält den
/// Singleton-Namen, damit bestehende Aufrufer (`TimeTrackingFirestore.shifts`)
/// nicht angefasst werden müssen.
class TimeTrackingFirestore {
  TimeTrackingFirestore._();

  static FirebaseFirestore get instance => FirebaseFirestore.instance;

  // ── Standard-Pfade als Convenience-Getter ────────────────────────

  /// `users/{adminUid}/drivers/{driverId}/time_entries`
  static CollectionReference<Map<String, dynamic>> timeEntries({
    required String adminUid,
    required String driverId,
  }) =>
      instance
          .collection('users')
          .doc(adminUid)
          .collection('drivers')
          .doc(driverId)
          .collection('time_entries');

  /// `users/{adminUid}/drivers/{driverId}/shifts`
  static CollectionReference<Map<String, dynamic>> shifts({
    required String adminUid,
    required String driverId,
  }) =>
      instance
          .collection('users')
          .doc(adminUid)
          .collection('drivers')
          .doc(driverId)
          .collection('shifts');

  /// `users/{adminUid}/drivers/{driverId}/time_account`
  static CollectionReference<Map<String, dynamic>> timeAccount({
    required String adminUid,
    required String driverId,
  }) =>
      instance
          .collection('users')
          .doc(adminUid)
          .collection('drivers')
          .doc(driverId)
          .collection('time_account');

  /// `users/{adminUid}/drivers/{driverId}/correction_requests`
  static CollectionReference<Map<String, dynamic>> correctionRequests({
    required String adminUid,
    required String driverId,
  }) =>
      instance
          .collection('users')
          .doc(adminUid)
          .collection('drivers')
          .doc(driverId)
          .collection('correction_requests');

  /// `users/{adminUid}/time_audit_log`
  static CollectionReference<Map<String, dynamic>> auditLog(
    String adminUid,
  ) =>
      instance
          .collection('users')
          .doc(adminUid)
          .collection('time_audit_log');

  /// Globale Feiertags-Cache pro Bundesland (`global_holidays`).
  static CollectionReference<Map<String, dynamic>> globalHolidays() =>
      instance.collection('global_holidays');
}
