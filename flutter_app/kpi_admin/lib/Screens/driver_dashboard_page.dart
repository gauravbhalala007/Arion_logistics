// lib/Screens/driver_dashboard_page.dart
//
// DashboardTabBody: ONLY the scrollable dashboard content.
// Header bar + bottom nav live in driver_home_shell.dart.
//
// FULLY LOCALIZED: all user-visible strings go through AppLocalizations.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';

String _s(dynamic v) => (v == null) ? '' : v.toString();

num _numOr0(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v;
  if (v is String) {
    final s = v.trim().replaceAll('%', '');
    return num.tryParse(s.replaceAll(',', '.')) ?? 0;
  }
  return 0;
}

const _kPrimaryGreen = Color(0xFF1D7F5A);
const _kPrimaryGreenLight = Color(0xFF36B27B);

// Monthly / yearly pill colors (from your mockup)
const _kFantasticPlusColor = Color(0xFF00B287); // Fantastic Plus
const _kFantasticColor = Color(0xFF0082AF); // Fantastic
const _kGreatColor = Color(0xFFF7AA00); // Great
const _kFairColor = Color(0xFFF47400); // Fair
const _kPoorColor = Color(0xFFCE4121); // Poor

Color _monthlyBucketColorFromScore(double s) {
  if (s > 93) return _kFantasticPlusColor; // Fantastic Plus
  if (s >= 85) return _kFantasticColor; // Fantastic
  if (s >= 70) return _kGreatColor; // Great
  if (s >= 50) return _kFairColor; // Fair
  return _kPoorColor; // Poor
}

enum _ViewMode { company, myScore }

// time range used in COMPANY view
enum _TimeFilter { week, month, year }

class DashboardTabBody extends StatefulWidget {
  final String dspUid;
  final String driverTransporterId;

  const DashboardTabBody({
    super.key,
    required this.dspUid,
    required this.driverTransporterId,
  });

  @override
  State<DashboardTabBody> createState() => _DashboardTabBodyState();
}

class _DashboardTabBodyState extends State<DashboardTabBody> {
  _ViewMode _viewMode = _ViewMode.company;
  _TimeFilter _timeFilter = _TimeFilter.week;

  String _bucket = 'ALL'; // ALL | FANTASTIC_PLUS | FANTASTIC | GREAT | FAIR | POOR
  String _query = '';
  int _selectedReportIndex = 0;

  // month selection: "YYYY-MM"
  String? _selectedMonthKey;

  // year selection: 2025, 2026, ...
  int? _selectedYear;

  late final Stream<QuerySnapshot<Map<String, dynamic>>> _reportsStreamCached;
  late final Stream<Map<String, String>> _globalNamesStreamCached;
  final Map<String, Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>>> _scoresStreamCache = {};
  final Map<String, Stream<Map<String, String>>> _weekNamesStreamCache = {};

  // All reports for this DSP (sorted latest first)
  Stream<QuerySnapshot<Map<String, dynamic>>> _reportsStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.dspUid)
        .collection('reports')
        .orderBy('year', descending: true)
        .orderBy('weekNumber', descending: true)
        .snapshots();
  }

  // Scores for selected report
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _scores(
    DocumentReference<Map<String, dynamic>> reportRef,
  ) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.dspUid)
        .collection('scores')
        .where('reportRef', isEqualTo: reportRef)
        .snapshots()
        .map((s) => s.docs);
  }

  // Scores for multiple reports (month / year)
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _scoresForReports(
    List<DocumentReference<Map<String, dynamic>>> reportRefs,
  ) {
    if (reportRefs.isEmpty) {
      return Stream.value(<QueryDocumentSnapshot<Map<String, dynamic>>>[]);
    }

    // per month / year we expect limited weeks → safe for whereIn
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.dspUid)
        .collection('scores')
        .where('reportRef', whereIn: reportRefs)
        .snapshots()
        .map((s) => s.docs);
  }

  // Per-week driver names: reports/{reportId}/driverNames
  Stream<Map<String, String>> _driverNamesForWeek(
    DocumentReference<Map<String, dynamic>> reportRef,
  ) {
    return reportRef.collection('driverNames').snapshots().map((snap) {
      final m = <String, String>{};
      for (final d in snap.docs) {
        final data = d.data();
        final id = _s(data['transporterId'] ?? d.id);
        final name = _s(data['driverName']);
        if (id.isNotEmpty) m[id] = name;
      }
      return m;
    });
  }

  // Global driver master: users/{dspUid}/drivers
  Stream<Map<String, String>> _driversNameMapGlobal() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.dspUid)
        .collection('drivers')
        .snapshots()
        .map((snap) {
      final m = <String, String>{};
      for (final d in snap.docs) {
        final data = d.data();
        final id = _s(data['transporterId']);
        final name = _s(data['driverName']);
        if (id.isNotEmpty) m[id] = name;
      }
      return m;
    });
  }

  @override
  void initState() {
    super.initState();
    _reportsStreamCached = _reportsStream();
    _globalNamesStreamCached = _driversNameMapGlobal();
  }

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _scoresCached(
    DocumentReference<Map<String, dynamic>> reportRef,
  ) {
    return _scoresStreamCache.putIfAbsent(reportRef.path, () => _scores(reportRef));
  }

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _scoresForReportsCached(
    List<DocumentReference<Map<String, dynamic>>> reportRefs,
  ) {
    final refs = [...reportRefs]..sort((a, b) => a.path.compareTo(b.path));
    final key = refs.map((r) => r.path).join('|');
    return _scoresStreamCache.putIfAbsent(key, () => _scoresForReports(refs));
  }

  Stream<Map<String, String>> _driverNamesForWeekCached(
    DocumentReference<Map<String, dynamic>> reportRef,
  ) {
    return _weekNamesStreamCache.putIfAbsent(
      reportRef.path,
      () => _driverNamesForWeek(reportRef),
    );
  }

  // Localized status text from numeric score
  String _statusText(BuildContext context, double v) {
    if (v >= 85) return 'Fantastic';
    if (v >= 70) return 'Great';
    if (v >= 55) return 'Fair';
    return 'Poor';
  }

  Color _statusColor(double v) {
    if (v >= 85) return const Color(0xFF16A34A);
    if (v >= 70) return const Color(0xFF22C55E);
    if (v >= 55) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  String _statusCodeFromScore(double v) {
    if (v >= 93) return 'FANTASTIC_PLUS';
    if (v >= 85) return 'FANTASTIC';
    if (v >= 70) return 'GREAT';
    if (v >= 50) return 'FAIR';
    return 'POOR';
  }

  // Pretty bucket name from API bucket code
  String _prettyBucket(BuildContext context, String raw) {
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

  Color _colorFromApiBucket(String apiBucket) {
    switch (_s(apiBucket).trim().toUpperCase()) {
      case 'FANTASTIC_PLUS':
        return _kFantasticPlusColor;
      case 'FANTASTIC':
        return _kFantasticColor;
      case 'GREAT':
        return _kGreatColor;
      case 'FAIR':
        return _kFairColor;
      case 'POOR':
      default:
        return _kPoorColor;
    }
  }

  int _monthIndexFromWeek(int year, int week) {
    final jan4 = DateTime.utc(year, 1, 4);
    final weekDayOfJan4 = jan4.weekday; // 1..7
    final mondayOfWeek1 = jan4.subtract(Duration(days: weekDayOfJan4 - 1));
    final mondayOfTarget = mondayOfWeek1.add(Duration(days: (week - 1) * 7));
    return mondayOfTarget.month;
  }

  String _monthNameFromIndex(BuildContext context, int m) {
    final loc = AppLocalizations.of(context);
    final i = m.clamp(1, 12).toInt();
    switch (i) {
      case 1:
        return loc.t('month_jan');
      case 2:
        return loc.t('month_feb');
      case 3:
        return loc.t('month_mar');
      case 4:
        return loc.t('month_apr');
      case 5:
        return loc.t('month_may');
      case 6:
        return loc.t('month_jun');
      case 7:
        return loc.t('month_jul');
      case 8:
        return loc.t('month_aug');
      case 9:
        return loc.t('month_sep');
      case 10:
        return loc.t('month_oct');
      case 11:
        return loc.t('month_nov');
      case 12:
        return loc.t('month_dec');
      default:
        return loc.t('month_jan');
    }
  }

  String _shortMonthNameFromIndex(BuildContext context, int m) {
    final loc = AppLocalizations.of(context);
    final i = m.clamp(1, 12).toInt();
    switch (i) {
      case 1:
        return loc.t('month_short_jan');
      case 2:
        return loc.t('month_short_feb');
      case 3:
        return loc.t('month_short_mar');
      case 4:
        return loc.t('month_short_apr');
      case 5:
        return loc.t('month_short_may');
      case 6:
        return loc.t('month_short_jun');
      case 7:
        return loc.t('month_short_jul');
      case 8:
        return loc.t('month_short_aug');
      case 9:
        return loc.t('month_short_sep');
      case 10:
        return loc.t('month_short_oct');
      case 11:
        return loc.t('month_short_nov');
      case 12:
        return loc.t('month_short_dec');
      default:
        return loc.t('month_short_jan');
    }
  }

  // Rough month name from ISO week + year (for default label)
  String _monthFromWeek(BuildContext context, int year, int week) {
    final monthIdx = _monthIndexFromWeek(year, week);
    return _monthNameFromIndex(context, monthIdx);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Center(
        child: Text(loc.t('error_must_be_logged_in_driver')),
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _reportsStreamCached,
      builder: (context, reportSnap) {
        if (reportSnap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (reportSnap.hasError) {
          return Center(
            child: Text(
              loc.tf('dash_error_loading_reports', {
                'error': reportSnap.error.toString(),
              }),
            ),
          );
        }

        final reportDocs = reportSnap.data?.docs ?? [];
        if (reportDocs.isEmpty) {
          return Center(
            child: Text(
              loc.t('dash_no_reports_uploaded'),
              textAlign: TextAlign.center,
            ),
          );
        }

        if (_selectedReportIndex >= reportDocs.length) {
          _selectedReportIndex = 0;
        }
        final selectedReport = reportDocs[_selectedReportIndex];
        final reportData = selectedReport.data();

        final summaryRaw = reportData['summary'];
        final summary = summaryRaw is Map
            ? Map<String, dynamic>.from(summaryRaw as Map)
            : <String, dynamic>{};

        final weekNumber = (summary['weekNumber'] as num?)?.toInt() ??
            (reportData['weekNumber'] as num?)?.toInt();
        final year =
            (summary['year'] as num?)?.toInt() ?? (reportData['year'] as num?)?.toInt();

        final weekLabel =
            weekNumber != null ? '${loc.t('dash_week')} $weekNumber' : loc.t('dash_week');

        final defaultMonthLabel = (year != null && weekNumber != null)
            ? _monthFromWeek(context, year, weekNumber).toUpperCase()
            : loc.t('period_month').toUpperCase();

        final range = (weekNumber != null && year != null)
            ? loc.tf('dash_week_range', {'week': '$weekNumber', 'year': '$year'})
            : '';

        // ---- Build available years and months from all reports ----
        final Set<int> yearsAvailable = {};
        final Map<int, Set<int>> monthsByYear = {};
        for (final doc in reportDocs) {
          final dData = doc.data();
          final sRaw = dData['summary'];
          final s = sRaw is Map
              ? Map<String, dynamic>.from(sRaw as Map)
              : <String, dynamic>{};

          final wy = (s['year'] as num?)?.toInt() ?? (dData['year'] as num?)?.toInt();
          final ww = (s['weekNumber'] as num?)?.toInt() ?? (dData['weekNumber'] as num?)?.toInt();
          if (wy == null || ww == null) continue;

          yearsAvailable.add(wy);
          final m = _monthIndexFromWeek(wy, ww);
          monthsByYear.putIfAbsent(wy, () => <int>{}).add(m);
        }

        final sortedYears = yearsAvailable.toList()..sort((a, b) => b.compareTo(a));
        final Map<int, List<int>> sortedMonthsByYear = {
          for (final y in sortedYears)
            y: (monthsByYear[y]?.toList() ?? [])..sort((a, b) => a.compareTo(b))
        };

        // ---- Prepare current month/year selection defaults ----
        String? currentMonthKey = _selectedMonthKey;
        if (currentMonthKey == null && year != null && weekNumber != null) {
          final m = _monthIndexFromWeek(year, weekNumber);
          final key = '$year-${m.toString().padLeft(2, '0')}';
          currentMonthKey = key;
          _selectedMonthKey ??= key;
        }

        if (_selectedYear == null && sortedYears.isNotEmpty) {
          _selectedYear = sortedYears.first;
        }

        bool isMonthlyCompany = _viewMode == _ViewMode.company &&
            _timeFilter == _TimeFilter.month &&
            currentMonthKey != null;

        bool isYearlyCompany = _viewMode == _ViewMode.company &&
            _timeFilter == _TimeFilter.year &&
            _selectedYear != null;

        int? filterMonth;
        int? filterYear;
        if (isMonthlyCompany && currentMonthKey != null) {
          final parts = currentMonthKey.split('-');
          if (parts.length == 2) {
            filterYear = int.tryParse(parts[0]);
            filterMonth = int.tryParse(parts[1]);
          }
          if (filterYear == null || filterMonth == null) {
            isMonthlyCompany = false;
          }
        }

        if (isYearlyCompany) {
          filterYear = _selectedYear;
          filterMonth = null;
        }

        List<DocumentReference<Map<String, dynamic>>> aggReportRefs = [];
        double aggOverallSum = 0;
        int aggOverallCount = 0;

        if ((isMonthlyCompany && filterYear != null && filterMonth != null) ||
            (isYearlyCompany && filterYear != null)) {
          for (final doc in reportDocs) {
            final dData = doc.data();
            final sRaw = dData['summary'];
            final s = sRaw is Map
                ? Map<String, dynamic>.from(sRaw as Map)
                : <String, dynamic>{};

            final wy = (s['year'] as num?)?.toInt() ?? (dData['year'] as num?)?.toInt();
            final ww = (s['weekNumber'] as num?)?.toInt() ?? (dData['weekNumber'] as num?)?.toInt();
            if (wy == null || ww == null) continue;

            if (wy != filterYear) continue;

            if (filterMonth != null) {
              final m = _monthIndexFromWeek(wy, ww);
              if (m != filterMonth) continue;
            }

            aggReportRefs.add(doc.reference);
            final o = (s['overallScore'] as num?)?.toDouble();
            if (o != null) {
              aggOverallSum += o;
              aggOverallCount++;
            }
          }
        }

        double overall = (summary['overallScore'] as num?)?.toDouble() ?? 0;
        if ((isMonthlyCompany || isYearlyCompany) && aggOverallCount > 0) {
          overall = aggOverallSum / aggOverallCount;
        }

        final relNext = (summary['reliabilityNextDay'] as num?)?.toDouble();
        final relGeneric = (summary['reliabilityScore'] as num?)?.toDouble();
        final reliability = relNext ?? relGeneric;

        final rankAtStation = (summary['rankAtStation'] as num?)?.toInt();
        final stationCount = (summary['stationCount'] as num?)?.toInt();
        final stationName = _s(summary['stationCode'] ?? reportData['stationCode']);

        String rankText = '—';
        if (rankAtStation != null) {
          // not localized because your key expects "{rank} of {total}" but here also includes station code
          // We keep structure but localize fragments:
          rankText = '${rankAtStation} ${loc.t('rank_at')} $stationName';
          if (stationCount != null && stationCount > 0) {
            rankText += ' ${loc.t('rank_of')} $stationCount';
          }
        }

        final overallStatusRaw = _s(summary['overallStatus']);
        final statusText = _prettyBucket(context, overallStatusRaw);
        final statusColor = _colorFromApiBucket(overallStatusRaw);

        final reportRef = selectedReport.reference;

        final scoreStream = (isMonthlyCompany || isYearlyCompany) && aggReportRefs.isNotEmpty
            ? _scoresForReportsCached(aggReportRefs)
            : _scoresCached(reportRef);

        String monthPillLabel;
        if (_viewMode != _ViewMode.company) {
          monthPillLabel = defaultMonthLabel;
        } else {
          switch (_timeFilter) {
            case _TimeFilter.week:
              monthPillLabel = loc.t('period_month').toUpperCase();
              break;
            case _TimeFilter.month:
              if (currentMonthKey != null) {
                final parts = currentMonthKey.split('-');
                if (parts.length == 2) {
                  final y = int.tryParse(parts[0]);
                  final m = int.tryParse(parts[1]);
                  if (y != null && m != null) {
                    monthPillLabel = _monthNameFromIndex(context, m).toUpperCase();
                    break;
                  }
                }
              }
              monthPillLabel = loc.t('period_month').toUpperCase();
              break;
            case _TimeFilter.year:
              monthPillLabel = (_selectedYear ?? year ?? DateTime.now().year).toString();
              break;
          }
        }

        final bool isWeekView = _timeFilter == _TimeFilter.week;
        final bool isMonthView = isMonthlyCompany;
        final bool isYearView = isYearlyCompany;

        String? monthHeaderName;
        int? monthFirstWeek;
        int? monthLastWeek;

        if (isMonthView && filterYear != null && filterMonth != null) {
          monthHeaderName = _monthNameFromIndex(context, filterMonth);
          final weeks = <int>[];
          for (final doc in reportDocs) {
            final dData = doc.data();
            final sRaw = dData['summary'];
            final s = sRaw is Map ? Map<String, dynamic>.from(sRaw as Map) : <String, dynamic>{};

            final wy = (s['year'] as num?)?.toInt() ?? (dData['year'] as num?)?.toInt();
            final ww = (s['weekNumber'] as num?)?.toInt() ?? (dData['weekNumber'] as num?)?.toInt();
            if (wy == null || ww == null) continue;
            if (wy != filterYear) continue;

            final m = _monthIndexFromWeek(wy, ww);
            if (m != filterMonth) continue;

            weeks.add(ww);
          }
          if (weeks.isNotEmpty) {
            weeks.sort();
            monthFirstWeek = weeks.first;
            monthLastWeek = weeks.last;
          }
        }

        final int? yearHeader = isYearView ? (filterYear ?? year) : null;

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // SCORECARD WEEK + date
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.tf('dash_scorecard_week', {'week': (weekNumber ?? '').toString()}),
                    style: const TextStyle(
                      fontSize: 12,
                      letterSpacing: 1.4,
                      color: Colors.black54,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    range,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _FilterPillRow(
                viewMode: _viewMode,
                onViewModeChanged: (mode) {
                  setState(() => _viewMode = mode);
                },
                timeFilter: _timeFilter,
                selectedMonthKey: currentMonthKey,
                selectedYear: _selectedYear,
                years: sortedYears,
                monthsByYear: sortedMonthsByYear,
                onTimeFilterChanged: (_TimeFilter newFilter, int? yearSel, String? monthKey) {
                  setState(() {
                    _timeFilter = newFilter;
                    if (newFilter == _TimeFilter.month) {
                      _selectedMonthKey = monthKey;
                    } else if (newFilter == _TimeFilter.year) {
                      _selectedYear = yearSel;
                    }
                  });
                },
                monthLabel: monthPillLabel,
                reports: reportDocs,
                selectedIndex: _selectedReportIndex,
                onWeekChanged: (newIndex) {
                  setState(() {
                    _selectedReportIndex = newIndex;
                    _timeFilter = _TimeFilter.week;
                  });
                },
              ),

              const SizedBox(height: 12),

              if (_viewMode == _ViewMode.company) ...[
                if (isWeekView)
                  _SummaryStrip(
                    weekNumber: weekNumber,
                    totalScore: overall,
                    rankText: rankText,
                    stationName: stationName,
                    statusText: statusText,
                    statusColor: statusColor,
                    reliability: reliability,
                    viewMode: _viewMode,
                  )
                else if (isMonthView && monthHeaderName != null)
                  _BestPeriodHeader(
                    title: loc.t('dash_best_da_month'),
                    subtitle: (monthFirstWeek != null && monthLastWeek != null)
                        ? '${monthHeaderName.toUpperCase()} | ${loc.t('kw')} $monthFirstWeek-$monthLastWeek'
                        : monthHeaderName.toUpperCase(),
                  )
                else if (isYearView && yearHeader != null)
                  _BestPeriodHeader(
                    title: loc.t('dash_best_da_year'),
                    subtitle: yearHeader.toString(),
                  ),
              ],

              const SizedBox(height: 18),

              // MAIN CONTENT
              StreamBuilder<Map<String, String>>(
                stream: _driverNamesForWeekCached(reportRef),
                builder: (context, weekSnap) {
                  final weekNames = weekSnap.data ?? const <String, String>{};

                  return StreamBuilder<Map<String, String>>(
                    stream: _globalNamesStreamCached,
                    builder: (context, globalSnap) {
                      final globalNames = globalSnap.data ?? const <String, String>{};

                      final nameMap = <String, String>{}
                        ..addAll(globalNames)
                        ..addAll(weekNames);

                      return StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
                        stream: scoreStream,
                        builder: (context, scoreSnap) {
                          if (scoreSnap.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          var docs = scoreSnap.data ?? [];
                          if (docs.isEmpty) {
                            return Center(
                              child: Text(loc.t('dash_no_scores_period')),
                            );
                          }

                          final isMonthly = _viewMode == _ViewMode.company &&
                              _timeFilter == _TimeFilter.month &&
                              currentMonthKey != null;
                          final isYearly = _viewMode == _ViewMode.company &&
                              _timeFilter == _TimeFilter.year &&
                              _selectedYear != null;

                          if (_viewMode == _ViewMode.company) {
                            // COMPANY VIEW
                            if (!isMonthly && !isYearly) {
                              final hasAnyRank = docs.any((d) => d.data()['rank'] != null);
                              docs.sort((a, b) {
                                if (hasAnyRank) {
                                  final ra = (a.data()['rank'] as num?)?.toInt() ?? 999999;
                                  final rb = (b.data()['rank'] as num?)?.toInt() ?? 999999;
                                  return ra.compareTo(rb);
                                }
                                final ca = (a.data()['comp'] ?? {}) as Map<String, dynamic>;
                                final cb = (b.data()['comp'] ?? {}) as Map<String, dynamic>;
                                final fa = _numOr0(ca['FinalScore']);
                                final fb = _numOr0(cb['FinalScore']);
                                return fb.compareTo(fa);
                              });

                              // Filter by bucket (kept logic)
                              if (_bucket != 'ALL') {
                                docs = docs.where((d) {
                                  final b = _s(d.data()['statusBucket']).toUpperCase();
                                  return b == _bucket;
                                }).toList();
                              }

                              // Search filter
                              if (_query.isNotEmpty) {
                                docs = docs.where((d) {
                                  final data = d.data();
                                  final tid = _s(data['transporterId']).toLowerCase();
                                  final name = _s(nameMap[_s(data['transporterId'])]).toLowerCase();
                                  return tid.contains(_query) || name.contains(_query);
                                }).toList();
                              }

                              if (docs.isEmpty) {
                                return Center(child: Text(loc.t('dash_no_drivers_match')));
                              }

                              return ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: docs.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 10),
                                itemBuilder: (context, i) {
                                  final data = docs[i].data();
                                  final compRaw = (data['comp'] ?? {});
                                  final comp = compRaw is Map<String, dynamic> ? compRaw : <String, dynamic>{};

                                  final tid = _s(data['transporterId']).trim();
                                  final name = _s(nameMap[tid]).isNotEmpty
                                      ? _s(nameMap[tid])
                                      : loc.t('dash_no_name');

                                  final score = _numOr0(comp['FinalScore']).toDouble();
                                  final rank = (data['rank'] as num?)?.toInt() ?? i + 1;
                                  final apiBucketRaw = _s(data['statusBucket']);
                                  final statusCode = apiBucketRaw.isNotEmpty
                                      ? apiBucketRaw
                                      : _statusCodeFromScore(score);
                                  final statusText = _prettyBucket(context, statusCode);
                                  final statusColor = _colorFromApiBucket(statusCode);

                                  return _LeaderboardRowCard(
                                    rank: rank,
                                    score: score,
                                    name: name,
                                    statusText: statusText,
                                    statusColor: statusColor,
                                  );
                                },
                              );
                            } else {
                              // Monthly / Yearly leaderboard: average per driver
                              final Map<String, _MonthlyAgg> aggMap = {};

                              for (final d in docs) {
                                final data = d.data();
                                final tid = _s(data['transporterId']).trim();
                                if (tid.isEmpty) continue;

                                final compRaw = (data['comp'] ?? {});
                                final comp = compRaw is Map<String, dynamic> ? compRaw : <String, dynamic>{};

                                final score = _numOr0(comp['FinalScore']).toDouble();
                                final agg = aggMap.putIfAbsent(tid, () => _MonthlyAgg());
                                agg.sumScore += score;
                                agg.count++;
                              }

                              var entries = <_MonthlyEntry>[];
                              aggMap.forEach((tid, agg) {
                                if (agg.count == 0) return;
                                final avgScore = agg.sumScore / agg.count;
                                entries.add(_MonthlyEntry(transporterId: tid, avgScore: avgScore));
                              });

                              if (_query.isNotEmpty) {
                                entries = entries.where((e) {
                                  final name = _s(nameMap[e.transporterId]).toLowerCase();
                                  final tid = e.transporterId.toLowerCase();
                                  return tid.contains(_query) || name.contains(_query);
                                }).toList();
                              }

                              entries.sort((a, b) => b.avgScore.compareTo(a.avgScore));

                              if (entries.isEmpty) {
                                return Center(child: Text(loc.t('dash_no_drivers_match')));
                              }

                              return ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: entries.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 10),
                                itemBuilder: (context, i) {
                                  final e = entries[i];
                                  final name = _s(nameMap[e.transporterId]).isNotEmpty
                                      ? _s(nameMap[e.transporterId])
                                      : loc.t('dash_no_name');
                                  final statusCode = _statusCodeFromScore(e.avgScore);
                                  final statusText = _prettyBucket(context, statusCode);
                                  final statusColor = _colorFromApiBucket(statusCode);

                                  return _LeaderboardRowCard(
                                    rank: i + 1,
                                    score: e.avgScore,
                                    name: name,
                                    statusText: statusText,
                                    statusColor: statusColor,
                                    backgroundColor: _monthlyBucketColorFromScore(e.avgScore),
                                  );
                                },
                              );
                            }
                          } else {
                            // MY SCORE VIEW (weekly only)
                            final myTid = widget.driverTransporterId.toUpperCase();

                            QueryDocumentSnapshot<Map<String, dynamic>>? myDoc;
                            for (final d in docs) {
                              final tid = _s(d.data()['transporterId']).toUpperCase();
                              if (tid == myTid) {
                                myDoc = d;
                                break;
                              }
                            }

                            if (myDoc == null) {
                              return Center(child: Text(loc.t('dash_no_my_score_week')));
                            }

                            final myData = myDoc.data();
                            final compRaw = (myData['comp'] ?? {});
                            final kpisRaw = (myData['kpis'] ?? {});
                            final comp = compRaw is Map<String, dynamic> ? compRaw : <String, dynamic>{};
                            final kpis = kpisRaw is Map<String, dynamic> ? kpisRaw : <String, dynamic>{};

                            final scoreTotal = _numOr0(comp['FinalScore']).toDouble();

                            final delivered = _numOr0(
                              kpis['Delivered'] ?? kpis['DELIVERED'] ?? kpis['delivered'],
                            ).toInt();

                            final rankMy = (myData['rank'] as num?)?.toInt();
                            final apiBucketRaw = _s(myData['statusBucket']);

                            final statusTextMy = apiBucketRaw.isNotEmpty
                                ? _prettyBucket(context, apiBucketRaw)
                                : _statusText(context, scoreTotal);

                            final statusColorMy = apiBucketRaw.isNotEmpty
                                ? _colorFromApiBucket(apiBucketRaw)
                                : _statusColor(scoreTotal);

                            final dcrScore = _numOr0(comp['DCR_Score']).toDouble();
                            final dnrScore = _numOr0(comp['DNR_Score']).toDouble();
                            final lorScore = _numOr0(comp['LoR_Score']).toDouble();
                            final podScore = _numOr0(comp['POD_Score']).toDouble();
                            final ccScore = _numOr0(comp['CC_Score']).toDouble();
                            final ceScore = _numOr0(comp['CE_Score'] ?? comp['CE']).toDouble();
                            final cdfScore = _numOr0(comp['CDF_Score']).toDouble();

                            final dcrValue = _numOr0(kpis['DCR'] ?? kpis['DCR %'] ?? kpis['DCR_PCT']).toDouble();
                            final dnrValue = _numOr0(kpis['DNR'] ?? kpis['DNR DPMO']).toDouble();
                            final lorValue = _numOr0(kpis['LoR'] ?? kpis['LoR DPMO']).toDouble();
                            final podValue = _numOr0(kpis['POD'] ?? kpis['POD %'] ?? kpis['POD_PCT']).toDouble();
                            final ccValue = _numOr0(kpis['CC'] ?? kpis['CC %'] ?? kpis['CC_PCT']).toDouble();
                            final ceValue = _numOr0(kpis['CE'] ?? kpis['CE %'] ?? kpis['CE_PCT']).toDouble();
                            final cdfValue = _numOr0(kpis['CDF'] ?? kpis['CDF DPMO']).toDouble();

                            final podQualityRaw = myData['podQuality'];
                            final podQualityMap = podQualityRaw is Map
                                ? Map<String, dynamic>.from(podQualityRaw as Map)
                                : <String, dynamic>{};

                            final podQuality = podQualityMap.isNotEmpty
                                ? _PodQualityStats(
                                    opportunities: _numOr0(podQualityMap['opportunities']).toDouble(),
                                    success: _numOr0(podQualityMap['success']).toDouble(),
                                    bypass: _numOr0(podQualityMap['bypass']).toDouble(),
                                    rejects: _numOr0(podQualityMap['rejects']).toDouble(),
                                    blurry: _numOr0(podQualityMap['blurryPhoto']).toDouble(),
                                    tooDark: _numOr0(podQualityMap['photoTooDark']).toDouble(),
                                    noPackage:
                                        _numOr0(podQualityMap['noPackageDetected']).toDouble(),
                                    inCar: _numOr0(podQualityMap['packageInCar']).toDouble(),
                                    tooClose: _numOr0(podQualityMap['packageTooClose']).toDouble(),
                                  )
                                : null;

                            final totalDrivers = docs.length;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _MySummaryStrip(
                                  totalScore: scoreTotal,
                                  delivered: delivered,
                                  rank: rankMy ?? 0,
                                  totalDrivers: totalDrivers,
                                  statusText: statusTextMy,
                                ),
                                const SizedBox(height: 18),
                                _MyScoreKpiList(
                                  totalScore: scoreTotal,
                                  delivered: delivered,
                                  rank: rankMy,
                                  statusText: statusTextMy,
                                  statusColor: statusColorMy,
                                  dcrScore: dcrScore,
                                  dcrValue: dcrValue,
                                  dnrScore: dnrScore,
                                  dnrValue: dnrValue,
                                  lorScore: lorScore,
                                  lorValue: lorValue,
                                  podScore: podScore,
                                  podValue: podValue,
                                  ccScore: ccScore,
                                  ccValue: ccValue,
                                  ceScore: ceScore,
                                  ceValue: ceValue,
                                  cdfScore: cdfScore,
                                  cdfValue: cdfValue,
                                  podQuality: podQuality,
                                ),
                              ],
                            );
                          }
                        },
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

// ===================== UI components (same as before, localized) =====================

class _FilterPillRow extends StatelessWidget {
  final _ViewMode viewMode;
  final ValueChanged<_ViewMode> onViewModeChanged;

  final _TimeFilter timeFilter;
  final String? selectedMonthKey;
  final int? selectedYear;
  final List<int> years;
  final Map<int, List<int>> monthsByYear;
  final void Function(_TimeFilter filter, int? year, String? monthKey) onTimeFilterChanged;

  final String monthLabel;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> reports;
  final int selectedIndex;
  final ValueChanged<int> onWeekChanged;

  const _FilterPillRow({
    required this.viewMode,
    required this.onViewModeChanged,
    required this.timeFilter,
    required this.selectedMonthKey,
    required this.selectedYear,
    required this.years,
    required this.monthsByYear,
    required this.onTimeFilterChanged,
    required this.monthLabel,
    required this.reports,
    required this.selectedIndex,
    required this.onWeekChanged,
  });

  // ✅ MOVED OUT OF build() so _showWeekPickerDialog() can access them
  int _weekOf(int i) {
    final d = reports[i].data();
    final summary = d['summary'];
    final s = summary is Map ? Map<String, dynamic>.from(summary as Map) : <String, dynamic>{};
    return (s['weekNumber'] as num?)?.toInt() ?? (d['weekNumber'] as num?)?.toInt() ?? 0;
  }

  int _yearOf(int i) {
    final d = reports[i].data();
    final summary = d['summary'];
    final s = summary is Map ? Map<String, dynamic>.from(summary as Map) : <String, dynamic>{};
    return (s['year'] as num?)?.toInt() ?? (d['year'] as num?)?.toInt() ?? DateTime.now().year;
  }

  String _stationOf(int i) {
    final d = reports[i].data();
    final summary = d['summary'];
    final s = summary is Map ? Map<String, dynamic>.from(summary as Map) : <String, dynamic>{};
    return _s(s['stationCode'] ?? d['stationCode']).toUpperCase();
  }

  String _weekPillLabel(BuildContext context, int idx) {
    final loc = AppLocalizations.of(context);
    final w = _weekOf(idx);
    final y = _yearOf(idx);
    final station = _stationOf(idx);
    return station.isNotEmpty
        ? '${loc.t('dash_week').toUpperCase()} $w • $y • $station'
        : '${loc.t('dash_week').toUpperCase()} $w • $y';
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    final scoreLabel = viewMode == _ViewMode.company
        ? loc.t('dash_company_score')
        : loc.t('dash_my_score');

    const pillHeight = 40.0;

    BoxDecoration _pillDec({required Color bg, required Color border}) {
      return BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border, width: 1.4),
      );
    }

    const pillTextStyle = TextStyle(
      fontSize: 11,
      letterSpacing: 0.6,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    );

    final scorePill = GestureDetector(
      onTap: () {
        final next = viewMode == _ViewMode.company ? _ViewMode.myScore : _ViewMode.company;
        onViewModeChanged(next);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: pillHeight,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: _pillDec(bg: Colors.white, border: _kPrimaryGreen),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              children: [
                Text(scoreLabel.toUpperCase(), style: pillTextStyle),
                const SizedBox(width: 6),
                const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.black87),
              ],
            ),
          ),
        ),
      ),
    );

    final weekPill = InkWell(
      onTap: () async {
        await _showWeekPickerDialog(context);
      },
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: pillHeight,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: _pillDec(bg: Colors.white, border: _kPrimaryGreen),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              children: [
                Text(
                  _weekPillLabel(context, selectedIndex),
                  style: pillTextStyle,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(width: 6),
                const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.black87),
              ],
            ),
          ),
        ),
      ),
    );

    final isCompany = viewMode == _ViewMode.company;

    final monthPill = InkWell(
      onTap: !isCompany ? null : () async => _showTimeFilterDialog(context),
      child: Container(
        height: pillHeight,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: _pillDec(
          bg: Colors.white,
          border: isCompany ? _kPrimaryGreen : Colors.grey.shade400,
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              children: [
                Text(
                  monthLabel.toUpperCase(),
                  style: pillTextStyle.copyWith(
                    color: isCompany ? Colors.black87 : Colors.grey.shade500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: isCompany ? Colors.black87 : Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTight = constraints.maxWidth < 720;

        if (!isTight) {
          return Row(
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 130),
                child: scorePill,
              ),
              const Spacer(),
              weekPill,
              const SizedBox(width: 5),
              monthPill,
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: scorePill),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: weekPill),
                const SizedBox(width: 5),
                Expanded(child: monthPill),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _showTimeFilterDialog(BuildContext context) async {
    final loc = AppLocalizations.of(context);

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
                        loc.t('dash_select_period'),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                          side: const BorderSide(color: _kPrimaryGreen, width: 1.1),
                        ),
                      ),
                      onPressed: () {
                        onTimeFilterChanged(_TimeFilter.week, null, null);
                        Navigator.of(ctx).pop();
                      },
                      child: Text(
                        loc.t('dash_weekly_view'),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _kPrimaryGreen,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      loc.t('dash_best_da_year'),
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
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                          selected: timeFilter == _TimeFilter.year && selectedYear == y,
                          onSelected: (_) {
                            onTimeFilterChanged(_TimeFilter.year, y, null);
                            Navigator.of(ctx).pop();
                          },
                        ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      loc.t('dash_best_da_month'),
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
                                    _shortMonthName(context, m),
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                  ),
                                  selected: timeFilter == _TimeFilter.month &&
                                      selectedMonthKey == '$y-${m.toString().padLeft(2, '0')}',
                                  onSelected: (_) {
                                    final key = '$y-${m.toString().padLeft(2, '0')}';
                                    onTimeFilterChanged(_TimeFilter.month, y, key);
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

  Future<void> _showWeekPickerDialog(BuildContext context) async {
    final loc = AppLocalizations.of(context);

    // Group report indices by year
    final Map<int, List<int>> byYear = {};
    for (int i = 0; i < reports.length; i++) {
      final y = _yearOf(i);
      byYear.putIfAbsent(y, () => []).add(i);
    }

    // Sort years (desc) and weeks (desc)
    final yearsSorted = byYear.keys.toList()..sort((a, b) => b.compareTo(a));
    for (final y in yearsSorted) {
      byYear[y]!.sort((a, b) => _weekOf(b).compareTo(_weekOf(a)));
    }

    // Default active year is year of currently selected report
    int activeYear = _yearOf(selectedIndex);
    if (!yearsSorted.contains(activeYear) && yearsSorted.isNotEmpty) {
      activeYear = yearsSorted.first;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            final list = byYear[activeYear] ?? const <int>[];

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
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
                          loc.t('dash_select_period'),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
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
                        loc.t('dash_best_da_year'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 34,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: yearsSorted.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final y = yearsSorted[i];
                          final selected = y == activeYear;
                          return ChoiceChip(
                            label: Text(
                              y.toString(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: selected ? Colors.white : Colors.black87,
                              ),
                            ),
                            selected: selected,
                            selectedColor: _kPrimaryGreen,
                            onSelected: (_) => setState(() => activeYear = y),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Text(
                          '${loc.t('dash_weekly_view')} • $activeYear',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                        ),
                        const Spacer(),
                        Text(
                          '${list.length}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 420),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final idx = list[i];
                          final w = _weekOf(idx);
                          final station = _stationOf(idx);
                          final isSelected = idx == selectedIndex;

                          return InkWell(
                            onTap: () {
                              onWeekChanged(idx);
                              Navigator.of(ctx).pop();
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? _kPrimaryGreen.withOpacity(0.10)
                                    : const Color(0xFFF7F8F8),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? _kPrimaryGreen : Colors.black12,
                                  width: isSelected ? 1.2 : 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    station.isNotEmpty
                                        ? '${loc.t('dash_week').toUpperCase()} $w • $station'
                                        : '${loc.t('dash_week').toUpperCase()} $w',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (isSelected)
                                    const Icon(Icons.check_circle, size: 18, color: _kPrimaryGreen)
                                  else
                                    const Icon(Icons.chevron_right, size: 18, color: Color(0xFF9CA3AF)),
                                ],
                              ),
                            ),
                          );
                        },
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

  String _shortMonthName(BuildContext context, int m) {
    final loc = AppLocalizations.of(context);
    switch (m) {
      case 1:
        return loc.t('month_short_jan');
      case 2:
        return loc.t('month_short_feb');
      case 3:
        return loc.t('month_short_mar');
      case 4:
        return loc.t('month_short_apr');
      case 5:
        return loc.t('month_short_may');
      case 6:
        return loc.t('month_short_jun');
      case 7:
        return loc.t('month_short_jul');
      case 8:
        return loc.t('month_short_aug');
      case 9:
        return loc.t('month_short_sep');
      case 10:
        return loc.t('month_short_oct');
      case 11:
        return loc.t('month_short_nov');
      case 12:
        return loc.t('month_short_dec');
      default:
        return '';
    }
  }
}


// ---------- Summary strip ----------

class _SummaryStrip extends StatelessWidget {
  final int? weekNumber;
  final double totalScore;
  final String rankText;
  final String stationName;
  final String statusText;
  final Color statusColor;
  final double? reliability;
  final _ViewMode viewMode;

  const _SummaryStrip({
    required this.weekNumber,
    required this.totalScore,
    required this.rankText,
    required this.stationName,
    required this.statusText,
    required this.statusColor,
    required this.reliability,
    required this.viewMode,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    if (viewMode == _ViewMode.myScore) {
      return const SizedBox.shrink();
    }

    const bgColor = _kPrimaryGreenLight;
    const borderColor = Colors.transparent;

    final labelColor = Colors.white.withOpacity(0.9);
    const valueColorDefault = Colors.white;
    final separatorColor = Colors.white.withOpacity(0.3);

    final totalScoreStr =
        totalScore == 0 ? '—' : totalScore.toStringAsFixed(2).replaceAll('.', ',');

    Widget _cell({
      required String label,
      required String value,
      Color? valueColor,
    }) {
      return Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 7.7,
                letterSpacing: 0.7,
                color: labelColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                height: 1.1,
                fontWeight: FontWeight.w800,
                color: valueColor ?? valueColorDefault,
              ),
            ),
          ],
        ),
      );
    }

    final cells = <Widget>[
      _cell(
        label: loc.t('dash_rank_in_station'),
        value: rankText,
      ),
      _cell(
        label: loc.t('dash_status'),
        value: statusText.toUpperCase(),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (int i = 0; i < cells.length; i++) ...[
            cells[i],
            if (i != cells.length - 1) ...[
              const SizedBox(width: 12),
              Container(width: 1, height: 32, color: separatorColor),
              const SizedBox(width: 12),
            ],
          ],
        ],
      ),
    );
  }
}

class _MySummaryStrip extends StatelessWidget {
  final double totalScore;
  final int delivered;
  final int rank;
  final int totalDrivers;
  final String statusText;

  const _MySummaryStrip({
    required this.totalScore,
    required this.delivered,
    required this.rank,
    required this.totalDrivers,
    required this.statusText,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    final scoreStr =
        totalScore == 0 ? '—' : totalScore.toStringAsFixed(2).replaceAll('.', ',');
    final deliveredStr = delivered > 0 ? delivered.toString() : '—';
    final rankStr = (rank > 0 && totalDrivers > 0)
        ? loc.tf('dash_rank_of_total', {'rank': '$rank', 'total': '$totalDrivers'})
        : '—';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2F78A5),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Row(
        children: [
          _cell(loc.t('dash_total_score'), scoreStr),
          _divider(),
          _cell(loc.t('dash_delivered'), deliveredStr),
          _divider(),
          _cell(loc.t('dash_rank_in_aion'), rankStr),
          _divider(),
          _cell(loc.t('dash_status'), statusText.toUpperCase(), isStatus: true),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: Colors.white.withOpacity(0.5),
    );
  }

  Widget _cell(String label, String value, {bool isStatus = false}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Text(
                label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 8,
                  letterSpacing: 1.1,
                  color: Colors.white.withOpacity(0.85),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: TextStyle(
                  fontSize: isStatus ? 14 : 18,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BestPeriodHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _BestPeriodHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.0,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// ---------- Leaderboard row (company view) ----------

class _LeaderboardRowCard extends StatelessWidget {
  final int rank;
  final double score;
  final String name;
  final String statusText;
  final Color statusColor;
  final Color? backgroundColor;

  const _LeaderboardRowCard({
    required this.rank,
    required this.score,
    required this.name,
    required this.statusText,
    required this.statusColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    final scoreStr = score.toStringAsFixed(2).replaceAll('.', ',');

    final bool isColored = backgroundColor != null;
    final Color textColor = isColored ? Colors.white : const Color(0xFF4B5563);
    final Color labelColor = isColored ? Colors.white70 : const Color(0xFF9CA3AF);
    final Color pillTextColor = isColored ? Colors.white : statusColor;
    final Color pillBgColor =
        isColored ? Colors.white.withOpacity(0.2) : statusColor.withOpacity(0.15);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isColored ? backgroundColor! : Colors.grey.shade300,
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                flex: 1,
                child: _col(
                  label: loc.t('dash_rank'),
                  value: '#$rank',
                  maxLines: 1,
                  labelColor: labelColor,
                  textColor: textColor,
                ),
              ),
              _separator(isColored),
              Expanded(
                flex: 1,
                child: _col(
                  label: loc.t('dash_score'),
                  value: scoreStr,
                  maxLines: 1,
                  labelColor: labelColor,
                  textColor: textColor,
                ),
              ),
              _separator(isColored),
              Expanded(
                flex: 2,
                child: _col(
                  label: loc.t('dash_name'),
                  value: name.isEmpty ? loc.t('dash_no_name') : name,
                  maxLines: 2,
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: pillBgColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusText.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: pillTextColor,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _separator(bool isColored) {
    return Container(
      width: 1,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      color: isColored ? Colors.white54 : Colors.grey.shade300,
    );
  }

  Widget _col({
    required String label,
    required String value,
    required Color labelColor,
    required Color textColor,
    int maxLines = 1,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.1,
            color: labelColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
      ],
    );
  }
}

// ---------- Helpers for monthly/yearly aggregation ----------

class _MonthlyAgg {
  double sumScore = 0;
  int count = 0;
}

class _MonthlyEntry {
  final String transporterId;
  final double avgScore;

  _MonthlyEntry({
    required this.transporterId,
    required this.avgScore,
  });
}

// ---------- My Score KPI tiles ----------

class _MyScoreKpiList extends StatelessWidget {
  final double totalScore;
  final int delivered;
  final int? rank;
  final String statusText;
  final Color statusColor;

  final double dcrScore;
  final double dcrValue;

  final double dnrScore;
  final double dnrValue;

  final double lorScore;
  final double lorValue;

  final double podScore;
  final double podValue;

  final double ccScore;
  final double ccValue;

  final double ceScore;
  final double ceValue;

  final double cdfScore;
  final double cdfValue;

  final _PodQualityStats? podQuality;

  const _MyScoreKpiList({
    required this.totalScore,
    required this.delivered,
    required this.rank,
    required this.statusText,
    required this.statusColor,
    required this.dcrScore,
    required this.dcrValue,
    required this.dnrScore,
    required this.dnrValue,
    required this.lorScore,
    required this.lorValue,
    required this.podScore,
    required this.podValue,
    required this.ccScore,
    required this.ccValue,
    required this.ceScore,
    required this.ceValue,
    required this.cdfScore,
    required this.cdfValue,
    required this.podQuality,
  });

  Color _kpiColorFromScore(double s) {
    if (s >= 93) return const Color(0xFF16A34A);
    if (s >= 85) return const Color(0xFF22C55E);
    if (s >= 70) return const Color(0xFFF59E0B);
    if (s >= 50) return const Color(0xFFFBBF24);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Column(
      children: [
        const SizedBox(height: 8),
        _ExpandableKpiTile(
          code: 'DCR',
          score: dcrScore,
          value: dcrValue,
          color: _kpiColorFromScore(dcrScore),
          title: loc.t('kpi_title_dcr'),
          description: loc.t('kpi_desc_dcr'),
          proTip: loc.t('kpi_tip_dcr'),
          podQuality: null,
        ),
        _ExpandableKpiTile(
          code: 'DSC DPMO',
          score: dnrScore,
          value: dnrValue,
          color: _kpiColorFromScore(dnrScore),
          title: loc.t('kpi_title_dnr'),
          description: loc.t('kpi_desc_dnr'),
          proTip: loc.t('kpi_tip_dnr'),
          podQuality: null,
        ),
        _ExpandableKpiTile(
          code: 'LoR',
          score: lorScore,
          value: lorValue,
          color: _kpiColorFromScore(lorScore),
          title: loc.t('kpi_title_lor'),
          description: loc.t('kpi_desc_lor'),
          proTip: loc.t('kpi_tip_lor'),
          podQuality: null,
        ),
        _ExpandableKpiTile(
          code: 'POD',
          score: podScore,
          value: podValue,
          color: _kpiColorFromScore(podScore),
          title: loc.t('kpi_title_pod'),
          description: loc.t('kpi_desc_pod'),
          proTip: loc.t('kpi_tip_pod'),
          podQuality: podQuality,
        ),
        _ExpandableKpiTile(
          code: 'CC',
          score: ccScore,
          value: ccValue,
          color: _kpiColorFromScore(ccScore),
          title: loc.t('kpi_title_cc'),
          description: loc.t('kpi_desc_cc'),
          proTip: loc.t('kpi_tip_cc'),
          podQuality: null,
        ),
        _ExpandableKpiTile(
          code: 'CE',
          score: ceScore,
          value: ceValue,
          color: _kpiColorFromScore(ceScore),
          title: loc.t('kpi_title_ce'),
          description: loc.t('kpi_desc_ce'),
          proTip: loc.t('kpi_tip_ce'),
          podQuality: null,
        ),
        _ExpandableKpiTile(
          code: 'CDF',
          score: cdfScore,
          value: cdfValue,
          color: _kpiColorFromScore(cdfScore),
          title: loc.t('kpi_title_cdf'),
          description: loc.t('kpi_desc_cdf'),
          proTip: loc.t('kpi_tip_cdf'),
          podQuality: null,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _ExpandableKpiTile extends StatefulWidget {
  final String code;
  final double score;
  final double value;
  final Color color;

  final String title;
  final String description;
  final String proTip;
  final _PodQualityStats? podQuality;

  const _ExpandableKpiTile({
    required this.code,
    required this.score,
    required this.value,
    required this.color,
    required this.title,
    required this.description,
    required this.proTip,
    required this.podQuality,
  });

  @override
  State<_ExpandableKpiTile> createState() => _ExpandableKpiTileState();
}

class _ExpandableKpiTileState extends State<_ExpandableKpiTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    final scoreStr = widget.score.toStringAsFixed(2).replaceAll('.', ',');
    final valueStr = widget.value.toStringAsFixed(2).replaceAll('.', ',');

    const labelStyle = TextStyle(
      fontSize: 11,
      letterSpacing: 1.2,
      fontWeight: FontWeight.w700,
      color: Color(0xFF9CA3AF),
    );

    const valueStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w800,
      color: Color(0xFF374151),
    );

    Widget metricColumn(String label, String value) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label, style: labelStyle),
          const SizedBox(height: 4),
          Text(
            value,
            style: valueStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
              child: Row(
                children: [
                  SizedBox(
                    width: 130,
                    height: 70,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: widget.color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          widget.code.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(child: metricColumn(loc.t('kpi_score'), scoreStr)),
                        Container(
                          width: 1,
                          height: 28,
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          color: const Color(0xFFE5E7EB),
                        ),
                        Expanded(child: metricColumn(loc.t('kpi_value'), valueStr)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: const Color(0xFF6B7280),
                  ),
                ],
              ),
            ),
          ),

          if (_expanded) const Divider(height: 1, color: Color(0xFFE5E7EB)),
          if (_expanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFF7F7F7),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.podQuality != null) ...[
                    _PodQualityInline(stats: widget.podQuality!),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF374151),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.description,
                              style: const TextStyle(
                                fontSize: 12,
                                height: 1.4,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.t('kpi_pro_tip'),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _kPrimaryGreen,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.proTip,
                              style: const TextStyle(
                                fontSize: 12,
                                height: 1.4,
                                color: Color(0xFF374151),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PodQualityStats {
  final double opportunities;
  final double success;
  final double bypass;
  final double rejects;
  final double blurry;
  final double tooDark;
  final double noPackage;
  final double inCar;
  final double tooClose;

  const _PodQualityStats({
    required this.opportunities,
    required this.success,
    required this.bypass,
    required this.rejects,
    required this.blurry,
    required this.tooDark,
    required this.noPackage,
    required this.inCar,
    required this.tooClose,
  });

  double? get successPct =>
      opportunities > 0 ? (success / opportunities) * 100.0 : null;

  double? get rejectsPct =>
      opportunities > 0 ? (rejects / opportunities) * 100.0 : null;
}

enum _PodTone { good, warn }

class _PodQualityInline extends StatelessWidget {
  final _PodQualityStats stats;

  const _PodQualityInline({required this.stats});

  String _fmtInt(double v) => v.toStringAsFixed(0).replaceAll('.', ',');

  String _fmtPct(double? v) =>
      v == null ? '—' : '${v.toStringAsFixed(2).replaceAll('.', ',')} %';

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  loc.t('pod_quality_title'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ),
              _PodStatPill(
                label: loc.t('pod_quality_success'),
                value: _fmtPct(stats.successPct),
                tone: _PodTone.good,
              ),
              const SizedBox(width: 8),
              _PodStatPill(
                label: loc.t('pod_quality_rejects'),
                value: _fmtPct(stats.rejectsPct),
                tone: _PodTone.warn,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _PodMiniStat(
                label: loc.t('pod_quality_opp'),
                value: _fmtInt(stats.opportunities),
              ),
              _PodMiniStat(
                label: loc.t('pod_quality_success'),
                value: _fmtInt(stats.success),
              ),
              _PodMiniStat(
                label: loc.t('pod_quality_bypass'),
                value: _fmtInt(stats.bypass),
              ),
              _PodMiniStat(
                label: loc.t('pod_quality_rejects'),
                value: _fmtInt(stats.rejects),
              ),
              _PodMiniStat(
                label: loc.t('pod_quality_blurry'),
                value: _fmtInt(stats.blurry),
              ),
              _PodMiniStat(
                label: loc.t('pod_quality_too_dark'),
                value: _fmtInt(stats.tooDark),
              ),
              _PodMiniStat(
                label: loc.t('pod_quality_no_package'),
                value: _fmtInt(stats.noPackage),
              ),
              _PodMiniStat(
                label: loc.t('pod_quality_in_car'),
                value: _fmtInt(stats.inCar),
              ),
              _PodMiniStat(
                label: loc.t('pod_quality_too_close'),
                value: _fmtInt(stats.tooClose),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PodStatPill extends StatelessWidget {
  final String label;
  final String value;
  final _PodTone tone;

  const _PodStatPill({
    required this.label,
    required this.value,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg =
        tone == _PodTone.good ? const Color(0xFFDCFCE7) : const Color(0xFFFFEDD5);
    final Color fg =
        tone == _PodTone.good ? const Color(0xFF15803D) : const Color(0xFF9A3412);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _PodMiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _PodMiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}
