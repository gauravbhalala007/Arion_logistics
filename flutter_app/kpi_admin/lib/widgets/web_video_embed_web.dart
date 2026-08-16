import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';

/// Bereits registrierte View-Typen. `registerViewFactory` darf pro Typ
/// nur einmal aufgerufen werden — sonst wirft Flutter beim zweiten Mal.
final Set<String> _registered = <String>{};

Widget buildWebVideoEmbed({
  required String viewType,
  required Uri uri,
}) {
  if (_registered.add(viewType)) {
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int _) {
      final iframe = html.IFrameElement()
        ..src = uri.toString()
        ..style.border = '0'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allow = 'autoplay; fullscreen; encrypted-media'
        ..allowFullscreen = true;
      return iframe;
    });
  }

  return HtmlElementView(viewType: viewType);
}
