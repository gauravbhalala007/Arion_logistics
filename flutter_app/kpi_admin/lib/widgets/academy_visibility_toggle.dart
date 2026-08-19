// lib/widgets/academy_visibility_toggle.dart
//
// Schalter „Für Fahrer sichtbar" unter jeder Schulungskarte der
// Admin-Academy.
//
// Der Schalter steuert AUSSCHLIESSLICH die Sichtbarkeit der Kachel in
// der Fahrer-Academy. An der Schulung selbst, an bereits erbrachten
// Nachweisen und an den Auswertungen ändert er nichts — eine
// ausgeblendete Schulung behält ihre Ergebnisse und taucht in der
// Admin-Übersicht unverändert auf.

import 'package:flutter/material.dart';

class AcademyVisibilityToggle extends StatelessWidget {
  const AcademyVisibilityToggle({
    super.key,
    required this.de,
    required this.narrow,
    required this.visible,
    required this.onChanged,
    this.systemLocked = false,
  });

  final bool de;
  final bool narrow;
  final bool visible;
  final ValueChanged<bool> onChanged;

  /// `true` = das Modul ist zusätzlich systemweit gesperrt (Feature-Flag
  /// im Code). Der Schalter bleibt bedienbar — der Admin soll seine
  /// Entscheidung schon vorbereiten können —, aber die Kachel erscheint
  /// erst, wenn beides an ist. Der Hinweis sagt das offen.
  final bool systemLocked;

  @override
  Widget build(BuildContext context) {
    final pad = narrow ? 14.0 : 18.0;
    final showNote = systemLocked && visible;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(pad, 0, pad - 6, showNote ? 4 : 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          Row(
            children: [
              Icon(
                visible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 18,
                color: visible
                    ? const Color(0xFF16704F)
                    : const Color(0xFF6B7280),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  de ? 'Für Fahrer sichtbar' : 'Visible to drivers',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              Text(
                visible
                    ? (de ? 'Sichtbar' : 'Visible')
                    : (de ? 'Kommt bald' : 'Coming soon'),
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: visible
                      ? const Color(0xFF16704F)
                      : const Color(0xFF6B7280),
                ),
              ),
              Switch(
                value: visible,
                onChanged: onChanged,
                activeThumbColor: const Color(0xFF16704F),
              ),
            ],
          ),
          if (showNote)
            Padding(
              padding: const EdgeInsets.only(left: 28, bottom: 8, right: 6),
              child: Text(
                de
                    ? 'Systemweit noch gesperrt — die Kachel erscheint erst, '
                          'wenn das Modul freigegeben ist.'
                    : 'Still locked system-wide — the tile appears only once '
                          'the module has been released.',
                style: const TextStyle(
                  fontSize: 11.5,
                  height: 1.4,
                  color: Color(0xFF9A5B00),
                ),
              ),
            ),
          if (!visible)
            Padding(
              padding: const EdgeInsets.only(left: 28, bottom: 8, right: 6),
              child: Text(
                de
                    ? 'Fahrer sehen die Kachel als „Kommt bald". Bereits '
                          'erbrachte Nachweise bleiben erhalten.'
                    : 'Drivers see the tile as "Coming soon". Records already '
                          'submitted are kept.',
                style: const TextStyle(
                  fontSize: 11.5,
                  height: 1.4,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
