import 'dart:async';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Result of optimising a user-supplied product photo for inventory.
class OptimizedPhoto {
  const OptimizedPhoto({
    required this.bytes,
    required this.width,
    required this.height,
  });

  final Uint8List bytes;
  final int width;
  final int height;
}

/// Down-scale and re-encode raw image bytes so they fit comfortably
/// inside a Firestore document (≤ ~1 MB) while staying crisp for a
/// product-grid card.
///
///  * Decoded once on a microtask (uses the synchronous `image`
///    library which works on Flutter web without dart:io).
///  * Longest edge clamped to [maxEdge] (default 600 px).
///  * JPEG quality starts at 82 and steps down until the encoded
///    size is below [maxBytes] (default 100 KB).
Future<OptimizedPhoto?> optimizeProductPhoto(
  Uint8List raw, {
  int maxEdge = 600,
  int maxBytes = 100 * 1024,
}) async {
  return Future.microtask(() {
    final decoded = img.decodeImage(raw);
    if (decoded == null) return null;

    img.Image working = decoded;
    final longest =
        decoded.width > decoded.height ? decoded.width : decoded.height;
    if (longest > maxEdge) {
      if (decoded.width >= decoded.height) {
        working = img.copyResize(
          decoded,
          width: maxEdge,
          interpolation: img.Interpolation.linear,
        );
      } else {
        working = img.copyResize(
          decoded,
          height: maxEdge,
          interpolation: img.Interpolation.linear,
        );
      }
    }

    Uint8List encoded;
    var q = 82;
    while (true) {
      encoded = Uint8List.fromList(img.encodeJpg(working, quality: q));
      if (encoded.length <= maxBytes || q <= 50) break;
      q -= 8;
    }
    return OptimizedPhoto(
      bytes: encoded,
      width: working.width,
      height: working.height,
    );
  });
}
