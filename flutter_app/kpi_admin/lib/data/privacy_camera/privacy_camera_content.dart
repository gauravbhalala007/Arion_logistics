// lib/data/privacy_camera/privacy_camera_content.dart
//
// DA Academy — Modul „Kameras im Fahrzeug – Datenschutz".
//
// RECHTLICHE EINORDNUNG — bitte vor jeder Änderung lesen:
// Der Fahrer BESTÄTIGT DEN EMPFANG der Datenschutzerklärung. Er willigt
// NICHT ein. Rechtsgrundlage der Verarbeitung ist Art. 6 Abs. 1 lit. f
// DSGVO (berechtigtes Interesse), dokumentiert in einer DSFA. Die
// Unterschrift dient allein dem Nachweis nach Art. 5 Abs. 2 DSGVO.
//
// Daraus folgt zwingend:
//   - Der Button heißt „Bestätigen" — nie „Zustimmen"/„Akzeptieren".
//   - Der Text lautet „Erhalten und zur Kenntnis genommen" — nie
//     „Ich stimme zu".
//   - „Ich möchte nicht bestätigen" ist ein sichtbarer, gleichwertiger
//     Weg und KEIN Fehlerfall.
//   - Der Kurs blockiert die App NIEMALS.
//
// INHALTLICHE KLARSTELLUNG (Kundenvorgabe):
// Das System zeichnet AUSSCHLIESSLICH ANLASSBEZOGEN auf — ausgelöst
// durch ein erkanntes sicherheitsrelevantes Ereignis. Bei einem Vorfall
// werden dabei BILD UND TON aufgezeichnet. Kein Livestream, keine
// lückenlose Überwachung, KEINE DURCHGEHENDE Bild- oder Tonaufzeichnung,
// kein Dauerupload.
//
// Die frühere Aussage „keine Tonaufnahme" war sachlich falsch und wurde
// korrigiert. Weil die Prüfsumme über den Volltext gebildet wird, löst
// diese Korrektur bei allen Fahrern automatisch eine Wiedervorlage aus —
// wer die falsche Fassung bestätigt hat, bestätigt die richtige erneut.
//
// WIDERSPRUCHSRECHT — bewusste Grenze (Kundenvorgabe + Gesetz):
// Der Kurs BETONT das Widerspruchsrecht nicht mehr: es gibt kein eigenes
// Modul und kein In-App-Formular. Die gesetzliche Mindestinformation
// bleibt aber erhalten, weil ein Art.-13-Hinweis ohne Angabe des
// Widerspruchsrechts fehlerhaft wäre (Art. 13 Abs. 2 lit. b DSGVO):
//   - in beiden Volltext-Dokumenten unverändert,
//   - im Rechte-Modul als EIN nüchterner Punkt neben Art. 15–18 und 77.
//
// KEIN QUIZ: Die Module sind reine Lese-/Informationsseiten. Der
// Kenntnisnahme-Beleg besteht aus completedModuleIds, dem Scroll-Gate im
// Volltext (documentScrolledToEnd) und der Lesedauer.
//
// MEHRSPRACHIGKEIT: Inhalte liegen als `privacy_course_{lang}.json` plus
// `documents/{key}_{lang}.md` für alle 11 App-Sprachen. Der VERBINDLICHE
// Wortlaut der Empfangsbestätigung (Spec §7) bleibt in JEDER Sprache
// zusätzlich auf Deutsch sichtbar — deshalb lädt das Bundle immer auch
// die deutsche Fassung als [bindingAck] / [bindingDocument].

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Dokument-ID unter `users/{dspUid}/academy_test_results/{testId}`.
///
/// Muss exakt dem Dokumentnamen entsprechen — die Firestore-Regel
/// verlangt `request.resource.data.testId == testId`.
/// Bewusst verschieden von `'privacy'` (DSGVO-Grundschulung) und
/// `'privacy_notice'` (Art.-13-Information beim Login).
const String kPrivacyCameraTestId = 'privacy_camera';

/// Ablage der Widersprüche. Der In-App-Flow ist auf Kundenwunsch
/// abgeschaltet; Pfad und Code bleiben für Bestandsdaten erhalten.
const String kPrivacyCameraObjectionTestId = 'privacy_camera_objection';

/// Dokumenttyp der Bescheinigung im Drivers Hub unter
/// „Nachweise & Zertifikate". Wird NUR bei `acknowledged` erzeugt — bei
/// einer Verweigerung entsteht nach Spec §7 nur ein Vermerk.
const String kPrivacyCameraCertificateDocType =
    'camera_privacy_ack_certificate';

/// Version der App, die in den Nachweis geschrieben wird (Kontextfeld
/// nach Spec §5).
const String kPrivacyCameraAppVersion = '1.0.0';

/// FREISCHALTUNG FÜR FAHRER.
///
/// `false` = das Modul ist in der Fahrer-App gesperrt: Die Kacheln in der
/// DA Academy erscheinen als „Kommt bald", der Datenschutz-Bereich ist
/// nicht erreichbar, und das Modul zählt NICHT im roten Academy-Zähler
/// auf der Home-Kachel mit. Die Admin-Ansicht bleibt sichtbar.
///
/// Auf `true` setzen, sobald der Kunde die Inhalte final abgestimmt hat —
/// mehr ist für die Freischaltung nicht nötig.
const bool kPrivacyCameraDriverEnabled = true;

/// Sprache des VERBINDLICHEN Wortlauts. Bleibt in jeder Sprachfassung
/// zusätzlich sichtbar und wird immer mitgespeichert.
const String kPrivacyBindingLanguage = 'de';

/// Alle Sprachen, für die Kursinhalte ausgeliefert werden — identisch
/// zu `AppLocalizations.supportedLocales`.
const List<String> kPrivacyCourseLanguages = <String>[
  'de',
  'en',
  'sq',
  'hu',
  'ro',
  'hr',
  'ar',
  'tr',
  'ru',
  'bg',
  'es',
];

/// Asset-Pfad der Kursinhalte je Sprache.
String privacyCourseAssetFor(String languageCode) =>
    'assets/content/privacy_course_$languageCode.json';

/// Normalisiert einen Locale-Code auf eine ausgelieferte Sprache.
String privacyCourseLanguageFor(String languageCode) {
  final lang = languageCode.trim().toLowerCase().split(RegExp('[-_]')).first;
  return kPrivacyCourseLanguages.contains(lang)
      ? lang
      : kPrivacyBindingLanguage;
}

// ── Inhaltsmodell ───────────────────────────────────────────────────

@immutable
class PrivacyCourse {
  final String courseId;
  final String locale;
  final String contentVersion;
  final String title;
  final String subtitle;
  final int estimatedMinutes;
  final bool requiresAcknowledgement;
  final List<String> documentRefs;
  final Map<String, PrivacyDocumentRef> documents;
  final List<PrivacyModule> modules;
  final PrivacyAckCopy acknowledgement;
  final PrivacyCenterCopy center;

  const PrivacyCourse({
    required this.courseId,
    required this.locale,
    required this.contentVersion,
    required this.title,
    required this.subtitle,
    required this.estimatedMinutes,
    required this.requiresAcknowledgement,
    required this.documentRefs,
    required this.documents,
    required this.modules,
    required this.acknowledgement,
    required this.center,
  });

  /// Das Dokument, dessen Fassung im Nachweis festgehalten wird.
  PrivacyDocumentRef get primaryDocumentRef => documents[documentRefs.first]!;

  factory PrivacyCourse.fromJson(Map<String, dynamic> j) {
    final rawDocs = (j['documents'] as Map?)?.cast<String, dynamic>() ?? {};
    return PrivacyCourse(
      courseId: j['courseId'] as String,
      locale: j['locale'] as String? ?? kPrivacyBindingLanguage,
      contentVersion: j['contentVersion'] as String? ?? '1.0.0',
      title: j['title'] as String? ?? '',
      subtitle: j['subtitle'] as String? ?? '',
      estimatedMinutes: (j['estimatedMinutes'] as num?)?.toInt() ?? 0,
      requiresAcknowledgement: j['requiresAcknowledgement'] as bool? ?? true,
      documentRefs:
          (j['documentRefs'] as List?)?.map((e) => '$e').toList() ?? const [],
      documents: {
        for (final entry in rawDocs.entries)
          entry.key: PrivacyDocumentRef.fromJson(
            (entry.value as Map).cast<String, dynamic>(),
          ),
      },
      modules: [
        for (final m in (j['modules'] as List? ?? const []))
          PrivacyModule.fromJson((m as Map).cast<String, dynamic>()),
      ],
      acknowledgement: PrivacyAckCopy.fromJson(
        (j['acknowledgement'] as Map).cast<String, dynamic>(),
      ),
      center: PrivacyCenterCopy.fromJson(
        (j['privacyCenter'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
    );
  }
}

/// Metadaten eines Volltext-Dokuments. Der Hash wird NICHT hier
/// gepflegt, sondern beim Laden aus dem tatsächlich ausgelieferten Text
/// berechnet — dadurch löst jede Textänderung (auch das Ausfüllen der
/// Platzhalter) automatisch eine Wiedervorlage aus.
@immutable
class PrivacyDocumentRef {
  final String documentKey;
  final String title;
  final String shortTitle;
  final String version;
  final DateTime validFrom;
  final String locale;
  final String asset;

  const PrivacyDocumentRef({
    required this.documentKey,
    required this.title,
    required this.shortTitle,
    required this.version,
    required this.validFrom,
    required this.locale,
    required this.asset,
  });

  factory PrivacyDocumentRef.fromJson(Map<String, dynamic> j) =>
      PrivacyDocumentRef(
        documentKey: j['documentKey'] as String,
        title: j['title'] as String? ?? '',
        shortTitle: j['shortTitle'] as String? ?? j['title'] as String? ?? '',
        version: j['version'] as String? ?? '',
        validFrom:
            DateTime.tryParse(j['validFrom'] as String? ?? '') ??
            DateTime(1970),
        locale: j['locale'] as String? ?? kPrivacyBindingLanguage,
        asset: j['asset'] as String,
      );
}

/// Geladener Volltext samt Prüfsumme des exakt ausgelieferten Textes.
@immutable
class PrivacyDocument {
  final PrivacyDocumentRef ref;
  final String markdown;
  final String contentSha256;

  const PrivacyDocument({
    required this.ref,
    required this.markdown,
    required this.contentSha256,
  });
}

/// Ein Kursmodul — reine Lese-/Informationsseite, ohne Quiz.
@immutable
class PrivacyModule {
  final String id;
  final String title;
  final String icon;
  final int estimatedSeconds;

  /// `true` = der Volltext muss geöffnet und bis ans Ende gelesen sein.
  /// Das ist das einzige verbleibende Gate im Kurs.
  final bool requiresFullScroll;
  final List<PrivacyBlock> blocks;

  const PrivacyModule({
    required this.id,
    required this.title,
    required this.icon,
    required this.estimatedSeconds,
    required this.requiresFullScroll,
    required this.blocks,
  });

  factory PrivacyModule.fromJson(Map<String, dynamic> j) => PrivacyModule(
    id: j['id'] as String,
    title: j['title'] as String? ?? '',
    icon: j['icon'] as String? ?? 'article',
    estimatedSeconds: (j['estimatedSeconds'] as num?)?.toInt() ?? 60,
    requiresFullScroll: j['requiresFullScroll'] as bool? ?? false,
    blocks: [
      for (final b in (j['blocks'] as List? ?? const []))
        PrivacyBlock.fromJson((b as Map).cast<String, dynamic>()),
    ],
  );
}

/// Ein Inhaltsblock. `type` steuert das Rendering in
/// `lib/widgets/privacy_camera_blocks.dart`.
/// paragraph | bullets | callout | keyValue | factCard | documentEmbed
@immutable
class PrivacyBlock {
  final String type;
  final String? title;
  final String? text;
  final String? style; // info | warning | success | positive | neutral
  final List<String> items;
  final List<PrivacyKeyValue> keyValues;
  final String? documentKey;

  const PrivacyBlock({
    required this.type,
    this.title,
    this.text,
    this.style,
    this.items = const [],
    this.keyValues = const [],
    this.documentKey,
  });

  factory PrivacyBlock.fromJson(Map<String, dynamic> j) {
    final raw = j['items'] as List? ?? const [];
    final isKeyValue = raw.isNotEmpty && raw.first is Map;
    return PrivacyBlock(
      type: j['type'] as String,
      title: j['title'] as String?,
      text: j['text'] as String?,
      style: j['style'] as String?,
      items: isKeyValue ? const [] : raw.map((e) => '$e').toList(),
      keyValues: isKeyValue
          ? [
              for (final e in raw)
                PrivacyKeyValue.fromJson((e as Map).cast<String, dynamic>()),
            ]
          : const [],
      documentKey: j['documentKey'] as String?,
    );
  }
}

@immutable
class PrivacyKeyValue {
  final String key;
  final String value;
  const PrivacyKeyValue({required this.key, required this.value});

  factory PrivacyKeyValue.fromJson(Map<String, dynamic> j) =>
      PrivacyKeyValue(key: '${j['key']}', value: '${j['value']}');
}

@immutable
class PrivacyAckCopy {
  final String headline;
  final String intro;
  final String statement;
  final String clarification;
  final String systemNote;
  final String checkboxLabel;
  final String signatureHint;
  /// `false` = die Unterschrift ist Pflicht (aktueller Stand).
  final bool signatureOptional;

  /// Klarstellung DIREKT am Unterschriftsfeld: Die Unterschrift belegt
  /// den Erhalt und die Kenntnisnahme — sie ist keine Einwilligung.
  /// Ohne diesen Satz könnte die Unterschrift als Einwilligung im
  /// Beschäftigungsverhältnis missverstanden werden (§ 26 Abs. 2 BDSG).
  final String signatureLegalNote;
  final String submitLabel;
  final String declineLabel;
  final String declineExplanation;
  final String declineNote;
  final String successTitle;
  final String successText;
  final String declinedTitle;
  final String declinedText;

  const PrivacyAckCopy({
    required this.headline,
    required this.intro,
    required this.statement,
    required this.clarification,
    required this.systemNote,
    required this.checkboxLabel,
    required this.signatureHint,
    required this.signatureOptional,
    required this.signatureLegalNote,
    required this.submitLabel,
    required this.declineLabel,
    required this.declineExplanation,
    required this.declineNote,
    required this.successTitle,
    required this.successText,
    required this.declinedTitle,
    required this.declinedText,
  });

  /// Verbindlicher Wortlaut mit eingesetztem Fassungsdatum (Spec §7).
  String statementFor(String documentDate) =>
      statement.replaceAll('{{documentDate}}', documentDate);

  /// Vermerk bei Verweigerung — kein Fahrertext, nur Admin-Ansicht.
  String declineNoteFor(String date) =>
      declineNote.replaceAll('{{datum}}', date);

  factory PrivacyAckCopy.fromJson(Map<String, dynamic> j) => PrivacyAckCopy(
    headline: j['headline'] as String? ?? '',
    intro: j['intro'] as String? ?? '',
    statement: j['statement'] as String? ?? '',
    clarification: j['clarification'] as String? ?? '',
    systemNote: j['systemNote'] as String? ?? '',
    checkboxLabel: j['checkboxLabel'] as String? ?? '',
    signatureHint: j['signatureHint'] as String? ?? '',
    signatureOptional: j['signatureOptional'] as bool? ?? false,
    signatureLegalNote: j['signatureLegalNote'] as String? ?? '',
    submitLabel: j['submitLabel'] as String? ?? '',
    declineLabel: j['declineLabel'] as String? ?? '',
    declineExplanation: j['declineExplanation'] as String? ?? '',
    declineNote: j['declineNote'] as String? ?? '',
    successTitle: j['successTitle'] as String? ?? '',
    successText: j['successText'] as String? ?? '',
    declinedTitle: j['declinedTitle'] as String? ?? '',
    declinedText: j['declinedText'] as String? ?? '',
  );
}

@immutable
class PrivacyCenterCopy {
  final String headline;
  final String intro;
  final String documentsTitle;
  final String courseTitle;
  final String contactTitle;
  final String contactIntro;
  final String contactEmail;
  final String contactPlaceholderHint;
  final String contactMailSubject;

  const PrivacyCenterCopy({
    required this.headline,
    required this.intro,
    required this.documentsTitle,
    required this.courseTitle,
    required this.contactTitle,
    required this.contactIntro,
    required this.contactEmail,
    required this.contactPlaceholderHint,
    required this.contactMailSubject,
  });

  /// `true`, solange die Kontaktadresse noch ein Platzhalter aus der
  /// Vorlage ist. Dann wird kein mailto angeboten, sondern der Hinweis.
  bool get contactIsPlaceholder {
    final v = contactEmail.trim();
    return v.isEmpty || v.startsWith('[') || !v.contains('@');
  }

  factory PrivacyCenterCopy.fromJson(Map<String, dynamic> j) =>
      PrivacyCenterCopy(
        headline: j['headline'] as String? ?? 'Datenschutz',
        intro: j['intro'] as String? ?? '',
        documentsTitle: j['documentsTitle'] as String? ?? '',
        courseTitle: j['courseTitle'] as String? ?? '',
        contactTitle: j['contactTitle'] as String? ?? '',
        contactIntro: j['contactIntro'] as String? ?? '',
        contactEmail: j['contactEmail'] as String? ?? '',
        contactPlaceholderHint: j['contactPlaceholderHint'] as String? ?? '',
        contactMailSubject: j['contactMailSubject'] as String? ?? '',
      );
}

// ── Laden ───────────────────────────────────────────────────────────

/// Kurs + Volltexte in der Anzeigesprache, PLUS die deutsche Fassung als
/// verbindliche Referenz.
///
/// Warum die deutsche Fassung immer mitgeladen wird:
///  1. Der verbindliche Wortlaut der Empfangsbestätigung (Spec §7) muss
///     in jeder Sprache zusätzlich auf Deutsch sichtbar sein und wird so
///     gespeichert.
///  2. Die Prüfsumme im Nachweis wird über den DEUTSCHEN Volltext
///     gebildet. Sonst würde ein Sprachwechsel des Fahrers fälschlich
///     als „neue Fassung" gelten und eine Wiedervorlage auslösen.
class PrivacyCourseBundle {
  final String languageCode;
  final PrivacyCourse course;
  final Map<String, PrivacyDocument> documents;

  /// Deutscher Volltext — maßgeblich für Fassung und Prüfsumme.
  final PrivacyDocument bindingDocument;

  /// Deutsche Empfangsbestätigungs-Texte — verbindlicher Wortlaut.
  final PrivacyAckCopy bindingAck;

  const PrivacyCourseBundle({
    required this.languageCode,
    required this.course,
    required this.documents,
    required this.bindingDocument,
    required this.bindingAck,
  });

  /// Volltext in der Anzeigesprache.
  PrivacyDocument get primaryDocument => documents[course.documentRefs.first]!;

  /// `true`, wenn die Anzeigesprache nicht die verbindliche Sprache ist —
  /// dann wird der deutsche Wortlaut zusätzlich eingeblendet.
  bool get needsBindingTranslationBlock =>
      languageCode != kPrivacyBindingLanguage;

  static final Map<String, PrivacyCourseBundle> _cache = {};

  static Future<PrivacyCourse> _loadCourse(String lang) async {
    final raw = await rootBundle.loadString(privacyCourseAssetFor(lang));
    return PrivacyCourse.fromJson(
      (jsonDecode(raw) as Map).cast<String, dynamic>(),
    );
  }

  static Future<Map<String, PrivacyDocument>> _loadDocuments(
    PrivacyCourse course,
  ) async {
    final out = <String, PrivacyDocument>{};
    for (final entry in course.documents.entries) {
      final text = await rootBundle.loadString(entry.value.asset);
      out[entry.key] = PrivacyDocument(
        ref: entry.value,
        markdown: text,
        // Prüfsumme des exakt ausgelieferten Textes — belegt später,
        // WELCHEN Wortlaut der Fahrer gesehen hat.
        contentSha256: sha256.convert(utf8.encode(text)).toString(),
      );
    }
    return out;
  }

  /// Lädt die Inhalte für [languageCode]; fehlt eine Sprachfassung,
  /// wird auf Deutsch zurückgefallen.
  static Future<PrivacyCourseBundle> load(String languageCode) async {
    final lang = privacyCourseLanguageFor(languageCode);
    final cached = _cache[lang];
    if (cached != null) return cached;

    PrivacyCourse course;
    var effective = lang;
    try {
      course = await _loadCourse(lang);
    } catch (_) {
      effective = kPrivacyBindingLanguage;
      course = await _loadCourse(kPrivacyBindingLanguage);
    }
    final documents = await _loadDocuments(course);

    PrivacyCourse bindingCourse = course;
    Map<String, PrivacyDocument> bindingDocs = documents;
    if (effective != kPrivacyBindingLanguage) {
      bindingCourse = await _loadCourse(kPrivacyBindingLanguage);
      bindingDocs = await _loadDocuments(bindingCourse);
    }

    final bundle = PrivacyCourseBundle(
      languageCode: effective,
      course: course,
      documents: documents,
      bindingDocument: bindingDocs[bindingCourse.documentRefs.first]!,
      bindingAck: bindingCourse.acknowledgement,
    );
    _cache[lang] = bundle;
    return bundle;
  }
}

/// Icon-Namen aus dem JSON auf Material-Icons abbilden.
IconData privacyModuleIcon(String name) {
  switch (name) {
    case 'info':
      return Icons.info_outline_rounded;
    case 'videocam':
      return Icons.photo_camera_outlined;
    case 'dataset':
      return Icons.dataset_outlined;
    case 'shield':
      return Icons.shield_outlined;
    case 'group':
      return Icons.group_outlined;
    case 'schedule':
      return Icons.schedule_rounded;
    case 'gavel':
      return Icons.gavel_rounded;
    case 'directions_walk':
      return Icons.directions_walk_rounded;
    case 'description':
      return Icons.description_outlined;
    default:
      return Icons.article_outlined;
  }
}
