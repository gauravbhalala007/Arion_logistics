// lib/Screens/driver_shift_plan_view.dart
//
// Driver-facing shift plan. Two tabs:
//   1. "My shift" — own entry for today (or tomorrow if today is
//      already past meeting time), with Meeting + Dispatch pairs per
//      block, ride along, day notes.
//   2. "All drivers" — every driver in the published plan, sorted by
//      dispatch start. Lets the driver see who else is on shift.
//
// Reads from the published ShiftPlanDoc at
// `users/{dspUid}/shift_plans/{YYYY-MM-DD}`. Falls back to tomorrow
// when no plan exists for today yet.
//
// Dispatch times come straight from the doc. Meeting time = dispatch
// − doc.parkingOffsetMinutes (defaults to 15).

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/shift_plan.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/pill_tab_bar.dart';

class DriverShiftPlanView extends StatefulWidget {
  const DriverShiftPlanView({
    super.key,
    required this.dspUid,
    required this.driverTransporterId,
  });

  final String dspUid;
  final String driverTransporterId;

  @override
  State<DriverShiftPlanView> createState() => _DriverShiftPlanViewState();
}

class _DriverShiftPlanViewState extends State<DriverShiftPlanView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  /// Currently displayed day. Defaults to today (or tomorrow after
  /// the 19:00 cutoff). Manually changed via the date strip chips.
  String? _selectedKey;

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

  String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// "Today" relative to the device clock, midnight-truncated.
  DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  /// After 19:00 today's plan is considered done — drivers should
  /// focus on tomorrow + later. Returns the earliest day key the
  /// driver is allowed to see (today's key or tomorrow's key).
  String get _earliestKey {
    final isEvening = DateTime.now().hour >= 19;
    final cutoff = isEvening
        ? _today.add(const Duration(days: 1))
        : _today;
    return _dateKey(cutoff);
  }

  /// Stream every published shift plan for this DSP. The result is
  /// filtered + sorted on the client so we don't need a Firestore
  /// composite index (plans are at most a handful of docs per week).
  Stream<List<ShiftPlanDoc>> _docsStream() {
    final col = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.dspUid)
        .collection('shift_plans');
    return col.snapshots().map((snap) {
      final earliest = _earliestKey;
      final docs = snap.docs
          .where((d) => d.id.compareTo(earliest) >= 0)
          .map(ShiftPlanDoc.fromDoc)
          .toList()
        ..sort((a, b) => a.dateKey.compareTo(b.dateKey));
      return docs;
    });
  }

  /// Apply doc.parkingOffsetMinutes to a dispatch time string to get
  /// the meeting time. Handles `HH:mm` and `h:mmam|pm` formats.
  String _meetingFor(String dispatch, int offsetMinutes) {
    final m = RegExp(r'^(\d{1,2}):(\d{2})\s*(am|pm)?',
            caseSensitive: false)
        .firstMatch(dispatch.trim());
    if (m == null) return '';
    var h = int.tryParse(m.group(1) ?? '0') ?? 0;
    final mins = int.tryParse(m.group(2) ?? '0') ?? 0;
    final suf = (m.group(3) ?? '').toLowerCase();
    if (suf == 'pm' && h < 12) h += 12;
    if (suf == 'am' && h == 12) h = 0;
    final total = h * 60 + mins - offsetMinutes;
    if (total < 0) return '';
    final hh = (total ~/ 60).toString().padLeft(2, '0');
    final mm = (total % 60).toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final me = widget.driverTransporterId.trim().toUpperCase();
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: StreamBuilder<List<ShiftPlanDoc>>(
            stream: _docsStream(),
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
              final docs = snap.data ?? const <ShiftPlanDoc>[];
              // ignore: avoid_print
              print(
                '[driver-shift-plan] me=$me earliest=$_earliestKey '
                'docs=${docs.length} keys=${docs.map((d) => d.dateKey).join(",")}',
              );
              if (docs.isEmpty) return const _EmptyState();

              // Reconcile the selected day:
              //   • Keep the user's pick if it's still in the eligible
              //     list (e.g. they picked Wednesday and Wednesday is
              //     still upcoming).
              //   • Otherwise default to today, falling back to the
              //     first eligible day (which is tomorrow after the
              //     19:00 cutoff).
              final keys = docs.map((d) => d.dateKey).toList();
              final preferred = _earliestKey;
              final effectiveKey = (_selectedKey != null &&
                      keys.contains(_selectedKey))
                  ? _selectedKey!
                  : keys.contains(preferred)
                      ? preferred
                      : keys.first;
              final doc =
                  docs.firstWhere((d) => d.dateKey == effectiveKey);

              final myEntry = doc.entries.firstWhere(
                (e) {
                  final tid = e.transporterId.trim().toUpperCase();
                  final mentee =
                      e.menteeTransporterId.trim().toUpperCase();
                  return tid == me || mentee == me;
                },
                orElse: () => const ShiftPlanEntry(
                  transporterId: '',
                  driverName: '',
                  blocks: <ShiftBlock>[],
                ),
              );
              final planHasAssignments = doc.entries
                  .where((e) => e.transporterId.trim().isNotEmpty)
                  .isNotEmpty;
              // ignore: avoid_print
              print(
                '[driver-shift-plan] selected=${doc.dateKey} '
                'planHasAssignments=$planHasAssignments '
                'myEntryFound=${myEntry.transporterId.isNotEmpty} '
                'driverTids=${doc.entries.map((e) => e.transporterId).take(20).join(",")}',
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HeaderCard(
                    dateKey: doc.dateKey,
                    driverCount: doc.entries
                        .where((e) =>
                            e.transporterId.trim().isNotEmpty)
                        .length,
                    parkingOffset: doc.parkingOffsetMinutes,
                  ),
                  if (docs.length > 1) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _DateStrip(
                      docs: docs,
                      selectedKey: effectiveKey,
                      onPick: (k) =>
                          setState(() => _selectedKey = k),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  PillTabBar(
                    controller: _tabs,
                    tabs: const ['My shift', 'All drivers'],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Expanded(
                    child: TabBarView(
                      controller: _tabs,
                      children: [
                        _MyShiftTab(
                          entry: myEntry,
                          notes: doc.notes,
                          dispatchers: doc.dispatchers,
                          dispatcherShifts: doc.dispatcherShifts,
                          parkingOffset: doc.parkingOffsetMinutes,
                          meetingFor: _meetingFor,
                          planHasAssignments: planHasAssignments,
                          myTid: me,
                          planDateKey: doc.dateKey,
                        ),
                        _AllDriversTab(
                          entries: doc.entries,
                          parkingOffset: doc.parkingOffsetMinutes,
                          highlightTid: me,
                          meetingFor: _meetingFor,
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
}

// ──────────────────────────────────────────────────────────────────
//   DATE STRIP  (today + future days the driver may inspect)
// ──────────────────────────────────────────────────────────────────

class _DateStrip extends StatelessWidget {
  const _DateStrip({
    required this.docs,
    required this.selectedKey,
    required this.onPick,
  });

  final List<ShiftPlanDoc> docs;
  final String selectedKey;
  final ValueChanged<String> onPick;

  static const _weekdays = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: docs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (ctx, i) {
          final d = DateTime.parse(docs[i].dateKey);
          final isSelected = docs[i].dateKey == selectedKey;
          return _DateChip(
            weekday: _weekdays[d.weekday - 1],
            day: d.day,
            selected: isSelected,
            onTap: () => onPick(docs[i].dateKey),
          );
        },
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.weekday,
    required this.day,
    required this.selected,
    required this.onTap,
  });

  final String weekday;
  final int day;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 56,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.codriverGreen : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.codriverGreen
                : const Color(0xFFE5E7EB),
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              weekday,
              style: TextStyle(
                color: selected
                    ? Colors.white.withValues(alpha: 0.85)
                    : const Color(0xFF6B7280),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              day.toString().padLeft(2, '0'),
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : const Color(0xFF111827),
                fontSize: 18,
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
//   HEADER
// ──────────────────────────────────────────────────────────────────

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.dateKey,
    required this.driverCount,
    required this.parkingOffset,
  });

  final String dateKey;
  final int driverCount;
  final int parkingOffset;

  String _label() {
    final d = DateTime.parse(dateKey);
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${weekdays[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.codriverDeep,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.event_note_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Shift plan',
                  style: AppTypography.caption2.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
                Text(
                  _label(),
                  style: AppTypography.title3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '$driverCount drivers · Meeting = Dispatch − $parkingOffset min',
                  style: AppTypography.caption2.copyWith(
                    color: Colors.white.withValues(alpha: 0.75),
                    height: 1.4,
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

// ──────────────────────────────────────────────────────────────────
//   MY SHIFT TAB
// ──────────────────────────────────────────────────────────────────

class _MyShiftTab extends StatelessWidget {
  const _MyShiftTab({
    required this.entry,
    required this.notes,
    required this.dispatchers,
    required this.dispatcherShifts,
    required this.parkingOffset,
    required this.meetingFor,
    required this.planHasAssignments,
    required this.myTid,
    required this.planDateKey,
  });

  final ShiftPlanEntry entry;
  final List<ShiftPlanNote> notes;
  final List<String> dispatchers;
  final Map<String, List<String>> dispatcherShifts;
  final int parkingOffset;
  final String Function(String dispatch, int offsetMinutes) meetingFor;

  /// True when the plan has at least one assigned driver — used to
  /// pick between "you're off today" and "you're not on the roster".
  final bool planHasAssignments;

  /// Driver's own transporter ID (uppercased). Surfaced when the
  /// driver isn't on the roster so they can flag the mismatch to the
  /// admin ("my TID is X, please add me").
  final String myTid;
  final String planDateKey;

  @override
  Widget build(BuildContext context) {
    if (entry.transporterId.trim().isEmpty || entry.blocks.isEmpty) {
      // Two distinct empty states:
      //   • Plan has other drivers but not you → "not on the roster"
      //     (likely a TID mismatch the admin needs to fix).
      //   • Plan is genuinely empty → "off today".
      final isNotOnRoster = planHasAssignments;
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isNotOnRoster
                      ? Icons.person_search_rounded
                      : Icons.coffee_rounded,
                  size: 44,
                  color: AppColors.labelSecondaryLight,
                ),
                const SizedBox(height: 12),
                Text(
                  isNotOnRoster
                      ? 'You\'re not on the roster'
                      : 'No shift for you today',
                  textAlign: TextAlign.center,
                  style: AppTypography.title3.copyWith(
                    color: AppColors.codriverGraphite,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isNotOnRoster
                      ? 'A plan was published for $planDateKey but '
                          'your transporter ID isn\'t in it. Check '
                          'with your dispatcher.'
                      : 'Enjoy your day off.',
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(
                    color: AppColors.labelSecondaryLight,
                    height: 1.5,
                  ),
                ),
                if (isNotOnRoster && myTid.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.green50,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppColors.codriverGreen
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      'Your TID: $myTid',
                      style: AppTypography.caption1.copyWith(
                        color: AppColors.codriverDeep,
                        fontWeight: FontWeight.w800,
                        fontFeatures: const [
                          FontFeature.tabularFigures(),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (dispatchers.isNotEmpty)
            _DispatchersCard(
              dispatchers: dispatchers,
              shifts: dispatcherShifts,
            ),
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 6),
              child: Text(
                'DAY NOTES',
                style: AppTypography.caption2.copyWith(
                  color: AppColors.labelSecondaryLight,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ),
            for (final n in notes) _DayNoteCard(note: n),
          ],
        ],
      );
    }

    return ListView(
      children: [
        // ─── Per-block Meeting + Dispatch pairs ──────────────
        for (final b in entry.blocks)
          _ShiftBlockCard(
            block: b,
            meeting: meetingFor(b.startTime, parkingOffset),
          ),
        if (dispatchers.isNotEmpty) ...[
          const SizedBox(height: 6),
          _DispatchersCard(
            dispatchers: dispatchers,
            shifts: dispatcherShifts,
          ),
        ],
        if (entry.menteeTransporterId.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          _RideAlongCard(
            menteeName: entry.menteeName,
            menteeTid: entry.menteeTransporterId,
          ),
        ],
        if (entry.personalNotes.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          _PersonalNoteCard(text: entry.personalNotes),
        ],
        if (entry.lateCancel) ...[
          const SizedBox(height: 6),
          _LateCancelBanner(reason: entry.lateCancelReason),
        ],
        if (notes.isNotEmpty) ...[
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              'DAY NOTES',
              style: AppTypography.caption2.copyWith(
                color: AppColors.labelSecondaryLight,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
          ),
          for (final n in notes) _DayNoteCard(note: n),
        ],
      ],
    );
  }
}

class _ShiftBlockCard extends StatelessWidget {
  const _ShiftBlockCard({required this.block, required this.meeting});
  final ShiftBlock block;
  final String meeting;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            block.serviceType.isEmpty
                ? 'Shift'
                : block.serviceType,
            style: AppTypography.subheadline.copyWith(
              color: AppColors.codriverGraphite,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _TimePill(
                  label: 'Meeting',
                  value: meeting.isEmpty ? '—' : meeting,
                  icon: Icons.local_parking_rounded,
                  accent: AppColors.codriverDeep,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: Color(0xFF9CA3AF),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _TimePill(
                  label: 'Dispatch',
                  value: _germanTime(block.startTime),
                  icon: Icons.directions_car_rounded,
                  accent: AppColors.codriverGreen,
                ),
              ),
            ],
          ),
          if (block.duration.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Duration: ${block.duration}',
              style: AppTypography.caption1.copyWith(
                color: AppColors.labelSecondaryLight,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TimePill extends StatelessWidget {
  const _TimePill({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: accent),
              const SizedBox(width: 5),
              Text(
                label.toUpperCase(),
                style: AppTypography.caption2.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTypography.title3.copyWith(
              color: accent,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

/// Lists the dispatchers on duty for the published day with their
/// shift range. Read-only — just headset-icon + name + start-end.
class _DispatchersCard extends StatelessWidget {
  const _DispatchersCard({
    required this.dispatchers,
    required this.shifts,
  });

  final List<String> dispatchers;
  final Map<String, List<String>> shifts;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.headset_mic_rounded,
                size: 18,
                color: AppColors.codriverDeep,
              ),
              const SizedBox(width: 8),
              Text(
                'Dispatchers',
                style: AppTypography.subheadline.copyWith(
                  color: AppColors.codriverGraphite,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < dispatchers.length; i++) ...[
            _DispatcherRow(
              name: dispatchers[i],
              shift: shifts[dispatchers[i]],
            ),
            if (i < dispatchers.length - 1) const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}

class _DispatcherRow extends StatelessWidget {
  const _DispatcherRow({required this.name, required this.shift});
  final String name;
  final List<String>? shift;

  @override
  Widget build(BuildContext context) {
    final hasShift = shift != null && shift!.length >= 2;
    final start = hasShift ? shift![0] : '';
    final end = hasShift ? shift![1] : '';
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: AppColors.green50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.codriverGreen.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: AppColors.codriverGreen,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              _initials(name),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.subheadline.copyWith(
                color: AppColors.codriverDeep,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (hasShift)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: AppColors.codriverGreen
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                '$start – $end',
                style: AppTypography.caption1.copyWith(
                  color: AppColors.codriverDeep,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _initials(String s) {
    final parts =
        s.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    final letters =
        parts.take(2).map((p) => p[0].toUpperCase()).join();
    return letters.isEmpty ? '?' : letters;
  }
}

class _RideAlongCard extends StatelessWidget {
  const _RideAlongCard({
    required this.menteeName,
    required this.menteeTid,
  });
  final String menteeName;
  final String menteeTid;

  static const _blue = Color(0xFF0A84FF);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F1FE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _blue.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: _blue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.school_rounded,
              size: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'RIDE ALONG',
                  style: AppTypography.caption2.copyWith(
                    color: _blue,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
                Text(
                  menteeName.isNotEmpty ? menteeName : menteeTid,
                  style: AppTypography.subheadline.copyWith(
                    color: _blue,
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

class _PersonalNoteCard extends StatelessWidget {
  const _PersonalNoteCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.sticky_note_2_rounded,
            size: 18,
            color: Color(0xFF9A3412),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTypography.body.copyWith(
                color: const Color(0xFF9A3412),
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LateCancelBanner extends StatelessWidget {
  const _LateCancelBanner({required this.reason});
  final String reason;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.cancel_outlined,
            size: 18,
            color: Color(0xFFB91C1C),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Cut · Late Cancel',
                  style: AppTypography.subheadline.copyWith(
                    color: const Color(0xFFB91C1C),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (reason.trim().isNotEmpty)
                  Text(
                    reason,
                    style: AppTypography.caption1.copyWith(
                      color: const Color(0xFF991B1B),
                      height: 1.4,
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

class _DayNoteCard extends StatelessWidget {
  const _DayNoteCard({required this.note});
  final ShiftPlanNote note;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.green50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.codriverGreen.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (note.title.trim().isNotEmpty)
            Text(
              note.title.trim(),
              style: AppTypography.subheadline.copyWith(
                color: AppColors.codriverDeep,
                fontWeight: FontWeight.w800,
              ),
            ),
          if (note.title.trim().isNotEmpty && note.body.trim().isNotEmpty)
            const SizedBox(height: 6),
          if (note.body.trim().isNotEmpty)
            Text(
              note.body.trim(),
              style: AppTypography.body.copyWith(
                color: AppColors.codriverDeep.withValues(alpha: 0.85),
                height: 1.45,
              ),
            ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
//   ALL DRIVERS TAB
// ──────────────────────────────────────────────────────────────────

class _AllDriversTab extends StatelessWidget {
  const _AllDriversTab({
    required this.entries,
    required this.parkingOffset,
    required this.highlightTid,
    required this.meetingFor,
  });

  final List<ShiftPlanEntry> entries;
  final int parkingOffset;
  final String highlightTid;
  final String Function(String dispatch, int offsetMinutes) meetingFor;

  int _minsOfDay(String s) {
    final m = RegExp(r'^(\d{1,2}):(\d{2})\s*(am|pm)?',
            caseSensitive: false)
        .firstMatch(s.trim());
    if (m == null) return 99999;
    var h = int.tryParse(m.group(1) ?? '0') ?? 0;
    final mins = int.tryParse(m.group(2) ?? '0') ?? 0;
    final suf = (m.group(3) ?? '').toLowerCase();
    if (suf == 'pm' && h < 12) h += 12;
    if (suf == 'am' && h == 12) h = 0;
    return h * 60 + mins;
  }

  @override
  Widget build(BuildContext context) {
    final assigned = entries
        .where((e) =>
            e.transporterId.trim().isNotEmpty && e.blocks.isNotEmpty)
        .toList()
      ..sort((a, b) {
        final at = a.blocks.first.startTime;
        final bt = b.blocks.first.startTime;
        return _minsOfDay(at).compareTo(_minsOfDay(bt));
      });

    if (assigned.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(
            'No drivers in this plan yet.',
            style: AppTypography.body.copyWith(
              color: AppColors.labelSecondaryLight,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: assigned.length,
      itemBuilder: (ctx, i) {
        final e = assigned[i];
        final isMe =
            e.transporterId.trim().toUpperCase() == highlightTid;
        final dispatch = e.blocks.first.startTime;
        final meeting = meetingFor(dispatch, parkingOffset);
        return _AllDriversRow(
          entry: e,
          meeting: meeting,
          isMe: isMe,
        );
      },
    );
  }
}

class _AllDriversRow extends StatelessWidget {
  const _AllDriversRow({
    required this.entry,
    required this.meeting,
    required this.isMe,
  });

  final ShiftPlanEntry entry;
  final String meeting;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final blocks = entry.blocks;
    final hasMentee = entry.menteeTransporterId.trim().isNotEmpty;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: isMe ? AppColors.green50 : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isMe
              ? AppColors.codriverGreen.withValues(alpha: 0.4)
              : const Color(0xFFE5E7EB),
          width: isMe ? 1.4 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.driverName.isEmpty
                            ? entry.transporterId
                            : entry.driverName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.subheadline.copyWith(
                          color: isMe
                              ? AppColors.codriverDeep
                              : AppColors.codriverGraphite,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (isMe)
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.codriverGreen,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'YOU',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                  ],
                ),
                if (hasMentee)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.school_rounded,
                          size: 11,
                          color: Color(0xFF0A84FF),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            entry.menteeName.isNotEmpty
                                ? entry.menteeName
                                : entry.menteeTransporterId,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption2.copyWith(
                              color: const Color(0xFF0A84FF),
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
          const SizedBox(width: 10),
          _MiniTimePair(
            meeting: meeting,
            dispatch: _germanTime(blocks.first.startTime),
          ),
        ],
      ),
    );
  }
}

class _MiniTimePair extends StatelessWidget {
  const _MiniTimePair({required this.meeting, required this.dispatch});
  final String meeting;
  final String dispatch;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MEET',
                style: AppTypography.caption2.copyWith(
                  color: AppColors.codriverDeep,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                meeting.isEmpty ? '—' : meeting,
                style: AppTypography.subheadline.copyWith(
                  color: AppColors.codriverDeep,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.arrow_forward_rounded,
            size: 14,
            color: Color(0xFF9CA3AF),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DISP',
                style: AppTypography.caption2.copyWith(
                  color: AppColors.codriverGreen,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                dispatch,
                style: AppTypography.subheadline.copyWith(
                  color: AppColors.codriverGreen,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
//   EMPTY STATE
// ──────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_note_rounded,
              size: 48,
              color: AppColors.labelSecondaryLight,
            ),
            const SizedBox(height: 12),
            Text(
              'No shift plan yet',
              style: AppTypography.title3.copyWith(
                color: AppColors.codriverGraphite,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your dispatcher will publish today\'s plan soon.',
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

/// Converts any shift time string ("7:00am", "6:00pm", "16:00", "07:00") to
/// German 24-hour "HH:MM". Returns the trimmed input when unparseable.
String _germanTime(String raw) {
  final m = RegExp(r'(\d{1,2}):(\d{2})\s*(am|pm)?', caseSensitive: false)
      .firstMatch(raw.trim());
  if (m == null) return raw.trim();
  var h = int.tryParse(m.group(1) ?? '0') ?? 0;
  final min = int.tryParse(m.group(2) ?? '0') ?? 0;
  final suf = (m.group(3) ?? '').toLowerCase();
  if (suf == 'pm' && h < 12) h += 12;
  if (suf == 'am' && h == 12) h = 0;
  String p(int n) => n.toString().padLeft(2, '0');
  return '${p(h % 24)}:${p(min)}';
}
