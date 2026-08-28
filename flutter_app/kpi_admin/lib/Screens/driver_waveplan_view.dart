// lib/Screens/driver_waveplan_view.dart
//
// Driver-facing waveplan. All user-visible labels go through
// `AppLocalizations.of(context).t(...)` — the literal "Waveplan" page
// brand is the only intentional exception.
//
// Driver-side Waveplan. Two tabs:
//   1. "Meine Wave" — the driver's own assigned route, dispatch
//      area, spur and shift times.
//   2. "Alle Fahrer" — every driver scheduled in the same dispatch
//      wave so carpools can be coordinated.
//
// Phase 1 stub: when no Waveplan has been published, the screen
// shows an empty state. Once the admin's Publish wires through
// Firestore (`users/{dspUid}/published_waveplans/{date}`), the
// view streams the data live.

import 'dart:async';
import 'dart:convert' show utf8;
import 'dart:html' as html; // Web-App: localStorage für "Sticky Note bestätigt"

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart' show md5;
import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_elevation.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/pill_tab_bar.dart';

class DriverWaveplanView extends StatefulWidget {
  /// UID of the DSP/admin that owns this driver — used to read the
  /// published Waveplan from Firestore.
  final String dspUid;

  /// The driver's own transporter ID (uppercase). Used to find the
  /// driver's row inside the published wave.
  final String driverTransporterId;

  const DriverWaveplanView({
    super.key,
    required this.dspUid,
    required this.driverTransporterId,
  });

  @override
  State<DriverWaveplanView> createState() => _DriverWaveplanViewState();
}

class _DriverWaveplanViewState extends State<DriverWaveplanView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  /// Today's published-waveplan docs across all programs. Drivers are
  /// always pinned to the current day — vergangene Waveplans bleiben
  /// in Firestore (für Admin sichtbar via Date-Strip), werden dem
  /// Driver aber nicht angezeigt.
  Stream<List<DocumentSnapshot<Map<String, dynamic>>>> _docsStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.dspUid)
        .collection('published_waveplans')
        .snapshots()
        .map((snap) {
          final now = DateTime.now();
          final today =
              '${now.year.toString().padLeft(4, '0')}-'
              '${now.month.toString().padLeft(2, '0')}-'
              '${now.day.toString().padLeft(2, '0')}';
          return snap.docs
              .where(
                (d) => d.id.startsWith(today) || d.id == 'sticky_note',
              )
              .toList();
        });
  }

  /// Sticky note of the admin if it is valid today. Returns the text plus
  /// a stable version hash (text + validFrom) so the confirm-popup can be
  /// acknowledged once per note version.
  static ({String text, String version}) _stickyFrom(
    List<DocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    for (final d in docs) {
      if (d.id != 'sticky_note') continue;
      final data = d.data();
      if (data == null) break;
      final text = (data['text'] ?? '').toString().trim();
      if (text.isEmpty) break;
      final now = DateTime.now();
      final vf = data['validFrom'];
      if (vf is Timestamp && now.isBefore(vf.toDate())) break;
      final vu = data['validUntil'];
      if (vu is Timestamp && now.isAfter(vu.toDate())) break;
      final vfMs = vf is Timestamp ? vf.millisecondsSinceEpoch : 0;
      final version = md5.convert(utf8.encode('$vfMs|$text')).toString();
      return (text: text, version: version);
    }
    return (text: '', version: '');
  }

  // ── Sticky-Note-Popup: einmal je Note-Version bestätigen ────────────
  // Bestätigung landet in localStorage, damit das Popup nach Reload
  // nicht erneut blockiert, solange dieselbe Note gilt.
  String get _stickyAckStorageKey =>
      'codriver_waveplan_sticky_ack_${widget.dspUid}';

  bool _isStickyAcked(String version) {
    try {
      return html.window.localStorage[_stickyAckStorageKey] == version;
    } catch (_) {
      return false;
    }
  }

  void _ackSticky(String version) {
    try {
      html.window.localStorage[_stickyAckStorageKey] = version;
    } catch (_) {}
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: StreamBuilder<
              List<DocumentSnapshot<Map<String, dynamic>>>>(
            stream: _docsStream(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final allDocs = snap.data ?? const [];
              final sticky = _stickyFrom(allDocs);
              final stickyText = sticky.text;
              final showStickyPopup =
                  stickyText.isNotEmpty && !_isStickyAcked(sticky.version);
              final docs =
                  allDocs.where((d) => d.id != 'sticky_note').toList();
              // Find the doc that actually contains the driver. If
              // none does, fall back to the first published doc so
              // the dispatcher info / notes still show.
              final me = widget.driverTransporterId.trim().toUpperCase();
              Map<String, dynamic>? data;
              for (final d in docs) {
                final dd = d.data();
                if (dd == null) continue;
                final routes = _routesFrom(dd);
                final hit = routes.any((r) {
                  final tid = (r['transporterId'] ?? '')
                      .toString()
                      .trim()
                      .toUpperCase();
                  final mentee = (r['menteeTransporterId'] ?? '')
                      .toString()
                      .trim()
                      .toUpperCase();
                  return tid == me || mentee == me;
                });
                if (hit) {
                  data = dd;
                  break;
                }
              }
              data ??= docs.isNotEmpty ? docs.first.data() : null;

              final routes = _routesFrom(data);
              final myRoute = _findMyRoute(routes);
              final myWave = myRoute?['dispatchTime']?.toString();
              // Ticket „Waveplan nicht sichtbar": Wer selbst nicht im
              // Plan steht (oder ohne Wave-Zeit eingetragen ist), sah
              // frueher NICHTS. Jetzt zeigt der Alle-Fahrer-Tab dann den
              // kompletten Plan, nach Wave-Zeit sortiert.
              final waveRoutes = myWave == null
                  ? (List<Map<String, dynamic>>.from(routes)
                    ..sort((a, b) => (a['dispatchTime'] ?? '')
                        .toString()
                        .compareTo((b['dispatchTime'] ?? '').toString())))
                  : routes
                        .where((r) => r['dispatchTime'] == myWave)
                        .toList();

              final notes = (data?['notes'] ?? '').toString().trim();
              final dispatchers = _dispatchersFrom(data);
              final content = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tabs first — driver's primary action is to switch
                  // between "Meine Wave" and "Alle Fahrer".
                  _SegmentedTabs(controller: _tabs),
                  const SizedBox(height: AppSpacing.sm),
                  _Header(
                    publishedAt: (data?['publishedAt'] as Timestamp?)?.toDate(),
                  ),
                  if (dispatchers.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _DispatcherStrip(entries: dispatchers),
                  ],
                  if (stickyText.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _NoticeBanner(text: stickyText),
                  ],
                  if (notes.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _NoticeBanner(text: notes),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  Expanded(
                    child: TabBarView(
                      controller: _tabs,
                      children: [
                        _MyWaveTab(myRoute: myRoute),
                        _AllDriversTab(
                          waveRoutes: waveRoutes,
                          myWave: myWave,
                          myTransporterId: widget.driverTransporterId,
                        ),
                      ],
                    ),
                  ),
                ],
              );
              // Ticket „WAVEPLAN": Sticky Note zusätzlich als blockierendes
              // Popup — 10 s Lesezeit, dann per „Gelesen und bestätigt"-
              // Slider wegwischen. Danach ist der Waveplan wieder sichtbar;
              // das Banner darunter bleibt als Nachschlage-Alternative.
              return Stack(
                children: [
                  content,
                  if (showStickyPopup)
                    Positioned.fill(
                      child: _StickyNotePopup(
                        key: ValueKey(sticky.version),
                        text: stickyText,
                        onConfirmed: () => _ackSticky(sticky.version),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _routesFrom(Map<String, dynamic>? data) {
    if (data == null) return const [];
    final raw = data['routes'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => e.cast<String, dynamic>())
        .toList();
  }

  /// The published route this driver is on, matched by transporter ID.
  ///
  /// Synthetic "Atlas only" entries (Atlas packages whose route code has
  /// no route in the wave) carry an empty `transporterId`, so they never
  /// match here — an Atlas-only plan simply shows no personal wave to a
  /// driver. Their packages become visible as soon as the route code
  /// gets a real route with a driver.
  Map<String, dynamic>? _findMyRoute(List<Map<String, dynamic>> routes) {
    final me = widget.driverTransporterId.trim().toUpperCase();
    for (final r in routes) {
      final tid = (r['transporterId'] ?? '').toString().trim().toUpperCase();
      final mentee =
          (r['menteeTransporterId'] ?? '').toString().trim().toUpperCase();
      if (tid.isNotEmpty && (tid == me || mentee == me)) return r;
    }
    return null;
  }

  /// Pulls the dispatcher list out of the published doc. Each entry
  /// is `{name, start, end}`.
  List<Map<String, String>> _dispatchersFrom(Map<String, dynamic>? data) {
    if (data == null) return const [];
    final raw = data['dispatchers'];
    if (raw is! List) return const [];
    final out = <Map<String, String>>[];
    for (final e in raw) {
      if (e is Map) {
        final name = (e['name'] ?? '').toString().trim();
        if (name.isEmpty) continue;
        out.add({
          'name': name,
          'start': (e['start'] ?? '').toString().trim(),
          'end': (e['end'] ?? '').toString().trim(),
        });
      } else if (e is String && e.trim().isNotEmpty) {
        // Legacy form (just a list of names).
        out.add({'name': e.trim(), 'start': '', 'end': ''});
      }
    }
    return out;
  }
}

/// Compact strip showing every dispatcher on duty plus their shift
/// bracket, so the driver always knows whom to call.
class _DispatcherStrip extends StatelessWidget {
  final List<Map<String, String>> entries;
  const _DispatcherStrip({required this.entries});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevatedLight,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppElevation.level1,
        border: Border.all(
          color: AppColors.separatorLight.withOpacity(0.4),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.headset_mic_rounded,
                size: 16,
                color: AppColors.codriverDeep,
              ),
              const SizedBox(width: 6),
              Text(
                t.t('driver_waveplan_dispatcher_today'),
                style: AppTypography.caption2.copyWith(
                  color: AppColors.labelSecondaryLight,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final d in entries)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.green50,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: AppColors.codriverGreen.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.person_rounded,
                        size: 11,
                        color: AppColors.codriverDeep,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        d['name'] ?? '',
                        style: AppTypography.caption1.copyWith(
                          color: AppColors.codriverDeep,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if ((d['start'] ?? '').isNotEmpty &&
                          (d['end'] ?? '').isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Text(
                          '${d['start']}–${d['end']}',
                          style: AppTypography.caption2.copyWith(
                            color: AppColors.codriverDeep,
                            fontWeight: FontWeight.w600,
                            fontFeatures: const [
                              FontFeature.tabularFigures(),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Header
// ════════════════════════════════════════════════════════════════════════════

class _Header extends StatelessWidget {
  final DateTime? publishedAt;
  const _Header({required this.publishedAt});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final now = DateTime.now();
    final dateLabel =
        '${now.day.toString().padLeft(2, '0')}.'
        '${now.month.toString().padLeft(2, '0')}.${now.year}';
    return Row(
      children: [
        Text(
          'Waveplan',
          style: AppTypography.title2.copyWith(
            color: AppColors.codriverGraphite,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: AppColors.green50,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            dateLabel,
            style: AppTypography.caption1.copyWith(
              color: AppColors.codriverDeep,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Spacer(),
        if (publishedAt != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                t.tf('driver_waveplan_published_at', {
                  'time': _hhmm(publishedAt!),
                }),
                style: AppTypography.footnote.copyWith(
                  color: AppColors.labelSecondaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
      ],
    );
  }

  static String _hhmm(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

// ════════════════════════════════════════════════════════════════════════════
//  Segmented tabs
// ════════════════════════════════════════════════════════════════════════════

/// `"11:00:00"` → `"11:00"`. Published routes may legitimately carry an
/// empty time — TMGM imports have none, and synthetic "Atlas only"
/// entries (Atlas packages whose route code has no route) carry nothing
/// at all — so anything shorter than `HH:MM` degrades to an em dash
/// instead of throwing a RangeError.
String _clock(dynamic raw) {
  final s = (raw ?? '').toString().trim();
  if (s.length < 5) return s.isEmpty ? '—' : s;
  return s.substring(0, 5);
}

class _SegmentedTabs extends StatelessWidget {
  final TabController controller;
  const _SegmentedTabs({required this.controller});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return PillTabBar(
      controller: controller,
      tabs: [
        t.t('driver_waveplan_tab_my_wave'),
        t.t('driver_waveplan_tab_all_drivers'),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Tab 1 — Meine Wave
// ════════════════════════════════════════════════════════════════════════════

class _MyWaveTab extends StatelessWidget {
  final Map<String, dynamic>? myRoute;
  const _MyWaveTab({required this.myRoute});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    if (myRoute == null) {
      return _EmptyState(
        icon: Icons.schedule_rounded,
        title: t.t('driver_waveplan_no_wave_yet_title'),
        description: t.t('driver_waveplan_no_wave_yet_desc'),
      );
    }

    final spur = (myRoute!['spur'] ?? '').toString().toLowerCase();
    final hasSpur = spur.trim().isNotEmpty;
    final isLeft = spur == 'links';
    final spurColor = !hasSpur
        ? AppColors.labelTertiaryLight
        : isLeft
            ? const Color(0xFF0A84FF)
            : AppColors.codriverGreen;
    final atlasIds = (myRoute!['atlasTrackingIds'] as List? ?? const [])
        .map((e) => e.toString())
        .where((e) => e.isNotEmpty)
        .toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (atlasIds.isNotEmpty) ...[
            _AtlasAlert(trackingIds: atlasIds),
            const SizedBox(height: AppSpacing.md),
          ],
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.codriverGreen,
                  AppColors.codriverDeep,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: AppElevation.level3,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${t.t('driver_waveplan_wave_prefix')} '
                  '${_clock(myRoute!['dispatchTime'])}',
                  style: AppTypography.footnote.copyWith(
                    color: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  (myRoute!['routeCode'] ?? '').toString(),
                  style: AppTypography.title2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Dispatch Area & Spur side-by-side. IntrinsicHeight + stretch
          // keeps the two cards visually aligned regardless of label
          // length (one of them may wrap on narrow phones).
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _DetailCard(
                    icon: Icons.place_rounded,
                    label: t.t('driver_waveplan_dispatch_area'),
                    value: (myRoute!['dispatchArea'] ?? '—').toString(),
                    compact: true,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: _DetailCard(
                    icon: !hasSpur
                        ? Icons.swap_horiz_rounded
                        : isLeft
                            ? Icons.arrow_back_rounded
                            : Icons.arrow_forward_rounded,
                    label: t.t('driver_waveplan_lane'),
                    // No lane published (TMGM / Atlas-only) → "—"
                    // instead of silently claiming "right".
                    value: !hasSpur
                        ? '—'
                        : isLeft
                            ? t.t('driver_waveplan_lane_left')
                            : t.t('driver_waveplan_lane_right'),
                    valueColor: spurColor,
                    compact: true,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          _DetailCard(
            icon: Icons.schedule_rounded,
            label: t.t('driver_waveplan_shift'),
            value: '${_clock(myRoute!['dispatchTime'])}'
                ' – '
                '${_clock(myRoute!['shiftEnd'])}',
          ),
        ],
      ),
    );
  }
}

/// Free-form notice from the dispatcher — e.g. "Stau auf A3" or
/// "Maximale Zustellzeit verkürzt".
class _NoticeBanner extends StatelessWidget {
  final String text;
  const _NoticeBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.green50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.codriverGreen.withOpacity(0.5),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.campaign_rounded,
            size: 20,
            color: AppColors.codriverDeep,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            // Cap the banner height so a long note can never push the
            // waveplan below it off-screen — the note scrolls inside
            // its own bounded box instead.
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 140),
              child: Scrollbar(
                child: SingleChildScrollView(
                  child: Text(
                    text,
                    style: AppTypography.body.copyWith(
                      color: AppColors.codriverDeep,
                      fontWeight: FontWeight.w600,
                    ),
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

/// Prominent alert that the driver has Atlas packages — these are
/// expensive/sensitive parcels that must be picked up from the
/// dispatcher in person. Shows the count and the tracking IDs so
/// the dispatcher can verify together.
class _AtlasAlert extends StatelessWidget {
  final List<String> trackingIds;
  const _AtlasAlert({required this.trackingIds});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.warning.withOpacity(0.16),
            AppColors.warning.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withOpacity(0.55), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.warning.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.inventory_2_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.tf(
                        trackingIds.length == 1
                            ? 'driver_waveplan_atlas_title_one'
                            : 'driver_waveplan_atlas_title_many',
                        {'count': '${trackingIds.length}'},
                      ),
                      style: AppTypography.subheadline.copyWith(
                        color: const Color(0xFF8A4A00),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      t.t('driver_waveplan_atlas_desc'),
                      style: AppTypography.caption1.copyWith(
                        color: const Color(0xFF8A4A00).withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.t('driver_waveplan_tracking_ids'),
                  style: AppTypography.caption2.copyWith(
                    color: const Color(0xFF8A4A00),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (var i = 0; i < trackingIds.length; i++)
                      Container(
                        padding: const EdgeInsets.fromLTRB(4, 4, 10, 4),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.16),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: AppColors.warning.withOpacity(0.4),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.warning,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${i + 1}',
                                style: AppTypography.caption2.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              trackingIds[i],
                              style: AppTypography.footnote.copyWith(
                                color: const Color(0xFF8A4A00),
                                fontWeight: FontWeight.w700,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
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

class _DetailCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  /// Compact layout for side-by-side use on narrow phones: smaller
  /// icon box, smaller padding, and the value uses [AppTypography.subheadline]
  /// instead of [AppTypography.headline] so it doesn't overflow.
  final bool compact;
  const _DetailCard({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconBox = compact ? 30.0 : 36.0;
    final gap = compact ? AppSpacing.sm : AppSpacing.md;
    final valueStyle = compact
        ? AppTypography.subheadline.copyWith(
            color: valueColor ?? AppColors.codriverGraphite,
            fontWeight: FontWeight.w700,
          )
        : AppTypography.headline.copyWith(
            color: valueColor ?? AppColors.codriverGraphite,
            fontWeight: FontWeight.w700,
          );
    return Container(
      padding: EdgeInsets.all(compact ? AppSpacing.sm : AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevatedLight,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppElevation.level1,
      ),
      child: Row(
        children: [
          Container(
            width: iconBox,
            height: iconBox,
            decoration: BoxDecoration(
              color: AppColors.green50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: compact ? 16 : 18,
              color: AppColors.codriverDeep,
            ),
          ),
          SizedBox(width: gap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTypography.caption2.copyWith(
                    color: AppColors.labelSecondaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: valueStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Tab 2 — Alle Fahrer in derselben Wave
// ════════════════════════════════════════════════════════════════════════════

class _AllDriversTab extends StatelessWidget {
  final List<Map<String, dynamic>> waveRoutes;
  final String? myWave;
  final String myTransporterId;
  const _AllDriversTab({
    required this.waveRoutes,
    required this.myWave,
    required this.myTransporterId,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    if (waveRoutes.isEmpty) {
      return _EmptyState(
        icon: Icons.groups_rounded,
        title: t.t('driver_waveplan_all_empty_title'),
        description: t.t('driver_waveplan_all_empty_desc'),
      );
    }
    final me = myTransporterId.trim().toUpperCase();
    return ListView.separated(
      itemCount: waveRoutes.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
      itemBuilder: (_, i) {
        final r = waveRoutes[i];
        final tid = (r['transporterId'] ?? '').toString().trim().toUpperCase();
        final mentee =
            (r['menteeTransporterId'] ?? '').toString().trim().toUpperCase();
        final isMe = tid == me || mentee == me;
        final spur = (r['spur'] ?? '').toString().toLowerCase();
        final hasSpur = spur.trim().isNotEmpty;
        final isLeft = spur == 'links';
        final spurColor = !hasSpur
            ? AppColors.labelTertiaryLight
            : isLeft
                ? const Color(0xFF0A84FF)
                : AppColors.codriverGreen;
        final name = (r['driverName'] ?? '').toString();
        final routeCode = (r['routeCode'] ?? '').toString();
        final atlasIds = (r['atlasTrackingIds'] as List? ?? const [])
            .map((e) => e.toString())
            .where((e) => e.isNotEmpty)
            .toList();

        return Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: isMe ? AppColors.green50 : AppColors.surfaceElevatedLight,
            borderRadius: BorderRadius.circular(14),
            boxShadow: AppElevation.level1,
            border: Border.all(
              color: isMe ? AppColors.codriverGreen : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // Uniform colored dot — same size for every driver,
              // no person icon (the name already identifies the row).
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isMe
                      ? AppColors.codriverGreen
                      : AppColors.labelTertiaryLight,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name.isNotEmpty
                          ? name +
                              (isMe
                                  ? '  ${t.t('driver_waveplan_me_suffix')}'
                                  : '')
                          // No driver at all (unassigned route or an
                          // Atlas-only entry) → fall back to the route
                          // code so the row is never blank.
                          : (tid.isNotEmpty ? tid : routeCode),
                      style: AppTypography.subheadline.copyWith(
                        color: AppColors.codriverGraphite,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (atlasIds.isNotEmpty) ...[
                          _AtlasCountChip(
                            count: atlasIds.length,
                            onTap: () => _showAtlasTrackingPopup(
                              context,
                              atlasIds,
                              driverName: name.isEmpty ? tid : name,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Flexible(
                          child: Text(
                            [
                              routeCode,
                              (r['dispatchArea'] ?? '').toString().trim(),
                            ].where((e) => e.isNotEmpty).join('  ·  '),
                            style: AppTypography.footnote.copyWith(
                              color: AppColors.labelSecondaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: spurColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: spurColor.withOpacity(0.25),
                    width: 1,
                  ),
                ),
                child: Text(
                  // Routes published without a lane show "—" instead of
                  // defaulting to "right".
                  !hasSpur
                      ? '—'
                      : isLeft
                          ? t.t('driver_waveplan_lane_left')
                          : t.t('driver_waveplan_lane_right'),
                  style: TextStyle(
                    fontSize: 11,
                    color: spurColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Modal popup listing all Atlas tracking-IDs for a single driver.
/// Triggered by tapping the orange Atlas count chip in the "Alle
/// Fahrer" tab.
Future<void> _showAtlasTrackingPopup(
  BuildContext context,
  List<String> trackingIds, {
  required String driverName,
}) async {
  final t = AppLocalizations.of(context);
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.warning,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.inventory_2_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t.t('driver_waveplan_tracking_ids'),
                  style: AppTypography.subheadline.copyWith(
                    color: AppColors.codriverGraphite,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  driverName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption2.copyWith(
                    color: AppColors.labelSecondaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360, maxHeight: 420),
        child: SingleChildScrollView(
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (var i = 0; i < trackingIds.length; i++)
                Container(
                  padding: const EdgeInsets.fromLTRB(4, 4, 10, 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: AppColors.warning.withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.warning,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${i + 1}',
                          style: AppTypography.caption2.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontFeatures: const [
                              FontFeature.tabularFigures(),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        trackingIds[i],
                        style: AppTypography.footnote.copyWith(
                          color: const Color(0xFF8A4A00),
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [
                            FontFeature.tabularFigures(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Schließen'),
        ),
      ],
    ),
  );
}

/// Tiny orange chip with the Atlas icon + parcel count. Tappable —
/// opens [_showAtlasTrackingPopup] with the tracking-IDs.
class _AtlasCountChip extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const _AtlasCountChip({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.16),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: AppColors.warning.withOpacity(0.4),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.inventory_2_rounded,
                size: 11,
                color: AppColors.warning,
              ),
              const SizedBox(width: 3),
              Text(
                '$count',
                style: AppTypography.caption2.copyWith(
                  color: const Color(0xFF8A4A00),
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Empty state
// ════════════════════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevatedLight,
                shape: BoxShape.circle,
                boxShadow: AppElevation.level1,
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 32,
                color: AppColors.codriverDeep,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.title3.copyWith(
                color: AppColors.codriverGraphite,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              description,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                color: AppColors.labelSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Sticky-Note-Popup mit Lese-Countdown + Slide-to-Confirm
// ════════════════════════════════════════════════════════════════════════════

/// Blocking popup for the admin's sticky note. The note is scrollable,
/// a 10 second countdown enforces reading time, then the driver swipes
/// the "I have read and confirm" slider to dismiss the popup.
class _StickyNotePopup extends StatefulWidget {
  final String text;
  final VoidCallback onConfirmed;

  const _StickyNotePopup({
    super.key,
    required this.text,
    required this.onConfirmed,
  });

  @override
  State<_StickyNotePopup> createState() => _StickyNotePopupState();
}

class _StickyNotePopupState extends State<_StickyNotePopup> {
  static const int _readSeconds = 10;

  int _secondsLeft = _readSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void didUpdateWidget(covariant _StickyNotePopup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _secondsLeft = _readSeconds;
      _startCountdown();
    }
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _secondsLeft = _secondsLeft > 0 ? _secondsLeft - 1 : 0;
      });
      if (_secondsLeft <= 0) timer.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final unlocked = _secondsLeft <= 0;
    return Container(
      color: Colors.black.withOpacity(0.55),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 440,
          maxHeight: MediaQuery.of(context).size.height * 0.72,
        ),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.green50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.campaign_rounded,
                        color: AppColors.codriverDeep,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        t.t('driver_waveplan_sticky_popup_title'),
                        style: AppTypography.title3.copyWith(
                          color: AppColors.codriverGraphite,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (!unlocked)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.green50,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          t.tf('driver_waveplan_sticky_popup_wait', {
                            'seconds': '$_secondsLeft',
                          }),
                          style: AppTypography.caption1.copyWith(
                            color: AppColors.codriverDeep,
                            fontWeight: FontWeight.w700,
                            fontFeatures: const [
                              FontFeature.tabularFigures(),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                // Scrollbare Note — lange Texte sprengen das Popup nicht.
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.green50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.codriverGreen.withOpacity(0.5),
                        width: 1.2,
                      ),
                    ),
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          widget.text,
                          style: AppTypography.body.copyWith(
                            color: AppColors.codriverDeep,
                            fontWeight: FontWeight.w600,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _SlideToConfirm(
                  label: t.t('driver_waveplan_sticky_popup_confirm'),
                  enabled: unlocked,
                  onConfirmed: widget.onConfirmed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Slide-to-confirm control: drag the thumb across the track to trigger
/// [onConfirmed]. While [enabled] is false the control is greyed out and
/// ignores drags (read-time countdown still running).
class _SlideToConfirm extends StatefulWidget {
  final String label;
  final bool enabled;
  final VoidCallback onConfirmed;

  const _SlideToConfirm({
    required this.label,
    required this.enabled,
    required this.onConfirmed,
  });

  @override
  State<_SlideToConfirm> createState() => _SlideToConfirmState();
}

class _SlideToConfirmState extends State<_SlideToConfirm> {
  static const double _trackHeight = 54;
  static const double _thumbSize = 46;

  double _dragX = 0;
  bool _dragging = false;
  bool _confirmed = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxDrag =
            (constraints.maxWidth - _thumbSize - 8).clamp(0.0, double.infinity);
        final progress = maxDrag <= 0 ? 0.0 : (_dragX / maxDrag).clamp(0.0, 1.0);
        final active = widget.enabled && !_confirmed;
        return GestureDetector(
          onHorizontalDragStart: active
              ? (_) => setState(() => _dragging = true)
              : null,
          onHorizontalDragUpdate: active
              ? (details) => setState(() {
                    _dragX =
                        (_dragX + details.delta.dx).clamp(0.0, maxDrag);
                  })
              : null,
          onHorizontalDragEnd: active
              ? (_) {
                  setState(() => _dragging = false);
                  if (_dragX >= maxDrag * 0.85) {
                    setState(() {
                      _dragX = maxDrag;
                      _confirmed = true;
                    });
                    widget.onConfirmed();
                  } else {
                    setState(() => _dragX = 0);
                  }
                }
              : null,
          child: Container(
            height: _trackHeight,
            decoration: BoxDecoration(
              color: widget.enabled
                  ? AppColors.codriverDeep.withOpacity(0.10)
                  : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: widget.enabled
                    ? AppColors.codriverGreen.withOpacity(0.6)
                    : const Color(0xFFCBD5E1),
                width: 1.2,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Fortschritts-Füllung hinter dem Thumb.
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: _thumbSize + 8 + _dragX,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.codriverGreen
                          .withOpacity(0.25 + 0.35 * progress),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _thumbSize + 12,
                  ),
                  child: Text(
                    widget.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AppTypography.subheadline.copyWith(
                      color: widget.enabled
                          ? AppColors.codriverDeep
                          : AppColors.labelTertiaryLight,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: _dragging
                      ? Duration.zero
                      : const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  left: 4 + _dragX,
                  top: (_trackHeight - _thumbSize) / 2,
                  child: Container(
                    width: _thumbSize,
                    height: _thumbSize,
                    decoration: BoxDecoration(
                      color: widget.enabled
                          ? AppColors.codriverGreen
                          : const Color(0xFF94A3B8),
                      shape: BoxShape.circle,
                      boxShadow: widget.enabled ? AppElevation.level2 : null,
                    ),
                    child: Icon(
                      _confirmed
                          ? Icons.check_rounded
                          : Icons.chevron_right_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
