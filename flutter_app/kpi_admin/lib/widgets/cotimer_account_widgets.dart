// lib/widgets/cotimer_account_widgets.dart
//
// Wiederverwendbare Sub-Widgets für die Driver-Zeitkonto-Übersicht:
// Segmented-Toggle (Cupertino-style) und Monats-Zeile mit Saldo.
//
// Design-Skills angewandt:
//   • taste       — Restraint: nur eine Akzentfarbe, tight palette,
//                   hierarchy durch Größe+Weight, keine Decoration
//   • impeccable  — Tabular figures, 4/8 px Spacing, sentence case Copy
//   • emil-koral. — Stagger Fade-In beim Mount (40 ms delay/item)

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class SegmentedToggle extends StatelessWidget {
  final int value;
  final List<String> labels;
  final ValueChanged<int> onChanged;

  const SegmentedToggle({
    super.key,
    required this.value,
    required this.labels,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 0.6),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: value == i
                        ? const Color(0xFF1C1C1E)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    labels[i],
                    style: AppTypography.subheadline.copyWith(
                      color: value == i
                          ? Colors.white
                          : const Color(0xFF6B7280),
                      fontWeight:
                          value == i ? FontWeight.w800 : FontWeight.w700,
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

class OverviewMonthRow extends StatefulWidget {
  final int delayMs;
  final String monthKey; // 'YYYY-MM'
  final Map<String, dynamic> data;
  final VoidCallback onTap;

  const OverviewMonthRow({
    super.key,
    required this.delayMs,
    required this.monthKey,
    required this.data,
    required this.onTap,
  });

  @override
  State<OverviewMonthRow> createState() => _OverviewMonthRowState();
}

class _OverviewMonthRowState extends State<OverviewMonthRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  String _monthLabel(String key) {
    final parts = key.split('-');
    if (parts.length != 2) return key;
    const months = [
      'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
      'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember',
    ];
    final m = int.tryParse(parts[1]) ?? 1;
    final y = parts[0];
    return '${months[m - 1]} $y';
  }

  @override
  Widget build(BuildContext context) {
    final saldoH = (widget.data['saldo'] as num?)?.toDouble() ?? 0;
    final sollH = (widget.data['soll'] as num?)?.toDouble() ?? 0;
    final istH = (widget.data['ist'] as num?)?.toDouble() ?? 0;
    final positive = saldoH >= 0;
    final sign = saldoH >= 0 ? '+' : '−';

    return FadeTransition(
      opacity: _c,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic)),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: const Color(0xFFE5E5EA), width: 0.6),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _monthLabel(widget.monthKey),
                          style: AppTypography.subheadline.copyWith(
                            color: const Color(0xFF1C1C1E),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${sollH.toStringAsFixed(0)} / '
                          '${istH.toStringAsFixed(0)} h',
                          style: AppTypography.caption1.copyWith(
                            color: const Color(0xFF6B7280),
                            fontWeight: FontWeight.w600,
                            fontFeatures: const [
                              FontFeature.tabularFigures()
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '$sign${saldoH.abs().toStringAsFixed(1)} h',
                    style: AppTypography.title3.copyWith(
                      color: positive
                          ? AppColors.codriverGreen
                          : const Color(0xFFF97316),
                      fontWeight: FontWeight.w800,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF9CA3AF),
                    size: 20,
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
