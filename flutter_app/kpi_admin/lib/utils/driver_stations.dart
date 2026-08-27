// lib/utils/driver_stations.dart
//
// Kleiner Helper fuer den Stations-Filter der Scorecard-Seiten.
// Laedt EINMAL die Zuordnung TransporterID -> Station aus der
// drivers-Collection des DSP (users/{uid}/drivers). Das Feld `station`
// (String, z. B. "DBY5") wird im Drivers Hub gepflegt; leer/fehlend
// bedeutet "keine Zuweisung".

import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/driver_csv.dart';

/// Sentinel fuer den Filter-Wert "Fahrer ohne Station".
/// (Kein gueltiger Stationscode, kollidiert daher nie mit echten Codes.)
const String kNoStationFilter = '__none__';

/// Laedt die Map normalisierte TransporterID -> Stationscode
/// (getrimmt + UPPERCASE, '' = keine Zuweisung) einmalig.
Future<Map<String, String>> loadDriverStations(String uid) async {
  final out = <String, String>{};
  if (uid.isEmpty) return out;
  try {
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('drivers')
        .get();
    for (final d in snap.docs) {
      final data = d.data();
      final tid = DriverCsvService.normalizeTransporterId(
        (data['transporterId'] ?? d.id).toString(),
      );
      if (tid.isEmpty) continue;
      out[tid] = (data['station'] ?? '').toString().trim().toUpperCase();
    }
  } catch (_) {
    // Ohne Daten erscheint der Filter einfach nicht.
  }
  return out;
}

/// Distinct vorhandene Stationen (nicht-leer), alphabetisch sortiert.
List<String> distinctStations(Map<String, String> tidToStation) {
  final s = tidToStation.values.where((v) => v.isNotEmpty).toSet().toList()
    ..sort();
  return s;
}

/// True, wenn mindestens ein Fahrer KEINE Station zugewiesen hat.
bool hasUnassignedDrivers(Map<String, String> tidToStation) =>
    tidToStation.values.any((v) => v.isEmpty);

/// Prueft, ob eine (normalisierte) TransporterID zum gewaehlten Filter
/// passt. [filter] = null bedeutet "Alle" (alles passt);
/// [kNoStationFilter] matcht Fahrer ohne Zuweisung — auch solche, die
/// gar nicht (mehr) in der drivers-Collection stehen.
bool tidMatchesStationFilter({
  required String? filter,
  required Map<String, String> tidToStation,
  required String normalizedTid,
}) {
  if (filter == null) return true;
  final station = tidToStation[normalizedTid] ?? '';
  if (filter == kNoStationFilter) return station.isEmpty;
  return station == filter;
}
