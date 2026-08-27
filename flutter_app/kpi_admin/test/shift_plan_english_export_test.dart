import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kpi_admin/services/shift_plan_parser.dart';

/// Englischer Amazon-Export (Mitarbeiter mit englischer Oberflaeche):
/// Blatt "Rostered work blocks", Header "Associate name", Summenzeile
/// "Total rostered" — exakt der Aufbau aus dem Fehler-Screenshot vom
/// 27.08.2026.
void main() {
  test('englischer Export wird erkannt', () {
    final excel = Excel.createExcel();
    final sheet = excel['Rostered work blocks'];
    excel.delete('Sheet1');

    void row(int r, List<String> cells) {
      for (var c = 0; c < cells.length; c++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r))
            .value = TextCellValue(cells[c]);
      }
    }

    row(0, ['Time stamp', 'Company', 'Station']);
    row(1, ['27.08.26, 15:58:30', 'ARION Logistics', 'DBY5']);
    row(3, [
      'Associate name',
      'Transporter ID',
      'So., 23/Aug.',
      'Mo., 24/Aug.',
      'Di., 25/Aug.',
    ]);
    row(4, ['Total rostered', '', '0', '55', '60']);
    row(5, [
      'Adrian Daniel Candrea',
      'A7XH5ILV93KZL',
      '',
      'Sameday Parcel\n6:00pm • 4 Std.',
      '',
    ]);
    row(6, [
      'Andon Stavre',
      'APRZ8PWWNT126',
      '',
      'Multi-Use\n7:00am • 6 Std.',
      'Sameday Parcel\n6:15pm • 4 Std.',
    ]);

    final bytes = excel.save()!;
    final plan = parseShiftPlanExcel(
      Uint8List.fromList(bytes),
      assumeYear: 2026,
    );

    expect(plan.company, 'ARION Logistics');
    expect(plan.station, 'DBY5');
    expect(plan.roster.length, 2);
    expect(plan.assignmentsByDate.keys, contains('2026-08-24'));
    final monday = plan.assignmentsByDate['2026-08-24']!;
    expect(monday.length, 2);
    expect(
      plan.roster.any((r) => r.driverName == 'Total rostered'),
      isFalse,
    );
  });
}
