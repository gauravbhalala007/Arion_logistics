import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/recruiting_application.dart';
import '../models/recruiting_form_config.dart';

/// Firestore wrapper for the Recruiting workflow.
///
/// Submissions live at
///   `users/{adminUid}/recruiting_applications/{appId}`.
///
/// The public form (no login) calls [submit] which uses
/// `collection.add()` so the rules can validate the resource shape.
/// Admins read/update via [watchByChannel] + [updateStatus].
class RecruitingRepository {
  RecruitingRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _col(String adminUid) =>
      _firestore
          .collection('users')
          .doc(adminUid)
          .collection('recruiting_applications');

  DocumentReference<Map<String, dynamic>> _formConfigDoc(
    String adminUid,
    RecruitingChannel channel,
  ) =>
      _firestore
          .collection('users')
          .doc(adminUid)
          .collection('settings')
          .doc('recruiting_form_${channel.value}');

  /// Stream the DSP's custom-question config for [channel]. Returns
  /// an empty config when no doc exists.
  Stream<RecruitingFormConfig> watchFormConfig({
    required String adminUid,
    required RecruitingChannel channel,
  }) {
    return _formConfigDoc(adminUid, channel).snapshots().map((snap) {
      if (!snap.exists) return RecruitingFormConfig.empty();
      return RecruitingFormConfig.fromDoc(snap);
    });
  }

  /// One-shot read used by the public form so a slow stream during
  /// page load doesn't delay the first paint.
  Future<RecruitingFormConfig> fetchFormConfig({
    required String adminUid,
    required RecruitingChannel channel,
  }) async {
    final snap = await _formConfigDoc(adminUid, channel).get();
    if (!snap.exists) return RecruitingFormConfig.empty();
    return RecruitingFormConfig.fromDoc(snap);
  }

  Future<void> saveFormConfig({
    required String adminUid,
    required RecruitingChannel channel,
    required List<RecruitingCustomField> fields,
  }) async {
    final cfg = RecruitingFormConfig(fields: fields, updatedAt: null);
    await _formConfigDoc(adminUid, channel).set(cfg.toMap());
  }

  /// Stream submissions filtered by [channel] (local vs visa), newest
  /// first. Used by the admin Recruiting panel.
  ///
  /// We stream the full collection and filter + sort client-side so
  /// we never need a composite Firestore index. Applications are
  /// low-volume (dozens, not millions) — the overhead is negligible
  /// and skipping the index keeps deploys simpler.
  Stream<List<RecruitingApplication>> watchByChannel({
    required String adminUid,
    required RecruitingChannel channel,
  }) {
    return _col(adminUid).snapshots().map((snap) {
      final all = snap.docs.map(RecruitingApplication.fromDoc).toList();
      final filtered =
          all.where((a) => a.channel == channel).toList();
      filtered.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
      return filtered;
    });
  }

  /// Public-form submission entry-point. Anyone can call this — the
  /// Firestore rule validates that `channel` is one of the known
  /// values and that the document carries the matching `adminUid`.
  Future<String> submit({
    required RecruitingApplication application,
  }) async {
    final ref =
        await _col(application.adminUid).add(application.toCreatePayload());
    return ref.id;
  }

  Future<void> updateStatus({
    required String adminUid,
    required String applicationId,
    required RecruitingStatus status,
  }) async {
    await _col(adminUid).doc(applicationId).update(<String, dynamic>{
      'status': status.value,
      'statusUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateNote({
    required String adminUid,
    required String applicationId,
    required String note,
  }) async {
    await _col(adminUid).doc(applicationId).update(<String, dynamic>{
      'adminNote': note.trim(),
      'noteUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Cascade-delete an application: wipe every file in the Storage
  /// folder `recruiting/{adminUid}/{appId}/`, then delete the
  /// Firestore doc. Storage errors are swallowed so an orphan file
  /// can never block the metadata delete (admins can clean up
  /// orphans manually via the Firebase console if needed).
  Future<void> delete({
    required String adminUid,
    required String applicationId,
  }) async {
    try {
      final folder = FirebaseStorage.instance
          .ref('recruiting/$adminUid/$applicationId');
      final listing = await folder.listAll();
      await Future.wait(
        listing.items.map((ref) => ref.delete()),
      );
    } catch (e) {
      // Best-effort: keep going so we still remove the Firestore doc
      // even if Storage cleanup fails (permissions, network, etc.).
      // ignore: avoid_print
      print('[recruiting] storage cleanup failed for '
          '$applicationId: $e');
    }
    await _col(adminUid).doc(applicationId).delete();
  }
}
