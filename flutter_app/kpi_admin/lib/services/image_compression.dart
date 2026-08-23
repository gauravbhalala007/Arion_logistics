// lib/services/image_compression.dart
//
// EINE Bild-Kompression für die ganze App.
//
// Vorher lag dasselbe Rezept (max. 1600 px längste Kante, JPEG q75) zweimal
// im Code: `RecruitingUploadService.compressImage` und
// `compressVehicleCheckPhoto`. Beide delegieren jetzt hierher, damit ein
// 12-MP-Handyfoto überall gleich behandelt wird und eine Änderung an
// Kantenlänge oder Qualität nur an einer Stelle passiert.

import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Längste Kante nach dem Skalieren. Für Schadensfotos, Ausweisscans und
/// Fahrzeug-Checks gleichermaßen gut lesbar.
const int kImageMaxEdge = 1600;

/// JPEG-Qualität nach dem Re-Encoding.
const int kImageJpegQuality = 75;

/// Skaliert [raw] auf max. [maxEdge] px längste Kante und kodiert als JPEG
/// mit [quality]. Liefert `null`, wenn das Format nicht dekodierbar ist
/// (z. B. HEIC — das `image`-Paket kann HEIC nicht lesen); die Aufrufer
/// entscheiden dann selbst, ob sie das Original nehmen oder abbrechen.
///
/// Läuft in einer `microtask`, damit ein großes Bild den aktuellen Frame
/// nicht mitten im Aufbau blockiert.
Future<Uint8List?> compressImageToJpeg(
  Uint8List raw, {
  int maxEdge = kImageMaxEdge,
  int quality = kImageJpegQuality,
}) {
  return Future<Uint8List?>.microtask(() {
    try {
      final decoded = img.decodeImage(raw);
      if (decoded == null) return null;
      final longest = decoded.width > decoded.height
          ? decoded.width
          : decoded.height;
      final resized = longest <= maxEdge
          ? decoded
          : img.copyResize(
              decoded,
              width: decoded.width >= decoded.height ? maxEdge : null,
              height: decoded.width >= decoded.height ? null : maxEdge,
              interpolation: img.Interpolation.linear,
            );
      return Uint8List.fromList(img.encodeJpg(resized, quality: quality));
    } catch (_) {
      return null;
    }
  });
}
