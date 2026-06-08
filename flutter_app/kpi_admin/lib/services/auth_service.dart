// lib/services/auth_service.dart

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
    // Force a fresh ID token so custom claims set after the user was
    // originally created (e.g. `role: 'admin'`) are immediately available
    // for Firestore + Storage rule checks. Without this, claims would
    // only propagate when the cached token expires (~1 hour) or the user
    // signs out + back in manually.
    try {
      await _auth.currentUser?.getIdToken(true);
    } catch (_) {
      // Network hiccup is non-fatal — token will refresh on next call.
    }
  }

  /// Force a fresh ID token for the currently signed-in user. Safe to
  /// call on app start; no-op if nobody is signed in.
  static Future<void> refreshIdToken() async {
    try {
      await _auth.currentUser?.getIdToken(true);
    } catch (_) {
      // Non-fatal — Firebase auto-retries on the next request.
    }
  }

  /// Register and create `users/{uid}` als sofort nutzbares Admin-Konto
  /// mit 30-Tage-Test (ab Tag 1). Nutzer ist nach der Registrierung direkt
  /// angemeldet und gelangt sofort in die App.
  static Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? companyName,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await cred.user?.updateDisplayName('$firstName $lastName');

    final uid = cred.user!.uid;
    final now = DateTime.now();
    await _db.collection('users').doc(uid).set({
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      if (companyName != null && companyName.isNotEmpty)
        'companyName': companyName,
      // Sofort nutzbar — kein manuelles Freischalten.
      'approved': true,
      'role': 'admin',
      // 30-Tage-Test ab Registrierung.
      'plan': 'trial',
      'trialStartedAt': FieldValue.serverTimestamp(),
      'trialEndsAt': Timestamp.fromDate(now.add(const Duration(days: 30))),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Bestätigungs-E-Mail senden (optional, blockiert den Zugang nicht).
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
