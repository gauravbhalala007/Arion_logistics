import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html; // Web-App: localStorage für "Scorecard gesehen"

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/academy_visibility.dart';
import '../data/privacy_camera/privacy_camera_content.dart'
    show
        PrivacyCourseBundle,
        kPrivacyBindingLanguage,
        kPrivacyCameraDriverEnabled,
        kPrivacyCameraTestId;
import '../data/privacy_camera/privacy_camera_repository.dart'
    show PrivacyCameraAck;
import '../data/safety_training/operating_instructions.dart'
    show kOperatingInstructionsTestId;
import '../data/safety_training/privacy_data.dart' show kPrivacyTestId;
import '../data/safety_training/safety_training_data.dart'
    show kSafetyTrainingTestId;
import '../localization/app_localizations.dart';
import '../widgets/motion_helpers.dart';
import 'driver_driving_safety_page.dart' show kDrivingSafetyTrainingId;
import 'driver_green_book_training_page.dart' show kGreenBookTestId;
import 'driver_ride_along_page.dart' show kRideAlongTestId;
import 'driver_vehicle_check_page.dart';
import 'driver_vehicle_inspection_page.dart';

/// Driver-Whitelist als Fallback, falls der Admin das Add-On Flag noch
/// nicht explizit aktiviert hat. Alle anderen Driver sehen co:timer nur,
/// wenn ihr DSP-Admin `users/{adminUid}.addons.timeTracking == true`
/// gesetzt hat (über den co:timer Setup-Tab).
const Set<String> _kCotimerVisibleForDrivers = {
  'albert.dobra@arion-logistics.de',
  'test@arion-logistics.de',
};

/// Testgate für die geführte Foto-Fahrzeuginspektion
/// ([DriverVehicleCheckPage], Stufe 1). Nur diese Login-E-Mails bekommen
/// den neuen Wizard — alle anderen Fahrer sehen weiterhin den bisherigen
/// Ja/Nein-Sheet aus `driver_vehicle_inspection_page.dart`.
///
/// Muster bewusst identisch zu [_kCotimerVisibleForDrivers], damit das
/// Freischalten später nur eine Zeile ist.
/// Test-Gate des geführten Fahrzeug-Checks — inzwischen leer, weil der
/// Check samt Sichtprüfung für alle Fahrer freigegeben ist. Die Liste
/// bleibt als Schalter stehen: Wer hier Adressen einträgt UND
/// [kGuidedVehicleCheckForEveryone] auf `false` setzt, schaltet ihn
/// wieder auf einzelne Testfahrer zurück.
const Set<String> _kVehicleCheckVisibleForDrivers = <String>{};

/// `false` = nur die Adressen oben sehen den geführten Check.
const bool kGuidedVehicleCheckForEveryone = true;

/// `true`, wenn der eingeloggte Fahrer den neuen geführten Check sieht.
bool _guidedVehicleCheckEnabled() =>
    kGuidedVehicleCheckForEveryone ||
    _kVehicleCheckVisibleForDrivers.contains(
      (FirebaseAuth.instance.currentUser?.email ?? '').toLowerCase().trim(),
    );

const double _kTopCardHeight = 142;

class DriverHomePage extends StatelessWidget {
  final String dspUid;
  final String driverTransporterId;
  final int pendingTasksCount;
  final int unconfirmedRulesCount;
  final VoidCallback onOpenScorecard;
  final VoidCallback onOpenAcademy;
  final VoidCallback onOpenTasks;
  final VoidCallback onOpenRules;
  final VoidCallback onOpenShiftPlan;
  final VoidCallback onOpenAbsence;
  final VoidCallback onOpenIncidentReport;
  final VoidCallback onOpenDaRequests;
  final VoidCallback onOpenWaveplan;
  final VoidCallback onOpenComingSoon;
  final VoidCallback onOpenCotimer;

  /// Flexplan: Kachel nur für Fahrer mit planType == 'flex'.
  final bool showFlexPlan;
  final VoidCallback onOpenFlexPlan;

  const DriverHomePage({
    super.key,
    required this.dspUid,
    this.driverTransporterId = '',
    required this.pendingTasksCount,
    required this.unconfirmedRulesCount,
    required this.onOpenScorecard,
    required this.onOpenAcademy,
    required this.onOpenTasks,
    required this.onOpenRules,
    required this.onOpenShiftPlan,
    required this.onOpenAbsence,
    required this.onOpenIncidentReport,
    required this.onOpenDaRequests,
    required this.onOpenWaveplan,
    required this.onOpenComingSoon,
    required this.onOpenCotimer,
    this.showFlexPlan = false,
    required this.onOpenFlexPlan,
  });

  @override
  Widget build(BuildContext context) {
    return _DriverHomePageBody(
      dspUid: dspUid,
      driverTransporterId: driverTransporterId,
      pendingTasks: pendingTasksCount,
      unconfirmedRules: unconfirmedRulesCount,
      onOpenScorecard: onOpenScorecard,
      onOpenAcademy: onOpenAcademy,
      onOpenTasks: onOpenTasks,
      onOpenRules: onOpenRules,
      onOpenShiftPlan: onOpenShiftPlan,
      onOpenAbsence: onOpenAbsence,
      onOpenIncidentReport: onOpenIncidentReport,
      onOpenDaRequests: onOpenDaRequests,
      onOpenWaveplan: onOpenWaveplan,
      onOpenComingSoon: onOpenComingSoon,
      onOpenCotimer: onOpenCotimer,
      showFlexPlan: showFlexPlan,
      onOpenFlexPlan: onOpenFlexPlan,
    );
  }
}

class _DriverHomePageBody extends StatefulWidget {
  final String dspUid;
  final String driverTransporterId;
  final int pendingTasks;
  final int unconfirmedRules;
  final VoidCallback onOpenScorecard;
  final VoidCallback onOpenAcademy;
  final VoidCallback onOpenTasks;
  final VoidCallback onOpenRules;
  final VoidCallback onOpenShiftPlan;
  final VoidCallback onOpenAbsence;
  final VoidCallback onOpenIncidentReport;
  final VoidCallback onOpenDaRequests;
  final VoidCallback onOpenWaveplan;
  final VoidCallback onOpenComingSoon;
  final VoidCallback onOpenCotimer;
  final bool showFlexPlan;
  final VoidCallback onOpenFlexPlan;

  const _DriverHomePageBody({
    required this.dspUid,
    required this.driverTransporterId,
    required this.pendingTasks,
    required this.unconfirmedRules,
    required this.onOpenScorecard,
    required this.onOpenAcademy,
    required this.onOpenTasks,
    required this.onOpenRules,
    required this.onOpenShiftPlan,
    required this.onOpenAbsence,
    required this.onOpenIncidentReport,
    required this.onOpenDaRequests,
    required this.onOpenWaveplan,
    required this.onOpenComingSoon,
    required this.onOpenCotimer,
    this.showFlexPlan = false,
    required this.onOpenFlexPlan,
  });

  @override
  State<_DriverHomePageBody> createState() => _DriverHomePageBodyState();
}

class _DriverHomePageBodyState extends State<_DriverHomePageBody> {
  static const _settingsCollection = 'settings';
  static const _dispatcherPillDoc = 'dispatcher_pill';

  /// Ticket "Dispatcher Center": Die Karte zeigt primär die im Waveplan
  /// für HEUTE eingetragenen diensthabenden Dispatcher (Name + Schicht).
  /// Quelle ist das veröffentlichte Wellenplan-Dokument
  /// `users/{dspUid}/published_waveplans/{YYYY-MM-DD}_{program}` — das
  /// einzige Waveplan-Dokument, das die Firestore-Rules dem Fahrer
  /// freigeben (`waveplan_drafts` ist admin-only). Telefon-/WhatsApp-
  /// Kontakte kommen weiterhin aus `settings/dispatcher_pill` und werden
  /// über den Namen zugeordnet.
  static const _publishedWaveplansCollection = 'published_waveplans';

  /// Ticket: Karte zeigt automatisch den laut Schichtzeit aktiven
  /// Dispatcher (null = automatisch). Manuelles Blättern per Pfeilen
  /// setzt eine Auswahl, die bis zum nächsten App-Start gilt.
  int? _selectedDispatcher;
  Timer? _dispatcherClock;
  // Reaktives Flag: ist co:timer Add-On vom Admin freigeschaltet?
  // Wird per Stream auf users/{dspUid}.addons.timeTracking live gehalten.
  bool _cotimerAddonEnabled = false;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _addonSub;

  /// "NEW" auf der Scorecard-Karte nur, wenn seit dem letzten Öffnen eine
  /// neue Score-Woche erschienen ist (Marker in localStorage je TID).
  bool _newScorecard = false;
  String? _latestScoreKey;

  /// Rote Academy-Notification: Anzahl offener/abgelaufener Trainings.
  int _academyOpenCount = 0;

  static const List<String> _academyStatusTestIds = <String>[
    kGreenBookTestId,
    kRideAlongTestId,
    kSafetyTrainingTestId,
    kPrivacyTestId,
    kDrivingSafetyTrainingId,
    kOperatingInstructionsTestId,
  ];

  @override
  void initState() {
    super.initState();
    _loadScorecardBadge();
    _loadAcademyOpenCount();
    final dsp = widget.dspUid.trim();
    if (dsp.isNotEmpty) {
      _addonSub = FirebaseFirestore.instance
          .collection('users')
          .doc(dsp)
          .snapshots()
          .listen((snap) {
        final addons = (snap.data()?['addons'] as Map?) ?? const {};
        final enabled = addons['timeTracking'] == true;
        if (mounted && enabled != _cotimerAddonEnabled) {
          setState(() => _cotimerAddonEnabled = enabled);
        }
      });
    }
    // Minütlicher Tick, damit die automatische Dispatcher-Auswahl beim
    // Schichtwechsel umspringt, ohne dass der Fahrer neu laden muss.
    _dispatcherClock = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted && _selectedDispatcher == null) setState(() {});
    });
  }

  @override
  void dispose() {
    _addonSub?.cancel();
    _dispatcherClock?.cancel();
    super.dispose();
  }

  /// Neueste Score-Woche des Fahrers laden und mit dem lokal gemerkten
  /// "gesehen"-Stand vergleichen.
  Future<void> _loadScorecardBadge() async {
    final dsp = widget.dspUid.trim();
    final tid = widget.driverTransporterId.trim().toUpperCase();
    if (dsp.isEmpty || tid.isEmpty) return;
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(dsp)
          .collection('scores')
          .where('transporterId', isEqualTo: tid)
          .get();
      var bestYear = -1;
      var bestWeek = -1;
      for (final d in snap.docs) {
        final y = (d.data()['year'] as num?)?.toInt() ?? -1;
        final w = (d.data()['weekNumber'] as num?)?.toInt() ?? -1;
        if (y > bestYear || (y == bestYear && w > bestWeek)) {
          bestYear = y;
          bestWeek = w;
        }
      }
      if (bestYear < 0 || !mounted) return;
      final key = '$bestYear-W$bestWeek';
      final seen = html.window.localStorage['codriver_scorecard_seen_$tid'];
      setState(() {
        _latestScoreKey = key;
        _newScorecard = seen != key;
      });
    } catch (_) {
      // Ohne Daten lieber kein Badge als ein falsches.
    }
  }

  void _openScorecardTapped() {
    final tid = widget.driverTransporterId.trim().toUpperCase();
    final key = _latestScoreKey;
    if (key != null && tid.isNotEmpty) {
      html.window.localStorage['codriver_scorecard_seen_$tid'] = key;
    }
    if (_newScorecard) setState(() => _newScorecard = false);
    widget.onOpenScorecard();
  }

  /// Zählt Trainings ohne gültigen Abschluss (nie bestanden oder
  /// abgelaufen) — gleiche Ergebnis-Dokumente wie die Academy-Seite.
  Future<void> _loadAcademyOpenCount() async {
    final dsp = widget.dspUid.trim();
    // Roh belassen (kein toUpperCase): alle Schreibpfade der Trainings
    // (academy_test_results/{testId}/drivers/{tid}) verwenden die
    // unveränderte TID — sonst zeigt das Badge dauerhaft "offen".
    final tid = widget.driverTransporterId.trim();
    if (dsp.isEmpty || tid.isEmpty) return;
    try {
      final base = FirebaseFirestore.instance
          .collection('users')
          .doc(dsp)
          .collection('academy_test_results');

      // Vom Admin ausgeblendete Schulungen zählen NICHT als offen —
      // sonst zeigt die Kachel eine Aufgabe an, die der Fahrer gar
      // nicht öffnen kann.
      final visibility = await AcademyVisibility.load(dsp);
      final visibleIds = _academyStatusTestIds
          .where(visibility.isVisible)
          .toList(growable: false);

      final snaps = await Future.wait(
        visibleIds.map(
          (id) => base.doc(id).collection('drivers').doc(tid).get(),
        ),
      );
      final now = DateTime.now();
      var open = 0;
      for (final s in snaps) {
        final data = s.data();
        final passedAt = data?['passedAt'];
        if (passedAt is! Timestamp) {
          open++;
          continue;
        }
        final validUntil = data?['validUntil'];
        if (validUntil is Timestamp && validUntil.toDate().isBefore(now)) {
          open++;
        }
      }

      // Kameras im Fahrzeug – Datenschutz. Eigene Prüfung, weil dieses
      // Modul kein `passedAt` kennt, sondern eine Kenntnisnahme: offen
      // ist es, solange für die AKTUELLE Fassung kein Nachweis vorliegt.
      //
      // Solange das Modul für Fahrer nicht freigeschaltet ist, darf es
      // den roten Zähler NICHT hochtreiben — sonst zeigt die Kachel eine
      // offene Aufgabe an, die der Fahrer gar nicht öffnen kann.
      if (kPrivacyCameraDriverEnabled &&
          visibility.isVisible(kPrivacyCameraTestId)) {
        try {
          final bundle = await PrivacyCourseBundle.load(
            kPrivacyBindingLanguage,
          );
          final camSnap = await base
              .doc(kPrivacyCameraTestId)
              .collection('drivers')
              .doc(tid)
              .get();
          final camData = camSnap.data();
          if (camData == null || camData['outcome'] == null) {
            open++;
          } else if (!PrivacyCameraAck.fromMap(
            camData,
          ).matchesDocument(bundle.bindingDocument)) {
            open++;
          }
        } catch (_) {
          // Ohne Inhalte/Daten lieber nicht mitzählen als falsch zählen.
        }
      }

      if (mounted && open != _academyOpenCount) {
        setState(() => _academyOpenCount = open);
      }
    } catch (_) {
      // Ohne Daten lieber kein Badge als ein falsches.
    }
  }

  /// Index des Dispatchers, der laut Schichtzeit gerade im Dienst ist —
  /// auch über Mitternacht (z. B. 22:00–06:00). Ist niemand im Dienst,
  /// wird der mit dem nächsten Schichtbeginn gewählt.
  static int _autoDispatcherIndex(List<_DispatcherContact> list) {
    final now = DateTime.now();
    final nowMin = now.hour * 60 + now.minute;
    int? parseTime(String s) {
      final m = RegExp(r'(\d{1,2})[:.](\d{2})').firstMatch(s);
      if (m == null) return null;
      final h = int.parse(m.group(1)!);
      final min = int.parse(m.group(2)!);
      if (h > 23 || min > 59) return null;
      return h * 60 + min;
    }

    for (var i = 0; i < list.length; i++) {
      final s = parseTime(list[i].startTime);
      final e = parseTime(list[i].endTime);
      if (s == null || e == null) continue;
      final onDuty =
          s <= e ? (nowMin >= s && nowMin < e) : (nowMin >= s || nowMin < e);
      if (onDuty) return i;
    }
    var best = 0;
    var bestDelta = 1 << 30;
    for (var i = 0; i < list.length; i++) {
      final s = parseTime(list[i].startTime);
      if (s == null) continue;
      final delta = ((s - nowMin) % 1440 + 1440) % 1440;
      if (delta < bestDelta) {
        bestDelta = delta;
        best = i;
      }
    }
    return best;
  }

  /// Ist der Dispatcher an [index] gerade im Dienst?
  static bool _isOnDutyNow(List<_DispatcherContact> list, int index) {
    if (index < 0 || index >= list.length) return false;
    final now = DateTime.now();
    final nowMin = now.hour * 60 + now.minute;
    int? parseTime(String s) {
      final m = RegExp(r'(\d{1,2})[:.](\d{2})').firstMatch(s);
      if (m == null) return null;
      return int.parse(m.group(1)!) * 60 + int.parse(m.group(2)!);
    }

    final s = parseTime(list[index].startTime);
    final e = parseTime(list[index].endTime);
    if (s == null || e == null) return false;
    return s <= e
        ? (nowMin >= s && nowMin < e)
        : (nowMin >= s || nowMin < e);
  }

  /// Test-phase access gate for the Shift Plan feature. Drivers can
  /// peek at the new view only after entering the shared password
  /// 4002. Remove this dialog (and the inline onTap wrapper) once the
  /// feature is opened to everyone.
  Future<void> _promptShiftPlanPassword(BuildContext ctx) async {
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (dialogCtx) => const _ShiftPlanPasswordDialog(),
    );
    if (ok == true && mounted) {
      widget.onOpenShiftPlan();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final now = DateTime.now();
    final dateLabel =
        '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${(now.year % 100).toString().padLeft(2, '0')}';
    final dispatcherDocStream = widget.dspUid.trim().isEmpty
        ? null
        : FirebaseFirestore.instance
              .collection('users')
              .doc(widget.dspUid)
              .collection(_settingsCollection)
              .doc(_dispatcherPillDoc)
              .snapshots();
    // Alle heute veröffentlichten Waveplan-Dokumente (ein Doc je
    // Programm: sameday_a / nextday / sameday_c). Der Doc-Key beginnt
    // mit dem ISO-Datum, deshalb reicht ein Präfix-Range über die ID.
    final todayId =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    final waveplanTodayStream = widget.dspUid.trim().isEmpty
        ? null
        : FirebaseFirestore.instance
              .collection('users')
              .doc(widget.dspUid)
              .collection(_publishedWaveplansCollection)
              .where(FieldPath.documentId,
                  isGreaterThanOrEqualTo: todayId)
              .where(FieldPath.documentId, isLessThan: '$todayId\uf8ff')
              .snapshots();

    final cards = <_HomeCardData>[
      _HomeCardData(
        title: t.t('nav_scorecard'),
        subtitle: t.t('driver_home_scorecard_subtitle'),
        iconAsset: 'assets/icons/cards_star.svg',
        iconColor: const Color(0xFF27B26A),
        iconBackground: const Color(0xFFE4F5EC),
        // "NEW" nur bei ungesehener neuer Score-Woche; verschwindet nach
        // dem ersten Öffnen.
        badgeText: _newScorecard ? t.t('driver_home_new_badge') : null,
        badgeColor: const Color(0xFF24C06F),
        onTap: _openScorecardTapped,
      ),
      _HomeCardData(
        title: t.t('driver_home_tasks_title'),
        subtitle: t.t('driver_home_tasks_subtitle'),
        icon: Icons.task_alt_outlined,
        iconColor: const Color(0xFF2CB773),
        iconBackground: const Color(0xFFE4F5EC),
        badgeText: widget.pendingTasks > 0 ? '${widget.pendingTasks}' : null,
        badgeColor: const Color(0xFFFF4B4B),
        onTap: widget.onOpenTasks,
      ),
      // Page: DriverAcademyPage
      // Wiring: driver_home_shell.dart -> DriverView.academy
      _HomeCardData(
        title: t.t('driver_academy_title'),
        subtitle: t.t('driver_home_academy_subtitle'),
        icon: Icons.school_outlined,
        iconColor: const Color(0xFF3E82F7),
        iconBackground: const Color(0xFFE9F1FE),
        // Rote Notification: Anzahl nicht (mehr) gültig abgeschlossener
        // Trainings.
        badgeText: _academyOpenCount > 0 ? '$_academyOpenCount' : null,
        badgeColor: const Color(0xFFFF4B4B),
        onTap: widget.onOpenAcademy,
      ),
      _HomeCardData(
        title: t.t('driver_home_rules_title'),
        subtitle: t.t('driver_home_rules_subtitle'),
        icon: Icons.gavel_outlined,
        iconColor: const Color(0xFF3E82F7),
        iconBackground: const Color(0xFFE9F1FE),
        badgeText: widget.unconfirmedRules > 0
            ? '${widget.unconfirmedRules}'
            : null,
        badgeColor: const Color(0xFFFF4B4B),
        onTap: widget.onOpenRules,
      ),
      // Fahrzeuge + CoDriver AI sind auf Kundenwunsch ausgeblendet, bis
      // die Seiten wirklich existieren (statt "Kommt bald"-Platzhalter).
      // Page: DriverAbsencePage
      // Wiring: driver_home_shell.dart -> DriverView.absence
      _HomeCardData(
        title: t.t('driver_home_absence_title'),
        subtitle: t.t('driver_home_absence_subtitle'),
        icon: Icons.event_busy_outlined,
        iconColor: const Color(0xFFFF7A18),
        iconBackground: const Color(0xFFFFF0E4),
        borderColor: const Color(0xFFFF8A1F),
        onTap: widget.onOpenAbsence,
      ),
      // Page: DriverDaRequestsView (Anträge inkl. Gehaltsvorschuss)
      // Wiring: driver_home_shell.dart -> DriverView.daRequests
      _HomeCardData(
        title: 'DA Requests',
        subtitle: Localizations.localeOf(context).languageCode == 'de'
            ? 'Anträge & Vorschuss'
            : 'Requests & advance',
        icon: Icons.request_page_outlined,
        iconColor: const Color(0xFF1D7F5A),
        iconBackground: const Color(0xFFE4F5EC),
        borderColor: const Color(0xFF23BD6C),
        onTap: widget.onOpenDaRequests,
      ),
      // Page: DriverIncidentReportPage
      // Wiring: driver_home_shell.dart -> DriverView.incidentReport
      _HomeCardData(
        title: t.t('driver_home_incident_title'),
        subtitle: t.t('driver_home_incident_subtitle'),
        icon: Icons.warning_amber_rounded,
        iconColor: const Color(0xFFFF7A18),
        iconBackground: const Color(0xFFFFF0E4),
        borderColor: const Color(0xFFFF8A1F),
        onTap: widget.onOpenIncidentReport,
      ),
      // Fahrzeug-Check.
      //  • Testgate-Fahrer (_kVehicleCheckVisibleForDrivers): geführte
      //    Foto-Inspektion (DriverVehicleCheckPage) — 8 Fotos, Schäden,
      //    Kilometerstand; landet im Fleet Hub.
      //  • Alle anderen: unveränderter Ja/Nein-Sheet mit dem Hinweis, ein
      //    Walk-around-Video an den Dispatcher zu schicken.
      if (_guidedVehicleCheckEnabled())
        _HomeCardData(
          title: 'Fahrzeug-Check',
          subtitle: Localizations.localeOf(context).languageCode == 'de'
              ? 'Fotos + Sichtprüfung'
              : 'Photos + visual check',
          icon: Icons.photo_camera_outlined,
          iconColor: const Color(0xFF1D7F5A),
          iconBackground: const Color(0xFFE6F8F2),
          badgeText: 'BETA',
          badgeColor: const Color(0xFFB7791F),
          onTap: () => openDriverVehicleCheck(
            context,
            dspUid: widget.dspUid,
            driverTransporterId: widget.driverTransporterId,
          ),
        )
      else
        _HomeCardData(
          title: 'Fahrzeug-Check',
          subtitle: 'Kurz vor Schichtstart bestätigen',
          icon: Icons.directions_car_rounded,
          iconColor: const Color(0xFF1D7F5A),
          iconBackground: const Color(0xFFE6F8F2),
          onTap: () => openDriverVehicleInspectionSheet(
            context,
            dspUid: widget.dspUid,
            driverDocId: widget.driverTransporterId.toUpperCase(),
          ),
        ),
      // Page: DriverWaveplanView
      // Wiring: driver_home_shell.dart -> DriverView.waveplan
      _HomeCardData(
        title: 'Waveplan',
        subtitle: 'Deine Route, Spur & Schicht',
        icon: Icons.waves_rounded,
        iconColor: const Color(0xFF00B287),
        iconBackground: const Color(0xFFE6F8F2),
        onTap: widget.onOpenWaveplan,
      ),
      // Page: DriverFlexPlanPage — nur für Flex-Plan-Fahrer (Minijobber),
      // Gating über users/{dsp}/drivers/{TID}.planType == 'flex'.
      // Wiring: driver_home_shell.dart -> DriverView.flexPlan
      if (widget.showFlexPlan)
        _HomeCardData(
          title: 'Flex Plan',
          subtitle: Localizations.localeOf(context).languageCode == 'de'
              ? 'Schichten für den Monat wählen'
              : 'Pick your shifts for the month',
          icon: Icons.event_repeat_rounded,
          iconColor: const Color(0xFF00B287),
          iconBackground: const Color(0xFFE6F8F2),
          onTap: widget.onOpenFlexPlan,
        ),
      // Page: DriverCotimerClockPage  (Add-On-Modul)
      // Wiring: driver_home_shell.dart -> DriverView.cotimer
      // Sichtbar wenn:
      //   • Admin hat `addons.timeTracking == true` gesetzt (UI im
      //     co:timer Setup-Tab), ODER
      //   • Driver-Email auf Test-Whitelist (legacy fallback).
      if (_cotimerAddonEnabled ||
          _kCotimerVisibleForDrivers.contains(
            (FirebaseAuth.instance.currentUser?.email ?? '')
                .toLowerCase()
                .trim(),
          ))
        _HomeCardData(
          title: 'co:timer',
          subtitle: 'Stempel-Uhr · Beta',
          icon: Icons.timer_outlined,
          iconColor: const Color(0xFF006047),
          iconBackground: const Color(0xFFE6F8F2),
          badgeText: 'BETA',
          badgeColor: const Color(0xFFB7791F),
          onTap: widget.onOpenCotimer,
        ),
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: waveplanTodayStream,
                  builder: (context, waveSnap) {
                    // Diensthabende Dispatcher von heute laut Waveplan.
                    // Fehler/kein Doc => leer, dann greift der Fallback.
                    final dutyToday = _waveplanDispatchersToday(waveSnap.data);
                    return StreamBuilder<
                        DocumentSnapshot<Map<String, dynamic>>>(
                      stream: dispatcherDocStream,
                      builder: (context, snap) {
                        final contacts = _parseDispatchers(snap.data?.data());
                        final dispatchers =
                            _mergeDispatchers(dutyToday, contacts);
                        if (dispatchers.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        // null = automatisch: Dispatcher nach Uhrzeit wählen.
                        final manual = _selectedDispatcher;
                        final safeIndex =
                            (manual != null && manual < dispatchers.length)
                                ? manual
                                : _autoDispatcherIndex(dispatchers);
                        return _DispatcherCard(
                          dateLabel: dateLabel,
                          selectedIndex: safeIndex,
                          dispatchers: dispatchers,
                          selectedOnDuty: _isOnDutyNow(dispatchers, safeIndex),
                          onSelect: (idx) {
                            setState(() => _selectedDispatcher = idx);
                          },
                          onCallTap: () =>
                              _callNumber(dispatchers[safeIndex].phone),
                          onWhatsAppTap: () =>
                              _openWhatsApp(dispatchers[safeIndex]),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                // Page: DriverShiftPlanView
                // Test phase: tap shows a 4-digit password gate. On
                // success the shift plan opens via onOpenShiftPlan.
                // Remove the gate once the feature ships to all DSPs.
                child: _TopFeatureCard(
                  title: t.t('driver_home_shift_plan_title'),
                  subtitle: t.t('driver_home_shift_plan_subtitle'),
                  icon: Icons.event_note_rounded,
                  badgeText: t.t('coming_soon'),
                  onTap: () => _promptShiftPlanPassword(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - 10) / 2;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (var i = 0; i < cards.length; i++)
                    SizedBox(
                      width: itemWidth,
                      // Stagger Fade-In beim Mount (Emil-Pattern):
                      // 30 ms je Item, kumulativ max ~300 ms.
                      child: StaggeredFadeIn(
                        delay: Duration(milliseconds: 30 * i),
                        slideOffsetY: 0.06,
                        child: _HomeFeatureCard(data: cards[i]),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 110),
        ],
      ),
    );
  }

  /// Diensthabende Dispatcher aus den heute veröffentlichten Waveplan-
  /// Dokumenten. Der Admin pflegt sie tagesweit (`dispatchers`: name,
  /// start, end) und spiegelt sie in alle Programme des Tages — hier
  /// werden alle Programme zusammengeführt und über den Namen
  /// dedupliziert. Einträge mit Schichtzeit gewinnen gegen solche ohne.
  List<_WaveplanDuty> _waveplanDispatchersToday(
    QuerySnapshot<Map<String, dynamic>>? snap,
  ) {
    if (snap == null) return const <_WaveplanDuty>[];
    final byName = <String, _WaveplanDuty>{};
    final order = <String>[];
    for (final doc in snap.docs) {
      final raw = doc.data()['dispatchers'];
      if (raw is! List) continue;
      for (final row in raw) {
        String name;
        var start = '';
        var end = '';
        if (row is Map) {
          final map = row.cast<String, dynamic>();
          name = _stringOf(map['name']);
          start = _stringOf(map['start']);
          end = _stringOf(map['end']);
        } else if (row is String) {
          // Legacy: reine Namensliste ohne Schichtzeit.
          name = row.trim();
        } else {
          continue;
        }
        if (name.isEmpty) continue;
        final key = _nameKey(name);
        final entry = _WaveplanDuty(name: name, start: start, end: end);
        final existing = byName[key];
        if (existing == null) {
          byName[key] = entry;
          order.add(key);
        } else if (!existing.hasShift && entry.hasShift) {
          byName[key] = entry;
        }
      }
    }
    return [for (final k in order) byName[k]!];
  }

  /// Verknüpft die heutigen Waveplan-Dienste mit den Kontaktdaten aus
  /// `settings/dispatcher_pill` (Zuordnung über den Namen).
  ///
  /// Ohne Waveplan-Angabe für heute fällt die Karte auf die Pill-Liste
  /// zurück; deren Schichtfelder sind Freitext und werden nur
  /// übernommen, wenn sie tatsächlich wie eine Uhrzeit aussehen — sonst
  /// zeigt die Karte einen neutralen Hinweis statt einer Behauptung
  /// wie „Free".
  List<_DispatcherContact> _mergeDispatchers(
    List<_WaveplanDuty> duty,
    List<_DispatcherContact> contacts,
  ) {
    if (duty.isEmpty) {
      return [
        for (final c in contacts)
          _DispatcherContact(
            name: c.name,
            startTime: _looksLikeTime(c.startTime) ? c.startTime : '',
            endTime: _looksLikeTime(c.endTime) ? c.endTime : '',
            phone: c.phone,
            whatsapp: c.whatsapp,
            whatsappLink: c.whatsappLink,
          ),
      ];
    }

    final contactByName = <String, _DispatcherContact>{};
    for (final c in contacts) {
      contactByName.putIfAbsent(_nameKey(c.name), () => c);
      // Zusätzlich der erste Namensteil, damit „Israfil K." aus dem
      // Waveplan noch den Kontakt „Israfil" findet.
      final first = _nameKey(c.name).split(' ').first;
      if (first.isNotEmpty) contactByName.putIfAbsent(first, () => c);
    }

    return [
      for (final d in duty)
        () {
          final key = _nameKey(d.name);
          final c = contactByName[key] ??
              contactByName[key.split(' ').first] ??
              const _DispatcherContact(name: '', startTime: '', endTime: '');
          return _DispatcherContact(
            name: d.name,
            startTime: d.start,
            endTime: d.end,
            phone: c.phone,
            whatsapp: c.whatsapp,
            whatsappLink: c.whatsappLink,
          );
        }(),
    ];
  }

  /// Normalisierter Vergleichsschlüssel für Dispatcher-Namen.
  static String _nameKey(String raw) =>
      raw.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  /// Sieht der Wert wie eine Uhrzeit aus (z. B. „06:00", „6.30")?
  static bool _looksLikeTime(String raw) =>
      RegExp(r'\d{1,2}[:.]\d{2}').hasMatch(raw.trim());

  List<_DispatcherContact> _parseDispatchers(Map<String, dynamic>? data) {
    final raw = data?['dispatchers'];
    if (raw is! List) return const <_DispatcherContact>[];

    final out = <_DispatcherContact>[];
    for (final row in raw) {
      if (row is! Map) continue;
      final map = row.cast<String, dynamic>();
      if (map['isActive'] == false) continue;
      final name = _firstNonEmpty([
        _stringOf(map['name']),
        _stringOf(map['label']),
        _stringOf(map['title']),
      ]);
      if (name.isEmpty) continue;

      out.add(
        _DispatcherContact(
          name: name,
          startTime: _firstNonEmpty([
            _stringOf(map['startTime']),
            _stringOf(map['shiftStart']),
          ]),
          endTime: _firstNonEmpty([
            _stringOf(map['endTime']),
            _stringOf(map['shiftEnd']),
          ]),
          phone: _stringOf(map['phone']),
          whatsapp: _firstNonEmpty([
            _stringOf(map['whatsapp']),
            _stringOf(map['whatsApp']),
            _stringOf(map['wa']),
          ]),
          whatsappLink: _firstNonEmpty([
            _stringOf(map['whatsappLink']),
            _stringOf(map['whatsappUrl']),
            _stringOf(map['waLink']),
          ]),
        ),
      );
    }

    return out;
  }

  Future<void> _callNumber(String rawNumber) async {
    final number = rawNumber.trim();
    if (number.isEmpty) {
      _showSnack(
        _isGerman
            ? 'Für diesen Dispatcher ist keine Telefonnummer hinterlegt.'
            : 'No phone number configured for this dispatcher.',
      );
      return;
    }
    final uri = Uri(scheme: 'tel', path: number);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!mounted) return;
    if (!opened) {
      _showSnack('Could not open dialer.');
    }
  }

  Future<void> _openWhatsApp(_DispatcherContact contact) async {
    final linkRaw = contact.whatsappLink.trim();
    Uri? uri;

    if (linkRaw.isNotEmpty) {
      final parsed = Uri.tryParse(linkRaw);
      if (parsed != null) {
        if (parsed.hasScheme) {
          uri = parsed;
        } else {
          uri = Uri.tryParse('https://$linkRaw');
        }
      }
    }

    if (uri == null) {
      final rawNumber = contact.whatsappOrPhone;
      final looksLikeLink =
          rawNumber.contains('://') ||
          rawNumber.startsWith('wa.me/') ||
          rawNumber.startsWith('www.');
      if (looksLikeLink) {
        final parsed = Uri.tryParse(rawNumber);
        if (parsed != null) {
          uri = parsed.hasScheme ? parsed : Uri.tryParse('https://$rawNumber');
        }
      }
    }

    if (uri == null) {
      final rawNumber = contact.whatsappOrPhone;
      final number = rawNumber.replaceAll(RegExp(r'[^0-9]'), '');
      if (number.isEmpty) {
        _showSnack(
          _isGerman
              ? 'Für diesen Dispatcher ist keine WhatsApp-Nummer hinterlegt.'
              : 'No WhatsApp link or number configured for this dispatcher.',
        );
        return;
      }
      uri = Uri.parse('https://wa.me/$number');
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!mounted) return;
    if (!opened) {
      _showSnack('Could not open WhatsApp.');
    }
  }

  /// Deutsch aktiv? (Bestandsmuster dieser Datei für Kurztexte, die
  /// nicht über AppLocalizations laufen.)
  bool get _isGerman =>
      Localizations.localeOf(context).languageCode == 'de';

  void _showSnack(String message) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(SnackBar(content: Text(message)));
  }

  static String _stringOf(dynamic value) => value?.toString().trim() ?? '';

  static String _firstNonEmpty(List<String> values) {
    for (final raw in values) {
      final v = raw.trim();
      if (v.isNotEmpty) return v;
    }
    return '';
  }
}

class _DispatcherCard extends StatelessWidget {
  final String dateLabel;
  final int selectedIndex;
  final List<_DispatcherContact> dispatchers;
  final bool selectedOnDuty;
  final ValueChanged<int> onSelect;
  final VoidCallback onCallTap;
  final VoidCallback onWhatsAppTap;

  const _DispatcherCard({
    required this.dateLabel,
    required this.selectedIndex,
    required this.dispatchers,
    required this.selectedOnDuty,
    required this.onSelect,
    required this.onCallTap,
    required this.onWhatsAppTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    if (dispatchers.isEmpty) {
      return const SizedBox.shrink();
    }
    final safeIndex = selectedIndex.clamp(0, dispatchers.length - 1);
    final selected = dispatchers[safeIndex];
    final selectedName = selected.name;
    final many = dispatchers.length > 1;

    return Container(
      height: _kTopCardHeight,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF23BD6C), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Ticket: kein Namens-Tab-Band mehr (brach bei >6 Dispatchern).
          // Der aktive Dispatcher wird automatisch nach Uhrzeit gewählt;
          // Blättern über die Pfeile bleibt möglich.
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF4F7F6),
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                if (many)
                  InkWell(
                    onTap: () => onSelect(
                      (safeIndex - 1 + dispatchers.length) %
                          dispatchers.length,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      child: Icon(Icons.chevron_left_rounded,
                          size: 20, color: Color(0xFF667085)),
                    ),
                  )
                else
                  const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      many
                          ? '${selectedName.toUpperCase()} · '
                              '${safeIndex + 1}/${dispatchers.length}'
                          : selectedName.toUpperCase(),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A9E56),
                      ),
                    ),
                  ),
                ),
                if (many)
                  InkWell(
                    onTap: () => onSelect(
                      (safeIndex + 1) % dispatchers.length,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      child: Icon(Icons.chevron_right_rounded,
                          size: 20, color: Color(0xFF667085)),
                    ),
                  )
                else
                  const SizedBox(width: 10),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.t('driver_home_dispatcher'),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Text(
                              selectedName,
                              style: const TextStyle(
                                fontSize: 30 / 2,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                // Grün nur, wenn laut Schichtzeit gerade
                                // im Dienst — sonst grau.
                                color: selectedOnDuty
                                    ? const Color(0xFF22C55E)
                                    : const Color(0xFFCBD5E1),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        // Schichtzeit aus dem Waveplan. Ist für heute
                        // nichts hinterlegt, steht hier ein neutraler
                        // Hinweis statt einer erfundenen Angabe.
                        Text(
                          selected.hasShiftInfo
                              ? selected.timeRange
                              : t.t('driver_home_dispatcher_no_shift_today'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: selected.hasShiftInfo ? 28 / 2 : 12,
                            fontWeight: selected.hasShiftInfo
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: selected.hasShiftInfo
                                ? const Color(0xFF1F2937)
                                : const Color(0xFF6B7280),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          dateLabel,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _RoundActionIcon(
                        icon: Icons.call,
                        bg: const Color(0xFF38B888),
                        onTap: onCallTap,
                      ),
                      SizedBox(height: 6),
                      _RoundActionIcon(
                        iconAsset: 'assets/icons/whatsapp.svg',
                        bg: const Color(0xFF24C269),
                        onTap: onWhatsAppTap,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopFeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final String? badgeText;

  const _TopFeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    final badge = badgeText?.trim();
    final hasBadge = badge != null && badge.isNotEmpty;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: _kTopCardHeight,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: isEnabled ? Colors.white : const Color(0xFFF8FAFB),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFDFE4E7)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isEnabled ? 0.06 : 0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Positioned.fill: sonst legt der Stack den Inhalt oben links
              // ab und die Karte wirkt schief statt zentriert.
              Positioned.fill(
                child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isEnabled
                            ? const Color(0xFFE9F5F1)
                            : const Color(0xFFEEF2F4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: isEnabled
                            ? const Color(0xFF38B888)
                            : const Color(0xFF9AA4B2),
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 29 / 2,
                        fontWeight: FontWeight.w800,
                        color: isEnabled
                            ? const Color(0xFF1F2937)
                            : const Color(0xFF4B5563),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: isEnabled
                            ? const Color(0xFF6B7280)
                            : const Color(0xFF98A2B3),
                      ),
                    ),
                  ],
                ),
                ),
              ),
              if (hasBadge)
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2F6),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0xFFD7DEE6)),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF667085),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeCardData {
  final String title;
  final String subtitle;
  final IconData? icon;
  final String? iconAsset;
  final Color iconColor;
  final Color iconBackground;
  final Color? borderColor;
  final Gradient? borderGradient;
  final String? badgeText;
  final Color badgeColor;
  final VoidCallback? onTap;

  const _HomeCardData({
    required this.title,
    required this.subtitle,
    this.icon,
    this.iconAsset,
    required this.iconColor,
    required this.iconBackground,
    required this.onTap,
    this.borderColor,
    // Bleibt für künftige Karten (z.B. CoDriver AI) erhalten.
    // ignore: unused_element_parameter
    this.borderGradient,
    this.badgeText,
    this.badgeColor = const Color(0xFFFF4B4B),
  }) : assert(icon != null || iconAsset != null);
}

class _HomeFeatureCard extends StatelessWidget {
  final _HomeCardData data;

  const _HomeFeatureCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final badge = data.badgeText?.trim();
    final hasBadge = badge != null && badge.isNotEmpty;
    final usesPillBadge = hasBadge;
    final isEnabled = data.onTap != null;

    final inner = Container(
      height: 96, // 8 px Rhythmus, +4 px vs alt für luftigeren Look
      decoration: BoxDecoration(
        color: isEnabled ? Colors.white : const Color(0xFFFAFBFC),
        borderRadius: BorderRadius.circular(16),
        border: data.borderGradient == null
            ? Border.all(
                color: const Color(0xFFE5E5EA), // hairline neutral
                width: 0.6,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isEnabled ? 0.04 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isEnabled
                  ? data.iconBackground
                  : const Color(0xFFEEF2F4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: data.iconAsset != null
                ? Center(
                    child: SvgPicture.asset(
                      data.iconAsset!,
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        isEnabled
                            ? data.iconColor
                            : const Color(0xFF9CA3AF),
                        BlendMode.srcIn,
                      ),
                    ),
                  )
                : Icon(
                    data.icon,
                    size: 20,
                    color: isEnabled
                        ? data.iconColor
                        : const Color(0xFF9CA3AF),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: isEnabled
                        ? const Color(0xFF1C1C1E)
                        : const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: isEnabled
                        ? const Color(0xFF6B7280)
                        : const Color(0xFF9CA3AF),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final cardBody = data.borderGradient == null
        ? inner
        : Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: data.borderGradient,
            ),
            padding: const EdgeInsets.all(1.4),
            child: inner,
          );

    return PressFeedback(
      onTap: data.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Stack(
          clipBehavior: Clip.none,
          children: [
            cardBody,
            if (hasBadge)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  constraints: BoxConstraints(
                    minWidth: usesPillBadge ? 36 : 24,
                    minHeight: 24,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: usesPillBadge ? 8 : 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isEnabled
                        ? data.badgeColor
                        : const Color(0xFFEEF2F6),
                    borderRadius: BorderRadius.circular(999),
                    border: isEnabled
                        ? null
                        : Border.all(color: const Color(0xFFD7DEE6)),
                  ),
                  child: Text(
                    badge,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isEnabled
                          ? Colors.white
                          : const Color(0xFF667085),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        ),
    );
  }
}

class _RoundActionIcon extends StatelessWidget {
  final IconData? icon;
  final String? iconAsset;
  final Color bg;
  final VoidCallback? onTap;

  const _RoundActionIcon({
    this.icon,
    this.iconAsset,
    required this.bg,
    this.onTap,
  }) : assert(icon != null || iconAsset != null);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: iconAsset != null
              ? Center(
                  child: SvgPicture.asset(
                    iconAsset!,
                    width: 18,
                    height: 18,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                )
              : Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

/// Ein im Waveplan für heute eingetragener Dispatcher-Dienst.
class _WaveplanDuty {
  final String name;
  final String start;
  final String end;

  const _WaveplanDuty({
    required this.name,
    required this.start,
    required this.end,
  });

  bool get hasShift => start.trim().isNotEmpty || end.trim().isNotEmpty;
}

class _DispatcherContact {
  final String name;
  final String startTime;
  final String endTime;
  final String phone;
  final String whatsapp;
  final String whatsappLink;

  const _DispatcherContact({
    required this.name,
    required this.startTime,
    required this.endTime,
    this.phone = '',
    this.whatsapp = '',
    this.whatsappLink = '',
  });

  /// Ist für diesen Dispatcher überhaupt eine Schichtzeit hinterlegt?
  bool get hasShiftInfo =>
      startTime.trim().isNotEmpty || endTime.trim().isNotEmpty;

  String get timeRange {
    final s = startTime.trim();
    final e = endTime.trim();
    if (s.isEmpty && e.isEmpty) return '--';
    if (s.isEmpty) return e;
    if (e.isEmpty) return s;
    return '$s - $e';
  }

  String get whatsappOrPhone {
    final wa = whatsapp.trim();
    if (wa.isNotEmpty) return wa;
    return phone;
  }
}

/// Test-phase password gate for the Shift Plan tile. Returns `true`
/// on correct passcode, `false` (or null) on cancel/wrong code. The
/// shared passcode is "4002"; remove this widget when the feature
/// rolls out to all drivers.
class _ShiftPlanPasswordDialog extends StatefulWidget {
  const _ShiftPlanPasswordDialog();

  @override
  State<_ShiftPlanPasswordDialog> createState() =>
      _ShiftPlanPasswordDialogState();
}

class _ShiftPlanPasswordDialogState
    extends State<_ShiftPlanPasswordDialog> {
  static const _passcode = '4002';
  final TextEditingController _ctrl = TextEditingController();
  final FocusNode _focus = FocusNode();
  bool _wrong = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit() {
    if (_ctrl.text.trim() == _passcode) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _wrong = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7F5EE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      color: Color(0xFF1D7F5A),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Shift plan · Beta',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Enter the 4-digit test passcode.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _ctrl,
                focusNode: _focus,
                keyboardType: TextInputType.number,
                obscureText: true,
                autocorrect: false,
                enableSuggestions: false,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 8,
                  color: Color(0xFF111827),
                ),
                onChanged: (_) {
                  if (_wrong) setState(() => _wrong = false);
                },
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '••••',
                  hintStyle: const TextStyle(
                    color: Color(0xFFD1D5DB),
                    letterSpacing: 8,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: _wrong
                          ? const Color(0xFFB91C1C)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: _wrong
                          ? const Color(0xFFB91C1C)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: _wrong
                          ? const Color(0xFFB91C1C)
                          : const Color(0xFF1D7F5A),
                      width: 1.6,
                    ),
                  ),
                ),
              ),
              if (_wrong) ...[
                const SizedBox(height: 6),
                const Text(
                  'Wrong passcode. Ask your dispatcher.',
                  style: TextStyle(
                    color: Color(0xFFB91C1C),
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () =>
                          Navigator.of(context).pop(false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF1D7F5A),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Unlock',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
