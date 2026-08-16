// lib/widgets/metric_info_chip.dart
//
// Wiederverwendbarer Chip für Concessions-Focus-Bereiche und POD-Quality-
// Reject-Reasons. Zeigt:
//   - Label (Klartext)
//   - Zahl (mit Severity-Farbe: rot wenn > 0, grau wenn 0)
//   - Info-Icon → öffnet Bottom-Sheet mit Beschreibung + Tipp
//
// Verwendung:
//   MetricInfoChip(
//     label: t.t('concessions_focus_attended_dnr'),
//     value: '5',
//     count: 5,
//     description: t.t('concessions_focus_attended_dnr_desc'),
//     tip: t.t('concessions_focus_attended_dnr_tip'),
//   )

import 'package:flutter/material.dart';

class MetricInfoChip extends StatelessWidget {
  /// Display label (e.g. "Kunde war zu Hause")
  final String label;

  /// Display value (e.g. "5" or "—")
  final String value;

  /// Numeric count — used for severity coloring (red if > 0).
  final num? count;

  /// Full description (1-2 sentences) — shown in bottom sheet on tap.
  final String description;

  /// How-to-fix tip — shown in bottom sheet on tap.
  final String tip;

  /// Optional override for the chip color when count > 0.
  final Color? warningColor;

  const MetricInfoChip({
    super.key,
    required this.label,
    required this.value,
    required this.count,
    required this.description,
    required this.tip,
    this.warningColor,
  });

  bool get _isWarn => count != null && count! > 0;

  Color get _bg => _isWarn
      ? (warningColor ?? const Color(0xFFFEF3F2))
      : const Color(0xFFF3F4F6);

  Color get _fg => _isWarn
      ? const Color(0xFFB42318)
      : const Color(0xFF374151);

  Color get _border => _isWarn
      ? const Color(0xFFFECDCA)
      : const Color(0xFFE5E7EB);

  void _openExplainer(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _bg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _isWarn
                          ? Icons.warning_amber_rounded
                          : Icons.info_outline_rounded,
                      color: _fg,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  if (count != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _bg,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: _border),
                      ),
                      child: Text(
                        value,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: _fg,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF374151),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF3),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFD1FADF)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lightbulb_outline_rounded,
                      size: 18,
                      color: Color(0xFF067647),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        tip,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF053D2A),
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('OK'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openExplainer(context),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: _border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _fg,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: _fg,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.info_outline_rounded,
              size: 14,
              color: _fg.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }
}
