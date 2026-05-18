// lib/Screens/admin_recruiting_form_builder_page.dart
//
// Form-builder MVP: each DSP can extend the standard recruiting form
// with their own follow-up questions (one Custom step at the end of
// the public form). Questions support short/long text, dropdown,
// yes/no and date. Persisted to
//   users/{adminUid}/settings/recruiting_form_{channel}
// and surfaced live to the public form.

import 'package:flutter/material.dart';

import '../models/recruiting_application.dart';
import '../models/recruiting_form_config.dart';
import '../services/recruiting_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/co_button.dart';
import '../widgets/pill_tab_bar.dart';

class AdminRecruitingFormBuilderPage extends StatefulWidget {
  const AdminRecruitingFormBuilderPage({
    super.key,
    required this.adminUid,
  });
  final String adminUid;

  @override
  State<AdminRecruitingFormBuilderPage> createState() =>
      _AdminRecruitingFormBuilderPageState();
}

class _AdminRecruitingFormBuilderPageState
    extends State<AdminRecruitingFormBuilderPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _repo = RecruitingRepository();

  /// Working set, keyed by channel — edits live here until Save.
  final Map<RecruitingChannel, List<RecruitingCustomField>> _draft = {
    RecruitingChannel.local: <RecruitingCustomField>[],
    RecruitingChannel.visa: <RecruitingCustomField>[],
  };
  final Map<RecruitingChannel, bool> _loaded = {
    RecruitingChannel.local: false,
    RecruitingChannel.visa: false,
  };
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _load(RecruitingChannel.local);
    _load(RecruitingChannel.visa);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load(RecruitingChannel c) async {
    final cfg = await _repo.fetchFormConfig(
      adminUid: widget.adminUid,
      channel: c,
    );
    if (!mounted) return;
    setState(() {
      _draft[c] = List<RecruitingCustomField>.from(cfg.fields);
      _loaded[c] = true;
    });
  }

  Future<void> _save(RecruitingChannel c) async {
    setState(() => _busy = true);
    try {
      await _repo.saveFormConfig(
        adminUid: widget.adminUid,
        channel: c,
        fields: _draft[c]!,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.codriverDeep,
          content: Text(
            'Saved · ${_draft[c]!.length} custom questions',
            style: const TextStyle(color: Colors.white),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _addOrEdit({
    required RecruitingChannel c,
    RecruitingCustomField? existing,
  }) async {
    final edited = await showDialog<RecruitingCustomField>(
      context: context,
      builder: (_) => _FieldEditorDialog(existing: existing),
    );
    if (edited == null) return;
    setState(() {
      final list = _draft[c]!;
      if (existing == null) {
        list.add(edited);
      } else {
        final i = list.indexWhere((f) => f.id == existing.id);
        if (i >= 0) list[i] = edited;
      }
    });
  }

  void _remove(RecruitingChannel c, int index) {
    setState(() => _draft[c]!.removeAt(index));
  }

  void _move(RecruitingChannel c, int index, int delta) {
    final list = _draft[c]!;
    final next = index + delta;
    if (next < 0 || next >= list.length) return;
    setState(() {
      final f = list.removeAt(index);
      list.insert(next, f);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: const Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB)),
        ),
        title: Text(
          'Form builder',
          style: AppTypography.title3.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Intro(),
                const SizedBox(height: 14),
                PillTabBar(
                  controller: _tabs,
                  tabs: const ['Local / EU', 'Non-EU / Visa'],
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: TabBarView(
                    controller: _tabs,
                    children: [
                      _channelTab(RecruitingChannel.local),
                      _channelTab(RecruitingChannel.visa),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _channelTab(RecruitingChannel c) {
    if (_loaded[c] != true) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor:
              AlwaysStoppedAnimation<Color>(AppColors.codriverGreen),
        ),
      );
    }
    final fields = _draft[c]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            CoButton(
              onPressed: () => _addOrEdit(c: c),
              label: 'Add question',
              icon: Icons.add_rounded,
            ),
            const Spacer(),
            CoButton(
              onPressed: _busy ? null : () => _save(c),
              label: 'Save',
              icon: Icons.check_rounded,
              busy: _busy,
              variant: CoButtonVariant.primary,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Expanded(
          child: fields.isEmpty
              ? _EmptyState(onAdd: () => _addOrEdit(c: c))
              : ListView.separated(
                  itemCount: fields.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 8),
                  itemBuilder: (ctx, i) => _FieldRow(
                    field: fields[i],
                    onEdit: () =>
                        _addOrEdit(c: c, existing: fields[i]),
                    onDelete: () => _remove(c, i),
                    onMoveUp: i == 0 ? null : () => _move(c, i, -1),
                    onMoveDown: i == fields.length - 1
                        ? null
                        : () => _move(c, i, 1),
                  ),
                ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────
//   Intro banner
// ──────────────────────────────────────────────────────────────────

class _Intro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.green50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.codriverGreen.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.tune_rounded,
            color: AppColors.codriverDeep,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add your own follow-up questions',
                  style: AppTypography.subheadline.copyWith(
                    color: AppColors.codriverDeep,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Custom questions appear at the end of the public '
                  'form as one extra step. Set per channel.',
                  style: AppTypography.caption2.copyWith(
                    color:
                        AppColors.codriverDeep.withValues(alpha: 0.75),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.dynamic_form_rounded,
            size: 44,
            color: AppColors.labelSecondaryLight,
          ),
          const SizedBox(height: 12),
          Text(
            'No custom questions yet',
            style: AppTypography.title3.copyWith(
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'The public form will only show the standard fields.',
            style: AppTypography.body.copyWith(
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 14),
          CoButton(
            onPressed: onAdd,
            label: 'Add the first question',
            icon: Icons.add_rounded,
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
//   Field row
// ──────────────────────────────────────────────────────────────────

class _FieldRow extends StatelessWidget {
  const _FieldRow({
    required this.field,
    required this.onEdit,
    required this.onDelete,
    required this.onMoveUp,
    required this.onMoveDown,
  });
  final RecruitingCustomField field;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.green50,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(
                  _iconFor(field.type),
                  size: 18,
                  color: AppColors.codriverDeep,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            field.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.subheadline.copyWith(
                              color: const Color(0xFF111827),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (field.required) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'REQUIRED',
                              style: TextStyle(
                                color: Color(0xFFB91C1C),
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      field.type.label +
                          (field.type == RecruitingFieldType.dropdown &&
                                  field.options.isNotEmpty
                              ? ' · ${field.options.length} options'
                              : ''),
                      style: AppTypography.caption2.copyWith(
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onMoveUp,
                icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                color: const Color(0xFF6B7280),
              ),
              IconButton(
                onPressed: onMoveDown,
                icon: const Icon(
                  Icons.arrow_downward_rounded,
                  size: 18,
                ),
                color: const Color(0xFF6B7280),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                color: const Color(0xFFB91C1C),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(RecruitingFieldType t) {
    switch (t) {
      case RecruitingFieldType.shortText:
        return Icons.short_text_rounded;
      case RecruitingFieldType.longText:
        return Icons.notes_rounded;
      case RecruitingFieldType.dropdown:
        return Icons.arrow_drop_down_circle_outlined;
      case RecruitingFieldType.yesNo:
        return Icons.toggle_on_outlined;
      case RecruitingFieldType.date:
        return Icons.calendar_today_rounded;
    }
  }
}

// ──────────────────────────────────────────────────────────────────
//   Field editor dialog
// ──────────────────────────────────────────────────────────────────

class _FieldEditorDialog extends StatefulWidget {
  const _FieldEditorDialog({this.existing});
  final RecruitingCustomField? existing;

  @override
  State<_FieldEditorDialog> createState() => _FieldEditorDialogState();
}

class _FieldEditorDialogState extends State<_FieldEditorDialog> {
  late final TextEditingController _label;
  late final TextEditingController _optionsCtrl;
  late RecruitingFieldType _type;
  late bool _required;

  @override
  void initState() {
    super.initState();
    _label = TextEditingController(text: widget.existing?.label ?? '');
    _optionsCtrl = TextEditingController(
      text: widget.existing?.options.join('\n') ?? '',
    );
    _type = widget.existing?.type ?? RecruitingFieldType.shortText;
    _required = widget.existing?.required ?? false;
  }

  @override
  void dispose() {
    _label.dispose();
    _optionsCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final label = _label.text.trim();
    if (label.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Question label is required.')),
      );
      return;
    }
    final options = _type == RecruitingFieldType.dropdown
        ? _optionsCtrl.text
            .split('\n')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList()
        : <String>[];
    final id = widget.existing?.id ??
        DateTime.now().millisecondsSinceEpoch.toString();
    final field = RecruitingCustomField(
      id: id,
      label: label,
      type: _type,
      options: options,
      required: _required,
    );
    Navigator.of(context).pop(field);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 620),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.existing == null
                    ? 'New question'
                    : 'Edit question',
                style: AppTypography.title3.copyWith(
                  color: const Color(0xFF111827),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _label,
                decoration: InputDecoration(
                  labelText: 'Question label',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final t in RecruitingFieldType.values)
                    ChoiceChip(
                      label: Text(t.label),
                      selected: _type == t,
                      onSelected: (_) => setState(() => _type = t),
                      selectedColor: AppColors.codriverGreen,
                      backgroundColor: const Color(0xFFF9FAFB),
                      side: BorderSide(
                        color: _type == t
                            ? AppColors.codriverGreen
                            : const Color(0xFFE5E7EB),
                      ),
                      labelStyle: AppTypography.caption1.copyWith(
                        color: _type == t
                            ? Colors.white
                            : const Color(0xFF111827),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
              if (_type == RecruitingFieldType.dropdown) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _optionsCtrl,
                  minLines: 3,
                  maxLines: 6,
                  decoration: InputDecoration(
                    labelText: 'Options (one per line)',
                    helperText: 'e.g. Option 1\\nOption 2\\nOption 3',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              SwitchListTile.adaptive(
                value: _required,
                onChanged: (v) => setState(() => _required = v),
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Required',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: const Text(
                  'Applicant cannot submit without answering.',
                  style: TextStyle(fontSize: 12),
                ),
                activeThumbColor: AppColors.codriverGreen,
              ),
              const Spacer(),
              Row(
                children: [
                  const Spacer(),
                  CoButton(
                    onPressed: () => Navigator.of(context).pop(),
                    label: 'Cancel',
                    variant: CoButtonVariant.quiet,
                  ),
                  const SizedBox(width: 6),
                  CoButton(
                    onPressed: _submit,
                    label:
                        widget.existing == null ? 'Add' : 'Save',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
