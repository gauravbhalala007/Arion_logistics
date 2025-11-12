import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;

  /// Email/password login
  static Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Register and create `users/{uid}` with approved=false, role=user.
  /// Sends verification email.
  static Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await cred.user?.updateDisplayName('$firstName $lastName');

    final uid = cred.user!.uid;
    await _db.collection('users').doc(uid).set({
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'approved': false,
      'role': 'user',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await cred.user?.sendEmailVerification();
  }

  static Future<void> resendVerificationEmail() async {
    final u = _auth.currentUser;
    if (u != null && !u.emailVerified) {
      await u.sendEmailVerification();
    }
  }

  static Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  /// convenience stream for current user's Firestore doc
  static Stream<DocumentSnapshot<Map<String, dynamic>>> userDocStream() {
    final u = _auth.currentUser;
    if (u == null) {
      final ctrl = Stream<DocumentSnapshot<Map<String, dynamic>>>.multi((c) {
        c.close();
      });
      return ctrl;
    }
    return _db.collection('users').doc(u.uid).snapshots();
  }
}
