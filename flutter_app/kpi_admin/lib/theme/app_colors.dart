import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const codriverGreen = Color(0xFF00B287);
  static const codriverDeep = Color(0xFF006047);
  static const codriverGraphite = Color(0xFF3D3D3D);

  // Tints / Shades
  static const green50 = Color(0xFFE6F8F2);
  static const green100 = Color(0xFFB8EBD8);
  static const green200 = Color(0xFF7DDDBE);
  static const green300 = Color(0xFF3DCFA3);
  static const green400 = codriverGreen;
  static const green500 = Color(0xFF009972);
  static const green600 = Color(0xFF007E5D);
  static const green700 = codriverDeep;
  static const green800 = Color(0xFF00422F);
  static const green900 = Color(0xFF002418);

  // Semantic — Light
  static const backgroundLight = Color(0xFFFFFFFF);
  static const surfaceLight = Color(0xFFF2F2F7);
  static const surfaceElevatedLight = Color(0xFFFFFFFF);
  static const separatorLight = Color(0x2E3C3C43); // 18%
  static const labelLight = Color(0xFF000000);
  static const labelSecondaryLight = Color(0x993C3C43); // 60%
  /// 30 % opacity black — only ~2.3:1 contrast on white. **Do not use for
  /// regular body text** (fails WCAG AA). Reserve for placeholder/hint text
  /// inside inputs and disabled-state labels. Prefer [labelHintLight] when
  /// the intent is a hint, for self-documenting code.
  static const labelTertiaryLight = Color(0x4D3C3C43); // 30%

  /// Semantic alias of [labelTertiaryLight] for placeholder/hint usage —
  /// makes hint usage explicit at call sites and reminds readers that
  /// the colour is intentionally low-contrast.
  static const labelHintLight = labelTertiaryLight;

  // Semantic — Dark
  static const backgroundDark = Color(0xFF000000);
  static const surfaceDark = Color(0xFF1C1C1E);
  static const surfaceElevatedDark = Color(0xFF2C2C2E);
  static const separatorDark = Color(0x99545458); // 60%
  static const labelDark = Color(0xFFFFFFFF);
  static const labelSecondaryDark = Color(0x99EBEBF5);
  static const labelTertiaryDark = Color(0x4DEBEBF5);

  // Status
  static const success = Color(0xFF34C759);
  static const warning = Color(0xFFFF9500);
  static const error = Color(0xFFFF3B30);

  // Tier (Scorecard performance levels — kept from existing code)
  static const tierFantasticPlus = Color(0xFF00B287);
  static const tierFantastic = Color(0xFF0082AF);
  static const tierGreat = Color(0xFFF7AA00);
  static const tierFair = Color(0xFFF47400);
  static const tierPoor = Color(0xFFCE4121);
}
