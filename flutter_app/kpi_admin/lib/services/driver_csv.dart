// lib/services/driver_csv.dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

class DriverCsvImportResult {
  const DriverCsvImportResult({
    required this.parsedRows,
    required this.mappedDrivers,
    required this.newDrivers,
    required this.updatedScores,
  });

  final int parsedRows;
  final int mappedDrivers;
  final int newDrivers;
  final int updatedScores;
}

class DriverCsvService {
  /// Upload a CSV with driver names for the CURRENT USER.
  /// Propagates names to:
  /// 1) users/{uid}/drivers (master dictionary)
  /// 2) users/{uid}/reports/*/driverNames
  /// 3) users/{uid}/scores (adds/refreshes driverName)
  static Future<DriverCsvImportResult> importForUser({
    required String uid,
    required Uint8List csvBytes,
  }) async {
    final db = FirebaseFirestore.instance;

    // ---------- Parse CSV (detect delimiter) ----------
    final text = utf8.decode(csvBytes, allowMalformed: true).replaceAll('\uFEFF', '');
    final delimiter = _detectDelimiter(text);
    final rows = _parseCsv(text, delimiter: delimiter);

    if (rows.isEmpty) {
      return const DriverCsvImportResult(
        parsedRows: 0,
        mappedDrivers: 0,
        newDrivers: 0,
        updatedScores: 0,
      );
    }

    // ---------- Header detection (several variants) ----------
    final header = rows.first.map((x) => x.toString().trim()).toList();

    final idIdx = _findIdColumnIndex(header);
    final nameIdx = _findNameColumnIndex(header);

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

      final tid = normalizeTransporterId(rawId);
      if (tid.isEmpty) continue;

      if (rawName.isNotEmpty) {
        latestNameById[tid] = rawName;
      }
    }
    if (latestNameById.isEmpty) {
      return DriverCsvImportResult(
        parsedRows: rows.length > 1 ? rows.length - 1 : 0,
        mappedDrivers: 0,
        newDrivers: 0,
        updatedScores: 0,
      );
    }

    // ---------- 1) Update users/{uid}/drivers ----------
    final newDrivers = await _writeDriversUser(db, uid, latestNameById);

    // ---------- 2) Update ALL reports of this user (driverNames subcollection) ----------
    final reportSnaps = await db
        .collection('users').doc(uid)
        .collection('reports')
        .get();

    final reportRefs = reportSnaps.docs.map((d) => d.reference).toList();
    await _writeDriverNamesToUserReports(db, reportRefs, latestNameById);

    // ---------- 3) Update ALL scores for this user (attach driverName) ----------
    final updatedScores = await _updateAllUserScoresWithNames(
      db,
      uid,
      latestNameById,
    );

    return DriverCsvImportResult(
      parsedRows: rows.length > 1 ? rows.length - 1 : 0,
      mappedDrivers: latestNameById.length,
      newDrivers: newDrivers,
      updatedScores: updatedScores,
    );
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

  static List<List<String>> _parseCsv(String text, {required String delimiter}) {
    final rows = <List<String>>[];
    var row = <String>[];
    var field = StringBuffer();
    var inQuotes = false;

    void pushField() {
      row.add(field.toString());
      field = StringBuffer();
    }

    void pushRow() {
      final normalized = row.map((value) => value.replaceAll('\r', '')).toList();
      final hasContent = normalized.any((value) => value.trim().isNotEmpty);
      if (hasContent) rows.add(normalized);
      row = <String>[];
    }

    for (var i = 0; i < text.length; i++) {
      final ch = text[i];

      if (inQuotes) {
        if (ch == '"') {
          final nextIsQuote = i + 1 < text.length && text[i + 1] == '"';
          if (nextIsQuote) {
            field.write('"');
            i++;
          } else {
            inQuotes = false;
          }
        } else {
          field.write(ch);
        }
        continue;
      }

      if (ch == '"') {
        inQuotes = true;
        continue;
      }

      if (ch == delimiter) {
        pushField();
        continue;
      }

      if (ch == '\n') {
        pushField();
        pushRow();
        continue;
      }

      if (ch == '\r') {
        continue;
      }

      field.write(ch);
    }

    final hasTrailingData = field.isNotEmpty || row.isNotEmpty;
    if (hasTrailingData) {
      pushField();
      pushRow();
    }

    return rows;
  }

  static int _findIdColumnIndex(List<String> header) {
    return _findHeaderIndex(
      header,
      const [
        'zustellende-id',
        'zustellende id',
        'transporter id',
        'transporterid',
        'associate id',
        'delivery associate id',
        'driver id',
        'driverid',
        'mitarbeiter id',
        'id',
      ],
      const [
        ['zustellende', 'id'],
        ['transporter', 'id'],
        ['delivery', 'associate', 'id'],
        ['associate', 'id'],
        ['driver', 'id'],
        ['mitarbeiter', 'id'],
      ],
    );
  }

  static int _findNameColumnIndex(List<String> header) {
    return _findHeaderIndex(
      header,
      const [
        'name des zustellenden',
        'driver name',
        'delivery associate name',
        'employee name',
        'mitarbeiter name',
        'associate name',
        'name',
      ],
      const [
        ['name', 'zustellenden'],
        ['driver', 'name'],
        ['delivery', 'associate', 'name'],
        ['employee', 'name'],
        ['mitarbeiter', 'name'],
        ['associate', 'name'],
      ],
    );
  }

  static int _findHeaderIndex(
    List<String> header,
    List<String> exactAliases,
    List<List<String>> tokenAliases,
  ) {
    final exact = exactAliases.map(_normalizeHeader).toSet();
    for (var i = 0; i < header.length; i++) {
      if (exact.contains(_normalizeHeader(header[i]))) return i;
    }

    for (var i = 0; i < header.length; i++) {
      final normalized = _normalizeHeader(header[i]);
      for (final alias in tokenAliases) {
        if (alias.every((token) => normalized.contains(_normalizeHeader(token)))) {
          return i;
        }
      }
    }
    return -1;
  }

  static String _normalizeHeader(String raw) {
    return raw.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  static String normalizeTransporterId(String raw) {
    final cleaned = raw.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    return cleaned.isEmpty ? raw.trim() : cleaned;
  }

  // ------------ Firestore write helpers (USER-SCOPED) ------------

  static Future<int> _writeDriversUser(
    FirebaseFirestore db,
    String uid,
    Map<String, String> idToName,
  ) async {
    final existingIds = <String>{};
    final driverCol = db.collection('users').doc(uid).collection('drivers');
    final ids = idToName.keys.toList(growable: false);
    const lookupChunk = 30;
    for (var i = 0; i < ids.length; i += lookupChunk) {
      final slice = ids.sublist(
        i,
        (i + lookupChunk > ids.length) ? ids.length : i + lookupChunk,
      );
      final snap = await driverCol.where(FieldPath.documentId, whereIn: slice).get();
      for (final doc in snap.docs) {
        existingIds.add(doc.id);
      }
    }

    var createdCount = 0;
    const chunk = 400;
    final entries = idToName.entries.toList();
    for (var i = 0; i < entries.length; i += chunk) {
      final batch = db.batch();
      final slice = entries.sublist(
        i,
        (i + chunk > entries.length) ? entries.length : i + chunk,
      );

      for (final e in slice) {
        final doc = driverCol.doc(e.key);
        final isNew = !existingIds.contains(e.key);
        if (isNew) createdCount++;
        final payload = <String, dynamic>{
          'transporterId': e.key,
          'driverName': e.value,
          'updatedAt': FieldValue.serverTimestamp(),
          if (isNew) 'createdAt': FieldValue.serverTimestamp(),
          if (isNew) 'hasLogin': false,
          if (isNew) 'active': true,
        };
        batch.set(doc, payload, SetOptions(merge: true));
      }
      await batch.commit();
    }
    return createdCount;
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

  static Future<int> _updateAllUserScoresWithNames(
    FirebaseFirestore db,
    String uid,
    Map<String, String> idToName,
  ) async {
    final scoresSnap = await db
        .collection('users').doc(uid)
        .collection('scores')
        .get();

    if (scoresSnap.docs.isEmpty) return 0;

    const chunk = 400;
    final docs = scoresSnap.docs;
    var updatedCount = 0;
    for (var i = 0; i < docs.length; i += chunk) {
      final batch = db.batch();
      final slice = docs.sublist(
        i,
        (i + chunk > docs.length) ? docs.length : i + chunk,
      );
      var writes = 0;

      for (final d in slice) {
        final data = d.data();
        final rawTid = (data['transporterId'] ?? '').toString().trim();
        final normalizedTid = normalizeTransporterId(rawTid);
        final name = idToName[normalizedTid];
        if (name == null || name.isEmpty) continue;

        final update = <String, dynamic>{
          'driverName': name,
          'updatedAt': FieldValue.serverTimestamp(),
        };
        if (normalizedTid.isNotEmpty && rawTid != normalizedTid) {
          update['transporterId'] = normalizedTid;
        }

        batch.set(d.reference, update, SetOptions(merge: true));
        writes++;
        updatedCount++;
      }

      if (writes > 0) {
        await batch.commit();
      }
    }
    return updatedCount;
  }
}
