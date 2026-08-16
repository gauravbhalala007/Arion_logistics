// lib/Screens/public_plan_page.dart
//
// Public, link-only, read-only plan viewer (no auth). Renders the generic
// payload written by PublicPlanService:
//   { type, title, subtitle, date, company, station, notes,
//     sections: [ { title, rows: [ {primary, secondary, badge,
//     badgeItems: []} ] } ] }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class PublicPlanPage extends StatelessWidget {
  const PublicPlanPage({super.key, required this.shareId});

  final String shareId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F7),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance
            .collection('public_plans')
            .doc(shareId)
            .get(),
        builder: (context, snap) {
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
          final data = snap.data?.data();
          if (snap.hasError || data == null) {
            return _NotFound(error: snap.error?.toString());
          }
          return _PlanView(data: data);
        },
      ),
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound({this.error});
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.link_off_rounded,
              size: 44,
              color: Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 12),
            Text(
              Localizations.localeOf(context).languageCode == 'de'
                  ? 'Dieser Plan ist nicht (mehr) verfügbar.'
                  : 'This plan is no longer available.',
              textAlign: TextAlign.center,
              style: AppTypography.headline.copyWith(
                color: const Color(0xFF374151),
              ),
            ),
            if (error != null) ...[
              const SizedBox(height: 8),
              Text(
                error!,
                textAlign: TextAlign.center,
                style: AppTypography.caption2.copyWith(
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlanView extends StatelessWidget {
  const _PlanView({required this.data});
  final Map<String, dynamic> data;

  String _s(dynamic v) => (v ?? '').toString();

  @override
  Widget build(BuildContext context) {
    final title = _s(data['title']);
    final subtitle = _s(data['subtitle']);
    final date = _s(data['date']);
    final company = _s(data['company']);
    final station = _s(data['station']);
    final notes = _s(data['notes']).trim();
    final stickyNote = _s(data['stickyNote']).trim();
    final dispatchers = (data['dispatchers'] is List)
        ? List<Map<String, dynamic>>.from(
            (data['dispatchers'] as List).whereType<Map>().map(
              (m) => Map<String, dynamic>.from(m),
            ),
          )
        : const <Map<String, dynamic>>[];
    final sections = (data['sections'] is List)
        ? List<Map<String, dynamic>>.from(
            (data['sections'] as List).whereType<Map>().map(
              (m) => Map<String, dynamic>.from(m),
            ),
          )
        : const <Map<String, dynamic>>[];

    // Header stays pinned at the top; only the plan body scrolls.
    final header = Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            decoration: BoxDecoration(
              color: AppColors.codriverDeep,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title.isEmpty ? 'Plan' : title,
                        style: AppTypography.title2.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (station.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          station,
                          style: AppTypography.caption1.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    if (date.isNotEmpty) date,
                    if (subtitle.isNotEmpty) subtitle,
                    if (company.isNotEmpty) company,
                  ].join('  ·  '),
                  style: AppTypography.caption1.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // Notes live INSIDE the scroll area (not the pinned header) so a long
    // multi-language note can't fill the screen and hide the routes/names.
    final notesBox = notes.isEmpty
        ? const SizedBox.shrink()
        : Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFED7AA)),
            ),
            child: Text(
              notes,
              style: AppTypography.footnote.copyWith(
                color: const Color(0xFF92400E),
                height: 1.4,
              ),
            ),
          );

    // Sticky Note des Admins — gilt über mehrere Tage und wird deshalb
    // vor der Tagesnotiz angezeigt.
    final stickyBox = stickyNote.isEmpty
        ? const SizedBox.shrink()
        : Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.green50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.codriverGreen.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.push_pin_rounded,
                    size: 16, color: AppColors.codriverDeep),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    stickyNote,
                    style: AppTypography.footnote.copyWith(
                      color: AppColors.codriverGraphite,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );

    final dispatcherBox = dispatchers.isEmpty
        ? const SizedBox.shrink()
        : Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE3E8EF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.headset_mic_rounded,
                        size: 15, color: AppColors.codriverDeep),
                    const SizedBox(width: 7),
                    Text(
                      'DISPATCHER',
                      style: AppTypography.caption2.copyWith(
                        color: AppColors.codriverDeep,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    for (final d in dispatchers)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.green50,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          [
                            _s(d['name']),
                            if (_s(d['time']).trim().isNotEmpty)
                              _s(d['time']),
                            if (_s(d['phone']).trim().isNotEmpty)
                              _s(d['phone']),
                          ].where((e) => e.trim().isNotEmpty).join('  ·  '),
                          style: AppTypography.caption1.copyWith(
                            color: AppColors.codriverGraphite,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                  children: [
                    dispatcherBox,
                    stickyBox,
                    notesBox,
                    for (final section in sections) ...[
                      const SizedBox(height: 16),
                      _SectionCard(section: section),
                    ],
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        Localizations.localeOf(context).languageCode == 'de'
                            ? 'Bereitgestellt über CoDriver · dsp-codriver.de'
                            : 'Provided via CoDriver · dsp-codriver.de',
                        style: AppTypography.caption2.copyWith(
                          color: const Color(0xFF9CA3AF),
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
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section});
  final Map<String, dynamic> section;

  String _s(dynamic v) => (v ?? '').toString();

  @override
  Widget build(BuildContext context) {
    final title = _s(section['title']);
    final rows = (section['rows'] is List)
        ? List<Map<String, dynamic>>.from(
            (section['rows'] as List).whereType<Map>().map(
              (m) => Map<String, dynamic>.from(m),
            ),
          )
        : const <Map<String, dynamic>>[];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              color: AppColors.codriverGreen.withValues(alpha: 0.10),
              child: Text(
                title,
                style: AppTypography.subheadline.copyWith(
                  color: AppColors.codriverDeep,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          for (int i = 0; i < rows.length; i++) ...[
            if (i != 0) const Divider(height: 1, color: Color(0xFFF1F5F9)),
            _RowTile(row: rows[i], zebra: i.isOdd),
          ],
        ],
      ),
    );
  }
}

class _RowTile extends StatelessWidget {
  const _RowTile({required this.row, required this.zebra});
  final Map<String, dynamic> row;
  final bool zebra;

  String _s(dynamic v) => (v ?? '').toString();

  @override
  Widget build(BuildContext context) {
    final primary = _s(row['primary']);
    final secondary = _s(row['secondary']);
    final badge = _s(row['badge']);
    final badgeItems = (row['badgeItems'] is List)
        ? (row['badgeItems'] as List).map((e) => e.toString()).toList()
        : const <String>[];
    final pills = (row['pills'] is List)
        ? (row['pills'] as List).map((e) => e.toString()).toList()
        : const <String>[];

    return Container(
      color: zebra ? const Color(0xFFFAFAFA) : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      primary,
                      style: AppTypography.subheadline.copyWith(
                        color: const Color(0xFF111827),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (secondary.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        secondary,
                        style: AppTypography.footnote.copyWith(
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                    if (pills.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          for (final p in pills)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.codriverGreen.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: AppColors.codriverGreen.withValues(
                                    alpha: 0.45,
                                  ),
                                ),
                              ),
                              child: Text(
                                p,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.codriverDeep,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (badge.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: const Color(0xFFFDBA74),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.inventory_2_rounded,
                        size: 15,
                        color: Color(0xFFC2410C),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        badge,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFFC2410C),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          if (badgeItems.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                for (final id in badgeItems)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFED7AA)),
                    ),
                    child: Text(
                      id,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        color: Color(0xFF7C2D12),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
