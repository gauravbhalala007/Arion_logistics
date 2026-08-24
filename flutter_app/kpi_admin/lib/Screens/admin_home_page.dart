import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/admin_scope.dart';
import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';
import '../theme/app_colors.dart';
import '../widgets/co_button.dart';
import '../widgets/co_pressable.dart';
import '../utils/driver_activity.dart';
import '../models/fleet_vehicle_document.dart';
import '../services/fleet_vehicle_document_service.dart';
import '../widgets/operative_tasks_card.dart';
import 'admin_calendar_page.dart';
import 'drivers_hub_page.dart';

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
  String? get _uid {
    final scoped = AdminScope.maybeOf(context)?.adminUid;
    if (scoped != null && scoped.isNotEmpty) return scoped;
    return FirebaseAuth.instance.currentUser?.uid;
  }

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
    final t = AppLocalizations.of(context);
    // ✅ Load notification details (title/body) once for the popup header
    final notifDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(dspUid)
        .collection('notifications')
        .doc(notificationId)
        .get();

    final notifTitle =
        (notifDoc.data()?['title'] ?? t.t('admin_home_notification'))
            .toString();
    final notifBody = (notifDoc.data()?['body'] ?? '').toString();

    Future<Map<String, dynamic>> loadMissingDrivers() async {
      final stats = await loadActiveRuleConfirmationStats(
        dspUid: dspUid,
        notificationId: notificationId,
        fallbackDriverLabel: t.t('admin_home_driver_fallback'),
      );
      return {
        'missing': stats.pendingDriverNames,
        'total': stats.totalCount,
        'confirmed': stats.confirmedCount,
      };
    }

    final statsFuture = loadMissingDrivers();

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        final size = MediaQuery.of(ctx).size;
        final dialogMaxHeight = size.height * 0.88;
        final dialogWidth = size.width < 560 ? size.width - 24 : 520.0;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 20,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: dialogWidth,
              maxHeight: dialogMaxHeight,
            ),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notifTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (notifBody.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: dialogMaxHeight * 0.28,
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          notifBody,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF4B5563),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Text(
                        t.t('admin_home_not_confirmed_by'),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      FutureBuilder<Map<String, dynamic>>(
                        future: statsFuture,
                        builder: (_, statsSnap) {
                          if (statsSnap.connectionState ==
                                  ConnectionState.waiting &&
                              !statsSnap.hasData) {
                            return Text(
                              t.t('admin_home_missing_loading'),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFE9741A),
                              ),
                            );
                          }
                          if (statsSnap.hasError) {
                            return Text(
                              t.t('admin_home_missing_unknown'),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFE9741A),
                              ),
                            );
                          }
                          final total =
                              (statsSnap.data?['total'] as num?)?.toInt() ?? 0;
                          final confirmed =
                              (statsSnap.data?['confirmed'] as num?)?.toInt() ??
                              0;
                          final missingRaw = total - confirmed;
                          final missing = missingRaw < 0 ? 0 : missingRaw;
                          return Text(
                            t.tf('admin_home_missing_count', {
                              'count': '$missing',
                            }),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFE9741A),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 10),

                  Expanded(
                    child: FutureBuilder<Map<String, dynamic>>(
                      future: statsFuture,
                      builder: (ctx, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.codriverGreen,
                              ),
                            ),
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

                        final items =
                            (snap.data?['missing'] as List<dynamic>? ??
                                    const [])
                                .map((e) => e.toString())
                                .toList(growable: false);
                        if (items.isEmpty) {
                          return Center(
                            child: Text(
                              t.t('admin_home_all_drivers_confirmed'),
                              style: const TextStyle(color: Colors.black54),
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
                    child: CoButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      label: t.t('admin_home_close'),
                      variant: CoButtonVariant.quiet,
                    ),
                  ),
                ],
              ),
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

          // Cleaned-up home: notifications feed (60%) + calendar with
          // upcoming events below it (40%). The other old dashboard cards
          // stay in this file in case they return.
          // ignore: dead_code
          if (true) {
            if (isStacked) {
              // Mobile: notifications + quick calendar actions + upcoming
              // events. No month grid — the button leads to the calendar.
              // Mobile order: operative tasks → upcoming events →
              // notifications. Calendar + add-event live in the
              // upcoming card's header buttons.
              return SingleChildScrollView(
                padding: EdgeInsets.all(pad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_uid != null) ...[
                      SizedBox(
                        height: 360,
                        child: OperativeTasksCard(adminUid: _uid!),
                      ),
                      SizedBox(height: gap),
                    ],
                    const SizedBox(
                      height: 320,
                      child: CalendarUpcomingCard(),
                    ),
                    SizedBox(height: gap),
                    SizedBox(
                      height: 460,
                      child: _AlertCenterCard(scale: scale),
                    ),
                  ],
                ),
              );
            }
            // Desktop: operative tasks LEFT (replaces the month grid — the
            // full calendar lives on its own nav page), upcoming events
            // below, notifications RIGHT — 50/50.
            return Padding(
              padding: EdgeInsets.all(pad),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: _uid != null
                              ? OperativeTasksCard(adminUid: _uid!)
                              : const SizedBox.shrink(),
                        ),
                        SizedBox(height: gap),
                        const SizedBox(
                          height: 240,
                          child: CalendarUpcomingCard(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: gap),
                  Expanded(
                    child: _AlertCenterCard(scale: scale),
                  ),
                ],
              ),
            );
          }

          // ignore: dead_code
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
  final void Function(
    String notificationId,
    int confirmedCount,
    int targetCount,
  )
  onOpenMissing;

  const _DesktopLayout({
    required this.scale,
    required this.gap,
    required this.dspUid,
    required this.onOpenMissing,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 600,
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
                  child: Column(
                    children: [
                      // Unified alert feed — TÜV, Visum, Führerschein,
                      // Ausweis, Arbeitsvertrag in ONE place.
                      Expanded(
                        child: _AlertCenterCard(scale: scale),
                      ),
                      SizedBox(height: gap),
                      // Slim upcoming-events overview — full calendar
                      // lives on its own nav page.
                      const SizedBox(
                        height: 280,
                        child: CalendarUpcomingCard(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: gap),
          SizedBox(
            height: 320,
            child: _NotificationHistoryCard(
              scale: scale,
              dspUid: dspUid,
              onOpenMissing: onOpenMissing,
            ),
          ),
          SizedBox(height: gap),
          SizedBox(
            height: _r(280, scale),
            child: _DriverDocumentsCard(scale: scale),
          ),
        ],
      ),
    );
  }
}

class _StackedLayout extends StatelessWidget {
  final double scale;
  final double gap;
  final String? dspUid;
  final void Function(
    String notificationId,
    int confirmedCount,
    int targetCount,
  )
  onOpenMissing;

  const _StackedLayout({
    required this.scale,
    required this.gap,
    required this.dspUid,
    required this.onOpenMissing,
  });

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final veryNarrow = screenW < 700;

    // Keep notification/doc cards bounded; scorecard/fleet are adaptive on very narrow screens.
    final hScore = 350.0;
    final hFleet = 520.0;
    final hNotif = veryNarrow ? 620.0 : 560.0;
    final hDocs = veryNarrow ? 760.0 : 700.0;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Unified alert feed first — the most important info on top.
          SizedBox(
            height: 420,
            child: _AlertCenterCard(scale: scale),
          ),
          SizedBox(height: gap),
          // Slim upcoming-events overview — full calendar lives on
          // its own nav page.
          const SizedBox(
            height: 280,
            child: CalendarUpcomingCard(),
          ),
          SizedBox(height: gap),
          if (veryNarrow)
            _ScorecardCard(scale: scale)
          else
            SizedBox(
              height: hScore,
              child: _ScorecardCard(scale: scale),
            ),
          SizedBox(height: gap),
          if (veryNarrow)
            _FleetHubCard(scale: scale, adaptiveHeight: true)
          else
            SizedBox(
              height: hFleet,
              child: _FleetHubCard(scale: scale),
            ),
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
          SizedBox(
            height: hDocs,
            child: _DriverDocumentsCard(scale: scale),
          ),
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

  const _AdminCard({required this.child, required this.scale});

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
          ),
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

  String? get _uid {
    final scoped = AdminScope.maybeOf(context)?.adminUid;
    if (scoped != null && scoped.isNotEmpty) return scoped;
    return FirebaseAuth.instance.currentUser?.uid;
  }

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

  String _monthName(AppLocalizations t, int m) {
    const keys = [
      'month_short_jan',
      'month_short_feb',
      'month_short_mar',
      'month_short_apr',
      'month_short_may',
      'month_short_jun',
      'month_short_jul',
      'month_short_aug',
      'month_short_sep',
      'month_short_oct',
      'month_short_nov',
      'month_short_dec',
    ];
    return t.t(keys[(m.clamp(1, 12) - 1)]);
  }

  double _companyOverallFromReportDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> d,
  ) {
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
    DocumentReference<Map<String, dynamic>> reportRef,
  ) {
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
            final name = (data['driverName'] ?? data['fullName'] ?? '')
                .toString()
                .trim();
            if (tid.isNotEmpty && name.isNotEmpty) m[tid] = name;
          }
          return m;
        });
  }

  /// Transporter IDs of drivers who are still actively working for this
  /// DSP (`isDriverWorking` filters out deleted / archived / left etc.).
  /// Used to keep the scorecard leaderboard free of ex-employees who
  /// happen to still appear in historic Amazon scorecard uploads.
  Stream<Set<String>> _activeDriverTidsGlobal() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('drivers')
        .snapshots()
        .map((snap) {
          final out = <String>{};
          for (final d in snap.docs) {
            final data = d.data();
            if (!isDriverWorking(data)) continue;
            final tid = (data['transporterId'] ?? '').toString().trim();
            if (tid.isNotEmpty) out.add(tid);
          }
          return out;
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
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  _scoresForReportRefs(
    List<DocumentReference<Map<String, dynamic>>> reportRefs,
  ) async {
    final uid = _uid;
    if (uid == null || reportRefs.isEmpty) return [];

    const chunkSize = 10;
    final allDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];

    for (int i = 0; i < reportRefs.length; i += chunkSize) {
      final chunk = reportRefs.sublist(
        i,
        (i + chunkSize).clamp(0, reportRefs.length),
      );

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
    final t = AppLocalizations.of(context);

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
              dropdownItems: [t.t('admin_home_last_week')],
              dropdownValue: t.t('admin_home_last_week'),
              onDropdownChanged: (_) {},
              best: const [],
              worst: const [],
              footerText: t.t('admin_home_not_logged_in'),
            );
          }

          if (reportSnap.connectionState == ConnectionState.waiting) {
            return _ScorecardShellLive(
              scale: scale,
              companyScore: '—',
              dropdownItems: [t.t('admin_home_last_week')],
              dropdownValue: t.t('admin_home_last_week'),
              onDropdownChanged: (_) {},
              best: const [],
              worst: const [],
              footerText: t.t('admin_home_loading_reports'),
            );
          }

          if (reportSnap.hasError) {
            return _ScorecardShellLive(
              scale: scale,
              companyScore: '—',
              dropdownItems: [t.t('admin_home_last_week')],
              dropdownValue: t.t('admin_home_last_week'),
              onDropdownChanged: (_) {},
              best: const [],
              worst: const [],
              footerText: t.tf('admin_home_error_generic', {
                'error': '${reportSnap.error}',
              }),
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
              dropdownItems: [t.t('admin_home_last_week')],
              dropdownValue: t.t('admin_home_last_week'),
              onDropdownChanged: (_) {},
              best: const [],
              worst: const [],
              footerText: t.t('admin_home_no_reports_uploaded'),
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
              y: (monthsByYear[y]?.toList() ?? [])
                ..sort((a, b) => a.compareTo(b)),
          };

          // Dropdown entries
          final entries = <_DropdownEntry>[];
          entries.add(
            _DropdownEntry(
              key: 'W|__LAST__',
              label: t.t('admin_home_last_week'),
            ),
          );

          // Weeks
          for (final r in reportDocs) {
            final data = r.data();
            final w = _weekOfReport(data);
            final y = _yearOfReport(data);
            final label = (w != null && y != null)
                ? '${t.t('admin_home_week_short')} $w | $y'
                : t.t('admin_home_week_short');
            entries.add(_DropdownEntry(key: 'W|${r.id}', label: label));
          }

          // Months
          for (final y in sortedYears) {
            for (final m in (sortedMonthsByYear[y] ?? const <int>[])) {
              final mm = m.toString().padLeft(2, '0');
              entries.add(
                _DropdownEntry(
                  key: 'M|$y-$mm',
                  label:
                      '${t.t('admin_home_month_prefix')}: ${_monthName(t, m)} $y',
                ),
              );
            }
          }

          // Years
          for (final y in sortedYears) {
            entries.add(
              _DropdownEntry(
                key: 'Y|$y',
                label: '${t.t('admin_home_year_prefix')}: $y',
              ),
            );
          }

          // Ensure selection still valid
          if (!entries.any((e) => e.key == _selectedKey)) {
            _selectedKey = 'W|__LAST__';
          }

          final selected = entries.firstWhere((e) => e.key == _selectedKey);

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

          final companyScore = (companyCount > 0)
              ? (companySum / companyCount)
              : 0.0;
          final companyScoreStr = companyScore <= 0
              ? '—'
              : _fmtScore(companyScore);

          final isWeekView = _selectedKey.startsWith('W|');
          final weekRef = isWeekView && reportRefs.isNotEmpty
              ? reportRefs.first
              : null;

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

                  return StreamBuilder<Set<String>>(
                    stream: _activeDriverTidsGlobal(),
                    builder: (ctx, activeSnap) {
                      // Until the driver collection has loaded once we
                      // pass null so the leaderboard still renders
                      // (with the zero-package filter still active).
                      final activeTids = activeSnap.hasData
                          ? activeSnap.data
                          : null;

                  // WEEK: live stream
                  if (isWeekView && reportRefs.isNotEmpty) {
                    return StreamBuilder<
                      List<QueryDocumentSnapshot<Map<String, dynamic>>>
                    >(
                      stream: _scoresForReportRef(reportRefs.first),
                      builder: (ctx, scoreSnap) {
                        final docs =
                            scoreSnap.data ??
                            const <
                              QueryDocumentSnapshot<Map<String, dynamic>>
                            >[];

                        final bestWorst = _computeBestWorst(
                          docs,
                          nameMap,
                          scoreFromDoc: _scoreFromDoc,
                          fallbackName: t.t('admin_home_name_fallback'),
                          activeTids: activeTids,
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
                          footerText:
                              scoreSnap.connectionState ==
                                  ConnectionState.waiting
                              ? t.t('admin_home_loading_scores')
                              : null,
                        );
                      },
                    );
                  }

                  // MONTH/YEAR: Future aggregation (avg per driver)
                  return FutureBuilder<
                    List<QueryDocumentSnapshot<Map<String, dynamic>>>
                  >(
                    future: _scoresForReportRefs(reportRefs),
                    builder: (ctx, scoreSnap) {
                      final docs =
                          scoreSnap.data ??
                          const <QueryDocumentSnapshot<Map<String, dynamic>>>[];

                      final bestWorst = _computeBestWorst(
                        docs,
                        nameMap,
                        scoreFromDoc: _scoreFromDoc,
                        aggregateAveragePerDriver: true,
                        fallbackName: t.t('admin_home_name_fallback'),
                        activeTids: activeTids,
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
                        footerText:
                            scoreSnap.connectionState == ConnectionState.waiting
                            ? t.t('admin_home_loading_scores')
                            : null,
                      );
                    },
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

/// Read the delivered-packages count off a scorecard row. Different
/// scorecard formats use different field casings (`Delivered`,
/// `DELIVERED`, `delivered`) so we probe all of them and fall back to
/// 0 — which then causes the driver to be excluded from the leaderboard.
double _packagesFromDoc(Map<String, dynamic> data) {
  final kpisRaw = data['kpis'];
  final kpis = kpisRaw is Map
      ? Map<String, dynamic>.from(kpisRaw as Map)
      : <String, dynamic>{};
  final v = kpis['Delivered'] ?? kpis['DELIVERED'] ?? kpis['delivered'];
  if (v == null) return 0.0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString().trim().replaceAll(',', '.')) ?? 0.0;
}

// Worst Defender ranking rule: lowest comp.FinalScore = worst.
// `activeTids`: only drivers in this set are considered. Pass null to
//               disable the activity filter (legacy behaviour).
// Drivers with zero delivered packages are always excluded — an empty
// week means the person didn't actually work and shouldn't rank either
// at the top or the bottom of the scorecard.
_BestWorstResult _computeBestWorst(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  Map<String, String> nameMap, {
  required double Function(Map<String, dynamic>) scoreFromDoc,
  bool aggregateAveragePerDriver = false,
  String fallbackName = '—',
  Set<String>? activeTids,
}) {
  bool isEligible(Map<String, dynamic> data, String tid) {
    if (_packagesFromDoc(data) <= 0) return false;
    if (activeTids != null && tid.isNotEmpty && !activeTids.contains(tid)) {
      return false;
    }
    return true;
  }

  if (!aggregateAveragePerDriver) {
    final entries = <_ScoreEntry>[];

    for (final d in docs) {
      final data = d.data();
      final tid = (data['transporterId'] ?? '').toString().trim();
      if (!isEligible(data, tid)) continue;

      final score = scoreFromDoc(data);

      final name = (tid.isNotEmpty && (nameMap[tid] ?? '').trim().isNotEmpty)
          ? nameMap[tid]!.trim()
          : (tid.isNotEmpty ? tid : fallbackName);

      entries.add(_ScoreEntry(transporterId: tid, name: name, score: score));
    }

    final best = List<_ScoreEntry>.from(entries)
      ..sort((a, b) => b.score.compareTo(a.score));
    final worst = List<_ScoreEntry>.from(entries)
      ..sort((a, b) => a.score.compareTo(b.score)); // lowest = worst

    return _BestWorstResult(
      best: best.take(5).toList(),
      worst: worst.take(5).toList(),
    );
  }

  // Month/Year: average score per transporterId. Only count weeks where
  // the driver actually delivered packages — otherwise an inactive week
  // would drag the average toward 0 unfairly.
  final sum = <String, double>{};
  final count = <String, int>{};

  for (final d in docs) {
    final data = d.data();
    final tid = (data['transporterId'] ?? '').toString().trim();
    if (tid.isEmpty) continue;
    if (!isEligible(data, tid)) continue;

    final score = scoreFromDoc(data);
    sum[tid] = (sum[tid] ?? 0) + score;
    count[tid] = (count[tid] ?? 0) + 1;
  }

  final entries = <_ScoreEntry>[];
  sum.forEach((tid, s) {
    final c = count[tid] ?? 0;
    if (c <= 0) return;
    final avg = s / c;

    final name = (nameMap[tid] ?? '').trim().isNotEmpty
        ? nameMap[tid]!.trim()
        : tid;

    entries.add(_ScoreEntry(transporterId: tid, name: name, score: avg));
  });

  final best = List<_ScoreEntry>.from(entries)
    ..sort((a, b) => b.score.compareTo(a.score));
  final worst = List<_ScoreEntry>.from(entries)
    ..sort((a, b) => a.score.compareTo(b.score)); // lowest = worst

  return _BestWorstResult(
    best: best.take(5).toList(),
    worst: worst.take(5).toList(),
  );
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
    final t = AppLocalizations.of(context);
    final compactHeader = MediaQuery.of(context).size.width < 700;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (compactHeader)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    color: AdminHomePage._kGreen,
                    size: _r(22, scale),
                  ),
                  SizedBox(width: _r(10, scale)),
                  Text(
                    t.t('admin_home_scorecard'),
                    style: TextStyle(
                      fontSize: _r(20, scale),
                      fontWeight: FontWeight.w900,
                      color: AdminHomePage._kText,
                    ),
                  ),
                ],
              ),
              SizedBox(height: _r(10, scale)),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: _r(8, scale),
                runSpacing: _r(8, scale),
                children: [
                  Text(
                    t.t('admin_home_company_score'),
                    style: TextStyle(
                      fontSize: _r(12, scale),
                      fontWeight: FontWeight.w900,
                      color: AdminHomePage._kText,
                    ),
                  ),
                  Text(
                    companyScore,
                    style: TextStyle(
                      fontSize: _r(16, scale),
                      fontWeight: FontWeight.w900,
                      color: AdminHomePage._kGreen,
                    ),
                  ),
                  Text(
                    t.t('admin_home_of'),
                    style: TextStyle(
                      color: AdminHomePage._kMuted,
                      fontSize: _r(12, scale),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  _PillPopupDropdown(
                    scale: scale,
                    items: dropdownItems,
                    value: dropdownValue,
                    onChanged: onDropdownChanged,
                  ),
                ],
              ),
            ],
          )
        else
          Row(
            children: [
              Icon(
                Icons.assignment_outlined,
                color: AdminHomePage._kGreen,
                size: _r(22, scale),
              ),
              SizedBox(width: _r(10, scale)),
              Text(
                t.t('admin_home_scorecard'),
                style: TextStyle(
                  fontSize: _r(20, scale),
                  fontWeight: FontWeight.w900,
                  color: AdminHomePage._kText,
                ),
              ),
              const Spacer(),
              Text(
                t.t('admin_home_company_score'),
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
                t.t('admin_home_of'),
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
                title: t.t('admin_home_best_driver'),
                positive: true,
                items: best,
              ),
            ),
            SizedBox(width: _r(16, scale)),
            Expanded(
              child: _MiniRankingLive(
                scale: scale,
                title: t.t('admin_home_worst_defender'),
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
              color: isAlt ? const Color(0xFFF9FAFB) : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(_r(12, scale)),
              border: Border.all(color: const Color(0xFFE5E7EB)),
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
  final void Function(
    String notificationId,
    int confirmedCount,
    int targetCount,
  )
  onOpenMissing;

  const _NotificationHistoryCard({
    required this.scale,
    required this.dspUid,
    required this.onOpenMissing,
  });

  @override
  State<_NotificationHistoryCard> createState() =>
      _NotificationHistoryCardState();
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
    final t = AppLocalizations.of(context);

    return _AdminCard(
      scale: scale,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.gavel_rounded,
                color: AdminHomePage._kGreen,
                size: _r(22, scale),
              ),
              SizedBox(width: _r(10, scale)),
              Text(
                'Company Rules',
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
                ? Center(child: Text(t.t('admin_home_not_logged_in')))
                : StreamBuilder<int>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(dspUid)
                        .collection('drivers')
                        .snapshots()
                        .map(
                          (s) => s.docs
                              .where((d) => isDriverWorking(d.data()))
                              .length,
                        ),
                    builder: (ctx, driverSnap) {
                      final currentDriverCount = driverSnap.hasData
                          ? (driverSnap.data ?? 0)
                          : -1;
                      return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(dspUid)
                            .collection('notifications')
                            .orderBy('createdAt', descending: true)
                            .snapshots(),
                        builder: (ctx, snap) {
                          final Widget body;
                          if (snap.connectionState == ConnectionState.waiting) {
                            body = const Center(
                              key: ValueKey('notif-loading'),
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.codriverGreen,
                                ),
                              ),
                            );
                            return CoStateSwitcher(child: body);
                          }
                          if (snap.hasError) {
                            body = Center(
                              key: const ValueKey('notif-error'),
                              child: Text(
                                t.tf('admin_home_error_generic', {
                                  'error': '${snap.error}',
                                }),
                              ),
                            );
                            return CoStateSwitcher(child: body);
                          }

                          final docs = snap.data?.docs ?? [];
                          if (docs.isEmpty) {
                            return CoStateSwitcher(
                              child: Center(
                                key: const ValueKey('notif-empty'),
                                child: Text(
                                  t.t('admin_home_no_notifications_yet'),
                                  style:
                                      const TextStyle(color: Colors.black54),
                                ),
                              ),
                            );
                          }

                          return CoStateSwitcher(
                            child: Scrollbar(
                            key: const ValueKey('notif-list'),
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
                                    (data['confirmedCount'] as num?)?.toInt() ??
                                    0;
                                final targetCount =
                                    (data['targetCount'] as num?)?.toInt() ?? 0;

                                final ts = data['createdAt'];
                                final dt = ts is Timestamp ? ts.toDate() : null;

                                final type = (data['type'] ?? 'rule')
                                    .toString();

                                return CoPressable(
                                  borderRadius: BorderRadius.circular(
                                    _r(16, scale),
                                  ),
                                  onTap: () => onOpenMissing(
                                    d.id,
                                    confirmedCount,
                                    targetCount,
                                  ),
                                  child: InkWell(
                                  borderRadius: BorderRadius.circular(
                                    _r(16, scale),
                                  ),
                                  onTap: () => onOpenMissing(
                                    d.id,
                                    confirmedCount,
                                    targetCount,
                                  ),
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
                                    currentDriverCount: currentDriverCount,
                                  ),
                                  ),
                                );
                              },
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
  final int currentDriverCount;

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
    required this.currentDriverCount,
  });

  String _fmtDate(BuildContext context, DateTime? dt) {
    if (dt == null) return '';
    final t = AppLocalizations.of(context);
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final yy = dt.year.toString();
    final hh = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    final suffix = t.t('admin_home_time_suffix').trim();
    return suffix.isEmpty
        ? '$dd.$mm.$yy | $hh:$min'
        : '$dd.$mm.$yy | $hh:$min $suffix';
  }

  String _typeLabel(BuildContext context, String t) {
    final loc = AppLocalizations.of(context);
    switch (t) {
      case 'message':
        return loc.t('admin_home_notification_type_message');
      case 'academy':
        return loc.t('admin_home_notification_type_academy');
      case 'rideAlong':
        return loc.t('admin_home_notification_type_ride_along');
      case 'rule':
      default:
        return loc.t('admin_home_notification_type_rule');
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

  Future<void> _editEverywhere(BuildContext context) async {
    final t = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);
    final titleCtrl = TextEditingController(text: title);
    final bodyCtrl = TextEditingController(text: body);

    try {
      final payload = await showDialog<Map<String, String>>(
        context: context,
        barrierDismissible: true,
        builder: (ctx) {
          return AlertDialog(
            title: Text(t.t('admin_home_edit_rule')),
            content: SizedBox(
              width: 520,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(
                      labelText: t.t('admin_home_title'),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: bodyCtrl,
                    minLines: 5,
                    maxLines: 12,
                    decoration: InputDecoration(
                      labelText: t.t('admin_home_body'),
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              CoButton(
                onPressed: () => Navigator.of(ctx).pop(),
                label: t.t('admin_home_cancel'),
                variant: CoButtonVariant.quiet,
              ),
              CoButton(
                onPressed: () {
                  Navigator.of(ctx).pop({
                    'title': titleCtrl.text.trim(),
                    'body': bodyCtrl.text.trim(),
                  });
                },
                label: t.t('admin_home_save'),
              ),
            ],
          );
        },
      );

      if (payload == null) return;
      final newTitle = (payload['title'] ?? '').trim();
      final newBody = (payload['body'] ?? '').trim();
      if (newTitle.isEmpty && newBody.isEmpty) {
        messenger?.showSnackBar(
          SnackBar(content: Text(t.t('admin_home_title_or_body_required'))),
        );
        return;
      }

      final db = FirebaseFirestore.instance;
      final dspRef = db.collection('users').doc(dspUid);
      final adminNotifRef = dspRef
          .collection('notifications')
          .doc(notificationId);

      final adminSnap = await adminNotifRef.get();
      if (!adminSnap.exists) {
        throw Exception(t.t('admin_home_notification_not_found'));
      }

      final adminData = adminSnap.data() ?? <String, dynamic>{};
      final notifType = (adminData['type'] ?? type).toString();
      final createdAt = adminData['createdAt'];
      final now = FieldValue.serverTimestamp();
      final sourceLang = Localizations.localeOf(context).languageCode
          .toLowerCase();

      final driversSnap = await dspRef.collection('drivers').get();
      final drivers = driversSnap.docs
          .where((d) => isDriverWorking(d.data()))
          .toList(growable: false);

      await adminNotifRef.set({
        'title': newTitle,
        'body': newBody,
        'sourceLang': sourceLang,
        'translations': <String, dynamic>{},
        'targetCount': drivers.length,
        'confirmedCount': 0,
        'requiresConfirmation': true,
        'updatedAt': now,
        'editedAt': now,
      }, SetOptions(merge: true));

      const chunkSize = 400;
      for (int i = 0; i < drivers.length; i += chunkSize) {
        final end = (i + chunkSize > drivers.length)
            ? drivers.length
            : (i + chunkSize);
        final batch = db.batch();

        for (final d in drivers.sublist(i, end)) {
          final driverNotifRef = d.reference
              .collection('notifications')
              .doc(notificationId);

          batch.set(driverNotifRef, {
            'notificationId': notificationId,
            'type': notifType,
            'title': newTitle,
            'body': newBody,
            'sourceLang': sourceLang,
            'translations': <String, dynamic>{},
            'status': 'unread',
            'readAt': null,
            'confirmedAt': null,
            'requiresConfirmation': true,
            'createdAt': createdAt ?? now,
            'updatedAt': now,
            'editedAt': now,
          }, SetOptions(merge: true));
        }

        await batch.commit();
      }

      messenger?.showSnackBar(
        SnackBar(
          content: Text(
            t.tf('admin_home_rule_updated_for_drivers', {
              'count': '${drivers.length}',
            }),
          ),
        ),
      );
    } catch (e) {
      messenger?.showSnackBar(
        SnackBar(
          content: Text(t.tf('admin_home_edit_failed', {'error': '$e'})),
        ),
      );
    } finally {
      titleCtrl.dispose();
      bodyCtrl.dispose();
    }
  }

  Future<void> _deleteEverywhere(BuildContext context) async {
    final t = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          title: Text(t.t('admin_home_delete_notification_question')),
          content: Text(t.t('admin_home_delete_notification_body')),
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
        );
      },
    );

    if (ok != true) return;

    try {
      final callable = FirebaseFunctions.instance.httpsCallable(
        'deleteNotificationEverywhere',
      );
      await callable.call({'dspUid': dspUid, 'notificationId': notificationId});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.t('admin_home_notification_deleted'))),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.tf('admin_home_delete_failed', {'error': '$e'})),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final total = targetCount > 0 ? targetCount : currentDriverCount;
    final safeTotal = total <= 0 ? 0 : total;
    final safeConfirmed = safeTotal <= 0
        ? 0
        : (confirmedCount > safeTotal ? safeTotal : confirmedCount);
    final fallbackRatio = '$safeConfirmed / $safeTotal';
    final compact = MediaQuery.of(context).size.width < 700;

    final menuButton = Theme(
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
            tooltip: t.t('admin_home_options'),
            splashRadius: _r(18, scale),
            offset: const Offset(0, 10),
            onSelected: (v) {
              if (v == 'edit') _editEverywhere(context);
              if (v == 'delete') _deleteEverywhere(context);
            },
            itemBuilder: (_) => [
              if (type == 'rule')
                PopupMenuItem<String>(
                  value: 'edit',
                  padding: EdgeInsets.symmetric(
                    horizontal: _r(12, scale),
                    vertical: _r(10, scale),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: _r(18, scale),
                        color: AdminHomePage._kGreen,
                      ),
                      SizedBox(width: _r(10, scale)),
                      Text(
                        t.t('admin_home_edit_rule'),
                        style: TextStyle(
                          color: AdminHomePage._kGreen,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
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
                    Text(
                      t.t('admin_home_delete'),
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
    );

    final ratioWidget = type == 'rule'
        ? FutureBuilder<ActiveRuleConfirmationStats>(
            future: loadActiveRuleConfirmationStats(
              dspUid: dspUid,
              notificationId: notificationId,
              fallbackDriverLabel: t.t('admin_home_driver_fallback'),
            ),
            builder: (context, snapshot) {
              final stats = snapshot.data;
              final ratio = stats == null
                  ? fallbackRatio
                  : '${stats.confirmedCount} / ${stats.totalCount}';
              return Text(
                ratio,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AdminHomePage._kGreen,
                  fontSize: _r(12, scale),
                ),
              );
            },
          )
        : Text(
            fallbackRatio,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: AdminHomePage._kGreen,
              fontSize: _r(12, scale),
            ),
          );

    return Container(
      padding: EdgeInsets.all(_r(14, scale)),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(_r(16, scale)),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tileCompact = compact || constraints.maxWidth < 560;

          final leading = Container(
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
          );

          final textContent = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_typeLabel(context, type)} | ${title.isEmpty ? t.t('admin_home_title_upper') : title}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: _r(12, scale),
                ),
              ),
              SizedBox(height: _r(4, scale)),
              if (_fmtDate(context, dateTime).isNotEmpty)
                Text(
                  _fmtDate(context, dateTime),
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
          );

          final meta = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t.t('admin_home_confirmed_by'),
                style: TextStyle(
                  fontSize: _r(10, scale),
                  color: AdminHomePage._kMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: _r(6, scale)),
              ratioWidget,
              SizedBox(width: _r(10, scale)),
              menuButton,
            ],
          );

          if (tileCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    leading,
                    SizedBox(width: _r(12, scale)),
                    Expanded(child: textContent),
                  ],
                ),
                SizedBox(height: _r(8, scale)),
                Align(alignment: Alignment.centerRight, child: meta),
              ],
            );
          }

          return Row(
            children: [
              leading,
              SizedBox(width: _r(12, scale)),
              Expanded(child: textContent),
              SizedBox(width: _r(10, scale)),
              meta,
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------
// FLEET HUB
// ---------------------------

class _FleetHubCard extends StatefulWidget {
  final double scale;
  final bool adaptiveHeight;
  const _FleetHubCard({required this.scale, this.adaptiveHeight = false});

  @override
  State<_FleetHubCard> createState() => _FleetHubCardState();
}

class _FleetHubCardState extends State<_FleetHubCard> {
  static const List<String> _requiredDocumentTypes = <String>[
    'tuv',
    'insurance',
    'service',
    'rc',
  ];

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _vehicleSubscription;
  final Map<String, StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>
  _documentSubscriptions =
      <String, StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>{};
  final Map<String, _FleetDashboardVehicle> _vehicles =
      <String, _FleetDashboardVehicle>{};
  final Map<String, List<_FleetDashboardDocument>> _documentsByVehicleId =
      <String, List<_FleetDashboardDocument>>{};
  final Set<String> _readyDocumentVehicleIds = <String>{};

  bool _loading = true;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    _initializeFleetHub();
  }

  @override
  void dispose() {
    _vehicleSubscription?.cancel();
    for (final subscription in _documentSubscriptions.values) {
      subscription.cancel();
    }
    super.dispose();
  }

  Future<void> _initializeFleetHub() async {
    final uid = AdminScope.adminUidOf(context);
    if (uid == null) {
      if (!mounted) return;
      setState(() => _loading = false);
      return;
    }

    try {
      final userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final userData = userSnap.data() ?? const <String, dynamic>{};
      final rawScope = (userData['dspUid'] ?? '').toString().trim();
      final fleetScope = rawScope.isEmpty ? uid : rawScope;
      _listenToVehicles(fleetScope);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = error;
      });
    }
  }

  void _listenToVehicles(String fleetScope) {
    _vehicleSubscription?.cancel();
    for (final subscription in _documentSubscriptions.values) {
      subscription.cancel();
    }
    _documentSubscriptions.clear();
    _vehicles.clear();
    _documentsByVehicleId.clear();
    _readyDocumentVehicleIds.clear();

    _vehicleSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(fleetScope)
        .collection('vehicles')
        .snapshots()
        .listen(
          (snapshot) {
            final nextVehicles = <String, _FleetDashboardVehicle>{
              for (final doc in snapshot.docs)
                doc.id: _FleetDashboardVehicle.fromDoc(doc),
            };

            final removedVehicleIds = _vehicles.keys
                .where((vehicleId) => !nextVehicles.containsKey(vehicleId))
                .toList(growable: false);
            for (final vehicleId in removedVehicleIds) {
              _documentSubscriptions.remove(vehicleId)?.cancel();
              _documentsByVehicleId.remove(vehicleId);
              _readyDocumentVehicleIds.remove(vehicleId);
            }

            _vehicles
              ..clear()
              ..addAll(nextVehicles);

            for (final entry in nextVehicles.entries) {
              if (_documentSubscriptions.containsKey(entry.key)) continue;
              _documentSubscriptions[entry.key] = FirebaseFirestore.instance
                  .collection('users')
                  .doc(fleetScope)
                  .collection('vehicles')
                  .doc(entry.key)
                  .collection('documents')
                  .snapshots()
                  .listen(
                    (documentsSnapshot) {
                      _documentsByVehicleId[entry.key] = documentsSnapshot.docs
                          .map(_FleetDashboardDocument.fromDoc)
                          .toList(growable: false);
                      _readyDocumentVehicleIds.add(entry.key);
                      if (!mounted) return;
                      setState(() {
                        _loading =
                            _readyDocumentVehicleIds.length < _vehicles.length;
                      });
                    },
                    onError: (error) {
                      if (!mounted) return;
                      setState(() {
                        _readyDocumentVehicleIds.add(entry.key);
                        _loading =
                            _readyDocumentVehicleIds.length < _vehicles.length;
                        _loadError = error;
                      });
                    },
                  );
            }

            if (!mounted) return;
            setState(() {
              _loading = nextVehicles.isNotEmpty &&
                  _readyDocumentVehicleIds.length < nextVehicles.length;
              _loadError = null;
            });
          },
          onError: (error) {
            if (!mounted) return;
            setState(() {
              _loading = false;
              _loadError = error;
            });
          },
        );
  }

  int _compareDocumentRecency(
    _FleetDashboardDocument a,
    _FleetDashboardDocument b,
  ) {
    final aTime = a.uploadedAt;
    final bTime = b.uploadedAt;
    if (aTime != null && bTime != null) {
      return aTime.compareTo(bTime);
    }
    if (aTime != null) return 1;
    if (bTime != null) return -1;
    return a.id.compareTo(b.id);
  }

  List<_FleetComplianceItem> _buildComplianceItems() {
    final items = <_FleetComplianceItem>[];

    for (final vehicle in _vehicles.values) {
      final latestByType = <String, _FleetDashboardDocument>{};
      final documents =
          _documentsByVehicleId[vehicle.id] ?? const <_FleetDashboardDocument>[];

      for (final document in documents) {
        final type = document.type.trim().toLowerCase();
        if (!_requiredDocumentTypes.contains(type)) continue;
        final current = latestByType[type];
        if (current == null ||
            _compareDocumentRecency(document, current) > 0) {
          latestByType[type] = document;
        }
      }

      for (final type in _requiredDocumentTypes) {
        items.add(
          _FleetComplianceItem.fromVehicleDocument(
            vehicleNumber: vehicle.vehicleNumber,
            type: type,
            document: latestByType[type],
          ),
        );
      }
    }

    items.sort((a, b) {
      final priorityComparison = a.priority.compareTo(b.priority);
      if (priorityComparison != 0) return priorityComparison;

      final aDate = a.sortDate;
      final bDate = b.sortDate;
      if (aDate != null && bDate != null) {
        final dateComparison = aDate.compareTo(bDate);
        if (dateComparison != 0) return dateComparison;
      } else if (aDate != null) {
        return -1;
      } else if (bDate != null) {
        return 1;
      }

      final vehicleComparison = a.vehicleNumber.compareTo(b.vehicleNumber);
      if (vehicleComparison != 0) return vehicleComparison;
      return a.type.compareTo(b.type);
    });

    return items.take(6).toList(growable: false);
  }

  String _expiryText(BuildContext context, _FleetComplianceItem item) {
    final t = AppLocalizations.of(context);
    if (item.state == _FleetComplianceState.missing) {
      return t.t('fleet_status_vehicle_details_missing');
    }
    if (item.state == _FleetComplianceState.noExpiry) {
      return t.t('fleet_status_vehicle_details_not_set');
    }
    final expiryDate = item.expiryDate;
    if (expiryDate == null) {
      return t.t('fleet_status_vehicle_details_not_set');
    }
    return MaterialLocalizations.of(context).formatShortDate(expiryDate);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final scale = widget.scale;
    final total = _vehicles.length;
    final active = _vehicles.values
        .where((vehicle) => vehicle.status.trim().toLowerCase() == 'active')
        .length;
    final inactive = total - active;
    final items = _buildComplianceItems();

    Widget content = Container(
      width: double.infinity,
      padding: EdgeInsets.all(_r(12, scale)),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(_r(18, scale)),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: CoStateSwitcher(
        child: _loading
            ? Center(
                key: const ValueKey('fleet-loading'),
                child: Text(
                  t.t('admin_home_loading_documents'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: _r(14, scale),
                    fontWeight: FontWeight.w700,
                    color: AdminHomePage._kMuted,
                  ),
                ),
              )
            : _loadError != null || items.isEmpty
                ? Center(
                    key: const ValueKey('fleet-empty'),
                    child: Text(
                      t.t('admin_home_no_items'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: _r(14, scale),
                        fontWeight: FontWeight.w700,
                        color: AdminHomePage._kMuted,
                      ),
                    ),
                  )
                : KeyedSubtree(
                    key: const ValueKey('fleet-list'),
                    child: _FleetComplianceList(
                      scale: scale,
                      adaptiveHeight: widget.adaptiveHeight,
                      items: items,
                      expiryTextBuilder: (item) => _expiryText(context, item),
                    ),
                  ),
      ),
    );

    return _AdminCard(
      scale: scale,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.directions_car_filled_outlined,
                      color: AdminHomePage._kGreen,
                      size: _r(22, scale),
                    ),
                    SizedBox(width: _r(10, scale)),
                    Flexible(
                      child: Text(
                        t.t('admin_home_fleet_hub'),
                        style: TextStyle(
                          fontSize: _r(20, scale),
                          fontWeight: FontWeight.w900,
                          color: AdminHomePage._kText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: _r(12, scale)),
              _FleetStats(
                scale: scale,
                total: total,
                active: active,
                inactive: inactive,
              ),
            ],
          ),
          SizedBox(height: _r(16, scale)),
          Text(
            t.t('admin_home_service'),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: _r(13, scale),
              color: AdminHomePage._kText,
            ),
          ),
          SizedBox(height: _r(10, scale)),
          if (widget.adaptiveHeight) content else Expanded(child: content),
        ],
      ),
    );
  }
}

class _FleetStats extends StatelessWidget {
  final double scale;
  final int total;
  final int active;
  final int inactive;

  const _FleetStats({
    required this.scale,
    required this.total,
    required this.active,
    required this.inactive,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Wrap(
      spacing: _r(14, scale),
      runSpacing: _r(6, scale),
      alignment: WrapAlignment.end,
      children: [
        _MiniStat(
          scale: scale,
          label: t.t('admin_home_total'),
          value: '$total',
          color: AdminHomePage._kText,
        ),
        _MiniStat(
          scale: scale,
          label: t.t('admin_home_active'),
          value: '$active',
          color: AdminHomePage._kGreen,
        ),
        _MiniStat(
          scale: scale,
          label: t.t('admin_home_inactive'),
          value: '$inactive',
          color: AdminHomePage._kOrange,
        ),
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
      mainAxisSize: MainAxisSize.min,
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

class _FleetComplianceList extends StatelessWidget {
  final double scale;
  final bool adaptiveHeight;
  final List<_FleetComplianceItem> items;
  final String Function(_FleetComplianceItem item) expiryTextBuilder;

  const _FleetComplianceList({
    required this.scale,
    required this.adaptiveHeight,
    required this.items,
    required this.expiryTextBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (adaptiveHeight) {
      return Column(
        children: items
            .map(
              (item) => Padding(
                padding: EdgeInsets.only(bottom: _r(10, scale)),
                child: _FleetComplianceTile(
                  scale: scale,
                  item: item,
                  expiryText: expiryTextBuilder(item),
                ),
              ),
            )
            .toList(growable: false),
      );
    }

    return ListView.separated(
      primary: false,
      itemCount: items.length,
      separatorBuilder: (_, __) => SizedBox(height: _r(10, scale)),
      itemBuilder: (_, index) => _FleetComplianceTile(
        scale: scale,
        item: items[index],
        expiryText: expiryTextBuilder(items[index]),
      ),
    );
  }
}

class _FleetComplianceTile extends StatelessWidget {
  final double scale;
  final _FleetComplianceItem item;
  final String expiryText;

  const _FleetComplianceTile({
    required this.scale,
    required this.item,
    required this.expiryText,
  });

  @override
  Widget build(BuildContext context) {
    final expiryColor = item.state == _FleetComplianceState.expired
        ? const Color(0xFFDC2626)
        : item.state == _FleetComplianceState.upcoming
        ? AdminHomePage._kOrange
        : AdminHomePage._kMuted;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _r(12, scale),
        vertical: _r(10, scale),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_r(12, scale)),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.vehicleNumber,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: _r(12, scale),
                color: AdminHomePage._kText,
              ),
            ),
          ),
          _FleetDocumentTypeTag(scale: scale, type: item.type),
          SizedBox(width: _r(10, scale)),
          Text(
            expiryText,
            style: TextStyle(
              fontSize: _r(12, scale),
              fontWeight: FontWeight.w900,
              color: expiryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _FleetDocumentTypeTag extends StatelessWidget {
  final double scale;
  final String type;

  const _FleetDocumentTypeTag({required this.scale, required this.type});

  @override
  Widget build(BuildContext context) {
    final color = type == 'service'
        ? AdminHomePage._kOrange
        : type == 'insurance'
        ? const Color(0xFF2563EB)
        : type == 'rc'
        ? const Color(0xFF7C3AED)
        : AdminHomePage._kGreen;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _r(10, scale),
        vertical: _r(4, scale),
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(_r(999, scale)),
        border: Border.all(color: color.withOpacity(0.30)),
      ),
      child: Text(
        _fleetDocumentTypeLabel(context, type),
        style: TextStyle(
          fontSize: _r(10, scale),
          fontWeight: FontWeight.w900,
          color: color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _FleetDashboardVehicle {
  const _FleetDashboardVehicle({
    required this.id,
    required this.vehicleNumber,
    required this.status,
  });

  final String id;
  final String vehicleNumber;
  final String status;

  factory _FleetDashboardVehicle.fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return _FleetDashboardVehicle(
      id: doc.id,
      vehicleNumber: (data['vehicleNumber'] ?? doc.id).toString(),
      status: (data['status'] ?? 'active').toString(),
    );
  }
}

class _FleetDashboardDocument {
  const _FleetDashboardDocument({
    required this.id,
    required this.type,
    required this.expiryDate,
    required this.uploadedAt,
  });

  final String id;
  final String type;
  final DateTime? expiryDate;
  final DateTime? uploadedAt;

  factory _FleetDashboardDocument.fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return _FleetDashboardDocument(
      id: doc.id,
      type: (data['type'] ?? '').toString(),
      expiryDate: _fleetDashboardDateValue(data['expiryDate']),
      uploadedAt: _fleetDashboardDateValue(data['uploadedAt']),
    );
  }
}

DateTime? _fleetDashboardDateValue(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) {
    final parsed = DateTime.tryParse(value.trim());
    return parsed == null
        ? null
        : DateTime(parsed.year, parsed.month, parsed.day);
  }
  return null;
}

enum _FleetComplianceState { missing, expired, noExpiry, upcoming }

class _FleetComplianceItem {
  const _FleetComplianceItem({
    required this.vehicleNumber,
    required this.type,
    required this.state,
    required this.expiryDate,
  });

  final String vehicleNumber;
  final String type;
  final _FleetComplianceState state;
  final DateTime? expiryDate;

  int get priority {
    switch (state) {
      case _FleetComplianceState.missing:
        return 0;
      case _FleetComplianceState.expired:
        return 1;
      case _FleetComplianceState.noExpiry:
        return 2;
      case _FleetComplianceState.upcoming:
        return 3;
    }
  }

  DateTime? get sortDate {
    if (state == _FleetComplianceState.expired ||
        state == _FleetComplianceState.upcoming) {
      return expiryDate;
    }
    return null;
  }

  factory _FleetComplianceItem.fromVehicleDocument({
    required String vehicleNumber,
    required String type,
    required _FleetDashboardDocument? document,
  }) {
    if (document == null) {
      return _FleetComplianceItem(
        vehicleNumber: vehicleNumber,
        type: type,
        state: _FleetComplianceState.missing,
        expiryDate: null,
      );
    }

    final expiryDate = document.expiryDate;
    if (expiryDate == null) {
      return _FleetComplianceItem(
        vehicleNumber: vehicleNumber,
        type: type,
        state: _FleetComplianceState.noExpiry,
        expiryDate: null,
      );
    }

    return _FleetComplianceItem(
      vehicleNumber: vehicleNumber,
      type: type,
      state: _isFleetExpiryDateExpired(expiryDate)
          ? _FleetComplianceState.expired
          : _FleetComplianceState.upcoming,
      expiryDate: expiryDate,
    );
  }
}

String _fleetDocumentTypeLabel(BuildContext context, String type) {
  final t = AppLocalizations.of(context);
  switch (type) {
    case 'tuv':
      return t.t('fleet_status_vehicle_document_type_tuv');
    case 'insurance':
      return t.t('fleet_status_vehicle_document_type_insurance');
    case 'service':
      return t.t('fleet_status_vehicle_document_type_service');
    case 'rc':
      return t.t('fleet_status_vehicle_document_type_rc');
    default:
      return type;
  }
}

bool _isFleetExpiryDateExpired(DateTime date) {
  final normalizedDate = DateTime(date.year, date.month, date.day);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return normalizedDate.isBefore(today);
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
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(_r(12, scale)),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
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

class _FleetListCompact extends StatelessWidget {
  final double scale;
  final String title;
  final String tag;
  const _FleetListCompact({
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
        ...items.map((i) {
          return Padding(
            padding: EdgeInsets.only(bottom: _r(10, scale)),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: _r(12, scale),
                vertical: _r(10, scale),
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(_r(12, scale)),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'FÜ DE 319',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
            ),
          );
        }).toList(),
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
  String? get _uid {
    final scoped = AdminScope.maybeOf(context)?.adminUid;
    if (scoped != null && scoped.isNotEmpty) return scoped;
    return FirebaseAuth.instance.currentUser?.uid;
  }

  static const int _kSoonDays = 30;
  static const int _kProbezeitExpiredGraceDays = 7;

  // Onboarding expiry keys -> labels
  static const List<_ExpiryField> _expiryFields = [
    _ExpiryField(key: 'idDocExpiry', label: 'admin_home_doc_id_card'),
    _ExpiryField(key: 'licenseExpiry', label: 'admin_home_doc_driving_license'),
    _ExpiryField(
      key: 'residencePermitExpiry',
      label: 'admin_home_doc_residence_permit',
      // Third-country residence permit: warn 90 days ahead (Ausländerbehörde
      // lead time is far longer than 30 days) — ticket request.
      soonDays: 90,
    ),
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
    _RequiredField(
      key: 'emergencyContactName',
      label: 'Emergency Contact Name',
    ),
    _RequiredField(
      key: 'emergencyContactPhone',
      label: 'Emergency Contact Phone',
    ),
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

  bool _hasDocId(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    String id,
  ) {
    final target = id.toLowerCase().trim();
    for (final d in docs) {
      if (d.id.toLowerCase().trim() == target) return true;
    }
    return false;
  }

  List<String> _missingDriverDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
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

  bool _isProbezeitExpiredWithinGrace(DateTime probationEnd, DateTime today) {
    final daysSinceEnd = today.difference(probationEnd).inDays;
    return daysSinceEnd >= 1 && daysSinceEnd <= _kProbezeitExpiredGraceDays;
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

    final out = <String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>{};

    final futures = drivers.map((d) async {
      final transporterId = (d.data()['transporterId'] ?? d.id)
          .toString()
          .trim();
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

      final matches =
          id == t || docType == t || docType.contains(t) || id.contains(t);

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

      final isContract =
          id == 'contract' ||
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
      final raw =
          (data['contractType'] ??
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
    final t = AppLocalizations.of(context);
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
              footerText: t.t('admin_home_loading_drivers'),
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
              footerText: t.tf('admin_home_error_generic', {
                'error': '${snap.error}',
              }),
            );
          }

          final drivers =
              List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(
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
              footerText: t.t('admin_home_no_drivers_yet'),
            );
          }

          return FutureBuilder<
            Map<String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>
          >(
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

                final transporterId = (data['transporterId'] ?? d.id)
                    .toString()
                    .trim();
                final driverName =
                    (data['driverName'] ?? data['fullName'] ?? transporterId)
                        .toString()
                        .trim();

                final onboardingRaw = data['onboarding'];
                final onboarding = onboardingRaw is Map
                    ? Map<String, dynamic>.from(onboardingRaw as Map)
                    : <String, dynamic>{};

                final hasOnboarding = onboarding.isNotEmpty;

                final docs =
                    docsByTid[transporterId] ??
                    const <QueryDocumentSnapshot<Map<String, dynamic>>>[];

                // ---- Expiry scan from onboarding fields ----
                if (hasOnboarding) {
                  for (final f in _expiryFields) {
                    // Skip documents explicitly marked "no expiry date".
                    if (onboarding[f.key.replaceAll('Expiry', 'NoExpiry')] ==
                        true) {
                      continue;
                    }
                    final dt = _parseDate(onboarding[f.key]);
                    if (dt == null) continue;

                    final day = DateTime(dt.year, dt.month, dt.day);

                    // Per-field warning window (residence permit = 90 days).
                    final fieldSoonLimit =
                        today.add(Duration(days: f.soonDays));

                    final isExpired = day.isBefore(today);
                    final isSoon =
                        !isExpired &&
                        (day.isBefore(fieldSoonLimit) ||
                            day.isAtSameMomentAs(fieldSoonLimit));

                    if (isExpired || isSoon) {
                      expiredPillsByDriver.putIfAbsent(
                        driverName,
                        () => <String>[],
                      );

                      final label = t.t(f.label);
                      if (!expiredPillsByDriver[driverName]!.contains(label)) {
                        expiredPillsByDriver[driverName]!.add(label);
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
                  final isSoon =
                      !isExpired &&
                      (cEnd.isBefore(soonLimit) ||
                          cEnd.isAtSameMomentAs(soonLimit));

                  if (isExpired || isSoon) {
                    contractRowsUi.add(
                      _DocRowUi(
                        name: driverName,
                        contractPill: t.t('admin_home_contract'),
                        contractTone: _PillTone
                            .yellow, // keep your style, adjust if needed
                        rightPrefix: t.t('admin_home_last_day'),
                        date: cEnd,
                      ),
                    );
                  }

                  if (isSoon) contractSoonDrivers.add(driverName);
                }

                final workStart = _parseDate(onboarding['workStartDate']);
                final probationEnd = _probationEndFromStart(workStart);
                if (probationEnd != null) {
                  final diff = probationEnd.difference(today).inDays;
                  final isExpired = _isProbezeitExpiredWithinGrace(
                    probationEnd,
                    today,
                  );
                  final isSoon =
                      !isExpired &&
                      diff >= 0 &&
                      (probationEnd.isBefore(soonLimit) ||
                          probationEnd.isAtSameMomentAs(soonLimit));

                  if (isExpired || isSoon) {
                    contractRowsUi.add(
                      _DocRowUi(
                        name: driverName,
                        contractPill: t.t('admin_home_probation'),
                        contractTone: _PillTone.blue,
                        rightPrefix: isExpired
                            ? t.t('admin_home_ended')
                            : t.t('admin_home_ends'),
                        date: probationEnd,
                      ),
                    );
                  }

                  if (isSoon) contractSoonDrivers.add(driverName);
                }
              }

              // Build expired UI rows
              final expiredRowsUi = <_DocRowUi>[];
              expiredPillsByDriver.forEach((name, pills) {
                expiredRowsUi.add(
                  _DocRowUi(
                    name: name,
                    pills: pills,
                    rightPrefix: t.t('admin_home_expired_by'),
                    date: expiredDateByDriver[name],
                  ),
                );
              });

              // Sort: earliest date first
              expiredRowsUi.sort(
                (a, b) => (a.date ?? DateTime(2100)).compareTo(
                  b.date ?? DateTime(2100),
                ),
              );
              contractRowsUi.sort(
                (a, b) => (a.date ?? DateTime(2100)).compareTo(
                  b.date ?? DateTime(2100),
                ),
              );

              // Missing names
              final missingNamesUi = missingDrivers.toList()..sort();

              return _DriverDocsShellV2(
                scale: scale,
                // COUNTS
                expiredSoonCount: soonDrivers.length,
                expiredRows: expiredRowsUi
                    .take(4)
                    .toList(), // keep dashboard summary

                missingCount: missingDrivers.length,
                missingNames:
                    missingNamesUi, // ✅ DO NOT LIMIT (scroll will show all)

                contractSoonCount: contractSoonDrivers.length,
                // Show ALL affected drivers (card scrolls) — user feedback:
                // the 3–4 cap hid drivers whose contract is ending.
                contractRows: contractRowsUi,

                footerText:
                    (docsSnap.connectionState == ConnectionState.waiting)
                    ? t.t('admin_home_loading_documents')
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
    final t = AppLocalizations.of(context);
    final compact = MediaQuery.of(context).size.width < 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: _r(10, scale),
          runSpacing: _r(6, scale),
          children: [
            Icon(
              Icons.folder_copy_outlined,
              color: AdminHomePage._kGreen,
              size: _r(22, scale),
            ),
            Text(
              t.t('admin_home_driver_documents'),
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
          child: compact
              ? Column(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _DocSectionV2(
                        scale: scale,
                        title: t.t('admin_home_expired_documents'),
                        counterLabel: t.t('admin_home_expired_soon'),
                        counterValue: expiredSoonCount.toString(),
                        variant: _DocSectionVariant.expired,
                        rows: expiredRows,
                      ),
                    ),
                    SizedBox(height: _r(12, scale)),
                    const Divider(height: 1),
                    SizedBox(height: _r(12, scale)),
                    Expanded(
                      flex: 5,
                      child: _DocSectionV2(
                        scale: scale,
                        title: t.t('admin_home_missing_documents_data'),
                        counterLabel: t.t('admin_home_total_missing'),
                        counterValue: missingCount.toString(),
                        variant: _DocSectionVariant.missing,
                        missingNames: missingNames,
                      ),
                    ),
                    SizedBox(height: _r(12, scale)),
                    const Divider(height: 1),
                    SizedBox(height: _r(12, scale)),
                    Expanded(
                      flex: 3,
                      child: _DocSectionV2(
                        scale: scale,
                        title: t.t('admin_home_driver_contracts'),
                        counterLabel: t.t('admin_home_last_day_soon'),
                        counterValue: contractSoonCount.toString(),
                        variant: _DocSectionVariant.contract,
                        rows: contractRows,
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: _DocSectionV2(
                        scale: scale,
                        title: t.t('admin_home_expired_documents'),
                        counterLabel: t.t('admin_home_expired_soon'),
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
                        title: t.t('admin_home_missing_documents_data'),
                        counterLabel: t.t('admin_home_total_missing'),
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
                        title: t.t('admin_home_driver_contracts'),
                        counterLabel: t.t('admin_home_last_day_soon'),
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
    final compactHeader = MediaQuery.of(context).size.width < 700;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (compactHeader)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: _r(13, scale),
                ),
              ),
              SizedBox(height: _r(4, scale)),
              Wrap(
                spacing: _r(6, scale),
                runSpacing: _r(4, scale),
                children: [
                  Text(
                    '${widget.counterLabel}:',
                    style: TextStyle(
                      fontSize: _r(10, scale),
                      color: AdminHomePage._kMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
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
            ],
          )
        else
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
    final t = AppLocalizations.of(context);
    final scale = widget.scale;

    // -------- Missing ----------
    if (widget.variant == _DocSectionVariant.missing) {
      if (widget.missingNames.isEmpty) {
        return Center(
          child: Text(
            t.t('admin_home_no_items'),
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
          itemBuilder: (_, i) =>
              _MissingNameTile(scale: scale, name: widget.missingNames[i]),
        ),
      );
    }

    // -------- Expired / Contract ----------
    if (widget.rows.isEmpty) {
      return Center(
        child: Text(
          t.t('admin_home_no_items'),
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
    final t = AppLocalizations.of(context);
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
                    row.rightPrefix.isEmpty
                        ? t.t('admin_home_expired_by')
                        : row.rightPrefix,
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
                    .map(
                      (p) =>
                          _Pill(scale: scale, text: p, tone: _PillTone.orange),
                    )
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
    final t = AppLocalizations.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _r(14, scale),
        vertical: _r(12, scale),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3F5),
        borderRadius: BorderRadius.circular(_r(14, scale)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 360;

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: _r(12, scale),
                  ),
                ),
                SizedBox(height: _r(8, scale)),
                Wrap(
                  spacing: _r(8, scale),
                  runSpacing: _r(8, scale),
                  children: [
                    if (row.contractPill.isNotEmpty)
                      _Pill(
                        scale: scale,
                        text: row.contractPill,
                        tone: row.contractTone,
                      ),
                    Text(
                      row.rightPrefix.isEmpty
                          ? t.t('admin_home_last_day')
                          : row.rightPrefix,
                      style: TextStyle(
                        fontSize: _r(10, scale),
                        fontWeight: FontWeight.w800,
                        color: AdminHomePage._kText,
                      ),
                    ),
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
              ],
            );
          }

          return Row(
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
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: _r(8, scale),
                    runSpacing: _r(4, scale),
                    children: [
                      Text(
                        row.rightPrefix.isEmpty
                            ? t.t('admin_home_last_day')
                            : row.rightPrefix,
                        style: TextStyle(
                          fontSize: _r(10, scale),
                          fontWeight: FontWeight.w800,
                          color: AdminHomePage._kText,
                        ),
                      ),
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
          );
        },
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
  /// Days-ahead window for the "expiring soon" warning (default 30).
  final int soonDays;
  const _ExpiryField({
    required this.key,
    required this.label,
    this.soonDays = 30,
  });
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
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(pillRadius),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          popupMenuTheme: PopupMenuThemeData(
            color: const Color(0xFFF9FAFB),
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
                    color: selected
                        ? const Color(0xFFE5E7EB)
                        : Colors.transparent,
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

// ════════════════════════════════════════════════════════════════════════════
//  ALERT CENTER — unified notifications on the home page.
//  Aggregates every expiry-type alert in ONE feed, sorted by urgency:
//    • TÜV expired / due soon (per vehicle)
//    • Visa / residence permit expiring (per driver)
//    • Driving licence + ID document expiring (per driver)
//    • Work contract ending (per driver)
// ════════════════════════════════════════════════════════════════════════════

class _HomeAlert {
  final IconData icon;
  final String title;
  final String subject;
  final DateTime date;
  final int daysLeft; // negative = overdue

  /// Transporter ID for driver-related alerts — tapping the row opens the
  /// driver profile. Empty for vehicle alerts (TÜV).
  final String tid;

  /// Kategorie für die Filter-Chips (visa / zusatzblatt / licence /
  /// id / probation / contract / tuv).
  final String kind;

  const _HomeAlert({
    required this.icon,
    required this.title,
    required this.subject,
    required this.date,
    required this.daysLeft,
    this.tid = '',
    this.kind = '',
  });
  bool get expired => daysLeft < 0;
}

/// One row in the "Missing data" tab — an employee or a vehicle with
/// the list of fields that have never been filled in.
class _MissingEntry {
  final IconData icon;
  final String subject;
  final List<String> missing;

  /// Stabile Kategorie-Keys parallel zu [missing] (licence / visa /
  /// zusatzblatt / id / probation / contract / tid / employee_id / tuv)
  /// — Basis für die Filter-Chips im "Fehlende Daten"-Tab.
  final List<String> kinds;
  final String tid; // empty for vehicles

  const _MissingEntry({
    required this.icon,
    required this.subject,
    required this.missing,
    required this.kinds,
    this.tid = '',
  });
}

class _AlertCenterCard extends StatefulWidget {
  final double scale;
  const _AlertCenterCard({required this.scale});

  @override
  State<_AlertCenterCard> createState() => _AlertCenterCardState();
}

class _AlertCenterCardState extends State<_AlertCenterCard> {
  static const int _kSoonDays = 30;

  /// 0 = expiring alerts, 1 = missing data.
  int _tab = 0;

  /// Ticket: Kategorie-Filter für die Ablauf-Warnungen ('all' oder
  /// eine _HomeAlert.kind wie 'probation' / 'zusatzblatt').
  String _alertKindFilter = 'all';

  /// Kategorie-Filter für den "Fehlende Daten"-Tab — bewusst getrennt vom
  /// Ablauf-Filter, damit ein Tab-Wechsel den anderen Filter nicht ändert.
  String _missingKindFilter = 'all';

  /// Reihenfolge der Kategorie-Chips (identisch in beiden Tabs, damit die
  /// Filterzeile beim Tab-Wechsel gleich wirkt).
  static const List<String> _kKindOrder = [
    'probation',
    'zusatzblatt',
    'visa',
    'licence',
    'id',
    'contract',
    'tid',
    'employee_id',
    'tuv',
  ];

  String _alertKindLabel(String kind) {
    switch (kind) {
      case 'probation':
        return _tr('Probezeit', 'Probation');
      case 'zusatzblatt':
        return 'Zusatzblatt';
      case 'visa':
        return _tr('Visum', 'Visa');
      case 'licence':
        return _tr('Führerschein', 'Licence');
      case 'id':
        return _tr('Ausweis', 'ID');
      case 'contract':
        return _tr('Vertrag', 'Contract');
      case 'tuv':
        return 'TÜV';
      case 'tid':
        return 'Transporter-ID';
      case 'employee_id':
        return 'Employee ID';
      default:
        return kind;
    }
  }

  /// German when the app language is German, English otherwise.
  bool get _de => Localizations.localeOf(context).languageCode == 'de';
  String _tr(String de, String en) => _de ? de : en;

  String? get _uid {
    final scoped = AdminScope.maybeOf(context)?.adminUid;
    if (scoped != null && scoped.isNotEmpty) return scoped;
    return FirebaseAuth.instance.currentUser?.uid;
  }

  // Cache the per-driver documents future so the stream rebuilds don't
  // refetch every subcollection on each tick.
  String _docsCacheKey = '';
  Future<Map<String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>>?
      _docsFuture;

  DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is Timestamp) return v.toDate();
    final s = v.toString().trim();
    if (s.isEmpty) return null;
    final m =
        RegExp(r'^(\d{1,2})[\/.](\d{1,2})[\/.](\d{4})$').firstMatch(s);
    if (m != null) {
      return DateTime(
        int.parse(m.group(3)!),
        int.parse(m.group(2)!),
        int.parse(m.group(1)!),
      );
    }
    final iso = DateTime.tryParse(s);
    if (iso != null) return DateTime(iso.year, iso.month, iso.day);
    return null;
  }

  Future<Map<String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>>
      _loadDriverDocs(
    String uid,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> drivers,
  ) async {
    final out = <String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>{};
    await Future.wait(drivers.map((d) async {
      final tid = (d.data()['transporterId'] ?? d.id).toString().trim();
      if (tid.isEmpty) return;
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('drivers')
          .doc(tid)
          .collection('documents')
          .get();
      out[tid] = snap.docs;
    }));
    return out;
  }

  List<_HomeAlert> _buildAlerts({
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> drivers,
    required Map<String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>
        docsByTid,
    required List<FleetVehicleDocument> fleetDocs,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final alerts = <_HomeAlert>[];

    void add(IconData icon, String base, String subject, DateTime date,
        {String tid = '', int? soonDays, String kind = ''}) {
      final daysLeft = date.difference(today).inDays;
      if (daysLeft > (soonDays ?? _kSoonDays)) return;
      alerts.add(_HomeAlert(
        icon: icon,
        title: daysLeft < 0
            ? _tr('$base abgelaufen', '$base expired')
            : _tr('$base läuft ab', '$base expiring'),
        subject: subject,
        date: date,
        daysLeft: daysLeft,
        tid: tid,
        kind: kind,
      ));
    }

    // ── Drivers: onboarding expiries + contract end ──
    for (final d in drivers) {
      final data = d.data();
      // Inactive / archived / terminated drivers create no alerts.
      if (!isDriverWorking(data)) continue;
      final tid = (data['transporterId'] ?? d.id).toString().trim();
      final name = (data['driverName'] ?? data['fullName'] ?? tid)
          .toString()
          .trim();
      final onboardingRaw = data['onboarding'];
      final onboarding = onboardingRaw is Map
          ? Map<String, dynamic>.from(onboardingRaw as Map)
          : <String, dynamic>{};

      // EU work-permit drivers need no visa / Zusatzblatt — no expiry alerts.
      final isEu = _isEuWorkPermit(onboarding);

      // Working visa / residence permit — same fields the Drivers Hub
      // badge uses (workVisaExpiry with residencePermitExpiry fallback).
      final visa = _parseDate(onboarding['workVisaExpiry'] ??
          onboarding['residencePermitExpiry'] ??
          onboarding['workPermitExpiry']);
      // Third-country immigration documents: warn 90 days ahead — dealing
      // with the Ausländerbehörde takes far longer than 30 days (ticket).
      if (visa != null && !isEu) {
        add(Icons.badge_outlined,
            _tr('Visum / Aufenthaltstitel', 'Visa / residence permit'),
            name, visa,
            tid: tid, soonDays: 90, kind: 'visa');
      }
      final zusatzblatt = _parseDate(onboarding['zusatzblattExpiry']);
      if (zusatzblatt != null &&
          !isEu &&
          onboarding['zusatzblattNoExpiry'] != true) {
        add(Icons.note_outlined, 'Zusatzblatt', name, zusatzblatt,
            tid: tid, soonDays: 90, kind: 'zusatzblatt');
      }
      final license = _parseDate(onboarding['licenseExpiry']);
      if (license != null && onboarding['licenseNoExpiry'] != true) {
        add(Icons.directions_car_outlined,
            _tr('Führerschein', 'Driving licence'), name, license,
            tid: tid, kind: 'licence');
      }
      final idDoc = _parseDate(onboarding['idDocExpiry']);
      if (idDoc != null) {
        add(Icons.credit_card_outlined, _tr('Ausweis', 'ID document'), name,
            idDoc, tid: tid, kind: 'id');
      }

      // Probezeit: Ende = Arbeitsbeginn + 6 Monate − 1 Tag. Zeigt sich ab
      // 30 Tage vorher und bleibt bis 7 Tage nach Ablauf sichtbar.
      final workStart = _parseDate(onboarding['workStartDate']);
      if (workStart != null) {
        final totalMonths = (workStart.month - 1) + 6;
        final year = workStart.year + (totalMonths ~/ 12);
        final month = (totalMonths % 12) + 1;
        final lastDay = DateTime(year, month + 1, 0).day;
        final day = workStart.day <= lastDay ? workStart.day : lastDay;
        final probationEnd =
            DateTime(year, month, day).subtract(const Duration(days: 1));
        final diff = probationEnd.difference(today).inDays;
        if (diff <= _kSoonDays && diff >= -7) {
          alerts.add(_HomeAlert(
            icon: Icons.hourglass_bottom_rounded,
            title: diff < 0
                ? _tr('Probezeit beendet', 'Probation ended')
                : _tr('Probezeit endet', 'Probation ends'),
            subject: name,
            date: probationEnd,
            daysLeft: diff,
            tid: tid,
            kind: 'probation',
          ));
        }
      }

      // Contract end — onboarding field first (what the Drivers Hub badge
      // uses), the contract document as fallback. Unlimited contracts
      // never alert.
      final contractUnlimited = onboarding['contractUnlimited'] == true;
      final contractExpiry = contractUnlimited
          ? null
          : _parseDate(onboarding['contractExpiry']);
      if (contractExpiry != null) {
        final daysLeft = contractExpiry.difference(today).inDays;
        if (daysLeft <= _kSoonDays) {
          alerts.add(_HomeAlert(
            icon: Icons.description_outlined,
            title: daysLeft < 0
                ? _tr('Arbeitsvertrag abgelaufen', 'Contract expired')
                : _tr('Arbeitsvertrag endet', 'Contract ends'),
            subject: name,
            date: contractExpiry,
            daysLeft: daysLeft,
            tid: tid,
            kind: 'contract',
          ));
        }
      }

      // Contract end from the driver's documents.
      final docs = docsByTid[tid] ?? const [];
      if (contractExpiry != null || contractUnlimited) {
        // onboarding already covered it — skip the document fallback.
      } else
      for (final doc in docs) {
        final docData = doc.data();
        final docType = (docData['type'] ?? docData['docType'] ?? '')
            .toString()
            .toLowerCase();
        final isContract = doc.id.toLowerCase() == 'contract' ||
            docType.contains('contract');
        if (!isContract) continue;
        DateTime? end;
        for (final k in ['endDate', 'expiry', 'expiresAt', 'validUntil']) {
          end = _parseDate(docData[k]);
          if (end != null) break;
        }
        if (end != null) {
          final daysLeft = end.difference(today).inDays;
          if (daysLeft <= _kSoonDays) {
            alerts.add(_HomeAlert(
              icon: Icons.description_outlined,
              title: daysLeft < 0
                  ? _tr('Arbeitsvertrag abgelaufen', 'Contract expired')
                  : _tr('Arbeitsvertrag endet', 'Contract ends'),
              subject: name,
              date: end,
              daysLeft: daysLeft,
              tid: tid,
              kind: 'contract',
            ));
          }
        }
        break;
      }
    }

    // ── Vehicles: TÜV (newest cert per plate) ──
    final tuvByPlate = <String, FleetVehicleDocument>{};
    for (final doc in fleetDocs) {
      if (!doc.documentType.toUpperCase().contains('TUV')) continue;
      final plate = doc.plateNumber.trim().toUpperCase();
      if (plate.isEmpty) continue;
      final current = tuvByPlate[plate];
      final docDate = doc.updatedAt ?? doc.createdAt;
      final curDate = current == null
          ? null
          : (current.updatedAt ?? current.createdAt);
      if (current == null ||
          (docDate != null &&
              (curDate == null || docDate.isAfter(curDate)))) {
        tuvByPlate[plate] = doc;
      }
    }
    for (final entry in tuvByPlate.entries) {
      final expiry = _parseDate(entry.value.expiryDate);
      if (expiry == null) continue;
      add(Icons.local_shipping_outlined, 'TÜV', entry.key, expiry,
          kind: 'tuv');
    }

    alerts.sort((a, b) => a.daysLeft.compareTo(b.daysLeft));
    return alerts;
  }

  /// True when the driver's work permit resolves to EU — those drivers need
  /// no visa / Zusatzblatt expiry, so those fields are neither flagged as
  /// "missing" nor alerted on. Mirrors the Drivers-Hub work-permit
  /// normalization so this stays consistent with the pill on each card.
  bool _isEuWorkPermit(Map<String, dynamic> onboarding) {
    final value =
        (onboarding['workPermitType'] ?? '').toString().trim().toLowerCase();
    if (value == 'eu' || value == 'permit_eu_id' || value == 'eu_id') {
      return true;
    }
    if (value == 'working_visa' ||
        value == 'work_visa' ||
        value == 'permit_work_visa' ||
        value == 'visa') {
      return false;
    }
    // Any other explicit value counts as non-EU; unset falls back to the
    // legacy heuristic (a residence-permit expiry on file ⇒ visa driver).
    if (value.isNotEmpty) return false;
    final hasLegacyExpiry = (onboarding['residencePermitExpiry'] ?? '')
        .toString()
        .trim()
        .isNotEmpty;
    return !hasLegacyExpiry;
  }

  /// "Missing data" tab: working drivers whose key expiry fields were
  /// never entered (licence, visa, Zusatzblatt, ID) and vehicles with
  /// no recorded TÜV date.
  List<_MissingEntry> _buildMissing({
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> drivers,
    required List<FleetVehicleDocument> fleetDocs,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> vehicles,
  }) {
    final out = <_MissingEntry>[];

    for (final d in drivers) {
      final data = d.data();
      if (!isDriverWorking(data)) continue;
      final tid = (data['transporterId'] ?? d.id).toString().trim();
      final name = (data['driverName'] ?? data['fullName'] ?? tid)
          .toString()
          .trim();
      final onboardingRaw = data['onboarding'];
      final onboarding = onboardingRaw is Map
          ? Map<String, dynamic>.from(onboardingRaw as Map)
          : <String, dynamic>{};

      final isEu = _isEuWorkPermit(onboarding);

      final missing = <String>[];
      // Stabile Filter-Keys, index-gleich zu [missing].
      final kinds = <String>[];
      void add(String kind, String label) {
        kinds.add(kind);
        missing.add(label);
      }

      if (_parseDate(onboarding['licenseExpiry']) == null &&
          onboarding['licenseNoExpiry'] != true) {
        add('licence', _tr('Führerschein', 'Driving licence'));
      }
      // EU work-permit drivers need no visa / Zusatzblatt — don't flag those.
      if (!isEu &&
          _parseDate(onboarding['workVisaExpiry'] ??
                  onboarding['residencePermitExpiry'] ??
                  onboarding['workPermitExpiry']) ==
              null) {
        add('visa',
            _tr('Visum / Aufenthaltstitel', 'Visa / residence permit'));
      }
      if (!isEu &&
          _parseDate(onboarding['zusatzblattExpiry']) == null &&
          onboarding['zusatzblattNoExpiry'] != true) {
        add('zusatzblatt', 'Zusatzblatt');
      }
      if (_parseDate(onboarding['idDocExpiry']) == null) {
        add('id', _tr('Ausweis', 'ID document'));
      }
      // Probezeit is derived from the work start date — flag when the
      // start date was never entered.
      if (_parseDate(onboarding['workStartDate']) == null) {
        add('probation',
            _tr('Arbeitsbeginn (Probezeit)', 'Work start (probation)'));
      }
      if (onboarding['contractUnlimited'] != true &&
          _parseDate(onboarding['contractExpiry']) == null) {
        add('contract', _tr('Vertragsende', 'Contract end'));
      }
      // Ticket: fehlende Transporter-ID und fehlende Employee ID
      // (Zeiterfassung) ebenfalls als Missing Data melden.
      if (data['tidPending'] == true ||
          (data['transporterId'] ?? '').toString().trim().isEmpty) {
        add('tid', 'Transporter-ID');
      }
      if ((data['employeeNumber'] ?? '').toString().trim().isEmpty) {
        add('employee_id', 'Employee ID');
      }
      if (missing.isNotEmpty) {
        out.add(_MissingEntry(
          icon: Icons.person_outline,
          subject: name,
          missing: missing,
          kinds: kinds,
          tid: tid,
        ));
      }
    }

    // Vehicles without any TÜV date on file.
    final tuvPlates = <String>{};
    for (final doc in fleetDocs) {
      if (!doc.documentType.toUpperCase().contains('TUV')) continue;
      if (_parseDate(doc.expiryDate) == null) continue;
      final plate = doc.plateNumber.trim().toUpperCase();
      if (plate.isNotEmpty) tuvPlates.add(plate);
    }
    final missingTuv = <String>{};
    for (final v in vehicles) {
      final data = v.data();
      if (data['isDeleted'] == true) continue;
      final status = (data['status'] ?? '').toString().toUpperCase();
      if (status == 'INACTIVE') continue;
      final plate = (data['plateNumber'] ?? data['vehicleNumber'] ?? v.id)
          .toString()
          .trim()
          .toUpperCase();
      if (plate.isEmpty || tuvPlates.contains(plate)) continue;
      missingTuv.add(plate);
    }
    for (final plate in missingTuv.toList()..sort()) {
      out.add(_MissingEntry(
        icon: Icons.local_shipping_outlined,
        subject: plate,
        missing: const ['TÜV'],
        kinds: const ['tuv'],
      ));
    }
    return out;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? _driversStream(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('drivers')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    final uid = _uid;
    if (uid == null) {
      return _AdminCard(scale: scale, child: const SizedBox.shrink());
    }

    return _AdminCard(
      scale: scale,
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _driversStream(uid),
        builder: (context, driverSnap) {
          final drivers = driverSnap.data?.docs ??
              const <QueryDocumentSnapshot<Map<String, dynamic>>>[];
          // Refresh the docs future only when the driver set changes.
          final key = '$uid:${drivers.length}';
          if (key != _docsCacheKey) {
            _docsCacheKey = key;
            _docsFuture = _loadDriverDocs(uid, drivers.toList());
          }
          return StreamBuilder<List<FleetVehicleDocument>>(
            stream:
                FleetVehicleDocumentService().watchScopeDocuments(dspUid: uid),
            builder: (context, fleetSnap) {
              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection('vehicles')
                    .snapshots(),
                builder: (context, vehiclesSnap) {
                return FutureBuilder<
                  Map<String,
                      List<QueryDocumentSnapshot<Map<String, dynamic>>>>>(
                future: _docsFuture,
                builder: (context, docsSnap) {
                  final alerts = _buildAlerts(
                    drivers: drivers.toList(),
                    docsByTid: docsSnap.data ?? const {},
                    fleetDocs:
                        fleetSnap.data ?? const <FleetVehicleDocument>[],
                  );
                  final missing = _buildMissing(
                    drivers: drivers.toList(),
                    fleetDocs:
                        fleetSnap.data ?? const <FleetVehicleDocument>[],
                    vehicles: vehiclesSnap.data?.docs.toList() ??
                        const <QueryDocumentSnapshot<Map<String, dynamic>>>[],
                  );
                  final expired = alerts.where((a) => a.expired).length;
                  final soon = alerts.length - expired;

                  // Ticket: Filter-Chips pro Kategorie mit Anzahl.
                  final kindCounts = <String, int>{};
                  for (final a in alerts) {
                    if (a.kind.isEmpty) continue;
                    kindCounts[a.kind] = (kindCounts[a.kind] ?? 0) + 1;
                  }
                  // Weggefallene Kategorie → zurück auf "All".
                  final activeKindFilter =
                      kindCounts.containsKey(_alertKindFilter)
                          ? _alertKindFilter
                          : 'all';
                  final visibleAlerts = activeKindFilter == 'all'
                      ? alerts
                      : alerts
                          .where((a) => a.kind == activeKindFilter)
                          .toList();
                  final presentKinds = _presentKinds(kindCounts);

                  // Ticket: dieselben Kategorie-Chips für "Fehlende Daten".
                  // Ein Eintrag kann mehrere Lücken haben — die Chip-Zahl
                  // zählt also Einträge, nicht Felder.
                  final missingCounts = <String, int>{};
                  for (final m in missing) {
                    for (final k in m.kinds.toSet()) {
                      if (k.isEmpty) continue;
                      missingCounts[k] = (missingCounts[k] ?? 0) + 1;
                    }
                  }
                  final activeMissingFilter =
                      missingCounts.containsKey(_missingKindFilter)
                          ? _missingKindFilter
                          : 'all';
                  final visibleMissing = activeMissingFilter == 'all'
                      ? missing
                      : missing
                          .where((m) => m.kinds.contains(activeMissingFilter))
                          .toList();
                  final presentMissingKinds = _presentKinds(missingCounts);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.notifications_active_outlined,
                            color: AdminHomePage._kGreen,
                            size: _r(22, scale),
                          ),
                          SizedBox(width: _r(10, scale)),
                          Expanded(
                            child: Text(
                              'Notifications',
                              style: TextStyle(
                                fontSize: _r(20, scale),
                                fontWeight: FontWeight.w900,
                                color: AdminHomePage._kText,
                              ),
                            ),
                          ),
                          if (expired > 0)
                            _alertCountChip(
                                _tr('$expired abgelaufen', '$expired expired'),
                                const Color(0xFFB91C1C)),
                          if (expired > 0 && soon > 0)
                            SizedBox(width: _r(6, scale)),
                          if (soon > 0)
                            _alertCountChip(
                                _tr('$soon bald fällig', '$soon due soon'),
                                const Color(0xFFB45309)),
                        ],
                      ),
                      SizedBox(height: _r(10, scale)),
                      Row(
                        children: [
                          _tabChip(0, _tr('Ablaufend', 'Expiring'),
                              alerts.length),
                          const SizedBox(width: 8),
                          _tabChip(1, _tr('Fehlende Daten', 'Missing data'),
                              missing.length),
                        ],
                      ),
                      // Kategorie-Filter je Tab: "Alle" zuerst, dann eine
                      // Chip pro vorkommender Kategorie mit Anzahl.
                      if (_tab == 0 && alerts.isNotEmpty) ...[
                        SizedBox(height: _r(8, scale)),
                        _kindFilterRow(
                          total: alerts.length,
                          kinds: presentKinds,
                          counts: kindCounts,
                          current: activeKindFilter,
                          onSelect: (k) =>
                              setState(() => _alertKindFilter = k),
                        ),
                      ],
                      if (_tab == 1 && missing.isNotEmpty) ...[
                        SizedBox(height: _r(8, scale)),
                        _kindFilterRow(
                          total: missing.length,
                          kinds: presentMissingKinds,
                          counts: missingCounts,
                          current: activeMissingFilter,
                          onSelect: (k) =>
                              setState(() => _missingKindFilter = k),
                        ),
                      ],
                      SizedBox(height: _r(10, scale)),
                      const Divider(height: 1),
                      SizedBox(height: _r(8, scale)),
                      Expanded(
                        child: (_tab == 0
                                ? visibleAlerts.isEmpty
                                : visibleMissing.isEmpty)
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.check_circle_outline,
                                        color: Color(0xFF16A34A), size: 32),
                                    SizedBox(height: _r(8, scale)),
                                    Text(
                                      _tab == 0
                                          ? _tr('Alles im grünen Bereich.',
                                              'All clear.')
                                          : _tr('Keine fehlenden Daten.',
                                              'No missing data.'),
                                      style: TextStyle(
                                        color: AdminHomePage._kMuted,
                                        fontSize: _r(13, scale),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : (_tab == 0
                                ? ListView.builder(
                                    itemCount: visibleAlerts.length,
                                    itemBuilder: (context, i) =>
                                        _alertRow(visibleAlerts[i], i),
                                  )
                                : ListView.builder(
                                    itemCount: visibleMissing.length,
                                    itemBuilder: (context, i) =>
                                        _missingRow(visibleMissing[i], i),
                                  )),
                      ),
                    ],
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

  /// Kategorien in fester Reihenfolge, ohne leere Kategorien —
  /// unbekannte Keys (Zukunft) hinten anhängen.
  List<String> _presentKinds(Map<String, int> counts) => [
        for (final k in _kKindOrder)
          if (counts.containsKey(k)) k,
        for (final k in counts.keys)
          if (!_kKindOrder.contains(k)) k,
      ];

  /// Horizontal scrollbare Filterzeile — identisch für beide Tabs
  /// ("Alle (n)" zuerst, danach eine Chip je Kategorie).
  Widget _kindFilterRow({
    required int total,
    required List<String> kinds,
    required Map<String, int> counts,
    required String current,
    required ValueChanged<String> onSelect,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _kindChip('all', _tr('Alle', 'All'), total, current,
              onSelect: onSelect),
          for (final k in kinds) ...[
            const SizedBox(width: 6),
            _kindChip(k, _alertKindLabel(k), counts[k] ?? 0, current,
                onSelect: onSelect),
          ],
        ],
      ),
    );
  }

  /// Kategorie-Chip für die Filterzeilen ("Alle (12)", "Probezeit (3)" …)
  /// — [current] ist der gerade wirksame Filter des jeweiligen Tabs.
  Widget _kindChip(
    String kind,
    String label,
    int count,
    String current, {
    required ValueChanged<String> onSelect,
  }) {
    final selected = current == kind;
    return InkWell(
      onTap: () => onSelect(kind),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF111827) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color:
                selected ? const Color(0xFF111827) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          '$label ($count)',
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF475569),
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _tabChip(int index, String label, int count) {
    final selected = _tab == index;
    return InkWell(
      onTap: () => setState(() => _tab = index),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AdminHomePage._kGreen : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AdminHomePage._kGreen : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          '$label ($count)',
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF475569),
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _missingRow(_MissingEntry m, int index) {
    final scale = widget.scale;
    final row = Container(
      color: index.isOdd ? const Color(0xFFF6F7F9) : Colors.white,
      padding: EdgeInsets.symmetric(
          horizontal: _r(10, scale), vertical: _r(8, scale)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: _r(30, scale),
            height: _r(30, scale),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(m.icon,
                size: _r(16, scale), color: const Color(0xFFEA580C)),
          ),
          SizedBox(width: _r(10, scale)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.subject,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: _r(13, scale),
                    fontWeight: FontWeight.w800,
                    color: AdminHomePage._kText,
                  ),
                ),
                SizedBox(height: _r(4, scale)),
                Wrap(
                  spacing: 5,
                  runSpacing: 4,
                  children: [
                    for (final label in m.missing)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEA580C)
                              .withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFC2410C),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (m.tid.isNotEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Icon(Icons.chevron_right,
                  size: 16, color: Color(0xFF9CA3AF)),
            ),
        ],
      ),
    );
    if (m.tid.isEmpty) return row;
    return InkWell(
      onTap: () => _openDriverProfile(m.tid),
      child: row,
    );
  }

  Widget _alertCountChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }

  /// Opens the tapped driver's profile inside a pushed Drivers-Hub route.
  void _openDriverProfile(String tid) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      // Ohne eigene AppBar: die Fahrer-Detailseite bringt ihren eigenen
      // Kopf mit (Zurück-Pfeil, Titel, Einstellungen) — ein Rahmen-Header
      // darüber ergäbe zwei gestapelte Kopfzeilen.
      builder: (_) => Scaffold(
        backgroundColor: AdminHomePage._kPageBg,
        body: SafeArea(child: DriversHubPage(initialOpenTid: tid)),
      ),
    ));
  }

  Widget _alertRow(_HomeAlert a, int index) {
    final scale = widget.scale;
    final color = a.expired
        ? const Color(0xFFB91C1C)
        : (a.daysLeft <= 7
            ? const Color(0xFFEA580C)
            : const Color(0xFFB45309));
    final when = a.expired
        ? (a.daysLeft == 0
            ? _tr('heute', 'today')
            : _tr('vor ${-a.daysLeft} T', '${-a.daysLeft} d ago'))
        : (a.daysLeft == 0
            ? _tr('heute', 'today')
            : _tr('in ${a.daysLeft} T', 'in ${a.daysLeft} d'));
    String two(int n) => n.toString().padLeft(2, '0');
    final dateStr =
        '${two(a.date.day)}.${two(a.date.month)}.${a.date.year % 100}';

    return InkWell(
      onTap: a.tid.isEmpty ? null : () => _openDriverProfile(a.tid),
      child: Container(
      // Alternating white / light grey for readability.
      color: index.isOdd ? const Color(0xFFF6F7F9) : Colors.white,
      padding: EdgeInsets.symmetric(
          vertical: _r(8, scale), horizontal: _r(6, scale)),
      child: Row(
        children: [
          Container(
            width: _r(34, scale),
            height: _r(34, scale),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(a.icon, size: _r(17, scale), color: color),
          ),
          SizedBox(width: _r(10, scale)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: _r(13.5, scale),
                    fontWeight: FontWeight.w700,
                    color: AdminHomePage._kText,
                  ),
                ),
                Text(
                  a.subject,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: _r(12, scale),
                    color: AdminHomePage._kMuted,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: _r(8, scale)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  when,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: _r(11, scale),
                  ),
                ),
              ),
              SizedBox(height: _r(2, scale)),
              Text(
                dateStr,
                style: TextStyle(
                  fontSize: _r(10.5, scale),
                  color: AdminHomePage._kMuted,
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}
