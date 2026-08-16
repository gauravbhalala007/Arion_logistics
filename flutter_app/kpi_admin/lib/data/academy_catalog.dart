// lib/data/academy_catalog.dart
//
// Zentrale Registry der fest eingebauten DA-Academy-Schulungen.
//
// Die Schulungen sind KEINE Firestore-Inhalte mehr, sondern liegen als
// Code in `lib/data/safety_training/**` (Kapitel, Fragen, Anweisungen).
// Diese Datei beschreibt sie einmal zentral, damit Admin-Übersicht,
// Zähler und Fragen-Ansicht aus derselben Quelle lesen.
//
// EINE NEUE SCHULUNG ERGÄNZEN
// ---------------------------
// 1. Inhalte/Fragen unter `lib/data/safety_training/` (bzw. einem eigenen
//    Verzeichnis) anlegen — wie bei den bestehenden Schulungen.
// 2. Hier UNTEN in [kAcademyTrainings] genau EINEN weiteren
//    [AcademyTraining]-Eintrag ergänzen. Mehr ist nicht nötig: die
//    Admin-Seite (`Screens/admin_academy_page.dart`) rendert Karte,
//    Fortschritt, Fahrerlisten und Fragen-Ansicht automatisch daraus.
//
// Beispiel für die parallel entstehende Datenschutzinformation
// (`lib/data/privacy_notice/privacy_notice_content.dart`, testId
// 'privacy_notice'): Sie kennt keinen Test, sondern eine Kenntnisnahme —
// also `kind: AcademyCompletionKind.test` mit `validity: null`, sobald sie
// `passedAt` schreibt, bzw. `AcademyCompletionKind.acknowledgement` mit
// `ackItems`, falls sie je Abschnitt bestätigt wird. Der Eintrag selbst ist
// ein Listenelement, sonst ändert sich nichts.
//
// Ergebnisse liegen für ALLE Schulungen unter
//   users/{dspUid}/academy_test_results/{testId}/drivers/{transporterId}
// Geschrieben werden je nach Schulung `passedAt`, `validUntil`, `score`,
// `total`, `attempts` bzw. bei den Betriebsanweisungen `acknowledged`
// (Map instructionId -> {at, version}). Nur diese Felder werden hier
// gelesen — geschrieben wird von der Admin-Seite nichts.

import 'package:flutter/material.dart';

// Die IDs/Grenzwerte dreier Schulungen liegen historisch in den jeweiligen
// Fahrer-Screens. Bewusst dort belassen (sie sind dort auch die Quelle für
// die Schreibvorgänge) und hier nur importiert, statt sie zu duplizieren —
// eine Kopie liefe unweigerlich auseinander.
import '../Screens/driver_driving_safety_page.dart'
    show kDrivingPassThreshold, kDrivingSafetyTrainingId;
import '../Screens/driver_green_book_training_page.dart'
    show kGreenBookPassThreshold, kGreenBookTestId;
import '../Screens/driver_operating_instructions_page.dart'
    show operatingInstructionsFor;
import '../Screens/driver_ride_along_page.dart'
    show kRideAlongPassThreshold, kRideAlongTestId;
import 'safety_training/driving_safety_data.dart';
import 'safety_training/driving_safety_quiz_de.dart' show DrivingQuestion;
import 'safety_training/green_book_data.dart';
import 'safety_training/operating_instructions.dart';
import 'safety_training/privacy_data.dart';
import 'safety_training/ride_along_data.dart';
import 'safety_training/safety_blocks.dart';
import 'safety_training/safety_training_data.dart';

/// Wie ein Fahrer eine Schulung abschließt.
enum AcademyCompletionKind {
  /// Abschlusstest — Ergebnisdokument mit `passedAt` (+ ggf. `validUntil`).
  test,

  /// Lesebestätigungen — Ergebnisdokument mit `acknowledged`-Map.
  acknowledgement,
}

/// Eine Prüfungsfrage, rein lesend für die Admin-Ansicht aufbereitet.
@immutable
class AcademyQuestionInfo {
  final String question;
  final List<String> options;

  /// Index der richtigen Antwort in [options].
  final int correctIndex;

  /// Begründung der richtigen Antwort — nicht jede Schulung liefert eine.
  final String? explanation;

  /// Frage ist in JEDEM Abschlusstest enthalten (nur Fahrsicherheit).
  final bool mandatoryInExam;

  /// Frage kommt nur im Modul-Quiz vor, nicht im Abschlusstest.
  final bool moduleOnly;

  const AcademyQuestionInfo({
    required this.question,
    required this.options,
    required this.correctIndex,
    this.explanation,
    this.mandatoryInExam = false,
    this.moduleOnly = false,
  });
}

/// Fragen eines Kapitels/Moduls.
@immutable
class AcademyQuestionGroup {
  final String id;
  final String title;
  final List<AcademyQuestionInfo> questions;
  const AcademyQuestionGroup({
    required this.id,
    required this.title,
    required this.questions,
  });
}

/// Ein Kapitel einer Schulung (für die Meta-Zeile der Karte).
@immutable
class AcademyChapterInfo {
  final String id;
  final String title;
  final String summary;
  final int slideCount;
  const AcademyChapterInfo({
    required this.id,
    required this.title,
    required this.summary,
    required this.slideCount,
  });
}

/// Eine einzeln zu bestätigende Betriebsanweisung.
@immutable
class AcademyAckItem {
  final String id;
  final String title;
  final String subtitle;

  /// `false` = betrifft nur die Disposition und zählt bei Fahrern nicht
  /// als offene Bestätigung (siehe [kDispatcherOnlyInstructionIds]).
  final bool driverRelevant;

  const AcademyAckItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.driverRelevant,
  });
}

/// Eine fest eingebaute Schulung.
@immutable
class AcademyTraining {
  /// Dokument-ID unter `users/{dspUid}/academy_test_results/{testId}`.
  final String testId;

  final String titleDe;
  final String titleEn;
  final String descriptionDe;
  final String descriptionEn;

  final IconData icon;
  final Color accent;
  final Color accentBg;

  final AcademyCompletionKind kind;

  /// Bestehensgrenze als Anteil (0.8 = 80 %). `null` = kein Test.
  final double? passRatio;

  /// Gültigkeitsdauer eines Abschlusses. `null` = läuft nicht ab.
  ///
  /// Nur Rückfallebene: liegt im Ergebnisdokument ein `validUntil`, gilt
  /// dieses. Ohne beides gilt der Abschluss dauerhaft.
  final Duration? validity;

  /// Wie viele Fragen ein Abschlusstest zieht, falls nicht alle
  /// (Fahrsicherheit: 18 aus dem Pool). `null` = alle Fragen.
  final int? examQuestionCount;

  final List<AcademyChapterInfo> Function(String languageCode) chaptersFor;
  final List<AcademyQuestionGroup> Function(String languageCode)
      questionGroupsFor;
  final List<AcademyAckItem> Function(String languageCode) ackItemsFor;

  const AcademyTraining({
    required this.testId,
    required this.titleDe,
    required this.titleEn,
    required this.descriptionDe,
    required this.descriptionEn,
    required this.icon,
    required this.accent,
    required this.accentBg,
    required this.kind,
    this.passRatio,
    this.validity,
    this.examQuestionCount,
    this.chaptersFor = _noChapters,
    this.questionGroupsFor = _noQuestionGroups,
    this.ackItemsFor = _noAckItems,
  });

  String title(bool de) => de ? titleDe : titleEn;
  String description(bool de) => de ? descriptionDe : descriptionEn;

  int chapterCount(String languageCode) => chaptersFor(languageCode).length;

  int slideCount(String languageCode) =>
      chaptersFor(languageCode).fold(0, (sum, c) => sum + c.slideCount);

  int questionCount(String languageCode) => questionGroupsFor(languageCode)
      .fold(0, (sum, g) => sum + g.questions.length);

  /// Fragen, die überhaupt im Abschlusstest vorkommen können.
  int examPoolCount(String languageCode) => questionGroupsFor(languageCode)
      .fold(0, (sum, g) => sum + g.questions.where((q) => !q.moduleOnly).length);

  /// IDs, die ein Fahrer bestätigt haben muss, damit die Schulung als
  /// erledigt gilt (Betriebsanweisungen ohne die Dispatcher-Anweisung).
  List<String> requiredAckIds(String languageCode) => [
        for (final item in ackItemsFor(languageCode))
          if (item.driverRelevant) item.id,
      ];
}

List<AcademyChapterInfo> _noChapters(String _) => const [];
List<AcademyQuestionGroup> _noQuestionGroups(String _) => const [];
List<AcademyAckItem> _noAckItems(String _) => const [];

// ── Aufbereitung der Code-Inhalte ───────────────────────────────────

List<AcademyChapterInfo> _chaptersOf(List<SafetyChapterContent> chapters) => [
      for (final c in chapters)
        AcademyChapterInfo(
          id: c.id,
          title: c.title,
          summary: c.summary,
          slideCount: c.slides.length,
        ),
    ];

/// Gruppiert `DrivingQuestion`s nach `moduleId` und benennt die Gruppen
/// über die gleichnamigen Kapitel-IDs. Kapitel ohne Fragen entfallen,
/// Fragen ohne passendes Kapitel bekommen ihre Modul-ID als Titel.
List<AcademyQuestionGroup> _groupDrivingQuestions(
  List<DrivingQuestion> questions,
  List<SafetyChapterContent> chapters,
) {
  final byModule = <String, List<DrivingQuestion>>{};
  for (final q in questions) {
    (byModule[q.moduleId] ??= <DrivingQuestion>[]).add(q);
  }

  AcademyQuestionInfo map(DrivingQuestion q) => AcademyQuestionInfo(
        question: q.question,
        options: q.options,
        correctIndex: q.correctIndex,
        explanation: q.explanation.trim().isEmpty ? null : q.explanation,
        mandatoryInExam: q.mandatoryInExam,
        moduleOnly: q.moduleOnly,
      );

  final out = <AcademyQuestionGroup>[];
  final used = <String>{};
  for (final c in chapters) {
    final qs = byModule[c.id];
    if (qs == null || qs.isEmpty) continue;
    used.add(c.id);
    out.add(AcademyQuestionGroup(
      id: c.id,
      title: c.title,
      questions: qs.map(map).toList(growable: false),
    ));
  }
  for (final entry in byModule.entries) {
    if (used.contains(entry.key)) continue;
    out.add(AcademyQuestionGroup(
      id: entry.key,
      title: entry.key.toUpperCase(),
      questions: entry.value.map(map).toList(growable: false),
    ));
  }
  return out;
}

List<AcademyQuestionGroup> _safetyQuestionGroups(String languageCode) => [
      AcademyQuestionGroup(
        id: 'safety_exam',
        title: languageCode == 'de' ? 'Abschlusstest' : 'Final test',
        questions: [
          for (final q in kSafetyQuestions)
            AcademyQuestionInfo(
              question: safetyText(languageCode, q.questionKey),
              options: [
                for (final key in q.optionKeys) safetyText(languageCode, key),
              ],
              correctIndex: q.correctIndex,
            ),
        ],
      ),
    ];

List<AcademyAckItem> _operatingInstructionItems(String languageCode) {
  // Bewusst die UNGEFILTERTE Liste: Der Admin soll alle acht Anweisungen
  // sehen. Welche davon für Fahrer zählen, steckt in [driverRelevant].
  final all = operatingInstructionsFor(languageCode, forDispatcher: true);
  return [
    for (final i in all)
      AcademyAckItem(
        id: i.id,
        title: i.title,
        subtitle: i.subtitle,
        driverRelevant: !kDispatcherOnlyInstructionIds.contains(i.id),
      ),
  ];
}

// ── Die Registry ────────────────────────────────────────────────────

/// Alle Schulungen der DA Academy — Reihenfolge = Reihenfolge der
/// Admin-Übersicht. Eine neue Schulung = ein weiterer Eintrag.
final List<AcademyTraining> kAcademyTrainings = <AcademyTraining>[
  AcademyTraining(
    testId: kSafetyTrainingTestId,
    titleDe: 'Sicherheitsunterweisung',
    titleEn: 'Safety instruction',
    descriptionDe: 'Jährliche Arbeitsschutz-Unterweisung gem. § 12 ArbSchG / '
        '§ 4 DGUV Vorschrift 1, mit Abschlusstest, Unterschrift und '
        'Nachweis-PDF.',
    descriptionEn: 'Annual occupational-safety instruction per § 12 ArbSchG / '
        '§ 4 DGUV Vorschrift 1, with final test, signature and certificate '
        'PDF.',
    icon: Icons.health_and_safety_rounded,
    accent: Color(0xFF1D7F5A),
    accentBg: Color(0xFFE4F5EC),
    kind: AcademyCompletionKind.test,
    passRatio: kSafetyTrainingPassRatio,
    validity: kSafetyTrainingValidity,
    chaptersFor: _safetyChapters,
    questionGroupsFor: _safetyQuestionGroups,
  ),
  AcademyTraining(
    testId: kDrivingSafetyTrainingId,
    titleDe: 'Fahrsicherheitstraining',
    titleEn: 'Driving safety training',
    descriptionDe: 'Zehn Module mit Modul-Quiz und Abschlusstest; danach '
        'Zertifikat mit Prüfnummer. Der Abschlusstest zieht 18 Fragen aus '
        'dem Pool, die Pflichtfragen immer.',
    descriptionEn: 'Ten modules with module quizzes and a final test, '
        'followed by a certificate with a verification number. The final '
        'test draws 18 questions from the pool, always including the '
        'mandatory ones.',
    icon: Icons.drive_eta_rounded,
    accent: Color(0xFF1D7F5A),
    accentBg: Color(0xFFE4F5EC),
    kind: AcademyCompletionKind.test,
    passRatio: kDrivingPassThreshold,
    // Rückfallebene; das Zertifikat schreibt sein `validUntil` selbst
    // (exakt +[kDrivingCertificateMonths] Monate).
    validity: Duration(days: 365),
    examQuestionCount: 18,
    chaptersFor: _drivingChapters,
    questionGroupsFor: _drivingQuestionGroups,
  ),
  AcademyTraining(
    testId: kGreenBookTestId,
    titleDe: 'Green Book',
    titleEn: 'Green Book',
    descriptionDe: 'Fahrtenkontrollbuch: Fahrzeugübernahme, Kontrollen, '
        'Schäden und Rückgabe — mit Abschlusstest ohne Ablaufdatum.',
    descriptionEn: 'Vehicle log book: handover, inspections, damage and '
        'return — with a final test that does not expire.',
    icon: Icons.menu_book_rounded,
    accent: Color(0xFF22AF66),
    accentBg: Color(0xFFE9F7EF),
    kind: AcademyCompletionKind.test,
    passRatio: kGreenBookPassThreshold,
    chaptersFor: _greenBookChapters,
    questionGroupsFor: _greenBookQuestionGroups,
  ),
  AcademyTraining(
    testId: kRideAlongTestId,
    titleDe: 'Ride Along',
    titleEn: 'Ride Along',
    descriptionDe: 'Vorbereitung auf die zweitägige Begleitfahrt mit einem '
        'Trainer — mit Abschlusstest ohne Ablaufdatum.',
    descriptionEn: 'Preparation for the two-day ride-along with a trainer — '
        'with a final test that does not expire.',
    icon: Icons.supervisor_account_rounded,
    accent: Color(0xFF2A5FB0),
    accentBg: Color(0xFFEAF1FB),
    kind: AcademyCompletionKind.test,
    passRatio: kRideAlongPassThreshold,
    chaptersFor: _rideAlongChapters,
    questionGroupsFor: _rideAlongQuestionGroups,
  ),
  AcademyTraining(
    testId: kPrivacyTestId,
    titleDe: 'Datenschutz',
    titleEn: 'Data protection',
    descriptionDe: 'DSGVO-Grundschulung mit Abschlusstest, Unterschrift und '
        'Nachweis-PDF; jährlich zu wiederholen.',
    descriptionEn: 'GDPR basic training with final test, signature and '
        'certificate PDF; to be repeated annually.',
    icon: Icons.privacy_tip_rounded,
    accent: Color(0xFF5C4B99),
    accentBg: Color(0xFFEFECF9),
    kind: AcademyCompletionKind.test,
    passRatio: kPrivacyPassThreshold,
    validity: kPrivacyValidity,
    chaptersFor: _privacyChapters,
    questionGroupsFor: _privacyQuestionGroups,
  ),
  AcademyTraining(
    testId: kOperatingInstructionsTestId,
    titleDe: 'Betriebsanweisungen',
    titleEn: 'Operating instructions',
    descriptionDe: 'Verbindliche Anweisungen des Arbeitgebers — kein Test, '
        'sondern eine Lesebestätigung je Anweisung.',
    descriptionEn: 'Binding instructions from the employer — no test, but a '
        'read receipt for each instruction.',
    icon: Icons.menu_book_outlined,
    accent: Color(0xFF3B5A80),
    accentBg: Color(0xFFEFF4FA),
    kind: AcademyCompletionKind.acknowledgement,
    ackItemsFor: _operatingInstructionItems,
  ),
];

// Tear-offs statt Closures, damit die Einträge oben lesbar bleiben.
List<AcademyChapterInfo> _safetyChapters(String lang) =>
    _chaptersOf(safetyChaptersFor(lang));
List<AcademyChapterInfo> _drivingChapters(String lang) =>
    _chaptersOf(drivingSafetyChaptersFor(lang));
List<AcademyChapterInfo> _greenBookChapters(String lang) =>
    _chaptersOf(greenBookChaptersFor(lang));
List<AcademyChapterInfo> _rideAlongChapters(String lang) =>
    _chaptersOf(rideAlongChaptersFor(lang));
List<AcademyChapterInfo> _privacyChapters(String lang) =>
    _chaptersOf(privacyChaptersFor(lang));

List<AcademyQuestionGroup> _drivingQuestionGroups(String lang) =>
    _groupDrivingQuestions(
      drivingQuestionsFor(lang),
      drivingSafetyChaptersFor(lang),
    );
List<AcademyQuestionGroup> _greenBookQuestionGroups(String lang) =>
    _groupDrivingQuestions(
      greenBookQuestionsFor(lang),
      greenBookChaptersFor(lang),
    );
List<AcademyQuestionGroup> _rideAlongQuestionGroups(String lang) =>
    _groupDrivingQuestions(
      rideAlongQuestionsFor(lang),
      rideAlongChaptersFor(lang),
    );
List<AcademyQuestionGroup> _privacyQuestionGroups(String lang) =>
    _groupDrivingQuestions(
      privacyQuestionsFor(lang),
      privacyChaptersFor(lang),
    );
