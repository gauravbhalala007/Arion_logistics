import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/fleet_vehicle.dart';
import 'incident_reports.dart' show plateKeyOf;

class DuplicateVehicleException implements Exception {}

/// Ein einzelner Schreibvorgang des Kennzeichen-Umzugs.
class _PlateMoveWrite {
  const _PlateMoveWrite(this.ref, this.data);

  final DocumentReference<Map<String, dynamic>> ref;
  final Map<String, dynamic> data;
}

class ImmutablePlateNumberException implements Exception {}

class VehicleValidationException implements Exception {
  const VehicleValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class FleetVehicleRepository {
  FleetVehicleRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> vehiclesCollection(String dspUid) {
    return _firestore.collection('users').doc(dspUid).collection('vehicles');
  }

  Stream<List<FleetVehicle>> watchVehicles({required String dspUid}) {
    return vehiclesCollection(dspUid).snapshots().map(
      (snapshot) => snapshot.docs
          .map(FleetVehicle.fromDoc)
          .where((vehicle) => !vehicle.isDeleted)
          .toList(),
    );
  }

  Future<FleetVehicle?> getVehicle({
    required String dspUid,
    required String plateNumber,
  }) async {
    final snapshot = await vehiclesCollection(
      dspUid,
    ).doc(normalizePlateNumber(plateNumber)).get();
    if (!snapshot.exists) return null;
    final vehicle = FleetVehicle.fromDoc(snapshot);
    return vehicle.isDeleted ? null : vehicle;
  }

  Future<void> createVehicle({
    required String dspUid,
    required FleetVehicleDraft draft,
  }) async {
    _validateDraft(draft);
    final normalizedPlateNumber = normalizePlateNumber(draft.plateNumber);
    final docRef = vehiclesCollection(dspUid).doc(normalizedPlateNumber);

    await _firestore.runTransaction((transaction) async {
      final existing = await transaction.get(docRef);
      if (existing.exists) {
        throw DuplicateVehicleException();
      }
      transaction.set(
        docRef,
        _createPayload(dspUid, normalizedPlateNumber, draft),
      );
    });
  }

  Future<void> updateVehicle({
    required String dspUid,
    required String originalPlateNumber,
    required FleetVehicleDraft draft,
  }) async {
    _validateDraft(draft);
    final normalizedOriginal = normalizePlateNumber(originalPlateNumber);
    final normalizedDraftPlate = normalizePlateNumber(draft.plateNumber);
    if (normalizedOriginal != normalizedDraftPlate) {
      throw ImmutablePlateNumberException();
    }

    final payload = <String, dynamic>{
      'dspUid': dspUid,
      'plateNumber': normalizedOriginal,
      'category': draft.category.value,
      'brand': draft.brand.trim(),
      'model': draft.model.trim(),
      'manufacturingYear': draft.manufacturingYear,
      'vinNumber': draft.vinNumber.trim(),
      'fuelType': draft.fuelType.value,
      'status': draft.status.value,
      'metadata': draft.metadata.toMap(),
      'notes': draft.notes.trim(),
      'isDeleted': false,
      'odometerKm': FieldValue.delete(),
      'registrationDate': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    final serviceEndDate = draft.serviceEndDate.trim();
    payload['serviceEndDate'] = serviceEndDate.isEmpty
        ? FieldValue.delete()
        : serviceEndDate;

    await vehiclesCollection(dspUid).doc(normalizedOriginal).update(payload);
  }

  Future<void> updateVehicleStatus({
    required String dspUid,
    required String plateNumber,
    required VehicleStatus status,
    String? serviceEndDate,
  }) async {
    final payload = <String, dynamic>{
      'status': status.value,
      'isDeleted': false,
      'odometerKm': FieldValue.delete(),
      'registrationDate': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (serviceEndDate != null) {
      final normalizedServiceEndDate = serviceEndDate.trim();
      payload['serviceEndDate'] = normalizedServiceEndDate.isEmpty
          ? FieldValue.delete()
          : normalizedServiceEndDate;
    }

    await vehiclesCollection(
      dspUid,
    ).doc(normalizePlateNumber(plateNumber)).update(payload);
  }

  // ─── Kennzeichen-Umzug ───────────────────────────────────────────────
  //
  // Die Doc-ID eines Fahrzeugs **ist** das normalisierte Kennzeichen. Ein
  // neues Kennzeichen bedeutet deshalb einen echten Umzug aller daran
  // hängenden Daten:
  //
  //   users/{dsp}/vehicles/{plate}                 (Stammdaten)
  //   users/{dsp}/vehicles/{plate}/documents/*     (TÜV, Fahrzeugschein, …)
  //   users/{dsp}/vehicles/{plate}/events/*        (Bestands-Events)
  //   users/{dsp}/fleet_vehicle_extras/{plate}     (Werkstatt, Bemerkungen,
  //                                                 Leasinggeber, Specs)
  //   users/{dsp}/fleet_events  (plateKey == alt)  (neue Fahrzeug-Events)
  //
  // Bewusst **nicht** mitgezogen: `users/{dsp}/incident_reports`. Vorfälle
  // sind historische Ereignisse und bleiben beim damals gültigen
  // Kennzeichen — der Schadenszähler auf der Detailseite zählt danach nur
  // noch neue Vorfälle.
  //
  // Storage bleibt unangetastet: Dokumente behalten `storagePath` und
  // `fileUrl`, nur die Firestore-Metadaten wandern mit.

  /// Verschiebt ein Fahrzeug samt Anhang auf ein neues Kennzeichen.
  ///
  /// Ablauf strikt „erst vollständig kopieren, dann löschen": schlägt das
  /// Kopieren fehl, wird das bereits Kopierte best-effort wieder entfernt und
  /// der Altbestand bleibt unberührt.
  ///
  /// Wirft [DuplicateVehicleException], wenn unter dem Zielkennzeichen bereits
  /// ein aktives Fahrzeug liegt, und [VehicleValidationException] bei
  /// ungültiger oder unveränderter Eingabe.
  Future<void> changePlateNumber({
    required String dspUid,
    required String fromPlateNumber,
    required String toPlateNumber,
  }) async {
    final from = normalizePlateNumber(fromPlateNumber);
    final to = normalizePlateNumber(toPlateNumber);

    if (to.isEmpty) {
      throw const VehicleValidationException('Plate number is required.');
    }
    if (from == to) return;

    final vehicles = vehiclesCollection(dspUid);
    final sourceRef = vehicles.doc(from);
    final targetRef = vehicles.doc(to);

    final source = await sourceRef.get();
    if (!source.exists) {
      throw const VehicleValidationException('Vehicle not found.');
    }

    final existingTarget = await targetRef.get();
    if (existingTarget.exists && existingTarget.data()?['isDeleted'] != true) {
      throw DuplicateVehicleException();
    }

    final documents = await sourceRef.collection('documents').get();
    final events = await sourceRef.collection('events').get();
    final extrasSource = _extrasCollection(dspUid).doc(from);
    final extras = await extrasSource.get();

    // Neue Fahrzeug-Events hängen nicht an der Doc-ID, sondern am `plateKey`.
    final fleetEvents = await _fleetEventsCollection(
      dspUid,
    ).where('plateKey', isEqualTo: plateKeyOf(from)).get();

    // Für das Aufräumen nach einem Teilfehler.
    final written = <DocumentReference<Map<String, dynamic>>>[];

    try {
      final writes = <_PlateMoveWrite>[
        _PlateMoveWrite(targetRef, {
          ...source.data() ?? const <String, dynamic>{},
          'plateNumber': to,
          'updatedAt': FieldValue.serverTimestamp(),
        }),
        for (final doc in documents.docs)
          _PlateMoveWrite(targetRef.collection('documents').doc(doc.id), {
            ...doc.data(),
            'plateNumber': to,
          }),
        for (final doc in events.docs)
          _PlateMoveWrite(targetRef.collection('events').doc(doc.id), {
            ...doc.data(),
            'plateNumber': to,
          }),
        if (extras.exists)
          _PlateMoveWrite(_extrasCollection(dspUid).doc(to), {
            ...extras.data() ?? const <String, dynamic>{},
            'plateNumber': to,
            'updatedAt': FieldValue.serverTimestamp(),
          }),
      ];

      for (final chunk in _chunk(writes, _kBatchLimit)) {
        final batch = _firestore.batch();
        for (final write in chunk) {
          batch.set(write.ref, write.data);
          written.add(write.ref);
        }
        await batch.commit();
      }
    } catch (_) {
      // Kopie unvollständig → Zielpfad best-effort wieder räumen, damit ein
      // erneuter Versuch nicht am Duplikat-Check scheitert. Der Altbestand
      // wurde noch nicht angefasst.
      for (final chunk in _chunk(written, _kBatchLimit)) {
        try {
          final batch = _firestore.batch();
          for (final ref in chunk) {
            batch.delete(ref);
          }
          await batch.commit();
        } catch (_) {
          // Aufräumen ist Kür — der Fehler unten ist die Hauptmeldung.
        }
      }
      rethrow;
    }

    // `fleet_events` zieht per Update um (die Doc-IDs bleiben, nur der
    // Schlüssel ändert sich) — deshalb erst nach der erfolgreichen Kopie.
    for (final chunk in _chunk(fleetEvents.docs, _kBatchLimit)) {
      final batch = _firestore.batch();
      for (final doc in chunk) {
        batch.update(doc.reference, <String, dynamic>{
          'plateKey': plateKeyOf(to),
          'plate': to,
        });
      }
      await batch.commit();
    }

    // Jetzt erst der Altbestand.
    final deletions = <DocumentReference<Map<String, dynamic>>>[
      for (final doc in documents.docs) doc.reference,
      for (final doc in events.docs) doc.reference,
      if (extras.exists) extrasSource,
      sourceRef,
    ];
    for (final chunk in _chunk(deletions, _kBatchLimit)) {
      final batch = _firestore.batch();
      for (final ref in chunk) {
        batch.delete(ref);
      }
      await batch.commit();
    }
  }

  CollectionReference<Map<String, dynamic>> _extrasCollection(String dspUid) {
    return _firestore
        .collection('users')
        .doc(dspUid)
        .collection('fleet_vehicle_extras');
  }

  CollectionReference<Map<String, dynamic>> _fleetEventsCollection(
    String dspUid,
  ) {
    return _firestore
        .collection('users')
        .doc(dspUid)
        .collection('fleet_events');
  }

  /// Firestore erlaubt 500 Schreibvorgänge je Batch — mit etwas Luft.
  static const int _kBatchLimit = 400;

  static Iterable<List<T>> _chunk<T>(List<T> items, int size) sync* {
    for (var i = 0; i < items.length; i += size) {
      yield items.sublist(i, i + size > items.length ? items.length : i + size);
    }
  }

  Future<void> softDeleteVehicle({
    required String dspUid,
    required String plateNumber,
  }) async {
    await vehiclesCollection(
      dspUid,
    ).doc(normalizePlateNumber(plateNumber)).update({
      'isDeleted': true,
      'odometerKm': FieldValue.delete(),
      'registrationDate': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Map<String, dynamic> _createPayload(
    String dspUid,
    String plateNumber,
    FleetVehicleDraft draft,
  ) {
    final payload = <String, dynamic>{
      'dspUid': dspUid,
      'plateNumber': plateNumber,
      'category': draft.category.value,
      'brand': draft.brand.trim(),
      'model': draft.model.trim(),
      'manufacturingYear': draft.manufacturingYear,
      'vinNumber': draft.vinNumber.trim(),
      'fuelType': draft.fuelType.value,
      'status': draft.status.value,
      'metadata': draft.metadata.toMap(),
      'notes': draft.notes.trim(),
      'isDeleted': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    final serviceEndDate = draft.serviceEndDate.trim();
    if (serviceEndDate.isNotEmpty) {
      payload['serviceEndDate'] = serviceEndDate;
    }
    return payload;
  }

  void _validateDraft(FleetVehicleDraft draft) {
    if (normalizePlateNumber(draft.plateNumber).isEmpty) {
      throw const VehicleValidationException('Plate number is required.');
    }
    if (draft.brand.trim().isEmpty) {
      throw const VehicleValidationException('Brand is required.');
    }
    if (draft.model.trim().isEmpty) {
      throw const VehicleValidationException('Model is required.');
    }
    if (draft.manufacturingYear <= 0) {
      throw const VehicleValidationException('Manufacturing year is required.');
    }
    if (draft.vinNumber.trim().isEmpty) {
      throw const VehicleValidationException('VIN number is required.');
    }
    _validateMetadata(draft.category, draft.metadata);
  }

  void _validateMetadata(VehicleCategory category, VehicleMetadata metadata) {
    switch (category) {
      case VehicleCategory.armada:
        final value = metadata is ArmadaVehicleMetadata
            ? metadata
            : const ArmadaVehicleMetadata();
        if (value.armadaId.trim().isEmpty ||
            value.armadaCompanyName.trim().isEmpty ||
            !isValidVehicleDate(value.contractStartDate) ||
            !isValidVehicleDate(value.contractEndDate)) {
          throw const VehicleValidationException(
            'Armada metadata is incomplete.',
          );
        }
        break;
      case VehicleCategory.amazonPaidRental:
        final value = metadata is AmazonPaidRentalMetadata
            ? metadata
            : const AmazonPaidRentalMetadata();
        if (value.rentalCompanyName.trim().isEmpty ||
            value.contractNumber.trim().isEmpty ||
            !isValidVehicleDate(value.rentalStartDate) ||
            !isValidVehicleDate(value.rentalEndDate)) {
          throw const VehicleValidationException(
            'Amazon paid rental metadata is incomplete.',
          );
        }
        break;
      case VehicleCategory.selfSourcedRental:
        final value = metadata is SelfSourcedRentalMetadata
            ? metadata
            : const SelfSourcedRentalMetadata();
        if (value.ownerName.trim().isEmpty ||
            value.ownerContactNumber.trim().isEmpty ||
            value.rentalAgreementNumber.trim().isEmpty ||
            !isValidVehicleDate(value.rentalStartDate) ||
            !isValidVehicleDate(value.rentalEndDate)) {
          throw const VehicleValidationException(
            'Self sourced rental metadata is incomplete.',
          );
        }
        break;
      case VehicleCategory.selfOwnedRental:
        final value = metadata is SelfOwnedRentalMetadata
            ? metadata
            : const SelfOwnedRentalMetadata();
        if (value.ownershipType.trim().isEmpty ||
            !isValidVehicleDate(value.purchaseDate)) {
          throw const VehicleValidationException(
            'Self owned rental metadata is incomplete.',
          );
        }
        break;
      case VehicleCategory.lmr:
      case VehicleCategory.sesoRental:
        // Generic categories carry no extra metadata to validate.
        break;
    }
  }
}
