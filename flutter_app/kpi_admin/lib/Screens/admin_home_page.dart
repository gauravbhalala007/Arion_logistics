import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  static const _kBorder = Color(0xFFE5E7EB);
  static const _kCardBg = Colors.white;
  static const _kMuted = Color(0xFF9CA3AF);
  static const _kText = Color(0xFF111827);
  static const _kSubText = Color(0xFF4B5563);
  static const _kGreen = Color(0xFF1D7F5A);
  static const _kOrange = Color(0xFFE9741A);

  static const _kPageBg = Color(0xFFF3F6F7);

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // ------------------------------------------------------------
  // Popup: Not confirmed by (copied logic from NotificationsPage)
  // ------------------------------------------------------------
  Future<void> _openNotConfirmedPopup({
    required BuildContext context,
    required String dspUid,
    required String notificationId,
    required int confirmedCount,
    required int targetCount,
  }) async {

    // ✅ Load notification details (title/body) once for the popup header
    final notifDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(dspUid)
        .collection('notifications')
        .doc(notificationId)
        .get();

    final notifTitle = (notifDoc.data()?['title'] ?? 'Notification').toString();
    final notifBody = (notifDoc.data()?['body'] ?? '').toString();
    
    Future<List<String>> loadMissingDrivers() async {
      final driversSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(dspUid)
          .collection('drivers')
          .get();

      final missing = <String>[];

      for (final d in driversSnap.docs) {
        final driverData = d.data();
        final driverName =
            (driverData['driverName'] ?? driverData['fullName'] ?? 'Driver')
                .toString();

        final notifSnap = await FirebaseFirestore.instance
            .collection('users')
            .doc(dspUid)
            .collection('drivers')
            .doc(d.id)
            .collection('notifications')
            .doc(notificationId)
            .get();

        final status = (notifSnap.data()?['status'] ?? 'unread').toString();

        if (status != 'confirmed') {
          missing.add(driverName);
        }
      }

      return missing;
    }

    await showDialog(
      context: context,
      barrierDismissible: true,
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
                // ✅ Notification context (TITLE + BODY)
                Text(
                  notifTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (notifBody.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    notifBody,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4B5563),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // ✅ Existing section header
                Row(
                  children: [
                    const Text(
                      'NOT CONFIRMED BY:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'missing: ${(targetCount - confirmedCount) < 0 ? 0 : (targetCount - confirmedCount)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFE9741A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 10),

                // ✅ Your list stays unchanged
                SizedBox(
                  height: 420,

                  child: FutureBuilder<List<String>>(
                    future: loadMissingDrivers(),
                    builder: (ctx, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snap.hasError) {
                        return Center(child: Text('Error: ${snap.error}'));
                      }

                      final items = snap.data ?? [];
                      if (items.isEmpty) {
                        return const Center(
                          child: Text(
                            'All drivers have confirmed.',
                            style: TextStyle(color: Colors.black54),
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              items[i],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AdminHomePage._kPageBg,
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          final w = constraints.maxWidth;

          final scale = _clampDouble(w / 1440.0, 0.78, 1.0);
          final bool isStacked = w < 980;
          final bool isTight = w < 1200;

          final pad = _r(24, scale);
          final gap = _r(isTight ? 12 : 16, scale);

          return Padding(
            padding: EdgeInsets.all(pad),
            child: isStacked
                ? _StackedLayout(
                    scale: scale,
                    gap: gap,
                    dspUid: _uid,
                    onOpenMissing: (notifId, confirmedCount, targetCount) {
                      final uid = _uid;
                      if (uid == null) return;
                      _openNotConfirmedPopup(
                        context: context,
                        dspUid: uid,
                        notificationId: notifId,
                        confirmedCount: confirmedCount,
                        targetCount: targetCount,
                      );
                    },
                  )
                : _DesktopLayout(
                    scale: scale,
                    gap: gap,
                    dspUid: _uid,
                    onOpenMissing: (notifId, confirmedCount, targetCount) {
                      final uid = _uid;
                      if (uid == null) return;
                      _openNotConfirmedPopup(
                        context: context,
                        dspUid: uid,
                        notificationId: notifId,
                        confirmedCount: confirmedCount,
                        targetCount: targetCount,
                      );
                    },
                  ),
          );
        },
      ),
    );

  }
}

// ---------------------------
// Layouts
// ---------------------------

class _DesktopLayout extends StatelessWidget {
  final double scale;
  final double gap;
  final String? dspUid;
  final void Function(String notificationId, int confirmedCount, int targetCount)
      onOpenMissing;

  const _DesktopLayout({
    required this.scale,
    required this.gap,
    required this.dspUid,
    required this.onOpenMissing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 7,
                child: Column(
                  children: [
                    _ScorecardCard(scale: scale),
                    SizedBox(height: gap),
                    Expanded(child: _FleetHubCard(scale: scale)),
                  ],
                ),
              ),
              SizedBox(width: gap),
              Expanded(
                flex: 5,
                child: _NotificationHistoryCard(
                  scale: scale,
                  dspUid: dspUid,
                  onOpenMissing: onOpenMissing,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: gap),
        SizedBox(
          height: _r(280, scale),
          child: _DriverDocumentsCard(scale: scale),
        ),
      ],
    );
  }
}

class _StackedLayout extends StatelessWidget {
  final double scale;
  final double gap;
  final String? dspUid;
  final void Function(String notificationId, int confirmedCount, int targetCount)
      onOpenMissing;

  const _StackedLayout({
    required this.scale,
    required this.gap,
    required this.dspUid,
    required this.onOpenMissing,
  });

  @override
  Widget build(BuildContext context) {
    final hScore = _r(320, scale);
    final hFleet = _r(520, scale);
    final hNotif = _r(520, scale);
    final hDocs = _r(320, scale);

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: hScore, child: _ScorecardCard(scale: scale)),
          SizedBox(height: gap),
          SizedBox(height: hFleet, child: _FleetHubCard(scale: scale)),
          SizedBox(height: gap),
          SizedBox(
            height: hNotif,
            child: _NotificationHistoryCard(
              scale: scale,
              dspUid: dspUid,
              onOpenMissing: onOpenMissing,
            ),
          ),
          SizedBox(height: gap),
          SizedBox(height: hDocs, child: _DriverDocumentsCard(scale: scale)),
        ],
      ),
    );
  }
}

// ---------------------------
// Card shell
// ---------------------------

class _AdminCard extends StatelessWidget {
  final Widget child;
  final double scale;

  const _AdminCard({
    required this.child,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final radius = _r(22, scale);
    final pad = _r(18, scale);

    return Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: AdminHomePage._kCardBg,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AdminHomePage._kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: _r(10, scale),
            offset: Offset(0, _r(4, scale)),
          )
        ],
      ),
      child: child,
    );
  }
}

// ---------------------------
// SCORECARD (BACKEND CONNECTED, UI KEPT)
// ---------------------------

class _ScorecardCard extends StatefulWidget {
  final double scale;
  const _ScorecardCard({required this.scale});

  @override
  State<_ScorecardCard> createState() => _ScorecardCardState();
}

class _ScorecardCardState extends State<_ScorecardCard> {
  // selection encoding:
  //  W|__LAST__              -> last week
  //  W|<reportDocId>         -> a specific week report
  //  M|YYYY-MM               -> month aggregation
  //  Y|YYYY                  -> year aggregation
  String _selectedKey = 'W|__LAST__';

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Stream<QuerySnapshot<Map<String, dynamic>>> _reportsStream() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('reports')
        .orderBy('year', descending: true)
        .orderBy('weekNumber', descending: true)
        .snapshots();
  }

  // comp.FinalScore parsing
  double _scoreFromDoc(Map<String, dynamic> data) {
    final compRaw = data['comp'];
    final comp = compRaw is Map
        ? Map<String, dynamic>.from(compRaw as Map)
        : <String, dynamic>{};

    final v = comp['FinalScore'];
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();

    final s = v.toString().trim().replaceAll('%', '').replaceAll(',', '.');
    return double.tryParse(s) ?? 0.0;
  }

  String _fmtScore(double v) => v.toStringAsFixed(2).replaceAll('.', ',');

  int? _weekOfReport(Map<String, dynamic> data) {
    final sRaw = data['summary'];
    final s = sRaw is Map
        ? Map<String, dynamic>.from(sRaw as Map)
        : <String, dynamic>{};

    return (data['weekNumber'] as num?)?.toInt() ??
        (s['weekNumber'] as num?)?.toInt();
  }

  int? _yearOfReport(Map<String, dynamic> data) {
    final sRaw = data['summary'];
    final s = sRaw is Map
        ? Map<String, dynamic>.from(sRaw as Map)
        : <String, dynamic>{};

    return (data['year'] as num?)?.toInt() ?? (s['year'] as num?)?.toInt();
  }

  // ISO-week -> month index
  int _monthIndexFromWeek(int year, int week) {
    final jan4 = DateTime.utc(year, 1, 4);
    final weekDayOfJan4 = jan4.weekday; // 1..7
    final mondayOfWeek1 = jan4.subtract(Duration(days: weekDayOfJan4 - 1));
    final mondayOfTarget = mondayOfWeek1.add(Duration(days: (week - 1) * 7));
    return mondayOfTarget.month;
  }

  String _monthName(int m) {
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return names[(m.clamp(1, 12) - 1)];
  }

  double _companyOverallFromReportDoc(
      QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final data = d.data();
    final sRaw = data['summary'];
    final s = sRaw is Map
        ? Map<String, dynamic>.from(sRaw as Map)
        : <String, dynamic>{};

    return (s['overallScore'] as num?)?.toDouble() ??
        (data['overallScore'] as num?)?.toDouble() ??
        0.0;
  }

  // Names (week-level driverNames overrides global drivers)
  Stream<Map<String, String>> _driverNamesForWeek(
      DocumentReference<Map<String, dynamic>> reportRef) {
    return reportRef.collection('driverNames').snapshots().map((snap) {
      final m = <String, String>{};
      for (final d in snap.docs) {
        final data = d.data();
        final tid = (data['transporterId'] ?? d.id).toString().trim();
        final name = (data['driverName'] ?? '').toString().trim();
        if (tid.isNotEmpty && name.isNotEmpty) m[tid] = name;
      }
      return m;
    });
  }

  Stream<Map<String, String>> _driversNameMapGlobal() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('drivers')
        .snapshots()
        .map((snap) {
      final m = <String, String>{};
      for (final d in snap.docs) {
        final data = d.data();
        final tid = (data['transporterId'] ?? '').toString().trim();
        final name =
            (data['driverName'] ?? data['fullName'] ?? '').toString().trim();
        if (tid.isNotEmpty && name.isNotEmpty) m[tid] = name;
      }
      return m;
    });
  }

  // Week: stream (live)
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _scoresForReportRef(
    DocumentReference<Map<String, dynamic>> reportRef,
  ) {
    final uid = _uid;
    if (uid == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('scores')
        .where('reportRef', isEqualTo: reportRef)
        .snapshots()
        .map((s) => s.docs);
  }

  // Month/Year: Future-based aggregation with whereIn chunking (10 max)
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _scoresForReportRefs(
    List<DocumentReference<Map<String, dynamic>>> reportRefs,
  ) async {
    final uid = _uid;
    if (uid == null || reportRefs.isEmpty) return [];

    const chunkSize = 10;
    final allDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];

    for (int i = 0; i < reportRefs.length; i += chunkSize) {
      final chunk =
          reportRefs.sublist(i, (i + chunkSize).clamp(0, reportRefs.length));

      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('scores')
          .where('reportRef', whereIn: chunk)
          .get();

      allDocs.addAll(snap.docs);
    }
    return allDocs;
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;

    return _AdminCard(
      scale: scale,
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _reportsStream(),
        builder: (ctx, reportSnap) {
          final uid = _uid;

          // --- Not logged in ---
          if (uid == null) {
            return _ScorecardShellLive(
              scale: scale,
              companyScore: '—',
              dropdownItems: const ['Last Week'],
              dropdownValue: 'Last Week',
              onDropdownChanged: (_) {},
              best: const [],
              worst: const [],
              footerText: 'Not logged in.',
            );
          }

          if (reportSnap.connectionState == ConnectionState.waiting) {
            return _ScorecardShellLive(
              scale: scale,
              companyScore: '—',
              dropdownItems: const ['Last Week'],
              dropdownValue: 'Last Week',
              onDropdownChanged: (_) {},
              best: const [],
              worst: const [],
              footerText: 'Loading reports…',
            );
          }

          if (reportSnap.hasError) {
            return _ScorecardShellLive(
              scale: scale,
              companyScore: '—',
              dropdownItems: const ['Last Week'],
              dropdownValue: 'Last Week',
              onDropdownChanged: (_) {},
              best: const [],
              worst: const [],
              footerText: 'Error: ${reportSnap.error}',
            );
          }

          // IMPORTANT: typed copy fixes Flutter Web _JsonQueryDocumentSnapshot issues
          final List<QueryDocumentSnapshot<Map<String, dynamic>>> reportDocs =
              List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(
            reportSnap.data?.docs ??
                const <QueryDocumentSnapshot<Map<String, dynamic>>>[],
          );

          if (reportDocs.isEmpty) {
            return _ScorecardShellLive(
              scale: scale,
              companyScore: '—',
              dropdownItems: const ['Last Week'],
              dropdownValue: 'Last Week',
              onDropdownChanged: (_) {},
              best: const [],
              worst: const [],
              footerText: 'No reports uploaded yet.',
            );
          }

          final latest = reportDocs.first;

          // Build year/month availability from reports
          final years = <int>{};
          final monthsByYear = <int, Set<int>>{};

          for (final r in reportDocs) {
            final data = r.data();
            final y = _yearOfReport(data);
            final w = _weekOfReport(data);
            if (y == null || w == null) continue;

            years.add(y);
            final m = _monthIndexFromWeek(y, w);
            monthsByYear.putIfAbsent(y, () => <int>{}).add(m);
          }

          final sortedYears = years.toList()..sort((a, b) => b.compareTo(a));
          final sortedMonthsByYear = <int, List<int>>{
            for (final y in sortedYears)
              y: (monthsByYear[y]?.toList() ?? [])..sort((a, b) => a.compareTo(b))
          };

          // Dropdown entries
          final entries = <_DropdownEntry>[];
          entries.add(const _DropdownEntry(key: 'W|__LAST__', label: 'Last Week'));

          // Weeks
          for (final r in reportDocs) {
            final data = r.data();
            final w = _weekOfReport(data);
            final y = _yearOfReport(data);
            final label = (w != null && y != null) ? 'KW $w | $y' : 'KW';
            entries.add(_DropdownEntry(key: 'W|${r.id}', label: label));
          }

          // Months
          for (final y in sortedYears) {
            for (final m in (sortedMonthsByYear[y] ?? const <int>[])) {
              final mm = m.toString().padLeft(2, '0');
              entries.add(_DropdownEntry(
                key: 'M|$y-$mm',
                label: 'MONTH: ${_monthName(m)} $y',
              ));
            }
          }

          // Years
          for (final y in sortedYears) {
            entries.add(_DropdownEntry(key: 'Y|$y', label: 'YEAR: $y'));
          }

          // Ensure selection still valid
          if (!entries.any((e) => e.key == _selectedKey)) {
            _selectedKey = 'W|__LAST__';
          }

          final selected =
              entries.firstWhere((e) => e.key == _selectedKey);

          // Resolve selected reportRefs + companyScore aggregation
          List<DocumentReference<Map<String, dynamic>>> reportRefs = [];
          double companySum = 0.0;
          int companyCount = 0;

          if (_selectedKey.startsWith('W|')) {
            QueryDocumentSnapshot<Map<String, dynamic>> reportDoc;

            if (_selectedKey == 'W|__LAST__') {
              reportDoc = latest;
            } else {
              final id = _selectedKey.substring(2);
              reportDoc = reportDocs.firstWhere(
                (d) => d.id == id,
                orElse: () => latest,
              );
            }

            reportRefs = [reportDoc.reference];
            final v = _companyOverallFromReportDoc(reportDoc);
            if (v > 0) {
              companySum = v;
              companyCount = 1;
            }
          } else if (_selectedKey.startsWith('M|')) {
            final key = _selectedKey.substring(2); // YYYY-MM
            final parts = key.split('-');
            final y = parts.length == 2 ? int.tryParse(parts[0]) : null;
            final m = parts.length == 2 ? int.tryParse(parts[1]) : null;

            if (y != null && m != null) {
              for (final r in reportDocs) {
                final data = r.data();
                final ry = _yearOfReport(data);
                final rw = _weekOfReport(data);
                if (ry == null || rw == null) continue;
                if (ry != y) continue;

                final rm = _monthIndexFromWeek(ry, rw);
                if (rm != m) continue;

                reportRefs.add(r.reference);

                final v = _companyOverallFromReportDoc(r);
                if (v > 0) {
                  companySum += v;
                  companyCount++;
                }
              }
            }
          } else if (_selectedKey.startsWith('Y|')) {
            final y = int.tryParse(_selectedKey.substring(2));
            if (y != null) {
              for (final r in reportDocs) {
                final data = r.data();
                final ry = _yearOfReport(data);
                final rw = _weekOfReport(data);
                if (ry == null || rw == null) continue;
                if (ry != y) continue;

                reportRefs.add(r.reference);

                final v = _companyOverallFromReportDoc(r);
                if (v > 0) {
                  companySum += v;
                  companyCount++;
                }
              }
            }
          }

          final companyScore =
              (companyCount > 0) ? (companySum / companyCount) : 0.0;
          final companyScoreStr =
              companyScore <= 0 ? '—' : _fmtScore(companyScore);

          final isWeekView = _selectedKey.startsWith('W|');
          final weekRef =
              isWeekView && reportRefs.isNotEmpty ? reportRefs.first : null;

          final weekNamesStream = (weekRef != null)
              ? _driverNamesForWeek(weekRef)
              : Stream.value(const <String, String>{});

          return StreamBuilder<Map<String, String>>(
            stream: weekNamesStream,
            builder: (ctx, weekNamesSnap) {
              final weekNames = weekNamesSnap.data ?? const <String, String>{};

              return StreamBuilder<Map<String, String>>(
                stream: _driversNameMapGlobal(),
                builder: (ctx, globalNamesSnap) {
                  final globalNames =
                      globalNamesSnap.data ?? const <String, String>{};

                  final nameMap = <String, String>{}
                    ..addAll(globalNames)
                    ..addAll(weekNames);

                  // WEEK: live stream
                  if (isWeekView && reportRefs.isNotEmpty) {
                    return StreamBuilder<
                        List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
                      stream: _scoresForReportRef(reportRefs.first),
                      builder: (ctx, scoreSnap) {
                        final docs = scoreSnap.data ??
                            const <QueryDocumentSnapshot<Map<String, dynamic>>>[];

                        final bestWorst = _computeBestWorst(
                          docs,
                          nameMap,
                          scoreFromDoc: _scoreFromDoc,
                        );

                        return _ScorecardShellLive(
                          scale: scale,
                          companyScore: companyScoreStr,
                          dropdownItems: entries.map((e) => e.label).toList(),
                          dropdownValue: selected.label,
                          onDropdownChanged: (label) {
                            final hit = entries.firstWhere(
                              (e) => e.label == label,
                              orElse: () => entries.first,
                            );
                            setState(() => _selectedKey = hit.key);
                          },
                          best: bestWorst.best,
                          worst: bestWorst.worst,
                          footerText: scoreSnap.connectionState ==
                                  ConnectionState.waiting
                              ? 'Loading scores…'
                              : null,
                        );
                      },
                    );
                  }

                  // MONTH/YEAR: Future aggregation (avg per driver)
                  return FutureBuilder<
                      List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
                    future: _scoresForReportRefs(reportRefs),
                    builder: (ctx, scoreSnap) {
                      final docs = scoreSnap.data ??
                          const <QueryDocumentSnapshot<Map<String, dynamic>>>[];

                      final bestWorst = _computeBestWorst(
                        docs,
                        nameMap,
                        scoreFromDoc: _scoreFromDoc,
                        aggregateAveragePerDriver: true,
                      );

                      return _ScorecardShellLive(
                        scale: scale,
                        companyScore: companyScoreStr,
                        dropdownItems: entries.map((e) => e.label).toList(),
                        dropdownValue: selected.label,
                        onDropdownChanged: (label) {
                          final hit = entries.firstWhere(
                            (e) => e.label == label,
                            orElse: () => entries.first,
                          );
                          setState(() => _selectedKey = hit.key);
                        },
                        best: bestWorst.best,
                        worst: bestWorst.worst,
                        footerText: scoreSnap.connectionState ==
                                ConnectionState.waiting
                            ? 'Loading scores…'
                            : null,
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// ---------- scorecard models + compute ----------

class _DropdownEntry {
  final String key;
  final String label;
  const _DropdownEntry({required this.key, required this.label});
}

class _ScoreEntry {
  final String transporterId;
  final String name;
  final double score;

  _ScoreEntry({
    required this.transporterId,
    required this.name,
    required this.score,
  });
}

class _BestWorstResult {
  final List<_ScoreEntry> best;
  final List<_ScoreEntry> worst;
  const _BestWorstResult({required this.best, required this.worst});
}

// Worst Defender ranking rule: lowest comp.FinalScore = worst
_BestWorstResult _computeBestWorst(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  Map<String, String> nameMap, {
  required double Function(Map<String, dynamic>) scoreFromDoc,
  bool aggregateAveragePerDriver = false,
}) {
  if (!aggregateAveragePerDriver) {
    final entries = <_ScoreEntry>[];

    for (final d in docs) {
      final data = d.data();
      final tid = (data['transporterId'] ?? '').toString().trim();
      final score = scoreFromDoc(data);

      final name = (tid.isNotEmpty && (nameMap[tid] ?? '').trim().isNotEmpty)
          ? nameMap[tid]!.trim()
          : (tid.isNotEmpty ? tid : 'Vorname Nachname');

      entries.add(_ScoreEntry(transporterId: tid, name: name, score: score));
    }

    final best = List<_ScoreEntry>.from(entries)
      ..sort((a, b) => b.score.compareTo(a.score));
    final worst = List<_ScoreEntry>.from(entries)
      ..sort((a, b) => a.score.compareTo(b.score)); // lowest = worst

    return _BestWorstResult(best: best.take(5).toList(), worst: worst.take(5).toList());
  }

  // Month/Year: average score per transporterId
  final sum = <String, double>{};
  final count = <String, int>{};

  for (final d in docs) {
    final data = d.data();
    final tid = (data['transporterId'] ?? '').toString().trim();
    if (tid.isEmpty) continue;

    final score = scoreFromDoc(data);
    sum[tid] = (sum[tid] ?? 0) + score;
    count[tid] = (count[tid] ?? 0) + 1;
  }

  final entries = <_ScoreEntry>[];
  sum.forEach((tid, s) {
    final c = count[tid] ?? 0;
    if (c <= 0) return;
    final avg = s / c;

    final name =
        (nameMap[tid] ?? '').trim().isNotEmpty ? nameMap[tid]!.trim() : tid;

    entries.add(_ScoreEntry(transporterId: tid, name: name, score: avg));
  });

  final best = List<_ScoreEntry>.from(entries)
    ..sort((a, b) => b.score.compareTo(a.score));
  final worst = List<_ScoreEntry>.from(entries)
    ..sort((a, b) => a.score.compareTo(b.score)); // lowest = worst

  return _BestWorstResult(best: best.take(5).toList(), worst: worst.take(5).toList());
}

// ---------- scorecard UI shell (same look, but live data) ----------

class _ScorecardShellLive extends StatelessWidget {
  final double scale;

  final String companyScore;
  final List<String> dropdownItems;
  final String dropdownValue;
  final ValueChanged<String> onDropdownChanged;

  final List<_ScoreEntry> best;
  final List<_ScoreEntry> worst;

  final String? footerText;

  const _ScorecardShellLive({
    required this.scale,
    required this.companyScore,
    required this.dropdownItems,
    required this.dropdownValue,
    required this.onDropdownChanged,
    required this.best,
    required this.worst,
    this.footerText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.assignment_outlined,
                color: AdminHomePage._kGreen, size: _r(22, scale)),
            SizedBox(width: _r(10, scale)),
            Text(
              'Scorecard',
              style: TextStyle(
                fontSize: _r(20, scale),
                fontWeight: FontWeight.w900,
                color: AdminHomePage._kText,
              ),
            ),
            const Spacer(),
            Text(
              'COMPANY SCORE',
              style: TextStyle(
                fontSize: _r(12, scale),
                fontWeight: FontWeight.w900,
                color: AdminHomePage._kText,
              ),
            ),
            SizedBox(width: _r(8, scale)),
            Text(
              companyScore,
              style: TextStyle(
                fontSize: _r(16, scale),
                fontWeight: FontWeight.w900,
                color: AdminHomePage._kGreen,
              ),
            ),
            SizedBox(width: _r(8, scale)),
            Text(
              'of',
              style: TextStyle(
                color: AdminHomePage._kMuted,
                fontSize: _r(12, scale),
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: _r(8, scale)),
            _PillPopupDropdown(
              scale: scale,
              items: dropdownItems,
              value: dropdownValue,
              onChanged: onDropdownChanged,
            ),
          ],
        ),
        SizedBox(height: _r(14, scale)),
        Row(
          children: [
            Expanded(
              child: _MiniRankingLive(
                scale: scale,
                title: 'Best Driver',
                positive: true,
                items: best,
              ),
            ),
            SizedBox(width: _r(16, scale)),
            Expanded(
              child: _MiniRankingLive(
                scale: scale,
                title: 'Worst Defender',
                positive: false,
                items: worst,
              ),
            ),
          ],
        ),
        if (footerText != null) ...[
          SizedBox(height: _r(8, scale)),
          Text(
            footerText!,
            style: TextStyle(
              color: AdminHomePage._kMuted,
              fontSize: _r(12, scale),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}

class _MiniRankingLive extends StatelessWidget {
  final double scale;
  final String title;
  final bool positive;
  final List<_ScoreEntry> items;

  const _MiniRankingLive({
    required this.scale,
    required this.title,
    required this.positive,
    required this.items,
  });

  String _fmt(double v) => v.toStringAsFixed(2).replaceAll('.', ',');

  @override
  Widget build(BuildContext context) {
    final rows = List.generate(5, (i) => i + 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: _r(13, scale),
            fontWeight: FontWeight.w800,
            color: AdminHomePage._kText,
          ),
        ),
        SizedBox(height: _r(10, scale)),
        ...rows.map((rank) {
          final isAlt = rank.isEven;
          final entry = (rank - 1 < items.length) ? items[rank - 1] : null;

          return Container(
            margin: EdgeInsets.only(bottom: _r(8, scale)),
            padding: EdgeInsets.symmetric(
              horizontal: _r(12, scale),
              vertical: _r(10, scale),
            ),
            decoration: BoxDecoration(
              color: isAlt ? const Color(0xFFF6F7F9) : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(_r(12, scale)),
              border: Border.all(color: const Color(0xFFEDEFF3)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: _r(18, scale),
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AdminHomePage._kText,
                      fontSize: _r(12, scale),
                    ),
                  ),
                ),
                SizedBox(width: _r(10, scale)),
                Expanded(
                  child: Text(
                    entry?.name ?? '—',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: _r(12, scale),
                    ),
                  ),
                ),
                Text(
                  entry == null ? '—' : _fmt(entry.score),
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: _r(12, scale),
                    color: positive
                        ? AdminHomePage._kGreen
                        : AdminHomePage._kOrange,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}


// ---------------------------
// NOTIFICATION HISTORY (BACKEND CONNECTED)
// ---------------------------

class _NotificationHistoryCard extends StatefulWidget {
  final double scale;
  final String? dspUid;
  final void Function(String notificationId, int confirmedCount, int targetCount)
      onOpenMissing;

  const _NotificationHistoryCard({
    required this.scale,
    required this.dspUid,
    required this.onOpenMissing,
  });

  @override
  State<_NotificationHistoryCard> createState() => _NotificationHistoryCardState();
}

class _NotificationHistoryCardState extends State<_NotificationHistoryCard> {
  late final ScrollController _scrollCtrl;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    final dspUid = widget.dspUid;
    final onOpenMissing = widget.onOpenMissing;

    return _AdminCard(
      scale: scale,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notifications_none,
                  color: AdminHomePage._kGreen, size: _r(22, scale)),
              SizedBox(width: _r(10, scale)),
              Text(
                'Notification History',
                style: TextStyle(
                  fontSize: _r(20, scale),
                  fontWeight: FontWeight.w900,
                  color: AdminHomePage._kText,
                ),
              ),
            ],
          ),
          SizedBox(height: _r(12, scale)),
          const Divider(height: 1),
          SizedBox(height: _r(12, scale)),
          Expanded(
            child: dspUid == null
                ? const Center(child: Text('Not logged in'))
                : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(dspUid)
                        .collection('notifications')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (ctx, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snap.hasError) {
                        return Center(child: Text('Error: ${snap.error}'));
                      }

                      final docs = snap.data?.docs ?? [];
                      if (docs.isEmpty) {
                        return const Center(
                          child: Text(
                            'No notifications yet.',
                            style: TextStyle(color: Colors.black54),
                          ),
                        );
                      }

                      return Scrollbar(
                        controller: _scrollCtrl,
                        thumbVisibility: true,
                        child: ListView.separated(
                          controller: _scrollCtrl,
                          primary: false,
                          itemCount: docs.length,
                          separatorBuilder: (_, __) =>
                              SizedBox(height: _r(12, scale)),
                          itemBuilder: (_, i) {
                            final d = docs[i];
                            final data = d.data();

                            final title = (data['title'] ?? '').toString();
                            final body = (data['body'] ?? '').toString();

                            final confirmedCount =
                                (data['confirmedCount'] as num?)?.toInt() ?? 0;
                            final targetCount =
                                (data['targetCount'] as num?)?.toInt() ?? 0;

                            final ts = data['createdAt'];
                            final dt = ts is Timestamp ? ts.toDate() : null;

                            final type = (data['type'] ?? 'rule').toString();

                            return InkWell(
                              borderRadius: BorderRadius.circular(_r(16, scale)),
                              onTap: () =>
                                  onOpenMissing(d.id, confirmedCount, targetCount),
                              child: _NotificationHistoryTileLive(
                                scale: scale,
                                dspUid: dspUid,
                                notificationId: d.id,
                                type: type,
                                title: title,
                                body: body,
                                dateTime: dt,
                                confirmedCount: confirmedCount,
                                targetCount: targetCount,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}


class _NotificationHistoryTileLive extends StatelessWidget {
  final double scale;

  final String dspUid;
  final String notificationId;

  final String type;
  final String title;
  final String body;
  final DateTime? dateTime;

  final int confirmedCount;
  final int targetCount;

  const _NotificationHistoryTileLive({
    required this.scale,
    required this.dspUid,
    required this.notificationId,
    required this.type,
    required this.title,
    required this.body,
    required this.dateTime,
    required this.confirmedCount,
    required this.targetCount,
  });

  String _fmtDate(DateTime? dt) {
    if (dt == null) return '';
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final yy = dt.year.toString();
    final hh = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$dd.$mm.$yy | $hh:$min Uhr';
  }

  String _typeLabel(String t) {
    switch (t) {
      case 'message':
        return 'NEW MESSAGE';
      case 'academy':
        return 'DA ACADEMY';
      case 'rideAlong':
        return 'RIDE ALONG';
      case 'rule':
      default:
        return 'NEW RULE';
    }
  }

  IconData _typeIcon(String t) {
    switch (t) {
      case 'message':
        return Icons.chat_bubble_outline;
      case 'academy':
        return Icons.school_outlined;
      case 'rideAlong':
        return Icons.directions_car_filled_outlined;
      case 'rule':
      default:
        return Icons.gavel;
    }
  }

  Future<void> _deleteEverywhere(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Delete notification?'),
          content: const Text(
            'This will delete this notification for you and for all drivers.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (ok != true) return;

    try {
      final callable =
          FirebaseFunctions.instance.httpsCallable('deleteNotificationEverywhere');
      await callable.call({
        'dspUid': dspUid,
        'notificationId': notificationId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification deleted.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ratio =
        (targetCount <= 0) ? '0 / 0' : '$confirmedCount / $targetCount';

    return Container(
      padding: EdgeInsets.all(_r(14, scale)),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(_r(16, scale)),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: _r(56, scale),
            height: _r(56, scale),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(_r(16, scale)),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Icon(
              _typeIcon(type),
              color: const Color(0xFF6B7280),
              size: _r(22, scale),
            ),
          ),
          SizedBox(width: _r(12, scale)),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${_typeLabel(type)} | ${title.isEmpty ? 'TITLE' : title}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: _r(12, scale),
                        ),
                      ),
                    ),
                    SizedBox(width: _r(8, scale)),
                    Text(
                      'confirmed by',
                      style: TextStyle(
                        fontSize: _r(10, scale),
                        color: AdminHomePage._kMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: _r(6, scale)),
                    Text(
                      ratio,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AdminHomePage._kGreen,
                        fontSize: _r(12, scale),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: _r(4, scale)),
                if (_fmtDate(dateTime).isNotEmpty)
                  Text(
                    _fmtDate(dateTime),
                    style: TextStyle(
                      fontSize: _r(11, scale),
                      color: AdminHomePage._kMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                SizedBox(height: _r(8, scale)),
                Text(
                  body.isEmpty ? '—' : body,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: _r(12, scale),
                    height: 1.25,
                    color: AdminHomePage._kSubText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: _r(10, scale)),

          Theme(
            data: Theme.of(context).copyWith(
              popupMenuTheme: PopupMenuThemeData(
                color: const Color(0xFFF3F6F7),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_r(14, scale)),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
              ),
            ),
            child: SizedBox(
              width: _r(36, scale),
              height: _r(36, scale),
              child: Center(
                child: PopupMenuButton<String>(
                  tooltip: 'Options',
                  splashRadius: _r(18, scale),
                  offset: const Offset(0, 10),
                  onSelected: (v) {
                    if (v == 'delete') _deleteEverywhere(context);
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem<String>(
                      value: 'delete',
                      padding: EdgeInsets.symmetric(
                        horizontal: _r(12, scale),
                        vertical: _r(10, scale),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: _r(18, scale),
                            color: const Color(0xFFE11D48),
                          ),
                          SizedBox(width: _r(10, scale)),
                          const Text(
                            'Delete',
                            style: TextStyle(
                              color: Color(0xFFE11D48),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  icon: Icon(
                    Icons.more_vert,
                    size: _r(18, scale),
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------
// FLEET HUB (unchanged dummy UI)
// ---------------------------

class _FleetHubCard extends StatelessWidget {
  final double scale;
  const _FleetHubCard({required this.scale});

  @override
  Widget build(BuildContext context) {
    return _AdminCard(
      scale: scale,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.directions_car_filled_outlined,
                  color: AdminHomePage._kGreen, size: _r(22, scale)),
              SizedBox(width: _r(10, scale)),
              Text(
                'Fleet Hub',
                style: TextStyle(
                  fontSize: _r(20, scale),
                  fontWeight: FontWeight.w900,
                  color: AdminHomePage._kText,
                ),
              ),
              const Spacer(),
              _FleetStats(scale: scale),
            ],
          ),
          SizedBox(height: _r(14, scale)),
          Expanded(
            child: Row(
              children: [
                Expanded(
                    child:
                        _FleetList(scale: scale, title: 'Service', tag: 'SERVICE')),
                SizedBox(width: _r(16, scale)),
                const VerticalDivider(width: 1),
                SizedBox(width: _r(16, scale)),
                Expanded(
                    child:
                        _FleetList(scale: scale, title: 'Accidents', tag: 'TDV')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FleetStats extends StatelessWidget {
  final double scale;
  const _FleetStats({required this.scale});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MiniStat(
            scale: scale, label: 'total', value: '57', color: AdminHomePage._kText),
        SizedBox(width: _r(14, scale)),
        _MiniStat(
            scale: scale,
            label: 'active',
            value: '45',
            color: AdminHomePage._kGreen),
        SizedBox(width: _r(14, scale)),
        _MiniStat(
            scale: scale,
            label: 'inactive',
            value: '12',
            color: AdminHomePage._kOrange),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final double scale;
  final String label;
  final String value;
  final Color color;

  const _MiniStat({
    required this.scale,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: AdminHomePage._kMuted,
            fontSize: _r(12, scale),
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(width: _r(6, scale)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: color,
            fontSize: _r(12, scale),
          ),
        ),
      ],
    );
  }
}

class _FleetList extends StatelessWidget {
  final double scale;
  final String title;
  final String tag;
  const _FleetList({
    required this.scale,
    required this.title,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    final items = List.generate(6, (i) => i);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: _r(13, scale),
          ),
        ),
        SizedBox(height: _r(10, scale)),
        Expanded(
          child: ListView.separated(
            primary: false,
            itemCount: items.length,
            separatorBuilder: (_, __) => SizedBox(height: _r(10, scale)),
            itemBuilder: (_, i) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: _r(12, scale),
                  vertical: _r(10, scale),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F7F9),
                  borderRadius: BorderRadius.circular(_r(12, scale)),
                  border: Border.all(color: const Color(0xFFEDEFF3)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'FÜ DE 319',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: _r(12, scale),
                        ),
                      ),
                    ),
                    _SmallTag(scale: scale, label: tag),
                    SizedBox(width: _r(10, scale)),
                    Text(
                      '30.03.26',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AdminHomePage._kOrange,
                        fontSize: _r(12, scale),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SmallTag extends StatelessWidget {
  final double scale;
  final String label;
  const _SmallTag({required this.scale, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _r(10, scale),
        vertical: _r(4, scale),
      ),
      decoration: BoxDecoration(
        color: AdminHomePage._kOrange.withOpacity(0.14),
        borderRadius: BorderRadius.circular(_r(999, scale)),
        border: Border.all(color: AdminHomePage._kOrange.withOpacity(0.30)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: _r(10, scale),
          fontWeight: FontWeight.w900,
          color: AdminHomePage._kOrange,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// ---------------------------
// DRIVER DOCUMENTS (unchanged dummy UI)
// ---------------------------

// ---------------------------
// DRIVER DOCUMENTS (BACKEND CONNECTED, UI KEPT)
// ---------------------------
// ===========================
// DRIVER DOCUMENTS (V2 - matches designer UI)
// Drop-in replacement for your current Driver Documents card section
// ===========================

class _DriverDocumentsCard extends StatefulWidget {
  final double scale;
  const _DriverDocumentsCard({required this.scale});

  @override
  State<_DriverDocumentsCard> createState() => _DriverDocumentsCardState();
}

class _DriverDocumentsCardState extends State<_DriverDocumentsCard> {
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  static const int _kSoonDays = 30;

  // Onboarding expiry keys -> labels
  static const List<_ExpiryField> _expiryFields = [
    _ExpiryField(key: 'idDocExpiry', label: 'ID Card'),
    _ExpiryField(key: 'licenseExpiry', label: 'Driving License'),
    _ExpiryField(key: 'residencePermitExpiry', label: 'Residence Permit'),
  ];

  // Required onboarding fields for "Missing Documents / Data"
  static const List<_RequiredField> _requiredOnboardingFields = [
    _RequiredField(key: 'phone', label: 'Phone'),
    _RequiredField(key: 'bankIban', label: 'IBAN'),
    _RequiredField(key: 'dateOfBirth', label: 'Date of Birth'),
    _RequiredField(key: 'address', label: 'Address'),
    _RequiredField(key: 'city', label: 'City'),
    _RequiredField(key: 'postalCode', label: 'Postal Code'),
    _RequiredField(key: 'country', label: 'Country'),
    _RequiredField(key: 'licenseNumber', label: 'License Number'),
    _RequiredField(key: 'taxId', label: 'Tax ID'),
    _RequiredField(key: 'emergencyContactName', label: 'Emergency Contact Name'),
    _RequiredField(key: 'emergencyContactPhone', label: 'Emergency Contact Phone'),
  ];

  // Required docs in /documents (we accept either docId match OR "type" match)
  // Exact Firestore doc IDs we require (groups)
  static const List<List<String>> _requiredDocGroups = [
    // Driving license needs both
    ['driver_license_front', 'driver_license_back'],

    // Residence permit needs one doc
    ['resident_permit'],

    // Tax ID needs one doc
    ['tax_id'],

    // Identity must be EITHER (id card both sides) OR (passport both sides)
    // We'll handle this as a special OR condition below.
  ];

  bool _hasDocIdWithUrl(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    String docId,
  ) {
    final target = docId.toLowerCase().trim();

    for (final d in docs) {
      if (d.id.toLowerCase().trim() != target) continue;

      final url = _extractUrl(d.data());
      if (url.isNotEmpty) return true;
    }
    return false;
  }

  bool _hasAllInGroup(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    List<String> group,
  ) {
    for (final id in group) {
      if (!_hasDocIdWithUrl(docs, id)) return false;
    }
    return true;
  }

  bool _hasDocId(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs, String id) {
    final target = id.toLowerCase().trim();
    for (final d in docs) {
      if (d.id.toLowerCase().trim() == target) return true;
    }
    return false;
  }

  List<String> _missingDriverDocs(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    // hard-required
    const requiredSingles = <String>[
      'driver_license_front',
      'driver_license_back',
      'resident_permit',
      'tax_id',
    ];

    final missing = <String>[];

    for (final id in requiredSingles) {
      if (!_hasDocId(docs, id)) missing.add(id);
    }

    // Either ID card (front+back) OR passport (front+back)
    final hasIdCard =
        _hasDocId(docs, 'id_card_front') && _hasDocId(docs, 'id_card_back');
    final hasPassport =
        _hasDocId(docs, 'passport_front') && _hasDocId(docs, 'passport_back');

    if (!hasIdCard && !hasPassport) {
      // add a single logical requirement marker (not both sets)
      missing.add('id_card_or_passport');
    }

    return missing;
  }




  Stream<QuerySnapshot<Map<String, dynamic>>> _driversStream() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('drivers')
        .snapshots();
  }

  DateTime _startOfTodayLocal() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is Timestamp) return v.toDate();

    final s = v.toString().trim();
    if (s.isEmpty) return null;

    final slashMatch = RegExp(r'^(\d{1,2})\/(\d{1,2})\/(\d{4})$');
    final match = slashMatch.firstMatch(s);
    if (match != null) {
      final d = int.tryParse(match.group(1)!);
      final m = int.tryParse(match.group(2)!);
      final y = int.tryParse(match.group(3)!);
      if (d != null && m != null && y != null) {
        return DateTime(y, m, d);
      }
    }

    final iso = DateTime.tryParse(s);
    if (iso != null) return DateTime(iso.year, iso.month, iso.day);

    return null;
  }

  DateTime _addMonthsClamped(DateTime date, int months) {
    final totalMonths = (date.month - 1) + months;
    final year = date.year + (totalMonths ~/ 12);
    final month = (totalMonths % 12) + 1;
    final lastDay = DateTime(year, month + 1, 0).day;
    final day = date.day <= lastDay ? date.day : lastDay;
    return DateTime(year, month, day);
  }

  DateTime? _probationEndFromStart(DateTime? start) {
    if (start == null) return null;
    final sixMonthsLater = _addMonthsClamped(start, 6);
    return sixMonthsLater.subtract(const Duration(days: 1));
  }

  String _fmtShortDate(DateTime? dt) {
    if (dt == null) return '—';
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final yy = (dt.year % 100).toString().padLeft(2, '0');
    return '$dd.$mm.$yy';
  }

  // Try to find a URL-like field in a document map
  String _extractUrl(Map<String, dynamic> docData) {
    final candidates = ['url', 'fileUrl', 'downloadUrl', 'storageUrl'];
    for (final k in candidates) {
      final v = docData[k];
      final s = (v ?? '').toString().trim();
      if (s.startsWith('http')) return s;
    }
    return '';
  }

  // Loads doc snapshots for all drivers
  Future<Map<String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>>
      _loadDocumentsForDrivers(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> drivers,
  ) async {
    final uid = _uid;
    if (uid == null) return {};

    final out =
        <String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>{};

    final futures = drivers.map((d) async {
      final transporterId =
          (d.data()['transporterId'] ?? d.id).toString().trim();
      if (transporterId.isEmpty) return;

      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('drivers')
          .doc(transporterId)
          .collection('documents')
          .get();

      out[transporterId] = snap.docs;
    }).toList();

    await Future.wait(futures);
    return out;
  }

  // Checks if a specific required doc exists and has a usable URL
  bool _hasDocType(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    String type,
  ) {
    final t = type.toLowerCase();

    for (final d in docs) {
      final id = d.id.toLowerCase().trim();
      final data = d.data();

      final docType = (data['type'] ?? data['docType'] ?? '')
          .toString()
          .toLowerCase()
          .trim();

      final url = _extractUrl(data);

      final matches = id == t ||
          docType == t ||
          docType.contains(t) ||
          id.contains(t);

      if (matches && url.isNotEmpty) return true;
    }
    return false;
  }

  ({DateTime? endDate, String pill, _PillTone tone}) _extractContractInfo(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    for (final d in docs) {
      final id = d.id.toLowerCase().trim();
      final data = d.data();

      final docType = (data['type'] ?? data['docType'] ?? '')
          .toString()
          .toLowerCase()
          .trim();

      final isContract = id == 'contract' ||
          docType == 'contract' ||
          docType.contains('contract');

      if (!isContract) continue;

      // 1) End date
      DateTime? end;
      for (final k in ['endDate', 'expiry', 'expiresAt', 'validUntil']) {
        final dt = _parseDate(data[k]);
        if (dt != null) {
          end = DateTime(dt.year, dt.month, dt.day);
          break;
        }
      }

      // 2) Contract subtype (adjust mapping to your schema if needed)
      final raw = (data['contractType'] ??
              data['subType'] ??
              data['label'] ??
              data['status'] ??
              '')
          .toString()
          .trim();

      String pill = raw.isEmpty ? 'Contract' : raw;
      _PillTone tone = _PillTone.yellow;

      final lc = raw.toLowerCase();
      if (lc.contains('probe')) {
        pill = raw.isEmpty ? 'Probezeit' : raw;
        tone = _PillTone.blue;
      } else if (lc.contains('lim')) {
        pill = raw.isEmpty ? 'lim. Contract' : raw;
        tone = _PillTone.yellow;
      } else {
        // default: keep yellow
        tone = _PillTone.yellow;
      }

      return (endDate: end, pill: pill, tone: tone);
    }

    return (endDate: null, pill: '', tone: _PillTone.yellow);
  }

  bool _isEmpty(dynamic v) {
    if (v == null) return true;
    if (v is String) return v.trim().isEmpty;
    return v.toString().trim().isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;

    return _AdminCard(
      scale: scale,
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _driversStream(),
        builder: (ctx, snap) {
          final uid = _uid;
          if (uid == null) {
            return _DriverDocsShellV2(
              scale: scale,
              expiredSoonCount: 0,
              expiredRows: const [],
              missingCount: 0,
              missingNames: const [],
              contractSoonCount: 0,
              contractRows: const [],
            );
          }

          if (snap.connectionState == ConnectionState.waiting) {
            return _DriverDocsShellV2(
              scale: scale,
              expiredSoonCount: 0,
              expiredRows: const [],
              missingCount: 0,
              missingNames: const [],
              contractSoonCount: 0,
              contractRows: const [],
              footerText: 'Loading drivers…',
            );
          }
          if (snap.hasError) {
            return _DriverDocsShellV2(
              scale: scale,
              expiredSoonCount: 0,
              expiredRows: const [],
              missingCount: 0,
              missingNames: const [],
              contractSoonCount: 0,
              contractRows: const [],
              footerText: 'Error: ${snap.error}',
            );
          }

          final drivers = List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(
            snap.data?.docs ??
                const <QueryDocumentSnapshot<Map<String, dynamic>>>[],
          );

          if (drivers.isEmpty) {
            return _DriverDocsShellV2(
              scale: scale,
              expiredSoonCount: 0,
              expiredRows: const [],
              missingCount: 0,
              missingNames: const [],
              contractSoonCount: 0,
              contractRows: const [],
              footerText: 'No drivers yet.',
            );
          }

          return FutureBuilder<
              Map<String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>>(
            future: _loadDocumentsForDrivers(drivers),
            builder: (ctx, docsSnap) {
              final docsByTid = docsSnap.data ?? const {};

              final today = _startOfTodayLocal();
              final soonLimit = today.add(const Duration(days: _kSoonDays));

              // -------------------------
              // Expired Documents (grouped by driver)
              // -------------------------
              final Map<String, List<String>> expiredPillsByDriver = {};
              final Map<String, DateTime> expiredDateByDriver = {};
              final Set<String> soonDrivers = {};

              // -------------------------
              // Missing Names
              // -------------------------
              final Set<String> missingDrivers = {};

              // -------------------------
              // Contracts
              // -------------------------
              final List<_DocRowUi> contractRowsUi = [];
              final Set<String> contractSoonDrivers = {};

              for (final d in drivers) {
                final data = d.data();

                final transporterId =
                    (data['transporterId'] ?? d.id).toString().trim();
                final driverName =
                    (data['driverName'] ?? data['fullName'] ?? transporterId)
                        .toString()
                        .trim();

                final onboardingRaw = data['onboarding'];
                final onboarding = onboardingRaw is Map
                    ? Map<String, dynamic>.from(onboardingRaw as Map)
                    : <String, dynamic>{};

                final hasOnboarding = onboarding.isNotEmpty;

                final docs = docsByTid[transporterId] ??
                    const <QueryDocumentSnapshot<Map<String, dynamic>>>[];

                // ---- Expiry scan from onboarding fields ----
                if (hasOnboarding) {
                  for (final f in _expiryFields) {
                    final dt = _parseDate(onboarding[f.key]);
                    if (dt == null) continue;

                    final day = DateTime(dt.year, dt.month, dt.day);

                    final isExpired = day.isBefore(today);
                    final isSoon = !isExpired &&
                        (day.isBefore(soonLimit) ||
                            day.isAtSameMomentAs(soonLimit));

                    if (isExpired || isSoon) {
                      expiredPillsByDriver.putIfAbsent(
                          driverName, () => <String>[]);

                      if (!expiredPillsByDriver[driverName]!.contains(f.label)) {
                        expiredPillsByDriver[driverName]!.add(f.label);
                      }

                      final cur = expiredDateByDriver[driverName];
                      if (cur == null || day.isBefore(cur)) {
                        expiredDateByDriver[driverName] = day;
                      }
                    }

                    if (isSoon) {
                      soonDrivers.add(driverName);
                    }
                  }
                }

                // ---- Missing logic: DOCUMENTS ONLY ----
                // Required:
                //  - driver_license_front + driver_license_back
                //  - resident_permit
                //  - tax_id
                //  - (id_card_front + id_card_back) OR (passport_front + passport_back)

                final missing = _missingDriverDocs(docs);

                if (missing.isNotEmpty) {
                  // driver is missing at least 1 required doc
                  missingDrivers.add(driverName);
                }


                // ---- Contracts (✅ from onboarding.contractExpiry) ----
                final cEnd = _parseDate(onboarding['contractExpiry']);
                if (cEnd != null) {
                  final isExpired = cEnd.isBefore(today);
                  final isSoon = !isExpired &&
                      (cEnd.isBefore(soonLimit) || cEnd.isAtSameMomentAs(soonLimit));

                  if (isExpired || isSoon) {
                    contractRowsUi.add(_DocRowUi(
                      name: driverName,
                      contractPill: 'Contract',
                      contractTone: _PillTone.yellow, // keep your style, adjust if needed
                      rightPrefix: 'last day',
                      date: cEnd,
                    ));
                  }

                  if (isSoon) contractSoonDrivers.add(driverName);
                }

                final workStart = _parseDate(onboarding['workStartDate']);
                final probationEnd = _probationEndFromStart(workStart);
                if (probationEnd != null) {
                  final isExpired = probationEnd.isBefore(today);
                  final isSoon = !isExpired &&
                      (probationEnd.isBefore(soonLimit) ||
                          probationEnd.isAtSameMomentAs(soonLimit));

                  if (isExpired || isSoon) {
                    contractRowsUi.add(_DocRowUi(
                      name: driverName,
                      contractPill: 'Probezeit',
                      contractTone: _PillTone.blue,
                      rightPrefix: isExpired ? 'ended' : 'ends',
                      date: probationEnd,
                    ));
                  }

                  if (isSoon) contractSoonDrivers.add(driverName);
                }

              }

              // Build expired UI rows
              final expiredRowsUi = <_DocRowUi>[];
              expiredPillsByDriver.forEach((name, pills) {
                expiredRowsUi.add(_DocRowUi(
                  name: name,
                  pills: pills,
                  rightPrefix: 'expired by',
                  date: expiredDateByDriver[name],
                ));
              });

              // Sort: earliest date first
              expiredRowsUi.sort((a, b) =>
                  (a.date ?? DateTime(2100)).compareTo(b.date ?? DateTime(2100)));
              contractRowsUi.sort((a, b) =>
                  (a.date ?? DateTime(2100)).compareTo(b.date ?? DateTime(2100)));

              // Missing names
              final missingNamesUi = missingDrivers.toList()..sort();

              return _DriverDocsShellV2(
                scale: scale,
                // COUNTS
                expiredSoonCount: soonDrivers.length,
                expiredRows: expiredRowsUi.take(4).toList(), // keep dashboard summary

                missingCount: missingDrivers.length,
                missingNames: missingNamesUi, // ✅ DO NOT LIMIT (scroll will show all)

                contractSoonCount: contractSoonDrivers.length,
                contractRows: contractRowsUi.take(4).toList(), // keep dashboard summary

                footerText: (docsSnap.connectionState == ConnectionState.waiting)
                    ? 'Loading documents…'
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}

// ===========================
// Driver Docs Shell (Designer UI)
// ===========================

class _DriverDocsShellV2 extends StatelessWidget {
  final double scale;

  final int expiredSoonCount;
  final List<_DocRowUi> expiredRows;

  final int missingCount;
  final List<String> missingNames;

  final int contractSoonCount;
  final List<_DocRowUi> contractRows;

  final String? footerText;

  const _DriverDocsShellV2({
    required this.scale,
    required this.expiredSoonCount,
    required this.expiredRows,
    required this.missingCount,
    required this.missingNames,
    required this.contractSoonCount,
    required this.contractRows,
    this.footerText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.folder_copy_outlined,
                color: AdminHomePage._kGreen, size: _r(22, scale)),
            SizedBox(width: _r(10, scale)),
            Text(
              'Driver Documents',
              style: TextStyle(
                fontSize: _r(20, scale),
                fontWeight: FontWeight.w900,
                color: AdminHomePage._kText,
              ),
            ),
          ],
        ),
        SizedBox(height: _r(14, scale)),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _DocSectionV2(
                  scale: scale,
                  title: 'Expired Documents',
                  counterLabel: 'expired soon',
                  counterValue: expiredSoonCount.toString(),
                  variant: _DocSectionVariant.expired,
                  rows: expiredRows,
                ),
              ),
              SizedBox(width: _r(16, scale)),
              const VerticalDivider(width: 1),
              SizedBox(width: _r(16, scale)),
              Expanded(
                child: _DocSectionV2(
                  scale: scale,
                  title: 'Missing Documents / Data',
                  counterLabel: 'total missing',
                  counterValue: missingCount.toString(),
                  variant: _DocSectionVariant.missing,
                  missingNames: missingNames,
                ),
              ),
              SizedBox(width: _r(16, scale)),
              const VerticalDivider(width: 1),
              SizedBox(width: _r(16, scale)),
              Expanded(
                child: _DocSectionV2(
                  scale: scale,
                  title: 'Driver Contracts',
                  counterLabel: 'last day soon',
                  counterValue: contractSoonCount.toString(),
                  variant: _DocSectionVariant.contract,
                  rows: contractRows,
                ),
              ),
            ],
          ),
        ),
        if (footerText != null) ...[
          SizedBox(height: _r(10, scale)),
          Text(
            footerText!,
            style: TextStyle(
              color: AdminHomePage._kMuted,
              fontSize: _r(12, scale),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}

// ===========================
// Sections + Tiles
// ===========================

enum _DocSectionVariant { expired, missing, contract }
enum _PillTone { orange, blue, yellow }

class _DocSectionV2 extends StatefulWidget {
  final double scale;
  final String title;
  final String counterLabel;
  final String counterValue;

  final _DocSectionVariant variant;

  final List<_DocRowUi> rows;
  final List<String> missingNames;

  const _DocSectionV2({
    super.key,
    required this.scale,
    required this.title,
    required this.counterLabel,
    required this.counterValue,
    required this.variant,
    this.rows = const [],
    this.missingNames = const [],
  });

  @override
  State<_DocSectionV2> createState() => _DocSectionV2State();
}

class _DocSectionV2State extends State<_DocSectionV2> {
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: _r(13, scale),
                ),
              ),
            ),
            Text(
              '${widget.counterLabel}:',
              style: TextStyle(
                fontSize: _r(10, scale),
                color: AdminHomePage._kMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: _r(6, scale)),
            Text(
              widget.counterValue,
              style: TextStyle(
                fontSize: _r(10, scale),
                fontWeight: FontWeight.w900,
                color: AdminHomePage._kOrange,
              ),
            ),
          ],
        ),
        SizedBox(height: _r(10, scale)),
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildBody() {
    final scale = widget.scale;

    // -------- Missing ----------
    if (widget.variant == _DocSectionVariant.missing) {
      if (widget.missingNames.isEmpty) {
        return Center(
          child: Text(
            'No items',
            style: TextStyle(
              color: AdminHomePage._kMuted,
              fontSize: _r(12, scale),
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      }

      return Scrollbar(
        controller: _controller,
        thumbVisibility: true,
        child: ListView.separated(
          controller: _controller,
          primary: false,
          itemCount: widget.missingNames.length,
          separatorBuilder: (_, __) => SizedBox(height: _r(12, scale)),
          itemBuilder: (_, i) => _MissingNameTile(
            scale: scale,
            name: widget.missingNames[i],
          ),
        ),
      );
    }

    // -------- Expired / Contract ----------
    if (widget.rows.isEmpty) {
      return Center(
        child: Text(
          'No items',
          style: TextStyle(
            color: AdminHomePage._kMuted,
            fontSize: _r(12, scale),
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Scrollbar(
      controller: _controller,
      thumbVisibility: true,
      child: ListView.separated(
        controller: _controller,
        primary: false,
        itemCount: widget.rows.length,
        separatorBuilder: (_, __) => SizedBox(height: _r(10, scale)),
        itemBuilder: (_, i) {
          final r = widget.rows[i];
          if (widget.variant == _DocSectionVariant.expired) {
            return _ExpiredDocTile(scale: scale, row: r);
          }
          return _ContractDocTile(scale: scale, row: r);
        },
      ),
    );
  }
}


class _MissingNameTile extends StatelessWidget {
  final double scale;
  final String name;
  const _MissingNameTile({required this.scale, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _r(14, scale),
        vertical: _r(12, scale),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3F5),
        borderRadius: BorderRadius.circular(_r(14, scale)),
      ),
      child: Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: _r(12, scale),
          color: AdminHomePage._kText,
        ),
      ),
    );
  }
}

class _ExpiredDocTile extends StatelessWidget {
  final double scale;
  final _DocRowUi row;
  const _ExpiredDocTile({required this.scale, required this.row});

  String _fmt(DateTime? dt) {
    if (dt == null) return '—';
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final yy = (dt.year % 100).toString().padLeft(2, '0');
    return '$dd.$mm.$yy';
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = row.isPlaceholder;

    return Container_toggle(
      scale: scale,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: _r(14, scale),
          vertical: _r(12, scale),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LINE 1: name + right date (never overflow)
            Row(
              children: [
                Expanded(
                  child: Text(
                    row.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: _r(12, scale),
                      color: AdminHomePage._kText,
                    ),
                  ),
                ),
                if (!isEmpty) ...[
                  SizedBox(width: _r(12, scale)),
                  Text(
                    row.rightPrefix.isEmpty ? 'expired by' : row.rightPrefix,
                    style: TextStyle(
                      fontSize: _r(10, scale),
                      fontWeight: FontWeight.w800,
                      color: AdminHomePage._kText,
                    ),
                  ),
                  SizedBox(width: _r(8, scale)),
                  Text(
                    _fmt(row.date),
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: _r(12, scale),
                      color: AdminHomePage._kOrange,
                    ),
                  ),
                ],
              ],
            ),

            // LINE 2: pills
            if (!isEmpty && row.pills.isNotEmpty) ...[
              SizedBox(height: _r(10, scale)),
              Wrap(
                spacing: _r(8, scale),
                runSpacing: _r(8, scale),
                children: row.pills
                    .map((p) => _Pill(scale: scale, text: p, tone: _PillTone.orange))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Small helper to keep the exact tile background from your design
class Container_toggle extends StatelessWidget {
  final double scale;
  final Widget child;
  const Container_toggle({required this.scale, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3F5),
        borderRadius: BorderRadius.circular(_r(14, scale)),
      ),
      child: child,
    );
  }
}


class _ContractDocTile extends StatelessWidget {
  final double scale;
  final _DocRowUi row;
  const _ContractDocTile({required this.scale, required this.row});

  String _fmt(DateTime? dt) {
    if (dt == null) return '—';
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final yy = (dt.year % 100).toString().padLeft(2, '0');
    return '$dd.$mm.$yy';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _r(14, scale),
        vertical: _r(12, scale),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3F5),
        borderRadius: BorderRadius.circular(_r(14, scale)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              row.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: _r(12, scale),
              ),
            ),
          ),
          SizedBox(width: _r(10, scale)),
          Expanded(
            flex: 2,
            child: row.contractPill.isEmpty
                ? const SizedBox.shrink()
                : Align(
                    alignment: Alignment.centerLeft,
                    child: _Pill(
                      scale: scale,
                      text: row.contractPill,
                      tone: row.contractTone,
                    ),
                  ),
          ),
          SizedBox(width: _r(10, scale)),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    row.rightPrefix.isEmpty ? 'last day' : row.rightPrefix,
                    style: TextStyle(
                      fontSize: _r(10, scale),
                      fontWeight: FontWeight.w800,
                      color: AdminHomePage._kText,
                    ),
                  ),
                  SizedBox(width: _r(8, scale)),
                  Text(
                    _fmt(row.date),
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: _r(12, scale),
                      color: AdminHomePage._kOrange,
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

class _Pill extends StatelessWidget {
  final double scale;
  final String text;
  final _PillTone tone;
  const _Pill({required this.scale, required this.text, required this.tone});

  @override
  Widget build(BuildContext context) {
    Color bg;
    switch (tone) {
      case _PillTone.blue:
        bg = const Color(0xFF3B28F6);
        break;
      case _PillTone.yellow:
        bg = const Color(0xFFD6A300);
        break;
      case _PillTone.orange:
      default:
        bg = AdminHomePage._kOrange;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _r(10, scale),
        vertical: _r(5, scale),
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(_r(999, scale)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: _r(10, scale),
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ===========================
// Small UI View Model
// ===========================

class _DocRowUi {
  final String name;

  /// Expired column: multiple pills
  final List<String> pills;

  /// Contract column: single pill
  final String contractPill;
  final _PillTone contractTone;

  /// Right side label + date
  final String rightPrefix;
  final DateTime? date;

  final bool isPlaceholder;

  const _DocRowUi({
    required this.name,
    this.pills = const [],
    this.contractPill = '',
    this.contractTone = _PillTone.orange,
    required this.rightPrefix,
    required this.date,
    this.isPlaceholder = false,
  });

}


// ===========================
// Helper Models
// ===========================

class _ExpiryField {
  final String key;
  final String label;
  const _ExpiryField({required this.key, required this.label});
}

class _RequiredField {
  final String key;
  final String label;
  const _RequiredField({required this.key, required this.label});
}

String _prettyDocType(String t) {
  switch (t) {
    case 'idCard':
      return 'ID Card';
    case 'drivingLicense':
      return 'Driving License';
    case 'residencePermit':
      return 'Residence Permit';
    case 'workPermit':
      return 'Work Permit';
    case 'contract':
      return 'Contract';
    default:
      return t;
  }
}


class _PillPopupDropdown extends StatelessWidget {
  final double scale;
  final List<String> items;
  final String value;
  final ValueChanged<String> onChanged;

  const _PillPopupDropdown({
    required this.scale,
    required this.items,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final pillRadius = _r(999, scale);
    final menuRadius = _r(14, scale);

    // Slightly wider menu like your design screenshot
    final menuWidth = _r(240, scale);
    final itemHeight = _r(42, scale);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: _r(12, scale)),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F9),
        borderRadius: BorderRadius.circular(pillRadius),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          popupMenuTheme: PopupMenuThemeData(
            color: const Color(0xFFF6F7F9),
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(menuRadius),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            textStyle: TextStyle(
              fontSize: _r(12, scale),
              fontWeight: FontWeight.w800,
              color: AdminHomePage._kText,
            ),
          ),
        ),
        child: PopupMenuButton<String>(
          tooltip: '',
          onSelected: onChanged,
          offset: Offset(0, _r(44, scale)),
          constraints: BoxConstraints.tightFor(width: menuWidth),
          itemBuilder: (_) {
            return items.map((label) {
              final selected = label == value;

              return PopupMenuItem<String>(
                value: label,
                height: itemHeight,
                padding: EdgeInsets.symmetric(
                  horizontal: _r(10, scale),
                  vertical: _r(6, scale),
                ),
                child: Container(
                  height: itemHeight - _r(10, scale),
                  padding: EdgeInsets.symmetric(horizontal: _r(10, scale)),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFFE5E7EB) : Colors.transparent,
                    borderRadius: BorderRadius.circular(_r(10, scale)),
                  ),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: _r(12, scale),
                      fontWeight: FontWeight.w800,
                      color: AdminHomePage._kText,
                    ),
                  ),
                ),
              );
            }).toList();
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: _r(170, scale)),
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: _r(12, scale),
                    fontWeight: FontWeight.w800,
                    color: AdminHomePage._kText,
                  ),
                ),
              ),
              SizedBox(width: _r(8, scale)),
              Icon(
                Icons.keyboard_arrow_down,
                size: _r(18, scale),
                color: const Color(0xFF6B7280),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ---------------------------
// Helpers
// ---------------------------

double _r(double v, double scale) => v * scale;

double _clampDouble(double v, double min, double max) =>
    math.max(min, math.min(max, v));
