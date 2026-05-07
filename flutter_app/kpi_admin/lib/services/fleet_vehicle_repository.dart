import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/fleet_vehicle.dart';

class DuplicateVehicleException implements Exception {}

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
      transaction.set(docRef, _createPayload(dspUid, normalizedPlateNumber, draft));
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

  Future<void> softDeleteVehicle({
    required String dspUid,
    required String plateNumber,
  }) async {
    await vehiclesCollection(dspUid).doc(normalizePlateNumber(plateNumber)).update({
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
    }
  }
}
