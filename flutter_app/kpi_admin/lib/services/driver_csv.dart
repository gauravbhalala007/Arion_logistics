import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';

class DriverCsvService {
  static Future<void> importForReport({
    required String reportId,
    required Uint8List csvBytes,
  }) async {
    final db = FirebaseFirestore.instance;
    final csvText = utf8.decode(csvBytes).replaceAll('\uFEFF', '');
    final rows = const CsvToListConverter(eol: '\n', fieldDelimiter: ',').convert(csvText);

    if (rows.isEmpty) return;

    final header = rows.first.map((x) => x.toString().trim().toLowerCase()).toList();
    int idxId   = _firstIndex(header, ['zustellende-id','transporter id','transporterid','associate id','driver id','id']);
    int idxName = _firstIndex(header, ['name des zustellenden','driver name','name','employee name']);
    if (idxId < 0) throw Exception('CSV missing transporter ID column');

    final reportRef = db.collection('reports').doc(reportId);
    final batch = db.batch();
    final latestNameById = <String,String>{};

    for (var i = 1; i < rows.length; i++) {
      final r = rows[i];
      if (r.isEmpty) continue;
      final id   = (idxId   < r.length ? r[idxId]   : '').toString().trim();
      final name = (idxName >= 0 && idxName < r.length ? r[idxName] : '').toString().trim();
      if (id.isEmpty) continue;
      if (name.isNotEmpty) latestNameById[id] = name;
    }

    // per-report names
    latestNameById.forEach((tid, driverName) {
      final ref = reportRef.collection('driverNames').doc(tid);
      batch.set(ref, {
        'transporterId': tid,
        'driverName'   : driverName,
        'updatedAt'    : FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });

    await batch.commit();

    // denormalize into that week's /scores
    for (final e in latestNameById.entries) {
      final tid = e.key;
      final driverName = e.value;
      final scoreId = '${reportId}_$tid';
      await db.collection('scores').doc(scoreId).set({
        'driverName': driverName,
        'updatedAt' : FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  static int _firstIndex(List<String> header, List<String> alts) {
    for (var i = 0; i < header.length; i++) {
      final h = header[i];
      for (final a in alts) {
        if (h == a) return i;
      }
    }
    return -1;
  }
}
