// lib/services/concessions_csv_parser.dart
//
// Client-seitiger Parser fuer den NEUEN Amazon-Concessions-Export im
// CSV-Format (ab 2026), z. B.
//
//   DSP_Associates_Concessions_DBY5_2026-W33.csv
//
// Amazon liefert die Datei als UTF-8 (mit BOM), komma-getrennt, alle Felder
// gequotet und mit deutschen Spaltenueberschriften:
//
//   "Woche","Name des Zustellenden","Zustellende-ID","Zugestellte Pakete",
//   "Pakete, die geliefert aber nicht empfangen wurden (DNR)","DNR DPMO",
//   "Versendete Pakete",
//   "Pakete, die an das Verteilzentrum zurueckgeliefert wurden (RTS)",
//   "... (RTS) %","Zum Verteilzentrum zurueck DPMO"
//
// Zahlen kommen im deutschen Format: "1.463" = 1463 (Tausenderpunkt!),
// Prozentwerte dagegen mit Punkt als Dezimaltrenner ("0.16%").
//
// Das Ergebnis ist BIT-KOMPATIBEL zu dem JSON, das der externe
// parser_service (`/parse`) fuer die alten Concessions-XLSX geliefert hat:
//
//   { "count": <int>, "drivers": [ {...} ], "summary": { ... } }
//
// damit `ReportWriter.writeReportAndScores(parserJson: ...)` unveraendert
// weiterverwendet werden kann.
//
// Reiner Dart-Code (kein Flutter, keine Packages) — dadurch auch in
// `tool/concessions_csv_test.dart` per `dart run` testbar.

import 'dart:convert';
import 'dart:typed_data';

/// Parser fuer den Amazon "DSP Associates Concessions"-CSV-Export.
class ConcessionsCsvParser {
  ConcessionsCsvParser._();

  /// Erkennt anhand der Dateiendung, ob der Client-Parser zustaendig ist.
  static bool isCsvFile(String filename) =>
      filename.toLowerCase().trim().endsWith('.csv');

  // ---------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------

  /// Parst die Rohbytes der CSV-Datei.
  static Map<String, dynamic> parseBytes(
    Uint8List bytes, {
    required String filename,
  }) {
    return parseString(_decode(bytes), filename: filename);
  }

  /// Parst den bereits dekodierten CSV-Text.
  static Map<String, dynamic> parseString(
    String csvText, {
    required String filename,
  }) {
    final rows = _splitCsv(csvText);
    if (rows.isEmpty) {
      throw const FormatException('Concessions-CSV: Datei ist leer.');
    }

    final header = rows.first;
    final cols = _ColumnMap.fromHeader(header);
    if (cols.transporterId < 0) {
      throw FormatException(
        'Concessions-CSV: Spalte "Zustellende-ID" nicht gefunden '
        '(Header: ${header.join(" | ")}).',
      );
    }

    final meta = parseMetaFromFilename(filename);

    // Rohzeilen -> pro (TID, Woche) aggregiert.
    final byId = <String, _DriverAcc>{};
    final weekKeys = <String>{};

    for (var i = 1; i < rows.length; i++) {
      final r = rows[i];
      if (r.isEmpty) continue;
      final rawTid = cols.pick(r, cols.transporterId);
      final tid = normalizeTransporterId(rawTid);
      if (tid.isEmpty) continue;
      final lower = tid.toLowerCase();
      if (lower == 'grandtotal' || lower == 'total') continue;

      final weekLabel = _normalizeWeekLabel(
        cols.pick(r, cols.week),
        fallbackYear: meta.year,
        fallbackWeek: meta.weekNumber,
      );
      if (weekLabel != null) weekKeys.add(weekLabel);

      final acc = byId.putIfAbsent(tid, () => _DriverAcc(tid));
      final name = cols.pick(r, cols.name).trim();
      if (name.isNotEmpty) acc.name = name;

      acc.addWeek(
        weekLabel: weekLabel,
        delivered: parseGermanNumber(cols.pick(r, cols.delivered)),
        dnrCount: parseGermanNumber(cols.pick(r, cols.dnrCount)),
        dnrDpmo: parseGermanNumber(cols.pick(r, cols.dnrDpmo)),
        shipped: parseGermanNumber(cols.pick(r, cols.shipped)),
        rtsCount: parseGermanNumber(cols.pick(r, cols.rtsCount)),
        rtsPct: parsePercent(cols.pick(r, cols.rtsPct)),
        rtsDpmo: parseGermanNumber(cols.pick(r, cols.rtsDpmo)),
      );
    }

    // Woche/Jahr: primaer aus der Spalte "Woche", sonst aus dem Dateinamen.
    final sortedWeeks = weekKeys.toList()..sort(_compareWeekLabels);
    int? year = meta.year;
    int? weekNumber = meta.weekNumber;
    if (sortedWeeks.isNotEmpty) {
      final parsed = _parseWeekLabel(sortedWeeks.last);
      if (parsed != null) {
        year = parsed.$1;
        weekNumber = parsed.$2;
      }
    }

    final drivers = <Map<String, dynamic>>[];
    var dspDelivered = 0.0;
    var dspDnr = 0.0;
    var hasDspVolume = false;

    for (final acc in byId.values) {
      drivers.add(acc.toParserRow(
        reportYear: year,
        reportWeek: weekNumber,
      ));
      if (acc.delivered != null) {
        dspDelivered += acc.delivered!;
        hasDspVolume = true;
      }
      if (acc.dnrCount != null) dspDnr += acc.dnrCount!;
    }

    // Stabile Reihenfolge (wie im Export: nach DNR absteigend, dann Name).
    drivers.sort((a, b) {
      final dnrA = (a['CONC_TotalDnr'] as num?)?.toDouble() ?? 0;
      final dnrB = (b['CONC_TotalDnr'] as num?)?.toDouble() ?? 0;
      final byDnr = dnrB.compareTo(dnrA);
      if (byDnr != 0) return byDnr;
      return (a['driverName'] ?? '')
          .toString()
          .compareTo((b['driverName'] ?? '').toString());
    });

    final summaryBlock = <String, dynamic>{
      if (hasDspVolume && dspDelivered > 0) 'delVolume': dspDelivered,
      if (dspDnr > 0) 'dnrCount': dspDnr,
      if (hasDspVolume && dspDelivered > 0)
        'dnrDpmo': (dspDnr / dspDelivered) * 1000000.0,
      'weekLabels': sortedWeeks,
    };

    final summary = <String, dynamic>{
      'concessionsSummary': summaryBlock,
      if (weekNumber != null) 'weekText': 'KW $weekNumber',
      if (weekNumber != null) 'weekNumber': weekNumber,
      if (year != null) 'year': year,
      if (meta.stationCode != null) 'stationCode': meta.stationCode,
      // Marker fuer die Herkunft — analog zu "concessionsFormat": "dsc"
      // im parser_service.
      'concessionsFormat': 'csv',
    };

    return <String, dynamic>{
      'count': drivers.length,
      'drivers': drivers,
      'summary': summary,
    };
  }

  // ---------------------------------------------------------------------
  // Dateiname-Metadaten
  // ---------------------------------------------------------------------

  /// Zieht Station / Jahr / Woche aus Dateinamen wie
  /// `DSP_Associates_Concessions_DBY5_2026-W33.csv` (neu) oder
  /// `DE-AION-DBY5-Week19-Concessions.xlsx` (alt).
  static ConcessionsFileMeta parseMetaFromFilename(String filename) {
    var base = filename.replaceAll('\\', '/').split('/').last;
    final dot = base.lastIndexOf('.');
    if (dot > 0) base = base.substring(0, dot);

    String? station;
    int? year;
    int? week;

    // Neues Format: ..._<STATION>_<YYYY>-W<WW>
    final mNew = RegExp(
      r'([A-Za-z]{2,4}\d{1,3}[A-Za-z]?)[_-](\d{4})[-_]?W(\d{1,2})',
    ).firstMatch(base);
    if (mNew != null) {
      station = mNew.group(1)!.toUpperCase();
      year = int.tryParse(mNew.group(2)!);
      week = int.tryParse(mNew.group(3)!);
    } else {
      // Altes Format: DE-AION-DBY5-Week19-Concessions
      final mOld = RegExp(
        r'([A-Z]{2})-([A-Z0-9]+)-([A-Z0-9]+)-Week(\d+)',
        caseSensitive: false,
      ).firstMatch(base);
      if (mOld != null) {
        station = mOld.group(3)!.toUpperCase();
        week = int.tryParse(mOld.group(4)!);
      } else {
        // Fallback: irgendwo "2026-W33"
        final mWeek =
            RegExp(r'(\d{4})[-_]?W(\d{1,2})', caseSensitive: false)
                .firstMatch(base);
        if (mWeek != null) {
          year = int.tryParse(mWeek.group(1)!);
          week = int.tryParse(mWeek.group(2)!);
        }
      }
    }

    return ConcessionsFileMeta(
      stationCode: station,
      year: year,
      weekNumber: week,
    );
  }

  // ---------------------------------------------------------------------
  // Zahlen-Parsing (deutsche Formate)
  // ---------------------------------------------------------------------

  /// Parst Zahlen im deutschen Export-Format.
  ///
  /// * `"1.463"` -> 1463 (Tausenderpunkt)
  /// * `"12.944"` -> 12944
  /// * `"683"` -> 683
  /// * `"1.234.567"` -> 1234567
  /// * `"12,5"` -> 12.5 (deutsches Dezimalkomma)
  /// * `"1.234,5"` -> 1234.5
  /// * `"0.16"` -> 0.16 (Punkt ohne 3er-Gruppe = Dezimalpunkt)
  static double? parseGermanNumber(String? raw) {
    if (raw == null) return null;
    var s = raw
        .trim()
        .replaceAll(' ', '')
        .replaceAll(' ', '')
        .replaceAll(' ', '')
        .replaceAll('"', '');
    if (s.isEmpty) return null;
    if (s == '-' || s == '—' || s == '–' || s.toLowerCase() == 'n/a') {
      return null;
    }
    if (s.contains('%')) return parsePercent(s);

    var negative = false;
    if (s.startsWith('-')) {
      negative = true;
      s = s.substring(1);
    } else if (s.startsWith('+')) {
      s = s.substring(1);
    }
    if (s.isEmpty) return null;

    final hasDot = s.contains('.');
    final hasComma = s.contains(',');

    if (hasDot && hasComma) {
      // Der letzte Trenner ist der Dezimaltrenner.
      if (s.lastIndexOf(',') > s.lastIndexOf('.')) {
        s = s.replaceAll('.', '').replaceAll(',', '.');
      } else {
        s = s.replaceAll(',', '');
      }
    } else if (hasComma) {
      s = _isThousandsGrouped(s, ',')
          ? s.replaceAll(',', '')
          : s.replaceAll(',', '.');
    } else if (hasDot) {
      // Punkt: nur dann Tausenderpunkt, wenn er sauber 3er-Gruppen bildet.
      if (_isThousandsGrouped(s, '.')) s = s.replaceAll('.', '');
    }

    final v = double.tryParse(s);
    if (v == null) return null;
    return negative ? -v : v;
  }

  /// Parst Prozentwerte wie `"0.16%"` oder `"7,97 %"` -> 0.16 / 7.97.
  static double? parsePercent(String? raw) {
    if (raw == null) return null;
    var s = raw
        .trim()
        .replaceAll('%', '')
        .replaceAll(' ', '')
        .replaceAll(' ', '')
        .replaceAll(' ', '')
        .replaceAll('"', '');
    if (s.isEmpty) return null;
    if (s == '-' || s == '—' || s == '–') return null;

    var negative = false;
    if (s.startsWith('-')) {
      negative = true;
      s = s.substring(1);
    }
    final hasDot = s.contains('.');
    final hasComma = s.contains(',');
    if (hasDot && hasComma) {
      if (s.lastIndexOf(',') > s.lastIndexOf('.')) {
        s = s.replaceAll('.', '').replaceAll(',', '.');
      } else {
        s = s.replaceAll(',', '');
      }
    } else if (hasComma) {
      s = s.replaceAll(',', '.');
    }
    final v = double.tryParse(s);
    if (v == null) return null;
    return negative ? -v : v;
  }

  static bool _isThousandsGrouped(String s, String sep) {
    final esc = RegExp.escape(sep);
    return RegExp('^\\d{1,3}($esc\\d{3})+\$').hasMatch(s);
  }

  /// Uppercase + nur A-Z0-9 — identisch zu
  /// `DriverCsvService.normalizeTransporterId`.
  static String normalizeTransporterId(String raw) {
    final cleaned = raw.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    return cleaned.isEmpty ? raw.trim() : cleaned;
  }

  // ---------------------------------------------------------------------
  // CSV / Encoding
  // ---------------------------------------------------------------------

  static String _decode(Uint8List bytes) {
    var data = bytes;
    // UTF-8 BOM
    if (data.length >= 3 &&
        data[0] == 0xEF &&
        data[1] == 0xBB &&
        data[2] == 0xBF) {
      data = Uint8List.sublistView(data, 3);
    }
    try {
      return utf8.decode(data);
    } catch (_) {
      return latin1.decode(data);
    }
  }

  /// Minimaler RFC-4180-CSV-Reader (Quotes, `""`-Escapes, CRLF, BOM).
  /// Der Trenner wird aus der Kopfzeile erkannt (`,` / `;` / Tab).
  static List<List<String>> _splitCsv(String text) {
    var input = text;
    if (input.startsWith('﻿')) input = input.substring(1);
    if (input.trim().isEmpty) return const [];

    final delimiter = _detectDelimiter(input);

    final rows = <List<String>>[];
    var row = <String>[];
    final field = StringBuffer();
    var inQuotes = false;
    var fieldStarted = false;

    void endField() {
      row.add(field.toString());
      field.clear();
      fieldStarted = false;
    }

    void endRow() {
      endField();
      if (row.length == 1 && row.first.trim().isEmpty) {
        row = <String>[];
        return;
      }
      rows.add(row);
      row = <String>[];
    }

    for (var i = 0; i < input.length; i++) {
      final ch = input[i];
      if (inQuotes) {
        if (ch == '"') {
          if (i + 1 < input.length && input[i + 1] == '"') {
            field.write('"');
            i++;
          } else {
            inQuotes = false;
          }
        } else {
          field.write(ch);
        }
        continue;
      }
      if (ch == '"' && !fieldStarted) {
        inQuotes = true;
        fieldStarted = true;
        continue;
      }
      if (ch == delimiter) {
        endField();
        continue;
      }
      if (ch == '\r') continue;
      if (ch == '\n') {
        endRow();
        continue;
      }
      fieldStarted = true;
      field.write(ch);
    }
    if (field.isNotEmpty || row.isNotEmpty) endRow();

    return rows;
  }

  static String _detectDelimiter(String input) {
    final nl = input.indexOf('\n');
    final head = nl >= 0 ? input.substring(0, nl) : input;
    var comma = 0, semi = 0, tab = 0;
    var inQuotes = false;
    for (var i = 0; i < head.length; i++) {
      final ch = head[i];
      if (ch == '"') {
        inQuotes = !inQuotes;
        continue;
      }
      if (inQuotes) continue;
      if (ch == ',') comma++;
      if (ch == ';') semi++;
      if (ch == '\t') tab++;
    }
    if (semi > comma && semi >= tab) return ';';
    if (tab > comma && tab > semi) return '\t';
    return ',';
  }

  // ---------------------------------------------------------------------
  // Wochen-Label
  // ---------------------------------------------------------------------

  /// `"2026-33"` / `"2026-W33"` / `"33"` -> `"2026-33"`.
  static String? _normalizeWeekLabel(
    String raw, {
    int? fallbackYear,
    int? fallbackWeek,
  }) {
    final s = raw.trim();
    if (s.isNotEmpty) {
      final m = RegExp(r'(\d{4})\s*[-/_]?\s*W?(\d{1,2})').firstMatch(s);
      if (m != null) {
        final y = int.parse(m.group(1)!);
        final w = int.parse(m.group(2)!);
        return '$y-$w';
      }
      final onlyWeek = RegExp(r'^W?(\d{1,2})$').firstMatch(s);
      if (onlyWeek != null && fallbackYear != null) {
        return '$fallbackYear-${int.parse(onlyWeek.group(1)!)}';
      }
    }
    if (fallbackYear != null && fallbackWeek != null) {
      return '$fallbackYear-$fallbackWeek';
    }
    return null;
  }

  static (int, int)? _parseWeekLabel(String label) {
    final m = RegExp(r'^(\d{4})-(\d{1,2})$').firstMatch(label);
    if (m == null) return null;
    return (int.parse(m.group(1)!), int.parse(m.group(2)!));
  }

  static int _compareWeekLabels(String a, String b) {
    final pa = _parseWeekLabel(a);
    final pb = _parseWeekLabel(b);
    if (pa == null || pb == null) return a.compareTo(b);
    final byYear = pa.$1.compareTo(pb.$1);
    if (byYear != 0) return byYear;
    return pa.$2.compareTo(pb.$2);
  }

  /// Verschiebt (Jahr, ISO-Woche) um [offset] Wochen — identisch zur Logik
  /// in `concessions_week.dart` / `driver_performance_sections.dart`.
  static (int, int) shiftIsoWeek(int year, int week, int offset) {
    DateTime mondayOfW1(int y) {
      final jan4 = DateTime(y, 1, 4);
      return jan4.subtract(Duration(days: (jan4.weekday + 6) % 7));
    }

    final monday =
        mondayOfW1(year).add(Duration(days: (week - 1 + offset) * 7));
    final thursday = monday.add(const Duration(days: 3));
    final isoYear = thursday.year;
    final isoWeek =
        (monday.difference(mondayOfW1(isoYear)).inDays ~/ 7) + 1;
    return (isoYear, isoWeek);
  }
}

/// Aus dem Dateinamen gelesene Metadaten.
class ConcessionsFileMeta {
  const ConcessionsFileMeta({this.stationCode, this.year, this.weekNumber});

  final String? stationCode;
  final int? year;
  final int? weekNumber;
}

// -------------------------------------------------------------------------
// Interne Helfer
// -------------------------------------------------------------------------

/// Spalten-Index-Auflösung anhand der (deutschen oder englischen) Header.
class _ColumnMap {
  int week = -1;
  int name = -1;
  int transporterId = -1;
  int delivered = -1;
  int dnrCount = -1;
  int dnrDpmo = -1;
  int shipped = -1;
  int rtsCount = -1;
  int rtsPct = -1;
  int rtsDpmo = -1;

  static String _norm(String h) => h
      .toLowerCase()
      .replaceAll('"', '')
      .replaceAll(' ', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  static _ColumnMap fromHeader(List<String> header) {
    final map = _ColumnMap();
    for (var i = 0; i < header.length; i++) {
      final h = _norm(header[i]);
      if (h.isEmpty) continue;

      final isDpmo = h.contains('dpmo');
      final isDnr = h.contains('dnr') || h.contains('nicht empfangen');
      final isRts = h.contains('rts') ||
          h.contains('zurückgeliefert') ||
          h.contains('zuruckgeliefert') ||
          h.contains('zurück') ||
          h.contains('returned to station');

      if (isDpmo) {
        if (isDnr && map.dnrDpmo < 0) {
          map.dnrDpmo = i;
        } else if (map.rtsDpmo < 0) {
          map.rtsDpmo = i;
        }
        continue;
      }
      if (isRts) {
        if (h.contains('%') || h.contains('prozent')) {
          if (map.rtsPct < 0) map.rtsPct = i;
        } else if (map.rtsCount < 0) {
          map.rtsCount = i;
        }
        continue;
      }
      if (isDnr) {
        if (map.dnrCount < 0) map.dnrCount = i;
        continue;
      }
      if (h.contains('zugestellte') || h.contains('delivered package')) {
        if (map.delivered < 0) map.delivered = i;
        continue;
      }
      if (h.contains('versendete') ||
          h.contains('shipped') ||
          h.contains('dispatched')) {
        if (map.shipped < 0) map.shipped = i;
        continue;
      }
      if (h.contains('woche') || h == 'week' || h.startsWith('week')) {
        if (map.week < 0) map.week = i;
        continue;
      }
      if (h.contains('name')) {
        if (map.name < 0) map.name = i;
        continue;
      }
      if (h.contains('id')) {
        if (map.transporterId < 0) map.transporterId = i;
        continue;
      }
    }
    return map;
  }

  String pick(List<String> row, int idx) {
    if (idx < 0 || idx >= row.length) return '';
    return row[idx];
  }
}

/// Sammelt (ggf. mehrere Wochen-)Zeilen eines Fahrers.
class _DriverAcc {
  _DriverAcc(this.transporterId);

  final String transporterId;
  String? name;

  double? delivered;
  double? dnrCount;
  double? shipped;
  double? rtsCount;

  /// weekLabel -> DNR-Anzahl
  final Map<String, double> dnrByWeek = {};

  /// weekLabel -> DNR DPMO
  final Map<String, double> dnrDpmoByWeek = {};

  /// weekLabel -> RTS-Prozent / RTS-DPMO
  final Map<String, double> rtsPctByWeek = {};
  final Map<String, double> rtsDpmoByWeek = {};

  int rowCount = 0;

  void addWeek({
    required String? weekLabel,
    double? delivered,
    double? dnrCount,
    double? dnrDpmo,
    double? shipped,
    double? rtsCount,
    double? rtsPct,
    double? rtsDpmo,
  }) {
    rowCount++;
    if (delivered != null) this.delivered = (this.delivered ?? 0) + delivered;
    if (dnrCount != null) this.dnrCount = (this.dnrCount ?? 0) + dnrCount;
    if (shipped != null) this.shipped = (this.shipped ?? 0) + shipped;
    if (rtsCount != null) this.rtsCount = (this.rtsCount ?? 0) + rtsCount;

    if (weekLabel == null) return;
    if (dnrCount != null) {
      dnrByWeek[weekLabel] = (dnrByWeek[weekLabel] ?? 0) + dnrCount;
    }
    if (dnrDpmo != null) dnrDpmoByWeek[weekLabel] = dnrDpmo;
    if (rtsPct != null) rtsPctByWeek[weekLabel] = rtsPct;
    if (rtsDpmo != null) rtsDpmoByWeek[weekLabel] = rtsDpmo;
  }

  /// Erzeugt eine Fahrer-Zeile im parser_service-Schema.
  Map<String, dynamic> toParserRow({int? reportYear, int? reportWeek}) {
    final row = <String, dynamic>{
      'Transporter ID': transporterId,
      if (name != null && name!.isNotEmpty) 'driverName': name,
      'CONC_TotalDelivered': delivered,
      'CONC_TotalDnr': dnrCount ?? 0,
    };

    // DNR DPMO: bei genau einer Woche den von Amazon gelieferten Wert
    // uebernehmen, sonst aus den Summen rechnen.
    double? dpmo4w;
    if (dnrDpmoByWeek.length == 1) {
      dpmo4w = dnrDpmoByWeek.values.first;
    } else if (delivered != null && delivered! > 0) {
      dpmo4w = ((dnrCount ?? 0) / delivered!) * 1000000.0;
    }
    row['CONC_DnrDpmo4w'] = dpmo4w;

    // w1..w4 relativ zur Report-Woche (w4 = Report-Woche selbst) — genau die
    // Semantik, die concessions_week.dart / driver_performance_sections.dart
    // erwarten.
    if (reportYear != null && reportWeek != null) {
      const offsets = <String, int>{'w4': 0, 'w3': -1, 'w2': -2, 'w1': -3};
      for (final e in offsets.entries) {
        final shifted =
            ConcessionsCsvParser.shiftIsoWeek(reportYear, reportWeek, e.value);
        final label = '${shifted.$1}-${shifted.$2}';
        final cnt = dnrByWeek[label];
        final dpmo = dnrDpmoByWeek[label];
        final slot = e.key.toUpperCase(); // W1..W4
        if (cnt != null) row['CONC_DnrCount_$slot'] = cnt;
        if (dpmo != null) row['CONC_DnrDpmo_$slot'] = dpmo;
      }
    }

    // Echte {Jahr-Woche: Anzahl}-Map (wie im DSC-XLSX-Format).
    if (dnrByWeek.isNotEmpty) {
      row['CONC_DnrCountByWeek'] = Map<String, dynamic>.from(dnrByWeek);
    }

    // Neu im CSV-Export und ohne Entsprechung im alten XLSX-JSON:
    // RTS (Rueckfuehrungen ans Verteilzentrum) + versendete Pakete.
    // Werden vom ReportWriter derzeit nicht persistiert, bleiben aber im
    // parserJson erhalten.
    row['CONC_TotalShipped'] = shipped;
    row['CONC_RtsCount'] = rtsCount ?? 0;
    row['CONC_RtsPct'] = rtsPctByWeek.isEmpty
        ? ((shipped != null && shipped! > 0)
            ? ((rtsCount ?? 0) / shipped!) * 100.0
            : null)
        : (rtsPctByWeek.length == 1
            ? rtsPctByWeek.values.first
            : ((shipped != null && shipped! > 0)
                ? ((rtsCount ?? 0) / shipped!) * 100.0
                : null));
    row['CONC_RtsDpmo'] = rtsDpmoByWeek.length == 1
        ? rtsDpmoByWeek.values.first
        : ((shipped != null && shipped! > 0)
            ? ((rtsCount ?? 0) / shipped!) * 1000000.0
            : null);

    return row;
  }
}
