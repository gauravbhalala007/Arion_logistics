// lib/screens/scorecard_overview.dart
import 'dart:typed_data';

import '../services/parser_api.dart';
import '../services/report_section_remover.dart';
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
import '../utils/driver_activity.dart';
import '../theme/app_colors.dart';
import '../theme/app_elevation.dart';
import '../theme/app_typography.dart';
import '../widgets/admin_scope.dart';
import '../widgets/co_button.dart';
import '../widgets/co_pressable.dart';
import '../widgets/pill_tab_bar.dart';
import '../widgets/report_source_hint.dart';

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
    // No wrapper AppBar here — ScorecardWeekPage brings its own header
    // (avoids a duplicated header + double back arrow on mobile).
    return ScorecardWeekPage(reportRef: reportRef);
  }
}

class _ScorecardOverviewPageState extends State<ScorecardOverviewPage>
    with TickerProviderStateMixin {
  bool _busyUpload = false; // PDFs (bottom-left)
  bool _busyCsv = false; // CSVs (top-right)

  // Default-Filter ist die Jahresansicht — zeigt sofort die Top-Driver
  // über das ganze Jahr ohne dass der Admin erst auf „Year" klicken muss.
  _PeriodFilter _periodFilter = _PeriodFilter.year;
  String? _selectedMonthKey;
  int? _selectedYear;
  String? _selectedStationCode;

  /// Top segmented control: 0 = Company Score view, 1 = Best Driver view.
  /// Replaces the previous Best-Drivers popup dialog — Best-Drivers is now
  /// just the second tab on this page.
  int _topTab = 0;
  late final TabController _topTabController = TabController(
    length: 2,
    vsync: this,
  )..addListener(() {
      if (_topTabController.indexIsChanging) return;
      if (_topTabController.index == _topTab) return;
      setState(() => _topTab = _topTabController.index);
    });

  /// Schwebender Upload-Plus-Button — true wenn die zwei Upload-Optionen
  /// (Scorecard-PDF + Drivers-CSV) ausgeklappt sind.
  bool _fabOpen = false;

  /// Wirksamer Admin-Namespace für alle Reads/Writes — `AdminScope` gibt
  /// den Parent-Admin zurück, wenn ein Dispatcher eingeloggt ist, sonst
  /// die UID des aktuellen Users.
  String? _currentAdminUid;

  /// Cache-Stream für Driver-Names — wird neu aufgebaut, wenn sich der
  /// Admin-Scope ändert (z.B. Erst-Initialisierung im Dispatcher-Shell).
  late Stream<Map<String, String>> _globalNamesStreamCached =
      const Stream<Map<String, String>>.empty();

  /// Cache-Stream für die aktiven Fahrer-TIDs — damit inaktive DAs aus der
  /// Best-Driver-Rangliste ausgeblendet werden (Feedback-Ticket).
  late Stream<Set<String>> _activeTidsStreamCached =
      const Stream<Set<String>>.empty();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = AdminScope.adminUidOf(context);
    if (next != _currentAdminUid) {
      _currentAdminUid = next;
      _globalNamesStreamCached = _driversNameMapGlobal();
      _activeTidsStreamCached = _activeTidsStream();
    }
  }

  /// Streams the set of transporter-IDs of drivers that are currently
  /// active/working. Used to filter inactive DAs out of the ranking.
  Stream<Set<String>> _activeTidsStream() {
    final uid =
        _currentAdminUid ?? FirebaseAuth.instance.currentUser?.uid ?? '';
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('drivers')
        .snapshots()
        .map((snap) {
      final s = <String>{};
      for (final d in snap.docs) {
        final data = d.data();
        if (!isDriverWorking(data)) continue;
        final id = _normTid(data['transporterId'] ?? d.id);
        if (id.isNotEmpty) s.add(id);
      }
      return s;
    });
  }

  @override
  void dispose() {
    _topTabController.dispose();
    super.dispose();
  }

  Stream<List<_ReportVM>> _reportsStream() {
    final uid = _currentAdminUid ?? FirebaseAuth.instance.currentUser?.uid ?? '';
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

  /// Ticket "Best Driver": Summe ALLER bisher gelieferten Pakete pro
  /// Fahrer (über alle Wochen/Jahre, unabhängig vom Perioden-Filter).
  /// Einmal pro Seitenaufruf geladen und gecacht.
  Map<String, int>? _allTimeDeliveredCache;

  Future<Map<String, int>> _allTimeDeliveredByTid() async {
    final cached = _allTimeDeliveredCache;
    if (cached != null) return cached;
    final uid =
        _currentAdminUid ?? FirebaseAuth.instance.currentUser?.uid ?? '';
    final out = <String, int>{};
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('scores')
          .get();
      for (final d in snap.docs) {
        final data = d.data();
        final tid = _normTid(data['transporterId']);
        if (tid.isEmpty) continue;
        final kpis = (data['kpis'] as Map?) ?? const {};
        final delivered = _numOr0(
          kpis['Delivered'] ??
              kpis['DELIVERED'] ??
              kpis['delivered'] ??
              data['Delivered'] ??
              data['delivered'],
        );
        if (delivered <= 0) continue;
        out[tid] = (out[tid] ?? 0) + delivered.round();
      }
    } catch (_) {
      // Ohne Daten einfach keine Paket-Chips anzeigen.
    }
    _allTimeDeliveredCache = out;
    return out;
  }

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _scoresForPeriod({
    required int year,
    required Set<String> reportIds,
    required Set<String> reportPaths,
  }) {
    if (reportIds.isEmpty && reportPaths.isEmpty) {
      return Stream.value(<QueryDocumentSnapshot<Map<String, dynamic>>>[]);
    }

    final uid = _currentAdminUid ?? FirebaseAuth.instance.currentUser?.uid ?? '';
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
                // Fahrer ohne Auslieferungen aus der Wertung
                // herausnehmen — sie hatten in dieser Woche keine
                // Pakete und sollen weder gezaehlt noch in der
                // Driver-Hub-Zusammenfassung erscheinen.
                final kpis = (data['kpis'] as Map?) ?? const {};
                final delivered = _numOr0(
                  kpis['Delivered'] ??
                      kpis['DELIVERED'] ??
                      kpis['delivered'] ??
                      data['Delivered'] ??
                      data['delivered'],
                );
                if (delivered <= 0) return false;

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
    final uid = _currentAdminUid ?? FirebaseAuth.instance.currentUser?.uid ?? '';
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
        const SizedBox(height: 16),
        if (subtitle != null && subtitle.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12, left: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.codriverGreen.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    (isMonthView
                            ? t.t('scorecard_overview_best_drivers_month')
                            : t.t('scorecard_overview_best_drivers_year'))
                        .toUpperCase(),
                    style: AppTypography.caption2.copyWith(
                      color: AppColors.codriverDeep,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  subtitle,
                  style: AppTypography.subheadline.copyWith(
                    color: AppColors.codriverDeep,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        StreamBuilder<Map<String, String>>(
          stream: _globalNamesStreamCached,
          builder: (context, namesSnap) {
            final names = namesSnap.data ?? const <String, String>{};

            return StreamBuilder<Set<String>>(
              stream: _activeTidsStreamCached,
              builder: (context, activeSnap) {
                // Only filter once we actually have the driver list; an
                // empty/loading set must NOT hide everybody.
                final activeTids = activeSnap.data;
                final filterActive =
                    activeTids != null && activeTids.isNotEmpty;

                return StreamBuilder<
                  List<QueryDocumentSnapshot<Map<String, dynamic>>>
                >(
              stream: scoreStream,
              builder: (context, scoreSnap) {
                if (scoreSnap.connectionState == ConnectionState.waiting) {
                  return const CoStateSwitcher(
                    child: Center(
                      key: ValueKey('best-loading'),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.codriverGreen,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                final docs = scoreSnap.data ?? [];
                if (docs.isEmpty) {
                  return CoStateSwitcher(
                    child: Padding(
                    key: const ValueKey('best-empty'),
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: const BoxDecoration(
                              color: AppColors.green50,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.emoji_events_outlined,
                              color: AppColors.codriverDeep,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            t.t('scorecard_overview_no_drivers_period'),
                            style: AppTypography.subheadline.copyWith(
                              color: AppColors.labelSecondaryLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ),
                  );
                }

                final Map<String, Map<String, _DriverAgg>> stationAgg = {};
                for (final d in docs) {
                  final data = d.data();
                  final tid = _normTid(data['transporterId']);
                  if (tid.isEmpty) continue;
                  // Skip inactive DAs (feedback ticket).
                  if (filterActive && !activeTids.contains(tid)) continue;

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

                return FutureBuilder<Map<String, int>>(
                  future: _allTimeDeliveredByTid(),
                  builder: (context, deliveredSnap) {
                    final deliveredTotals =
                        deliveredSnap.data ?? const <String, int>{};
                    return CoStateSwitcher(
                      child: Column(
                      key: const ValueKey('best-loaded'),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final station in stationsSorted)
                          if (activeStation == null ||
                              station == activeStation) ...[
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 14, bottom: 10, left: 4),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.place_outlined,
                                    size: 14,
                                    color: AppColors.labelSecondaryLight,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    station == 'UNKNOWN'
                                        ? t
                                            .t('scorecard_overview_station')
                                            .toUpperCase()
                                        : station,
                                    style:
                                        AppTypography.caption2.copyWith(
                                      color:
                                          AppColors.labelSecondaryLight,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _buildStationDriverList(
                              stationAgg[station] ??
                                  const <String, _DriverAgg>{},
                              names,
                              t,
                              deliveredTotals,
                            ),
                          ],
                      ],
                      ),
                    );
                  },
                );
              },
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
    Map<String, int> deliveredTotals,
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
        // Klick öffnet die Gesamtübersicht aller Leistungen des Fahrers
        // (gleiche Detailseite wie in der Wochen-Scorecard).
        return Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              final uid = AdminScope.adminUidOf(context) ??
                  FirebaseAuth.instance.currentUser?.uid;
              if (uid == null) return;
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => DriverScoreDetailPage(
                    uid: uid,
                    transporterId: e.transporterId,
                    driverName: name,
                    currentScore: e.avgScore,
                    currentBucket: e.statusCode,
                  ),
                ),
              );
            },
            child: _BestDriverRow(
              rank: i + 1,
              score: e.avgScore,
              name: name,
              statusText: statusText,
              statusColor: statusColor,
              deliveredTotal: deliveredTotals[normalizedTid],
            ),
          ),
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
          adminUid: _currentAdminUid,
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

      // ✅ NEW: user-scoped update so ALL of this user's reports/scores get names
      final uid = _currentAdminUid ?? FirebaseAuth.instance.currentUser?.uid ?? '';
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

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.t('scorecard_overview_delete_report_q')),
        content: Text(
          t.tf('scorecard_overview_delete_report_body', {'title': titleLabel}),
        ),
        actions: [
          CoButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            label: t.t('admin_home_cancel'),
            variant: CoButtonVariant.quiet,
          ),
          CoButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            label: t.t('admin_home_delete'),
            variant: CoButtonVariant.destructive,
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      final uid = _currentAdminUid ?? FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception(t.t('admin_home_not_logged_in'));

      // Nur die Scorecard-Sektion entfernen. POD Quality, Concessions,
      // CDF und DWC derselben Woche liegen im selben Report- und
      // Score-Dokument und bleiben erhalten; das Wochen-Dokument wird nur
      // gelöscht, wenn danach nichts mehr übrig ist.
      await ReportSectionRemover.removeSection(
        uid: uid,
        reportRef: reportRef,
        sectionKey: 'deliveryQualitySwc',
        alsoRemove: const ['complianceAndSafety'],
        scoreFields: const ['kpis', 'statusBucket', 'comp'],
      );
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
                        ],
                      ),
                    if (!narrow) SizedBox(height: _pad(16, w)),

                    Expanded(
                      child: StreamBuilder<List<_ReportVM>>(
                        stream: _reportsStream(),
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const CoStateSwitcher(
                              child: Center(
                                key: ValueKey('reports-loading'),
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.codriverGreen,
                                  ),
                                ),
                              ),
                            );
                          }
                          if (snap.hasError) {
                            return CoStateSwitcher(
                              child: Center(
                                key: const ValueKey('reports-error'),
                                child: Text(
                                  t.tf('admin_home_error_generic', {
                                    'error': '${snap.error}',
                                  }),
                                ),
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
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: [
                                  const _ScorecardSourceHint(),
                                  _UploadDropZone(
                                    busy: _busyUpload,
                                    onPick: _uploadWeeklyPdf,
                                    promptText: _busyUpload
                                        ? t.t('uploading')
                                        : t.t(
                                            'scorecard_overview_upload_prompt'),
                                    buttonLabel:
                                        t.t('scorecard_overview_choose_file'),
                                  ),
                                ],
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

                          // Alle Wochen ab KW 1 bis jetzt zeigen — scrollt
                          // horizontal wenn es viele werden.
                          final chart = list.reversed.toList();

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
                            SizedBox(height: _pad(20, w)),
                            // Section-Header für das Chart — kein Panel-
                            // Wrapper, damit die Balken volle Breite haben.
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(4, 0, 4, 10),
                              child: Text(
                                t.t('scorecard_overview_chart_title'),
                                style: AppTypography.headline.copyWith(
                                  color: AppColors.codriverDeep,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ),
                            _MiniBarChart(
                              points: chart
                                  .map(
                                    (p) => _BarPoint(
                                      label: p.week
                                          .toString()
                                          .padLeft(2, '0'),
                                      value: p.overall ?? 0,
                                      ref: p.ref,
                                      overallStatus: p.overallStatus,
                                    ),
                                  )
                                  .toList(),
                            ),
                            SizedBox(height: _pad(16, w)),
                          ];

                          // ----- RIGHT panel (Apple-Style Summary)
                          final rightPanel = _Panel(
                            title: t.t('scorecard_overview_summary_title'),
                            trailing: Icon(
                              Icons.more_horiz,
                              color: _UI.textSecondary,
                              size: _sp(20, w),
                            ),
                            child: Column(
                              children: [
                                for (var i = 0; i < list.length; i++) ...[
                                  if (i > 0)
                                    const Divider(
                                      height: 1,
                                      thickness: 0.5,
                                      color: Color(0xFFE5E5EA),
                                    ),
                                  _SummaryRow(
                                    report: list[i],
                                    onTap: () =>
                                        Navigator.of(context).push(
                                      PageRouteBuilder(
                                        pageBuilder: (_, __, ___) =>
                                            ScorecardWeekShellPage(
                                          reportRef: list[i].ref,
                                        ),
                                        transitionDuration:
                                            Duration.zero,
                                        reverseTransitionDuration:
                                            Duration.zero,
                                      ),
                                    ),
                                    onDelete: () =>
                                        _handleReportMenuAction(
                                      'delete',
                                      reportRef: list[i].ref,
                                      titleLabel: t.tf(
                                        'scorecard_overview_row_title',
                                        {
                                          'year': '${list[i].year}',
                                          'week': '${list[i].week}',
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );

                          // ── Tab Bar + Body switch ─────────────────────
                          final tabBar = Padding(
                            padding: EdgeInsets.only(bottom: _pad(14, w)),
                            child: PillTabBar(
                              controller: _topTabController,
                              tabs: [
                                t.t('scorecard_overview_tab_company') ==
                                        'scorecard_overview_tab_company'
                                    ? 'Company Score'
                                    : t.t('scorecard_overview_tab_company'),
                                t.t('scorecard_overview_best_drivers'),
                              ],
                            ),
                          );

                          // Tab-Bar sitzt fix oben; nur der Inhalt darunter
                          // scrollt.
                          final Widget content;
                          if (_topTab == 1) {
                            content = ListView(
                              padding: EdgeInsets.only(
                                bottom: _pad(96, w),
                              ),
                              children: [
                                _Panel(
                                  title:
                                      t.t('scorecard_overview_best_drivers'),
                                  child: _buildBestDriversContent(
                                    context: context,
                                    years: sortedYears,
                                    monthsByYear: sortedMonthsByYear,
                                    reports: list,
                                    setDialogState: (fn) =>
                                        setState(() => fn()),
                                    w: w,
                                  ),
                                ),
                              ],
                            );
                          } else if (narrow) {
                            content = ListView(
                              padding: EdgeInsets.only(
                                bottom: _pad(96, w),
                              ),
                              children: [
                                ...leftColumnContent,
                                SizedBox(height: _pad(16, w)),
                                rightPanel,
                              ],
                            );
                          } else {
                            content = ListView(
                              padding: EdgeInsets.only(
                                bottom: _pad(96, w),
                              ),
                              children: [
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: leftColumnContent,
                                      ),
                                    ),
                                    SizedBox(width: _pad(16, w)),
                                    Expanded(
                                      flex: 2,
                                      child: rightPanel,
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (!_isNarrow(context))
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                  children: [
                                    Expanded(child: tabBar),
                                    const SizedBox(width: 12),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        bottom: _pad(14, w),
                                      ),
                                      child: _UploadNewButton(
                                        onPickPdf: _uploadWeeklyPdf,
                                        onPickCsv: _uploadDriverCsv,
                                        pdfLabel: t.t(
                                          'scorecard_overview_upload_pdf',
                                        ),
                                        csvLabel:
                                            t.t('dash_upload_driver_csv'),
                                      ),
                                    ),
                                  ],
                                )
                              else
                                tabBar,
                              Expanded(child: content),
                            ],
                          );
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

        // Speed-Dial nur auf Mobile/schmal — Desktop nutzt den
        // grünen "New"-Button oben rechts.
        if (_isNarrow(context))
          Positioned(
            right: 20,
            bottom: 24,
            child: _UploadSpeedDial(
              open: _fabOpen,
              onToggle: () => setState(() => _fabOpen = !_fabOpen),
              busyPdf: _busyUpload,
              busyCsv: _busyCsv,
              onPickPdf: () {
                setState(() => _fabOpen = false);
                _uploadWeeklyPdf();
              },
              onPickCsv: () {
                setState(() => _fabOpen = false);
                _uploadDriverCsv();
              },
              pdfLabel: t.t('scorecard_overview_upload_pdf'),
              csvLabel: t.t('dash_upload_driver_csv'),
            ),
          ),

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
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.codriverGreen,
                          ),
                        ),
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
    final isMobile = w < 800;
    return Container(
      decoration: BoxDecoration(
        color: _UI.card,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppElevation.level1,
      ),
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.headline.copyWith(
                    color: AppColors.codriverDeep,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          SizedBox(height: isMobile ? 12 : 16),
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

/// Apple-style Filter-Pille für Period + Station. Hellgrauer 0.5px-
/// Rahmen, weißer Background, caption2 Eyebrow + Wert in subheadline.
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

  Widget _pill({
    required String eyebrow,
    required String label,
    required VoidCallback? onTap,
  }) {
    return CoPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
          height: 56,
          padding: const EdgeInsets.fromLTRB(14, 8, 12, 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevatedLight,
            borderRadius: BorderRadius.circular(14),
            border:
                Border.all(color: const Color(0xFFE5E5EA), width: 0.6),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      eyebrow.toUpperCase(),
                      style: AppTypography.caption2.copyWith(
                        color: AppColors.labelSecondaryLight,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.subheadline.copyWith(
                        color: AppColors.codriverDeep,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: AppColors.codriverDeep,
              ),
            ],
          ),
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final periodPill = _pill(
      eyebrow: 'Period',
      label: periodLabel,
      onTap: onPeriodTap,
    );

    if (stationLabel == null || onStationTap == null) {
      return periodPill;
    }

    final stationPill = _pill(
      eyebrow: t.t('scorecard_overview_station'),
      label: stationLabel!,
      onTap: onStationTap,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 520) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              periodPill,
              const SizedBox(height: 10),
              stationPill,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: periodPill),
            const SizedBox(width: 10),
            Expanded(child: stationPill),
          ],
        );
      },
    );
  }
}

/// Apple-Card-Zeile für die Best-Driver-Leaderboard. Tier-farbiger
/// Rank-Badge, Name + Tier-Pill, Score rechts mit tabular figures.
class _BestDriverRow extends StatelessWidget {
  final int rank;
  final double score;
  final String name;
  final String statusText;
  final Color statusColor;
  final Color? backgroundColor;

  /// Summe aller bisher gelieferten Pakete (alle Wochen/Jahre).
  /// null = unbekannt → Chip wird ausgeblendet.
  final int? deliveredTotal;

  const _BestDriverRow({
    required this.rank,
    required this.score,
    required this.name,
    required this.statusText,
    required this.statusColor,
    this.backgroundColor,
    this.deliveredTotal,
  });

  /// Olympia-Medaillen-Verlauf für Top-3 als Rank-Badge.
  Gradient? _medalGradient() {
    switch (rank) {
      case 1:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFE36F), Color(0xFFE0A91A)],
        );
      case 2:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8E8EE), Color(0xFF9AA0A6)],
        );
      case 3:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE6B381), Color(0xFFA86A2C)],
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final medal = _medalGradient();
    final isTop3 = medal != null;
    final displayName = name.isEmpty ? t.t('dash_no_name') : name;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevatedLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppElevation.level1,
        border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Rank Badge — Tier-Farbe oder Medaillen-Verlauf für Top-3
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: medal,
              color: isTop3 ? null : statusColor.withValues(alpha: 0.14),
            ),
            alignment: Alignment.center,
            child: Text(
              '$rank',
              style: AppTypography.subheadline.copyWith(
                color: isTop3 ? Colors.white : statusColor,
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Name + Tier-Pille
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.subheadline.copyWith(
                    color: AppColors.codriverDeep,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (statusText.isNotEmpty ||
                    (deliveredTotal ?? 0) > 0) ...[
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (statusText.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            statusText.toUpperCase(),
                            style: AppTypography.caption2.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      // Ticket: Anzahl aller bisher gelieferten Pakete.
                      if ((deliveredTotal ?? 0) > 0)
                        Tooltip(
                          message: Localizations.localeOf(context)
                                      .languageCode ==
                                  'de'
                              ? 'Bisher gelieferte Pakete (gesamt)'
                              : 'Total packages delivered so far',
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.inventory_2_outlined,
                                  size: 11,
                                  color: Color(0xFF1D4ED8),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  NumberFormat.decimalPattern('de')
                                      .format(deliveredTotal),
                                  style:
                                      AppTypography.caption2.copyWith(
                                    color: const Color(0xFF1D4ED8),
                                    fontWeight: FontWeight.w800,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Score rechts
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                t.t('dash_score').toUpperCase(),
                style: AppTypography.caption2.copyWith(
                  color: AppColors.labelSecondaryLight,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _pct2.format(score),
                style: AppTypography.title3.copyWith(
                  color: AppColors.codriverDeep,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ],
      ),
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
    final isMobile = w < 800;
    final isUp = (delta ?? 0) >= 0;

    // Inter durchgehend — kein hand-skaliertes TextStyle mehr. Mobile
    // bekommt einen großen Hero-Wert (Title 1 = 28pt) statt der vorher
    // auf ~17pt herunterskalierten Zahl.
    final labelStyle = AppTypography.caption2.copyWith(
      color: AppColors.labelSecondaryLight,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.8,
    );
    final subtitleStyle = AppTypography.caption1.copyWith(
      color: AppColors.labelSecondaryLight,
      fontWeight: FontWeight.w600,
    );
    final valueStyle =
        (isMobile ? AppTypography.title1 : AppTypography.largeTitle).copyWith(
      color: AppColors.codriverDeep,
      fontWeight: FontWeight.w800,
      fontFeatures: const [FontFeature.tabularFigures()],
      letterSpacing: -0.5,
    );
    final deltaColor = isUp ? AppColors.codriverGreen : AppColors.error;
    final deltaStyle = AppTypography.footnote.copyWith(
      color: deltaColor,
      fontWeight: FontWeight.w800,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final captionStyle = AppTypography.caption1.copyWith(
      color: AppColors.labelSecondaryLight,
    );

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: _UI.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppElevation.level1,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 20,
        vertical: isMobile ? 12 : 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title.toUpperCase(),
                textAlign: TextAlign.center,
                style: labelStyle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: subtitleStyle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value != null ? '${_pct2.format(value)} %' : '—',
                textAlign: TextAlign.center,
                style: valueStyle,
              ),
            ),
          ),
          // Delta-Bereich — zweizeilig: Icon + Wert oben, Caption darunter.
          // Fixe Höhe sorgt dafür, dass der Hero-Wert in allen Karten auf
          // der gleichen Linie sitzt; ohne Delta bleibt der Slot leer.
          SizedBox(
            height: isMobile ? 48 : 52,
            child: delta == null
                ? const SizedBox.shrink()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isUp ? Icons.trending_up : Icons.trending_down,
                            size: 16,
                            color: deltaColor,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${isUp ? '+' : ''}${_pct2.format(delta!.abs())} %',
                              style: deltaStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (deltaCaption.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            deltaCaption,
                            style: captionStyle,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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

class _MiniBarChart extends StatefulWidget {
  final List<_BarPoint> points;
  const _MiniBarChart({required this.points});

  @override
  State<_MiniBarChart> createState() => _MiniBarChartState();
}

class _MiniBarChartState extends State<_MiniBarChart> {
  // Shared controller so the Scrollbar attaches to (and can drag) the
  // horizontal scroll view — without it the bar chart cannot be scrolled
  // with a mouse and no scrollbar is shown.
  final ScrollController _sc = ScrollController();

  List<_BarPoint> get points => widget.points;

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

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
    final isNarrow = _isNarrow(context);

    // Schlanke Balken über die volle Breite. Keine Y-Achse — wenn mehr
    // Wochen geladen sind als der Screen tragen kann, wird horizontal
    // gescrollt, ansonsten stretchen die Slots auf den verfügbaren Raum.
    const minSlotW = 30.0;
    const xLabelAreaH = 40.0;
    const valueLabelH = 26.0;
    final chartH = isNarrow ? 360.0 : 420.0;

    return Container(
      height: chartH,
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
      child: LayoutBuilder(
        builder: (context, c) {
          final innerH = c.maxHeight;
          final barsAreaH = innerH - xLabelAreaH - valueLabelH;
          final visibleW = c.maxWidth;
          // Slot-Breite wächst, wenn genug Platz da ist — sonst Mindestbreite
          // + horizontaler Scroll.
          final naturalSlot = points.isEmpty ? minSlotW : visibleW / points.length;
          final slotW = naturalSlot < minSlotW ? minSlotW : naturalSlot;
          final barW = (slotW * 0.7).clamp(16.0, 32.0);
          final contentW = points.length * slotW;

          final scrollable = contentW > visibleW;
          return ClipRect(
            child: Scrollbar(
              controller: _sc,
              thumbVisibility: scrollable,
              trackVisibility: scrollable,
              interactive: true,
              child: SingleChildScrollView(
                controller: _sc,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                // Leave room at the bottom so the horizontal scrollbar does
                // not cover the KW labels.
                padding: EdgeInsets.only(bottom: scrollable ? 10 : 0),
                child: SizedBox(
                  width: contentW > visibleW ? contentW : visibleW,
                  child: Stack(
                    children: [
                            // Grid lines (5 horizontale Linien) — hellgrau
                            Positioned.fill(
                              top: valueLabelH,
                              bottom: xLabelAreaH,
                              child: Column(
                                children: List.generate(
                                  5,
                                  (_) => const Expanded(
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        border: Border(
                                          top: BorderSide(
                                            color: Color(0xFFE5E5EA),
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Basislinie — selber Hellgrau-Ton
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: xLabelAreaH - 0.5,
                              child: Container(
                                height: 1,
                                color: const Color(0xFFE5E5EA),
                              ),
                            ),

                            // Bars + Wert-Labels
                            Positioned.fill(
                              top: 0,
                              bottom: xLabelAreaH,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  for (final p in points)
                                    SizedBox(
                                      width: slotW,
                                      child: _BarSlot(
                                        point: p,
                                        valueLabelH: valueLabelH,
                                        barsAreaH: barsAreaH,
                                        barW: barW,
                                        color: _colorForStatus(p.overallStatus),
                                        statusLabel:
                                            _labelForStatus(p.overallStatus),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // X-Labels (KW)
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              height: xLabelAreaH,
                              child: Row(
                                children: [
                                  for (final p in points)
                                    SizedBox(
                                      width: slotW,
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Text(
                                          p.label,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: AppTypography.caption1.copyWith(
                                            color:
                                                AppColors.labelSecondaryLight,
                                            fontWeight: FontWeight.w600,
                                            fontFeatures: const [
                                              FontFeature.tabularFigures()
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
        },
      ),
    );
  }
}

/// Ein Slot im Bar-Chart — feste Breite, Tap → Wochenseite, Wert oben,
/// Bar mit Gradient & Shadow.
class _BarSlot extends StatelessWidget {
  final _BarPoint point;
  final double valueLabelH;
  final double barsAreaH;
  final double barW;
  final Color color;
  final String statusLabel;

  const _BarSlot({
    required this.point,
    required this.valueLabelH,
    required this.barsAreaH,
    required this.barW,
    required this.color,
    required this.statusLabel,
  });

  @override
  Widget build(BuildContext context) {
    final v = point.value.clamp(0, 100).toDouble();
    final h = (v / 100) * barsAreaH;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: CoPressable(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) =>
                ScorecardWeekShellPage(reportRef: point.ref),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              height: valueLabelH,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    v.toStringAsFixed(0),
                    style: AppTypography.subheadline.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              height: h,
              width: barW,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                  bottom: Radius.circular(2),
                ),
              ),
              child: h < 110
                  ? null
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Center(
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              statusLabel,
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 8,
                                color: Colors.white.withOpacity(0.75),
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
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
    );
  }
}

/* ====================  Summary row (Apple-style)  ==================== */

/// Eine Zeile in der Scorecard-Liste rechts. Apple-Look: leading Score-
/// Avatar in Tier-Farbe, KW-Bezeichner als Headline, Datum/Status als
/// Subline, trailing kleines Chevron + Overflow-Menü.
class _SummaryRow extends StatelessWidget {
  final _ReportVM report;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const _SummaryRow({
    required this.report,
    required this.onTap,
    required this.onDelete,
  });

  Color _tierColor(String? statusCode) {
    switch (_s(statusCode).trim().toUpperCase()) {
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
        return AppColors.codriverDeep;
    }
  }

  String _tierLabel(String? statusCode) {
    switch (_s(statusCode).trim().toUpperCase()) {
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
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final p = report;
    final start = _isoWeekStartUtc(p.year, p.week);
    final end = start.add(const Duration(days: 6));
    final dateRange = '${_dotted(start)} – ${_dotted(end)}';
    final tier = _tierColor(p.overallStatus);
    final tierLabel = _tierLabel(p.overallStatus);
    final score = p.overall;

    return CoPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 4, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Leading score badge — runder Container in Tier-Farbe @ 12%
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: tier.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  score != null ? _pct2.format(score) : '—',
                  style: AppTypography.subheadline.copyWith(
                    color: tier,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.tf('scorecard_overview_row_title', {
                        'year': '${p.year}',
                        'week': '${p.week}',
                      }),
                      style: AppTypography.subheadline.copyWith(
                        color: AppColors.codriverDeep,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateRange,
                      style: AppTypography.caption1.copyWith(
                        color: AppColors.labelSecondaryLight,
                        fontWeight: FontWeight.w500,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (tierLabel.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: tier.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          tierLabel.toUpperCase(),
                          style: AppTypography.caption2.copyWith(
                            color: tier,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: t.t('scorecard_overview_more'),
                onSelected: (v) {
                  if (v == 'delete') onDelete();
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Text(
                      t.t('scorecard_overview_delete_report_menu'),
                      style: AppTypography.callout.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                icon: Icon(
                  Icons.more_vert,
                  color: AppColors.labelSecondaryLight,
                  size: 20,
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.labelTertiaryLight,
                size: 22,
              ),
            ],
          ),
        ),
    );
  }
}

/* ====================  Floating upload speed dial  ==================== */

/// Schwebender Plus-Button rechts unten. Tap → klappt zwei Upload-
/// Optionen aus: Scorecard-PDF und Drivers-CSV. Beide jeweils mit
/// Label-Pille, deutlich getrennt, Apple-iOS-Pattern.
/// Desktop: grüner "New"-Button (oben rechts) mit Popup-Menü für die
/// Uploads (Scorecard-PDF + Driver-CSV).
/// Quellen-Hinweis für die Scorecard-Upload-Stellen: Wochen-Scorecard-PDF
/// plus die Driver-CSV aus dem Liefermitarbeiter-Bereich.
class _ScorecardSourceHint extends StatelessWidget {
  const _ScorecardSourceHint({this.compact = false, this.margin});

  final bool compact;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return ReportSourceHint(
      compact: compact,
      margin: margin ?? const EdgeInsets.only(bottom: 12),
      sourceDe: 'Quelle: Cortex → Leistung → Scorecard',
      sourceEn: 'Source: Cortex → Performance → Scorecard',
      expectedFileName: 'z. B. DE-AION-DBY5-Week19-Scorecard.pdf',
      extraHintDe: 'Driver-CSV: Cortex → Leistung → Liefermitarbeiter → '
          'Woche auswählen → Download-Icon oben rechts',
      extraHintEn: 'Driver CSV: Cortex → Performance → Delivery Associates → '
          'select week → download icon top right',
      extraFileName: 'z. B. delivery-associates-week19.csv',
    );
  }
}

class _UploadNewButton extends StatelessWidget {
  const _UploadNewButton({
    required this.onPickPdf,
    required this.onPickCsv,
    required this.pdfLabel,
    required this.csvLabel,
  });

  final VoidCallback onPickPdf;
  final VoidCallback onPickCsv;
  final String pdfLabel;
  final String csvLabel;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      tooltip: '',
      offset: const Offset(0, 48),
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      onSelected: (v) {
        if (v == 0) onPickPdf();
        if (v == 1) onPickCsv();
      },
      itemBuilder: (_) => [
        const PopupMenuItem<int>(
          enabled: false,
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: SizedBox(
            width: 320,
            child: _ScorecardSourceHint(
              compact: true,
              margin: EdgeInsets.symmetric(vertical: 6),
            ),
          ),
        ),
        PopupMenuItem<int>(
          value: 0,
          child: Row(
            children: [
              const Icon(Icons.picture_as_pdf_outlined,
                  size: 18, color: AppColors.codriverDeep),
              const SizedBox(width: 10),
              Text(pdfLabel),
            ],
          ),
        ),
        PopupMenuItem<int>(
          value: 1,
          child: Row(
            children: [
              const Icon(Icons.table_chart_outlined,
                  size: 18, color: AppColors.codriverDeep),
              const SizedBox(width: 10),
              Text(csvLabel),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.codriverGreen,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: AppColors.codriverGreen.withValues(alpha: 0.30),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: Colors.white, size: 18),
            SizedBox(width: 6),
            Text(
              'New',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UploadSpeedDial extends StatelessWidget {
  final bool open;
  final VoidCallback onToggle;
  final bool busyPdf;
  final bool busyCsv;
  final VoidCallback onPickPdf;
  final VoidCallback onPickCsv;
  final String pdfLabel;
  final String csvLabel;

  const _UploadSpeedDial({
    required this.open,
    required this.onToggle,
    required this.busyPdf,
    required this.busyCsv,
    required this.onPickPdf,
    required this.onPickCsv,
    required this.pdfLabel,
    required this.csvLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AnimatedSlide(
          offset: open ? Offset.zero : const Offset(0, 0.2),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            opacity: open ? 1 : 0,
            duration: const Duration(milliseconds: 180),
            child: IgnorePointer(
              ignoring: !open,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: const _ScorecardSourceHint(compact: true),
                  ),
                  _MiniFab(
                    icon: Icons.picture_as_pdf_rounded,
                    label: pdfLabel,
                    busy: busyPdf,
                    onTap: onPickPdf,
                  ),
                  const SizedBox(height: 10),
                  _MiniFab(
                    icon: Icons.groups_rounded,
                    label: csvLabel,
                    busy: busyCsv,
                    onTap: onPickCsv,
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),
        ),
        // Haupt-Plus-Button — dreht sich beim Öffnen leicht zu einem ×.
        Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: open
                    ? AppColors.codriverDeep
                    : AppColors.codriverGreen,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: AnimatedRotation(
                turns: open ? 0.125 : 0.0,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutBack,
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniFab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool busy;
  final VoidCallback onTap;
  const _MiniFab({
    required this.icon,
    required this.label,
    required this.busy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label-Pille links neben dem Mini-Button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            label,
            style: AppTypography.footnote.copyWith(
              color: AppColors.codriverDeep,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: busy ? null : onTap,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: busy
                    ? AppColors.codriverGreen.withOpacity(0.5)
                    : AppColors.codriverGreen,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x29000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: busy
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Icon(icon, color: Colors.white, size: 22),
            ),
          ),
        ),
      ],
    );
  }
}

/* ====================  Upload drop zone (Apple-style)  ==================== */

/// Saubere Apple-mäßige Drop-Zone für PDF-Uploads. Gestrichelte Border auf
/// hellgrauer Fläche, großer Tap-Bereich auf dem gesamten Container, plus
/// ein klassischer primärer Pill-Button. Die ganze Fläche reagiert auf
/// Tap — der Button ist nur die visuelle Affordanz.
class _UploadDropZone extends StatelessWidget {
  final bool busy;
  final VoidCallback onPick;
  final String promptText;
  final String buttonLabel;

  const _UploadDropZone({
    required this.busy,
    required this.onPick,
    required this.promptText,
    required this.buttonLabel,
  });

  @override
  Widget build(BuildContext context) {
    return CoPressable(
      onTap: busy ? null : onPick,
      borderRadius: BorderRadius.circular(18),
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: AppColors.codriverGreen.withOpacity(0.5),
          radius: 18,
          strokeWidth: 1.5,
          dashLength: 6,
          gapLength: 5,
        ),
        child: Container(
            constraints: const BoxConstraints(minHeight: 160),
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 22),
            decoration: BoxDecoration(
              color: AppColors.green50.withOpacity(0.4),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.codriverGreen.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.upload_file_rounded,
                    color: AppColors.codriverDeep,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  promptText,
                  textAlign: TextAlign.center,
                  style: AppTypography.subheadline.copyWith(
                    color: AppColors.codriverDeep,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                CoButton(
                  onPressed: busy ? null : onPick,
                  label: buttonLabel,
                  busy: busy,
                ),
              ],
            ),
          ),
        ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + dashLength).clamp(0.0, metric.length);
        canvas.drawPath(
          metric.extractPath(distance, next.toDouble()),
          paint,
        );
        distance = next + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) =>
      old.color != color ||
      old.radius != radius ||
      old.strokeWidth != strokeWidth ||
      old.dashLength != dashLength ||
      old.gapLength != gapLength;
}

/* ====================  Score Hero (Apple-style)  ==================== */

/// Großer Hero mit dem aktuellsten Overall-Score, zentral platziert.
/// Apple-Wallet-Karten-Look: dunkler Marken-Verlauf, ein dominanter
/// Zahlenwert in der Mitte, eyebrow oben, Trend-Pille unten.
class _ScoreHero extends StatelessWidget {
  final String eyebrow;
  final double? score;
  final double? delta;
  final String deltaCaption;

  const _ScoreHero({
    required this.eyebrow,
    required this.score,
    required this.delta,
    required this.deltaCaption,
  });

  @override
  Widget build(BuildContext context) {
    final isUp = (delta ?? 0) >= 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.codriverGreen, AppColors.codriverDeep],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppElevation.level2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Eyebrow links
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              eyebrow,
              style: AppTypography.caption2.copyWith(
                color: Colors.white.withOpacity(0.85),
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
          // Zentrierter Hero-Wert
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: score != null ? _pct2.format(score) : '—',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 56,
                          height: 1.0,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -1.4,
                          fontFeatures: const [
                            FontFeature.tabularFigures()
                          ],
                        ),
                      ),
                      TextSpan(
                        text: '  %',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Trend-Pille zentriert unten
          if (delta != null)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.16),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isUp ? Icons.trending_up : Icons.trending_down,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${isUp ? '+' : ''}${_pct2.format(delta!.abs())} %  $deltaCaption',
                    style: AppTypography.footnote.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            )
          else
            const SizedBox(height: 22),
        ],
      ),
    );
  }
}

/// Weiße Sekundär-Karte für den YEAR-Score — sitzt rechts neben dem
/// grünen Hero, exakt gleich hoch, eigenes Padding + Margin.
class _YearScoreCard extends StatelessWidget {
  final String label;
  final double? score;

  const _YearScoreCard({required this.label, required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 18),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevatedLight,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppElevation.level1,
        border: Border.all(
          color: const Color(0xFFE5E5EA),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.caption2.copyWith(
              color: AppColors.labelSecondaryLight,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: score != null ? _pct2.format(score) : '—',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 38,
                        height: 1.0,
                        fontWeight: FontWeight.w800,
                        color: AppColors.codriverDeep,
                        letterSpacing: -0.9,
                        fontFeatures: const [
                          FontFeature.tabularFigures()
                        ],
                      ),
                    ),
                    TextSpan(
                      text: '  %',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.labelSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

/// Kompakter Stat-Tile. Standard = weiß. Mit `accent: true` wird die
/// gleiche Anatomie auf dem grünen Markenverlauf gerendert (weiße Schrift)
/// — gedacht für die wichtigste „Last Week"-Kachel.
class _StatTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final double? value;
  final double? delta;
  final String deltaCaption;
  final bool accent;

  const _StatTile({
    required this.label,
    required this.subtitle,
    required this.value,
    this.delta,
    this.deltaCaption = '',
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    final isUp = (delta ?? 0) >= 0;

    final labelColor = accent
        ? Colors.white.withOpacity(0.85)
        : AppColors.labelSecondaryLight;
    final subtitleColor = accent
        ? Colors.white.withOpacity(0.7)
        : AppColors.labelTertiaryLight;
    final valueColor = accent ? Colors.white : AppColors.codriverDeep;
    final deltaColor = accent
        ? Colors.white
        : (isUp ? AppColors.codriverGreen : AppColors.error);

    final decoration = accent
        ? BoxDecoration(
            color: AppColors.codriverGreen,
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppElevation.level2,
          )
        : BoxDecoration(
            color: AppColors.surfaceElevatedLight,
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppElevation.level1,
            border: Border.all(
              color: const Color(0xFFE5E5EA),
              width: 0.5,
            ),
          );

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.caption2.copyWith(
              color: labelColor,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTypography.caption1.copyWith(
              color: subtitleColor,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value != null ? '${_pct2.format(value)} %' : '—',
              style: AppTypography.title2.copyWith(
                color: valueColor,
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
                letterSpacing: -0.4,
              ),
            ),
          ),
          const SizedBox(height: 4),
          if (delta != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isUp ? Icons.trending_up : Icons.trending_down,
                  size: 13,
                  color: deltaColor,
                ),
                const SizedBox(width: 2),
                Flexible(
                  child: Text(
                    '${isUp ? '+' : ''}${_pct2.format(delta!.abs())} %',
                    style: AppTypography.caption1.copyWith(
                      color: deltaColor,
                      fontWeight: FontWeight.w800,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          else
            const SizedBox(height: 16),
        ],
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
      // Desktop: one row of 4 — alle Tiles identische Höhe via IntrinsicHeight.
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
        ),
      );
    } else if (w >= 800) {
      // Tablet: 2×2 — IntrinsicHeight pro Reihe sorgt für identische Höhe.
      return Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
          ),
          SizedBox(height: _pad(12, w)),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
          ),
        ],
      );
    } else {
      // Mobile — alle vier Tiles in identischer Anatomie. Erste Reihe:
      // Scorecard Last Week (grün) + Scorecard Year (weiß). Zweite Reihe:
      // Reliability Last Week + Reliability Year (beide weiß).
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _StatTile(
                    accent: true,
                    label: t.t('nav_scorecard'),
                    subtitle: t.t('admin_home_last_week').toUpperCase(),
                    value: latestOverall,
                    delta: lastWeekOverallDelta,
                    deltaCaption:
                        t.t('scorecard_overview_from_last_week'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatTile(
                    label: t.t('nav_scorecard'),
                    subtitle:
                        '${t.t('admin_home_year_prefix')} $yearLabel',
                    value: ytdOverall,
                    delta: yoyOverallDelta,
                    deltaCaption:
                        t.t('scorecard_overview_from_last_year'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _StatTile(
                    label: t.t('scorecard_overview_reliability_score'),
                    subtitle: t.t('admin_home_last_week').toUpperCase(),
                    value: latestRel,
                    delta: lastWeekRelDelta,
                    deltaCaption:
                        t.t('scorecard_overview_from_last_week'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatTile(
                    label: t.t('scorecard_overview_reliability_score'),
                    subtitle:
                        '${t.t('admin_home_year_prefix')} $yearLabel',
                    value: ytdRel,
                    delta: yoyRelDelta,
                    deltaCaption:
                        t.t('scorecard_overview_from_last_year'),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }
}
