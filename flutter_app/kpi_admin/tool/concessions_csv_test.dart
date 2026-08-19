// tool/concessions_csv_test.dart
//
// Standalone verification harness for the NEW Amazon Concessions CSV export.
//
//   dart run tool/concessions_csv_test.dart
//   dart run tool/concessions_csv_test.dart <DSP_Associates_Concessions_*.csv>
//
// Exercises EXACTLY the code the web app runs — `lib/services/
// concessions_csv_parser.dart` is deliberately Flutter-free, so app and
// harness share one implementation.
//
// Two suites:
//   A. SYNTHETIC — in-code fixtures for the German number formats
//      ("1.463" = 1463) and the filename metadata. Always run.
//   B. REAL FILE — the actual Amazon export. Skipped (not failed) when the
//      file is not present on this machine.
//
// Nothing is uploaded or persisted; only local files are read.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:kpi_admin/services/concessions_csv_parser.dart';

const _defaultCsv =
    '/Users/albertdobra/Downloads/DSP_Associates_Concessions_DBY5_2026-W33.csv';

int _failures = 0;
int _checks = 0;

void _check(String label, bool ok, {String? detail}) {
  _checks++;
  if (ok) {
    stdout.writeln('  ok    $label');
  } else {
    _failures++;
    final suffix = detail == null ? '' : '  ($detail)';
    stdout.writeln('  FAIL  $label$suffix');
  }
}

void _expect(String label, Object? actual, Object? expected) {
  final ok = actual == expected;
  _checks++;
  if (ok) {
    stdout.writeln('  ok    $label = $actual');
  } else {
    _failures++;
    stdout.writeln('  FAIL  $label: expected $expected, got $actual');
  }
}

// ---------------------------------------------------------------------------
// A. SYNTHETIC
// ---------------------------------------------------------------------------

void _suiteNumbers() {
  stdout.writeln('\nA1 — German number formats');
  _expect('"618"', ConcessionsCsvParser.parseGermanNumber('618'), 618.0);
  _expect('"1.463" (Tausenderpunkt)',
      ConcessionsCsvParser.parseGermanNumber('1.463'), 1463.0);
  _expect('"12.944"', ConcessionsCsvParser.parseGermanNumber('12.944'),
      12944.0);
  _expect('"79.710"', ConcessionsCsvParser.parseGermanNumber('79.710'),
      79710.0);
  _expect('"1.234.567"',
      ConcessionsCsvParser.parseGermanNumber('1.234.567'), 1234567.0);
  _expect('"683"', ConcessionsCsvParser.parseGermanNumber('683'), 683.0);
  _expect('"0"', ConcessionsCsvParser.parseGermanNumber('0'), 0.0);
  _expect('"" -> null', ConcessionsCsvParser.parseGermanNumber(''), null);
  _expect('"12,5" (dt. Dezimalkomma)',
      ConcessionsCsvParser.parseGermanNumber('12,5'), 12.5);
  _expect('"1.234,5"', ConcessionsCsvParser.parseGermanNumber('1.234,5'),
      1234.5);
  _expect('"0.16" (kein 3er-Block -> Dezimalpunkt)',
      ConcessionsCsvParser.parseGermanNumber('0.16'), 0.16);

  stdout.writeln('\nA2 — percent values');
  _expect('"0.16%"', ConcessionsCsvParser.parsePercent('0.16%'), 0.16);
  _expect('"7.97%"', ConcessionsCsvParser.parsePercent('7.97%'), 7.97);
  _expect('"1,27 %"', ConcessionsCsvParser.parsePercent('1,27 %'), 1.27);
}

void _suiteFilenameMeta() {
  stdout.writeln('\nA3 — filename metadata');
  final m = ConcessionsCsvParser.parseMetaFromFilename(
      'DSP_Associates_Concessions_DBY5_2026-W33.csv');
  _expect('station', m.stationCode, 'DBY5');
  _expect('year', m.year, 2026);
  _expect('week', m.weekNumber, 33);

  final old = ConcessionsCsvParser.parseMetaFromFilename(
      'DE-AION-DBY5-Week19-Concessions.xlsx');
  _expect('legacy station', old.stationCode, 'DBY5');
  _expect('legacy week', old.weekNumber, 19);
}

void _suiteSyntheticCsv() {
  stdout.writeln('\nA4 — synthetic CSV (quoted commas in header)');
  const csv = '\u{FEFF}"Woche","Name des Zustellenden","Zustellende-ID",'
      '"Zugestellte Pakete",'
      '"Pakete, die geliefert aber nicht empfangen wurden (DNR)",'
      '"DNR DPMO","Versendete Pakete",'
      '"Pakete, die an das Verteilzentrum zurückgeliefert wurden (RTS)",'
      '"Pakete, die an das Verteilzentrum zurückgeliefert wurden (RTS) %",'
      '"Zum Verteilzentrum zurück DPMO"\r\n'
      '"2026-33","Max Muster","a1b2c3d4e5f6g7","1.463","4","2.734",'
      '"1.464","1","0.07%","683"\r\n';

  final json = ConcessionsCsvParser.parseString(
    csv,
    filename: 'DSP_Associates_Concessions_DBY5_2026-W33.csv',
  );
  _expect('count', json['count'], 1);
  final d = (json['drivers'] as List).first as Map<String, dynamic>;
  _expect('TID normalisiert (uppercase)', d['Transporter ID'],
      'A1B2C3D4E5F6G7');
  _expect('driverName', d['driverName'], 'Max Muster');
  _expect('CONC_TotalDelivered', d['CONC_TotalDelivered'], 1463.0);
  _expect('CONC_TotalDnr', d['CONC_TotalDnr'], 4.0);
  _expect('CONC_DnrDpmo4w', d['CONC_DnrDpmo4w'], 2734.0);
  _expect('CONC_DnrCount_W4 (Report-Woche)', d['CONC_DnrCount_W4'], 4.0);
  _expect('CONC_DnrDpmo_W4', d['CONC_DnrDpmo_W4'], 2734.0);
  _check('CONC_DnrCount_W1..W3 leer',
      d['CONC_DnrCount_W1'] == null &&
          d['CONC_DnrCount_W2'] == null &&
          d['CONC_DnrCount_W3'] == null);
  _expect('CONC_DnrCountByWeek', '${d['CONC_DnrCountByWeek']}',
      '{2026-33: 4.0}');
  _expect('CONC_TotalShipped', d['CONC_TotalShipped'], 1464.0);
  _expect('CONC_RtsCount', d['CONC_RtsCount'], 1.0);
  _expect('CONC_RtsPct', d['CONC_RtsPct'], 0.07);
  _expect('CONC_RtsDpmo', d['CONC_RtsDpmo'], 683.0);

  final s = json['summary'] as Map<String, dynamic>;
  _expect('summary.weekNumber', s['weekNumber'], 33);
  _expect('summary.year', s['year'], 2026);
  _expect('summary.weekText', s['weekText'], 'KW 33');
  _expect('summary.stationCode', s['stationCode'], 'DBY5');
  _expect('summary.concessionsFormat', s['concessionsFormat'], 'csv');
  final cs = s['concessionsSummary'] as Map<String, dynamic>;
  _expect('summary.concessionsSummary.delVolume', cs['delVolume'], 1463.0);
  _expect('summary.concessionsSummary.dnrCount', cs['dnrCount'], 4.0);
  _expect('summary.concessionsSummary.weekLabels', '${cs['weekLabels']}',
      '[2026-33]');
}

void _suiteSemicolonVariant() {
  stdout.writeln('\nA5 — semicolon-separated variant');
  const csv = 'Woche;Name des Zustellenden;Zustellende-ID;Zugestellte Pakete;'
      'Pakete DNR;DNR DPMO;Versendete Pakete;Pakete RTS;Pakete RTS %;'
      'Zum Verteilzentrum zurück DPMO\n'
      '2026-33;Test Fahrer;A1CLJB8AKDH065;943;0;0;944;1;0.11%;1.059\n';
  final json = ConcessionsCsvParser.parseString(
    csv,
    filename: 'DSP_Associates_Concessions_DBY5_2026-W33.csv',
  );
  final d = (json['drivers'] as List).first as Map<String, dynamic>;
  _expect('delivered', d['CONC_TotalDelivered'], 943.0);
  _expect('rtsDpmo', d['CONC_RtsDpmo'], 1059.0);
}

// ---------------------------------------------------------------------------
// B. REAL FILE
// ---------------------------------------------------------------------------

Map<String, dynamic>? _driverByTid(List<dynamic> drivers, String tid) {
  for (final d in drivers) {
    if (d is Map<String, dynamic> && d['Transporter ID'] == tid) return d;
  }
  return null;
}

void _suiteRealFile(String path) {
  stdout.writeln('\nB — real Amazon export: $path');
  final file = File(path);
  if (!file.existsSync()) {
    stdout.writeln('  SKIP  file not found');
    return;
  }

  final bytes = Uint8List.fromList(file.readAsBytesSync());
  final json = ConcessionsCsvParser.parseBytes(
    bytes,
    filename: path.split('/').last,
  );

  final drivers = json['drivers'] as List<dynamic>;
  _expect('Fahrer-Anzahl', json['count'], 61);
  _expect('drivers.length', drivers.length, 61);

  final summary = json['summary'] as Map<String, dynamic>;
  _expect('summary.year', summary['year'], 2026);
  _expect('summary.weekNumber', summary['weekNumber'], 33);
  _expect('summary.weekText', summary['weekText'], 'KW 33');
  _expect('summary.stationCode', summary['stationCode'], 'DBY5');
  final cs = summary['concessionsSummary'] as Map<String, dynamic>;
  _expect('weekLabels', '${cs['weekLabels']}', '[2026-33]');

  final albin = _driverByTid(drivers, 'A2QB9QXY1ZOCID');
  _check('Albin Bucolli gefunden (A2QB9QXY1ZOCID)', albin != null);
  if (albin != null) {
    _expect('  Albin driverName', albin['driverName'], 'Albin Bucolli');
    _expect('  Albin CONC_TotalDnr', albin['CONC_TotalDnr'], 8.0);
    _expect('  Albin CONC_TotalDelivered', albin['CONC_TotalDelivered'],
        618.0);
    _expect('  Albin CONC_DnrDpmo4w', albin['CONC_DnrDpmo4w'], 12944.0);
    _expect('  Albin CONC_DnrCount_W4', albin['CONC_DnrCount_W4'], 8.0);
    _expect('  Albin CONC_TotalShipped', albin['CONC_TotalShipped'], 619.0);
    _expect('  Albin CONC_RtsCount', albin['CONC_RtsCount'], 1.0);
    _expect('  Albin CONC_RtsPct', albin['CONC_RtsPct'], 0.16);
    _expect('  Albin CONC_RtsDpmo', albin['CONC_RtsDpmo'], 1615.0);
  }

  final leon = _driverByTid(drivers, 'A1Z5D00H03RRZJ');
  _check('Leon Dobra gefunden (A1Z5D00H03RRZJ)', leon != null);
  if (leon != null) {
    _expect('  Leon driverName', leon['driverName'], 'Leon Dobra');
    _expect('  Leon CONC_TotalDelivered (Tausenderpunkt!)',
        leon['CONC_TotalDelivered'], 1463.0);
    _expect('  Leon CONC_TotalDnr', leon['CONC_TotalDnr'], 4.0);
    _expect('  Leon CONC_DnrDpmo4w', leon['CONC_DnrDpmo4w'], 2734.0);
    _expect('  Leon CONC_TotalShipped', leon['CONC_TotalShipped'], 1464.0);
  }

  final denise = _driverByTid(drivers, 'ASSFMKI5PF5AX');
  _check('Denise Muller gefunden (ASSFMKI5PF5AX)', denise != null);
  if (denise != null) {
    _expect('  Denise CONC_TotalDnr (0)', denise['CONC_TotalDnr'], 0.0);
    _expect('  Denise CONC_RtsCount', denise['CONC_RtsCount'], 55.0);
    _expect('  Denise CONC_RtsPct', denise['CONC_RtsPct'], 7.97);
    _expect('  Denise CONC_RtsDpmo', denise['CONC_RtsDpmo'], 79710.0);
  }

  // Struktur-Invarianten fuer den ReportWriter.
  var missingTid = 0;
  var missingDnr = 0;
  var totalDnr = 0.0;
  var totalDelivered = 0.0;
  for (final d in drivers) {
    final m = d as Map<String, dynamic>;
    final tid = (m['Transporter ID'] ?? '').toString();
    if (tid.isEmpty || tid != tid.toUpperCase()) missingTid++;
    if (m['CONC_TotalDnr'] == null) missingDnr++;
    totalDnr += (m['CONC_TotalDnr'] as num?)?.toDouble() ?? 0;
    totalDelivered += (m['CONC_TotalDelivered'] as num?)?.toDouble() ?? 0;
  }
  _expect('alle TIDs vorhanden + uppercase (Fehler)', missingTid, 0);
  _expect('alle CONC_TotalDnr gesetzt (Fehler)', missingDnr, 0);
  _expect('Summe DNR == summary.dnrCount', totalDnr, cs['dnrCount']);
  _expect('Summe Delivered == summary.delVolume', totalDelivered,
      cs['delVolume']);

  stdout.writeln(
    '  info  DSP: delVolume=${cs['delVolume']} dnrCount=${cs['dnrCount']} '
    'dnrDpmo=${(cs['dnrDpmo'] as num).toStringAsFixed(1)}',
  );
  stdout.writeln('  info  Beispiel-Fahrerzeile (JSON):');
  stdout.writeln('        ${jsonEncode(albin)}');
}

void main(List<String> args) {
  final path = args.isNotEmpty ? args.first : _defaultCsv;

  stdout.writeln('=== Concessions CSV parser harness ===');
  _suiteNumbers();
  _suiteFilenameMeta();
  _suiteSyntheticCsv();
  _suiteSemicolonVariant();
  _suiteRealFile(path);

  stdout.writeln('\n---------------------------------------');
  stdout.writeln('checks: $_checks   failures: $_failures');
  if (_failures > 0) exitCode = 1;
}
