// lib/services/recruiting_upload_service.dart
//
// Shared document pipeline for every public recruiting form (driver
// application + staffing-agency form). Extracted verbatim from
// `recruiting_form_page.dart` so all forms enforce the SAME size
// limits, the same compression and the same Storage layout:
//
//   recruiting/{adminUid}/{appId}/{label}.{ext}
//
// Nothing in here requires authentication — the public forms run
// without a login and the Storage rules allow the write on that path.

import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

import '../models/recruiting_application.dart';

/// A document the applicant picked but that has not been uploaded yet.
/// Uploads are deferred to submit time so a slow connection while
/// picking never blocks the user.
class PickedRecruitingFile {
  const PickedRecruitingFile({
    required this.bytes,
    required this.filename,
    required this.mimeType,
  });

  final Uint8List bytes;
  final String filename;
  final String mimeType;
}

/// Outcome of [RecruitingUploadService.pickDocument] — either a file or
/// a reason why the pick failed, so the caller can surface the message
/// in the language the form is currently rendered in.
class PickDocumentResult {
  const PickDocumentResult._({this.file, this.error, this.megabytes});

  const PickDocumentResult.picked(PickedRecruitingFile f)
      : this._(file: f);
  const PickDocumentResult.cancelled() : this._();
  const PickDocumentResult.compressionFailed()
      : this._(error: PickDocumentError.compressionFailed);
  const PickDocumentResult.tooLarge(String mb)
      : this._(error: PickDocumentError.tooLarge, megabytes: mb);

  final PickedRecruitingFile? file;
  final PickDocumentError? error;

  /// Size of the rejected file, pre-formatted to one decimal (e.g. "12.4").
  final String? megabytes;
}

enum PickDocumentError { compressionFailed, tooLarge }

/// Bucket the app uploads to. `firebase_options.dart` and the deployed
/// Storage CORS config agree on this value, so it stays consistent
/// across environments.
const String _kStorageBucket = 'codriver-eu.firebasestorage.app';

class RecruitingUploadService {
  const RecruitingUploadService();

  /// Auto-compress every image above this size. iOS Safari on cellular
  /// can choke on resumable Storage uploads beyond ~2 MB.
  static const int maxImageBytes = 1200 * 1024;

  /// Hard cap for non-image documents (PDF scans).
  static const int hardCapBytes = 10 * 1024 * 1024;

  static const List<String> allowedExtensions = <String>[
    'pdf',
    'png',
    'jpg',
    'jpeg',
    'heic',
  ];

  /// Opens the platform file picker, compresses oversized images and
  /// returns the file in memory. [extensions] narrows the picker (the
  /// EZB slot on the agency form accepts PDF only).
  Future<PickDocumentResult> pickDocument({
    List<String> extensions = allowedExtensions,
  }) async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: extensions,
      withData: true,
    );
    if (res == null || res.files.isEmpty) {
      return const PickDocumentResult.cancelled();
    }
    final f = res.files.first;
    if (f.bytes == null) return const PickDocumentResult.cancelled();

    final ext = (f.extension ?? '').toLowerCase();
    var bytes = f.bytes!;
    var mime = ext == 'pdf'
        ? 'application/pdf'
        : ext == 'png'
            ? 'image/png'
            : ext == 'heic'
                ? 'image/heic'
                : 'image/jpeg';

    if (mime.startsWith('image/') && bytes.lengthInBytes > maxImageBytes) {
      final shrunk = await compressImage(bytes);
      if (shrunk == null) return const PickDocumentResult.compressionFailed();
      bytes = shrunk;
      mime = 'image/jpeg';
    } else if (bytes.lengthInBytes > hardCapBytes) {
      final mb = (bytes.lengthInBytes / 1024 / 1024).toStringAsFixed(1);
      return PickDocumentResult.tooLarge(mb);
    }

    return PickDocumentResult.picked(
      PickedRecruitingFile(
        bytes: bytes,
        filename: f.name,
        mimeType: mime,
      ),
    );
  }

  /// Down-scales an image so its longest edge is ≤ 1600 px and
  /// re-encodes at JPEG q75 — still perfectly readable for ID
  /// documents, but upload-friendly on cellular.
  Future<Uint8List?> compressImage(Uint8List raw) async {
    try {
      final decoded = img.decodeImage(raw);
      if (decoded == null) return null;
      const maxEdge = 1600;
      final longest =
          decoded.width > decoded.height ? decoded.width : decoded.height;
      final resized = longest > maxEdge
          ? img.copyResize(
              decoded,
              width: decoded.width >= decoded.height ? maxEdge : null,
              height: decoded.width >= decoded.height ? null : maxEdge,
              interpolation: img.Interpolation.linear,
            )
          : decoded;
      final encoded = img.encodeJpg(resized, quality: 75);
      return Uint8List.fromList(encoded);
    } catch (_) {
      return null;
    }
  }

  /// Uploads one file to Firebase Storage and returns the resulting
  /// downloadUrl + storagePath.
  ///
  /// We deliberately BYPASS the Firebase Storage SDK and POST directly
  /// to the REST endpoint. The SDK on iOS Safari uses a resumable
  /// protocol that occasionally throws a misleading
  /// `firebase_storage/unauthorized` on cellular even when the rule
  /// allows the write. A plain `uploadType=media` POST is one
  /// round-trip and behaves identically on every browser.
  Future<RecruitingDocument> uploadDocument({
    required String adminUid,
    required String appId,
    required String label,
    required Uint8List bytes,
    required String filename,
    required String mimeType,
  }) async {
    final ext = mimeType == 'application/pdf'
        ? 'pdf'
        : mimeType == 'image/png'
            ? 'png'
            : mimeType == 'image/heic'
                ? 'heic'
                : 'jpg';
    final path = 'recruiting/$adminUid/$appId/$label.$ext';
    final encodedPath = Uri.encodeComponent(path);
    final uri = Uri.parse(
      'https://firebasestorage.googleapis.com/v0/b/$_kStorageBucket/o'
      '?uploadType=media&name=$encodedPath',
    );

    final resp = await http.post(
      uri,
      headers: <String, String>{'Content-Type': mimeType},
      body: bytes,
    );

    if (resp.statusCode != 200) {
      throw Exception(
        'Storage POST returned ${resp.statusCode}: ${resp.body}',
      );
    }

    final meta = jsonDecode(resp.body) as Map<String, dynamic>;
    final downloadTokens = (meta['downloadTokens'] ?? '').toString();
    final downloadUrl =
        'https://firebasestorage.googleapis.com/v0/b/$_kStorageBucket/o/'
        '$encodedPath?alt=media&token=$downloadTokens';

    return RecruitingDocument(
      label: label,
      filename: filename,
      mimeType: mimeType,
      downloadUrl: downloadUrl,
      storagePath: path,
      sizeBytes: bytes.lengthInBytes,
    );
  }
}
