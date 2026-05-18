// lib/Screens/admin_cotimer_page.dart
//
// co:timer — Admin-Page für das Zeiterfassungs-Modul.
//
// Tabs:
//   1. Live-Board   — wer ist gerade eingestempelt
//   2. Zeitkonto    — Soll/Ist/Saldo pro Driver
//   3. Korrekturen  — Inbox für Driver-Anträge
//   4. Compliance   — ArbZG-Verstöße + Compliance-Reports
//   5. Setup        — Stationen, Geofences, Hub-Adressen
//
// Sichtbar nur für den Super-Admin (`admin@arion-logistics.de`). Side-
// Menu-Eintrag ist hinter derselben Email-Whitelist gegated.

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:http/http.dart' as http;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../services/time_tracking_firestore.dart';
import '../theme/app_colors.dart';
import '../widgets/pill_tab_bar.dart';
import '../theme/app_elevation.dart';
import '../theme/app_typography.dart';
import '../widgets/admin_scope.dart';
import 'admin_cotimer_employment_dialog.dart';
import '../widgets/web_preview.dart'
    if (dart.library.html) '../widgets/web_preview_web.dart';

class AdminCotimerPage extends StatefulWidget {
  const AdminCotimerPage({super.key});

  @override
  State<AdminCotimerPage> createState() => _AdminCotimerPageState();
}

class _AdminCotimerPageState extends State<AdminCotimerPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = AdminScope.adminUidOf(context) ??
        FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: uid == null
                  ? _buildHeaderOnly()
                  : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .snapshots(),
                      builder: (context, adminSnap) {
                        return StreamBuilder<
                            QuerySnapshot<Map<String, dynamic>>>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(uid)
                              .collection('stations')
                              .snapshots(),
                          builder: (context, stationsSnap) {
                            final adminData = adminSnap.data?.data();
                            final emp =
                                (adminData?['cotimerEmployment'] as Map?) ??
                                    const {};
                            final addons =
                                (adminData?['addons'] as Map?) ?? const {};
                            final addonEnabled =
                                addons['timeTracking'] == true;
                            final hasContract = emp.isNotEmpty &&
                                (emp['bundesland'] ?? '')
                                    .toString()
                                    .trim()
                                    .isNotEmpty;
                            final stations =
                                stationsSnap.data?.docs ?? const [];
                            final stationsWithFence = stations.where((d) {
                              final fences =
                                  (d.data()['geofences'] as List?) ??
                                      const [];
                              return fences.isNotEmpty;
                            }).toList();
                            final hasStation = stationsWithFence.isNotEmpty;
                            final setupComplete =
                                hasContract && hasStation;

                            return Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                              children: [
                                _buildHeader(),
                                const SizedBox(height: 16),
                                if (!setupComplete)
                                  Expanded(
                                    child: _SetupGate(
                                      adminUid: uid,
                                      hasContract: hasContract,
                                      hasStation: hasStation,
                                      stationCount: stations.length,
                                      addonEnabled: addonEnabled,
                                    ),
                                  )
                                else ...[
                                  _buildTabBar(),
                                  const SizedBox(height: 16),
                                  Expanded(
                                    child: TabBarView(
                                      controller: _tab,
                                      children: const [
                                        _LiveBoardTab(),
                                        _TimeAccountTab(),
                                        _CorrectionsTab(),
                                        _ComplianceTab(),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            );
                          },
                        );
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderOnly() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
        ],
      );

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Schlankes Logo-Mark — kleiner, sodass die Daten im Fokus stehen.
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'co',
                style: AppTypography.title2.copyWith(
              color: Colors.black,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                ),
              ),
              TextSpan(
                text: ':',
                style: AppTypography.title2.copyWith(
                  color: AppColors.codriverGreen,
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextSpan(
                text: 'timer',
                style: AppTypography.title2.copyWith(
              color: Colors.black,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        // DSP-UID-Chip (kopierbar) + Settings-Zahnrad oben rechts.
        // Der UID-Chip hilft beim Abgleich mit dem Driver — wenn ein
        // Fahrer co:timer noch nicht stempeln kann, kann er seine
        // DSP-UID mit dieser hier vergleichen.
        Builder(
          builder: (ctx) {
            final uid = AdminScope.adminUidOf(ctx) ??
                FirebaseAuth.instance.currentUser?.uid;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (uid != null)
                  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .snapshots(),
                    builder: (sCtx, snap) {
                      final email =
                          (snap.data?.data()?['email'] ?? '')
                              .toString()
                              .trim();
                      final initial = email.isEmpty
                          ? '?'
                          : email[0].toUpperCase();
                      return Tooltip(
                        message: email.isEmpty
                            ? 'DSP-UID: $uid'
                            : email,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: () async {
                            final copy = email.isEmpty ? uid : email;
                            await Clipboard.setData(
                                ClipboardData(text: copy));
                            if (sCtx.mounted) {
                              ScaffoldMessenger.of(sCtx).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Account kopiert: $copy'),
                                ),
                              );
                            }
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.codriverGreen
                                  .withValues(alpha: 0.14),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.codriverGreen
                                    .withValues(alpha: 0.3),
                                width: 0.8,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              initial,
                              style: AppTypography.subheadline.copyWith(
              color: Colors.black,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(width: 8),
                Material(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(
                        color: Color(0xFFE5E5EA), width: 0.6),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: uid == null
                        ? null
                        : () => _openSetupPage(ctx, uid),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.settings_outlined,
                        size: 20,
                        color: uid == null
                            ? AppColors.labelSecondaryLight
                            : AppColors.codriverDeep,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> _openSetupPage(BuildContext ctx, String adminUid) async {
    await Navigator.of(ctx).push(MaterialPageRoute<void>(
      builder: (_) => _SetupFullPage(adminUid: adminUid),
    ));
  }

  Widget _buildTabBar() {
    return PillTabBar(
      controller: _tab,
      tabs: const ['Live', 'Zeitkonto', 'Korrekturen', 'Compliance'],
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  Tab 1 — Live-Board
// ════════════════════════════════════════════════════════════════════

class _LiveBoardTab extends StatefulWidget {
  const _LiveBoardTab();

  @override
  State<_LiveBoardTab> createState() => _LiveBoardTabState();
}

class _LiveBoardTabState extends State<_LiveBoardTab> {
  // Kein parent-Ticker mehr — der hat jede Sekunde den GESAMTEN Tab
  // (inkl. StreamBuilder + ListView) neu gerendert und damit visuell
  // geflackert. Jede _ActiveShiftCard hat jetzt ihren eigenen Ticker,
  // der nur den Live-Timer-Text inside der Karte aktualisiert.

  @override
  Widget build(BuildContext context) {
    final uid = AdminScope.adminUidOf(context) ??
        FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const _EmptyTabState(
        icon: Icons.lock_outline,
        title: 'Nicht eingeloggt',
        subtitle: 'Bitte erneut anmelden, um das Live-Board zu sehen.',
      );
    }

    // Driver-Namen aus der Default-DB (nam5) abfragen — separat,
    // weil die Default-DB und die Time-DB nicht verknüpft sind.
    final driversStream = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('drivers')
        .snapshots();

    // Offene Schichten aus der Time-DB (eur3) über CollectionGroup-Query.
    final openShiftsStream = TimeTrackingFirestore.instance
        .collectionGroup('shifts')
        .where('adminUid', isEqualTo: uid)
        .where('isOpen', isEqualTo: true)
        .orderBy('startTs', descending: true)
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: driversStream,
      builder: (context, driversSnap) {
        final driverNames = <String, String>{};
        if (driversSnap.hasData) {
          for (final d in driversSnap.data!.docs) {
            final data = d.data();
            final name = (data['driverName'] ?? '').toString();
            driverNames[d.id] = name;
          }
        }

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: openShiftsStream,
          builder: (context, shiftsSnap) {
            if (shiftsSnap.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (shiftsSnap.hasError) {
              return _EmptyTabState(
                icon: Icons.error_outline_rounded,
                title: 'Fehler beim Laden',
                subtitle: '${shiftsSnap.error}\n\n'
                    'Hinweis: Der Firestore-CollectionGroup-Index für '
                    '`shifts` wird beim Erst-Aufruf angelegt — das kann '
                    'ein paar Minuten dauern. Bitte gleich erneut '
                    'versuchen.',
              );
            }
            final shifts = shiftsSnap.data?.docs ?? const [];
            if (shifts.isEmpty) {
              return const _EmptyTabState(
                icon: Icons.coffee_outlined,
                title: 'Niemand ist eingestempelt',
                subtitle:
                    'Sobald ein Fahrer per co:timer einstempelt, erscheint '
                    'er hier mit Live-Schichtdauer und Compliance-Status.',
              );
            }

            // Stats berechnen
            int onPause = 0;
            int compliancePoor = 0;
            int sumWorkedSeconds = 0;
            final now = DateTime.now();
            for (final s in shifts) {
              final data = s.data();
              final pauses = (data['pauses'] as List?) ?? const [];
              if (pauses.isNotEmpty &&
                  (pauses.last as Map)['end'] == null) {
                onPause++;
              }
              final start = (data['startTs'] as Timestamp?)?.toDate();
              final pauseDur = (data['pauseDuration'] as num?)?.toInt() ?? 0;
              if (start != null) {
                final elapsed = now.difference(start).inSeconds;
                final worked = (elapsed - pauseDur).clamp(0, 1 << 31);
                sumWorkedSeconds += worked.toInt();
                // Pause-Schwelle nach 6 h ohne Pause
                if (worked >= 6 * 3600 && pauseDur < 1800) {
                  compliancePoor++;
                }
                if (elapsed / 3600 > 10) compliancePoor++;
              }
            }

            return ListView(
              padding: const EdgeInsets.only(bottom: 80),
              children: [
                _StatsRow(
                  active: shifts.length,
                  onPause: onPause,
                  warnings: compliancePoor,
                  totalWorkedSeconds: sumWorkedSeconds,
                ),
                const SizedBox(height: 14),
                for (final s in shifts) ...[
                  _ActiveShiftCard(
                    shift: s.data(),
                    driverName: driverNames[s.data()['driverId'] as String?
                            ?? ''] ??
                        (s.data()['driverId'] ?? '').toString(),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            );
          },
        );
      },
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int active;
  final int onPause;
  final int warnings;
  final int totalWorkedSeconds;
  const _StatsRow({
    required this.active,
    required this.onPause,
    required this.warnings,
    required this.totalWorkedSeconds,
  });

  String _fmtHm(int seconds) {
    final h = (seconds ~/ 3600);
    final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _StatChip(
              label: 'EINGESTEMPELT',
              value: '$active',
              color: AppColors.codriverGreen,
              icon: Icons.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatChip(
              label: 'HEUTE GESAMT',
              value: _fmtHm(totalWorkedSeconds),
              color: const Color(0xFF1C1C1E),
              icon: Icons.schedule_rounded,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatChip(
              label: 'IN PAUSE',
              value: '$onPause',
              color: const Color(0xFFB7791F),
              icon: Icons.pause_circle_filled_rounded,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatChip(
              label: 'WARNUNGEN',
              value: '$warnings',
              color: warnings > 0
                  ? AppColors.error
                  : AppColors.labelSecondaryLight,
              icon: Icons.warning_amber_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevatedLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppElevation.level1,
        border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: color, size: 12),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption2.copyWith(
                    color: AppColors.labelSecondaryLight,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.title2.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveShiftCard extends StatefulWidget {
  final Map<String, dynamic> shift;
  final String driverName;
  const _ActiveShiftCard({required this.shift, required this.driverName});

  @override
  State<_ActiveShiftCard> createState() => _ActiveShiftCardState();
}

class _ActiveShiftCardState extends State<_ActiveShiftCard> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Eigener 1Hz-Ticker pro Karte. Nur diese Card rebuilt jede Sekunde,
    // nicht der ganze Live-Board-Tab.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _formatElapsed(int seconds) {
    final h = (seconds ~/ 3600).toString().padLeft(2, '0');
    final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Widget _miniDetail({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.caption2.copyWith(
            color: const Color(0xFF6B7280),
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: AppTypography.subheadline.copyWith(
            color: const Color(0xFF1C1C1E),
            fontWeight: FontWeight.w800,
            fontFeatures: const [FontFeature.tabularFigures()],
            height: 1.0,
          ),
        ),
      ],
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final shift = widget.shift;
    final driverName = widget.driverName;
    final start = (shift['startTs'] as Timestamp?)?.toDate();
    final stationCode = (shift['stationCode'] ?? '').toString();
    final pauses = (shift['pauses'] as List?) ?? const [];
    final inPause = pauses.isNotEmpty &&
        (pauses.last as Map)['end'] == null;
    final pauseDur = (shift['pauseDuration'] as num?)?.toInt() ?? 0;

    final totalSeconds =
        start == null ? 0 : DateTime.now().difference(start).inSeconds;
    final workSeconds = (totalSeconds - pauseDur).clamp(0, 1 << 31);
    final workHours = workSeconds / 3600;

    final warnings = <String>[];
    if (workHours >= 6 && pauseDur < 1800) {
      warnings.add('Mindestpause noch nicht erreicht');
    }
    if (workHours > 9 && pauseDur < 2700) {
      warnings.add('Bei >9 h sind 45 min Pause Pflicht');
    }
    if (totalSeconds / 3600 > 10) {
      warnings.add('Schichtdauer über 10 h (ArbZG §3)');
    }

    // „Nächste Pause fällig in" — sobald 6 h gearbeitet ohne 30 min
    // Pause, geht die Schwelle auf 0 und der Driver muss Pause machen.
    final secondsUntilPauseDue = 6 * 3600 - workSeconds;
    final pauseDueSoon = !inPause && pauseDur < 1800 &&
        secondsUntilPauseDue > 0 && secondsUntilPauseDue < 30 * 60;

    final accent = inPause
        ? const Color(0xFFB7791F)
        : (warnings.isNotEmpty ? AppColors.error : AppColors.codriverGreen);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevatedLight,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppElevation.level1,
        border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar mit Status-Dot — Initial neutral dunkel, der
              // Status-Dot unten rechts zeigt die Live-Farbe.
              Stack(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF2F2F7),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _initials(driverName),
                      style: AppTypography.subheadline.copyWith(
              color: Colors.black,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      driverName.isEmpty ? '— Unbekannt —' : driverName,
                      style: AppTypography.subheadline.copyWith(
              color: Colors.black,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F2F7),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            stationCode.isEmpty ? '—' : stationCode,
                            style: AppTypography.caption2.copyWith(
              color: Colors.black,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (inPause)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF4E5),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'PAUSE',
                              style: AppTypography.caption2.copyWith(
                                color: const Color(0xFFB7791F),
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Live timer rechts — neutral dunkel, der Status wird
              // ohnehin schon links durch Avatar-Dot kommuniziert.
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatElapsed(totalSeconds),
                    style: AppTypography.title3.copyWith(
              color: Colors.black,
                      fontWeight: FontWeight.w800,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      letterSpacing: -0.2,
                    ),
                  ),
                  if (start != null)
                    Text(
                      'seit ${_formatTime(start)}',
                      style: AppTypography.caption1.copyWith(
                        color: AppColors.labelSecondaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ],
          ),
          // Detail-Zeile: Arbeit / Pause + ggf. „Pause bald fällig"
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                _miniDetail(
                  label: 'Arbeit',
                  value: _formatElapsed(workSeconds.toInt()),
                ),
                Container(
                    width: 0.6,
                    height: 22,
                    color: const Color(0xFFE5E5EA),
                    margin: const EdgeInsets.symmetric(horizontal: 12)),
                _miniDetail(
                  label: 'Pause',
                  value: _formatElapsed(pauseDur),
                ),
                if (pauseDueSoon) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.coffee_outlined,
                          size: 12,
                          color: Color(0xFF92400E),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Pause in ${_formatElapsed(secondsUntilPauseDue.toInt())}',
                          style: AppTypography.caption2.copyWith(
                            color: const Color(0xFF92400E),
                            fontWeight: FontWeight.w800,
                            fontFeatures: const [
                              FontFeature.tabularFigures()
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (warnings.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4E5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFFFB547),
                  width: 0.6,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: Color(0xFFB7791F),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final w in warnings)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 1),
                            child: Text(
                              w,
                              style: AppTypography.caption1.copyWith(
                                color: const Color(0xFFB7791F),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  Tab 2 — Zeitkonto
// ════════════════════════════════════════════════════════════════════

class _TimeAccountTab extends StatefulWidget {
  const _TimeAccountTab();

  @override
  State<_TimeAccountTab> createState() => _TimeAccountTabState();
}

class _TimeAccountTabState extends State<_TimeAccountTab> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month, 1);
  }

  String _ym(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}';

  String _monthLabel(DateTime d) {
    const months = [
      'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
      'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember',
    ];
    return '${months[d.month - 1]} ${d.year}';
  }

  void _prev() => setState(() => _month = DateTime(_month.year, _month.month - 1, 1));
  void _next() => setState(() => _month = DateTime(_month.year, _month.month + 1, 1));

  String _formatHours(double h) {
    final sign = h < 0 ? '-' : '';
    final abs = h.abs();
    final hours = abs.floor();
    final mins = ((abs - hours) * 60).round();
    return '$sign$hours:${mins.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final uid = AdminScope.adminUidOf(context) ??
        FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const _EmptyTabState(
        icon: Icons.lock_outline,
        title: 'Nicht eingeloggt',
        subtitle: 'Bitte erneut anmelden, um das Zeitkonto zu sehen.',
      );
    }

    final driversStream = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('drivers')
        .snapshots();

    final accountsStream = TimeTrackingFirestore.instance
        .collectionGroup('time_account')
        .where('adminUid', isEqualTo: uid)
        .where('month', isEqualTo: _ym(_month))
        .snapshots();

    return Column(
      children: [
        _buildMonthPicker(),
        const SizedBox(height: 14),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: driversStream,
            builder: (context, driversSnap) {
              final drivers = driversSnap.data?.docs ?? const [];
              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: accountsStream,
                builder: (context, accSnap) {
                  if (driversSnap.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (drivers.isEmpty) {
                    return const _EmptyTabState(
                      icon: Icons.group_outlined,
                      title: 'Keine Driver erfasst',
                      subtitle:
                          'Sobald Fahrer im Drivers-Hub angelegt sind, '
                          'erscheinen sie hier mit Soll/Ist/Saldo.',
                    );
                  }
                  // Map driverId -> account-doc
                  final byDriver = <String, Map<String, dynamic>>{};
                  for (final a in (accSnap.data?.docs ?? const [])) {
                    byDriver[(a.data()['driverId'] ?? '').toString()] =
                        a.data();
                  }

                  // Sum
                  double sumSoll = 0, sumIst = 0;
                  for (final a in byDriver.values) {
                    sumSoll += (a['soll'] as num?)?.toDouble() ?? 0;
                    sumIst += (a['ist'] as num?)?.toDouble() ?? 0;
                  }
                  final sumSaldo = sumIst - sumSoll;

                  return ListView(
                    padding: const EdgeInsets.only(bottom: 80),
                    children: [
                      _AccountSummary(
                        driverCount: drivers.length,
                        sumSoll: sumSoll,
                        sumIst: sumIst,
                        sumSaldo: sumSaldo,
                        formatHours: _formatHours,
                      ),
                      const SizedBox(height: 14),
                      for (final d in drivers) ...[
                        _TimeAccountRow(
                          adminUid: uid,
                          driverId: d.id,
                          driverData: d.data(),
                          account: byDriver[d.id],
                          month: _ym(_month),
                          formatHours: _formatHours,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMonthPicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevatedLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _prev,
            icon: const Icon(Icons.chevron_left_rounded),
            color: Colors.black,
            tooltip: 'Vorheriger Monat',
          ),
          Expanded(
            child: Center(
              child: Text(
                _monthLabel(_month),
                style: AppTypography.headline.copyWith(
              color: Colors.black,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: _next,
            icon: const Icon(Icons.chevron_right_rounded),
            color: Colors.black,
            tooltip: 'Nächster Monat',
          ),
          const SizedBox(width: 4),
          // 3-Punkte-Menü mit selten gebrauchten Aktionen.
          // „Neu berechnen" muss man normalerweise NICHT klicken —
          // Soll/Ist/Saldo werden nach jedem Clock-Out und nach jeder
          // Absence-Genehmigung automatisch frisch geschrieben. Der
          // Menüpunkt bleibt für Debugging / manuelle Korrekturen.
          PopupMenuButton<String>(
            tooltip: 'Mehr',
            icon: _recomputing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.more_horiz_rounded),
            color: Colors.white,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            onSelected: (v) {
              switch (v) {
                case 'export':
                  _exportPayrollCsv();
                  break;
                case 'recompute':
                  _recomputeMonth();
                  break;
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download_rounded,
                        size: 18, color: Color(0xFF374151)),
                    SizedBox(width: 10),
                    Text('Payroll-CSV exportieren'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'recompute',
                child: Row(
                  children: [
                    Icon(Icons.refresh_rounded,
                        size: 18, color: Color(0xFF374151)),
                    SizedBox(width: 10),
                    Text('Neu berechnen (manuell)'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  bool _recomputing = false;

  Future<void> _recomputeMonth() async {
    if (_recomputing) return;
    setState(() => _recomputing = true);
    final messenger = ScaffoldMessenger.of(context);
    final month = _ym(_month);
    try {
      final res = await FirebaseFunctions.instanceFor(region: 'europe-west3')
          .httpsCallable('recomputeMonthlyAccount')
          .call(<String, dynamic>{'month': month});
      final m = res.data is Map ? res.data as Map : const {};
      messenger.showSnackBar(SnackBar(
        content: Text(
          'Konto neu berechnet für ${m['month'] ?? month} · '
          '${m['driversProcessed'] ?? '?'} Fahrer',
        ),
      ));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Fehler: $e')));
    } finally {
      if (mounted) setState(() => _recomputing = false);
    }
  }

  /// Lädt Driver-Stammdaten + monatliches Zeitkonto + Zeitkonto-Eckdaten,
  /// erzeugt eine Lohnabrechnungs-CSV und triggert den Browser-Download.
  Future<void> _exportPayrollCsv() async {
    final uid = AdminScope.adminUidOf(context) ??
        FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      // Company-wide employment settings (Bundesland gilt für alle Fahrer).
      final adminDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final companyEmp =
          (adminDoc.data()?['cotimerEmployment'] as Map?) ?? const {};
      final companyBundesland =
          (companyEmp['bundesland'] ?? '').toString();

      final drivers = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('drivers')
          .get();

      final accountsSnap = await TimeTrackingFirestore.instance
          .collectionGroup('time_account')
          .where('adminUid', isEqualTo: uid)
          .where('month', isEqualTo: _ym(_month))
          .get();
      final accounts = <String, Map<String, dynamic>>{};
      for (final a in accountsSnap.docs) {
        accounts[(a.data()['driverId'] ?? '').toString()] = a.data();
      }

      String esc(String s) {
        if (s.contains(',') || s.contains('"') || s.contains('\n')) {
          return '"${s.replaceAll('"', '""')}"';
        }
        return s;
      }

      final csv = StringBuffer();
      csv.writeln([
        'Driver Name',
        'Transporter ID',
        'External Employee ID',
        'Bundesland',
        'Soll (h)',
        'Ist (h)',
        'Saldo (h)',
        'Arbeitstage',
        'Feiertage',
        'Urlaubstage',
        'Krankentage',
        'Spesentage (>=8h)',
        'Spesen EUR',
        'Monat',
      ].map(esc).join(','));

      for (final d in drivers.docs) {
        final data = d.data();
        // Per-Driver payroll-IDs liegen weiterhin am Driver-Doc;
        // Bundesland kommt jetzt aus den Company-Settings.
        final payroll =
            (data['payroll'] as Map?) ?? const <String, dynamic>{};
        final acc = accounts[d.id] ?? const {};
        csv.writeln([
          (data['driverName'] ?? '').toString(),
          (data['transporterId'] ?? '').toString(),
          (payroll['externalEmployeeId'] ?? '').toString(),
          companyBundesland,
          _formatHours((acc['soll'] as num?)?.toDouble() ?? 0),
          _formatHours((acc['ist'] as num?)?.toDouble() ?? 0),
          _formatHours((acc['saldo'] as num?)?.toDouble() ?? 0),
          ((acc['workingDays'] as num?)?.toInt() ?? 0).toString(),
          ((acc['holidayDays'] as num?)?.toInt() ?? 0).toString(),
          ((acc['vacationDays'] as num?)?.toInt() ?? 0).toString(),
          ((acc['sickDays'] as num?)?.toInt() ?? 0).toString(),
          ((acc['spesenDays'] as num?)?.toInt() ?? 0).toString(),
          ((acc['spesenAmount'] as num?)?.toDouble() ?? 0.0)
              .toStringAsFixed(2)
              .replaceAll('.', ','),
          _ym(_month),
        ].map((v) => esc(v.toString())).join(','));
      }

      final bytes = Uint8List.fromList(utf8.encode(csv.toString()));
      await downloadWebBytes(
        bytes,
        'codriver_payroll_${_ym(_month)}.csv',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export ${_ym(_month)} heruntergeladen')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export-Fehler: $e')),
      );
    }
  }
}

class _AccountSummary extends StatelessWidget {
  final int driverCount;
  final double sumSoll;
  final double sumIst;
  final double sumSaldo;
  final String Function(double) formatHours;
  const _AccountSummary({
    required this.driverCount,
    required this.sumSoll,
    required this.sumIst,
    required this.sumSaldo,
    required this.formatHours,
  });

  @override
  Widget build(BuildContext context) {
    final saldoColor = sumSaldo > 0.01
        ? AppColors.codriverGreen
        : (sumSaldo < -0.01 ? AppColors.error : AppColors.labelSecondaryLight);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppElevation.level2,
      ),
      child: Row(
        children: [
          _summaryCell(
            'DRIVER',
            '$driverCount',
            Colors.white,
          ),
          _verticalDivider(),
          _summaryCell(
            'SOLL',
            '${formatHours(sumSoll)} h',
            Colors.white,
          ),
          _verticalDivider(),
          _summaryCell(
            'IST',
            '${formatHours(sumIst)} h',
            Colors.white,
          ),
          _verticalDivider(),
          _summaryCell(
            'SALDO',
            '${sumSaldo >= 0 ? '+' : ''}${formatHours(sumSaldo)} h',
            saldoColor,
          ),
        ],
      ),
    );
  }

  Widget _summaryCell(String label, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.caption2.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTypography.title3.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() => Container(
        width: 1,
        height: 32,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        color: Colors.white.withValues(alpha: 0.18),
      );
}

class _TimeAccountRow extends StatelessWidget {
  final String adminUid;
  final String driverId;
  final Map<String, dynamic> driverData;
  final Map<String, dynamic>? account;
  final String month;
  final String Function(double) formatHours;
  const _TimeAccountRow({
    required this.adminUid,
    required this.driverId,
    required this.driverData,
    required this.account,
    required this.month,
    required this.formatHours,
  });

  void _openDetails(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => _DriverTimeDetailDialog(
        adminUid: adminUid,
        driverId: driverId,
        driverData: driverData,
        month: month,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = (driverData['driverName'] ?? '—').toString();
    final tid = (driverData['transporterId'] ?? '').toString();
    final soll = (account?['soll'] as num?)?.toDouble();
    final ist = (account?['ist'] as num?)?.toDouble();
    final saldo = (account?['saldo'] as num?)?.toDouble();
    final hasData = account != null;

    Color? saldoColor;
    if (saldo != null) {
      saldoColor = saldo > 0.01
          ? AppColors.codriverGreen
          : (saldo < -0.01 ? AppColors.error : AppColors.labelSecondaryLight);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openDetails(context),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevatedLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
        boxShadow: AppElevation.level1,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.codriverGreen.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              _initials(name),
              style: AppTypography.subheadline.copyWith(
              color: Colors.black,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name.isEmpty ? '—' : name,
                  style: AppTypography.subheadline.copyWith(
              color: Colors.black,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  tid,
                  style: AppTypography.caption1.copyWith(
                    color: AppColors.labelSecondaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (!hasData)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'KEINE DATEN',
                style: AppTypography.caption2.copyWith(
                  color: AppColors.labelSecondaryLight,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _miniCell('Soll', '${formatHours(soll!)} h'),
                const SizedBox(width: 14),
                _miniCell('Ist', '${formatHours(ist!)} h'),
                const SizedBox(width: 14),
                _miniCell(
                  'Saldo',
                  '${saldo! >= 0 ? '+' : ''}${formatHours(saldo)} h',
                  color: saldoColor,
                ),
              ],
            ),
          const SizedBox(width: 6),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.labelTertiaryLight,
            size: 22,
          ),
        ],
      ),
    ),
      ),
    );
  }

  Widget _miniCell(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.caption2.copyWith(
            color: AppColors.labelSecondaryLight,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.subheadline.copyWith(
            color: color ?? AppColors.codriverDeep,
            fontWeight: FontWeight.w800,
            fontFeatures: const [FontFeature.tabularFigures()],
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final f = parts.first[0];
    final l = parts.length > 1 ? parts.last[0] : '';
    return (f + l).toUpperCase();
  }
}

// ════════════════════════════════════════════════════════════════════
//  Driver-Detail-Dialog — Monatshistorie + Einzelschichten
// ════════════════════════════════════════════════════════════════════

class _DriverTimeDetailDialog extends StatelessWidget {
  final String adminUid;
  final String driverId;
  final Map<String, dynamic> driverData;
  final String month; // 'YYYY-MM'

  const _DriverTimeDetailDialog({
    required this.adminUid,
    required this.driverId,
    required this.driverData,
    required this.month,
  });

  String _fmtHours(int seconds) {
    final h = (seconds ~/ 3600).toString().padLeft(2, '0');
    final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _fmtDay(DateTime d) {
    const days = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
    final w = days[d.weekday - 1];
    return '$w ${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.';
  }

  String _fmtTime(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final name = (driverData['driverName'] ?? '—').toString();
    final tid = (driverData['transporterId'] ?? '').toString();
    final parts = month.split('-');
    final year = int.parse(parts[0]);
    final monthNum = int.parse(parts[1]);
    final monthStart = DateTime.utc(year, monthNum, 1);
    final monthEnd = DateTime.utc(year, monthNum + 1, 1);

    final shiftsStream = TimeTrackingFirestore.shifts(
      adminUid: adminUid,
      driverId: driverId,
    )
        .where('startTs',
            isGreaterThanOrEqualTo: Timestamp.fromDate(monthStart))
        .where('startTs', isLessThan: Timestamp.fromDate(monthEnd))
        .where('isOpen', isEqualTo: false)
        .orderBy('startTs', descending: true)
        .snapshots();

    return Dialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 720),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 14),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE5E5EA), width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.codriverGreen.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          name,
                          style: AppTypography.title3.copyWith(
              color: Colors.black,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          tid.isEmpty ? 'Keine TID' : 'TID · $tid',
                          style: AppTypography.caption1.copyWith(
                            color: AppColors.labelSecondaryLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      month,
                      style: AppTypography.caption2.copyWith(
              color: Colors.black,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    color: AppColors.labelSecondaryLight,
                  ),
                ],
              ),
            ),

            Flexible(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: shiftsStream,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snap.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Fehler: ${snap.error}',
                        style: AppTypography.footnote.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    );
                  }
                  final docs = snap.data?.docs ?? const [];
                  if (docs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 60),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppColors.green50,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.event_busy_rounded,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Keine Schichten in $month',
                              style: AppTypography.subheadline.copyWith(
                                color: AppColors.labelSecondaryLight,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final totalWork = docs.fold<int>(
                    0,
                    (s, d) =>
                        s + ((d.data()['workDuration'] as num?)?.toInt() ?? 0),
                  );
                  final totalPause = docs.fold<int>(
                    0,
                    (s, d) =>
                        s + ((d.data()['pauseDuration'] as num?)?.toInt() ?? 0),
                  );

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                    shrinkWrap: true,
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            _summaryCell('Schichten', '${docs.length}'),
                            _vDivider(),
                            _summaryCell(
                                'Arbeitszeit', '${_fmtHours(totalWork)} h'),
                            _vDivider(),
                            _summaryCell(
                                'Pausen', '${_fmtHours(totalPause)} h'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      for (final s in docs) _shiftRow(s),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCell(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.caption2.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTypography.title3.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _vDivider() => Container(
        width: 1,
        height: 32,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        color: Colors.white.withValues(alpha: 0.18),
      );

  Widget _shiftRow(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final start = (data['startTs'] as Timestamp?)?.toDate();
    final end = (data['endTs'] as Timestamp?)?.toDate();
    final work = (data['workDuration'] as num?)?.toInt() ?? 0;
    final pause = (data['pauseDuration'] as num?)?.toInt() ?? 0;
    final flags = (data['complianceFlags'] as Map?) ?? const {};
    final warns = ((flags['warnings'] as List?) ?? const []).length;
    final stationCode = (data['stationCode'] ?? '').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevatedLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
      ),
      child: Row(
        children: [
          if (start != null)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                _fmtDay(start),
                style: AppTypography.caption2.copyWith(
              color: Colors.black,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  start != null && end != null
                      ? '${_fmtTime(start)} – ${_fmtTime(end)}'
                      : '—',
                  style: AppTypography.subheadline.copyWith(
              color: Colors.black,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                Text(
                  '$stationCode · Arbeit ${_fmtHours(work)} h · Pause ${_fmtHours(pause)} h',
                  style: AppTypography.caption1.copyWith(
                    color: AppColors.labelSecondaryLight,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (warns > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 12,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '$warns',
                    style: AppTypography.caption2.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w800,
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

// ════════════════════════════════════════════════════════════════════
//  Tab 3 — Korrekturen
// ════════════════════════════════════════════════════════════════════

class _CorrectionsTab extends StatelessWidget {
  const _CorrectionsTab();

  @override
  Widget build(BuildContext context) {
    final uid = AdminScope.adminUidOf(context) ??
        FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const _EmptyTabState(
        icon: Icons.lock_outline,
        title: 'Nicht eingeloggt',
        subtitle: 'Bitte erneut anmelden.',
      );
    }

    final driversStream = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('drivers')
        .snapshots();

    final pendingStream = TimeTrackingFirestore.instance
        .collectionGroup('correction_requests')
        .where('adminUid', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .orderBy('submittedAt', descending: true)
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: driversStream,
      builder: (context, driversSnap) {
        final names = <String, String>{
          for (final d in driversSnap.data?.docs ?? const [])
            d.id: (d.data()['driverName'] ?? '').toString(),
        };
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: pendingStream,
          builder: (context, reqSnap) {
            if (reqSnap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (reqSnap.hasError) {
              return _EmptyTabState(
                icon: Icons.error_outline_rounded,
                title: 'Fehler beim Laden',
                subtitle: '${reqSnap.error}',
              );
            }
            final reqs = reqSnap.data?.docs ?? const [];
            if (reqs.isEmpty) {
              return const _EmptyTabState(
                icon: Icons.inbox_outlined,
                title: 'Keine offenen Anträge',
                subtitle:
                    'Sobald ein Driver einen Korrektur-Antrag stellt, '
                    'erscheint er hier mit Diff-View und Approve/Reject.',
              );
            }
            return ListView(
              padding: const EdgeInsets.only(bottom: 80),
              children: [
                for (final r in reqs) ...[
                  _CorrectionRequestCard(
                    requestDoc: r,
                    driverName: names[r.data()['driverId']] ?? '',
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            );
          },
        );
      },
    );
  }
}

class _CorrectionRequestCard extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> requestDoc;
  final String driverName;
  const _CorrectionRequestCard({
    required this.requestDoc,
    required this.driverName,
  });

  String _typeLabel(String type) {
    switch (type) {
      case 'missing_entry':
        return 'Stempel vergessen';
      case 'wrong_time':
        return 'Falsche Zeit';
      case 'forgot_pause':
        return 'Pause nicht erfasst';
      default:
        return 'Sonstige Korrektur';
    }
  }

  String _formatTs(Timestamp? ts) {
    if (ts == null) return '—';
    final d = ts.toDate();
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final hh = d.hour.toString().padLeft(2, '0');
    final mi = d.minute.toString().padLeft(2, '0');
    return '$dd.$mm.${d.year} · $hh:$mi';
  }

  Future<void> _process(BuildContext context, String action) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => _CommentDialog(action: action),
    );
    if (reason == null) return;

    final parentPath = requestDoc.reference.parent.parent!.path;
    try {
      await FirebaseFunctions.instanceFor(region: 'europe-west3')
          .httpsCallable('processCorrectionRequest')
          .call({
        'driverPath': parentPath,
        'requestId': requestDoc.id,
        'action': action,
        'comment': reason.isEmpty ? null : reason,
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(action == 'approve' ? 'Antrag genehmigt' : 'Antrag abgelehnt'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = requestDoc.data();
    final type = (data['type'] ?? 'other').toString();
    final shiftDate = (data['shiftDate'] ?? '').toString();
    final reason = (data['reason'] ?? '').toString();
    final submittedAt = data['submittedAt'] as Timestamp?;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevatedLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
        boxShadow: AppElevation.level1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF4E5),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.fact_check_outlined,
                  color: Color(0xFFB7791F),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      driverName.isEmpty ? '—' : driverName,
                      style: AppTypography.subheadline.copyWith(
              color: Colors.black,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${_typeLabel(type)} · $shiftDate',
                      style: AppTypography.caption1.copyWith(
                        color: AppColors.labelSecondaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _formatTs(submittedAt),
                style: AppTypography.caption1.copyWith(
                  color: AppColors.labelTertiaryLight,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          if (reason.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
              ),
              child: Text(
                reason,
                style: AppTypography.footnote.copyWith(
                  color: AppColors.codriverGraphite,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () => _process(context, 'reject'),
                icon: const Icon(Icons.close_rounded, size: 16),
                label: const Text('Ablehnen'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: Color(0xFFFFCDD2), width: 1),
                  shape: const StadiumBorder(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: () => _process(context, 'approve'),
                icon: const Icon(Icons.check_rounded, size: 16),
                label: const Text('Genehmigen'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.codriverGreen,
                  shape: const StadiumBorder(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CommentDialog extends StatefulWidget {
  final String action;
  const _CommentDialog({required this.action});
  @override
  State<_CommentDialog> createState() => _CommentDialogState();
}

class _CommentDialogState extends State<_CommentDialog> {
  final _ctrl = TextEditingController();
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isApprove = widget.action == 'approve';
    return AlertDialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(isApprove ? 'Antrag genehmigen' : 'Antrag ablehnen'),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        maxLines: 3,
        decoration: const InputDecoration(
          labelText: 'Kommentar (optional)',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_ctrl.text.trim()),
          style: FilledButton.styleFrom(
            backgroundColor:
                isApprove ? AppColors.codriverGreen : AppColors.error,
            shape: const StadiumBorder(),
          ),
          child: Text(isApprove ? 'Genehmigen' : 'Ablehnen'),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  Tab 4 — Compliance
// ════════════════════════════════════════════════════════════════════

class _ComplianceTab extends StatelessWidget {
  const _ComplianceTab();

  String _fmtDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd.$mm.${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final uid = AdminScope.adminUidOf(context) ??
        FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const _EmptyTabState(
        icon: Icons.lock_outline,
        title: 'Nicht eingeloggt',
        subtitle: 'Bitte erneut anmelden.',
      );
    }

    final driversStream = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('drivers')
        .snapshots();

    // Geschlossene Schichten der letzten 60 Tage
    final since = Timestamp.fromDate(
      DateTime.now().subtract(const Duration(days: 60)),
    );
    final shiftsStream = TimeTrackingFirestore.instance
        .collectionGroup('shifts')
        .where('adminUid', isEqualTo: uid)
        .where('isOpen', isEqualTo: false)
        .where('startTs', isGreaterThan: since)
        .orderBy('startTs', descending: true)
        .limit(100)
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: driversStream,
      builder: (context, driversSnap) {
        final names = <String, String>{
          for (final d in driversSnap.data?.docs ?? const [])
            d.id: (d.data()['driverName'] ?? '').toString(),
        };
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: shiftsStream,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return _EmptyTabState(
                icon: Icons.error_outline_rounded,
                title: 'Fehler beim Laden',
                subtitle: '${snap.error}',
              );
            }
            // Nur Schichten mit warnings
            final docs = (snap.data?.docs ?? const []).where((d) {
              final flags = d.data()['complianceFlags'] as Map?;
              final warns = (flags?['warnings'] as List?) ?? const [];
              return warns.isNotEmpty;
            }).toList();

            if (docs.isEmpty) {
              return const _EmptyTabState(
                icon: Icons.verified_rounded,
                title: 'Keine Compliance-Verstöße',
                subtitle:
                    'In den letzten 60 Tagen gab es keine erkannten '
                    'ArbZG-Verstöße. Sauber!',
              );
            }

            return ListView(
              padding: const EdgeInsets.only(bottom: 80),
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.32),
                      width: 0.6,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${docs.length} Schichten mit Compliance-Verstößen '
                          'in den letzten 60 Tagen',
                          style: AppTypography.subheadline.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                for (final s in docs) ...[
                  _ComplianceRow(
                    shift: s.data(),
                    driverName: names[s.data()['driverId']] ?? '',
                    formatDate: _fmtDate,
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            );
          },
        );
      },
    );
  }
}

class _ComplianceRow extends StatelessWidget {
  final Map<String, dynamic> shift;
  final String driverName;
  final String Function(DateTime) formatDate;
  const _ComplianceRow({
    required this.shift,
    required this.driverName,
    required this.formatDate,
  });

  String _fmtHours(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    return '${h}h ${m.toString().padLeft(2, '0')}m';
  }

  @override
  Widget build(BuildContext context) {
    final flags = (shift['complianceFlags'] as Map?) ?? const {};
    final warns = ((flags['warnings'] as List?) ?? const [])
        .map((e) => e.toString())
        .toList();
    final start = (shift['startTs'] as Timestamp?)?.toDate();
    final workSec = (shift['workDuration'] as num?)?.toInt() ?? 0;
    final pauseSec = (shift['pauseDuration'] as num?)?.toInt() ?? 0;
    final stationCode = (shift['stationCode'] ?? '').toString();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevatedLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
        boxShadow: AppElevation.level1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${warns.length}× WARNUNG',
                  style: AppTypography.caption2.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  driverName.isEmpty ? '— Unbekannt —' : driverName,
                  style: AppTypography.subheadline.copyWith(
              color: Colors.black,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (start != null)
                Text(
                  formatDate(start),
                  style: AppTypography.caption1.copyWith(
                    color: AppColors.labelSecondaryLight,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (stationCode.isNotEmpty) ...[
                Text(stationCode,
                    style: AppTypography.caption1.copyWith(
                      color: AppColors.labelSecondaryLight,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    )),
                const Text(' · '),
              ],
              Text(
                'Arbeit ${_fmtHours(workSec)} · Pause ${_fmtHours(pauseSec)}',
                style: AppTypography.caption1.copyWith(
                  color: AppColors.labelSecondaryLight,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final w in warns)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      size: 14, color: AppColors.error),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      w,
                      style: AppTypography.footnote.copyWith(
                        color: AppColors.codriverGraphite,
                        fontWeight: FontWeight.w600,
                      ),
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

// ════════════════════════════════════════════════════════════════════
//  Tab 5 — Setup (Stationen + Geofences)
// ════════════════════════════════════════════════════════════════════

Future<void> _openTransferDriverDialog(
  BuildContext context,
  String adminUid,
) async {
  final emailCtrl = TextEditingController();
  await showDialog<void>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx2, setLocal) {
          bool busy = false;
          String? error;
          String? success;
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Fahrer auf diesen Admin übernehmen'),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Der Fahrer wird vom alten DSP gelöst und unter '
                    'diesem Admin-Account verknüpft. Stationen, Soll '
                    'und Schichten von diesem Admin werden danach '
                    'für den Fahrer sichtbar.',
                    style: AppTypography.footnote.copyWith(
                      color: AppColors.labelSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Fahrer-Email',
                      hintText: 'driver@example.com',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        error!,
                        style: const TextStyle(
                          color: Color(0xFFB91C1C),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  if (success != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.green50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        success!,
                        style: AppTypography.caption1.copyWith(
              color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed:
                    busy ? null : () => Navigator.of(ctx).pop(),
                child: const Text('Schließen'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.codriverGreen,
                ),
                onPressed: busy
                    ? null
                    : () async {
                        final email = emailCtrl.text.trim();
                        if (email.isEmpty) {
                          setLocal(() => error = 'Email eintragen');
                          return;
                        }
                        setLocal(() {
                          busy = true;
                          error = null;
                          success = null;
                        });
                        try {
                          final res = await FirebaseFunctions.instance
                              .httpsCallable(
                                  'transferDriverToCallerAdmin')
                              .call(<String, dynamic>{
                            'driverEmail': email,
                          });
                          final tid = (res.data is Map
                                  ? res.data['transporterId']
                                  : null) ??
                              '?';
                          setLocal(() {
                            busy = false;
                            success =
                                'Fahrer $email übernommen (TID: $tid). '
                                'Der Fahrer muss sich einmal aus- und '
                                'wieder einloggen, damit die '
                                'Berechtigungen aktualisiert werden.';
                          });
                        } catch (e) {
                          setLocal(() {
                            busy = false;
                            error = '$e';
                          });
                        }
                      },
                child: busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Übernehmen'),
              ),
            ],
          );
        },
      );
    },
  );
  emailCtrl.dispose();
}

Future<void> _seedHolidays(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Dialog(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Lade deutsche Feiertage …'),
          ],
        ),
      ),
    ),
  );
  try {
    final res = await FirebaseFunctions.instanceFor(region: 'europe-west3')
        .httpsCallable('seedHolidaysNow')
        .call(<String, dynamic>{});
    final count = (res.data is Map ? res.data['count'] : null) ?? '?';
    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
    messenger.showSnackBar(
      SnackBar(content: Text('Feiertage geladen ($count Einträge).')),
    );
  } catch (e) {
    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
    messenger.showSnackBar(
      SnackBar(content: Text('Fehler beim Laden: $e')),
    );
  }
}

/// Vollbild-Wrapper für die Setup-Seite — Aufruf über das Zahnrad-Icon
/// im Header. Lädt den Addon-Flag selbst und kapselt den
/// iOS-Settings-Inhalt in einem Scaffold mit AppBar + Close-Pfeil.
class _SetupFullPage extends StatelessWidget {
  final String adminUid;
  const _SetupFullPage({required this.adminUid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        foregroundColor: AppColors.codriverDeep,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Einstellungen',
          style: AppTypography.headline.copyWith(
              color: Colors.black,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(adminUid)
                    .snapshots(),
                builder: (ctx, snap) {
                  final addons =
                      (snap.data?.data()?['addons'] as Map?) ?? const {};
                  final addonEnabled = addons['timeTracking'] == true;
                  return _SetupTab(addonEnabled: addonEnabled);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SetupTab extends StatelessWidget {
  final bool addonEnabled;
  const _SetupTab({this.addonEnabled = false});

  @override
  Widget build(BuildContext context) {
    final uid = AdminScope.adminUidOf(context) ??
        FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const _EmptyTabState(
        icon: Icons.lock_outline,
        title: 'Nicht eingeloggt',
        subtitle: 'Bitte erneut anmelden, um Stationen zu verwalten.',
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots(),
      builder: (context, adminSnap) {
        final emp =
            (adminSnap.data?.data()?['cotimerEmployment'] as Map?) ??
                const {};
        return ListView(
          padding: const EdgeInsets.only(bottom: 80),
          children: [
            // ── Sektion: Freischaltung ────────────────────────────
            _iOSSection(
              title: 'Freischaltung',
              children: [
                _iOSSwitchRow(
                  icon: Icons.group_outlined,
                  iconColor: AppColors.codriverGreen,
                  title: 'co:timer für alle Fahrer',
                  subtitle: addonEnabled
                      ? 'Alle Fahrer sehen das co:timer-Tile'
                      : 'Nur du siehst co:timer aktuell',
                  value: addonEnabled,
                  onChanged: (v) async {
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .set({
                        'addons': {'timeTracking': v},
                        'updatedAt': FieldValue.serverTimestamp(),
                      }, SetOptions(merge: true));
                      messenger.showSnackBar(SnackBar(
                        content: Text(v
                            ? 'co:timer freigeschaltet.'
                            : 'co:timer deaktiviert.'),
                      ));
                    } catch (e) {
                      messenger.showSnackBar(
                        SnackBar(content: Text('Fehler: $e')),
                      );
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Sektion: Arbeitsvertrag ───────────────────────────
            _iOSSection(
              title: 'Arbeitsvertrag (gilt für alle Fahrer)',
              children: [
                _iOSValueRow(
                  icon: Icons.access_time_rounded,
                  iconColor: AppColors.codriverGreen,
                  title: 'Soll-Modus',
                  value: _sollModeLabel(emp),
                  onTap: () =>
                      EmploymentEditDialog.show(context, adminUid: uid),
                ),
                _iOSDivider(),
                _iOSValueRow(
                  icon: Icons.map_outlined,
                  iconColor: AppColors.codriverGreen,
                  title: 'Bundesland',
                  value: _bundeslandLabel(emp),
                  onTap: () =>
                      EmploymentEditDialog.show(context, adminUid: uid),
                ),
                _iOSDivider(),
                _iOSValueRow(
                  icon: Icons.calendar_today_outlined,
                  iconColor: AppColors.codriverGreen,
                  title: 'Arbeitstage',
                  value: _workingDaysLabel(emp),
                  onTap: () =>
                      EmploymentEditDialog.show(context, adminUid: uid),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Sektion: Stationen ────────────────────────────────
            _iOSStationsSection(adminUid: uid),

            const SizedBox(height: 24),

            // ── Sektion: System ───────────────────────────────────
            _iOSSection(
              title: 'System',
              children: [
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('global_holidays')
                      .where('year',
                          isEqualTo: DateTime.now().year)
                      .snapshots(),
                  builder: (ctx, snap) {
                    final count = snap.data?.docs.length ?? 0;
                    final year = DateTime.now().year;
                    final loaded = count > 0;
                    return _iOSValueRow(
                      icon: Icons.event_available_outlined,
                      iconColor: AppColors.codriverGreen,
                      title: 'Feiertage $year',
                      value: loaded
                          ? '$count Einträge'
                          : 'Nicht geladen',
                      onTap: () => _seedHolidays(ctx),
                    );
                  },
                ),
                const _iOSDivider(),
                _iOSValueRow(
                  icon: Icons.swap_horiz_rounded,
                  iconColor: AppColors.codriverGreen,
                  title: 'Fahrer übernehmen',
                  value: 'Tippe zum Öffnen',
                  onTap: () =>
                      _openTransferDriverDialog(context, uid),
                ),
              ],
            ),
            // (Stations-StreamBuilder vom alten Code) — wird vom
            // _iOSStationsSection oben ersetzt. Der folgende Block ist
            // bewusst tot, damit das alte Closing intakt bleibt:
            const SizedBox.shrink(),
          ],
        );
      },
    );
  }

  String _sollModeLabel(Map emp) {
    final mode = (emp['sollMode'] ?? '').toString();
    if (mode == 'fixed_monthly') {
      final h = (emp['monthlyContractHours'] ?? 173).toString();
      return 'Fest · $h h / Monat';
    }
    if (mode == 'workday_based' || mode.isEmpty) {
      final d = (emp['dailyContractHours'] ?? 8).toString();
      return 'Berechnet · $d h / Tag';
    }
    return mode;
  }

  String _bundeslandLabel(Map emp) {
    const map = {
      'BW': 'Baden-Württemberg', 'BY': 'Bayern', 'BE': 'Berlin',
      'BB': 'Brandenburg', 'HB': 'Bremen', 'HH': 'Hamburg',
      'HE': 'Hessen', 'MV': 'Meck.-Vorpomm.', 'NI': 'Niedersachsen',
      'NW': 'Nordrhein-Westf.', 'RP': 'Rheinland-Pfalz', 'SL': 'Saarland',
      'SN': 'Sachsen', 'ST': 'Sachsen-Anhalt', 'SH': 'Schleswig-Holst.',
      'TH': 'Thüringen',
    };
    final code = (emp['bundesland'] ?? '').toString();
    if (code.isEmpty) return 'Nicht gesetzt';
    return '${map[code] ?? code} ($code)';
  }

  String _workingDaysLabel(Map emp) {
    final wd = (emp['workingDays'] as List?)
            ?.map((e) => e.toString().toUpperCase())
            .toList() ??
        const ['MO', 'TU', 'WE', 'TH', 'FR'];
    final set = wd.toSet();
    final mf = {'MO', 'TU', 'WE', 'TH', 'FR'};
    final ms = {...mf, 'SA'};
    if (set.length == mf.length && set.containsAll(mf)) {
      return '5-Tage-Woche (Mo–Fr)';
    }
    if (set.length == ms.length && set.containsAll(ms)) {
      return '6-Tage-Woche (Mo–Sa)';
    }
    const lookup = {
      'MO': 'Mo', 'TU': 'Di', 'WE': 'Mi', 'TH': 'Do',
      'FR': 'Fr', 'SA': 'Sa', 'SU': 'So',
    };
    final ordered = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU']
        .where(set.contains)
        .map((e) => lookup[e]!)
        .join(', ');
    return ordered;
  }
}

// ───────────────────────────────────────────────────────────────────────
// iOS-Style Settings Primitives
// ───────────────────────────────────────────────────────────────────────

class _iOSSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _iOSSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            title.toUpperCase(),
            style: AppTypography.caption2.copyWith(
              color: AppColors.labelSecondaryLight,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border:
                Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _iOSDivider extends StatelessWidget {
  const _iOSDivider();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.only(left: 52),
        child: Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5EA)),
      );
}

class _iOSValueRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final VoidCallback? onTap;

  const _iOSValueRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: AppTypography.subheadline.copyWith(
              color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: AppTypography.subheadline.copyWith(
                  color: AppColors.labelSecondaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: Color(0xFF9CA3AF),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _iOSSwitchRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _iOSSwitchRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.subheadline.copyWith(
              color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.caption1.copyWith(
                    color: AppColors.labelSecondaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(
            value: value,
            activeThumbColor: AppColors.codriverGreen,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _iOSStationsSection extends StatelessWidget {
  final String adminUid;
  const _iOSStationsSection({required this.adminUid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(adminUid)
          .collection('stations')
          .snapshots(),
      builder: (context, snap) {
        final docs = snap.data?.docs ?? const [];
        return _iOSSection(
          title: 'Stationen (${docs.length})',
          children: [
            for (var i = 0; i < docs.length; i++) ...[
              _iOSStationRow(adminUid: adminUid, stationDoc: docs[i]),
              if (i < docs.length - 1) const _iOSDivider(),
            ],
            if (docs.isNotEmpty) const _iOSDivider(),
            InkWell(
              onTap: () =>
                  _AddStationDialog.show(context, adminUid: adminUid),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.codriverGreen
                            .withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.add_rounded,
                        size: 20,
                        color: AppColors.codriverGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Station hinzufügen',
                      style: AppTypography.subheadline.copyWith(
                        color: AppColors.codriverGreen,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _iOSStationRow extends StatelessWidget {
  final String adminUid;
  final QueryDocumentSnapshot<Map<String, dynamic>> stationDoc;
  const _iOSStationRow({
    required this.adminUid,
    required this.stationDoc,
  });

  Future<void> _openStationDetail(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _StationCard(
              adminUid: adminUid,
              stationDoc: stationDoc,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = stationDoc.data();
    final code = stationDoc.id;
    final label = (data['label'] ?? code).toString();
    final fences = (data['geofences'] as List?) ?? const [];
    // Einheitlicher Anzeige-Name: „DBY5 Pommersfelden" (Code + Label)
    final displayName =
        (label.isEmpty || label == code) ? code : '$code $label';
    return InkWell(
      onTap: () => _openStationDetail(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.codriverGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.place_rounded,
                size: 18,
                color: AppColors.codriverGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.subheadline.copyWith(
              color: Colors.black,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              fences.isEmpty
                  ? 'Kein Geofence'
                  : '${fences.length} Geofence${fences.length == 1 ? '' : 's'}',
              style: AppTypography.caption1.copyWith(
                color: fences.isEmpty
                    ? const Color(0xFFB7791F)
                    : AppColors.labelSecondaryLight,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }
}


class _StationCard extends StatelessWidget {
  final String adminUid;
  final QueryDocumentSnapshot<Map<String, dynamic>> stationDoc;
  const _StationCard({
    required this.adminUid,
    required this.stationDoc,
  });

  @override
  Widget build(BuildContext context) {
    final data = stationDoc.data();
    final code = stationDoc.id;
    final label = (data['label'] ?? code).toString();
    final fences = (data['geofences'] as List?) ?? const [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevatedLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppElevation.level1,
        border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.codriverGreen.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.place_rounded,
                  color: Colors.black,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      code,
                      style: AppTypography.headline.copyWith(
              color: Colors.black,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      label,
                      style: AppTypography.caption1.copyWith(
                        color: AppColors.labelSecondaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (fences.isEmpty)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4E5),
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: const Color(0xFFFFB547), width: 0.6),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: Color(0xFFB7791F),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Noch kein Geofence definiert — Driver kann an '
                      'dieser Station nicht stempeln.',
                      style: AppTypography.footnote.copyWith(
                        color: const Color(0xFFB7791F),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < fences.length; i++)
                  _FenceRow(
                    index: i,
                    data: (fences[i] as Map).cast<String, dynamic>(),
                    // „DBY5 Pommersfelden" — bei mehreren Fences
                    // gleicher Station bekommt der zweite „· #2" usw.
                    displayName: label.isEmpty || label == code
                        ? (fences.length > 1
                            ? '$code · #${i + 1}'
                            : code)
                        : (fences.length > 1
                            ? '$code $label · #${i + 1}'
                            : '$code $label'),
                  ),
              ],
            ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () => _openFenceEditor(context),
              icon: const Icon(Icons.add_location_alt_outlined, size: 18),
              label: const Text('Geofence hinzufügen'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.codriverDeep,
                side: const BorderSide(
                  color: AppColors.codriverGreen,
                  width: 1.2,
                ),
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openFenceEditor(BuildContext context) async {
    final existing = List<Map<String, dynamic>>.from(
      (stationDoc.data()['geofences'] as List?) ?? const [],
    );
    final saved = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _FenceEditorDialog(
        stationCode: stationDoc.id,
        existingFences: existing,
      ),
    );
    if (saved == null) return;
    existing.add(saved);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(adminUid)
        .collection('stations')
        .doc(stationDoc.id)
        .set({'geofences': existing}, SetOptions(merge: true));
  }
}

class _FenceRow extends StatelessWidget {
  final int index;
  final Map<String, dynamic> data;
  // Anzeige-Name: kombiniert Station-Code + Label, z.B. „DBY5 Pommersfelden".
  // Bei mehreren Fences pro Station bekommt der zweite/dritte „· #2", „· #3".
  final String displayName;
  const _FenceRow({
    required this.index,
    required this.data,
    required this.displayName,
  });

  @override
  Widget build(BuildContext context) {
    final lat = (data['centerLat'] as num?)?.toDouble() ?? 0;
    final lng = (data['centerLng'] as num?)?.toDouble() ?? 0;
    final radius = (data['radiusMeters'] as num?)?.toInt() ?? 0;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.adjust_rounded,
            size: 18,
            color: AppColors.codriverGreen,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: AppTypography.subheadline.copyWith(
              color: Colors.black,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)} · '
                  'r=${radius}m',
                  style: AppTypography.caption1.copyWith(
                    color: AppColors.labelSecondaryLight,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
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

class _FenceEditorDialog extends StatefulWidget {
  final String stationCode;
  final List<Map<String, dynamic>> existingFences;
  const _FenceEditorDialog({
    required this.stationCode,
    required this.existingFences,
  });

  @override
  State<_FenceEditorDialog> createState() => _FenceEditorDialogState();
}

class _FenceEditorDialogState extends State<_FenceEditorDialog> {
  final _radiusCtrl = TextEditingController(text: '200');
  final _addressCtrl = TextEditingController();
  final _mapController = MapController();
  bool _fetchingLocation = false;
  bool _searchingAddress = false;
  // Default-Center: Frankfurt (zentrales DE) — wird sofort von "Aktueller
  // Standort", Adress-Suche oder Map-Tap überschrieben.
  LatLng _center = const LatLng(50.110924, 8.682127);
  bool _hasCenter = false;
  double _radius = 200;
  String? _resolvedAddress;

  /// Generiert eine Auto-ID basierend auf existierenden Fences:
  /// `STATION_main` für die erste, danach `STATION_2`, `STATION_3`, …
  String _autoId() {
    final used = widget.existingFences
        .map((f) => (f['id'] ?? '').toString())
        .toSet();
    final base = widget.stationCode;
    if (!used.contains('${base}_main')) return '${base}_main';
    for (var i = 2; i < 100; i++) {
      final candidate = '${base}_$i';
      if (!used.contains(candidate)) return candidate;
    }
    return '${base}_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  void initState() {
    super.initState();
    // Position direkt beim Öffnen abfragen, damit die Map sich auf den
    // Admin-Standort zentriert.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _useCurrentLocation();
    });
  }

  @override
  void dispose() {
    _radiusCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  /// Adress-Suche via OpenStreetMap Nominatim (frei, kein API-Key).
  /// Setzt bei Treffer den Map-Mittelpunkt + zoomt auf Hub-Detail-Level.
  Future<void> _searchAddress() async {
    final query = _addressCtrl.text.trim();
    if (query.isEmpty || _searchingAddress) return;
    setState(() => _searchingAddress = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?q=${Uri.encodeQueryComponent(query)}'
        '&format=json&limit=1&accept-language=de&countrycodes=de,at,ch',
      );
      final resp = await http.get(
        url,
        headers: const {
          'User-Agent': 'CoDriver-co-timer/1.0 (kontakt@codriver-app.com)',
        },
      ).timeout(const Duration(seconds: 8));
      if (resp.statusCode != 200) {
        throw Exception('Nominatim HTTP ${resp.statusCode}');
      }
      final list = jsonDecode(resp.body) as List;
      if (list.isEmpty) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Adresse nicht gefunden')),
        );
        return;
      }
      final hit = list.first as Map<String, dynamic>;
      final lat = double.tryParse(hit['lat']?.toString() ?? '');
      final lon = double.tryParse(hit['lon']?.toString() ?? '');
      if (lat == null || lon == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Ungültiges Suchergebnis')),
        );
        return;
      }
      if (!mounted) return;
      setState(() {
        _center = LatLng(lat, lon);
        _hasCenter = true;
        _resolvedAddress = (hit['display_name'] ?? '').toString();
      });
      _mapController.move(_center, 17);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Suche fehlgeschlagen: $e')),
      );
    } finally {
      if (mounted) setState(() => _searchingAddress = false);
    }
  }

  Future<void> _useCurrentLocation() async {
    if (_fetchingLocation) return;
    setState(() => _fetchingLocation = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        messenger.showSnackBar(
          const SnackBar(
              content: Text('Standort-Berechtigung verweigert')),
        );
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );
      if (!mounted) return;
      setState(() {
        _center = LatLng(pos.latitude, pos.longitude);
        _hasCenter = true;
      });
      _mapController.move(_center, 17);
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text('Standort konnte nicht ermittelt werden: $e'),
      ));
    } finally {
      if (mounted) setState(() => _fetchingLocation = false);
    }
  }

  void _onMapTap(TapPosition _, LatLng pos) {
    setState(() {
      _center = pos;
      _hasCenter = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaW = MediaQuery.of(context).size.width;
    final mediaH = MediaQuery.of(context).size.height;
    final dialogW = mediaW < 700 ? mediaW - 24 : 640.0;
    final dialogH = mediaH < 720 ? mediaH - 40 : 680.0;
    return Dialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: dialogW, maxHeight: dialogH),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Neuer Geofence',
                style: AppTypography.title3.copyWith(
              color: Colors.black,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Suche per Adresse, nutze GPS oder tippe auf die Karte. '
                'Fahrer können nur innerhalb des Radius einstempeln.',
                style: AppTypography.footnote.copyWith(
                  color: AppColors.labelSecondaryLight,
                ),
              ),
              const SizedBox(height: 14),
              // ── Adress-Suche ──────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _addressCtrl,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _searchAddress(),
                      decoration: InputDecoration(
                        hintText: 'Adresse, z.B. Bahnhofstr. 1, Bonn',
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: Color(0xFF6B7280),
                          size: 20,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFFE5E5EA), width: 0.6),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFFE5E5EA), width: 0.6),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.codriverGreen
                                .withValues(alpha: 0.8),
                            width: 1.2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _searchingAddress ? null : _searchAddress,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.codriverGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    child: _searchingAddress
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(
                                  Colors.white),
                            ),
                          )
                        : const Text('Suchen'),
                  ),
                ],
              ),
              if (_resolvedAddress != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 14,
                      color: AppColors.codriverGreen,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _resolvedAddress!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption1.copyWith(
                          color: AppColors.labelSecondaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              // ── Map ────────────────────────────────────────────────
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _center,
                          initialZoom: 14,
                          onTap: _onMapTap,
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.all &
                                ~InteractiveFlag.rotate,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'de.codriver.kpi_admin',
                          ),
                          if (_hasCenter)
                            CircleLayer(
                              circles: [
                                CircleMarker(
                                  point: _center,
                                  radius: _radius,
                                  useRadiusInMeter: true,
                                  color: AppColors.codriverGreen
                                      .withValues(alpha: 0.22),
                                  borderColor: AppColors.codriverGreen,
                                  borderStrokeWidth: 2,
                                ),
                              ],
                            ),
                          if (_hasCenter)
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: _center,
                                  width: 36,
                                  height: 36,
                                  child: const Icon(
                                    Icons.place_rounded,
                                    color: Colors.black,
                                    size: 36,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Material(
                          color: Colors.white,
                          shape: const CircleBorder(),
                          elevation: 3,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: _fetchingLocation
                                ? null
                                : _useCurrentLocation,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: _fetchingLocation
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Icon(
                                      Icons.my_location_rounded,
                                      size: 20,
                                      color: Colors.black,
                                    ),
                            ),
                          ),
                        ),
                      ),
                      if (!_hasCenter)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 12,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.92),
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x1A000000),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                'Adresse suchen, GPS nutzen oder Karte antippen',
                                style: AppTypography.footnote.copyWith(
              color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // ── Radius-Slider ─────────────────────────────────────
              Row(
                children: [
                  Text(
                    'Radius',
                    style: AppTypography.subheadline.copyWith(
              color: Colors.black,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_radius.round()} m',
                    style: AppTypography.subheadline.copyWith(
                      color: AppColors.codriverGreen,
                      fontWeight: FontWeight.w800,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
              Slider(
                value: _radius,
                min: 50,
                max: 1000,
                divisions: 19,
                activeColor: AppColors.codriverGreen,
                label: '${_radius.round()} m',
                onChanged: (v) {
                  setState(() => _radius = v);
                  _radiusCtrl.text = v.round().toString();
                },
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Abbrechen'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.codriverGreen,
                      shape: const StadiumBorder(),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 18),
                    ),
                    onPressed: _hasCenter
                        ? () {
                            Navigator.of(context).pop({
                              'id': _autoId(),
                              'centerLat': _center.latitude,
                              'centerLng': _center.longitude,
                              'radiusMeters': _radius.round(),
                            });
                          }
                        : null,
                    child: const Text('Speichern'),
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

// ════════════════════════════════════════════════════════════════════
//  Shared
// ════════════════════════════════════════════════════════════════════

class _EmptyTabState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _EmptyTabState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevatedLight,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppElevation.level1,
          border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.codriverGreen.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: Colors.black, size: 26),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.title3.copyWith(
              color: Colors.black,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTypography.subheadline.copyWith(
                color: AppColors.labelSecondaryLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Setup-Gate — versperrt den Zugriff auf Live/Zeitkonto/Korrekturen/
/// Compliance bis die Pflicht-Konfiguration steht. Zeigt eine Checkliste
/// mit den fehlenden Schritten + direkten Aktions-Buttons; sobald alle
/// Bedingungen erfüllt sind ersetzt sich das Gate automatisch durch die
/// normale Tab-Navigation.
class _SetupGate extends StatelessWidget {
  final String adminUid;
  final bool hasContract;
  final bool hasStation;
  final int stationCount;
  final bool addonEnabled;

  const _SetupGate({
    required this.adminUid,
    required this.hasContract,
    required this.hasStation,
    required this.stationCount,
    required this.addonEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          decoration: BoxDecoration(
            color: AppColors.green50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.codriverGreen.withValues(alpha: 0.32),
              width: 0.6,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.codriverGreen,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.timer_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'co:timer einrichten',
                          style: AppTypography.title3.copyWith(
              color: Colors.black,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Zwei Schritte bevor du loslegen kannst.',
                          style: AppTypography.footnote.copyWith(
              color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _AddonToggleCard(
                adminUid: adminUid,
                enabled: addonEnabled,
              ),
              const SizedBox(height: 12),
              _SetupStep(
                done: hasContract,
                stepNumber: 1,
                title: 'Vertragseinstellungen',
                subtitle: hasContract
                    ? 'Bundesland und Soll-Modus sind gesetzt.'
                    : 'Wochenstunden bzw. Monatsstunden + Bundesland '
                        'für die Feiertage festlegen.',
                actionLabel: hasContract
                    ? 'Bearbeiten'
                    : 'Jetzt einrichten',
                onTap: () => EmploymentEditDialog.show(
                  context,
                  adminUid: adminUid,
                ),
              ),
              const SizedBox(height: 12),
              _SetupStep(
                done: hasStation,
                stepNumber: 2,
                title: 'Station mit Geofence',
                subtitle: !hasContract
                    ? 'Erst Vertrag einrichten, dann eine Station anlegen.'
                    : hasStation
                        ? 'Mindestens eine Station hat einen Geofence.'
                        : stationCount == 0
                            ? 'Lege eine Station an und setze auf der '
                                'Karte den Hub-Mittelpunkt.'
                            : '$stationCount Station${stationCount == 1 ? '' : 'en'} '
                                'vorhanden — Geofence fehlt noch. '
                                'Tippe in der Station-Karte auf '
                                '„Geofence hinzufügen".',
                actionLabel: stationCount == 0
                    ? 'Station anlegen'
                    : 'Geofence hinzufügen',
                onTap: !hasContract
                    ? null
                    : stationCount == 0
                        ? () => _AddStationDialog.show(
                              context,
                              adminUid: adminUid,
                            )
                        : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        // Bestehende Stationen — direkt editierbar (Geofence hinzufügen)
        if (stationCount > 0) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'STATIONEN',
              style: AppTypography.caption2.copyWith(
                color: AppColors.labelSecondaryLight,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(adminUid)
                .collection('stations')
                .snapshots(),
            builder: (context, snap) {
              final docs = snap.data?.docs ?? const [];
              return Column(
                children: [
                  for (final d in docs) ...[
                    _StationCard(adminUid: adminUid, stationDoc: d),
                    const SizedBox(height: 10),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          if (hasContract)
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () => _AddStationDialog.show(
                  context,
                  adminUid: adminUid,
                ),
                icon: const Icon(Icons.add_location_alt_outlined, size: 18),
                label: const Text('Weitere Station'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.codriverDeep,
                  side: BorderSide(
                    color: AppColors.codriverGreen.withValues(alpha: 0.5),
                  ),
                  shape: const StadiumBorder(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

/// Toggle der `users/{adminUid}.addons.timeTracking` Flag. Wenn aktiv,
/// sehen ALLE Fahrer dieses DSP-Admins das co:timer Tile in ihrer
/// Driver-App — sonst niemand (außer der Legacy-Email-Whitelist).
class _AddonToggleCard extends StatelessWidget {
  final String adminUid;
  final bool enabled;

  const _AddonToggleCard({
    required this.adminUid,
    required this.enabled,
  });

  Future<void> _setEnabled(BuildContext context, bool value) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(adminUid)
          .set({
        'addons': {'timeTracking': value},
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      messenger.showSnackBar(SnackBar(
        content: Text(value
            ? 'co:timer für alle Fahrer freigeschaltet.'
            : 'co:timer deaktiviert — keine Fahrer sehen mehr das Tile.'),
      ));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Fehler: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: enabled
              ? AppColors.codriverGreen.withValues(alpha: 0.6)
              : const Color(0xFFE5E5EA),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Icon(
            enabled
                ? Icons.toggle_on_rounded
                : Icons.toggle_off_outlined,
            size: 28,
            color: enabled
                ? AppColors.codriverGreen
                : AppColors.labelSecondaryLight,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Freischaltung für alle Fahrer',
                  style: AppTypography.subheadline.copyWith(
              color: Colors.black,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  enabled
                      ? 'Alle deine Fahrer sehen das co:timer-Tile.'
                      : 'Nur du siehst co:timer — Fahrer noch nicht.',
                  style: AppTypography.caption1.copyWith(
                    color: AppColors.labelSecondaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: enabled,
            activeThumbColor: AppColors.codriverGreen,
            onChanged: (v) => _setEnabled(context, v),
          ),
        ],
      ),
    );
  }
}

class _SetupStep extends StatelessWidget {
  final bool done;
  final int stepNumber;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback? onTap;

  const _SetupStep({
    required this.done,
    required this.stepNumber,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: done
              ? AppColors.codriverGreen.withValues(alpha: 0.5)
              : const Color(0xFFE5E5EA),
          width: 0.6,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: done
                  ? AppColors.codriverGreen
                  : const Color(0xFFF2F2F7),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: done
                ? const Icon(Icons.check_rounded,
                    color: Colors.white, size: 18)
                : Text(
                    '$stepNumber',
                    style: AppTypography.subheadline.copyWith(
                      color: AppColors.labelSecondaryLight,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.subheadline.copyWith(
              color: Colors.black,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.caption1.copyWith(
                    color: AppColors.labelSecondaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (onTap != null)
            FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: done
                    ? Colors.white
                    : AppColors.codriverGreen,
                foregroundColor: done
                    ? AppColors.codriverDeep
                    : Colors.white,
                side: done
                    ? const BorderSide(
                        color: Color(0xFFE5E5EA),
                        width: 0.6,
                      )
                    : null,
                shape: const StadiumBorder(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                textStyle: AppTypography.footnote.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              child: Text(actionLabel),
            ),
        ],
      ),
    );
  }
}

/// Dialog zum manuellen Anlegen einer Station — alternativer Weg, falls
/// noch keine Scorecard hochgeladen wurde aus deren Header die Station
/// abgeleitet wird. Schreibt nach `users/{adminUid}/stations/{code}`.
class _AddStationDialog extends StatefulWidget {
  final String adminUid;
  const _AddStationDialog({required this.adminUid});

  static Future<void> show(BuildContext context,
      {required String adminUid}) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _AddStationDialog(adminUid: adminUid),
    );
  }

  @override
  State<_AddStationDialog> createState() => _AddStationDialogState();
}

class _AddStationDialogState extends State<_AddStationDialog> {
  final _codeCtrl = TextEditingController();
  final _labelCtrl = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _codeCtrl.dispose();
    _labelCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final code = _codeCtrl.text.trim().toUpperCase();
    final label = _labelCtrl.text.trim();
    if (code.isEmpty) {
      setState(() => _error = 'Station-Code ist Pflicht (z.B. DBN1)');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      // Bundesland nicht mehr per Station — die Firmen-Adresse aus
      // `cotimerEmployment.bundesland` bestimmt die Feiertage zentral.
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.adminUid)
          .collection('stations')
          .doc(code)
          .set({
        'label': label.isEmpty ? code : label,
        'timezone': 'Europe/Berlin',
        'geofences': <Map<String, dynamic>>[],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Station $code angelegt — jetzt Geofence eintragen'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = '$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Station anlegen',
                  style: AppTypography.title3
                      .copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(
                'Trage den Amazon-Station-Code ein (z.B. DBN1). Geofence (Lat/Lng/Radius) kannst du danach in der Station-Karte hinzufügen.',
                style: AppTypography.footnote
                    .copyWith(color: AppColors.labelSecondaryLight),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _codeCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Station-Code',
                  hintText: 'z.B. DBN1',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _labelCtrl,
                decoration: const InputDecoration(
                  labelText: 'Anzeigename (optional)',
                  hintText: 'z.B. Bonn-Süd',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Bundesland für Feiertage wird zentral in den '
                        'Vertragseinstellungen festgelegt — gilt für '
                        'alle Stationen.',
                        style: AppTypography.caption1.copyWith(
                          color: const Color(0xFF6B7280),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      color: Color(0xFFB91C1C),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _saving ? null : () => Navigator.of(context).pop(),
                    child: const Text('Abbrechen'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Anlegen'),
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

