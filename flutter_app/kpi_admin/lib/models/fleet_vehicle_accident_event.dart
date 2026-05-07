import 'package:cloud_firestore/cloud_firestore.dart';

class FleetVehicleAccidentEvent {
  const FleetVehicleAccidentEvent({
    required this.eventId,
    required this.dspUid,
    required this.plateNumber,
    required this.eventType,
    required this.title,
    required this.eventDate,
    required this.metadata,
    required this.fileUrl,
    required this.fileName,
    required this.fileType,
    required this.notes,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  final String eventId;
  final String dspUid;
  final String plateNumber;
  final String eventType;
  final String title;
  final String eventDate;
  final Map<String, dynamic> metadata;
  final String fileUrl;
  final String fileName;
  final String fileType;
  final String notes;
  final bool isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory FleetVehicleAccidentEvent.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return FleetVehicleAccidentEvent.fromMap(doc.id, doc.data() ?? const {});
  }

  factory FleetVehicleAccidentEvent.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    final rawMetadata = data['metadata'];
    return FleetVehicleAccidentEvent(
      eventId: (data['eventId'] ?? id).toString(),
      dspUid: (data['dspUid'] ?? '').toString(),
      plateNumber: (data['plateNumber'] ?? '').toString(),
      eventType: (data['eventType'] ?? 'ACCIDENT').toString(),
      title: (data['title'] ?? '').toString(),
      eventDate: (data['eventDate'] ?? '').toString(),
      metadata: rawMetadata is Map<String, dynamic>
          ? rawMetadata
          : Map<String, dynamic>.from(rawMetadata as Map? ?? const {}),
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

class FleetVehicleAccidentEventDraft {
  const FleetVehicleAccidentEventDraft({
    required this.title,
    required this.eventDate,
    required this.metadata,
    required this.fileName,
    required this.fileType,
    required this.notes,
  });

  final String title;
  final String eventDate;
  final Map<String, dynamic> metadata;
  final String fileName;
  final String fileType;
  final String notes;
}

class FleetVehicleAccidentEventPage {
  const FleetVehicleAccidentEventPage({
    required this.items,
    required this.lastDocument,
  });

  final List<FleetVehicleAccidentEvent> items;
  final DocumentSnapshot<Map<String, dynamic>>? lastDocument;
}
