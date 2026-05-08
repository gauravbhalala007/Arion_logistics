import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../models/task_sheet_task.dart';
import '../utils/driver_activity.dart';

enum _TaskComposerKind { standard, feedbackText, feedbackChoice }

class _FeedbackChoiceSummary {
  final List<String> optionOrder;
  final Map<String, List<TaskSheetTask>> tasksByOption;
  final List<TaskSheetTask> pendingTasks;

  const _FeedbackChoiceSummary({
    required this.optionOrder,
    required this.tasksByOption,
    required this.pendingTasks,
  });

  int countForOption(String option) => tasksByOption[option]?.length ?? 0;

  int get totalActive {
    var total = pendingTasks.length;
    for (final tasks in tasksByOption.values) {
      total += tasks.length;
    }
    return total;
  }
}

class TaskSheetPage extends StatefulWidget {
  const TaskSheetPage({super.key});

  @override
  State<TaskSheetPage> createState() => _TaskSheetPageState();
}

class _TaskSheetPageState extends State<TaskSheetPage> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _composerScrollCtrl = ScrollController();
  final List<TextEditingController> _feedbackOptionCtrls = [
    TextEditingController(),
    TextEditingController(),
  ];
  bool _creating = false;
  bool _assignToEveryone = false;
  String? _selectedTransporterId;
  String? _selectedDriverName;
  String _driverQuery = '';
  _TaskComposerKind _taskKind = _TaskComposerKind.standard;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> _tasksCol() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('tasks');
  }

  CollectionReference<Map<String, dynamic>> _driversCol() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('drivers');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _composerScrollCtrl.dispose();
    for (final controller in _feedbackOptionCtrls) {
      controller.dispose();
    }
    super.dispose();
  }

  String _newBatchId() {
    return 'all_${DateTime.now().microsecondsSinceEpoch}';
  }

  List<String> _parsedFeedbackOptions() {
    return _feedbackOptionCtrls
        .map((controller) => controller.text.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);
  }

  void _setTaskKind(_TaskComposerKind kind) {
    setState(() {
      _taskKind = kind;
      if (kind != _TaskComposerKind.feedbackChoice) {
        for (final controller in _feedbackOptionCtrls) {
          controller.clear();
        }
      } else if (_feedbackOptionCtrls.length < 2) {
        while (_feedbackOptionCtrls.length < 2) {
          _feedbackOptionCtrls.add(TextEditingController());
        }
      }
    });
  }

  void _addFeedbackOption() {
    setState(() {
      _feedbackOptionCtrls.add(TextEditingController());
    });
  }

  void _removeFeedbackOption(int index) {
    if (_feedbackOptionCtrls.length <= 2) return;
    setState(() {
      final controller = _feedbackOptionCtrls.removeAt(index);
      controller.dispose();
    });
  }

  String _taskKindValue() {
    switch (_taskKind) {
      case _TaskComposerKind.feedbackText:
        return 'feedback_text';
      case _TaskComposerKind.feedbackChoice:
        return 'feedback_choice';
      case _TaskComposerKind.standard:
        return 'standard';
    }
  }

  Future<void> _createTask() async {
    final l10n = AppLocalizations.of(context);
    if (_uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('task_sheet_must_be_logged_in'))),
      );
      return;
    }

    final title = _titleCtrl.text.trim();
    final description = _descCtrl.text.trim();
    final transporterId = (_selectedTransporterId ?? '').trim().toUpperCase();
    final driverName = (_selectedDriverName ?? '').trim();
    final feedbackOptions = _parsedFeedbackOptions();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('task_sheet_title_required'))),
      );
      return;
    }
    if (!_assignToEveryone && transporterId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('task_sheet_assign_driver_required'))),
      );
      return;
    }
    if (_taskKind == _TaskComposerKind.feedbackChoice &&
        feedbackOptions.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('task_sheet_feedback_options_required'))),
      );
      return;
    }

    final basePayload = <String, dynamic>{
      'title': title,
      'description': description,
      'taskKind': _taskKindValue(),
      'feedbackOptions': feedbackOptions,
      'feedbackText': '',
      'feedbackSelectedOption': '',
      'respondedAt': null,
      'status': 'pending',
      'completedConfirmed': false,
      'createdByUid': _uid,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    setState(() => _creating = true);
    try {
      if (_assignToEveryone) {
        final driversSnap = await _driversCol().get();
        final activeDrivers = driversSnap.docs
            .where((d) => isDriverWorking(d.data()))
            .toList(growable: false);
        if (activeDrivers.isEmpty) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.t('task_sheet_no_drivers_assign'))),
          );
          return;
        }

        final db = FirebaseFirestore.instance;
        WriteBatch batch = db.batch();
        var opCount = 0;
        var assignedCount = 0;
        final batchId = _newBatchId();

        for (final driverDoc in activeDrivers) {
          final data = driverDoc.data();
          final tid = (data['transporterId'] ?? driverDoc.id).toString().trim();
          final name = (data['driverName'] ?? data['fullName'] ?? tid)
              .toString()
              .trim();

          if (tid.isEmpty) continue;

          final taskRef = _tasksCol().doc();
          batch.set(taskRef, {
            ...basePayload,
            'assignedTransporterId': tid.toUpperCase(),
            'assignedDriverName': name,
            'assignmentScope': 'all',
            'assignmentBatchId': batchId,
          });
          opCount++;
          if (opCount >= 450) {
            await batch.commit();
            batch = db.batch();
            opCount = 0;
          }
          assignedCount++;
        }

        if (assignedCount == 0) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.t('task_sheet_no_valid_drivers'))),
          );
          return;
        }

        if (opCount > 0) {
          await batch.commit();
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.tf('task_sheet_created_for_drivers', {
                  'count': '$assignedCount',
                }),
              ),
            ),
          );
        }
      } else {
        await _tasksCol().add({
          ...basePayload,
          'assignedTransporterId': transporterId,
          'assignedDriverName': driverName,
          'assignmentScope': 'single',
          'assignmentBatchId': '',
        });
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.t('task_sheet_created'))));
        }
      }

      _titleCtrl.clear();
      _descCtrl.clear();
      for (final controller in _feedbackOptionCtrls) {
        controller.clear();
      }
      _driverQuery = '';
      _taskKind = _TaskComposerKind.standard;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.tf('task_sheet_failed_create', {'error': e.toString()}),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  Future<void> _deleteTask(String taskId) async {
    final l10n = AppLocalizations.of(context);
    await _deleteTasksByIds([
      taskId,
    ], successMessage: l10n.t('task_sheet_deleted'));
  }

  Future<void> _deleteTaskBatch(List<String> taskIds) async {
    final l10n = AppLocalizations.of(context);
    await _deleteTasksByIds(
      taskIds,
      successMessage: l10n.t('task_sheet_deleted_all_assigned'),
    );
  }

  Future<void> _deleteTasksByIds(
    List<String> taskIds, {
    required String successMessage,
  }) async {
    final l10n = AppLocalizations.of(context);
    if (taskIds.isEmpty) return;

    try {
      final db = FirebaseFirestore.instance;
      WriteBatch batch = db.batch();
      var opCount = 0;

      for (final taskId in taskIds) {
        batch.delete(_tasksCol().doc(taskId));
        opCount++;
        if (opCount >= 450) {
          await batch.commit();
          batch = db.batch();
          opCount = 0;
        }
      }

      if (opCount > 0) {
        await batch.commit();
      }

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.tf('task_sheet_failed_delete', {'error': e.toString()}),
          ),
        ),
      );
    }
  }

  Future<void> _confirmDeleteTask(TaskSheetTask task) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.t('task_sheet_delete_task_title')),
        content: Text(
          l10n.tf('task_sheet_delete_task_confirm', {'title': task.title}),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.t('task_sheet_cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.t('task_sheet_delete')),
          ),
        ],
      ),
    );

    if (ok == true) {
      await _deleteTask(task.id);
    }
  }

  Future<void> _confirmDeleteTaskBatch(
    String title,
    List<TaskSheetTask> tasksInBatch,
  ) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.t('task_sheet_delete_for_everyone_title')),
        content: Text(
          l10n.tf('task_sheet_delete_for_everyone_confirm', {
            'title': title,
            'count': '${tasksInBatch.length}',
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.t('task_sheet_cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.t('task_sheet_delete_all')),
          ),
        ],
      ),
    );

    if (ok == true) {
      await _deleteTaskBatch(tasksInBatch.map((t) => t.id).toList());
    }
  }

  List<_TaskListItem> _groupTaskItemsForAdmin(List<TaskSheetTask> tasks) {
    final items = <_TaskListItem>[];
    final handledBatchIds = <String>{};

    for (final task in tasks) {
      final isAllTask =
          task.assignmentScope == 'all' && task.assignmentBatchId.isNotEmpty;
      if (!isAllTask) {
        items.add(_TaskListItem.single(task));
        continue;
      }

      if (handledBatchIds.contains(task.assignmentBatchId)) {
        continue;
      }

      final grouped = tasks
          .where(
            (t) =>
                t.assignmentScope == 'all' &&
                t.assignmentBatchId == task.assignmentBatchId,
          )
          .toList();

      handledBatchIds.add(task.assignmentBatchId);
      items.add(
        _TaskListItem.group(batchId: task.assignmentBatchId, tasks: grouped),
      );
    }

    return items;
  }

  String _formatDate(DateTime dateTime) {
    if (dateTime.millisecondsSinceEpoch == 0) {
      return AppLocalizations.of(context).t('task_sheet_just_now');
    }
    final local = dateTime.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  String _taskKindLabel(TaskSheetTask task) {
    final l10n = AppLocalizations.of(context);
    if (task.isFeedbackText) return l10n.t('task_sheet_response_feedback_text');
    if (task.isFeedbackChoice) {
      return l10n.t('task_sheet_response_feedback_choice');
    }
    return l10n.t('task_sheet_response_standard');
  }

  _FeedbackChoiceSummary _feedbackChoiceSummary(List<TaskSheetTask> tasks) {
    final optionOrder = tasks.isNotEmpty
        ? tasks.first.feedbackOptions
        : const <String>[];
    final tasksByOption = {
      for (final option in optionOrder) option: <TaskSheetTask>[],
    };
    final pendingTasks = <TaskSheetTask>[];

    for (final task in tasks) {
      final selected = task.feedbackSelectedOption.trim();
      if (selected.isEmpty || !tasksByOption.containsKey(selected)) {
        pendingTasks.add(task);
        continue;
      }
      tasksByOption[selected]!.add(task);
    }

    return _FeedbackChoiceSummary(
      optionOrder: optionOrder,
      tasksByOption: tasksByOption,
      pendingTasks: pendingTasks,
    );
  }

  Widget _responseTypeCard({
    required String label,
    required String description,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final borderColor = selected
        ? const Color(0xFF1D7F5A)
        : const Color(0xFFE5E7EB);
    final backgroundColor = selected
        ? const Color(0xFFEFF9F2)
        : const Color(0xFFF8FAFC);
    final iconColor = selected
        ? const Color(0xFF1D7F5A)
        : const Color(0xFF6B7280);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: selected ? 1.6 : 1.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: selected
                          ? const Color(0xFF1D7F5A)
                          : const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 11.5,
                      height: 1.35,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _pillField({required String hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF6F7F9),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFF1D7F5A), width: 1.2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_uid == null) {
      return Center(child: Text(l10n.t('task_sheet_must_be_logged_in')));
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          final stack = w < 800;

          const headerBlock = 22.0 + 16.0;
          final contentH = (h - headerBlock).clamp(520.0, 5000.0);
          final historyH = stack
              ? (contentH * 0.44).clamp(320.0, 620.0)
              : contentH;

          final left = _buildComposerCard(compactLayout: stack);
          final right = _buildHistoryCard();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                runSpacing: 6,
                children: [
                  const Icon(Icons.task_alt_outlined, size: 22),
                  Text(
                    l10n.t('task_sheet_page_title'),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: stack
                    ? ListView(
                        children: [
                          left,
                          const SizedBox(height: 16),
                          SizedBox(height: historyH, child: right),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(flex: 6, child: left),
                          const SizedBox(width: 18),
                          Expanded(flex: 4, child: right),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildComposerCard({required bool compactLayout}) {
    final l10n = AppLocalizations.of(context);
    final responseCardsCompact = MediaQuery.sizeOf(context).width < 1100;
    final detailsHeight = compactLayout
        ? 140.0
        : (_taskKind == _TaskComposerKind.feedbackChoice ? 120.0 : 170.0);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Scrollbar(
            controller: _composerScrollCtrl,
            thumbVisibility: constraints.maxHeight < 760,
            child: SingleChildScrollView(
              controller: _composerScrollCtrl,
              primary: false,
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.task_alt_outlined,
                        color: Color(0xFF1D7F5A),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.t('task_sheet_new_content_title'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    l10n.t('task_sheet_assign_task'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: Text(l10n.t('task_sheet_specific_driver')),
                        selected: !_assignToEveryone,
                        onSelected: (_) {
                          setState(() {
                            _assignToEveryone = false;
                          });
                        },
                        backgroundColor: Colors.white,
                        selectedColor: const Color(0xFFE8F5EE),
                        side: BorderSide(
                          color: !_assignToEveryone
                              ? const Color(0xFF1D7F5A)
                              : const Color(0xFFD1D5DB),
                        ),
                        labelStyle: TextStyle(
                          color: !_assignToEveryone
                              ? const Color(0xFF1D7F5A)
                              : const Color(0xFF374151),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      ChoiceChip(
                        label: Text(l10n.t('task_sheet_everyone')),
                        selected: _assignToEveryone,
                        onSelected: (_) {
                          setState(() {
                            _assignToEveryone = true;
                            _selectedTransporterId = null;
                            _selectedDriverName = null;
                            _driverQuery = '';
                          });
                        },
                        backgroundColor: Colors.white,
                        selectedColor: const Color(0xFFE8F5EE),
                        side: BorderSide(
                          color: _assignToEveryone
                              ? const Color(0xFF1D7F5A)
                              : const Color(0xFFD1D5DB),
                        ),
                        labelStyle: TextStyle(
                          color: _assignToEveryone
                              ? const Color(0xFF1D7F5A)
                              : const Color(0xFF374151),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _driversCol().snapshots(),
                    builder: (context, snapshot) {
                      final docs = snapshot.data?.docs ?? const [];
                      final options =
                          docs
                              .where((d) => isDriverWorking(d.data()))
                              .map((d) {
                                final data = d.data();
                                final transporterId =
                                    (data['transporterId'] ?? d.id)
                                        .toString()
                                        .trim();
                                final driverName =
                                    (data['driverName'] ??
                                            data['fullName'] ??
                                            d.id)
                                        .toString()
                                        .trim();
                                return _DriverOption(
                                  transporterId: transporterId.toUpperCase(),
                                  driverName: driverName.isEmpty
                                      ? transporterId
                                      : driverName,
                                );
                              })
                              .where((o) => o.transporterId.isNotEmpty)
                              .toList()
                            ..sort(
                              (a, b) => a.driverName.toLowerCase().compareTo(
                                b.driverName.toLowerCase(),
                              ),
                            );

                      if (_selectedTransporterId != null &&
                          !options.any(
                            (o) => o.transporterId == _selectedTransporterId,
                          )) {
                        _selectedTransporterId = null;
                        _selectedDriverName = null;
                      }

                      if (_assignToEveryone) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: _pill(
                            l10n.t('task_sheet_assigned_to_everyone'),
                            borderColor: const Color(0xFF1D7F5A),
                            textColor: const Color(0xFF1D7F5A),
                          ),
                        );
                      }

                      final query = _driverQuery.trim().toLowerCase();
                      final filtered = query.isEmpty
                          ? options
                          : options.where((o) {
                              return o.driverName.toLowerCase().contains(query) ||
                                  o.transporterId.toLowerCase().contains(query);
                            }).toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            decoration: InputDecoration(
                              hintText: l10n.t('task_sheet_search_driver_hint'),
                              prefixIcon: const Icon(Icons.search),
                              filled: true,
                              fillColor: const Color(0xFFF6F7F9),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE5E7EB),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE5E7EB),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: const BorderSide(
                                  color: Color(0xFF1D7F5A),
                                  width: 1.2,
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() => _driverQuery = value);
                            },
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(maxHeight: 170),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFD1D5DB)),
                            ),
                            child: filtered.isEmpty
                                ? Center(
                                    child: Text(
                                      l10n.t('task_sheet_no_drivers_found'),
                                      style: const TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),
                                  )
                                : SingleChildScrollView(
                                    child: Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: filtered.map((o) {
                                        final selected =
                                            o.transporterId ==
                                            _selectedTransporterId;
                                        return ChoiceChip(
                                          label: Text(
                                            '${o.driverName} (${o.transporterId})',
                                          ),
                                          selected: selected,
                                          onSelected: (_) {
                                            setState(() {
                                              _selectedTransporterId =
                                                  o.transporterId;
                                              _selectedDriverName = o.driverName;
                                            });
                                          },
                                          showCheckmark: false,
                                          backgroundColor: Colors.white,
                                          selectedColor:
                                              const Color(0xFFE8F5EE),
                                          side: BorderSide(
                                            color: selected
                                                ? const Color(0xFF1D7F5A)
                                                : const Color(0xFFD1D5DB),
                                          ),
                                          labelStyle: TextStyle(
                                            color: selected
                                                ? const Color(0xFF1D7F5A)
                                                : const Color(0xFF374151),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                          ),
                          if ((_selectedDriverName ?? '').isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _pill(
                              l10n.tf('task_sheet_selected_driver', {
                                'name': _selectedDriverName!,
                                'id': _selectedTransporterId!,
                              }),
                              borderColor: const Color(0xFF1D7F5A),
                              textColor: const Color(0xFF1D7F5A),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.t('task_sheet_response_type'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.t('task_sheet_response_type_help'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  responseCardsCompact
                      ? Column(
                          children: [
                            _responseTypeCard(
                              label: l10n.t('task_sheet_response_standard'),
                              description: l10n.t(
                                'task_sheet_response_standard_help',
                              ),
                              icon: Icons.task_alt_rounded,
                              selected: _taskKind == _TaskComposerKind.standard,
                              onTap: () =>
                                  _setTaskKind(_TaskComposerKind.standard),
                            ),
                            const SizedBox(height: 10),
                            _responseTypeCard(
                              label: l10n.t('task_sheet_response_feedback_text'),
                              description: l10n.t(
                                'task_sheet_response_feedback_text_help',
                              ),
                              icon: Icons.edit_note_rounded,
                              selected:
                                  _taskKind == _TaskComposerKind.feedbackText,
                              onTap: () =>
                                  _setTaskKind(_TaskComposerKind.feedbackText),
                            ),
                            const SizedBox(height: 10),
                            _responseTypeCard(
                              label: l10n.t(
                                'task_sheet_response_feedback_choice',
                              ),
                              description: l10n.t(
                                'task_sheet_response_feedback_choice_help',
                              ),
                              icon: Icons.checklist_rounded,
                              selected:
                                  _taskKind == _TaskComposerKind.feedbackChoice,
                              onTap: () => _setTaskKind(
                                _TaskComposerKind.feedbackChoice,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: _responseTypeCard(
                                label: l10n.t('task_sheet_response_standard'),
                                description: l10n.t(
                                  'task_sheet_response_standard_help',
                                ),
                                icon: Icons.task_alt_rounded,
                                selected:
                                    _taskKind == _TaskComposerKind.standard,
                                onTap: () =>
                                    _setTaskKind(_TaskComposerKind.standard),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _responseTypeCard(
                                label: l10n.t(
                                  'task_sheet_response_feedback_text',
                                ),
                                description: l10n.t(
                                  'task_sheet_response_feedback_text_help',
                                ),
                                icon: Icons.edit_note_rounded,
                                selected:
                                    _taskKind == _TaskComposerKind.feedbackText,
                                onTap: () => _setTaskKind(
                                  _TaskComposerKind.feedbackText,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _responseTypeCard(
                                label: l10n.t(
                                  'task_sheet_response_feedback_choice',
                                ),
                                description: l10n.t(
                                  'task_sheet_response_feedback_choice_help',
                                ),
                                icon: Icons.checklist_rounded,
                                selected:
                                    _taskKind ==
                                    _TaskComposerKind.feedbackChoice,
                                onTap: () => _setTaskKind(
                                  _TaskComposerKind.feedbackChoice,
                                ),
                              ),
                            ),
                          ],
                        ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _titleCtrl,
                    decoration: _pillField(
                      hint: l10n.t('task_sheet_title_hint'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: detailsHeight,
                    child: TextField(
                      controller: _descCtrl,
                      minLines: null,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: _pillField(
                        hint: l10n.t('task_sheet_details_hint'),
                      ),
                    ),
                  ),
                  if (_taskKind == _TaskComposerKind.feedbackChoice) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  l10n.t('task_sheet_feedback_options_title'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _feedbackOptionCtrls.length >= 6
                                    ? null
                                    : _addFeedbackOption,
                                icon: const Icon(Icons.add_rounded, size: 18),
                                label: Text(
                                  l10n.t('task_sheet_feedback_add_option'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.t('task_sheet_feedback_options_hint'),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 260),
                            child: SingleChildScrollView(
                              child: Column(
                                children: List.generate(
                                  _feedbackOptionCtrls.length,
                                  (index) {
                                    final ctrl = _feedbackOptionCtrls[index];
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        bottom:
                                            index ==
                                                _feedbackOptionCtrls.length - 1
                                            ? 0
                                            : 10,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 28,
                                            height: 28,
                                            margin: const EdgeInsets.only(
                                              top: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE8F5EE),
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${index + 1}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  color: Color(0xFF1D7F5A),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: TextField(
                                              controller: ctrl,
                                              decoration: _pillField(
                                                hint: l10n.tf(
                                                  'task_sheet_feedback_option_label',
                                                  {'index': '${index + 1}'},
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            onPressed:
                                                _feedbackOptionCtrls.length <= 2
                                                ? null
                                                : () =>
                                                      _removeFeedbackOption(
                                                        index,
                                                      ),
                                            icon: const Icon(
                                              Icons.close_rounded,
                                            ),
                                            tooltip: l10n.t(
                                              'task_sheet_feedback_remove_option',
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      height: 44,
                      width: 220,
                      child: ElevatedButton(
                        onPressed: _creating ? null : _createTask,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1D7F5A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: _creating
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                l10n.t('task_sheet_publish'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  letterSpacing: 0.2,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard() {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history, color: Color(0xFF1D7F5A)),
              const SizedBox(width: 10),
              Text(
                l10n.t('task_sheet_history'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(child: _buildTaskList()),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    final l10n = AppLocalizations.of(context);
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _tasksCol().orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              l10n.tf('task_sheet_error_generic', {
                'error': '${snapshot.error}',
              }),
            ),
          );
        }

        final tasks = (snapshot.data?.docs ?? const [])
            .map(TaskSheetTask.fromDoc)
            .toList();
        final taskItems = _groupTaskItemsForAdmin(tasks);

        if (tasks.isEmpty) {
          return Center(
            child: Text(
              l10n.t('task_sheet_no_tasks'),
              style: const TextStyle(color: Colors.black54),
            ),
          );
        }

        return ListView.separated(
          itemCount: taskItems.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final item = taskItems[i];
            if (item.isGroup) {
              return _buildGroupTaskCard(
                l10n: l10n,
                groupedTasks: item.tasks,
              );
            }
            if (item.isGroup) {
              final groupedTasks = item.tasks;
              final first = groupedTasks.first;
              final pendingCount = groupedTasks
                  .where((t) => t.status == DriverTaskStatus.pending)
                  .length;
              final inProgressCount = groupedTasks
                  .where((t) => t.status == DriverTaskStatus.inProgress)
                  .length;
              final completedCount = groupedTasks
                  .where((t) => t.status == DriverTaskStatus.completed)
                  .length;

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 560;

                    final content = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.tf('task_sheet_everyone_title', {
                            'title': first.title,
                          }),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(first.createdAt),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _taskKindLabel(first),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF1D7F5A),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          first.description.isEmpty ? '—' : first.description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF4B5563),
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _statusActionPill(
                              label: l10n.t('driver_tasks_status_pending'),
                              count: pendingCount,
                              textColor: const Color(0xFF6B7280),
                              borderColor: const Color(0xFFD1D5DB),
                              onTap: () => _openDriversByStatusDialog(
                                taskTitle: first.title,
                                statusLabel: l10n.t(
                                  'driver_tasks_status_pending',
                                ),
                                drivers: groupedTasks
                                    .where(
                                      (t) =>
                                          t.status == DriverTaskStatus.pending,
                                    )
                                    .toList(),
                              ),
                            ),
                            _statusActionPill(
                              label: l10n.t('driver_tasks_status_in_progress'),
                              count: inProgressCount,
                              textColor: const Color(0xFFE9741A),
                              borderColor: const Color(0xFFE9741A),
                              onTap: () => _openDriversByStatusDialog(
                                taskTitle: first.title,
                                statusLabel: l10n.t(
                                  'driver_tasks_status_in_progress',
                                ),
                                drivers: groupedTasks
                                    .where(
                                      (t) =>
                                          t.status ==
                                          DriverTaskStatus.inProgress,
                                    )
                                    .toList(),
                              ),
                            ),
                            _statusActionPill(
                              label: l10n.t('driver_tasks_status_completed'),
                              count: completedCount,
                              textColor: const Color(0xFF1D7F5A),
                              borderColor: const Color(0xFF1D7F5A),
                              onTap: () => _openDriversByStatusDialog(
                                taskTitle: first.title,
                                statusLabel: l10n.t(
                                  'driver_tasks_status_completed',
                                ),
                                drivers: groupedTasks
                                    .where(
                                      (t) =>
                                          t.status ==
                                          DriverTaskStatus.completed,
                                    )
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );

                    final meta = Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          l10n.tf('task_sheet_drivers_count', {
                            'count': '${groupedTasks.length}',
                          }),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                        IconButton(
                          tooltip: l10n.t(
                            'task_sheet_delete_for_everyone_tooltip',
                          ),
                          onPressed: () => _confirmDeleteTaskBatch(
                            first.title,
                            groupedTasks,
                          ),
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Color(0xFFE11D48),
                          ),
                        ),
                      ],
                    );

                    if (compact) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFFE5E7EB),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.groups_2_outlined,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: content),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [meta],
                          ),
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: const Icon(
                            Icons.groups_2_outlined,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: content),
                        const SizedBox(width: 10),
                        meta,
                      ],
                    );
                  },
                ),
              );
            }

            final task = item.tasks.first;
            final statusColor = _statusColor(task.status);
            final statusLabel = _statusLabel(task.status);

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 560;

                  final content = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${task.assignedDriverName} | ${task.title}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${task.assignedTransporterId} | ${_formatDate(task.createdAt)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _taskKindLabel(task),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF1D7F5A),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        task.description.isEmpty ? '—' : task.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4B5563),
                          height: 1.25,
                        ),
                      ),
                      if (task.feedbackResponse.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          '${l10n.t('task_sheet_feedback_response_label')}: ${task.feedbackResponse}',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF1D7F5A),
                            height: 1.3,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  );

                  final meta = Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: statusColor, width: 1.4),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        task.completedConfirmed
                            ? l10n.t('task_sheet_confirmed')
                            : l10n.t('task_sheet_awaiting_confirm'),
                        style: TextStyle(
                          fontSize: 10,
                          color: task.completedConfirmed
                              ? const Color(0xFF1D7F5A)
                              : const Color(0xFFE9741A),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.t('task_sheet_delete_task_tooltip'),
                        onPressed: () => _confirmDeleteTask(task),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Color(0xFFE11D48),
                        ),
                      ),
                    ],
                  );

                  if (compact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                ),
                              ),
                              child: const Icon(
                                Icons.person_outline,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: content),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [meta],
                        ),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: content),
                      const SizedBox(width: 10),
                      meta,
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGroupTaskCard({
    required AppLocalizations l10n,
    required List<TaskSheetTask> groupedTasks,
  }) {
    final first = groupedTasks.first;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _driversCol().snapshots(),
      builder: (context, driversSnapshot) {
        final activeTransporterIds = (driversSnapshot.data?.docs ?? const [])
            .where((d) => isDriverWorking(d.data()))
            .map(
              (d) => (d.data()['transporterId'] ?? d.id)
                  .toString()
                  .trim()
                  .toUpperCase(),
            )
            .where((id) => id.isNotEmpty)
            .toSet();
        final activeGroupedTasks = groupedTasks
            .where(
              (t) => activeTransporterIds.contains(
                t.assignedTransporterId.trim().toUpperCase(),
              ),
            )
            .toList(growable: false);
        final pendingCount = activeGroupedTasks
            .where((t) => t.status == DriverTaskStatus.pending)
            .length;
        final inProgressCount = activeGroupedTasks
            .where((t) => t.status == DriverTaskStatus.inProgress)
            .length;
        final completedCount = activeGroupedTasks
            .where((t) => t.status == DriverTaskStatus.completed)
            .length;
        final feedbackSummary = first.isFeedbackChoice
            ? _feedbackChoiceSummary(activeGroupedTasks)
            : null;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 560;

              final content = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.tf('task_sheet_everyone_title', {
                      'title': first.title,
                    }),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(first.createdAt),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _taskKindLabel(first),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF1D7F5A),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    first.description.isEmpty ? '-' : first.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF4B5563),
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildGroupTaskPills(
                    l10n: l10n,
                    firstTask: first,
                    activeGroupedTasks: activeGroupedTasks,
                    pendingCount: pendingCount,
                    inProgressCount: inProgressCount,
                    completedCount: completedCount,
                    feedbackSummary: feedbackSummary,
                  ),
                ],
              );

              final meta = Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    l10n.tf('task_sheet_drivers_count', {
                      'count': '${activeGroupedTasks.length}',
                    }),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.t('task_sheet_delete_for_everyone_tooltip'),
                    onPressed: () => _confirmDeleteTaskBatch(
                      first.title,
                      groupedTasks,
                    ),
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Color(0xFFE11D48),
                    ),
                  ),
                ],
              );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                            ),
                          ),
                          child: const Icon(
                            Icons.groups_2_outlined,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: content),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [meta],
                    ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: const Icon(
                      Icons.groups_2_outlined,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: content),
                  const SizedBox(width: 10),
                  meta,
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildGroupTaskPills({
    required AppLocalizations l10n,
    required TaskSheetTask firstTask,
    required List<TaskSheetTask> activeGroupedTasks,
    required int pendingCount,
    required int inProgressCount,
    required int completedCount,
    required _FeedbackChoiceSummary? feedbackSummary,
  }) {
    if (firstTask.isFeedbackChoice && feedbackSummary != null) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ...feedbackSummary.optionOrder.map(
            (option) => _statusActionPill(
              label: option,
              count: feedbackSummary.countForOption(option),
              textColor: const Color(0xFF1D7F5A),
              borderColor: const Color(0xFF1D7F5A),
              onTap: () => _openFeedbackChoiceBreakdownDialog(
                taskTitle: firstTask.title,
                focusLabel: option,
                rows:
                    feedbackSummary.tasksByOption[option] ??
                    const <TaskSheetTask>[],
                summary: feedbackSummary,
              ),
            ),
          ),
          _statusActionPill(
            label: l10n.t('driver_tasks_status_pending'),
            count: feedbackSummary.pendingTasks.length,
            textColor: const Color(0xFF6B7280),
            borderColor: const Color(0xFFD1D5DB),
            onTap: () => _openFeedbackChoiceBreakdownDialog(
              taskTitle: firstTask.title,
              focusLabel: l10n.t('driver_tasks_status_pending'),
              rows: feedbackSummary.pendingTasks,
              summary: feedbackSummary,
            ),
          ),
        ],
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _statusActionPill(
          label: l10n.t('driver_tasks_status_pending'),
          count: pendingCount,
          textColor: const Color(0xFF6B7280),
          borderColor: const Color(0xFFD1D5DB),
          onTap: () => _openDriversByStatusDialog(
            taskTitle: firstTask.title,
            statusLabel: l10n.t('driver_tasks_status_pending'),
            drivers: activeGroupedTasks
                .where((t) => t.status == DriverTaskStatus.pending)
                .toList(),
          ),
        ),
        _statusActionPill(
          label: l10n.t('driver_tasks_status_in_progress'),
          count: inProgressCount,
          textColor: const Color(0xFFE9741A),
          borderColor: const Color(0xFFE9741A),
          onTap: () => _openDriversByStatusDialog(
            taskTitle: firstTask.title,
            statusLabel: l10n.t('driver_tasks_status_in_progress'),
            drivers: activeGroupedTasks
                .where((t) => t.status == DriverTaskStatus.inProgress)
                .toList(),
          ),
        ),
        _statusActionPill(
          label: l10n.t('driver_tasks_status_completed'),
          count: completedCount,
          textColor: const Color(0xFF1D7F5A),
          borderColor: const Color(0xFF1D7F5A),
          onTap: () => _openDriversByStatusDialog(
            taskTitle: firstTask.title,
            statusLabel: l10n.t('driver_tasks_status_completed'),
            drivers: activeGroupedTasks
                .where((t) => t.status == DriverTaskStatus.completed)
                .toList(),
          ),
        ),
      ],
    );
  }

  Future<void> _openFeedbackChoiceBreakdownDialog({
    required String taskTitle,
    required String focusLabel,
    required List<TaskSheetTask> rows,
    required _FeedbackChoiceSummary summary,
  }) async {
    final l10n = AppLocalizations.of(context);
    final sortedRows = [...rows]..sort((a, b) {
      final aLabel = a.assignedDriverName.isEmpty
          ? a.assignedTransporterId
          : a.assignedDriverName;
      final bLabel = b.assignedDriverName.isEmpty
          ? b.assignedTransporterId
          : b.assignedDriverName;
      return aLabel.toLowerCase().compareTo(bLabel.toLowerCase());
    });

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 560,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.tf('task_sheet_everyone_title', {'title': taskTitle}),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$focusLabel: ${sortedRows.length}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4B5563),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...summary.optionOrder.map(
                      (option) => _pill(
                        '$option: ${summary.countForOption(option)}',
                        textColor: const Color(0xFF1D7F5A),
                        borderColor: const Color(0xFF1D7F5A),
                      ),
                    ),
                    _pill(
                      '${l10n.t('driver_tasks_status_pending')}: ${summary.pendingTasks.length}',
                      textColor: const Color(0xFF6B7280),
                      borderColor: const Color(0xFFD1D5DB),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 10),
                SizedBox(
                  height: 360,
                  child: sortedRows.isEmpty
                      ? Center(
                          child: Text(
                            l10n.t('task_sheet_no_drivers_in_status'),
                            style: const TextStyle(color: Colors.black54),
                          ),
                        )
                      : ListView.separated(
                          itemCount: sortedRows.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final task = sortedRows[i];
                            final name = task.assignedDriverName.trim();
                            final id = task.assignedTransporterId.trim();
                            final label = name.isEmpty ? id : '$name ($id)';
                            final selectedOption =
                                task.feedbackSelectedOption.trim();
                            final choiceLabel = selectedOption.isEmpty
                                ? l10n.t('driver_tasks_status_pending')
                                : selectedOption;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    label,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    choiceLabel,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: selectedOption.isEmpty
                                          ? const Color(0xFF6B7280)
                                          : const Color(0xFF1D7F5A),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  if (task.feedbackResponse.isNotEmpty &&
                                      task.feedbackResponse !=
                                          selectedOption) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      '${l10n.t('task_sheet_feedback_response_label')}: ${task.feedbackResponse}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF1D7F5A),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(l10n.t('task_sheet_close')),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _pill(
    String text, {
    Color textColor = const Color(0xFF374151),
    Color borderColor = const Color(0xFFD1D5DB),
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _statusActionPill({
    required String label,
    required int count,
    required Color textColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Text(
          '$label: $count',
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Future<void> _openDriversByStatusDialog({
    required String taskTitle,
    required String statusLabel,
    required List<TaskSheetTask> drivers,
  }) async {
    final l10n = AppLocalizations.of(context);
    final rows = [...drivers]..sort((a, b) {
      final aLabel = a.assignedDriverName.isEmpty
          ? a.assignedTransporterId
          : a.assignedDriverName;
      final bLabel = b.assignedDriverName.isEmpty
          ? b.assignedTransporterId
          : b.assignedDriverName;
      return aLabel.toLowerCase().compareTo(bLabel.toLowerCase());
    });

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 520,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.tf('task_sheet_everyone_title', {'title': taskTitle}),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.tf('task_sheet_status_drivers_count', {
                    'status': statusLabel,
                    'count': '${rows.length}',
                  }),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4B5563),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 10),
                SizedBox(
                  height: 360,
                  child: rows.isEmpty
                      ? Center(
                          child: Text(
                            l10n.t('task_sheet_no_drivers_in_status'),
                            style: const TextStyle(color: Colors.black54),
                          ),
                        )
                      : ListView.separated(
                          itemCount: rows.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final task = rows[i];
                            final name = task.assignedDriverName.trim();
                            final id = task.assignedTransporterId.trim();
                            final label = name.isEmpty ? id : '$name ($id)';
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    label,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (task.feedbackResponse.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      '${l10n.t('task_sheet_feedback_response_label')}: ${task.feedbackResponse}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF1D7F5A),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(l10n.t('task_sheet_close')),
                  ),
                ),
              ],
            ),
          ),
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

  String _statusLabel(DriverTaskStatus status) {
    final l10n = AppLocalizations.of(context);
    switch (status) {
      case DriverTaskStatus.completed:
        return l10n.t('driver_tasks_status_completed');
      case DriverTaskStatus.inProgress:
        return l10n.t('driver_tasks_status_in_progress');
      case DriverTaskStatus.pending:
        return l10n.t('driver_tasks_status_pending');
    }
  }
}

class _DriverOption {
  final String transporterId;
  final String driverName;

  const _DriverOption({required this.transporterId, required this.driverName});
}

class _TaskListItem {
  final String? batchId;
  final List<TaskSheetTask> tasks;

  const _TaskListItem._({required this.batchId, required this.tasks});

  factory _TaskListItem.single(TaskSheetTask task) {
    return _TaskListItem._(batchId: null, tasks: [task]);
  }

  factory _TaskListItem.group({
    required String batchId,
    required List<TaskSheetTask> tasks,
  }) {
    return _TaskListItem._(batchId: batchId, tasks: tasks);
  }

  bool get isGroup => batchId != null;
}

