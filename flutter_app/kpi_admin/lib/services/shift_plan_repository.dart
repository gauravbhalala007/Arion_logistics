import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/shift_plan.dart';

class ShiftPlanRepository {
  ShiftPlanRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _docRef(
    String adminUid,
    String dateKey,
  ) =>
      _firestore
          .collection('users')
          .doc(adminUid)
          .collection('shift_plans')
          .doc(dateKey);

  Stream<ShiftPlanDoc?> watch({
    required String adminUid,
    required String dateKey,
  }) {
    return _docRef(adminUid, dateKey).snapshots().map((snap) {
      if (!snap.exists) return null;
      return ShiftPlanDoc.fromDoc(snap);
    });
  }

  Future<void> publish({
    required String adminUid,
    required ShiftPlanDoc plan,
  }) async {
    await _docRef(adminUid, plan.dateKey).set(plan.toCreatePayload());
  }

  DocumentReference<Map<String, dynamic>> _draftDocRef(
    String adminUid,
    String dateKey,
  ) =>
      _firestore
          .collection('users')
          .doc(adminUid)
          .collection('shift_plan_drafts')
          .doc(dateKey);

  /// Persist a plan WITHOUT publishing to drivers. Stored in a separate
  /// `shift_plan_drafts` collection that drivers cannot read, so it stays
  /// internal. Used to back-fill past weeks for the Payment Check.
  Future<void> saveInternal({
    required String adminUid,
    required ShiftPlanDoc plan,
  }) async {
    await _draftDocRef(adminUid, plan.dateKey).set(plan.toDraftPayload());
  }

  /// Watch the internally-saved draft for a day (if any). Lets the admin
  /// page rehydrate a saved-but-unpublished plan after a browser refresh
  /// or re-login, so "Save" actually persists across sessions.
  Stream<ShiftPlanDoc?> watchDraft({
    required String adminUid,
    required String dateKey,
  }) {
    return _draftDocRef(adminUid, dateKey).snapshots().map((snap) {
      if (!snap.exists) return null;
      return ShiftPlanDoc.fromDoc(snap);
    });
  }

  Future<void> unpublish({
    required String adminUid,
    required String dateKey,
  }) async {
    await _docRef(adminUid, dateKey).delete();
  }

  // ── Note templates ────────────────────────────────────────────────
  // Saved per admin under
  // `users/{adminUid}/shift_plan_note_templates/{templateId}`.
  // Each doc: `{title, body, createdAt}`.

  CollectionReference<Map<String, dynamic>> _templatesCol(
    String adminUid,
  ) =>
      _firestore
          .collection('users')
          .doc(adminUid)
          .collection('shift_plan_note_templates');

  Stream<List<NoteTemplate>> watchNoteTemplates(String adminUid) {
    return _templatesCol(adminUid)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => NoteTemplate.fromDoc(d))
            .toList());
  }

  Future<void> saveNoteTemplate({
    required String adminUid,
    required String title,
    required String body,
  }) async {
    await _templatesCol(adminUid).add(<String, dynamic>{
      'title': title.trim(),
      'body': body.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteNoteTemplate({
    required String adminUid,
    required String templateId,
  }) async {
    await _templatesCol(adminUid).doc(templateId).delete();
  }
}

class NoteTemplate {
  const NoteTemplate({
    required this.id,
    required this.title,
    required this.body,
  });

  final String id;
  final String title;
  final String body;

  factory NoteTemplate.fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data();
    return NoteTemplate(
      id: doc.id,
      title: (d['title'] ?? '').toString(),
      body: (d['body'] ?? '').toString(),
    );
  }
}
