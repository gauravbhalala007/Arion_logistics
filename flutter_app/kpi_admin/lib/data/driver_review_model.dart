// lib/data/driver_review_model.dart
//
// Monatliche Fahrerbewertung durch Dispatcher.
//
// Ablauf: Der Admin erzeugt pro Dispatcher einen Link mit Zufalls-Token.
// Das Link-Dokument enthält bereits die Liste der aktiven Fahrer, damit
// die öffentliche Seite NICHT auf die Fahrerstammdaten zugreifen muss.
//
// Firestore:
//   dispatcher_review_links/{token}
//     { adminUid, dispatcherName, period: 'YYYY-MM', active,
//       drivers: [{tid, name}], createdAt }
//   users/{adminUid}/driver_reviews/{period}_{tid}
//     { period, driverTransporterId, driverName, dispatcherName,
//       linkToken, ratings: {...}, attitude, comment, note }
//
// Die frühere Frage nach der Weiterbeschäftigung wurde bewusst
// entfernt: Sie las sich als Vertragsempfehlung, obwohl die Bewertung
// ausschließlich der Einsatzplanung und Entwicklung dient.

import 'package:flutter/foundation.dart';

/// Eine Bewertungsfrage mit fester Antwortskala.
@immutable
class ReviewQuestion {
  final String id;
  final String label;

  /// Antwortoptionen von "schlecht" nach "gut" — der Index ist der Wert.
  final List<String> optionsDe;
  final List<String> optionsEn;

  /// Kurzer Hinweis unter der Frage (optional).
  final String? hintDe;

  const ReviewQuestion({
    required this.id,
    required this.label,
    required this.optionsDe,
    required this.optionsEn,
    this.hintDe,
  });

  /// Wertung 0..1 für die Gesamtnote; null wenn die Frage nicht in die
  /// Note einfließt (z. B. Arbeitstempo, wo die Mitte am besten ist).
  double? normalized(int answer) {
    if (id == 'pace') {
      // ideal (Index 1) = 1.0, Extreme = 0.5
      return answer == 1 ? 1.0 : 0.5;
    }
    if (optionsDe.length <= 1) return null;
    return answer / (optionsDe.length - 1);
  }
}

/// Die Fragen der monatlichen Bewertung — bewusst kurz gehalten.
const List<ReviewQuestion> kDriverReviewQuestions = [
  ReviewQuestion(
    id: 'pace',
    label: 'Arbeitstempo',
    optionsDe: ['Zu langsam', 'Ideal', 'Zu schnell'],
    optionsEn: ['Too slow', 'Ideal', 'Too fast'],
    hintDe: 'Zu schnell ist genauso ein Risiko wie zu langsam.',
  ),
  ReviewQuestion(
    id: 'helpfulness',
    label: 'Hilfsbereitschaft',
    optionsDe: [
      'Hilft nie',
      'Hilft ab und zu',
      'Hilft gerne',
      'Fragt von sich aus, ob er helfen kann',
    ],
    optionsEn: [
      'Never helps',
      'Helps occasionally',
      'Helps willingly',
      'Offers help on their own',
    ],
  ),
  ReviewQuestion(
    id: 'communication',
    label: 'Kommunikation',
    optionsDe: ['Schwierig', 'Geht so', 'Gut', 'Sehr gut'],
    optionsEn: ['Difficult', 'Okay', 'Good', 'Very good'],
    hintDe: 'Erreichbarkeit, Rückmeldungen, Probleme melden.',
  ),
  ReviewQuestion(
    id: 'punctuality',
    label: 'Pünktlichkeit',
    optionsDe: ['Oft zu spät', 'Manchmal zu spät', 'Pünktlich', 'Immer früh da'],
    optionsEn: ['Often late', 'Sometimes late', 'On time', 'Always early'],
  ),
  ReviewQuestion(
    id: 'mood',
    label: 'Laune & Auftreten',
    optionsDe: ['Meist mürrisch', 'Wechselhaft', 'Freundlich', 'Sehr positiv'],
    optionsEn: ['Mostly grumpy', 'Variable', 'Friendly', 'Very positive'],
  ),
  ReviewQuestion(
    id: 'complaints',
    label: 'Beschwert sich',
    optionsDe: ['Ständig', 'Häufig', 'Selten', 'So gut wie nie'],
    optionsEn: ['Constantly', 'Often', 'Rarely', 'Almost never'],
  ),
  ReviewQuestion(
    id: 'vehicle',
    label: 'Sauberkeit Fahrzeug',
    optionsDe: ['Verschmutzt', 'Geht so', 'Sauber', 'Vorbildlich'],
    optionsEn: ['Dirty', 'Okay', 'Clean', 'Exemplary'],
  ),
  ReviewQuestion(
    id: 'respect',
    label: 'Respektvoller Umgang',
    optionsDe: ['Problematisch', 'Geht so', 'Respektvoll', 'Vorbildlich'],
    optionsEn: ['Problematic', 'Okay', 'Respectful', 'Exemplary'],
    hintDe: 'Gegenüber Kollegen, Managern und Kunden.',
  ),
  ReviewQuestion(
    id: 'language',
    label: 'Sprachkenntnisse',
    optionsDe: [
      'Verständigung schwierig',
      'Grundlagen',
      'Gut verständlich',
      'Sehr gut',
    ],
    optionsEn: ['Hard to communicate', 'Basics', 'Understandable', 'Very good'],
  ),
];

/// Grundhaltung des Fahrers.
const List<String> kAttitudeOptionsDe = [
  'Eher negativ eingestellt',
  'Neutral',
  'Positiv eingestellt',
];
const List<String> kAttitudeOptionsEn = [
  'Rather negative',
  'Neutral',
  'Positive',
];


/// Gesamtnote 0..1 aus den beantworteten Fragen.
double reviewScore(Map<String, int> answers) {
  var sum = 0.0;
  var n = 0;
  for (final q in kDriverReviewQuestions) {
    final a = answers[q.id];
    if (a == null) continue;
    final v = q.normalized(a);
    if (v == null) continue;
    sum += v;
    n++;
  }
  return n == 0 ? 0 : sum / n;
}

/// Aktueller Bewertungszeitraum, z. B. '2026-08'.
String currentReviewPeriod([DateTime? now]) {
  final d = now ?? DateTime.now();
  return '${d.year}-${d.month.toString().padLeft(2, '0')}';
}

String reviewPeriodLabel(String period) {
  const months = [
    'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
    'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember',
  ];
  final parts = period.split('-');
  if (parts.length != 2) return period;
  final m = int.tryParse(parts[1]) ?? 0;
  if (m < 1 || m > 12) return period;
  return '${months[m - 1]} ${parts[0]}';
}
