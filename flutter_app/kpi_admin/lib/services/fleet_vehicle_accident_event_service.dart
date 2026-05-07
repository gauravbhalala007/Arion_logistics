import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/fleet_vehicle_accident_event.dart';
import 'fleet_vehicle_accident_event_repository.dart';

class FleetVehicleAccidentEventService {
  FleetVehicleAccidentEventService({
    FleetVehicleAccidentEventRepository? repository,
  }) : _repository = repository ?? FleetVehicleAccidentEventRepository();

  final FleetVehicleAccidentEventRepository _repository;

  Stream<List<FleetVehicleAccidentEvent>> watchEvents({
    required String dspUid,
    required String plateNumber,
    String orderByField = 'eventDate',
    bool descending = true,
  }) {
    return _repository.watchEvents(
      dspUid: dspUid,
      plateNumber: plateNumber,
      orderByField: orderByField,
      descending: descending,
    );
  }

  Future<FleetVehicleAccidentEventPage> getEventsPage({
    required String dspUid,
    required String plateNumber,
    int limit = 20,
    String orderByField = 'eventDate',
    bool descending = true,
    String? searchQuery,
    DocumentSnapshot<Map<String, dynamic>>? startAfterDocument,
  }) {
    return _repository.getEventsPage(
      dspUid: dspUid,
      plateNumber: plateNumber,
      limit: limit,
      orderByField: orderByField,
      descending: descending,
      searchQuery: searchQuery,
      startAfterDocument: startAfterDocument,
    );
  }

  Future<FleetVehicleAccidentEvent?> getEvent({
    required String dspUid,
    required String plateNumber,
    required String eventId,
  }) {
    return _repository.getEvent(
      dspUid: dspUid,
      plateNumber: plateNumber,
      eventId: eventId,
    );
  }

  Future<FleetVehicleAccidentEvent> createEvent({
    required String dspUid,
    required String plateNumber,
    required FleetVehicleAccidentEventDraft draft,
    Uint8List? fileBytes,
    String? originalFileName,
  }) {
    return _repository.createEvent(
      dspUid: dspUid,
      plateNumber: plateNumber,
      draft: draft,
      fileBytes: fileBytes,
      originalFileName: originalFileName,
    );
  }

  Future<void> updateEvent({
    required String dspUid,
    required String plateNumber,
    required String eventId,
    required FleetVehicleAccidentEvent existingEvent,
    required FleetVehicleAccidentEventDraft draft,
    Uint8List? fileBytes,
    String? originalFileName,
  }) {
    return _repository.updateEvent(
      dspUid: dspUid,
      plateNumber: plateNumber,
      eventId: eventId,
      existingEvent: existingEvent,
      draft: draft,
      fileBytes: fileBytes,
      originalFileName: originalFileName,
    );
  }

  Future<void> softDeleteEvent({
    required String dspUid,
    required String plateNumber,
    required String eventId,
  }) {
    return _repository.softDeleteEvent(
      dspUid: dspUid,
      plateNumber: plateNumber,
      eventId: eventId,
    );
  }
}
