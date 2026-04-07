import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';

Widget buildWebVideoEmbed({
  required String viewType,
  required Uri uri,
}) {
  ui_web.platformViewRegistry.registerViewFactory(viewType, (int _) {
    final iframe = html.IFrameElement()
      ..src = uri.toString()
      ..style.border = '0'
      ..style.width = '100%'
      ..style.height = '100%'
      ..allowFullscreen = true;
    return iframe;
  });

  return HtmlElementView(viewType: viewType);
}
