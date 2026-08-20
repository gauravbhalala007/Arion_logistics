// lib/services/vacation_pools_repository.dart
//
// Zugriff auf die DSP-weite Urlaubstopf-Konfiguration
// (`users/{dspUid}/settings/vacation_pools`).
//
// Bewusst nur ein dünner Wrapper: die eigentliche Logik steckt in
// `utils/vacation_pools.dart` und bleibt dadurch Firestore-frei und
// testbar. Fehlt das Dokument, liefern alle Methoden
// [VacationPoolsConfig.disabled] — DSPs ohne Konfiguration behalten
// exakt das bisherige Ein-Topf-Verhalten.

import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/vacation_pools.dart';

class VacationPoolsRepository {
  const VacationPoolsRepository._();

  static const String settingsDocId = 'vacation_pools';

  static DocumentReference<Map<String, dynamic>> docRef(String dspUid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(dspUid)
        .collection('settings')
        .doc(settingsDocId);
  }

  /// Einmaliger Lesevorgang. Bewusst `get()` statt `snapshots()`: die
  /// Konfiguration ändert sich praktisch nie, und ein fehlgeschlagener
  /// Read (z. B. Dispatcher ohne Rechte auf fremde Settings) darf die
  /// Seite nicht blockieren — er fällt still auf das Bestandsverhalten
  /// zurück.
  static Future<VacationPoolsConfig> load(String? dspUid) async {
    if (dspUid == null || dspUid.trim().isEmpty) {
      return VacationPoolsConfig.disabled;
    }
    try {
      final snap = await docRef(dspUid).get();
      return VacationPoolsConfig.fromSettings(snap.data());
    } catch (_) {
      // Fehlende Leserechte o. Ä. dürfen die Seite nicht kippen —
      // im Zweifel gilt das Bestandsverhalten.
      return VacationPoolsConfig.disabled;
    }
  }

  static Future<void> save(String dspUid, VacationPoolsConfig config) {
    return docRef(dspUid).set(<String, dynamic>{
      ...config.toSettings(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
