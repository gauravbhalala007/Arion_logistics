// lib/Screens/driver_waveplan_view.dart
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_elevation.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

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

  /// Today's published-waveplan docs across all programs. Each
  /// `(date, program)` pair lives under
  /// `users/{dspUid}/published_waveplans/{YYYY-MM-DD_program}` so we
  /// query the whole collection and filter in-memory.
  Stream<List<DocumentSnapshot<Map<String, dynamic>>>> _todayDocsStream() {
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
              .where((d) => d.id.startsWith(today))
              .toList();
        });
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
            stream: _todayDocsStream(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snap.data ?? const [];
              // Find the doc that actually contains the driver. If
              // none does, fall back to the first published doc so
              // the dispatcher info / notes still show.
              final me = widget.driverTransporterId.trim().toUpperCase();
              Map<String, dynamic>? data;
              for (final d in docs) {
                final dd = d.data();
                if (dd == null) continue;
                final routes = _routesFrom(dd);
                final hit = routes.any((r) =>
                    (r['transporterId'] ?? '')
                        .toString()
                        .trim()
                        .toUpperCase() ==
                    me);
                if (hit) {
                  data = dd;
                  break;
                }
              }
              data ??= docs.isNotEmpty ? docs.first.data() : null;

              final routes = _routesFrom(data);
              final myRoute = _findMyRoute(routes);
              final myWave = myRoute?['dispatchTime']?.toString();
              final waveRoutes = myWave == null
                  ? const <Map<String, dynamic>>[]
                  : routes
                        .where((r) => r['dispatchTime'] == myWave)
                        .toList();

              final notes = (data?['notes'] ?? '').toString().trim();
              final dispatchers = _dispatchersFrom(data);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(
                    publishedAt: (data?['publishedAt'] as Timestamp?)?.toDate(),
                  ),
                  if (dispatchers.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _DispatcherStrip(entries: dispatchers),
                  ],
                  if (notes.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _NoticeBanner(text: notes),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  _SegmentedTabs(controller: _tabs),
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

  Map<String, dynamic>? _findMyRoute(List<Map<String, dynamic>> routes) {
    final me = widget.driverTransporterId.trim().toUpperCase();
    for (final r in routes) {
      final tid = (r['transporterId'] ?? '').toString().trim().toUpperCase();
      if (tid.isNotEmpty && tid == me) return r;
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
                'Dispatcher heute',
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
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final d in entries)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.green50,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: AppColors.codriverGreen.withOpacity(0.5),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.person_rounded,
                        size: 14,
                        color: AppColors.codriverDeep,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        d['name'] ?? '',
                        style: AppTypography.subheadline.copyWith(
                          color: AppColors.codriverDeep,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if ((d['start'] ?? '').isNotEmpty &&
                          (d['end'] ?? '').isNotEmpty) ...[
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.schedule_rounded,
                          size: 12,
                          color: AppColors.codriverDeep,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${d['start']}–${d['end']}',
                          style: AppTypography.footnote.copyWith(
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
                'Veröffentlicht ${_hhmm(publishedAt!)}',
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

class _SegmentedTabs extends StatelessWidget {
  final TabController controller;
  const _SegmentedTabs({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevatedLight,
        borderRadius: BorderRadius.circular(999),
        boxShadow: AppElevation.level1,
        border: Border.all(
          color: AppColors.separatorLight.withOpacity(0.4),
          width: 0.5,
        ),
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          color: AppColors.codriverGreen,
          borderRadius: BorderRadius.circular(999),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.labelSecondaryLight,
        labelStyle: AppTypography.subheadline.copyWith(
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: AppTypography.subheadline.copyWith(
          fontWeight: FontWeight.w500,
        ),
        dividerColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        tabs: const [
          Tab(text: 'Meine Wave'),
          Tab(text: 'Alle Fahrer'),
        ],
      ),
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
    if (myRoute == null) {
      return const _EmptyState(
        icon: Icons.schedule_rounded,
        title: 'Noch keine Wave veröffentlicht',
        description: 'Sobald dein Dispatcher den Waveplan veröffentlicht, '
            'siehst du hier deine Route, Spur und Abfahrtszeit.',
      );
    }

    final spur = (myRoute!['spur'] ?? '').toString().toLowerCase();
    final isLeft = spur == 'links';
    final spurColor = isLeft
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
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.codriverGreen,
                  AppColors.codriverDeep,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppElevation.level3,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wave ${(myRoute!['dispatchTime'] ?? '').toString().substring(0, 5)}',
                  style: AppTypography.headline.copyWith(
                    color: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  (myRoute!['routeCode'] ?? '').toString(),
                  style: AppTypography.largeTitle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  (myRoute!['serviceType'] ?? '').toString(),
                  style: AppTypography.body.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Detail rows
          _DetailCard(
            icon: Icons.place_rounded,
            label: 'Dispatch Area',
            value: (myRoute!['dispatchArea'] ?? '—').toString(),
          ),
          const SizedBox(height: AppSpacing.xs),
          _DetailCard(
            icon: isLeft
                ? Icons.arrow_back_rounded
                : Icons.arrow_forward_rounded,
            label: 'Spur',
            value: isLeft ? 'links' : 'rechts',
            valueColor: spurColor,
          ),
          const SizedBox(height: AppSpacing.xs),
          _DetailCard(
            icon: Icons.schedule_rounded,
            label: 'Schicht',
            value:
                '${(myRoute!['dispatchTime'] ?? '').toString().substring(0, 5)}'
                ' – '
                '${(myRoute!['shiftEnd'] ?? '').toString().substring(0, 5)}',
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
            child: Text(
              text,
              style: AppTypography.body.copyWith(
                color: AppColors.codriverDeep,
                fontWeight: FontWeight.w600,
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
                      '${trackingIds.length} Atlas-Paket'
                      '${trackingIds.length == 1 ? '' : 'e'} '
                      'beim Dispatcher abholen',
                      style: AppTypography.headline.copyWith(
                        color: const Color(0xFF8A4A00),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Diese Pakete sind hochwertig und müssen persönlich '
                      'übergeben werden.',
                      style: AppTypography.footnote.copyWith(
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
                  'Tracking-IDs',
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
                    for (final tid in trackingIds)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.16),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: AppColors.warning.withOpacity(0.4),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          tid,
                          style: AppTypography.footnote.copyWith(
                            color: const Color(0xFF8A4A00),
                            fontWeight: FontWeight.w700,
                            fontFeatures: const [
                              FontFeature.tabularFigures(),
                            ],
                          ),
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
  const _DetailCard({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevatedLight,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppElevation.level1,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.green50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.codriverDeep),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.caption1.copyWith(
                    color: AppColors.labelSecondaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: AppTypography.headline.copyWith(
                    color: valueColor ?? AppColors.codriverGraphite,
                    fontWeight: FontWeight.w700,
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
    if (myWave == null || waveRoutes.isEmpty) {
      return const _EmptyState(
        icon: Icons.groups_rounded,
        title: 'Niemand sichtbar',
        description: 'Sobald der Waveplan veröffentlicht ist, siehst du hier '
            'alle anderen Fahrer in deiner Wave — praktisch für Fahrgemeinschaften.',
      );
    }
    final me = myTransporterId.trim().toUpperCase();
    return ListView.separated(
      itemCount: waveRoutes.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
      itemBuilder: (_, i) {
        final r = waveRoutes[i];
        final tid = (r['transporterId'] ?? '').toString().trim().toUpperCase();
        final isMe = tid == me;
        final spur = (r['spur'] ?? '').toString().toLowerCase();
        final isLeft = spur == 'links';
        final spurColor = isLeft
            ? const Color(0xFF0A84FF)
            : AppColors.codriverGreen;
        final name = (r['driverName'] ?? '').toString();

        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
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
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isMe ? AppColors.codriverGreen : AppColors.surfaceLight,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.person_rounded,
                  size: 20,
                  color: isMe ? Colors.white : AppColors.labelSecondaryLight,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isNotEmpty
                          ? name + (isMe ? '  (du)' : '')
                          : tid,
                      style: AppTypography.headline.copyWith(
                        color: AppColors.codriverGraphite,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${(r['routeCode'] ?? '').toString()}  ·  '
                      '${(r['dispatchArea'] ?? '').toString()}',
                      style: AppTypography.footnote.copyWith(
                        color: AppColors.labelSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: spurColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: spurColor.withOpacity(0.25),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isLeft
                          ? Icons.arrow_back_rounded
                          : Icons.arrow_forward_rounded,
                      size: 12,
                      color: spurColor,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      isLeft ? 'links' : 'rechts',
                      style: TextStyle(
                        fontSize: 11,
                        color: spurColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
