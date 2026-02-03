import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

Widget buildWebImagePreview(String url) {
  return Image.network(
    url,
    fit: BoxFit.contain,
  );
}

Widget buildWebPdfPreview(String url) {
  return const Center(
    child: Text('PDF preview is only available on web.'),
  );
}

Future<void> downloadWebFile(String url, String filename) async {
  final disposition = Uri.encodeComponent('attachment; filename="$filename"');
  final adjustedUrl = url.contains('response-content-disposition=')
      ? url
      : '${url}${url.contains('?') ? '&' : '?'}response-content-disposition=$disposition';
  final uri = Uri.parse(adjustedUrl);
  if (await canLaunchUrl(uri)) {
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }
}

Future<void> downloadWebBytes(Uint8List bytes, String filename) async {
  throw UnsupportedError('downloadWebBytes is only available on web');
}
