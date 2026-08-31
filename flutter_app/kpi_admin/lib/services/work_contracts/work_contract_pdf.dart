// lib/services/work_contracts/work_contract_pdf.dart
//
// PDF-Erzeugung für Work Contracts im bestehenden ARION-Vertragsdesign:
// Deckblatt "ZUSAMMENFASSUNG", Adressblatt, Vertrag mit nummerierten
// Paragraphen, Unterschriftenblock (GF-Unterschrift eingebettet),
// DSGVO-Anlage — plus Extra-Dokumente (Zeitkonto, Kamera-DSGVO, EzB).

import 'dart:typed_data';
import 'dart:ui' show Offset, Rect;

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;

import 'work_contract_model.dart';
import 'work_contract_texts.dart';

const _orange = PdfColor.fromInt(0xFFF59A00);
const _ink = PdfColor.fromInt(0xFF1F2327);
const _grey = PdfColor.fromInt(0xFF8A8F98);
const _line = PdfColor.fromInt(0xFFB9BEC6);

class WcAssets {
  WcAssets({
    required this.logoDelivery,
    required this.logoLogistics,
    required this.qr,
    required this.body,
    required this.bodyBold,
    required this.display,
    this.signature,
  });

  final pw.MemoryImage logoDelivery;
  final pw.MemoryImage logoLogistics;
  final pw.MemoryImage qr;
  final pw.Font body;
  final pw.Font bodyBold;
  final pw.Font display;
  final pw.MemoryImage? signature;
}

/// Lädt Logos/QR aus den App-Assets, Schriften von Google Fonts (mit
/// Helvetica-Fallback) und nimmt die GF-Unterschrift als Bytes entgegen.
Future<WcAssets> wcLoadAssets({Uint8List? signaturePng}) async {
  final logo1 = pw.MemoryImage(
    (await rootBundle.load('assets/contracts/logo_delivery.png'))
        .buffer
        .asUint8List(),
  );
  final logo2 = pw.MemoryImage(
    (await rootBundle.load('assets/contracts/logo_logistics.png'))
        .buffer
        .asUint8List(),
  );
  final qr = pw.MemoryImage(
    (await rootBundle.load('assets/contracts/footer_qr.png'))
        .buffer
        .asUint8List(),
  );

  // Gebündelte Fonts (netz-unabhängig, volle Umlaut-/Anführungszeichen-
  // Unterstützung). Google-Fonts-Fallback nur, falls Assets fehlen.
  pw.Font body;
  pw.Font bodyBold;
  pw.Font display;
  try {
    body = pw.Font.ttf(
        await rootBundle.load('assets/contracts/OpenSans-Regular.ttf'));
    bodyBold = pw.Font.ttf(
        await rootBundle.load('assets/contracts/OpenSans-Bold.ttf'));
    display = pw.Font.ttf(
        await rootBundle.load('assets/contracts/Montserrat-ExtraBold.ttf'));
  } catch (_) {
    try {
      body = await PdfGoogleFonts.openSansRegular();
      bodyBold = await PdfGoogleFonts.openSansBold();
      display = await PdfGoogleFonts.montserratExtraBold();
    } catch (_) {
      body = pw.Font.helvetica();
      bodyBold = pw.Font.helveticaBold();
      display = pw.Font.helveticaBold();
    }
  }

  return WcAssets(
    logoDelivery: logo1,
    logoLogistics: logo2,
    qr: qr,
    body: body,
    bodyBold: bodyBold,
    display: display,
    signature: signaturePng == null ? null : pw.MemoryImage(signaturePng),
  );
}

// ── Bausteine ────────────────────────────────────────────────────────────

pw.Widget _coverFooter(WcAssets a) => pw.Column(children: [
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(WcEmployer.name,
                    style: pw.TextStyle(
                        font: a.bodyBold, fontSize: 11, color: _ink)),
                pw.SizedBox(height: 2),
                pw.Text(WcEmployer.web,
                    style: pw.TextStyle(
                        font: a.body, fontSize: 10, color: _grey)),
                pw.Text(WcEmployer.email,
                    style: pw.TextStyle(
                        font: a.body, fontSize: 10, color: _grey)),
                pw.SizedBox(height: 2),
                pw.Text(WcEmployer.phone,
                    style: pw.TextStyle(
                        font: a.body, fontSize: 10, color: _grey)),
              ],
            ),
          ),
          pw.Image(a.qr, width: 58, height: 58),
        ],
      ),
      pw.SizedBox(height: 8),
      pw.Container(height: 2.5, color: _orange),
    ]);

pw.Widget _fieldLine(WcAssets a, String value, String label,
        {double width = double.infinity}) =>
    pw.Container(
      width: width == double.infinity ? null : width,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 2, bottom: 2),
            child: pw.Text(value.isEmpty ? ' ' : value,
                style:
                    pw.TextStyle(font: a.body, fontSize: 11.5, color: _ink)),
          ),
          pw.Container(height: 0.8, color: _line),
          pw.SizedBox(height: 2),
          pw.Text(label.toUpperCase(),
              style: pw.TextStyle(
                  font: a.bodyBold,
                  fontSize: 6.5,
                  color: _grey,
                  letterSpacing: 0.5)),
        ],
      ),
    );

pw.Widget _checkbox(WcAssets a, bool checked, String label,
        {double size = 9}) =>
    pw.Row(mainAxisSize: pw.MainAxisSize.min, children: [
      pw.Container(
        width: size,
        height: size,
        decoration: pw.BoxDecoration(
            border: pw.Border.all(color: _ink, width: 0.9)),
        alignment: pw.Alignment.center,
        child: checked
            ? pw.Text('X',
                style: pw.TextStyle(
                    font: a.bodyBold, fontSize: size - 2, color: _ink))
            : null,
      ),
      pw.SizedBox(width: 4),
      pw.Text(label,
          style: pw.TextStyle(font: a.bodyBold, fontSize: 7.5, color: _grey)),
    ]);

/// Unterschriftenblock: links Arbeitgeber (mit eingebetteter Signatur),
/// rechts Arbeitnehmer.
pw.Widget _signatureBlock(WcAssets a, WorkContractData d,
    {String rightLabel = 'UNTERSCHRIFT, ARBEITNEHMER'}) {
  pw.Widget side({
    required String place,
    required String label,
    pw.MemoryImage? sig,
  }) =>
      pw.Expanded(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(place,
                style:
                    pw.TextStyle(font: a.body, fontSize: 10.5, color: _ink)),
            pw.SizedBox(height: 2),
            pw.Container(height: 0.8, width: 190, color: _line),
            pw.SizedBox(height: 2),
            pw.Text('ORT, DATUM',
                style: pw.TextStyle(
                    font: a.bodyBold, fontSize: 6.5, color: _grey)),
            pw.SizedBox(height: 14),
            pw.Container(
              height: 44,
              alignment: pw.Alignment.bottomLeft,
              child: sig == null
                  ? pw.SizedBox()
                  : pw.Image(sig, height: 44, fit: pw.BoxFit.contain),
            ),
            pw.SizedBox(height: 2),
            pw.Container(height: 0.8, width: 190, color: _line),
            pw.SizedBox(height: 2),
            pw.Text(label,
                style: pw.TextStyle(
                    font: a.bodyBold, fontSize: 6.5, color: _grey)),
          ],
        ),
      );

  final placeDate = '${d.signCity}, ${wcDate(d.signDate)}';
  return pw.Row(children: [
    side(
      place: placeDate,
      label: 'UNTERSCHRIFT, GESCHÄFTSFÜHRER | ${WcEmployer.name}',
      sig: a.signature,
    ),
    pw.SizedBox(width: 24),
    side(place: placeDate, label: rightLabel),
  ]);
}

pw.Widget _sectionTitle(WcAssets a, int n, String title) => pw.Padding(
      padding: const pw.EdgeInsets.only(top: 7, bottom: 3),
      child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.SizedBox(
          width: 30,
          child: pw.Text('$n.',
              style:
                  pw.TextStyle(font: a.bodyBold, fontSize: 9.8, color: _ink)),
        ),
        pw.Expanded(
          child: pw.Text(title,
              style:
                  pw.TextStyle(font: a.bodyBold, fontSize: 9.8, color: _ink)),
        ),
      ]),
    );

pw.Widget _clause(WcAssets a, int? n, String text) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.SizedBox(
          width: 30,
          child: n == null
              ? pw.SizedBox()
              : pw.Text('($n)',
                  style:
                      pw.TextStyle(font: a.body, fontSize: 8.8, color: _ink)),
        ),
        pw.Expanded(
          child: pw.Text(text,
                  style: pw.TextStyle(
                  font: a.body, fontSize: 8.8, color: _ink, lineSpacing: 1.1)),
        ),
      ]),
    );

// ── Arbeitsvertrag ──────────────────────────────────────────────────────

Future<Uint8List> wcBuildContractPdf(WorkContractData d, WcAssets a) async {
  final doc = pw.Document();
  final sections = wcBuildSections(d);

  // 1) Deckblatt "ZUSAMMENFASSUNG".
  doc.addPage(pw.Page(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.fromLTRB(40, 36, 40, 30),
    build: (ctx) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Image(a.logoDelivery, width: 210),
        pw.SizedBox(height: 42),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('ZUSAMMENFASSUNG',
                      style: pw.TextStyle(
                          font: a.display,
                          fontSize: 24,
                          color: PdfColor.fromInt(0xFF565B63),
                          letterSpacing: 1)),
                  pw.SizedBox(height: 4),
                  pw.Text('DATEN ZUM VERTRAG',
                      style: pw.TextStyle(
                          font: a.body,
                          fontSize: 12,
                          color: _grey,
                          letterSpacing: 1.5)),
                ],
              ),
            ),
            pw.SizedBox(
              width: 190,
              child:
                  _fieldLine(a, '${d.signCity}, ${wcDate(d.signDate)}', 'Ort, Datum'),
            ),
          ],
        ),
        pw.SizedBox(height: 48),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Kontaktdaten
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('KONTAKTDATEN',
                      style: pw.TextStyle(
                          font: a.display,
                          fontSize: 13,
                          color: PdfColor.fromInt(0xFF565B63),
                          letterSpacing: 1)),
                  pw.SizedBox(height: 18),
                  _fieldLine(a, d.employeeName, 'Vorname, Nachname',
                      width: 210),
                  pw.SizedBox(height: 14),
                  _fieldLine(a, d.employeeStreet, 'Strasse, Hausnr.',
                      width: 210),
                  pw.SizedBox(height: 14),
                  _fieldLine(a, d.employeeZipCity, 'PLZ, Ort', width: 210),
                  pw.SizedBox(height: 14),
                  _fieldLine(a, wcDate(d.birthDate), 'Geburtsdatum',
                      width: 210),
                  if (d.isVisa) ...[
                    pw.SizedBox(height: 14),
                    _fieldLine(a, d.nationality, 'Staatsangehörigkeit',
                        width: 210),
                  ],
                ],
              ),
            ),
            pw.SizedBox(width: 28),
            // Vertragsdaten
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('VERTRAGSDATEN',
                      style: pw.TextStyle(
                          font: a.display,
                          fontSize: 13,
                          color: PdfColor.fromInt(0xFF565B63),
                          letterSpacing: 1)),
                  pw.SizedBox(height: 18),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('BEFRISTUNG',
                          style: pw.TextStyle(
                              font: a.bodyBold, fontSize: 7, color: _grey)),
                      pw.SizedBox(width: 18),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _checkbox(a, !d.fixedTerm, 'UNBEFRISTET'),
                          pw.SizedBox(height: 5),
                          _checkbox(a, d.fixedTerm, 'BEFRISTET BIS'),
                          if (d.fixedTerm)
                            pw.Padding(
                              padding: const pw.EdgeInsets.only(left: 13),
                              child: pw.Column(
                                crossAxisAlignment:
                                    pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(wcDate(d.endDate),
                                      style: pw.TextStyle(
                                          font: a.body,
                                          fontSize: 10.5,
                                          color: _ink)),
                                  pw.Container(
                                      height: 0.8, width: 90, color: _orange),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 16),
                  _fieldLine(a, wcDate(d.startDate),
                      'Das Arbeitsverhältnis beginnt am'),
                  pw.SizedBox(height: 14),
                  pw.Row(children: [
                    pw.Expanded(
                      child: d.pay == WcPay.monthly
                          ? _fieldLine(a, '${wcEur(d.monthlySalary)} €',
                              'Gehalt / Monat')
                          : _fieldLine(a, '${wcEur(d.hourlyWage)} €',
                              'Stundenlohn (brutto)'),
                    ),
                    pw.SizedBox(width: 14),
                    pw.Expanded(
                      child: _fieldLine(
                          a, wcHours(d.hoursPerWeek), 'Std / Woche'),
                    ),
                  ]),
                  pw.SizedBox(height: 14),
                  _fieldLine(a, '${d.vacationDays}', 'Urlaubstage',
                      width: 110),
                  pw.SizedBox(height: 14),
                  _fieldLine(a, d.type.labelDe(), 'Vertragstyp', width: 180),
                ],
              ),
            ),
          ],
        ),
        pw.Spacer(),
        _coverFooter(a),
      ],
    ),
  ));

  // "Zweitschrift / FÜR MITARBEITER"-Kennzeichnung (oben rechts, wie im
  // bisherigen Vollpaket).
  pw.Widget copyMark() => pw.Align(
        alignment: pw.Alignment.topRight,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('Zweitschrift',
                style:
                    pw.TextStyle(font: a.bodyBold, fontSize: 12, color: _ink)),
            pw.Text('FÜR MITARBEITER',
                style: pw.TextStyle(
                    font: a.bodyBold,
                    fontSize: 6.5,
                    color: _grey,
                    letterSpacing: 1)),
          ],
        ),
      );

  // 3) Vertragstext — einmal als Original, einmal als Zweitschrift.
  void addContract({required bool copy}) {
    final firstPage = <int?>[null];
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.fromLTRB(46, copy ? 20 : 30, 46, 34),
      // Zweitschrift-Kennzeichnung sitzt bewusst weit oben mit klarem
      // Abstand zum Haupttext.
      header: (ctx) => copy
          ? pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 16),
              child: copyMark(),
            )
          : pw.SizedBox(height: ctx.pageNumber == 0 ? 0 : 6),
      footer: (ctx) {
        firstPage[0] ??= ctx.pageNumber;
        return pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text('${ctx.pageNumber - firstPage[0]! + 1}',
              style: pw.TextStyle(font: a.body, fontSize: 9, color: _grey)),
        );
      },
      build: (ctx) => [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('ARBEITSVERTRAG',
                      style: pw.TextStyle(
                          font: a.display, fontSize: 26, color: _ink)),
                  pw.SizedBox(height: 4),
                  pw.Text(
                      'Arbeitsvertragliche Vereinbarung zwischen folgenden '
                      'Parteien:',
                      style: pw.TextStyle(
                          font: a.body, fontSize: 9.5, color: _ink)),
                ],
              ),
            ),
            pw.Image(a.logoLogistics, width: 170),
          ],
        ),
        pw.SizedBox(height: 24),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _fieldLine(a, WcEmployer.name, 'Firmenname', width: 210),
                  pw.SizedBox(height: 10),
                  _fieldLine(a, WcEmployer.street, 'Straße, Hausnr.',
                      width: 210),
                  pw.SizedBox(height: 10),
                  _fieldLine(a, WcEmployer.zipCity, 'PLZ, Ort', width: 210),
                  pw.SizedBox(height: 10),
                  pw.Text('- ARBEITGEBER -',
                      style: pw.TextStyle(
                          font: a.bodyBold, fontSize: 7.5, color: _grey)),
                ],
              ),
            ),
            pw.SizedBox(width: 30),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _fieldLine(a, d.employeeName, 'Vorname, Nachname',
                      width: 210),
                  pw.SizedBox(height: 10),
                  _fieldLine(a, d.employeeStreet, 'Straße, Hausnr.',
                      width: 210),
                  pw.SizedBox(height: 10),
                  _fieldLine(a, d.employeeZipCity, 'PLZ, Ort', width: 210),
                  pw.SizedBox(height: 10),
                  pw.Text('- ARBEITNEHMER -',
                      style: pw.TextStyle(
                          font: a.bodyBold, fontSize: 7.5, color: _grey)),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        for (var i = 0; i < sections.length - 1; i++) ...[
          _sectionTitle(a, i + 1, sections[i].title),
          if (sections[i].clauses.length == 1)
            _clause(a, null, sections[i].clauses.first)
          else
            for (var c = 0; c < sections[i].clauses.length; c++)
              _clause(a, c + 1, sections[i].clauses[c]),
        ],
        // Letzter Paragraph + Unterschriften als EIN Block, damit die
        // Unterschriften nie allein auf einer Seite stehen (pw.Column ist
        // ein SpanningWidget — erst der Container macht den Block atomar).
        pw.Container(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _sectionTitle(a, sections.length, sections.last.title),
              if (sections.last.clauses.length == 1)
                _clause(a, null, sections.last.clauses.first)
              else
                for (var c = 0; c < sections.last.clauses.length; c++)
                  _clause(a, c + 1, sections.last.clauses[c]),
              pw.SizedBox(height: 22),
              _signatureBlock(a, d),
            ],
          ),
        ),
      ],
    ));
  }

  // 4) Anlage DSGVO — ebenfalls je einmal für Original und Zweitschrift.
  void addAnnex({required bool copy}) {
    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.fromLTRB(48, copy ? 20 : 30, 48, 44),
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (copy) copyMark(),
          pw.SizedBox(height: copy ? 18 : 14),
          pw.Text('Anlage: DSGVO',
              style:
                  pw.TextStyle(font: a.bodyBold, fontSize: 12, color: _ink)),
          pw.SizedBox(height: 4),
          pw.Text(wcDsgvoAnnexTitle,
              style:
                  pw.TextStyle(font: a.bodyBold, fontSize: 10.5, color: _ink)),
          pw.SizedBox(height: 14),
          pw.Row(children: [
            pw.Expanded(
              child: _fieldLine(
                  a,
                  '${d.signCity}, ${wcDate(d.signDate)}',
                  'Anlage zum Arbeitsvertrag vom'),
            ),
            pw.SizedBox(width: 24),
            pw.Expanded(
              child: _fieldLine(a, d.employeeName, 'Arbeitnehmer'),
            ),
          ]),
          pw.SizedBox(height: 18),
          for (final p in wcDsgvoAnnexBody)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Text(p,
                          style: pw.TextStyle(
                      font: a.body,
                      fontSize: 9.5,
                      color: _ink,
                      lineSpacing: 1.6)),
            ),
          pw.SizedBox(height: 30),
          _signatureBlock(a, d),
          pw.Spacer(),
          _coverFooter(a),
        ],
      ),
    ));
  }

  // Beim Arbeitsvisum: NUR der reine Arion-Vertrag (Deckblatt + Vertrag +
  // DSGVO-Anlage) — keine Zweitschrift, keine Amazon-Anhänge.
  if (d.isVisa) {
    addContract(copy: false);
    addAnnex(copy: false);
    return doc.save();
  }

  addContract(copy: false);
  addAnnex(copy: false);
  addContract(copy: true);
  addAnnex(copy: true);

  // 5) Statische Anhänge (AMZL Privacy Notice, Background-Check-Consent,
  // Postgesetz-Lieferanweisungen, Unterweisungsnachweis ArbSchG) aus dem
  // bisherigen Vollpaket anhängen — alles in EINER PDF. Die
  // Teilnahmebescheinigung Training bleibt bewusst draußen.
  final generated = await doc.save();
  final anhang = (await rootBundle.load('assets/contracts/anhang_amazon.pdf'))
      .buffer
      .asUint8List();
  return _appendStaticPdf(generated, anhang, d);
}

/// Fügt generierte PDF + statischen Vorlagen-Anhang zu EINER PDF zusammen
/// und personalisiert die Unterschrifts-Seiten des Anhangs (AMZL Privacy,
/// Background Check, Unterweisungsnachweis): alte eingebrannte Werte der
/// Vorlage werden geweißt und Name/Ort/Datum des Mitarbeiters eingedruckt.
///
/// Wichtig: In ein NEUES Dokument mergen — bei einem geladenen Dokument
/// ignoriert Syncfusion `pageSettings.margins` für `pages.add()` und
/// clippt die Seiteninhalte auf die Default-Ränder (40 pt).
Future<Uint8List> _appendStaticPdf(
    Uint8List base, Uint8List attachment, WorkContractData d) async {
  final target = sf.PdfDocument();
  target.pageSettings.margins.all = 0;

  final fontData = (await rootBundle.load('assets/contracts/OpenSans-Regular.ttf'))
      .buffer
      .asUint8List();
  final font = sf.PdfTrueTypeFont(fontData, 9);
  final white = sf.PdfSolidBrush(sf.PdfColor(255, 255, 255));
  final black = sf.PdfSolidBrush(sf.PdfColor(31, 35, 39));

  // Vorlagen-Seiten 1–12 wurden von US-Letter auf A4 skaliert — der
  // Inhalt sitzt dadurch UNTEN im A4 (PDF-Ursprung links unten), in
  // Top-Koordinaten also um (A4-Höhe − skalierte Letter-Höhe) versetzt.
  const s = 595.276 / 612.0;
  const yOff = 841.89 - 792.0 * s;
  final placeDate = '${d.signCity}, ${wcDate(d.signDate)}';

  void stamp(sf.PdfGraphics g, double scale, double dy,
      List<({double x, double y, double w, String? text})> items) {
    for (final it in items) {
      if (it.w > 0) {
        g.drawRectangle(
          brush: white,
          bounds: Rect.fromLTWH(it.x * scale, it.y * scale + dy,
              it.w * scale, 15 * scale),
        );
      }
      if (it.text != null) {
        // Höhe großzügig — Syncfusion clippt Zeilen, die nicht komplett in
        // die Bounds passen.
        g.drawString(it.text!, font,
            brush: black,
            bounds: Rect.fromLTWH(
                (it.x + 2) * scale, (it.y + 1) * scale + dy, 320, 18));
      }
    }
  }

  var attachmentIndex = -1;
  for (final part in [base, attachment]) {
    final isAttachment = !identical(part, base);
    final src = sf.PdfDocument(inputBytes: part);
    for (var i = 0; i < src.pages.count; i++) {
      final srcPage = src.pages[i];
      target.pageSettings.size = srcPage.size;
      final template = srcPage.createTemplate();
      final page = target.pages.add();
      page.graphics.drawPdfTemplate(template, Offset.zero);
      if (!isAttachment) continue;
      attachmentIndex = i;
      switch (attachmentIndex) {
        case 6: // AMZL Privacy Notice — Bestätigungsblock.
          stamp(page.graphics, s, yOff, [
            (x: 142, y: 325, w: 180, text: d.employeeName),
            (x: 142, y: 355, w: 180, text: placeDate),
          ]);
        case 9: // Background-Check-Consent — Datum + Name.
          stamp(page.graphics, s, yOff, [
            (x: 115, y: 300, w: 190, text: placeDate),
            (x: 320, y: 300, w: 0, text: 'Name: ${d.employeeName}'),
          ]);
        case 12: // Unterweisungsnachweis ArbSchG.
          stamp(page.graphics, 1, 0, [
            (x: 219, y: 164, w: 148, text: placeDate),
            (x: 443, y: 164, w: 0, text: d.employeeName),
            (x: 60, y: 517, w: 122, text: placeDate),
            (x: 331, y: 517, w: 122, text: placeDate),
          ]);
      }
    }
    src.dispose();
  }
  final out = Uint8List.fromList(target.saveSync());
  target.dispose();
  return out;
}

// ── Zeitkontovereinbarung ───────────────────────────────────────────────

Future<Uint8List> wcBuildZeitkontoPdf(WorkContractData d, WcAssets a) async {
  final doc = pw.Document();
  final clauses = wcZeitkontoClauses(d);

  doc.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.fromLTRB(48, 44, 48, 44),
    footer: (ctx) => pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Text('${ctx.pageNumber}',
          style: pw.TextStyle(font: a.body, fontSize: 9, color: _grey)),
    ),
    build: (ctx) => [
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('ERGÄNZUNGSVEREINBARUNG',
                    style: pw.TextStyle(
                        font: a.display, fontSize: 18, color: _ink)),
                pw.SizedBox(height: 4),
                pw.Text(
                    'zum Arbeitsvertrag über die Einrichtung eines '
                    'Arbeitszeitkontos',
                    style: pw.TextStyle(
                        font: a.body, fontSize: 10.5, color: _ink)),
              ],
            ),
          ),
          pw.Image(a.logoLogistics, width: 160),
        ],
      ),
      pw.SizedBox(height: 26),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _fieldLine(a, WcEmployer.name, 'Firmenname', width: 210),
                pw.SizedBox(height: 10),
                _fieldLine(
                    a,
                    '${WcEmployer.street}, ${WcEmployer.zipCity}',
                    'Adresse',
                    width: 210),
                pw.SizedBox(height: 8),
                pw.Text('- ARBEITGEBER -',
                    style: pw.TextStyle(
                        font: a.bodyBold, fontSize: 7.5, color: _grey)),
              ],
            ),
          ),
          pw.SizedBox(width: 30),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _fieldLine(a, d.employeeName, 'Vorname, Nachname',
                    width: 210),
                pw.SizedBox(height: 10),
                _fieldLine(
                    a,
                    '${d.employeeStreet}, ${d.employeeZipCity}',
                    'Adresse',
                    width: 210),
                pw.SizedBox(height: 8),
                pw.Text('- ARBEITNEHMER -',
                    style: pw.TextStyle(
                        font: a.bodyBold, fontSize: 7.5, color: _grey)),
              ],
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 18),
      pw.Text('Präambel',
          style: pw.TextStyle(font: a.bodyBold, fontSize: 10.5, color: _ink)),
      pw.SizedBox(height: 4),
      pw.Text(
        'Zwischen den Parteien besteht ein Arbeitsverhältnis auf Grundlage '
        'des am ${wcDate(d.signDate)} geschlossenen Arbeitsvertrages '
        '(„Arbeitsvertrag“). Ergänzend zu den Regelungen des '
        'Arbeitsvertrages vereinbaren die Parteien, zur Flexibilisierung '
        'der Arbeitszeit, die Einrichtung eines Arbeitszeitkontos ab dem '
        '${wcDate(d.startDate)}:',
        style: pw.TextStyle(
            font: a.body, fontSize: 9.5, color: _ink, lineSpacing: 1.6),
      ),
      pw.SizedBox(height: 8),
      for (var i = 0; i < clauses.length - 1; i++)
        _clause(a, i + 1, clauses[i]),
      // Letzte Klausel + Unterschriften zusammenhalten (kein verwaister
      // Unterschriftenblock auf einer eigenen Seite).
      pw.Container(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _clause(a, clauses.length, clauses.last),
            pw.SizedBox(height: 22),
            _signatureBlock(a, d),
          ],
        ),
      ),
    ],
  ));
  return doc.save();
}

// ── Kamera-DSGVO (VAS Road Safety) ──────────────────────────────────────

Future<Uint8List> wcBuildCameraPrivacyPdf(
    WorkContractData d, WcAssets a) async {
  final doc = pw.Document();
  final sections = wcCameraPrivacySections(d);

  doc.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.fromLTRB(48, 44, 48, 44),
    footer: (ctx) => pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Text('${ctx.pageNumber}',
          style: pw.TextStyle(font: a.body, fontSize: 9, color: _grey)),
    ),
    build: (ctx) => [
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Text(
                'Datenschutzerklärung für den Einsatz von '
                'Verkehrssicherheitstechnologien und Fahrsicherheitstools',
                style: pw.TextStyle(
                    font: a.bodyBold, fontSize: 13, color: _ink)),
          ),
          pw.SizedBox(width: 16),
          pw.Image(a.logoLogistics, width: 150),
        ],
      ),
      pw.SizedBox(height: 4),
      pw.Text('Zuletzt aktualisiert: ${wcDate(d.signDate)}',
          style: pw.TextStyle(font: a.body, fontSize: 9, color: _grey)),
      pw.SizedBox(height: 10),
      pw.Text(
        'Mit dieser Datenschutzerklärung informieren wir Sie darüber, wie '
        'wir Ihre personenbezogenen Daten im Zusammenhang mit unserem in '
        'Lieferfahrzeugen installierten kamerabasierten '
        'Verkehrssicherheitssystem und Fahrsicherheitstools '
        '(„Verkehrssicherheitstechnologien“) verarbeiten.',
        style: pw.TextStyle(
            font: a.body, fontSize: 9.5, color: _ink, lineSpacing: 1.6),
      ),
      pw.SizedBox(height: 6),
      for (var i = 0; i < sections.length; i++) ...[
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 8, bottom: 3),
          child: pw.Text('${i + 1}. ${sections[i].title}',
              style: pw.TextStyle(
                  font: a.bodyBold, fontSize: 10.5, color: _ink)),
        ),
        for (final c in sections[i].clauses)
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 5),
            child: pw.Text(c,
                      style: pw.TextStyle(
                    font: a.body,
                    fontSize: 9.5,
                    color: _ink,
                    lineSpacing: 1.6)),
          ),
      ],
      // Bestätigungsblock als EIN Element — steht nie allein/zerissen.
      pw.Container(
          child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(height: 24),
          pw.Text('Erhalten am:',
              style:
                  pw.TextStyle(font: a.bodyBold, fontSize: 10, color: _ink)),
          pw.SizedBox(height: 20),
          pw.Row(children: [
            pw.Expanded(
                child: _fieldLine(
                    a, '${d.signCity}, ${wcDate(d.signDate)}', 'Datum')),
            pw.SizedBox(width: 24),
            pw.Expanded(
                child: _fieldLine(
                    a, d.employeeName, 'Name in Druckbuchstaben')),
          ]),
          pw.SizedBox(height: 26),
          pw.SizedBox(
              width: 220,
              child: _fieldLine(a, '', 'Unterschrift Arbeitnehmer')),
        ],
      )),
    ],
  ));
  return doc.save();
}

// ── EzB: Erklärung zum Beschäftigungsverhältnis (Visum) ─────────────────
//
// Füllt das ORIGINAL-Formular der Bundesagentur für Arbeit (ba047549,
// AcroForm, 5 Seiten) und bettet die GF-Unterschrift auf Seite 5 ein.
// Anschließend werden die Felder geflattet, damit die Werte beim Drucken
// in jedem Viewer sicher sichtbar sind.

Future<Uint8List> wcFillEzbOriginalPdf(
    WorkContractData d, Uint8List? signaturePng) async {
  final blank = (await rootBundle.load('assets/contracts/ezb_form.pdf'))
      .buffer
      .asUint8List();
  final doc = sf.PdfDocument(inputBytes: blank);
  final form = doc.form;

  final byName = <String, sf.PdfField>{};
  for (var i = 0; i < form.fields.count; i++) {
    final f = form.fields[i];
    byName[f.name ?? ''] = f;
  }

  void setText(String name, String value) {
    final f = byName[name];
    if (f is sf.PdfTextBoxField) f.text = value;
  }

  void setRadio(String name, int index) {
    final f = byName[name];
    if (f is sf.PdfRadioButtonListField &&
        index >= 0 &&
        index < f.items.count) {
      f.selectedIndex = index;
    }
  }

  void setCheck(String name, {bool value = true}) {
    final f = byName[name];
    if (f is sf.PdfCheckBoxField) f.isChecked = value;
  }

  // A. Erklärung und Anlass
  setRadio('rbtn_1_Erklaerung', switch (d.ezbProcedure) {
    'aufenthaltstitel' => 0,
    'arbeitserlaubnis' => 4,
    _ => 3, // Vorabzustimmung
  });
  setRadio('rbtn_2_Anlass', switch (d.ezbOccasion) {
    'verlaengerung' => 1,
    'wechsel' => 2,
    _ => 0, // Ersterteilung
  });

  // B. Arbeitnehmer/in
  final parts = d.employeeName.trim().split(RegExp(r'\s+'));
  final lastName = parts.isEmpty ? '' : parts.removeLast();
  setText('txtf_3_Vorname', parts.join(' '));
  setText('txtf_4_Nachname', lastName);
  setText('txtf_5_Geburtsdatum', wcDate(d.birthDate));
  if (d.gender == 'm') setRadio('rbtn_6_Geschlecht', 0);
  if (d.gender == 'w') setRadio('rbtn_6_Geschlecht', 1);
  if (d.gender == 'd') setRadio('rbtn_6_Geschlecht', 2);
  setText('txtf_7_Staatsangehoerigkeit', d.nationality);
  setText('txtf_8_Wohnsitz', '${d.employeeStreet}, ${d.employeeZipCity}');
  setText('txtf_9_seit', wcDate(d.residenceSince));

  // C. Arbeitgeber (Arion-Konstanten)
  setText('txtf_10_Firma', WcEmployer.name);
  setText('txtf_11_Strasse', 'Industriestr.');
  setText('txtf_12_Hausnummer', '12a');
  setText('txtf_13_Postleitzahl', '91325');
  setText('txtf_14_Ort', 'Adelsdorf');
  setText('txtf_15_Kontaktperson', WcEmployer.managingDirector);
  setText('txtf_16_Telefon', WcEmployer.contactPhone);
  setText('txtf_17_E-Mail', WcEmployer.email);
  setText('txtf_19_Betriebsnummer', WcEmployer.betriebsnummer);
  setRadio('rbtn_20_Unternehmen_gegruendet', 1); // Nein

  // D. Beschäftigung
  setText('txtf_21_Beschaeftigungsverhaeltniss', wcDate(d.startDate));
  setRadio('rbtn_22_Beschaeftigungsverhaeltniss', d.fixedTerm ? 1 : 0);
  if (d.fixedTerm) {
    setText('txtf_22_Beschaeftigungsverhaeltniss', wcDate(d.endDate));
  }
  setRadio('rbtn_23_Dritte', 1); // Nein
  setRadio('rbtn_24_Arbeitsort', 1); // wechselnde Arbeits-/Einsatzorte
  setText(
    'txtf_25_Berufsbezeichnung',
    'Berufsbezeichnung: Kurierfahrer/Paketzusteller. Beschreibung: '
        'Auslieferung und Zustellung von Waren und Gebrauchsgütern (Pakete) '
        'nach einer vorgeplanten Route; Be- und Entladen der Fahrzeuge; '
        'Fahrzeugpflege.',
  );

  // E. Qualifikation — Helfertätigkeit ohne Ausbildungsvoraussetzung.
  setCheck('chbx_34_keine_Ausbildung');

  // F. Berufsausübungserlaubnis
  setRadio('rbtn_35_Berufsausuebungserlaubnis', 1); // Nein

  // G. Arbeitszeit
  setRadio(
      'rbtn_37_Arbeitszeit',
      d.isMinijob
          ? 2
          : (d.hoursPerWeek >= 35 ? 0 : 1));
  setText('txtf_37_Arbeitsstunden_Woche', wcHours(d.hoursPerWeek));

  // H. Überstunden
  setRadio('rbtn_38_Ueberstunden', 0); // Ja
  setText('txtf_39_Ueberstundenumpfang', 'im gesetzlich zulässigen Rahmen');
  setText('txtf_40_Ueberstundenausgleich',
      'Freizeit oder Vergütung (Arbeitszeitkonto)');

  // I. Urlaub
  setText('txtf_41_Urlaubsanpruch', '${d.vacationDays}');

  // J. Arbeitsentgelt
  setRadio('rbtn_42_Arbeitgeber_tarifgebunden', 1); // Nein
  final entgelt = byName['chbx_46_Arbeitsentgelt'];
  if (entgelt is sf.PdfCheckBoxField && entgelt.items != null) {
    // Kind 0 = "pro Stunde", Kind 1 = "pro Monat".
    final idx = d.pay == WcPay.hourly ? 0 : 1;
    final item = entgelt.items![idx];
    if (item is sf.PdfCheckBoxItem) item.checked = true;
  }
  if (d.pay == WcPay.hourly) {
    setText('txtf_46_Entgelt_pro_Stunde', wcEur(d.hourlyWage));
  } else {
    setText('txtf_46_Entgelt_pro_Monat', wcEur(d.monthlySalary));
  }

  // K. Sozialversicherungspflicht
  setRadio('rbtn_52_besteht_Versicherungspflicht', 0); // Ja

  // L. Unterschrift
  setText('txtf_57_Ort', d.signCity);
  setText('txtf_58_Datum', wcDate(d.signDate));

  // Werte fest einbrennen, dann Unterschrift rechts neben Ort/Datum
  // (Feld 59) auf der letzten Seite platzieren.
  form.flattenAllFields();
  if (signaturePng != null) {
    final page = doc.pages[doc.pages.count - 1];
    // Seite ist A4 (595×842 pt); das Ort/Datum-Band liegt bei y≈735
    // (Top-Koordinaten). Unterschrift in den 59er-Bereich rechts daneben.
    page.graphics.drawImage(
      sf.PdfBitmap(signaturePng),
      // Direkt IM Unterschriften-Kasten von Feld 59 (Kasten ~735–753 pt,
      // Top-Koordinaten) — die Signatur ragt wie handschriftlich leicht
      // darüber hinaus.
      const Rect.fromLTWH(338, 718, 72, 36),
    );
  }

  final bytes = Uint8List.fromList(await doc.save());
  doc.dispose();
  return bytes;
}

// ── Führerschein-Bestätigung (Visum) ────────────────────────────────────

Future<Uint8List> wcBuildLicenseLetterPdf(
    WorkContractData d, WcAssets a) async {
  final doc = pw.Document();
  doc.addPage(pw.Page(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.fromLTRB(48, 44, 48, 44),
    build: (ctx) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Image(a.logoDelivery, width: 190),
        pw.SizedBox(height: 26),
        pw.Text(
            '${WcEmployer.name}\n${WcEmployer.street}, '
            '${WcEmployer.zipCity}\n${WcEmployer.email}',
            style: pw.TextStyle(font: a.body, fontSize: 10, color: _ink)),
        pw.SizedBox(height: 18),
        pw.Text('Datum: ${wcDate(d.signDate)}',
            style: pw.TextStyle(font: a.body, fontSize: 10, color: _ink)),
        pw.SizedBox(height: 24),
        pw.Text('Sehr geehrte Damen und Herren,',
            style: pw.TextStyle(font: a.body, fontSize: 10.5, color: _ink)),
        pw.SizedBox(height: 10),
        pw.Text(
          'wir möchten Sie darüber informieren, dass ${d.employeeName} in '
          'unserem Unternehmen als Fahrer für Fahrzeuge bis zu einem '
          'Gesamtgewicht von 3,5 Tonnen tätig sein wird. Für diese Aufgabe '
          'ist die Fahrerlaubnis der Kategorie B vollkommen ausreichend.',
          style: pw.TextStyle(
              font: a.body, fontSize: 10.5, color: _ink, lineSpacing: 1.8),
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          '${d.employeeName} wird sowohl im ländlichen Raum als auch in '
          'städtischen Gebieten unterwegs sein, um Pakete auszuliefern und '
          'wird dabei alle Straßen nutzen, die für den Verkehr freigegeben '
          'sind. Unser Fuhrpark besteht aus Fahrzeugen der Typen Mercedes '
          'Vito und Mercedes Sprinter, die jeweils ein maximales Gewicht '
          'von 3,5 Tonnen aufweisen.',
          style: pw.TextStyle(
              font: a.body, fontSize: 10.5, color: _ink, lineSpacing: 1.8),
        ),
        pw.SizedBox(height: 22),
        pw.Text('Mit freundlichen Grüßen',
            style: pw.TextStyle(font: a.body, fontSize: 10.5, color: _ink)),
        pw.SizedBox(height: 10),
        pw.Container(
          height: 46,
          alignment: pw.Alignment.bottomLeft,
          child: a.signature == null
              ? pw.SizedBox()
              : pw.Image(a.signature!, height: 46, fit: pw.BoxFit.contain),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
            '${WcEmployer.managingDirector}\nGeschäftsführer\n'
            '${WcEmployer.name}',
            style: pw.TextStyle(font: a.body, fontSize: 10.5, color: _ink)),
        pw.Spacer(),
        _coverFooter(a),
      ],
    ),
  ));
  return doc.save();
}
