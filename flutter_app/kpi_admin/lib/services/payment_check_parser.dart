// lib/services/payment_check_parser.dart
//
// Payment Check — parsing + reconciliation core.
//
// PRIVACY / DATENSCHUTZ
// ─────────────────────
// Everything in this file is *pure computation* on bytes that the caller
// already holds in memory. Nothing here reads or writes files, opens sockets,
// touches Firestore / Storage / the parser_service or any other backend.
// The Payment Check screen feeds invoice + WST bytes straight from the file
// picker into these functions and keeps the results in widget state only.
//
// This file is deliberately **Flutter-free** (no `package:flutter`, no
// `dart:ui`) so that the exact same code runs
//   * inside the web app, and
//   * inside the standalone harness `tool/payment_check_parse_test.dart`
//     via plain `dart run`.
//
// Contents:
//   1. PDF text extraction (pure Dart, content-stream interpreter)
//   2. Amazon invoice (Gutschrift) parsing
//   3. Work Summary Tool (WST) ZIP/CSV parsing
//   4. Reconciliation — "what is MISSING on the invoice"

import 'dart:convert';

import 'package:archive/archive.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 0. Shared text helpers
// ═══════════════════════════════════════════════════════════════════════════

/// All the hyphen-ish code points Amazon / the WST export mix freely:
/// U+2010 hyphen, U+2011 non-breaking hyphen, U+2012 figure dash,
/// U+2013 en dash, U+2014 em dash, U+2212 minus sign.
final RegExp _kDashVariants = RegExp('[‐‑‒–—−]');
final RegExp _kWhitespaceRun = RegExp(r'\s+');

/// Canonicalises a free-text label: unifies dash variants, collapses runs of
/// whitespace (incl. NBSP) and trims. Case is preserved — use [normKey] for
/// comparison keys.
String normText(String s) => s
    .replaceAll(' ', ' ')
    .replaceAll('﻿', '')
    .replaceAll(_kDashVariants, '-')
    .replaceAll(_kWhitespaceRun, ' ')
    .trim();

/// Comparison key: [normText] + lower-case, and spaces around dashes removed
/// so that `A - B`, `A-B` and `A — B` all collapse to the same key.
String normKey(String s) =>
    normText(s).toLowerCase().replaceAll(RegExp(r'\s*-\s*'), '-');

/// Pure thousands grouping with dots and no decimal part: `10.436`,
/// `1.234.567`. Every group after the first must be exactly three digits,
/// which is what separates it from a US decimal like `250.65` or a quantity
/// like `10436.0`.
final RegExp _kDotGrouped = RegExp(r'^\d{1,3}(\.\d{3})+$');

/// Every flavour of space that can show up as a thousands separator or as
/// padding: normal, NBSP, narrow NBSP, thin space, tab, newline.
final RegExp _kAnySpace = RegExp(r'[\s\u00A0\u202F\u2009\u2007]');

/// Parses a number that may be German (`1.234,56`, `10.436`) or plain/US
/// (`20.0`, `10436.0`).
///
/// Amazon invoices mix both in the *same table row*: money uses `,` as the
/// decimal separator with `.` as the thousands separator, while quantities are
/// emitted as `20.0` / `10436.0`. The WST CSVs additionally emit plain German
/// grouped integers **without** a comma (`10.436`) — reading those as a US
/// decimal silently truncated them to `10`, under-reporting the WST side and
/// hiding real gaps. Hence the explicit grouping check below.
double? parseNumberLoose(String raw) {
  // Strip spaces first, so space-grouped values like `10 436` collapse to
  // `10436` on their own.
  var s = raw.replaceAll(_kAnySpace, '');
  s = s.replaceAll('\u20AC', '').replaceAll('EUR', '').trim();
  if (s.isEmpty) return null;
  final negative = s.startsWith('-') || (s.startsWith('(') && s.endsWith(')'));
  s = s.replaceAll(RegExp(r'^[-(]|\)$'), '');
  if (s.contains(',')) {
    // German money: dots are grouping, the comma is the decimal separator.
    s = s.replaceAll('.', '').replaceAll(',', '.');
  } else if (_kDotGrouped.hasMatch(s)) {
    // German grouped integer without decimals: dots are grouping only.
    s = s.replaceAll('.', '');
  }
  final v = double.tryParse(s);
  if (v == null) return null;
  return negative ? -v : v;
}

String _two(int v) => v.toString().padLeft(2, '0');

/// `yyyy-MM-dd` — the canonical join key for both sources.
String dayKey(DateTime d) => '${d.year}-${_two(d.month)}-${_two(d.day)}';

/// Formats a date the German way (`03.08.2026`) or ISO for EN callers.
String formatDay(DateTime d, {bool de = true}) => de
    ? '${_two(d.day)}.${_two(d.month)}.${d.year}'
    : '${d.year}-${_two(d.month)}-${_two(d.day)}';

// ═══════════════════════════════════════════════════════════════════════════
// 1. PDF text extraction — pure Dart
// ═══════════════════════════════════════════════════════════════════════════
//
// Why hand-rolled instead of only syncfusion_flutter_pdf?
//   * syncfusion_flutter_pdf pulls in `dart:ui`, so it cannot run under a
//     plain `dart run` harness — the verification harness would then test
//     *different* code than the app.
//   * The Amazon Gutschrift is a plain, uncompressed-font PDF (FlateDecode
//     content streams, Type1 Helvetica, WinAnsiEncoding, no CMaps), which a
//     compact content-stream interpreter handles exactly.
//
// The Flutter screen still keeps syncfusion as a *fallback* for exotic PDFs
// (embedded subset fonts / CMaps) — see [pdfTextLooksUsable].

/// A positioned text fragment recovered from a content stream.
class _Frag {
  final double x;
  final double y;
  final String text;
  _Frag(this.x, this.y, this.text);
}

/// Multiplies two PDF matrices `[a b c d e f]` (m1 × m2).
List<double> _mul(List<double> m1, List<double> m2) => <double>[
      m1[0] * m2[0] + m1[1] * m2[2],
      m1[0] * m2[1] + m1[1] * m2[3],
      m1[2] * m2[0] + m1[3] * m2[2],
      m1[2] * m2[1] + m1[3] * m2[3],
      m1[4] * m2[0] + m1[5] * m2[2] + m2[4],
      m1[4] * m2[1] + m1[5] * m2[3] + m2[5],
    ];

const List<double> _identity = <double>[1, 0, 0, 1, 0, 0];

/// WinAnsiEncoding overrides for 0x80–0x9F (the rest is Latin-1 / ASCII).
const Map<int, int> _winAnsiHigh = <int, int>{
  0x80: 0x20AC, 0x82: 0x201A, 0x83: 0x0192, 0x84: 0x201E, 0x85: 0x2026,
  0x86: 0x2020, 0x87: 0x2021, 0x88: 0x02C6, 0x89: 0x2030, 0x8A: 0x0160,
  0x8B: 0x2039, 0x8C: 0x0152, 0x8E: 0x017D, 0x91: 0x2018, 0x92: 0x2019,
  0x93: 0x201C, 0x94: 0x201D, 0x95: 0x2022, 0x96: 0x2013, 0x97: 0x2014,
  0x98: 0x02DC, 0x99: 0x2122, 0x9A: 0x0161, 0x9B: 0x203A, 0x9C: 0x0153,
  0x9E: 0x017E, 0x9F: 0x0178,
};

String _decodeWinAnsi(List<int> bytes) {
  final sb = StringBuffer();
  for (final b in bytes) {
    if (b >= 0x80 && b <= 0x9F) {
      sb.writeCharCode(_winAnsiHigh[b] ?? b);
    } else {
      sb.writeCharCode(b);
    }
  }
  return sb.toString();
}

/// Inflates a PDF `/FlateDecode` stream payload.
///
/// Only attempted when the payload actually carries a valid zlib header
/// (CMF/FLG checksum) — feeding raw binary (images, ICC blobs, fonts) to the
/// inflater otherwise makes it allocate gigabytes before failing.
List<int>? _inflate(List<int> data) {
  if (data.length < 2) return null;
  final cmf = data[0], flg = data[1];
  if ((cmf & 0x0F) != 8) return null; // not "deflate"
  if (((cmf << 8) + flg) % 31 != 0) return null; // header checksum
  try {
    final out = ZLibDecoder().decodeBytes(data, verify: false);
    return out.isEmpty ? null : out;
  } catch (_) {
    return null;
  }
}

/// Pulls every FlateDecode stream out of [bytes] in file order.
///
/// A brute-force `stream … endstream` scan is used on purpose: it needs no
/// xref table, survives incremental updates and broken offsets, and the
/// resulting order matches page order for linearly written documents.
List<List<int>> _extractStreams(List<int> bytes) {
  final out = <List<int>>[];
  final needle = <int>[0x73, 0x74, 0x72, 0x65, 0x61, 0x6D]; // "stream"
  final end = <int>[
    0x65, 0x6E, 0x64, 0x73, 0x74, 0x72, 0x65, 0x61, 0x6D, //
  ]; // "endstream"
  var i = 0;
  while (i < bytes.length - 6) {
    if (_matchAt(bytes, i, needle)) {
      var s = i + 6;
      if (s < bytes.length && bytes[s] == 0x0D) s++;
      if (s < bytes.length && bytes[s] == 0x0A) s++;
      final e = _indexOf(bytes, end, s);
      if (e < 0) break;
      var payloadEnd = e;
      // Trim the EOL that precedes "endstream".
      if (payloadEnd > s && bytes[payloadEnd - 1] == 0x0A) payloadEnd--;
      if (payloadEnd > s && bytes[payloadEnd - 1] == 0x0D) payloadEnd--;
      final inflated = _inflate(bytes.sublist(s, payloadEnd));
      if (inflated != null && inflated.isNotEmpty) out.add(inflated);
      i = e + end.length;
    } else {
      i++;
    }
  }
  return out;
}

bool _matchAt(List<int> hay, int at, List<int> needle) {
  if (at + needle.length > hay.length) return false;
  for (var k = 0; k < needle.length; k++) {
    if (hay[at + k] != needle[k]) return false;
  }
  return true;
}

int _indexOf(List<int> hay, List<int> needle, int from) {
  for (var i = from; i <= hay.length - needle.length; i++) {
    if (_matchAt(hay, i, needle)) return i;
  }
  return -1;
}

/// A parsed PDF object operand: number, string, name or array.
class _Tok {
  final double? number;
  final String? text; // decoded literal/hex string
  final String? name; // /Foo
  final List<_Tok>? array;
  const _Tok.num(this.number)
      : text = null,
        name = null,
        array = null;
  const _Tok.str(this.text)
      : number = null,
        name = null,
        array = null;
  const _Tok.nam(this.name)
      : number = null,
        text = null,
        array = null;
  const _Tok.arr(this.array)
      : number = null,
        text = null,
        name = null;
}

bool _isPdfWhite(int c) =>
    c == 0x20 || c == 0x0A || c == 0x0D || c == 0x09 || c == 0x0C || c == 0x00;

bool _isPdfDelim(int c) =>
    c == 0x28 ||
    c == 0x29 ||
    c == 0x3C ||
    c == 0x3E ||
    c == 0x5B ||
    c == 0x5D ||
    c == 0x7B ||
    c == 0x7D ||
    c == 0x2F ||
    c == 0x25;

/// Reads a literal string `( … )` starting at [i] (which points at `(`).
/// Returns the decoded text and the index just past the closing paren.
(String, int) _readLiteralString(String s, int i) {
  final bytes = <int>[];
  var depth = 1;
  i++; // consume '('
  final len = s.length;
  while (i < len) {
    final ch = s.codeUnitAt(i);
    if (ch == 0x5C) {
      i++;
      if (i >= len) break;
      final e = s.codeUnitAt(i);
      switch (e) {
        case 0x6E:
          bytes.add(0x0A);
          i++;
          break;
        case 0x72:
          bytes.add(0x0D);
          i++;
          break;
        case 0x74:
          bytes.add(0x09);
          i++;
          break;
        case 0x62:
          bytes.add(0x08);
          i++;
          break;
        case 0x66:
          bytes.add(0x0C);
          i++;
          break;
        case 0x0A:
          i++;
          break;
        case 0x0D:
          i++;
          if (i < len && s.codeUnitAt(i) == 0x0A) i++;
          break;
        default:
          if (e >= 0x30 && e <= 0x37) {
            var oct = 0;
            var n = 0;
            while (i < len && n < 3) {
              final d = s.codeUnitAt(i);
              if (d < 0x30 || d > 0x37) break;
              oct = oct * 8 + (d - 0x30);
              i++;
              n++;
            }
            bytes.add(oct & 0xFF);
          } else {
            bytes.add(e & 0xFF);
            i++;
          }
      }
      continue;
    }
    if (ch == 0x28) depth++;
    if (ch == 0x29) {
      depth--;
      i++;
      if (depth == 0) break;
      bytes.add(0x29);
      continue;
    }
    bytes.add(ch & 0xFF);
    i++;
  }
  return (_decodeWinAnsi(bytes), i);
}

/// Reads a hex string `< … >` starting at [i] (which points at `<`).
(String, int) _readHexString(String s, int i) {
  i++; // consume '<'
  final hex = StringBuffer();
  final len = s.length;
  while (i < len && s.codeUnitAt(i) != 0x3E) {
    final c = s.codeUnitAt(i);
    final isHex = (c >= 0x30 && c <= 0x39) ||
        (c >= 0x41 && c <= 0x46) ||
        (c >= 0x61 && c <= 0x66);
    if (isHex) hex.write(s[i]);
    i++;
  }
  if (i < len) i++; // consume '>'
  var h = hex.toString();
  if (h.length.isOdd) h += '0';
  final bytes = <int>[];
  for (var k = 0; k + 1 < h.length; k += 2) {
    bytes.add(int.parse(h.substring(k, k + 2), radix: 16));
  }
  return (_decodeWinAnsi(bytes), i);
}

/// Reads an array `[ … ]` starting at [i] (which points at `[`).
(List<_Tok>, int) _readArray(String s, int i) {
  i++; // consume '['
  final out = <_Tok>[];
  final len = s.length;
  while (i < len) {
    final c = s.codeUnitAt(i);
    if (_isPdfWhite(c)) {
      i++;
      continue;
    }
    if (c == 0x5D) {
      i++;
      break;
    }
    if (c == 0x28) {
      final r = _readLiteralString(s, i);
      out.add(_Tok.str(r.$1));
      i = r.$2;
      continue;
    }
    if (c == 0x3C) {
      final r = _readHexString(s, i);
      out.add(_Tok.str(r.$1));
      i = r.$2;
      continue;
    }
    if (c == 0x5B) {
      final r = _readArray(s, i);
      out.add(_Tok.arr(r.$1));
      i = r.$2;
      continue;
    }
    final start = i;
    while (i < len && !_isPdfWhite(s.codeUnitAt(i)) && !_isPdfDelim(s.codeUnitAt(i))) {
      i++;
    }
    if (i == start) {
      i++;
      continue;
    }
    final v = double.tryParse(s.substring(start, i));
    if (v != null) out.add(_Tok.num(v));
  }
  return (out, i);
}

/// Skips a dictionary `<< … >>` starting at [i]; returns the index past it.
int _skipDict(String s, int i) {
  final len = s.length;
  var depth = 0;
  while (i < len) {
    if (i + 1 < len && s.codeUnitAt(i) == 0x3C && s.codeUnitAt(i + 1) == 0x3C) {
      depth++;
      i += 2;
      continue;
    }
    if (i + 1 < len && s.codeUnitAt(i) == 0x3E && s.codeUnitAt(i + 1) == 0x3E) {
      depth--;
      i += 2;
      if (depth <= 0) return i;
      continue;
    }
    i++;
  }
  return i;
}

/// Interprets one content stream and returns its positioned text fragments.
///
/// Implements the subset of the PDF operator set that affects text placement:
/// `q/Q/cm` (graphics state + CTM), `BT/ET`, `Tm/Td/TD/T*/TL` (text matrices)
/// and `Tj/TJ/'/"` (show text). Everything else is skipped.
List<_Frag> _runContentStream(List<int> raw) {
  final frags = <_Frag>[];
  // 1:1 byte→code-unit mapping; strings are WinAnsi-decoded when they are read.
  final s = String.fromCharCodes(raw);
  final len = s.length;

  var ctm = _identity;
  final ctmStack = <List<double>>[];
  var tm = _identity;
  var tlm = _identity;
  var leading = 0.0;

  final operands = <_Tok>[];

  void emit(String text) {
    if (text.trim().isEmpty) return;
    final m = _mul(tm, ctm);
    frags.add(_Frag(m[4], m[5], text));
  }

  /// Collapses a TJ array into one string; large negative kerning offsets
  /// (< -120/1000 em) are rendered as a space, which is how the viewer shows
  /// them too.
  String flattenTj(List<_Tok> parts) {
    final sb = StringBuffer();
    for (final p in parts) {
      if (p.text != null) {
        sb.write(p.text);
      } else if (p.number != null && p.number! <= -120) {
        if (!sb.toString().endsWith(' ')) sb.write(' ');
      }
    }
    return sb.toString();
  }

  /// Numeric operand counted from the end of the operand stack (1 = last).
  double numAt(int fromEnd) {
    final idx = operands.length - fromEnd;
    if (idx < 0 || idx >= operands.length) return 0;
    return operands[idx].number ?? 0;
  }

  String? lastText() {
    for (var k = operands.length - 1; k >= 0; k--) {
      if (operands[k].text != null) return operands[k].text;
    }
    return null;
  }

  var i = 0;
  while (i < len) {
    final c = s.codeUnitAt(i);

    if (_isPdfWhite(c)) {
      i++;
      continue;
    }
    if (c == 0x25) {
      // comment
      while (i < len && s.codeUnitAt(i) != 0x0A && s.codeUnitAt(i) != 0x0D) {
        i++;
      }
      continue;
    }
    if (c == 0x28) {
      final r = _readLiteralString(s, i);
      operands.add(_Tok.str(r.$1));
      i = r.$2;
      continue;
    }
    if (c == 0x3C) {
      if (i + 1 < len && s.codeUnitAt(i + 1) == 0x3C) {
        i = _skipDict(s, i);
      } else {
        final r = _readHexString(s, i);
        operands.add(_Tok.str(r.$1));
        i = r.$2;
      }
      continue;
    }
    if (c == 0x5B) {
      final r = _readArray(s, i);
      operands.add(_Tok.arr(r.$1));
      i = r.$2;
      continue;
    }
    if (c == 0x2F) {
      final start = i;
      i++;
      while (i < len &&
          !_isPdfWhite(s.codeUnitAt(i)) &&
          !_isPdfDelim(s.codeUnitAt(i))) {
        i++;
      }
      operands.add(_Tok.nam(s.substring(start, i)));
      continue;
    }
    if (c == 0x5D || c == 0x3E || c == 0x29 || c == 0x7B || c == 0x7D) {
      i++;
      continue;
    }

    final start = i;
    while (i < len &&
        !_isPdfWhite(s.codeUnitAt(i)) &&
        !_isPdfDelim(s.codeUnitAt(i))) {
      i++;
    }
    if (i == start) {
      i++;
      continue;
    }
    final tok = s.substring(start, i);
    final asNum = double.tryParse(tok);
    if (asNum != null) {
      operands.add(_Tok.num(asNum));
      continue;
    }

    switch (tok) {
      case 'q':
        ctmStack.add(ctm);
        break;
      case 'Q':
        if (ctmStack.isNotEmpty) ctm = ctmStack.removeLast();
        break;
      case 'cm':
        if (operands.length >= 6) {
          ctm = _mul(<double>[
            numAt(6), numAt(5), numAt(4), numAt(3), numAt(2), numAt(1),
          ], ctm);
        }
        break;
      case 'BT':
        tm = _identity;
        tlm = _identity;
        break;
      case 'Tm':
        if (operands.length >= 6) {
          tm = <double>[
            numAt(6), numAt(5), numAt(4), numAt(3), numAt(2), numAt(1),
          ];
          tlm = tm;
        }
        break;
      case 'TL':
        leading = numAt(1);
        break;
      case 'Td':
        if (operands.length >= 2) {
          tlm = _mul(<double>[1, 0, 0, 1, numAt(2), numAt(1)], tlm);
          tm = tlm;
        }
        break;
      case 'TD':
        if (operands.length >= 2) {
          leading = -numAt(1);
          tlm = _mul(<double>[1, 0, 0, 1, numAt(2), numAt(1)], tlm);
          tm = tlm;
        }
        break;
      case 'T*':
        tlm = _mul(<double>[1, 0, 0, 1, 0, -leading], tlm);
        tm = tlm;
        break;
      case 'Tj':
        final t = lastText();
        if (t != null) emit(t);
        break;
      case "'":
      case '"':
        tlm = _mul(<double>[1, 0, 0, 1, 0, -leading], tlm);
        tm = tlm;
        final t2 = lastText();
        if (t2 != null) emit(t2);
        break;
      case 'TJ':
        for (var k = operands.length - 1; k >= 0; k--) {
          if (operands[k].array != null) {
            emit(flattenTj(operands[k].array!));
            break;
          }
        }
        break;
      default:
        break;
    }
    operands.clear();
  }
  return frags;
}

/// Extracts the visible text of [bytes] as layout-ordered lines.
///
/// Fragments are grouped into lines by their device Y (2pt tolerance), sorted
/// left-to-right and joined with a double space so that table cells stay
/// separated. Streams are processed in file order, which preserves page order.
String extractPdfText(List<int> bytes) {
  final sb = StringBuffer();
  for (final stream in _extractStreams(bytes)) {
    // Cheap pre-filter: only content streams carry BT/ET text objects.
    if (_indexOf(stream, <int>[0x42, 0x54], 0) < 0) continue;
    final frags = _runContentStream(stream);
    if (frags.isEmpty) continue;

    // Group by Y with tolerance.
    final lines = <List<_Frag>>[];
    final sorted = [...frags]..sort((a, b) => b.y.compareTo(a.y));
    for (final f in sorted) {
      if (f.text.trim().isEmpty) continue;
      final target = lines.isEmpty ? null : lines.last;
      if (target != null && (target.first.y - f.y).abs() <= 2.0) {
        target.add(f);
      } else {
        lines.add(<_Frag>[f]);
      }
    }
    for (final line in lines) {
      line.sort((a, b) => a.x.compareTo(b.x));
      sb.writeln(line.map((f) => f.text.trim()).join('  '));
    }
  }
  return sb.toString();
}

/// Heuristic: did [text] come out of a PDF our extractor understands?
///
/// Used by the app to decide whether to fall back to syncfusion_flutter_pdf
/// (which handles embedded subset fonts / CMaps that this extractor does not).
bool pdfTextLooksUsable(String text) {
  if (text.trim().length < 200) return false;
  return RegExp(r'\d{2}/\d{2}/\d{4}').hasMatch(text) ||
      text.contains('Gesamtbetrag') ||
      RegExp('Details des Rechnungsdatums').hasMatch(text);
}

// ═══════════════════════════════════════════════════════════════════════════
// 2. Invoice (Amazon Gutschrift) parsing
// ═══════════════════════════════════════════════════════════════════════════

/// One row of the invoice's "Details des Rechnungsdatums" table.
class InvoiceLine {
  final DateTime date;
  final String description;
  final double unitPrice;
  final double quantity;
  final double total;

  InvoiceLine({
    required this.date,
    required this.description,
    required this.unitPrice,
    required this.quantity,
    required this.total,
  });

  /// Service type for `… - Block of N Hours` rows, else `null`.
  String? get blockServiceType => _blockMatch(description)?.$1;

  /// Block length in hours for `… - Block of N Hours` rows, else `null`.
  int? get blockHours => _blockMatch(description)?.$2;

  bool get isPackageLine =>
      normKey(description) == normKey('Variable Per Shipment');

  bool get isBrandingPackageLine =>
      normKey(description) == normKey('Branding - Variable Per Shipment');

  @override
  String toString() =>
      '${dayKey(date)} | $description | $unitPrice € x $quantity = $total €';
}

/// `<service> - Block of <N> Hours`.
///
/// Deliberately **not** anchored at the end: if a stray fragment (page footer,
/// address line) ever gets glued onto the description, the position must still
/// be recognised as a route block instead of silently becoming "unrelated" —
/// which is what turned a parsing glitch into fabricated missing-route claims.
final RegExp _kBlockRe =
    RegExp(r'^(.*?)\s*-\s*Block\s+of\s+(\d+)\s+Hours?\b', caseSensitive: false);

/// A description that already reads as a finished position — nothing more may
/// be appended to it.
final RegExp _kDescriptionComplete = RegExp(
  r'(Block\s+of\s+\d+\s+Hours?|Per\s+Shipment)\s*$',
  caseSensitive: false,
);

/// Page footers, addresses and legal boilerplate that follow the detail table.
/// These must never be mistaken for a wrapped description cell.
final RegExp _kFooterish = RegExp(
  r'(GmbH|mbH|AG\b|Ltd\b|Inc\b|S\.à|Amazon\s+Logistics|Amazon\s+Deutschland|'
  r'USt|VAT|Steuer|Handelsregister|Amtsgericht|Registergericht|'
  r'Gutschrift|UStG|Finanzamt|Rechnungsnr|Rechnungsdatum|Gesamtbetrag|'
  r'MwSt|Seite\s*\d|Page\s*\d|www\.|@|\bStr\.|\bstraße|\d{5}\s+\p{L})',
  caseSensitive: false,
  unicode: true,
);

/// Longest a wrapped table cell may plausibly be. Real continuations are short
/// tails such as `Hours` or `(350CF/81KWh) - Block of 9 Hours`.
const int _kMaxContinuationLength = 60;

bool _descriptionLooksComplete(String description) =>
    _kDescriptionComplete.hasMatch(normText(description));

(String, int)? _blockMatch(String description) {
  final m = _kBlockRe.firstMatch(normText(description));
  if (m == null) return null;
  final hours = int.tryParse(m.group(2)!);
  if (hours == null) return null;
  return (normText(m.group(1)!), hours);
}

/// Everything the Payment Check needs out of one invoice PDF.
class InvoiceData {
  final List<InvoiceLine> lines;
  final double? grandTotal;
  final String? invoiceNumber;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final int? weekNumber;
  final List<String> warnings;

  InvoiceData({
    required this.lines,
    this.grandTotal,
    this.invoiceNumber,
    this.periodStart,
    this.periodEnd,
    this.weekNumber,
    this.warnings = const <String>[],
  });

  bool get isEmpty => lines.isEmpty;

  DateTime? get minDate => lines.isEmpty
      ? null
      : lines.map((l) => l.date).reduce((a, b) => a.isBefore(b) ? a : b);

  DateTime? get maxDate => lines.isEmpty
      ? null
      : lines.map((l) => l.date).reduce((a, b) => a.isAfter(b) ? a : b);

  double get sumOfLines =>
      lines.fold<double>(0, (acc, l) => acc + l.total);
}

final RegExp _kDetailRowRe = RegExp(
  r'^(\d{2}/\d{2}/\d{4})\s+(.+?)\s+([\d.,]+)\s*€\s+([\d.,]+)\s+([\d.,]+)\s*€\s*$',
);
final RegExp _kUsDateRe = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$');

DateTime? _parseUsDate(String s) {
  final m = _kUsDateRe.firstMatch(s.trim());
  if (m == null) return null;
  final mm = int.parse(m.group(1)!);
  final dd = int.parse(m.group(2)!);
  final yyyy = int.parse(m.group(3)!);
  if (mm < 1 || mm > 12 || dd < 1 || dd > 31) return null;
  return DateTime(yyyy, mm, dd);
}

/// Parses the text of an Amazon Gutschrift into [InvoiceData].
///
/// Only the *detail* table ("Details des Rechnungsdatums") is used for the
/// reconciliation — it is the only place with per-day quantities. The summary
/// table above it is read solely for `Gesamtbetrag`.
InvoiceData parseInvoiceText(String rawText) {
  final warnings = <String>[];
  final text = rawText.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  final allLines = text.split('\n');

  // ── header facts ──────────────────────────────────────────────────────
  String? invoiceNumber;
  double? grandTotal;
  DateTime? periodStart;
  DateTime? periodEnd;
  int? weekNumber;

  final joined = normText(allLines.join(' '));

  final invNo = RegExp(r'Rechnungsnr:?\s*([A-Z0-9\-]+)').firstMatch(joined);
  invoiceNumber = invNo?.group(1);

  final total = RegExp(r'Gesamtbetrag\s+([\d.,]+)\s*€').firstMatch(joined);
  if (total != null) grandTotal = parseNumberLoose(total.group(1)!);

  // "Für Zustellungen in Woche 32: 08/02/2026 to 08/08/2026" sits in the
  // right-hand header column and wraps across two rendered lines, with the
  // left-hand address column interleaved. So: locate the "Woche" line and
  // harvest the first two US dates from that line plus the next two.
  final weekLineIdx =
      allLines.indexWhere((l) => RegExp(r'Woche\s+\d+').hasMatch(l));
  if (weekLineIdx >= 0) {
    final slice = allLines
        .sublist(weekLineIdx,
            (weekLineIdx + 3).clamp(0, allLines.length))
        .join(' ');
    weekNumber =
        int.tryParse(RegExp(r'Woche\s+(\d+)').firstMatch(slice)!.group(1)!);
    final dates = RegExp(r'\d{2}/\d{2}/\d{4}')
        .allMatches(slice)
        .map((m) => _parseUsDate(m.group(0)!))
        .whereType<DateTime>()
        .toList();
    if (dates.length >= 2) {
      dates.sort();
      periodStart = dates.first;
      periodEnd = dates.last;
    }
  }

  // ── detail table ──────────────────────────────────────────────────────
  final marker = allLines.indexWhere(
    (l) => l.contains('Details des Rechnungsdatums'),
  );
  final detailLines =
      marker >= 0 ? allLines.sublist(marker + 1) : allLines.toList();
  if (marker < 0) {
    warnings.add('detail-table-marker-missing');
  }

  final lines = <InvoiceLine>[];
  // Pending continuation text for a wrapped description cell.
  final pending = <String>[];

  bool isNoise(String l) {
    final n = normText(l);
    if (n.isEmpty) return true;
    if (n.startsWith('Datum') && n.contains('Beschreibung')) return true;
    if (n.startsWith('Seite') || RegExp(r'^Page\s+\d+').hasMatch(n)) {
      return true;
    }
    return false;
  }

  // How many further lines may still attach to the row we just parsed.
  // A wrapped table cell spills over at most one or two rendered lines, and
  // only *directly* after its own row — anything else (blank line, noise,
  // footer, a new row) closes the window. Without this budget, everything the
  // PDF prints after the table (page footer, company address, legal notice)
  // was swallowed into the last position's description, which destroyed that
  // position and produced fabricated "missing" claims for it.
  var continuationBudget = 0;

  void closeRow() {
    _flushPending(lines, pending);
    continuationBudget = 0;
  }

  for (final raw in detailLines) {
    final line = normText(raw);
    if (isNoise(line)) {
      closeRow();
      continue;
    }

    final m = _kDetailRowRe.firstMatch(line);
    if (m != null) {
      // A new row starts → flush any continuation onto the previous row.
      closeRow();
      final date = _parseUsDate(m.group(1)!);
      final price = parseNumberLoose(m.group(3)!);
      final qty = parseNumberLoose(m.group(4)!);
      final sum = parseNumberLoose(m.group(5)!);
      if (date == null || price == null || qty == null || sum == null) {
        warnings.add('unparsable-detail-row: $line');
        continue;
      }
      final description = normText(m.group(2)!);
      lines.add(InvoiceLine(
        date: date,
        description: description,
        unitPrice: price,
        quantity: qty,
        total: sum,
      ));
      // A description that already ends in "Block of N Hours" / "Per Shipment"
      // is complete — never extend it.
      continuationBudget = _descriptionLooksComplete(description) ? 0 : 2;
      continue;
    }

    // Continuation of the previous row's description (wrapped table cell).
    final isPlausibleContinuation = continuationBudget > 0 &&
        lines.isNotEmpty &&
        !line.contains('€') &&
        !RegExp(r'\d{2}/\d{2}/\d{4}').hasMatch(line) &&
        line.length <= _kMaxContinuationLength &&
        !_kFooterish.hasMatch(line);

    if (!isPlausibleContinuation) {
      closeRow();
      continue;
    }

    pending.add(line);
    continuationBudget--;
    if (_descriptionLooksComplete(
        '${lines.last.description} ${pending.join(' ')}')) {
      closeRow();
    }
  }
  closeRow();

  return InvoiceData(
    lines: lines,
    grandTotal: grandTotal,
    invoiceNumber: invoiceNumber,
    periodStart: periodStart,
    periodEnd: periodEnd,
    weekNumber: weekNumber,
    warnings: warnings,
  );
}

void _flushPending(List<InvoiceLine> lines, List<String> pending) {
  if (pending.isEmpty || lines.isEmpty) {
    pending.clear();
    return;
  }
  final last = lines.removeLast();
  lines.add(InvoiceLine(
    date: last.date,
    description: normText('${last.description} ${pending.join(' ')}'),
    unitPrice: last.unitPrice,
    quantity: last.quantity,
    total: last.total,
  ));
  pending.clear();
}

/// Convenience: bytes → [InvoiceData] using the built-in pure-Dart extractor.
InvoiceData parseInvoicePdf(List<int> bytes) =>
    parseInvoiceText(extractPdfText(bytes));

// ═══════════════════════════════════════════════════════════════════════════
// 3. Work Summary Tool (WST) parsing
// ═══════════════════════════════════════════════════════════════════════════

/// A file handed to [parseWstFiles] — name plus raw bytes, nothing else.
class NamedBytes {
  final String name;
  final List<int> bytes;
  const NamedBytes(this.name, this.bytes);
}

/// One `Weekly Report` row: routes completed per day × service type × block.
class WstRouteRow {
  final DateTime date;
  final String station;
  final String serviceType;
  final int hours;
  final int completed;

  WstRouteRow({
    required this.date,
    required this.station,
    required this.serviceType,
    required this.hours,
    required this.completed,
  });

  @override
  String toString() =>
      '${dayKey(date)} | $serviceType | ${hours}h | completed=$completed';
}

/// One `Package Report` row: parcels delivered per day.
class WstPackageRow {
  final DateTime date;
  final String station;
  final int delivered;

  WstPackageRow({
    required this.date,
    required this.station,
    required this.delivered,
  });

  @override
  String toString() => '${dayKey(date)} | delivered=$delivered';
}

class WstData {
  final List<WstRouteRow> routes;
  final List<WstPackageRow> packages;
  final List<String> filesUsed;
  final List<String> filesIgnored;
  final Set<String> stations;
  final List<String> warnings;

  WstData({
    required this.routes,
    required this.packages,
    required this.filesUsed,
    required this.filesIgnored,
    required this.stations,
    this.warnings = const <String>[],
  });

  bool get isEmpty => routes.isEmpty && packages.isEmpty;

  int get totalRoutes =>
      routes.fold<int>(0, (acc, r) => acc + r.completed);

  int get totalPackages =>
      packages.fold<int>(0, (acc, p) => acc + p.delivered);

  DateTime? get minDate {
    final all = <DateTime>[
      ...routes.map((r) => r.date),
      ...packages.map((p) => p.date),
    ];
    if (all.isEmpty) return null;
    return all.reduce((a, b) => a.isBefore(b) ? a : b);
  }

  DateTime? get maxDate {
    final all = <DateTime>[
      ...routes.map((r) => r.date),
      ...packages.map((p) => p.date),
    ];
    if (all.isEmpty) return null;
    return all.reduce((a, b) => a.isAfter(b) ? a : b);
  }
}

/// Führt einen weiteren WST-Upload mit dem bisherigen Stand zusammen.
///
/// Komponentenweise Ersetzung statt Addition: Liefert der neue Upload
/// Routen (Weekly Report), ersetzen sie die bisherigen Routen komplett;
/// dasselbe gilt für Pakete (Package Report). So können Weekly- und
/// Package-Report in beliebiger Reihenfolge einzeln hochgeladen werden,
/// und ein erneuter Upload desselben Reports korrigiert statt doppelt
/// zu zählen.
WstData mergeWstData(WstData? previous, WstData incoming) {
  if (previous == null || previous.isEmpty) return incoming;
  final useNewRoutes = incoming.routes.isNotEmpty;
  final useNewPackages = incoming.packages.isNotEmpty;
  final files = <String>{
    // Alte Dateinamen nur behalten, soweit ihre Komponente bestehen bleibt.
    if (!useNewRoutes || !useNewPackages) ...previous.filesUsed,
    ...incoming.filesUsed,
  };
  return WstData(
    routes: useNewRoutes ? incoming.routes : previous.routes,
    packages: useNewPackages ? incoming.packages : previous.packages,
    filesUsed: files.toList(),
    filesIgnored: incoming.filesIgnored,
    stations: {...previous.stations, ...incoming.stations},
    warnings: {...previous.warnings, ...incoming.warnings}.toList(),
  );
}

/// Minimal RFC-4180-ish CSV splitter (quotes, escaped quotes, embedded
/// separators + newlines). Hand-rolled to stay Flutter-free and to control
/// BOM handling precisely.
List<List<String>> parseCsv(String input) {
  final text = input.replaceAll('﻿', '').replaceAll('\r\n', '\n');
  final rows = <List<String>>[];
  var row = <String>[];
  final cell = StringBuffer();
  var inQuotes = false;
  for (var i = 0; i < text.length; i++) {
    final ch = text[i];
    if (inQuotes) {
      if (ch == '"') {
        if (i + 1 < text.length && text[i + 1] == '"') {
          cell.write('"');
          i++;
        } else {
          inQuotes = false;
        }
      } else {
        cell.write(ch);
      }
      continue;
    }
    if (ch == '"') {
      inQuotes = true;
    } else if (ch == ',' || ch == ';') {
      row.add(cell.toString());
      cell.clear();
    } else if (ch == '\n' || ch == '\r') {
      row.add(cell.toString());
      cell.clear();
      rows.add(row);
      row = <String>[];
    } else {
      cell.write(ch);
    }
  }
  if (cell.isNotEmpty || row.isNotEmpty) {
    row.add(cell.toString());
    rows.add(row);
  }
  return rows.where((r) => r.any((c) => c.trim().isNotEmpty)).toList();
}

/// Finds a column index by fuzzy header match ([normKey] on both sides), so
/// the U+2011 in `Anbieter‑Kurzcode` and casing differences do not matter.
int _col(List<String> header, List<String> candidates) {
  final keys = header.map(normKey).toList();
  for (final c in candidates) {
    final want = normKey(c);
    final idx = keys.indexOf(want);
    if (idx >= 0) return idx;
  }
  for (final c in candidates) {
    final want = normKey(c);
    // Empty header cells (trailing separators, spacer columns) must never take
    // part in the fuzzy pass — `want.contains('')` is always true and would
    // silently bind the column to the first blank header.
    final idx = keys.indexWhere(
      (k) => k.isNotEmpty && (k.contains(want) || want.contains(k)),
    );
    if (idx >= 0) return idx;
  }
  return -1;
}

final RegExp _kIsoDateRe = RegExp(r'^(\d{4})-(\d{2})-(\d{2})');
final RegExp _kDeDateRe = RegExp(r'^(\d{1,2})\.(\d{1,2})\.(\d{4})');

DateTime? _parseWstDate(String s) {
  final t = s.trim();
  final iso = _kIsoDateRe.firstMatch(t);
  if (iso != null) {
    return DateTime(
      int.parse(iso.group(1)!),
      int.parse(iso.group(2)!),
      int.parse(iso.group(3)!),
    );
  }
  final de = _kDeDateRe.firstMatch(t);
  if (de != null) {
    return DateTime(
      int.parse(de.group(3)!),
      int.parse(de.group(2)!),
      int.parse(de.group(1)!),
    );
  }
  return _parseUsDate(t);
}

/// `9 Std.` / `9 hrs` / `9 h` / `9` → 9
int? parseDurationHours(String s) {
  final m = RegExp(r'(\d+)').firstMatch(normText(s));
  if (m == null) return null;
  return int.tryParse(m.group(1)!);
}

int _asInt(String s) {
  final v = parseNumberLoose(s);
  if (v == null) return 0;
  return v.round();
}

enum _WstKind { weekly, packages, other }

_WstKind _classify(List<String> header) {
  final keys = header.map(normKey).toSet();
  final hasDate = keys.any((k) => k.contains('datum') || k.contains('date'));
  if (!hasDate) return _WstKind.other;
  final hasService =
      keys.any((k) => k.contains('servicetyp') || k.contains('servicetype'));
  final hasCompleted = keys.any(
    (k) => k.contains('abgeschlossen') || k.contains('completed'),
  );
  // Service Details is per-driver/per-route; the Weekly Report is aggregated.
  // Careful: the Weekly Report *does* have an "Abort Routes" column, so match
  // the driver/route columns exactly rather than by substring.
  final hasDriver = keys.any(
    (k) =>
        k.contains('zustellmitarbeiter') ||
        k.contains('delivery associate') ||
        k == 'route' ||
        k == 'routes',
  );
  // Weekly Report = aggregated (service + completed) and *no* per-driver column.
  if (hasService && hasCompleted && !hasDriver) return _WstKind.weekly;
  final hasDelivered =
      keys.any((k) => k.contains('zugestellt') || k.contains('delivered'));
  if (hasDelivered && !hasService) return _WstKind.packages;
  return _WstKind.other;
}

/// Parses WST input: a ZIP export, loose CSVs, or any mix of both.
///
/// Only `Weekly Report` (routes) and `Package Report` (parcels) are used;
/// Service Details and Unplanned Delay are recognised and ignored on purpose.
WstData parseWstFiles(List<NamedBytes> input) {
  final routes = <WstRouteRow>[];
  final packages = <WstPackageRow>[];
  final used = <String>[];
  final ignored = <String>[];
  final stations = <String>{};
  final warnings = <String>[];

  // Flatten ZIPs into their CSV members.
  final flat = <NamedBytes>[];
  for (final f in input) {
    final lower = f.name.toLowerCase();
    if (lower.endsWith('.zip')) {
      try {
        final archive = ZipDecoder().decodeBytes(f.bytes);
        for (final e in archive.files) {
          if (!e.isFile) continue;
          final n = e.name.split('/').last;
          if (n.startsWith('.') || n.startsWith('__MACOSX')) continue;
          flat.add(NamedBytes(n, e.content as List<int>));
        }
      } catch (e) {
        warnings.add('zip-unreadable: ${f.name}');
      }
    } else {
      flat.add(f);
    }
  }

  for (final f in flat) {
    final lower = f.name.toLowerCase();
    if (!lower.endsWith('.csv') && !lower.endsWith('.txt')) {
      ignored.add(f.name);
      continue;
    }
    String content;
    try {
      content = utf8.decode(f.bytes, allowMalformed: true);
    } catch (_) {
      content = latin1.decode(f.bytes, allowInvalid: true);
    }
    final rows = parseCsv(content);
    if (rows.length < 2) {
      ignored.add(f.name);
      continue;
    }
    final header = rows.first;
    final kind = _classify(header);

    if (kind == _WstKind.weekly) {
      final cDate = _col(header, ['Datum', 'Date']);
      final cStation = _col(header, ['Station']);
      final cService = _col(header, ['Servicetyp', 'Service Type']);
      final cDur = _col(header, ['Geplante Dauer', 'Scheduled Duration']);
      final cDone = _col(header, ['abgeschlossen', 'completed']);
      if (cDate < 0 || cService < 0 || cDur < 0 || cDone < 0) {
        ignored.add(f.name);
        continue;
      }
      var added = 0;
      for (final r in rows.skip(1)) {
        if (r.length <= cDone) continue;
        final d = _parseWstDate(r[cDate]);
        final hours = parseDurationHours(r[cDur]);
        if (d == null || hours == null) continue;
        final station = cStation >= 0 && cStation < r.length
            ? normText(r[cStation])
            : '';
        if (station.isNotEmpty) stations.add(station);
        routes.add(WstRouteRow(
          date: d,
          station: station,
          serviceType: normText(r[cService]),
          hours: hours,
          completed: _asInt(r[cDone]),
        ));
        added++;
      }
      if (added > 0) {
        used.add(f.name);
      } else {
        ignored.add(f.name);
      }
      continue;
    }

    if (kind == _WstKind.packages) {
      final cDate = _col(header, ['Datum', 'Date']);
      final cStation = _col(header, ['Station']);
      final cDel = _col(header, ['zugestellt', 'delivered']);
      if (cDate < 0 || cDel < 0) {
        ignored.add(f.name);
        continue;
      }
      var added = 0;
      for (final r in rows.skip(1)) {
        if (r.length <= cDel) continue;
        final d = _parseWstDate(r[cDate]);
        if (d == null) continue;
        final station = cStation >= 0 && cStation < r.length
            ? normText(r[cStation])
            : '';
        if (station.isNotEmpty) stations.add(station);
        packages.add(WstPackageRow(
          date: d,
          station: station,
          delivered: _asInt(r[cDel]),
        ));
        added++;
      }
      if (added > 0) {
        used.add(f.name);
      } else {
        ignored.add(f.name);
      }
      continue;
    }

    ignored.add(f.name);
  }

  return WstData(
    routes: routes,
    packages: packages,
    filesUsed: used,
    filesIgnored: ignored,
    stations: stations,
    warnings: warnings,
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// 4. Reconciliation — only what is MISSING on the invoice
// ═══════════════════════════════════════════════════════════════════════════

/// A route position where the WST reports **more** than the invoice pays.
class MissingRouteRow {
  final DateTime date;
  final String serviceType;
  final int hours;
  final int wstCount;
  final int invoiceCount;

  /// Unit price taken from the invoice; `null` when no comparable position
  /// exists anywhere on the invoice.
  final double? unitPrice;

  /// `true` when [unitPrice] was borrowed from another block of the same
  /// duration because this service type is not billed at all.
  final bool priceIsFallback;

  MissingRouteRow({
    required this.date,
    required this.serviceType,
    required this.hours,
    required this.wstCount,
    required this.invoiceCount,
    required this.unitPrice,
    required this.priceIsFallback,
  });

  int get diff => wstCount - invoiceCount;
  double? get missingAmount => unitPrice == null ? null : unitPrice! * diff;
}

/// A day where the WST reports more parcels than the invoice pays.
class MissingPackageRow {
  /// `Variable Per Shipment` or `Branding - Variable Per Shipment`.
  final String kind;
  final DateTime date;
  final int wstCount;
  final int invoiceCount;
  final double? unitPrice;

  MissingPackageRow({
    required this.kind,
    required this.date,
    required this.wstCount,
    required this.invoiceCount,
    required this.unitPrice,
  });

  int get diff => wstCount - invoiceCount;
  double? get missingAmount => unitPrice == null ? null : unitPrice! * diff;
}

/// Aggregierte bezahlte Rechnungsposition außerhalb des Routen-Abgleichs —
/// Late Cancels, Boni usw. sowie die beiden Per-Shipment-Gebühren.
/// Anzeige mit Menge und Betrag, damit der Betreiber sieht, was zusätzlich
/// zur reinen Routenvergütung gezahlt wurde.
class PaidExtraItem {
  final String description;
  final double quantity;
  final double amount;
  const PaidExtraItem({
    required this.description,
    required this.quantity,
    required this.amount,
  });
}

/// Eine Zeile der Tagesdetail-Ansicht: WST- und Rechnungs-Anzahl für einen
/// Tag × Servicetyp × Blockdauer — unabhängig davon, ob etwas fehlt.
class DailyRouteDetail {
  final DateTime date;
  final String serviceType;
  final int hours;
  final int wstCount;
  final int invoiceCount;
  const DailyRouteDetail({
    required this.date,
    required this.serviceType,
    required this.hours,
    required this.wstCount,
    required this.invoiceCount,
  });
  bool get matches => wstCount == invoiceCount;
}

/// Paket-Zeile der Tagesdetail-Ansicht (je Tag).
class DailyPackageDetail {
  final DateTime date;
  final int wstDelivered;
  final int invoiceVps;
  final int invoiceBranding;
  const DailyPackageDetail({
    required this.date,
    required this.wstDelivered,
    required this.invoiceVps,
    required this.invoiceBranding,
  });
}

class ReconResult {
  final List<MissingRouteRow> missingRoutes;
  final List<MissingPackageRow> missingPackages;

  /// Vollständige Tagesdetails (alle Touren beider Seiten, nicht nur
  /// Fehlendes) — Grundlage der „Tagesdetails"-Ansicht.
  final List<DailyRouteDetail> dailyRoutes;
  final List<DailyPackageDetail> dailyPackages;

  /// Invoice positions with no WST counterpart (Late Cancel, bonuses, …).
  /// These are EXPECTED and are only surfaced as a footnote.
  final int unrelatedInvoiceLineCount;
  final List<String> unrelatedInvoiceDescriptions;

  /// Bezahlt, aber nicht Teil des Routen-Abgleichs: Late Cancels & Co.
  /// (kein WST-Bezug) plus die beiden Per-Shipment-Gebühren — aggregiert
  /// über die Woche, absteigend nach Betrag.
  final List<PaidExtraItem> paidExtras;

  final DateTime? invoiceStart;
  final DateTime? invoiceEnd;
  final DateTime? wstStart;
  final DateTime? wstEnd;

  ReconResult({
    required this.missingRoutes,
    required this.missingPackages,
    required this.unrelatedInvoiceLineCount,
    required this.unrelatedInvoiceDescriptions,
    this.paidExtras = const <PaidExtraItem>[],
    this.dailyRoutes = const <DailyRouteDetail>[],
    this.dailyPackages = const <DailyPackageDetail>[],
    this.invoiceStart,
    this.invoiceEnd,
    this.wstStart,
    this.wstEnd,
  });

  int get totalMissingRoutes =>
      missingRoutes.fold<int>(0, (acc, r) => acc + r.diff);

  /// Number of **parcels** missing, counted once per day.
  ///
  /// A single parcel can carry more than one fee line (`Variable Per Shipment`
  /// *and* `Branding - Variable Per Shipment`), so summing the rows would
  /// double the physical parcel count. The money side is different — both fees
  /// really are owed — so [totalMissingPackageAmount] keeps summing all rows.
  int get totalMissingPackages {
    final perDay = <String, int>{};
    for (final p in missingPackages) {
      final k = dayKey(p.date);
      final prev = perDay[k] ?? 0;
      perDay[k] = p.diff > prev ? p.diff : prev;
    }
    return perDay.values.fold<int>(0, (acc, v) => acc + v);
  }

  /// How many distinct parcel fee kinds are affected (1 = plain, 2 = plain +
  /// branding). Used to explain the amount next to the parcel count.
  int get missingPackageFeeKinds =>
      missingPackages.map((p) => p.kind).toSet().length;

  double get totalMissingRouteAmount => missingRoutes.fold<double>(
      0, (acc, r) => acc + (r.missingAmount ?? 0));

  double get totalMissingPackageAmount => missingPackages.fold<double>(
      0, (acc, r) => acc + (r.missingAmount ?? 0));

  double get totalMissingAmount =>
      totalMissingRouteAmount + totalMissingPackageAmount;

  bool get hasAnyPriceGap =>
      missingRoutes.any((r) => r.unitPrice == null) ||
      missingPackages.any((r) => r.unitPrice == null);

  bool get isComplete => missingRoutes.isEmpty && missingPackages.isEmpty;

  /// `true` only when both sides actually yielded a date range. When this is
  /// `false` the comparison is unverifiable and the UI says so rather than
  /// implying the week matched.
  bool get periodsKnown =>
      invoiceStart != null &&
      invoiceEnd != null &&
      wstStart != null &&
      wstEnd != null;

  /// `false` when the two periods do not overlap at all — almost always means
  /// the wrong week was uploaded. Also `false` when a period is unknown; check
  /// [periodsKnown] to tell the two situations apart.
  bool get periodsOverlap {
    if (!periodsKnown) return false;
    return !invoiceEnd!.isBefore(wstStart!) && !wstEnd!.isBefore(invoiceStart!);
  }
}

String _routeKey(DateTime d, String service, int hours) =>
    '${dayKey(d)}|${normKey(service)}|$hours';

/// Compares WST against the invoice and reports **only what is missing**,
/// i.e. positions where the WST shows more than the invoice pays.
///
/// Invoice positions without a WST counterpart (`AMZL Late Cancel`, …) are
/// deliberately NOT reported as errors — they are expected and only counted.
ReconResult reconcile(InvoiceData invoice, WstData wst) {
  // ── aggregate both sides ────────────────────────────────────────────────
  final wstRoutes = <String, int>{};
  final wstMeta = <String, (DateTime, String, int)>{};
  for (final r in wst.routes) {
    final k = _routeKey(r.date, r.serviceType, r.hours);
    wstRoutes[k] = (wstRoutes[k] ?? 0) + r.completed;
    wstMeta[k] = (r.date, r.serviceType, r.hours);
  }

  final invRoutes = <String, int>{};
  final invMeta = <String, (DateTime, String, int)>{};
  final pkgDateByKey = <String, DateTime>{};
  final invPriceByKey = <String, double>{};
  // Fallback price pool: service-type-agnostic, keyed by block length. Holds
  // the *lowest* unit price seen for that duration — see below.
  final invPriceByHours = <int, double>{};
  final unrelated = <String>[];

  final pkgByDate = <String, double>{}; // Variable Per Shipment
  final brandingByDate = <String, double>{};
  double? pkgUnitPrice;
  double? brandingUnitPrice;

  for (final l in invoice.lines) {
    final block = _blockMatch(l.description);
    if (block != null) {
      final k = _routeKey(l.date, block.$1, block.$2);
      invRoutes[k] = (invRoutes[k] ?? 0) + l.quantity.round();
      invMeta[k] = (l.date, block.$1, block.$2);
      invPriceByKey['${normKey(block.$1)}|${block.$2}'] = l.unitPrice;
      // Conservative + deterministic: take the LOWEST unit price of any block
      // with that duration. Keeping the first-seen price made the claimed
      // amount depend on the order of the invoice rows, and could overstate a
      // claim by pricing an unknown service type at a premium block's rate.
      invPriceByHours.update(
        block.$2,
        (cur) => l.unitPrice < cur ? l.unitPrice : cur,
        ifAbsent: () => l.unitPrice,
      );
      continue;
    }
    if (l.isPackageLine) {
      pkgByDate[dayKey(l.date)] = (pkgByDate[dayKey(l.date)] ?? 0) + l.quantity;
      pkgDateByKey[dayKey(l.date)] = l.date;
      pkgUnitPrice ??= l.unitPrice;
      continue;
    }
    if (l.isBrandingPackageLine) {
      brandingByDate[dayKey(l.date)] =
          (brandingByDate[dayKey(l.date)] ?? 0) + l.quantity;
      pkgDateByKey[dayKey(l.date)] = l.date;
      brandingUnitPrice ??= l.unitPrice;
      continue;
    }
    unrelated.add(normText(l.description));
  }

  // ── bezahlte Extras aggregieren (Anzeige mit Menge + Betrag) ───────────
  // Late Cancels & Co. (unrelated) je Beschreibung zusammenfassen; die
  // beiden Per-Shipment-Gebühren als je eine Sammelzeile dazu.
  final extrasByKey = <String, PaidExtraItem>{};
  void addExtra(String description, double qty, double amount) {
    final k = normKey(description);
    final prev = extrasByKey[k];
    extrasByKey[k] = PaidExtraItem(
      description: prev?.description ?? description.trim(),
      quantity: (prev?.quantity ?? 0) + qty,
      amount: (prev?.amount ?? 0) + amount,
    );
  }

  for (final l in invoice.lines) {
    if (_blockMatch(l.description) != null) continue;
    final amount = l.total != 0 ? l.total : l.quantity * l.unitPrice;
    addExtra(l.description, l.quantity, amount);
  }
  final paidExtras = extrasByKey.values.toList()
    ..sort((a, b) => b.amount.compareTo(a.amount));

  // ── missing routes ──────────────────────────────────────────────────────
  final missingRoutes = <MissingRouteRow>[];
  for (final entry in wstRoutes.entries) {
    final meta = wstMeta[entry.key]!;
    final wstCount = entry.value;
    final invCount = invRoutes[entry.key] ?? 0;
    if (wstCount <= invCount) continue;

    final exactPriceKey = '${normKey(meta.$2)}|${meta.$3}';
    final exact = invPriceByKey[exactPriceKey];
    final fallback = invPriceByHours[meta.$3];
    missingRoutes.add(MissingRouteRow(
      date: meta.$1,
      serviceType: meta.$2,
      hours: meta.$3,
      wstCount: wstCount,
      invoiceCount: invCount,
      unitPrice: exact ?? fallback,
      priceIsFallback: exact == null && fallback != null,
    ));
  }
  missingRoutes.sort((a, b) {
    final c = a.date.compareTo(b.date);
    return c != 0 ? c : a.serviceType.compareTo(b.serviceType);
  });

  // ── missing packages ────────────────────────────────────────────────────
  final missingPackages = <MissingPackageRow>[];
  final wstPkgByDate = <String, int>{};
  final wstPkgDate = <String, DateTime>{};
  for (final p in wst.packages) {
    final k = dayKey(p.date);
    wstPkgByDate[k] = (wstPkgByDate[k] ?? 0) + p.delivered;
    wstPkgDate[k] = p.date;
  }

  void comparePackages(
    String kind,
    Map<String, double> invoiceByDate,
    double? unitPrice,
    bool billed,
  ) {
    if (!billed) return;
    for (final e in wstPkgByDate.entries) {
      final inv = (invoiceByDate[e.key] ?? 0).round();
      if (e.value <= inv) continue;
      missingPackages.add(MissingPackageRow(
        kind: kind,
        date: wstPkgDate[e.key]!,
        wstCount: e.value,
        invoiceCount: inv,
        unitPrice: unitPrice,
      ));
    }
  }

  comparePackages(
    'Variable Per Shipment',
    pkgByDate,
    pkgUnitPrice,
    pkgByDate.isNotEmpty,
  );
  comparePackages(
    'Branding - Variable Per Shipment',
    brandingByDate,
    brandingUnitPrice,
    brandingByDate.isNotEmpty,
  );
  missingPackages.sort((a, b) {
    final c = a.kind.compareTo(b.kind);
    return c != 0 ? c : a.date.compareTo(b.date);
  });

  // ── Tagesdetails: alle Touren beider Seiten (Union der Schlüssel) ──────
  final dailyRoutes = <DailyRouteDetail>[];
  final allKeys = <String>{...wstRoutes.keys, ...invRoutes.keys};
  for (final k in allKeys) {
    final meta = wstMeta[k] ?? invMeta[k]!;
    dailyRoutes.add(DailyRouteDetail(
      date: meta.$1,
      serviceType: meta.$2,
      hours: meta.$3,
      wstCount: wstRoutes[k] ?? 0,
      invoiceCount: invRoutes[k] ?? 0,
    ));
  }
  dailyRoutes.sort((a, b) {
    final c = a.date.compareTo(b.date);
    return c != 0 ? c : a.serviceType.compareTo(b.serviceType);
  });

  final dailyPackages = <DailyPackageDetail>[];
  final pkgDays = <String>{
    ...wstPkgByDate.keys,
    ...pkgByDate.keys,
    ...brandingByDate.keys,
  };
  for (final k in pkgDays) {
    final date = wstPkgDate[k] ?? pkgDateByKey[k];
    if (date == null) continue;
    dailyPackages.add(DailyPackageDetail(
      date: date,
      wstDelivered: wstPkgByDate[k] ?? 0,
      invoiceVps: (pkgByDate[k] ?? 0).round(),
      invoiceBranding: (brandingByDate[k] ?? 0).round(),
    ));
  }
  dailyPackages.sort((a, b) => a.date.compareTo(b.date));

  return ReconResult(
    missingRoutes: missingRoutes,
    missingPackages: missingPackages,
    unrelatedInvoiceLineCount: unrelated.length,
    unrelatedInvoiceDescriptions: unrelated.toSet().toList()..sort(),
    paidExtras: paidExtras,
    dailyRoutes: dailyRoutes,
    dailyPackages: dailyPackages,
    invoiceStart: invoice.periodStart ?? invoice.minDate,
    invoiceEnd: invoice.periodEnd ?? invoice.maxDate,
    wstStart: wst.minDate,
    wstEnd: wst.maxDate,
  );
}
