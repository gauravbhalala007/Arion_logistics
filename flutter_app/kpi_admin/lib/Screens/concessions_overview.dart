import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/parser_api.dart';
import '../services/report_writer.dart';
import '../localization/app_localizations.dart';
import 'concessions_week.dart';

final _intFmt = NumberFormat.decimalPattern('de');

String _intStr(num? v) {
  if (v == null) return '—';
  try {
    return _intFmt.format(v);
  } catch (_) {
    return '—';
  }
}

double? _num(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  if (v is String) {
    final s = v.trim().replaceAll('%', '');
    return double.tryParse(s.replaceAll(',', '.'));
  }
  return null;
}

class ConcessionsWeekShellPage extends StatelessWidget {
  final DocumentReference<Map<String, dynamic>> reportRef;

  const ConcessionsWeekShellPage({super.key, required this.reportRef});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: Text(
          t.t('concessions_shell_week_title'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ConcessionsWeekPage(reportRef: reportRef),
    );
  }
}

class ConcessionsOverviewPage extends StatefulWidget {
  const ConcessionsOverviewPage({super.key});

  @override
  State<ConcessionsOverviewPage> createState() =>
      _ConcessionsOverviewPageState();
}

class _ConcessionsOverviewPageState extends State<ConcessionsOverviewPage> {
  bool _busyUpload = false;

  Stream<List<_ConcessionsReportVM>> _reportsStream() {
    final t = AppLocalizations.of(context);
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('reports')
        .orderBy('reportDate', descending: true)
        .limit(52)
        .snapshots()
        .map((snap) {
          final rows = snap.docs
              .map((d) {
                final m = d.data();
                final summary =
                    (m['summary'] as Map?)?.cast<String, dynamic>() ?? {};
                final conc =
                    (summary['concessions'] as Map?)
                        ?.cast<String, dynamic>() ??
                    const <String, dynamic>{};
                final reportName = (m['reportName'] ?? '').toString();
                final hasConcessions =
                    conc.isNotEmpty ||
                    reportName.toLowerCase().contains('concession');
                final y = (m['year'] as num?)?.toInt() ?? 0;
                final w = (m['weekNumber'] as num?)?.toInt() ?? 0;
                final station =
                    (summary['stationCode'] ?? m['stationCode'] ?? '')
                        .toString();

                return _ConcessionsReportVM(
                  ref: d.reference,
                  year: y,
                  week: w,
                  label:
                      (summary['weekText'] ??
                              t.tf('concessions_week_label', {'week': '$w'}))
                          .toString(),
                  stationCode: station,
                  concSummary:
                      (conc['summary'] as Map?)?.cast<String, dynamic>() ??
                      const {},
                  concFocus:
                      (conc['focusBuckets'] as Map?)
                          ?.cast<String, dynamic>() ??
                      const {},
                  hasConcessions: hasConcessions,
                );
              })
              .where((vm) => vm.hasConcessions)
              .toList();
          rows.sort((a, b) {
            final yearCmp = b.year.compareTo(a.year);
            if (yearCmp != 0) return yearCmp;
            return b.week.compareTo(a.week);
          });
          return rows;
        });
  }

  Future<void> _uploadConcessionsXlsx() async {
    final t = AppLocalizations.of(context);
    if (_busyUpload) return;
    setState(() => _busyUpload = true);

    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true,
        allowMultiple: true,
      );

      if (picked == null || picked.files.isEmpty) {
        return;
      }

      int successCount = 0;
      for (final f in picked.files) {
        final Uint8List? bytes = f.bytes;
        if (bytes == null) continue;

        final parsed = await ParserApi.parseXlsx(bytes, filename: f.name);
        final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
        final pseudoPath = 'inline/$date/${f.name}';

        await ReportWriter.writeReportAndScores(
          parserJson: parsed,
          storagePath: pseudoPath,
        );
        successCount++;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            successCount == 1
                ? t.t('concessions_upload_success_one')
                : t.tf('concessions_upload_success_many', {
                    'count': '$successCount',
                  }),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t.tf('concessions_upload_parse_failed', {'error': '$e'}),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _busyUpload = false);
    }
  }

  void _openWeek(DocumentReference<Map<String, dynamic>> reportRef) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ConcessionsWeekShellPage(reportRef: reportRef),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final w = MediaQuery.of(context).size.width;
    final isNarrow = w < 980;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isNarrow)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.t('concessions_dashboard_title'),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF111827),
                          ),
                    ),
                    const SizedBox(height: 10),
                    FilledButton.icon(
                      onPressed: _busyUpload ? null : _uploadConcessionsXlsx,
                      icon: const Icon(Icons.upload_file),
                      label: Text(
                        _busyUpload
                            ? t.t('uploading')
                            : t.t('concessions_upload_xlsx'),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        t.t('concessions_dashboard_title'),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF111827),
                            ),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: _busyUpload ? null : _uploadConcessionsXlsx,
                      icon: const Icon(Icons.upload_file),
                      label: Text(
                        _busyUpload
                            ? t.t('uploading')
                            : t.t('concessions_upload_xlsx'),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<List<_ConcessionsReportVM>>(
                  stream: _reportsStream(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snap.hasError) {
                      return Center(
                        child: Text(
                          t.tf('admin_home_error_generic', {
                            'error': '${snap.error}',
                          }),
                        ),
                      );
                    }
                    final list =
                        snap.data ?? const <_ConcessionsReportVM>[];
                    if (list.isEmpty) {
                      return Center(
                        child: Text(
                          t.t('concessions_no_reports_uploaded'),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final r = list[index];
                        final s = r.concSummary;
                        final delVolume = _num(s['delVolume']);
                        final dnrCount = _num(s['dnrCount']);
                        final dnrDpmo = _num(s['dnrDpmo']);

                        return InkWell(
                          onTap: () => _openWeek(r.ref),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        r.label,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF111827),
                                        ),
                                      ),
                                    ),
                                    if (r.stationCode.isNotEmpty)
                                      Flexible(
                                        child: Text(
                                          r.stationCode,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                      ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.chevron_right),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    _StatChip(
                                      label: t.t('concessions_delivered'),
                                      value: _intStr(delVolume),
                                      tone: _ChipTone.neutral,
                                    ),
                                    _StatChip(
                                      label: t.t('concessions_dnr_count'),
                                      value: _intStr(dnrCount),
                                      tone: _ChipTone.warn,
                                    ),
                                    _StatChip(
                                      label: t.t('concessions_dnr_dpmo'),
                                      value: _intStr(dnrDpmo),
                                      tone: _ChipTone.warn,
                                    ),
                                  ],
                                ),
                                if (!isNarrow && r.concFocus.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    t.t('concessions_focus_breakdown'),
                                    style: const TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _MiniStat(
                                        label: t.t(
                                          'concessions_focus_attended_dnr',
                                        ),
                                        value: _intStr(
                                          _num(r.concFocus['attendedDnr']),
                                        ),
                                      ),
                                      _MiniStat(
                                        label: t.t(
                                          'concessions_focus_photo_on_delivery',
                                        ),
                                        value: _intStr(
                                          _num(
                                            r.concFocus['photoOnDelivery'],
                                          ),
                                        ),
                                      ),
                                      _MiniStat(
                                        label: t.t(
                                          'concessions_focus_successful_contact',
                                        ),
                                        value: _intStr(
                                          _num(
                                            r.concFocus['successfulContact'],
                                          ),
                                        ),
                                      ),
                                      _MiniStat(
                                        label: t.t(
                                          'concessions_focus_delivered_25m',
                                        ),
                                        value: _intStr(
                                          _num(r.concFocus['delivered25m']),
                                        ),
                                      ),
                                      _MiniStat(
                                        label: t.t(
                                          'concessions_focus_false_scan',
                                        ),
                                        value: _intStr(
                                          _num(r.concFocus['falseScan']),
                                        ),
                                      ),
                                      _MiniStat(
                                        label: t.t(
                                          'concessions_focus_mailbox',
                                        ),
                                        value: _intStr(
                                          _num(r.concFocus['mailbox']),
                                        ),
                                      ),
                                      _MiniStat(
                                        label: t.t(
                                          'concessions_focus_delivered_otp',
                                        ),
                                        value: _intStr(
                                          _num(r.concFocus['deliveredOtp']),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConcessionsReportVM {
  final DocumentReference<Map<String, dynamic>> ref;
  final int year;
  final int week;
  final String label;
  final String stationCode;
  final Map<String, dynamic> concSummary;
  final Map<String, dynamic> concFocus;
  final bool hasConcessions;

  const _ConcessionsReportVM({
    required this.ref,
    required this.year,
    required this.week,
    required this.label,
    required this.stationCode,
    required this.concSummary,
    required this.concFocus,
    required this.hasConcessions,
  });
}

enum _ChipTone { neutral, good, warn }

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final _ChipTone tone;

  const _StatChip({
    required this.label,
    required this.value,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    switch (tone) {
      case _ChipTone.good:
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
        break;
      case _ChipTone.warn:
        bg = const Color(0xFFFFEDD5);
        fg = const Color(0xFF9A3412);
        break;
      case _ChipTone.neutral:
      default:
        bg = const Color(0xFFE5E7EB);
        fg = const Color(0xFF374151);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}
