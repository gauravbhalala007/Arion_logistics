import 'dart:js_interop';

@JS('cdShowXlsxLoader')
external void _cdShow(JSString msg);

@JS('cdSetXlsxLoaderMsg')
external void _cdSetMsg(JSString msg);

@JS('cdHideXlsxLoader')
external void _cdHide();

/// Browser-native (CSS) loading overlay for the Shift Plan Excel upload.
///
/// CSS animations run on the browser's compositor thread, so this spinner
/// keeps moving even while the Dart main isolate is blocked by the
/// synchronous `Excel.decodeBytes` call — unlike a Flutter spinner, which
/// freezes for the duration of the decode. Defined in `web/index.html`.
class XlsxLoader {
  static void show([String msg = 'Datei wird verarbeitet …']) {
    try {
      _cdShow(msg.toJS);
    } catch (_) {}
  }

  static void message(String msg) {
    try {
      _cdSetMsg(msg.toJS);
    } catch (_) {}
  }

  static void hide() {
    try {
      _cdHide();
    } catch (_) {}
  }
}
