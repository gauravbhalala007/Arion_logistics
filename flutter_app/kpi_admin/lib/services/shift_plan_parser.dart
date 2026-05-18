import 'dart:typed_data';

import 'package:excel/excel.dart';

import '../models/shift_plan.dart';

/// Async version of [parseShiftPlanExcel] that yields back to the
/// browser between work phases so a loading overlay stays animated.
/// `Excel.decodeBytes` is still synchronous and unavoidably blocks
/// for its duration; we just bracket it with yields so the overlay
/// has a chance to paint before and after.
///
/// `onPhase` is invoked with a short status string so the caller can
/// update its UI ('Decoding workbook…', 'Walking rows…', etc.).
Future<ParsedShiftPlan> parseShiftPlanExcelAsync(
  Uint8List bytes, {
  int? assumeYear,
  void Function(String phase)? onPhase,
}) async {
  // Phase 1: decode workbook. Sync + heavy — happens in one chunk.
  onPhase?.call('Decoding workbook…');
  await Future<void>.delayed(const Duration(milliseconds: 16));
  final Excel excel = Excel.decodeBytes(bytes);
  await Future<void>.delayed(const Duration(milliseconds: 16));

  // Phase 2: find the right sheet + header row.
  onPhase?.call('Reading header…');
  await Future<void>.delayed(const Duration(milliseconds: 16));
  final sheetName = excel.tables.keys.firstWhere(
    (k) => k.toLowerCase().contains('arbeitsbl'),
    orElse: () => excel.tables.keys.first,
  );
  final Sheet sheet = excel.tables[sheetName]!;

  String company = '';
  String station = '';
  if (sheet.maxRows >= 2) {
    company = _cellString(sheet, col: 1, row: 1);
    station = _cellString(sheet, col: 2, row: 1);
  }

  int? headerRow;
  for (var r = 0; r < sheet.maxRows && r < 30; r++) {
    final cell = _cellString(sheet, col: 0, row: r).toLowerCase();
    if (cell.startsWith('name des mit')) {
      headerRow = r;
      break;
    }
  }
  if (headerRow == null) {
    throw const FormatException(
      'Header-Zeile "Name des Mitarbeiters" wurde nicht gefunden.',
    );
  }

  // Phase 3: day columns.
  final year = assumeYear ?? DateTime.now().year;
  final dayCols = <int, DateTime>{};
  final headerRowData = sheet.rows.length > headerRow
      ? sheet.rows[headerRow]
      : const <Data?>[];
  for (var c = 2; c < headerRowData.length; c++) {
    final label = (headerRowData[c]?.value?.toString() ?? '').trim();
    if (label.isEmpty) continue;
    final d = _parseDayLabel(label, year);
    if (d != null) dayCols[c] = d;
  }
  if (dayCols.isEmpty) {
    throw const FormatException(
      'Keine Tages-Spalten in der Tabelle erkannt.',
    );
  }

  // Phase 4: walk data rows, yielding every 25 rows so the overlay's
  // pulse animation keeps painting on slower devices.
  onPhase?.call('Walking rows…');
  await Future<void>.delayed(const Duration(milliseconds: 16));
  final byDate = <String, List<ShiftPlanEntry>>{};
  final roster = <ShiftRoster>[];
  final seenTids = <String>{};
  const yieldEvery = 25;
  var rowsSinceYield = 0;
  for (var r = headerRow + 1; r < sheet.maxRows; r++) {
    final name = _cellString(sheet, col: 0, row: r);
    if (name.isEmpty) continue;
    final lower = name.toLowerCase();
    if (lower.startsWith('eingeplant') ||
        lower.startsWith('gesamt') ||
        lower.startsWith('summe')) {
      continue;
    }
    final tid = _cellString(sheet, col: 1, row: r);
    if (tid.isEmpty) continue;

    if (seenTids.add(tid.toUpperCase())) {
      roster.add(ShiftRoster(transporterId: tid, driverName: name));
    }

    for (final entry in dayCols.entries) {
      final col = entry.key;
      final date = entry.value;
      final raw = _cellString(sheet, col: col, row: r);
      if (raw.isEmpty) continue;
      final blocks = _parseShiftBlocks(raw);
      if (blocks.isEmpty) continue;
      final key =
          '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';
      byDate.putIfAbsent(key, () => <ShiftPlanEntry>[]).add(
            ShiftPlanEntry(
              transporterId: tid,
              driverName: name,
              blocks: blocks,
            ),
          );
    }
    rowsSinceYield++;
    if (rowsSinceYield >= yieldEvery) {
      rowsSinceYield = 0;
      await Future<void>.delayed(Duration.zero);
    }
  }

  // Phase 5: sort.
  onPhase?.call('Grouping by day…');
  await Future<void>.delayed(const Duration(milliseconds: 16));
  for (final list in byDate.values) {
    list.sort((a, b) =>
        a.driverName.toLowerCase().compareTo(b.driverName.toLowerCase()));
  }
  roster.sort((a, b) =>
      a.driverName.toLowerCase().compareTo(b.driverName.toLowerCase()));

  return ParsedShiftPlan(
    assignmentsByDate: byDate,
    roster: roster,
    station: station,
    company: company,
  );
}

/// Reads an Amazon-style "Woche-{N}-Zeitplan.xlsx" workbook into a
/// [ParsedShiftPlan]. Only the sheet "Arbeitsblöcke nach Dienstplan"
/// is used — that's where the actual shift assignments live.
ParsedShiftPlan parseShiftPlanExcel(Uint8List bytes, {int? assumeYear}) {
  final Excel excel = Excel.decodeBytes(bytes);
  final sheetName = excel.tables.keys.firstWhere(
    (k) => k.toLowerCase().contains('arbeitsbl'),
    orElse: () => excel.tables.keys.first,
  );
  final Sheet sheet = excel.tables[sheetName]!;

  // ─── Pull metadata (row 1 = labels, row 2 = values) ───
  String company = '';
  String station = '';
  if (sheet.maxRows >= 2) {
    company = _cellString(sheet, col: 1, row: 1);
    station = _cellString(sheet, col: 2, row: 1);
  }

  // ─── Find the header row that contains "Name des Mitarbeiters" ───
  int? headerRow;
  for (var r = 0; r < sheet.maxRows && r < 30; r++) {
    final cell = _cellString(sheet, col: 0, row: r).toLowerCase();
    if (cell.startsWith('name des mit')) {
      headerRow = r;
      break;
    }
  }
  if (headerRow == null) {
    throw const FormatException(
      'Header-Zeile "Name des Mitarbeiters" wurde nicht gefunden.',
    );
  }

  // ─── Day columns start at col index 2 ───
  final year = assumeYear ?? DateTime.now().year;
  final dayCols = <int, DateTime>{};
  final headerRowData = sheet.rows.length > headerRow
      ? sheet.rows[headerRow]
      : const <Data?>[];
  for (var c = 2; c < headerRowData.length; c++) {
    final label = (headerRowData[c]?.value?.toString() ?? '').trim();
    if (label.isEmpty) continue;
    final d = _parseDayLabel(label, year);
    if (d != null) dayCols[c] = d;
  }
  if (dayCols.isEmpty) {
    throw const FormatException(
      'Keine Tages-Spalten in der Tabelle erkannt.',
    );
  }

  // ─── Walk the data rows ───
  final byDate = <String, List<ShiftPlanEntry>>{};
  final roster = <ShiftRoster>[];
  final seenTids = <String>{};
  for (var r = headerRow + 1; r < sheet.maxRows; r++) {
    final name = _cellString(sheet, col: 0, row: r);
    if (name.isEmpty) continue;
    final lower = name.toLowerCase();
    if (lower.startsWith('eingeplant') ||
        lower.startsWith('gesamt') ||
        lower.startsWith('summe')) {
      continue;
    }
    final tid = _cellString(sheet, col: 1, row: r);
    if (tid.isEmpty) continue;

    if (seenTids.add(tid.toUpperCase())) {
      roster.add(ShiftRoster(transporterId: tid, driverName: name));
    }

    for (final entry in dayCols.entries) {
      final col = entry.key;
      final date = entry.value;
      final raw = _cellString(sheet, col: col, row: r);
      if (raw.isEmpty) continue;
      final blocks = _parseShiftBlocks(raw);
      if (blocks.isEmpty) continue;
      final key =
          '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';
      byDate.putIfAbsent(key, () => <ShiftPlanEntry>[]).add(
            ShiftPlanEntry(
              transporterId: tid,
              driverName: name,
              blocks: blocks,
            ),
          );
    }
  }

  // Sort each day alphabetically by driver name for predictable output.
  for (final list in byDate.values) {
    list.sort((a, b) =>
        a.driverName.toLowerCase().compareTo(b.driverName.toLowerCase()));
  }
  roster.sort((a, b) =>
      a.driverName.toLowerCase().compareTo(b.driverName.toLowerCase()));

  return ParsedShiftPlan(
    assignmentsByDate: byDate,
    roster: roster,
    station: station,
    company: company,
  );
}

String _cellString(Sheet sheet, {required int col, required int row}) {
  final c = sheet.cell(
    CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row),
  );
  final v = c.value;
  if (v == null) return '';
  if (v is TextCellValue) return v.value.text?.trim() ?? '';
  return v.toString().trim();
}

DateTime? _parseDayLabel(String s, int year) {
  // Examples: "So., 10/Mai", "Mo., 11/Mai", "Mi., 13/Mai"
  final m = RegExp(r'(\d{1,2})\s*/\s*(\p{L}+)', unicode: true).firstMatch(s);
  if (m == null) return null;
  final day = int.tryParse(m.group(1)!);
  if (day == null) return null;
  final raw = m.group(2)!.toLowerCase();
  const months = <String, int>{
    'januar': 1, 'jan': 1,
    'februar': 2, 'feb': 2,
    'märz': 3, 'mar': 3, 'mär': 3,
    'april': 4, 'apr': 4,
    'mai': 5,
    'juni': 6, 'jun': 6,
    'juli': 7, 'jul': 7,
    'august': 8, 'aug': 8,
    'september': 9, 'sep': 9, 'sept': 9,
    'oktober': 10, 'okt': 10, 'oct': 10,
    'november': 11, 'nov': 11,
    'dezember': 12, 'dez': 12, 'dec': 12,
  };
  final month = months[raw] ??
      months[raw.length >= 3 ? raw.substring(0, 3) : raw];
  if (month == null) return null;
  return DateTime(year, month, day);
}

final RegExp _timeLineRe = RegExp(
  r'^(\d{1,2}:\d{2}\s*(?:am|pm))\s*[•·]\s*(.+)$',
  caseSensitive: false,
);

List<ShiftBlock> _parseShiftBlocks(String raw) {
  final lines = raw
      .split(RegExp(r'[\r\n]+'))
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty)
      .toList();
  final out = <ShiftBlock>[];
  for (var i = 0; i < lines.length; i++) {
    // Service line (i) + time spec (i+1) come in pairs.
    final service = lines[i];
    if (i + 1 >= lines.length) break;
    final time = lines[i + 1];
    final m = _timeLineRe.firstMatch(time);
    if (m != null) {
      out.add(ShiftBlock(
        serviceType: service,
        startTime: m.group(1)!.replaceAll(RegExp(r'\s+'), '').toLowerCase(),
        duration: m.group(2)!.trim(),
      ));
      i++; // consume the time line
    }
  }
  return out;
}
