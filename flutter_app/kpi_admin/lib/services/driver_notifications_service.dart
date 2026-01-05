// lib/services/driver_notifications_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class DriverNotificationsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col({
    required String dspUid,
    required String transporterId,
  }) {
    return _db
        .collection('users')
        .doc(dspUid)
        .collection('drivers')
        .doc(transporterId.toUpperCase())
        .collection('notifications');
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> allStream({
    required String dspUid,
    required String transporterId,
  }) {
    return _col(dspUid: dspUid, transporterId: transporterId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> rulesStream({
    required String dspUid,
    required String transporterId,
  }) {
    return _col(dspUid: dspUid, transporterId: transporterId)
        .where('type', isEqualTo: 'rule')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<int> unreadCountStream({
    required String dspUid,
    required String transporterId,
  }) {
    return _col(dspUid: dspUid, transporterId: transporterId)
        .where('readAt', isNull: true)
        .snapshots()
        .map((s) => s.size);
  }

  Future<void> markRead({
    required String dspUid,
    required String transporterId,
    required String notificationId,
  }) async {
    final ref = _col(dspUid: dspUid, transporterId: transporterId).doc(notificationId);
    await ref.set({
      'readAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> confirm({
    required String dspUid,
    required String transporterId,
    required String notificationId,
  }) async {
    final ref = _col(dspUid: dspUid, transporterId: transporterId).doc(notificationId);
    await ref.set({
      'confirmedAt': FieldValue.serverTimestamp(),
      'readAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
