// lib/Screens/admin_dispatcher_center_page.dart
//
// Single entry point that merges:
//   • "Dispatcher Pill"  — contact info shown to drivers
//   • "Dispatcher Accounts" — sub-account logins with permissions
//   • "Aufgaben (TODO)" — smart, recurring per-dispatcher task list
//
// Replaces the two earlier menu items (`AppNav.dispatcherPill` and
// `AppNav.dispatchers`) with a single "Dispatcher Center".

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/dispatcher_task.dart';
import '../services/dispatcher_task_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_elevation.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/admin_scope.dart';
import '../widgets/pill_tab_bar.dart';
import 'admin_dispatcher_pill_page.dart';
import 'admin_dispatchers_page.dart';

class AdminDispatcherCenterPage extends StatelessWidget {
  const AdminDispatcherCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final adminUid = AdminScope.adminUidOf(context) ??
        FirebaseAuth.instance.currentUser?.uid;
    if (adminUid == null) {
      return const Center(child: Text('Bitte einloggen.'));
    }

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Builder(
              builder: (ctx) => PillTabBar(
                controller: DefaultTabController.of(ctx),
                tabs: const [
                  'Dispatcher (Kontakt)',
                  'Sub-Accounts',
                  'Aufgaben',
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                const AdminDispatcherPillPage(),
                const AdminDispatchersPage(),
                _DispatcherTasksTab(dspUid: adminUid),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Aufgaben tab — smart, recurring TODO list per dispatcher
// ════════════════════════════════════════════════════════════════════════════

class _DispatcherTasksTab extends StatefulWidget {
  final String dspUid;
  const _DispatcherTasksTab({required this.dspUid});

  @override
  State<_DispatcherTasksTab> createState() => _DispatcherTasksTabState();
}

class _DispatcherTasksTabState extends State<_DispatcherTasksTab> {
  final _repo = DispatcherTaskRepository();
  String? _filterDispatcher;

  Stream<List<String>> _dispatcherNamesStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.dspUid)
        .collection('settings')
        .doc('dispatcher_pill')
        .snapshots()
        .map((doc) {
      final raw = (doc.data() ?? const {})['dispatchers'];
      if (raw is! List) return const <String>[];
      final out = <String>[];
      for (final row in raw) {
        if (row is Map) {
          final n = (row['name'] ?? '').toString().trim();
          if (n.isNotEmpty) out.add(n);
        }
      }
      return out;
    });
  }

  Future<void> _openTaskDialog([DispatcherTask? existing]) async {
    final names = await _dispatcherNamesStream().first;
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => _TaskEditorDialog(
        repo: _repo,
        dspUid: widget.dspUid,
        existing: existing,
        dispatcherNames: names,
        initialDispatcher:
            existing?.dispatcherKey ?? _filterDispatcher,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF3F6F7),
      child: StreamBuilder<List<String>>(
        stream: _dispatcherNamesStream(),
        builder: (context, namesSnap) {
          final names = namesSnap.data ?? const <String>[];
          return StreamBuilder<List<DispatcherTask>>(
            stream: _repo.watch(widget.dspUid),
            builder: (context, tasksSnap) {
              if (tasksSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final tasks = tasksSnap.data ?? const <DispatcherTask>[];
              final filtered = _filterDispatcher == null
                  ? tasks
                  : tasks
                      .where((t) => t.dispatcherKey == _filterDispatcher)
                      .toList();
              filtered.sort((a, b) {
                // Done last; closest-due first; else newest first.
                final aDone = a.isDoneForNow;
                final bDone = b.isDoneForNow;
                if (aDone != bDone) return aDone ? 1 : -1;
                final ad = a.computedNextDue;
                final bd = b.computedNextDue;
                if (ad != null && bd != null) return ad.compareTo(bd);
                if (ad != null) return -1;
                if (bd != null) return 1;
                return 0;
              });

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Aufgaben',
                          style: AppTypography.title2.copyWith(
                            color: AppColors.codriverGraphite,
                          ),
                        ),
                        const Spacer(),
                        FilledButton.icon(
                          onPressed: names.isEmpty
                              ? null
                              : () => _openTaskDialog(),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Neue Aufgabe'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Wiederkehrende Aufgaben pro Dispatcher. Kategorien zur Übersicht.',
                      style: AppTypography.footnote.copyWith(
                        color: AppColors.labelSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (names.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border:
                              Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: const Text(
                          'Lege zuerst Dispatcher im Tab "Dispatcher (Kontakt)" '
                          'oder "Sub-Accounts" an, dann kannst du hier Aufgaben '
                          'zuweisen.',
                        ),
                      )
                    else
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          ChoiceChip(
                            label: const Text('Alle'),
                            selected: _filterDispatcher == null,
                            onSelected: (_) =>
                                setState(() => _filterDispatcher = null),
                          ),
                          for (final n in names)
                            ChoiceChip(
                              label: Text(n),
                              selected: _filterDispatcher == n,
                              onSelected: (_) => setState(
                                () => _filterDispatcher = n,
                              ),
                            ),
                        ],
                      ),
                    const SizedBox(height: 12),
                    if (filtered.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text(
                            'Keine Aufgaben.',
                            style: AppTypography.footnote.copyWith(
                              color: AppColors.labelSecondaryLight,
                            ),
                          ),
                        ),
                      )
                    else
                      for (final task in filtered)
                        _TaskRow(
                          task: task,
                          onToggle: () async {
                            if (task.lastCompletedAt == null) {
                              await _repo.markComplete(
                                dspUid: widget.dspUid,
                                taskId: task.id,
                              );
                            } else {
                              await _repo.markIncomplete(
                                dspUid: widget.dspUid,
                                taskId: task.id,
                              );
                            }
                          },
                          onEdit: () => _openTaskDialog(task),
                          onDelete: () async {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (c) => AlertDialog(
                                title: const Text('Aufgabe löschen?'),
                                content: Text('"${task.title}" entfernen?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(c).pop(false),
                                    child: const Text('Abbrechen'),
                                  ),
                                  FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppColors.error,
                                    ),
                                    onPressed: () =>
                                        Navigator.of(c).pop(true),
                                    child: const Text('Löschen'),
                                  ),
                                ],
                              ),
                            );
                            if (ok == true) {
                              await _repo.delete(
                                dspUid: widget.dspUid,
                                taskId: task.id,
                              );
                            }
                          },
                        ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  final DispatcherTask task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _TaskRow({
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final done = task.isDoneForNow;
    final due = task.computedNextDue;
    Color recurrenceColor() {
      switch (task.recurrence) {
        case TaskRecurrence.daily:
          return const Color(0xFF0A84FF);
        case TaskRecurrence.weekly:
          return AppColors.codriverGreen;
        case TaskRecurrence.monthly:
          return const Color(0xFF7B5BFF);
        case TaskRecurrence.once:
          return AppColors.labelSecondaryLight;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: AppElevation.level1,
      ),
      child: Row(
        children: [
          Checkbox.adaptive(
            value: done,
            onChanged: (_) => onToggle(),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: AppTypography.subheadline.copyWith(
                    color: AppColors.codriverGraphite,
                    fontWeight: FontWeight.w700,
                    decoration: done ? TextDecoration.lineThrough : null,
                  ),
                ),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _MiniChip(
                      text: task.dispatcherKey,
                      color: AppColors.codriverDeep,
                      icon: Icons.person_rounded,
                    ),
                    _MiniChip(
                      text: task.recurrence.label,
                      color: recurrenceColor(),
                      icon: Icons.repeat_rounded,
                    ),
                    if (task.category.isNotEmpty)
                      _MiniChip(
                        text: task.category,
                        color: AppColors.labelSecondaryLight,
                        icon: Icons.label_outline_rounded,
                      ),
                    if (due != null)
                      _MiniChip(
                        text: 'fällig '
                            '${due.day.toString().padLeft(2, '0')}.'
                            '${due.month.toString().padLeft(2, '0')}.'
                            '${due.year}',
                        color: done
                            ? AppColors.success
                            : (due.isBefore(DateTime.now())
                                ? AppColors.error
                                : AppColors.codriverGreen),
                        icon: Icons.event_rounded,
                      ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Bearbeiten',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_rounded),
          ),
          IconButton(
            tooltip: 'Löschen',
            onPressed: onDelete,
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;
  const _MiniChip({
    required this.text,
    required this.color,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            text,
            style: AppTypography.caption2.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Editor dialog ──────────────────────────────────────────────────

class _TaskEditorDialog extends StatefulWidget {
  final DispatcherTaskRepository repo;
  final String dspUid;
  final DispatcherTask? existing;
  final List<String> dispatcherNames;
  final String? initialDispatcher;

  const _TaskEditorDialog({
    required this.repo,
    required this.dspUid,
    required this.dispatcherNames,
    this.existing,
    this.initialDispatcher,
  });

  @override
  State<_TaskEditorDialog> createState() => _TaskEditorDialogState();
}

class _TaskEditorDialogState extends State<_TaskEditorDialog> {
  late TextEditingController _titleCtrl;
  late TextEditingController _categoryCtrl;
  late TextEditingController _noteCtrl;
  late String? _dispatcher;
  late TaskRecurrence _recurrence;
  DateTime? _dueDate;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final ex = widget.existing;
    _titleCtrl = TextEditingController(text: ex?.title ?? '');
    _categoryCtrl = TextEditingController(text: ex?.category ?? '');
    _noteCtrl = TextEditingController(text: ex?.note ?? '');
    _dispatcher = ex?.dispatcherKey ??
        widget.initialDispatcher ??
        (widget.dispatcherNames.isNotEmpty
            ? widget.dispatcherNames.first
            : null);
    _recurrence = ex?.recurrence ?? TaskRecurrence.weekly;
    _dueDate = ex?.dueDate;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _categoryCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final init = _dueDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: init,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty || _dispatcher == null) {
      setState(() => _error = 'Titel und Dispatcher pflichtfeld.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      if (widget.existing == null) {
        await widget.repo.create(
          dspUid: widget.dspUid,
          dispatcherKey: _dispatcher!,
          title: title,
          category: _categoryCtrl.text.trim(),
          recurrence: _recurrence,
          dueDate: _dueDate,
          note: _noteCtrl.text.trim(),
        );
      } else {
        await widget.repo.update(
          dspUid: widget.dspUid,
          taskId: widget.existing!.id,
          title: title,
          category: _categoryCtrl.text.trim(),
          recurrence: _recurrence,
          dueDate: _dueDate,
          clearDueDate: _dueDate == null,
          note: _noteCtrl.text.trim(),
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _saving = false;
        _error = '$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'Neue Aufgabe' : 'Aufgabe bearbeiten'),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _dispatcher,
              decoration: const InputDecoration(labelText: 'Dispatcher'),
              items: [
                for (final n in widget.dispatcherNames)
                  DropdownMenuItem(value: n, child: Text(n)),
              ],
              onChanged: (v) => setState(() => _dispatcher = v),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Aufgabe'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _categoryCtrl,
              decoration: const InputDecoration(
                labelText: 'Kategorie',
                hintText: 'z.B. Morgenrunde, Wartung, …',
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<TaskRecurrence>(
              initialValue: _recurrence,
              decoration: const InputDecoration(labelText: 'Wiederholung'),
              items: [
                for (final r in TaskRecurrence.values)
                  DropdownMenuItem(value: r, child: Text(r.label)),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _recurrence = v);
              },
            ),
            const SizedBox(height: 8),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: _pickDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: _recurrence == TaskRecurrence.once
                      ? 'Termin (optional)'
                      : 'Erstmals fällig (optional)',
                  suffixIcon: _dueDate != null
                      ? IconButton(
                          onPressed: () => setState(() => _dueDate = null),
                          icon: const Icon(Icons.close_rounded),
                        )
                      : const Icon(Icons.event_rounded),
                ),
                child: Text(
                  _dueDate == null
                      ? '— Datum wählen —'
                      : '${_dueDate!.day.toString().padLeft(2, '0')}.'
                          '${_dueDate!.month.toString().padLeft(2, '0')}.'
                          '${_dueDate!.year}',
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteCtrl,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Notiz'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(color: AppColors.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Speichern'),
        ),
      ],
    );
  }
}
