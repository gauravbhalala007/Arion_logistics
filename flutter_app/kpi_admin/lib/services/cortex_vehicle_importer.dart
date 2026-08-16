// lib/services/cortex_vehicle_importer.dart
//
// Imports the DSP fleet from Amazon's Cortex `VehiclesData.xlsx`.
//
// Flow:
//   1. Pick file → parser_service /parse → list of vehicle dicts
//   2. Pre-fetch all existing vehicle docs for the DSP
//   3. Build dedup sets: existing VINs + existing plates
//   4. For each Cortex row: skip if VIN OR plate already exists,
//      otherwise create a new doc.
//   5. Return a small report (added, skipped, total).
//
// The dedup is INTENTIONALLY non-overwriting: re-uploading the same
// Cortex export on a later day will only add new vehicles, never
// touch existing ones. Edits made manually in the app stay safe.

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/fleet_vehicle.dart';
import 'parser_api.dart';

class CortexImportReport {
  final int total;
  final int added;
  final int skippedDuplicate;
  final int failed;
  final List<String> addedPlates;
  final List<String> duplicatePlates;
  /// Human-readable "PLATE: error" entries for vehicles that failed to write.
  final List<String> failures;

  const CortexImportReport({
    required this.total,
    required this.added,
    required this.skippedDuplicate,
    this.failed = 0,
    required this.addedPlates,
    required this.duplicatePlates,
    this.failures = const [],
  });
}

class CortexVehicleImporter {
  CortexVehicleImporter({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _vehiclesCollection(
    String dspUid,
  ) =>
      _db.collection('users').doc(dspUid).collection('vehicles');

  /// Maps Cortex `Eigentumstypus` (+ name/provider hints) → CoDriver
  /// [VehicleCategory]. SESO- and LMR-named vehicles land in their own
  /// categories; plain rentals default to SESO Rental.
  VehicleCategory _mapCategory(
    String ownershipType, {
    String fleetName = '',
    String vehicleProvider = '',
  }) {
    final hint = '${fleetName.toUpperCase()} ${vehicleProvider.toUpperCase()}';
    if (hint.contains('SESO')) return VehicleCategory.sesoRental;
    if (hint.contains('LMR') || hint.contains('LAST MILE')) {
      return VehicleCategory.lmr;
    }
    switch (ownershipType.trim().toUpperCase()) {
      case 'RENTAL':
        // Short-term rentals without an explicit hint are SESO rentals.
        return VehicleCategory.sesoRental;
      case 'SELF_OWNED':
      case 'SELF_SOURCED':
        return VehicleCategory.selfOwnedRental;
      case 'AMAZON_LEASED':
      case 'AMAZON_PAID_RENTAL':
      case 'ARMADA':
      default:
        return VehicleCategory.armada;
    }
  }

  VehicleStatus _mapStatus({
    required String cortexStatus,
    required String operationalStatus,
  }) {
    // The Amazon "Status" column (ACTIVE / INACTIVE) wins: inactive/archived
    // vehicles are inactive regardless of their operational status.
    final s = cortexStatus.trim().toUpperCase();
    if (s == 'INACTIVE' || s == 'DEFLEETED') return VehicleStatus.inactive;
    // Active vehicles are split by their operational status (Betriebsstatus).
    final op = operationalStatus.trim().toUpperCase();
    if (op == 'GROUNDED' || op == 'IN_SERVICE') {
      return VehicleStatus.groundedDefect;
    }
    if (op == 'OPERATIONAL') return VehicleStatus.operational;
    return VehicleStatus.active;
  }

  /// Parses + writes new vehicles. Existing rows (matched by either
  /// VIN or plate number) are skipped, never overwritten.
  Future<CortexImportReport> importFromXlsx({
    required String dspUid,
    required Uint8List bytes,
    required String filename,
    void Function(String phase)? onPhase,
    void Function(int done, int total)? onProgress,
  }) async {
    onPhase?.call('Datei wird gelesen …');
    final parsed = await ParserApi.parseXlsx(bytes, filename: filename);
    final rawList = (parsed['vehicles'] as List?) ?? const [];
    final vehicles = <Map<String, dynamic>>[
      for (final v in rawList)
        if (v is Map) v.cast<String, dynamic>(),
    ];
    if (vehicles.isEmpty) {
      // Ohne diesen Guard würde ein nicht erkanntes Dateiformat als
      // "Import abgeschlossen, 0 neu" gemeldet.
      throw Exception(
        'Keine Fahrzeuge in der Datei erkannt. Bitte den originalen '
        'Cortex-Export "VehiclesData.xlsx" unverändert hochladen '
        '(Spalten FIN + Nummernschild in der ersten Zeile).',
      );
    }

    // Snapshot of what's already there → dedup sets.
    final existing = await _vehiclesCollection(dspUid).get();
    final existingVins = <String>{};
    final existingPlates = <String>{};
    // Keep every existing doc (incl. soft-deleted) by id so re-importing a
    // previously deleted vehicle preserves its createdAt (the update rule
    // requires createdAt to stay unchanged).
    final existingByDocId = <String, Map<String, dynamic>>{};
    for (final d in existing.docs) {
      final data = d.data();
      existingByDocId[d.id] = data;
      // Soft-deleted vehicles must NOT count as duplicates — a re-import
      // should bring them back instead of skipping them.
      if (data['isDeleted'] == true) continue;
      final vin = (data['vinNumber'] ?? '').toString().trim().toUpperCase();
      final plate = (data['plateNumber'] ?? d.id).toString().trim().toUpperCase();
      if (vin.isNotEmpty) existingVins.add(vin);
      if (plate.isNotEmpty) existingPlates.add(plate);
    }

    final added = <String>[];
    final dupes = <String>[];
    final failures = <String>[];
    var processed = 0;
    onPhase?.call('${vehicles.length} Fahrzeuge werden gespeichert …');

    for (final v in vehicles) {
      processed++;
      onProgress?.call(processed, vehicles.length);
      final vin = (v['vinNumber'] ?? '').toString().trim().toUpperCase();
      final plateRaw = (v['plateNumber'] ?? '').toString();
      final plate = normalizePlateNumber(plateRaw);
      if (plate.isEmpty && vin.isEmpty) continue;

      // Die Firestore-Rules verlangen Kennzeichen (== DocID) und FIN.
      // Solche Zeilen vorab aussortieren, damit der Nutzer den Grund
      // sieht statt "Zugriff verweigert".
      if (plate.isEmpty) {
        failures.add('$vin: Kennzeichen fehlt in der Cortex-Zeile');
        continue;
      }
      if (vin.isEmpty) {
        failures.add('$plate: FIN fehlt in der Cortex-Zeile');
        continue;
      }

      // Skip inactive/archived vehicles (ownership ended, archived) — only the
      // active fleet belongs in the Fleet Hub.
      final rawStatus = (v['status'] ?? '').toString().trim().toUpperCase();
      if (rawStatus == 'INACTIVE' || rawStatus == 'DEFLEETED') continue;

      if ((vin.isNotEmpty && existingVins.contains(vin)) ||
          (plate.isNotEmpty && existingPlates.contains(plate))) {
        dupes.add(plate.isNotEmpty ? plate : vin);
        continue;
      }

      final docId = plate.isNotEmpty ? plate : vin;
      final docRef = _vehiclesCollection(dspUid).doc(docId);

      // Re-activating a soft-deleted doc is an UPDATE — keep its original
      // createdAt so the security rule passes; otherwise stamp a new one.
      final prior = existingByDocId[docId];
      final Object createdAtValue = (prior != null && prior['createdAt'] != null)
          ? prior['createdAt'] as Object
          : FieldValue.serverTimestamp();

      final category = _mapCategory(
        (v['ownershipType'] ?? '').toString(),
        fleetName: (v['fleetName'] ?? '').toString(),
        vehicleProvider: (v['vehicleProvider'] ?? '').toString(),
      );
      final status = _mapStatus(
        cortexStatus: (v['status'] ?? '').toString(),
        operationalStatus: (v['operationalStatus'] ?? '').toString(),
      );

      final docData = <String, dynamic>{
        'dspUid': dspUid,
        'plateNumber': plate,
        'vinNumber': vin,
        // Rules verlangen nicht-leere brand/model — Cortex lässt sie
        // gelegentlich leer, dann Platzhalter statt Rule-Rejection.
        'brand': (v['brand'] ?? '').toString().trim().isEmpty
            ? 'Unbekannt'
            : (v['brand'] ?? '').toString().trim(),
        'model': (v['model'] ?? '').toString().trim().isEmpty
            ? 'Unbekannt'
            : (v['model'] ?? '').toString().trim(),
        'submodel': (v['submodel'] ?? '').toString(),
        'fleetName': (v['fleetName'] ?? '').toString(),
        'category': category.value,
        'status': status.value,
        'fuelType': VehicleFuelType.diesel.value,
        'manufacturingYear': v['manufacturingYear'] is int
            ? v['manufacturingYear']
            : int.tryParse('${v['manufacturingYear'] ?? ''}') ?? 0,
        'metadata': const <String, dynamic>{},
        'notes': '',
        'isDeleted': false,
        // Cortex-only fields stored as a flat namespace so we can keep
        // them visible in the edit page without losing structure.
        'cortex': {
          'vehicleProvider': (v['vehicleProvider'] ?? '').toString(),
          'subcontractorName': (v['subcontractorName'] ?? '').toString(),
          'ownershipType': (v['ownershipType'] ?? '').toString(),
          'ownershipStart': (v['ownershipStart'] ?? '').toString(),
          'ownershipEnd': (v['ownershipEnd'] ?? '').toString(),
          'statusPriority': (v['statusPriority'] ?? '').toString(),
          'statusReasonCode': (v['statusReasonCode'] ?? '').toString(),
          'statusReasonMessage': (v['statusReasonMessage'] ?? '').toString(),
          'registrationType': (v['registrationType'] ?? '').toString(),
          'registrationExpiry': (v['registrationExpiry'] ?? '').toString(),
          'registeredState': (v['registeredState'] ?? '').toString(),
          'serviceTier': (v['serviceTier'] ?? '').toString(),
          'serviceType': (v['serviceType'] ?? '').toString(),
          'stationCode': (v['stationCode'] ?? '').toString(),
          'payload': (v['payload'] ?? '').toString(),
          'cubicCapacity': (v['cubicCapacity'] ?? '').toString(),
          'lastImportedAt': FieldValue.serverTimestamp(),
        },
        'createdAt': createdAtValue,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Write each vehicle on its own so a single rule rejection / bad row
      // can't abort the whole import — failures are collected and reported.
      try {
        await docRef.set(docData);
        if (vin.isNotEmpty) existingVins.add(vin);
        if (plate.isNotEmpty) existingPlates.add(plate);
        added.add(docId);
      } catch (e) {
        failures.add('$docId: ${_errText(e)}');
      }
    }

    onPhase?.call('Fertig.');
    return CortexImportReport(
      total: vehicles.length,
      added: added.length,
      skippedDuplicate: dupes.length,
      failed: failures.length,
      addedPlates: added,
      duplicatePlates: dupes,
      failures: failures,
    );
  }

  String _errText(Object e) {
    if (e is FirebaseException) {
      return e.code == 'permission-denied'
          ? 'Zugriff verweigert (Firestore-Rules)'
          : (e.message ?? e.code);
    }
    return e.toString();
  }
}
