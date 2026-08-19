import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/parser_api.dart';
import '../services/report_section_remover.dart';
import '../services/report_writer.dart';
import '../localization/app_localizations.dart';
import '../widgets/admin_scope.dart';
import '../widgets/co_button.dart';
import '../widgets/report_source_hint.dart';
import 'concessions_dashboard.dart';
import 'concessions_week.dart';

final _intFmt = NumberFormat.decimalPattern('de');
final _eurFmtTop = NumberFormat.currency(
  locale: 'de_DE',
  symbol: '€',
  decimalDigits: 2,
);

String _eurStrInline(num eur) {
  try {
    return _eurFmtTop.format(eur);
  } catch (_) {
    return '€ ${eur.toStringAsFixed(2)}';
  }
}

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

enum _WeekSort { lossDesc, dnrsDesc, dateDesc }

class _ConcessionsOverviewPageState extends State<ConcessionsOverviewPage> {
  bool _busyUpload = false;
  _WeekSort _weekSort = _WeekSort.lossDesc;

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

  Future<void> _confirmDeleteWeek(_ConcessionsReportVM r) async {
    final t = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.t('concessions_delete_week_title')),
        content: Text(
          t.tf('concessions_delete_week_body', {'week': r.label}),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.t('admin_home_cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB42318),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t.t('concessions_delete_week_confirm')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _deleteWeek(r);
  }

  Future<void> _deleteWeek(_ConcessionsReportVM r) async {
    final t = AppLocalizations.of(context);
    try {
      // Nur die Concessions-Sektion entfernen. Alle Features (Scorecard,
      // POD, CDF, DWC) teilen sich pro Woche dasselbe Report-Dokument und
      // je Fahrer dasselbe Score-Dokument — ein komplettes Löschen würde
      // deren Daten mit vernichten.
      final uid = AdminScope.adminUidOf(context) ??
          FirebaseAuth.instance.currentUser!.uid;
      await ReportSectionRemover.removeSection(
        uid: uid,
        reportRef: r.ref,
        sectionKey: 'concessions',
        scoreFields: const ['concessions'],
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t.tf('concessions_delete_week_success', {'week': r.label}),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t.tf('concessions_delete_week_failed', {'error': '$e'}),
          ),
        ),
      );
    }
  }

  double _weekLoss(_ConcessionsReportVM r) {
    final dnr = _num(r.concSummary['dnrCount']) ?? 0;
    return dnr * 5.50;
  }

  void _sortWeekList(List<_ConcessionsReportVM> list) {
    switch (_weekSort) {
      case _WeekSort.lossDesc:
        list.sort((a, b) => _weekLoss(b).compareTo(_weekLoss(a)));
        break;
      case _WeekSort.dnrsDesc:
        list.sort((a, b) {
          final ad = _num(a.concSummary['dnrCount']) ?? 0;
          final bd = _num(b.concSummary['dnrCount']) ?? 0;
          return bd.compareTo(ad);
        });
        break;
      case _WeekSort.dateDesc:
        list.sort((a, b) {
          final yc = b.year.compareTo(a.year);
          if (yc != 0) return yc;
          return b.week.compareTo(a.week);
        });
        break;
    }
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
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        FilledButton.tonalIcon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ConcessionsDashboardPage(),
                            ),
                          ),
                          icon: const Icon(Icons.dashboard_outlined),
                          label: Text(t.t('concessions_dashboard_open')),
                        ),
                        CoButton(
                          onPressed:
                              _busyUpload ? null : _uploadConcessionsXlsx,
                          icon: Icons.upload_file,
                          label: _busyUpload
                              ? t.t('uploading')
                              : t.t('concessions_upload_xlsx'),
                          busy: _busyUpload,
                        ),
                      ],
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
                    FilledButton.tonalIcon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ConcessionsDashboardPage(),
                        ),
                      ),
                      icon: const Icon(Icons.dashboard_outlined),
                      label: Text(t.t('concessions_dashboard_open')),
                    ),
                    const SizedBox(width: 12),
                    CoButton(
                      onPressed: _busyUpload ? null : _uploadConcessionsXlsx,
                      icon: Icons.upload_file,
                      label: _busyUpload
                          ? t.t('uploading')
                          : t.t('concessions_upload_xlsx'),
                      busy: _busyUpload,
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              const ReportSourceHint(
                expectedFileName:
                    'z. B. DE-AION-DBY5-Week19-Concessions.xlsx',
                margin: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              // Hero-Stats: Gesamt-Verlust + Gesamt-DNRs + Betroffene
              _OverallTotalsCard(),
              const SizedBox(height: 16),
              // Sort-Bar: Wochen-Sortierung (Default: schlechtester Verlust)
              Row(
                children: [
                  Text(
                    t.t('concessions_weeks_label'),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF6B7280),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  _WeekSortMenu(
                    value: _weekSort,
                    onChanged: (v) => setState(() => _weekSort = v),
                  ),
                ],
              ),
              const SizedBox(height: 10),
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
                    final list = [
                      ...(snap.data ?? const <_ConcessionsReportVM>[]),
                    ];
                    if (list.isEmpty) {
                      return Center(
                        child: Text(
                          t.t('concessions_no_reports_uploaded'),
                        ),
                      );
                    }
                    _sortWeekList(list);

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
                                    const SizedBox(width: 6),
                                    IconButton(
                                      tooltip: t.t(
                                        'concessions_delete_week_tooltip',
                                      ),
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: Color(0xFFB42318),
                                        size: 22,
                                      ),
                                      onPressed: () => _confirmDeleteWeek(r),
                                    ),
                                    const SizedBox(width: 4),
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
                                    _StatChip(
                                      label: t.t('concessions_loss'),
                                      value: _eurStrInline(_weekLoss(r)),
                                      tone: _ChipTone.danger,
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

enum _ChipTone { neutral, good, warn, danger }

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
      case _ChipTone.danger:
        bg = const Color(0xFFFEE4E2);
        fg = const Color(0xFFB42318);
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

// ============================================================
//  Overall Totals Card — sichtbar oben auf Concessions Overview
//  Aggregiert ueber alle scores aller Wochen.
// ============================================================

class _OverallTotalsCard extends StatelessWidget {
  const _OverallTotalsCard();

  static const double _eurPerDnr = 5.50;
  static final NumberFormat _intFmt = NumberFormat.decimalPattern('de');
  static final NumberFormat _decFmt = NumberFormat.decimalPattern('de');
  static final NumberFormat _eurFmt = NumberFormat.currency(
    locale: 'de_DE',
    symbol: '€',
    decimalDigits: 2,
  );

  String _intStr(num v) {
    try {
      return _intFmt.format(v.round());
    } catch (_) {
      return v.toStringAsFixed(0);
    }
  }

  String _decStr(num v) {
    try {
      return _decFmt.format(double.parse(v.toStringAsFixed(1)));
    } catch (_) {
      return v.toStringAsFixed(1);
    }
  }

  String _eurStr(num v) {
    try {
      return _eurFmt.format(v);
    } catch (_) {
      return '€ ${v.toStringAsFixed(2)}';
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _reportsStream() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('reports')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _reportsStream(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return _SkeletonHero();
        }

        // Pro Wochen-Report die concessions.summary herauslesen.
        double sumDnr = 0;
        double sumDpmo = 0;
        int weekCount = 0;
        for (final d in snap.data!.docs) {
          final m = d.data();
          final summary =
              (m['summary'] as Map?)?.cast<String, dynamic>() ?? const {};
          final conc =
              (summary['concessions'] as Map?)?.cast<String, dynamic>();
          if (conc == null) continue;
          final concSum =
              (conc['summary'] as Map?)?.cast<String, dynamic>() ??
                  const {};
          if (concSum.isEmpty) continue;

          double parseN(dynamic v) {
            if (v is num) return v.toDouble();
            if (v is String) {
              return double.tryParse(
                    v.trim().replaceAll('%', '').replaceAll(',', '.'),
                  ) ??
                  0;
            }
            return 0;
          }

          sumDnr += parseN(concSum['dnrCount']);
          sumDpmo += parseN(concSum['dnrDpmo']);
          weekCount += 1;
        }

        final totalLoss = sumDnr * _eurPerDnr;
        final avgDnr = weekCount > 0 ? sumDnr / weekCount : 0.0;
        final avgDpmo = weekCount > 0 ? sumDpmo / weekCount : 0.0;
        final avgLoss = weekCount > 0 ? totalLoss / weekCount : 0.0;

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFEF3F2), Color(0xFFFFF7E6)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFECDCA)),
          ),
          child: LayoutBuilder(
            builder: (context, c) {
              final isNarrow = c.maxWidth < 760;
              final cells = <Widget>[
                _HeroCell(
                  label: t.t('concessions_total_loss'),
                  value: _eurStr(totalLoss),
                  accent: const Color(0xFFB42318),
                  icon: Icons.payments_outlined,
                ),
                _HeroCell(
                  label: t.t('concessions_avg_loss_week'),
                  value: _eurStr(avgLoss),
                  accent: const Color(0xFFB54708),
                  icon: Icons.trending_up_rounded,
                ),
                _HeroCell(
                  label: t.t('concessions_avg_dnr_week'),
                  value: _decStr(avgDnr),
                  accent: const Color(0xFF1F2937),
                  icon: Icons.warning_amber_rounded,
                ),
                _HeroCell(
                  label: t.t('concessions_avg_dpmo'),
                  value: _intStr(avgDpmo),
                  accent: const Color(0xFF1F2937),
                  icon: Icons.equalizer_rounded,
                ),
              ];

              if (isNarrow) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: cells[0]),
                        Container(
                          width: 1,
                          height: 52,
                          color: const Color(0xFFFECDCA),
                        ),
                        Expanded(child: cells[1]),
                      ],
                    ),
                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(vertical: 14),
                      color: const Color(0xFFFECDCA),
                    ),
                    Row(
                      children: [
                        Expanded(child: cells[2]),
                        Container(
                          width: 1,
                          height: 52,
                          color: const Color(0xFFFECDCA),
                        ),
                        Expanded(child: cells[3]),
                      ],
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: cells[0]),
                  Container(
                    width: 1,
                    height: 56,
                    color: const Color(0xFFFECDCA),
                  ),
                  Expanded(child: cells[1]),
                  Container(
                    width: 1,
                    height: 56,
                    color: const Color(0xFFFECDCA),
                  ),
                  Expanded(child: cells[2]),
                  Container(
                    width: 1,
                    height: 56,
                    color: const Color(0xFFFECDCA),
                  ),
                  Expanded(child: cells[3]),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _SkeletonHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

class _HeroCell extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  final IconData icon;
  const _HeroCell({
    required this.label,
    required this.value,
    required this.accent,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: accent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: accent,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
//  Wochen-Sortier-Menu
// ============================================================

class _WeekSortMenu extends StatelessWidget {
  final _WeekSort value;
  final ValueChanged<_WeekSort> onChanged;
  const _WeekSortMenu({required this.value, required this.onChanged});

  String _label(BuildContext context, _WeekSort v) {
    final t = AppLocalizations.of(context);
    switch (v) {
      case _WeekSort.lossDesc:
        return t.t("concessions_weeks_sort_loss");
      case _WeekSort.dnrsDesc:
        return t.t("concessions_weeks_sort_dnrs");
      case _WeekSort.dateDesc:
        return t.t("concessions_weeks_sort_date");
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_WeekSort>(
      tooltip: AppLocalizations.of(context).t("concessions_sort_tooltip"),
      onSelected: onChanged,
      itemBuilder: (ctx) => _WeekSort.values
          .map((v) => PopupMenuItem<_WeekSort>(
                value: v,
                child: Row(
                  children: [
                    if (v == value)
                      const Icon(Icons.check,
                          size: 18, color: Color(0xFF1D7F5A))
                    else
                      const SizedBox(width: 18),
                    const SizedBox(width: 8),
                    Text(_label(ctx, v)),
                  ],
                ),
              ))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.swap_vert_rounded,
                size: 16, color: Color(0xFF374151)),
            const SizedBox(width: 6),
            Text(
              _label(context, value),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down_rounded,
                size: 20, color: Color(0xFF6B7280)),
          ],
        ),
      ),
    );
  }
}
