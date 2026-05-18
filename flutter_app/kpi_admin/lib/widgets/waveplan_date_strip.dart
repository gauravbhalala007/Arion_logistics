import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Shared month + day-pill date selector used at the top of the
/// Waveplan pages (admin and driver). Public so both sides can
/// navigate to past or future days without diverging visual style.
class WaveplanDateStrip extends StatefulWidget {
  const WaveplanDateStrip({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final DateTime selected;
  final ValueChanged<DateTime> onSelect;

  @override
  State<WaveplanDateStrip> createState() => _WaveplanDateStripState();
}

class _WaveplanDateStripState extends State<WaveplanDateStrip> {
  static const double _pillWidth = 56;
  static const double _pillGap = 8;

  final ScrollController _scroll = ScrollController();
  late DateTime _shownMonth;

  @override
  void initState() {
    super.initState();
    _shownMonth = DateTime(widget.selected.year, widget.selected.month, 1);
    WidgetsBinding.instance.addPostFrameCallback((_) => _centerSelected());
  }

  @override
  void didUpdateWidget(covariant WaveplanDateStrip old) {
    super.didUpdateWidget(old);
    final monthChanged = old.selected.year != widget.selected.year ||
        old.selected.month != widget.selected.month;
    if (monthChanged) {
      _shownMonth = DateTime(widget.selected.year, widget.selected.month, 1);
    }
    if (old.selected != widget.selected) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _centerSelected());
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  DateTime get _rangeStart {
    final m = DateTime(_shownMonth.year, _shownMonth.month - 1, 1);
    return DateTime(m.year, m.month, 1);
  }

  DateTime get _rangeEnd {
    final next = DateTime(_shownMonth.year, _shownMonth.month + 2, 0);
    return DateTime(next.year, next.month, next.day);
  }

  List<DateTime> get _days {
    final start = _rangeStart;
    final end = _rangeEnd;
    final out = <DateTime>[];
    for (var d = start;
        !d.isAfter(end);
        d = d.add(const Duration(days: 1))) {
      out.add(d);
    }
    return out;
  }

  void _prevMonth() {
    setState(() {
      _shownMonth = DateTime(_shownMonth.year, _shownMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _shownMonth = DateTime(_shownMonth.year, _shownMonth.month + 1, 1);
    });
  }

  void _centerSelected() {
    if (!_scroll.hasClients) return;
    final days = _days;
    final idx = days.indexWhere((d) =>
        d.year == widget.selected.year &&
        d.month == widget.selected.month &&
        d.day == widget.selected.day);
    if (idx < 0) return;
    final viewport = _scroll.position.viewportDimension;
    final offset = (idx * (_pillWidth + _pillGap)) -
        (viewport / 2) +
        (_pillWidth / 2);
    final clamped = offset.clamp(
      _scroll.position.minScrollExtent,
      _scroll.position.maxScrollExtent,
    );
    _scroll.animateTo(
      clamped,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  String _monthLabel(DateTime d) {
    const months = [
      'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
      'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember',
    ];
    return '${months[d.month - 1]} ${d.year}';
  }

  String _weekdayShort(int w) {
    const w0 = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
    return w0[(w - 1) % 7];
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final isOnToday = widget.selected.year == today.year &&
        widget.selected.month == today.month &&
        widget.selected.day == today.day;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevatedLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: _prevMonth,
                icon: const Icon(Icons.chevron_left_rounded),
                color: AppColors.codriverGraphite,
                tooltip: 'Vorheriger Monat',
              ),
              Expanded(
                child: Center(
                  child: Text(
                    _monthLabel(_shownMonth),
                    style: AppTypography.subheadline.copyWith(
                      color: AppColors.codriverGraphite,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: _nextMonth,
                icon: const Icon(Icons.chevron_right_rounded),
                color: AppColors.codriverGraphite,
                tooltip: 'Nächster Monat',
              ),
              if (!isOnToday)
                Padding(
                  padding: const EdgeInsets.only(left: 4, right: 4),
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _shownMonth = DateTime(today.year, today.month, 1);
                      });
                      widget.onSelect(
                          DateTime(today.year, today.month, today.day));
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.codriverDeep,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      'Heute',
                      style: AppTypography.caption1.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.codriverDeep,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 70,
            child: ListView.separated(
              controller: _scroll,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _days.length,
              separatorBuilder: (_, __) => const SizedBox(width: _pillGap),
              itemBuilder: (ctx, i) {
                final d = _days[i];
                final isSelected = d.year == widget.selected.year &&
                    d.month == widget.selected.month &&
                    d.day == widget.selected.day;
                final isToday = d.year == today.year &&
                    d.month == today.month &&
                    d.day == today.day;
                final inMonth = d.month == _shownMonth.month;
                return _DayPill(
                  width: _pillWidth,
                  weekday: _weekdayShort(d.weekday),
                  day: d.day,
                  isSelected: isSelected,
                  isToday: isToday,
                  isMuted: !inMonth,
                  onTap: () => widget.onSelect(d),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DayPill extends StatelessWidget {
  const _DayPill({
    required this.width,
    required this.weekday,
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.isMuted,
    required this.onTap,
  });

  final double width;
  final String weekday;
  final int day;
  final bool isSelected;
  final bool isToday;
  final bool isMuted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = isSelected
        ? AppColors.codriverGreen
        : (isMuted
            ? AppColors.surfaceLight
            : AppColors.surfaceElevatedLight);
    final fg = isSelected
        ? Colors.white
        : (isMuted
            ? AppColors.labelTertiaryLight
            : AppColors.codriverGraphite);
    final borderColor = isSelected
        ? AppColors.codriverGreen
        : (isToday ? AppColors.codriverGreen : const Color(0xFFE5E5EA));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        width: width,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: borderColor,
            width: isToday && !isSelected ? 1.4 : 0.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.codriverGreen.withValues(alpha: 0.18),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              weekday,
              style: AppTypography.caption2.copyWith(
                color:
                    isSelected ? Colors.white.withValues(alpha: 0.85) : fg,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$day',
              style: AppTypography.title3.copyWith(
                color: fg,
                fontWeight: FontWeight.w800,
                height: 1.0,
              ),
            ),
            if (isToday && !isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.codriverGreen,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
