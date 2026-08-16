// lib/services/public_plan_service.dart
//
// Publishes a read-only snapshot of a plan (waveplan / shift plan) under an
// unguessable share ID so anyone with the link can view it WITHOUT logging
// in.
//
//   public_plans/{shareId}          ← world-readable (get only, no list)
//   users/{uid}/plan_shares/{key}   ← private mapping so re-sharing the same
//                                     plan/day reuses the same link.
//
// The public doc carries a pre-rendered, generic payload (sections → rows)
// so the viewer page stays dumb and works for every plan type.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PublicPlanService {
  PublicPlanService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  static const String _baseUrl = 'https://dsp-codriver.de/plan';

  /// Creates or refreshes the public share for [key] (e.g.
  /// "waveplan_2026-07-03_sameday_a") and returns the share URL.
  /// Re-sharing the same key updates the existing public doc, so a link
  /// that is already in circulation always shows the latest snapshot.
  Future<String> share({
    required String key,
    required Map<String, dynamic> payload,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw StateError('Nicht angemeldet.');
    }

    final mappingRef = _db
        .collection('users')
        .doc(uid)
        .collection('plan_shares')
        .doc(key);

    String shareId;
    final mapping = await mappingRef.get();
    final existing = (mapping.data()?['shareId'] ?? '').toString();
    if (existing.isNotEmpty) {
      shareId = existing;
    } else {
      shareId = _db.collection('public_plans').doc().id;
      await mappingRef.set({
        'shareId': shareId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await _db.collection('public_plans').doc(shareId).set({
      ...payload,
      'createdBy': uid,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return '$_baseUrl/$shareId';
  }
}
