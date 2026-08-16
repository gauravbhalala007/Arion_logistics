// lib/services/recruiting_slug_service.dart
//
// Resolves short, brand-friendly slugs (e.g. "arion") to the long
// Firebase admin UID for the public recruiting form.
//
// Mapping lives in `recruiting_slugs/{slug}` — public-read,
// admin-SDK-only writes. Two URL forms supported:
//
//   /apply/arion          → local channel
//   /apply/arion/visa     → visa channel
//
// Legacy `/apply?dsp=<uid>&type=local|visa` keeps working.

import 'package:cloud_firestore/cloud_firestore.dart';

class RecruitingSlugService {
  static String? sanitize(String input) {
    final clean = input
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9-]'), '');
    if (clean.isEmpty || clean.length > 40) return null;
    return clean;
  }

  /// Reads `recruiting_slugs/{slug}` and returns the admin UID,
  /// or null if the slug doesn't exist.
  static Future<String?> resolveAdminUid(String slug) async {
    final clean = sanitize(slug);
    if (clean == null) return null;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('recruiting_slugs')
          .doc(clean)
          .get();
      if (!doc.exists) return null;
      final uid = (doc.data()?['adminUid'] ?? '').toString().trim();
      return uid.isEmpty ? null : uid;
    } catch (_) {
      return null;
    }
  }

  /// Returns the slug currently assigned to this admin, if any.
  static Future<String?> slugFor(String adminUid) async {
    if (adminUid.trim().isEmpty) return null;
    try {
      final q = await FirebaseFirestore.instance
          .collection('recruiting_slugs')
          .where('adminUid', isEqualTo: adminUid)
          .limit(1)
          .get();
      if (q.docs.isEmpty) return null;
      return q.docs.first.id;
    } catch (_) {
      return null;
    }
  }
}
