import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../models/task_sheet_task.dart';

class DriverTasksView extends StatefulWidget {
  final String dspUid;
  final String driverTransporterId;

  const DriverTasksView({
    super.key,
    required this.dspUid,
    required this.driverTransporterId,
  });

  @override
  State<DriverTasksView> createState() => _DriverTasksViewState();
}

class _DriverTasksViewState extends State<DriverTasksView> {
  String get _driverTid => widget.driverTransporterId.toUpperCase();

  CollectionReference<Map<String, dynamic>> _tasksCol() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.dspUid)
        .collection('tasks');
  }

  Future<void> _updateStatus(
    TaskSheetTask task,
    DriverTaskStatus status,
  ) async {
    final t = AppLocalizations.of(context);
    final update = <String, dynamic>{
      'status': driverTaskStatusValue(status),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (status != DriverTaskStatus.completed) {
      update['completedConfirmed'] = false;
      update['completedConfirmedAt'] = null;
    }

    try {
      await _tasksCol().doc(task.id).set(update, SetOptions(merge: true));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            t.tf('driver_tasks_failed_update_status', {'error': '$e'}),
          ),
        ),
      );
    }
  }

  Future<void> _confirmCompleted(TaskSheetTask task) async {
    final t = AppLocalizations.of(context);
    if (task.status != DriverTaskStatus.completed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.t('driver_tasks_set_completed_first'))),
      );
      return;
    }

    try {
      await _tasksCol().doc(task.id).set({
        'completedConfirmed': true,
        'completedConfirmedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(content: Text(t.t('driver_tasks_completion_confirmed'))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            t.tf('driver_tasks_failed_confirm_task', {'error': '$e'}),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _tasksCol()
          .where('assignedTransporterId', isEqualTo: _driverTid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              t.tf('driver_tasks_error', {'error': '${snapshot.error}'}),
            ),
          );
        }

        final tasks =
            (snapshot.data?.docs ?? const [])
                .map(TaskSheetTask.fromDoc)
                .toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        if (tasks.isEmpty) {
          return Center(
            child: Text(
              t.t('driver_tasks_no_tasks'),
              style: const TextStyle(color: Colors.black54),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          itemCount: tasks.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final task = tasks[i];
            final statusColor = _statusColor(task.status);

            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: statusColor, width: 1.4),
                        ),
                        child: Text(
                          _statusLabel(t, task.status),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      task.description,
                      style: const TextStyle(
                        color: Color(0xFF4B5563),
                        height: 1.35,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    t.t('driver_tasks_update_status'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: DriverTaskStatus.values.map((status) {
                      final selected = status == task.status;
                      final color = _statusColor(status);
                      return ChoiceChip(
                        label: Text(_statusLabel(t, status)),
                        selected: selected,
                        showCheckmark: false,
                        backgroundColor: Colors.white,
                        selectedColor: color.withValues(alpha: 0.15),
                        side: BorderSide(
                          color: selected ? color : const Color(0xFFD1D5DB),
                          width: selected ? 1.4 : 1.0,
                        ),
                        labelStyle: TextStyle(
                          color: selected ? color : const Color(0xFF374151),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                        onSelected: (_) async {
                          if (selected) return;
                          await _updateStatus(task, status);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed:
                              (task.status == DriverTaskStatus.completed &&
                                  !task.completedConfirmed)
                              ? () => _confirmCompleted(task)
                              : null,
                          icon: const Icon(Icons.check_circle_outline),
                          label: Text(t.t('driver_tasks_confirm_completed')),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    task.completedConfirmed
                        ? t.t('driver_tasks_status_confirmed_by_you')
                        : t.t('driver_tasks_confirm_when_fully_done'),
                    style: TextStyle(
                      fontSize: 12,
                      color: task.completedConfirmed
                          ? const Color(0xFF1D7F5A)
                          : const Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _statusColor(DriverTaskStatus status) {
    switch (status) {
      case DriverTaskStatus.completed:
        return const Color(0xFF1D7F5A);
      case DriverTaskStatus.inProgress:
        return const Color(0xFFE9741A);
      case DriverTaskStatus.pending:
        return const Color(0xFF6B7280);
    }
  }

  String _statusLabel(AppLocalizations t, DriverTaskStatus status) {
    switch (status) {
      case DriverTaskStatus.completed:
        return t.t('driver_tasks_status_completed');
      case DriverTaskStatus.inProgress:
        return t.t('driver_tasks_status_in_progress');
      case DriverTaskStatus.pending:
        return t.t('driver_tasks_status_pending');
    }
  }
}
