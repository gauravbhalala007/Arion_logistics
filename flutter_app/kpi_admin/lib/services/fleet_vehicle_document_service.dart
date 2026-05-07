import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/fleet_vehicle_document.dart';
import 'fleet_vehicle_document_repository.dart';

class FleetVehicleDocumentService {
  FleetVehicleDocumentService({
    FleetVehicleDocumentRepository? repository,
  }) : _repository = repository ?? FleetVehicleDocumentRepository();

  final FleetVehicleDocumentRepository _repository;

  Stream<List<FleetVehicleDocument>> watchDocuments({
    required String dspUid,
    required String plateNumber,
    String orderByField = 'updatedAt',
    bool descending = true,
  }) {
    return _repository.watchDocuments(
      dspUid: dspUid,
      plateNumber: plateNumber,
      orderByField: orderByField,
      descending: descending,
    );
  }

  Stream<List<FleetVehicleDocument>> watchScopeDocuments({
    required String dspUid,
  }) {
    return _repository.watchScopeDocuments(dspUid: dspUid);
  }

  Future<FleetVehicleDocumentPage> getDocumentsPage({
    required String dspUid,
    required String plateNumber,
    int limit = 20,
    String orderByField = 'updatedAt',
    bool descending = true,
    String? searchQuery,
    DocumentSnapshot<Map<String, dynamic>>? startAfterDocument,
  }) {
    return _repository.getDocumentsPage(
      dspUid: dspUid,
      plateNumber: plateNumber,
      limit: limit,
      orderByField: orderByField,
      descending: descending,
      searchQuery: searchQuery,
      startAfterDocument: startAfterDocument,
    );
  }

  Future<FleetVehicleDocument?> getDocument({
    required String dspUid,
    required String plateNumber,
    required String documentId,
  }) {
    return _repository.getDocument(
      dspUid: dspUid,
      plateNumber: plateNumber,
      documentId: documentId,
    );
  }

  Future<FleetVehicleDocument> createDocument({
    required String dspUid,
    required String plateNumber,
    required FleetVehicleDocumentDraft draft,
    required Uint8List fileBytes,
    required String originalFileName,
  }) {
    return _repository.createDocument(
      dspUid: dspUid,
      plateNumber: plateNumber,
      draft: draft,
      fileBytes: fileBytes,
      originalFileName: originalFileName,
    );
  }

  Future<void> updateDocument({
    required String dspUid,
    required String plateNumber,
    required String documentId,
    required FleetVehicleDocument existingDocument,
    required FleetVehicleDocumentDraft draft,
    Uint8List? fileBytes,
    String? originalFileName,
  }) {
    return _repository.updateDocument(
      dspUid: dspUid,
      plateNumber: plateNumber,
      documentId: documentId,
      existingDocument: existingDocument,
      draft: draft,
      fileBytes: fileBytes,
      originalFileName: originalFileName,
    );
  }

  Future<void> softDeleteDocument({
    required String dspUid,
    required String plateNumber,
    required String documentId,
  }) {
    return _repository.softDeleteDocument(
      dspUid: dspUid,
      plateNumber: plateNumber,
      documentId: documentId,
    );
  }

  FleetVehicleDocumentStatus getDocumentStatus({
    required String expiryDate,
    required String fileUrl,
    DateTime? currentDate,
  }) {
    if (fileUrl.trim().isEmpty) {
      return FleetVehicleDocumentStatus.missing;
    }

    final now = currentDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final parsedExpiry = DateTime.tryParse(expiryDate.trim());
    if (parsedExpiry == null) {
      return FleetVehicleDocumentStatus.missing;
    }

    final normalizedExpiry = DateTime(
      parsedExpiry.year,
      parsedExpiry.month,
      parsedExpiry.day,
    );

    if (normalizedExpiry.isBefore(today)) {
      return FleetVehicleDocumentStatus.expired;
    }

    final expiringSoonThreshold = today.add(const Duration(days: 30));
    if (!normalizedExpiry.isAfter(expiringSoonThreshold)) {
      return FleetVehicleDocumentStatus.expiringSoon;
    }

    return FleetVehicleDocumentStatus.active;
  }
}
