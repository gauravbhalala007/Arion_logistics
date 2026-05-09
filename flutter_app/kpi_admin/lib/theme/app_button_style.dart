import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Button system for Codriver. All variants share the same anatomy
/// (height, shape, padding, typography, icon size) — only the colour
/// pair differs. Use one of these styles whenever a button is needed.
///
/// Usage:
/// ```dart
/// FilledButton(
///   style: AppButtonStyle.of(AppButtonVariant.primary),
///   onPressed: ...,
///   child: const Text('Speichern'),
/// )
/// ```
enum AppButtonVariant {
  /// Brand colour fill, white label. Highest emphasis. Max. one per screen.
  primary,

  /// Dark graphite fill, white label. High emphasis but neutral
  /// (non-brand) — for actions that shouldn't compete with the
  /// primary one (e.g. secondary upload, "Cancel & save").
  secondary,

  /// Light surface fill, dark graphite label. Low emphasis —
  /// for tertiary actions, filter chips, modal "Cancel".
  subtle,

  /// Error red fill, white label. Reserved for destructive actions
  /// (delete, logout, decline).
  destructive,
}

class AppButtonStyle {
  AppButtonStyle._();

  /// Constant button anatomy across every variant.
  static const double _height = 50;
  static const double _horizontalPadding = AppSpacing.xl; // 24
  static const double _iconSize = 20;

  /// Subtle 1px inner edge that catches light on coloured fills.
  /// Transparent on the [subtle] variant where there's no contrast
  /// against the surrounding surface.
  static const Color _innerHighlight = Color(0x1FFFFFFF); // white @ 12 %

  static ButtonStyle of(AppButtonVariant v) {
    final colors = _colorsFor(v);

    return ButtonStyle(
      // Background — solid by default, slightly darker on hover/pressed.
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.background.withOpacity(0.5);
        }
        if (states.contains(WidgetState.pressed)) {
          return _darken(colors.background, 0.08);
        }
        if (states.contains(WidgetState.hovered)) {
          return _darken(colors.background, 0.04);
        }
        return colors.background;
      }),

      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.foreground.withOpacity(0.5);
        }
        return colors.foreground;
      }),

      iconColor: WidgetStateProperty.all(colors.foreground),

      // Inner highlight border — only meaningful on coloured fills.
      side: WidgetStateProperty.all(
        BorderSide(color: colors.innerBorder, width: 1),
      ),

      shape: WidgetStateProperty.all(const StadiumBorder()),

      minimumSize: WidgetStateProperty.all(const Size(0, _height)),
      fixedSize: WidgetStateProperty.all(const Size.fromHeight(_height)),

      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      ),

      iconSize: WidgetStateProperty.all(_iconSize),

      // Apple-style: no elevation, no Material ripple ink halo on hover.
      elevation: WidgetStateProperty.all(0),
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      shadowColor: WidgetStateProperty.all(Colors.transparent),
      surfaceTintColor: WidgetStateProperty.all(Colors.transparent),

      textStyle: WidgetStateProperty.all(AppTypography.headline),

      visualDensity: VisualDensity.standard,
      tapTargetSize: MaterialTapTargetSize.padded,
      animationDuration: const Duration(milliseconds: 160),
    );
  }

  static _ButtonColors _colorsFor(AppButtonVariant v) {
    switch (v) {
      case AppButtonVariant.primary:
        return const _ButtonColors(
          background: AppColors.codriverGreen,
          foreground: Colors.white,
          innerBorder: _innerHighlight,
        );
      case AppButtonVariant.secondary:
        return const _ButtonColors(
          background: AppColors.codriverGraphite,
          foreground: Colors.white,
          innerBorder: _innerHighlight,
        );
      case AppButtonVariant.subtle:
        return const _ButtonColors(
          background: AppColors.surfaceLight,
          foreground: AppColors.codriverGraphite,
          innerBorder: Colors.transparent,
        );
      case AppButtonVariant.destructive:
        return const _ButtonColors(
          background: AppColors.error,
          foreground: Colors.white,
          innerBorder: _innerHighlight,
        );
    }
  }

  /// Darken a colour by mixing it with black at the given amount.
  static Color _darken(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    final l = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(l).toColor();
  }
}

class _ButtonColors {
  final Color background;
  final Color foreground;
  final Color innerBorder;
  const _ButtonColors({
    required this.background,
    required this.foreground,
    required this.innerBorder,
  });
}
