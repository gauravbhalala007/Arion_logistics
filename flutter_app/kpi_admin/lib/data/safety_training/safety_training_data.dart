// lib/data/safety_training/safety_training_data.dart
//
// Sicherheitsunterweisung (DA Academy) — Datenmodell + Sprachauflösung.
//
// Inhalte kompakt aus der SVG-Sicherheitsunterweisung (71 Folien)
// extrahiert, generisch formuliert (ohne Firmen-/SVG-Bezug).
// Texte liegen pro Sprache in eigenen Dateien (safety_texts_<lang>.dart)
// mit identischem Key-Satz; Fallback-Kette: locale → en → de.

import 'safety_blocks.dart';
import 'safety_content_ar.dart';
import 'safety_content_bg.dart';
import 'safety_content_es.dart';
import 'safety_content_de.dart';
import 'safety_content_en.dart';
import 'safety_content_hr.dart';
import 'safety_content_hu.dart';
import 'safety_content_ro.dart';
import 'safety_content_ru.dart';
import 'safety_content_sq.dart';
import 'safety_content_tr.dart';
import 'safety_texts_ar.dart';
import 'safety_texts_bg.dart';
import 'safety_texts_es.dart';
import 'safety_texts_de.dart';
import 'safety_texts_en.dart';
import 'safety_texts_hr.dart';
import 'safety_texts_hu.dart';
import 'safety_texts_ro.dart';
import 'safety_texts_ru.dart';
import 'safety_texts_sq.dart';
import 'safety_texts_tr.dart';

/// ID unter der Abschlüsse gespeichert werden:
/// users/{uid}/academy_test_results/safety_training/drivers/{tid}
const String kSafetyTrainingTestId = 'safety_training';

/// Gültigkeit eines Abschlusses (jährliche Unterweisungspflicht).
const Duration kSafetyTrainingValidity = Duration(days: 365);

/// Bestehensgrenze des Abschluss-Tests.
const double kSafetyTrainingPassRatio = 0.8;

/// Kapitelinhalte für [languageCode].
///
/// Die Inhalte liegen als Seiten-/Baustein-Struktur vor (siehe
/// `safety_blocks.dart`). Solange eine Sprache noch nicht übersetzt ist,
/// wird die deutsche Fassung ausgeliefert — die Bedien-Texte drumherum
/// (Buttons, Test, Unterschrift) sind bereits in allen Sprachen da.
List<SafetyChapterContent> safetyChaptersFor(String languageCode) {
  return switch (languageCode) {
    'en' => safetyContentEn,
    'sq' => safetyContentSq,
    'hu' => safetyContentHu,
    'ro' => safetyContentRo,
    'hr' => safetyContentHr,
    'tr' => safetyContentTr,
    'ru' => safetyContentRu,
    'bg' => safetyContentBg,
    'es' => safetyContentEs,
    'ar' => safetyContentAr,
    _ => safetyContentDe,
  };
}

/// Gesamtzahl der Seiten über alle Kapitel — für die Fortschrittsanzeige.
int safetySlideCount(String languageCode) => safetyChaptersFor(languageCode)
    .fold(0, (sum, c) => sum + c.slides.length);

class SafetyQuestion {
  final String questionKey;

  /// Antwort-Keys in fester Reihenfolge a/b/c.
  final List<String> optionKeys;

  /// Index der richtigen Antwort in [optionKeys].
  final int correctIndex;
  const SafetyQuestion(this.questionKey, this.optionKeys, this.correctIndex);
}


const List<SafetyQuestion> kSafetyQuestions = [
  SafetyQuestion('q01', ['q01_a', 'q01_b', 'q01_c'], 1),
  SafetyQuestion('q02', ['q02_a', 'q02_b', 'q02_c'], 1),
  SafetyQuestion('q03', ['q03_a', 'q03_b', 'q03_c'], 1),
  SafetyQuestion('q04', ['q04_a', 'q04_b', 'q04_c'], 2),
  SafetyQuestion('q05', ['q05_a', 'q05_b', 'q05_c'], 1),
  SafetyQuestion('q06', ['q06_a', 'q06_b', 'q06_c'], 2),
  SafetyQuestion('q07', ['q07_a', 'q07_b', 'q07_c'], 1),
  SafetyQuestion('q08', ['q08_a', 'q08_b', 'q08_c'], 1),
  SafetyQuestion('q09', ['q09_a', 'q09_b', 'q09_c'], 1),
  SafetyQuestion('q10', ['q10_a', 'q10_b', 'q10_c'], 1),
  SafetyQuestion('q11', ['q11_a', 'q11_b', 'q11_c'], 1),
  SafetyQuestion('q12', ['q12_a', 'q12_b', 'q12_c'], 1),
  SafetyQuestion('q13', ['q13_a', 'q13_b', 'q13_c'], 1),
  SafetyQuestion('q14', ['q14_a', 'q14_b', 'q14_c'], 2),
  SafetyQuestion('q15', ['q15_a', 'q15_b', 'q15_c'], 0),
  SafetyQuestion('q16', ['q16_a', 'q16_b', 'q16_c'], 1),
  SafetyQuestion('q17', ['q17_a', 'q17_b', 'q17_c'], 2),
  SafetyQuestion('q18', ['q18_a', 'q18_b', 'q18_c'], 1),
  SafetyQuestion('q19', ['q19_a', 'q19_b', 'q19_c'], 0),
  SafetyQuestion('q20', ['q20_a', 'q20_b', 'q20_c'], 1),
];

const Map<String, Map<String, String>> _byLang = {
  'de': safetyTextsDe,
  'en': safetyTextsEn,
  'sq': safetyTextsSq,
  'hu': safetyTextsHu,
  'ro': safetyTextsRo,
  'hr': safetyTextsHr,
  'ar': safetyTextsAr,
  'tr': safetyTextsTr,
  'ru': safetyTextsRu,
  'bg': safetyTextsBg,
  'es': safetyTextsEs,
};

/// Text-Lookup mit Fallback locale → en → de.
String safetyText(String languageCode, String key) {
  final lang = _byLang[languageCode];
  return lang?[key] ?? safetyTextsEn[key] ?? safetyTextsDe[key] ?? key;
}
