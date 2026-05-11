// lib/services/time_account_repository.dart
//
// Reads / writes the time-account documents and parses the payroll
// Excel produced by the external time-tracking tool. Each Excel
// upload creates a `time_imports/{id}` doc plus one
// `time_imports/{id}/entries/{rowId}` per employee row.

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart' as xlsx;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/time_account.dart';

class TimeAccountRepository {
  TimeAccountRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> _imports(String dspUid) => _firestore
      .collection('users')
      .doc(dspUid)
      .collection('time_imports');

  CollectionReference<Map<String, dynamic>> _entries(
    String dspUid,
    String importId,
  ) => _imports(dspUid).doc(importId).collection('entries');

  CollectionReference<Map<String, dynamic>> _paidHours(String dspUid) =>
      _firestore.collection('users').doc(dspUid).collection('paid_hours');

  /// Streams every imported entry across all imports for the admin.
  /// The page aggregates these client-side into per-employee monthly
  /// rows.
  Stream<List<TimeImportEntry>> watchAllEntries(String dspUid) {
    return _firestore
        .collectionGroup('entries')
        .where('dspUid', isEqualTo: dspUid)
        .snapshots()
        .map((snap) => snap.docs.map(TimeImportEntry.fromDoc).toList());
  }

  /// Alternative — read entries one import at a time. Avoids the need
  /// for a collection-group index. Used by the page that lists all
  /// imports + aggregates from there.
  Stream<List<TimeImport>> watchImports(String dspUid) {
    return _imports(dspUid)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(TimeImport.fromDoc).toList());
  }

  Future<List<TimeImportEntry>> readEntries({
    required String dspUid,
    required String importId,
  }) async {
    final snap = await _entries(dspUid, importId).get();
    return snap.docs.map(TimeImportEntry.fromDoc).toList();
  }

  Stream<List<PaidHoursEntry>> watchPaidHours(String dspUid) {
    return _paidHours(dspUid)
        .orderBy('paidAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(PaidHoursEntry.fromDoc).toList());
  }

  Future<String> addPaidHours({
    required String dspUid,
    required String employeeId,
    required String employeeName,
    required double hours,
    required DateTime paidAt,
    String? note,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final ref = await _paidHours(dspUid).add({
      'employeeId': employeeId,
      'employeeName': employeeName,
      'hours': hours,
      'paidAt': Timestamp.fromDate(paidAt),
      if (note != null && note.isNotEmpty) 'note': note,
      if (uid != null) 'createdByUid': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> deletePaidHours({
    required String dspUid,
    required String id,
  }) => _paidHours(dspUid).doc(id).delete();

  Future<void> deleteImport({
    required String dspUid,
    required String importId,
  }) async {
    // Delete all entries in batches.
    final entriesSnap = await _entries(dspUid, importId).get();
    for (var i = 0; i < entriesSnap.docs.length; i += 400) {
      final batch = _firestore.batch();
      for (final d
          in entriesSnap.docs.skip(i).take(400)) {
        batch.delete(d.reference);
      }
      await batch.commit();
    }
    // Best-effort Storage cleanup.
    try {
      final folder = _storage.ref('users/$dspUid/time_imports/$importId');
      final list = await folder.listAll();
      for (final f in list.items) {
        await f.delete();
      }
    } catch (_) {}
    await _imports(dspUid).doc(importId).delete();
  }

  /// Parses [bytes] (an xlsx file) into a draft list of entries +
  /// summary metadata. Detects the period from the filename or the
  /// header columns. Does NOT write anything yet — caller can preview
  /// before persisting via [commitImport].
  static Future<_ParsedImport> parseExcel({
    required String filename,
    required Uint8List bytes,
  }) async {
    final book = xlsx.Excel.decodeBytes(bytes);
    if (book.sheets.isEmpty) {
      throw StateError('Excel-Datei enthält kein Sheet.');
    }
    final sheet = book.tables.values.first;
    if (sheet == null || sheet.rows.isEmpty) {
      throw StateError('Erstes Sheet ist leer.');
    }

    // Locate the header row: pick the row that contains the literal
    // "Employee" + "time tracked" + "contractual expected" cells.
    int headerIdx = -1;
    for (var i = 0; i < sheet.rows.length && i < 5; i++) {
      final row = sheet.rows[i];
      final values = row
          .map((c) => (c?.value ?? '').toString().toLowerCase().trim())
          .toList();
      if (values.contains('employee') &&
          values.contains('time tracked') &&
          values.contains('contractual expected')) {
        headerIdx = i;
        break;
      }
    }
    if (headerIdx == -1) {
      throw StateError(
        'Spalten "Employee", "time tracked" und "contractual expected" '
        'wurden nicht gefunden.',
      );
    }

    final header = [
      for (final c in sheet.rows[headerIdx])
        (c?.value ?? '').toString().toLowerCase().trim(),
    ];
    int col(String name) => header.indexOf(name.toLowerCase());

    final iEmp = col('Employee');
    final iEmpId = col('Employee ID');
    final iSoll = col('contractual expected');
    final iIst = col('time tracked');
    final iOvertime = col('overtime balance');
    final iStation = col('delivery station');
    final iContract = col('contract type');
    final iRate = col('hourly rate');

    final period = _detectPeriod(filename);

    final entries = <_ParsedRow>[];
    for (var r = headerIdx + 1; r < sheet.rows.length; r++) {
      final row = sheet.rows[r];
      if (row.isEmpty) continue;

      String at(int i) {
        if (i < 0 || i >= row.length) return '';
        final v = row[i]?.value;
        if (v == null) return '';
        return v.toString().trim();
      }

      double num0(int i) {
        if (i < 0 || i >= row.length) return 0.0;
        final v = row[i]?.value;
        if (v == null) return 0.0;
        final s = v.toString().replaceAll(',', '.');
        return double.tryParse(s) ?? 0.0;
      }

      final emp = at(iEmp);
      if (emp.isEmpty) continue; // skip totals / empty rows

      entries.add(_ParsedRow(
        employeeName: emp,
        employeeId: at(iEmpId),
        sollHours: num0(iSoll),
        istHours: num0(iIst),
        overtimeBalance: num0(iOvertime),
        deliveryStation: at(iStation).isEmpty ? null : at(iStation),
        contractType: at(iContract).isEmpty ? null : at(iContract),
        hourlyRate: num0(iRate),
        raw: {
          for (var c = 0; c < header.length && c < row.length; c++)
            if (header[c].isNotEmpty)
              header[c]: row[c]?.value?.toString() ?? '',
        },
      ));
    }

    return _ParsedImport(
      periodStart: period.start,
      periodEnd: period.end,
      rows: entries,
    );
  }

  /// Persists a parsed import. Uploads the original xlsx to Storage
  /// for audit (if [bytes] is supplied) and writes one Firestore doc
  /// per row.
  Future<String> commitImport({
    required String dspUid,
    required String filename,
    required _ParsedImport parsed,
    Uint8List? bytes,
  }) async {
    final importRef = _imports(dspUid).doc();
    final uid = FirebaseAuth.instance.currentUser?.uid;

    String? storagePath;
    if (bytes != null) {
      final ref = _storage.ref(
        'users/$dspUid/time_imports/${importRef.id}/$filename',
      );
      await ref.putData(
        bytes,
        SettableMetadata(
          contentType:
              'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        ),
      );
      storagePath = ref.fullPath;
    }

    await importRef.set({
      'filename': filename,
      'rowCount': parsed.rows.length,
      'periodStart': Timestamp.fromDate(parsed.periodStart),
      'periodEnd': Timestamp.fromDate(parsed.periodEnd),
      'uploadedAt': FieldValue.serverTimestamp(),
      if (uid != null) 'uploadedByUid': uid,
      if (storagePath != null) 'storagePath': storagePath,
    });

    // Write entries in chunks of 400.
    for (var i = 0; i < parsed.rows.length; i += 400) {
      final batch = _firestore.batch();
      for (final p in parsed.rows.skip(i).take(400)) {
        final ref = _entries(dspUid, importRef.id).doc();
        batch.set(ref, {
          'dspUid': dspUid,
          'importId': importRef.id,
          'employeeName': p.employeeName,
          'employeeId': p.employeeId,
          'sollHours': p.sollHours,
          'istHours': p.istHours,
          'overtimeBalance': p.overtimeBalance,
          'periodStart': Timestamp.fromDate(parsed.periodStart),
          'periodEnd': Timestamp.fromDate(parsed.periodEnd),
          if (p.deliveryStation != null)
            'deliveryStation': p.deliveryStation,
          if (p.contractType != null) 'contractType': p.contractType,
          if (p.hourlyRate != null && p.hourlyRate! > 0)
            'hourlyRate': p.hourlyRate,
          'raw': p.raw,
        });
      }
      await batch.commit();
    }

    return importRef.id;
  }

  /// Best-effort: extract a period (YYYY-MM-DD_YYYY-MM-DD) from the
  /// filename (matches the format the external tool produces:
  /// `payroll_export_2026-03-01_2026-03-31.xlsx`).
  static _Period _detectPeriod(String filename) {
    final re = RegExp(
      r'(\d{4})-(\d{2})-(\d{2})[_\-](\d{4})-(\d{2})-(\d{2})',
    );
    final m = re.firstMatch(filename);
    if (m != null) {
      return _Period(
        start: DateTime(
          int.parse(m.group(1)!),
          int.parse(m.group(2)!),
          int.parse(m.group(3)!),
        ),
        end: DateTime(
          int.parse(m.group(4)!),
          int.parse(m.group(5)!),
          int.parse(m.group(6)!),
        ),
      );
    }
    // Fallback: current month.
    final now = DateTime.now();
    return _Period(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month + 1, 0),
    );
  }
}

class _Period {
  final DateTime start;
  final DateTime end;
  const _Period({required this.start, required this.end});
}

class _ParsedRow {
  final String employeeName;
  final String employeeId;
  final double sollHours;
  final double istHours;
  final double overtimeBalance;
  final String? deliveryStation;
  final String? contractType;
  final double? hourlyRate;
  final Map<String, dynamic> raw;
  const _ParsedRow({
    required this.employeeName,
    required this.employeeId,
    required this.sollHours,
    required this.istHours,
    required this.overtimeBalance,
    this.deliveryStation,
    this.contractType,
    this.hourlyRate,
    required this.raw,
  });
}

class _ParsedImport {
  final DateTime periodStart;
  final DateTime periodEnd;
  final List<_ParsedRow> rows;
  const _ParsedImport({
    required this.periodStart,
    required this.periodEnd,
    required this.rows,
  });
}

/// Make the ParsedImport class accessible to UI code that wants to
/// preview the parsed rows before committing.
typedef ParsedImport = _ParsedImport;
typedef ParsedRow = _ParsedRow;
