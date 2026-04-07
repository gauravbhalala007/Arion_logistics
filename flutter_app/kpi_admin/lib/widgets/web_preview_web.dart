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
  final inlineUrl = _inlinePdfUrl(url);

  // ignore: undefined_prefixed_name
  ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
    final container = html.DivElement()
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.backgroundColor = '#f3f4f6'
      ..style.display = 'flex'
      ..style.alignItems = 'center'
      ..style.justifyContent = 'center';

    final status = html.DivElement()
      ..text = 'Loading PDF preview...'
      ..style.fontFamily = 'sans-serif'
      ..style.fontSize = '14px'
      ..style.color = '#6b7280';
    container.children = [status];

    html.HttpRequest.request(inlineUrl, responseType: 'blob').then((request) {
      final blob = request.response;
      if (blob is! html.Blob) {
        status.text = 'Could not load PDF preview.';
        return;
      }

      final objectUrl = html.Url.createObjectUrlFromBlob(blob);
      final embed = html.EmbedElement()
        ..src = objectUrl
        ..type = 'application/pdf'
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';

      container.children = [embed];
    }).catchError((_) {
      status.text = 'Could not load PDF preview.';
    });

    return container;
  });

  return SizedBox.expand(
    child: HtmlElementView(viewType: viewType),
  );
}

String _inlinePdfUrl(String url) {
  var adjusted = url;
  if (!adjusted.contains('response-content-type=')) {
    adjusted =
        '$adjusted${adjusted.contains('?') ? '&' : '?'}response-content-type=${Uri.encodeQueryComponent('application/pdf')}';
  }
  if (!adjusted.contains('response-content-disposition=')) {
    adjusted =
        '$adjusted${adjusted.contains('?') ? '&' : '?'}response-content-disposition=${Uri.encodeQueryComponent('inline')}';
  }
  return adjusted;
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
