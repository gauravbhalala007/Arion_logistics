// lib/services/driver_csv.dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'driver_identity_service.dart';

class DriverCsvImportResult {
  const DriverCsvImportResult({
    required this.parsedRows,
    required this.mappedDrivers,
    required this.newDrivers,
    required this.updatedScores,
    this.mergedDrivers = 0,
    this.ambiguousDrivers = const <String>[],
    this.loginSyncWarnings = const <String>[],
    this.mergeErrors = const <String>[],
  });

  final int parsedRows;
  final int mappedDrivers;
  final int newDrivers;
  final int updatedScores;

  /// Fahrer, die statt als Dublette neu angelegt zu werden, von ihrer
  /// Platzhalter-ID (`PENDING-…`) auf die echte TID umgezogen wurden.
  final int mergedDrivers;

  /// Fälle, in denen mehrere Platzhalter-Fahrer gepasst hätten — hier
  /// wird **nichts** automatisch zusammengeführt, der Fahrer wird wie
  /// bisher neu angelegt. Format: `"Name (TID)"`.
  final List<String> ambiguousDrivers;

  /// Umzüge, bei denen die Cloud Function
  /// `syncDriverLoginTransporterId` fehlschlug. Das Fahrer-Login zeigt
  /// dann noch auf die alte ID — der Admin muss es erfahren.
  final List<String> loginSyncWarnings;

  /// Umzüge, die komplett fehlschlugen. Der Fahrer wurde stattdessen
  /// (wie bisher) unter der neuen TID angelegt.
  final List<String> mergeErrors;

  /// True, wenn der Import etwas gemeldet hat, das der Admin sehen sollte.
  bool get hasWarnings =>
      ambiguousDrivers.isNotEmpty ||
      loginSyncWarnings.isNotEmpty ||
      mergeErrors.isNotEmpty;

  /// Zweisprachige Zusammenfassung für die SnackBar nach dem Import.
  ///
  /// Der Import läuft ohne UI durch — was er automatisch zusammengeführt
  /// hat und was er bewusst NICHT angefasst hat (mehrdeutige Fälle), muss
  /// der Admin hier erfahren.
  String summary({required bool de}) {
    final parts = <String>[
      de
          ? 'Zeilen $parsedRows, zugeordnet $mappedDrivers, neu $newDrivers, '
              'Score-Zeilen $updatedScores.'
          : 'Rows $parsedRows, matched $mappedDrivers, new $newDrivers, '
              'score rows $updatedScores.',
    ];
    if (mergedDrivers > 0) {
      parts.add(de
          ? '$mergedDrivers Fahrer von ihrer Platzhalter-ID auf die echte '
              'TID zusammengeführt.'
          : '$mergedDrivers driver(s) merged from their placeholder ID onto '
              'the real TID.');
    }
    if (ambiguousDrivers.isNotEmpty) {
      parts.add(de
          ? 'Nicht eindeutig, bitte manuell prüfen: '
              '${ambiguousDrivers.join(', ')}.'
          : 'Ambiguous, please check manually: '
              '${ambiguousDrivers.join(', ')}.');
    }
    if (loginSyncWarnings.isNotEmpty) {
      parts.add(de
          ? 'Login-Sync fehlgeschlagen bei: '
              '${loginSyncWarnings.join(', ')}.'
          : 'Login sync failed for: ${loginSyncWarnings.join(', ')}.');
    }
    if (mergeErrors.isNotEmpty) {
      parts.add(de
          ? 'Zusammenführen fehlgeschlagen: ${mergeErrors.join(', ')}.'
          : 'Merge failed: ${mergeErrors.join(', ')}.');
    }
    return parts.join(' ');
  }
}

/// Zwischenergebnis von `_writeDriversUser`.
class _DriversWriteOutcome {
  const _DriversWriteOutcome({
    required this.created,
    required this.merged,
    required this.ambiguous,
    required this.loginSyncWarnings,
    required this.mergeErrors,
  });

  final int created;
  final int merged;
  final List<String> ambiguous;
  final List<String> loginSyncWarnings;
  final List<String> mergeErrors;
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
    // Optional — hilft dem Platzhalter-Matcher, wenn der Export die
    // Personalnummer mitliefert. Muss eine ANDERE Spalte als die TID
    // sein, sonst ignorieren wir sie.
    final employeeIdxRaw = _findEmployeeNumberColumnIndex(header);
    final employeeIdx = employeeIdxRaw == idIdx ? -1 : employeeIdxRaw;

    if (idIdx < 0) {
      throw Exception('CSV missing transporter ID column (e.g. "Transporter ID" / "Zustellende-ID").');
    }

    // ---------- Build {transporterId -> driverName} ----------
    final latestNameById = <String, String>{};
    final employeeNumberById = <String, String>{};
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
      if (employeeIdx >= 0 && employeeIdx < r.length) {
        final rawEmployee = r[employeeIdx].toString().trim();
        if (rawEmployee.isNotEmpty) {
          employeeNumberById[tid] = rawEmployee;
        }
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
    final driverOutcome = await _writeDriversUser(
      db,
      uid,
      latestNameById,
      employeeNumberById,
    );

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
      newDrivers: driverOutcome.created,
      updatedScores: updatedScores,
      mergedDrivers: driverOutcome.merged,
      ambiguousDrivers: driverOutcome.ambiguous,
      loginSyncWarnings: driverOutcome.loginSyncWarnings,
      mergeErrors: driverOutcome.mergeErrors,
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

  /// Optionale Spalte mit der Personalnummer / Employee-ID.
  ///
  /// Bewusst nur eindeutige Aliase — `mitarbeiter id` gehört bereits zur
  /// TID-Erkennung und darf hier nicht zusätzlich greifen. Findet der
  /// Export nichts, matcht der Platzhalter-Abgleich eben nur über den
  /// Namen.
  static int _findEmployeeNumberColumnIndex(List<String> header) {
    return _findHeaderIndex(
      header,
      const [
        'personalnummer',
        'personal-nr',
        'personalnr',
        'employee number',
        'employee no',
        'employee id',
        'mitarbeiternummer',
      ],
      const [
        ['personal', 'nummer'],
        ['employee', 'number'],
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

  /// Schreibt die Fahrer-Stammdaten — und führt dabei Platzhalter-Profile
  /// mit ihrer echten TID zusammen.
  ///
  /// Früher legte diese Methode für jede TID aus der CSV blind
  /// `drivers/{TID}` an. Fahrer, die im Drivers Hub schon als
  /// `PENDING-XXXXXX` existierten (weil Amazon die TID noch nicht
  /// vergeben hatte), bekamen dadurch ein **zweites** Profil, und ihre
  /// Dokumente, Zeitkonten und Nachweise blieben am Platzhalter hängen.
  ///
  /// Jetzt wird die Fahrerliste des DSP **einmal** geladen
  /// ([DriverIdentityIndex]) und je TID im Speicher geprüft, ob ein
  /// Platzhalter-Fahrer dazu passt:
  ///
  ///   • Eindeutiger Treffer → [migrateDriverToTid] zieht den Fahrer samt
  ///     Subcollections auf die echte TID um, statt ein zweites Profil
  ///     anzulegen.
  ///   • Mehrdeutiger Treffer → **kein** Automatismus. Der Fahrer wird
  ///     wie bisher neu angelegt und der Fall im Ergebnis gemeldet.
  ///
  /// Der Umzug läuft bewusst sequenziell und schreibt den Index fort
  /// ([DriverIdentityIndex.applyMigration]), damit zwei TIDs derselben
  /// CSV nicht denselben Platzhalter beanspruchen.
  static Future<_DriversWriteOutcome> _writeDriversUser(
    FirebaseFirestore db,
    String uid,
    Map<String, String> idToName,
    Map<String, String> idToEmployeeNumber,
  ) async {
    final driverCol = db.collection('users').doc(uid).collection('drivers');

    // Eine Query für den ganzen Import statt einer je Zeile.
    final index = await DriverIdentityIndex.load(dspUid: uid, firestore: db);

    var mergedCount = 0;
    final ambiguous = <String>[];
    final loginSyncWarnings = <String>[];
    final mergeErrors = <String>[];

    for (final e in idToName.entries) {
      final tid = e.key;
      final name = e.value;
      final targetExists = index.hasDoc(tid);

      final match = index.match(
        tid: tid,
        driverName: name,
        employeeNumber: idToEmployeeNumber[tid] ?? '',
      );

      if (match.isAmbiguous) {
        // Nur melden, wenn wir sonst zusammengeführt hätten — sonst
        // stünde bei jedem Import dieselbe Namensdublette in der
        // Meldung, obwohl gar nichts anstand.
        if (!targetExists) ambiguous.add('$name ($tid)');
        continue;
      }
      if (!match.isMatch) continue;

      // Liegt unter der echten TID schon ein Dokument, greifen wir nur
      // beim sichersten Treffer ein: `transporterId` zeigt bereits auf
      // diese TID, nur die Doc-ID hinkt hinterher. Genau das ist die
      // Altlast aus „TID zuordnen" ohne Umzug — hier ist das
      // Zusammenführen eindeutig richtig. Namens-/Personalnummer-Treffer
      // gegen ein bestehendes Profil bleiben dem manuellen Werkzeug
      // „Profile zusammenführen" im Drivers Hub überlassen.
      if (targetExists &&
          match.reason != DriverMatchReason.transporterIdField) {
        continue;
      }

      try {
        final result = await migrateDriverToTid(
          dspUid: uid,
          fromDocId: match.docId!,
          toTid: tid,
          firestore: db,
        );
        index.applyMigration(fromDocId: match.docId!, toTid: tid);
        if (!result.skipped) mergedCount++;
        if (result.hasLoginSyncWarning) {
          loginSyncWarnings.add('$name ($tid)');
        }
      } catch (err) {
        // Nicht fatal: der Fahrer wird unten wie bisher angelegt bzw.
        // aktualisiert. Der Admin erfährt es über das Import-Ergebnis.
        mergeErrors.add('$name ($tid): $err');
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
        // `hasDoc` kennt nach den Umzügen oben auch die frisch
        // umgezogenen Fahrer — die gelten deshalb nicht als „neu" und
        // behalten `createdAt`, `hasLogin` und `active`.
        final isNew = !index.hasDoc(e.key);
        if (isNew) createdCount++;
        final payload = <String, dynamic>{
          'transporterId': e.key,
          'driverName': e.value,
          'updatedAt': FieldValue.serverTimestamp(),
          if (isNew) 'createdAt': FieldValue.serverTimestamp(),
          if (isNew) 'hasLogin': false,
          if (isNew) 'active': true,
          // Der Fahrer hat jetzt nachweislich eine echte TID — ein
          // hängengebliebenes Flag würde ihn sonst weiter als
          // „TID ausstehend" anzeigen.
          'tidPending': false,
        };
        batch.set(doc, payload, SetOptions(merge: true));
      }
      await batch.commit();
    }

    return _DriversWriteOutcome(
      created: createdCount,
      merged: mergedCount,
      ambiguous: ambiguous,
      loginSyncWarnings: loginSyncWarnings,
      mergeErrors: mergeErrors,
    );
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
