// lib/services/time_tracking_service.dart
//
// Client-Wrapper für die Time-Tracking Cloud Functions. Driver-App
// und Admin-Dashboard rufen ausschließlich über diese Klasse die
// Funktionen `clockIn`, `clockOut`, `pauseToggle` auf — niemand
// schreibt direkt in die Firestore-Collections (Server-Pflicht).

import 'package:cloud_functions/cloud_functions.dart';

class TimeTrackingService {
  TimeTrackingService._();
  static final TimeTrackingService instance = TimeTrackingService._();

  static final _functions =
      FirebaseFunctions.instanceFor(region: 'europe-west3');

  /// Startet eine Schicht. Server wählt anhand des GPS-Standorts die
  /// passende Station (Multi-Station-Support für Aushilfsfahrer).
  Future<ClockInResult> clockIn({
    required String qrToken,
    required double lat,
    required double lng,
    required double accuracy,
  }) async {
    final result = await _functions.httpsCallable('clockIn').call({
      'qrToken': qrToken,
      'lat': lat,
      'lng': lng,
      'accuracy': accuracy,
      'clientTime': DateTime.now().millisecondsSinceEpoch,
      'deviceInfo': {
        'platform': 'web',
        'appVersion': '1.0.0',
      },
    });
    final data = (result.data as Map?)?.cast<String, dynamic>() ?? {};
    return ClockInResult(
      shiftId: (data['shiftId'] ?? '').toString(),
      entryId: (data['entryId'] ?? '').toString(),
      tsMillis: (data['ts'] as num?)?.toInt() ?? 0,
      warnings: ((data['warnings'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  /// Beendet die offene Schicht. Geofence-Check ist hier loose
  /// (Driver darf auch vom Auto aus ausstempeln).
  Future<ClockOutResult> clockOut({
    required double lat,
    required double lng,
    required double accuracy,
  }) async {
    final result = await _functions.httpsCallable('clockOut').call({
      'lat': lat,
      'lng': lng,
      'accuracy': accuracy,
      'clientTime': DateTime.now().millisecondsSinceEpoch,
      'deviceInfo': {
        'platform': 'web',
        'appVersion': '1.0.0',
      },
    });
    final data = (result.data as Map?)?.cast<String, dynamic>() ?? {};
    return ClockOutResult(
      shiftId: (data['shiftId'] ?? '').toString(),
      entryId: (data['entryId'] ?? '').toString(),
      workDurationSec: (data['workDuration'] as num?)?.toInt() ?? 0,
      warnings: ((data['warnings'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  /// Toggelt Pause an/aus.
  Future<PauseToggleResult> togglePause() async {
    final result = await _functions.httpsCallable('pauseToggle').call(<String, dynamic>{});
    final data = (result.data as Map?)?.cast<String, dynamic>() ?? {};
    return PauseToggleResult(
      newState: (data['newState'] ?? '').toString(),
      pauseDurationSec: (data['pauseDuration'] as num?)?.toInt() ?? 0,
    );
  }
}

class ClockInResult {
  final String shiftId;
  final String entryId;
  final int tsMillis;
  final List<String> warnings;
  ClockInResult({
    required this.shiftId,
    required this.entryId,
    required this.tsMillis,
    required this.warnings,
  });
}

class ClockOutResult {
  final String shiftId;
  final String entryId;
  final int workDurationSec;
  final List<String> warnings;
  ClockOutResult({
    required this.shiftId,
    required this.entryId,
    required this.workDurationSec,
    required this.warnings,
  });
}

class PauseToggleResult {
  final String newState; // 'pause_started' | 'pause_ended'
  final int pauseDurationSec;
  PauseToggleResult({
    required this.newState,
    required this.pauseDurationSec,
  });
}
