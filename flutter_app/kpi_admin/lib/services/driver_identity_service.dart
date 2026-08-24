// lib/services/driver_identity_service.dart
//
// ─── Fahrer-Identität: Platzhalter-TID → echte Transporter-ID ─────────
//
// Fahrer werden im Drivers Hub angelegt, **bevor** Amazon eine
// Transporter-ID (TID) vergibt. Bis dahin bekommt der Fahrer eine
// Platzhalter-ID der Form `PENDING-XXXXXX` (siehe
// `lib/Screens/add_driver_dialog.dart`), die gleichzeitig Doc-ID **und**
// Feld `transporterId` ist. Die echte TID taucht erst später auf — mit
// der ersten Scorecard bzw. dem ersten Driver-CSV.
//
// Genau an dieser Stelle sind bisher Dubletten entstanden:
//
//   1. Der CSV-Import legte für jede TID blind `drivers/{TID}` an, ohne
//      zu prüfen, ob derselbe Fahrer schon als `PENDING-…` existiert.
//   2. Der Dialog „TID zuordnen" setzte zwar `transporterId` und
//      `tidPending: false`, verschob das Dokument aber nicht auf die
//      neue Doc-ID — der nächste Import legte dann trotzdem ein zweites
//      Profil an.
//   3. Der TID-Wechsel im Drivers Hub kopierte nur das Fahrer-Dokument,
//      nicht dessen Subcollections — Dokumente, Zeitkonto und Nachweise
//      gingen verloren, und `tidPending: true` blieb hängen.
//
// Dieser Service ist die eine Stelle, an der beides gelöst wird:
//
//   • [DriverIdentityIndex] / [findPendingMatch] finden zu einer neu
//     auftauchenden TID den passenden Platzhalter-Fahrer — konservativ:
//     bei mehr als einem Kandidaten wird **nie** automatisch
//     zusammengeführt.
//   • [migrateDriverToTid] zieht einen Fahrer vollständig auf die neue
//     Doc-ID um — erst kopieren, dann löschen (Vorbild:
//     `FleetVehicleRepository.changePlateNumber`).
//   • [isDriverTidPending] ist die eine Wahrheit für „TID ausstehend"
//     und ersetzt das früher allein ausschlaggebende (und regelmäßig
//     hängengebliebene) Feld `tidPending`.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../data/academy_catalog.dart' show kAcademyTrainings;
import '../data/privacy_camera/privacy_camera_content.dart'
    show kPrivacyCameraObjectionTestId, kPrivacyCameraTestId;
import '../data/privacy_notice/privacy_notice_content.dart'
    show kPrivacyNoticeTestId;

// ─── Platzhalter-TIDs ────────────────────────────────────────────────

/// Präfix der generierten Platzhalter-IDs (`PENDING-A7B3K9`).
///
/// Wird in `add_driver_dialog.dart` vergeben; hier zentral, damit die
/// Erkennung nicht an einem zweiten Literal hängt.
const String kPendingTidPrefix = 'PENDING-';

/// True, wenn [tid] keine echte Transporter-ID ist: leer oder eine
/// generierte `PENDING-…`-Platzhalter-ID (Groß-/Kleinschreibung egal).
bool isPlaceholderTid(String tid) {
  final value = tid.trim();
  if (value.isEmpty) return true;
  return value.toUpperCase().startsWith(kPendingTidPrefix);
}

/// Die **eine** Wahrheit für „TID ausstehend".
///
/// Maßgeblich ist die wirksame TID des Fahrers: das Feld `transporterId`,
/// ersatzweise (wenn leer) die Doc-ID. Ist sie ein Platzhalter, steht die
/// TID aus — sonst nicht.
///
/// Das Feld `tidPending` wird bewusst **nicht** mehr als alleinige Quelle
/// verwendet: es bleibt bei jedem TID-Wechsel, der es nicht explizit
/// zurücksetzt, auf `true` hängen und ließ Fahrer mit längst echter TID
/// als „ausstehend" erscheinen. Es zählt nur noch als Hinweis für den
/// Fall, dass gar keine TID ermittelbar ist.
bool isDriverTidPending(Map<String, dynamic> data, String docId) {
  final field = (data['transporterId'] ?? '').toString().trim();
  final effective = field.isNotEmpty ? field : docId.trim();
  if (effective.isEmpty) return true;
  return isPlaceholderTid(effective);
}

/// Die wirksame TID eines Fahrer-Dokuments: Feld vor Doc-ID, in
/// Großbuchstaben. Leer, wenn beides fehlt.
String effectiveDriverTid(Map<String, dynamic> data, String docId) {
  final field = (data['transporterId'] ?? '').toString().trim();
  final effective = field.isNotEmpty ? field : docId.trim();
  return effective.toUpperCase();
}

/// Normalisiert eine **echte** TID auf die Schreibweise, die auch als
/// Doc-ID benutzt wird: Großbuchstaben, nur `A-Z0-9`.
///
/// Bewusst getrennt von [isPlaceholderTid]: Platzhalter enthalten einen
/// Bindestrich und dürfen hier nicht durchlaufen.
String normalizeRealTid(String raw) {
  return raw.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
}

// ─── Namens- und Personalnummer-Normalisierung ───────────────────────

/// Diakritika, die in den Fahrernamen dieser App real vorkommen
/// (deutsch, rumänisch, polnisch, albanisch, türkisch, tschechisch,
/// ungarisch, …). Alles darüber hinaus fällt in [normalizeDriverName]
/// ohnehin weg, weil dort nur `a-z` übrig bleibt.
const Map<String, String> _kDiacriticFolding = <String, String>{
  'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a', 'ā': 'a',
  'ă': 'a', 'ą': 'a',
  'ç': 'c', 'ć': 'c', 'č': 'c', 'ĉ': 'c',
  'ď': 'd', 'đ': 'd', 'ð': 'd',
  'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e', 'ē': 'e', 'ĕ': 'e', 'ė': 'e',
  'ę': 'e', 'ě': 'e',
  'ğ': 'g', 'ģ': 'g',
  'ĥ': 'h',
  'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i', 'ī': 'i', 'į': 'i', 'ı': 'i',
  'ĵ': 'j',
  'ķ': 'k',
  'ł': 'l', 'ľ': 'l', 'ĺ': 'l', 'ļ': 'l',
  'ñ': 'n', 'ń': 'n', 'ň': 'n', 'ņ': 'n',
  'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o', 'ø': 'o', 'ő': 'o',
  'ō': 'o',
  'ŕ': 'r', 'ř': 'r',
  'ś': 's', 'š': 's', 'ş': 's', 'ș': 's', 'ŝ': 's',
  'ţ': 't', 'ț': 't', 'ť': 't',
  'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u', 'ū': 'u', 'ů': 'u', 'ű': 'u',
  'ų': 'u',
  'ŵ': 'w',
  'ý': 'y', 'ÿ': 'y', 'ŷ': 'y',
  'ź': 'z', 'ż': 'z', 'ž': 'z',
  'ß': 'ss',
  'æ': 'ae', 'œ': 'oe',
};

/// Vergleichsform eines Fahrernamens.
///
/// Trimmt, senkt auf Kleinschreibung, faltet Diakritika (`ä→a`, `ç→c`,
/// `ą→a`, `ß→ss`, …), wirft alles außer `a-z` weg, **sortiert** die
/// Namensteile und verbindet sie mit `|`.
///
/// Die Sortierung ist der Kern: Amazon liefert je nach Export mal
/// „Ardi Syla", mal „Syla Ardi" — beides normalisiert zu `ardi|syla`.
///
/// ```dart
/// normalizeDriverName('Alin-Vasile Loghin'); // 'alin|loghin|vasile'
/// normalizeDriverName('Loghin, Alin Vasile'); // 'alin|loghin|vasile'
/// ```
String normalizeDriverName(String raw) {
  final lowered = raw.trim().toLowerCase();
  if (lowered.isEmpty) return '';

  final folded = StringBuffer();
  for (final ch in lowered.split('')) {
    folded.write(_kDiacriticFolding[ch] ?? ch);
  }

  final tokens = folded
      .toString()
      .split(RegExp(r'[^a-z]+'))
      .map((t) => t.trim())
      .where((t) => t.isNotEmpty)
      .toList()
    ..sort();

  return tokens.join('|');
}

/// Vergleichsform einer Personalnummer / Employee-ID.
///
/// Führende Nullen fallen weg („00023" → „23"), genau wie beim Editor im
/// Drivers Hub, damit ein CSV-Export mit gepolsterten Nummern trotzdem
/// trifft.
String normalizeEmployeeNumber(String raw) {
  final trimmed = raw.trim().toLowerCase();
  if (trimmed.isEmpty) return '';
  return trimmed.replaceFirst(RegExp(r'^0+(?=[0-9a-z])'), '');
}

// ─── Match-Ergebnis ──────────────────────────────────────────────────

/// Warum ein Platzhalter-Fahrer als Treffer gilt.
enum DriverMatchReason {
  /// Das Feld `transporterId` trägt bereits die echte TID, nur die
  /// Doc-ID hinkt hinterher — der Klassiker nach „TID zuordnen".
  /// Sicherster Treffer, weil ein Mensch die Zuordnung schon bestätigt hat.
  transporterIdField,

  /// Eindeutige, nicht-leere Personalnummer.
  employeeNumber,

  /// Eindeutiger normalisierter Name.
  driverName,
}

/// Ausgang der Suche nach einem Platzhalter-Fahrer.
enum DriverMatchStatus {
  /// Kein Kandidat — die TID gehört zu einem wirklich neuen Fahrer.
  none,

  /// Genau ein Kandidat — der Umzug darf automatisch laufen.
  matched,

  /// Mehrere Kandidaten — **nie** automatisch zusammenführen, sondern
  /// wie bisher neu anlegen und den Fall melden.
  ambiguous,
}

/// Ein Fahrer-Dokument, wie es der Matcher betrachtet.
class DriverMatchCandidate {
  const DriverMatchCandidate({
    required this.docId,
    required this.driverName,
    required this.employeeNumber,
    required this.transporterId,
    required this.tidPending,
  });

  /// Doc-ID unter `users/{dsp}/drivers` — heute meist die TID bzw. der
  /// Platzhalter.
  final String docId;

  final String driverName;

  /// Top-Level `employeeNumber`, ersatzweise `onboarding.employeeNumber`.
  final String employeeNumber;

  /// Feld `transporterId` (kann von [docId] abweichen!).
  final String transporterId;

  /// Ergebnis von [isDriverTidPending] für dieses Dokument.
  final bool tidPending;

  String get normalizedName => normalizeDriverName(driverName);
  String get normalizedEmployeeNumber => normalizeEmployeeNumber(employeeNumber);

  factory DriverMatchCandidate.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    final onboarding = data['onboarding'];
    var employeeNumber = (data['employeeNumber'] ?? '').toString().trim();
    if (employeeNumber.isEmpty && onboarding is Map) {
      employeeNumber = (onboarding['employeeNumber'] ?? '').toString().trim();
    }
    return DriverMatchCandidate(
      docId: doc.id,
      driverName: (data['driverName'] ?? '').toString().trim(),
      employeeNumber: employeeNumber,
      transporterId: (data['transporterId'] ?? '').toString().trim(),
      tidPending: isDriverTidPending(data, doc.id),
    );
  }

  @override
  String toString() =>
      'DriverMatchCandidate($docId, "$driverName", emp="$employeeNumber")';
}

/// Ergebnis von [findPendingMatch] / [DriverIdentityIndex.match].
class DriverMatchResult {
  const DriverMatchResult._({
    required this.status,
    this.docId,
    this.reason,
    this.candidates = const <DriverMatchCandidate>[],
  });

  /// Kein passender Platzhalter-Fahrer.
  const DriverMatchResult.none() : this._(status: DriverMatchStatus.none);

  /// Genau ein Treffer.
  const DriverMatchResult.matched(String docId, DriverMatchReason reason)
      : this._(
          status: DriverMatchStatus.matched,
          docId: docId,
          reason: reason,
        );

  /// Mehrere Treffer — der Aufrufer muss den Menschen entscheiden lassen.
  const DriverMatchResult.ambiguous(
    List<DriverMatchCandidate> candidates,
    DriverMatchReason reason,
  ) : this._(
          status: DriverMatchStatus.ambiguous,
          reason: reason,
          candidates: candidates,
        );

  final DriverMatchStatus status;

  /// Doc-ID des Platzhalter-Fahrers — nur bei [DriverMatchStatus.matched].
  final String? docId;

  final DriverMatchReason? reason;

  /// Nur bei [DriverMatchStatus.ambiguous] befüllt.
  final List<DriverMatchCandidate> candidates;

  bool get isMatch => status == DriverMatchStatus.matched;
  bool get isAmbiguous => status == DriverMatchStatus.ambiguous;

  @override
  String toString() => 'DriverMatchResult($status, docId=$docId, '
      'reason=$reason, candidates=${candidates.length})';
}

// ─── Der Matcher ─────────────────────────────────────────────────────

/// Alle Fahrer eines DSP, **einmal** geladen und im Speicher durchsucht.
///
/// Ein CSV-Import bringt gerne 150 TIDs mit — eine Query je Zeile wäre
/// weder bezahlbar noch schnell. Deshalb: einmal `get()`, danach nur noch
/// [match] auf der Liste.
class DriverIdentityIndex {
  DriverIdentityIndex(List<DriverMatchCandidate> candidates)
      : _candidates = List<DriverMatchCandidate>.from(candidates);

  final List<DriverMatchCandidate> _candidates;

  /// Lädt `users/{dspUid}/drivers` komplett.
  static Future<DriverIdentityIndex> load({
    required String dspUid,
    FirebaseFirestore? firestore,
  }) async {
    final db = firestore ?? FirebaseFirestore.instance;
    final snap = await db
        .collection('users')
        .doc(dspUid)
        .collection('drivers')
        .get();
    return DriverIdentityIndex(
      snap.docs.map(DriverMatchCandidate.fromSnapshot).toList(),
    );
  }

  /// Alle bekannten Fahrer (Lesekopie).
  List<DriverMatchCandidate> get candidates =>
      List<DriverMatchCandidate>.unmodifiable(_candidates);

  /// True, wenn unter dieser Doc-ID schon ein Fahrer liegt.
  bool hasDoc(String docId) => _candidates.any((c) => c.docId == docId);

  /// Sucht zu einer neu aufgetauchten [tid] den passenden
  /// Platzhalter-Fahrer.
  ///
  /// Reihenfolge — von „bereits durch einen Menschen bestätigt" nach
  /// „nur heuristisch":
  ///
  ///   a) **Sicherer Treffer:** ein Dokument, dessen Feld
  ///      `transporterId` schon `tid` ist, dessen Doc-ID aber nicht.
  ///      Das ist exakt der Zustand nach „TID zuordnen" ohne Umzug.
  ///   b) **Personalnummer:** genau ein Fahrer mit Platzhalter-TID und
  ///      identischer, nicht-leerer `employeeNumber`.
  ///   c) **Name:** genau ein Fahrer mit Platzhalter-TID und identischem
  ///      normalisiertem Namen.
  ///
  /// Trifft eine Stufe mehrfach, wird [DriverMatchStatus.ambiguous]
  /// zurückgegeben und **nicht** auf die nächste (unschärfere) Stufe
  /// ausgewichen — zwei gleichnamige Platzhalter dürfen nie geraten
  /// zusammengeführt werden.
  DriverMatchResult match({
    required String tid,
    required String driverName,
    String employeeNumber = '',
  }) {
    final target = normalizeRealTid(tid);
    if (target.isEmpty) return const DriverMatchResult.none();

    // a) Zuordnung war schon gemacht, nur der Umzug fehlte.
    final byField = _candidates
        .where((c) =>
            c.docId != target && normalizeRealTid(c.transporterId) == target)
        .toList();
    if (byField.length == 1) {
      return DriverMatchResult.matched(
        byField.first.docId,
        DriverMatchReason.transporterIdField,
      );
    }
    if (byField.length > 1) {
      return DriverMatchResult.ambiguous(
        byField,
        DriverMatchReason.transporterIdField,
      );
    }

    // Ab hier zählen nur noch Fahrer, die überhaupt auf eine TID warten.
    final pending =
        _candidates.where((c) => c.tidPending && c.docId != target).toList();
    if (pending.isEmpty) return const DriverMatchResult.none();

    // b) Personalnummer.
    final wantedEmployee = normalizeEmployeeNumber(employeeNumber);
    if (wantedEmployee.isNotEmpty) {
      final byEmployee = pending
          .where((c) => c.normalizedEmployeeNumber == wantedEmployee)
          .toList();
      if (byEmployee.length == 1) {
        return DriverMatchResult.matched(
          byEmployee.first.docId,
          DriverMatchReason.employeeNumber,
        );
      }
      if (byEmployee.length > 1) {
        return DriverMatchResult.ambiguous(
          byEmployee,
          DriverMatchReason.employeeNumber,
        );
      }
    }

    // c) Name.
    final wantedName = normalizeDriverName(driverName);
    if (wantedName.isEmpty) return const DriverMatchResult.none();
    final byName =
        pending.where((c) => c.normalizedName == wantedName).toList();
    if (byName.length == 1) {
      return DriverMatchResult.matched(
        byName.first.docId,
        DriverMatchReason.driverName,
      );
    }
    if (byName.length > 1) {
      return DriverMatchResult.ambiguous(byName, DriverMatchReason.driverName);
    }

    return const DriverMatchResult.none();
  }

  /// Zieht einen erfolgten Umzug im Index nach, damit eine spätere Zeile
  /// desselben Imports denselben Fahrer nicht ein zweites Mal trifft.
  void applyMigration({required String fromDocId, required String toTid}) {
    final target = normalizeRealTid(toTid);
    for (var i = 0; i < _candidates.length; i++) {
      if (_candidates[i].docId != fromDocId) continue;
      final old = _candidates[i];
      _candidates[i] = DriverMatchCandidate(
        docId: target,
        driverName: old.driverName,
        employeeNumber: old.employeeNumber,
        transporterId: target,
        tidPending: false,
      );
      return;
    }
  }
}

/// Einzelabfrage für Aufrufer außerhalb eines Imports (Dialoge, Detail-
/// seiten). Lädt die Fahrerliste einmal und matcht darauf.
///
/// **Nicht** in einer Schleife verwenden — dafür gibt es
/// [DriverIdentityIndex.load] plus [DriverIdentityIndex.match].
Future<DriverMatchResult> findPendingMatch({
  required String dspUid,
  required String tid,
  required String driverName,
  String employeeNumber = '',
  FirebaseFirestore? firestore,
}) async {
  final index =
      await DriverIdentityIndex.load(dspUid: dspUid, firestore: firestore);
  return index.match(
    tid: tid,
    driverName: driverName,
    employeeNumber: employeeNumber,
  );
}

// ─── Dubletten-Erkennung (rein lesend) ───────────────────────────────

/// Woran ein Verdachtsfall hängt.
enum DuplicateDriverSignal {
  /// Identische, nicht-leere Personalnummer.
  employeeNumber,

  /// Identischer normalisierter Name.
  driverName,
}

/// Ein Verdachtsfall: zwei oder mehr Fahrer-Dokumente, die vermutlich
/// dieselbe Person sind.
///
/// Bewusst **nur ein Verdacht** — es wird nichts automatisch
/// zusammengeführt. Der Admin entscheidet im Drivers Hub, welches Profil
/// bestehen bleibt.
class DuplicateDriverGroup {
  const DuplicateDriverGroup({
    required this.docIds,
    required this.signals,
    required this.label,
  });

  /// Doc-IDs der beteiligten Fahrer, mindestens zwei.
  final List<String> docIds;

  /// Welche Signale den Verdacht ausgelöst haben.
  final Set<DuplicateDriverSignal> signals;

  /// Anzeigename für die Überschrift des Falls.
  final String label;
}

/// Findet Verdachtsfälle in einer bereits geladenen Fahrerliste.
///
/// Rein lesend und **ohne** eine einzige zusätzliche Query: die Seite hat
/// die Fahrer ohnehin im Stream. Zwei Signale zählen:
///
///   • identische, nicht-leere Personalnummer,
///   • identischer normalisierter Name ([normalizeDriverName], also auch
///     „Syla Ardi" == „Ardi Syla").
///
/// Überlappende Treffer werden zu **einem** Fall verschmolzen — so
/// erscheint eine Person mit drei Profilen als ein Fall mit drei
/// Einträgen und nicht als drei Paare.
///
/// Fahrer ohne Namen und ohne Personalnummer werden ignoriert.
List<DuplicateDriverGroup> findDuplicateDriverGroups(
  Iterable<DocumentSnapshot<Map<String, dynamic>>> docs,
) {
  final candidates = <String, DriverMatchCandidate>{};
  for (final doc in docs) {
    if (!doc.exists) continue;
    candidates[doc.id] = DriverMatchCandidate.fromSnapshot(doc);
  }

  // Signal → Schlüssel → Doc-IDs
  final buckets = <DuplicateDriverSignal, Map<String, List<String>>>{
    DuplicateDriverSignal.employeeNumber: <String, List<String>>{},
    DuplicateDriverSignal.driverName: <String, List<String>>{},
  };
  for (final c in candidates.values) {
    final employee = c.normalizedEmployeeNumber;
    if (employee.isNotEmpty) {
      buckets[DuplicateDriverSignal.employeeNumber]!
          .putIfAbsent(employee, () => <String>[])
          .add(c.docId);
    }
    final name = c.normalizedName;
    if (name.isNotEmpty) {
      buckets[DuplicateDriverSignal.driverName]!
          .putIfAbsent(name, () => <String>[])
          .add(c.docId);
    }
  }

  // Union-Find über die Doc-IDs, damit sich Namens- und
  // Personalnummer-Treffer zu einem Fall verbinden.
  final parent = <String, String>{for (final id in candidates.keys) id: id};
  String find(String id) {
    var root = id;
    while (parent[root] != root) {
      root = parent[root]!;
    }
    var cursor = id;
    while (parent[cursor] != root) {
      final next = parent[cursor]!;
      parent[cursor] = root;
      cursor = next;
    }
    return root;
  }

  void union(String a, String b) {
    final ra = find(a);
    final rb = find(b);
    if (ra != rb) parent[rb] = ra;
  }

  final signalsPerDoc = <String, Set<DuplicateDriverSignal>>{};
  for (final entry in buckets.entries) {
    for (final ids in entry.value.values) {
      if (ids.length < 2) continue;
      for (final id in ids) {
        signalsPerDoc
            .putIfAbsent(id, () => <DuplicateDriverSignal>{})
            .add(entry.key);
        union(ids.first, id);
      }
    }
  }

  final grouped = <String, List<String>>{};
  for (final id in signalsPerDoc.keys) {
    grouped.putIfAbsent(find(id), () => <String>[]).add(id);
  }

  final out = <DuplicateDriverGroup>[];
  for (final ids in grouped.values) {
    if (ids.length < 2) continue;
    final signals = <DuplicateDriverSignal>{};
    for (final id in ids) {
      signals.addAll(signalsPerDoc[id] ?? const <DuplicateDriverSignal>{});
    }
    final sorted = [...ids]..sort();
    final label = candidates[sorted.first]?.driverName ?? sorted.first;
    out.add(DuplicateDriverGroup(
      docIds: sorted,
      signals: signals,
      label: label.isEmpty ? sorted.first : label,
    ));
  }
  out.sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));
  return out;
}

// ─── Der Umzug ───────────────────────────────────────────────────────

/// Fehler beim Umzug eines Fahrers auf eine neue Doc-ID.
///
/// Trägt eine sprechende Meldung, damit der Aufrufer sie direkt in einer
/// SnackBar zeigen kann.
class DriverMigrationException implements Exception {
  const DriverMigrationException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Alle Subcollections unter `users/{dsp}/drivers/{tid}`.
///
/// Der Firestore-Client kann Subcollections **nicht** auflisten (das geht
/// nur im Admin-SDK), deshalb diese feste Liste. Kommt eine neue
/// Subcollection dazu, muss sie hier eingetragen werden — sonst bleibt
/// sie beim TID-Wechsel zurück.
///
/// Belegt durch:
///   documents           — `admin_home_page.dart`, Nachweise/Dokumente
///   time_account        — `services/time_tracking_firestore.dart`
///   time_entries        — `services/time_tracking_firestore.dart`
///   shifts              — `driver_shift_plan_page.dart`
///   correction_requests — `services/time_tracking_firestore.dart`
///   absence_requests    — `driver_absence_page.dart`
///   notifications       — `driver_home_shell.dart`
///   academy_tests       — `driver_academy_module_page.dart`
///   faq_training        — `driver_faq_training_page.dart`
///   forms               — `driver_residence_permit_form_page.dart`
///   incident_reports    — `work_accident_form.dart`
const List<String> kDriverSubcollections = <String>[
  'documents',
  'time_account',
  'time_entries',
  'shifts',
  'correction_requests',
  'absence_requests',
  'notifications',
  'academy_tests',
  'faq_training',
  'forms',
  'incident_reports',
];

/// Die Schulungs-IDs, die in der Produktionsdatenbank tatsächlich unter
/// `users/{dsp}/academy_test_results/{testId}/drivers/{TID}` liegen
/// (Stand: ausgelesen beim DSP Arion — genau diese acht).
///
/// Bewusst als Referenzliste festgehalten, damit nachvollziehbar bleibt,
/// was der Umzug abdecken **muss**. Die Strings selbst werden nicht
/// dupliziert, sondern aus den vorhandenen Konstanten gezogen:
///
///   dsp_fahrsicherheit_v1  → `kDrivingSafetyTrainingId`
///   green_book             → `kGreenBookTestId`
///   operating_instructions → `kOperatingInstructionsTestId`
///   privacy                → `kPrivacyTestId`
///   privacy_camera         → `kPrivacyCameraTestId`
///   privacy_notice         → `kPrivacyNoticeTestId`
///   ride_along             → `kRideAlongTestId`
///   safety_training        → `kSafetyTrainingTestId`
///
/// Die ersten sechs davon stehen bereits in der Academy-Registry
/// [kAcademyTrainings] — eine neue Schulung, die dort eingetragen wird,
/// ist deshalb automatisch dabei. `privacy_camera` (plus der zugehörige
/// Widerspruch `privacy_camera_objection`) und `privacy_notice` leben
/// außerhalb der Registry und werden hier explizit ergänzt.
///
/// **Wichtig:** Entsteht eine neue Nachweis-Art außerhalb von
/// [kAcademyTrainings], muss sie hier ergänzt werden — sonst bleibt der
/// Nachweis beim TID-Wechsel an der alten ID hängen.
List<String> get kAcademyTestIdsForMigration => <String>{
      for (final training in kAcademyTrainings) training.testId,
      kPrivacyCameraTestId,
      kPrivacyCameraObjectionTestId,
      kPrivacyNoticeTestId,
    }.toList(growable: false);

// ─── Ergebnis des Umzugs ─────────────────────────────────────────────

/// Was beim Umzug eines Fahrers passiert ist.
///
/// Der Umzug selbst ist entweder ganz durch oder wirft
/// [DriverMigrationException]. Der Login-Sync dagegen darf scheitern,
/// ohne den Umzug zu gefährden — der Aufrufer erfährt das über
/// [loginSynced] / [loginSyncError] und kann eine Warnung anzeigen.
class DriverMigrationResult {
  const DriverMigrationResult({
    required this.fromDocId,
    required this.toTid,
    required this.driverName,
    this.movedSubcollectionDocs = 0,
    this.mergedIntoExisting = false,
    this.skipped = false,
    this.loginSynced = false,
    this.loginSyncError,
  });

  /// Alte Doc-ID (die Platzhalter-ID).
  final String fromDocId;

  /// Neue Doc-ID = echte Transporter-ID.
  final String toTid;

  /// Name des Fahrers — für Meldungen an den Admin.
  final String driverName;

  /// Anzahl kopierter Subcollection- und Nachweis-Dokumente.
  final int movedSubcollectionDocs;

  /// True, wenn unter [toTid] bereits ein (meist per CSV angelegtes)
  /// Dokument lag und zusammengeführt wurde.
  final bool mergedIntoExisting;

  /// True, wenn es nichts zu tun gab (Umzug lief schon, oder Quelle und
  /// Ziel sind dieselbe Doc-ID).
  final bool skipped;

  /// True, wenn `syncDriverLoginTransporterId` erfolgreich lief.
  final bool loginSynced;

  /// Gesetzt, wenn der Login-Sync nötig war, aber fehlschlug. Dann zeigt
  /// das Fahrer-Login (`users/{driverAuthUid}.transporterId` und die
  /// Auth-Claims) weiter auf die alte ID und der Fahrer läuft in seiner
  /// App in `permission-denied`.
  final String? loginSyncError;

  bool get hasLoginSyncWarning => loginSyncError != null;

  @override
  String toString() => 'DriverMigrationResult($fromDocId → $toTid, '
      'docs=$movedSubcollectionDocs, merged=$mergedIntoExisting, '
      'skipped=$skipped, loginSynced=$loginSynced, '
      'loginSyncError=$loginSyncError)';
}

/// Firestore erlaubt 500 Schreibvorgänge je Batch — mit Luft nach oben.
const int _kMigrationBatchSize = 300;

/// Zieht einen Fahrer vollständig auf die Doc-ID [toTid] um.
///
/// Ablauf strikt „**erst vollständig kopieren, dann löschen**" (Vorbild:
/// `FleetVehicleRepository.changePlateNumber`): bricht das Kopieren ab,
/// wird das bereits Geschriebene best-effort wieder entfernt — der
/// Altbestand bleibt unangetastet und der Aufruf kann wiederholt werden.
///
/// Mit umziehen:
///   • das Fahrer-Dokument (`transporterId` → [toTid], `tidPending` →
///     `false`, `createdAt` des alten Docs bleibt, `updatedAt` neu,
///     `previousTransporterId` als Spur),
///   • `employmentPeriods`: Einträge, deren `transporterId` die alte war,
///     bekommen die neue,
///   • alle Subcollections aus [kDriverSubcollections] (Doc-IDs bleiben),
///   • die nach TID geschlüsselten Academy-Nachweise
///     (`academy_test_results/{testId}/drivers/{TID}`).
///
/// **Dubletten:** existiert `drivers/{toTid}` bereits (das karge
/// CSV-Dokument), wird nicht blind überschrieben. Befüllte Felder des
/// Ziels behalten Vorrang, leere Zielfelder werden aus der Quelle (dem
/// gepflegten Profil) ergänzt. Bereits vorhandene Subcollection-Dokumente
/// im Ziel bleiben unverändert.
///
/// **Idempotent:** ist die Quelle schon weg und das Ziel vorhanden, tut
/// der Aufruf nichts. Ist `fromDocId == toTid`, wird nur das
/// `tidPending`-Flag geradegerückt.
///
/// **Fahrer-Login:** hat der Fahrer ein Login, wird danach die Cloud
/// Function `syncDriverLoginTransporterId` gerufen. Ohne sie zeigen das
/// Login-Dokument (`users/{driverAuthUid}.transporterId`) und die
/// Auth-Custom-Claims weiter auf die alte ID — die Firestore-Rules
/// vergleichen genau diese, der Fahrer bekäme `permission-denied`. Ein
/// Fehler dabei ist **nicht** fatal für den Umzug, wird aber im
/// [DriverMigrationResult] gemeldet.
///
/// Wirft [DriverMigrationException] mit sprechender Meldung.
Future<DriverMigrationResult> migrateDriverToTid({
  required String dspUid,
  required String fromDocId,
  required String toTid,
  FirebaseFirestore? firestore,
  FirebaseFunctions? functions,
}) async {
  final db = firestore ?? FirebaseFirestore.instance;
  final from = fromDocId.trim();
  final to = normalizeRealTid(toTid);

  if (dspUid.trim().isEmpty) {
    throw const DriverMigrationException(
      'Kein DSP-Konto — Umzug abgebrochen. / No DSP account — migration '
      'aborted.',
    );
  }
  if (from.isEmpty) {
    throw const DriverMigrationException(
      'Quell-Fahrer fehlt. / Source driver missing.',
    );
  }
  if (to.isEmpty || isPlaceholderTid(to)) {
    throw DriverMigrationException(
      'Ungültige Transporter-ID "$toTid". / Invalid transporter ID "$toTid".',
    );
  }

  final drivers = db.collection('users').doc(dspUid).collection('drivers');
  final sourceRef = drivers.doc(from);
  final targetRef = drivers.doc(to);

  // Sonderfall: Doc-ID stimmt schon, nur die Felder hinken hinterher.
  if (from == to) {
    final snap = await sourceRef.get();
    if (!snap.exists) {
      return DriverMigrationResult(
        fromDocId: from,
        toTid: to,
        driverName: '',
        skipped: true,
      );
    }
    await sourceRef.set(<String, dynamic>{
      'transporterId': to,
      'tidPending': false,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return DriverMigrationResult(
      fromDocId: from,
      toTid: to,
      driverName: (snap.data()?['driverName'] ?? '').toString(),
      skipped: true,
    );
  }

  final source = await sourceRef.get();
  final target = await targetRef.get();

  if (!source.exists) {
    // Idempotenz: ein früherer Lauf war schon erfolgreich.
    if (target.exists) {
      return DriverMigrationResult(
        fromDocId: from,
        toTid: to,
        driverName: (target.data()?['driverName'] ?? '').toString(),
        skipped: true,
      );
    }
    throw DriverMigrationException(
      'Fahrer "$from" nicht gefunden. / Driver "$from" not found.',
    );
  }

  final sourceData = source.data() ?? const <String, dynamic>{};
  final targetData = target.data();

  // ── 1. Lesen: Subcollections der Quelle (und des Ziels, um dort
  //    Vorhandenes nicht zu überschreiben).
  final sourceSubs = <String, QuerySnapshot<Map<String, dynamic>>>{};
  final targetSubIds = <String, Set<String>>{};
  for (final name in kDriverSubcollections) {
    sourceSubs[name] = await sourceRef.collection(name).get();
    if (target.exists && sourceSubs[name]!.docs.isNotEmpty) {
      final existing = await targetRef.collection(name).get();
      targetSubIds[name] = existing.docs.map((d) => d.id).toSet();
    } else {
      targetSubIds[name] = const <String>{};
    }
  }

  // ── 2. Lesen: Academy-Nachweise (nach TID geschlüsselt).
  final academyResults = db
      .collection('users')
      .doc(dspUid)
      .collection('academy_test_results');
  final academySources =
      <String, DocumentSnapshot<Map<String, dynamic>>>{};
  final academyTargetExists = <String, bool>{};
  for (final testId in kAcademyTestIdsForMigration) {
    final snap =
        await academyResults.doc(testId).collection('drivers').doc(from).get();
    if (!snap.exists) continue;
    academySources[testId] = snap;
    final existing =
        await academyResults.doc(testId).collection('drivers').doc(to).get();
    academyTargetExists[testId] = existing.exists;
  }

  // ── 3. Schreiben: erst alles kopieren.
  final payload = _mergedDriverPayload(
    source: sourceData,
    target: targetData,
    fromDocId: from,
    toTid: to,
  );

  // Refs, die es vor dem Umzug noch nicht gab — nur die dürfen bei einem
  // Abbruch wieder weg. Ein bereits existierendes Ziel-Dokument gehört
  // ausdrücklich **nicht** dazu.
  final createdRefs = <DocumentReference<Map<String, dynamic>>>[];
  final writes = <_DriverMoveWrite>[
    _DriverMoveWrite(targetRef, payload, isNew: !target.exists),
    for (final name in kDriverSubcollections)
      for (final doc in sourceSubs[name]!.docs)
        if (!targetSubIds[name]!.contains(doc.id))
          _DriverMoveWrite(
            targetRef.collection(name).doc(doc.id),
            doc.data(),
            isNew: true,
          ),
    for (final entry in academySources.entries)
      if (academyTargetExists[entry.key] != true)
        _DriverMoveWrite(
          academyResults
              .doc(entry.key)
              .collection('drivers')
              .doc(to),
          <String, dynamic>{
            ...entry.value.data() ?? const <String, dynamic>{},
            'transporterId': to,
          },
          isNew: true,
        ),
  ];

  try {
    for (final chunk in _chunk(writes, _kMigrationBatchSize)) {
      final batch = db.batch();
      for (final write in chunk) {
        batch.set(write.ref, write.data, SetOptions(merge: true));
        if (write.isNew) createdRefs.add(write.ref);
      }
      await batch.commit();
    }
  } catch (e) {
    // Kopie unvollständig → neu Angelegtes best-effort wieder räumen.
    // Der Altbestand wurde noch nicht angefasst, ein zweiter Versuch
    // startet also von vorn.
    for (final chunk in _chunk(createdRefs, _kMigrationBatchSize)) {
      try {
        final batch = db.batch();
        for (final ref in chunk) {
          batch.delete(ref);
        }
        await batch.commit();
      } catch (_) {
        // Aufräumen ist Kür — die Hauptmeldung ist der Fehler unten.
      }
    }
    throw DriverMigrationException(
      'Umzug von "$from" auf "$to" fehlgeschlagen: $e / '
      'Migration from "$from" to "$to" failed: $e',
    );
  }

  // ── 4. Fahrer-Login mitziehen.
  //
  // Bewusst **vor** dem Löschen: das Ziel-Dokument steht schon, und wenn
  // das Aufräumen unten scheitert, ist wenigstens das Login korrekt.
  // Ein Fehler hier bricht den Umzug nicht ab — er wird gemeldet.
  var loginSynced = false;
  String? loginSyncError;
  final loginEmail = _loginEmailOf(payload);
  // `hasLogin == false` heißt: nie ein Auth-User angelegt (so schreibt es
  // der CSV-Import für neue Fahrer). Nur dann sparen wir uns den Aufruf —
  // fehlt das Feld ganz (Altbestand), rufen wir lieber einmal zu viel.
  final needsLoginSync =
      loginEmail.isNotEmpty && payload['hasLogin'] != false;
  if (needsLoginSync) {
    try {
      await (functions ?? FirebaseFunctions.instance)
          .httpsCallable('syncDriverLoginTransporterId')
          .call(<String, dynamic>{
        'driverEmail': loginEmail,
        'newTransporterId': to,
      });
      loginSynced = true;
    } catch (e) {
      loginSyncError = e.toString();
    }
  }

  // ── 5. Jetzt erst der Altbestand.
  final deletions = <DocumentReference<Map<String, dynamic>>>[
    for (final name in kDriverSubcollections)
      for (final doc in sourceSubs[name]!.docs) doc.reference,
    for (final entry in academySources.entries) entry.value.reference,
    sourceRef,
  ];
  try {
    for (final chunk in _chunk(deletions, _kMigrationBatchSize)) {
      final batch = db.batch();
      for (final ref in chunk) {
        batch.delete(ref);
      }
      await batch.commit();
    }
  } catch (e) {
    // Die Kopie steht bereits — ein Rest im alten Pfad ist unschön, aber
    // kein Datenverlust. Erneutes Aufrufen räumt ihn ab.
    throw DriverMigrationException(
      'Fahrer wurde auf "$to" kopiert, das alte Profil "$from" konnte aber '
      'nicht vollständig gelöscht werden: $e / '
      'Driver was copied to "$to", but the old profile "$from" could not be '
      'fully deleted: $e',
    );
  }

  return DriverMigrationResult(
    fromDocId: from,
    toTid: to,
    driverName: (payload['driverName'] ?? '').toString(),
    movedSubcollectionDocs: writes.where((w) => w.ref != targetRef).length,
    mergedIntoExisting: target.exists,
    loginSynced: loginSynced,
    loginSyncError: loginSyncError,
  );
}

/// Login-E-Mail eines Fahrers — wie im Drivers Hub: `email`, ersatzweise
/// `loginEmail`, ersatzweise `onboarding.email`.
String _loginEmailOf(Map<String, dynamic> data) {
  final onboarding = data['onboarding'];
  final raw = data['email'] ??
      data['loginEmail'] ??
      (onboarding is Map ? onboarding['email'] : null) ??
      '';
  return raw.toString().trim();
}

/// Ein einzelner Schreibvorgang des Fahrer-Umzugs.
class _DriverMoveWrite {
  const _DriverMoveWrite(this.ref, this.data, {required this.isNew});

  final DocumentReference<Map<String, dynamic>> ref;
  final Map<String, dynamic> data;

  /// True, wenn das Dokument vor dem Umzug noch nicht existierte — nur
  /// diese dürfen beim Aufräumen nach einem Fehler gelöscht werden.
  final bool isNew;
}

/// Baut das Fahrer-Dokument für die neue Doc-ID.
///
/// Regel bei einer Dublette: **befüllte Felder des Ziels gewinnen**, leere
/// werden aus der Quelle ergänzt — das Ziel ist typischerweise das karge
/// CSV-Dokument, die Quelle das gepflegte Profil.
///
/// Bewusste Ausnahmen, weil die stumpfe Regel dort Schaden anrichtet:
///   • `createdAt`  — das ältere Datum der Quelle bleibt (Spezifikation).
///   • `hasLogin`   — logisches ODER; der CSV-Stub schreibt `false`, das
///                    darf ein bestehendes Login nicht wegwerfen.
///   • `active`     — die Quelle gewinnt, wenn sie das Feld führt; eine
///                    Deaktivierung durch den Admin darf ein CSV-`true`
///                    nicht rückgängig machen.
///   • `transporterId` / `tidPending` — immer neu gesetzt.
Map<String, dynamic> _mergedDriverPayload({
  required Map<String, dynamic> source,
  required Map<String, dynamic>? target,
  required String fromDocId,
  required String toTid,
}) {
  final out = <String, dynamic>{...source};

  if (target != null) {
    for (final entry in target.entries) {
      if (_isBlank(entry.value)) continue;
      out[entry.key] = entry.value;
    }
    if (source.containsKey('createdAt')) {
      out['createdAt'] = source['createdAt'];
    }
    if (source['hasLogin'] == true || target['hasLogin'] == true) {
      out['hasLogin'] = true;
    }
    if (source.containsKey('active')) {
      out['active'] = source['active'];
    }
  }

  final oldTid = (source['transporterId'] ?? '').toString().trim();
  out['transporterId'] = toTid;
  out['tidPending'] = false;
  out['previousTransporterId'] = fromDocId;
  out['updatedAt'] = FieldValue.serverTimestamp();

  final periods = _remapEmploymentPeriods(
    out['employmentPeriods'],
    oldIds: <String>{fromDocId.toUpperCase(), oldTid.toUpperCase()},
    toTid: toTid,
  );
  if (periods != null) out['employmentPeriods'] = periods;

  return out;
}

/// Setzt in `employmentPeriods` die alte TID auf die neue.
///
/// Arbeitet bewusst auf den rohen Maps statt über
/// `EmploymentPeriod.fromMap`/`toMap`: so bleiben eventuelle Zusatzfelder
/// eines Eintrags erhalten und ein unparsbarer Eintrag geht nicht
/// verloren. Gibt `null` zurück, wenn es nichts zu tun gibt.
List<dynamic>? _remapEmploymentPeriods(
  Object? raw, {
  required Set<String> oldIds,
  required String toTid,
}) {
  if (raw is! List) return null;
  final wanted = oldIds.where((id) => id.isNotEmpty).toSet();
  final out = <dynamic>[];
  for (final entry in raw) {
    if (entry is! Map) {
      out.add(entry);
      continue;
    }
    final map = entry.map((k, v) => MapEntry(k.toString(), v));
    final tid = (map['transporterId'] ?? '').toString().trim().toUpperCase();
    if (tid.isEmpty || wanted.contains(tid)) {
      map['transporterId'] = toTid;
    }
    out.add(map);
  }
  return out;
}

/// „Leer" im Sinne der Dubletten-Regel: nichts, was ein gepflegtes Feld
/// der Quelle verdrängen dürfte.
bool _isBlank(Object? value) {
  if (value == null) return true;
  if (value is String) return value.trim().isEmpty;
  if (value is Iterable) return value.isEmpty;
  if (value is Map) return value.isEmpty;
  return false;
}

Iterable<List<T>> _chunk<T>(List<T> items, int size) sync* {
  for (var i = 0; i < items.length; i += size) {
    yield items.sublist(i, i + size > items.length ? items.length : i + size);
  }
}
