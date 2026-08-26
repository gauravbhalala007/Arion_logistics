import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kpi_admin/services/shift_plan_parser.dart';

// Prueft den Parser gegen den echten Amazon-Export von Woche 35.
// Die Datei liegt lokal in Downloads und wird nicht committet —
// ohne sie werden die Tests uebersprungen.
void main() {
  final file = File('/Users/albertdobra/Downloads/Woche-35-Zeitplan.xlsx');
  final exists = file.existsSync();

  test('Woche 35: Datei wird erkannt und vollstaendig gelesen', () {
    final plan = parseShiftPlanExcel(file.readAsBytesSync(), assumeYear: 2026);
    // ignore: avoid_print
    print('Firma: ${plan.company} | Station: ${plan.station}');
    // ignore: avoid_print
    print('Roster: ${plan.roster.length}');
    // ignore: avoid_print
    print('Tage: ${plan.assignmentsByDate.keys.toList()..sort()}');
    var total = 0;
    plan.assignmentsByDate.forEach((_, v) => total += v.length);
    // ignore: avoid_print
    print('Fahrer-Tage gesamt: $total');
    expect(plan.roster.length, greaterThan(80));
    expect(plan.assignmentsByDate.keys.length, greaterThanOrEqualTo(4));
  }, skip: !exists);

  test('Woche 35: async-Variante liefert dasselbe Ergebnis', () async {
    final plan = await parseShiftPlanExcelAsync(file.readAsBytesSync());
    var total = 0;
    plan.assignmentsByDate.forEach((_, v) => total += v.length);
    // ignore: avoid_print
    print('ASYNC Roster: ${plan.roster.length} | Tage: '
        '${plan.assignmentsByDate.keys.length} | Fahrer-Tage: $total');
    expect(plan.roster.length, 95);
    expect(plan.assignmentsByDate.keys.length, 4);
    expect(total, 208);
  }, skip: !exists);
}
