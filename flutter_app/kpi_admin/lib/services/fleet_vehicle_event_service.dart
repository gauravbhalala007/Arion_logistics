import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/fleet_vehicle_event.dart';
import 'fleet_vehicle_event_repository.dart';

class FleetVehicleEventService {
  FleetVehicleEventService({
    FleetVehicleEventRepository? repository,
  }) : _repository = repository ?? FleetVehicleEventRepository();

  final FleetVehicleEventRepository _repository;

  Stream<List<FleetVehicleEvent>> watchEvents({
    required String dspUid,
    required String plateNumber,
    String orderByField = 'eventDate',
    bool descending = true,
    String? eventType,
  }) {
    return _repository.watchEvents(
      dspUid: dspUid,
      plateNumber: plateNumber,
      orderByField: orderByField,
      descending: descending,
      eventType: eventType,
    );
  }

  Future<FleetVehicleEventPage> getEventsPage({
    required String dspUid,
    required String plateNumber,
    int limit = 20,
    String orderByField = 'eventDate',
    bool descending = true,
    String? searchQuery,
    String? eventType,
    DocumentSnapshot<Map<String, dynamic>>? startAfterDocument,
  }) {
    return _repository.getEventsPage(
      dspUid: dspUid,
      plateNumber: plateNumber,
      limit: limit,
      orderByField: orderByField,
      descending: descending,
      searchQuery: searchQuery,
      eventType: eventType,
      startAfterDocument: startAfterDocument,
    );
  }

  Future<FleetVehicleEvent?> getEvent({
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

  Future<FleetVehicleEvent> createEvent({
    required String dspUid,
    required String plateNumber,
    required FleetVehicleEventDraft draft,
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
    required FleetVehicleEvent existingEvent,
    required FleetVehicleEventDraft draft,
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
