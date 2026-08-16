import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../config/app_config.dart';

class ParserApi {
  /// Cloud-Run-Cold-Starts brauchen ein paar Sekunden; ohne Limit hängt
  /// der blockierende Fortschrittsdialog sonst unbegrenzt.
  static const Duration _timeout = Duration(seconds: 120);

  static Never _timeoutError() => throw Exception(
        'Zeitüberschreitung beim Parser-Service. Bitte erneut versuchen.',
      );

  static Future<Map<String, dynamic>> parsePdf(
    Uint8List pdfBytes, {
    String filename = 'report.pdf',
  }) async {
    final uri = Uri.parse(AppConfig.parserUrl);

    final req = http.MultipartRequest('POST', uri)
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          pdfBytes,
          filename: filename,
          contentType: MediaType('application', 'pdf'),
        ),
      );

    final streamed =
        await req.send().timeout(_timeout, onTimeout: _timeoutError);
    final resp = await http.Response.fromStream(streamed)
        .timeout(_timeout, onTimeout: _timeoutError);

    if (resp.statusCode != 200) {
      throw Exception('Parser error ${resp.statusCode}: ${resp.body}');
    }
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> parseXlsx(
    Uint8List xlsxBytes, {
    String filename = 'report.xlsx',
  }) async {
    final uri = Uri.parse(AppConfig.parserUrl);

    final req = http.MultipartRequest('POST', uri)
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          xlsxBytes,
          filename: filename,
          contentType: MediaType(
            'application',
            'vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          ),
        ),
      );

    final streamed =
        await req.send().timeout(_timeout, onTimeout: _timeoutError);
    final resp = await http.Response.fromStream(streamed)
        .timeout(_timeout, onTimeout: _timeoutError);

    if (resp.statusCode != 200) {
      throw Exception('Parser error ${resp.statusCode}: ${resp.body}');
    }
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  /// Uploads an Amazon DSP weekly credit note (Gutschrift) PDF and returns
  /// the parsed `invoice` payload:
  /// `{ invoiceNumber, week, rangeStart, rangeEnd, total, lines: [...] }`.
  /// Throws if the service did not recognise the file as an invoice.
  static Future<Map<String, dynamic>> parseInvoice(
    Uint8List pdfBytes, {
    String filename = 'invoice.pdf',
  }) async {
    final res = await parsePdf(pdfBytes, filename: filename);
    final invoice = res['invoice'];
    if (invoice is Map) return Map<String, dynamic>.from(invoice);
    throw Exception('Die Datei wurde nicht als Rechnung erkannt.');
  }

  /// CDF (Customer Delivery Feedback) reports come as HTML files from
  /// Amazon. The parser_service auto-detects format by filename + sniff,
  /// so this method is just a thin wrapper to make the calling site
  /// self-documenting.
  static Future<Map<String, dynamic>> parseHtml(
    Uint8List htmlBytes, {
    String filename = 'report.html',
  }) async {
    final uri = Uri.parse(AppConfig.parserUrl);

    final req = http.MultipartRequest('POST', uri)
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          htmlBytes,
          filename: filename,
          contentType: MediaType('text', 'html'),
        ),
      );

    final streamed =
        await req.send().timeout(_timeout, onTimeout: _timeoutError);
    final resp = await http.Response.fromStream(streamed)
        .timeout(_timeout, onTimeout: _timeoutError);

    if (resp.statusCode != 200) {
      throw Exception('Parser error ${resp.statusCode}: ${resp.body}');
    }
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }
}
