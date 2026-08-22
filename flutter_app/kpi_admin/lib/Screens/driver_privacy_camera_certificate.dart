// lib/Screens/driver_privacy_camera_certificate.dart
//
// Bescheinigung über Aushändigung und Kenntnisnahme der
// Datenschutzerklärung zur Verkehrssicherheitstechnologie.
//
// WICHTIG — das ist KEIN Test-/Bestehens-Zertifikat und KEINE
// Einwilligung. Auf dem Dokument steht deshalb bewusst
//   - kein „Bestanden", kein Punktestand, kein Testergebnis,
//   - dafür der Klarstellungssatz aus Spec §7: die Bestätigung ist keine
//     Einwilligung, der Widerspruch ist jederzeit und ohne Begründung
//     möglich.
//
// Layout übernommen aus driver_privacy_training_page.dart /
// driver_safety_training_page.dart (Urkundenrahmen, Siegel, Kopf- und
// Fußzeile), damit die Nachweise im Drivers Hub einheitlich aussehen.

import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

const PdfColor _certGrey = PdfColor.fromInt(0xFF6B7280);
const PdfColor _certDark = PdfColor.fromInt(0xFF111827);
const PdfColor _certAccent = PdfColor.fromInt(0xFF2A5FB0);

/// Ersetzt Zeichen außerhalb von Latin-1 — die PDF-Standardschrift
/// stellt sie sonst als leere Kästchen dar.
String _pdfSafe(String input) {
  const map = <String, String>{
    '\u2013': '-',
    '\u2014': '-',
    '\u2018': "'",
    '\u2019': "'",
    '\u201C': '"',
    '\u201D': '"',
    '\u201E': '"',
    '\u2026': '...',
    '\u00A0': ' ',
    '\u202F': ' ',
    '\u20AC': 'EUR',
    '\u2192': '->',
    '\u2022': '-',
    '\u2713': 'x',
  };
  var out = input;
  map.forEach((k, v) => out = out.replaceAll(k, v));
  return out.replaceAll(RegExp(r'[^\u0000-\u00FF]'), '');
}

pw.Widget _certKv(String label, String value) => pw.Container(
  decoration: const pw.BoxDecoration(
    border: pw.Border(
      bottom: pw.BorderSide(color: PdfColor.fromInt(0xFFECEEF2), width: 0.6),
    ),
  ),
  padding: const pw.EdgeInsets.symmetric(vertical: 5),
  child: pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.SizedBox(
        width: 175,
        child: pw.Text(
          _pdfSafe(label),
          style: const pw.TextStyle(fontSize: 10, color: _certGrey),
        ),
      ),
      pw.Expanded(
        child: pw.Text(
          _pdfSafe(value),
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: _certDark,
          ),
        ),
      ),
    ],
  ),
);

pw.Widget _certHeader(
  String title,
  String subtitle,
  String nr, {
  double titleSize = 13.5,
}) => pw.Column(
  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
  children: [
    pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.RichText(
          text: pw.TextSpan(
            children: [
              pw.TextSpan(
                text: 'CoDriver',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: _certAccent,
                ),
              ),
              const pw.TextSpan(
                text: '  ·  DA Academy',
                style: pw.TextStyle(fontSize: 10, color: _certGrey),
              ),
            ],
          ),
        ),
        pw.Text(
          'Nachweis-Nr. $nr',
          style: const pw.TextStyle(fontSize: 9, color: _certGrey),
        ),
      ],
    ),
    pw.SizedBox(height: 8),
    pw.Container(height: 0.8, color: const PdfColor.fromInt(0xFFE1E4EA)),
    pw.SizedBox(height: 24),
    pw.Text(
      _pdfSafe(title),
      textAlign: pw.TextAlign.center,
      style: pw.TextStyle(
        fontSize: titleSize,
        fontWeight: pw.FontWeight.bold,
        color: _certDark,
        letterSpacing: 1.8,
      ),
    ),
    pw.SizedBox(height: 7),
    pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 26),
      child: pw.Text(
        _pdfSafe(subtitle),
        textAlign: pw.TextAlign.center,
        style: const pw.TextStyle(
          fontSize: 9,
          color: _certGrey,
          lineSpacing: 1.4,
        ),
      ),
    ),
    pw.SizedBox(height: 12),
    pw.Center(child: pw.Container(width: 76, height: 2.4, color: _certAccent)),
    pw.SizedBox(height: 18),
  ],
);

pw.Widget _certSeal(String line1, String line2, String dateText) => pw.Container(
  width: 86,
  height: 86,
  decoration: pw.BoxDecoration(
    shape: pw.BoxShape.circle,
    border: pw.Border.all(color: _certAccent, width: 1.6),
  ),
  child: pw.Container(
    margin: const pw.EdgeInsets.all(3.5),
    decoration: pw.BoxDecoration(
      shape: pw.BoxShape.circle,
      border: pw.Border.all(color: _certAccent, width: 0.6),
    ),
    child: pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        pw.Text(
          line1,
          style: pw.TextStyle(
            fontSize: 9.5,
            fontWeight: pw.FontWeight.bold,
            color: _certAccent,
            letterSpacing: 0.6,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          line2,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            fontSize: 6.4,
            fontWeight: pw.FontWeight.bold,
            color: _certAccent,
            letterSpacing: 0.8,
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Container(width: 30, height: 0.7, color: _certAccent),
        pw.SizedBox(height: 3),
        pw.Text(
          dateText,
          style: const pw.TextStyle(fontSize: 7, color: _certGrey),
        ),
      ],
    ),
  ),
);

pw.Widget _certFrame(pw.Widget child) => pw.Container(
  decoration: pw.BoxDecoration(border: pw.Border.all(color: _certAccent, width: 1.4)),
  padding: const pw.EdgeInsets.all(4),
  child: pw.Container(
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: const PdfColor.fromInt(0xFFD5DAE2), width: 0.7),
    ),
    padding: const pw.EdgeInsets.fromLTRB(34, 24, 34, 20),
    child: child,
  ),
);

pw.Widget _certTopicList(List<String> topics) => pw.Wrap(
  spacing: 12,
  runSpacing: 3,
  children: [
    for (final topic in topics)
      pw.SizedBox(
        width: 224,
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              margin: const pw.EdgeInsets.only(top: 2),
              width: 7,
              height: 7,
              decoration: pw.BoxDecoration(
                color: _certAccent,
                borderRadius: pw.BorderRadius.circular(2),
              ),
            ),
            pw.SizedBox(width: 5),
            pw.Expanded(
              child: pw.Text(
                _pdfSafe(topic),
                style: const pw.TextStyle(fontSize: 9, color: _certDark),
              ),
            ),
          ],
        ),
      ),
  ],
);

pw.Widget _certLegalBox(String text) => pw.Container(
  width: double.infinity,
  padding: const pw.EdgeInsets.all(10),
  decoration: pw.BoxDecoration(
    color: const PdfColor.fromInt(0xFFF8FAFC),
    borderRadius: pw.BorderRadius.circular(8),
    border: pw.Border.all(color: const PdfColor.fromInt(0xFFE5E7EB)),
  ),
  child: pw.Text(
    _pdfSafe(text),
    style: const pw.TextStyle(fontSize: 8, color: _certGrey, lineSpacing: 1.6),
  ),
);

/// Unterschriftenzeile.
///
/// Die Unterschrift ist im Fahrer-Flow VERPFLICHTEND — ohne sie lässt
/// sich nicht bestätigen, es entsteht also auch keine Bescheinigung.
/// [sig] bleibt trotzdem nullable: Sollte der PNG-Export einmal
/// fehlschlagen, wird die Bescheinigung lieber mit einem sachlichen
/// Vermerk erstellt als gar nicht.
pw.Widget _certSignatures({
  required pw.MemoryImage? sig,
  required String leftText,
  required String rightText,
  required pw.Widget sealWidget,
}) => pw.Row(
  crossAxisAlignment: pw.CrossAxisAlignment.end,
  children: [
    sealWidget,
    pw.SizedBox(width: 26),
    pw.Expanded(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(height: 58),
          pw.Container(
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(color: _certGrey, width: 0.8),
              ),
            ),
            padding: const pw.EdgeInsets.only(top: 4),
            child: pw.Text(
              _pdfSafe(leftText),
              style: const pw.TextStyle(fontSize: 8, color: _certGrey),
            ),
          ),
        ],
      ),
    ),
    pw.SizedBox(width: 26),
    pw.Expanded(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            height: 54,
            alignment: pw.Alignment.bottomLeft,
            child: sig == null
                ? pw.Text(
                    _pdfSafe(
                      'Kenntnisnahme in der App bestätigt\n'
                      '(Unterschriftsbild nicht verfügbar)',
                    ),
                    style: const pw.TextStyle(fontSize: 8, color: _certGrey),
                  )
                : pw.Image(sig, height: 50, fit: pw.BoxFit.contain),
          ),
          pw.Container(
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(color: _certGrey, width: 0.8),
              ),
            ),
            padding: const pw.EdgeInsets.only(top: 4),
            child: pw.Text(
              _pdfSafe(rightText),
              style: const pw.TextStyle(fontSize: 8, color: _certGrey),
            ),
          ),
        ],
      ),
    ),
  ],
);

pw.Widget _certFooter(String text) => pw.Column(
  children: [
    pw.SizedBox(height: 12),
    pw.Container(height: 0.8, color: const PdfColor.fromInt(0xFFE1E4EA)),
    pw.SizedBox(height: 6),
    pw.Center(
      child: pw.Text(
        _pdfSafe(text),
        style: const pw.TextStyle(fontSize: 7.5, color: _certGrey),
      ),
    ),
  ],
);

/// Baut die Bescheinigung. Wird ausschließlich bei
/// `outcome == acknowledged` erzeugt — bei einer Verweigerung entsteht
/// nach Spec §7 nur der Vermerk in der Admin-Ansicht, kein Dokument.
Future<Uint8List> buildPrivacyCameraCertificatePdf({
  required Uint8List? signaturePng,
  required String driverName,
  required String employeeNumber,
  required String companyName,
  required DateTime occurredAt,
  required String documentTitle,
  required String documentVersion,
  required String contentSha256,
  required List<String> moduleTitles,
  // Verbindlicher deutscher Wortlaut (Spec §7) — steht IMMER auf der
  // Bescheinigung, unabhängig von der Sprache des Fahrers.
  //
  // Die Bescheinigung ist bewusst EINSPRACHIG deutsch: sie ist das
  // Nachweisdokument gegenüber der Aufsichtsbehörde, und dafür zählt der
  // verbindliche Wortlaut. Die gelesene Übersetzung wird weiterhin im
  // Nachweis-Dokument (`statementShownLocalized`) gespeichert, aber nicht
  // mitgedruckt. Zweisprachig bleibt allein der Bestätigungs-Screen.
  required String statementShown,
  required String clarification,
}) async {
  final doc = pw.Document();
  final sigImage = signaturePng == null ? null : pw.MemoryImage(signaturePng);
  final dateText = DateFormat('dd.MM.yyyy').format(occurredAt);
  final nr = occurredAt.millisecondsSinceEpoch.toString();

  final body = pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      _certHeader(
        'EMPFANGS- UND KENNTNISNAHMEBESTÄTIGUNG',
        'Bescheinigung über Aushändigung und Kenntnisnahme der '
            'Datenschutzerklärung für den Einsatz von '
            'Verkehrssicherheitstechnologien und Fahrsicherheitstools · '
            'Nachweis gemäß Art. 5 Abs. 2 DSGVO · keine Einwilligung',
        nr,
      ),
      _certKv('Unternehmen', companyName.isEmpty ? '-' : companyName),
      _certKv('Fahrer / Empfänger', driverName),
      if (employeeNumber.isNotEmpty) _certKv('Personalnummer', employeeNumber),
      _certKv('Datum der Aushändigung und Kenntnisnahme', dateText),
      _certKv('Ausgehändigtes Dokument', documentTitle),
      _certKv('Fassung', documentVersion),
      _certKv('Prüfsumme des Wortlauts (SHA-256)', contentSha256),
      _certKv(
        'Form der Aushändigung',
        'Digitale Aushändigung in der CoDriver DA Academy, mit Lektüre des '
            'Volltextes',
      ),
      pw.SizedBox(height: 10),
      pw.Text(
        'Inhalt der Information',
        style: pw.TextStyle(
          fontSize: 11,
          fontWeight: pw.FontWeight.bold,
          color: _certDark,
        ),
      ),
      pw.SizedBox(height: 5),
      _certTopicList(moduleTitles),
      pw.SizedBox(height: 11),
      // Verbindlicher Wortlaut aus Spec §7 — unverändert übernommen und
      // ausschließlich auf Deutsch.
      _certLegalBox(
        '$statementShown\n\n'
        '$clarification\n\n'
        'Diese Bescheinigung belegt ausschließlich die Aushändigung und '
        'Kenntnisnahme der genannten Datenschutzerklärung. Sie ist weder ein '
        'Prüfungs- oder Schulungszertifikat noch eine Einwilligung in die '
        'Datenverarbeitung. Die Verarbeitung stützt sich auf Art. 6 Abs. 1 '
        'lit. f DSGVO (berechtigtes Interesse). Der Nachweis wird nach '
        'Art. 5 Abs. 2 DSGVO für die Dauer des Beschäftigungsverhältnisses '
        'zuzüglich drei Jahren aufbewahrt und danach gelöscht.',
      ),
      pw.Spacer(),
      _certSignatures(
        sig: sigImage,
        sealWidget: _certSeal(
          'CoDriver',
          'DA ACADEMY\nDIGITAL SIGNIERT',
          dateText,
        ),
        leftText:
            'Ort, Datum | Aushändigung durch'
            '${companyName.isEmpty ? '' : ' | $companyName'}',
        rightText:
            '$dateText | Unterschrift Fahrer - bestätigt nur Erhalt und '
            'Kenntnisnahme, keine Einwilligung\n$driverName',
      ),
      _certFooter(
        'Digital erstellt über CoDriver DA Academy · Empfangsbestätigung '
        'nach Art. 5 Abs. 2 DSGVO · kein Einwilligungsnachweis',
      ),
    ],
  );

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(24),
      build: (ctx) => _certFrame(body),
    ),
  );

  return doc.save();
}
