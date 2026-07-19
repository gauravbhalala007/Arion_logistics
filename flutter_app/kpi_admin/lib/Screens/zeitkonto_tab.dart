// lib/Screens/zeitkonto_tab.dart
//
// "Zeitkonto" tab inside the Zeiten-und-Abwesenheiten admin page.
// Admin uploads the monthly payroll xlsx from the external time-
// tracking tool; the page reads per-employee Soll/Ist/Überstunden
// rows back out and lets the admin track which overtime has already
// been paid out.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/time_account.dart';
import '../services/time_account_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_elevation.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class ZeitkontoTab extends StatefulWidget {
  final String dspUid;
  const ZeitkontoTab({super.key, required this.dspUid});

  @override
  State<ZeitkontoTab> createState() => _ZeitkontoTabState();
}

class _ZeitkontoTabState extends State<ZeitkontoTab> {
  final _repo = TimeAccountRepository();
  bool _uploading = false;
  String? _uploadError;

  Future<void> _pickAndImport() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final f = result.files.first;
    if (f.bytes == null) return;

    setState(() {
      _uploading = true;
      _uploadError = null;
    });

    try {
      final parsed = await TimeAccountRepository.parseExcel(
        filename: f.name,
        bytes: f.bytes!,
      );
      if (parsed.rows.isEmpty) {
        setState(() {
          _uploading = false;
          _uploadError = 'Keine Zeilen erkannt.';
        });
        return;
      }
      await _repo.commitImport(
        dspUid: widget.dspUid,
        filename: f.name,
        parsed: parsed,
        bytes: f.bytes,
      );
      if (!mounted) return;
      setState(() => _uploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${parsed.rows.length} Zeilen importiert für '
            '${_formatMonth(parsed.periodStart)}.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _uploading = false;
        _uploadError = '$e';
      });
    }
  }

  Future<void> _showAddPaidHoursDialog(
    String employeeId,
    String employeeName,
    double openOvertime,
  ) async {
    final ctrl = TextEditingController(text: openOvertime.toStringAsFixed(1));
    final noteCtrl = TextEditingController();
    DateTime when = DateTime.now();

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Bezahlte Stunden — $employeeName'),
          content: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Offene Überstunden: ${openOvertime.toStringAsFixed(1)} h',
                  style: AppTypography.footnote.copyWith(
                    color: AppColors.labelSecondaryLight,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ctrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Bezahlte Stunden',
                    suffixText: 'h',
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: when,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setDialogState(() => when = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Bezahlt am',
                      suffixIcon: Icon(Icons.event_rounded),
                    ),
                    child: Text(
                      '${when.day.toString().padLeft(2, '0')}.'
                      '${when.month.toString().padLeft(2, '0')}.${when.year}',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Notiz (optional)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Abbrechen'),
            ),
            FilledButton(
              onPressed: () async {
                final h = double.tryParse(
                      ctrl.text.replaceAll(',', '.'),
                    ) ??
                    0.0;
                if (h <= 0) return;
                await _repo.addPaidHours(
                  dspUid: widget.dspUid,
                  employeeId: employeeId,
                  employeeName: employeeName,
                  hours: h,
                  paidAt: when,
                  note: noteCtrl.text.trim(),
                );
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
              child: const Text('Speichern'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TimeImport>>(
      stream: _repo.watchImports(widget.dspUid),
      builder: (context, importsSnap) {
        if (importsSnap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final imports = importsSnap.data ?? const [];

        // For each import, fetch entries lazily. Aggregate happens
        // once entries are loaded for ALL imports.
        return FutureBuilder<List<TimeImportEntry>>(
          future: _loadAllEntries(imports),
          builder: (context, entriesSnap) {
            if (entriesSnap.connectionState == ConnectionState.waiting &&
                imports.isNotEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            final entries = entriesSnap.data ?? const <TimeImportEntry>[];

            return StreamBuilder<List<PaidHoursEntry>>(
              stream: _repo.watchPaidHours(widget.dspUid),
              builder: (context, paidSnap) {
                final paid = paidSnap.data ?? const <PaidHoursEntry>[];
                final aggregates = _aggregate(entries, paid);

                return _buildBody(
                  context,
                  imports: imports,
                  aggregates: aggregates,
                  paidEntries: paid,
                );
              },
            );
          },
        );
      },
    );
  }

  Future<List<TimeImportEntry>> _loadAllEntries(
    List<TimeImport> imports,
  ) async {
    if (imports.isEmpty) return const [];
    final out = <TimeImportEntry>[];
    for (final imp in imports) {
      final rows = await _repo.readEntries(
        dspUid: widget.dspUid,
        importId: imp.id,
      );
      out.addAll(rows);
    }
    return out;
  }

  List<TimeAccountAggregate> _aggregate(
    List<TimeImportEntry> entries,
    List<PaidHoursEntry> paid,
  ) {
    final byEmp = <String, List<TimeImportEntry>>{};
    for (final e in entries) {
      final key = e.employeeId.isNotEmpty
          ? '${e.employeeId}::${e.employeeName}'
          : e.employeeName;
      byEmp.putIfAbsent(key, () => []).add(e);
    }
    final paidByEmp = <String, double>{};
    for (final p in paid) {
      final key = p.employeeId.isNotEmpty
          ? '${p.employeeId}::${p.employeeName}'
          : p.employeeName;
      paidByEmp.update(key, (v) => v + p.hours, ifAbsent: () => p.hours);
    }

    final out = <TimeAccountAggregate>[];
    byEmp.forEach((key, list) {
      list.sort((a, b) => a.periodStart.compareTo(b.periodStart));
      final lifetime = list.fold<double>(
        0,
        (s, e) {
          final ot = e.overtimeBalance != 0
              ? e.overtimeBalance
              : e.istHours - e.sollHours;
          return s + ot;
        },
      );
      out.add(TimeAccountAggregate(
        employeeId: list.first.employeeId,
        employeeName: list.first.employeeName,
        lifetimeOvertime: lifetime,
        paidHours: paidByEmp[key] ?? 0,
        months: list,
      ));
    });
    out.sort((a, b) => a.employeeName.compareTo(b.employeeName));
    return out;
  }

  Widget _buildBody(
    BuildContext context, {
    required List<TimeImport> imports,
    required List<TimeAccountAggregate> aggregates,
    required List<PaidHoursEntry> paidEntries,
  }) {
    final totalIst = aggregates.fold<double>(
      0,
      (s, a) => s + a.months.fold<double>(0, (m, e) => m + e.istHours),
    );
    final totalOpen = aggregates.fold<double>(
      0,
      (s, a) => s + a.openOvertime,
    );

    return Container(
      color: const Color(0xFFF3F6F7),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Zeitkonto',
                  style: AppTypography.title2.copyWith(
                    color: AppColors.codriverGraphite,
                  ),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _uploading ? null : _pickAndImport,
                  icon: _uploading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.upload_file_rounded),
                  label: const Text('Excel hochladen'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Soll- und Ist-Stunden aus dem externen Payroll-Export. '
              'Bezahlte Überstunden lassen sich pro Mitarbeiter '
              'eintragen, um den offenen Saldo zu reduzieren.',
              style: AppTypography.footnote.copyWith(
                color: AppColors.labelSecondaryLight,
              ),
            ),
            if (_uploadError != null) ...[
              const SizedBox(height: 12),
              Text(
                _uploadError!,
                style: const TextStyle(color: AppColors.error),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: '# Mitarbeiter',
                    value: '${aggregates.length}',
                    color: AppColors.codriverDeep,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Gesamt Ist-Stunden',
                    value: '${totalIst.toStringAsFixed(0)} h',
                    color: AppColors.codriverGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Offene Überstunden',
                    value: '${totalOpen.toStringAsFixed(1)} h',
                    color: totalOpen > 0
                        ? AppColors.warning
                        : AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (aggregates.isEmpty)
              _EmptyState(onUpload: _pickAndImport)
            else
              _AggregateTable(
                aggregates: aggregates,
                onAddPaid: (a) => _showAddPaidHoursDialog(
                  a.employeeId,
                  a.employeeName,
                  a.openOvertime,
                ),
              ),
            const SizedBox(height: 24),
            _ImportsList(
              imports: imports,
              onDelete: (id) async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: const Text('Import löschen?'),
                    content: const Text(
                      'Alle Zeilen dieses Imports werden entfernt.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(c).pop(false),
                        child: const Text('Abbrechen'),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.error,
                        ),
                        onPressed: () => Navigator.of(c).pop(true),
                        child: const Text('Löschen'),
                      ),
                    ],
                  ),
                );
                if (ok == true) {
                  await _repo.deleteImport(
                    dspUid: widget.dspUid,
                    importId: id,
                  );
                }
              },
            ),
            const SizedBox(height: 24),
            _PaidHistory(
              entries: paidEntries,
              onDelete: (id) =>
                  _repo.deletePaidHours(dspUid: widget.dspUid, id: id),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatMonth(DateTime d) =>
    '${_monthName(d.month)} ${d.year}';
String _monthName(int m) => const [
      'Januar',
      'Februar',
      'März',
      'April',
      'Mai',
      'Juni',
      'Juli',
      'August',
      'September',
      'Oktober',
      'November',
      'Dezember',
    ][m - 1];

// ───────────────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: AppElevation.level1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.caption2.copyWith(
              color: AppColors.labelSecondaryLight,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.title2.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _AggregateTable extends StatelessWidget {
  final List<TimeAccountAggregate> aggregates;
  final void Function(TimeAccountAggregate) onAddPaid;
  const _AggregateTable({
    required this.aggregates,
    required this.onAddPaid,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: AppElevation.level1,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Mitarbeiter',
                    style: _headerStyle(),
                  ),
                ),
                Expanded(child: Text('Soll', style: _headerStyle())),
                Expanded(child: Text('Ist', style: _headerStyle())),
                Expanded(
                  child: Text('Überstd. ges.', style: _headerStyle()),
                ),
                Expanded(child: Text('Bezahlt', style: _headerStyle())),
                Expanded(child: Text('Offen', style: _headerStyle())),
                const SizedBox(width: 40),
              ],
            ),
          ),
          const Divider(height: 1),
          for (final a in aggregates)
            _AggregateRow(aggregate: a, onAddPaid: () => onAddPaid(a)),
        ],
      ),
    );
  }

  TextStyle _headerStyle() => AppTypography.caption2.copyWith(
        color: AppColors.labelSecondaryLight,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      );
}

class _AggregateRow extends StatelessWidget {
  final TimeAccountAggregate aggregate;
  final VoidCallback onAddPaid;
  const _AggregateRow({
    required this.aggregate,
    required this.onAddPaid,
  });

  @override
  Widget build(BuildContext context) {
    final a = aggregate;
    final totalSoll = a.months.fold<double>(0, (s, m) => s + m.sollHours);
    final totalIst = a.months.fold<double>(0, (s, m) => s + m.istHours);
    final overtime = a.lifetimeOvertime;
    final open = a.openOvertime;
    final openColor = open > 0
        ? AppColors.warning
        : (open < 0 ? AppColors.error : AppColors.success);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.employeeName,
                  style: AppTypography.subheadline.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.codriverGraphite,
                  ),
                ),
                Text(
                  '${a.months.length} Monate',
                  style: AppTypography.caption2.copyWith(
                    color: AppColors.labelSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _num(totalSoll)),
          Expanded(child: _num(totalIst)),
          Expanded(child: _num(overtime, color: openColor)),
          Expanded(child: _num(a.paidHours, color: AppColors.codriverDeep)),
          Expanded(child: _num(open, color: openColor, bold: true)),
          IconButton(
            tooltip: 'Bezahlte Stunden hinzufügen',
            onPressed: onAddPaid,
            icon: const Icon(Icons.payments_outlined),
          ),
        ],
      ),
    );
  }

  Widget _num(double v, {Color? color, bool bold = false}) {
    return Text(
      '${v.toStringAsFixed(1)} h',
      style: AppTypography.subheadline.copyWith(
        color: color ?? AppColors.codriverGraphite,
        fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}

class _ImportsList extends StatelessWidget {
  final List<TimeImport> imports;
  final void Function(String id) onDelete;
  const _ImportsList({
    required this.imports,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Imports',
          style: AppTypography.subheadline.copyWith(
            color: AppColors.codriverGraphite,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        if (imports.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Noch kein Import.',
              style: AppTypography.footnote.copyWith(
                color: AppColors.labelSecondaryLight,
              ),
            ),
          )
        else
          for (final imp in imports)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.description_rounded,
                      color: Color(0xFF6B7280)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          imp.filename,
                          style: AppTypography.subheadline.copyWith(
                            color: AppColors.codriverGraphite,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          imp.periodStart != null && imp.periodEnd != null
                              ? '${_dmy(imp.periodStart!)} – ${_dmy(imp.periodEnd!)} · ${imp.rowCount} Zeilen'
                              : '${imp.rowCount} Zeilen',
                          style: AppTypography.caption2.copyWith(
                            color: AppColors.labelSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => onDelete(imp.id),
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
      ],
    );
  }

  String _dmy(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.'
      '${d.month.toString().padLeft(2, '0')}.${d.year}';
}

class _PaidHistory extends StatelessWidget {
  final List<PaidHoursEntry> entries;
  final void Function(String id) onDelete;
  const _PaidHistory({required this.entries, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bezahlte Stunden — Historie',
          style: AppTypography.subheadline.copyWith(
            color: AppColors.codriverGraphite,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        if (entries.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Noch keine Auszahlungen eingetragen.',
              style: AppTypography.footnote.copyWith(
                color: AppColors.labelSecondaryLight,
              ),
            ),
          )
        else
          for (final p in entries)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
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
                    child: const Icon(
                      Icons.payments_rounded,
                      size: 18,
                      color: AppColors.codriverDeep,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${p.employeeName} · ${p.hours.toStringAsFixed(1)} h',
                          style: AppTypography.subheadline.copyWith(
                            color: AppColors.codriverGraphite,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${p.paidAt.day.toString().padLeft(2, '0')}.'
                          '${p.paidAt.month.toString().padLeft(2, '0')}.'
                          '${p.paidAt.year}'
                          '${p.note != null ? ' · ${p.note}' : ''}',
                          style: AppTypography.caption2.copyWith(
                            color: AppColors.labelSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => onDelete(p.id),
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onUpload;
  const _EmptyState({required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.schedule_rounded,
            size: 36,
            color: Color(0xFF9CA3AF),
          ),
          const SizedBox(height: 10),
          Text(
            'Noch kein Zeit-Import.',
            style: AppTypography.subheadline.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.codriverGraphite,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Lade den monatlichen Payroll-Export (.xlsx) hoch.',
            style: AppTypography.footnote.copyWith(
              color: AppColors.labelSecondaryLight,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onUpload,
            icon: const Icon(Icons.upload_file_rounded),
            label: const Text('Excel hochladen'),
          ),
        ],
      ),
    );
  }
}
