// lib/screens/scorecard_overview.dart
import 'dart:typed_data';

import '../services/parser_api.dart';
import '../services/report_writer.dart';
import '../services/driver_csv.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ⬇️ for uploading PDFs & CSVs
import 'package:file_picker/file_picker.dart';

import 'scorecard_week.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../localization/app_localizations.dart';
import '../theme/app_button_style.dart';
import '../theme/app_colors.dart';
import '../theme/app_elevation.dart';

/// Simple German-style number formatting
final _pct2 = NumberFormat.decimalPattern('de')
  ..minimumFractionDigits = 2
  ..maximumFractionDigits = 2;

String _s(dynamic v) => (v == null) ? '' : v.toString();
String _normTid(dynamic v) => DriverCsvService.normalizeTransporterId(_s(v));
num _numOr0(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v;
  if (v is String) {
    final s = v.trim().replaceAll('%', '');
    return num.tryParse(s.replaceAll(',', '.')) ?? 0;
  }
  return 0;
}

/// ---------- Week date helpers (ISO week: Monday start) ----------
DateTime _isoWeekStartUtc(int year, int week) {
  final jan4 = DateTime.utc(year, 1, 4);
  final week1Mon = jan4.subtract(
    Duration(days: jan4.weekday - DateTime.monday),
  );
  return week1Mon.add(Duration(days: (week - 1) * 7));
}

String _dotted(DateTime d) => DateFormat('dd.MM.yyyy').format(d.toLocal());

int _monthIndexFromWeek(int year, int week) {
  final jan4 = DateTime.utc(year, 1, 4);
  final week1Mon = jan4.subtract(
    Duration(days: jan4.weekday - DateTime.monday),
  );
  final target = week1Mon.add(Duration(days: (week - 1) * 7));
  return target.month;
}

String _monthNameFromIndex(int m) {
  final date = DateTime(2024, m, 1);
  return DateFormat('MMMM').format(date);
}

String _shortMonthName(int m) {
  final date = DateTime(2024, m, 1);
  return DateFormat('MMM').format(date);
}

/// ---------- Responsive helpers (match scorecard_week.dart) ----------
double _scaleForWidth(double w) {
  if (w >= 1440) return 1.0;
  if (w >= 1200) return 0.93 + (w - 1200) / 240 * (1.0 - 0.93);
  if (w >= 1000) return 0.86 + (w - 1000) / 200 * (0.93 - 0.86);
  if (w >= 800) return 0.78 + (w - 800) / 200 * (0.86 - 0.78);
  if (w >= 600) return 0.70 + (w - 600) / 200 * (0.78 - 0.70);
  if (w >= 420) return 0.62 + (w - 420) / 180 * (0.70 - 0.62);
  return 0.60;
}

double _sp(double base, double w) => base * _scaleForWidth(w);
double _pad(double base, double w) => base * _scaleForWidth(w);
bool _isNarrow(BuildContext c) => MediaQuery.of(c).size.width < 1100;

enum _PeriodFilter { week, month, year }

/* ====================  Palette / styles  ==================== */
/// Maps the legacy `_UI` API onto the new design-system tokens
/// (lib/theme/*). Keeps internal call-sites unchanged while the
/// visual layer is migrated.
class _UI {
  static const bg = AppColors.surfaceLight;
  static const card = AppColors.surfaceElevatedLight;
  static const textPrimary = AppColors.codriverGraphite;
  static const textSecondary = AppColors.labelSecondaryLight;
  static const green = AppColors.green200;
  static const greenDark = AppColors.codriverGreen;
  static const border = AppColors.separatorLight;
  static const dark = AppColors.codriverDeep;
  static BoxShadow shadow = AppElevation.level2.first;
}

/* ====================  Model for view  ==================== */
class _ReportVM {
  final DocumentReference<Map<String, dynamic>> ref;
  final int year;
  final int week;
  final String label; // "Week 23 - 2025"
  final double? overall;
  final String? overallStatus;
  final double? relNext;
  final double? relSame;
  final int? rankAtStation;
  final int? stationCount;
  final String? stationCode;

  _ReportVM({
    required this.ref,
    required this.year,
    required this.week,
    required this.label,
    required this.overall,
    required this.overallStatus,
    required this.relNext,
    required this.relSame,
    required this.rankAtStation,
    required this.stationCount,
    required this.stationCode,
  });
}

const _kFantasticPlusColor = AppColors.tierFantasticPlus;
const _kFantasticColor = AppColors.tierFantastic;
const _kGreatColor = AppColors.tierGreat;
const _kFairColor = AppColors.tierFair;
const _kPoorColor = AppColors.tierPoor;

class ScorecardOverviewPage extends StatefulWidget {
  const ScorecardOverviewPage({super.key});

  @override
  State<ScorecardOverviewPage> createState() => _ScorecardOverviewPageState();
}

class ScorecardWeekShellPage extends StatelessWidget {
  final DocumentReference<Map<String, dynamic>> reportRef;

  const ScorecardWeekShellPage({super.key, required this.reportRef});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: _UI.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _UI.textPrimary,
        elevation: 0,
        title: Text(
          '${t.t('nav_scorecard').toUpperCase()} ${t.t('dash_week').toUpperCase()}',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ScorecardWeekPage(reportRef: reportRef),
    );
  }
}

class _ScorecardOverviewPageState extends State<ScorecardOverviewPage> {
  bool _busyUpload = false; // PDFs (bottom-left)
  bool _busyCsv = false; // CSVs (top-right)

  _PeriodFilter _periodFilter = _PeriodFilter.month;
  String? _selectedMonthKey;
  int? _selectedYear;
  String? _selectedStationCode;

  late final Stream<Map<String, String>> _globalNamesStreamCached;

  @override
  void initState() {
    super.initState();
    _globalNamesStreamCached = _driversNameMapGlobal();
  }

  Stream<List<_ReportVM>> _reportsStream() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('reports')
        .orderBy('year', descending: true)
        .orderBy('weekNumber', descending: true)
        .limit(52)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) {
            final m = d.data();
            final s = (m['summary'] as Map?)?.cast<String, dynamic>() ?? {};
            final y = (m['year'] as num?)?.toInt() ?? 0;
            final w = (m['weekNumber'] as num?)?.toInt() ?? 0;
            return _ReportVM(
              ref: d.reference,
              year: y,
              week: w,
              label: (s['weekText'] ?? 'Week $w - $y').toString(),
              overall: (s['overallScore'] as num?)?.toDouble(),
              overallStatus: s['overallStatus'] as String?,
              relNext: (s['reliabilityNextDay'] as num?)?.toDouble(),
              relSame: (s['reliabilitySameDay'] as num?)?.toDouble(),
              rankAtStation: (s['rankAtStation'] as num?)?.toInt(),
              stationCount: (s['stationCount'] as num?)?.toInt(),
              stationCode: s['stationCode'] as String?,
            );
          }).toList(),
        );
  }

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _scoresForPeriod({
    required int year,
    required Set<String> reportIds,
    required Set<String> reportPaths,
  }) {
    if (reportIds.isEmpty && reportPaths.isEmpty) {
      return Stream.value(<QueryDocumentSnapshot<Map<String, dynamic>>>[]);
    }

    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('scores')
        .where('year', isEqualTo: year)
        .snapshots()
        .map((s) {
          return s.docs
              .where((doc) {
                final data = doc.data();
                final reportId = _s(data['reportId']);
                if (reportId.isNotEmpty && reportIds.contains(reportId)) {
                  return true;
                }

                final reportPath = _s(data['reportPath']);
                return reportPath.isNotEmpty &&
                    reportPaths.contains(reportPath);
              })
              .toList(growable: false);
        });
  }

  Stream<Map<String, String>> _driversNameMapGlobal() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('drivers')
        .snapshots()
        .map((snap) {
          final m = <String, String>{};
          for (final d in snap.docs) {
            final data = d.data();
            final id = _normTid(data['transporterId'] ?? d.id);
            final name = _s(data['driverName']);
            if (id.isNotEmpty) m[id] = name;
          }
          return m;
        });
  }

  Color _statusColorFromCode(String code) {
    switch (code.trim().toUpperCase()) {
      case 'FANTASTIC_PLUS':
        return _kFantasticPlusColor;
      case 'FANTASTIC':
        return _kFantasticColor;
      case 'GREAT':
        return _kGreatColor;
      case 'FAIR':
        return _kFairColor;
      case 'POOR':
        return _kPoorColor;
      default:
        return _UI.textSecondary;
    }
  }

  String _prettyStatus(String? raw, AppLocalizations t) {
    switch (_s(raw).trim().toUpperCase()) {
      case 'FANTASTIC_PLUS':
        return 'Fantastic Plus';
      case 'FANTASTIC':
        return 'Fantastic';
      case 'GREAT':
        return 'Great';
      case 'FAIR':
        return 'Fair';
      case 'POOR':
        return 'Poor';
      default:
        return _s(raw);
    }
  }

  String _statusCodeFromScore(double? score) {
    if (score == null) return '';
    final s = score;
    if (s >= 93.0) return 'FANTASTIC_PLUS';
    if (s >= 86.0) return 'FANTASTIC';
    if (s >= 70.0) return 'GREAT';
    if (s >= 50.0) return 'FAIR';
    return 'POOR';
  }

  Widget _buildBestDriversContent({
    required BuildContext context,
    required List<int> years,
    required Map<int, List<int>> monthsByYear,
    required List<_ReportVM> reports,
    required void Function(VoidCallback) setDialogState,
    required double w,
  }) {
    final t = AppLocalizations.of(context);
    if (reports.isEmpty) {
      return Text(
        t.t('scorecard_overview_no_reports_available'),
        style: TextStyle(fontSize: 12, color: _UI.textSecondary),
      );
    }

    final latest = reports.first;
    final defaultMonthKey = () {
      final m = _monthIndexFromWeek(latest.year, latest.week);
      return '${latest.year}-${m.toString().padLeft(2, '0')}';
    }();

    final currentMonthKey = _selectedMonthKey ?? defaultMonthKey;
    final activeYear =
        _selectedYear ?? (years.isNotEmpty ? years.first : latest.year);

    final isYearView = _periodFilter == _PeriodFilter.year;
    final isMonthView = !isYearView;

    int? filterYear;
    int? filterMonth;
    if (isYearView) {
      filterYear = activeYear;
    } else {
      final parts = currentMonthKey.split('-');
      if (parts.length == 2) {
        filterYear = int.tryParse(parts[0]);
        filterMonth = int.tryParse(parts[1]);
      }
    }

    final periodReports = <_ReportVM>[];
    for (final r in reports) {
      if (filterYear != null && r.year != filterYear) continue;
      if (filterMonth != null) {
        final m = _monthIndexFromWeek(r.year, r.week);
        if (m != filterMonth) continue;
      }
      periodReports.add(r);
    }

    final stationByReportPath = <String, String>{};
    for (final r in periodReports) {
      stationByReportPath[r.ref.path] = _s(r.stationCode).toUpperCase();
    }
    final stationOptions =
        stationByReportPath.values.where((s) => s.isNotEmpty).toSet().toList()
          ..sort();

    final hasValidStation =
        _selectedStationCode != null &&
        stationOptions.contains(_selectedStationCode);
    final stationLabel = hasValidStation
        ? t.tf('scorecard_overview_station_code', {
            'code': _selectedStationCode ?? '',
          })
        : t.t('scorecard_overview_all_stations');

    final scoreStream = (filterYear == null || periodReports.isEmpty)
        ? Stream.value(<QueryDocumentSnapshot<Map<String, dynamic>>>[])
        : _scoresForPeriod(
            year: filterYear,
            reportIds: periodReports.map((e) => e.ref.id).toSet(),
            reportPaths: periodReports.map((e) => e.ref.path).toSet(),
          );

    final pillLabel = isYearView
        ? (filterYear ?? latest.year).toString()
        : (filterMonth != null
              ? _monthNameFromIndex(filterMonth).toUpperCase()
              : _monthNameFromIndex(
                  _monthIndexFromWeek(latest.year, latest.week),
                ).toUpperCase());

    final subtitle = isYearView
        ? (filterYear?.toString() ?? '')
        : (filterMonth != null && filterYear != null
              ? '${_monthNameFromIndex(filterMonth).toUpperCase()} $filterYear'
              : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BestDriversPeriodRow(
          periodLabel: pillLabel,
          stationLabel: stationLabel,
          onPeriodTap: () => _showBestPeriodDialog(
            context: context,
            years: years,
            monthsByYear: monthsByYear,
            onChanged: () => setDialogState(() {}),
          ),
          onStationTap: () => _showStationFilterDialog(
            context: context,
            stations: stationOptions,
            onChanged: () => setDialogState(() {}),
          ),
        ),
        SizedBox(height: _pad(10, w)),
        if (subtitle != null && subtitle.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              isMonthView
                  ? t.t('scorecard_overview_best_drivers_month')
                  : t.t('scorecard_overview_best_drivers_year'),
              style: TextStyle(
                fontSize: _sp(12, w),
                fontWeight: FontWeight.w700,
                color: _UI.textSecondary,
              ),
            ),
          ),
        if (subtitle != null && subtitle.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: _sp(13, w),
                fontWeight: FontWeight.w800,
                color: _UI.textPrimary,
              ),
            ),
          ),
        StreamBuilder<Map<String, String>>(
          stream: _globalNamesStreamCached,
          builder: (context, namesSnap) {
            final names = namesSnap.data ?? const <String, String>{};

            return StreamBuilder<
              List<QueryDocumentSnapshot<Map<String, dynamic>>>
            >(
              stream: scoreStream,
              builder: (context, scoreSnap) {
                if (scoreSnap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final docs = scoreSnap.data ?? [];
                if (docs.isEmpty) {
                  return Text(
                    t.t('scorecard_overview_no_drivers_period'),
                    style: TextStyle(fontSize: 12, color: _UI.textSecondary),
                  );
                }

                final Map<String, Map<String, _DriverAgg>> stationAgg = {};
                for (final d in docs) {
                  final data = d.data();
                  final tid = _normTid(data['transporterId']);
                  if (tid.isEmpty) continue;

                  String station = '';
                  final reportPath = _s(data['reportPath']);
                  if (reportPath.isNotEmpty) {
                    station = stationByReportPath[reportPath] ?? '';
                  } else {
                    final reportRef = data['reportRef'];
                    if (reportRef is DocumentReference) {
                      station = stationByReportPath[reportRef.path] ?? '';
                    } else if (reportRef is String) {
                      station = stationByReportPath[reportRef] ?? '';
                    }
                  }
                  station = station.isEmpty ? 'UNKNOWN' : station;

                  final compRaw = data['comp'] ?? {};
                  final comp = compRaw is Map<String, dynamic>
                      ? compRaw
                      : <String, dynamic>{};
                  final score = _numOr0(comp['FinalScore']).toDouble();

                  final aggMap = stationAgg.putIfAbsent(
                    station,
                    () => <String, _DriverAgg>{},
                  );
                  final agg = aggMap.putIfAbsent(tid, () => _DriverAgg());
                  agg.sumScore += score;
                  agg.count++;
                }

                final stationsSorted = stationAgg.keys.toList()..sort();
                final activeStation =
                    (hasValidStation &&
                        stationAgg.containsKey(_selectedStationCode))
                    ? _selectedStationCode
                    : null;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final station in stationsSorted)
                      if (activeStation == null ||
                          station == activeStation) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6, top: 8),
                          child: Text(
                            station == 'UNKNOWN'
                                ? t.t('scorecard_overview_station')
                                : t.tf('scorecard_overview_station_code', {
                                    'code': station,
                                  }),
                            style: TextStyle(
                              fontSize: _sp(12, w),
                              fontWeight: FontWeight.w800,
                              color: _UI.textPrimary,
                            ),
                          ),
                        ),
                        _buildStationDriverList(
                          stationAgg[station] ?? const <String, _DriverAgg>{},
                          names,
                          t,
                        ),
                      ],
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildStationDriverList(
    Map<String, _DriverAgg> aggMap,
    Map<String, String> names,
    AppLocalizations t,
  ) {
    final entries = <_DriverEntry>[];
    aggMap.forEach((tid, agg) {
      if (agg.count == 0) return;
      entries.add(
        _DriverEntry(
          transporterId: tid,
          avgScore: agg.sumScore / agg.count,
          statusCode: _statusCodeFromScore(agg.sumScore / agg.count),
        ),
      );
    });
    entries.sort((a, b) => b.avgScore.compareTo(a.avgScore));

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final e = entries[i];
        final normalizedTid = _normTid(e.transporterId);
        final name = _s(names[normalizedTid]).isNotEmpty
            ? _s(names[normalizedTid])
            : t.t('dash_no_name');
        final statusText = _prettyStatus(e.statusCode, t);
        final statusColor = _statusColorFromCode(e.statusCode);
        return _BestDriverRow(
          rank: i + 1,
          score: e.avgScore,
          name: name,
          statusText: statusText,
          statusColor: statusColor,
        );
      },
    );
  }

  Future<void> _openBestDriversDialog({
    required BuildContext context,
    required Widget Function(BuildContext, void Function(VoidCallback)) builder,
  }) async {
    final t = AppLocalizations.of(context);
    final media = MediaQuery.of(context).size;
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 820,
                  maxHeight: media.height * 0.85,
                ),
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: _Panel(
                        title: t.t('scorecard_overview_best_drivers'),
                        child: builder(ctx, setDialogState),
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showStationFilterDialog({
    required BuildContext context,
    required List<String> stations,
    VoidCallback? onChanged,
  }) async {
    final t = AppLocalizations.of(context);
    final items = ['ALL', ...stations.where((s) => s.isNotEmpty).toList()];

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      t.t('scorecard_overview_select_station'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final s in items)
                      ChoiceChip(
                        label: Text(
                          s == 'ALL'
                              ? t.t('scorecard_overview_all_stations')
                              : s,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        selected: s == 'ALL'
                            ? _selectedStationCode == null
                            : _selectedStationCode == s,
                        onSelected: (_) {
                          setState(() {
                            _selectedStationCode = s == 'ALL' ? null : s;
                          });
                          onChanged?.call();
                          Navigator.of(ctx).pop();
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showBestPeriodDialog({
    required BuildContext context,
    required List<int> years,
    required Map<int, List<int>> monthsByYear,
    VoidCallback? onChanged,
  }) async {
    final t = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        t.t('scorecard_overview_select_period'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      t.t('scorecard_overview_best_drivers_year'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final y in years)
                        ChoiceChip(
                          label: Text(
                            y.toString(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          selected:
                              _periodFilter == _PeriodFilter.year &&
                              _selectedYear == y,
                          onSelected: (_) {
                            setState(() {
                              _periodFilter = _PeriodFilter.year;
                              _selectedYear = y;
                              _selectedMonthKey = null;
                            });
                            onChanged?.call();
                            Navigator.of(ctx).pop();
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      t.t('scorecard_overview_best_drivers_month'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final y in years) ...[
                        if ((monthsByYear[y] ?? []).isNotEmpty) ...[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              y.toString(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              for (final m in monthsByYear[y]!)
                                ChoiceChip(
                                  label: Text(
                                    _shortMonthName(m),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  selected:
                                      _periodFilter == _PeriodFilter.month &&
                                      _selectedMonthKey ==
                                          '$y-${m.toString().padLeft(2, '0')}',
                                  onSelected: (_) {
                                    setState(() {
                                      _periodFilter = _PeriodFilter.month;
                                      _selectedYear = y;
                                      _selectedMonthKey =
                                          '$y-${m.toString().padLeft(2, '0')}';
                                    });
                                    onChanged?.call();
                                    Navigator.of(ctx).pop();
                                  },
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                        ],
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _uploadWeeklyPdf() async {
    final t = AppLocalizations.of(context);
    if (_busyUpload) return;
    setState(() => _busyUpload = true);

    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
        allowMultiple: true, // 👈 allow selecting multiple PDFs
      );

      if (picked == null || picked.files.isEmpty) {
        return; // user cancelled
      }

      int successCount = 0;

      for (final f in picked.files) {
        final Uint8List? bytes = f.bytes;
        if (bytes == null) continue; // skip weird cases

        // ✅ Parse directly (no Firebase Storage)
        final parsed = await ParserApi.parsePdf(bytes, filename: f.name);

        // ✅ Write to Firestore — keep a pseudo storagePath for traceability
        final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
        final pseudoPath = 'inline/$date/${f.name}'; // informational only

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
                ? t.t('scorecard_overview_upload_success_one')
                : t.tf('scorecard_overview_upload_success_many', {
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
            t.tf('scorecard_overview_upload_parse_failed', {'error': '$e'}),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _busyUpload = false);
    }
  }

  Future<void> _uploadDriverCsv() async {
    final t = AppLocalizations.of(context);
    if (_busyCsv) return;
    setState(() => _busyCsv = true);
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );
      if (picked == null || picked.files.isEmpty) {
        setState(() => _busyCsv = false);
        return;
      }
      final f = picked.files.single;
      final Uint8List? bytes = f.bytes;
      if (bytes == null)
        throw Exception(t.t('scorecard_overview_no_file_bytes'));

      // ✅ NEW: user-scoped update so ALL of this user’s reports/scores get names
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final result = await DriverCsvService.importForUser(
        uid: uid,
        csvBytes: bytes,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${t.t('scorecard_overview_csv_updated')} '
            'Parsed ${result.parsedRows}, '
            'matched ${result.mappedDrivers}, '
            'new ${result.newDrivers}, '
            'score rows updated ${result.updatedScores}.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.tf('scorecard_overview_csv_failed', {'error': '$e'})),
        ),
      );
    } finally {
      if (mounted) setState(() => _busyCsv = false);
    }
  }

  // ---- delete a report doc and its linked score rows ----
  Future<void> _confirmAndDeleteReport(
    BuildContext context, {
    required DocumentReference<Map<String, dynamic>> reportRef,
    required String titleLabel,
  }) async {
    final t = AppLocalizations.of(context);
    final w = MediaQuery.of(context).size.width;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.t('scorecard_overview_delete_report_q')),
        content: Text(
          t.tf('scorecard_overview_delete_report_body', {'title': titleLabel}),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(t.t('admin_home_cancel')),
          ),
          FilledButton(
            style: AppButtonStyle.of(AppButtonVariant.destructive),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(t.t('admin_home_delete')),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception(t.t('admin_home_not_logged_in'));
      final db = FirebaseFirestore.instance;
      final scoresCol = db.collection('users').doc(uid).collection('scores');
      final reportPath = reportRef.path;
      final reportId = reportRef.id;

      final scoreRefs = <String, DocumentReference<Map<String, dynamic>>>{};
      Future<void> collect(Query<Map<String, dynamic>> q) async {
        final snap = await q.get();
        for (final d in snap.docs) {
          scoreRefs[d.id] = d.reference;
        }
      }

      await collect(scoresCol.where('reportId', isEqualTo: reportId));
      await collect(scoresCol.where('reportPath', isEqualTo: reportPath));

      if (scoreRefs.isNotEmpty) {
        final refs = scoreRefs.values.toList(growable: false);
        for (var i = 0; i < refs.length; i += 450) {
          final batch = db.batch();
          final end = i + 450 < refs.length ? i + 450 : refs.length;
          for (var j = i; j < end; j++) {
            batch.delete(refs[j]);
          }
          await batch.commit();
        }
      }

      final driverNamesSnap = await reportRef.collection('driverNames').get();
      if (driverNamesSnap.docs.isNotEmpty) {
        for (var i = 0; i < driverNamesSnap.docs.length; i += 450) {
          final batch = db.batch();
          final end = i + 450 < driverNamesSnap.docs.length
              ? i + 450
              : driverNamesSnap.docs.length;
          for (var j = i; j < end; j++) {
            batch.delete(driverNamesSnap.docs[j].reference);
          }
          await batch.commit();
        }
      }

      await reportRef.delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.t('scorecard_overview_deleted'))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t.tf('scorecard_overview_delete_failed', {'error': '$e'}),
          ),
        ),
      );
    }
  }

  void _handleReportMenuAction(
    String action, {
    required DocumentReference<Map<String, dynamic>> reportRef,
    required String titleLabel,
  }) {
    if (action != 'delete') return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _confirmAndDeleteReport(
        context,
        reportRef: reportRef,
        titleLabel: titleLabel,
      );
    });
  }

  /* ---------------- Stats helpers ---------------- */
  double? _avg(Iterable<double?> xs) {
    final v = xs.whereType<double>().toList();
    if (v.isEmpty) return null;
    return v.reduce((a, b) => a + b) / v.length;
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final sc = _scaleForWidth(w);
    final narrow = _isNarrow(context);
    final t = AppLocalizations.of(context);

    final body = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main content area (no local drawer/side menu here; handled by AppShell)
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: EdgeInsets.all(_pad(18, w)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row (hidden on narrow because AppBar from shell already shows a title)
                    if (!narrow)
                      Row(
                        children: [
                          Expanded(
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: _pad(8, w),
                              children: [
                                Text(
                                  t.t('scorecard_overview_title'),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontSize: _sp(24, w),
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: .2,
                                        color: _UI.textPrimary,
                                      ),
                                ),
                                Text(
                                  t.t('scorecard_overview_overview_suffix'),
                                  style: TextStyle(
                                    fontSize: _sp(13, w),
                                    color: _UI.textSecondary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          FilledButton.icon(
                            onPressed: _busyCsv ? null : _uploadDriverCsv,
                            style: AppButtonStyle.of(
                              AppButtonVariant.secondary,
                            ),
                            icon: const Icon(Icons.upload_file),
                            label: Text(
                              _busyCsv
                                  ? t.t('uploading')
                                  : t.t('dash_upload_driver_csv'),
                            ),
                          ),
                        ],
                      ),
                    if (!narrow) SizedBox(height: _pad(16, w)),

                    Expanded(
                      child: StreamBuilder<List<_ReportVM>>(
                        stream: _reportsStream(),
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
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
                          final list = snap.data ?? const <_ReportVM>[];

                          // ======== EMPTY STATE (upload panel + summary) ========
                          if (list.isEmpty) {
                            final uploadPanel = _Panel(
                              title: t.t('scorecard_overview_upload_pdf'),
                              trailing: Icon(
                                Icons.more_horiz,
                                color: _UI.textSecondary,
                                size: _sp(20, w),
                              ),
                              child: LayoutBuilder(
                                builder: (context, c) {
                                  final iconSize = w < 380
                                      ? _sp(28, w)
                                      : _sp(34, w);
                                  final gap = w < 380 ? _pad(6, w) : _pad(8, w);
                                  return Container(
                                    constraints: const BoxConstraints(
                                      minHeight: 120,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: _pad(12, w),
                                    ),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        16 * sc,
                                      ),
                                      border: Border.all(color: _UI.border),
                                      color: _UI.bg,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.upload_rounded,
                                          size: iconSize,
                                        ),
                                        SizedBox(height: gap),
                                        Text(
                                          _busyUpload
                                              ? t.t('uploading')
                                              : t.t(
                                                  'scorecard_overview_upload_prompt',
                                                ),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: _sp(13, w),
                                            color: _UI.textSecondary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: gap),
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            minWidth: 140,
                                          ),
                                          child: FilledButton(
                                            onPressed: _busyUpload
                                                ? null
                                                : _uploadWeeklyPdf,
                                            style: AppButtonStyle.of(
                                              AppButtonVariant.primary,
                                            ),
                                            child: Text(
                                              t.t(
                                                'scorecard_overview_choose_file',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            );

                            final summaryRight = _Panel(
                              title: t.t('scorecard_overview_summary_title'),
                              trailing: Icon(
                                Icons.more_horiz,
                                color: _UI.textSecondary,
                                size: _sp(20, w),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(_pad(12, w)),
                                child: Text(
                                  t.t('scorecard_overview_no_reports_yet'),
                                  style: TextStyle(
                                    color: _UI.textSecondary,
                                    fontSize: _sp(13, w),
                                  ),
                                ),
                              ),
                            );

                            if (narrow) {
                              return ListView(
                                children: [
                                  uploadPanel,
                                  SizedBox(height: _pad(16, w)),
                                  summaryRight,
                                ],
                              );
                            } else {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: ListView(children: [uploadPanel]),
                                  ),
                                  SizedBox(width: _pad(16, w)),
                                  Expanded(flex: 2, child: summaryRight),
                                ],
                              );
                            }
                          }

                          // ======== NON-EMPTY ========
                          final latest = list.first;
                          final currentYear = latest.year;

                          final byYear = <int, List<_ReportVM>>{};
                          for (final r in list) {
                            byYear.putIfAbsent(r.year, () => []).add(r);
                          }
                          final ytd = byYear[currentYear] ?? [];

                          final ytdOverall = _avg(ytd.map((e) => e.overall));
                          final ytdRel = _avg(
                            ytd.map((e) => e.relNext ?? e.relSame),
                          );

                          double? lastWeekOverallDelta, lastWeekRelDelta;
                          if (list.length >= 2) {
                            final prev = list[1];
                            if (latest.overall != null &&
                                prev.overall != null) {
                              lastWeekOverallDelta =
                                  latest.overall! - prev.overall!;
                            }
                            final lRel = latest.relNext ?? latest.relSame;
                            final pRel = prev.relNext ?? prev.relSame;
                            if (lRel != null && pRel != null) {
                              lastWeekRelDelta = lRel - pRel;
                            }
                          }

                          double? yoyOverallDelta, yoyRelDelta;
                          final prevYear = currentYear - 1;
                          if (byYear.containsKey(prevYear)) {
                            final py = byYear[prevYear]!;
                            final pyOverall = _avg(py.map((e) => e.overall));
                            final cyOverall = ytdOverall;
                            if (pyOverall != null && cyOverall != null) {
                              yoyOverallDelta = cyOverall - pyOverall;
                            }
                            final pyRel = _avg(
                              py.map((e) => e.relNext ?? e.relSame),
                            );
                            if (ytdRel != null && pyRel != null) {
                              yoyRelDelta = ytdRel - pyRel;
                            }
                          }

                          final chart = list
                              .take(12)
                              .toList()
                              .reversed
                              .toList();

                          final yearsAvailable = <int>{};
                          final Map<int, Set<int>> monthsByYear = {};
                          for (final r in list) {
                            yearsAvailable.add(r.year);
                            final m = _monthIndexFromWeek(r.year, r.week);
                            monthsByYear
                                .putIfAbsent(r.year, () => <int>{})
                                .add(m);
                          }

                          final sortedYears = yearsAvailable.toList()
                            ..sort((a, b) => b.compareTo(a));
                          final Map<int, List<int>> sortedMonthsByYear = {
                            for (final y in sortedYears)
                              y: (monthsByYear[y]?.toList() ?? [])
                                ..sort((a, b) => a.compareTo(b)),
                          };

                          // ----- LEFT column content
                          final leftColumnContent = <Widget>[
                            _ResponsiveStatStrip(
                              latestOverall: latest.overall,
                              ytdOverall: ytdOverall,
                              lastWeekOverallDelta: lastWeekOverallDelta,
                              yoyOverallDelta: yoyOverallDelta,
                              latestRel: latest.relNext ?? latest.relSame,
                              ytdRel: ytdRel,
                              lastWeekRelDelta: lastWeekRelDelta,
                              yoyRelDelta: yoyRelDelta,
                              yearLabel: latest.year.toString(),
                            ),
                            SizedBox(height: _pad(16, w)),
                            _Panel(
                              title: t.t('scorecard_overview_chart_title'),
                              child: _MiniBarChart(
                                points: chart
                                    .map(
                                      (p) => _BarPoint(
                                        label:
                                            'W${p.week.toString().padLeft(2, '0')}',
                                        value: p.overall ?? 0,
                                        ref: p.ref,
                                        overallStatus: p.overallStatus,
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                            SizedBox(height: _pad(16, w)),
                            _Panel(
                              title: t.t('scorecard_overview_upload_pdf'),
                              trailing: Icon(
                                Icons.more_horiz,
                                color: _UI.textSecondary,
                                size: _sp(20, w),
                              ),
                              child: LayoutBuilder(
                                builder: (context, c) {
                                  final iconSize = w < 380
                                      ? _sp(28, w)
                                      : _sp(34, w);
                                  final gap = w < 380 ? _pad(6, w) : _pad(8, w);
                                  return Container(
                                    constraints: const BoxConstraints(
                                      minHeight: 120,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: _pad(12, w),
                                    ),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        16 * sc,
                                      ),
                                      border: Border.all(color: _UI.border),
                                      color: _UI.bg,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.upload_rounded,
                                          size: iconSize,
                                        ),
                                        SizedBox(height: gap),
                                        Text(
                                          _busyUpload
                                              ? t.t('uploading')
                                              : t.t(
                                                  'scorecard_overview_upload_prompt',
                                                ),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: _sp(13, w),
                                            color: _UI.textSecondary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: gap),
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            minWidth: 140,
                                          ),
                                          child: FilledButton(
                                            onPressed: _busyUpload
                                                ? null
                                                : _uploadWeeklyPdf,
                                            style: AppButtonStyle.of(
                                              AppButtonVariant.primary,
                                            ),
                                            child: Text(
                                              t.t(
                                                'scorecard_overview_choose_file',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ];

                          final bestDriversButton = TextButton.icon(
                            onPressed: () => _openBestDriversDialog(
                              context: context,
                              builder: (ctx, setDialogState) =>
                                  _buildBestDriversContent(
                                    context: ctx,
                                    years: sortedYears,
                                    monthsByYear: sortedMonthsByYear,
                                    reports: list,
                                    setDialogState: setDialogState,
                                    w: w,
                                  ),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: _UI.greenDark,
                              padding: EdgeInsets.symmetric(
                                horizontal: _pad(10, w),
                                vertical: _pad(6, w),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                                side: const BorderSide(
                                  color: _UI.greenDark,
                                  width: 1.1,
                                ),
                              ),
                            ),
                            icon: Icon(
                              Icons.emoji_events_outlined,
                              size: _sp(14, w),
                            ),
                            label: Text(
                              t.t('scorecard_overview_best_drivers'),
                              style: TextStyle(
                                fontSize: _sp(11, w),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          );

                          // ----- RIGHT panel (summary list) with 3-dots delete menu
                          final rightPanel = _Panel(
                            title: t.t('scorecard_overview_summary_title'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                bestDriversButton,
                                SizedBox(width: _pad(6, w)),
                                Icon(
                                  Icons.more_horiz,
                                  color: _UI.textSecondary,
                                  size: _sp(20, w),
                                ),
                              ],
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: list.length,
                              separatorBuilder: (_, __) =>
                                  Divider(height: 1, color: _UI.border),
                              itemBuilder: (_, i) {
                                final p = list[i];
                                final badge = (p.overall != null)
                                    ? _pct2.format(p.overall)
                                    : '—';

                                final start = _isoWeekStartUtc(p.year, p.week);
                                final end = start.add(const Duration(days: 6));
                                final dateRange =
                                    '${_dotted(start)} – ${_dotted(end)}';

                                final rankLine =
                                    (p.rankAtStation != null &&
                                        p.stationCount != null)
                                    ? '${t.t('dash_rank_in_station')}: ${t.tf('dash_rank_of_total', {'rank': '${p.rankAtStation}', 'total': '${p.stationCount}'})}'
                                    : '${_s(p.stationCode)} • ${_prettyStatus(p.overallStatus, t)}';

                                final rowTitle = t.tf(
                                  'scorecard_overview_row_title',
                                  {'year': '${p.year}', 'week': '${p.week}'},
                                );

                                return ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: _pad(8, w),
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: _UI.green.withOpacity(.2),
                                    radius: _pad(26, w),
                                    child: Text(
                                      badge,
                                      style: TextStyle(
                                        color: _UI.greenDark,
                                        fontWeight: FontWeight.w800,
                                        fontSize: _sp(12, w),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    rowTitle,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: _sp(14, w),
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: _pad(2, w)),
                                      Text(
                                        dateRange,
                                        style: TextStyle(
                                          color: _UI.textSecondary,
                                          fontSize: _sp(12, w),
                                        ),
                                      ),
                                      Text(
                                        '• $rankLine • ',
                                        style: TextStyle(
                                          color: _UI.textSecondary,
                                          fontSize: _sp(12, w),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      PopupMenuButton<String>(
                                        tooltip: t.t('scorecard_overview_more'),
                                        onSelected: (v) =>
                                            _handleReportMenuAction(
                                              v,
                                              reportRef: p.ref,
                                              titleLabel: rowTitle,
                                            ),
                                        itemBuilder: (ctx) => [
                                          PopupMenuItem<String>(
                                            value: 'delete',
                                            child: Text(
                                              t.t(
                                                'scorecard_overview_delete_report_menu',
                                              ),
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.w700,
                                                fontSize: _sp(13, w),
                                              ),
                                            ),
                                          ),
                                        ],
                                        icon: const Icon(Icons.more_vert),
                                      ),
                                      SizedBox(width: _pad(4, w)),
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        size: _sp(22, w),
                                      ),
                                    ],
                                  ),
                                  onTap: () => Navigator.of(context).push(
                                    PageRouteBuilder(
                                      pageBuilder: (_, __, ___) =>
                                          ScorecardWeekShellPage(
                                            reportRef: p.ref,
                                          ),
                                      transitionDuration: Duration.zero,
                                      reverseTransitionDuration: Duration.zero,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );

                          if (narrow) {
                            return ListView(
                              children: [
                                ...leftColumnContent,
                                SizedBox(height: _pad(16, w)),
                                rightPanel,
                              ],
                            );
                          } else {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: ListView(children: leftColumnContent),
                                ),
                                SizedBox(width: _pad(16, w)),
                                Expanded(
                                  flex: 2,
                                  child: ListView(children: [rightPanel]),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );

    // Use shared AppShell + shared side menu
    return Stack(
      children: [
        Container(color: _UI.bg, child: body),

        if (_busyUpload) ...[
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.08),
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        t.t('scorecard_overview_upload_processing'),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/* ====================  UI helpers  ==================== */

class _Panel extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;
  const _Panel({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        color: _UI.card,
        borderRadius: BorderRadius.circular(18 * _scaleForWidth(w)),
        boxShadow: AppElevation.level1,
      ),
      padding: EdgeInsets.all(_pad(20, w)),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: _sp(17, w),
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.43,
                  color: _UI.textPrimary,
                ),
              ),
              const Spacer(),
              if (trailing != null) trailing!,
            ],
          ),
          SizedBox(height: _pad(16, w)),
          child,
        ],
      ),
    );
  }
}

class _DriverAgg {
  double sumScore = 0;
  int count = 0;
}

class _DriverEntry {
  final String transporterId;
  final double avgScore;
  final String statusCode;

  const _DriverEntry({
    required this.transporterId,
    required this.avgScore,
    required this.statusCode,
  });
}

class _BestDriversPeriodRow extends StatelessWidget {
  final String periodLabel;
  final String? stationLabel;
  final VoidCallback onPeriodTap;
  final VoidCallback? onStationTap;

  const _BestDriversPeriodRow({
    required this.periodLabel,
    this.stationLabel,
    required this.onPeriodTap,
    this.onStationTap,
  });

  @override
  Widget build(BuildContext context) {
    const pillHeight = 38.0;

    BoxDecoration _pillDec() {
      return BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _UI.greenDark, width: 1.2),
      );
    }

    const pillTextStyle = TextStyle(
      fontSize: 11,
      letterSpacing: 0.6,
      fontWeight: FontWeight.w700,
      color: Colors.black87,
    );

    Widget _pill(String text, VoidCallback? onTap) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: pillHeight,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: _pillDec(),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                children: [
                  Text(text.toUpperCase(), style: pillTextStyle),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: Colors.black87,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (stationLabel == null || onStationTap == null) {
      return _pill(periodLabel, onPeriodTap);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTight = constraints.maxWidth < 520;
        final periodPill = _pill(periodLabel, onPeriodTap);
        final stationPill = _pill(stationLabel!, onStationTap);

        if (!isTight) {
          return Row(
            children: [
              Expanded(child: periodPill),
              const SizedBox(width: 8),
              Expanded(child: stationPill),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [periodPill, const SizedBox(height: 8), stationPill],
        );
      },
    );
  }
}

class _BestDriverRow extends StatelessWidget {
  final int rank;
  final double score;
  final String name;
  final String statusText;
  final Color statusColor;
  final Color? backgroundColor;

  const _BestDriverRow({
    required this.rank,
    required this.score,
    required this.name,
    required this.statusText,
    required this.statusColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isColored = backgroundColor != null;
    final textColor = isColored ? Colors.white : _UI.textPrimary;
    final labelColor = isColored ? Colors.white70 : _UI.textSecondary;
    final pillTextColor = isColored ? Colors.white : statusColor;
    final pillBgColor = isColored
        ? Colors.white.withOpacity(0.2)
        : statusColor.withOpacity(0.15);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: backgroundColor ?? _UI.border, width: 1.2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: _bestCol(
                  label: t.t('dash_rank').toUpperCase(),
                  value: '#$rank',
                  labelColor: labelColor,
                  textColor: textColor,
                ),
              ),
              _bestDivider(isColored),
              Expanded(
                child: _bestCol(
                  label: t.t('dash_score').toUpperCase(),
                  value: _pct2.format(score),
                  labelColor: labelColor,
                  textColor: textColor,
                ),
              ),
              _bestDivider(isColored),
              Expanded(
                flex: 2,
                child: _bestCol(
                  label: t.t('dash_name').toUpperCase(),
                  value: name.isEmpty ? t.t('dash_no_name') : name,
                  labelColor: labelColor,
                  textColor: textColor,
                ),
              ),
            ],
          ),
          if (statusText.isNotEmpty) ...[
            const SizedBox(height: 8),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: pillBgColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusText.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: pillTextColor,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _bestDivider(bool isColored) {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: isColored ? Colors.white.withOpacity(0.5) : _UI.border,
    );
  }

  Widget _bestCol({
    required String label,
    required String value,
    required Color labelColor,
    required Color textColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 9,
            letterSpacing: 1.1,
            color: labelColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double? value; // percent
  final double? delta; // change vs prev period
  final String deltaCaption;
  const _StatCard({
    required this.title,
    required this.subtitle,
    required this.value,
    this.delta,
    this.deltaCaption = '',
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final sc = _scaleForWidth(w);
    final isUp = (delta ?? 0) >= 0;
    final deltaAreaMinHeight = _pad(46, w);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _UI.card,
        borderRadius: BorderRadius.circular(18 * sc),
        boxShadow: AppElevation.level1,
      ),
      padding: EdgeInsets.all(_pad(20, w)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _sp(12, w),
              color: _UI.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: .6,
            ),
          ),
          SizedBox(height: _pad(4, w)),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _sp(12, w),
              color: _UI.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: _pad(8, w)),
          Text(
            value != null ? '${_pct2.format(value)} %' : '—',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _sp(28, w),
              fontWeight: FontWeight.w700,
              color: _UI.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: _pad(8, w)),
          SizedBox(
            width: double.infinity,
            height: deltaAreaMinHeight,
            child: delta == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: EdgeInsets.only(top: _pad(4, w)),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: _pad(6, w),
                      runSpacing: _pad(2, w),
                      children: [
                        Icon(
                          isUp ? Icons.trending_up : Icons.trending_down,
                          size: _sp(16, w),
                          color: isUp ? _UI.greenDark : Colors.red,
                        ),
                        Text(
                          '${isUp ? '+' : ''}${_pct2.format(delta!.abs())} %',
                          style: TextStyle(
                            fontSize: _sp(13, w),
                            color: isUp ? _UI.greenDark : Colors.red,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          deltaCaption,
                          style: TextStyle(
                            color: _UI.textSecondary,
                            fontSize: _sp(12, w),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/* ====================  Chart (unchanged)  ==================== */

class _BarPoint {
  final String label;
  final double value;
  final DocumentReference<Map<String, dynamic>> ref;
  final String? overallStatus;
  _BarPoint({
    required this.label,
    required this.value,
    required this.ref,
    this.overallStatus,
  });
}

class _MiniBarChart extends StatelessWidget {
  final List<_BarPoint> points;
  const _MiniBarChart({required this.points});

  /// Tier color from the scorecard `overallStatus` code as used elsewhere
  /// in this file. Falls back to neutral when the status is unknown.
  Color _colorForStatus(String? status) {
    switch (_s(status).trim().toUpperCase()) {
      case 'FANTASTIC_PLUS':
        return _kFantasticPlusColor;
      case 'FANTASTIC':
        return _kFantasticColor;
      case 'GREAT':
        return _kGreatColor;
      case 'FAIR':
        return _kFairColor;
      case 'POOR':
        return _kPoorColor;
      default:
        return AppColors.labelTertiaryLight;
    }
  }

  String _labelForStatus(String? status) {
    switch (_s(status).trim().toUpperCase()) {
      case 'FANTASTIC_PLUS':
        return 'FANTASTIC +';
      case 'FANTASTIC':
        return 'FANTASTIC';
      case 'GREAT':
        return 'GREAT';
      case 'FAIR':
        return 'FAIR';
      case 'POOR':
        return 'POOR';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final sc = _scaleForWidth(w);

    const axisMax = 100.0;
    final isNarrow = _isNarrow(context);

    final xLabelAreaH = (_pad(36, w)).clamp(28.0, 56.0);
    final valueLabelH = _pad(22, w).clamp(18.0, 30.0);
    final chartH = (isNarrow ? _pad(280, w) : _pad(340, w));

    return SizedBox(
      height: chartH,
      child: LayoutBuilder(
        builder: (context, c) {
          // Width per slot grows/shrinks with available space and bar count.
          final slotW =
              ((c.maxWidth - _pad(60, w)) / points.length).clamp(14.0, 44.0);
          final barW = (slotW * 0.55).clamp(8.0, 22.0) * sc;

          return Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceElevatedLight,
              borderRadius: BorderRadius.circular(18 * sc),
              boxShadow: AppElevation.level1,
            ),
            padding: EdgeInsets.all(_pad(20, w)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Y-axis labels (aligned with the bar area only)
                Padding(
                  padding: EdgeInsets.only(
                    top: valueLabelH,
                    bottom: xLabelAreaH,
                  ),
                  child: SizedBox(
                    width: _pad(34, w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [100, 80, 60, 40, 20, 0]
                          .map(
                            (v) => Text(
                              '$v',
                              style: TextStyle(
                                color: AppColors.labelTertiaryLight,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                SizedBox(width: _pad(8, w)),

                // Chart area
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, area) {
                      final barsAreaH =
                          area.maxHeight - xLabelAreaH - valueLabelH;

                      return Stack(
                        children: [
                          // Grid lines (5 horizontal lines)
                          Positioned.fill(
                            top: valueLabelH,
                            bottom: xLabelAreaH,
                            child: Column(
                              children: List.generate(
                                5,
                                (_) => Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                          color: AppColors.separatorLight
                                              .withOpacity(0.6),
                                          width: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Bottom baseline (slightly stronger)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: xLabelAreaH - 0.5,
                            child: Container(
                              height: 1,
                              color: AppColors.separatorLight,
                            ),
                          ),

                          // Bars + value labels (each slot uses Expanded
                          // so any number of bars fits the available width)
                          Positioned.fill(
                            top: 0,
                            bottom: xLabelAreaH,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: points.map((p) {
                                final v = p.value.clamp(0, axisMax).toDouble();
                                final h = (v / axisMax) * barsAreaH;
                                final barColor = _colorForStatus(
                                  p.overallStatus,
                                );
                                return Expanded(
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: () => Navigator.of(context).push(
                                        PageRouteBuilder(
                                          pageBuilder: (_, __, ___) =>
                                              ScorecardWeekShellPage(
                                                reportRef: p.ref,
                                              ),
                                          transitionDuration: Duration.zero,
                                          reverseTransitionDuration:
                                              Duration.zero,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          // Value label above the bar
                                          SizedBox(
                                            height: valueLabelH,
                                            child: Center(
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(
                                                  v.toStringAsFixed(0),
                                                  style: TextStyle(
                                                    fontSize: _sp(12, w),
                                                    fontWeight: FontWeight.w700,
                                                    color: barColor,
                                                    letterSpacing: -0.3,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          // The bar itself (centered in its slot)
                                          AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 320,
                                            ),
                                            curve: Curves.easeOutCubic,
                                            height: h,
                                            width: barW,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  barColor.withOpacity(0.85),
                                                  barColor,
                                                ],
                                              ),
                                              borderRadius:
                                                  const BorderRadius.vertical(
                                                    top: Radius.circular(8),
                                                    bottom: Radius.circular(2),
                                                  ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: barColor.withOpacity(
                                                    0.25,
                                                  ),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            // Vertical status label inside the bar
                                            // Only render when the bar is tall
                                            // enough to comfortably fit the text.
                                            child: h < 70
                                                ? null
                                                : Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 10,
                                                        ),
                                                    child: Center(
                                                      child: RotatedBox(
                                                        quarterTurns: 3,
                                                        child: FittedBox(
                                                          fit: BoxFit.scaleDown,
                                                          child: Text(
                                                            _labelForStatus(
                                                              p.overallStatus,
                                                            ),
                                                            maxLines: 1,
                                                            softWrap: false,
                                                            overflow:
                                                                TextOverflow
                                                                    .clip,
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                    0.55,
                                                                  ),
                                                              fontSize: 9,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                              letterSpacing:
                                                                  1.4,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                          // X labels strip — each slot uses Expanded so
                          // every column fits without horizontal overflow
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            height: xLabelAreaH,
                            child: Row(
                              children: points.map((p) {
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      p.label,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: _sp(11, w),
                                        color: AppColors.labelSecondaryLight,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/* ====================  Stat strip  ==================== */

class _ResponsiveStatStrip extends StatelessWidget {
  final double? latestOverall;
  final double? ytdOverall;
  final double? lastWeekOverallDelta;
  final double? yoyOverallDelta;

  final double? latestRel;
  final double? ytdRel;
  final double? lastWeekRelDelta;
  final double? yoyRelDelta;

  final String yearLabel;

  const _ResponsiveStatStrip({
    super.key,
    required this.latestOverall,
    required this.ytdOverall,
    required this.lastWeekOverallDelta,
    required this.yoyOverallDelta,
    required this.latestRel,
    required this.ytdRel,
    required this.lastWeekRelDelta,
    required this.yoyRelDelta,
    required this.yearLabel,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final w = MediaQuery.of(context).size.width;

    if (w >= 1280) {
      // Desktop: one row of 4
      return Row(
        children: [
          Expanded(
            child: _StatCard(
              title: t.t('nav_scorecard'),
              subtitle: t.t('admin_home_last_week').toUpperCase(),
              value: latestOverall,
              deltaCaption: t.t('scorecard_overview_from_last_week'),
              delta: lastWeekOverallDelta,
            ),
          ),
          SizedBox(width: _pad(12, w)),
          Expanded(
            child: _StatCard(
              title: t.t('nav_scorecard'),
              subtitle: '${t.t('admin_home_year_prefix')} $yearLabel',
              value: ytdOverall,
              deltaCaption: t.t('scorecard_overview_from_last_year'),
              delta: yoyOverallDelta,
            ),
          ),
          SizedBox(width: _pad(12, w)),
          Expanded(
            child: _StatCard(
              title: t.t('scorecard_overview_reliability_score'),
              subtitle: t.t('admin_home_last_week').toUpperCase(),
              value: latestRel,
              deltaCaption: t.t('scorecard_overview_from_last_week'),
              delta: lastWeekRelDelta,
            ),
          ),
          SizedBox(width: _pad(12, w)),
          Expanded(
            child: _StatCard(
              title: t.t('scorecard_overview_reliability_score'),
              subtitle: '${t.t('admin_home_year_prefix')} $yearLabel',
              value: ytdRel,
              deltaCaption: t.t('scorecard_overview_from_last_year'),
              delta: yoyRelDelta,
            ),
          ),
        ],
      );
    } else if (w >= 800) {
      // Tablet: 2×2
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: t.t('nav_scorecard'),
                  subtitle: t.t('admin_home_last_week').toUpperCase(),
                  value: latestOverall,
                  deltaCaption: t.t('scorecard_overview_from_last_week'),
                  delta: lastWeekOverallDelta,
                ),
              ),
              SizedBox(width: _pad(12, w)),
              Expanded(
                child: _StatCard(
                  title: t.t('nav_scorecard'),
                  subtitle: '${t.t('admin_home_year_prefix')} $yearLabel',
                  value: ytdOverall,
                  deltaCaption: t.t('scorecard_overview_from_last_year'),
                  delta: yoyOverallDelta,
                ),
              ),
            ],
          ),
          SizedBox(height: _pad(12, w)),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: t.t('scorecard_overview_reliability_score'),
                  subtitle: t.t('admin_home_last_week').toUpperCase(),
                  value: latestRel,
                  deltaCaption: t.t('scorecard_overview_from_last_week'),
                  delta: lastWeekRelDelta,
                ),
              ),
              SizedBox(width: _pad(12, w)),
              Expanded(
                child: _StatCard(
                  title: t.t('scorecard_overview_reliability_score'),
                  subtitle: '${t.t('admin_home_year_prefix')} $yearLabel',
                  value: ytdRel,
                  deltaCaption: t.t('scorecard_overview_from_last_year'),
                  delta: yoyRelDelta,
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      // Mobile: stacked
      return Column(
        children: [
          _StatCard(
            title: t.t('nav_scorecard'),
            subtitle: t.t('admin_home_last_week').toUpperCase(),
            value: latestOverall,
            deltaCaption: t.t('scorecard_overview_from_last_week'),
            delta: lastWeekOverallDelta,
          ),
          SizedBox(height: _pad(12, w)),
          _StatCard(
            title: t.t('nav_scorecard'),
            subtitle: '${t.t('admin_home_year_prefix')} $yearLabel',
            value: ytdOverall,
            deltaCaption: t.t('scorecard_overview_from_last_year'),
            delta: yoyOverallDelta,
          ),
          SizedBox(height: _pad(12, w)),
          _StatCard(
            title: t.t('scorecard_overview_reliability_score'),
            subtitle: t.t('admin_home_last_week').toUpperCase(),
            value: latestRel,
            deltaCaption: t.t('scorecard_overview_from_last_week'),
            delta: lastWeekRelDelta,
          ),
          SizedBox(height: _pad(12, w)),
          _StatCard(
            title: t.t('scorecard_overview_reliability_score'),
            subtitle: '${t.t('admin_home_year_prefix')} $yearLabel',
            value: ytdRel,
            deltaCaption: t.t('scorecard_overview_from_last_year'),
            delta: yoyRelDelta,
          ),
        ],
      );
    }
  }
}
