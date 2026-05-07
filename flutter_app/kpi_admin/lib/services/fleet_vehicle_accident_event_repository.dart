import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as fb_storage;

import '../models/fleet_vehicle.dart';
import '../models/fleet_vehicle_accident_event.dart';

class FleetVehicleAccidentEventException implements Exception {
  const FleetVehicleAccidentEventException(this.message);

  final String message;

  @override
  String toString() => message;
}

class FleetVehicleAccidentUploadResult {
  const FleetVehicleAccidentUploadResult({
    required this.fileUrl,
    required this.storagePath,
  });

  final String fileUrl;
  final String storagePath;
}

class FleetVehicleAccidentEventRepository {
  FleetVehicleAccidentEventRepository({
    FirebaseFirestore? firestore,
    fb_storage.FirebaseStorage? storage,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? fb_storage.FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final fb_storage.FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> eventsCollection({
    required String dspUid,
    required String plateNumber,
  }) {
    return _firestore
        .collection('users')
        .doc(dspUid)
        .collection('vehicles')
        .doc(normalizePlateNumber(plateNumber))
        .collection('events');
  }

  Stream<List<FleetVehicleAccidentEvent>> watchEvents({
    required String dspUid,
    required String plateNumber,
    String orderByField = 'eventDate',
    bool descending = true,
  }) {
    return eventsCollection(dspUid: dspUid, plateNumber: plateNumber)
        .where('isDeleted', isEqualTo: false)
        .orderBy(orderByField, descending: descending)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(FleetVehicleAccidentEvent.fromDoc)
              .toList(),
        );
  }

  Future<FleetVehicleAccidentEvent?> getEvent({
    required String dspUid,
    required String plateNumber,
    required String eventId,
  }) async {
    final snapshot = await eventsCollection(
      dspUid: dspUid,
      plateNumber: plateNumber,
    ).doc(eventId).get();
    if (!snapshot.exists) return null;
    final event = FleetVehicleAccidentEvent.fromDoc(snapshot);
    return event.isDeleted ? null : event;
  }

  Future<FleetVehicleAccidentEventPage> getEventsPage({
    required String dspUid,
    required String plateNumber,
    int limit = 20,
    String orderByField = 'eventDate',
    bool descending = true,
    String? searchQuery,
    DocumentSnapshot<Map<String, dynamic>>? startAfterDocument,
  }) async {
    var query = eventsCollection(dspUid: dspUid, plateNumber: plateNumber)
        .where('isDeleted', isEqualTo: false)
        .orderBy(orderByField, descending: descending)
        .limit(limit);

    if (startAfterDocument != null) {
      query = query.startAfterDocument(startAfterDocument);
    }

    final snapshot = await query.get();
    final items = snapshot.docs
        .map(FleetVehicleAccidentEvent.fromDoc)
        .where((event) {
          final search = searchQuery?.trim().toLowerCase() ?? '';
          if (search.isEmpty) return true;
          return event.title.toLowerCase().contains(search);
        })
        .toList();

    return FleetVehicleAccidentEventPage(
      items: items,
      lastDocument: snapshot.docs.isEmpty ? null : snapshot.docs.last,
    );
  }

  Future<FleetVehicleAccidentEvent> createEvent({
    required String dspUid,
    required String plateNumber,
    required FleetVehicleAccidentEventDraft draft,
    Uint8List? fileBytes,
    String? originalFileName,
  }) async {
    _validateDraft(draft);
    final eventsCol = eventsCollection(dspUid: dspUid, plateNumber: plateNumber);
    final docRef = eventsCol.doc();
    final eventId = docRef.id;

    FleetVehicleAccidentUploadResult? upload;
    if (fileBytes != null &&
        originalFileName != null &&
        originalFileName.trim().isNotEmpty) {
      upload = await uploadEventFile(
        dspUid: dspUid,
        plateNumber: plateNumber,
        eventId: eventId,
        fileBytes: fileBytes,
        originalFileName: originalFileName,
        fileType: draft.fileType,
      );
    }

    try {
      await docRef.set({
        'eventId': eventId,
        'dspUid': dspUid,
        'plateNumber': normalizePlateNumber(plateNumber),
        'eventType': 'ACCIDENT',
        'title': draft.title.trim(),
        'eventDate': draft.eventDate.trim(),
        'metadata': draft.metadata,
        'fileUrl': upload?.fileUrl ?? '',
        'fileName': draft.fileName.trim(),
        'fileType': draft.fileType.trim(),
        'notes': draft.notes.trim(),
        'isDeleted': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      final created = await docRef.get();
      return FleetVehicleAccidentEvent.fromDoc(created);
    } catch (e) {
      if (upload != null) {
        try {
          await _storage.ref().child(upload.storagePath).delete();
        } catch (_) {}
      }
      rethrow;
    }
  }

  Future<void> updateEvent({
    required String dspUid,
    required String plateNumber,
    required String eventId,
    required FleetVehicleAccidentEvent existingEvent,
    required FleetVehicleAccidentEventDraft draft,
    Uint8List? fileBytes,
    String? originalFileName,
  }) async {
    _validateDraft(draft);
    var fileUrl = existingEvent.fileUrl;
    FleetVehicleAccidentUploadResult? upload;
    if (fileBytes != null &&
        originalFileName != null &&
        originalFileName.trim().isNotEmpty) {
      upload = await uploadEventFile(
        dspUid: dspUid,
        plateNumber: plateNumber,
        eventId: eventId,
        fileBytes: fileBytes,
        originalFileName: originalFileName,
        fileType: draft.fileType,
      );
      fileUrl = upload.fileUrl;
    }

    try {
      await eventsCollection(dspUid: dspUid, plateNumber: plateNumber)
          .doc(eventId)
          .update({
            'eventId': eventId,
            'dspUid': dspUid,
            'plateNumber': normalizePlateNumber(plateNumber),
            'eventType': 'ACCIDENT',
            'title': draft.title.trim(),
            'eventDate': draft.eventDate.trim(),
            'metadata': draft.metadata,
            'fileUrl': fileUrl,
            'fileName': draft.fileName.trim(),
            'fileType': draft.fileType.trim(),
            'notes': draft.notes.trim(),
            'isDeleted': false,
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      if (upload != null) {
        try {
          await _storage.ref().child(upload.storagePath).delete();
        } catch (_) {}
      }
      rethrow;
    }
  }

  Future<void> softDeleteEvent({
    required String dspUid,
    required String plateNumber,
    required String eventId,
  }) async {
    await eventsCollection(dspUid: dspUid, plateNumber: plateNumber)
        .doc(eventId)
        .update({
          'isDeleted': true,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  Future<FleetVehicleAccidentUploadResult> uploadEventFile({
    required String dspUid,
    required String plateNumber,
    required String eventId,
    required Uint8List fileBytes,
    required String originalFileName,
    required String fileType,
  }) async {
    final safeFileName = originalFileName.trim();
    if (safeFileName.isEmpty) {
      throw const FleetVehicleAccidentEventException('File name is required.');
    }
    final ref = _storage
        .ref()
        .child('vehicles')
        .child(dspUid)
        .child(normalizePlateNumber(plateNumber))
        .child('events')
        .child('${eventId}_$safeFileName');
    await ref.putData(
      fileBytes,
      fb_storage.SettableMetadata(
        contentType: _contentTypeForFileType(fileType, safeFileName),
      ),
    );
    final url = await ref.getDownloadURL();
    return FleetVehicleAccidentUploadResult(
      fileUrl: url,
      storagePath: ref.fullPath,
    );
  }

  void _validateDraft(FleetVehicleAccidentEventDraft draft) {
    if (draft.title.trim().isEmpty) {
      throw const FleetVehicleAccidentEventException('Title is required.');
    }
    if (!isValidVehicleDate(draft.eventDate)) {
      throw const FleetVehicleAccidentEventException(
        'Event date must use YYYY-MM-DD.',
      );
    }
    if (draft.fileName.trim().isNotEmpty && draft.fileType.trim().isEmpty) {
      throw const FleetVehicleAccidentEventException('File type is required.');
    }
  }

  String _contentTypeForFileType(String fileType, String fileName) {
    final normalizedType = fileType.trim().toUpperCase();
    if (normalizedType == 'PDF' || fileName.toLowerCase().endsWith('.pdf')) {
      return 'application/pdf';
    }
    if (normalizedType == 'PNG' || fileName.toLowerCase().endsWith('.png')) {
      return 'image/png';
    }
    if (normalizedType == 'JPG' ||
        normalizedType == 'JPEG' ||
        normalizedType == 'IMAGE' ||
        fileName.toLowerCase().endsWith('.jpg') ||
        fileName.toLowerCase().endsWith('.jpeg') ||
        fileName.toLowerCase().endsWith('.webp')) {
      return 'image/jpeg';
    }
    return 'application/octet-stream';
  }
}
