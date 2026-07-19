// lib/models/dispatcher_task.dart
//
// Smart todo entry attached to a dispatcher (either a contact-only
// "Dispatcher Pill" name OR a sub-account UID). Tasks can recur
// daily / weekly / monthly; completing a recurring task does NOT
// delete it — instead `lastCompletedAt` is updated and a fresh
// `nextDue` is computed.

import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskRecurrence { once, daily, weekly, monthly }

extension TaskRecurrenceX on TaskRecurrence {
  String get wire => name;
  String get label {
    switch (this) {
      case TaskRecurrence.once:
        return 'Einmalig';
      case TaskRecurrence.daily:
        return 'Täglich';
      case TaskRecurrence.weekly:
        return 'Wöchentlich';
      case TaskRecurrence.monthly:
        return 'Monatlich';
    }
  }

  static TaskRecurrence fromWire(String? raw) {
    switch ((raw ?? '').toLowerCase()) {
      case 'daily':
        return TaskRecurrence.daily;
      case 'weekly':
        return TaskRecurrence.weekly;
      case 'monthly':
        return TaskRecurrence.monthly;
      case 'once':
      default:
        return TaskRecurrence.once;
    }
  }
}

class DispatcherTask {
  final String id;
  /// Who the task belongs to. Free-form string — usually the
  /// dispatcher's display name (matches the entries on the Dispatcher
  /// Pill page) OR a sub-account UID for managed dispatchers.
  final String dispatcherKey;
  final String title;
  final String category; // free-form ("Morgenrunde", "Wartung", …)
  final TaskRecurrence recurrence;
  /// Scheduled date for the next execution. Optional for `once`
  /// tasks where the admin doesn't care about a fixed day.
  final DateTime? dueDate;
  /// `null` if the task hasn't been completed yet. For recurring
  /// tasks this is the most recent completion — `nextDue` is computed
  /// from this + recurrence interval.
  final DateTime? lastCompletedAt;
  final String? note;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdByUid;

  const DispatcherTask({
    required this.id,
    required this.dispatcherKey,
    required this.title,
    required this.category,
    required this.recurrence,
    this.dueDate,
    this.lastCompletedAt,
    this.note,
    this.createdAt,
    this.updatedAt,
    this.createdByUid,
  });

  /// True for once-tasks already completed, or recurring tasks whose
  /// computed next-due is in the future (so admin treats them as
  /// "done for now").
  bool get isDoneForNow {
    if (recurrence == TaskRecurrence.once) return lastCompletedAt != null;
    final next = computedNextDue;
    if (next == null) return false;
    return next.isAfter(DateTime.now());
  }

  /// For recurring tasks: when the next instance becomes due.
  /// For one-shot: the dueDate (or null).
  DateTime? get computedNextDue {
    if (recurrence == TaskRecurrence.once) return dueDate;
    final base = lastCompletedAt ?? dueDate;
    if (base == null) return null;
    switch (recurrence) {
      case TaskRecurrence.daily:
        return base.add(const Duration(days: 1));
      case TaskRecurrence.weekly:
        return base.add(const Duration(days: 7));
      case TaskRecurrence.monthly:
        return DateTime(base.year, base.month + 1, base.day);
      case TaskRecurrence.once:
        return dueDate;
    }
  }

  Map<String, dynamic> toMap() => {
        'dispatcherKey': dispatcherKey,
        'title': title,
        'category': category,
        'recurrence': recurrence.wire,
        if (dueDate != null) 'dueDate': Timestamp.fromDate(dueDate!),
        if (lastCompletedAt != null)
          'lastCompletedAt': Timestamp.fromDate(lastCompletedAt!),
        if (note != null && note!.isNotEmpty) 'note': note,
        if (createdByUid != null) 'createdByUid': createdByUid,
        'updatedAt': FieldValue.serverTimestamp(),
      };

  factory DispatcherTask.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final m = doc.data() ?? const <String, dynamic>{};
    final dt = m['dueDate'];
    final lc = m['lastCompletedAt'];
    final ca = m['createdAt'];
    final ua = m['updatedAt'];
    return DispatcherTask(
      id: doc.id,
      dispatcherKey: (m['dispatcherKey'] ?? '').toString(),
      title: (m['title'] ?? '').toString(),
      category: (m['category'] ?? '').toString(),
      recurrence:
          TaskRecurrenceX.fromWire(m['recurrence']?.toString()),
      dueDate: dt is Timestamp ? dt.toDate() : null,
      lastCompletedAt: lc is Timestamp ? lc.toDate() : null,
      note: (m['note'] ?? '').toString().isEmpty
          ? null
          : m['note'] as String,
      createdAt: ca is Timestamp ? ca.toDate() : null,
      updatedAt: ua is Timestamp ? ua.toDate() : null,
      createdByUid: (m['createdByUid'] ?? '').toString().isEmpty
          ? null
          : m['createdByUid'] as String,
    );
  }
}
