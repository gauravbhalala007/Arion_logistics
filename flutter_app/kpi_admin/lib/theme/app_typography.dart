import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography tokens for the entire app — all built on **Inter** via
/// `google_fonts`. The size scale is the same Apple-HIG-derived ladder
/// the app already uses; only the family, weights and tracking were
/// tuned for Inter's metrics (slightly larger x-height + more open
/// counters, so we use less aggressive negative tracking than SF Pro
/// would need). Line-height is encoded as a unitless ratio that works
/// equally well at desktop and mobile sizes.
///
/// Why `static final` instead of `static const`: `GoogleFonts.inter`
/// is a runtime factory — the resulting `TextStyle` cannot be `const`.
/// No callsite uses `const AppTypography.foo`, so this is safe.
class AppTypography {
  AppTypography._();

  /// Resolved Inter family name from the bundled google_fonts package.
  /// Used by theme tokens (`appBarTheme`, `chipTheme`, …) that need a
  /// raw `fontFamily` string rather than a full `TextStyle`.
  static String get fontFamily => GoogleFonts.inter().fontFamily ?? 'Inter';

  /// Same as [fontFamily] — kept for backwards compatibility with
  /// callsites that referenced `fontFamilyFallback`.
  static String get fontFamilyFallback => fontFamily;

  // ─── Display & titles ─────────────────────────────────────────────────────

  static final TextStyle largeTitle = GoogleFonts.inter(
    fontSize: 34,
    height: 40 / 34,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.7,
  );

  static final TextStyle title1 = GoogleFonts.inter(
    fontSize: 28,
    height: 34 / 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  static final TextStyle title2 = GoogleFonts.inter(
    fontSize: 22,
    height: 28 / 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );

  static final TextStyle title3 = GoogleFonts.inter(
    fontSize: 20,
    height: 25 / 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
  );

  // ─── Headlines & body ─────────────────────────────────────────────────────

  static final TextStyle headline = GoogleFonts.inter(
    fontSize: 17,
    height: 22 / 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.15,
  );

  static final TextStyle body = GoogleFonts.inter(
    fontSize: 15,
    height: 22 / 15,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.1,
  );

  static final TextStyle callout = GoogleFonts.inter(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  // ─── Sub-body, footnote, captions ─────────────────────────────────────────

  static final TextStyle subheadline = GoogleFonts.inter(
    fontSize: 14,
    height: 19 / 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );

  static final TextStyle footnote = GoogleFonts.inter(
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static final TextStyle caption1 = GoogleFonts.inter(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.05,
  );

  static final TextStyle caption2 = GoogleFonts.inter(
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
  );
}
