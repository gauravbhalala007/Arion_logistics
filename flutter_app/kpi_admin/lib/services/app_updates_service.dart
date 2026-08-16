import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_update.dart';

/// Reads/writes the global `appUpdates` collection and tracks which update a
/// user has already seen (stored on the user's own `users/{uid}` doc as
/// `lastSeenAppUpdateId`, so it works across devices without extra rules).
class AppUpdatesService {
  AppUpdatesService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('appUpdates');

  /// All updates, newest first — for the admin management list.
  Stream<List<AppUpdate>> watchAll() {
    return _col.orderBy('createdAt', descending: true).snapshots().map(
          (s) => s.docs.map(AppUpdate.fromDoc).toList(growable: false),
        );
  }

  Future<void> create({
    required String title,
    required String body,
    required AppUpdateAudience audience,
    String iconKey = 'campaign',
  }) async {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    await _col.add(<String, dynamic>{
      'title': title.trim(),
      'body': body.trim(),
      'iconKey': iconKey,
      'audience': appUpdateAudienceValue(audience),
      'active': true,
      'createdByEmail': email,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> update({
    required String id,
    required String title,
    required String body,
    required AppUpdateAudience audience,
    required bool active,
    String iconKey = 'campaign',
  }) async {
    await _col.doc(id).set(<String, dynamic>{
      'title': title.trim(),
      'body': body.trim(),
      'iconKey': iconKey,
      'audience': appUpdateAudienceValue(audience),
      'active': active,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> delete(String id) => _col.doc(id).delete();

  /// The newest active update that targets [side] ('admin' | 'driver') and
  /// that the user hasn't dismissed yet. Returns null when there's nothing
  /// new to show.
  Future<AppUpdate?> latestUnseenFor({
    required String uid,
    required String side,
  }) async {
    final userSnap = await _db.collection('users').doc(uid).get();
    final lastSeen =
        (userSnap.data()?['lastSeenAppUpdateId'] ?? '').toString();

    // Small fetch — newest active updates, filtered client-side by audience
    // so we don't need a composite index on (audience, active, createdAt).
    final snap = await _col
        .where('active', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(10)
        .get();

    for (final doc in snap.docs) {
      final u = AppUpdate.fromDoc(doc);
      if (!u.reaches(side)) continue;
      if (u.id == lastSeen) return null; // newest relevant one already seen
      return u;
    }
    return null;
  }

  /// Marks [updateId] as seen for [uid] (writes to the user's own doc).
  Future<void> markSeen({
    required String uid,
    required String updateId,
  }) async {
    await _db.collection('users').doc(uid).set(<String, dynamic>{
      'lastSeenAppUpdateId': updateId,
    }, SetOptions(merge: true));
  }
}
