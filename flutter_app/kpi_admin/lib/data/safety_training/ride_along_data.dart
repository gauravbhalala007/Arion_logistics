// lib/data/safety_training/ride_along_data.dart
//
// Ride Along (zweitägige Begleitfahrt) — Sprachauflösung für Inhalte
// und Fragen. Aufbau wie `green_book_data.dart`.
//
// Derzeit existiert nur die deutsche Fassung: alle Sprachen fallen auf
// sie zurück. Sobald Übersetzungen vorliegen, hier je Sprache einen
// eigenen Zweig ergänzen — die Bedientexte der Seite sind davon
// unabhängig und liegen schon in allen zehn Sprachen vor
// (`ride_along_texts.dart`).

import 'driving_safety_quiz_de.dart' show DrivingQuestion;
import 'ride_along_content_de.dart';
import 'ride_along_content_sq.dart';
import 'ride_along_content_ar.dart';
import 'ride_along_content_bg.dart';
import 'ride_along_content_es.dart';
import 'ride_along_content_ru.dart';
import 'ride_along_content_tr.dart';
import 'ride_along_content_hr.dart';
import 'ride_along_content_ro.dart';
import 'ride_along_content_hu.dart';
import 'ride_along_content_en.dart';
import 'ride_along_quiz_de.dart';
import 'ride_along_quiz_sq.dart';
import 'ride_along_quiz_ar.dart';
import 'ride_along_quiz_bg.dart';
import 'ride_along_quiz_es.dart';
import 'ride_along_quiz_ru.dart';
import 'ride_along_quiz_tr.dart';
import 'ride_along_quiz_hr.dart';
import 'ride_along_quiz_ro.dart';
import 'ride_along_quiz_hu.dart';
import 'ride_along_quiz_en.dart';
import 'safety_blocks.dart';

/// Kapitelinhalte für [languageCode].
List<SafetyChapterContent> rideAlongChaptersFor(String languageCode) {
  return switch (languageCode) {
    'en' => rideAlongContentEn,
    'hu' => rideAlongContentHu,
    'ro' => rideAlongContentRo,
    'hr' => rideAlongContentHr,
    'tr' => rideAlongContentTr,
    'ru' => rideAlongContentRu,
    'bg' => rideAlongContentBg,
    'es' => rideAlongContentEs,
    'ar' => rideAlongContentAr,
    'sq' => rideAlongContentSq,
    _ => rideAlongContentDe,
  };
}

/// Prüfungsfragen für [languageCode] — Reihenfolge und `correctIndex`
/// sind in allen Sprachen identisch zur deutschen Fassung.
List<DrivingQuestion> rideAlongQuestionsFor(String languageCode) {
  return switch (languageCode) {
    'en' => rideAlongQuestionsEn,
    'hu' => rideAlongQuestionsHu,
    'ro' => rideAlongQuestionsRo,
    'hr' => rideAlongQuestionsHr,
    'tr' => rideAlongQuestionsTr,
    'ru' => rideAlongQuestionsRu,
    'bg' => rideAlongQuestionsBg,
    'es' => rideAlongQuestionsEs,
    'ar' => rideAlongQuestionsAr,
    'sq' => rideAlongQuestionsSq,
    _ => rideAlongQuestionsDe,
  };
}
