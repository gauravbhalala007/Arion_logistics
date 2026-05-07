import 'package:cloud_firestore/cloud_firestore.dart';

enum VehicleCategory {
  armada('ARMADA'),
  amazonPaidRental('AMAZON_PAID_RENTAL'),
  selfSourcedRental('SELF_SOURCED_RENTAL'),
  selfOwnedRental('SELF_OWNED_RENTAL');

  const VehicleCategory(this.value);

  final String value;

  static VehicleCategory fromFirestore(dynamic value) {
    final normalized = (value ?? '').toString().trim().toUpperCase();
    switch (normalized) {
      case 'AMAZON_PAID_RENTAL':
        return VehicleCategory.amazonPaidRental;
      case 'SELF_SOURCED_RENTAL':
        return VehicleCategory.selfSourcedRental;
      case 'SELF_OWNED_RENTAL':
        return VehicleCategory.selfOwnedRental;
      case 'ARMADA':
      default:
        return VehicleCategory.armada;
    }
  }
}

enum VehicleFuelType {
  diesel('DIESEL'),
  petrol('PETROL'),
  electric('ELECTRIC'),
  hybrid('HYBRID');

  const VehicleFuelType(this.value);

  final String value;

  static VehicleFuelType fromFirestore(dynamic value) {
    final normalized = (value ?? '').toString().trim().toUpperCase();
    switch (normalized) {
      case 'PETROL':
        return VehicleFuelType.petrol;
      case 'ELECTRIC':
        return VehicleFuelType.electric;
      case 'HYBRID':
        return VehicleFuelType.hybrid;
      case 'DIESEL':
      default:
        return VehicleFuelType.diesel;
    }
  }
}

enum VehicleStatus {
  active('ACTIVE'),
  grounded('GROUNDED'),
  inService('IN_SERVICE'),
  defleeted('DEFLEETED');

  const VehicleStatus(this.value);

  final String value;

  static VehicleStatus fromFirestore(dynamic value) {
    final normalized = (value ?? '').toString().trim().toUpperCase();
    switch (normalized) {
      case 'GROUNDED':
        return VehicleStatus.grounded;
      case 'IN_SERVICE':
        return VehicleStatus.inService;
      case 'DEFLEETED':
        return VehicleStatus.defleeted;
      case 'ACTIVE':
      default:
        return VehicleStatus.active;
    }
  }
}

abstract class VehicleMetadata {
  const VehicleMetadata();

  Map<String, dynamic> toMap();

  static VehicleMetadata emptyFor(VehicleCategory category) {
    switch (category) {
      case VehicleCategory.armada:
        return const ArmadaVehicleMetadata();
      case VehicleCategory.amazonPaidRental:
        return const AmazonPaidRentalMetadata();
      case VehicleCategory.selfSourcedRental:
        return const SelfSourcedRentalMetadata();
      case VehicleCategory.selfOwnedRental:
        return const SelfOwnedRentalMetadata();
    }
  }

  static VehicleMetadata fromFirestore(
    VehicleCategory category,
    dynamic raw,
  ) {
    final map = raw is Map<String, dynamic>
        ? raw
        : Map<String, dynamic>.from(raw as Map? ?? const <String, dynamic>{});
    switch (category) {
      case VehicleCategory.armada:
        return ArmadaVehicleMetadata.fromMap(map);
      case VehicleCategory.amazonPaidRental:
        return AmazonPaidRentalMetadata.fromMap(map);
      case VehicleCategory.selfSourcedRental:
        return SelfSourcedRentalMetadata.fromMap(map);
      case VehicleCategory.selfOwnedRental:
        return SelfOwnedRentalMetadata.fromMap(map);
    }
  }
}

class ArmadaVehicleMetadata extends VehicleMetadata {
  const ArmadaVehicleMetadata({
    this.armadaId = '',
    this.armadaCompanyName = '',
    this.contractStartDate = '',
    this.contractEndDate = '',
  });

  final String armadaId;
  final String armadaCompanyName;
  final String contractStartDate;
  final String contractEndDate;

  factory ArmadaVehicleMetadata.fromMap(Map<String, dynamic> map) {
    return ArmadaVehicleMetadata(
      armadaId: (map['armadaId'] ?? '').toString(),
      armadaCompanyName: (map['armadaCompanyName'] ?? '').toString(),
      contractStartDate: (map['contractStartDate'] ?? '').toString(),
      contractEndDate: (map['contractEndDate'] ?? '').toString(),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'armadaId': armadaId.trim(),
      'armadaCompanyName': armadaCompanyName.trim(),
      'contractStartDate': contractStartDate.trim(),
      'contractEndDate': contractEndDate.trim(),
    };
  }
}

class AmazonPaidRentalMetadata extends VehicleMetadata {
  const AmazonPaidRentalMetadata({
    this.rentalCompanyName = '',
    this.contractNumber = '',
    this.rentalStartDate = '',
    this.rentalEndDate = '',
  });

  final String rentalCompanyName;
  final String contractNumber;
  final String rentalStartDate;
  final String rentalEndDate;

  factory AmazonPaidRentalMetadata.fromMap(Map<String, dynamic> map) {
    return AmazonPaidRentalMetadata(
      rentalCompanyName: (map['rentalCompanyName'] ?? '').toString(),
      contractNumber: (map['contractNumber'] ?? '').toString(),
      rentalStartDate: (map['rentalStartDate'] ?? '').toString(),
      rentalEndDate: (map['rentalEndDate'] ?? '').toString(),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'rentalCompanyName': rentalCompanyName.trim(),
      'contractNumber': contractNumber.trim(),
      'rentalStartDate': rentalStartDate.trim(),
      'rentalEndDate': rentalEndDate.trim(),
    };
  }
}

class SelfSourcedRentalMetadata extends VehicleMetadata {
  const SelfSourcedRentalMetadata({
    this.ownerName = '',
    this.ownerContactNumber = '',
    this.rentalAgreementNumber = '',
    this.rentalStartDate = '',
    this.rentalEndDate = '',
  });

  final String ownerName;
  final String ownerContactNumber;
  final String rentalAgreementNumber;
  final String rentalStartDate;
  final String rentalEndDate;

  factory SelfSourcedRentalMetadata.fromMap(Map<String, dynamic> map) {
    return SelfSourcedRentalMetadata(
      ownerName: (map['ownerName'] ?? '').toString(),
      ownerContactNumber: (map['ownerContactNumber'] ?? '').toString(),
      rentalAgreementNumber: (map['rentalAgreementNumber'] ?? '').toString(),
      rentalStartDate: (map['rentalStartDate'] ?? '').toString(),
      rentalEndDate: (map['rentalEndDate'] ?? '').toString(),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'ownerName': ownerName.trim(),
      'ownerContactNumber': ownerContactNumber.trim(),
      'rentalAgreementNumber': rentalAgreementNumber.trim(),
      'rentalStartDate': rentalStartDate.trim(),
      'rentalEndDate': rentalEndDate.trim(),
    };
  }
}

class SelfOwnedRentalMetadata extends VehicleMetadata {
  const SelfOwnedRentalMetadata({
    this.ownershipType = '',
    this.purchaseDate = '',
  });

  final String ownershipType;
  final String purchaseDate;

  factory SelfOwnedRentalMetadata.fromMap(Map<String, dynamic> map) {
    return SelfOwnedRentalMetadata(
      ownershipType: (map['ownershipType'] ?? '').toString(),
      purchaseDate: (map['purchaseDate'] ?? '').toString(),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'ownershipType': ownershipType.trim(),
      'purchaseDate': purchaseDate.trim(),
    };
  }
}

class FleetVehicle {
  const FleetVehicle({
    required this.dspUid,
    required this.plateNumber,
    required this.category,
    required this.brand,
    required this.model,
    required this.manufacturingYear,
    required this.vinNumber,
    required this.fuelType,
    required this.status,
    required this.serviceEndDate,
    required this.metadata,
    required this.notes,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  final String dspUid;
  final String plateNumber;
  final VehicleCategory category;
  final String brand;
  final String model;
  final int manufacturingYear;
  final String vinNumber;
  final VehicleFuelType fuelType;
  final VehicleStatus status;
  final String serviceEndDate;
  final VehicleMetadata metadata;
  final String notes;
  final bool isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory FleetVehicle.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return FleetVehicle.fromMap(doc.id, doc.data() ?? const <String, dynamic>{});
  }

  factory FleetVehicle.fromMap(String id, Map<String, dynamic> data) {
    final category = VehicleCategory.fromFirestore(
      data['category'] ?? _legacyCategory(data['fleetType']),
    );
    return FleetVehicle(
      dspUid: (data['dspUid'] ?? '').toString(),
      plateNumber: normalizePlateNumber(
        (data['plateNumber'] ?? data['vehicleNumber'] ?? id).toString(),
      ),
      category: category,
      brand: (data['brand'] ?? '').toString(),
      model: (data['model'] ?? '').toString(),
      manufacturingYear: _intOrZero(data['manufacturingYear']),
      vinNumber: (data['vinNumber'] ?? '').toString(),
      fuelType: VehicleFuelType.fromFirestore(data['fuelType']),
      status: VehicleStatus.fromFirestore(data['status']),
      serviceEndDate: (data['serviceEndDate'] ?? '').toString(),
      metadata: VehicleMetadata.fromFirestore(category, data['metadata']),
      notes: (data['notes'] ?? '').toString(),
      isDeleted: data['isDeleted'] == true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}

class FleetVehicleDraft {
  const FleetVehicleDraft({
    required this.plateNumber,
    required this.category,
    required this.brand,
    required this.model,
    required this.manufacturingYear,
    required this.vinNumber,
    required this.fuelType,
    required this.status,
    required this.serviceEndDate,
    required this.metadata,
    required this.notes,
  });

  final String plateNumber;
  final VehicleCategory category;
  final String brand;
  final String model;
  final int manufacturingYear;
  final String vinNumber;
  final VehicleFuelType fuelType;
  final VehicleStatus status;
  final String serviceEndDate;
  final VehicleMetadata metadata;
  final String notes;
}

String normalizePlateNumber(String value) {
  return value.trim().toUpperCase();
}

bool isValidVehicleDate(String value) {
  final normalized = value.trim();
  return RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(normalized);
}

String _legacyCategory(dynamic value) {
  final normalized = (value ?? '').toString().trim().toLowerCase();
  switch (normalized) {
    case 'amazon_paid_rental':
      return 'AMAZON_PAID_RENTAL';
    case 'self_sourced_rental':
      return 'SELF_SOURCED_RENTAL';
    case 'self_owned_rental':
      return 'SELF_OWNED_RENTAL';
    case 'armada':
    default:
      return 'ARMADA';
  }
}

int _intOrZero(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse((value ?? '').toString()) ?? 0;
}
