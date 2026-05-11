import 'package:flutter/material.dart';

import 'app_button_style.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    final interFamily = AppTypography.fontFamily;

    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.codriverGreen,
        brightness: Brightness.light,
        primary: AppColors.codriverGreen,
        onPrimary: Colors.white,
        secondary: AppColors.codriverDeep,
        surface: AppColors.surfaceElevatedLight,
        onSurface: AppColors.labelLight,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.surfaceLight,
      canvasColor: AppColors.surfaceLight,
      dividerColor: AppColors.separatorLight,
      textTheme: _textTheme(AppColors.labelLight),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.labelLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.title3.copyWith(
          color: AppColors.labelLight,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceElevatedLight,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.allMd),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
      // Default button styling — every FilledButton/ElevatedButton picks
      // this up automatically so screens don't need to set styles by hand.
      filledButtonTheme: FilledButtonThemeData(
        style: AppButtonStyle.of(AppButtonVariant.primary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: AppButtonStyle.of(AppButtonVariant.primary),
      ),
      // Apple HIG doesn't really use outlined buttons — when an outlined
      // look is wanted, use the [subtle] variant instead. We still define
      // sensible defaults here so legacy `OutlinedButton` usages don't
      // visually fall apart while migration is in progress.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: AppButtonStyle.of(AppButtonVariant.subtle),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.codriverGreen,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          textStyle: TextStyle(
            fontFamily: interFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.allSm,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.allSm,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.allSm,
          borderSide: const BorderSide(
            color: AppColors.codriverGreen,
            width: 2,
          ),
        ),
        hintStyle: const TextStyle(color: AppColors.labelTertiaryLight),
      ),
      dialogTheme: DialogThemeData(
        elevation: 8,
        backgroundColor: AppColors.surfaceElevatedLight,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.allLg),
      ),
      dialogBackgroundColor: AppColors.surfaceElevatedLight,
      menuButtonTheme: MenuButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            const RoundedRectangleBorder(borderRadius: AppRadius.allSm),
          ),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(
            AppColors.surfaceElevatedLight,
          ),
          shape: WidgetStateProperty.all(
            const RoundedRectangleBorder(borderRadius: AppRadius.allSm),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceLight,
        selectedColor: AppColors.green50,
        side: BorderSide.none,
        labelStyle: TextStyle(
          fontFamily: interFamily,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        shape: const StadiumBorder(),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.separatorLight,
        thickness: 0.5,
        space: 0.5,
      ),
    );
  }

  static TextTheme _textTheme(Color baseColor) {
    return TextTheme(
      displayLarge: AppTypography.largeTitle.copyWith(color: baseColor),
      displayMedium: AppTypography.title1.copyWith(color: baseColor),
      headlineLarge: AppTypography.title1.copyWith(color: baseColor),
      headlineMedium: AppTypography.title2.copyWith(color: baseColor),
      headlineSmall: AppTypography.title3.copyWith(color: baseColor),
      titleLarge: AppTypography.title3.copyWith(color: baseColor),
      titleMedium: AppTypography.headline.copyWith(color: baseColor),
      titleSmall: AppTypography.subheadline.copyWith(
        color: baseColor,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: AppTypography.body.copyWith(color: baseColor),
      bodyMedium: AppTypography.callout.copyWith(color: baseColor),
      bodySmall: AppTypography.footnote.copyWith(color: baseColor),
      labelLarge: AppTypography.headline.copyWith(color: baseColor),
      labelMedium: AppTypography.subheadline.copyWith(color: baseColor),
      labelSmall: AppTypography.caption1.copyWith(color: baseColor),
    );
  }
}
