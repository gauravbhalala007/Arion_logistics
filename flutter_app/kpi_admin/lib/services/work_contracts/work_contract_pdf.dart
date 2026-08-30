// lib/services/work_contracts/work_contract_pdf.dart
//
// PDF-Erzeugung für Work Contracts im bestehenden ARION-Vertragsdesign:
// Deckblatt "ZUSAMMENFASSUNG", Adressblatt, Vertrag mit nummerierten
// Paragraphen, Unterschriftenblock (GF-Unterschrift eingebettet),
// DSGVO-Anlage — plus Extra-Dokumente (Zeitkonto, Kamera-DSGVO, EzB).

import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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
      padding: const pw.EdgeInsets.only(top: 10, bottom: 4),
      child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.SizedBox(
          width: 34,
          child: pw.Text('$n.',
              style:
                  pw.TextStyle(font: a.bodyBold, fontSize: 10.5, color: _ink)),
        ),
        pw.Expanded(
          child: pw.Text(title,
              style:
                  pw.TextStyle(font: a.bodyBold, fontSize: 10.5, color: _ink)),
        ),
      ]),
    );

pw.Widget _clause(WcAssets a, int? n, String text) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.SizedBox(
          width: 34,
          child: n == null
              ? pw.SizedBox()
              : pw.Text('($n)',
                  style:
                      pw.TextStyle(font: a.body, fontSize: 9.5, color: _ink)),
        ),
        pw.Expanded(
          child: pw.Text(text,
              textAlign: pw.TextAlign.justify,
              style: pw.TextStyle(
                  font: a.body, fontSize: 9.5, color: _ink, lineSpacing: 1.6)),
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

  // 2) Adressblatt.
  doc.addPage(pw.Page(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.fromLTRB(40, 36, 40, 30),
    build: (ctx) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Image(a.logoDelivery, width: 210),
        pw.SizedBox(height: 30),
        pw.Text(
          '${WcEmployer.name}, ${WcEmployer.street}, ${WcEmployer.zipCity}',
          style: pw.TextStyle(font: a.bodyBold, fontSize: 7.5, color: _orange),
        ),
        pw.SizedBox(height: 8),
        pw.Text(d.employeeName,
            style: pw.TextStyle(font: a.body, fontSize: 12, color: _ink)),
        pw.SizedBox(height: 3),
        pw.Text(d.employeeStreet,
            style: pw.TextStyle(font: a.body, fontSize: 12, color: _ink)),
        pw.SizedBox(height: 3),
        pw.Text(d.employeeZipCity,
            style: pw.TextStyle(font: a.body, fontSize: 12, color: _ink)),
        pw.Spacer(),
        _coverFooter(a),
      ],
    ),
  ));

  // 3) Vertragstext.
  doc.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.fromLTRB(48, 44, 48, 44),
    footer: (ctx) => pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Text('${ctx.pageNumber - 2}',
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
      pw.SizedBox(height: 34),
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
      pw.SizedBox(height: 22),
      pw.Text('Präambel',
          style: pw.TextStyle(font: a.bodyBold, fontSize: 10.5, color: _ink)),
      pw.SizedBox(height: 4),
      pw.Text(wcPreamble,
          textAlign: pw.TextAlign.justify,
          style: pw.TextStyle(
              font: a.body, fontSize: 9.5, color: _ink, lineSpacing: 1.6)),
      pw.SizedBox(height: 6),
      for (var i = 0; i < sections.length; i++) ...[
        _sectionTitle(a, i + 1, sections[i].title),
        if (sections[i].clauses.length == 1)
          _clause(a, null, sections[i].clauses.first)
        else
          for (var c = 0; c < sections[i].clauses.length; c++)
            _clause(a, c + 1, sections[i].clauses[c]),
      ],
      pw.SizedBox(height: 26),
      _signatureBlock(a, d),
    ],
  ));

  // 4) Anlage DSGVO.
  doc.addPage(pw.Page(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.fromLTRB(48, 44, 48, 44),
    build: (ctx) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Anlage: DSGVO',
            style: pw.TextStyle(font: a.bodyBold, fontSize: 12, color: _ink)),
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
                textAlign: pw.TextAlign.justify,
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

  return doc.save();
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
        textAlign: pw.TextAlign.justify,
        style: pw.TextStyle(
            font: a.body, fontSize: 9.5, color: _ink, lineSpacing: 1.6),
      ),
      pw.SizedBox(height: 8),
      for (var i = 0; i < clauses.length; i++) _clause(a, i + 1, clauses[i]),
      pw.SizedBox(height: 26),
      _signatureBlock(a, d),
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
        textAlign: pw.TextAlign.justify,
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
                textAlign: pw.TextAlign.justify,
                style: pw.TextStyle(
                    font: a.body,
                    fontSize: 9.5,
                    color: _ink,
                    lineSpacing: 1.6)),
          ),
      ],
      pw.SizedBox(height: 26),
      pw.Text('Erhalten am:',
          style: pw.TextStyle(font: a.bodyBold, fontSize: 10, color: _ink)),
      pw.SizedBox(height: 22),
      pw.Row(children: [
        pw.Expanded(child: _fieldLine(a, '', 'Datum')),
        pw.SizedBox(width: 24),
        pw.Expanded(
            child:
                _fieldLine(a, d.employeeName, 'Name in Druckbuchstaben')),
      ]),
      pw.SizedBox(height: 26),
      pw.SizedBox(
          width: 220, child: _fieldLine(a, '', 'Unterschrift Arbeitnehmer')),
    ],
  ));
  return doc.save();
}

// ── EzB: Erklärung zum Beschäftigungsverhältnis (Visum) ─────────────────

Future<Uint8List> wcBuildEzbPdf(WorkContractData d, WcAssets a) async {
  final doc = pw.Document();

  pw.Widget label(String t) => pw.Padding(
        padding: const pw.EdgeInsets.only(top: 7, bottom: 2),
        child: pw.Text(t,
            style: pw.TextStyle(font: a.bodyBold, fontSize: 8.5, color: _ink)),
      );
  pw.Widget value(String t) => pw.Text(t.isEmpty ? '—' : t,
      style: pw.TextStyle(font: a.body, fontSize: 9.5, color: _ink));
  pw.Widget head(String t) => pw.Padding(
        padding: const pw.EdgeInsets.only(top: 12, bottom: 4),
        child: pw.Container(
          width: double.infinity,
          color: PdfColor.fromInt(0xFFEDEFF2),
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          child: pw.Text(t,
              style:
                  pw.TextStyle(font: a.bodyBold, fontSize: 10, color: _ink)),
        ),
      );
  pw.Widget check(bool on, String t) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 3),
        child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Container(
            width: 9,
            height: 9,
            margin: const pw.EdgeInsets.only(top: 1),
            decoration: pw.BoxDecoration(
                border: pw.Border.all(color: _ink, width: 0.9)),
            alignment: pw.Alignment.center,
            child: on
                ? pw.Text('X',
                    style: pw.TextStyle(
                        font: a.bodyBold, fontSize: 7, color: _ink))
                : null,
          ),
          pw.SizedBox(width: 5),
          pw.Expanded(
            child: pw.Text(t,
                style: pw.TextStyle(font: a.body, fontSize: 9, color: _ink)),
          ),
        ]),
      );

  final salaryLine = d.pay == WcPay.monthly
      ? 'pro Monat: ${wcEur(d.monthlySalary)} EUR (brutto)'
      : 'pro Stunde: ${wcEur(d.hourlyWage)} EUR (brutto)';

  doc.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.fromLTRB(44, 40, 44, 40),
    footer: (ctx) => pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text('nach Vorlage EzB - 02/2024',
            style: pw.TextStyle(font: a.body, fontSize: 8, color: _grey)),
        pw.Text('Seite ${ctx.pageNumber}',
            style: pw.TextStyle(font: a.body, fontSize: 8, color: _grey)),
      ],
    ),
    build: (ctx) => [
      pw.Text('Erklärung zum Beschäftigungsverhältnis',
          style: pw.TextStyle(font: a.display, fontSize: 16, color: _ink)),
      pw.Text('Bei Arbeitskräften aus Drittstaaten auszufüllen',
          style: pw.TextStyle(font: a.body, fontSize: 9.5, color: _grey)),
      pw.SizedBox(height: 8),
      pw.Container(
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
            border: pw.Border.all(color: _line, width: 0.8)),
        child: pw.Text(
          'Hinweis: Das Formular dient zur Vorlage bei der zuständigen '
          'Auslandsvertretung oder Ausländerbehörde zur Beantragung eines '
          'Aufenthaltstitels zum Zweck der Beschäftigung bzw. zur Vorlage '
          'bei der Bundesagentur für Arbeit für die Beantragung einer '
          'Vorabzustimmung oder Arbeitserlaubnis. Mit dieser Erklärung '
          'bestätigt der Arbeitgeber verbindlich, dass er dem/der unter '
          '„Abschnitt B“ genannten ausländischen Arbeitnehmer/in einen '
          'konkreten Arbeitsplatz anbietet (§ 18 Abs. 2 Nr. 1 AufenthG) '
          'und dass die Beschäftigung tatsächlich ausgeübt werden soll '
          '(§ 18 Abs. 2 Nr. 4a AufenthG).',
          textAlign: pw.TextAlign.justify,
          style: pw.TextStyle(font: a.body, fontSize: 8.5, color: _ink),
        ),
      ),
      head('A. Erklärung und Anlass'),
      label('1  Erklärung zum Beschäftigungsverhältnis zur Vorlage in '
          'folgendem Verfahren:'),
      check(d.ezbProcedure == 'aufenthaltstitel',
          'zur Erteilung eines Aufenthaltstitels zum Zweck der Beschäftigung'),
      check(d.ezbProcedure == 'vorabzustimmung',
          'zur Erteilung einer Vorabzustimmung der Bundesagentur für Arbeit'),
      check(d.ezbProcedure == 'arbeitserlaubnis',
          'zur Erteilung einer Arbeitserlaubnis der Bundesagentur für Arbeit'),
      label('2  Anlass der Vorlage der Erklärung:'),
      pw.Row(children: [
        pw.Expanded(
            child: check(d.ezbOccasion == 'ersterteilung', 'Ersterteilung')),
        pw.Expanded(
            child: check(d.ezbOccasion == 'verlaengerung', 'Verlängerung')),
        pw.Expanded(
            child:
                check(d.ezbOccasion == 'wechsel', 'Arbeitgeberwechsel')),
      ]),
      head('B. Angaben zur Arbeitnehmerin/zum Arbeitnehmer'),
      label('3/4  Vorname(n), Nachname'),
      value(d.employeeName),
      label('5  Geburtsdatum'),
      value(wcDate(d.birthDate)),
      label('6  Geschlecht'),
      pw.Row(children: [
        pw.Expanded(child: check(d.gender == 'm', 'männlich')),
        pw.Expanded(child: check(d.gender == 'w', 'weiblich')),
        pw.Expanded(child: check(d.gender == 'd', 'divers')),
      ]),
      label('7  Staatsangehörigkeit'),
      value(d.nationality),
      label('8  Derzeitiger Wohnsitz oder gewöhnlicher Aufenthaltsort'),
      value('${d.employeeStreet}, ${d.employeeZipCity}'),
      label('9  Seit wann besteht der Wohnsitz/gewöhnliche Aufenthaltsort?'),
      value(wcDate(d.residenceSince)),
      head('C. Angaben zum Arbeitgeber'),
      label('10  Firma'),
      value(WcEmployer.name),
      label('11–14  Anschrift'),
      value('${WcEmployer.street}, ${WcEmployer.zipCity}'),
      pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Expanded(
          child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                label('15  Kontaktperson'),
                value(WcEmployer.managingDirector),
              ]),
        ),
        pw.Expanded(
          child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                label('16  Telefon'),
                value(WcEmployer.contactPhone),
              ]),
        ),
      ]),
      label('17  E-Mail'),
      value(WcEmployer.email),
      label('19  Betriebsnummer des Beschäftigungsbetriebes'),
      value(WcEmployer.betriebsnummer),
      label('20  Wurde das Unternehmen in den letzten 24 Monaten gegründet?'),
      pw.Row(children: [
        pw.Expanded(child: check(false, 'Ja')),
        pw.Expanded(child: check(true, 'Nein')),
      ]),
      head('D. Angaben zur Beschäftigung'),
      label('21  Das Beschäftigungsverhältnis beginnt am'),
      value(wcDate(d.startDate)),
      label('22  Befristung des Beschäftigungsverhältnisses:'),
      pw.Row(children: [
        pw.Expanded(child: check(!d.fixedTerm, 'unbefristet')),
        pw.Expanded(
            child: check(d.fixedTerm,
                'befristet bis ${d.fixedTerm ? wcDate(d.endDate) : ''}')),
      ]),
      label('23  Soll die Arbeitnehmerin/der Arbeitnehmer an Dritte '
          'überlassen werden?'),
      pw.Row(children: [
        pw.Expanded(child: check(false, 'Ja')),
        pw.Expanded(child: check(true, 'Nein')),
      ]),
      label('24  Angaben zum Arbeitsort:'),
      check(true,
          'Arbeitnehmerin oder Arbeitnehmer wird an wechselnden '
          'Arbeits-/Einsatzorten beschäftigt'),
      label('25  Berufsbezeichnung und Beschreibung der Tätigkeit'),
      value('Berufsbezeichnung: Kurierfahrer/Paketzusteller. Beschreibung: '
          'Auslieferung und Zustellung von Waren und Gebrauchsgütern '
          '(Pakete) nach einer vorgeplanten Route; Be- und Entladen der '
          'Fahrzeuge; Fahrzeugpflege.'),
      head('E. Angaben zur Qualifikation'),
      check(true,
          'Nach meiner Kenntnis setzt die Tätigkeit keine qualifizierte '
          'Berufsausbildung (reguläre Ausbildungsdauer mindestens zwei '
          'Jahre) und keinen Hochschulabschluss voraus; zum Beispiel weil '
          'es sich um eine Helfertätigkeit oder Anlerntätigkeit handelt '
          'oder weil die Beschäftigung aufgrund einer bestimmten Vorschrift '
          'der Beschäftigungsverordnung erfolgen soll, nach der eine '
          'bestimmte Qualifikation nicht erforderlich ist.'),
      head('F. Angaben zur Berufsausübungserlaubnis'),
      label('35  Ist die Berufsausübung an eine bestimmte Qualifikation '
          'beziehungsweise eine Erlaubnis gebunden?'),
      pw.Row(children: [
        pw.Expanded(child: check(false, 'Ja')),
        pw.Expanded(child: check(true, 'Nein (weiter mit Abschnitt G.)')),
      ]),
      head('G. Angaben zur Arbeitszeit'),
      label('37  Welche Arbeitszeit hat die Arbeitnehmerin/der '
          'Arbeitnehmer?'),
      pw.Row(children: [
        pw.Expanded(child: check(true, 'Vollzeit')),
        pw.Expanded(child: check(false, 'Teilzeit')),
        pw.Expanded(child: check(false, 'Geringfügige Beschäftigung')),
      ]),
      value('Arbeitsstunden pro Woche: ${wcHours(d.hoursPerWeek)}'),
      head('H. Überstunden'),
      label('38  Ist die Arbeitnehmerin/der Arbeitnehmer verpflichtet, '
          'Überstunden zu leisten?'),
      pw.Row(children: [
        pw.Expanded(child: check(true, 'Ja')),
        pw.Expanded(child: check(false, 'Nein')),
      ]),
      label('39/40  Überstundenumfang / Ausgleich'),
      value('Im gesetzlich zulässigen Rahmen; Ausgleich durch Freizeit oder '
          'Vergütung (Arbeitszeitkonto).'),
      head('I. Urlaubsanspruch'),
      label('41  Auf wie viele Arbeitstage je Urlaubsjahr besteht '
          'Anspruch?'),
      value('${d.vacationDays}'),
      head('J. Arbeitsentgelt'),
      label('42  Ist der Arbeitgeber tarifgebunden (§ 3 oder § 5 TVG)?'),
      pw.Row(children: [
        pw.Expanded(child: check(false, 'Ja')),
        pw.Expanded(child: check(true, 'Nein (weiter mit 46)')),
      ]),
      label('46  Höhe und Berechnungsart des Arbeitsentgelts:'),
      value(salaryLine),
      head('K. Inländisches Beschäftigungsverhältnis'),
      label('52  Besteht für den Arbeitnehmer/die Arbeitnehmerin '
          'Sozialversicherungspflicht in Deutschland?'),
      pw.Row(children: [
        pw.Expanded(child: check(true, 'Ja (weiter mit 54)')),
        pw.Expanded(child: check(false, 'Nein')),
      ]),
      head('L. Unterschrift'),
      pw.Text(
        'Alle Angaben in diesem Formular entsprechen dem Inhalt des '
        'Arbeitsvertrages, der zwischen dem bezeichneten Unternehmen und '
        'dem/der Antragsteller/in geschlossen wird. Mir ist bekannt, dass '
        'dieses Formular an Dritte (Kommune, Gemeinsame Einrichtung nach '
        'SGB II) zur Suche nach bevorrechtigten Bewerbern weitergegeben '
        'werden kann, falls eine Vorrangprüfung durchgeführt wird. Die '
        'datenschutzrechtlichen Hinweise der Bundesagentur für Arbeit '
        'finden Sie unter: www.arbeitsagentur.de/datenerhebung. Die '
        'Richtigkeit der Angaben wird durch Datum und Unterschrift '
        'bestätigt.',
        textAlign: pw.TextAlign.justify,
        style: pw.TextStyle(font: a.body, fontSize: 8.5, color: _ink),
      ),
      pw.SizedBox(height: 16),
      pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
        pw.Expanded(child: _fieldLine(a, d.signCity, '57  Ort')),
        pw.SizedBox(width: 16),
        pw.Expanded(child: _fieldLine(a, wcDate(d.signDate), '58  Datum')),
        pw.SizedBox(width: 16),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                height: 40,
                alignment: pw.Alignment.bottomLeft,
                child: a.signature == null
                    ? pw.SizedBox()
                    : pw.Image(a.signature!,
                        height: 40, fit: pw.BoxFit.contain),
              ),
              pw.Container(height: 0.8, color: _line),
              pw.SizedBox(height: 2),
              pw.Text('59  UNTERSCHRIFT ARBEITGEBER',
                  style: pw.TextStyle(
                      font: a.bodyBold, fontSize: 6.5, color: _grey)),
            ],
          ),
        ),
      ]),
    ],
  ));

  // Zusatzblatt: Bestätigung Führerschein Kategorie B (wie bisher bei
  // Visa-Anträgen beigelegt).
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
          textAlign: pw.TextAlign.justify,
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
          textAlign: pw.TextAlign.justify,
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
