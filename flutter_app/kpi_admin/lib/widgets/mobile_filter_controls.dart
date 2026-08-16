// lib/widgets/mobile_filter_controls.dart
//
// Gemeinsame Mobile-Bausteine für Listenseiten (Fleet Hub, Incident-Center):
// der quadratische 48er-Icon-Button neben dem Suchfeld und das dazugehörige
// Bottom-Sheet mit Griff und Titel.
//
// Zuerst im Fleet Hub entstanden — hier herausgezogen, damit beide Bereiche
// exakt dieselbe Mechanik und dieselben Handoff-Tokens benutzen.

import 'package:flutter/material.dart';

/// Handoff-Tokens (design_handoff_fleet_hub).
const Color kMobileAccent = Color(0xFF0D8A60);
const Color kMobileAccentTint = Color(0xFFE7F6EF);
const Color kMobileLine = Color(0xFFE5E9EE);
const Color kMobileSurface = Color(0xFFF7F9FB);
const Color kMobileInk = Color(0xFF1A212B);
const Color kMobileSubtle = Color(0xFF5B6572);
const Color kMobileFaint = Color(0xFF8A93A0);

/// Quadratischer Icon-Button (48×48, Radius 12) neben dem Suchfeld.
/// Ist ein Filter gesetzt, färbt sich der Button grün und bekommt einen
/// kleinen Punkt-Badge.
class MobileIconButton extends StatelessWidget {
  const MobileIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.active = false,
    this.size = 48,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool active;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 500),
      child: Material(
        color: active ? kMobileAccentTint : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: active ? kMobileAccent : kMobileLine),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    icon,
                    size: 21,
                    color: active ? kMobileAccent : kMobileSubtle,
                  ),
                ),
                if (active)
                  Positioned(
                    top: 9,
                    right: 9,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: kMobileAccent,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Rahmen der Mobile-Sheets: Griff, Titel, scrollbarer Inhalt (max. 80 % der
/// Bildschirmhöhe).
Future<T?> showMobileSheet<T>({
  required BuildContext context,
  required String title,
  required Widget Function(BuildContext ctx) builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: kMobileLine,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: kMobileInk,
                ),
              ),
            ),
            Flexible(child: SingleChildScrollView(child: builder(ctx))),
            const SizedBox(height: 12),
          ],
        ),
      ),
    ),
  );
}

/// Auswahlzeile eines Sheets — mindestens 48 px hoch, aktive Option grün.
class MobileSheetOption extends StatelessWidget {
  const MobileSheetOption({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.trailing,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minVerticalPadding: 12,
      leading: Icon(
        icon ?? (selected ? Icons.radio_button_checked : Icons.circle_outlined),
        size: 20,
        color: selected ? kMobileAccent : kMobileFaint,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          color: selected ? kMobileAccent : kMobileInk,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

/// Kleine Abschnittsüberschrift innerhalb eines Sheets.
class MobileSheetSection extends StatelessWidget {
  const MobileSheetSection({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: kMobileFaint,
        ),
      ),
    );
  }
}
