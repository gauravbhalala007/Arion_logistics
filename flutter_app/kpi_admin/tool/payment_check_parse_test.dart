// tool/payment_check_parse_test.dart
//
// Standalone verification harness for the Payment Check parsing core.
//
//   dart run tool/payment_check_parse_test.dart
//   dart run tool/payment_check_parse_test.dart <invoice.pdf> <wst.zip|csv…>
//
// It exercises EXACTLY the code the web app runs — `lib/services/
// payment_check_parser.dart` is deliberately Flutter-free so that the app and
// this harness share one implementation (no `dart:ui`, hence no
// syncfusion/Flutter dependency here).
//
// Two suites:
//   A. SYNTHETIC — in-code fixtures, always run, no external files needed.
//      These pin down the regressions found in review: table-footer bleed,
//      German grouped numbers, and order-dependent price fallback.
//   B. REAL FILES — the actual Amazon invoice + WST export. Skipped (not
//      failed) when the fixtures are not present on this machine.
//
// Nothing is uploaded or persisted; the harness only reads local files it is
// explicitly pointed at.

import 'dart:io';

import 'package:kpi_admin/services/payment_check_parser.dart';

const _defaultInvoice = '/tmp/invoice.pdf';
const _defaultWstZip = '/tmp/wst.zip';

int _failures = 0;
int _checks = 0;
int _skipped = 0;

void check(String label, Object? actual, Object? expected) {
  _checks++;
  final ok = '$actual' == '$expected';
  if (!ok) _failures++;
  stdout.writeln('  ${ok ? '✅' : '❌'} $label → $actual'
      '${ok ? '' : '   (expected $expected)'}');
}

String eur(double? v) =>
    v == null ? '—' : '${v.toStringAsFixed(2).replaceAll('.', ',')} €';

void section(String title) => stdout.writeln('\n$title');

// ═══════════════════════════════════════════════════════════════════════════
// Suite A — synthetic fixtures (no external files)
// ═══════════════════════════════════════════════════════════════════════════

/// Mimics what `extractPdfText` produces: table cells joined by double spaces,
/// wrapped description cells on their own continuation line — and, crucially,
/// the page footer / company address that follows the table.
const _syntheticInvoiceText = '''
Rechnung - INV-TEST-0000000001  Gutschrift
ARION Logistics  Für Zustellungen in Woche 32:  08/02/2026 to
Industriestr. 12a  08/08/2026
Rechnungsnr: INV-TEST-0000000001
Beschreibung  Stückpreis  Menge  MwSt  Summe
Premium Parcel - Block of 6 Hours  200,00 €  1.0  19%  200,00 €
Gesamtbetrag  8.000,00 €

Details des Rechnungsdatums:

Datum  Beschreibung  Stückpreis  Menge  Summe
08/03/2026  Standard Parcel - Low Emission Vehicle  250,65 €  20.0  5.013,00 €
(350CF/81KWh) - Block of 9 Hours
08/03/2026  Premium Parcel - Block of 6 Hours  200,00 €  1.0  200,00 €
08/03/2026  Sameday Parcel - Block of 6 Hours  179,10 €  10.0  1.791,00 €
08/03/2026  Variable Per Shipment  0,05 €  10436.0  521,80 €
Amazon Logistics Germany GmbH
Marcel-Breuer-Str. 12
80807 München Germany
USt-IdNr: DE814584193 - Amtsgericht München HRB 141335
Seite 1 von 1
''';

/// Weekly Report. Header keeps the U+2011 non-breaking hyphen in
/// `Anbieter‑Kurzcode`. `Ghost Service` has no invoice counterpart at all, so
/// its price must come from the fallback pool for 6-hour blocks.
const _syntheticWeeklyCsv =
    '﻿Datum,Station,Anbieter‑Kurzcode,Servicetyp,Geplante Dauer,'
    'Geplante Gesamtentfernung,Zulässige Gesamtstrecke,'
    'Geplante Entfernungseinheit,Abort Routes,'
    'Verspätete Stornierung durch den Dienstleister,Bonus,Angenommen,'
    'abgeschlossen\n'
    '2026-08-03,Teststation(TST1),AION,'
    'Standard Parcel - Low Emission Vehicle (350CF/81KWh),9 Std.,'
    '2.113,2545,Kilometer,,,,,20\n'
    '2026-08-03,Teststation(TST1),AION,Sameday Parcel,6 Std.,'
    '1234,1485,Kilometer,,,,,10\n'
    '2026-08-03,Teststation(TST1),AION,Ghost Service,6 Std.,'
    '100,120,Kilometer,,,,,2\n';

/// Package Report with two review traps:
///   * a blank spacer column in the header (M1 — the fuzzy column match must
///     not bind to it), and
///   * a German grouped parcel count `10.436` (I1).
const _syntheticPackageCsv =
    '﻿Datum,Station,Anbieter‑Kurzcode,,zugestellt insgesamt\n'
    '2026-08-03,Teststation(TST1),AION,,10.436\n';

/// Minimal WST matching the A1b invoice: one Sameday 6h day, fully billed.
WstData wstForFooterCase() => parseWstFiles(<NamedBytes>[
      NamedBytes(
        'Weekly.csv',
        ('Datum,Station,Servicetyp,Geplante Dauer,abgeschlossen\n'
                '2026-08-03,Teststation(TST1),Sameday Parcel,6 Std.,10\n')
            .codeUnits,
      ),
    ]);

void runSyntheticSuite() {
  section('═══ SUITE A — synthetic fixtures (no external files) ═══');

  // ── A1 / C1: the footer after the table must not corrupt the last row ──
  section('A1 · C1 — table footer must not bleed into descriptions');
  final invoice = parseInvoiceText(_syntheticInvoiceText);
  for (final l in invoice.lines) {
    stdout.writeln('    $l');
  }
  check('detail rows parsed', invoice.lines.length, 4);
  check(
    'wrapped cell merged onto its own row',
    invoice.lines.first.description,
    'Standard Parcel - Low Emission Vehicle (350CF/81KWh) - Block of 9 Hours',
  );
  check(
    'last row description NOT polluted by the footer',
    invoice.lines.last.description,
    'Variable Per Shipment',
  );
  check(
    'last row still recognised as a parcel fee',
    invoice.lines.last.isPackageLine,
    true,
  );
  check('grand total from the summary table', invoice.grandTotal, 8000.0);
  check('week number', invoice.weekNumber, 32);

  // ── A1b / C1: the harder case — the last row's description does NOT end in
  // "Block of N Hours" / "Per Shipment", so the completeness guard cannot help
  // and the footer/address heuristics have to carry it on their own.
  section('A1b · C1 — footer rejected even when the last row looks unfinished');
  final lateCancelLast = parseInvoiceText('''
Details des Rechnungsdatums:
Datum  Beschreibung  Stückpreis  Menge  Summe
08/03/2026  Sameday Parcel - Block of 6 Hours  179,10 €  10.0  1.791,00 €
08/08/2026  AMZL Late Cancel - weekend  105,50 €  1.0  105,50 €
Amazon Logistics Germany GmbH
Marcel-Breuer-Str. 12
80807 München Germany
Gutschrift gem. § 14 Abs. 2 S. 2 UStG.
''');
  for (final l in lateCancelLast.lines) {
    stdout.writeln('    $l');
  }
  check('rows parsed', lateCancelLast.lines.length, 2);
  check(
    'trailing Late-Cancel description stays clean',
    lateCancelLast.lines.last.description,
    'AMZL Late Cancel - weekend',
  );
  final lateCancelRes = reconcile(lateCancelLast, wstForFooterCase());
  check(
    'Late Cancel still classified as unrelated (not a broken route)',
    lateCancelRes.unrelatedInvoiceDescriptions,
    ['AMZL Late Cancel - weekend'],
  );
  check(
    'no fabricated missing routes from the footer',
    lateCancelRes.missingRoutes.length,
    0,
  );

  // ── A2 / I1: German grouped integers in the WST CSVs ──
  section('A2 · I1 — German grouped numbers (`10.436`) must not truncate');
  check('parseNumberLoose("10.436")', parseNumberLoose('10.436'), 10436.0);
  check('parseNumberLoose("1.234.567")', parseNumberLoose('1.234.567'), 1234567.0);
  check('parseNumberLoose("10 436")', parseNumberLoose('10 436'), 10436.0);
  // Must NOT be treated as grouping — these are genuine decimals.
  check('parseNumberLoose("10436.0")', parseNumberLoose('10436.0'), 10436.0);
  check('parseNumberLoose("250.65")', parseNumberLoose('250.65'), 250.65);
  check('parseNumberLoose("1.234,56")', parseNumberLoose('1.234,56'), 1234.56);

  final wst = parseWstFiles(<NamedBytes>[
    NamedBytes('AION Weekly Report-2026-08-02.csv', _syntheticWeeklyCsv.codeUnits),
    NamedBytes('AION Package Report-2026-08-02.csv', _syntheticPackageCsv.codeUnits),
  ]);
  stdout.writeln('    files used: ${wst.filesUsed}');
  check('weekly + package report both recognised', wst.filesUsed.length, 2);
  check(
    'grouped parcel count read in full (M1 blank header column too)',
    wst.packages.isEmpty ? 'missing' : wst.packages.first.delivered,
    10436,
  );
  check('grouped route distance did not break the row', wst.totalRoutes, 32);

  // ── A3 / I2: price fallback must be the minimum, not the first seen ──
  section('A3 · I2 — price fallback must take the LOWEST same-duration block');
  final res = reconcile(invoice, wst);
  for (final r in res.missingRoutes) {
    stdout.writeln('    ${dayKey(r.date)}  ${r.serviceType} · ${r.hours}h  '
        'WST=${r.wstCount}  Rechnung=${r.invoiceCount}  Δ=${r.diff}  '
        '${eur(r.missingAmount)}'
        '${r.priceIsFallback ? '  (fallback price)' : ''}');
  }
  // The invoice lists Premium Parcel (200,00 €) BEFORE Sameday Parcel
  // (179,10 €) — both 6-hour blocks. First-seen would have picked 200,00 €.
  check('missing route positions', res.missingRoutes.length, 1);
  check('missing service type', res.missingRoutes.first.serviceType, 'Ghost Service');
  check('fallback flagged', res.missingRoutes.first.priceIsFallback, true);
  check(
    'fallback price is the minimum 6h block, not the first seen',
    res.missingRoutes.first.unitPrice,
    179.10,
  );
  check('missing amount', res.totalMissingAmount.toStringAsFixed(2), '358.20');

  // ── A4 / C1 consequence: no fabricated parcel claim ──
  section('A4 · C1 — no fabricated parcel claim from the footer bleed');
  check('missing parcels', res.missingPackages.length, 0);
  check('unrelated invoice lines', res.unrelatedInvoiceLineCount, 0);

  // ── A5 / M2: parcel count must not double-count the two fee kinds ──
  section('A5 · M2 — parcel count is per parcel, amount covers both fees');
  final twoFeeInvoice = parseInvoiceText('''
Details des Rechnungsdatums:
Datum  Beschreibung  Stückpreis  Menge  Summe
08/03/2026  Variable Per Shipment  0,05 €  1000.0  50,00 €
08/03/2026  Branding - Variable Per Shipment  0,05 €  1000.0  50,00 €
''');
  final twoFeeRes = reconcile(twoFeeInvoice, wst);
  check('two fee rows reported', twoFeeRes.missingPackages.length, 2);
  check('distinct fee kinds', twoFeeRes.missingPackageFeeKinds, 2);
  check(
    'parcel count counted once (9436, not 18872)',
    twoFeeRes.totalMissingPackages,
    9436,
  );
  check(
    'amount still covers BOTH fees (2 × 9436 × 0,05 €)',
    twoFeeRes.totalMissingPackageAmount.toStringAsFixed(2),
    '943.60',
  );

  // ── A6 / M5: unknown periods must not silently claim "overlaps" ──
  section('A6 · M5 — unknown period is reported as unknown, not as OK');
  final noWst = parseWstFiles(const <NamedBytes>[]);
  final unknownRes = reconcile(invoice, noWst);
  check('periodsKnown', unknownRes.periodsKnown, false);
  check('periodsOverlap not silently true', unknownRes.periodsOverlap, false);
  check('known periods still overlap', res.periodsKnown && res.periodsOverlap, true);

  // ── A7: getrennte Uploads (Weekly-only, dann Package-only) ergänzen
  //    sich; erneuter Upload derselben Komponente ersetzt statt addiert ──
  section('A7 — mergeWstData: separate uploads accumulate, re-upload replaces');
  final weeklyOnly = parseWstFiles([
    NamedBytes('AION Weekly Report-2026-08-02.csv', _syntheticWeeklyCsv.codeUnits),
  ]);
  final packageOnly = parseWstFiles([
    NamedBytes('AION Package Report-2026-08-02.csv', _syntheticPackageCsv.codeUnits),
  ]);
  check('weekly-only has routes, no packages',
      weeklyOnly.routes.isNotEmpty && weeklyOnly.packages.isEmpty, true);
  check('package-only has packages, no routes',
      packageOnly.packages.isNotEmpty && packageOnly.routes.isEmpty, true);
  final merged = mergeWstData(weeklyOnly, packageOnly);
  check('merged has both components',
      merged.routes.isNotEmpty && merged.packages.isNotEmpty, true);
  check('merged route total equals weekly-only total',
      merged.totalRoutes, weeklyOnly.totalRoutes);
  check('merged package total equals package-only total',
      merged.totalPackages, packageOnly.totalPackages);
  final remerged = mergeWstData(merged, weeklyOnly);
  check('re-uploading weekly replaces routes (no double count)',
      remerged.totalRoutes, weeklyOnly.totalRoutes);
  check('re-uploading weekly keeps packages',
      remerged.totalPackages, packageOnly.totalPackages);

  // ── A8: paidExtras + Tagesdetails ──
  section('A8 — paid extras aggregate & daily detail consistency');
  final extrasRes = reconcile(invoice, merged);
  check('paidExtras present (per-shipment fees at least)',
      extrasRes.paidExtras.isNotEmpty, true);
  final extrasQtySane = extrasRes.paidExtras
      .every((e) => e.quantity > 0 && e.amount >= 0);
  check('paidExtras quantities/amounts sane', extrasQtySane, true);
  final dailyWstSum = extrasRes.dailyRoutes
      .fold<int>(0, (acc, r) => acc + r.wstCount);
  check('daily detail WST route sum equals WST total',
      dailyWstSum, merged.totalRoutes);
}

// ═══════════════════════════════════════════════════════════════════════════
// Suite B — real fixture files (optional)
// ═══════════════════════════════════════════════════════════════════════════

void runRealSuite(String invoicePath, List<String> wstPaths) {
  section('═══ SUITE B — real fixture files ═══');

  final invoiceFile = File(invoicePath);
  final missing = <String>[
    if (!invoiceFile.existsSync()) invoicePath,
    ...wstPaths.where((p) => !File(p).existsSync()),
  ];
  if (missing.isNotEmpty) {
    _skipped++;
    stdout.writeln('  ⏭  SKIPPED — fixture(s) not on this machine:');
    for (final m in missing) {
      stdout.writeln('       $m');
    }
    stdout.writeln('     Pass paths explicitly to run this suite:');
    stdout.writeln('       dart run tool/payment_check_parse_test.dart '
        '<invoice.pdf> <wst.zip|csv…>');
    return;
  }

  // ── (a) Invoice PDF ────────────────────────────────────────────────────
  section('(a) Invoice PDF: $invoicePath');
  final rawText = extractPdfText(invoiceFile.readAsBytesSync());
  check('pdf text usable', pdfTextLooksUsable(rawText), true);

  final invoice = parseInvoiceText(rawText);
  stdout.writeln('  invoice no       : ${invoice.invoiceNumber}');
  stdout.writeln('  week             : ${invoice.weekNumber}');
  stdout.writeln('  period           : ${_range(invoice.periodStart, invoice.periodEnd)}');
  stdout.writeln('  detail positions : ${invoice.lines.length}');
  stdout.writeln('  grand total      : ${eur(invoice.grandTotal)}');
  if (invoice.warnings.isNotEmpty) {
    stdout.writeln('  warnings         : ${invoice.warnings}');
  }

  final lowEm9 = invoice.lines.where((l) =>
      dayKey(l.date) == '2026-08-03' &&
      normKey(l.description) ==
          normKey('Standard Parcel - Low Emission Vehicle (350CF/81KWh) '
              '- Block of 9 Hours'));
  check(
    '08/03 "Standard Parcel - Low Emission Vehicle (350CF/81KWh) '
    '- Block of 9 Hours" qty',
    lowEm9.isEmpty ? 'missing' : lowEm9.first.quantity.round(),
    20,
  );

  final vps = invoice.lines
      .where((l) => dayKey(l.date) == '2026-08-03' && l.isPackageLine);
  check(
    '08/03 "Variable Per Shipment" qty',
    vps.isEmpty ? 'missing' : vps.first.quantity.round(),
    10436,
  );
  check('Gesamtbetrag (98.230,08 €)', invoice.grandTotal, 98230.08);

  // ── (b) WST export ─────────────────────────────────────────────────────
  section('(b) WST files: ${wstPaths.join(', ')}');
  final wstInput = <NamedBytes>[
    for (final p in wstPaths)
      NamedBytes(
        p.split(Platform.pathSeparator).last,
        File(p).readAsBytesSync(),
      ),
  ];
  final wst = parseWstFiles(wstInput);
  stdout.writeln('  files used       : ${wst.filesUsed}');
  stdout.writeln('  files ignored    : ${wst.filesIgnored}');
  stdout.writeln('  stations         : ${wst.stations}');
  stdout.writeln('  period           : ${_range(wst.minDate, wst.maxDate)}');
  stdout.writeln('  routes total     : ${wst.totalRoutes}');
  stdout.writeln('  packages total   : ${wst.totalPackages}');

  final wRow = wst.routes.where((r) =>
      dayKey(r.date) == '2026-08-03' &&
      r.hours == 9 &&
      normKey(r.serviceType) ==
          normKey('Standard Parcel - Low Emission Vehicle (350CF/81KWh)'));
  check(
    'Weekly 2026-08-03 "Standard Parcel - Low Emission Vehicle '
    '(350CF/81KWh)" 9 Std. completed',
    wRow.isEmpty ? 'missing' : wRow.first.completed,
    20,
  );
  final pRow = wst.packages.where((p) => dayKey(p.date) == '2026-08-03');
  check(
    'Package 2026-08-03 delivered',
    pRow.isEmpty ? 'missing' : pRow.first.delivered,
    10436,
  );

  // ── (c) Reconciliation ─────────────────────────────────────────────────
  section('(c) Reconciliation — only what is MISSING on the invoice');
  final res = reconcile(invoice, wst);
  stdout.writeln('  invoice period   : ${_range(res.invoiceStart, res.invoiceEnd)}');
  stdout.writeln('  wst period       : ${_range(res.wstStart, res.wstEnd)}');
  stdout.writeln('  MISSING ROUTES (${res.missingRoutes.length} positions):');
  if (res.missingRoutes.isEmpty) stdout.writeln('    — none —');
  for (final r in res.missingRoutes) {
    stdout.writeln('    ${dayKey(r.date)}  ${r.serviceType} · ${r.hours}h  '
        'WST=${r.wstCount}  Rechnung=${r.invoiceCount}  Δ=${r.diff}  '
        '${eur(r.missingAmount)}'
        '${r.priceIsFallback ? '  (Preis aus gleichartigem Block)' : ''}');
  }
  stdout.writeln('  MISSING PACKAGES (${res.missingPackages.length} positions):');
  if (res.missingPackages.isEmpty) stdout.writeln('    — none —');
  for (final p in res.missingPackages) {
    stdout.writeln('    ${dayKey(p.date)}  ${p.kind}  WST=${p.wstCount}  '
        'Rechnung=${p.invoiceCount}  Δ=${p.diff}  ${eur(p.missingAmount)}');
  }
  stdout.writeln('  Fehlend gesamt   : ${res.totalMissingRoutes} Routen · '
      '${res.totalMissingPackages} Pakete · ${eur(res.totalMissingAmount)}');
  stdout.writeln('  Ohne WST-Bezug   : ${res.unrelatedInvoiceLineCount} '
      'Rechnungspositionen ${res.unrelatedInvoiceDescriptions}');

  check('periods known', res.periodsKnown, true);
  check('periods overlap', res.periodsOverlap, true);
  // The real week is fully billed: WST reports 333 completed routes and the
  // invoice bills exactly 333 blocks. Anything else is a parsing regression.
  check('WST routes total', wst.totalRoutes, 333);
  check('missing routes (week is fully billed)', res.totalMissingRoutes, 0);
  check('missing packages', res.missingPackages.length, 0);
  check(
    'unrelated invoice lines are Late-Cancel only',
    res.unrelatedInvoiceDescriptions
        .every((d) => d.toLowerCase().contains('late cancel')),
    true,
  );

  // ── (d) Synthetic gap on real data ─────────────────────────────────────
  //
  // (c) reconciles perfectly, which would leave the missing-detection code
  // untested against real input. So we remove three kinds of positions from
  // the real invoice and assert they surface correctly.
  section('(d) Real invoice with positions removed → must report the gap');
  final trimmed = InvoiceData(
    lines: invoice.lines
        .where((l) => !(dayKey(l.date) == '2026-08-05' &&
            normKey(l.description) ==
                normKey('Sameday Parcel - Block of 6 Hours')))
        .where((l) =>
            normKey(l.description) !=
            normKey('Nursery Route Level 4 - Block of 9 Hours'))
        .where((l) => !(dayKey(l.date) == '2026-08-07' && l.isPackageLine))
        .toList(),
    grandTotal: invoice.grandTotal,
    invoiceNumber: invoice.invoiceNumber,
    periodStart: invoice.periodStart,
    periodEnd: invoice.periodEnd,
    weekNumber: invoice.weekNumber,
  );
  final gap = reconcile(trimmed, wst);
  for (final r in gap.missingRoutes) {
    stdout.writeln('    ${dayKey(r.date)}  ${r.serviceType} · ${r.hours}h  '
        'WST=${r.wstCount}  Rechnung=${r.invoiceCount}  Δ=${r.diff}  '
        '${eur(r.missingAmount)}'
        '${r.priceIsFallback ? '  (Preis aus gleichartigem Block)' : ''}');
  }
  for (final p in gap.missingPackages) {
    stdout.writeln('    ${dayKey(p.date)}  ${p.kind}  WST=${p.wstCount}  '
        'Rechnung=${p.invoiceCount}  Δ=${p.diff}  ${eur(p.missingAmount)}');
  }
  check('gap: missing route positions', gap.missingRoutes.length, 2);
  check('gap: missing routes total', gap.totalMissingRoutes, 11);
  check(
    'gap: fallback price used for un-billed service type',
    gap.missingRoutes.any((r) => r.priceIsFallback && r.unitPrice == 250.65),
    true,
  );
  check('gap: missing parcels', gap.totalMissingPackages, 9495);
  check('gap: missing amount', gap.totalMissingAmount.toStringAsFixed(2), '2516.40');
  check('gap: not complete', gap.isComplete, false);
}

String _range(DateTime? a, DateTime? b) =>
    '${a == null ? '—' : dayKey(a)} … ${b == null ? '—' : dayKey(b)}';

// ═══════════════════════════════════════════════════════════════════════════

void main(List<String> args) {
  stdout.writeln('═══ Payment Check parse harness ═══');

  runSyntheticSuite();
  runRealSuite(
    args.isNotEmpty ? args[0] : _defaultInvoice,
    args.length > 1 ? args.sublist(1) : <String>[_defaultWstZip],
  );

  stdout.writeln('\n═══════════════════════════════════════');
  if (_failures == 0) {
    stdout.writeln('ALL GREEN — $_checks checks passed'
        '${_skipped > 0 ? ', $_skipped suite(s) skipped' : ''}.');
    exit(0);
  }
  stdout.writeln('FAILED — $_failures of $_checks checks failed.');
  exit(1);
}
