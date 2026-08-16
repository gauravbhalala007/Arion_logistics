// lib/data/safety_training/driving_safety_data.dart
//
// DSP-Fahrsicherheitstraining — Sprachauflösung für Inhalte und Fragen.
//
// Aufbau wie bei der Sicherheitsunterweisung
// (`safety_training_data.dart` → `safetyChaptersFor()`): die Inhalte
// liegen pro Sprache in eigenen Dateien mit identischer Struktur, hier
// wird nur nach Sprachcode aufgelöst. Nicht übersetzte Sprachen fallen
// auf Deutsch zurück.

import 'dart:math';

import 'driving_safety_content_ar.dart';
import 'driving_safety_content_de.dart';
import 'driving_safety_content_en.dart';
import 'driving_safety_content_ro.dart';
import 'driving_safety_content_hu.dart';
import 'driving_safety_content_bg.dart';
import 'driving_safety_content_es.dart';
import 'driving_safety_content_ru.dart';
import 'driving_safety_content_hr.dart';
import 'driving_safety_content_sq.dart';
import 'driving_safety_content_tr.dart';
import 'driving_safety_quiz_ar.dart';
import 'driving_safety_quiz_de.dart';
import 'driving_safety_quiz_en.dart';
import 'driving_safety_quiz_ro.dart';
import 'driving_safety_quiz_hu.dart';
import 'driving_safety_quiz_bg.dart';
import 'driving_safety_quiz_es.dart';
import 'driving_safety_quiz_ru.dart';
import 'driving_safety_quiz_hr.dart';
import 'driving_safety_quiz_sq.dart';
import 'driving_safety_quiz_tr.dart';
import 'safety_blocks.dart';

/// Modulinhalte (M1–M10) für [languageCode].
List<SafetyChapterContent> drivingSafetyChaptersFor(String languageCode) {
  return switch (languageCode) {
    'en' => drivingSafetyContentEn,
    'ru' => drivingSafetyContentRu,
    'bg' => drivingSafetyContentBg,
    'es' => drivingSafetyContentEs,
    'hu' => drivingSafetyContentHu,
    'ro' => drivingSafetyContentRo,
    'sq' => drivingSafetyContentSq,
    'hr' => drivingSafetyContentHr,
    'tr' => drivingSafetyContentTr,
    'ar' => drivingSafetyContentAr,
    _ => drivingSafetyContentDe,
  };
}

/// Alle Quiz-/Testfragen für [languageCode] — gleiche Reihenfolge und
/// gleiche Flags wie in der deutschen Master-Liste.
List<DrivingQuestion> drivingQuestionsFor(String languageCode) {
  return switch (languageCode) {
    'en' => drivingQuestionsEn,
    'ru' => drivingQuestionsRu,
    'bg' => drivingQuestionsBg,
    'es' => drivingQuestionsEs,
    'hu' => drivingQuestionsHu,
    'ro' => drivingQuestionsRo,
    'sq' => drivingQuestionsSq,
    'hr' => drivingQuestionsHr,
    'tr' => drivingQuestionsTr,
    'ar' => drivingQuestionsAr,
    _ => drivingQuestionsDe,
  };
}

/// Gesamtzahl der Seiten über alle Module — für Fortschrittsanzeigen.
int drivingSlideCount(String languageCode) =>
    drivingSafetyChaptersFor(languageCode)
        .fold(0, (sum, c) => sum + c.slides.length);

/// Fragen eines Moduls in der gewünschten Sprache.
List<DrivingQuestion> drivingQuestionsForModule(
  String moduleId, [
  String languageCode = 'de',
]) =>
    drivingQuestionsFor(languageCode)
        .where((q) => q.moduleId == moduleId)
        .toList();

/// Stellt einen Abschlusstest zusammen: alle Pflichtfragen plus zufällige
/// weitere aus dem Pool, insgesamt [count] Fragen.
///
/// Die Sprache wirkt nur auf die Texte — Reihenfolge, Pflichtfragen und
/// richtige Antworten sind in allen Sprachen identisch.
List<DrivingQuestion> buildDrivingExam({
  int count = 18,
  int? seed,
  String languageCode = 'de',
}) {
  final pool =
      drivingQuestionsFor(languageCode).where((q) => !q.moduleOnly).toList();
  final mandatory = pool.where((q) => q.mandatoryInExam).toList();
  final rest = pool.where((q) => !q.mandatoryInExam).toList()
    ..shuffle(seed == null ? null : _SeededRandom(seed));
  final picked = <DrivingQuestion>[
    ...mandatory,
    ...rest.take((count - mandatory.length).clamp(0, rest.length)),
  ];
  picked.shuffle(seed == null ? null : _SeededRandom(seed + 1));
  return picked;
}

/// Kleiner deterministischer Zufall, damit ein laufender Test bei einem
/// Rebuild nicht die Fragen wechselt.
class _SeededRandom implements Random {
  final Random _r;
  _SeededRandom(int seed) : _r = Random(seed);
  @override
  bool nextBool() => _r.nextBool();
  @override
  double nextDouble() => _r.nextDouble();
  @override
  int nextInt(int max) => _r.nextInt(max);
}
