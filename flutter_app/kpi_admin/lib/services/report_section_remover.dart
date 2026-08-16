// lib/services/report_section_remover.dart
//
// Entfernt EINE Feature-Sektion (CDF, DWC, POD, Concessions, Scorecard)
// aus einer Report-Woche — statt die ganze Woche zu löschen.
//
// Hintergrund: Alle Features teilen sich pro Kalenderwoche EIN Dokument
// `users/{uid}/reports/{reportId}` und je Fahrer EIN Dokument
// `users/{uid}/scores/{reportId}_{tid}`. Ein `reportRef.delete()` löscht
// deshalb auch Scorecard-, POD- und Concessions-Daten derselben Woche —
// genau so gingen im August 2026 Wochen verloren.
//
// Diese Klasse löscht gezielt:
//   - `summary.<sectionKey>` im Report-Dokument
//   - die zugehörigen Felder in allen Score-Dokumenten der Woche
// und entfernt das Report-Dokument nur dann komplett, wenn danach keine
// Feature-Daten mehr übrig sind.

import 'package:cloud_firestore/cloud_firestore.dart';

class ReportSectionRemover {
  /// Alle bekannten Feature-Sektionen in `report.summary`.
  static const List<String> knownSections = [
    'deliveryQualitySwc',
    'complianceAndSafety',
    'podQuality',
    'concessions',
    'cdf',
    'dwc',
  ];

  /// Zusätzliche Summary-Keys, die zur Scorecard gehören und mit ihr
  /// zusammen verschwinden müssen.
  static const List<String> _scorecardExtras = [
    'overallScore',
    'overallStatus',
    'rankAtStation',
    'rankDeltaWoW',
    'stationCount',
    'reliabilityScore',
    'reliabilityNextDay',
    'reliabilitySameDay',
  ];

  /// Entfernt eine Feature-Sektion aus der Woche [reportRef].
  ///
  /// [sectionKey] ist die Hauptsektion; [alsoRemove] weitere Summary-Keys,
  /// die untrennbar dazugehören (z. B. `complianceAndSafety` bei der
  /// Scorecard). [scoreFields] sind die Felder im Score-Dokument des
  /// Fahrers, die zu dieser Sektion gehören (z. B. `['cdf']`).
  ///
  /// Gibt zurück, ob das Report-Dokument komplett entfernt wurde (weil
  /// keine anderen Daten mehr übrig waren).
  static Future<bool> removeSection({
    required String uid,
    required DocumentReference<Map<String, dynamic>> reportRef,
    required String sectionKey,
    required List<String> scoreFields,
    List<String> alsoRemove = const [],
  }) async {
    final db = FirebaseFirestore.instance;

    final snap = await reportRef.get();
    final data = snap.data() ?? const <String, dynamic>{};
    final summary =
        (data['summary'] as Map?)?.cast<String, dynamic>() ?? const {};

    final removedKeys = <String>{sectionKey, ...alsoRemove};

    // Welche Sektionen bleiben nach dem Entfernen übrig?
    final remaining = knownSections
        .where((k) => !removedKeys.contains(k) && summary[k] != null)
        .toList();
    final deleteWholeReport = remaining.isEmpty;

    final scores = await db
        .collection('users')
        .doc(uid)
        .collection('scores')
        .where('reportPath', isEqualTo: reportRef.path)
        .get();

    // Firestore erlaubt 500 Operationen pro Batch.
    var batch = db.batch();
    var ops = 0;
    Future<void> flushIfNeeded() async {
      if (ops >= 400) {
        await batch.commit();
        batch = db.batch();
        ops = 0;
      }
    }

    for (final s in scores.docs) {
      final sd = s.data();
      // Bleibt im Score-Doc noch etwas Sinnvolles übrig?
      final otherFeatureFields = sd.keys.where((k) =>
          !scoreFields.contains(k) &&
          const {
            'reportRef',
            'reportPath',
            'reportId',
            'transporterId',
            'driverName',
            'year',
            'weekNumber',
            'reportDate',
            'computedAt',
          }.contains(k) ==
              false);

      if (deleteWholeReport && otherFeatureFields.isEmpty) {
        batch.delete(s.reference);
      } else {
        batch.update(s.reference, {
          for (final f in scoreFields) f: FieldValue.delete(),
        });
      }
      ops++;
      await flushIfNeeded();
    }

    if (deleteWholeReport) {
      // Auch die driverNames-Subcollection mitnehmen, sonst bleiben
      // verwaiste Dokumente unter dem gelöschten Report liegen.
      final names = await reportRef.collection('driverNames').get();
      for (final n in names.docs) {
        batch.delete(n.reference);
        ops++;
        await flushIfNeeded();
      }
      batch.delete(reportRef);
    } else {
      batch.update(reportRef, {
        for (final k in removedKeys) 'summary.$k': FieldValue.delete(),
        if (sectionKey == 'deliveryQualitySwc')
          for (final k in _scorecardExtras) 'summary.$k': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
    return deleteWholeReport;
  }
}
