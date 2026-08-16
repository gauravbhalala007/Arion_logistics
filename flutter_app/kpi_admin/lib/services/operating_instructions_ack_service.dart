// lib/services/operating_instructions_ack_service.dart
//
// Lesebestätigungen der Betriebsanweisungen (BAW).
//
// Betriebsanweisungen sind statische Inhalte (lib/data/safety_training/
// operating_instructions_*.dart) — nur die Bestätigung des Fahrers wird
// gespeichert. Ablage im selben Baum wie die Schulungsergebnisse:
//
//   users/{dspUid}/academy_test_results/operating_instructions/drivers/{tid}
//
// Dort greift diese Firestore-Regel (firebase/firestore.rules):
//
//   match /academy_test_results/{testId} {
//     match /drivers/{driverId} {
//       allow create, update: if isDriverForUser(userId)
//         && isApproved(userId)
//         && driverTransporterId() == driverId
//         && request.resource.data.driverTransporterId == driverId
//         && request.resource.data.testId == testId;
//     }
//   }
//
// Deshalb MUSS jeder Schreibvorgang `driverTransporterId` und `testId`
// mitschreiben — auch beim reinen Nachtragen einer Bestätigung. Alle
// Schreib-/Lesezugriffe laufen ausschließlich über diese Klasse; muss der
// Pfad je wechseln, ist nur diese Datei anzufassen.

import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/safety_training/operating_instructions.dart';

/// Eine einzelne Lesebestätigung.
class OperatingInstructionAck {
  /// Zeitpunkt der Bestätigung.
  final DateTime at;

  /// Inhaltsstand, der bestätigt wurde ([kOperatingInstructionsVersion]).
  final int version;

  const OperatingInstructionAck({required this.at, required this.version});

  /// Bestätigung bezieht sich auf einen älteren Inhaltsstand.
  ///
  /// Nur informativ — eine erneute Bestätigung wird nicht erzwungen.
  bool get isOutdated => version < kOperatingInstructionsVersion;
}

/// Dienst für [dspUid]/[transporterId] — `null`, sobald eine der beiden
/// Angaben fehlt oder leer ist. Ansichten schalten dann auf reines Lesen.
OperatingInstructionsAckService? buildOperatingInstructionsAckService(
  String? dspUid,
  String? transporterId,
) {
  final uid = dspUid?.trim() ?? '';
  final tid = transporterId?.trim() ?? '';
  if (uid.isEmpty || tid.isEmpty) return null;
  return OperatingInstructionsAckService(
    dspUid: uid,
    driverTransporterId: tid,
  );
}

/// Liest und schreibt die Lesebestätigungen eines Fahrers.
class OperatingInstructionsAckService {
  final String dspUid;
  final String driverTransporterId;
  final FirebaseFirestore _db;

  OperatingInstructionsAckService({
    required this.dspUid,
    required this.driverTransporterId,
    FirebaseFirestore? firestore,
  }) : _db = firestore ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> get _ref => _db
      .collection('users')
      .doc(dspUid.trim())
      .collection('academy_test_results')
      .doc(kOperatingInstructionsTestId)
      .collection('drivers')
      .doc(driverTransporterId.trim());

  /// Laufende Bestätigungen, Schlüssel ist die Anweisungs-ID.
  Stream<Map<String, OperatingInstructionAck>> watch() =>
      _ref.snapshots().map((snap) => _parse(snap.data()));

  /// Einmaliges Laden — für Ansichten ohne Live-Aktualisierung.
  Future<Map<String, OperatingInstructionAck>> load() async {
    final snap = await _ref.get();
    return _parse(snap.data());
  }

  /// Trägt die Bestätigung für [instructionId] nach.
  ///
  /// Idempotent: `set(merge: true)` legt das Dokument beim ersten Mal an
  /// und ergänzt danach nur den einen Map-Eintrag. Mehrfaches Bestätigen
  /// erzeugt deshalb keinen zweiten Eintrag, sondern überschreibt denselben
  /// Schlüssel (die Oberfläche unterbindet das ohnehin vorab).
  Future<void> acknowledge(String instructionId, {DateTime? at}) async {
    final now = at ?? DateTime.now();
    await _ref.set({
      // Pflichtfelder der Firestore-Regel — müssen bei jedem Schreibvorgang
      // im resultierenden Dokument stehen.
      'driverTransporterId': driverTransporterId.trim(),
      'testId': kOperatingInstructionsTestId,
      'version': kOperatingInstructionsVersion,
      'acknowledged': {
        instructionId: {
          'at': Timestamp.fromDate(now),
          'version': kOperatingInstructionsVersion,
        },
      },
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Map<String, OperatingInstructionAck> _parse(Map<String, dynamic>? data) {
    final raw = data?['acknowledged'];
    if (raw is! Map) return const {};

    final out = <String, OperatingInstructionAck>{};
    raw.forEach((key, value) {
      final id = '$key';
      // Neues Format: { at: Timestamp, version: int }.
      if (value is Map) {
        final at = value['at'];
        if (at is Timestamp) {
          out[id] = OperatingInstructionAck(
            at: at.toDate(),
            version: (value['version'] as num?)?.toInt() ?? 1,
          );
        }
        return;
      }
      // Toleranz für einen blanken Zeitstempel ohne Versionsangabe.
      if (value is Timestamp) {
        out[id] = OperatingInstructionAck(at: value.toDate(), version: 1);
      }
    });
    return out;
  }
}
