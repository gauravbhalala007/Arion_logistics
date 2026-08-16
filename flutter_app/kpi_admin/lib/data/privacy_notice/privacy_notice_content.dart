// lib/data/privacy_notice/privacy_notice_content.dart
//
// Datenschutzinformation für Fahrer nach Art. 13 DSGVO.
//
// WICHTIG — rechtliche Einordnung:
// Das hier ist eine INFORMATION mit Bestätigung der Kenntnisnahme, keine
// Erklärung des Fahrers, mit der eine Verarbeitung erlaubt wird. Im
// Beschäftigungsverhältnis wäre eine solche Erklärung wegen des
// Abhängigkeitsverhältnisses kaum freiwillig und jederzeit widerruflich.
// Die Verarbeitung stützt sich deshalb auf Art. 6 Abs. 1 lit. b DSGVO
// (Durchführung des Arbeitsvertrags), Art. 6 Abs. 1 lit. c DSGVO
// (rechtliche Pflichten), Art. 6 Abs. 1 lit. f DSGVO (berechtigtes
// Interesse) und § 26 BDSG.
//
// Folge für alle Texte in diesem Verzeichnis: durchgehend
// „Ich wurde informiert" / „Ich habe gelesen und verstanden" — niemals
// eine Formulierung, die nach einer Erlaubniserteilung klingt.
//
// Aufbau: Abschnitte aus denselben typisierten Bausteinen wie die
// Sicherheitsunterweisung (`safety_blocks.dart`), gerendert über
// `SafetyBlockView` — dadurch identische Optik zum Rest der App.

import 'package:flutter/foundation.dart';

import '../safety_training/safety_blocks.dart';
import 'privacy_notice_de.dart';
import 'privacy_notice_es.dart';
import 'privacy_notice_hr.dart';
import 'privacy_notice_ro.dart';
import 'privacy_notice_ru.dart';
import 'privacy_notice_sq.dart';

/// Fassung der Datenschutzinformation.
///
/// Wird die Information inhaltlich geändert, muss diese Zahl erhöht
/// werden. Der Login-Gate vergleicht sie mit der beim Fahrer
/// gespeicherten `version` — ist die gespeicherte kleiner, erscheint die
/// Information erneut und muss neu unterschrieben werden.
const int kPrivacyNoticeVersion = 1;

/// Stand der aktuellen Fassung (Anzeige im Kopf der Seite).
const String kPrivacyNoticeIssuedOn = '11.08.2026';

/// ID, unter der die Kenntnisnahme abgelegt wird:
/// users/{dspUid}/academy_test_results/privacy_notice/drivers/{tid}
///
/// Muss exakt dem Dokument-Namen entsprechen — die Firestore-Regel
/// verlangt `request.resource.data.testId == testId`.
const String kPrivacyNoticeTestId = 'privacy_notice';

/// Ein Abschnitt der Datenschutzinformation.
@immutable
class PrivacyNoticeSection {
  /// Stabile ID (für Fortschritt/Tests), sprachunabhängig.
  final String id;

  final String title;

  /// Einzeiler für die Abschnittsübersicht.
  final String summary;

  final List<SafetyBlock> blocks;

  const PrivacyNoticeSection({
    required this.id,
    required this.title,
    required this.summary,
    required this.blocks,
  });
}

/// Abschnitte für [languageCode].
///
/// Aufbau wie `green_book_data.dart`: pro Sprache ein eigener Zweig.
/// Volltexte liegen bislang in de, ro, ru, hr, sq und es vor — die
/// übrigen Sprachen fallen auf die deutsche Master-Fassung zurück
/// (die Kurzinformation/Popup-Texte sind davon unabhängig und
/// existieren in allen Sprachen, `privacy_notice_texts.dart`).
List<PrivacyNoticeSection> privacyNoticeSectionsFor(String languageCode) {
  return switch (languageCode) {
    'ro' => privacyNoticeSectionsRo,
    'ru' => privacyNoticeSectionsRu,
    'hr' => privacyNoticeSectionsHr,
    'sq' => privacyNoticeSectionsSq,
    'es' => privacyNoticeSectionsEs,
    _ => privacyNoticeSectionsDe,
  };
}

/// Anzahl der Abschnitte — für die Metazeile im Intro.
int privacyNoticeSectionCount(String languageCode) =>
    privacyNoticeSectionsFor(languageCode).length;
