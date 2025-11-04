import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../config/app_config.dart';

class ParserApi {
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

    final streamed = await req.send();
    final resp = await http.Response.fromStream(streamed);

    if (resp.statusCode != 200) {
      throw Exception('Parser error ${resp.statusCode}: ${resp.body}');
    }
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }
}
