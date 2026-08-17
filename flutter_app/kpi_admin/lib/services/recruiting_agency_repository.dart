// lib/services/recruiting_agency_repository.dart
//
// Directory of staffing agencies ("Personalagenturen") per DSP.
//
// STORAGE LOCATION — deliberate:
//   users/{adminUid}/settings/recruiting_form_agencies
//
// The public, login-less agency form has to READ this list to offer
// "pick a saved agency". `firestore.rules` grants public read on
// `users/{uid}/settings/{settingId}` only when the settingId matches
// `recruiting_form_.*` — this doc does, so the picker works without a
// rules change. A dedicated `recruiting_agencies` collection would have
// no match block at all and would therefore be denied for EVERYONE
// (public AND admin) until the rules are extended.
//
// Writes stay admin-only (isSelf && isApproved), which is why a public
// submission carries its agency data on the application document and
// the admin panel adopts unknown agencies via [syncFromApplications].

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/recruiting_agency.dart';
import '../models/recruiting_application.dart';

class RecruitingAgencyRepository {
  RecruitingAgencyRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Settings doc id — MUST keep the `recruiting_form_` prefix so the
  /// public-read rule keeps matching it.
  static const String settingsDocId = 'recruiting_form_agencies';

  DocumentReference<Map<String, dynamic>> _doc(String adminUid) => _firestore
      .collection('users')
      .doc(adminUid)
      .collection('settings')
      .doc(settingsDocId);

  List<RecruitingAgency> _parse(Map<String, dynamic>? data) {
    final raw = data?['agencies'];
    if (raw is! List) return const <RecruitingAgency>[];
    final list = raw
        .whereType<Map>()
        .map((e) => RecruitingAgency.fromMap(Map<String, dynamic>.from(e)))
        .where((a) => a.name.trim().isNotEmpty || a.email.trim().isNotEmpty)
        .toList();
    list.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return list;
  }

  /// Live list for the admin panel.
  Stream<List<RecruitingAgency>> watch(String adminUid) =>
      _doc(adminUid).snapshots().map((s) => _parse(s.data()));

  /// One-shot read used by the public form so a slow stream never
  /// delays the first paint. Returns an empty list on any error — the
  /// form still works, the applicant just types the agency manually.
  Future<List<RecruitingAgency>> fetch(String adminUid) async {
    try {
      final snap = await _doc(adminUid).get();
      return _parse(snap.data());
    } catch (_) {
      return const <RecruitingAgency>[];
    }
  }

  /// Adds or updates one agency (dedupe by lower-cased email, falling
  /// back to the lower-cased name when no email is given).
  /// ADMIN ONLY — the public form cannot write to `settings`.
  Future<void> upsert({
    required String adminUid,
    required RecruitingAgency agency,
  }) async {
    final current = await fetch(adminUid);
    final merged = _merge(current, [agency]);
    await _write(adminUid, merged);
  }

  /// Adopts every agency referenced by [apps] that is not in the
  /// directory yet. Idempotent: writes only when something actually
  /// changed, so it is safe to call on every panel load.
  ///
  /// This is how agencies from PUBLIC submissions end up in the picker
  /// — the public form itself has no write access to `settings`.
  Future<void> syncFromApplications({
    required String adminUid,
    required List<RecruitingApplication> apps,
  }) async {
    final incoming = <RecruitingAgency>[];
    for (final a in apps) {
      if (a.customAnswers['viaAgency'] != true) continue;
      final name = (a.customAnswers['agencyName'] ?? '').toString().trim();
      final email = (a.customAnswers['agencyEmail'] ?? '').toString().trim();
      final phone = (a.customAnswers['agencyPhone'] ?? '').toString().trim();
      if (name.isEmpty && email.isEmpty) continue;
      incoming.add(
        RecruitingAgency(
          id: '',
          name: name,
          phone: phone,
          email: email,
          createdAt: a.submittedAt,
        ),
      );
    }
    if (incoming.isEmpty) return;

    final current = await fetch(adminUid);
    final merged = _merge(current, incoming);
    // Nur schreiben, wenn sich INHALTLICH etwas geändert hat — ein reiner
    // Längenvergleich würde aktualisierte Telefon-/Namensdaten bestehender
    // Agenturen still verwerfen.
    String sig(List<RecruitingAgency> list) => (list
            .map((a) => '${a.name.trim()}|${a.phone.trim()}|${a.email.trim()}')
            .toList()
          ..sort())
        .join('\n');
    if (sig(merged) == sig(current)) return;
    await _write(adminUid, merged);
  }

  /// Merges [incoming] into [current], keeping the existing entry (and
  /// its id/createdAt) when the dedupe key already exists.
  List<RecruitingAgency> _merge(
    List<RecruitingAgency> current,
    List<RecruitingAgency> incoming,
  ) {
    String keyOf(RecruitingAgency a) => a.email.trim().isEmpty
        ? 'name:${a.name.trim().toLowerCase()}'
        : 'mail:${a.dedupeKey}';

    final byKey = <String, RecruitingAgency>{
      for (final a in current) keyOf(a): a,
    };
    final now = DateTime.now();
    for (final a in incoming) {
      final k = keyOf(a);
      final existing = byKey[k];
      if (existing == null) {
        byKey[k] = RecruitingAgency(
          id: a.id.isNotEmpty
              ? a.id
              : now.microsecondsSinceEpoch.toString() +
                  k.hashCode.abs().toString(),
          name: a.name,
          phone: a.phone,
          email: a.email,
          createdAt: a.createdAt ?? now,
          updatedAt: now,
        );
      } else {
        // Keep identity, refresh contact details when they are filled.
        byKey[k] = existing.copyWith(
          name: a.name.trim().isEmpty ? existing.name : a.name,
          phone: a.phone.trim().isEmpty ? existing.phone : a.phone,
          updatedAt: now,
        );
      }
    }
    final list = byKey.values.toList();
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  Future<void> _write(String adminUid, List<RecruitingAgency> agencies) async {
    await _doc(adminUid).set(
      <String, dynamic>{
        'agencies': agencies.map((a) => a.toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
