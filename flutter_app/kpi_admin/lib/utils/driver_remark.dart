/// Bemerkung zu einem Fahrer (Ticket „DRIVER'S HUB": Remarks-Option).
///
/// Die Notiz wird im Drivers Hub gepflegt und erscheint im Monatsplan
/// direkt unter dem Fahrernamen. Sie liegt als Feld `remark` auf dem
/// Fahrerdokument — bewusst NICHT unter `onboarding`: dort stehen
/// Vertrags- und Ausweisdaten, die beim Onboarding einmal erhoben und
/// danach kaum angefasst werden. Eine Bemerkung ist Tagesgeschäft.
library;

/// Maximale Länge einer Bemerkung.
///
/// Zwei Zeilen sind im Monatsplan sichtbar; alles darüber hinaus würde
/// dort ohnehin abgeschnitten und im Drivers Hub die Karte sprengen.
const int kDriverRemarkMaxLength = 200;

/// Liest die Bemerkung aus einem Fahrerdokument.
///
/// Toleriert das Altfeld `remarks` (Plural) und eine Ablage unter
/// `onboarding`, damit von Hand in Firestore gesetzte Werte nicht
/// stillschweigend verschwinden.
String driverRemarkOf(Map<String, dynamic> driverData) {
  String pick(dynamic raw) => raw is String ? raw.trim() : '';

  final direct = pick(driverData['remark']);
  if (direct.isNotEmpty) return direct;

  final plural = pick(driverData['remarks']);
  if (plural.isNotEmpty) return plural;

  final onboarding = driverData['onboarding'];
  if (onboarding is Map) {
    final nested = pick(onboarding['remark']);
    if (nested.isNotEmpty) return nested;
  }
  return '';
}
