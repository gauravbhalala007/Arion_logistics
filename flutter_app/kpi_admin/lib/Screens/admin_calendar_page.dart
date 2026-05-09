// lib/Screens/admin_calendar_page.dart
//
// Admin-side calendar. Two-column layout:
//   ┌────────────────────────────────────────┬──────────────────┐
//   │  ◀ Mai 2026 ▶                          │  Anstehend       │
//   │  ┌────┬────┬────┬────┬────┬────┬────┐  │  ─────────────── │
//   │  │KW17│ M  │ D  │ M  │ D  │ F  │ S │…│  │  Mo 12.05.       │
//   │  │ 18 │ 28 │ 29 │ 30 │  1 │  2 │ 3 │…│  │   ● Briefing 09  │
//   │  │ 19 │  4 │  5 │  6 │  7 │  8 │ 9 │…│  │   ● TÜV Sprinter │
//   │  └────┴────┴────┴────┴────┴────┴────┘  │  Di 13.05.       │
//   │                                        │   ● …            │
//   └────────────────────────────────────────┴──────────────────┘
//
// Calendar weeks (KW) are rendered as a left-side column. The right
// panel lists every event in the next 7 days. Events are read live
// from `users/{uid}/calendar_events` (Phase 2 will add admin CRUD).

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_colors.dart';
import '../theme/app_elevation.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Standalone calendar page (Scaffold wrapper).
class AdminCalendarPage extends StatelessWidget {
  const AdminCalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: AdminCalendarSection(),
        ),
      ),
    );
  }
}

/// Calendar widget that can be dropped into any layout — no Scaffold,
/// no outer padding. Use this on the admin home so the calendar lives
/// alongside the other home cards.
class AdminCalendarSection extends StatefulWidget {
  const AdminCalendarSection({super.key});

  @override
  State<AdminCalendarSection> createState() => _AdminCalendarPageState();
}

class _AdminCalendarPageState extends State<AdminCalendarSection> {
  late DateTime _visibleMonth; // first day of the month being viewed
  DateTime? _selectedDay;

  Stream<List<_CalEvent>>? _eventsStream;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
    _selectedDay = DateTime(now.year, now.month, now.day);
    _eventsStream = _streamEvents();
  }

  Stream<List<_CalEvent>> _streamEvents() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value(_demoEvents());
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('calendar_events')
        .snapshots()
        .map((snap) {
          final out = <_CalEvent>[];
          for (final d in snap.docs) {
            final data = d.data();
            final start = (data['start'] as Timestamp?)?.toDate();
            if (start == null) continue;
            final end = (data['end'] as Timestamp?)?.toDate();
            out.add(
              _CalEvent(
                id: d.id,
                start: start,
                end: end,
                title: (data['title'] ?? '').toString(),
                category: (data['category'] ?? '').toString(),
                location: (data['location'] ?? '').toString(),
                dispatcher: (data['dispatcher'] ?? '').toString(),
              ),
            );
          }
          if (out.isEmpty) return _demoEvents();
          out.sort((a, b) => a.start.compareTo(b.start));
          return out;
        });
  }

  Future<void> _addEvent({DateTime? prefillStart}) async {
    final result = await showDialog<_NewEventResult>(
      context: context,
      builder: (ctx) => _AddEventDialog(prefillStart: prefillStart),
    );
    if (result == null) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('calendar_events')
          .add({
            'start': Timestamp.fromDate(result.start),
            'end': Timestamp.fromDate(result.end),
            'title': result.title,
            'category': result.category,
            'location': result.location,
            'dispatcher': result.dispatcher,
            'createdAt': FieldValue.serverTimestamp(),
          });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Termin "${result.title}" hinzugefügt.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Speichern: $e')),
      );
    }
  }

  /// Sample events shown when Firestore is empty so the screen is
  /// never blank during the first preview.
  List<_CalEvent> _demoEvents() {
    final now = DateTime.now();
    DateTime at(int dayOffset, int h, int m) =>
        DateTime(now.year, now.month, now.day + dayOffset, h, m);
    DateTime day(int dayOffset, [int h = 9, int m = 0]) =>
        DateTime(now.year, now.month, now.day + dayOffset, h, m);
    return [
      _CalEvent(
        id: 'demo1',
        start: at(0, 9, 0),
        end: null,
        title: 'Morning briefing',
        category: 'Meeting',
        location: 'DBY5 — Halle 3',
      ),
      _CalEvent(
        id: 'demo2',
        start: at(0, 14, 30),
        end: null,
        title: 'TÜV Sprinter M-XF 4219',
        category: 'Service',
        location: 'Werkstatt Müller',
      ),
      // Multi-day rental pickup spanning 12 days (across multiple weeks)
      _CalEvent(
        id: 'demo_rental',
        start: day(2, 8, 0),
        end: day(13, 18, 0),
        title: 'Mietfahrzeug-Abholung Sixt',
        category: 'Mietfahrzeug',
        location: 'Sixt Stuttgart Hbf',
      ),
      _CalEvent(
        id: 'demo3',
        start: at(1, 10, 0),
        end: null,
        title: 'Driver-Onboarding Maria',
        category: 'HR',
        location: 'Büro 2. OG',
      ),
      _CalEvent(
        id: 'demo4',
        start: at(2, 8, 0),
        end: null,
        title: 'DSP-Meeting',
        category: 'Meeting',
        location: 'Online',
      ),
      _CalEvent(
        id: 'demo5',
        start: at(4, 15, 0),
        end: null,
        title: 'Wartung Sprinter Flotte',
        category: 'Service',
        location: 'Werkstatt',
      ),
      _CalEvent(
        id: 'demo6',
        start: at(6, 11, 0),
        end: null,
        title: 'Quartalsplanung',
        category: 'Planning',
        location: 'Konferenzraum',
      ),
    ];
  }

  void _gotoMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(
        _visibleMonth.year,
        _visibleMonth.month + delta,
      );
    });
  }

  void _gotoToday() {
    final now = DateTime.now();
    setState(() {
      _visibleMonth = DateTime(now.year, now.month);
      _selectedDay = DateTime(now.year, now.month, now.day);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 1100;
    return StreamBuilder<List<_CalEvent>>(
      stream: _eventsStream,
      builder: (context, snap) {
        final events = snap.data ?? const <_CalEvent>[];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(
              visibleMonth: _visibleMonth,
              onPrev: () => _gotoMonth(-1),
              onNext: () => _gotoMonth(1),
              onToday: _gotoToday,
              onAddEvent: () => _addEvent(prefillStart: _selectedDay),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: isNarrow
                  ? Column(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _CalendarGrid(
                            visibleMonth: _visibleMonth,
                            selectedDay: _selectedDay,
                            events: events,
                            onSelectDay: (d) =>
                                setState(() => _selectedDay = d),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        SizedBox(
                          height: 280,
                          child: _UpcomingPanel(events: events),
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 7,
                          child: _CalendarGrid(
                            visibleMonth: _visibleMonth,
                            selectedDay: _selectedDay,
                            events: events,
                            onSelectDay: (d) =>
                                setState(() => _selectedDay = d),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        SizedBox(
                          width: 320,
                          child: _UpcomingPanel(events: events),
                        ),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Header — month label + nav
// ════════════════════════════════════════════════════════════════════════════

class _Header extends StatelessWidget {
  final DateTime visibleMonth;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onToday;
  final VoidCallback onAddEvent;
  const _Header({
    required this.visibleMonth,
    required this.onPrev,
    required this.onNext,
    required this.onToday,
    required this.onAddEvent,
  });

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('MMMM yyyy', _localeForFormat(context));
    return Row(
      children: [
        // Month title + nav arrows directly next to it.
        Text(
          df.format(visibleMonth),
          style: AppTypography.title2.copyWith(
            color: AppColors.codriverGraphite,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        _RoundIconButton(
          icon: Icons.chevron_left_rounded,
          onTap: onPrev,
        ),
        const SizedBox(width: AppSpacing.xs),
        _RoundIconButton(
          icon: Icons.chevron_right_rounded,
          onTap: onNext,
        ),
        const SizedBox(width: AppSpacing.sm),
        _PillButton(label: 'Heute', onTap: onToday),
        const Spacer(),
        _AddEventButton(onTap: onAddEvent),
      ],
    );
  }
}

/// Primary CTA in the top-right corner of the calendar — opens the
/// dialog to create a new event (single-day or multi-day).
class _AddEventButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddEventButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.codriverGreen,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.18)),
            boxShadow: AppElevation.level1,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_rounded, size: 18, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                'Termin',
                style: AppTypography.subheadline.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIconButton({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevatedLight,
            shape: BoxShape.circle,
            boxShadow: AppElevation.level1,
            border: Border.all(
              color: AppColors.separatorLight.withOpacity(0.4),
              width: 0.5,
            ),
          ),
          child: Icon(icon, size: 20, color: AppColors.codriverDeep),
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PillButton({required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevatedLight,
            borderRadius: BorderRadius.circular(999),
            boxShadow: AppElevation.level1,
            border: Border.all(
              color: AppColors.separatorLight.withOpacity(0.4),
              width: 0.5,
            ),
          ),
          child: Text(
            label,
            style: AppTypography.footnote.copyWith(
              color: AppColors.codriverGraphite,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Calendar grid (with KW column on the left)
// ════════════════════════════════════════════════════════════════════════════

class _CalendarGrid extends StatelessWidget {
  final DateTime visibleMonth;
  final DateTime? selectedDay;
  final List<_CalEvent> events;
  final ValueChanged<DateTime> onSelectDay;

  const _CalendarGrid({
    required this.visibleMonth,
    required this.selectedDay,
    required this.events,
    required this.onSelectDay,
  });

  @override
  Widget build(BuildContext context) {
    final weeks = _buildWeeks(visibleMonth);
    final today = DateTime.now();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevatedLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppElevation.level1,
        border: Border.all(
          color: AppColors.separatorLight.withOpacity(0.4),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          // Weekday header row (Mo Di Mi Do Fr Sa So)
          Row(
            children: [
              const SizedBox(width: 56), // KW column reservation
              for (final wd in const ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'])
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      wd,
                      style: AppTypography.caption2.copyWith(
                        color: AppColors.labelSecondaryLight,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          // Week rows — KW label + 7 day cells each
          Expanded(
            child: Column(
              children: [
                for (final week in weeks)
                  Expanded(
                    child: Row(
                      children: [
                        // KW label (left column)
                        SizedBox(
                          width: 56,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'KW ${_isoWeek(week.first)}',
                                style: AppTypography.caption2.copyWith(
                                  color: AppColors.codriverDeep,
                                  fontWeight: FontWeight.w700,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        for (final day in week)
                          Expanded(
                            child: _DayCell(
                              day: day,
                              inMonth: day.month == visibleMonth.month,
                              isToday: _sameDay(day, today),
                              isSelected: selectedDay != null &&
                                  _sameDay(day, selectedDay!),
                              events: events
                                  .where((e) => e.coversDay(day))
                                  .toList(),
                              onTap: () => onSelectDay(day),
                            ),
                          ),
                      ],
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

class _DayCell extends StatelessWidget {
  final DateTime day;
  final bool inMonth;
  final bool isToday;
  final bool isSelected;
  final List<_CalEvent> events;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.inMonth,
    required this.isToday,
    required this.isSelected,
    required this.events,
    required this.onTap,
  });

  Color _categoryColor(String category) {
    final c = category.toLowerCase();
    if (c.contains('miet')) return const Color(0xFF7B5BFF); // rental purple
    if (c.contains('meeting') || c.contains('plan')) return AppColors.codriverGreen;
    if (c.contains('service') || c.contains('tüv')) return AppColors.warning;
    if (c.contains('hr') || c.contains('onboard')) return const Color(0xFF0A84FF);
    return AppColors.codriverDeep;
  }

  @override
  Widget build(BuildContext context) {
    final fg = !inMonth
        ? AppColors.labelTertiaryLight
        : AppColors.codriverGraphite;
    final cellBg = !inMonth
        ? AppColors.surfaceLight.withOpacity(0.4)
        : AppColors.surfaceLight;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(3),
          padding: const EdgeInsets.fromLTRB(6, 6, 6, 4),
          decoration: BoxDecoration(
            color: cellBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? AppColors.codriverGreen
                  : AppColors.separatorLight.withOpacity(0.35),
              width: isSelected ? 1.5 : 0.6,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date pill (top-left): "09.05" — today gets brand pill
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isToday
                        ? AppColors.codriverGreen
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${day.day.toString().padLeft(2, '0')}.${day.month.toString().padLeft(2, '0')}',
                    style: AppTypography.caption1.copyWith(
                      color: isToday ? Colors.white : fg,
                      fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // Event bars — up to 3 visible, "+N more" otherwise
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < events.length && i < 3; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: _EventBar(
                          event: events[i],
                          day: day,
                          color: _categoryColor(events[i].category),
                        ),
                      ),
                    if (events.length > 3)
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(
                          '+${events.length - 3} mehr',
                          style: AppTypography.caption2.copyWith(
                            color: AppColors.labelSecondaryLight,
                            fontWeight: FontWeight.w600,
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

/// Single event bar inside a day cell. For multi-day events the bar
/// renders square on its inner edges (no rounding) so it visually
/// merges with the next cell.
class _EventBar extends StatelessWidget {
  final _CalEvent event;
  final DateTime day;
  final Color color;
  const _EventBar({
    required this.event,
    required this.day,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isFirst = _sameDay(event.start, day);
    final isLast = _sameDay(event.end, day);
    final isStartOfWeek = day.weekday == DateTime.monday;
    final isEndOfWeek = day.weekday == DateTime.sunday;

    final leftRound = isFirst || isStartOfWeek;
    final rightRound = isLast || isEndOfWeek;

    return Container(
      height: 18,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(leftRound ? 5 : 0),
          bottomLeft: Radius.circular(leftRound ? 5 : 0),
          topRight: Radius.circular(rightRound ? 5 : 0),
          bottomRight: Radius.circular(rightRound ? 5 : 0),
        ),
        border: Border(
          left: BorderSide(
            color: color,
            width: isFirst ? 3 : 0,
          ),
        ),
      ),
      child: Text(
        // Show the title only on the first day or at the start of a
        // week so multi-day events don't repeat the label in every cell.
        (isFirst || isStartOfWeek) ? event.title : '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 10,
          height: 1.0,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Upcoming panel (right column) — events in the next 7 days
// ════════════════════════════════════════════════════════════════════════════

class _UpcomingPanel extends StatelessWidget {
  final List<_CalEvent> events;
  const _UpcomingPanel({required this.events});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final until = today.add(const Duration(days: 7));
    final filtered = events
        .where((e) => !e.start.isBefore(today) && e.start.isBefore(until))
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    // Group by date.
    final grouped = <DateTime, List<_CalEvent>>{};
    for (final e in filtered) {
      final key = DateTime(e.start.year, e.start.month, e.start.day);
      grouped.putIfAbsent(key, () => []).add(e);
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevatedLight,
        borderRadius: BorderRadius.circular(20),
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
                Icons.event_rounded,
                size: 18,
                color: AppColors.codriverDeep,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Anstehend',
                style: AppTypography.headline.copyWith(
                  color: AppColors.codriverGraphite,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'nächste 7 Tage',
                style: AppTypography.footnote.copyWith(
                  color: AppColors.labelSecondaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Center(
                child: Text(
                  'Keine Termine in den nächsten 7 Tagen.',
                  style: AppTypography.footnote.copyWith(
                    color: AppColors.labelTertiaryLight,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ListView(
                children: [
                  for (final entry in grouped.entries) ...[
                    _DayHeader(date: entry.key),
                    const SizedBox(height: 4),
                    for (final e in entry.value)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: _EventTile(event: e),
                      ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  final DateTime date;
  const _DayHeader({required this.date});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('EEE, d. MMMM', _localeForFormat(context));
    final today = DateTime.now();
    final isToday = _sameDay(date, today);
    final isTomorrow = _sameDay(date, today.add(const Duration(days: 1)));
    final label = isToday
        ? 'Heute · ${df.format(date)}'
        : isTomorrow
            ? 'Morgen · ${df.format(date)}'
            : df.format(date);
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 14,
            decoration: BoxDecoration(
              color: isToday
                  ? AppColors.codriverGreen
                  : AppColors.separatorLight.withOpacity(0.6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.caption1.copyWith(
              color: isToday
                  ? AppColors.codriverDeep
                  : AppColors.labelSecondaryLight,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  final _CalEvent event;
  const _EventTile({required this.event});

  Color get _categoryColor {
    final c = event.category.toLowerCase();
    if (c.contains('meeting') || c.contains('plan')) return AppColors.codriverGreen;
    if (c.contains('service') || c.contains('tüv')) return AppColors.warning;
    if (c.contains('hr') || c.contains('onboard')) return const Color(0xFF0A84FF);
    return AppColors.labelSecondaryLight;
  }

  @override
  Widget build(BuildContext context) {
    final tf = DateFormat.Hm(_localeForFormat(context));
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: _categoryColor, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                tf.format(event.start),
                style: AppTypography.footnote.copyWith(
                  color: _categoryColor,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              if (event.category.isNotEmpty) ...[
                const SizedBox(width: 6),
                Text(
                  '· ${event.category}',
                  style: AppTypography.caption2.copyWith(
                    color: AppColors.labelSecondaryLight,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(
            event.title,
            style: AppTypography.subheadline.copyWith(
              color: AppColors.codriverGraphite,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (event.location.isNotEmpty) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(
                  Icons.place_rounded,
                  size: 12,
                  color: AppColors.labelTertiaryLight,
                ),
                const SizedBox(width: 2),
                Flexible(
                  child: Text(
                    event.location,
                    style: AppTypography.caption2.copyWith(
                      color: AppColors.labelSecondaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          if (event.dispatcher.isNotEmpty) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(
                  Icons.headset_mic_rounded,
                  size: 12,
                  color: AppColors.codriverDeep,
                ),
                const SizedBox(width: 2),
                Flexible(
                  child: Text(
                    event.dispatcher,
                    style: AppTypography.caption2.copyWith(
                      color: AppColors.codriverDeep,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

/// Standalone "Anstehende Termine" card — drop into the admin Home
/// dashboard. Streams events from `users/{uid}/calendar_events` and
/// displays the upcoming 7 days, grouped by date.
class CalendarUpcomingCard extends StatefulWidget {
  const CalendarUpcomingCard({super.key});

  @override
  State<CalendarUpcomingCard> createState() => _CalendarUpcomingCardState();
}

class _CalendarUpcomingCardState extends State<CalendarUpcomingCard> {
  Stream<List<_CalEvent>>? _stream;

  @override
  void initState() {
    super.initState();
    _stream = _streamEvents();
  }

  Stream<List<_CalEvent>> _streamEvents() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value(const []);
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('calendar_events')
        .snapshots()
        .map((snap) {
          final out = <_CalEvent>[];
          for (final d in snap.docs) {
            final data = d.data();
            final start = (data['start'] as Timestamp?)?.toDate();
            if (start == null) continue;
            final end = (data['end'] as Timestamp?)?.toDate();
            out.add(
              _CalEvent(
                id: d.id,
                start: start,
                end: end,
                title: (data['title'] ?? '').toString(),
                category: (data['category'] ?? '').toString(),
                location: (data['location'] ?? '').toString(),
                dispatcher: (data['dispatcher'] ?? '').toString(),
              ),
            );
          }
          out.sort((a, b) => a.start.compareTo(b.start));
          return out;
        });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<_CalEvent>>(
      stream: _stream,
      builder: (context, snap) {
        final events = snap.data ?? const <_CalEvent>[];
        return _UpcomingPanel(events: events);
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Helpers
// ════════════════════════════════════════════════════════════════════════════

class _CalEvent {
  final String id;
  final DateTime start;
  final DateTime end; // inclusive last day; equal to start for single-day events
  final String title;
  final String category;
  final String location;
  final String dispatcher; // pinned dispatcher name (optional)
  const _CalEvent({
    required this.id,
    required this.start,
    required DateTime? end,
    required this.title,
    this.category = '',
    this.location = '',
    this.dispatcher = '',
  }) : end = end ?? start;

  bool get isMultiDay =>
      end.year != start.year ||
      end.month != start.month ||
      end.day != start.day;

  bool coversDay(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);
    return !d.isBefore(s) && !d.isAfter(e);
  }
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// ISO 8601 calendar-week number — week starts Monday, week 1 is the
/// week with the year's first Thursday.
int _isoWeek(DateTime date) {
  final thursday = date.add(Duration(days: 4 - ((date.weekday + 6) % 7 + 1)));
  final firstThursday = DateTime(thursday.year, 1, 4);
  final firstThursdayWeekStart = firstThursday.subtract(
    Duration(days: (firstThursday.weekday + 6) % 7),
  );
  final diff = thursday.difference(firstThursdayWeekStart).inDays;
  return (diff / 7).floor() + 1;
}

/// Build a list of weeks (each a list of 7 DateTimes Mon-Sun) covering
/// the entire visible month, including leading days from the previous
/// month and trailing days from the next.
List<List<DateTime>> _buildWeeks(DateTime visibleMonth) {
  final firstOfMonth = DateTime(visibleMonth.year, visibleMonth.month, 1);
  // Monday-start: weekday 1 (Mon) → 0 days back, 7 (Sun) → 6 days back.
  final start = firstOfMonth.subtract(
    Duration(days: (firstOfMonth.weekday + 6) % 7),
  );
  final lastOfMonth = DateTime(visibleMonth.year, visibleMonth.month + 1, 0);
  // Always render whole weeks; pad to the last Sunday of the visible
  // span so the grid is rectangular.
  final end = lastOfMonth.add(
    Duration(days: 7 - ((lastOfMonth.weekday + 6) % 7) - 1),
  );

  final weeks = <List<DateTime>>[];
  var cursor = start;
  while (!cursor.isAfter(end)) {
    final week = <DateTime>[];
    for (var i = 0; i < 7; i++) {
      week.add(cursor.add(Duration(days: i)));
    }
    weeks.add(week);
    cursor = cursor.add(const Duration(days: 7));
  }
  return weeks;
}

String _localeForFormat(BuildContext context) {
  final code = Localizations.localeOf(context).languageCode;
  return code.isEmpty ? 'en' : code;
}

// ════════════════════════════════════════════════════════════════════════════
//  Add-event dialog
// ════════════════════════════════════════════════════════════════════════════

class _NewEventResult {
  final String title;
  final String category;
  final String location;
  final String dispatcher;
  final DateTime start;
  final DateTime end;
  const _NewEventResult({
    required this.title,
    required this.category,
    required this.location,
    required this.dispatcher,
    required this.start,
    required this.end,
  });
}

class _AddEventDialog extends StatefulWidget {
  final DateTime? prefillStart;
  const _AddEventDialog({this.prefillStart});

  @override
  State<_AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<_AddEventDialog> {
  final _titleCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  String _category = 'Meeting';
  String _dispatcher = '';
  late DateTime _start;
  late DateTime _end;
  bool _multiDay = false;

  Stream<List<String>> _dispatcherStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value(const []);
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('settings')
        .doc('dispatcher_pill')
        .snapshots()
        .map((doc) {
          final raw = (doc.data() ?? const {})['dispatchers'];
          if (raw is! List) return const <String>[];
          final out = <String>[];
          for (final row in raw) {
            if (row is Map) {
              final n = (row['name'] ?? '').toString().trim();
              if (n.isNotEmpty) out.add(n);
            }
          }
          return out;
        });
  }

  static const _categories = [
    'Meeting',
    'Service',
    'Mietfahrzeug',
    'HR',
    'Planning',
    'Sonstiges',
  ];

  @override
  void initState() {
    super.initState();
    final base = widget.prefillStart ?? DateTime.now();
    _start = DateTime(base.year, base.month, base.day, 9, 0);
    _end = DateTime(base.year, base.month, base.day, 10, 0);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool start) async {
    final result = await showDialog<_PickerResult>(
      context: context,
      builder: (ctx) => _CodriverDatePickerDialog(
        initial: start ? _start : _end,
        allowWeekSelection: true,
      ),
    );
    if (result == null) return;
    setState(() {
      if (result.weekStart != null && result.weekEnd != null) {
        // Whole-week selection — switch to multi-day automatically.
        _multiDay = true;
        final ws = result.weekStart!;
        final we = result.weekEnd!;
        _start = DateTime(ws.year, ws.month, ws.day, _start.hour, _start.minute);
        _end = DateTime(we.year, we.month, we.day, _end.hour, _end.minute);
      } else if (result.day != null) {
        final p = result.day!;
        if (start) {
          _start = DateTime(p.year, p.month, p.day, _start.hour, _start.minute);
          if (_end.isBefore(_start)) _end = _start;
        } else {
          _end = DateTime(p.year, p.month, p.day, _end.hour, _end.minute);
        }
      }
    });
  }

  bool get _valid => _titleCtrl.text.trim().isNotEmpty;

  void _submit() {
    if (!_valid) return;
    Navigator.of(context).pop(
      _NewEventResult(
        title: _titleCtrl.text.trim(),
        category: _category,
        location: _locationCtrl.text.trim(),
        dispatcher: _dispatcher,
        start: _start,
        end: _multiDay ? _end : _start,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('EEE, d. MMMM y', _localeForFormat(context));
    return AlertDialog(
      title: const Text('Neuer Termin'),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleCtrl,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Titel',
                hintText: 'z.B. Mietfahrzeug-Abholung Sixt',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Kategorie',
              ),
              items: [
                for (final c in _categories)
                  DropdownMenuItem(value: c, child: Text(c)),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _category = v);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _locationCtrl,
              decoration: const InputDecoration(
                labelText: 'Ort (optional)',
                hintText: 'z.B. Sixt Stuttgart Hbf',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Dispatcher dropdown — streamed from Dispatcher-Pill page.
            StreamBuilder<List<String>>(
              stream: _dispatcherStream(),
              builder: (context, snap) {
                final names = snap.data ?? const <String>[];
                final items = ['', ...names]; // empty = no pin
                final value = items.contains(_dispatcher) ? _dispatcher : '';
                return DropdownButtonFormField<String>(
                  value: value,
                  decoration: const InputDecoration(
                    labelText: 'Dispatcher anheften (optional)',
                    prefixIcon: Icon(
                      Icons.headset_mic_rounded,
                      size: 18,
                    ),
                  ),
                  items: [
                    for (final n in items)
                      DropdownMenuItem(
                        value: n,
                        child: Text(n.isEmpty ? '— kein Dispatcher —' : n),
                      ),
                  ],
                  onChanged: (v) =>
                      setState(() => _dispatcher = v ?? ''),
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            // Multi-day toggle
            Row(
              children: [
                Switch(
                  value: _multiDay,
                  onChanged: (v) => setState(() => _multiDay = v),
                  activeColor: AppColors.codriverGreen,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Mehrtägiger Termin',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            // Start date
            _DateRow(
              label: _multiDay ? 'Von' : 'Datum',
              value: df.format(_start),
              onPick: () => _pickDate(true),
            ),
            if (_multiDay) ...[
              const SizedBox(height: AppSpacing.xs),
              _DateRow(
                label: 'Bis',
                value: df.format(_end),
                onPick: () => _pickDate(false),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: _valid ? _submit : null,
          child: const Text('Speichern'),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Custom Codriver date picker — Mon-Sun, KW column on the left
//  (click a KW → whole week is returned as range).
// ════════════════════════════════════════════════════════════════════════════

class _PickerResult {
  /// Set when a single day was picked.
  final DateTime? day;
  /// Set when a KW row was clicked — both populated together.
  final DateTime? weekStart;
  final DateTime? weekEnd;
  const _PickerResult.day(DateTime d) : day = d, weekStart = null, weekEnd = null;
  const _PickerResult.week(DateTime s, DateTime e)
      : day = null,
        weekStart = s,
        weekEnd = e;
}

class _CodriverDatePickerDialog extends StatefulWidget {
  final DateTime initial;
  final bool allowWeekSelection;
  const _CodriverDatePickerDialog({
    required this.initial,
    this.allowWeekSelection = true,
  });

  @override
  State<_CodriverDatePickerDialog> createState() =>
      _CodriverDatePickerDialogState();
}

class _CodriverDatePickerDialogState extends State<_CodriverDatePickerDialog> {
  late DateTime _visibleMonth;
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    _visibleMonth = DateTime(widget.initial.year, widget.initial.month);
    _selected = DateTime(
      widget.initial.year,
      widget.initial.month,
      widget.initial.day,
    );
  }

  void _gotoMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('MMMM yyyy', _localeForFormat(context));
    final weeks = _buildWeeks(_visibleMonth);
    final today = DateTime.now();

    return Dialog(
      insetPadding: const EdgeInsets.all(AppSpacing.lg),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  df.format(_visibleMonth),
                  style: AppTypography.title3.copyWith(
                    color: AppColors.codriverGraphite,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _MiniIconButton(
                  icon: Icons.chevron_left_rounded,
                  onTap: () => _gotoMonth(-1),
                ),
                const SizedBox(width: 4),
                _MiniIconButton(
                  icon: Icons.chevron_right_rounded,
                  onTap: () => _gotoMonth(1),
                ),
                const Spacer(),
                if (widget.allowWeekSelection)
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
                      'KW klicken = ganze Woche',
                      style: AppTypography.caption2.copyWith(
                        color: AppColors.codriverDeep,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Weekday header — Mon to Sun
            Row(
              children: [
                const SizedBox(width: 50),
                for (final wd in const ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'])
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        wd,
                        style: AppTypography.caption2.copyWith(
                          color: AppColors.labelSecondaryLight,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            // Week rows
            for (final week in weeks)
              SizedBox(
                height: 44,
                child: Row(
                  children: [
                    // KW label — clickable to select whole week
                    SizedBox(
                      width: 50,
                      child: MouseRegion(
                        cursor: widget.allowWeekSelection
                            ? SystemMouseCursors.click
                            : SystemMouseCursors.basic,
                        child: GestureDetector(
                          onTap: widget.allowWeekSelection
                              ? () {
                                  Navigator.of(context).pop(
                                    _PickerResult.week(
                                      week.first,
                                      week.last,
                                    ),
                                  );
                                }
                              : null,
                          child: Container(
                            margin: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.separatorLight
                                    .withOpacity(0.5),
                                width: 0.6,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'KW ${_isoWeek(week.first)}',
                              style: AppTypography.caption2.copyWith(
                                color: AppColors.codriverDeep,
                                fontWeight: FontWeight.w700,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    for (final day in week)
                      Expanded(
                        child: _PickerDayCell(
                          day: day,
                          inMonth: day.month == _visibleMonth.month,
                          isToday: _sameDay(day, today),
                          isSelected: _sameDay(day, _selected),
                          onTap: () {
                            Navigator.of(context).pop(
                              _PickerResult.day(day),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Abbrechen'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerDayCell extends StatelessWidget {
  final DateTime day;
  final bool inMonth;
  final bool isToday;
  final bool isSelected;
  final VoidCallback onTap;
  const _PickerDayCell({
    required this.day,
    required this.inMonth,
    required this.isToday,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = !inMonth
        ? AppColors.labelTertiaryLight
        : (isSelected || isToday
            ? Colors.white
            : AppColors.codriverGraphite);
    final bg = isSelected
        ? AppColors.codriverGreen
        : (isToday
            ? AppColors.codriverGreen.withOpacity(0.18)
            : Colors.transparent);
    final fgToday = isSelected ? Colors.white : AppColors.codriverDeep;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: isToday && !isSelected
                ? Border.all(
                    color: AppColors.codriverGreen,
                    width: 1.5,
                  )
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            '${day.day}',
            style: AppTypography.subheadline.copyWith(
              color: isToday && !isSelected ? fgToday : fg,
              fontWeight: isSelected || isToday
                  ? FontWeight.w700
                  : FontWeight.w500,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MiniIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: AppColors.codriverDeep),
        ),
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onPick;
  const _DateRow({
    required this.label,
    required this.value,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: AppTypography.footnote.copyWith(
              color: AppColors.labelSecondaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: onPick,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: AppColors.codriverDeep,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    value,
                    style: AppTypography.subheadline.copyWith(
                      color: AppColors.codriverGraphite,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
