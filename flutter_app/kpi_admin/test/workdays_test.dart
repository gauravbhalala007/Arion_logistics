import 'package:flutter_test/flutter_test.dart';
import 'package:kpi_admin/utils/vacation_days.dart';

void main() {
  test('August 2026 hat 21 Arbeitstage', () {
    // 31 Tage, 1 Feiertag faellt auf keinen Werktag → reine Mo-Fr-Zaehlung.
    expect(germanWorkdaysInMonth(2026, 8), 21);
  });

  test('Mai 2026: drei Feiertage fallen auf Werktage', () {
    // Mai 2026 hat 21 Mo-Fr-Tage. Davon gehen ab: 1. Mai (Freitag),
    // Christi Himmelfahrt am 14.05. (Donnerstag) und Pfingstmontag am
    // 25.05. → 18 Arbeitstage.
    expect(isGermanyPublicHoliday(DateTime(2026, 5, 1)), isTrue);
    expect(isGermanyPublicHoliday(DateTime(2026, 5, 14)), isTrue);
    expect(isGermanyPublicHoliday(DateTime(2026, 5, 25)), isTrue);
    expect(germanWorkdaysInMonth(2026, 5), 18);
  });

  test('Dezember 2026: Weihnachten faellt auf Fr/Sa', () {
    expect(isGermanyPublicHoliday(DateTime(2026, 12, 25)), isTrue);
    expect(germanWorkdaysInMonth(2026, 12), 22);
  });

  test('Jahressumme liegt im plausiblen Bereich', () {
    var total = 0;
    for (var m = 1; m <= 12; m++) {
      total += germanWorkdaysInMonth(2026, m);
    }
    expect(total, inInclusiveRange(248, 256));
  });
}
