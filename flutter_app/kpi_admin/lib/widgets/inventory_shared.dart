import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Shared visual tokens for the Inventory + Cart modules.
class InvTokens {
  InvTokens._();

  static const Color pageBg = Color(0xFFF3F6F7);
  static const Color border = Color(0xFFE5E7EB);
  static const Color muted = Color(0xFF6B7280);
  static const Color text = Color(0xFF111827);
  static const Color softSurface = Color(0xFFF9FAFB);

  static const Color danger = Color(0xFFB91C1C);
  static const Color warning = Color(0xFFD97706);
  static const Color info = Color(0xFF1D4ED8);

  static const Color warningBg = Color(0xFFFEF3C7);
  static const Color dangerBg = Color(0xFFFEE2E2);
  static const Color infoBg = Color(0xFFDBEAFE);
}

InputDecoration invDecoration(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.body.copyWith(
        color: AppColors.labelHintLight,
      ),
      filled: true,
      fillColor: InvTokens.softSurface,
      isDense: true,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: InvTokens.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: InvTokens.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: AppColors.codriverGreen,
          width: 1.4,
        ),
      ),
    );

class InvLabel extends StatelessWidget {
  const InvLabel(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.subheadline.copyWith(
        color: InvTokens.text,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class InvField extends StatelessWidget {
  const InvField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final List<dynamic>? inputFormatters;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InvLabel(label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters?.cast(),
          maxLines: maxLines,
          style: AppTypography.body.copyWith(color: InvTokens.text),
          decoration: invDecoration(hint),
        ),
      ],
    );
  }
}

class InvStepper extends StatelessWidget {
  const InvStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 9999,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: InvTokens.softSurface,
        border: Border.all(color: InvTokens.border),
        borderRadius: BorderRadius.circular(10),
      ),
      height: 40,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Btn(
            icon: Icons.remove,
            onTap: () => onChanged((value - 1).clamp(min, max)),
          ),
          SizedBox(
            width: 32,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: AppTypography.subheadline.copyWith(
                fontWeight: FontWeight.w800,
                color: InvTokens.text,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          _Btn(
            icon: Icons.add,
            onTap: () => onChanged((value + 1).clamp(min, max)),
          ),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  const _Btn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 22,
      containedInkWell: false,
      child: SizedBox(
        width: 36,
        height: 36,
        child: Icon(icon, size: 16, color: InvTokens.text),
      ),
    );
  }
}

class InvChip extends StatelessWidget {
  const InvChip({
    super.key,
    required this.label,
    required this.bg,
    required this.fg,
  });

  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14111827),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: AppTypography.caption2.copyWith(
          color: fg,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
