import 'package:cloud_firestore/cloud_firestore.dart';

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

  // simple ISO week calc (adequate for our use)
  static int _isoWeekOfYear(DateTime date) {
    final thursday = date.add(Duration(days: (4 - (date.weekday == 7 ? 0 : date.weekday))));
    final firstThursday = DateTime(thursday.year, 1, 4);
    return ((thursday.difference(firstThursday).inDays) / 7).floor() + 1;
  }

  static String _bucketFor(num? finalScore) {
    if (finalScore == null) return 'Unknown';
    final fs = finalScore.toDouble();
    if (fs >= 85) return 'Fantastic';
    if (fs >= 70) return 'Great';
    if (fs >= 55) return 'Fair';
    return 'Poor';
  }

  static Future<void> writeReportAndScores({
    required Map<String, dynamic> parserJson,
    required String storagePath,
  }) async {
    final db = FirebaseFirestore.instance;

    final summary = (parserJson['summary'] as Map?)?.map((k, v) => MapEntry(k.toString(), v)) ?? <String, dynamic>{};
    final drivers = (parserJson['drivers'] as List?)?.cast<Map>() ?? const [];

    final reportId = makeReportId(summary);
    final reportRef = db.collection('reports').doc(reportId);

    final year = (summary['year'] as num?)?.toInt();
    final week = (summary['weekNumber'] as num?)?.toInt();
    final station = _normStation(summary['stationCode']?.toString());

    await reportRef.set({
      'reportName' : storagePath.split('/').last,
      'storagePath': storagePath,
      'status'     : 'done',
      'reportDate' : FieldValue.serverTimestamp(),
      'year'       : year,
      'weekNumber' : week,
      'stationCode': station,
      'summary'    : {
        'overallScore'      : (summary['overallScore'] as num?)?.toDouble(),
        'reliabilityScore'  : (summary['reliabilityScore'] as num?)?.toDouble(),
        'reliabilityNextDay': (summary['reliabilityNextDay'] as num?)?.toDouble(),
        'reliabilitySameDay': (summary['reliabilitySameDay'] as num?)?.toDouble(),
        'rankAtStation'     : (summary['rankAtStation'] as num?)?.toInt(),
        'stationCount'      : (summary['stationCount'] as num?)?.toInt(),
        'rankDeltaWoW'      : (summary['rankDeltaWoW'] as num?)?.toInt(),
        'weekText'          : (summary['weekText'] ?? '').toString(),
        'weekNumber'        : week,
        'year'              : year,
        'stationCode'       : station,
      },
      'createdAt'  : FieldValue.serverTimestamp(),
      'updatedAt'  : FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final batch = db.batch();

    for (final raw in drivers) {
      final m = raw.map((k, v) => MapEntry(k.toString(), v));
      final transporterId = (m['Transporter ID'] ?? '').toString().trim();
      if (transporterId.isEmpty) continue;

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
      final bucket = _bucketFor(comp['FinalScore'] as num?);

      // deterministic score doc id → prevents duplicates for same reportId + transporter
      final scoreId = '${reportId}_$transporterId';
      final scoreRef = db.collection('scores').doc(scoreId);

      batch.set(scoreRef, {
        'reportRef'   : reportRef,
        'transporterId': transporterId,
        'year'        : year,
        'weekNumber'  : week,
        'reportDate'  : FieldValue.serverTimestamp(),
        'kpis'        : kpis,
        'comp'        : comp,
        'rank'        : rank,
        'statusBucket': bucket,
        'computedAt'  : FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }
}
