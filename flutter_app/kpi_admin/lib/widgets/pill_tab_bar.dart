import 'package:flutter/material.dart';

import '../theme/app_typography.dart';

/// CoDriver-Standard TabBar: Pill · Neutral.
///
/// • Trough hellgrau (`#EEF1F4`), aktives Tab als weiße Pill mit
///   Hairline-Border und sanftem Schatten — keine Brand-Farbe.
/// • Aktiver Text Near-Black, inaktiver mittelgrau.
/// • Komplett rund (`StadiumBorder` / `circular(999)`).
/// • Touch-Target ≥ 38 pt pro Tab.
class PillTabBar extends StatelessWidget {
  const PillTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    this.isScrollable = false,
    this.tabHeight = 38,
  });

  final TabController controller;
  final List<String> tabs;
  final bool isScrollable;
  final double tabHeight;

  static const Color _troughBg = Color(0xFFEEF1F4);
  static const Color _troughBorder = Color(0xFFE0E4EA);
  static const Color _labelActive = Color(0xFF111827);
  static const Color _labelInactive = Color(0xFF9AA3AF);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _troughBg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _troughBorder, width: 0.6),
      ),
      padding: const EdgeInsets.all(5),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: _troughBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: _labelActive,
        unselectedLabelColor: _labelInactive,
        labelStyle: AppTypography.footnote.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.1,
        ),
        unselectedLabelStyle: AppTypography.footnote.copyWith(
          fontWeight: FontWeight.w600,
        ),
        labelPadding: EdgeInsets.zero,
        isScrollable: isScrollable,
        tabAlignment: isScrollable ? TabAlignment.start : null,
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        tabs: [
          for (final label in tabs)
            Tab(
              height: tabHeight,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isScrollable ? 16 : 8,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
