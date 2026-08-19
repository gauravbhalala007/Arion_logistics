// lib/Screens/admin_academy_page.dart
//
// DA Academy — Admin-Übersicht (rein lesend).
//
// Die Schulungen sind fest eingebaut (Code unter `lib/data/safety_training/**`,
// zentral beschrieben in `lib/data/academy_catalog.dart`). Diese Seite zeigt
// nur noch:
//   • wie viele aktive Fahrer es gibt,
//   • je Schulung Umfang (Kapitel/Seiten/Fragen/Bestehensgrenze/Gültigkeit),
//   • einen Zähler „X von Y aktiven Fahrern erledigt · Z offen",
//   • wer bestanden hat (mit Datum / Gültig-bis) und wer noch fehlt,
//   • die Fragen samt richtiger Antwort und Erklärung — nur lesend.
//
// BEWUSST ENTFERNT: der frühere Editor für `academy_tests` (Kategorien,
// Fragen, Optionen anlegen/ändern/löschen). Die Collection `academy_tests`
// bleibt unangetastet — sie wird weiterhin von der Fahrer-Seite gelesen
// (`driver_academy_page.dart` für dynamische Kategorien,
// `driver_academy_module_page.dart` für deren Inhalte und
// `driver_green_book_page.dart` für die Green-Book-Video-URL). Diese Seite
// liest und schreibt dort nichts mehr.
//
// Daten (lesend, gebündelt — eine Sammelabfrage je Schulung):
//   users/{dspUid}/drivers
//   users/{dspUid}/academy_test_results/{testId}/drivers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/academy_catalog.dart';
import '../data/academy_visibility.dart';
import '../data/privacy_camera/privacy_camera_content.dart'
    show PrivacyCourseBundle, kPrivacyBindingLanguage, kPrivacyCameraTestId;
import '../data/privacy_camera/privacy_camera_repository.dart'
    show PrivacyCameraAdminRepository;
import '../utils/driver_activity.dart';
import '../widgets/academy_visibility_toggle.dart';
import '../widgets/admin_scope.dart';
import 'admin_privacy_camera_section.dart';

const Color _kGreen = Color(0xFF1D7F5A);
const Color _kGreenBg = Color(0xFFE4F5EC);
const Color _kText = Color(0xFF111827);
const Color _kSub = Color(0xFF4B5563);
const Color _kMuted = Color(0xFF6B7280);
const Color _kBorder = Color(0xFFE5E7EB);
const Color _kBg = Color(0xFFF5F7F9);
const Color _kAmber = Color(0xFFB45309);
const Color _kAmberBg = Color(0xFFFEF3C7);
const Color _kRed = Color(0xFFB91C1C);
const Color _kRedBg = Color(0xFFFEE2E2);
const Color _kOpen = Color(0xFF9A3412);
const Color _kOpenBg = Color(0xFFFFEDD5);

/// Vorwarnzeit: so viele Tage vor Ablauf gilt ein Abschluss als
/// „läuft bald ab" — er zählt weiterhin als erledigt.
const int _kDueSoonDays = 30;

final DateFormat _kDate = DateFormat('dd.MM.yyyy');

// ══════════════════════════════════════════════════════════════════════
// Auswertung
// ══════════════════════════════════════════════════════════════════════

/// Zustand eines Fahrers zu einer Schulung.
///
/// Reihenfolge = Sortierreihenfolge in den Listen.
enum _DriverStatus { done, dueSoon, expired, open }

extension on _DriverStatus {
  /// Nur gültige Abschlüsse zählen als erledigt — abgelaufene NICHT.
  bool get counts =>
      this == _DriverStatus.done || this == _DriverStatus.dueSoon;
}

class _DriverRow {
  final String transporterId;
  final String name;
  final String employeeNumber;
  final _DriverStatus status;
  final DateTime? passedAt;
  final DateTime? validUntil;
  final String? scoreLabel;

  /// Unterschriebenes Nachweis-PDF (Zertifikat), sofern vorhanden.
  final String? certificateUrl;

  /// Nur Betriebsanweisungen: bestätigte / benötigte Anweisungen.
  final int ackDone;
  final int ackTotal;

  const _DriverRow({
    required this.transporterId,
    required this.name,
    required this.employeeNumber,
    required this.status,
    this.passedAt,
    this.validUntil,
    this.scoreLabel,
    this.certificateUrl,
    this.ackDone = 0,
    this.ackTotal = 0,
  });

  bool matches(String query) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase();
    return name.toLowerCase().contains(q) ||
        transporterId.toLowerCase().contains(q) ||
        employeeNumber.toLowerCase().contains(q);
  }
}

/// Ausgewertete Zahlen und Listen einer Schulung.
class _TrainingStats {
  final AcademyTraining training;
  final List<_DriverRow> doneRows;
  final List<_DriverRow> openRows;
  final int expiredCount;

  const _TrainingStats({
    required this.training,
    required this.doneRows,
    required this.openRows,
    required this.expiredCount,
  });

  int get doneCount => doneRows.length;
  int get openCount => openRows.length;
  int get totalCount => doneCount + openCount;
  double get ratio => totalCount == 0 ? 0 : doneCount / totalCount;
}

/// Ein Ladevorgang für die ganze Seite.
class _AcademyData {
  /// Aktive Fahrer (Filter: [isDriverWorking]).
  final List<Map<String, dynamic>> drivers;

  /// testId -> transporterId (UPPER) -> Ergebnisdokument.
  final Map<String, Map<String, Map<String, dynamic>>> results;

  /// Welche Schulungen der Admin für seine Fahrer freigeschaltet hat.
  final AcademyVisibility visibility;

  /// Kamera-Datenschutzmodul. Bewusst NICHT über `kAcademyTrainings`:
  /// dort steckt die Semantik `passedAt` + Ablaufdatum, dieses Modul
  /// kennt aber nur „Kenntnisnahme zur aktuellen Fassung". Deshalb eine
  /// gezielte Auswertung, die in denselben Zähler einfließt.
  final int cameraDone;
  final int cameraOpen;

  const _AcademyData({
    required this.drivers,
    required this.results,
    required this.visibility,
    required this.cameraDone,
    required this.cameraOpen,
  });
}

DateTime? _toDate(Object? value) =>
    value is Timestamp ? value.toDate() : (value is DateTime ? value : null);

/// Ergebniszeile eines Tests. `null` bei `passedAt` = nie bestanden.
String? _scoreLabelOf(Map<String, dynamic> data) {
  final correct = (data['correct'] as num?)?.toInt();
  final total = (data['total'] as num?)?.toInt();
  final score = (data['score'] as num?)?.toDouble();

  if (correct != null && total != null && total > 0) {
    return '$correct/$total (${(correct / total * 100).round()} %)';
  }
  // Sicherheitsunterweisung schreibt `score` als Anzahl richtiger Antworten.
  if (score != null && total != null && total > 0 && score > 1) {
    return '${score.round()}/$total (${(score / total * 100).round()} %)';
  }
  // Alle übrigen schreiben `score` als Anteil (0…1).
  if (score != null && score <= 1) return '${(score * 100).round()} %';
  return null;
}

_TrainingStats _evaluate(
  AcademyTraining training,
  _AcademyData data,
  String languageCode,
) {
  final now = DateTime.now();
  final results = data.results[training.testId] ?? const {};
  final requiredAcks = training.kind == AcademyCompletionKind.acknowledgement
      ? training.requiredAckIds(languageCode)
      : const <String>[];

  final done = <_DriverRow>[];
  final open = <_DriverRow>[];
  var expired = 0;

  for (final driver in data.drivers) {
    final tid = (driver['__id'] ?? '').toString();
    final name = _driverName(driver, fallback: tid);
    final employeeNumber = (driver['employeeNumber'] ?? '').toString().trim();
    final result = results[tid.toUpperCase()];

    late final _DriverRow row;

    if (training.kind == AcademyCompletionKind.acknowledgement) {
      final raw = result?['acknowledged'];
      final acknowledged = raw is Map ? raw : const {};
      var ackDone = 0;
      DateTime? last;
      for (final id in requiredAcks) {
        final entry = acknowledged[id];
        if (entry == null) continue;
        ackDone++;
        final at = entry is Map ? _toDate(entry['at']) : _toDate(entry);
        final previous = last;
        if (at != null && (previous == null || at.isAfter(previous))) {
          last = at;
        }
      }
      final complete = requiredAcks.isNotEmpty && ackDone >= requiredAcks.length;
      row = _DriverRow(
        transporterId: tid,
        name: name,
        employeeNumber: employeeNumber,
        status: complete ? _DriverStatus.done : _DriverStatus.open,
        passedAt: complete ? last : null,
        ackDone: ackDone,
        ackTotal: requiredAcks.length,
      );
    } else {
      final passedAt = _toDate(result?['passedAt']);
      DateTime? validUntil = _toDate(result?['validUntil']);
      if (passedAt != null && validUntil == null && training.validity != null) {
        validUntil = passedAt.add(training.validity!);
      }

      final _DriverStatus status;
      if (passedAt == null) {
        status = _DriverStatus.open;
      } else if (validUntil == null) {
        status = _DriverStatus.done;
      } else if (!validUntil.isAfter(now)) {
        status = _DriverStatus.expired;
      } else if (validUntil.difference(now).inDays <= _kDueSoonDays) {
        status = _DriverStatus.dueSoon;
      } else {
        status = _DriverStatus.done;
      }

      final certUrl = (result?['certificateUrl'] ?? '').toString();
      row = _DriverRow(
        transporterId: tid,
        name: name,
        employeeNumber: employeeNumber,
        status: status,
        passedAt: passedAt,
        validUntil: validUntil,
        scoreLabel: result == null ? null : _scoreLabelOf(result),
        certificateUrl: certUrl.isEmpty ? null : certUrl,
      );
    }

    if (row.status == _DriverStatus.expired) expired++;
    (row.status.counts ? done : open).add(row);
  }

  int byStatusThenName(_DriverRow a, _DriverRow b) {
    final s = a.status.index.compareTo(b.status.index);
    if (s != 0) return s;
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  }

  done.sort(byStatusThenName);
  open.sort(byStatusThenName);

  return _TrainingStats(
    training: training,
    doneRows: done,
    openRows: open,
    expiredCount: expired,
  );
}

String _driverName(Map<String, dynamic> data, {required String fallback}) {
  for (final key in ['driverName', 'fullName', 'name']) {
    final value = (data[key] ?? '').toString().trim();
    if (value.isNotEmpty) return value;
  }
  final first = (data['firstName'] ?? '').toString().trim();
  final last = (data['lastName'] ?? '').toString().trim();
  final joined = [first, last].where((e) => e.isNotEmpty).join(' ');
  return joined.isNotEmpty ? joined : fallback;
}

// ══════════════════════════════════════════════════════════════════════
// Seite
// ══════════════════════════════════════════════════════════════════════

class AdminAcademyPage extends StatefulWidget {
  const AdminAcademyPage({super.key});

  @override
  State<AdminAcademyPage> createState() => _AdminAcademyPageState();
}

class _AdminAcademyPageState extends State<AdminAcademyPage> {
  Future<_AcademyData>? _future;
  String? _loadedForUid;

  bool get _de => Localizations.localeOf(context).languageCode == 'de';

  String get _lang => _de ? 'de' : 'en';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final uid = AdminScope.adminUidOf(context);
    if (uid != null && uid != _loadedForUid) {
      _loadedForUid = uid;
      _future = _load(uid);
    }
  }

  Future<_AcademyData> _load(String uid) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

    // Eine Sammelabfrage je Schulung plus eine für die Fahrer — nicht eine
    // Abfrage je Fahrer und Schulung.
    final snaps = await Future.wait<QuerySnapshot<Map<String, dynamic>>>([
      userRef.collection('drivers').get(),
      for (final training in kAcademyTrainings)
        userRef
            .collection('academy_test_results')
            .doc(training.testId)
            .collection('drivers')
            .get(),
    ]);

    final drivers = <Map<String, dynamic>>[];
    for (final doc in snaps.first.docs) {
      final data = doc.data();
      if (!isDriverWorking(data)) continue;
      final tid = (data['transporterId'] ?? doc.id).toString().trim();
      drivers.add({...data, '__id': tid.isEmpty ? doc.id : tid});
    }

    final results = <String, Map<String, Map<String, dynamic>>>{};
    for (var i = 0; i < kAcademyTrainings.length; i++) {
      results[kAcademyTrainings[i].testId] = {
        for (final doc in snaps[i + 1].docs) doc.id.toUpperCase(): doc.data(),
      };
    }

    final visibility = await AcademyVisibility.load(uid);

    // Kamera-Datenschutz: bestätigt = gültiger Nachweis zur AKTUELLEN
    // (deutschen, verbindlichen) Fassung. Alles andere — kein Nachweis,
    // veraltete Fassung oder eine Verweigerung aus Bestandsdaten — zählt
    // als offen, aber ohne Alarmfarbe: eine Verweigerung ist kein Fehler.
    var cameraDone = 0;
    var cameraOpen = 0;
    try {
      final bundle = await PrivacyCourseBundle.load(kPrivacyBindingLanguage);
      final acks = await PrivacyCameraAdminRepository(dspUid: uid).loadAcks();
      final doc = bundle.bindingDocument;
      for (final driver in drivers) {
        final tid = '${driver['__id'] ?? ''}'.trim();
        if (tid.isEmpty) continue;
        final ack = acks[tid.toUpperCase()];
        if (ack != null && ack.isAcknowledged && ack.matchesDocument(doc)) {
          cameraDone++;
        } else {
          cameraOpen++;
        }
      }
    } catch (_) {
      // Ohne Inhalte/Daten lieber keine Zahl als eine falsche.
      cameraDone = 0;
      cameraOpen = 0;
    }

    return _AcademyData(
      drivers: drivers,
      results: results,
      visibility: visibility,
      cameraDone: cameraDone,
      cameraOpen: cameraOpen,
    );
  }

  /// Optimistische Overrides, damit der Schalter sofort umspringt und
  /// nicht erst nach einem Reload.
  final Map<String, bool> _visOverride = <String, bool>{};

  bool _visibleOf(_AcademyData data, String testId) =>
      _visOverride[testId] ?? data.visibility.isVisible(testId);

  Future<void> _setVisible(String testId, bool visible) async {
    final uid = _loadedForUid;
    if (uid == null) return;
    setState(() => _visOverride[testId] = visible);
    try {
      await AcademyVisibility.setVisible(uid, testId, visible);
    } catch (e) {
      if (!mounted) return;
      // Zurückdrehen — sonst zeigt die UI eine Freischaltung an, die
      // gar nicht gespeichert wurde.
      setState(() => _visOverride[testId] = !visible);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _de
                ? 'Sichtbarkeit konnte nicht gespeichert werden: $e'
                : 'Visibility could not be saved: $e',
          ),
        ),
      );
    }
  }

  void _reload() {
    final uid = _loadedForUid;
    if (uid == null) return;
    setState(() => _future = _load(uid));
  }

  @override
  Widget build(BuildContext context) {
    final de = _de;
    final future = _future;

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: future == null
            ? Center(
                child: Text(
                  de ? 'Bitte einloggen.' : 'Please sign in.',
                  style: const TextStyle(color: _kMuted),
                ),
              )
            : FutureBuilder<_AcademyData>(
                future: future,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError || snap.data == null) {
                    return _errorState(de);
                  }
                  return _content(de, snap.data!);
                },
              ),
      ),
    );
  }

  Widget _errorState(bool de) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 40, color: _kMuted),
              const SizedBox(height: 10),
              Text(
                de
                    ? 'Die Schulungsdaten konnten nicht geladen werden.'
                    : 'Training data could not be loaded.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: _kSub, fontSize: 14),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _reload,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(de ? 'Erneut versuchen' : 'Try again'),
              ),
            ],
          ),
        ),
      );

  Widget _content(bool de, _AcademyData data) {
    final lang = _lang;
    final stats = [
      for (final training in kAcademyTrainings) _evaluate(training, data, lang),
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 700;
            final pad = narrow ? 12.0 : 20.0;
            return ListView(
              padding: EdgeInsets.fromLTRB(pad, pad, pad, pad + 20),
              children: [
                _header(de, narrow),
                const SizedBox(height: 14),
                _OverviewCard(
                  de: de,
                  narrow: narrow,
                  activeDrivers: data.drivers.length,
                  stats: stats,
                  // Kameramodul zählt mit, obwohl es nicht in der
                  // Registry steht.
                  extraTrainings: 1,
                  extraFullyDone: data.cameraOpen == 0 ? 1 : 0,
                ),
                const SizedBox(height: 14),
                for (final s in stats)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _TrainingCard(
                      key: ValueKey(s.training.testId),
                      de: de,
                      languageCode: lang,
                      narrow: narrow,
                      stats: s,
                      visible: _visibleOf(data, s.training.testId),
                      onVisibilityChanged: (v) =>
                          _setVisible(s.training.testId, v),
                    ),
                  ),
                // Kameras im Fahrzeug – Datenschutz. Eigener Abschnitt
                // statt eines Eintrags in `kAcademyTrainings`: dieses
                // Modul kennt kein Bestehen und keinen Ablauf, sondern
                // Kenntnisnahme / Verweigerung — und Verweigerung ist
                // kein Rückstand. Siehe admin_privacy_camera_section.dart.
                if (_loadedForUid != null)
                  AdminPrivacyCameraSection(
                    dspUid: _loadedForUid!,
                    drivers: data.drivers,
                    de: de,
                    narrow: narrow,
                    visible: _visibleOf(data, kPrivacyCameraTestId),
                    onVisibilityChanged: (v) =>
                        _setVisible(kPrivacyCameraTestId, v),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _header(bool de, bool narrow) {
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DA Academy',
          style: TextStyle(
            fontSize: narrow ? 21 : 24,
            fontWeight: FontWeight.w900,
            color: _kText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          de
              ? 'Übersicht aller hinterlegten Schulungen mit Fragen und '
                  'Abschlussquote. Die Inhalte sind fest eingebaut und '
                  'werden hier nur angezeigt — nicht bearbeitet.'
              : 'Overview of every built-in training with its questions and '
                  'completion rate. Contents are shipped with the app and are '
                  'only displayed here — not edited.',
          style: const TextStyle(fontSize: 13.5, color: _kMuted, height: 1.35),
        ),
      ],
    );

    final refresh = OutlinedButton.icon(
      onPressed: _reload,
      icon: const Icon(Icons.refresh_rounded, size: 18),
      label: Text(de ? 'Aktualisieren' : 'Refresh'),
      style: OutlinedButton.styleFrom(
        foregroundColor: _kGreen,
        side: const BorderSide(color: _kBorder),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );

    if (narrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          const SizedBox(height: 10),
          refresh,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: title),
        const SizedBox(width: 12),
        refresh,
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Kopfbereich: Gesamtüberblick
// ══════════════════════════════════════════════════════════════════════

class _OverviewCard extends StatelessWidget {
  final bool de;
  final bool narrow;
  final int activeDrivers;
  final List<_TrainingStats> stats;

  /// Schulungen, die nicht aus `kAcademyTrainings` stammen, aber in den
  /// Zählern erscheinen sollen (derzeit: Kamera-Datenschutz).
  final int extraTrainings;
  final int extraFullyDone;

  const _OverviewCard({
    required this.de,
    required this.narrow,
    required this.activeDrivers,
    required this.stats,
    this.extraTrainings = 0,
    this.extraFullyDone = 0,
  });

  @override
  Widget build(BuildContext context) {
    final fullyDone =
        stats.where((s) => s.openCount == 0).length + extraFullyDone;
    final expired = stats.fold<int>(0, (acc, s) => acc + s.expiredCount);

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatTile(
                value: '$activeDrivers',
                label: de ? 'aktive Fahrer' : 'active drivers',
                color: _kGreen,
                narrow: narrow,
              ),
              _StatTile(
                value: '${stats.length + extraTrainings}',
                label: de ? 'Schulungen' : 'trainings',
                color: _kText,
                narrow: narrow,
              ),
              _StatTile(
                value: '$fullyDone',
                label: de ? 'vollständig erledigt' : 'fully completed',
                color: _kGreen,
                narrow: narrow,
              ),
              _StatTile(
                value: '$expired',
                label: de ? 'abgelaufene Abschlüsse' : 'expired completions',
                color: expired == 0 ? _kMuted : _kRed,
                narrow: narrow,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: _kBorder),
          const SizedBox(height: 14),
          Text(
            de ? 'Fortschritt je Schulung' : 'Progress per training',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: _kText,
              letterSpacing: .2,
            ),
          ),
          const SizedBox(height: 10),
          for (final s in stats)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _MiniProgressRow(de: de, narrow: narrow, stats: s),
            ),
          if (activeDrivers == 0)
            Text(
              de
                  ? 'Es sind derzeit keine aktiven Fahrer hinterlegt.'
                  : 'There are currently no active drivers.',
              style: const TextStyle(fontSize: 12.5, color: _kMuted),
            ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final bool narrow;

  const _StatTile({
    required this.value,
    required this.label,
    required this.color,
    required this.narrow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: narrow ? 148 : 190,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: narrow ? 22 : 26,
              fontWeight: FontWeight.w900,
              color: color,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: _kMuted),
          ),
        ],
      ),
    );
  }
}

class _MiniProgressRow extends StatelessWidget {
  final bool de;
  final bool narrow;
  final _TrainingStats stats;

  const _MiniProgressRow({
    required this.de,
    required this.narrow,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final t = stats.training;
    final counter = '${stats.doneCount}/${stats.totalCount}';

    final label = Row(
      children: [
        Icon(t.icon, size: 16, color: t.accent),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            t.title(de),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _kText,
            ),
          ),
        ),
      ],
    );

    final bar = _ProgressBar(ratio: stats.ratio, color: t.accent);

    final value = Text(
      counter,
      style: const TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w900,
        color: _kSub,
      ),
    );

    if (narrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: label),
              const SizedBox(width: 8),
              value,
            ],
          ),
          const SizedBox(height: 6),
          bar,
        ],
      );
    }

    return Row(
      children: [
        SizedBox(width: 240, child: label),
        const SizedBox(width: 12),
        Expanded(child: bar),
        const SizedBox(width: 12),
        SizedBox(width: 56, child: Align(alignment: Alignment.centerRight, child: value)),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double ratio;
  final Color color;

  const _ProgressBar({required this.ratio, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: ratio.clamp(0.0, 1.0),
        minHeight: 8,
        backgroundColor: const Color(0xFFE9EDF1),
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Schulungs-Karte
// ══════════════════════════════════════════════════════════════════════

class _TrainingCard extends StatefulWidget {
  final bool de;
  final String languageCode;
  final bool narrow;
  final _TrainingStats stats;

  /// Für Fahrer sichtbar? Steuert nur die Kachel in der Fahrer-Academy,
  /// nicht die Schulungslogik selbst.
  final bool visible;
  final ValueChanged<bool> onVisibilityChanged;

  const _TrainingCard({
    super.key,
    required this.de,
    required this.languageCode,
    required this.narrow,
    required this.stats,
    required this.visible,
    required this.onVisibilityChanged,
  });

  @override
  State<_TrainingCard> createState() => _TrainingCardState();
}

class _TrainingCardState extends State<_TrainingCard> {
  bool _expanded = false;
  bool _doneOpen = false;
  bool _missingOpen = true;
  String _query = '';
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool get _isAck =>
      widget.stats.training.kind == AcademyCompletionKind.acknowledgement;

  @override
  Widget build(BuildContext context) {
    final de = widget.de;
    final s = widget.stats;
    final t = s.training;

    return _Card(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: EdgeInsets.all(widget.narrow ? 14 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: t.accentBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(t.icon, size: 21, color: t.accent),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.title(de),
                              style: TextStyle(
                                fontSize: widget.narrow ? 15.5 : 17,
                                fontWeight: FontWeight.w900,
                                color: _kText,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              t.description(de),
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: _kMuted,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 180),
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: _kMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _metaChips(de),
                  const SizedBox(height: 12),
                  _counter(de),
                ],
              ),
            ),
          ),
          AcademyVisibilityToggle(
            de: de,
            narrow: widget.narrow,
            visible: widget.visible,
            onChanged: widget.onVisibilityChanged,
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _expanded
                ? Padding(
                    padding: EdgeInsets.fromLTRB(
                      widget.narrow ? 14 : 18,
                      0,
                      widget.narrow ? 14 : 18,
                      widget.narrow ? 14 : 18,
                    ),
                    child: _details(de),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  // ── Meta ──────────────────────────────────────────────────────────

  Widget _metaChips(bool de) {
    final t = widget.stats.training;
    final lang = widget.languageCode;
    final chips = <String>[];

    if (_isAck) {
      final all = t.ackItemsFor(lang);
      final required = t.requiredAckIds(lang).length;
      chips.add(de
          ? '${all.length} Anweisungen'
          : '${all.length} instructions');
      chips.add(de
          ? '$required für Fahrer verbindlich'
          : '$required binding for drivers');
      chips.add(de ? 'Lesebestätigung statt Test' : 'Read receipt, no test');
    } else {
      final chapters = t.chapterCount(lang);
      final slides = t.slideCount(lang);
      final questions = t.questionCount(lang);
      if (chapters > 0) {
        chips.add(de
            ? '$chapters Kapitel · $slides Seiten'
            : '$chapters chapters · $slides pages');
      }
      chips.add(de ? '$questions Fragen' : '$questions questions');
      if (t.examQuestionCount != null) {
        chips.add(de
            ? '${t.examQuestionCount} Fragen je Abschlusstest'
            : '${t.examQuestionCount} questions per final test');
      }
      if (t.passRatio != null) {
        final pct = (t.passRatio! * 100).round();
        chips.add(de ? 'Bestehensgrenze $pct %' : 'Pass mark $pct %');
      }
      chips.add(_validityLabel(de, t.validity));
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [for (final c in chips) _Pill(text: c)],
    );
  }

  String _validityLabel(bool de, Duration? validity) {
    if (validity == null) {
      return de ? 'Ohne Ablauf' : 'No expiry';
    }
    final months = (validity.inDays / 30).round();
    if (months >= 1) {
      return de ? 'Gültig $months Monate' : 'Valid for $months months';
    }
    return de
        ? 'Gültig ${validity.inDays} Tage'
        : 'Valid for ${validity.inDays} days';
  }

  // ── Zähler ────────────────────────────────────────────────────────

  Widget _counter(bool de) {
    final s = widget.stats;
    final t = s.training;

    final String headline;
    if (_isAck) {
      final required = t.requiredAckIds(widget.languageCode).length;
      headline = de
          ? '${s.doneCount} von ${s.totalCount} Fahrern haben alle $required '
              'bestätigt · ${s.openCount} offen'
          : '${s.doneCount} of ${s.totalCount} drivers confirmed all '
              '$required · ${s.openCount} open';
    } else {
      headline = de
          ? '${s.doneCount} von ${s.totalCount} aktiven Fahrern erledigt · '
              '${s.openCount} offen'
          : '${s.doneCount} of ${s.totalCount} active drivers completed · '
              '${s.openCount} open';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ProgressBar(ratio: s.ratio, color: t.accent),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              headline,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: _kSub,
              ),
            ),
            if (s.expiredCount > 0)
              _Chip(
                text: de
                    ? '${s.expiredCount} abgelaufen'
                    : '${s.expiredCount} expired',
                bg: _kRedBg,
                fg: _kRed,
              ),
          ],
        ),
      ],
    );
  }

  // ── Aufgeklappter Bereich ─────────────────────────────────────────

  Widget _details(bool de) {
    final s = widget.stats;
    final t = s.training;
    final lang = widget.languageCode;

    final doneRows = s.doneRows.where((r) => r.matches(_query)).toList();
    final openRows = s.openRows.where((r) => r.matches(_query)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1, color: _kBorder),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => _isAck
                      ? _InstructionListPage(
                          training: t,
                          languageCode: lang,
                          de: de,
                        )
                      : _QuestionListPage(
                          training: t,
                          languageCode: lang,
                          de: de,
                        ),
                ),
              ),
              icon: Icon(
                _isAck ? Icons.rule_rounded : Icons.quiz_outlined,
                size: 18,
              ),
              label: Text(
                _isAck
                    ? (de
                        ? 'Anweisungen ansehen (${t.ackItemsFor(lang).length})'
                        : 'View instructions (${t.ackItemsFor(lang).length})')
                    : (de
                        ? 'Fragen ansehen (${t.questionCount(lang)})'
                        : 'View questions (${t.questionCount(lang)})'),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: t.accent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            _Chip(
              text: de ? 'Nur lesend' : 'Read-only',
              bg: const Color(0xFFF3F4F6),
              fg: _kMuted,
            ),
          ],
        ),
        if (!_isAck) ...[
          const SizedBox(height: 8),
          Text(
            de
                ? 'Inhalte und Fragen sind fest in der App hinterlegt und '
                    'können hier nicht geändert werden.'
                : 'Contents and questions ship with the app and cannot be '
                    'edited here.',
            style: const TextStyle(fontSize: 12, color: _kMuted),
          ),
        ],
        const SizedBox(height: 14),
        TextField(
          controller: _search,
          onChanged: (value) => setState(() => _query = value.trim()),
          decoration: InputDecoration(
            isDense: true,
            hintText: de
                ? 'Fahrer suchen (Name, Transporter-ID, Personalnr.)'
                : 'Search drivers (name, transporter ID, employee no.)',
            hintStyle: const TextStyle(fontSize: 13, color: _kMuted),
            prefixIcon: const Icon(Icons.search_rounded, size: 18),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    onPressed: () {
                      _search.clear();
                      setState(() => _query = '');
                    },
                  ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _kBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _kBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: t.accent),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _DriverSection(
          de: de,
          title: de ? 'Erledigt' : 'Completed',
          count: s.doneCount,
          shown: doneRows,
          expanded: _doneOpen,
          onToggle: () => setState(() => _doneOpen = !_doneOpen),
          accent: _kGreen,
          emptyText: de ? 'Noch niemand.' : 'Nobody yet.',
          isAck: _isAck,
        ),
        const SizedBox(height: 8),
        _DriverSection(
          de: de,
          title: de ? 'Fehlt noch' : 'Still missing',
          count: s.openCount,
          shown: openRows,
          expanded: _missingOpen,
          onToggle: () => setState(() => _missingOpen = !_missingOpen),
          accent: _kOpen,
          emptyText: de ? 'Alle erledigt.' : 'Everyone is done.',
          isAck: _isAck,
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Fahrerlisten
// ══════════════════════════════════════════════════════════════════════

class _DriverSection extends StatelessWidget {
  final bool de;
  final String title;
  final int count;
  final List<_DriverRow> shown;
  final bool expanded;
  final VoidCallback onToggle;
  final Color accent;
  final String emptyText;
  final bool isAck;

  const _DriverSection({
    required this.de,
    required this.title,
    required this.count,
    required this.shown,
    required this.expanded,
    required this.onToggle,
    required this.accent,
    required this.emptyText,
    required this.isAck,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onToggle,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      '$title ($count)',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: _kText,
                      ),
                    ),
                  ),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: _kMuted,
                  ),
                ],
              ),
            ),
          ),
          if (expanded) ...[
            const Divider(height: 1, color: _kBorder),
            if (shown.isEmpty)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  count == 0
                      ? emptyText
                      : (de
                          ? 'Kein Treffer für die Suche.'
                          : 'No match for your search.'),
                  style: const TextStyle(fontSize: 12.5, color: _kMuted),
                ),
              )
            else
              // Höhe gedeckelt: bei 100 Fahrern soll die Karte nicht
              // endlos wachsen, sondern die Liste in sich scrollen.
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 360),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: shown.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: Color(0xFFEFF1F3)),
                  itemBuilder: (context, i) =>
                      _DriverTile(de: de, row: shown[i], isAck: isAck),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _DriverTile extends StatelessWidget {
  final bool de;
  final _DriverRow row;
  final bool isAck;

  const _DriverTile({required this.de, required this.row, required this.isAck});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = _badge();

    final meta = <String>[
      row.transporterId,
      if (row.employeeNumber.isNotEmpty)
        '${de ? 'Personalnr.' : 'Emp. no.'} ${row.employeeNumber}',
      if (row.passedAt != null)
        '${de ? 'am' : 'on'} ${_kDate.format(row.passedAt!)}',
      if (row.validUntil != null)
        '${de ? 'gültig bis' : 'valid until'} ${_kDate.format(row.validUntil!)}',
      if (row.scoreLabel != null) '${de ? 'Ergebnis' : 'Score'} ${row.scoreLabel}',
      if (isAck && row.ackTotal > 0)
        de
            ? '${row.ackDone} von ${row.ackTotal} bestätigt'
            : '${row.ackDone} of ${row.ackTotal} confirmed',
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: _kText,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  meta,
                  style: const TextStyle(fontSize: 11.5, color: _kMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (row.certificateUrl != null) ...[
            Tooltip(
              message: de ? 'Nachweis-PDF öffnen' : 'Open certificate PDF',
              child: InkWell(
                onTap: () {
                  final uri = Uri.tryParse(row.certificateUrl!);
                  if (uri != null) {
                    launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.picture_as_pdf_rounded,
                    size: 18,
                    color: _kMuted,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
          _Chip(text: label, bg: bg, fg: fg),
        ],
      ),
    );
  }

  (Color, Color, String) _badge() {
    switch (row.status) {
      case _DriverStatus.done:
        return (_kGreenBg, _kGreen, de ? 'Erledigt' : 'Completed');
      case _DriverStatus.dueSoon:
        return (_kAmberBg, _kAmber, de ? 'Läuft bald ab' : 'Due soon');
      case _DriverStatus.expired:
        return (_kRedBg, _kRed, de ? 'Abgelaufen' : 'Expired');
      case _DriverStatus.open:
        return (
          _kOpenBg,
          _kOpen,
          isAck
              ? (de ? 'Unvollständig' : 'Incomplete')
              : (de ? 'Offen' : 'Open')
        );
    }
  }
}

// ══════════════════════════════════════════════════════════════════════
// Unteransicht: Fragen (nur lesend)
// ══════════════════════════════════════════════════════════════════════

class _QuestionListPage extends StatelessWidget {
  final AcademyTraining training;
  final String languageCode;
  final bool de;

  const _QuestionListPage({
    required this.training,
    required this.languageCode,
    required this.de,
  });

  @override
  Widget build(BuildContext context) {
    final groups = training.questionGroupsFor(languageCode);
    final total = training.questionCount(languageCode);

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        foregroundColor: _kText,
        elevation: 0,
        title: Text(
          training.title(de),
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 700;
              final pad = narrow ? 12.0 : 20.0;
              var running = 0;
              return ListView(
                padding: EdgeInsets.fromLTRB(pad, 4, pad, pad + 24),
                children: [
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          de
                              ? '$total Fragen · nur zur Ansicht'
                              : '$total questions · view only',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: _kText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          de
                              ? 'Die richtige Antwort ist grün markiert. '
                                  'Fragen sind Teil der App und können nicht '
                                  'bearbeitet werden.'
                              : 'The correct answer is highlighted in green. '
                                  'Questions ship with the app and cannot be '
                                  'edited.',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: _kMuted,
                            height: 1.35,
                          ),
                        ),
                        if (training.examQuestionCount != null) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _Pill(
                                text: de
                                    ? '${training.examQuestionCount} Fragen je '
                                        'Abschlusstest'
                                    : '${training.examQuestionCount} questions '
                                        'per final test',
                              ),
                              _Pill(
                                text: de
                                    ? '${training.examPoolCount(languageCode)} '
                                        'Fragen im Test-Pool'
                                    : '${training.examPoolCount(languageCode)} '
                                        'questions in the test pool',
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  for (final group in groups) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8, top: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              group.title,
                              style: TextStyle(
                                fontSize: narrow ? 14.5 : 16,
                                fontWeight: FontWeight.w900,
                                color: _kText,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _Pill(
                            text: de
                                ? '${group.questions.length} Fragen'
                                : '${group.questions.length} questions',
                          ),
                        ],
                      ),
                    ),
                    for (final q in group.questions)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _QuestionCard(
                          de: de,
                          index: ++running,
                          question: q,
                          accent: training.accent,
                        ),
                      ),
                    const SizedBox(height: 6),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final bool de;
  final int index;
  final AcademyQuestionInfo question;
  final Color accent;

  const _QuestionCard({
    required this.de,
    required this.index,
    required this.question,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$index',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: _kSub,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  question.question,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _kText,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          if (question.mandatoryInExam || question.moduleOnly) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (question.mandatoryInExam)
                  _Chip(
                    text: de ? 'Pflichtfrage im Test' : 'Mandatory in test',
                    bg: _kAmberBg,
                    fg: _kAmber,
                  ),
                if (question.moduleOnly)
                  _Chip(
                    text: de ? 'Nur Modul-Quiz' : 'Module quiz only',
                    bg: const Color(0xFFF3F4F6),
                    fg: _kMuted,
                  ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          for (var i = 0; i < question.options.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _optionRow(i == question.correctIndex, question.options[i]),
            ),
          if (question.explanation != null) ...[
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(10),
                border: const Border(
                  left: BorderSide(color: _kGreen, width: 3),
                  top: BorderSide(color: _kBorder),
                  right: BorderSide(color: _kBorder),
                  bottom: BorderSide(color: _kBorder),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    de ? 'Erklärung' : 'Explanation',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: _kGreen,
                      letterSpacing: .3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    question.explanation!,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: _kSub,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _optionRow(bool correct, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: correct ? _kGreenBg : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: correct ? _kGreen : _kBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            correct
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 17,
            color: correct ? _kGreen : const Color(0xFFB6BDC6),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                height: 1.35,
                color: correct ? _kGreen : _kSub,
                fontWeight: correct ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Unteransicht: Betriebsanweisungen (nur lesend)
// ══════════════════════════════════════════════════════════════════════

class _InstructionListPage extends StatelessWidget {
  final AcademyTraining training;
  final String languageCode;
  final bool de;

  const _InstructionListPage({
    required this.training,
    required this.languageCode,
    required this.de,
  });

  @override
  Widget build(BuildContext context) {
    final items = training.ackItemsFor(languageCode);
    final required = items.where((i) => i.driverRelevant).length;

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        foregroundColor: _kText,
        elevation: 0,
        title: Text(
          training.title(de),
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final pad = constraints.maxWidth < 700 ? 12.0 : 20.0;
              return ListView(
                padding: EdgeInsets.fromLTRB(pad, 4, pad, pad + 24),
                children: [
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          de
                              ? '${items.length} Betriebsanweisungen · '
                                  '$required davon für Fahrer verbindlich'
                              : '${items.length} operating instructions · '
                                  '$required of them binding for drivers',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: _kText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          de
                              ? 'Betriebsanweisungen haben keinen Test — der '
                                  'Fahrer bestätigt jede einzeln als gelesen. '
                                  'Erst wenn alle verbindlichen bestätigt '
                                  'sind, gilt die Schulung als erledigt.'
                              : 'Operating instructions have no test — each '
                                  'driver confirms every single one as read. '
                                  'The training counts as completed only once '
                                  'all binding ones are confirmed.',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: _kMuted,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  for (var i = 0; i < items.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _Card(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${i + 1}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: _kSub,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    items[i].title,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: _kText,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    items[i].subtitle,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      color: _kMuted,
                                      height: 1.35,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _Chip(
                                    text: items[i].driverRelevant
                                        ? (de
                                            ? 'Für Fahrer verbindlich'
                                            : 'Binding for drivers')
                                        : (de
                                            ? 'Nur Disposition'
                                            : 'Dispatch only'),
                                    bg: items[i].driverRelevant
                                        ? _kGreenBg
                                        : const Color(0xFFF3F4F6),
                                    fg: items[i].driverRelevant
                                        ? _kGreen
                                        : _kMuted,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Kleinteile
// ══════════════════════════════════════════════════════════════════════

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _Card({required this.child, this.padding = const EdgeInsets.all(18)});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: child,
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  const _Pill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _kBorder),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: _kSub,
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;

  const _Chip({required this.text, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
          color: fg,
          letterSpacing: .2,
        ),
      ),
    );
  }
}
