// lib/services/incident_photos.dart
//
// Auswählen, Optimieren und Hochladen von Vorfall-Fotos — für das
// Admin-Formular und die Fahrer-Meldung derselbe Code.
//
// ─────────────────────────────────────────────────────────────────────────
//  STORAGE-PFAD (Rules dürfen NICHT geändert werden)
// ─────────────────────────────────────────────────────────────────────────
//
//   incident_reports/{dspUid}/{TID}/{reportId}/photos/{datei}
//
//   `storage.rules:208` matcht exakt fünf Segmente
//   (`{dspUid}/{tid}/{reportId}/{folder}/{fileName}`) und erlaubt
//   `create, update` für `isAdminOfDsp(dspUid) || isSelfDriver(tid)`,
//   jeweils nur mit Bild-MIME-Type und < 20 MB. Derselbe Pfad funktioniert
//   also für BEIDE Rollen — der Admin ist über `{dspUid}` berechtigt, der
//   Fahrer über seine eigene `{TID}`. Gelesen werden darf zusätzlich vom
//   Dispatcher des DSP.
//
//   `allow delete` gilt NUR für `isAdminOfDsp(dspUid)`. Deshalb lädt die
//   Fahrer-Seite erst beim Absenden hoch: ein vorher wieder entferntes Foto
//   erzeugt so gar keine Datei, die der Fahrer nicht mehr löschen dürfte.
//
//   `contentType` MUSS gesetzt sein, sonst greift `isImage()` nicht —
//   Flutter Web lädt sonst als `application/octet-stream` hoch.

import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as fb;

import 'image_compression.dart';
import 'incident_reports.dart' show IncidentPhoto, transporterIdOf;

/// Unterordner im Vorfall-Ordner (viertes Pfadsegment der Rule).
const String kIncidentPhotoFolder = 'photos';

/// Hardcap auf das **Original**: alles darüber wird gar nicht erst
/// dekodiert. 10 MB deckt jedes Handyfoto ab; darüber ist es eher ein
/// versehentlich gewähltes RAW/Panorama.
const int kIncidentPhotoHardCapBytes = 10 * 1024 * 1024;

/// Obergrenze in der Fahrer-App — mehr ist auf dem Handy weder gut
/// bedienbar noch im Mobilfunknetz zumutbar.
const int kIncidentDriverPhotoLimit = 6;

/// Ein ausgewähltes, bereits optimiertes Foto — noch nicht hochgeladen.
/// Der Upload passiert erst beim Speichern/Absenden, damit ein wieder
/// entferntes Bild keine verwaiste Datei im Bucket hinterlässt.
class PickedIncidentPhoto {
  const PickedIncidentPhoto({
    required this.name,
    required this.bytes,
    required this.contentType,
  });

  final String name;
  final Uint8List bytes;
  final String contentType;
}

/// Ergebnis von [pickIncidentPhotos] — inklusive der Gründe, warum etwas
/// aussortiert wurde, damit die UI eine konkrete Meldung zeigen kann.
class IncidentPhotoPickResult {
  const IncidentPhotoPickResult({
    this.photos = const <PickedIncidentPhoto>[],
    this.tooLarge = 0,
    this.unreadable = 0,
    this.overLimit = 0,
  });

  final List<PickedIncidentPhoto> photos;

  /// Original größer als [kIncidentPhotoHardCapBytes].
  final int tooLarge;

  /// Der Picker hat keine Bytes geliefert.
  final int unreadable;

  /// Über das übergebene `limit` hinaus ausgewählt.
  final int overLimit;

  bool get hasRejections => tooLarge > 0 || unreadable > 0 || overLimit > 0;
}

/// Öffnet den Bild-Picker, verkleinert jedes Bild auf 1600 px / JPEG q75
/// und gibt die Bytes zurück. [limit] begrenzt die Übernahme (Fahrer-App).
Future<IncidentPhotoPickResult> pickIncidentPhotos({int? limit}) async {
  if (limit != null && limit <= 0) {
    return const IncidentPhotoPickResult(overLimit: 1);
  }
  final result = await FilePicker.platform.pickFiles(
    type: FileType.image,
    allowMultiple: limit == null || limit > 1,
    withData: true,
  );
  if (result == null || result.files.isEmpty) {
    return const IncidentPhotoPickResult();
  }

  final out = <PickedIncidentPhoto>[];
  var tooLarge = 0;
  var unreadable = 0;
  var overLimit = 0;

  for (final file in result.files) {
    if (limit != null && out.length >= limit) {
      overLimit++;
      continue;
    }
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      unreadable++;
      continue;
    }
    if (bytes.lengthInBytes > kIncidentPhotoHardCapBytes) {
      tooLarge++;
      continue;
    }
    // HEIC/PNG → JPEG. Kann `image` das Format nicht dekodieren (HEIC),
    // geht das Original raus statt das Foto zu verlieren — die Rule
    // erlaubt jedes `image/*` bis 20 MB, der Hardcap oben greift ohnehin.
    final compressed = await compressImageToJpeg(bytes);
    out.add(
      PickedIncidentPhoto(
        name: file.name,
        bytes: compressed ?? bytes,
        contentType: compressed != null
            ? 'image/jpeg'
            : _contentTypeOf(file.name),
      ),
    );
  }

  return IncidentPhotoPickResult(
    photos: out,
    tooLarge: tooLarge,
    unreadable: unreadable,
    overLimit: overLimit,
  );
}

/// Storage-Pfad eines Vorfall-Fotos (siehe Kopfkommentar).
String incidentPhotoStoragePath({
  required String dspUid,
  required String transporterId,
  required String reportId,
  required String fileName,
  String folder = kIncidentPhotoFolder,
}) =>
    'incident_reports/$dspUid/${transporterIdOf(transporterId)}/$reportId/'
    '$folder/$fileName';

/// Lädt ein ausgewähltes Foto hoch und liefert den Eintrag für das
/// `photos`-Array. [index] hält die Reihenfolge im Dateinamen stabil.
Future<IncidentPhoto> uploadIncidentPhoto({
  required String dspUid,
  required String transporterId,
  required String reportId,
  required PickedIncidentPhoto photo,
  required int index,
  String folder = kIncidentPhotoFolder,
}) async {
  final stamp = DateTime.now().millisecondsSinceEpoch;
  final ext = photo.contentType == 'image/png'
      ? 'png'
      : photo.contentType == 'image/webp'
          ? 'webp'
          : photo.contentType == 'image/heic'
              ? 'heic'
              : 'jpg';
  final path = incidentPhotoStoragePath(
    dspUid: dspUid,
    transporterId: transporterId,
    reportId: reportId,
    folder: folder,
    fileName: '${stamp}_$index.$ext',
  );
  final ref = fb.FirebaseStorage.instance.ref().child(path);
  await ref.putData(
    photo.bytes,
    fb.SettableMetadata(
      contentType: photo.contentType,
      cacheControl: 'public,max-age=31536000',
    ),
  );
  return IncidentPhoto(
    url: await ref.getDownloadURL(),
    path: path,
    uploadedBy: FirebaseAuth.instance.currentUser?.uid ?? '',
    uploadedAt: DateTime.now(),
  );
}

/// Löscht die Storage-Datei eines entfernten Fotos — best effort.
///
/// Schlägt fehl bei Bestandsfotos ohne `path` und bei allen Rollen außer
/// Admin (`allow delete: if isAdminOfDsp(dspUid)`). In dem Fall bleibt die
/// Datei verwaist im Bucket zurück; im Dokument ist sie weg, also taucht
/// sie nirgends mehr auf.
Future<bool> deleteIncidentPhotoFile(String path) async {
  if (path.trim().isEmpty) return false;
  try {
    await fb.FirebaseStorage.instance.ref().child(path).delete();
    return true;
  } catch (_) {
    return false;
  }
}

String _contentTypeOf(String fileName) {
  final lower = fileName.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.webp')) return 'image/webp';
  if (lower.endsWith('.heic') || lower.endsWith('.heif')) return 'image/heic';
  return 'image/jpeg';
}
