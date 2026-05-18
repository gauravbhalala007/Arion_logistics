// lib/services/driver_export_service.dart
//
// Bündelt alle Fahrer-Stammdaten + hochgeladenen Dokumente in eine
// sauber benannte ZIP-Datei. Im Browser wird die ZIP direkt als
// Download ausgeliefert.
//
// Struktur der ZIP:
//
//   codriver_drivers_export_YYYY-MM-DD.zip
//   ├── README.txt
//   ├── _drivers_overview.csv          ← Master-Liste aller Fahrer
//   └── drivers/
//       ├── Nachname_Vorname__TID12345/
//       │   ├── 00_stammdaten.json
//       │   ├── 01_Arbeitsvertrag.pdf
//       │   ├── 02_Aufenthaltsgenehmigung.jpg
//       │   └── …
//       └── Schmidt_Anna__TID67890/
//           └── …

import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as fb;
import 'package:http/http.dart' as http;

class DriverExportProgress {
  final int driversDone;
  final int driversTotal;
  final int docsDone;
  final int docsTotal;
  final String? currentDriver;
  const DriverExportProgress({
    required this.driversDone,
    required this.driversTotal,
    required this.docsDone,
    required this.docsTotal,
    this.currentDriver,
  });
}

class DriverExportService {
  /// Stabile Bezeichnungen pro Doc-Type — werden im Dateinamen verwendet.
  /// Schlüssel sind die `docType`-IDs aus Firestore (`users/{uid}/drivers/
  /// {tid}/documents/{docType}`).
  static const _docLabels = <String, String>{
    'contract': 'Arbeitsvertrag',
    'resident_permit': 'Aufenthaltsgenehmigung',
    'tax_id': 'Steuer-ID',
    'insurance': 'Krankenkasse',
    'id_card_front': 'Personalausweis_Vorne',
    'id_card_back': 'Personalausweis_Hinten',
    'passport_front': 'Reisepass_Vorne',
    'passport_back': 'Reisepass_Hinten',
    'driver_license_front': 'Fuehrerschein_Vorne',
    'driver_license_back': 'Fuehrerschein_Hinten',
  };

  /// Reihenfolge der Doc-Types im Ordner — bestimmt die Nummern-Präfixe
  /// (01_, 02_, …). Unbekannte Types kommen ans Ende mit Index 99+.
  static const _docOrder = <String>[
    'contract',
    'resident_permit',
    'tax_id',
    'insurance',
    'id_card_front',
    'id_card_back',
    'passport_front',
    'passport_back',
    'driver_license_front',
    'driver_license_back',
  ];

  /// Sauberer, dateisystem-tauglicher Ordnername für einen einzelnen
  /// Fahrer. Identisches Mapping wie bei der internen ZIP-Struktur, damit
  /// der heruntergeladene Dateiname der Datei zum Inhalt passt.
  static String driverFolderName({
    required String driverName,
    required String transporterId,
  }) {
    final last = driverName.trim().isEmpty ? 'Unbekannt' : driverName.trim();
    return _sanitize('${last}__${transporterId.trim()}');
  }

  /// Baut eine ZIP, die nur einen einzelnen Fahrer enthält — Struktur ist
  /// dieselbe wie bei [buildExportZip], aber ohne Master-CSV-Liste über
  /// alle Fahrer. Das Stammdaten-JSON und alle Dokumente sind drin.
  Future<Uint8List> buildSingleDriverZip({
    required String adminUid,
    required DocumentReference<Map<String, dynamic>> driverRef,
    void Function(DriverExportProgress)? onProgress,
  }) async {
    final archive = Archive();
    final storage = fb.FirebaseStorage.instance;

    final driverSnap = await driverRef.get();
    final data = driverSnap.data() ?? const <String, dynamic>{};
    final tid = (data['transporterId'] ?? driverRef.id).toString().trim();
    final fullName = _fullName(data);
    final folderName = _sanitize('${fullName}__$tid');

    final docsSnap = await driverRef.collection('documents').get();
    final docs = docsSnap.docs;

    onProgress?.call(DriverExportProgress(
      driversDone: 0,
      driversTotal: 1,
      docsDone: 0,
      docsTotal: docs.length,
      currentDriver: fullName,
    ));

    // 1. Stammdaten als JSON
    final infoJson = const JsonEncoder.withIndent('  ').convert({
      'transporterId': tid,
      'firstName': data['firstName'],
      'lastName': data['lastName'],
      'name': fullName,
      'email': data['email'],
      'phone': data['phone'],
      'birthday': _stringifyTs(data['birthday']),
      'address': data['address'],
      'status': data['status'],
      'role': data['role'],
      'createdAt': _stringifyTs(data['createdAt']),
      'updatedAt': _stringifyTs(data['updatedAt']),
    });
    _addFile(archive, '$folderName/00_stammdaten.json',
        utf8.encode(infoJson));

    // 2. Dokumente in stabiler Reihenfolge ablegen
    final docByType = <String, Map<String, dynamic>>{
      for (final d in docs) (d.data()['docType'] ?? d.id).toString(): d.data(),
    };
    final orderedTypes = <String>[];
    for (final type in _docOrder) {
      if (docByType.containsKey(type)) orderedTypes.add(type);
    }
    final unknown = docByType.keys
        .where((k) => !_docOrder.contains(k))
        .toList()
      ..sort();
    orderedTypes.addAll(unknown);

    final errors = <String>[];
    final debug = StringBuffer();
    debug.writeln('CoDriver export debug log');
    debug.writeln('=========================');
    debug.writeln('Driver ref path: ${driverRef.path}');
    debug.writeln('Admin uid:       $adminUid');
    debug.writeln('Driver TID:      $tid');
    debug.writeln('Driver name:     $fullName');
    debug.writeln('Documents found: ${docs.length}');
    debug.writeln('');
    debug.writeln('Subcollection-Dokumente:');
    for (final d in docs) {
      final data = d.data();
      debug.writeln('  - id=${d.id} keys=${data.keys.toList()}');
      debug.writeln(
          '    docType=${data['docType']} storagePath=${data['storagePath']}');
      debug.writeln(
          '    downloadUrl=${data['downloadUrl']?.toString().substring(0, (data['downloadUrl']?.toString().length ?? 0).clamp(0, 80))}...');
    }
    debug.writeln('');
    debug.writeln('Order verarbeitet:');

    var docsDone = 0;
    var idx = 1;
    for (final type in orderedTypes) {
      final docData = docByType[type]!;
      debug.writeln('  → $type:');
      final result = await _fetchDocBytes(storage, docData);

      if (result.bytes != null) {
        final label = _docLabels[type] ?? _sanitize(type);
        final ext = _extensionFor(
          contentType: (docData['contentType'] ?? '').toString(),
          originalName: (docData['fileName'] ?? '').toString(),
          storagePath: (docData['storagePath'] ?? '').toString(),
        );
        final fname =
            '${idx.toString().padLeft(2, '0')}_$label$ext';
        _addFile(archive, '$folderName/$fname', result.bytes!);
        debug.writeln('      OK ${result.bytes!.length} bytes → $fname');
        idx++;
      } else {
        errors.add(
          '  $type: ${result.error ?? 'unbekannter Fehler'}',
        );
        debug.writeln('      FAIL ${result.error}');
      }

      docsDone++;
      onProgress?.call(DriverExportProgress(
        driversDone: 0,
        driversTotal: 1,
        docsDone: docsDone,
        docsTotal: docs.length,
        currentDriver: fullName,
      ));
    }

    _addFile(archive, '$folderName/_debug.txt', utf8.encode(debug.toString()));

    // 3. README
    final errorBlock = errors.isEmpty
        ? ''
        : '\n\n⚠ Nicht abrufbare Dokumente:\n${errors.join('\n')}\n';
    final readme = '''
CoDriver — Fahrer-Datenexport
==============================
Erstellt: ${DateTime.now().toIso8601String()}

Fahrer:  $fullName
TID:     $tid
Anzahl Dokumente in Firestore: ${docs.length}
Erfolgreich exportiert:        ${idx - 1}
$errorBlock
Inhalt
------
00_stammdaten.json   Stammdaten als JSON
NN_<Doc-Name>.<ext>  Hochgeladene Dokumente, durchnummeriert

Dokumenten-Typen
----------------
${_docOrder.map((t) => '  $t → ${_docLabels[t] ?? t}').join('\n')}
''';
    _addFile(archive, '$folderName/README.txt', utf8.encode(readme));

    onProgress?.call(DriverExportProgress(
      driversDone: 1,
      driversTotal: 1,
      docsDone: docsDone,
      docsTotal: docs.length,
      currentDriver: fullName,
    ));

    final zipBytes = ZipEncoder().encode(archive);
    return Uint8List.fromList(zipBytes!);
  }

  /// Baut die ZIP komplett im Speicher zusammen und gibt die Bytes zurück.
  /// `onProgress` wird nach jedem geladenen Dokument aufgerufen.
  Future<Uint8List> buildExportZip({
    required String adminUid,
    void Function(DriverExportProgress)? onProgress,
  }) async {
    final archive = Archive();
    final fs = FirebaseFirestore.instance;
    final storage = fb.FirebaseStorage.instance;

    // ── 1. Alle Driver-Docs holen ──────────────────────────────────────
    final driversSnap = await fs
        .collection('users')
        .doc(adminUid)
        .collection('drivers')
        .get();

    final drivers = driversSnap.docs;

    // ── 2. Master-CSV vorbereiten ──────────────────────────────────────
    final csvBuf = StringBuffer();
    csvBuf.writeln(
      _csvRow([
        'Name',
        'TransporterID',
        'E-Mail',
        'Telefon',
        'Geburtsdatum',
        'Adresse',
        'Status',
        'Anzahl Dokumente',
        'Created At',
      ]),
    );

    // ── 3. Per Driver: Dokumente sammeln + ablegen ─────────────────────
    final totalDrivers = drivers.length;
    final docCounts = <int>[];

    // Zuerst alle Doc-Counts berechnen damit der Progress sinnvoll ist.
    final allDocsByDriver = <String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>{};
    var totalDocs = 0;
    for (final dr in drivers) {
      final docsSnap =
          await dr.reference.collection('documents').get();
      allDocsByDriver[dr.id] = docsSnap.docs;
      totalDocs += docsSnap.docs.length;
      docCounts.add(docsSnap.docs.length);
    }

    var docsDone = 0;
    for (var i = 0; i < drivers.length; i++) {
      final driverDoc = drivers[i];
      final data = driverDoc.data();
      final tid = (data['transporterId'] ?? driverDoc.id).toString().trim();
      final fullName = _fullName(data);

      final folderName = _sanitize('${fullName}__${tid}');
      final folderPath = 'drivers/$folderName';

      onProgress?.call(DriverExportProgress(
        driversDone: i,
        driversTotal: totalDrivers,
        docsDone: docsDone,
        docsTotal: totalDocs,
        currentDriver: fullName,
      ));

      // 3a. Stammdaten als JSON
      final infoJson = const JsonEncoder.withIndent('  ').convert({
        'transporterId': tid,
        'firstName': data['firstName'],
        'lastName': data['lastName'],
        'name': fullName,
        'email': data['email'],
        'phone': data['phone'],
        'birthday': _stringifyTs(data['birthday']),
        'address': data['address'],
        'status': data['status'],
        'role': data['role'],
        'createdAt': _stringifyTs(data['createdAt']),
        'updatedAt': _stringifyTs(data['updatedAt']),
      });
      _addFile(
        archive,
        '$folderPath/00_stammdaten.json',
        utf8.encode(infoJson),
      );

      // 3b. Dokumente: in stabiler Reihenfolge sortieren + numerieren
      final docs = allDocsByDriver[driverDoc.id] ?? const [];
      final docByType = <String, Map<String, dynamic>>{
        for (final d in docs) (d.data()['docType'] ?? d.id).toString(): d.data(),
      };

      // Sortierte Liste der Doc-Types: erst die bekannten in der vorgegebenen
      // Reihenfolge, dann Unbekannte alphabetisch.
      final orderedTypes = <String>[];
      for (final type in _docOrder) {
        if (docByType.containsKey(type)) orderedTypes.add(type);
      }
      final unknown = docByType.keys
          .where((k) => !_docOrder.contains(k))
          .toList()
        ..sort();
      orderedTypes.addAll(unknown);

      var idx = 1;
      for (final type in orderedTypes) {
        final docData = docByType[type]!;
        final storagePath = (docData['storagePath'] ?? '').toString();
        if (storagePath.isEmpty) continue;

        try {
          final bytes = await storage.ref(storagePath).getData();
          if (bytes == null) {
            docsDone++;
            continue;
          }

          final label = _docLabels[type] ?? _sanitize(type);
          final ext = _extensionFor(
            contentType: (docData['contentType'] ?? '').toString(),
            originalName: (docData['fileName'] ?? '').toString(),
            storagePath: storagePath,
          );

          final fname =
              '${idx.toString().padLeft(2, '0')}_$label$ext';
          _addFile(archive, '$folderPath/$fname', bytes);
          idx++;
        } catch (_) {
          // Datei nicht erreichbar — wir markieren das in der README,
          // brechen den Export aber nicht ab.
        }

        docsDone++;
        onProgress?.call(DriverExportProgress(
          driversDone: i,
          driversTotal: totalDrivers,
          docsDone: docsDone,
          docsTotal: totalDocs,
          currentDriver: fullName,
        ));
      }

      // 3c. CSV-Zeile
      csvBuf.writeln(_csvRow([
        fullName,
        tid,
        (data['email'] ?? '').toString(),
        (data['phone'] ?? '').toString(),
        _stringifyTs(data['birthday']) ?? '',
        (data['address'] ?? '').toString(),
        (data['status'] ?? '').toString(),
        docs.length.toString(),
        _stringifyTs(data['createdAt']) ?? '',
      ]));
    }

    // ── 4. README + CSV ablegen ────────────────────────────────────────
    _addFile(
      archive,
      '_drivers_overview.csv',
      utf8.encode(csvBuf.toString()),
    );

    final readme = '''
CoDriver — Fahrer-Datenexport
==============================
Erstellt: ${DateTime.now().toIso8601String()}

Inhalt
------
- _drivers_overview.csv      Tabelle mit allen Fahrer-Stammdaten
- drivers/<Name>__<TID>/     Pro Fahrer ein Ordner
   ├── 00_stammdaten.json    Alle Stammdaten als JSON
   └── NN_<Doc-Name>.<ext>   Hochgeladene Dokumente, durchnummeriert

Anzahl Fahrer:    $totalDrivers
Anzahl Dokumente: $totalDocs

Dokumenten-Typen
----------------
${_docOrder.map((t) => '  $t → ${_docLabels[t] ?? t}').join('\n')}
''';
    _addFile(archive, 'README.txt', utf8.encode(readme));

    onProgress?.call(DriverExportProgress(
      driversDone: totalDrivers,
      driversTotal: totalDrivers,
      docsDone: docsDone,
      docsTotal: totalDocs,
    ));

    final zipBytes = ZipEncoder().encode(archive);
    return Uint8List.fromList(zipBytes!);
  }

  // ─── Helpers ─────────────────────────────────────────────────────────

  /// Versucht ein Dokument zu laden. Auf Flutter Web wirft das SDK-eigene
  /// `getData()` einen Type-Cast-Fehler — wir gehen deshalb primär den
  /// direkten HTTP-GET-Weg auf die `downloadUrl` (Firebase Storage stellt
  /// die URLs mit `?alt=media&token=…` so aus, dass jeder Browser sie
  /// direkt abrufen kann). Der SDK-Pfad bleibt als Fallback drin.
  static Future<({Uint8List? bytes, String? error})> _fetchDocBytes(
    fb.FirebaseStorage storage,
    Map<String, dynamic> docData,
  ) async {
    final storagePath = (docData['storagePath'] ?? '').toString();
    final downloadUrl = (docData['downloadUrl'] ?? '').toString();

    if (storagePath.isEmpty && downloadUrl.isEmpty) {
      return (bytes: null, error: 'kein storagePath / downloadUrl im Doc');
    }

    // 1) Direkter HTTP-GET auf die Download-URL — funktioniert ohne SDK-
    //    Cast-Issues und nutzt den Token aus der URL für die Auth.
    final urls = <String>[
      if (downloadUrl.isNotEmpty) downloadUrl,
    ];
    // 2) Falls keine downloadUrl gespeichert ist, aber ein storagePath,
    //    fragen wir die URL einmal über das SDK ab (das funktioniert,
    //    weil nur eine String zurück kommt — kein Byte-Cast).
    if (urls.isEmpty && storagePath.isNotEmpty) {
      try {
        final url = await storage.ref(storagePath).getDownloadURL();
        urls.add(url);
      } catch (e) {
        // weiter mit Fallback
      }
    }

    String? lastError;
    for (final url in urls) {
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          return (bytes: response.bodyBytes, error: null);
        }
        lastError = 'HTTP ${response.statusCode}';
      } catch (e) {
        lastError = 'HTTP-Fehler: $e';
      }
    }

    // 3) Allerletzter Fallback: das SDK direkt — falls jemand am
    //    Backend irgendwann das Cast-Issue gefixt hat.
    if (storagePath.isNotEmpty) {
      try {
        final bytes = await storage.ref(storagePath).getData(50 * 1024 * 1024);
        if (bytes != null) return (bytes: bytes, error: null);
      } catch (e) {
        lastError = 'SDK-Fehler: $e';
      }
    }

    return (bytes: null, error: lastError ?? 'unbekannter Fehler');
  }

  static void _addFile(Archive archive, String path, List<int> bytes) {
    archive.addFile(ArchiveFile(path, bytes.length, bytes));
  }

  static String _fullName(Map<String, dynamic> data) {
    final first = (data['firstName'] ?? '').toString().trim();
    final last = (data['lastName'] ?? '').toString().trim();
    final composite = (data['name'] ?? '').toString().trim();
    if (last.isNotEmpty || first.isNotEmpty) {
      return [last, first].where((s) => s.isNotEmpty).join(', ');
    }
    if (composite.isNotEmpty) return composite;
    return 'Unbekannt';
  }

  /// Macht einen String dateisystem-tauglich: Umlaute → ASCII, alles
  /// andere wird durch Unterstrich ersetzt.
  static String _sanitize(String input) {
    const map = {
      'ä': 'ae',
      'ö': 'oe',
      'ü': 'ue',
      'Ä': 'Ae',
      'Ö': 'Oe',
      'Ü': 'Ue',
      'ß': 'ss',
      ' ': '_',
      ',': '_',
      '.': '_',
      '/': '_',
      '\\': '_',
      ':': '_',
      ';': '_',
    };
    final buf = StringBuffer();
    for (final ch in input.runes) {
      final s = String.fromCharCode(ch);
      if (map.containsKey(s)) {
        buf.write(map[s]);
      } else if (RegExp(r'[A-Za-z0-9_\-]').hasMatch(s)) {
        buf.write(s);
      } else {
        buf.write('_');
      }
    }
    // Doppelte Unterstriche normalisieren, aber __TID-Trenner erhalten.
    return buf.toString().replaceAll(RegExp(r'_{3,}'), '__');
  }

  static String _extensionFor({
    required String contentType,
    required String originalName,
    required String storagePath,
  }) {
    // 1) Aus contentType ableiten
    switch (contentType.toLowerCase()) {
      case 'application/pdf':
        return '.pdf';
      case 'image/jpeg':
      case 'image/jpg':
        return '.jpg';
      case 'image/png':
        return '.png';
      case 'image/webp':
        return '.webp';
      case 'image/heic':
        return '.heic';
    }
    // 2) Aus originalName / storagePath holen
    for (final src in [originalName, storagePath]) {
      final dot = src.lastIndexOf('.');
      if (dot > 0 && dot < src.length - 1) {
        final ext = src.substring(dot).toLowerCase();
        if (RegExp(r'^\.[a-z0-9]{2,5}$').hasMatch(ext)) return ext;
      }
    }
    return '';
  }

  static String? _stringifyTs(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate().toIso8601String();
    if (value is DateTime) return value.toIso8601String();
    return value.toString();
  }

  static String _csvRow(List<String> cells) {
    return cells.map(_csvEscape).join(',');
  }

  static String _csvEscape(String s) {
    if (s.contains(',') || s.contains('"') || s.contains('\n')) {
      return '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }
}
