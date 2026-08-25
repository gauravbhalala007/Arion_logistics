// Ticket „DA balance PDF": Der Urlaubsanspruch endet mit dem Vertrag.
// Ohne Stichtag wuchs er bei ausgetretenen Fahrern immer weiter.
import 'package:flutter_test/flutter_test.dart';
import 'package:kpi_admin/utils/vacation_pools.dart';

void main() {
  final start = DateTime(2025, 1, 1);
  final contractEnd = DateTime(2026, 4, 30);
  final today = DateTime(2026, 8, 25);

  VacationBalance balanceUntil(DateTime stichtag) => computeVacationBalance(
        absences: const <VacationAbsence>[],
        config: VacationPoolsConfig.disabled,
        annualVacationDays: 24,
        workStartDate: start,
        now: stichtag,
      );

  test('laufender Vertrag: Anspruch waechst bis heute', () {
    // 01.01.2025 bis 25.08.2026 = 19 volle Monate → 24/12 * 19 = 38.
    expect(balanceUntil(today).totalEntitlement, closeTo(38, 0.01));
  });

  test('beendeter Vertrag: Anspruch friert zum Vertragsende ein', () {
    // 01.01.2025 bis 30.04.2026 = 15 volle Monate → 24/12 * 15 = 30.
    expect(balanceUntil(contractEnd).totalEntitlement, closeTo(30, 0.01));
  });

  test('Stichtag Vertragsende liefert weniger als Stichtag heute', () {
    expect(
      balanceUntil(contractEnd).totalEntitlement <
          balanceUntil(today).totalEntitlement,
      isTrue,
      reason: 'Nach dem Austritt darf kein Anspruch mehr entstehen',
    );
  });

  test('genommener Urlaub bleibt unabhaengig vom Stichtag erhalten', () {
    final b = computeVacationBalance(
      absences: [
        VacationAbsence(
          from: DateTime(2026, 2, 2), // Montag
          to: DateTime(2026, 2, 6), // Freitag
          chargeable: true,
          bookedAt: DateTime(2026, 1, 5),
        ),
      ],
      config: VacationPoolsConfig.disabled,
      annualVacationDays: 24,
      workStartDate: start,
      now: contractEnd,
    );
    expect(b.totalUsedAllTime, 5);
    expect(b.totalRemaining, closeTo(25, 0.01));
  });
}
