import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/parser_api.dart';
import '../services/report_writer.dart';
import '../localization/app_localizations.dart';
import '../widgets/app_shell.dart';
import '../widgets/app_side_menu.dart';
import 'pod_quality_week.dart';

final _pct = NumberFormat.decimalPattern('de');
final _int = NumberFormat.decimalPattern('de');

String _pctStr(num? v) {
  if (v == null) return '—';
  try {
    return '${_pct.format(v)} %';
  } catch (_) {
    return '—';
  }
}

String _intStr(num? v) {
  if (v == null) return '—';
  try {
    return _int.format(v);
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

class PodQualityWeekShellPage extends StatelessWidget {
  final DocumentReference<Map<String, dynamic>> reportRef;

  const PodQualityWeekShellPage({super.key, required this.reportRef});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return AppShell(
      menuWidth: 300,
      sideMenu: const AppSideMenu(width: 300, active: AppNav.podQuality),
      body: PodQualityWeekPage(reportRef: reportRef),
      title: Text(t.t('pod_quality_shell_week_title')),
    );
  }
}

class PodQualityOverviewPage extends StatefulWidget {
  const PodQualityOverviewPage({super.key});

  @override
  State<PodQualityOverviewPage> createState() => _PodQualityOverviewPageState();
}

class _PodQualityOverviewPageState extends State<PodQualityOverviewPage> {
  bool _busyUpload = false;

  Stream<List<_PodReportVM>> _podReportsStream() {
    final t = AppLocalizations.of(context);
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('reports')
        .orderBy('year', descending: true)
        .orderBy('weekNumber', descending: true)
        .limit(52)
        .snapshots()
        .map((snap) {
          return snap.docs
              .map((d) {
                final m = d.data();
                final summary =
                    (m['summary'] as Map?)?.cast<String, dynamic>() ?? {};
                final pod =
                    (summary['podQuality'] as Map?)?.cast<String, dynamic>() ??
                    const <String, dynamic>{};
                final reportName = (m['reportName'] ?? '').toString();
                final hasPod =
                    pod.isNotEmpty ||
                    reportName.toLowerCase().contains('pod-quality') ||
                    reportName.toLowerCase().contains('pod quality');
                final y = (m['year'] as num?)?.toInt() ?? 0;
                final w = (m['weekNumber'] as num?)?.toInt() ?? 0;
                final station =
                    (summary['stationCode'] ?? m['stationCode'] ?? '')
                        .toString();

                return _PodReportVM(
                  ref: d.reference,
                  year: y,
                  week: w,
                  label:
                      (summary['weekText'] ??
                              t.tf('pod_quality_week_label', {'week': '$w'}))
                          .toString(),
                  stationCode: station,
                  podSummary:
                      (pod['summary'] as Map?)?.cast<String, dynamic>() ??
                      const {},
                  podRejects:
                      (pod['rejects'] as Map?)?.cast<String, dynamic>() ??
                      const {},
                  hasPod: hasPod,
                );
              })
              .where((vm) => vm.hasPod)
              .toList();
        });
  }

  Future<void> _uploadPodQualityPdf() async {
    final t = AppLocalizations.of(context);
    if (_busyUpload) return;
    setState(() => _busyUpload = true);

    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
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

        final parsed = await ParserApi.parsePdf(bytes, filename: f.name);
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
                ? t.t('pod_quality_upload_success_one')
                : t.tf('pod_quality_upload_success_many', {
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
            t.tf('pod_quality_upload_parse_failed', {'error': '$e'}),
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
        builder: (_) => PodQualityWeekShellPage(reportRef: reportRef),
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
                      t.t('pod_quality_dashboard_title'),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF111827),
                          ),
                    ),
                    const SizedBox(height: 10),
                    FilledButton.icon(
                      onPressed: _busyUpload ? null : _uploadPodQualityPdf,
                      icon: const Icon(Icons.upload_file),
                      label: Text(
                        _busyUpload
                            ? t.t('uploading')
                            : t.t('pod_quality_upload_pdf'),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        t.t('pod_quality_dashboard_title'),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF111827),
                            ),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: _busyUpload ? null : _uploadPodQualityPdf,
                      icon: const Icon(Icons.upload_file),
                      label: Text(
                        _busyUpload
                            ? t.t('uploading')
                            : t.t('pod_quality_upload_pdf'),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<List<_PodReportVM>>(
                  stream: _podReportsStream(),
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
                    final list = snap.data ?? const <_PodReportVM>[];
                    if (list.isEmpty) {
                      return Center(
                        child: Text(t.t('pod_quality_no_reports_uploaded')),
                      );
                    }

                    return ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final r = list[index];
                        final summary = r.podSummary;
                        final successPct = _num(summary['successPct']);
                        final rejectsPct = _num(summary['rejectsPct']);
                        final opportunities = _num(
                          summary['opportunitiesCount'],
                        );

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
                                      label: t.t('pod_quality_opp'),
                                      value: _intStr(opportunities),
                                      tone: _ChipTone.neutral,
                                    ),
                                    _StatChip(
                                      label: t.t('pod_quality_success'),
                                      value: _pctStr(successPct),
                                      tone: _ChipTone.good,
                                    ),
                                    _StatChip(
                                      label: t.t('pod_quality_rejects'),
                                      value: _pctStr(rejectsPct),
                                      tone: _ChipTone.warn,
                                    ),
                                  ],
                                ),
                                if (!isNarrow && r.podRejects.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    t.t('pod_quality_rejects_breakdown'),
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
                                        label: t.t('pod_quality_blurry'),
                                        value: _intStr(
                                          _num(
                                            r.podRejects['blurryPhotoCount'],
                                          ),
                                        ),
                                      ),
                                      _MiniStat(
                                        label: t.t('pod_quality_too_dark'),
                                        value: _intStr(
                                          _num(
                                            r.podRejects['photoTooDarkCount'],
                                          ),
                                        ),
                                      ),
                                      _MiniStat(
                                        label: t.t('pod_quality_no_package'),
                                        value: _intStr(
                                          _num(
                                            r.podRejects['noPackageDetectedCount'],
                                          ),
                                        ),
                                      ),
                                      _MiniStat(
                                        label: t.t('pod_quality_in_car'),
                                        value: _intStr(
                                          _num(
                                            r.podRejects['packageInCarCount'],
                                          ),
                                        ),
                                      ),
                                      _MiniStat(
                                        label: t.t('pod_quality_too_close'),
                                        value: _intStr(
                                          _num(
                                            r.podRejects['packageTooCloseCount'],
                                          ),
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

class _PodReportVM {
  final DocumentReference<Map<String, dynamic>> ref;
  final int year;
  final int week;
  final String label;
  final String stationCode;
  final Map<String, dynamic> podSummary;
  final Map<String, dynamic> podRejects;
  final bool hasPod;

  const _PodReportVM({
    required this.ref,
    required this.year,
    required this.week,
    required this.label,
    required this.stationCode,
    required this.podSummary,
    required this.podRejects,
    required this.hasPod,
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
