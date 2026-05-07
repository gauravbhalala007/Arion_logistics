import 'package:cloud_firestore/cloud_firestore.dart';

enum FleetVehicleDocumentStatus {
  active('ACTIVE'),
  expiringSoon('EXPIRING_SOON'),
  expired('EXPIRED'),
  missing('MISSING');

  const FleetVehicleDocumentStatus(this.value);

  final String value;
}

class FleetVehicleDocument {
  const FleetVehicleDocument({
    required this.documentId,
    required this.dspUid,
    required this.plateNumber,
    required this.documentType,
    required this.documentNumber,
    required this.expiryDate,
    required this.fileUrl,
    required this.fileName,
    required this.fileType,
    required this.notes,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  final String documentId;
  final String dspUid;
  final String plateNumber;
  final String documentType;
  final String documentNumber;
  final String expiryDate;
  final String fileUrl;
  final String fileName;
  final String fileType;
  final String notes;
  final bool isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory FleetVehicleDocument.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return FleetVehicleDocument.fromMap(doc.id, doc.data() ?? const {});
  }

  factory FleetVehicleDocument.fromMap(String id, Map<String, dynamic> data) {
    return FleetVehicleDocument(
      documentId: (data['documentId'] ?? id).toString(),
      dspUid: (data['dspUid'] ?? '').toString(),
      plateNumber: (data['plateNumber'] ?? '').toString(),
      documentType: (data['documentType'] ?? '').toString(),
      documentNumber: (data['documentNumber'] ?? '').toString(),
      expiryDate: (data['expiryDate'] ?? '').toString(),
      fileUrl: (data['fileUrl'] ?? '').toString(),
      fileName: (data['fileName'] ?? '').toString(),
      fileType: (data['fileType'] ?? '').toString(),
      notes: (data['notes'] ?? '').toString(),
      isDeleted: data['isDeleted'] == true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}

class FleetVehicleDocumentDraft {
  const FleetVehicleDocumentDraft({
    required this.documentType,
    required this.documentNumber,
    required this.expiryDate,
    required this.fileName,
    required this.fileType,
    required this.notes,
  });

  final String documentType;
  final String documentNumber;
  final String expiryDate;
  final String fileName;
  final String fileType;
  final String notes;
}

class FleetVehicleDocumentPage {
  const FleetVehicleDocumentPage({
    required this.items,
    required this.lastDocument,
  });

  final List<FleetVehicleDocument> items;
  final DocumentSnapshot<Map<String, dynamic>>? lastDocument;
}
