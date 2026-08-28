// lib/Screens/public_incident_view.dart
//
// Öffentliche, link-only Ansicht eines Unfall-/Vorfallberichts (Ticket
// "INCIDENT REPORT"). Rendert den Snapshot-Payload aus
// IncidentShareService (`type: 'incident'` in `public_plans/{shareId}`):
// Felder, Fotos, Anhänge — plus PDF-Download, alles ohne Login.

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class PublicIncidentView extends StatelessWidget {
  const PublicIncidentView({super.key, required this.data});

  final Map<String, dynamic> data;

  String _s(dynamic v) => (v ?? '').toString();

  List<Map<String, String>> get _rows {
    final raw = data['rows'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map(
          (e) => e.map((k, v) => MapEntry(k.toString(), (v ?? '').toString())),
        )
        .toList();
  }

  List<String> get _photos {
    final raw = data['photos'];
    if (raw is! List) return const [];
    return raw.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
  }

  List<Map<String, String>> get _attachments {
    final raw = data['attachments'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map(
          (e) => e.map((k, v) => MapEntry(k.toString(), (v ?? '').toString())),
        )
        .toList();
  }

  Future<void> _downloadPdf(bool de) async {
    final title = de ? _s(data['titleDe']) : _s(data['titleEn']);
    final subtitle = _s(data['subtitle']);
    final rows = _rows;

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (context) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF0B4A33),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'CoDriver — $title',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    subtitle,
                    style: const pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headers: null,
            data: [
              for (final r in rows)
                [
                  de ? (r['labelDe'] ?? '') : (r['labelEn'] ?? ''),
                  de ? (r['valueDe'] ?? '') : (r['valueEn'] ?? ''),
                ],
            ],
            columnWidths: {
              0: const pw.FixedColumnWidth(140),
              1: const pw.FlexColumnWidth(),
            },
            cellStyle: const pw.TextStyle(fontSize: 10),
            cellAlignment: pw.Alignment.topLeft,
            border: pw.TableBorder.all(
              color: PdfColor.fromInt(0xFFE5E7EB),
              width: 0.6,
            ),
            cellPadding: const pw.EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 6,
            ),
          ),
          pw.SizedBox(height: 14),
          pw.Text(
            de
                ? 'Erstellt mit CoDriver — dsp-codriver.de'
                : 'Created with CoDriver — dsp-codriver.de',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
        ],
      ),
    );

    final caseId = _s(data['caseId']);
    final suffix = caseId.length >= 6 ? caseId.substring(0, 6) : caseId;
    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: de ? 'unfallbericht-$suffix.pdf' : 'incident-report-$suffix.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final title = de ? _s(data['titleDe']) : _s(data['titleEn']);
    final subtitle = _s(data['subtitle']);
    final rows = _rows;
    final photos = _photos;
    final attachments = _attachments;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F7),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Kopfkarte ────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.codriverGreen, AppColors.codriverDeep],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CoDriver',
                        style: AppTypography.caption1.copyWith(
                          color: Colors.white.withOpacity(0.85),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: AppTypography.title2.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: AppTypography.subheadline.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FilledButton.icon(
                          onPressed: () => _downloadPdf(de),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.codriverDeep,
                          ),
                          icon: const Icon(Icons.download_rounded, size: 18),
                          label: Text(
                            de ? 'Als PDF herunterladen' : 'Download as PDF',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // ── Felder ───────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < rows.length; i++) ...[
                        if (i > 0)
                          const Divider(height: 18, color: Color(0xFFF1F5F9)),
                        _FieldRow(
                          label: de
                              ? (rows[i]['labelDe'] ?? '')
                              : (rows[i]['labelEn'] ?? ''),
                          value: de
                              ? (rows[i]['valueDe'] ?? '')
                              : (rows[i]['valueEn'] ?? ''),
                        ),
                      ],
                      if (rows.isEmpty)
                        Text(
                          de
                              ? 'Keine Angaben erfasst.'
                              : 'No details recorded.',
                          style: AppTypography.footnote.copyWith(
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                    ],
                  ),
                ),
                // ── Fotos ────────────────────────────────────────────
                if (photos.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          de
                              ? 'Fotos (${photos.length})'
                              : 'Photos (${photos.length})',
                          style: AppTypography.caption1.copyWith(
                            color: const Color(0xFF6B7280),
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final url in photos)
                              InkWell(
                                onTap: () => launchUrlString(url),
                                borderRadius: BorderRadius.circular(12),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    url,
                                    width: 148,
                                    height: 148,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 148,
                                      height: 148,
                                      color: const Color(0xFFF3F4F6),
                                      child: const Icon(
                                        Icons.broken_image_rounded,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                // ── Anhänge ──────────────────────────────────────────
                if (attachments.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          de
                              ? 'Anhänge (${attachments.length})'
                              : 'Attachments (${attachments.length})',
                          style: AppTypography.caption1.copyWith(
                            color: const Color(0xFF6B7280),
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        for (final a in attachments)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            leading: const Icon(
                              Icons.description_outlined,
                              color: AppColors.codriverDeep,
                            ),
                            title: Text(
                              (a['name'] ?? '').isEmpty
                                  ? (de ? 'Dokument' : 'Document')
                                  : a['name']!,
                              style: AppTypography.subheadline.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.open_in_new_rounded,
                              size: 18,
                              color: Color(0xFF6B7280),
                            ),
                            onTap: () => launchUrlString(a['url'] ?? ''),
                          ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    de
                        ? 'Bereitgestellt über CoDriver — nur für Empfänger dieses Links.'
                        : 'Provided via CoDriver — for recipients of this link only.',
                    textAlign: TextAlign.center,
                    style: AppTypography.caption2.copyWith(
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: Text(
            label,
            style: AppTypography.footnote.copyWith(
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SelectableText(
            value,
            style: AppTypography.subheadline.copyWith(
              color: const Color(0xFF111827),
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
