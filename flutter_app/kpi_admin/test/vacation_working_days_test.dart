// Ticket „TIME OFF & BALANCE": Wochenenden und bundesweite Feiertage
// dürfen kein Urlaubskontingent aufzehren.
import 'package:flutter_test/flutter_test.dart';
import 'package:kpi_admin/utils/vacation_days.dart';
import 'package:kpi_admin/utils/vacation_pools.dart';

VacationAbsence _v(DateTime from, DateTime to) => VacationAbsence(
      from: from,
      to: to,
      chargeable: true,
      bookedAt: DateTime(2026, 1, 1),
    );

void main() {
  test('Freitag bis Montag kostet zwei Tage statt vier', () {
    // 2026-08-21 = Freitag, 24. = Montag.
    expect(vacationChargeableDays(DateTime(2026, 8, 21), DateTime(2026, 8, 24)), 2);
  });

  test('reines Wochenende kostet nichts', () {
    expect(vacationChargeableDays(DateTime(2026, 8, 22), DateTime(2026, 8, 23)), 0);
  });

  test('Feiertag mitten in der Woche zaehlt nicht', () {
    // 03.10.2026 (Tag der Deutschen Einheit) faellt auf einen Samstag,
    // deshalb der 1. Mai 2026 — ein Freitag.
    expect(isGermanyPublicHoliday(DateTime(2026, 5, 1)), isTrue);
    // Mo 27.04. bis Fr 01.05.: 5 Werktage minus Feiertag = 4.
    expect(vacationChargeableDays(DateTime(2026, 4, 27), DateTime(2026, 5, 1)), 4);
  });

  test('ganze Kalenderwoche kostet fuenf Tage', () {
    expect(vacationChargeableDays(DateTime(2026, 8, 17), DateTime(2026, 8, 23)), 5);
  });

  test('Saldo zieht nur Werktage ab', () {
    final balance = computeVacationBalance(
      absences: [
        // Fr–Mo über ein Wochenende: 2 Werktage.
        _v(DateTime(2026, 8, 21), DateTime(2026, 8, 24)),
      ],
      config: VacationPoolsConfig.disabled,
      annualVacationDays: 24,
      workStartDate: DateTime(2024, 1, 1),
      now: DateTime(2026, 8, 25),
    );
    expect(balance.totalUsedAllTime, 2);
    expect(balance.totalUsed, 2);
  });

  test('Topf-Modus verbucht ebenfalls nur Werktage', () {
    final balance = computeVacationBalance(
      absences: [
        // Mo–So: 5 Werktage.
        _v(DateTime(2026, 8, 17), DateTime(2026, 8, 23)),
      ],
      config: VacationPoolsConfig.defaults,
      annualVacationDays: 24,
      workStartDate: DateTime(2024, 1, 1),
      now: DateTime(2026, 8, 25),
    );
    expect(balance.totalUsed, 5);
    expect(balance.unallocatedDays, 0);
  });

  test('Ostern: Karfreitag und Ostermontag kosten nichts', () {
    // Ostersonntag 2026 = 05.04. → Karfreitag 03.04., Ostermontag 06.04.
    expect(isGermanyPublicHoliday(DateTime(2026, 4, 3)), isTrue);
    expect(isGermanyPublicHoliday(DateTime(2026, 4, 6)), isTrue);
    // Do 02.04. bis Di 07.04. = 6 Kalendertage, davon 2 Werktage
    // (Do + Di), weil Fr/Mo Feiertag und Sa/So Wochenende sind.
    expect(vacationChargeableDays(DateTime(2026, 4, 2), DateTime(2026, 4, 7)), 2);
  });
}
