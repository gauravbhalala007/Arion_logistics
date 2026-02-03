import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'dart:typed_data';

import 'package:flutter/widgets.dart';

Widget buildWebImagePreview(String url) {
  final viewType = 'web-img-${DateTime.now().microsecondsSinceEpoch}';

  // ignore: undefined_prefixed_name
  ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
    final img = html.ImageElement()
      ..src = url
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'contain'
      ..style.display = 'block';
    return img;
  });

  return SizedBox.expand(
    child: HtmlElementView(viewType: viewType),
  );
}

Widget buildWebPdfPreview(String url) {
  final viewType = 'web-pdf-${DateTime.now().microsecondsSinceEpoch}';

  // ignore: undefined_prefixed_name
  ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
    final frame = html.IFrameElement()
      ..src = url
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%';
    return frame;
  });

  return SizedBox.expand(
    child: HtmlElementView(viewType: viewType),
  );
}

Future<void> downloadWebFile(String url, String filename) async {
  try {
    final request = await html.HttpRequest.request(
      url,
      responseType: 'blob',
    );
    final blob = request.response as html.Blob;
    final objectUrl = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: objectUrl)
      ..download = filename
      ..style.display = 'none';
    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(objectUrl);
    return;
  } catch (_) {
    // Fallback to server-provided filename if the blob request fails.
  }

  final disposition = Uri.encodeComponent('attachment; filename="$filename"');
  final adjustedUrl = url.contains('response-content-disposition=')
      ? url
      : '${url}${url.contains('?') ? '&' : '?'}response-content-disposition=$disposition';
  final anchor = html.AnchorElement(href: adjustedUrl)
    ..download = filename
    ..style.display = 'none';
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
}

Future<void> downloadWebBytes(Uint8List bytes, String filename) async {
  final blob = html.Blob([bytes]);
  final objectUrl = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: objectUrl)
    ..download = filename
    ..style.display = 'none';
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(objectUrl);
}
