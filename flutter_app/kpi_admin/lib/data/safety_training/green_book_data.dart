// lib/data/safety_training/green_book_data.dart
//
// Green Book (Fahrtenkontrollbuch) — Sprachauflösung für Inhalte und
// Fragen. Aufbau wie `driving_safety_data.dart`: Sprachen, die noch
// nicht übersetzt sind, fallen auf die deutsche Fassung zurück.

import 'driving_safety_quiz_de.dart' show DrivingQuestion;
import 'green_book_content_ar.dart';
import 'green_book_content_bg.dart';
import 'green_book_content_es.dart';
import 'green_book_content_de.dart';
import 'green_book_content_en.dart';
import 'green_book_content_hu.dart';
import 'green_book_content_hr.dart';
import 'green_book_content_ro.dart';
import 'green_book_content_ru.dart';
import 'green_book_content_sq.dart';
import 'green_book_content_tr.dart';
import 'green_book_quiz_ar.dart';
import 'green_book_quiz_bg.dart';
import 'green_book_quiz_es.dart';
import 'green_book_quiz_de.dart';
import 'green_book_quiz_en.dart';
import 'green_book_quiz_hu.dart';
import 'green_book_quiz_hr.dart';
import 'green_book_quiz_ro.dart';
import 'green_book_quiz_ru.dart';
import 'green_book_quiz_sq.dart';
import 'green_book_quiz_tr.dart';
import 'safety_blocks.dart';

/// Kapitelinhalte für [languageCode].
List<SafetyChapterContent> greenBookChaptersFor(String languageCode) {
  return switch (languageCode) {
    'en' => greenBookContentEn,
    'sq' => greenBookContentSq,
    'hu' => greenBookContentHu,
    'ro' => greenBookContentRo,
    'hr' => greenBookContentHr,
    'tr' => greenBookContentTr,
    'ru' => greenBookContentRu,
    'bg' => greenBookContentBg,
    'es' => greenBookContentEs,
    'ar' => greenBookContentAr,
    _ => greenBookContentDe,
  };
}

/// Prüfungsfragen für [languageCode] — Reihenfolge und `correctIndex`
/// sind in allen Sprachen identisch zur deutschen Fassung.
List<DrivingQuestion> greenBookQuestionsFor(String languageCode) {
  return switch (languageCode) {
    'en' => greenBookQuestionsEn,
    'sq' => greenBookQuestionsSq,
    'hu' => greenBookQuestionsHu,
    'ro' => greenBookQuestionsRo,
    'hr' => greenBookQuestionsHr,
    'tr' => greenBookQuestionsTr,
    'ru' => greenBookQuestionsRu,
    'bg' => greenBookQuestionsBg,
    'es' => greenBookQuestionsEs,
    'ar' => greenBookQuestionsAr,
    _ => greenBookQuestionsDe,
  };
}
