import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// Kanonisches Schema für `users/{scope}/incident_reports/{id}`.
///
/// Dieses Modul ist die **einzige** Quelle der Wahrheit für Feldnamen,
/// Labels, Plate-Normalisierung, Zähler-Aggregation und das WhatsApp-
/// Kopierformat. Sowohl das Admin-Incident-Center als auch der
/// Alt-Datenimport (274 WhatsApp-Fälle, Doc-ID `ACC-XXXXXX`) schreiben
/// exakt diese Felder.
///
/// Felder (vollständig):
///   category            'vehicle' | 'work_accident'
///   incidentType        (vehicle) 'accident' | 'recovery' | 'wear_defect'
///                       | 'third_party_damage' | 'withdrawn' | 'unclear'
///   occurredAt          Timestamp
///   timeText            'HH:MM' oder ''
///   driverTransporterId UPPERCASE, '' wenn unbekannt
///   driverName, driverNameRaw
///   plate, plateRaw, plateKey
///   address, description, damage
///   responsibility      'at_fault'|'not_at_fault'|'partial'|'unclear'|'unknown'
///   grounding           'yes'|'no'|'possible'|'unknown', groundingReason
///   thirdParty          {name, plate, phone, email, insurance}
///   notes, source, confidence, reviewFlag, reportedAt, reportedBy
///   photos              [{url, path, uploadedBy, uploadedAt}]  (additiv)
///   photoCount          int — gespiegelte Länge von `photos`
///   (work_accident) injuryType, bodyPart, activityAtTime, firstAid,
///                   firstAidBy, doctorVisited, witnesses, expectedDaysOff,
///                   bgReportRequired
///   createdAt, createdBy
///
/// Bestandsdokumente der Fahrer-App tragen **kein** `category`-Feld — sie
/// gelten beim Lesen als `vehicle` (siehe [incidentCategoryOf]).
/// ─────────────────────────────────────────────────────────────────────────

// ── Enum-artige Konstanten ───────────────────────────────────────────────

const String kIncidentVehicle = 'vehicle';
const String kIncidentWorkAccident = 'work_accident';

/// Vorfallarten für `category == 'vehicle'` (Reihenfolge = UI-Reihenfolge).
const List<String> kVehicleIncidentTypes = <String>[
  'accident',
  'recovery',
  'wear_defect',
  'third_party_damage',
  'withdrawn',
  'unclear',
];

const List<String> kResponsibilityValues = <String>[
  'at_fault',
  'not_at_fault',
  'partial',
  'unclear',
  'unknown',
];

const List<String> kGroundingValues = <String>[
  'yes',
  'no',
  'possible',
  'unknown',
];

/// Herkunft eines Datensatzes. `codriver` = im Admin-Center erfasst,
/// `driver_app` = aus der Fahrer-Meldung, der Rest kommt aus dem Import.
const String kIncidentSourceCoDriver = 'codriver';
const String kIncidentSourceDriverApp = 'driver_app';

// ── Labels (DE/EN) ───────────────────────────────────────────────────────

String incidentTypeLabel(String value, {required bool de}) {
  switch (value) {
    case 'accident':
      return de ? 'Unfall' : 'Accident';
    case 'recovery':
      return de ? 'Bergung/Festgefahren' : 'Recovery / stuck';
    case 'wear_defect':
      return de ? 'Verschleiß/Defekt' : 'Wear / defect';
    case 'third_party_damage':
      return de ? 'Fremdschaden (Dritte)' : 'Third-party damage';
    case 'withdrawn':
      return de ? 'Zurückgezogen' : 'Withdrawn';
    case 'unclear':
    default:
      return de ? 'Unklar' : 'Unclear';
  }
}

String responsibilityLabel(String value, {required bool de}) {
  switch (value) {
    case 'at_fault':
      return de ? 'Eigenverschulden' : 'At fault';
    case 'not_at_fault':
      return de ? 'Fremdverschulden' : 'Not at fault';
    case 'partial':
      return de ? 'Teilschuld' : 'Partially at fault';
    case 'unclear':
      return de ? 'Unklar' : 'Unclear';
    case 'unknown':
    default:
      return de ? 'Keine Angabe' : 'Not specified';
  }
}

String groundingLabel(String value, {required bool de}) {
  switch (value) {
    case 'yes':
      return de ? 'Ja' : 'Yes';
    case 'no':
      return de ? 'Nein' : 'No';
    case 'possible':
      return de ? 'Möglich' : 'Possible';
    case 'unknown':
    default:
      return de ? 'Unklar' : 'Unknown';
  }
}

// ── Normalisierung ───────────────────────────────────────────────────────

/// Normalisiert ein Kennzeichen zu einem stabilen Match-Key:
/// Uppercase, Umlaute ausgeschrieben (Ü→UE, Ö→OE, Ä→AE), danach nur
/// noch `A-Z0-9`. `FÜ-DE 314` → `FUEDE314`.
///
/// Wird sowohl beim Schreiben (`plateKey`) als auch beim Zählen im
/// Fleet Hub benutzt — beide Seiten müssen dieselbe Funktion nehmen.
String plateKeyOf(String raw) {
  final upper = raw
      .toUpperCase()
      .replaceAll('Ü', 'UE')
      .replaceAll('Ö', 'OE')
      .replaceAll('Ä', 'AE');
  return upper.replaceAll(RegExp('[^A-Z0-9]'), '');
}

/// Normalisiert eine Transporter-ID (Doc-ID in `users/{scope}/drivers`).
String transporterIdOf(String raw) => raw.trim().toUpperCase();

// ── Lesen (mit Bestandsdaten-Fallbacks) ──────────────────────────────────

String _s(dynamic value) => value?.toString().trim() ?? '';

String _firstNonEmpty(List<String> values) {
  for (final v in values) {
    final t = v.trim();
    if (t.isNotEmpty) return t;
  }
  return '';
}

Map<String, dynamic> incidentMapOf(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.cast<String, dynamic>();
  return const <String, dynamic>{};
}

/// Kategorie eines Dokuments. Bestandsdokumente ohne `category` gelten
/// als `vehicle`; die Fahrer-App schrieb früher `type: 'work_accident'`.
String incidentCategoryOf(Map<String, dynamic> data) {
  final category = _s(data['category']);
  if (category == kIncidentWorkAccident) return kIncidentWorkAccident;
  if (category == kIncidentVehicle) return kIncidentVehicle;
  if (_s(data['type']) == kIncidentWorkAccident) return kIncidentWorkAccident;
  return kIncidentVehicle;
}

bool isWorkAccident(Map<String, dynamic> data) =>
    incidentCategoryOf(data) == kIncidentWorkAccident;

/// Zeitpunkt des Vorfalls — `occurredAt` zuerst, danach die Feldnamen
/// der Fahrer-App bzw. des Imports.
DateTime? incidentOccurredAt(Map<String, dynamic> data) {
  for (final key in const <String>[
    'occurredAt',
    'accidentAt',
    'reportedAt',
    'submittedAt',
    'createdAt',
  ]) {
    final v = data[key];
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
  }
  return null;
}

String incidentDriverName(Map<String, dynamic> data) => _firstNonEmpty([
      _s(data['driverName']),
      _s(data['driverNameRaw']),
      _s(data['driverTransporterId']),
    ]);

String incidentDriverTid(Map<String, dynamic> data) =>
    transporterIdOf(_s(data['driverTransporterId']));

String incidentPlate(Map<String, dynamic> data) => _firstNonEmpty([
      _s(data['plate']),
      _s(data['plateRaw']),
      _s(data['plateKey']),
      _s(data['vehiclePlate']),
    ]);

/// Untermap `workAccident` der Fahrer-App-Unfallanzeige. Die Felder tragen
/// dort die Namen des amtlichen deutschen Formulars — alle Lese-Helfer
/// unten mappen sie auf die kanonischen Feldnamen.
Map<String, dynamic> _wa(Map<String, dynamic> data) =>
    incidentMapOf(data['workAccident']);

String incidentAddress(Map<String, dynamic> data) => _firstNonEmpty([
      _s(data['address']),
      _s(data['location']),
      _s(_wa(data)['unfallort']),
      _s(_wa(data)['naehereOrt']),
    ]);

String incidentDescription(Map<String, dynamic> data) => _firstNonEmpty([
      _s(data['description']),
      _s(_wa(data)['unfallhergang']),
      _s(_wa(data)['schilderung']),
    ]);

String incidentInjuryType(Map<String, dynamic> data) => _firstNonEmpty([
      _s(data['injuryType']),
      _s(_wa(data)['artVerletzung']),
    ]);

String incidentBodyPart(Map<String, dynamic> data) => _firstNonEmpty([
      _s(data['bodyPart']),
      _s(_wa(data)['verletzteKoerperteile']),
    ]);

String incidentActivityAtTime(Map<String, dynamic> data) => _firstNonEmpty([
      _s(data['activityAtTime']),
      _s(_wa(data)['taetigkeit']),
    ]);

String incidentWitnesses(Map<String, dynamic> data) {
  final direct = _s(data['witnesses']);
  if (direct.isNotEmpty) return direct;
  final wa = _wa(data);
  return <String>[_s(wa['zeuge']), _s(wa['augenzeuge'])]
      .where((e) => e.isNotEmpty)
      .join(' · ');
}

/// Behandelnder Arzt bzw. Erstbehandlung aus der Unfallanzeige. Der
/// kanonische Bool `doctorVisited` sagt nur *ob*, die Fahrer-App liefert
/// zusätzlich Klartext — beides wird angezeigt.
String incidentDoctorText(Map<String, dynamic> data) {
  final wa = _wa(data);
  return _firstNonEmpty([
    _s(data['firstAidBy']),
    _s(wa['behandelnderArzt']),
    _s(wa['erstbehandlung']),
  ]);
}

/// Freitext-Unfallzeitpunkt der Fahrer-App (kein Timestamp), nur als
/// Ergänzung zum normalisierten [incidentOccurredAt].
String incidentOccurredAtText(Map<String, dynamic> data) =>
    _s(_wa(data)['unfallzeitpunkt']);

/// Schadenart der Fahrer-App-Meldung (`vehicle` | `property` | `both`).
String incidentDamageTypeLabel(Map<String, dynamic> data, {required bool de}) {
  switch (_s(data['damageType'])) {
    case 'vehicle':
      return de ? 'Fahrzeugschaden' : 'Vehicle damage';
    case 'property':
      return de ? 'Sachschaden' : 'Property damage';
    case 'both':
      return de ? 'Fahrzeug- und Sachschaden' : 'Vehicle and property damage';
    default:
      return '';
  }
}

/// Polizei beteiligt — nur wenn das Feld überhaupt gesetzt ist, sonst ''.
String incidentPoliceLabel(Map<String, dynamic> data, {required bool de}) {
  final raw = data['policeInvolved'];
  if (raw is! bool) return '';
  return raw ? (de ? 'Ja' : 'Yes') : (de ? 'Nein' : 'No');
}

/// Vorfallart mit Fallback: alte Fahrer-App-Meldungen sind immer `accident`.
String incidentTypeOf(Map<String, dynamic> data) {
  final raw = _s(data['incidentType']);
  if (kVehicleIncidentTypes.contains(raw)) return raw;
  return 'accident';
}

String incidentResponsibilityOf(Map<String, dynamic> data) {
  final raw = _s(data['responsibility']);
  if (kResponsibilityValues.contains(raw)) return raw;
  // Fahrer-App: faultOpinion self|other|both|unclear
  switch (_s(data['faultOpinion'])) {
    case 'self':
      return 'at_fault';
    case 'other':
      return 'not_at_fault';
    case 'both':
      return 'partial';
    case 'unclear':
      return 'unclear';
  }
  return 'unknown';
}

String incidentGroundingOf(Map<String, dynamic> data) {
  final raw = _s(data['grounding']);
  if (kGroundingValues.contains(raw)) return raw;
  return 'unknown';
}

// ── Fotos ────────────────────────────────────────────────────────────────

/// Firestore-Feld mit der kanonischen Fotoliste.
const String kIncidentPhotosField = 'photos';

/// Ein Foto am Vorfall-Dokument.
///
/// `path` ist der Storage-Pfad und wird gebraucht, um die Datei beim
/// Entfernen wirklich zu löschen. Bestandsfotos aus der Fahrer-App
/// (`platePhotoUrl` / `damagePhotoUrls`) kennen nur die URL — dort bleibt
/// `path` leer und die Datei bleibt beim Entfernen im Bucket liegen
/// (verwaist, aber ohne Referenz im Dokument).
class IncidentPhoto {
  const IncidentPhoto({
    required this.url,
    this.path = '',
    this.uploadedBy = '',
    this.uploadedAt,
  });

  final String url;
  final String path;

  /// Auth-UID des Hochladenden (Admin oder Fahrer).
  final String uploadedBy;
  final DateTime? uploadedAt;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'url': url,
        'path': path,
        'uploadedBy': uploadedBy,
        'uploadedAt':
            uploadedAt == null ? null : Timestamp.fromDate(uploadedAt!),
      };

  static IncidentPhoto? fromMap(Object? raw) {
    if (raw is String) {
      final url = raw.trim();
      return url.isEmpty ? null : IncidentPhoto(url: url);
    }
    if (raw is! Map) return null;
    final url = _s(raw['url']);
    if (url.isEmpty) return null;
    final at = raw['uploadedAt'];
    return IncidentPhoto(
      url: url,
      path: _s(raw['path']),
      uploadedBy: _s(raw['uploadedBy']),
      uploadedAt: at is Timestamp
          ? at.toDate()
          : at is DateTime
              ? at
              : null,
    );
  }
}

/// Alle Fotos eines Vorfalls.
///
/// Kanonisch ist das Array [kIncidentPhotosField]. Nur wenn es fehlt oder
/// leer ist, greifen die Altfelder der Fahrer-App (`platePhotoUrl`,
/// `damagePhotoUrls`) — sonst würde eine seit dem Foto-Update gespeicherte
/// Meldung, die beides schreibt, jedes Bild doppelt zeigen.
List<IncidentPhoto> incidentPhotosOf(Map<String, dynamic> data) {
  final raw = data[kIncidentPhotosField];
  if (raw is List) {
    final out = <IncidentPhoto>[];
    for (final entry in raw) {
      final photo = IncidentPhoto.fromMap(entry);
      if (photo != null) out.add(photo);
    }
    if (out.isNotEmpty) return out;
  }

  final legacy = <IncidentPhoto>[];
  final plate = _s(data['platePhotoUrl']);
  if (plate.isNotEmpty) legacy.add(IncidentPhoto(url: plate));
  final damage = data['damagePhotoUrls'];
  if (damage is List) {
    for (final entry in damage) {
      final url = _s(entry);
      if (url.isNotEmpty) legacy.add(IncidentPhoto(url: url));
    }
  }
  return legacy;
}

/// Anzahl der Fotos — für das Kachel-Badge und den Kopier-Bericht.
int incidentPhotoCount(Map<String, dynamic> data) =>
    incidentPhotosOf(data).length;

// ── Client-seitige Gruppierung (Statistik-Panel) ─────────────────────────

/// Gruppenschlüssel eines Vorfalls für die Fahrer-Statistik.
///
/// Bevorzugt die Transporter-ID; Importfälle ohne TID werden über den
/// normalisierten Fahrernamen zusammengefasst, damit sie nicht als
/// namenlose Einzelzeilen zerfallen.
String incidentDriverGroupKey(Map<String, dynamic> data) {
  final tid = incidentDriverTid(data);
  if (tid.isNotEmpty) return tid;
  return incidentDriverName(data).trim().toUpperCase();
}

/// Gruppenschlüssel eines Vorfalls für die Fahrzeug-Statistik.
String incidentPlateGroupKey(Map<String, dynamic> data) {
  final key = _s(data['plateKey']);
  if (key.isNotEmpty) return key;
  return plateKeyOf(incidentPlate(data));
}

/// Eine Zeile der Statistik: Schlüssel, Anzeigename, Anzahl.
class IncidentGroup {
  const IncidentGroup({
    required this.key,
    required this.label,
    required this.count,
  });

  final String key;
  final String label;
  final int count;
}

List<IncidentGroup> _groupBy(
  Iterable<Map<String, dynamic>> docs,
  String Function(Map<String, dynamic>) keyOf,
  String Function(Map<String, dynamic>) labelOf,
) {
  final counts = <String, int>{};
  final labels = <String, String>{};
  for (final data in docs) {
    final key = keyOf(data);
    if (key.isEmpty) continue;
    counts[key] = (counts[key] ?? 0) + 1;
    final label = labelOf(data).trim();
    if (label.isNotEmpty) labels.putIfAbsent(key, () => label);
  }
  final out = <IncidentGroup>[
    for (final entry in counts.entries)
      IncidentGroup(
        key: entry.key,
        label: labels[entry.key] ?? entry.key,
        count: entry.value,
      ),
  ];
  // Häufigste zuerst; bei Gleichstand alphabetisch, damit die Reihenfolge
  // zwischen zwei Renders nicht springt.
  out.sort((a, b) {
    final byCount = b.count.compareTo(a.count);
    if (byCount != 0) return byCount;
    return a.label.toLowerCase().compareTo(b.label.toLowerCase());
  });
  return out;
}

/// Vorfälle je Fahrer, absteigend nach Anzahl. Arbeitet auf bereits
/// geladenen Dokumenten — kein zusätzlicher Firestore-Roundtrip.
List<IncidentGroup> groupIncidentsByDriver(
  Iterable<Map<String, dynamic>> docs,
) =>
    _groupBy(docs, incidentDriverGroupKey, incidentDriverName);

/// Vorfälle je Fahrzeug (`plateKey`), absteigend nach Anzahl.
List<IncidentGroup> groupIncidentsByPlate(
  Iterable<Map<String, dynamic>> docs,
) =>
    _groupBy(docs, incidentPlateGroupKey, incidentPlate);

// ── Firestore ────────────────────────────────────────────────────────────

CollectionReference<Map<String, dynamic>> incidentReportsCol(String dspUid) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(dspUid)
      .collection('incident_reports');
}

/// Ein Dokument gilt als Arbeitsunfall, wenn **eines** der beiden Felder
/// `work_accident` sagt: `category` (Admin-Center und Import) oder das
/// Altfeld `type` (Fahrer-App).
///
/// Als **eine** `Filter.or`-Bedingung formuliert und nicht als zwei
/// getrennte Zählungen: ein Dokument, das beide Felder trägt — etwa ein im
/// Admin-Center nachbearbeiteter Alt-Arbeitsunfall — würde sonst zweimal
/// abgezogen und den Fahrzeug-Zähler zu niedrig ausweisen.
final Filter _workAccidentFilter = Filter.or(
  Filter('category', isEqualTo: kIncidentWorkAccident),
  Filter('type', isEqualTo: kIncidentWorkAccident),
);

/// Zählt Fahrzeug-Vorfälle über Gegenrechnung: `alle − arbeitsunfälle`.
///
/// Firestore kann „Feld fehlt" nicht abfragen, Bestandsdokumente der
/// Fahrer-App tragen aber kein `category` — ein direktes
/// `where('category','==','vehicle')` würde sie unterschlagen.
///
/// Beides sind reine count()-Aggregationen; es werden keine Dokumente
/// übertragen.
Future<int> _countVehicleIncidents({
  required String dspUid,
  required Filter match,
}) async {
  final col = incidentReportsCol(dspUid);
  final results = await Future.wait(<Future<AggregateQuerySnapshot>>[
    col.where(match).count().get(),
    col.where(Filter.and(match, _workAccidentFilter)).count().get(),
  ]);
  final value = (results[0].count ?? 0) - (results[1].count ?? 0);
  return value < 0 ? 0 : value;
}

/// Anzahl der **Fahrzeug**-Vorfälle eines Fahrers (Match über
/// `driverTransporterId`).
Future<int> countVehicleIncidentsForDriver({
  required String dspUid,
  required String transporterId,
}) async {
  final tid = transporterIdOf(transporterId);
  if (dspUid.trim().isEmpty || tid.isEmpty) return 0;
  return _countVehicleIncidents(
    dspUid: dspUid,
    match: Filter('driverTransporterId', isEqualTo: tid),
  );
}

/// Anzahl der **Fahrzeug**-Vorfälle eines Fahrzeugs (Match über `plateKey`).
Future<int> countVehicleIncidentsForPlate({
  required String dspUid,
  required String plate,
}) async {
  final key = plateKeyOf(plate);
  if (dspUid.trim().isEmpty || key.isEmpty) return 0;
  return _countVehicleIncidents(
    dspUid: dspUid,
    match: Filter('plateKey', isEqualTo: key),
  );
}

// ── WhatsApp-Kopie ───────────────────────────────────────────────────────

final DateFormat _kDateFmt = DateFormat('dd.MM.yyyy');
final DateFormat _kTimeFmt = DateFormat('HH:mm');

/// Baut den kompletten Bericht als formatierten Text für die
/// WhatsApp-Gruppe. Bewusst **immer deutsch**: das Zielformat ist das
/// etablierte Gruppenformat, nicht die UI-Sprache des Admins.
/// Leere Felder werden weggelassen.
String buildIncidentClipboardText(Map<String, dynamic> data) {
  final workAccident = isWorkAccident(data);
  final lines = <String>[];

  void add(String label, String value) {
    final v = value.trim();
    if (v.isEmpty) return;
    lines.add('$label: $v');
  }

  lines.add(workAccident ? '🩹 Arbeitsunfall' : '🚨 Unfallmeldung');

  // Datum · Uhrzeit
  final occurredAt = incidentOccurredAt(data);
  if (occurredAt != null) {
    final timeText = _s(data['timeText']);
    final time = timeText.isNotEmpty
        ? timeText
        : (occurredAt.hour == 0 && occurredAt.minute == 0
            ? ''
            : _kTimeFmt.format(occurredAt));
    add(
      'Datum',
      time.isEmpty
          ? _kDateFmt.format(occurredAt)
          : '${_kDateFmt.format(occurredAt)} · $time',
    );
  } else {
    // Fahrer-App-Unfallanzeige ohne Timestamp: Freitext-Zeitpunkt.
    add('Datum', incidentOccurredAtText(data));
  }

  if (!workAccident) {
    add('Typ', incidentTypeLabel(incidentTypeOf(data), de: true));
  }

  // Fahrer + Fahrzeug
  final driverName = incidentDriverName(data);
  final tid = incidentDriverTid(data);
  if (driverName.isNotEmpty) {
    add(
      'Fahrer',
      tid.isEmpty || tid == driverName ? driverName : '$driverName ($tid)',
    );
  } else {
    add('Fahrer', tid);
  }
  add('Fahrzeug', incidentPlate(data));

  add('Ort', incidentAddress(data));
  add('Hergang', incidentDescription(data));
  add('Schaden', _s(data['damage']));

  if (workAccident) {
    add('Verletzung', incidentInjuryType(data));
    add('Körperteil', incidentBodyPart(data));
    add('Tätigkeit', incidentActivityAtTime(data));
    if (data['firstAid'] == true) {
      final by = _s(data['firstAidBy']);
      add('Erste Hilfe', by.isEmpty ? 'Ja' : 'Ja (durch $by)');
    }
    if (data['doctorVisited'] == true) add('Durchgangsarzt', 'Ja');
    // Klartext aus der Fahrer-App-Unfallanzeige (behandelnder Arzt /
    // Erstbehandlung) — ergänzt den reinen Ja/Nein-Bool oben.
    if (data['firstAid'] != true) add('Behandlung', incidentDoctorText(data));
    add('Zeugen', incidentWitnesses(data));
    final daysOff = data['expectedDaysOff'];
    if (daysOff is num && daysOff > 0) {
      add('Voraussichtlicher Ausfall', '${daysOff.toInt()} Tage');
    }
    if (data['bgReportRequired'] == true) add('BG-Meldung', 'erforderlich');
  } else {
    add('Schadenart', incidentDamageTypeLabel(data, de: true));
    add('Polizei beteiligt', incidentPoliceLabel(data, de: true));
    final responsibility = incidentResponsibilityOf(data);
    if (responsibility != 'unknown') {
      add('Schuldfrage', responsibilityLabel(responsibility, de: true));
    }
    final grounding = incidentGroundingOf(data);
    if (grounding != 'unknown') {
      final reason = _s(data['groundingReason']);
      add(
        'Grounding',
        reason.isEmpty
            ? groundingLabel(grounding, de: true)
            : '${groundingLabel(grounding, de: true)} ($reason)',
      );
    }
    final thirdParty = incidentMapOf(data['thirdParty']);
    final parts = <String>[
      _s(thirdParty['name']),
      _s(thirdParty['plate']),
      if (_s(thirdParty['phone']).isNotEmpty) 'Tel ${_s(thirdParty['phone'])}',
      _s(thirdParty['email']),
      _s(thirdParty['insurance']),
    ].where((e) => e.isNotEmpty).toList();
    if (parts.isNotEmpty) add('Gegenpartei', parts.join(' · '));
  }

  add('Notizen', _s(data['notes']));

  // Bewusst nur die Anzahl, keine URLs: die Download-Links tragen einen
  // Storage-Token und wären in einer WhatsApp-Gruppe ein dauerhaft
  // öffentlicher Zugang zu Fahrer- und Fahrzeugfotos.
  final photoCount = incidentPhotoCount(data);
  if (photoCount > 0) {
    add('Fotos', '$photoCount ${photoCount == 1 ? 'Foto' : 'Fotos'} in CoDriver');
  }

  add('Gemeldet von', _firstNonEmpty([_s(data['reportedBy']), _s(data['createdBy'])]));

  return lines.join('\n');
}
