// lib/services/dispatcher_task_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/dispatcher_task.dart';

class DispatcherTaskRepository {
  DispatcherTaskRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _col(String dspUid) => _db
      .collection('users')
      .doc(dspUid)
      .collection('dispatcher_tasks');

  Stream<List<DispatcherTask>> watch(String dspUid) {
    return _col(dspUid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(DispatcherTask.fromDoc).toList());
  }

  Stream<List<DispatcherTask>> watchFor({
    required String dspUid,
    required String dispatcherKey,
  }) {
    return _col(dspUid)
        .where('dispatcherKey', isEqualTo: dispatcherKey)
        .snapshots()
        .map((s) => s.docs.map(DispatcherTask.fromDoc).toList());
  }

  Future<String> create({
    required String dspUid,
    required String dispatcherKey,
    required String title,
    required String category,
    required TaskRecurrence recurrence,
    DateTime? dueDate,
    String? note,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final ref = await _col(dspUid).add({
      'dispatcherKey': dispatcherKey,
      'title': title,
      'category': category,
      'recurrence': recurrence.wire,
      if (dueDate != null) 'dueDate': Timestamp.fromDate(dueDate),
      if (note != null && note.isNotEmpty) 'note': note,
      if (uid != null) 'createdByUid': uid,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> update({
    required String dspUid,
    required String taskId,
    String? title,
    String? category,
    TaskRecurrence? recurrence,
    DateTime? dueDate,
    bool clearDueDate = false,
    String? note,
  }) async {
    final patch = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (title != null) patch['title'] = title;
    if (category != null) patch['category'] = category;
    if (recurrence != null) patch['recurrence'] = recurrence.wire;
    if (clearDueDate) {
      patch['dueDate'] = FieldValue.delete();
    } else if (dueDate != null) {
      patch['dueDate'] = Timestamp.fromDate(dueDate);
    }
    if (note != null) {
      patch['note'] = note.isEmpty ? FieldValue.delete() : note;
    }
    await _col(dspUid).doc(taskId).update(patch);
  }

  Future<void> markComplete({
    required String dspUid,
    required String taskId,
  }) async {
    await _col(dspUid).doc(taskId).update({
      'lastCompletedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markIncomplete({
    required String dspUid,
    required String taskId,
  }) async {
    await _col(dspUid).doc(taskId).update({
      'lastCompletedAt': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> delete({
    required String dspUid,
    required String taskId,
  }) async {
    await _col(dspUid).doc(taskId).delete();
  }
}
