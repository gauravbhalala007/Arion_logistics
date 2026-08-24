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

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/admin_scope.dart';
import '../widgets/co_button.dart';
import '../widgets/co_pressable.dart';
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
  const AdminCalendarSection({super.key, this.collapsibleDayPanel = false});

  /// When true (dashboard embed) the day-events panel stays hidden until a
  /// day is tapped — the month grid gets the full width.
  final bool collapsibleDayPanel;

  @override
  State<AdminCalendarSection> createState() => _AdminCalendarPageState();
}

/// Opens the add-event dialog and saves the result. Public so the home
/// dashboard's "+ Termin" button can use the exact same flow.
Future<void> showAddCalendarEventDialog(BuildContext context) async {
  final result = await showDialog<_NewEventResult>(
    context: context,
    builder: (ctx) => _AddEventDialog(prefillStart: DateTime.now()),
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
      // Backward compatible: only write the field when it has content.
      if (result.description.isNotEmpty) 'description': result.description,
      'createdAt': FieldValue.serverTimestamp(),
    });
    if (!context.mounted) return;
    final de = Localizations.localeOf(context).languageCode == 'de';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(de
            ? 'Termin "${result.title}" hinzugefügt.'
            : 'Event "${result.title}" added.'),
      ),
    );
  } catch (e) {
    if (!context.mounted) return;
    final de = Localizations.localeOf(context).languageCode == 'de';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(de ? 'Fehler beim Speichern: $e' : 'Error while saving: $e'),
      ),
    );
  }
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

  Stream<List<_CalEvent>> _streamEvents() => _streamAllCalendarEvents();

  Future<void> _showEventDetail(_CalEvent event) =>
      showCalendarEventDetail(context, event);

  /// Whether the inline day panel is visible. The dashboard embed
  /// (collapsible mode) never shows it inline — day taps open a popup
  /// instead, so the month grid keeps its full width.
  bool get _showDayPanel => !widget.collapsibleDayPanel;

  /// Day tap: select + (dashboard embed) open the day popup.
  void _handleSelectDay(DateTime d) {
    setState(() => _selectedDay = d);
    if (widget.collapsibleDayPanel) _openDayPopup(d);
  }

  /// Dashboard embed: the day's events as a popup dialog instead of an
  /// inline panel that would crush the month grid.
  ///
  /// Wichtig: _DayEventsPanel enthält Expanded-Kinder und braucht daher
  /// eine TIGHT begrenzte Höhe — sonst wirft das Layout im Release-Build
  /// (grauer ErrorWidget-Kasten statt Inhalt).
  Future<void> _openDayPopup(DateTime day) async {
    final screen = MediaQuery.of(context).size;
    final width = screen.width < 470 ? screen.width - 48 : 420.0;
    final height =
        (screen.height - 120).clamp(320.0, 540.0).toDouble();
    // Eigener Stream fürs Popup: _eventsStream ist single-subscription
    // (StreamController) und wird bereits vom Monats-Grid gehört — ein
    // zweites listen() darauf wirft "Stream has already been listened
    // to" und ließ das Popup als grauen ErrorWidget-Kasten rendern.
    final popupStream = _streamAllCalendarEvents();
    await showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              StreamBuilder<List<_CalEvent>>(
                stream: popupStream,
                builder: (ctx2, snap) => _DayEventsPanel(
                  selectedDay: day,
                  events: snap.data ?? const <_CalEvent>[],
                  onEventTap: (e) => _showEventDetail(e),
                  onAddForSelected: () => _addEvent(prefillStart: day),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: InkWell(
                  onTap: () => Navigator.of(ctx).pop(),
                  borderRadius: BorderRadius.circular(999),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.close_rounded,
                        size: 20, color: Color(0xFF6B7280)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
            // Backward compatible: only write the field when it has content.
            if (result.description.isNotEmpty)
              'description': result.description,
            'createdAt': FieldValue.serverTimestamp(),
          });
      if (!mounted) return;
      final de = Localizations.localeOf(context).languageCode == 'de';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(de
              ? 'Termin "${result.title}" hinzugefügt.'
              : 'Event "${result.title}" added.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final de = Localizations.localeOf(context).languageCode == 'de';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(de ? 'Fehler beim Speichern: $e' : 'Error while saving: $e'),
        ),
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
    final width = MediaQuery.of(context).size.width;
    final isNarrow = width < 1100;
    final isMobile = width < 700;
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
              isMobile: isMobile,
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
                            onSelectDay: _handleSelectDay,
                            onEventTap: _showEventDetail,
                            isMobile: isMobile,
                          ),
                        ),
                        if (_showDayPanel) ...[
                          const SizedBox(height: AppSpacing.md),
                          SizedBox(
                            height: isMobile ? 360 : 280,
                            child: _DayEventsPanel(
                              selectedDay: _selectedDay,
                              events: events,
                              onEventTap: _showEventDetail,
                              onAddForSelected: () =>
                                  _addEvent(prefillStart: _selectedDay),
                            ),
                          ),
                        ],
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
                            onSelectDay: _handleSelectDay,
                            onEventTap: _showEventDetail,
                            isMobile: false,
                          ),
                        ),
                        if (_showDayPanel) ...[
                          const SizedBox(width: AppSpacing.md),
                          SizedBox(
                            width: 320,
                            child: _DayEventsPanel(
                              selectedDay: _selectedDay,
                              events: events,
                              onEventTap: _showEventDetail,
                              onAddForSelected: () =>
                                  _addEvent(prefillStart: _selectedDay),
                            ),
                          ),
                        ],
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
  final bool isMobile;
  const _Header({
    required this.visibleMonth,
    required this.onPrev,
    required this.onNext,
    required this.onToday,
    required this.onAddEvent,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    // Wider screens get the full month name; on mobile we use the
    // short variant ("Mai 2026") so it fits next to nav + actions.
    final monthFmt = isMobile ? 'MMM yyyy' : 'MMMM yyyy';
    final df = DateFormat(monthFmt, _localeForFormat(context));
    final btnSize = isMobile ? 32.0 : 38.0;
    final titleStyle = (isMobile ? AppTypography.headline : AppTypography.title2)
        .copyWith(color: AppColors.codriverGraphite);

    return Row(
      children: [
        Flexible(
          child: Text(
            df.format(visibleMonth),
            style: titleStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        _RoundIconButton(
          icon: Icons.chevron_left_rounded,
          onTap: onPrev,
          size: btnSize,
        ),
        const SizedBox(width: AppSpacing.xs),
        _RoundIconButton(
          icon: Icons.chevron_right_rounded,
          onTap: onNext,
          size: btnSize,
        ),
        const SizedBox(width: AppSpacing.xs),
        // On mobile the "Heute" pill collapses to an icon button to
        // save horizontal space.
        if (isMobile)
          _RoundIconButton(
            icon: Icons.today_rounded,
            onTap: onToday,
            size: btnSize,
          )
        else ...[
          const SizedBox(width: AppSpacing.xs),
          _PillButton(label: de ? 'Heute' : 'Today', onTap: onToday),
        ],
        const Spacer(),
        _AddEventButton(onTap: onAddEvent, isMobile: isMobile),
      ],
    );
  }
}

/// Primary CTA in the top-right corner of the calendar — opens the
/// dialog to create a new event (single-day or multi-day).
class _AddEventButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isMobile;
  const _AddEventButton({required this.onTap, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final h = isMobile ? 32.0 : 38.0;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: CoPressable(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: h,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? AppSpacing.sm : AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.codriverGreen,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.18)),
            boxShadow: AppElevation.level1,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_rounded,
                size: isMobile ? 16 : 18,
                color: Colors.white,
              ),
              if (!isMobile) ...[
                const SizedBox(width: 4),
                Text(
                  de ? 'Termin' : 'Event',
                  style: AppTypography.subheadline.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
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
  final double size;
  const _RoundIconButton({
    required this.icon,
    required this.onTap,
    this.size = 38,
  });
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: CoPressable(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevatedLight,
            shape: BoxShape.circle,
            boxShadow: AppElevation.level1,
            border: Border.all(
              color: AppColors.separatorLight.withOpacity(0.4),
              width: 0.5,
            ),
          ),
          child: Icon(icon, size: size * 0.52, color: AppColors.codriverDeep),
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
      child: CoPressable(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
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
  final ValueChanged<_CalEvent> onEventTap;
  final bool isMobile;

  const _CalendarGrid({
    required this.visibleMonth,
    required this.selectedDay,
    required this.events,
    required this.onSelectDay,
    required this.onEventTap,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final weeks = _buildWeeks(visibleMonth);
    final today = DateTime.now();
    // The KW (Kalenderwoche) column is kept on every viewport; on
    // mobile we just shrink it to a 24-px stripe with the bare week
    // number (no "KW " prefix) so day cells still have room.
    final kwWidth = isMobile ? 24.0 : 56.0;
    final outerPadding = isMobile ? AppSpacing.sm : AppSpacing.lg;
    final radius = isMobile ? 14.0 : 20.0;

    return Container(
      padding: EdgeInsets.all(outerPadding),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevatedLight,
        borderRadius: BorderRadius.circular(radius),
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
              if (kwWidth > 0)
                SizedBox(
                  width: kwWidth,
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      'KW',
                      style: AppTypography.caption2.copyWith(
                        color: AppColors.labelTertiaryLight,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        fontSize: isMobile ? 9 : null,
                      ),
                    ),
                  ),
                ),
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
          // Week rows — KW label (desktop only) + 7 day cells each
          Expanded(
            child: Column(
              children: [
                for (final week in weeks)
                  Expanded(
                    child: Row(
                      children: [
                        if (kwWidth > 0)
                          SizedBox(
                            width: kwWidth,
                            child: Center(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 4 : 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isMobile
                                      ? '${_isoWeek(week.first)}'
                                      : 'KW ${_isoWeek(week.first)}',
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
                              onEventTap: onEventTap,
                              isMobile: isMobile,
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
  final ValueChanged<_CalEvent> onEventTap;
  final bool isMobile;

  const _DayCell({
    required this.day,
    required this.inMonth,
    required this.isToday,
    required this.isSelected,
    required this.events,
    required this.onTap,
    required this.onEventTap,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final fg = !inMonth
        ? AppColors.labelTertiaryLight
        : AppColors.codriverGraphite;
    final cellBg = !inMonth
        ? AppColors.surfaceLight.withOpacity(0.4)
        : AppColors.surfaceLight;

    // Mobile uses just the day number (1-31) instead of "DD.MM" because
    // each cell is only ~45px wide on a phone screen.
    final dateLabel = isMobile
        ? '${day.day}'
        : '${day.day.toString().padLeft(2, '0')}.${day.month.toString().padLeft(2, '0')}';

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: CoPressable(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
        child: Container(
          margin: EdgeInsets.all(isMobile ? 1.5 : 3),
          padding: isMobile
              ? const EdgeInsets.fromLTRB(3, 3, 3, 3)
              : const EdgeInsets.fromLTRB(6, 6, 6, 4),
          decoration: BoxDecoration(
            color: cellBg,
            borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
            border: Border.all(
              color: isSelected
                  ? AppColors.codriverGreen
                  : AppColors.separatorLight.withOpacity(0.35),
              width: isSelected ? 1.5 : 0.6,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Date pill — today gets the brand pill, otherwise plain.
              Align(
                alignment: isMobile ? Alignment.center : Alignment.topLeft,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 4 : 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isToday
                        ? AppColors.codriverGreen
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    dateLabel,
                    style: AppTypography.caption1.copyWith(
                      color: isToday ? Colors.white : fg,
                      fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      fontSize: isMobile ? 11.5 : null,
                    ),
                  ),
                ),
              ),
              SizedBox(height: isMobile ? 2 : 4),
              // Events: on mobile show colored dots (no titles, no room);
              // on desktop show full event bars with labels — each bar
              // taps through to the event detail dialog.
              Expanded(
                child: isMobile
                    ? _MobileEventDots(
                        events: events,
                        colorOf: _categoryColorFor,
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < events.length && i < 3; i++)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: _EventBar(
                                event: events[i],
                                day: day,
                                color:
                                    _categoryColorFor(events[i].category),
                                onTap: () => onEventTap(events[i]),
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

/// Compact event indicator for mobile day cells: up to 4 colored dots
/// in a row, then a "+N" overflow label. The titles can't fit in a
/// ~45px cell so we lean on color alone — the upcoming-panel below
/// gives the labels.
class _MobileEventDots extends StatelessWidget {
  final List<_CalEvent> events;
  final Color Function(String category) colorOf;
  const _MobileEventDots({required this.events, required this.colorOf});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const SizedBox.shrink();
    const maxDots = 4;
    final visible = events.take(maxDots).toList();
    final overflow = events.length - visible.length;
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 3,
        runSpacing: 2,
        children: [
          for (final e in visible)
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: colorOf(e.category),
                shape: BoxShape.circle,
              ),
            ),
          if (overflow > 0)
            Text(
              '+$overflow',
              style: AppTypography.caption2.copyWith(
                fontSize: 9,
                color: AppColors.labelSecondaryLight,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
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
  final VoidCallback? onTap;
  const _EventBar({
    required this.event,
    required this.day,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isFirst = _sameDay(event.start, day);
    final isLast = _sameDay(event.end, day);
    final isStartOfWeek = day.weekday == DateTime.monday;
    final isEndOfWeek = day.weekday == DateTime.sunday;

    final leftRound = isFirst || isStartOfWeek;
    final rightRound = isLast || isEndOfWeek;

    final bar = Container(
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

    if (onTap == null) return bar;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: CoPressable(
        onTap: onTap,
        child: bar,
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Upcoming panel (right column) — events in the next 7 days
// ════════════════════════════════════════════════════════════════════════════

/// Side panel that lists the events covering the currently selected
/// day. Replaces the older "next 7 days" view — clicking a day in the
/// grid drives this list. Tapping a tile opens the event detail.
class _DayEventsPanel extends StatelessWidget {
  final DateTime? selectedDay;
  final List<_CalEvent> events;
  final ValueChanged<_CalEvent> onEventTap;
  final VoidCallback onAddForSelected;

  const _DayEventsPanel({
    required this.selectedDay,
    required this.events,
    required this.onEventTap,
    required this.onAddForSelected,
  });

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final today = DateTime.now();
    final day = selectedDay ?? DateTime(today.year, today.month, today.day);
    final isToday = _sameDay(day, today);
    final df = DateFormat('EEE, d. MMMM yyyy', _localeForFormat(context));
    final filtered = events.where((e) => e.coversDay(day)).toList()
      ..sort((a, b) => a.start.compareTo(b.start));
    final subtitle = isToday
        ? '${de ? 'Heute' : 'Today'} · ${df.format(day)}'
        : df.format(day);

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
              Expanded(
                child: Text(
                  de ? 'Termine' : 'Events',
                  style: AppTypography.headline.copyWith(
                    color: AppColors.codriverGraphite,
                  ),
                ),
              ),
              if (filtered.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.green50,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${filtered.length}',
                    style: AppTypography.caption2.copyWith(
                      color: AppColors.codriverDeep,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTypography.footnote.copyWith(
              color: AppColors.labelSecondaryLight,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: CoStateSwitcher(
              child: filtered.isEmpty
                  ? Center(
                      key: const ValueKey('day-events-empty'),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.event_busy_rounded,
                            size: 28,
                            color: AppColors.labelTertiaryLight.withOpacity(0.6),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            de
                                ? 'Keine Termine an diesem Tag.'
                                : 'No events on this day.',
                            style: AppTypography.footnote.copyWith(
                              color: AppColors.labelTertiaryLight,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          CoButton(
                            onPressed: onAddForSelected,
                            label: de ? 'Termin hinzufügen' : 'Add event',
                            icon: Icons.add_rounded,
                            variant: CoButtonVariant.quiet,
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      key: const ValueKey('day-events-list'),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (_, i) => _EventTile(
                        event: filtered[i],
                        onTap: () => onEventTap(filtered[i]),
                      ),
                    ),
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
  final VoidCallback? onTap;
  const _EventTile({required this.event, this.onTap});

  @override
  Widget build(BuildContext context) {
    final tf = DateFormat.Hm(_localeForFormat(context));
    final color = _categoryColorFor(event.category);
    final card = Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: color, width: 4),
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
                  color: color,
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
          if (event.description.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              event.description,
              style: AppTypography.caption2.copyWith(
                color: AppColors.labelSecondaryLight,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
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
    if (onTap == null) return card;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: CoPressable(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: card,
      ),
    );
  }
}

/// Compact one-line event tile for the dashboard "upcoming" card:
/// `| 09:00  Title … 📍`. Full details open on tap.
class _CompactEventTile extends StatelessWidget {
  final _CalEvent event;
  final VoidCallback? onTap;
  const _CompactEventTile({required this.event, this.onTap});

  @override
  Widget build(BuildContext context) {
    final tf = DateFormat.Hm(_localeForFormat(context));
    final color = _categoryColorFor(event.category);
    final card = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(9),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                tf.format(event.start),
                style: AppTypography.caption1.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  event.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.footnote.copyWith(
                    color: AppColors.codriverGraphite,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (event.dispatcher.isNotEmpty) ...[
                const SizedBox(width: 6),
                const Icon(
                  Icons.headset_mic_rounded,
                  size: 11,
                  color: AppColors.codriverDeep,
                ),
              ],
              if (event.location.isNotEmpty) ...[
                const SizedBox(width: 4),
                const Icon(
                  Icons.place_rounded,
                  size: 11,
                  color: AppColors.labelTertiaryLight,
                ),
              ],
            ],
          ),
          // Truncated description — one line, secondary color, so the
          // dashboard tile stays compact. Full text lives in the detail.
          if (event.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text(
                event.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption2.copyWith(
                  color: AppColors.labelSecondaryLight,
                ),
              ),
            ),
        ],
      ),
    );
    if (onTap == null) return card;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: CoPressable(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: card,
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
    return _streamAllCalendarEvents();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<_CalEvent>>(
      stream: _stream,
      builder: (context, snap) {
        final events = snap.data ?? const <_CalEvent>[];
        return _UpcomingHomePanel(events: events);
      },
    );
  }
}

/// Compact "next 7 days" card used on the admin home dashboard. The
/// detail-page calendar uses [_DayEventsPanel] instead (per-day view);
/// this widget is intentionally kept simple and read-only.
class _UpcomingHomePanel extends StatelessWidget {
  final List<_CalEvent> events;
  const _UpcomingHomePanel({required this.events});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final filtered = events
        .where((e) => !e.start.isBefore(today))
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));

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
          Builder(builder: (context) {
            final de = Localizations.localeOf(context).languageCode == 'de';
            return Row(
              children: [
                const Icon(Icons.event_rounded,
                    size: 18, color: AppColors.codriverDeep),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          de ? 'Anstehende Termine' : 'Upcoming events',
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.headline.copyWith(
                            color: AppColors.codriverGraphite,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (filtered.isNotEmpty)
                        Text(
                          '${filtered.length}',
                          style: AppTypography.footnote.copyWith(
                            color: AppColors.labelSecondaryLight,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                ),
                CoIconButton(
                  onPressed: () => Navigator.of(context)
                      .pushNamedAndRemoveUntil('/calendar', (r) => false),
                  icon: Icons.calendar_month_rounded,
                  size: 34,
                  tooltip: de ? 'Zum Kalender' : 'Open calendar',
                ),
                const SizedBox(width: 6),
                CoIconButton(
                  onPressed: () => showAddCalendarEventDialog(context),
                  icon: Icons.add_rounded,
                  size: 34,
                  tooltip: de ? 'Termin hinzufügen' : 'Add event',
                ),
              ],
            );
          }),
          const SizedBox(height: AppSpacing.sm),
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Center(
                child: Builder(builder: (context) {
                  final de =
                      Localizations.localeOf(context).languageCode == 'de';
                  return Text(
                    de ? 'Keine anstehenden Termine.' : 'No upcoming events.',
                    style: AppTypography.footnote.copyWith(
                      color: AppColors.labelTertiaryLight,
                      fontStyle: FontStyle.italic,
                    ),
                  );
                }),
              ),
            )
          else
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Side-by-side compact tiles when the card is wide enough
                  // (desktop dashboard); single column on narrow screens.
                  const gap = 6.0;
                  final cols = constraints.maxWidth >= 520 ? 2 : 1;
                  final tileW =
                      (constraints.maxWidth - (cols - 1) * gap) / cols;
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final entry in grouped.entries) ...[
                          _DayHeader(date: entry.key),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: gap,
                            runSpacing: gap,
                            children: [
                              for (final e in entry.value)
                                SizedBox(
                                  width: tileW,
                                  child: Builder(
                                    builder: (ctx) => _CompactEventTile(
                                      event: e,
                                      onTap: () =>
                                          showCalendarEventDetail(ctx, e),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                      ],
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

/// Top-level unified event stream — demo baseline + manual calendar
/// entries + Fleet-Hub events. Each source contributes independently;
/// if the Fleet collection-group query is denied (no rule yet) or the
/// user has no vehicles, demos + manual events still show.
Stream<List<_CalEvent>> _streamAllCalendarEvents() {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value(_topLevelDemoEvents());
  final uid = user.uid;

  late StreamController<List<_CalEvent>> ctrl;
  var calendar = <_CalEvent>[];
  var fleet = <_CalEvent>[];
  StreamSubscription? subCal, subFleet;

  void emit() {
    // Only real Codriver data — manual calendar entries + Fleet-Hub events.
    // No demo / placeholder content.
    final out = <_CalEvent>[
      ...calendar,
      ...fleet,
    ]..sort((a, b) => a.start.compareTo(b.start));
    if (!ctrl.isClosed) ctrl.add(out);
  }

  ctrl = StreamController<List<_CalEvent>>(
    onListen: () {
      // Emit demos immediately so the screen is never blank.
      emit();

      // Manual calendar entries
      subCal = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('calendar_events')
          .snapshots()
          .listen(
        (snap) {
          calendar = [
            for (final d in snap.docs)
              if ((d.data()['start'] as Timestamp?) != null)
                _CalEvent(
                  id: 'cal:${d.id}',
                  start: (d.data()['start'] as Timestamp).toDate(),
                  end: (d.data()['end'] as Timestamp?)?.toDate(),
                  title: (d.data()['title'] ?? '').toString(),
                  category: (d.data()['category'] ?? '').toString(),
                  location: (d.data()['location'] ?? '').toString(),
                  dispatcher: (d.data()['dispatcher'] ?? '').toString(),
                  description: (d.data()['description'] ?? '').toString(),
                ),
          ];
          emit();
        },
        onError: (_) {
          // Permission/connection issue — keep demos.
          calendar = const [];
          emit();
        },
      );

      // Fleet-Hub events (TÜV, service, accidents, …) via collection group.
      subFleet = FirebaseFirestore.instance
          .collectionGroup('events')
          .where('dspUid', isEqualTo: uid)
          .where('isDeleted', isEqualTo: false)
          .snapshots()
          .listen(
        (snap) {
          final out = <_CalEvent>[];
          for (final d in snap.docs) {
            final data = d.data();
            final parsed = _topLevelParseFleetDate(
              (data['eventDate'] ?? '').toString().trim(),
            );
            if (parsed == null) continue;
            final type = (data['eventType'] ?? '').toString();
            final plate = (data['plateNumber'] ?? '').toString();
            final title = (data['title'] ?? '').toString().trim();
            out.add(
              _CalEvent(
                id: 'fleet:${d.id}',
                start: parsed,
                end: null,
                title: title.isNotEmpty
                    ? '$plate · $title'
                    : '$plate · ${_topLevelPrettyFleetType(type)}',
                category: _topLevelFleetCategoryFor(type),
                location: '',
                dispatcher: '',
              ),
            );
          }
          fleet = out;
          emit();
        },
        onError: (_) {
          // Collection-group rule may be missing — gracefully ignore.
          fleet = const [];
          emit();
        },
      );
    },
    onCancel: () async {
      await subCal?.cancel();
      await subFleet?.cancel();
    },
  );

  return ctrl.stream;
}

List<_CalEvent> _topLevelDemoEvents() {
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

DateTime? _topLevelParseFleetDate(String raw) {
  if (raw.isEmpty) return null;
  final iso = DateTime.tryParse(raw);
  if (iso != null) return DateTime(iso.year, iso.month, iso.day, 9);
  final m = RegExp(r'^(\d{1,2})\.(\d{1,2})\.(\d{4})').firstMatch(raw);
  if (m != null) {
    return DateTime(
      int.parse(m.group(3)!),
      int.parse(m.group(2)!),
      int.parse(m.group(1)!),
      9,
    );
  }
  return null;
}

String _topLevelPrettyFleetType(String type) {
  switch (type.trim().toUpperCase()) {
    case 'SERVICE':
      return 'Service';
    case 'ACCIDENT':
      return 'Unfall';
    case 'TYRE_CHANGE':
      return 'Reifenwechsel';
    case 'INSPECTION':
      return 'Inspektion';
    case 'BREAKDOWN':
      return 'Panne';
    case 'REPAIR':
      return 'Reparatur';
    case 'DOCUMENT_RENEWAL':
      return 'TÜV / Dokumente';
    case 'CUSTOM':
      return 'Sonstiges';
    default:
      return type;
  }
}

String _topLevelFleetCategoryFor(String type) {
  switch (type.trim().toUpperCase()) {
    case 'INSPECTION':
    case 'DOCUMENT_RENEWAL':
      return 'TÜV';
    case 'SERVICE':
    case 'TYRE_CHANGE':
    case 'REPAIR':
      return 'Service';
    case 'ACCIDENT':
    case 'BREAKDOWN':
      return 'Sonstiges';
    default:
      return 'Service';
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Helpers
// ════════════════════════════════════════════════════════════════════════════

/// Strips the `cal:` prefix from a stream-emitted event id back to
/// the underlying Firestore doc id. Returns null for fleet/demo
/// events which can't be edited or deleted from the calendar surface.
String? _calendarDocIdFor(_CalEvent event) {
  const prefix = 'cal:';
  if (!event.id.startsWith(prefix)) return null;
  return event.id.substring(prefix.length);
}

/// Read-only detail popup with optional Edit / Delete actions. Lives
/// at top-level so the home-dashboard upcoming card and the calendar
/// page can both reach it.
Future<void> showCalendarEventDetail(
  BuildContext context,
  _CalEvent event,
) async {
  final df = DateFormat(
    event.isMultiDay ? 'EEE, d. MMM yyyy' : 'EEE, d. MMMM yyyy',
    _localeForFormat(context),
  );
  final tf = DateFormat.Hm(_localeForFormat(context));
  final timeLabel = event.isMultiDay
      ? '${df.format(event.start)} — ${df.format(event.end)}'
      : '${df.format(event.start)} · ${tf.format(event.start)}';
  final color = _categoryColorFor(event.category);

  Widget detailRow(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: AppColors.codriverDeep),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: AppTypography.footnote.copyWith(
                  color: AppColors.codriverGraphite,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );

  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 28,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              event.title.isEmpty ? '—' : event.title,
              style: AppTypography.title3.copyWith(
                color: AppColors.codriverGraphite,
              ),
            ),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            detailRow(Icons.access_time_rounded, timeLabel),
            if (event.category.isNotEmpty)
              detailRow(Icons.label_rounded, event.category),
            if (event.location.isNotEmpty)
              detailRow(Icons.place_rounded, event.location),
            if (event.dispatcher.isNotEmpty)
              detailRow(Icons.headset_mic_rounded, event.dispatcher),
            if (event.description.isNotEmpty)
              detailRow(Icons.notes_rounded, event.description),
          ],
        ),
      ),
      actions: [
        if (event.id.startsWith('cal:')) ...[
          CoButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await deleteCalendarEvent(context, event);
            },
            label: 'Löschen',
            variant: CoButtonVariant.destructiveQuiet,
          ),
          CoButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await editCalendarEvent(context, event);
            },
            label: 'Bearbeiten',
            variant: CoButtonVariant.quiet,
          ),
        ] else if (event.id.startsWith('fleet:'))
          CoButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Fleet-Hub-Termine im Fleet-Hub verwalten.'),
                ),
              );
            },
            label: 'Fleet-Hub',
            variant: CoButtonVariant.quiet,
          ),
        CoButton(
          onPressed: () => Navigator.of(ctx).pop(),
          label: 'Schließen',
          variant: CoButtonVariant.quiet,
        ),
      ],
    ),
  );
}

Future<void> deleteCalendarEvent(
  BuildContext context,
  _CalEvent event,
) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;
  final docId = _calendarDocIdFor(event);
  if (docId == null) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dieser Termin kann hier nicht gelöscht werden.'),
      ),
    );
    return;
  }
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('calendar_events')
        .doc(docId)
        .delete();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Termin "${event.title}" gelöscht.')),
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Löschen fehlgeschlagen: $e')),
    );
  }
}

Future<void> editCalendarEvent(
  BuildContext context,
  _CalEvent event,
) async {
  final docId = _calendarDocIdFor(event);
  if (docId == null) return;
  final result = await showDialog<_NewEventResult>(
    context: context,
    builder: (ctx) => _AddEventDialog(initial: event),
  );
  if (result == null) return;
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('calendar_events')
        .doc(docId)
        .update({
      'start': Timestamp.fromDate(result.start),
      'end': Timestamp.fromDate(result.end),
      'title': result.title,
      'category': result.category,
      'location': result.location,
      'dispatcher': result.dispatcher,
      // Set when filled; remove the field when the admin cleared it.
      'description': result.description.isEmpty
          ? FieldValue.delete()
          : result.description,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Termin "${result.title}" aktualisiert.')),
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Speichern fehlgeschlagen: $e')),
    );
  }
}

/// Single source of truth for the colored accent used by every event
/// surface (day-cell bar, event tile, detail dialog).
Color _categoryColorFor(String category) {
  final c = category.toLowerCase();
  if (c.contains('miet')) return const Color(0xFF7B5BFF);
  if (c.contains('meeting') || c.contains('plan')) {
    return AppColors.codriverGreen;
  }
  if (c.contains('service') || c.contains('tüv')) return AppColors.warning;
  if (c.contains('hr') || c.contains('onboard')) {
    return const Color(0xFF0A84FF);
  }
  return AppColors.codriverDeep;
}

class _CalEvent {
  final String id;
  final DateTime start;
  final DateTime end; // inclusive last day; equal to start for single-day events
  final String title;
  final String category;
  final String location;
  final String dispatcher; // pinned dispatcher name (optional)
  final String description; // optional free-text notes (may be empty)
  const _CalEvent({
    required this.id,
    required this.start,
    required DateTime? end,
    required this.title,
    this.category = '',
    this.location = '',
    this.dispatcher = '',
    this.description = '',
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

/// Merge two streams and emit a combined value whenever either side
/// updates. Avoids pulling in rxdart for one call site.
Stream<R> _combineLatest2<A, B, R>(
  Stream<A> a,
  Stream<B> b,
  R Function(A, B) combiner,
) {
  late StreamController<R> ctrl;
  A? lastA;
  B? lastB;
  bool hasA = false;
  bool hasB = false;
  StreamSubscription<A>? subA;
  StreamSubscription<B>? subB;

  void emit() {
    if (hasA && hasB) {
      ctrl.add(combiner(lastA as A, lastB as B));
    }
  }

  ctrl = StreamController<R>(
    onListen: () {
      subA = a.listen(
        (v) {
          lastA = v;
          hasA = true;
          emit();
        },
        onError: ctrl.addError,
      );
      subB = b.listen(
        (v) {
          lastB = v;
          hasB = true;
          emit();
        },
        onError: ctrl.addError,
      );
    },
    onCancel: () async {
      await subA?.cancel();
      await subB?.cancel();
    },
  );
  return ctrl.stream;
}

// ════════════════════════════════════════════════════════════════════════════
//  Add-event dialog
// ════════════════════════════════════════════════════════════════════════════

class _NewEventResult {
  final String title;
  final String category;
  final String location;
  final String dispatcher;
  final String description;
  final DateTime start;
  final DateTime end;
  const _NewEventResult({
    required this.title,
    required this.category,
    required this.location,
    required this.dispatcher,
    required this.description,
    required this.start,
    required this.end,
  });
}

class _AddEventDialog extends StatefulWidget {
  final DateTime? prefillStart;
  /// If non-null the dialog acts as an EDITOR: all fields are
  /// pre-filled and the submit button reads "Speichern" instead of
  /// "Hinzufügen".
  final _CalEvent? initial;
  const _AddEventDialog({this.prefillStart, this.initial});

  @override
  State<_AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<_AddEventDialog> {
  final _titleCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  String _category = 'Meeting';
  String _dispatcher = '';
  late DateTime _start;
  late DateTime _end;
  bool _multiDay = false;
  bool get _isEditing => widget.initial != null;

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
    final initial = widget.initial;
    if (initial != null) {
      _titleCtrl.text = initial.title;
      _locationCtrl.text = initial.location;
      _descriptionCtrl.text = initial.description;
      if (_categories.contains(initial.category)) {
        _category = initial.category;
      } else if (initial.category.isNotEmpty) {
        _category = 'Sonstiges';
      }
      _dispatcher = initial.dispatcher;
      _start = initial.start;
      _end = initial.end;
      _multiDay = !(initial.start.year == initial.end.year &&
          initial.start.month == initial.end.month &&
          initial.start.day == initial.end.day);
    } else {
      final base = widget.prefillStart ?? DateTime.now();
      _start = DateTime(base.year, base.month, base.day, 9, 0);
      _end = DateTime(base.year, base.month, base.day, 10, 0);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _descriptionCtrl.dispose();
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

  /// Time-of-day picker for start ([start] = true) or end time. Keeps
  /// the already-chosen date and only swaps hour/minute, mirroring how
  /// _pickDate keeps the previously chosen time.
  Future<void> _pickTime(bool start) async {
    final base = start ? _start : _end;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: base.hour, minute: base.minute),
    );
    if (picked == null) return;
    setState(() {
      if (start) {
        _start = DateTime(
          _start.year, _start.month, _start.day, picked.hour, picked.minute,
        );
        if (_multiDay && _end.isBefore(_start)) _end = _start;
      } else {
        _end = DateTime(
          _end.year, _end.month, _end.day, picked.hour, picked.minute,
        );
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
        description: _descriptionCtrl.text.trim(),
        start: _start,
        end: _multiDay ? _end : _start,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final df = DateFormat('EEE, d. MMMM y', _localeForFormat(context));
    final tfmt = DateFormat.Hm(_localeForFormat(context));
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
      title: Text(
        _isEditing ? 'Termin bearbeiten' : 'Neuer Termin',
        style: AppTypography.title3.copyWith(
          color: AppColors.codriverGraphite,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
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
            // Optional multi-line description / notes for the event.
            TextField(
              controller: _descriptionCtrl,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: de
                    ? 'Beschreibung (optional)'
                    : 'Description (optional)',
                hintText: de
                    ? 'z.B. Agenda, Ansprechpartner, Hinweise …'
                    : 'e.g. agenda, contact person, notes …',
                alignLabelWithHint: true,
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
            // Start date + time
            _DateRow(
              label: _multiDay ? 'Von' : 'Datum',
              value: df.format(_start),
              onPick: () => _pickDate(true),
              timeValue: tfmt.format(_start),
              onPickTime: () => _pickTime(true),
            ),
            if (_multiDay) ...[
              const SizedBox(height: AppSpacing.xs),
              _DateRow(
                label: 'Bis',
                value: df.format(_end),
                onPick: () => _pickDate(false),
                timeValue: tfmt.format(_end),
                onPickTime: () => _pickTime(false),
              ),
            ],
          ],
          ),
        ),
      ),
      actions: [
        CoButton(
          onPressed: () => Navigator.of(context).pop(),
          label: 'Abbrechen',
          variant: CoButtonVariant.quiet,
        ),
        CoButton(
          onPressed: _valid ? _submit : null,
          label: 'Speichern',
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
                        child: CoPressable(
                          enabled: widget.allowWeekSelection,
                          borderRadius: BorderRadius.circular(8),
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
              child: CoButton(
                onPressed: () => Navigator.of(context).pop(),
                label: 'Abbrechen',
                variant: CoButtonVariant.quiet,
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
      child: CoPressable(
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
      child: CoPressable(
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
  /// Optional time chip ("09:00") rendered next to the date — taps
  /// open a time picker via [onPickTime]. Both must be set together.
  final String? timeValue;
  final VoidCallback? onPickTime;
  const _DateRow({
    required this.label,
    required this.value,
    required this.onPick,
    this.timeValue,
    this.onPickTime,
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
          child: CoPressable(
            onTap: onPick,
            borderRadius: BorderRadius.circular(10),
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
                  Flexible(
                    child: Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.subheadline.copyWith(
                        color: AppColors.codriverGraphite,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (timeValue != null && onPickTime != null) ...[
          const SizedBox(width: AppSpacing.xs),
          CoPressable(
            onTap: onPickTime,
            borderRadius: BorderRadius.circular(10),
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: AppColors.codriverDeep,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    timeValue!,
                    style: AppTypography.subheadline.copyWith(
                      color: AppColors.codriverGraphite,
                      fontWeight: FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
