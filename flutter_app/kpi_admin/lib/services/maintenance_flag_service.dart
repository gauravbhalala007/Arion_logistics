// lib/services/maintenance_flag_service.dart
//
// Liest das Wartungs-Flag aus _system/flags. Wenn 'maintenance' == true,
// zeigen alle Shells einen Warn-Banner an. Wird waehrend der EU-Migration
// (Cutover-Nacht) genutzt, um Schreibzugriffe zu unterbinden.
//
// Aktivierung (durch Admin via Firebase Console oder CLI):
//   firebase firestore:set _system/flags '{"maintenance": true}'
//
// Deaktivierung am Ende:
//   firebase firestore:set _system/flags '{"maintenance": false}'

import 'package:cloud_firestore/cloud_firestore.dart';

class MaintenanceFlagService {
  MaintenanceFlagService._();

  static Stream<MaintenanceState> watch() {
    return FirebaseFirestore.instance
        .collection('_system')
        .doc('flags')
        .snapshots()
        .map(MaintenanceState.fromSnapshot);
  }
}

class MaintenanceState {
  final bool isActive;
  final String? message;

  const MaintenanceState({required this.isActive, this.message});

  static const MaintenanceState off = MaintenanceState(isActive: false);

  factory MaintenanceState.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snap,
  ) {
    final data = snap.data();
    if (data == null) return off;
    final active = data['maintenance'] == true;
    final message = data['maintenanceMessage']?.toString();
    return MaintenanceState(isActive: active, message: message);
  }
}
