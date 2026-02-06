// lib/services/report_writer.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportWriter {
  static String _normStation(String? code) {
    final s = (code ?? 'UNK').toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    return s.isEmpty ? 'UNK' : s;
  }

  static String makeReportId(Map<String, dynamic> summary) {
    final now = DateTime.now();
    final year = (summary['year'] as num?)?.toInt() ?? now.year;
    final week = (summary['weekNumber'] as num?)?.toInt() ?? _isoWeekOfYear(now);
    final station = _normStation(summary['stationCode']?.toString());
    return '${station}_${year}-W$week';
  }

  static int _isoWeekOfYear(DateTime date) {
    final thursday = date.add(Duration(days: (4 - (date.weekday == 7 ? 0 : date.weekday))));
    final firstThursday = DateTime(thursday.year, 1, 4);
    return ((thursday.difference(firstThursday).inDays) / 7).floor() + 1;
  }

  static Future<void> writeReportAndScores({
    required Map<String, dynamic> parserJson,
    required String storagePath,
  }) async {
    final db = FirebaseFirestore.instance;
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final summary = (parserJson['summary'] as Map?)
            ?.map((k, v) => MapEntry(k.toString(), v)) ??
        <String, dynamic>{};
    final drivers = (parserJson['drivers'] as List?)?.cast<Map>() ?? const [];

    final podSummary =
        (summary['podQualitySummary'] as Map?)?.map((k, v) => MapEntry(k.toString(), v));
    final podRejects =
        (summary['podQualityRejects'] as Map?)?.map((k, v) => MapEntry(k.toString(), v));

    final hasPodQuality = podSummary != null ||
        podRejects != null ||
        drivers.any((d) => d.containsKey('POD_Q_Opportunities'));

    final reportId = makeReportId(summary);
    final reportRef = db.collection('users').doc(uid).collection('reports').doc(reportId);

    final year = (summary['year'] as num?)?.toInt();
    final week = (summary['weekNumber'] as num?)?.toInt();
    final station = _normStation(summary['stationCode']?.toString());

    final summaryUpdate = <String, dynamic>{};

    void setIfPresent(String key, dynamic value) {
      if (value == null) return;
      if (value is String && value.trim().isEmpty) return;
      summaryUpdate[key] = value;
    }

    setIfPresent('overallScore', (summary['overallScore'] as num?)?.toDouble());
    setIfPresent('overallStatus', summary['overallStatus']?.toString());
    setIfPresent('reliabilityScore', (summary['reliabilityScore'] as num?)?.toDouble());
    setIfPresent('reliabilityNextDay', (summary['reliabilityNextDay'] as num?)?.toDouble());
    setIfPresent('reliabilitySameDay', (summary['reliabilitySameDay'] as num?)?.toDouble());
    setIfPresent('rankAtStation', (summary['rankAtStation'] as num?)?.toInt());
    setIfPresent('stationCount', (summary['stationCount'] as num?)?.toInt());
    setIfPresent('rankDeltaWoW', (summary['rankDeltaWoW'] as num?)?.toInt());
    setIfPresent('weekText', summary['weekText']?.toString());
    setIfPresent('weekNumber', week);
    setIfPresent('year', year);
    setIfPresent('stationCode', station);

    if (podSummary != null || podRejects != null) {
      summaryUpdate['podQuality'] = {
        if (podSummary != null) 'summary': podSummary,
        if (podRejects != null) 'rejects': podRejects,
      };
    }

    final reportUpdate = <String, dynamic>{
      'reportName' : storagePath.split('/').last,
      'storagePath': storagePath,
      'status'     : 'done',
      'reportDate' : FieldValue.serverTimestamp(),
      'createdAt'  : FieldValue.serverTimestamp(),
      'updatedAt'  : FieldValue.serverTimestamp(),
    };

    if (year != null) reportUpdate['year'] = year;
    if (week != null) reportUpdate['weekNumber'] = week;
    if (station.isNotEmpty) reportUpdate['stationCode'] = station;
    if (summaryUpdate.isNotEmpty) reportUpdate['summary'] = summaryUpdate;

    await reportRef.set(reportUpdate, SetOptions(merge: true));

    // NEW: load user driver dictionary once
    final driverDictSnap = await db
        .collection('users').doc(uid)
        .collection('drivers').get();
    final driverDict = <String, String>{
      for (final d in driverDictSnap.docs)
        (d.data()['transporterId'] ?? d.id).toString(): (d.data()['driverName'] ?? '').toString(),
    };

    final batch = db.batch();

    for (final raw in drivers) {
      final m = raw.map((k, v) => MapEntry(k.toString(), v));
      final transporterId = (m['Transporter ID'] ?? '').toString().trim();
      if (transporterId.isEmpty) continue;

      final scoreId = '${reportId}_$transporterId';
      final scoreRef = db.collection('users').doc(uid).collection('scores').doc(scoreId);

      final driverName = driverDict[transporterId];

      if (hasPodQuality) {
        final podQuality = {
          'opportunities': (m['POD_Q_Opportunities'] as num?)?.toDouble(),
          'success': (m['POD_Q_Success'] as num?)?.toDouble(),
          'bypass': (m['POD_Q_Bypass'] as num?)?.toDouble(),
          'rejects': (m['POD_Q_Rejects'] as num?)?.toDouble(),
          'blurryPhoto': (m['POD_Q_BlurryPhoto'] as num?)?.toDouble(),
          'photoTooDark': (m['POD_Q_PhotoTooDark'] as num?)?.toDouble(),
          'noPackageDetected': (m['POD_Q_NoPackageDetected'] as num?)?.toDouble(),
          'packageInCar': (m['POD_Q_PackageInCar'] as num?)?.toDouble(),
          'packageTooClose': (m['POD_Q_PackageTooClose'] as num?)?.toDouble(),
        };

        batch.set(scoreRef, {
          'reportRef'    : reportRef,
          'transporterId': transporterId,
          'driverName'   : driverName,
          if (year != null) 'year': year,
          if (week != null) 'weekNumber': week,
          'reportDate'   : FieldValue.serverTimestamp(),
          'podQuality'   : podQuality,
          'computedAt'   : FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        final comp = {
          'POD_Score' : (m['POD_Score'] as num?)?.toDouble(),
          'CC_Score'  : (m['CC_Score'] as num?)?.toDouble(),
          'DCR_Score' : (m['DCR_Score'] as num?)?.toDouble(),
          'CE_Score'  : (m['CE_Score'] as num?)?.toDouble(),
          'LoR_Score' : (m['LoR_Score'] as num?)?.toDouble(),
          'DNR_Score' : (m['DNR_Score'] as num?)?.toDouble(),
          'CDF_Score' : (m['CDF_Score'] as num?)?.toDouble(),
          'FinalScore': (m['FinalScore'] as num?)?.toDouble(),
        };

        final kpis = {
          'Delivered': (m['Delivered'] as num?)?.toDouble(),
          'POD'      : m['POD'],
          'CC'       : m['CC'],
          'DCR'      : m['DCR'],
          'CE'       : (m['CE'] as num?)?.toDouble(),
          'LoR'      : (m['LoR DPMO'] as num?)?.toDouble(),
          'DNR'      : (m['DNR DPMO'] as num?)?.toDouble(),
          'CDF'      : (m['CDF DPMO'] as num?)?.toDouble(),
        };

        final rank = (m['rank'] as num?)?.toInt();

        final incomingBucket = (m['statusBucket'] ?? '').toString().trim();
        final bucket = incomingBucket.isNotEmpty ? incomingBucket : 'Unknown';

        batch.set(scoreRef, {
          'reportRef'    : reportRef,
          'transporterId': transporterId,
          'driverName'   : driverName, // <-- attach if known
          if (year != null) 'year': year,
          if (week != null) 'weekNumber': week,
          'reportDate'   : FieldValue.serverTimestamp(),
          'kpis'         : kpis,
          'comp'         : comp,
          'rank'         : rank,
          'statusBucket' : bucket,
          'computedAt'   : FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      // Also reflect into this report’s /driverNames for convenience
      if (driverName != null && driverName.isNotEmpty) {
        final dnRef = reportRef.collection('driverNames').doc(transporterId);
        batch.set(dnRef, {
          'transporterId': transporterId,
          'driverName'   : driverName,
          'updatedAt'    : FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    }

    await batch.commit();
  }
}
