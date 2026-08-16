// lib/services/report_writer.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'driver_csv.dart';

class ReportWriter {
  static String _firstNonEmpty(Map<String, dynamic> m, List<String> keys) {
    for (final key in keys) {
      final text = (m[key] ?? '').toString().trim();
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  static num? _numFrom(dynamic v) {
    if (v == null) return null;
    if (v is num) return v;
    final s = v.toString().trim().replaceAll('%', '').replaceAll(',', '.');
    return num.tryParse(s);
  }

  static num? _numFromAny(Map<String, dynamic> m, List<String> keys) {
    for (final key in keys) {
      final n = _numFrom(m[key]);
      if (n != null) return n;
    }
    return null;
  }

  static bool _hasAnyValue(Map<String, dynamic> m, List<String> keys) {
    for (final key in keys) {
      final v = m[key];
      if (v == null) continue;
      if (v is String && v.trim().isEmpty) continue;
      return true;
    }
    return false;
  }

  static Future<void> _deleteExistingScoresForWeek({
    required FirebaseFirestore db,
    required String uid,
    required DocumentReference<Map<String, dynamic>> reportRef,
    required String reportId,
  }) async {
    final scoresCol = db.collection('users').doc(uid).collection('scores');
    final refsById = <String, DocumentReference<Map<String, dynamic>>>{};

    Future<void> collect(Query<Map<String, dynamic>> q) async {
      final snap = await q.get();
      for (final d in snap.docs) {
        refsById[d.id] = d.reference;
      }
    }

    await collect(scoresCol.where('reportId', isEqualTo: reportId));
    await collect(scoresCol.where('reportPath', isEqualTo: reportRef.path));

    if (refsById.isEmpty) return;

    final refs = refsById.values.toList(growable: false);
    for (var i = 0; i < refs.length; i += 450) {
      final batch = db.batch();
      final end = i + 450 < refs.length ? i + 450 : refs.length;
      for (var j = i; j < end; j++) {
        batch.delete(refs[j]);
      }
      await batch.commit();
    }
  }

  static String _normStation(String? code) {
    final s = (code ?? 'UNK').toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    return s.isEmpty ? 'UNK' : s;
  }

  static String makeReportId(Map<String, dynamic> summary) {
    final now = DateTime.now();
    final year = _numFromAny(summary, ['year', 'Year'])?.toInt() ?? now.year;
    final week = _numFromAny(summary, ['weekNumber', 'week_number', 'week'])?.toInt() ?? _isoWeekOfYear(now);
    final station = _normStation(summary['stationCode']?.toString());
    return '${station}_$year-W$week';
  }

  static int _isoWeekOfYear(DateTime date) {
    // UTC + Jan-4-Regel: DST-sicher und ohne Sonntags-Sonderfall
    // (weekday ist 1..7, Sonntag = 7).
    final day = DateTime.utc(date.year, date.month, date.day);
    final thursday = day.add(Duration(days: 4 - day.weekday));
    final jan4 = DateTime.utc(thursday.year, 1, 4);
    final week1Monday = jan4.subtract(Duration(days: jan4.weekday - 1));
    return thursday.difference(week1Monday).inDays ~/ 7 + 1;
  }

  static Future<void> writeReportAndScores({
    required Map<String, dynamic> parserJson,
    required String storagePath,
    String? adminUid,
  }) async {
    final db = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Not signed in');
    // Wenn ein Dispatcher Scorecards hochlädt, schreibt er in den
    // Namespace des Parent-Admins (übergeben via [adminUid]). Admins
    // selbst übergeben nichts und schreiben in ihren eigenen Namespace.
    final uid = adminUid ?? user.uid;

    final summary = (parserJson['summary'] as Map?)
            ?.map((k, v) => MapEntry(k.toString(), v)) ??
        <String, dynamic>{};
    final rawDrivers = (parserJson['drivers'] as List?) ?? const [];
    final drivers = <Map<String, dynamic>>[
      for (final d in rawDrivers)
        if (d is Map) d.map((k, v) => MapEntry(k.toString(), v)),
    ];

    final podSummary =
        (summary['podQualitySummary'] as Map?)?.map((k, v) => MapEntry(k.toString(), v));
    final podRejects =
        (summary['podQualityRejects'] as Map?)?.map((k, v) => MapEntry(k.toString(), v));

    final hasPodQuality = podSummary != null ||
        podRejects != null ||
        drivers.any((d) => d.containsKey('POD_Q_Opportunities'));

    final concessionsSummary = (summary['concessionsSummary'] as Map?)
        ?.map((k, v) => MapEntry(k.toString(), v));
    final concessionsFocus = (summary['concessionsFocusBuckets'] as Map?)
        ?.map((k, v) => MapEntry(k.toString(), v));

    final hasConcessions = concessionsSummary != null ||
        concessionsFocus != null ||
        drivers.any((d) => d.containsKey('CONC_TotalDelivered'));

    // CDF (Customer Delivery Feedback) — weekly HTML report from Amazon.
    final cdfSummary = (summary['cdfSummary'] as Map?)
        ?.map((k, v) => MapEntry(k.toString(), v));
    final cdfDistribution = (summary['cdfL1Distribution'] as Map?)
        ?.map((k, v) => MapEntry(k.toString(), v));
    final hasCdf = cdfSummary != null ||
        cdfDistribution != null ||
        drivers.any((d) => d.containsKey('CDF_TotalFeedback'));

    // DWC / IADC — weekly HTML report from Amazon (per-driver DWC% / IADC%).
    final dwcSummary = (summary['dwcSummary'] as Map?)
        ?.map((k, v) => MapEntry(k.toString(), v));
    final hasDwc = dwcSummary != null ||
        drivers.any((d) =>
            d.containsKey('DWC_DwcPct') || d.containsKey('DWC_IadcPct'));

    final now = DateTime.now();
    final reportId = makeReportId(summary);
    final reportRef = db.collection('users').doc(uid).collection('reports').doc(reportId);

    final year =
        _numFromAny(summary, ['year', 'Year'])?.toInt() ?? now.year;
    final week =
        _numFromAny(summary, ['weekNumber', 'week_number', 'week'])?.toInt() ??
        _isoWeekOfYear(now);
    final station = _normStation(summary['stationCode']?.toString());

    final summaryUpdate = <String, dynamic>{};

    void setIfPresent(String key, dynamic value) {
      if (value == null) return;
      if (value is String && value.trim().isEmpty) return;
      summaryUpdate[key] = value;
    }

    setIfPresent('overallScore', _numFromAny(summary, ['overallScore', 'overall_score'])?.toDouble());
    setIfPresent('overallStatus', summary['overallStatus']?.toString());
    setIfPresent('reliabilityScore', _numFromAny(summary, ['reliabilityScore', 'reliability_score'])?.toDouble());
    setIfPresent('reliabilityNextDay', _numFromAny(summary, ['reliabilityNextDay', 'reliability_next_day'])?.toDouble());
    setIfPresent('reliabilitySameDay', _numFromAny(summary, ['reliabilitySameDay', 'reliability_same_day'])?.toDouble());
    setIfPresent('rankAtStation', _numFromAny(summary, ['rankAtStation', 'rank_at_station'])?.toInt());
    setIfPresent('stationCount', _numFromAny(summary, ['stationCount', 'station_count'])?.toInt());
    setIfPresent('rankDeltaWoW', _numFromAny(summary, ['rankDeltaWoW', 'rank_delta_wow'])?.toInt());
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

    if (concessionsSummary != null || concessionsFocus != null) {
      summaryUpdate['concessions'] = {
        if (concessionsSummary != null) 'summary': concessionsSummary,
        if (concessionsFocus != null) 'focusBuckets': concessionsFocus,
      };
    }

    if (cdfSummary != null || cdfDistribution != null) {
      summaryUpdate['cdf'] = {
        if (cdfSummary != null) 'summary': cdfSummary,
        if (cdfDistribution != null) 'l1Distribution': cdfDistribution,
      };
    }

    if (dwcSummary != null) {
      summaryUpdate['dwc'] = {
        'summary': dwcSummary,
      };
    }

    final complianceAndSafety =
        (summary['complianceAndSafety'] as Map?)?.map((k, v) => MapEntry(k.toString(), v));
    final deliveryQualitySwc =
        (summary['deliveryQualitySwc'] as Map?)?.map((k, v) => MapEntry(k.toString(), v));
    if (complianceAndSafety != null && complianceAndSafety.isNotEmpty) {
      summaryUpdate['complianceAndSafety'] = complianceAndSafety;
    }
    if (deliveryQualitySwc != null && deliveryQualitySwc.isNotEmpty) {
      summaryUpdate['deliveryQualitySwc'] = deliveryQualitySwc;
    }

    final reportUpdate = <String, dynamic>{
      'reportName' : storagePath.split('/').last,
      'storagePath': storagePath,
      'status'     : 'done',
      'reportDate' : FieldValue.serverTimestamp(),
      'createdAt'  : FieldValue.serverTimestamp(),
      'updatedAt'  : FieldValue.serverTimestamp(),
    };

    reportUpdate['year'] = year;
    reportUpdate['weekNumber'] = week;
    if (station.isNotEmpty) reportUpdate['stationCode'] = station;
    if (summaryUpdate.isNotEmpty) reportUpdate['summary'] = summaryUpdate;

    await reportRef.set(reportUpdate, SetOptions(merge: true));

    // NEW: load user driver dictionary once
    final driverDictSnap = await db
        .collection('users').doc(uid)
        .collection('drivers').get();
    final driverDict = <String, String>{
      for (final d in driverDictSnap.docs)
        DriverCsvService.normalizeTransporterId(
          (d.data()['transporterId'] ?? d.id).toString(),
        ): (d.data()['driverName'] ?? '').toString(),
    };

    final hasAnyDspRows = drivers.any(
      (m) => _hasAnyValue(m, const [
        'FinalScore',
        'POD_Score',
        'CC_Score',
        'DCR_Score',
        'CE_Score',
        'LoR_Score',
        'DNR_Score',
        'CDF_Score',
        'Delivered',
        'DELIVERED',
        'delivered',
        'LoR DPMO',
        'DNR DPMO',
        'CDF DPMO',
        'rank',
        'Rank',
        'statusBucket',
        'status_bucket',
      ]),
    );

    // Only full DSP scorecard uploads should replace the week's score docs.
    // POD Quality uploads should merge POD data onto existing driver scores.
    if (hasAnyDspRows) {
      await _deleteExistingScoresForWeek(
        db: db,
        uid: uid,
        reportRef: reportRef,
        reportId: reportId,
      );
    }

    final batch = db.batch();

    for (final m in drivers) {
      final transporterId = DriverCsvService.normalizeTransporterId(
        _firstNonEmpty(m, [
        'Transporter ID',
        'transporterId',
        'transporter_id',
        'TransporterID',
        'transporter id',
      ]),
      );
      if (transporterId.isEmpty) continue;

      final scoreId = '${reportId}_$transporterId';
      final scoreRef = db.collection('users').doc(uid).collection('scores').doc(scoreId);

      final driverName = driverDict[transporterId];

      final hasPodRow = hasPodQuality && _hasAnyValue(m, const [
        'POD_Q_Opportunities',
        'POD_Q_Success',
        'POD_Q_Bypass',
        'POD_Q_Rejects',
        'POD_Q_BlurryPhoto',
        'POD_Q_PhotoTooDark',
        'POD_Q_NoPackageDetected',
        'POD_Q_PackageInCar',
        'POD_Q_PackageTooClose',
      ]);

      final hasConcessionsRow = hasConcessions && _hasAnyValue(m, const [
        'CONC_TotalDelivered',
        'CONC_TotalDnr',
        'CONC_DnrDpmo4w',
        'CONC_DnrCount_W1',
        'CONC_DnrCount_W2',
        'CONC_DnrCount_W3',
        'CONC_DnrCount_W4',
        'CONC_DnrDpmo_W1',
        'CONC_DnrDpmo_W2',
        'CONC_DnrDpmo_W3',
        'CONC_DnrDpmo_W4',
        'CONC_Focus_AttendedDnr',
        'CONC_Focus_PhotoOnDelivery',
        'CONC_Focus_SuccessfulContact',
        'CONC_Focus_Delivered25m',
        'CONC_Focus_FalseScan',
        'CONC_Focus_Mailbox',
        'CONC_Focus_DeliveredOtp',
      ]);

      final hasCdfRow = hasCdf && _hasAnyValue(m, const [
        'CDF_TotalFeedback',
        'CDF_NegativeFeedback',
        'CDF_L1_NeverReceived',
        'CDF_L1_DriverMishandled',
        'CDF_L1_NotDeliveredToPreferredLocation',
        'CDF_L1_DamagedPackage',
        'CDF_L1_DeliveryWasLate',
        'CDF_L1_BadDeliveryExperience',
        'CDF_L1_DriverWasUnprofessional',
        'CDF_L1_Other',
      ]);

      final hasDwcRow = hasDwc && _hasAnyValue(m, const [
        'DWC_DwcPct',
        'DWC_IadcPct',
      ]);

      final hasDspRow = _hasAnyValue(m, const [
        'FinalScore',
        'POD_Score',
        'CC_Score',
        'DCR_Score',
        'CE_Score',
        'LoR_Score',
        'DNR_Score',
        'CDF_Score',
        'Delivered',
        'DELIVERED',
        'delivered',
        'LoR DPMO',
        'DNR DPMO',
        'CDF DPMO',
        'rank',
        'Rank',
        'statusBucket',
        'status_bucket',
      ]);

      if (hasPodRow) {
        final podQuality = {
          'opportunities': _numFromAny(m, ['POD_Q_Opportunities'])?.toDouble(),
          'success': _numFromAny(m, ['POD_Q_Success'])?.toDouble(),
          'bypass': _numFromAny(m, ['POD_Q_Bypass'])?.toDouble(),
          'rejects': _numFromAny(m, ['POD_Q_Rejects'])?.toDouble(),
          'blurryPhoto': _numFromAny(m, ['POD_Q_BlurryPhoto'])?.toDouble(),
          'photoTooDark': _numFromAny(m, ['POD_Q_PhotoTooDark'])?.toDouble(),
          'noPackageDetected': _numFromAny(m, ['POD_Q_NoPackageDetected'])?.toDouble(),
          'packageInCar': _numFromAny(m, ['POD_Q_PackageInCar'])?.toDouble(),
          'packageTooClose': _numFromAny(m, ['POD_Q_PackageTooClose'])?.toDouble(),
        };

        batch.set(scoreRef, {
          'reportRef'    : reportRef,
          'reportPath'   : reportRef.path,
          'reportId'     : reportId,
          'transporterId': transporterId,
          'driverName'   : driverName,
          'year': year,
          'weekNumber': week,
          'reportDate'   : FieldValue.serverTimestamp(),
          'podQuality'   : podQuality,
          'computedAt'   : FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      if (hasConcessionsRow) {
        final concessions = {
          'totalDelivered': _numFromAny(m, ['CONC_TotalDelivered'])?.toDouble(),
          'totalDnr': _numFromAny(m, ['CONC_TotalDnr'])?.toDouble(),
          'dnrDpmo4w': _numFromAny(m, ['CONC_DnrDpmo4w'])?.toDouble(),
          'dnrCountByWeek': {
            'w1': _numFromAny(m, ['CONC_DnrCount_W1'])?.toDouble(),
            'w2': _numFromAny(m, ['CONC_DnrCount_W2'])?.toDouble(),
            'w3': _numFromAny(m, ['CONC_DnrCount_W3'])?.toDouble(),
            'w4': _numFromAny(m, ['CONC_DnrCount_W4'])?.toDouble(),
          },
          'dnrDpmoByWeek': {
            'w1': _numFromAny(m, ['CONC_DnrDpmo_W1'])?.toDouble(),
            'w2': _numFromAny(m, ['CONC_DnrDpmo_W2'])?.toDouble(),
            'w3': _numFromAny(m, ['CONC_DnrDpmo_W3'])?.toDouble(),
            'w4': _numFromAny(m, ['CONC_DnrDpmo_W4'])?.toDouble(),
          },
          'focusBuckets': {
            // Legacy buckets (alte Concessions XLSX-Variante)
            'attendedDnr':
                _numFromAny(m, ['CONC_Focus_AttendedDnr'])?.toDouble(),
            'photoOnDelivery':
                _numFromAny(m, ['CONC_Focus_PhotoOnDelivery'])?.toDouble(),
            'successfulContact':
                _numFromAny(m, ['CONC_Focus_SuccessfulContact'])?.toDouble(),
            'delivered25m':
                _numFromAny(m, ['CONC_Focus_Delivered25m'])?.toDouble(),
            'falseScan':
                _numFromAny(m, ['CONC_Focus_FalseScan'])?.toDouble(),
            'mailbox': _numFromAny(m, ['CONC_Focus_Mailbox'])?.toDouble(),
            'deliveredOtp':
                _numFromAny(m, ['CONC_Focus_DeliveredOtp'])?.toDouble(),
          },
          // NEW: DSC Concession format fields (Amazon 2026)
          // dnrCountByYearWeek: {"2026-16": 4, "2026-17": 3, ...}
          'dnrCountByYearWeek':
              (m['CONC_DnrCountByWeek'] as Map?)?.cast<String, dynamic>(),
          // dscBuckets: new buckets mapping {bucketKey: count}
          'dscBuckets':
              (m['CONC_DscBuckets'] as Map?)?.cast<String, dynamic>(),
          // dnrEvents: list of {trackingId, dnrDate, deliveryDateTime, ...}
          'dnrEvents': m['CONC_DnrEvents'],
        };

        batch.set(scoreRef, {
          'reportRef'    : reportRef,
          'reportPath'   : reportRef.path,
          'reportId'     : reportId,
          'transporterId': transporterId,
          'driverName'   : driverName,
          'year': year,
          'weekNumber': week,
          'reportDate'   : FieldValue.serverTimestamp(),
          'concessions'  : concessions,
          'computedAt'   : FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      if (hasCdfRow) {
        final cdfDoc = {
          'totalFeedback':
              _numFromAny(m, ['CDF_TotalFeedback'])?.toDouble(),
          'negativeFeedback':
              _numFromAny(m, ['CDF_NegativeFeedback'])?.toDouble(),
          'l1Buckets': {
            'neverReceived':
                _numFromAny(m, ['CDF_L1_NeverReceived'])?.toDouble(),
            'driverMishandled':
                _numFromAny(m, ['CDF_L1_DriverMishandled'])?.toDouble(),
            'notDeliveredToPreferredLocation': _numFromAny(
                m, ['CDF_L1_NotDeliveredToPreferredLocation'])?.toDouble(),
            'damagedPackage':
                _numFromAny(m, ['CDF_L1_DamagedPackage'])?.toDouble(),
            'deliveryWasLate':
                _numFromAny(m, ['CDF_L1_DeliveryWasLate'])?.toDouble(),
            'badDeliveryExperience':
                _numFromAny(m, ['CDF_L1_BadDeliveryExperience'])?.toDouble(),
            'driverWasUnprofessional': _numFromAny(
                m, ['CDF_L1_DriverWasUnprofessional'])?.toDouble(),
            'other': _numFromAny(m, ['CDF_L1_Other'])?.toDouble(),
          },
          // event-level rows: list of maps with trackingId, feedbackL1/L2,
          // feedbackDate, city, postalCode, dnrConcession, ...
          'events': m['CDF_Events'],
        };

        batch.set(scoreRef, {
          'reportRef'    : reportRef,
          'reportPath'   : reportRef.path,
          'reportId'     : reportId,
          'transporterId': transporterId,
          'driverName'   : driverName,
          'year': year,
          'weekNumber': week,
          'reportDate'   : FieldValue.serverTimestamp(),
          'cdf'          : cdfDoc,
          'computedAt'   : FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      if (hasDwcRow) {
        final rawMisses = m['DWC_Misses'];
        final misses = <String, dynamic>{
          if (rawMisses is Map)
            for (final e in rawMisses.entries)
              e.key.toString(): e.value is num
                  ? (e.value as num).toInt()
                  : int.tryParse('${e.value}') ?? 0,
        };
        final dwcDoc = {
          'dwcPct' : _numFromAny(m, ['DWC_DwcPct'])?.toDouble(),
          'iadcPct': _numFromAny(m, ['DWC_IadcPct'])?.toDouble(),
          // Per-category miss counts { "Photo Defect": 3, … }.
          'misses' : misses,
        };

        batch.set(scoreRef, {
          'reportRef'    : reportRef,
          'reportPath'   : reportRef.path,
          'reportId'     : reportId,
          'transporterId': transporterId,
          'driverName'   : driverName,
          'year': year,
          'weekNumber': week,
          'reportDate'   : FieldValue.serverTimestamp(),
          'dwc'          : dwcDoc,
          'computedAt'   : FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      if (hasDspRow) {
        final comp = {
          'POD_Score' : _numFromAny(m, ['POD_Score'])?.toDouble(),
          'CC_Score'  : _numFromAny(m, ['CC_Score'])?.toDouble(),
          'DCR_Score' : _numFromAny(m, ['DCR_Score'])?.toDouble(),
          'CE_Score'  : _numFromAny(m, ['CE_Score'])?.toDouble(),
          'LoR_Score' : _numFromAny(m, ['LoR_Score'])?.toDouble(),
          'DNR_Score' : _numFromAny(m, ['DNR_Score'])?.toDouble(),
          'CDF_Score' : _numFromAny(m, ['CDF_Score'])?.toDouble(),
          'FinalScore': _numFromAny(m, ['FinalScore'])?.toDouble(),
        };

        final kpis = {
          'Delivered': _numFromAny(m, ['Delivered', 'DELIVERED', 'delivered'])?.toDouble(),
          'POD'      : m['POD'],
          'CC'       : m['CC'],
          'DCR'      : m['DCR'],
          'CE'       : _numFromAny(m, ['CE'])?.toDouble(),
          'LoR'      : _numFromAny(m, ['LoR DPMO', 'LoR'])?.toDouble(),
          'DNR'      : _numFromAny(m, ['DNR DPMO', 'DNR'])?.toDouble(),
          'CDF'      : _numFromAny(m, ['CDF DPMO', 'CDF'])?.toDouble(),
        };

        final rank = _numFromAny(m, ['rank', 'Rank'])?.toInt();

        final incomingBucket = _firstNonEmpty(m, [
          'statusBucket',
          'status_bucket',
          'status',
          'bucket',
        ]);

        batch.set(scoreRef, {
          'reportRef'    : reportRef,
          'reportPath'   : reportRef.path,
          'reportId'     : reportId,
          'transporterId': transporterId,
          'driverName'   : driverName, // <-- attach if known
          'year': year,
          'weekNumber': week,
          'reportDate'   : FieldValue.serverTimestamp(),
          'kpis'         : kpis,
          'comp'         : comp,
          'rank'         : rank,
          if (incomingBucket.isNotEmpty) 'statusBucket': incomingBucket,
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
