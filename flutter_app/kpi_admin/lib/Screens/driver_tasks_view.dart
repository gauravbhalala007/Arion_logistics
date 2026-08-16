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
  final Map<String, TextEditingController> _feedbackCtrls = {};
  final Map<String, String> _selectedFeedbackOptions = {};
  final Set<String> _submittingFeedback = <String>{};

  String get _driverTid => widget.driverTransporterId.toUpperCase();

  CollectionReference<Map<String, dynamic>> _tasksCol() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.dspUid)
        .collection('tasks');
  }

  @override
  void dispose() {
    for (final controller in _feedbackCtrls.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _feedbackCtrlFor(TaskSheetTask task) {
    final existing = _feedbackCtrls[task.id];
    if (existing != null) {
      if (task.feedbackText.isNotEmpty && existing.text != task.feedbackText) {
        existing.text = task.feedbackText;
      }
      return existing;
    }
    final controller = TextEditingController(text: task.feedbackText);
    _feedbackCtrls[task.id] = controller;
    return controller;
  }

  String _selectedOptionFor(TaskSheetTask task) {
    final local = _selectedFeedbackOptions[task.id];
    if (local != null) return local;
    return task.feedbackSelectedOption;
  }

  String _taskKindLabel(AppLocalizations t, TaskSheetTask task) {
    if (task.isFeedbackText) return t.t('task_sheet_response_feedback_text');
    if (task.isFeedbackChoice) {
      return t.t('task_sheet_response_feedback_choice');
    }
    return t.t('task_sheet_response_standard');
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

  Future<void> _submitFeedback(TaskSheetTask task) async {
    final t = AppLocalizations.of(context);
    final update = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
      'respondedAt': FieldValue.serverTimestamp(),
      'status': driverTaskStatusValue(DriverTaskStatus.completed),
      'completedConfirmed': true,
      'completedConfirmedAt': FieldValue.serverTimestamp(),
    };

    if (task.isFeedbackText) {
      final feedback = _feedbackCtrlFor(task).text.trim();
      if (feedback.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.t('task_sheet_feedback_text_required'))),
        );
        return;
      }
      update['feedbackText'] = feedback;
      update['feedbackSelectedOption'] = '';
    } else if (task.isFeedbackChoice) {
      final selected = _selectedOptionFor(task).trim();
      if (selected.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.t('task_sheet_feedback_choice_required'))),
        );
        return;
      }
      update['feedbackSelectedOption'] = selected;
      update['feedbackText'] = '';
    } else {
      return;
    }

    setState(() => _submittingFeedback.add(task.id));
    try {
      await _tasksCol().doc(task.id).set(update, SetOptions(merge: true));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.t('task_sheet_feedback_submitted'))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t.tf('driver_tasks_failed_confirm_task', {'error': '$e'}),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _submittingFeedback.remove(task.id));
      }
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
            final feedbackBusy = _submittingFeedback.contains(task.id);
            // Show the task in the driver's active app language when an
            // auto-translation exists; otherwise fall back to the source text.
            final lang = Localizations.localeOf(context).languageCode;
            final taskTitle = task.localizedTitle(lang);
            final taskDescription = task.localizedDescription(lang);

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
                          taskTitle,
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
                  if (taskDescription.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      taskDescription,
                      style: const TextStyle(
                        color: Color(0xFF4B5563),
                        height: 1.35,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F6F8),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _taskKindLabel(t, task),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (task.isFeedbackText) ...[
                    _FeedbackPanel(
                      title: t.t('task_sheet_feedback_prompt_text'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _feedbackCtrlFor(task),
                            minLines: 3,
                            maxLines: 5,
                            textAlignVertical: TextAlignVertical.top,
                            decoration: InputDecoration(
                              hintText: t.t('task_sheet_feedback_input_hint'),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE5E7EB),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE5E7EB),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xFF1D7F5A),
                                  width: 1.2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _FeedbackSubmitButton(
                            busy: feedbackBusy,
                            label: task.feedbackResponse.isNotEmpty
                                ? t.t('task_sheet_feedback_update')
                                : t.t('task_sheet_feedback_submit'),
                            onPressed: () => _submitFeedback(task),
                          ),
                        ],
                      ),
                    ),
                  ] else if (task.isFeedbackChoice) ...[
                    _FeedbackPanel(
                      title: t.t('task_sheet_feedback_prompt_choice'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: task.feedbackOptions.map((option) {
                              final selected = _selectedOptionFor(task) == option;
                              return ChoiceChip(
                                label: Text(option),
                                selected: selected,
                                showCheckmark: false,
                                backgroundColor: Colors.white,
                                selectedColor: const Color(0xFFE8F5EE),
                                side: BorderSide(
                                  color: selected
                                      ? const Color(0xFF1D7F5A)
                                      : const Color(0xFFD1D5DB),
                                ),
                                labelStyle: TextStyle(
                                  color: selected
                                      ? const Color(0xFF1D7F5A)
                                      : const Color(0xFF374151),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                                onSelected: (_) {
                                  setState(() {
                                    _selectedFeedbackOptions[task.id] = option;
                                  });
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 10),
                          _FeedbackSubmitButton(
                            busy: feedbackBusy,
                            label: task.feedbackResponse.isNotEmpty
                                ? t.t('task_sheet_feedback_update')
                                : t.t('task_sheet_feedback_submit'),
                            onPressed: () => _submitFeedback(task),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
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
                  ],
                  const SizedBox(height: 6),
                  Text(
                    task.isFeedbackTask
                        ? (task.feedbackResponse.isNotEmpty
                              ? t.t('task_sheet_feedback_received')
                              : t.t('task_sheet_feedback_waiting'))
                        : (task.completedConfirmed
                              ? t.t('driver_tasks_status_confirmed_by_you')
                              : t.t('driver_tasks_confirm_when_fully_done')),
                    style: TextStyle(
                      fontSize: 12,
                      color: (task.isFeedbackTask
                              ? task.feedbackResponse.isNotEmpty
                              : task.completedConfirmed)
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

class _FeedbackPanel extends StatelessWidget {
  final String title;
  final Widget child;

  const _FeedbackPanel({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _FeedbackSubmitButton extends StatelessWidget {
  final bool busy;
  final String label;
  final VoidCallback onPressed;

  const _FeedbackSubmitButton({
    required this.busy,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: busy ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1D7F5A),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        child: busy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(label),
              ),
      ),
    );
  }
}
