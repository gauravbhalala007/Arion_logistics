// lib/services/driver_csv.dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';

class DriverCsvService {
  /// Upload a CSV with driver names for the CURRENT USER.
  /// Propagates names to:
  /// 1) users/{uid}/drivers (master dictionary)
  /// 2) users/{uid}/reports/*/driverNames
  /// 3) users/{uid}/scores (adds/refreshes driverName)
  static Future<void> importForUser({
    required String uid,
    required Uint8List csvBytes,
  }) async {
    final db = FirebaseFirestore.instance;

    // ---------- Parse CSV (detect delimiter) ----------
    final text = utf8.decode(csvBytes, allowMalformed: true).replaceAll('\uFEFF', '');
    final delimiter = _detectDelimiter(text);
    final rows = const CsvToListConverter(
      eol: '\n',
      fieldDelimiter: ',',
      shouldParseNumbers: false,
    ).convert(delimiter == ',' ? text : text.replaceAll(delimiter, ','));

    if (rows.isEmpty) return;

    // ---------- Header detection (several variants) ----------
    final header = rows.first.map((x) => x.toString().trim().toLowerCase()).toList();

    final idIdx = _firstIndex(header, const [
      'zustellende-id','zustellende id','transporter id','transporterid',
      'associate id','driver id','driverid','id','mitarbeiter id',
    ]);

    final nameIdx = _firstIndex(header, const [
      'name des zustellenden','driver name','name','employee name','mitarbeiter name',
    ]);

    if (idIdx < 0) {
      throw Exception('CSV missing transporter ID column (e.g. "Transporter ID" / "Zustellende-ID").');
    }

    // ---------- Build {transporterId -> driverName} ----------
    final latestNameById = <String, String>{};
    for (var i = 1; i < rows.length; i++) {
      final r = rows[i];
      if (r.isEmpty) continue;

      final rawId   = (idIdx   < r.length ? r[idIdx]   : '').toString().trim();
      final rawName = (nameIdx >= 0 && nameIdx < r.length ? r[nameIdx] : '').toString().trim();
      if (rawId.isEmpty) continue;

      final tid = _normId(rawId);
      if (tid.isEmpty) continue;

      if (rawName.isNotEmpty) {
        latestNameById[tid] = rawName;
      }
    }
    if (latestNameById.isEmpty) return;

    // ---------- 1) Update users/{uid}/drivers ----------
    await _writeDriversUser(db, uid, latestNameById);

    // ---------- 2) Update ALL reports of this user (driverNames subcollection) ----------
    final reportSnaps = await db
        .collection('users').doc(uid)
        .collection('reports')
        .get();

    final reportRefs = reportSnaps.docs.map((d) => d.reference).toList();
    await _writeDriverNamesToUserReports(db, reportRefs, latestNameById);

    // ---------- 3) Update ALL scores for this user (attach driverName) ----------
    await _updateAllUserScoresWithNames(db, uid, latestNameById);
  }

  /// Backward compatibility with older call sites. Keeps signature but uses uid
  /// from the report’s path: users/{uid}/reports/{reportId}.
  static Future<void> importForReport({
    required String reportId, // not used directly anymore
    required Uint8List csvBytes,
  }) async {
    // This path is kept only for compatibility; callers should prefer importForUser.
    // We infer uid by looking up the report in all users. If that’s too heavy,
    // please switch your UI to call importForUser(uid: …).
    final db = FirebaseFirestore.instance;

    // Try to discover the owning uid by scanning user report ids (limited).
    final usersSnap = await db.collection('users').limit(50).get();
    String? ownerUid;
    DocumentReference<Map<String, dynamic>>? ownerReportRef;

    for (final u in usersSnap.docs) {
      final rs = await db
          .collection('users').doc(u.id)
          .collection('reports').doc(reportId).get();
      if (rs.exists) {
        ownerUid = u.id;
        ownerReportRef = rs.reference;
        break;
      }
    }
    if (ownerUid == null || ownerReportRef == null) {
      throw Exception('Could not find report owner for $reportId. Call importForUser(uid: …) instead.');
    }

    // Delegate to the correct user-scoped import
    await importForUser(uid: ownerUid, csvBytes: csvBytes);
  }

  // ====================== Helpers ======================

  static String _detectDelimiter(String text) {
    final lines = const LineSplitter().convert(text);
    final first = lines.firstWhere((l) => l.trim().isNotEmpty, orElse: () => '');
    if (first.isEmpty) return ',';
    final comma = first.split(',').length;
    final semi  = first.split(';').length;
    final tab   = first.split('\t').length;
    if (comma >= semi && comma >= tab) return ',';
    if (semi >= comma && semi >= tab)  return ';';
    return '\t';
  }

  static int _firstIndex(List<String> header, List<String> alts) {
    for (var i = 0; i < header.length; i++) {
      final h = header[i];
      for (final a in alts) {
        if (h == a) return i;
      }
    }
    for (var i = 0; i < header.length; i++) {
      final h = header[i];
      for (final a in alts) {
        if (h.contains(a)) return i;
      }
    }
    return -1;
  }

  static String _normId(String raw) {
    final cleaned = raw.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    return cleaned.isEmpty ? raw.trim() : cleaned;
  }

  // ------------ Firestore write helpers (USER-SCOPED) ------------

  static Future<void> _writeDriversUser(
    FirebaseFirestore db,
    String uid,
    Map<String, String> idToName,
  ) async {
    const chunk = 400;
    final entries = idToName.entries.toList();
    for (var i = 0; i < entries.length; i += chunk) {
      final batch = db.batch();
      final slice = entries.sublist(i, (i + chunk > entries.length) ? entries.length : i + chunk);

      for (final e in slice) {
        final doc = db.collection('users').doc(uid)
            .collection('drivers').doc(e.key);
        batch.set(doc, {
          'transporterId': e.key,
          'driverName'   : e.value,
          'updatedAt'    : FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      await batch.commit();
    }
  }

  static Future<void> _writeDriverNamesToUserReports(
    FirebaseFirestore db,
    List<DocumentReference<Map<String, dynamic>>> reportRefs,
    Map<String, String> idToName,
  ) async {
    const reportsPerPass = 40;
    for (var r = 0; r < reportRefs.length; r += reportsPerPass) {
      final refs = reportRefs.sublist(r, (r + reportsPerPass > reportRefs.length) ? reportRefs.length : r + reportsPerPass);

      for (final reportRef in refs) {
        const chunk = 400;
        final entries = idToName.entries.toList();
        for (var i = 0; i < entries.length; i += chunk) {
          final batch = db.batch();
          final slice = entries.sublist(i, (i + chunk > entries.length) ? entries.length : i + chunk);

          for (final e in slice) {
            final doc = reportRef.collection('driverNames').doc(e.key);
            batch.set(doc, {
              'transporterId': e.key,
              'driverName'   : e.value,
              'updatedAt'    : FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }
          await batch.commit();
        }
      }
    }
  }

  static Future<void> _updateAllUserScoresWithNames(
    FirebaseFirestore db,
    String uid,
    Map<String, String> idToName,
  ) async {
    for (final entry in idToName.entries) {
      final tid = entry.key;
      final name = entry.value;

      final q = await db
          .collection('users').doc(uid)
          .collection('scores')
          .where('transporterId', isEqualTo: tid)
          .get();

      if (q.docs.isEmpty) continue;

      const chunk = 400;
      final docs = q.docs;
      for (var i = 0; i < docs.length; i += chunk) {
        final batch = db.batch();
        final slice = docs.sublist(i, (i + chunk > docs.length) ? docs.length : i + chunk);

        for (final d in slice) {
          batch.set(d.reference, {
            'driverName': name,
            'updatedAt' : FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
        await batch.commit();
      }
    }
  }
}
