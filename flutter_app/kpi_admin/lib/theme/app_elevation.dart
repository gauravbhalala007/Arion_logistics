import 'package:flutter/material.dart';

class AppElevation {
  AppElevation._();

  static const List<BoxShadow> level1 = [
    BoxShadow(color: Color(0x0A000000), offset: Offset(0, 1), blurRadius: 2),
  ];
  static const List<BoxShadow> level2 = [
    BoxShadow(color: Color(0x0F000000), offset: Offset(0, 4), blurRadius: 12),
  ];
  static const List<BoxShadow> level3 = [
    BoxShadow(color: Color(0x14000000), offset: Offset(0, 8), blurRadius: 24),
  ];
  static const List<BoxShadow> level4 = [
    BoxShadow(color: Color(0x1F000000), offset: Offset(0, 16), blurRadius: 48),
  ];
}
