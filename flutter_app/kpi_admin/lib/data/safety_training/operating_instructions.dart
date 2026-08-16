// lib/data/safety_training/operating_instructions.dart
//
// Betriebsanweisungen (BAW) — Modell.
//
// Aufbau nach dem Standard-Schema aus der Unterweisung: sechs
// Abschnitte, immer in derselben Reihenfolge. So findet man im Ernstfall
// sofort die richtige Stelle, egal welche Anweisung man aufschlägt.
//
// Betriebsanweisungen sind verbindliche Anweisungen des Arbeitgebers
// (§ 12 ArbSchG, § 4 DGUV Vorschrift 1, für Gefahrstoffe zusätzlich
// § 14 GefStoffV).

import 'package:flutter/foundation.dart';

/// ID unter der die Lesebestätigungen abgelegt werden:
/// users/{dspUid}/academy_test_results/operating_instructions/drivers/{tid}
///
/// Bewusst derselbe Baum wie bei den Schulungsergebnissen — dort dürfen
/// Fahrer laut Firestore-Rules ihr eigenes Ergebnisdokument anlegen und
/// aktualisieren.
const String kOperatingInstructionsTestId = 'operating_instructions';

/// Betriebsanweisungen, die nur Dispatcher betreffen.
///
/// „Bildschirmarbeitsplatz" richtet sich an Disposition und Büroarbeit —
/// für Zusteller ist sie gegenstandslos und würde die Liste nur
/// verlängern und die Lesebestätigungen verwässern. Zentral gepflegt,
/// damit nicht alle zehn Sprachdateien angefasst werden müssen.
const Set<String> kDispatcherOnlyInstructionIds = {
  'baw_bildschirm',
};

/// Inhaltsstand der Betriebsanweisungen.
///
/// Wird bei jeder Bestätigung mitgeschrieben. Ändert sich der Inhalt einer
/// Anweisung, wird diese Zahl erhöht — dann lässt sich später auswerten,
/// welche Bestätigungen auf einem älteren Stand beruhen. Eine erneute
/// Bestätigung wird dadurch **nicht** erzwungen.
const int kOperatingInstructionsVersion = 1;

/// Themenbereich — steuert Icon und Gruppierung in der Übersicht.
enum InstructionCategory {
  vehicle,
  ppe,
  handling,
  hazardous,
  hygiene,
  workplace,
}

@immutable
class OperatingInstruction {
  final String id;
  final String title;

  /// Ein Satz, worum es geht — für die Listenansicht.
  final String subtitle;
  final InstructionCategory category;

  /// 1. Geltungsbereich
  final String scope;

  /// 2. Gefahren für Mensch und Umwelt
  final List<String> hazards;

  /// 3. Schutzmaßnahmen und Verhaltensregeln
  final List<String> protection;

  /// 4. Verhalten bei Störungen
  final List<String> onFailure;

  /// 5. Verhalten bei Unfällen und Erste Hilfe
  final List<String> onAccident;

  /// 6. Instandhaltung und Entsorgung
  final List<String> maintenance;

  const OperatingInstruction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.scope,
    required this.hazards,
    required this.protection,
    required this.onFailure,
    required this.onAccident,
    required this.maintenance,
  });
}
