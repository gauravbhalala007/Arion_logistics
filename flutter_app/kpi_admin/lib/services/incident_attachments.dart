// lib/services/incident_attachments.dart
//
// Dokumente (PDF + Bilder) an einem Vorfall: auswählen, hochladen, löschen.
// Gegenstück zu `incident_photos.dart` — dort geht es um komprimierte
// Fotos, hier um Belege: Polizeibericht, Zusammenfassung der Schaden-
// meldung, Kostenvoranschlag, Gutachten, Werkstattrechnung.
//
// ─────────────────────────────────────────────────────────────────────────
//  STORAGE-PFAD — und warum NICHT `incident_reports/...`
// ─────────────────────────────────────────────────────────────────────────
//
//   vehicles/{dspUid}/incident-{reportId}/events/{datei}
//
//   Naheliegend wäre `incident_reports/{dspUid}/{TID}/{reportId}/docs/…`
//   gewesen. Diese Rule (`storage.rules`, Abschnitt INCIDENT REPORTS)
//   verlangt beim Schreiben aber `isImage()` — ein PDF wird dort vom
//   Server abgelehnt. Die Rules dürfen in diesem Schritt nicht geändert
//   werden, also läuft der Upload über den einzigen bereits erlaubten
//   Pfad, der PDFs zulässt UND DSP-scoped von Admin *und* Dispatcher
//   gelesen/geschrieben werden darf:
//
//     match /vehicles/{dspUid}/{plate}/events/{fileName} {
//       allow read:          isAdminOfDsp || isDispatcherOfDsp
//       allow create,update: isAdminOfDsp || isDispatcherOfDsp
//                            && isImageOrPdf() && maxMb(20)
//       allow delete:        isAdminOfDsp
//     }
//
//   Das mittlere Segment ist in der Rule ein freier Wildcard. Wir setzen
//   dort `incident-{reportId}` statt eines Kennzeichens ein:
//
//   * Kollisionsfrei — echte Kennzeichen-Ordner entstehen über
//     `normalizePlateNumber()` / `plateKeyOf()` und enthalten nach
//     `[^A-Z0-9]`-Strip niemals ein `-`.
//   * Keine Fremd-Feature stört sich daran: `listAll()` läuft im Projekt
//     nur auf `recruiting/`, `users/{dsp}/seso/` und
//     `users/{dsp}/time_imports/` — nie unter `vehicles/`.
//   * Arbeitsunfälle ohne Fahrzeug funktionieren genauso, weil die Rule
//     das Segment nicht gegen den Fahrzeugbestand prüft.
//
//   TODO(rules): Sauberer wäre `isImage()` → `isImageOrPdf()` im Abschnitt
//   INCIDENT REPORTS plus ein Dispatcher-Write. Sobald das deployed ist,
//   kann [incidentAttachmentStoragePath] umgestellt werden — Altdateien
//   bleiben erreichbar, weil jeder Anhang seinen vollen `path` im
//   Firestore-Dokument mitführt.
//
//   `contentType` MUSS gesetzt sein, sonst greift `isImageOrPdf()` nicht:
//   Flutter Web lädt sonst als `application/octet-stream` hoch.

import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as fb;

import 'incident_reports.dart' show IncidentAttachment;

/// Erlaubte Endungen im Datei-Dialog. Deckungsgleich mit dem, was
/// `isImageOrPdf()` in den Storage-Rules durchlässt — alles andere würde
/// beim Upload serverseitig scheitern.
const List<String> kIncidentAttachmentExtensions = <String>[
  'pdf',
  'jpg',
  'jpeg',
  'png',
  'webp',
  'heic',
  'heif',
];

/// Obergrenze je Datei. Die Rule erlaubt 20 MB; 15 MB lässt Luft für den
/// Base64-/Multipart-Overhead und ist für einen Scan reichlich.
const int kIncidentAttachmentMaxBytes = 15 * 1024 * 1024;

/// Präfix des Pfad-Segments, das in der Rule eigentlich das Kennzeichen
/// ist (siehe Kopfkommentar).
const String kIncidentAttachmentPathPrefix = 'incident-';

/// Eine ausgewählte, noch nicht hochgeladene Datei.
class PickedIncidentAttachment {
  const PickedIncidentAttachment({
    required this.name,
    required this.bytes,
    required this.contentType,
  });

  final String name;
  final Uint8List bytes;
  final String contentType;

  int get size => bytes.lengthInBytes;
}

/// Ergebnis von [pickIncidentAttachments] — mit den Gründen, warum etwas
/// aussortiert wurde, damit die UI eine konkrete Snackbar zeigen kann.
class IncidentAttachmentPickResult {
  const IncidentAttachmentPickResult({
    this.files = const <PickedIncidentAttachment>[],
    this.tooLarge = 0,
    this.unreadable = 0,
    this.wrongType = 0,
  });

  final List<PickedIncidentAttachment> files;

  /// Größer als [kIncidentAttachmentMaxBytes].
  final int tooLarge;

  /// Der Picker hat keine Bytes geliefert.
  final int unreadable;

  /// Endung nicht in [kIncidentAttachmentExtensions] (manche Plattformen
  /// ignorieren den Filter im Dialog).
  final int wrongType;

  bool get hasRejections => tooLarge > 0 || unreadable > 0 || wrongType > 0;
}

/// Öffnet den Datei-Dialog für Vorfall-Dokumente.
///
/// `withData: true` ist auf Web Pflicht — dort gibt es keinen `path`, die
/// Bytes sind der einzige Weg zum Upload.
Future<IncidentAttachmentPickResult> pickIncidentAttachments() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: kIncidentAttachmentExtensions,
    allowMultiple: true,
    withData: true,
  );
  if (result == null || result.files.isEmpty) {
    return const IncidentAttachmentPickResult();
  }

  final out = <PickedIncidentAttachment>[];
  var tooLarge = 0;
  var unreadable = 0;
  var wrongType = 0;

  for (final file in result.files) {
    final contentType = incidentAttachmentContentType(file.name);
    if (contentType == null) {
      wrongType++;
      continue;
    }
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      unreadable++;
      continue;
    }
    if (bytes.lengthInBytes > kIncidentAttachmentMaxBytes) {
      tooLarge++;
      continue;
    }
    out.add(
      PickedIncidentAttachment(
        name: file.name,
        bytes: bytes,
        contentType: contentType,
      ),
    );
  }

  return IncidentAttachmentPickResult(
    files: out,
    tooLarge: tooLarge,
    unreadable: unreadable,
    wrongType: wrongType,
  );
}

/// MIME-Type anhand der Endung — `null`, wenn der Typ nicht erlaubt ist.
///
/// Bewusst nicht `file.extension` des Pickers: der ist auf manchen
/// Plattformen leer, der Name ist immer da.
String? incidentAttachmentContentType(String fileName) {
  final lower = fileName.toLowerCase();
  if (lower.endsWith('.pdf')) return 'application/pdf';
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.webp')) return 'image/webp';
  if (lower.endsWith('.heic') || lower.endsWith('.heif')) return 'image/heic';
  if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
  return null;
}

/// Storage-Pfad eines Vorfall-Dokuments (siehe Kopfkommentar).
String incidentAttachmentStoragePath({
  required String dspUid,
  required String reportId,
  required String fileName,
}) =>
    'vehicles/$dspUid/$kIncidentAttachmentPathPrefix$reportId/events/$fileName';

/// Entschärft einen Dateinamen für den Storage-Pfad: keine Slashes, keine
/// Umlaute/Leerzeichen, gedeckelte Länge. Der Klarname bleibt im
/// Firestore-Eintrag (`name`) erhalten und wird in der UI gezeigt.
String sanitizeIncidentAttachmentFileName(String raw) {
  final trimmed = raw.trim();
  final mapped = trimmed
      .replaceAll('ä', 'ae')
      .replaceAll('ö', 'oe')
      .replaceAll('ü', 'ue')
      .replaceAll('Ä', 'Ae')
      .replaceAll('Ö', 'Oe')
      .replaceAll('Ü', 'Ue')
      .replaceAll('ß', 'ss')
      .replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '_')
      .replaceAll(RegExp('_{2,}'), '_');
  final cleaned = mapped.replaceAll(RegExp(r'^[._-]+'), '');
  if (cleaned.isEmpty) return 'datei';
  return cleaned.length <= 80 ? cleaned : cleaned.substring(0, 80);
}

/// Lädt eine ausgewählte Datei hoch und liefert den Firestore-Eintrag.
/// [index] hält die Reihenfolge im Dateinamen stabil, falls mehrere
/// Dateien in derselben Millisekunde hochgehen.
Future<IncidentAttachment> uploadIncidentAttachment({
  required String dspUid,
  required String reportId,
  required PickedIncidentAttachment file,
  required int index,
}) async {
  final stamp = DateTime.now().millisecondsSinceEpoch;
  final path = incidentAttachmentStoragePath(
    dspUid: dspUid,
    reportId: reportId,
    fileName: '${stamp}_${index}_'
        '${sanitizeIncidentAttachmentFileName(file.name)}',
  );
  final ref = fb.FirebaseStorage.instance.ref().child(path);
  await ref.putData(
    file.bytes,
    fb.SettableMetadata(
      contentType: file.contentType,
      // Ohne `inline` bietet der Browser das PDF als Download an statt es
      // im neuen Tab zu rendern — der Admin will es aber nur ansehen.
      contentDisposition: 'inline',
      cacheControl: 'private,max-age=3600',
    ),
  );
  return IncidentAttachment(
    url: await ref.getDownloadURL(),
    path: path,
    name: file.name.trim().isEmpty ? 'Dokument' : file.name.trim(),
    size: file.size,
    contentType: file.contentType,
    uploadedBy: FirebaseAuth.instance.currentUser?.uid ?? '',
    uploadedAt: DateTime.now(),
  );
}

/// Löscht die Storage-Datei eines entfernten Dokuments — best effort.
///
/// `allow delete` gilt nur für `isAdminOfDsp(dspUid)`. Scheitert der
/// Aufruf (Dispatcher, Bestandseintrag ohne `path`), bleibt die Datei
/// verwaist im Bucket; im Dokument ist sie weg, also taucht sie in der UI
/// nicht mehr auf.
Future<bool> deleteIncidentAttachmentFile(String path) async {
  if (path.trim().isEmpty) return false;
  try {
    await fb.FirebaseStorage.instance.ref().child(path).delete();
    return true;
  } catch (_) {
    return false;
  }
}
