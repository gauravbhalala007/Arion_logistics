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
  final Excel excel = _decodeWorkbook(bytes);
  await Future<void>.delayed(const Duration(milliseconds: 16));

  // Phase 2: find the right sheet + header row.
  onPhase?.call('Reading header…');
  await Future<void>.delayed(const Duration(milliseconds: 16));
  final Sheet sheet = _pickShiftSheet(excel);

  String company = '';
  String station = '';
  if (sheet.maxRows >= 2) {
    company = _cellString(sheet, col: 1, row: 1);
    station = _cellString(sheet, col: 2, row: 1);
  }

  // One-time snapshot: the `sheet.rows` getter rebuilds the full
  // maxRows×maxColumns matrix on EVERY call — repeated calls in loops
  // froze the tab on large exports.
  final rows = sheet.rows;

  final header = _findNameHeader(rows);
  if (header == null) {
    throw FormatException(_headerNotFoundMessage(excel, rows));
  }
  final headerRow = header.row;
  final nameCol = header.nameCol;
  final tidCol = header.tidCol;

  // Phase 3: day columns (everything to the right of the TID column).
  final year = assumeYear ?? DateTime.now().year;
  final dayCols = <int, DateTime>{};
  final headerRowData =
      rows.length > headerRow ? rows[headerRow] : const <Data?>[];
  for (var c = tidCol + 1; c < headerRowData.length; c++) {
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

  // Phase 4: walk data rows. We iterate the already-parsed `rows`
  // (fast, O(1) per cell) instead of calling sheet.cell() per cell, and
  // yield to the event loop on a FIXED cadence — every row counts, even
  // skipped/empty ones — so a workbook with thousands of trailing empty
  // rows can never freeze the tab. We also stop scanning after a long run
  // of empty rows (the roster is contiguous), which keeps a sheet whose
  // declared dimension is huge from being walked end to end.
  onPhase?.call('Walking rows…');
  await Future<void>.delayed(const Duration(milliseconds: 16));
  final byDate = <String, List<ShiftPlanEntry>>{};
  final roster = <ShiftRoster>[];
  final seenTids = <String>{};
  const yieldEvery = 60;
  const stopAfterEmptyRun = 40;
  var emptyRun = 0;
  for (var r = headerRow + 1; r < rows.length; r++) {
    if (r % yieldEvery == 0) {
      await Future<void>.delayed(Duration.zero);
    }
    final row = rows[r];
    final name = _rowCell(row, nameCol);
    if (name.isEmpty) {
      emptyRun++;
      if (emptyRun >= stopAfterEmptyRun) break;
      continue;
    }
    emptyRun = 0;
    final lower = name.toLowerCase();
    if (lower.startsWith('eingeplant') ||
        lower.startsWith('gesamt') ||
        lower.startsWith('summe') ||
        // Englischer Export: "Total rostered".
        lower.startsWith('total')) {
      continue;
    }
    final tid = _rowCell(row, tidCol);
    if (tid.isEmpty) continue;

    if (seenTids.add(tid.toUpperCase())) {
      roster.add(ShiftRoster(transporterId: tid, driverName: name));
    }

    for (final entry in dayCols.entries) {
      final col = entry.key;
      final date = entry.value;
      final raw = _rowCell(row, col);
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
  final Excel excel = _decodeWorkbook(bytes);
  final Sheet sheet = _pickShiftSheet(excel);

  // ─── Pull metadata (row 1 = labels, row 2 = values) ───
  String company = '';
  String station = '';
  if (sheet.maxRows >= 2) {
    company = _cellString(sheet, col: 1, row: 1);
    station = _cellString(sheet, col: 2, row: 1);
  }

  // ─── Find the header row + name/TID columns (tolerant) ───
  final rows = sheet.rows;
  final header = _findNameHeader(rows);
  if (header == null) {
    throw FormatException(_headerNotFoundMessage(excel, rows));
  }
  final headerRow = header.row;
  final nameCol = header.nameCol;
  final tidCol = header.tidCol;

  // ─── Day columns start right of the TID column ───
  final year = assumeYear ?? DateTime.now().year;
  final dayCols = <int, DateTime>{};
  final headerRowData =
      rows.length > headerRow ? rows[headerRow] : const <Data?>[];
  for (var c = tidCol + 1; c < headerRowData.length; c++) {
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
    final name = _cellString(sheet, col: nameCol, row: r);
    if (name.isEmpty) continue;
    final lower = name.toLowerCase();
    if (lower.startsWith('eingeplant') ||
        lower.startsWith('gesamt') ||
        lower.startsWith('summe') ||
        // Englischer Export: "Total rostered".
        lower.startsWith('total')) {
      continue;
    }
    final tid = _cellString(sheet, col: tidCol, row: r);
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

/// Baut die Header-nicht-gefunden-Meldung MIT Diagnose: Blattnamen und
/// die ersten Zellen der ersten Zeilen. So sagt schon der Screenshot des
/// Fehlers, wie die fremde Datei aufgebaut ist (englischer Export,
/// anderes Blatt, neu gespeichert, …) — ohne dass die Datei erst
/// eingeschickt werden muss.
String _headerNotFoundMessage(Excel excel, List<List<Data?>> rows) {
  final sheets = excel.tables.keys.join(', ');
  final preview = StringBuffer();
  for (var r = 0; r < rows.length && r < 6; r++) {
    final cells = <String>[];
    final row = rows[r];
    for (var c = 0; c < row.length && c < 6; c++) {
      final v = _rowCell(row, c);
      if (v.isNotEmpty) cells.add(v.length > 24 ? '${v.substring(0, 24)}…' : v);
    }
    if (cells.isNotEmpty) {
      preview.writeln('Zeile ${r + 1}: ${cells.join(' | ')}');
    }
  }
  return 'Header-Zeile mit der Namens-Spalte ("Name des Mitarbeiters" / '
      '"Employee Name") wurde nicht gefunden. Bitte den Amazon-Export '
      'unverändert hochladen.\n\n'
      'Diagnose — Blätter: $sheets\n'
      '${preview.toString().trim()}';
}

/// Decodes the workbook with a user-readable error instead of the
/// excel package's internal exceptions (minified stack traces on web).
Excel _decodeWorkbook(Uint8List bytes) {
  try {
    return Excel.decodeBytes(bytes);
  } catch (e) {
    throw FormatException(
      'Die Datei konnte nicht als Excel (.xlsx) gelesen werden. '
      'Bitte den originalen Amazon-Export unverändert hochladen — '
      '.xls/CSV oder in LibreOffice neu gespeicherte Dateien werden '
      'nicht unterstützt. (Details: $e)',
    );
  }
}

/// Picks the "Arbeitsblöcke…" sheet, else the first non-empty sheet.
Sheet _pickShiftSheet(Excel excel) {
  final keys = excel.tables.keys.toList();
  if (keys.isEmpty) {
    throw const FormatException('Die Excel-Datei enthält keine Tabellen.');
  }
  // DE: "Arbeitsblöcke nach Dienstplan" · EN: "Rostered work blocks" —
  // je nach Sprache der Amazon-Oberflaeche beim Download.
  final byName = keys.where((k) {
    final l = k.toLowerCase();
    return l.contains('arbeitsbl') || l.contains('rostered work');
  });
  if (byName.isNotEmpty) return excel.tables[byName.first]!;
  // Fallback: first sheet that actually has rows (skips empty cover sheets).
  for (final k in keys) {
    final s = excel.tables[k]!;
    if (s.maxRows > 0) return s;
  }
  return excel.tables[keys.first]!;
}

/// Reads a trimmed string from a pre-parsed row (from `sheet.rows`).
/// Much cheaper than `sheet.cell()` because it avoids per-cell index
/// construction and lookups.
String _rowCell(List<Data?> row, int col) {
  if (col < 0 || col >= row.length) return '';
  final v = row[col]?.value;
  if (v == null) return '';
  if (v is TextCellValue) return v.value.text?.trim() ?? '';
  return v.toString().trim();
}

/// Where the roster header sits, and which columns hold the driver name
/// and the transporter-ID.
class _HeaderLocation {
  final int row;
  final int nameCol;
  final int tidCol;
  const _HeaderLocation(this.row, this.nameCol, this.tidCol);
}

/// Tolerantly locates the header row and the name column. Amazon's export
/// usually puts "Name des Mitarbeiters" in column A, but exports vary
/// (extra leading columns, English headers, "Mitarbeiter" only). We scan
/// the first rows/columns for anything that looks like a name header, then
/// take the next non-empty header cell as the transporter-ID column.
_HeaderLocation? _findNameHeader(List<List<Data?>> rows) {
  const maxScanRows = 40;
  const maxScanCols = 12;

  // Metadaten-Labels wie "Name des Unternehmens" / "Name der Station"
  // stehen in Zeile 1 des Amazon-Exports und dürfen NICHT als
  // Mitarbeiter-Spalte erkannt werden.
  bool looksLikeMeta(String l) {
    return l.contains('unternehmen') ||
        l.contains('station') ||
        l.contains('standort') ||
        l.contains('firma') ||
        l.contains('company') ||
        l.contains('woche');
  }

  bool looksLikeName(String s) {
    final l = s.toLowerCase().trim();
    if (looksLikeMeta(l)) return false;
    return l.startsWith('name des mit') ||
        l == 'name' ||
        l.startsWith('name ') ||
        l == 'mitarbeiter' ||
        l.startsWith('mitarbeiter') ||
        l.contains('employee name') ||
        // Englischer Amazon-Export: "Associate name" (und Verwandte wie
        // "Driver name"). Meta-Spalten wie "Company name" filtert
        // looksLikeMeta oben schon weg.
        l.contains('associate name') ||
        l.endsWith(' name') ||
        (l.contains('name') && l.contains('mitarbeiter'));
  }

  bool looksLikeTid(String s) {
    final l = s.toLowerCase().trim();
    return l.contains('transporter') ||
        l.contains('mitarbeiter-id') ||
        l.contains('mitarbeiter id') ||
        l == 'id' ||
        l.contains('personal') ||
        l.endsWith(' id') ||
        l.contains('tid');
  }

  final rowCount = rows.length < maxScanRows ? rows.length : maxScanRows;
  final anyYear = DateTime.now().year;
  _HeaderLocation? fallback;
  for (var r = 0; r < rowCount; r++) {
    final row = rows[r];
    final colCount = row.length < maxScanCols ? row.length : maxScanCols;
    for (var c = 0; c < colCount; c++) {
      final cell = _rowCell(row, c);
      if (cell.isEmpty || !looksLikeName(cell)) continue;
      // Found a name column candidate. Pick the TID column: the next
      // header cell that looks like an ID, else simply the next column.
      var tidCol = c + 1;
      for (var cc = c + 1; cc < colCount; cc++) {
        if (looksLikeTid(_rowCell(row, cc))) {
          tidCol = cc;
          break;
        }
      }
      final loc = _HeaderLocation(r, c, tidCol);
      // Nur Zeilen mit echten Tages-Spalten rechts daneben sind der
      // Roster-Header; sonst als Fallback merken und weitersuchen.
      var dayLabels = 0;
      for (var cc = tidCol + 1; cc < row.length; cc++) {
        final label = _rowCell(row, cc);
        if (label.isEmpty) continue;
        if (_parseDayLabel(label, anyYear) != null) dayLabels++;
      }
      if (dayLabels > 0) return loc;
      fallback ??= loc;
    }
  }
  return fallback;
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
  final d = DateTime(year, month, day);
  // Guard against silent rollover (e.g. "32/Mai" → 1. Juni).
  if (d.month != month || d.day != day) return null;
  return d;
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
