class AppSpacing {
  AppSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

/// Semantic spacing presets — readable aliases over the raw [AppSpacing]
/// scale that document *what* a value is meant for. Prefer these over
/// hand-picking from [AppSpacing] when there's a matching purpose.
class AppSpacingUsage {
  AppSpacingUsage._();

  // Card padding by visual weight
  static const double cardCompact = AppSpacing.md; // 16
  static const double cardStandard = AppSpacing.lg; // 20
  static const double cardHero = AppSpacing.xl; // 24

  // Vertical rhythm
  static const double sectionInner = AppSpacing.lg; // 20
  static const double sectionGap = AppSpacing.xxl; // 32
  static const double screenEdge = AppSpacing.xl; // 24

  // Buttons
  static const double buttonHorizontal = AppSpacing.xl; // 24
  static const double buttonGroupGap = AppSpacing.sm; // 12

  // Form fields
  static const double formFieldGap = AppSpacing.md; // 16
}
