// lib/Screens/driver_cotimer_clock_page.dart
//
// co:timer Driver-Stempelpage.
//
// Wichtig — diese Seite ist absichtlich NICHT in die Driver-Bottom-Tab-
// Navigation eingebunden. Sie liegt als Codebase-Page bereit, um sie
// per Direkt-Route oder Internal-Test zu öffnen. Live-Rollout für
// Driver passiert separat.
//
// UX:
//   • Header mit Status (eingestempelt seit … / nicht eingestempelt)
//   • Live-Timer (HH:MM:SS) wenn Schicht läuft
//   • Apple-style **Swipe-to-Start / Swipe-to-Stop** Button
//   • Pause-Toggle (klein) unten
//   • Standort-Status-Card (GPS aktiv, am Hub ja/nein)
//
// Cloud-Function-Calls über `TimeTrackingService`. Standort via
// `geolocator`. Live-Schichtdaten aus der `time-tracking`-DB.

import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

import '../services/time_tracking_firestore.dart';
import '../services/time_tracking_service.dart';
import 'driver_cotimer_account_page.dart';
import '../theme/app_colors.dart';
import '../theme/app_elevation.dart';
import '../theme/app_typography.dart';

/// Resolver-Wrapper für die Driver-Stempel-Seite. Nimmt nur adminUid +
/// driverId und ermittelt automatisch die erste Station des DSP mit
/// definiertem Geofence. Wird vom Driver-Home aufgerufen.
class DriverCotimerLauncher extends StatelessWidget {
  final String adminUid;
  final String driverId;
  const DriverCotimerLauncher({
    super.key,
    required this.adminUid,
    required this.driverId,
  });

  @override
  Widget build(BuildContext context) {
    final stationsStream = FirebaseFirestore.instance
        .collection('users')
        .doc(adminUid)
        .collection('stations')
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stationsStream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final stations = snap.data?.docs ?? const [];
        // Erste Station mit mindestens einem Geofence
        final withFence = stations.where((d) {
          final fences = (d.data()['geofences'] as List?) ?? const [];
          return fences.isNotEmpty;
        }).toList();

        if (withFence.isEmpty) {
          final stationsCount = stations.length;
          return _CotimerNotReadyView(
            adminUid: adminUid,
            driverId: driverId,
            stationsCount: stationsCount,
          );
        }

        // Multi-Station: der Server wählt beim clockIn automatisch die
        // Station, deren Geofence den GPS-Punkt einschließt. Der Launcher
        // muss keine Station mehr vorab festlegen. Wir zeigen einfach
        // die Liste aller verfügbaren Hubs zur Info.
        final stationLabels = withFence
            .map((d) =>
                ((d.data()['label'] ?? d.id) as String).toString())
            .toList();
        return DriverCotimerClockPage(
          adminUid: adminUid,
          driverId: driverId,
          availableStations: stationLabels,
        );
      },
    );
  }
}

class DriverCotimerClockPage extends StatefulWidget {
  final String adminUid;
  final String driverId;
  // Liste der verfügbaren Hub-Labels — rein informativ; der Server wählt
  // anhand des GPS-Standorts die richtige Station automatisch.
  final List<String> availableStations;

  const DriverCotimerClockPage({
    super.key,
    required this.adminUid,
    required this.driverId,
    this.availableStations = const [],
  });

  @override
  State<DriverCotimerClockPage> createState() => _DriverCotimerClockPageState();
}

class _DriverCotimerClockPageState extends State<DriverCotimerClockPage>
    with SingleTickerProviderStateMixin {
  Position? _position;
  String? _locationError;
  bool _busy = false;
  Timer? _ticker;
  late final AnimationController _cardBorderRot;

  @override
  void initState() {
    super.initState();
    _refreshPosition();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    // Rotierender Rahmen-Schein wenn eine Schicht läuft. Eine Umdrehung
    // alle 14 s — sehr langsamer Atem-Rhythmus, lebt im Hintergrund mit
    // ohne abzulenken.
    _cardBorderRot = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 14000),
    )..repeat();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _cardBorderRot.dispose();
    super.dispose();
  }

  Future<void> _refreshPosition() async {
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        setState(() => _locationError = 'Standort-Berechtigung verweigert');
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
        _position = pos;
        _locationError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _locationError = '$e');
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _openShiftStream() {
    return TimeTrackingFirestore.shifts(
      adminUid: widget.adminUid,
      driverId: widget.driverId,
    )
        .where('isOpen', isEqualTo: true)
        .limit(1)
        .snapshots();
  }

  Future<void> _clockIn() async {
    if (_position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Standort wird noch ermittelt')),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await TimeTrackingService.instance.clockIn(
        qrToken: '',
        lat: _position!.latitude,
        lng: _position!.longitude,
        accuracy: _position!.accuracy,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Stempel-Fehler: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _clockOut() async {
    if (_position == null) return;
    setState(() => _busy = true);
    try {
      await TimeTrackingService.instance.clockOut(
        lat: _position!.latitude,
        lng: _position!.longitude,
        accuracy: _position!.accuracy,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Stempel-Fehler: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _togglePause() async {
    setState(() => _busy = true);
    try {
      await TimeTrackingService.instance.togglePause();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pause-Fehler: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _formatDuration(int seconds) {
    final h = (seconds ~/ 3600).toString().padLeft(2, '0');
    final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F7),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _openShiftStream(),
          builder: (context, snap) {
            final hasOpen = (snap.data?.docs ?? const []).isNotEmpty;
            final shift = hasOpen ? snap.data!.docs.first.data() : null;
            final startTs = (shift?['startTs'] as Timestamp?)?.toDate();
            final pauses = (shift?['pauses'] as List?) ?? const [];
            final inPause = pauses.isNotEmpty &&
                (pauses.last as Map)['end'] == null;

            final liveSeconds = startTs == null
                ? 0
                : DateTime.now().difference(startTs).inSeconds;

            int currentPauseSeconds = 0;
            int totalPauseSeconds = 0;
            for (var i = 0; i < pauses.length; i++) {
              final p = pauses[i] as Map;
              final pStart = (p['start'] as Timestamp?)?.toDate();
              final pEnd = (p['end'] as Timestamp?)?.toDate();
              if (pEnd != null && pStart != null) {
                totalPauseSeconds += pEnd.difference(pStart).inSeconds;
              } else if (pStart != null && i == pauses.length - 1) {
                currentPauseSeconds =
                    DateTime.now().difference(pStart).inSeconds;
                totalPauseSeconds += currentPauseSeconds;
              }
            }
            final workSeconds =
                (liveSeconds - totalPauseSeconds).clamp(0, 1 << 31);

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 18),
                  _buildWeekStrip(),
                  const SizedBox(height: 16),
                  _buildClockCard(
                    hasOpen: hasOpen,
                    inPause: inPause,
                    workSeconds: workSeconds,
                    totalPauseSeconds: totalPauseSeconds,
                    currentPauseSeconds: currentPauseSeconds,
                    startTs: startTs,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _SecondaryActionTile(
                          icon: Icons.account_balance_wallet_outlined,
                          label: 'Zeitkonto',
                          onTap: _openTimeAccount,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SecondaryActionTile(
                          icon: Icons.edit_note_rounded,
                          label: 'Korrektur',
                          onTap: _openCorrectionRequest,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Wochen-Strip (Mo–So) ─────────────────────────────────────────────
  Widget _buildWeekStrip() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    const wd = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
      ),
      child: Row(
        children: [
          for (var i = 0; i < 7; i++)
            Expanded(
              // Stagger fade-in: jede Tageskarte erscheint mit 40 ms
              // Versatz zur vorherigen. Gibt dem Auge eine Lesepfad-
              // Richtung (links → rechts). Cumulative 7 × 40 = 280 ms.
              child: _StaggeredFadeIn(
                delay: Duration(milliseconds: 40 * i),
                child: _buildDayCard(
                  weekday: wd[i],
                  date: monday.add(Duration(days: i)),
                  isToday: monday.add(Duration(days: i)).day == now.day &&
                      monday.add(Duration(days: i)).month == now.month,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDayCard({
    required String weekday,
    required DateTime date,
    required bool isToday,
  }) {
    final dd = date.day.toString().padLeft(2, '0');
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isToday ? AppColors.codriverGreen : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            weekday,
            style: AppTypography.caption2.copyWith(
              color: isToday ? Colors.white : const Color(0xFF6B7280),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dd,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 17,
              color: isToday ? Colors.white : Colors.black,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  // ── Stempel-Karte (zentrales UI-Element) ─────────────────────────────
  Widget _buildClockCard({
    required bool hasOpen,
    required bool inPause,
    required int workSeconds,
    required int totalPauseSeconds,
    required int currentPauseSeconds,
    required DateTime? startTs,
  }) {
    final paidH = workSeconds / 3600;
    final waitingForGps = _position == null && !hasOpen;

    final card = Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: hasOpen
            ? null
            : Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
        boxShadow: AppElevation.level1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top-Row: Status-Pill links, „HEUTE" rechts
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _statusPill(
                hasOpen: hasOpen,
                inPause: inPause,
                waitingForGps: waitingForGps,
              ),
              const Spacer(),
              Text(
                'HEUTE',
                style: AppTypography.caption2.copyWith(
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Ein dominanter Timer — was im aktuellen Status zählt (Arbeit
          // oder Pause). Daneben rechts die jeweils andere Größe als
          // kleines Sekundär-Detail.
          _buildMainTimer(
            hasOpen: hasOpen,
            inPause: inPause,
            workSeconds: workSeconds,
            totalPauseSeconds: totalPauseSeconds,
            currentPauseSeconds: currentPauseSeconds,
          ),
          const SizedBox(height: 18),
          // Bezahlte-Arbeitszeit-Card (grün getintet)
          _buildPaidWorkRow(paidH: paidH),
          const SizedBox(height: 16),
          // Primary-Action: Idle ↔ Active mit Crossfade+Scale-Morph.
          // Emil-Kowalski-Pattern: state morphs via AnimatedSwitcher mit
          // 200 ms duration, ease-in/out, opacity + slight scale (0.96)
          // — liest sich für das Auge als „content morphed in place",
          // nicht als „zwei screens swapped".
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, anim) {
              return FadeTransition(
                opacity: anim,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.96, end: 1.0).animate(anim),
                  child: child,
                ),
              );
            },
            child: !hasOpen
                ? SizedBox(
                    key: const ValueKey('idle-swipe'),
                    height: 56,
                    child: _SwipeAction(
                      label: _busy
                          ? 'WIRD GESTEMPELT …'
                          : waitingForGps
                              ? 'STANDORT WIRD GESUCHT …'
                              : 'SWIPE ZUM EINSTEMPELN',
                      color: waitingForGps
                          ? const Color(0xFF9CA3AF)
                          : AppColors.codriverGreen,
                      icon: Icons.chevron_right_rounded,
                      enabled: !_busy && !waitingForGps,
                      onCompleted: _clockIn,
                    ),
                  )
                : Column(
                    key: const ValueKey('active-actions'),
                    children: [
                      SizedBox(
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: _busy ? null : _togglePause,
                          icon: Icon(
                            inPause
                                ? Icons.play_arrow_rounded
                                : Icons.pause_rounded,
                          ),
                          label: Text(
                            inPause ? 'Pause beenden' : 'Pause starten',
                            style: AppTypography.subheadline.copyWith(
                              color: const Color(0xFF1C1C1E),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                            side: const BorderSide(
                                color: Color(0xFFE5E5EA), width: 0.6),
                            shape: const StadiumBorder(),
                            backgroundColor: const Color(0xFFF9FAFB),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 56,
                        child: _SwipeAction(
                          label: 'SWIPE ZUM AUSSTEMPELN',
                          color: const Color(0xFFF97316),
                          icon: Icons.chevron_right_rounded,
                          enabled: !_busy,
                          onCompleted: _clockOut,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );

    if (!hasOpen) return card;
    // Rotierender Conic-Schein um die Karte — nur wenn eingestempelt.
    // SweepGradient + Rotation, in einem ClipPath mit Padding sodass
    // nur ein dünner Ring sichtbar ist.
    return AnimatedBuilder(
      animation: _cardBorderRot,
      builder: (ctx, _) {
        final angle = _cardBorderRot.value * 2 * math.pi;
        // Bei Pause wechselt der Glow auf Blau — visuell klarer
        // Unterschied zu „aktiv arbeiten" (grün) und „ausstempeln"
        // (orange im Swipe-Button).
        final accent = inPause
            ? const Color(0xFF3B82F6)
            : AppColors.codriverGreen;
        return Container(
          // Dünnerer Rahmen — 3 px statt 6 px. Wirkt feiner und
          // technischer.
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: SweepGradient(
              transform: GradientRotation(angle),
              // Längere Striche: jeder Lichtbogen breitet sich über
              // ~25 % des Kreis-Umfangs aus (vorher ~10 %). Niedrigere
              // Peak-Alpha (0.55 statt 0.85) macht den Ring softer und
              // durchsichtiger — eher Glow als feste Linie.
              colors: [
                accent.withValues(alpha: 0.0),
                accent.withValues(alpha: 0.0),
                accent.withValues(alpha: 0.28),
                accent.withValues(alpha: 0.28),
                accent.withValues(alpha: 0.0),
                accent.withValues(alpha: 0.0),
                accent.withValues(alpha: 0.28),
                accent.withValues(alpha: 0.28),
                accent.withValues(alpha: 0.0),
                accent.withValues(alpha: 0.0),
              ],
              stops: const [
                0.0, 0.12,        // Auslauf erste Lücke
                0.22, 0.36,       // erster Lichtbogen (14 % breit)
                0.46, 0.54,       // zweite Lücke (8 %)
                0.64, 0.78,       // zweiter Lichtbogen
                0.88, 1.0,        // letzte Lücke
              ],
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: card,
          ),
        );
      },
    );
  }

  Widget _statusPill({
    required bool hasOpen,
    required bool inPause,
    required bool waitingForGps,
  }) {
    final (label, dotColor, bg) = waitingForGps
        ? ('Standort wird gesucht', const Color(0xFF9CA3AF),
            const Color(0xFFF3F6F7))
        : !hasOpen
            ? ('Nicht eingestempelt', const Color(0xFF9CA3AF),
                const Color(0xFFF3F6F7))
            : inPause
                ? ('In Pause', const Color(0xFFB7791F),
                    const Color(0xFFFFF4E5))
                : ('Eingestempelt', AppColors.codriverGreen,
                    AppColors.codriverGreen.withValues(alpha: 0.12));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTypography.footnote.copyWith(
              color: const Color(0xFF1C1C1E),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  /// Splits in [HH, MM, SS] strings, each zero-padded.
  List<String> _hmsSplit(int seconds) {
    final v = seconds < 0 ? 0 : seconds;
    final h = (v ~/ 3600).toString().padLeft(2, '0');
    final m = ((v % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (v % 60).toString().padLeft(2, '0');
    return [h, m, s];
  }

  /// Großer zentraler Timer + kleiner Pause/Arbeit-Sekundärwert daneben.
  /// Im Idle-Zustand zeigt der Hauptwert die Arbeitszeit (00:00).
  Widget _buildMainTimer({
    required bool hasOpen,
    required bool inPause,
    required int workSeconds,
    required int totalPauseSeconds,
    required int currentPauseSeconds,
  }) {
    final showingPause = hasOpen && inPause;
    final primarySeconds = showingPause ? currentPauseSeconds : workSeconds;
    final primaryLabel = showingPause ? 'Pause läuft' : 'Arbeitszeit';
    final secondarySeconds =
        showingPause ? workSeconds : totalPauseSeconds;
    final secondaryLabel = showingPause ? 'Arbeit' : 'Pause';

    final primaryHms = _hmsSplit(primarySeconds);
    final secondaryHms = _hmsSplit(secondarySeconds);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hauptwert — passt sich der Breite an via FittedBox
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${primaryHms[0]}:${primaryHms[1]}',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 64,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1C1C1E),
                  letterSpacing: -1.4,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Text(
                  ':${primaryHms[2]}',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF6B7280),
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          primaryLabel,
          style: AppTypography.footnote.copyWith(
            color: const Color(0xFF6B7280),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        // Sekundärwert als kompakte Inline-Info — eine Zeile, klar lesbar.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F6F7),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$secondaryLabel ',
                style: AppTypography.caption1.copyWith(
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${secondaryHms[0]}:${secondaryHms[1]}:${secondaryHms[2]}',
                style: AppTypography.caption1.copyWith(
                  color: const Color(0xFF1C1C1E),
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaidWorkRow({required double paidH}) {
    final hms = _hmsSplit((paidH * 3600).round());
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.codriverGreen.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.codriverGreen.withValues(alpha: 0.3),
          width: 0.6,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.codriverGreen.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.payments_rounded,
              size: 18,
              color: AppColors.codriverGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Bezahlte Arbeitszeit',
                  style: AppTypography.subheadline.copyWith(
                    color: const Color(0xFF1C1C1E),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Arbeitszeit – Pausenzeit',
                  style: AppTypography.caption1.copyWith(
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${hms[0]}:${hms[1]}',
            style: AppTypography.title3.copyWith(
              color: const Color(0xFF1C1C1E),
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openTimeAccount() async {
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => DriverTimeAccountPage(
        adminUid: widget.adminUid,
        driverId: widget.driverId,
      ),
    ));
  }

  Future<void> _openCorrectionRequest() async {
    final saved = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _CorrectionRequestDialog(),
    );
    if (saved == null) return;
    try {
      await TimeTrackingFirestore.correctionRequests(
        adminUid: widget.adminUid,
        driverId: widget.driverId,
      ).add({
        'adminUid': widget.adminUid,
        'driverId': widget.driverId,
        'type': saved['type'],
        'shiftDate': saved['shiftDate'],
        'requestedChanges': saved['requestedChanges'],
        'reason': saved['reason'],
        'status': 'pending',
        'submittedAt': Timestamp.now(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Korrektur-Antrag verschickt')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler: $e')),
      );
    }
  }

  static String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Widget _buildHeader() {
    return Row(
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'co',
                style: AppTypography.title1.copyWith(
                  color: const Color(0xFF1C1C1E),
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                ),
              ),
              TextSpan(
                text: ':',
                style: AppTypography.title1.copyWith(
                  color: AppColors.codriverGreen,
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextSpan(
                text: 'timer',
                style: AppTypography.title1.copyWith(
                  color: const Color(0xFF1C1C1E),
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        if (widget.availableStations.isNotEmpty)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F6F7),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              widget.availableStations.length == 1
                  ? widget.availableStations.first
                  : '${widget.availableStations.length} Hubs',
              style: AppTypography.caption2.copyWith(
              color: const Color(0xFF1C1C1E),
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  Correction-Request Dialog (Driver)
// ════════════════════════════════════════════════════════════════════

class _CorrectionRequestDialog extends StatefulWidget {
  @override
  State<_CorrectionRequestDialog> createState() =>
      _CorrectionRequestDialogState();
}

class _CorrectionRequestDialogState extends State<_CorrectionRequestDialog> {
  DateTime _date = DateTime.now();
  TimeOfDay _start = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 17, minute: 0);
  int _pauseMinutes = 30;
  String _type = 'missing_entry';
  final _reasonCtrl = TextEditingController();

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  String _ymd(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '$y-$m-$dd';
  }

  String _hm(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _start : _end,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _start = picked;
        } else {
          _end = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFF3F6F7),
      surfaceTintColor: const Color(0xFFF3F6F7),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Korrektur anfragen',
                style: AppTypography.title3.copyWith(
                  color: const Color(0xFF1C1C1E),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Dein Admin entscheidet, ob die Korrektur übernommen wird.',
                style: AppTypography.footnote.copyWith(
                  color: const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 16),
              // Type
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _typeChip('missing_entry', 'Stempel vergessen'),
                  _typeChip('wrong_time', 'Falsche Zeit'),
                  _typeChip('forgot_pause', 'Pause nicht erfasst'),
                  _typeChip('other', 'Sonstige'),
                ],
              ),
              const SizedBox(height: 14),
              _PickField(
                label: 'Datum',
                value: _ymd(_date),
                icon: Icons.calendar_today_rounded,
                onTap: _pickDate,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _PickField(
                      label: 'Start',
                      value: _hm(_start),
                      icon: Icons.play_arrow_rounded,
                      onTap: () => _pickTime(true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _PickField(
                      label: 'Ende',
                      value: _hm(_end),
                      icon: Icons.stop_rounded,
                      onTap: () => _pickTime(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.pause_rounded,
                    size: 18,
                    color: AppColors.labelSecondaryLight,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Pause: ',
                    style: AppTypography.subheadline.copyWith(
              color: const Color(0xFF1C1C1E),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: _pauseMinutes.toDouble(),
                      min: 0,
                      max: 90,
                      divisions: 18,
                      label: '$_pauseMinutes min',
                      activeColor: AppColors.codriverGreen,
                      onChanged: (v) =>
                          setState(() => _pauseMinutes = v.round()),
                    ),
                  ),
                  SizedBox(
                    width: 56,
                    child: Text(
                      '$_pauseMinutes min',
                      textAlign: TextAlign.end,
                      style: AppTypography.subheadline.copyWith(
              color: const Color(0xFF1C1C1E),
                        fontWeight: FontWeight.w800,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _reasonCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Begründung',
                  hintText: 'Was ist passiert?',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 18),
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
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                    ),
                    onPressed: () {
                      // Build shiftDate + ts pair
                      final newStart = DateTime(
                          _date.year,
                          _date.month,
                          _date.day,
                          _start.hour,
                          _start.minute);
                      final newEnd = DateTime(_date.year, _date.month,
                          _date.day, _end.hour, _end.minute);
                      Navigator.of(context).pop({
                        'type': _type,
                        'shiftDate': _ymd(_date),
                        'requestedChanges': {
                          'newStart': Timestamp.fromDate(newStart),
                          'newEnd': Timestamp.fromDate(newEnd),
                          'pauseDurationSec': _pauseMinutes * 60,
                        },
                        'reason': _reasonCtrl.text.trim(),
                      });
                    },
                    child: const Text('Anfrage senden'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeChip(String key, String label) {
    final selected = _type == key;
    return GestureDetector(
      onTap: () => setState(() => _type = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.codriverGreen
              : const Color(0xFFF3F6F7),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: AppTypography.caption1.copyWith(
            color: selected ? Colors.white : AppColors.codriverDeep,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _PickField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;
  const _PickField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E5EA), width: 0.6),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.labelSecondaryLight),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTypography.caption2.copyWith(
                    color: AppColors.labelSecondaryLight,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
                Text(
                  value,
                  style: AppTypography.subheadline.copyWith(
              color: const Color(0xFF1C1C1E),
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
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

// ════════════════════════════════════════════════════════════════════
//  Idle-View — Swipe-to-Start
// ════════════════════════════════════════════════════════════════════

// ════════════════════════════════════════════════════════════════════
//  Diagnose-View wenn co:timer noch nicht eingerichtet ist
// ════════════════════════════════════════════════════════════════════

class _CotimerNotReadyView extends StatelessWidget {
  final String adminUid;
  final String driverId;
  final int stationsCount;

  const _CotimerNotReadyView({
    required this.adminUid,
    required this.driverId,
    required this.stationsCount,
  });

  /// Lädt die Email des Admin-Accounts, dem dieser Driver zugewiesen ist.
  /// So sieht der Driver (und der Admin) auf einen Blick, ob die Daten
  /// unter dem richtigen Account angelegt wurden.
  Future<String?> _loadAdminEmail() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(adminUid)
          .get();
      final data = snap.data();
      return (data?['email'] ?? '').toString().trim();
    } catch (_) {
      return null;
    }
  }

  Future<void> _copy(BuildContext context, String value, String label) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label kopiert: $value')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasStations = stationsCount > 0;
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF4E5),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.location_off_outlined,
                      color: Color(0xFFB7791F),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'co:timer ist noch nicht aktiv',
                    textAlign: TextAlign.center,
                    style: AppTypography.title3.copyWith(
              color: const Color(0xFF1C1C1E),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    hasStations
                        ? 'Unter deinem DSP-Account sind $stationsCount '
                            'Station${stationsCount == 1 ? '' : 'en'} '
                            'angelegt, aber noch kein Geofence. Bitte '
                            'deinen Admin, das im co:timer Setup zu '
                            'ergänzen.'
                        : 'Unter deinem DSP-Account ist noch keine '
                            'Station mit Geofence angelegt.',
                    textAlign: TextAlign.center,
                    style: AppTypography.subheadline.copyWith(
                      color: AppColors.labelSecondaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Diagnose-Card mit voller adminUid + driverId.
                  // Hilft dem Admin zu sehen, ob der Driver evtl. unter
                  // einem ANDEREN Admin-Account angelegt wurde als dem,
                  // unter dem er die Stationen erstellt hat.
                  FutureBuilder<String?>(
                    future: _loadAdminEmail(),
                    builder: (ctx, snap) {
                      final email =
                          (snap.data ?? '').toString().trim();
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFE5E5EA),
                            width: 0.6,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Diagnose',
                              style: AppTypography.caption2.copyWith(
                                color: AppColors.labelSecondaryLight,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _DiagRow(
                              label: 'Mein Admin (Email)',
                              value: email.isEmpty
                                  ? '— wird geladen —'
                                  : email,
                              onCopy: email.isEmpty
                                  ? null
                                  : () => _copy(
                                      context, email, 'Admin-Email'),
                            ),
                            const SizedBox(height: 6),
                            _DiagRow(
                              label: 'Admin-UID',
                              value: adminUid,
                              onCopy: () =>
                                  _copy(context, adminUid, 'Admin-UID'),
                            ),
                            const SizedBox(height: 6),
                            _DiagRow(
                              label: 'Driver-ID',
                              value: driverId,
                              onCopy: () =>
                                  _copy(context, driverId, 'Driver-ID'),
                            ),
                            const SizedBox(height: 6),
                            _DiagRow(
                              label: 'Stationen unter dieser UID',
                              value: '$stationsCount',
                              onCopy: null,
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.green50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                email.isEmpty
                                    ? 'Schick deinem Admin die UID — er '
                                        'muss unter genau dieser UID '
                                        'eingeloggt sein und die Station '
                                        'mit Geofence anlegen.'
                                    : 'Dieser Driver hängt am Account '
                                        '"$email". Der Admin muss in '
                                        'GENAU diesem Account eingeloggt '
                                        'sein, um Stationen für diesen '
                                        'Driver anzulegen.',
                                style: AppTypography.caption1.copyWith(
              color: const Color(0xFF1C1C1E),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DiagRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onCopy;
  const _DiagRow({
    required this.label,
    required this.value,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: AppTypography.caption1.copyWith(
              color: AppColors.labelSecondaryLight,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.caption1.copyWith(
              color: const Color(0xFF1C1C1E),
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        if (onCopy != null)
          InkWell(
            onTap: onCopy,
            borderRadius: BorderRadius.circular(6),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.copy_rounded,
                size: 16,
                color: AppColors.codriverGreen,
              ),
            ),
          ),
      ],
    );
  }
}

/// Mountet das Child mit Fade + leichter Aufwärtsbewegung, verzögert um
/// [delay]. Verwendet ease-out (informational, nicht von User getriggert).
class _StaggeredFadeIn extends StatefulWidget {
  final Duration delay;
  final Widget child;
  const _StaggeredFadeIn({required this.delay, required this.child});

  @override
  State<_StaggeredFadeIn> createState() => _StaggeredFadeInState();
}

class _StaggeredFadeInState extends State<_StaggeredFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _opacity = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
    Future.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

class _SecondaryActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SecondaryActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevatedLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: const Color(0xFFE5E5EA), width: 0.6),
            boxShadow: AppElevation.level1,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: Colors.black),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTypography.subheadline.copyWith(
                  color: const Color(0xFF1C1C1E),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IdleView extends StatelessWidget {
  final VoidCallback? onClockIn;
  final bool busy;
  final bool waitingForGps;
  const _IdleView({
    required this.onClockIn,
    required this.busy,
    this.waitingForGps = false,
  });

  String _dateLine() {
    const wd = [
      'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag',
      'Freitag', 'Samstag', 'Sonntag',
    ];
    const mn = [
      'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
      'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember',
    ];
    final now = DateTime.now();
    return '${wd[now.weekday - 1]}, ${now.day}. ${mn[now.month - 1]}';
  }

  String _timeLine() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevatedLight,
            borderRadius: BorderRadius.circular(22),
            boxShadow: AppElevation.level1,
            border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
          ),
          child: Column(
            children: [
              Text(
                _dateLine().toUpperCase(),
                style: AppTypography.caption2.copyWith(
                  color: AppColors.labelSecondaryLight,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _timeLine(),
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 64,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1C1C1E),
                  letterSpacing: -1.2,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Bereit zum Einstempeln',
                style: AppTypography.footnote.copyWith(
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        SizedBox(
          width: double.infinity,
          height: 72,
          child: _SwipeAction(
            label: busy
                ? 'Wird gestempelt …'
                : waitingForGps
                    ? 'STANDORT WIRD GESUCHT …'
                    : 'SWIPE ZUM START',
            color: waitingForGps
                ? AppColors.labelSecondaryLight
                : AppColors.codriverGreen,
            icon: Icons.chevron_right_rounded,
            enabled: !busy && !waitingForGps && onClockIn != null,
            onCompleted: onClockIn,
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  Active-Shift-View — Pause-Toggle + Swipe-to-Stop
// ════════════════════════════════════════════════════════════════════

class _ActiveShiftView extends StatelessWidget {
  final int liveSeconds;
  final bool inPause;
  final int currentPauseSeconds;
  final int totalPauseSeconds;
  final VoidCallback? onPauseToggle;
  final VoidCallback? onClockOut;
  const _ActiveShiftView({
    required this.liveSeconds,
    required this.inPause,
    required this.currentPauseSeconds,
    required this.totalPauseSeconds,
    required this.onPauseToggle,
    required this.onClockOut,
  });

  String _format(int s) {
    final v = s < 0 ? 0 : s;
    final h = (v ~/ 3600).toString().padLeft(2, '0');
    final m = ((v % 3600) ~/ 60).toString().padLeft(2, '0');
    final sec = (v % 60).toString().padLeft(2, '0');
    return '$h:$m:$sec';
  }

  Widget _miniStat({
    required String label,
    required String value,
    required bool inPause,
  }) {
    final fg = inPause ? const Color(0xFFB7791F) : Colors.white;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.caption2.copyWith(
            color: fg.withValues(alpha: 0.7),
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.subheadline.copyWith(
            color: fg,
            fontWeight: FontWeight.w800,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
          decoration: BoxDecoration(
            color: inPause
                ? const Color(0xFFFFF4E5)
                : AppColors.codriverGreen,
            borderRadius: BorderRadius.circular(22),
            boxShadow: AppElevation.level2,
          ),
          child: Column(
            children: [
              Text(
                inPause ? 'PAUSE' : 'EINGESTEMPELT',
                style: AppTypography.caption2.copyWith(
                  color: inPause
                      ? const Color(0xFFB7791F)
                      : Colors.white.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                inPause ? _format(currentPauseSeconds) : _format(liveSeconds),
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 56,
                  fontWeight: FontWeight.w800,
                  color: inPause
                      ? const Color(0xFFB7791F)
                      : Colors.white,
                  letterSpacing: -1.0,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              if (totalPauseSeconds > 0 || inPause) ...[
                const SizedBox(height: 8),
                Container(
                  height: 1,
                  color: (inPause
                          ? const Color(0xFFB7791F)
                          : Colors.white)
                      .withValues(alpha: 0.18),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _miniStat(
                        label: 'Arbeit',
                        value: _format(liveSeconds - totalPauseSeconds),
                        inPause: inPause,
                      ),
                    ),
                    Expanded(
                      child: _miniStat(
                        label: 'Pause heute',
                        value: _format(totalPauseSeconds),
                        inPause: inPause,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        // Spesen-Schwelle (≥ 8 h Abwesenheit = 1 Tag steuerfreie
        // Verpflegungspauschale à 14 €). Sobald die Hero-Schicht-Dauer
        // diese Marke überschreitet, blendet sich der grüne Hinweis ein.
        if (!inPause && liveSeconds >= 8 * 3600) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.codriverGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.codriverGreen.withValues(alpha: 0.5),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.restaurant_outlined,
                  size: 18,
                  color: AppColors.codriverGreen,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Spesen-Tag erreicht — 14 € steuerfrei',
                    style: AppTypography.footnote.copyWith(
              color: const Color(0xFF1C1C1E),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: onPauseToggle,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.codriverDeep,
              side: const BorderSide(color: Color(0xFFE5E5EA), width: 0.6),
              shape: const StadiumBorder(),
              backgroundColor: AppColors.surfaceElevatedLight,
            ),
            icon: Icon(
              inPause
                  ? Icons.play_arrow_rounded
                  : Icons.pause_rounded,
            ),
            label: Text(
              inPause ? 'Pause beenden' : 'Pause starten',
              style: AppTypography.subheadline.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: 64,
          child: _SwipeAction(
            label: 'SWIPE ZUM BEENDEN',
            color: AppColors.error,
            icon: Icons.chevron_right_rounded,
            enabled: onClockOut != null,
            onCompleted: onClockOut,
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  Location-Card
// ════════════════════════════════════════════════════════════════════

class _LocationCard extends StatelessWidget {
  final Position? position;
  final String? error;
  final VoidCallback onRefresh;
  const _LocationCard({
    required this.position,
    required this.error,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final hasPos = position != null;
    final hasErr = error != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevatedLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
        boxShadow: AppElevation.level1,
      ),
      child: Row(
        children: [
          Icon(
            hasErr
                ? Icons.location_off_outlined
                : hasPos
                    ? Icons.location_on_rounded
                    : Icons.location_searching_rounded,
            size: 22,
            color: hasErr
                ? AppColors.error
                : hasPos
                    ? AppColors.codriverGreen
                    : AppColors.labelSecondaryLight,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  hasErr
                      ? 'Standort-Fehler'
                      : hasPos
                          ? 'Standort erfasst'
                          : 'Standort wird ermittelt …',
                  style: AppTypography.subheadline.copyWith(
              color: const Color(0xFF1C1C1E),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  hasErr
                      ? error!
                      : hasPos
                          ? '±${position!.accuracy.toStringAsFixed(0)} m'
                          : 'GPS wird abgefragt',
                  style: AppTypography.caption1.copyWith(
                    color: AppColors.labelSecondaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.labelSecondaryLight,
              size: 20,
            ),
            tooltip: 'Standort aktualisieren',
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  Swipe-to-Action Button — Apple Wallet Style
// ════════════════════════════════════════════════════════════════════

class _SwipeAction extends StatefulWidget {
  final String label;
  final Color color;
  final IconData icon;
  final bool enabled;
  final VoidCallback? onCompleted;
  const _SwipeAction({
    required this.label,
    required this.color,
    required this.icon,
    required this.enabled,
    required this.onCompleted,
  });

  @override
  State<_SwipeAction> createState() => _SwipeActionState();
}

class _SwipeActionState extends State<_SwipeAction>
    with SingleTickerProviderStateMixin {
  double _drag = 0;
  static const double _knobSize = 44;
  static const double _knobInset = 6;
  static const double _completeThreshold = 0.8;

  late final AnimationController _resetCtrl;
  double _resetFrom = 0;

  @override
  void initState() {
    super.initState();
    _resetCtrl = AnimationController.unbounded(vsync: this);
  }

  @override
  void dispose() {
    _resetCtrl.dispose();
    super.dispose();
  }

  /// Spring-Rücksetzung statt hartem `_drag = 0`. Wenn der User unter der
  /// Threshold loslässt, fühlt sich der Reset jetzt physikalisch an —
  /// Knob schwingt sanft zurück mit leichter Überreaktion. (Emil
  /// Kowalski: spring physics beat cubic-bezier für user-getriggerte
  /// Bewegung.)
  void _springReset() {
    _resetFrom = _drag;
    _resetCtrl
      ..stop()
      ..value = 0;
    final sim = SpringSimulation(
      const SpringDescription(mass: 1, stiffness: 220, damping: 22),
      0, // animation pos
      1, // animation end
      0, // initial velocity
    );
    _resetCtrl.animateWith(sim);
    _resetCtrl.addListener(() {
      final t = _resetCtrl.value.clamp(0.0, 1.0);
      // Inverse Lerp: drag → 0
      final newDrag = _resetFrom * (1 - t);
      if (!mounted) return;
      setState(() => _drag = newDrag.clamp(0.0, double.infinity));
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        // Knob bewegt sich zwischen `_knobInset` (Startposition) und
        // `c.maxWidth - _knobSize - _knobInset` (Endposition).
        final maxDrag = c.maxWidth - _knobSize - _knobInset * 2;
        final progress = (_drag / maxDrag).clamp(0.0, 1.0);
        return Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Track
            Container(
              height: c.maxHeight,
              decoration: BoxDecoration(
                color: widget.enabled
                    ? widget.color.withValues(alpha: 0.16)
                    : const Color(0xFFE5E5EA),
                borderRadius: BorderRadius.circular(999),
              ),
              alignment: Alignment.center,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 120),
                opacity: 1 - progress,
                child: Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: AppTypography.footnote.copyWith(
                    color: widget.enabled
                        ? widget.color.withValues(alpha: 0.85)
                        : AppColors.labelTertiaryLight,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
            ),
            // Filled progress fill — nur beim Ziehen sichtbar.
            if (_drag > 0)
              Padding(
                padding: const EdgeInsets.all(_knobInset),
                child: Container(
                  width: _drag + _knobSize - _knobInset,
                  height: c.maxHeight - _knobInset * 2,
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.28),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            // Knob — Position startet bei _knobInset (Abstand vom Rand).
            Positioned(
              left: _knobInset + _drag,
              child: GestureDetector(
                onHorizontalDragUpdate: widget.enabled
                    ? (details) {
                        setState(() {
                          _drag = (_drag + details.delta.dx)
                              .clamp(0.0, maxDrag);
                        });
                      }
                    : null,
                onHorizontalDragEnd: widget.enabled
                    ? (_) {
                        if (_drag / maxDrag >= _completeThreshold) {
                          setState(() => _drag = maxDrag);
                          widget.onCompleted?.call();
                          Future.delayed(
                              const Duration(milliseconds: 400), () {
                            if (mounted) _springReset();
                          });
                        } else {
                          // Spring-Reset statt hartem Snap.
                          _springReset();
                        }
                      }
                    : null,
                child: Container(
                  width: _knobSize,
                  height: _knobSize,
                  decoration: BoxDecoration(
                    color: widget.enabled
                        ? widget.color
                        : const Color(0xFFD1D5DB),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.14),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
