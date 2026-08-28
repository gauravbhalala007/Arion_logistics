// lib/Screens/driver_flex_plan_page.dart
//
// Fahrer-Seite "Flex Plan" (nur für Fahrer mit planType == 'flex'):
// zeigt die vom Admin freigegebenen Monate, lässt Schichten verbindlich
// wählen (Limit = Maximalverdienst ÷ Stundenlohn, in Minuten gerechnet)
// und erlaubt Storno nur als Anfrage an den Admin.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/flexplan_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

const List<String> _kMonthsDe = [
  'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni', 'Juli', 'August',
  'September', 'Oktober', 'November', 'Dezember',
];
const List<String> _kMonthsEn = [
  'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August',
  'September', 'October', 'November', 'December',
];
const List<String> _kWeekdaysDe = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
const List<String> _kWeekdaysEn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

class DriverFlexPlanPage extends StatefulWidget {
  const DriverFlexPlanPage({
    super.key,
    required this.dspUid,
    required this.driverTransporterId,
    required this.driverName,
    required this.onBack,
  });

  final String dspUid;
  final String driverTransporterId;
  final String driverName;
  final VoidCallback onBack;

  @override
  State<DriverFlexPlanPage> createState() => _DriverFlexPlanPageState();
}

class _DriverFlexPlanPageState extends State<DriverFlexPlanPage> {
  late final FlexplanRepository _repo = FlexplanRepository(widget.dspUid);
  late final Stream<List<FlexMonth>> _openMonths = _repo.watchOpenMonths();

  String get _tid => widget.driverTransporterId.trim().toUpperCase();

  /// Aktuell ausgewählter Monat (Key) — null = automatisch erster offener.
  String? _selectedMonthKey;

  bool get _de => Localizations.localeOf(context).languageCode == 'de';

  String _monthLabel(String monthKey) {
    final parts = monthKey.split('-');
    final year = int.tryParse(parts[0]) ?? 0;
    final month = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 1;
    return '${(_de ? _kMonthsDe : _kMonthsEn)[(month - 1).clamp(0, 11)]} $year';
  }

  void _snack(String message, {bool error = false}) {
    if (!mounted) return;
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (overlay == null) {
      messenger?.showSnackBar(SnackBar(content: Text(message)));
      return;
    }
    messenger?.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? const Color(0xFFB91C1C) : null,
        content: Text(message),
      ),
    );
  }

  Future<void> _book(FlexMonth month, String dateKey, FlexShift shift) async {
    final de = _de;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(de ? 'Schicht verbindlich wählen?' : 'Book this shift?'),
        content: Text(
          de
              ? '„${shift.name}" am $dateKey, ${shift.start}–${shift.end} '
                  '(${formatMinutes(shift.minutes)}).\n\n'
                  'Wichtig: Du kannst die Schicht danach nicht selbst '
                  'zurücknehmen — nur per Storno-Anfrage an die Dispo.'
              : '"${shift.name}" on $dateKey, ${shift.start}–${shift.end} '
                  '(${formatMinutes(shift.minutes)}).\n\n'
                  'Important: you cannot undo this yourself afterwards — '
                  'only via a cancellation request to dispatch.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(de ? 'Abbrechen' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(de ? 'Verbindlich wählen' : 'Book'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _repo.bookShift(
        monthKey: month.monthKey,
        tid: _tid,
        driverName: widget.driverName,
        date: dateKey,
        shift: shift,
      );
      _snack(de ? 'Schicht gebucht.' : 'Shift booked.');
    } on StateError catch (e) {
      final msg = switch (e.message) {
        'limit_exceeded' => de
            ? 'Stundenlimit erreicht — diese Schicht passt nicht mehr in '
                'dein Monats-Maximum.'
            : 'Hour limit reached — this shift no longer fits your monthly '
                'maximum.',
        'already_booked' =>
            de ? 'Schicht ist bereits gebucht.' : 'Shift already booked.',
        'month_closed' => de
            ? 'Dieser Monat ist nicht mehr freigegeben.'
            : 'This month is no longer open.',
        _ => de ? 'Buchung fehlgeschlagen.' : 'Booking failed.',
      };
      _snack(msg, error: true);
    } catch (e) {
      _snack(
        _de ? 'Buchung fehlgeschlagen: $e' : 'Booking failed: $e',
        error: true,
      );
    }
  }

  Future<void> _requestCancellation(
    FlexMonth month,
    FlexBookingEntry entry,
  ) async {
    final de = _de;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(de ? 'Storno anfragen?' : 'Request cancellation?'),
        content: Text(
          de
              ? 'Die Dispo entscheidet über deine Anfrage für '
                  '„${entry.name}" am ${entry.date}. Bis dahin bleibt die '
                  'Schicht gebucht.'
              : 'Dispatch will decide on your request for "${entry.name}" '
                  'on ${entry.date}. The shift stays booked until then.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(de ? 'Abbrechen' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(de ? 'Anfrage senden' : 'Send request'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _repo.requestCancellation(
        monthKey: month.monthKey,
        tid: _tid,
        driverName: widget.driverName,
        entry: entry,
      );
      _snack(
        de
            ? 'Storno-Anfrage gesendet — die Dispo meldet sich.'
            : 'Cancellation request sent — dispatch will follow up.',
      );
    } catch (e) {
      _snack(
        de ? 'Anfrage fehlgeschlagen: $e' : 'Request failed: $e',
        error: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final de = _de;
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: widget.onBack,
                    borderRadius: BorderRadius.circular(999),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.chevron_left_rounded,
                          color: AppColors.codriverDeep,
                        ),
                        Text(
                          de ? 'Zurück' : 'Back',
                          style: AppTypography.subheadline.copyWith(
                            color: AppColors.codriverDeep,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Flex Plan',
                style: AppTypography.title2.copyWith(
                  color: AppColors.codriverGraphite,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: StreamBuilder<List<FlexMonth>>(
                  stream: _openMonths,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting &&
                        !snap.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    final months = snap.data ?? const <FlexMonth>[];
                    if (months.isEmpty) {
                      return _EmptyState(
                        title: de
                            ? 'Kein Monat freigegeben'
                            : 'No month open yet',
                        description: de
                            ? 'Sobald die Dispo einen Monat freigibt, kannst '
                                'du hier deine Schichten wählen. Du bekommst '
                                'dann eine Benachrichtigung.'
                            : 'Once dispatch opens a month you can pick your '
                                'shifts here. You will get a notification.',
                      );
                    }
                    final selectedKey = months.any(
                            (m) => m.monthKey == _selectedMonthKey)
                        ? _selectedMonthKey!
                        : months.first.monthKey;
                    final month = months
                        .firstWhere((m) => m.monthKey == selectedKey);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (months.length > 1) ...[
                          Wrap(
                            spacing: 8,
                            children: [
                              for (final m in months)
                                ChoiceChip(
                                  selected: m.monthKey == selectedKey,
                                  label: Text(_monthLabel(m.monthKey)),
                                  onSelected: (_) => setState(
                                    () => _selectedMonthKey = m.monthKey,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                        Expanded(child: _monthView(month)),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _monthView(FlexMonth month) {
    final de = _de;
    return StreamBuilder<FlexBooking>(
      stream: _repo.watchBooking(month.monthKey, _tid),
      builder: (context, bookingSnap) {
        final booking = bookingSnap.data ??
            FlexBooking(
              driverTransporterId: _tid,
              driverName: widget.driverName,
              entries: const [],
            );
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _repo.cancellationsCol
              .where('driverTransporterId', isEqualTo: _tid)
              .where('status', isEqualTo: 'pending')
              .snapshots(),
          builder: (context, cancelSnap) {
            final pendingCancellations = <String>{
              for (final d in cancelSnap.data?.docs ?? const [])
                '${d.data()['date']}|${d.data()['shiftId']}',
            };
            final remaining = month.maxMinutes - booking.totalMinutes;
            // Alle Arbeitstage des Monats (Mo–Sa, keine Feiertage) — die
            // Schichten sind einmal angelegt und gelten für jeden davon.
            final workDays = <DateTime>[
              for (var d = 1; d <= month.daysInMonth; d++)
                if (month
                    .shiftsForDate(DateTime(month.year, month.month, d))
                    .isNotEmpty)
                  DateTime(month.year, month.month, d),
            ];

            // Stunden-Übersicht bleibt fix oben stehen — nur die
            // Tagesliste scrollt darunter.
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _totalsCard(month, booking, remaining),
                const SizedBox(height: AppSpacing.sm),
                Expanded(
                  child: ListView(
                    children: [
                      if (workDays.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Text(
                            de
                                ? 'Für ${_monthLabel(month.monthKey)} sind '
                                    'noch keine Schichten angelegt.'
                                : 'No shifts created yet for '
                                    '${_monthLabel(month.monthKey)}.',
                            style: AppTypography.body.copyWith(
                              color: AppColors.labelSecondaryLight,
                            ),
                          ),
                        ),
                      for (final day in workDays)
                        _dayCard(
                          month,
                          day,
                          booking,
                          pendingCancellations,
                          remaining,
                        ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _totalsCard(FlexMonth month, FlexBooking booking, int remaining) {
    final de = _de;
    final earned = earningsForMinutes(booking.totalMinutes, month.hourlyWage);
    final progress = month.maxMinutes == 0
        ? 0.0
        : (booking.totalMinutes / month.maxMinutes).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.codriverGreen, AppColors.codriverDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _monthLabel(month.monthKey),
            style: AppTypography.subheadline.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            de
                ? '${formatMinutes(booking.totalMinutes)} von '
                    '${formatMinutes(month.maxMinutes)} gebucht'
                : '${formatMinutes(booking.totalMinutes)} of '
                    '${formatMinutes(month.maxMinutes)} booked',
            style: AppTypography.title3.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            de
                ? '≈ ${earned.toStringAsFixed(2)} € von '
                    '${month.maxEarnings.toStringAsFixed(2)} € · '
                    '${month.hourlyWage.toStringAsFixed(2)} €/h · '
                    'frei: ${formatMinutes(remaining.clamp(0, 1 << 31))}'
                : '≈ ${earned.toStringAsFixed(2)} € of '
                    '${month.maxEarnings.toStringAsFixed(2)} € · '
                    '${month.hourlyWage.toStringAsFixed(2)} €/h · '
                    'left: ${formatMinutes(remaining.clamp(0, 1 << 31))}',
            style: AppTypography.caption1.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dayCard(
    FlexMonth month,
    DateTime date,
    FlexBooking booking,
    Set<String> pendingCancellations,
    int remaining,
  ) {
    final de = _de;
    final dayKey = FlexplanRepository.dateKeyOf(date);
    final shifts = month.shiftsForDate(date);
    final weekday = (de ? _kWeekdaysDe : _kWeekdaysEn)[date.weekday - 1];

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevatedLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$weekday, ${date.day.toString().padLeft(2, '0')}.'
            '${date.month.toString().padLeft(2, '0')}.${date.year}',
            style: AppTypography.subheadline.copyWith(
              color: AppColors.codriverGraphite,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final shift in shifts)
                _shiftChip(
                  month,
                  dayKey,
                  shift,
                  booking,
                  pendingCancellations,
                  remaining,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _shiftChip(
    FlexMonth month,
    String dayKey,
    FlexShift shift,
    FlexBooking booking,
    Set<String> pendingCancellations,
    int remaining,
  ) {
    final de = _de;
    FlexBookingEntry? bookedEntry;
    for (final e in booking.entries) {
      if (e.date == dayKey && e.shiftId == shift.id) {
        bookedEntry = e;
        break;
      }
    }
    final booked = bookedEntry != null;
    final cancellationPending =
        pendingCancellations.contains('$dayKey|${shift.id}');
    final fits = shift.minutes <= remaining;

    final Color bg;
    final Color fg;
    final Color border;
    if (booked) {
      bg = AppColors.green50;
      fg = AppColors.codriverDeep;
      border = AppColors.codriverGreen;
    } else if (!fits) {
      bg = const Color(0xFFF3F4F6);
      fg = AppColors.labelTertiaryLight;
      border = const Color(0xFFE5E7EB);
    } else {
      bg = Colors.white;
      fg = AppColors.codriverGraphite;
      border = const Color(0xFFCBD5E1);
    }

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: booked
          ? (cancellationPending
              ? null
              : () => _requestCancellation(month, bookedEntry!))
          : (fits ? () => _book(month, dayKey, shift) : null),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: booked ? 1.5 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  booked
                      ? (cancellationPending
                          ? Icons.hourglass_top_rounded
                          : Icons.check_circle_rounded)
                      : Icons.add_circle_outline_rounded,
                  size: 15,
                  color: booked ? AppColors.codriverGreen : fg,
                ),
                const SizedBox(width: 5),
                Text(
                  shift.name.isEmpty
                      ? '${shift.start}–${shift.end}'
                      : shift.name,
                  style: AppTypography.subheadline.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              '${shift.start}–${shift.end} · ${formatMinutes(shift.minutes)}',
              style: AppTypography.caption1.copyWith(
                color: fg,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (booked) ...[
              const SizedBox(height: 2),
              Text(
                cancellationPending
                    ? (de ? 'Storno angefragt' : 'Cancellation requested')
                    : (de ? 'Gebucht · Storno anfragen' : 'Booked · request cancellation'),
                style: AppTypography.caption2.copyWith(
                  color: cancellationPending
                      ? const Color(0xFFB45309)
                      : AppColors.codriverDeep,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ] else if (!fits) ...[
              const SizedBox(height: 2),
              Text(
                de ? 'Über deinem Limit' : 'Over your limit',
                style: AppTypography.caption2.copyWith(
                  color: AppColors.labelTertiaryLight,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.description});

  final String title;
  final String description;

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
              decoration: const BoxDecoration(
                color: AppColors.surfaceElevatedLight,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.event_available_rounded,
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
