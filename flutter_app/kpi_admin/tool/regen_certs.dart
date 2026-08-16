// Regeneriert bestehende Nachweis-PDFs im neuen, schlichten Design.
//
// Liest /tmp/regen/jobs.json (erzeugt per Node-Skript aus Firestore),
// nimmt je Job die aus dem alten PDF extrahierte Unterschrift
// (/tmp/regen/sig/{idx}.png) und schreibt /tmp/regen/new/{idx}.pdf.
//
// Layout je Typ identisch zu den aktuellen Buildern in
// driver_safety_training_page.dart / driver_privacy_training_page.dart
// bzw. — für die Kenntnisnahmen — deren neuer, badge-freier Stil:
// weißer Grund, dunkler Titel, graue Rechtsgrundlage, feine Akzentlinie,
// keine Pillen/„BESTANDEN"-Badges, kein Testergebnis, keine
// Transporter-ID.
//
// Aufruf: dart run tool/regen_certs.dart
import 'dart:convert';
import 'dart:io';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

const grey = PdfColor.fromInt(0xFF6B7280);
const dark = PdfColor.fromInt(0xFF111827);

String _pdfSafe(String input) {
  const map = {
    '–': '-', '—': '-', '‘': "'", '’': "'",
    '“': '"', '”': '"', '„': '"', '…': '...',
    ' ': ' ', ' ': ' ', '€': 'EUR', '→': '->',
    '•': '-', '✓': 'x',
  };
  var out = input;
  map.forEach((k, v) => out = out.replaceAll(k, v));
  return out.replaceAll(RegExp(r'[^\x00-\xff]'), '');
}

String _fmt(String? iso) {
  if (iso == null || iso.isEmpty) return '-';
  final d = DateTime.parse(iso).toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}.${two(d.month)}.${d.year}';
}

pw.Widget kv(String label, String value) => pw.Container(
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
            width: 165,
            child: pw.Text(_pdfSafe(label),
                style: const pw.TextStyle(fontSize: 10, color: grey)),
          ),
          pw.Expanded(
            child: pw.Text(_pdfSafe(value),
                style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: dark)),
          ),
        ],
      ),
    );

/// Briefkopf + zentrierter Titelblock im Urkunden-Stil.
pw.Widget header(String title, String subtitle, PdfColor accent, String nr,
        {double titleSize = 19}) =>
    pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: [
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.RichText(
            text: pw.TextSpan(children: [
              pw.TextSpan(
                  text: 'CoDriver',
                  style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: accent)),
              const pw.TextSpan(
                  text: '  ·  DA Academy',
                  style: pw.TextStyle(fontSize: 10, color: grey)),
            ]),
          ),
          pw.Text('Nachweis-Nr. $nr',
              style: const pw.TextStyle(fontSize: 9, color: grey)),
        ],
      ),
      pw.SizedBox(height: 8),
      pw.Container(height: 0.8, color: const PdfColor.fromInt(0xFFE1E4EA)),
      pw.SizedBox(height: 26),
      pw.Text(_pdfSafe(title),
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
              fontSize: titleSize,
              fontWeight: pw.FontWeight.bold,
              color: dark,
              letterSpacing: 2.2)),
      pw.SizedBox(height: 7),
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 40),
        child: pw.Text(_pdfSafe(subtitle),
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(
                fontSize: 9.5, color: grey, lineSpacing: 1.4)),
      ),
      pw.SizedBox(height: 14),
      pw.Center(child: pw.Container(width: 76, height: 2.4, color: accent)),
      pw.SizedBox(height: 22),
    ]);

/// Rundes „digital signiert"-Siegel im Prüfsiegel-Stil.
pw.Widget seal(PdfColor accent, String line1, String line2, String dateText) =>
    pw.Container(
      width: 86,
      height: 86,
      decoration: pw.BoxDecoration(
        shape: pw.BoxShape.circle,
        border: pw.Border.all(color: accent, width: 1.6),
      ),
      child: pw.Container(
        margin: const pw.EdgeInsets.all(3.5),
        decoration: pw.BoxDecoration(
          shape: pw.BoxShape.circle,
          border: pw.Border.all(color: accent, width: 0.6),
        ),
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text(line1,
                style: pw.TextStyle(
                    fontSize: 9.5,
                    fontWeight: pw.FontWeight.bold,
                    color: accent,
                    letterSpacing: 0.6)),
            pw.SizedBox(height: 2),
            pw.Text(line2,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                    fontSize: 6.4,
                    fontWeight: pw.FontWeight.bold,
                    color: accent,
                    letterSpacing: 0.8)),
            pw.SizedBox(height: 3),
            pw.Container(width: 30, height: 0.7, color: accent),
            pw.SizedBox(height: 3),
            pw.Text(dateText,
                style: const pw.TextStyle(fontSize: 7, color: grey)),
          ],
        ),
      ),
    );

/// Doppelter Urkundenrahmen um den Seiteninhalt.
pw.Widget certFrame(PdfColor accent, pw.Widget child) => pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: accent, width: 1.4),
      ),
      padding: const pw.EdgeInsets.all(4),
      child: pw.Container(
        decoration: pw.BoxDecoration(
          border:
              pw.Border.all(color: const PdfColor.fromInt(0xFFD5DAE2), width: 0.7),
        ),
        padding: const pw.EdgeInsets.fromLTRB(34, 26, 34, 22),
        child: child,
      ),
    );

pw.Widget topicList(List<String> topics, PdfColor accent) => pw.Wrap(
      spacing: 12,
      runSpacing: 3,
      children: [
        for (final topic in topics)
          pw.SizedBox(
            width: 224,
            child:
                pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Container(
                  margin: const pw.EdgeInsets.only(top: 2),
                  width: 7,
                  height: 7,
                  decoration: pw.BoxDecoration(
                      color: accent, borderRadius: pw.BorderRadius.circular(2))),
              pw.SizedBox(width: 5),
              pw.Expanded(
                  child: pw.Text(_pdfSafe(topic),
                      style: const pw.TextStyle(fontSize: 9, color: dark))),
            ]),
          ),
      ],
    );

pw.Widget legalBox(String text) => pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFF8FAFC),
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: const PdfColor.fromInt(0xFFE5E7EB)),
      ),
      child: pw.Text(_pdfSafe(text),
          style: const pw.TextStyle(fontSize: 8, color: grey, lineSpacing: 1.6)),
    );

pw.Widget signatures({
  required pw.MemoryImage sig,
  required String leftText,
  required String rightText,
  required pw.Widget sealWidget,
}) =>
    pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
      sealWidget,
      pw.SizedBox(width: 26),
      pw.Expanded(
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.SizedBox(height: 58),
          pw.Container(
            decoration: const pw.BoxDecoration(
                border: pw.Border(top: pw.BorderSide(color: grey, width: 0.8))),
            padding: const pw.EdgeInsets.only(top: 4),
            child: pw.Text(_pdfSafe(leftText),
                style: const pw.TextStyle(fontSize: 8, color: grey)),
          ),
        ]),
      ),
      pw.SizedBox(width: 26),
      pw.Expanded(
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Container(
              height: 54,
              alignment: pw.Alignment.bottomLeft,
              child: pw.Image(sig, height: 50, fit: pw.BoxFit.contain)),
          pw.Container(
            decoration: const pw.BoxDecoration(
                border: pw.Border(top: pw.BorderSide(color: grey, width: 0.8))),
            padding: const pw.EdgeInsets.only(top: 4),
            child: pw.Text(_pdfSafe(rightText),
                style: const pw.TextStyle(fontSize: 8, color: grey)),
          ),
        ]),
      ),
    ]);

pw.Widget footer(String text) => pw.Column(children: [
      pw.SizedBox(height: 14),
      pw.Container(height: 0.8, color: const PdfColor.fromInt(0xFFE1E4EA)),
      pw.SizedBox(height: 6),
      pw.Center(
        child: pw.Text(_pdfSafe(text),
            style: const pw.TextStyle(fontSize: 7.5, color: grey)),
      ),
    ]);

Future<void> main() async {
  final jobs =
      (jsonDecode(File('/tmp/regen/jobs.json').readAsStringSync()) as List)
          .cast<Map<String, dynamic>>();

  const safetyTopics = [
    'Rechtsgrundlagen & deine Pflichten',
    'Die 10 Regeln für sicheres Arbeiten',
    'Verhalten im Brandfall',
    'Sitzen & Bewegen',
    'Sicheres Fahren & Abfahrtkontrolle',
    'Die 3-Punkte-Regel',
    'Betriebsanweisungen',
    'Persönliche Schutzausrüstung (PSA)',
    'Erste Hilfe',
    'Belastung & Konzentration',
    'Pannen & Unfälle',
  ];
  const privacyTrainingTopics = [
    'Warum Datenschutz dich betrifft',
    'Fotos und Ablieferungsnachweise',
    'Umgang mit Empfängerdaten',
    'Deine eigenen Daten und die der Kollegen',
    'Wenn etwas schiefgeht — Datenpanne',
    'Verschwiegenheit und Loyalität',
  ];
  const noticeTopics = [
    'Wer deine Daten verarbeitet',
    'Deine Stammdaten',
    'Zeiterfassung und Standortprüfung',
    'DA Academy — Schulungen und Nachweise',
    'Deine Dokumente',
    'Abwesenheiten, Urlaub und Krankmeldungen',
    'Schicht- und Wellenplanung',
    'Leistungsdaten aus der Scorecard',
    'Wer deine Daten sieht',
    'Deine Rechte',
    'Was deine Bestätigung bedeutet',
  ];

  for (final j in jobs) {
    final idx = j['idx'];
    final type = j['type'] as String;
    final company = (j['company'] ?? '').toString();
    final name = (j['driverName'] ?? '').toString();
    final emp = (j['employeeNumber'] ?? '').toString();
    final sig = pw.MemoryImage(File('/tmp/regen/sig/$idx.png').readAsBytesSync());
    final doc = pw.Document();
    final nr = DateTime.parse(
            (j['passedAt'] ?? j['acknowledgedAt'] ?? j['uploadedAt']) as String)
        .millisecondsSinceEpoch
        .toString();

    late final pw.Widget body;
    if (type == 'safety_training_certificate') {
      const green = PdfColor.fromInt(0xFF1D7F5A);
      final dateText = _fmt(j['passedAt'] as String?);
      body = pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        header(
            'UNTERWEISUNGSNACHWEIS',
            'Sicherheitsunterweisung gemäß § 12 Abs. 1 Arbeitsschutzgesetz '
                '(ArbSchG) i. V. m. § 4 DGUV Vorschrift 1',
            green,
            nr),
        kv('Unternehmen', company.isEmpty ? '-' : company),
        kv('Unterweisender', 'Geschäftsführung $company'),
        kv('Mitarbeiter / Teilnehmer', name),
        if (emp.isNotEmpty) kv('Personalnummer', emp),
        kv('Datum der Unterweisung', dateText),
        kv('Form der Unterweisung',
            'Digitale Unterweisung mit Verständnistest (CoDriver DA Academy)'),
        kv('Gültig bis',
            '${_fmt(j['validUntil'] as String?)} (jährliche Wiederholung gem. § 12 ArbSchG / DGUV V1)'),
        pw.SizedBox(height: 10),
        pw.Text('Inhalt der Unterweisung',
            style: pw.TextStyle(
                fontSize: 11, fontWeight: pw.FontWeight.bold, color: dark)),
        pw.SizedBox(height: 5),
        topicList(safetyTopics, green),
        pw.SizedBox(height: 12),
        legalBox('Mit meiner Unterschrift bestätige ich, dass ich an der '
            'Unterweisung teilgenommen und den Inhalt verstanden habe. '
            'Ich hatte Gelegenheit, Fragen zu stellen. Die vorstehenden '
            'Daten werden im Rahmen der gesetzlich verpflichtenden '
            'Arbeitsschutz-Unterweisung erhoben und verarbeitet. '
            'Rechtsgrundlage hierfür ist Art. 6 Abs. 1 lit. c) und f) '
            'der Datenschutz-Grundverordnung (DSGVO). Die Daten werden '
            'so lange gespeichert, wie sie zur Erfüllung der '
            'Dokumentationspflicht sowie zum Nachweis der Durchführung '
            'benötigt werden, mindestens aber zwei Jahre bzw. bis zu '
            'einer folgenden Unterweisung.'),
        pw.Spacer(),
        signatures(
            sig: sig,
            sealWidget: seal(green, 'CoDriver', 'DA ACADEMY\nDIGITAL SIGNIERT',
                dateText),
            leftText: 'Ort, Datum | Unterschrift Unterweisender\n'
                'Geschäftsführung${company.isEmpty ? '' : ' | $company'}',
            rightText: '$dateText | Unterschrift Mitarbeiter\n$name'),
        footer('Digital erstellt und signiert über CoDriver DA Academy · '
            'Jährliche Unterweisung nach § 12 ArbSchG / DGUV Vorschrift 1'),
      ]);
    } else if (type == 'privacy_training_certificate') {
      const blue = PdfColor.fromInt(0xFF5C4B99);
      final dateText = _fmt(j['passedAt'] as String?);
      body = pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        header(
            'DATENSCHUTZ-SCHULUNGSNACHWEIS',
            'Datenschutzschulung nach Art. 32 DSGVO i. V. m. Art. 39 Abs. 1 '
                'lit. b DSGVO; Nachweis gemäß Art. 5 Abs. 2 DSGVO '
                '(Rechenschaftspflicht)',
            blue,
            nr,
            titleSize: 16),
        kv('Unternehmen', company.isEmpty ? '-' : company),
        kv('Schulungsverantwortlich', 'Geschäftsführung $company'),
        kv('Mitarbeiter / Teilnehmer', name),
        if (emp.isNotEmpty) kv('Personalnummer', emp),
        kv('Datum der Schulung', dateText),
        kv('Form der Schulung',
            'Digitale Schulung mit Verständnistest (CoDriver DA Academy)'),
        kv('Gültig bis',
            '${_fmt(j['validUntil'] as String?)} (jährliche Wiederholung empfohlen)'),
        pw.SizedBox(height: 10),
        pw.Text('Inhalt der Schulung',
            style: pw.TextStyle(
                fontSize: 11, fontWeight: pw.FontWeight.bold, color: dark)),
        pw.SizedBox(height: 5),
        topicList(privacyTrainingTopics, blue),
        pw.SizedBox(height: 12),
        legalBox('Mit meiner Unterschrift bestätige ich, dass ich an der '
            'Datenschutz-Schulung teilgenommen und den Inhalt verstanden '
            'habe. Ich hatte Gelegenheit, Fragen zu stellen. Ich '
            'verpflichte mich, personenbezogene Daten ausschließlich für '
            'dienstliche Zwecke zu verarbeiten, Verschwiegenheit zu wahren '
            'und jede Verletzung des Schutzes personenbezogener Daten '
            'unverzüglich zu melden. Die vorstehenden Daten werden zum '
            'Nachweis der Schulung nach Art. 5 Abs. 2 DSGVO erhoben und '
            'verarbeitet. Rechtsgrundlage ist Art. 6 Abs. 1 lit. c und f '
            'DSGVO. Die Daten werden so lange gespeichert, wie sie zum '
            'Nachweis der Durchführung benötigt werden, mindestens aber '
            'bis zu einer folgenden Schulung.'),
        pw.Spacer(),
        signatures(
            sig: sig,
            sealWidget: seal(blue, 'CoDriver', 'DA ACADEMY\nDIGITAL SIGNIERT',
                dateText),
            leftText: 'Ort, Datum | Unterschrift Schulungsverantwortlicher\n'
                'Geschäftsführung${company.isEmpty ? '' : ' | $company'}',
            rightText: '$dateText | Unterschrift Mitarbeiter\n$name'),
        footer('Digital erstellt und signiert über CoDriver DA Academy · '
            'Datenschutzschulung nach Art. 32, 39 DSGVO'),
      ]);
    } else {
      // privacy_notice_ack
      const blue = PdfColor.fromInt(0xFF1E3A8A);
      final dateText = _fmt((j['acknowledgedAt'] ?? j['uploadedAt']) as String?);
      final lang = (j['language'] ?? '').toString().toUpperCase();
      final version = (j['version'] ?? 1).toString();
      body = pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        header(
            'DATENSCHUTZINFORMATION — KENNTNISNAHME',
            'Information der beschäftigten Person nach Art. 13 DSGVO mit '
                'Bestätigung der Kenntnisnahme; Dokumentation gemäß Art. 5 '
                'Abs. 2 DSGVO (Rechenschaftspflicht)',
            blue,
            nr,
            titleSize: 15),
        kv('Verantwortlicher', company.isEmpty ? '-' : company),
        kv('Mitarbeiter / Betroffene Person', name),
        if (emp.isNotEmpty) kv('Personalnummer', emp),
        kv('Fassung der Information', 'Version $version (Stand 11.08.2026)'),
        kv('Datum der Kenntnisnahme', dateText),
        if (lang.isNotEmpty) kv('Sprache der Anzeige', lang),
        kv('Form',
            'Digitale Anzeige in CoDriver (Kurzinformation mit Zugang zum '
                'Volltext) mit Unterschrift'),
        pw.SizedBox(height: 10),
        pw.Text('Inhalt der Information',
            style: pw.TextStyle(
                fontSize: 11, fontWeight: pw.FontWeight.bold, color: dark)),
        pw.SizedBox(height: 5),
        topicList(noticeTopics, blue),
        pw.SizedBox(height: 12),
        legalBox('Mit meiner Unterschrift bestätige ich: Ich wurde nach '
            'Art. 13 DSGVO über die Verarbeitung meiner personenbezogenen '
            'Daten informiert. Mir wurde eine Kurzinformation angezeigt, '
            'die vollständige Information in der oben genannten Fassung '
            'war dabei jederzeit abrufbar und bleibt es auch weiterhin '
            '(gestuftes Hinweismodell nach Art. 12 Abs. 1 DSGVO). Ich habe '
            'die Datenschutzinformation gelesen und verstanden und hatte '
            'Gelegenheit, Fragen zu stellen. Diese Bestätigung '
            'dokumentiert ausschließlich die Kenntnisnahme; sie ist keine '
            'Erklärung, mit der ich eine Verarbeitung erlaube. Die '
            'Verarbeitung stützt sich auf Art. 6 Abs. 1 lit. b, c und f '
            'DSGVO in Verbindung mit § 26 BDSG. Meine Rechte nach Art. 15 '
            'bis 21 DSGVO sowie mein Beschwerderecht nach Art. 77 DSGVO '
            'bleiben davon unberührt. Diese Bestätigung wird zum Nachweis '
            'nach Art. 5 Abs. 2 DSGVO gespeichert.'),
        pw.Spacer(),
        signatures(
            sig: sig,
            sealWidget:
                seal(blue, 'CoDriver', 'ART. 13 DSGVO\nDIGITAL SIGNIERT', dateText),
            leftText: 'Ort, Datum | Unterschrift Verantwortlicher\n'
                'Geschäftsführung${company.isEmpty ? '' : ' | $company'}',
            rightText: '$dateText | Unterschrift Mitarbeiter\n$name'),
        footer('Digital erstellt und signiert über CoDriver · '
            'Kenntnisnahme nach Art. 13 DSGVO'),
      ]);
    }

    doc.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (ctx) => certFrame(
            type == 'safety_training_certificate'
                ? const PdfColor.fromInt(0xFF1D7F5A)
                : type == 'privacy_training_certificate'
                    ? const PdfColor.fromInt(0xFF5C4B99)
                    : const PdfColor.fromInt(0xFF1E3A8A),
            body)));

    File('/tmp/regen/new/$idx.pdf').writeAsBytesSync(await doc.save());
    stdout.writeln('ok $idx $type $name');
  }
}
