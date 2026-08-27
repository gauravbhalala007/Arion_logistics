// lib/services/vehicle_appointments.dart
//
// Fahrzeug-Termine aus dem Admin-Kalender (`users/{dspUid}/calendar_events`
// mit `plateKey`-Feld) — Feedback-Ticket "CALENDAR / HOMEPAGE EVENTS":
//
//  * Kalender-Termine können optional ein Fahrzeug tragen (`plate`,
//    `plateKey`, geschrieben in admin_calendar_page.dart).
//  * Liegt der Termin in der Vergangenheit und wurde noch nicht
//    aufgelöst, zeigt die Fahrzeug-Detailseite ein Warnbanner und die
//    Fleet-Liste ein Badge ("Unterlagen fehlen").
//  * Aufgelöst wird per Datei-Upload (Servicebericht/Kostenvoranschlag),
//    per Freitext-Beschreibung oder per "Kein Bericht nötig" — gespeichert
//    als `resolution`-Map direkt am Event-Dokument:
//      resolution: {
//        type: 'file' | 'description' | 'none_needed',
//        text?, fileUrl?, filePath?, fileName?,
//        resolvedAt, resolvedBy,
//      }
//
// Der Datei-Upload geht nach `vehicles/{dspUid}/{plate}/events/…` — dieser
// Storage-Pfad erlaubt laut storage.rules Admin UND Dispatcher des DSP
// (nur Bilder/PDF, max. 20 MB). Keine Rules-Änderung nötig.
//
// Hinweis fürs spätere KI-Auslesen: `resolution.filePath` trägt den vollen
// Storage-Pfad der hochgeladenen Datei — eine Cloud Function kann darüber
// die Datei lesen, dekodieren (km-Stand, Service-Art, …) und die Ergebnisse
// z. B. unter `resolution.parsed` ergänzen.

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as fb_storage;
import 'package:flutter/material.dart';

import 'incident_reports.dart' show plateKeyOf;

/// Ein Kalender-Termin mit Fahrzeugbezug (Feld `plateKey` gesetzt).
class VehicleAppointment {
  const VehicleAppointment({
    required this.id,
    required this.ownerUid,
    required this.start,
    required this.title,
    required this.plate,
    required this.plateKey,
    required this.resolutionType,
  });

  /// Firestore-Doc-ID in `users/{ownerUid}/calendar_events`.
  final String id;

  /// UID, unter deren Namespace der Termin liegt (DSP-Admin).
  final String ownerUid;

  final DateTime start;
  final String title;
  final String plate;
  final String plateKey;

  /// 'file' | 'description' | 'none_needed' | '' (= offen).
  final String resolutionType;

  bool get isResolved => resolutionType.isNotEmpty;

  /// Vergangener Termin? (Event-Tag < heute)
  bool isPast(DateTime now) {
    final day = DateTime(start.year, start.month, start.day);
    final today = DateTime(now.year, now.month, now.day);
    return day.isBefore(today);
  }

  static VehicleAppointment? fromDoc(
    String ownerUid,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final start = (data['start'] as Timestamp?)?.toDate();
    final plateKey = (data['plateKey'] ?? '').toString().trim();
    if (start == null || plateKey.isEmpty) return null;
    final resolution = data['resolution'];
    final resolutionType = resolution is Map
        ? (resolution['type'] ?? '').toString().trim()
        : '';
    return VehicleAppointment(
      id: doc.id,
      ownerUid: ownerUid,
      start: start,
      title: (data['title'] ?? '').toString(),
      plate: (data['plate'] ?? '').toString(),
      plateKey: plateKey,
      resolutionType: resolutionType,
    );
  }
}

/// EINE Query je DSP: alle Kalender-Termine mit Fahrzeugbezug
/// (`plateKey` nicht leer). Vergangenheits-/Aufgelöst-Filter passiert
/// clientseitig, damit kein Composite-Index nötig ist.
Stream<List<VehicleAppointment>> watchVehicleAppointments({
  required String dspUid,
}) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(dspUid)
      .collection('calendar_events')
      .where('plateKey', isGreaterThan: '')
      .snapshots()
      .map(
        (snap) => [
          for (final doc in snap.docs)
            if (VehicleAppointment.fromDoc(dspUid, doc)
                case final VehicleAppointment appt)
              appt,
        ],
      );
}

/// Offene (unaufgelöste) VERGANGENE Termine, gruppiert nach `plateKey` —
/// für das Badge in der Fleet-Liste und das Banner der Detailseite.
Map<String, List<VehicleAppointment>> openPastAppointmentsByPlateKey(
  List<VehicleAppointment> appointments, {
  DateTime? now,
}) {
  final ts = now ?? DateTime.now();
  final out = <String, List<VehicleAppointment>>{};
  for (final appt in appointments) {
    if (appt.isResolved || !appt.isPast(ts)) continue;
    out.putIfAbsent(appt.plateKey, () => <VehicleAppointment>[]).add(appt);
  }
  for (final list in out.values) {
    list.sort((a, b) => a.start.compareTo(b.start));
  }
  return out;
}

/// Schreibt die Auflösung an das Event-Dokument (additiv, dauerhaft).
Future<void> resolveVehicleAppointment({
  required VehicleAppointment appointment,
  required String type, // 'file' | 'description' | 'none_needed'
  String? text,
  String? fileUrl,
  String? filePath,
  String? fileName,
}) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(appointment.ownerUid)
      .collection('calendar_events')
      .doc(appointment.id)
      .update({
    'resolution': {
      'type': type,
      if (text != null && text.trim().isNotEmpty) 'text': text.trim(),
      if (fileUrl != null && fileUrl.isNotEmpty) 'fileUrl': fileUrl,
      if (filePath != null && filePath.isNotEmpty) 'filePath': filePath,
      if (fileName != null && fileName.isNotEmpty) 'fileName': fileName,
      'resolvedAt': Timestamp.now(),
      'resolvedBy': FirebaseAuth.instance.currentUser?.uid ?? '',
    },
  });
}

String _contentTypeFor(String fileName) {
  final lower = fileName.toLowerCase();
  if (lower.endsWith('.pdf')) return 'application/pdf';
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.webp')) return 'image/webp';
  if (lower.endsWith('.gif')) return 'image/gif';
  return 'image/jpeg';
}

/// Upload nach `vehicles/{dspUid}/{plate}/events/appt_{eventId}_{name}` —
/// dort dürfen Admin UND Dispatcher schreiben (Bilder/PDF, max. 20 MB).
Future<({String url, String path})> _uploadAppointmentFile({
  required String dspUid,
  required String plate,
  required String appointmentId,
  required String fileName,
  required Uint8List bytes,
}) async {
  final safeName = fileName.trim().replaceAll('/', '_');
  final ref = fb_storage.FirebaseStorage.instance
      .ref()
      .child('vehicles/$dspUid/$plate/events/appt_${appointmentId}_$safeName');
  await ref.putData(
    bytes,
    fb_storage.SettableMetadata(contentType: _contentTypeFor(safeName)),
  );
  final url = await ref.getDownloadURL();
  return (url: url, path: ref.fullPath);
}

/// Auflösungs-Dialog mit den drei Wegen aus dem Ticket:
/// (a) Datei hochladen, (b) Reparatur beschreiben, (c) kein Bericht nötig.
/// Gibt `true` zurück, wenn der Termin aufgelöst wurde.
Future<bool> showVehicleAppointmentResolveDialog(
  BuildContext context, {
  required String dspUid,
  required String plate,
  required VehicleAppointment appointment,
}) async {
  final resolved = await showDialog<bool>(
    context: context,
    builder: (ctx) => _ResolveAppointmentDialog(
      dspUid: dspUid,
      plate: plate,
      appointment: appointment,
    ),
  );
  return resolved == true;
}

class _ResolveAppointmentDialog extends StatefulWidget {
  const _ResolveAppointmentDialog({
    required this.dspUid,
    required this.plate,
    required this.appointment,
  });

  final String dspUid;
  final String plate;
  final VehicleAppointment appointment;

  @override
  State<_ResolveAppointmentDialog> createState() =>
      _ResolveAppointmentDialogState();
}

class _ResolveAppointmentDialogState extends State<_ResolveAppointmentDialog> {
  final TextEditingController _textCtrl = TextEditingController();
  bool _busy = false;

  static const Color _ink = Color(0xFF1A212B);
  static const Color _sub = Color(0xFF5B6572);
  static const Color _line = Color(0xFFE5E9EE);
  static const Color _green = Color(0xFF0D8A60);
  static const Color _amberBg = Color(0xFFFDF6EC);
  static const Color _amberBorder = Color(0xFFF1E3C6);
  static const Color _amberText = Color(0xFF9A6B1F);

  bool get _de => Localizations.localeOf(context).languageCode == 'de';

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: error ? const Color(0xFFB32F2F) : null,
        content: Text(msg),
      ),
    );
  }

  Future<void> _runResolve(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      if (!mounted) return;
      _snack(
        _de ? 'Termin aufgelöst — Warnung entfernt.' : 'Appointment resolved — warning cleared.',
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      _snack(
        _de ? 'Auflösen fehlgeschlagen: $e' : 'Could not resolve: $e',
        error: true,
      );
      setState(() => _busy = false);
    }
  }

  Future<void> _pickAndUpload() async {
    final picked = await FilePicker.platform.pickFiles(
      withData: true,
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg', 'webp', 'gif'],
    );
    if (picked == null || picked.files.isEmpty) return;
    final file = picked.files.first;
    final bytes = file.bytes;
    if (bytes == null) {
      _snack(
        _de ? 'Datei konnte nicht gelesen werden.' : 'Could not read the file.',
        error: true,
      );
      return;
    }
    await _runResolve(() async {
      final upload = await _uploadAppointmentFile(
        dspUid: widget.dspUid,
        plate: widget.plate,
        appointmentId: widget.appointment.id,
        fileName: file.name,
        bytes: bytes,
      );
      await resolveVehicleAppointment(
        appointment: widget.appointment,
        type: 'file',
        text: _textCtrl.text,
        fileUrl: upload.url,
        filePath: upload.path,
        fileName: file.name,
      );
    });
  }

  Future<void> _saveDescription() async {
    if (_textCtrl.text.trim().isEmpty) {
      _snack(
        _de
            ? 'Bitte zuerst die Reparatur kurz beschreiben.'
            : 'Please describe the repair first.',
        error: true,
      );
      return;
    }
    await _runResolve(
      () => resolveVehicleAppointment(
        appointment: widget.appointment,
        type: 'description',
        text: _textCtrl.text,
      ),
    );
  }

  Future<void> _noReportNeeded() async {
    await _runResolve(
      () => resolveVehicleAppointment(
        appointment: widget.appointment,
        type: 'none_needed',
        text: _textCtrl.text,
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool primary = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: primary
          ? FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
              ),
              onPressed: _busy ? null : onTap,
              icon: Icon(icon, size: 18),
              label: Text(label),
            )
          : OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: _ink,
                side: const BorderSide(color: _line),
              ),
              onPressed: _busy ? null : onTap,
              icon: Icon(icon, size: 18, color: _sub),
              label: Text(label),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final de = _de;
    final appt = widget.appointment;
    final d = appt.start;
    final dateLabel = '${d.day.toString().padLeft(2, '0')}.'
        '${d.month.toString().padLeft(2, '0')}.${d.year}';
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        de ? 'Unterlagen zum Termin' : 'Appointment documents',
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: _ink,
        ),
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _amberBg,
                  border: Border.all(color: _amberBorder),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  de
                      ? 'Zum Termin am $dateLabel'
                          '${appt.title.trim().isEmpty ? '' : ' („${appt.title.trim()}“)'} '
                          'fehlen die Unterlagen. Datei hochladen '
                          '(Servicebericht/Kostenvoranschlag), Reparatur '
                          'beschreiben oder „Kein Bericht nötig“ wählen.'
                      : 'The data for the appointment on $dateLabel'
                          '${appt.title.trim().isEmpty ? '' : ' (“${appt.title.trim()}”)'} '
                          'is missing. Upload a file (service report/cost '
                          'estimate), describe the repair, or choose '
                          '“No report needed”.',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: _amberText,
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _textCtrl,
                minLines: 2,
                maxLines: 4,
                enabled: !_busy,
                decoration: InputDecoration(
                  labelText: de
                      ? 'Reparatur beschreiben (optional bei Upload)'
                      : 'Describe the repair (optional with upload)',
                  hintText: de
                      ? 'z. B. Bremsen vorne erneuert, 84.500 km …'
                      : 'e.g. front brakes replaced, 84,500 km …',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 14),
              _actionButton(
                icon: Icons.upload_file_rounded,
                label: de
                    ? 'Datei hochladen (PDF/Bild)'
                    : 'Upload file (PDF/image)',
                onTap: _pickAndUpload,
                primary: true,
              ),
              const SizedBox(height: 8),
              _actionButton(
                icon: Icons.notes_rounded,
                label: de
                    ? 'Beschreibung speichern'
                    : 'Save description',
                onTap: _saveDescription,
              ),
              const SizedBox(height: 8),
              _actionButton(
                icon: Icons.do_not_disturb_on_outlined,
                label: de ? 'Kein Bericht nötig' : 'No report needed',
                onTap: _noReportNeeded,
              ),
              if (_busy) ...[
                const SizedBox(height: 12),
                const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(false),
          child: Text(
            de ? 'Später' : 'Later',
            style: const TextStyle(color: _sub, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

/// Convenience: `plateKey` für ein Kennzeichen (Re-Export-Muster, damit die
/// UI-Seiten nur diese Datei importieren müssen).
String vehicleAppointmentPlateKey(String plate) => plateKeyOf(plate);
