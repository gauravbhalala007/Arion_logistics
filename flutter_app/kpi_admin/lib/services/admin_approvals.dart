import 'package:cloud_firestore/cloud_firestore.dart';

class AdminApprovalsService {
  static final _db = FirebaseFirestore.instance;

  /// Stream pending users without server-side orderBy to avoid composite-index requirement.
  /// We sort by createdAt on the client instead.
  static Stream<QuerySnapshot<Map<String, dynamic>>> pendingUsersStream() {
    return _db
        .collection('users')
        .where('approved', isEqualTo: false)
        .snapshots();
  }

  static Future<void> approve(String uid) async {
    await _db.collection('users').doc(uid).update({
      'approved': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> deleteUserDoc(String uid) async {
    await _db.collection('users').doc(uid).delete();
  }
}
