import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// CoDriver's single button class. Every button in the app should be
/// a `CoButton` (or `CoIconButton` for icon-only square actions).
///
/// Only the **color** is variable — shape (pill), height (≥44), padding,
/// font weight (w600) and tap target are baked into the widget so the
/// whole app stays consistent. To shift the style globally, edit this
/// file only.
class CoButton extends StatelessWidget {
  const CoButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.variant = CoButtonVariant.primary,
    this.fullWidth = false,
    this.busy = false,
  });

  final VoidCallback? onPressed;
  final String label;

  /// Optional leading icon. When provided the button becomes
  /// icon + label; size 18.
  final IconData? icon;

  /// Colour variant. Use a [CoButtonVariant] — never set bg/fg
  /// directly on the call-site so themes stay coherent.
  final CoButtonVariant variant;

  /// When true the button stretches to fill its parent (used on
  /// mobile primary CTAs in sticky bars).
  final bool fullWidth;

  /// When true the label is replaced by a spinner and `onPressed`
  /// is suppressed.
  final bool busy;

  // ── canonical sizing ──────────────────────────────────────────
  static const double _kHeight = 44;
  static const double _kVPad = 14;
  static const double _kHPad = 22;
  static const double _kHPadWithIcon = 18;

  @override
  Widget build(BuildContext context) {
    final colors = _resolve(variant);
    final padding = EdgeInsets.symmetric(
      horizontal: icon != null ? _kHPadWithIcon : _kHPad,
      vertical: _kVPad,
    );
    final shape = const StadiumBorder();
    final textStyle = AppTypography.subheadline.copyWith(
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
    );
    final minSize = fullWidth
        ? const Size.fromHeight(_kHeight)
        : const Size(0, _kHeight);
    final tap = busy ? null : onPressed;

    Widget content = busy
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Text(label);

    // ── Quiet (text-only) ────────────────────────────────────
    if (variant == CoButtonVariant.quiet ||
        variant == CoButtonVariant.destructiveQuiet) {
      final btn = icon != null
          ? TextButton.icon(
              onPressed: tap,
              icon: Icon(icon, size: 18),
              label: content,
              style: TextButton.styleFrom(
                foregroundColor: colors.fg,
                padding: padding,
                shape: shape,
                textStyle: textStyle,
                minimumSize: const Size(0, _kHeight),
              ),
            )
          : TextButton(
              onPressed: tap,
              style: TextButton.styleFrom(
                foregroundColor: colors.fg,
                padding: padding,
                shape: shape,
                textStyle: textStyle,
                minimumSize: const Size(0, _kHeight),
              ),
              child: content,
            );
      return fullWidth ? SizedBox(width: double.infinity, child: btn) : btn;
    }

    // ── Outlined (bordered) ─────────────────────────────────
    if (variant == CoButtonVariant.secondaryOutlined ||
        variant == CoButtonVariant.destructiveOutlined) {
      final borderColor = colors.border ?? colors.fg;
      final btn = icon != null
          ? OutlinedButton.icon(
              onPressed: tap,
              icon: Icon(icon, size: 18),
              label: content,
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.fg,
                backgroundColor: colors.bg,
                side: BorderSide(color: borderColor),
                padding: padding,
                minimumSize: minSize,
                shape: shape,
                textStyle: textStyle,
              ),
            )
          : OutlinedButton(
              onPressed: tap,
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.fg,
                backgroundColor: colors.bg,
                side: BorderSide(color: borderColor),
                padding: padding,
                minimumSize: minSize,
                shape: shape,
                textStyle: textStyle,
              ),
              child: content,
            );
      return btn;
    }

    // ── Filled (primary / secondary-tinted / destructive / …) ─
    final btn = icon != null
        ? FilledButton.icon(
            onPressed: tap,
            icon: Icon(icon, size: 18),
            label: content,
            style: FilledButton.styleFrom(
              backgroundColor: colors.bg,
              foregroundColor: colors.fg,
              padding: padding,
              minimumSize: minSize,
              shape: shape,
              textStyle: textStyle,
            ),
          )
        : FilledButton(
            onPressed: tap,
            style: FilledButton.styleFrom(
              backgroundColor: colors.bg,
              foregroundColor: colors.fg,
              padding: padding,
              minimumSize: minSize,
              shape: shape,
              textStyle: textStyle,
            ),
            child: content,
          );
    return btn;
  }

  _CoButtonColors _resolve(CoButtonVariant v) {
    switch (v) {
      case CoButtonVariant.primary:
        return const _CoButtonColors(
          bg: AppColors.codriverGreen,
          fg: Colors.white,
        );
      case CoButtonVariant.secondaryTinted:
        return const _CoButtonColors(
          bg: AppColors.green50,
          fg: AppColors.codriverDeep,
        );
      case CoButtonVariant.secondaryOutlined:
        return const _CoButtonColors(
          bg: Colors.white,
          fg: Color(0xFF111827),
          border: Color(0xFFE5E7EB),
        );
      case CoButtonVariant.quiet:
        return const _CoButtonColors(
          bg: Colors.transparent,
          fg: AppColors.codriverDeep,
        );
      case CoButtonVariant.destructive:
        return const _CoButtonColors(
          bg: Color(0xFFB91C1C),
          fg: Colors.white,
        );
      case CoButtonVariant.destructiveTinted:
        return const _CoButtonColors(
          bg: Color(0xFFFEE2E2),
          fg: Color(0xFFB91C1C),
        );
      case CoButtonVariant.destructiveOutlined:
        return const _CoButtonColors(
          bg: Colors.white,
          fg: Color(0xFFB91C1C),
          border: Color(0xFFB91C1C),
        );
      case CoButtonVariant.destructiveQuiet:
        return const _CoButtonColors(
          bg: Colors.transparent,
          fg: Color(0xFFB91C1C),
        );
    }
  }
}

class _CoButtonColors {
  const _CoButtonColors({
    required this.bg,
    required this.fg,
    this.border,
  });

  final Color bg;
  final Color fg;
  final Color? border;
}

enum CoButtonVariant {
  primary,
  secondaryTinted,
  secondaryOutlined,
  quiet,
  destructive,
  destructiveTinted,
  destructiveOutlined,
  destructiveQuiet,
}

// ──────────────────────────────────────────────────────────────────
//  Icon-only square companion — same canonical pill, just 44×44
// ──────────────────────────────────────────────────────────────────

enum CoIconButtonVariant {
  primary,
  secondaryOutlined,
  secondaryTinted,
}

class CoIconButton extends StatelessWidget {
  const CoIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.variant = CoIconButtonVariant.secondaryOutlined,
    this.size = 44,
    this.tooltip,
    this.badge = 0,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final CoIconButtonVariant variant;
  final double size;
  final String? tooltip;
  final int badge;

  @override
  Widget build(BuildContext context) {
    final Color bg, fg;
    BorderSide side = BorderSide.none;
    switch (variant) {
      case CoIconButtonVariant.primary:
        bg = AppColors.codriverGreen;
        fg = Colors.white;
        break;
      case CoIconButtonVariant.secondaryOutlined:
        bg = Colors.white;
        fg = const Color(0xFF111827);
        side = const BorderSide(color: Color(0xFFE5E7EB));
        break;
      case CoIconButtonVariant.secondaryTinted:
        bg = AppColors.green50;
        fg = AppColors.codriverDeep;
        break;
    }

    final inner = Material(
      color: bg,
      shape: StadiumBorder(side: side),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: fg, size: size * 0.5),
              if (badge > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    constraints: const BoxConstraints(minWidth: 18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB91C1C),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Text(
                      badge > 99 ? '99+' : '$badge',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    return tooltip != null ? Tooltip(message: tooltip!, child: inner) : inner;
  }
}
