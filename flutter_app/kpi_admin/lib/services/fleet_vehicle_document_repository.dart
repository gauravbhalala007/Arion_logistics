import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as fb_storage;

import '../models/fleet_vehicle.dart';
import '../models/fleet_vehicle_document.dart';

class FleetVehicleDocumentException implements Exception {
  const FleetVehicleDocumentException(this.message);

  final String message;

  @override
  String toString() => message;
}

class DuplicateVehicleDocumentTypeException implements Exception {
  const DuplicateVehicleDocumentTypeException(this.documentType);

  final String documentType;
}

class ImmutableVehicleDocumentTypeException implements Exception {
  const ImmutableVehicleDocumentTypeException(this.documentType);

  final String documentType;
}

class FleetVehicleDocumentUploadResult {
  const FleetVehicleDocumentUploadResult({
    required this.fileUrl,
    required this.storagePath,
  });

  final String fileUrl;
  final String storagePath;
}

class FleetVehicleDocumentRepository {
  FleetVehicleDocumentRepository({
    FirebaseFirestore? firestore,
    fb_storage.FirebaseStorage? storage,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? fb_storage.FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final fb_storage.FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> documentsCollection({
    required String dspUid,
    required String plateNumber,
  }) {
    return _firestore
        .collection('users')
        .doc(dspUid)
        .collection('vehicles')
        .doc(normalizePlateNumber(plateNumber))
        .collection('documents');
  }

  Stream<List<FleetVehicleDocument>> watchDocuments({
    required String dspUid,
    required String plateNumber,
    String orderByField = 'updatedAt',
    bool descending = true,
  }) {
    return documentsCollection(dspUid: dspUid, plateNumber: plateNumber)
        .where('isDeleted', isEqualTo: false)
        .orderBy(orderByField, descending: descending)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(FleetVehicleDocument.fromDoc).toList(),
        );
  }

  Stream<List<FleetVehicleDocument>> watchScopeDocuments({
    required String dspUid,
  }) {
    late final StreamController<List<FleetVehicleDocument>> controller;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? vehiclesSubscription;
    final documentSubscriptions =
        <String, StreamSubscription<List<FleetVehicleDocument>>>{};
    final documentsByPlate = <String, List<FleetVehicleDocument>>{};

    void emit() {
      final items = documentsByPlate.values
          .expand((docs) => docs)
          .toList()
        ..sort((a, b) {
          final aDate = a.updatedAt ?? a.createdAt;
          final bDate = b.updatedAt ?? b.createdAt;
          if (aDate == null && bDate == null) return 0;
          if (aDate == null) return 1;
          if (bDate == null) return -1;
          return bDate.compareTo(aDate);
        });
      if (!controller.isClosed) {
        controller.add(items);
      }
    }

    Future<void> syncVehicleSubscriptions(
      QuerySnapshot<Map<String, dynamic>> snapshot,
    ) async {
      final activePlates = snapshot.docs
          .map((doc) => normalizePlateNumber(doc.id))
          .toSet();

      final removedPlates = documentSubscriptions.keys
          .where((plate) => !activePlates.contains(plate))
          .toList();
      for (final plate in removedPlates) {
        await documentSubscriptions.remove(plate)?.cancel();
        documentsByPlate.remove(plate);
      }

      for (final plate in activePlates) {
        if (documentSubscriptions.containsKey(plate)) continue;
        documentSubscriptions[plate] = watchDocuments(
          dspUid: dspUid,
          plateNumber: plate,
        ).listen(
          (docs) {
            documentsByPlate[plate] = docs;
            emit();
          },
          onError: (Object error, StackTrace stackTrace) {
            if (!controller.isClosed) {
              controller.addError(error, stackTrace);
            }
          },
        );
      }

      emit();
    }

    controller = StreamController<List<FleetVehicleDocument>>(
      onListen: () {
        vehiclesSubscription = _firestore
            .collection('users')
            .doc(dspUid)
            .collection('vehicles')
            .where('isDeleted', isEqualTo: false)
            .snapshots()
            .listen(
              (snapshot) {
                unawaited(syncVehicleSubscriptions(snapshot));
              },
              onError: (Object error, StackTrace stackTrace) {
                if (!controller.isClosed) {
                  controller.addError(error, stackTrace);
                }
              },
            );
      },
      onCancel: () async {
        await vehiclesSubscription?.cancel();
        for (final subscription in documentSubscriptions.values) {
          await subscription.cancel();
        }
        documentSubscriptions.clear();
        documentsByPlate.clear();
      },
    );

    return controller.stream;
  }

  Future<FleetVehicleDocument?> getDocument({
    required String dspUid,
    required String plateNumber,
    required String documentId,
  }) async {
    final snapshot = await documentsCollection(
      dspUid: dspUid,
      plateNumber: plateNumber,
    ).doc(documentId).get();
    if (!snapshot.exists) return null;
    final document = FleetVehicleDocument.fromDoc(snapshot);
    return document.isDeleted ? null : document;
  }

  Future<FleetVehicleDocumentPage> getDocumentsPage({
    required String dspUid,
    required String plateNumber,
    int limit = 20,
    String orderByField = 'updatedAt',
    bool descending = true,
    String? searchQuery,
    DocumentSnapshot<Map<String, dynamic>>? startAfterDocument,
  }) async {
    var query = documentsCollection(dspUid: dspUid, plateNumber: plateNumber)
        .where('isDeleted', isEqualTo: false)
        .orderBy(orderByField, descending: descending)
        .limit(limit);

    if (startAfterDocument != null) {
      query = query.startAfterDocument(startAfterDocument);
    }

    final snapshot = await query.get();
    final items = snapshot.docs.map(FleetVehicleDocument.fromDoc).where((doc) {
          final search = searchQuery?.trim().toLowerCase() ?? '';
          if (search.isEmpty) return true;
          return _documentSearchLabel(doc.documentType).contains(search);
        })
        .toList();

    return FleetVehicleDocumentPage(
      items: items,
      lastDocument: snapshot.docs.isEmpty ? null : snapshot.docs.last,
    );
  }

  Future<FleetVehicleDocument> createDocument({
    required String dspUid,
    required String plateNumber,
    required FleetVehicleDocumentDraft draft,
    required Uint8List fileBytes,
    required String originalFileName,
  }) async {
    _validateDraft(draft);
    final docsCol = documentsCollection(dspUid: dspUid, plateNumber: plateNumber);
    await _ensureUniqueActiveDocumentType(
      docsCol: docsCol,
      documentType: draft.documentType,
    );
    final docRef = docsCol.doc();
    final documentId = docRef.id;

    final upload = await uploadDocumentFile(
      dspUid: dspUid,
      plateNumber: plateNumber,
      documentId: documentId,
      fileBytes: fileBytes,
      originalFileName: originalFileName,
      fileType: draft.fileType,
    );

    try {
      await docRef.set({
        'documentId': documentId,
        'dspUid': dspUid,
        'plateNumber': normalizePlateNumber(plateNumber),
        'documentType': draft.documentType.trim(),
        'documentNumber': draft.documentNumber.trim(),
        'expiryDate': draft.expiryDate.trim(),
        'fileUrl': upload.fileUrl,
        'storagePath': upload.storagePath,
        'fileName': draft.fileName.trim(),
        'fileType': draft.fileType.trim(),
        'notes': draft.notes.trim(),
        'isDeleted': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      final created = await docRef.get();
      return FleetVehicleDocument.fromDoc(created);
    } catch (e) {
      try {
        await _storage.ref().child(upload.storagePath).delete();
      } catch (_) {}
      rethrow;
    }
  }

  Future<void> updateDocument({
    required String dspUid,
    required String plateNumber,
    required String documentId,
    required FleetVehicleDocument existingDocument,
    required FleetVehicleDocumentDraft draft,
    Uint8List? fileBytes,
    String? originalFileName,
  }) async {
    _validateDraft(draft);
    final existingType = _canonicalVehicleDocumentType(existingDocument.documentType);
    final requestedType = _canonicalVehicleDocumentType(draft.documentType);
    if (requestedType != existingType) {
      throw ImmutableVehicleDocumentTypeException(existingDocument.documentType);
    }

    var fileUrl = existingDocument.fileUrl;
    FleetVehicleDocumentUploadResult? upload;
    if (fileBytes != null &&
        originalFileName != null &&
        originalFileName.trim().isNotEmpty) {
      upload = await uploadDocumentFile(
        dspUid: dspUid,
        plateNumber: plateNumber,
        documentId: documentId,
        fileBytes: fileBytes,
        originalFileName: originalFileName,
        fileType: draft.fileType,
      );
      fileUrl = upload.fileUrl;
    }

    try {
      await documentsCollection(dspUid: dspUid, plateNumber: plateNumber)
          .doc(documentId)
          .update({
            'documentId': documentId,
            'dspUid': dspUid,
            'plateNumber': normalizePlateNumber(plateNumber),
            'documentType': existingDocument.documentType.trim(),
            'documentNumber': draft.documentNumber.trim(),
            'expiryDate': draft.expiryDate.trim(),
            'fileUrl': fileUrl,
            if (upload != null) 'storagePath': upload.storagePath,
            'fileName': draft.fileName.trim(),
            'fileType': draft.fileType.trim(),
            'notes': draft.notes.trim(),
            'isDeleted': false,
            'documentName': FieldValue.delete(),
            'issueDate': FieldValue.delete(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
      if (upload != null) {
        final oldStoragePath = _documentStoragePath(
          dspUid: dspUid,
          plateNumber: plateNumber,
          documentId: documentId,
          fileName: existingDocument.fileName,
        );
        if (oldStoragePath.isNotEmpty &&
            oldStoragePath != upload.storagePath) {
          try {
            await _storage.ref().child(oldStoragePath).delete();
          } catch (_) {}
        }
      }
    } catch (e) {
      if (upload != null) {
        try {
          await _storage.ref().child(upload.storagePath).delete();
        } catch (_) {}
      }
      rethrow;
    }
  }

  Future<void> _ensureUniqueActiveDocumentType({
    required CollectionReference<Map<String, dynamic>> docsCol,
    required String documentType,
  }) async {
    final requestedType = _canonicalVehicleDocumentType(documentType);
    final snapshot = await docsCol.where('isDeleted', isEqualTo: false).get();
    for (final doc in snapshot.docs) {
      final existing = FleetVehicleDocument.fromDoc(doc);
      final existingType = _canonicalVehicleDocumentType(existing.documentType);
      if (existingType == requestedType) {
        throw DuplicateVehicleDocumentTypeException(existing.documentType);
      }
    }
  }

  Future<void> softDeleteDocument({
    required String dspUid,
    required String plateNumber,
    required String documentId,
  }) async {
    await documentsCollection(dspUid: dspUid, plateNumber: plateNumber)
        .doc(documentId)
        .update({
          'isDeleted': true,
          'documentName': FieldValue.delete(),
          'issueDate': FieldValue.delete(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  Future<FleetVehicleDocumentUploadResult> uploadDocumentFile({
    required String dspUid,
    required String plateNumber,
    required String documentId,
    required Uint8List fileBytes,
    required String originalFileName,
    required String fileType,
  }) async {
    final safeFileName = originalFileName.trim();
    if (safeFileName.isEmpty) {
      throw const FleetVehicleDocumentException('File name is required.');
    }

    final ref = _storage
        .ref()
        .child(
          _documentStoragePath(
            dspUid: dspUid,
            plateNumber: plateNumber,
            documentId: documentId,
            fileName: safeFileName,
          ),
        );

    await ref.putData(
      fileBytes,
      fb_storage.SettableMetadata(
        contentType: _contentTypeForFileType(fileType, safeFileName),
      ),
    );
    final url = await ref.getDownloadURL();
    return FleetVehicleDocumentUploadResult(
      fileUrl: url,
      storagePath: ref.fullPath,
    );
  }

  void _validateDraft(FleetVehicleDocumentDraft draft) {
    if (draft.documentType.trim().isEmpty) {
      throw const FleetVehicleDocumentException('Document type is required.');
    }
    // Empty expiry is allowed — not every document type has an expiry
    // date (e.g. Fahrzeugschein scans).
    if (draft.expiryDate.trim().isNotEmpty &&
        !isValidVehicleDate(draft.expiryDate)) {
      throw const FleetVehicleDocumentException(
        'Expiry date must use YYYY-MM-DD.',
      );
    }
    if (draft.fileName.trim().isEmpty) {
      throw const FleetVehicleDocumentException('File name is required.');
    }
    if (draft.fileType.trim().isEmpty) {
      throw const FleetVehicleDocumentException('File type is required.');
    }
  }

  String _documentStoragePath({
    required String dspUid,
    required String plateNumber,
    required String documentId,
    required String fileName,
  }) {
    final trimmedFileName = fileName.trim();
    if (trimmedFileName.isEmpty) return '';
    return 'vehicles/'
        '$dspUid/'
        '${normalizePlateNumber(plateNumber)}/'
        'documents/'
        '${documentId}_$trimmedFileName';
  }

  String _canonicalVehicleDocumentType(String documentType) {
    final normalized = documentType.trim().toUpperCase();
    if (normalized == 'REGISTRATION_CERTIFICATE') {
      return 'FAHRZEUGSCHEIN';
    }
    if (normalized == 'TUV' ||
        normalized == 'TUV_CERTIFICATE' ||
        normalized == 'HU_TUV') {
      return 'HU_TUV_CERTIFICATE';
    }
    return normalized;
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
        fileName.toLowerCase().endsWith('.jpg') ||
        fileName.toLowerCase().endsWith('.jpeg')) {
      return 'image/jpeg';
    }
    if (normalizedType == 'WEBP' || fileName.toLowerCase().endsWith('.webp')) {
      return 'image/webp';
    }
    return 'application/octet-stream';
  }

  String _documentSearchLabel(String documentType) {
    final normalized = documentType.trim().toUpperCase();
    if (normalized.isEmpty) return '';
    if (normalized == 'FAHRZEUGSCHEIN' ||
        normalized == 'REGISTRATION_CERTIFICATE') {
      return 'fahrzeugschein';
    }
    return normalized.replaceAll('_', ' ').toLowerCase();
  }
}
