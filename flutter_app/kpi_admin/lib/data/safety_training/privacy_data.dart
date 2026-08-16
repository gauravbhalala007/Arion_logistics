// lib/data/safety_training/privacy_data.dart
//
// Datenschutz-Schulung (DSGVO) — Sprachauflösung für Inhalte und Fragen.
// Aufbau wie `ride_along_data.dart`.
//
// Inhalte und Fragen liegen in allen zehn Sprachen vor; unbekannte
// Sprachcodes fallen auf die deutsche Master-Fassung zurück. Die
// Bedientexte der Seite sind davon unabhängig (`privacy_texts.dart`).

import 'driving_safety_quiz_de.dart' show DrivingQuestion;
import 'privacy_content_ar.dart';
import 'privacy_content_bg.dart';
import 'privacy_content_es.dart';
import 'privacy_content_de.dart';
import 'privacy_content_en.dart';
import 'privacy_content_hr.dart';
import 'privacy_content_hu.dart';
import 'privacy_content_ro.dart';
import 'privacy_content_ru.dart';
import 'privacy_content_sq.dart';
import 'privacy_content_tr.dart';
import 'privacy_quiz_ar.dart';
import 'privacy_quiz_bg.dart';
import 'privacy_quiz_es.dart';
import 'privacy_quiz_de.dart';
import 'privacy_quiz_en.dart';
import 'privacy_quiz_hr.dart';
import 'privacy_quiz_hu.dart';
import 'privacy_quiz_ro.dart';
import 'privacy_quiz_ru.dart';
import 'privacy_quiz_sq.dart';
import 'privacy_quiz_tr.dart';
import 'safety_blocks.dart';

/// ID, unter der Abschlüsse gespeichert werden:
/// users/{dspUid}/academy_test_results/privacy/drivers/{tid}
const String kPrivacyTestId = 'privacy';

/// Bestehensgrenze des Abschlusstests.
const double kPrivacyPassThreshold = 0.8;

/// Gültigkeit eines Abschlusses — wie bei der Sicherheitsunterweisung
/// zwölf Monate (jährliche Grundschulung).
const Duration kPrivacyValidity = Duration(days: 365);

/// Kapitelinhalte für [languageCode].
List<SafetyChapterContent> privacyChaptersFor(String languageCode) {
  return switch (languageCode) {
    'en' => privacyContentEn,
    'sq' => privacyContentSq,
    'hu' => privacyContentHu,
    'ro' => privacyContentRo,
    'hr' => privacyContentHr,
    'tr' => privacyContentTr,
    'ru' => privacyContentRu,
    'bg' => privacyContentBg,
    'es' => privacyContentEs,
    'ar' => privacyContentAr,
    _ => privacyContentDe,
  };
}

/// Prüfungsfragen für [languageCode] — Reihenfolge und `correctIndex`
/// sind in allen Sprachen identisch zur deutschen Fassung.
List<DrivingQuestion> privacyQuestionsFor(String languageCode) {
  return switch (languageCode) {
    'en' => privacyQuestionsEn,
    'sq' => privacyQuestionsSq,
    'hu' => privacyQuestionsHu,
    'ro' => privacyQuestionsRo,
    'hr' => privacyQuestionsHr,
    'tr' => privacyQuestionsTr,
    'ru' => privacyQuestionsRu,
    'bg' => privacyQuestionsBg,
    'es' => privacyQuestionsEs,
    'ar' => privacyQuestionsAr,
    _ => privacyQuestionsDe,
  };
}

/// Gesamtzahl der Seiten über alle Kapitel — für die Intro-Metazeile.
int privacySlideCount(String languageCode) => privacyChaptersFor(languageCode)
    .fold(0, (sum, c) => sum + c.slides.length);
