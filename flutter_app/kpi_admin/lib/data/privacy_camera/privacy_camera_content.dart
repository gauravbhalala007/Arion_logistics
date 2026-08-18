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
//   - Der Kurs blockiert die App NIEMALS. Erinnerung ja, Aussperrung
//     nein — sonst wird aus der Kenntnisnahme faktisch ein Zwang und die
//     Freiwilligkeitsargumentation der DSFA fällt in sich zusammen.
//
// INHALTLICHE KLARSTELLUNG (Kundenvorgabe):
// Das System nimmt AUSSCHLIESSLICH ANLASSBEZOGEN FOTOS auf — ausgelöst
// durch ein erkanntes sicherheitsrelevantes Ereignis. Kein Livestream,
// keine lückenlose Überwachung, keine Daueraufzeichnung, kein
// Dauerupload. Diese Aussage trägt die Verhältnismäßigkeit der DSFA und
// darf in den Inhalten nicht verwässert werden.
//
// Inhalte liegen als Asset-JSON (`assets/content/privacy_course_de.json`)
// plus zwei Markdown-Volltexten unter `assets/content/documents/`. Damit
// lassen sich Texte ohne Code-Änderung pflegen, und weitere Sprachen
// docken später als `privacy_course_{lang}.json` an.

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

/// Ablage der Widersprüche — gleiche Regelmechanik, eigener Zweig.
const String kPrivacyCameraObjectionTestId = 'privacy_camera_objection';

/// Dokumenttyp der Bescheinigung im Drivers Hub unter
/// „Nachweise & Zertifikate". Wird NUR bei `acknowledged` erzeugt — bei
/// einer Verweigerung entsteht nach Spec §7 nur ein Vermerk.
const String kPrivacyCameraCertificateDocType =
    'camera_privacy_ack_certificate';

/// Asset-Pfad der Kursinhalte je Sprache.
String privacyCourseAssetFor(String languageCode) =>
    'assets/content/privacy_course_${languageCode.toLowerCase()}.json';

/// Sprache, die als Inhalt v1 ausgeliefert wird. Weitere Sprachen
/// brauchen nur eine weitere JSON-Datei mit gleicher Struktur.
const String kPrivacyCourseFallbackLanguage = 'de';

/// Version der App, die in den Nachweis geschrieben wird (Kontextfeld
/// nach Spec §5). Bei Releases mit geänderten Inhalten mitziehen.
const String kPrivacyCameraAppVersion = '1.0.0';

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
  final PrivacyObjectionCopy objectionForm;
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
    required this.objectionForm,
    required this.center,
  });

  /// Das Dokument, dessen Fassung im Nachweis festgehalten wird.
  PrivacyDocumentRef get primaryDocument => documents[documentRefs.first]!;

  int get quizTotal => modules.fold(0, (sum, m) => sum + m.quiz.length);

  factory PrivacyCourse.fromJson(Map<String, dynamic> j) {
    final rawDocs = (j['documents'] as Map?)?.cast<String, dynamic>() ?? {};
    return PrivacyCourse(
      courseId: j['courseId'] as String,
      locale: j['locale'] as String? ?? 'de-DE',
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
      objectionForm: PrivacyObjectionCopy.fromJson(
        (j['objectionForm'] as Map).cast<String, dynamic>(),
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
        locale: j['locale'] as String? ?? 'de-DE',
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

@immutable
class PrivacyModule {
  final String id;
  final String title;
  final String icon;
  final int estimatedSeconds;

  /// `true` = der Volltext muss geöffnet und bis ans Ende gelesen sein.
  final bool requiresFullScroll;
  final List<PrivacyBlock> blocks;
  final List<PrivacyQuizQuestion> quiz;

  const PrivacyModule({
    required this.id,
    required this.title,
    required this.icon,
    required this.estimatedSeconds,
    required this.requiresFullScroll,
    required this.blocks,
    required this.quiz,
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
    quiz: [
      for (final q in (j['quiz'] as List? ?? const []))
        PrivacyQuizQuestion.fromJson((q as Map).cast<String, dynamic>()),
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

/// Quizfrage. Das Quiz ist KEIN Bestehens-Gate: eine falsche Antwort
/// blockiert nicht, sondern zeigt die Erklärung. Der Punktestand wandert
/// in den Nachweis und belegt „es wurde informiert, nicht weggeklickt".
@immutable
class PrivacyQuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const PrivacyQuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  factory PrivacyQuizQuestion.fromJson(Map<String, dynamic> j) =>
      PrivacyQuizQuestion(
        id: j['id'] as String,
        question: j['question'] as String,
        options: (j['options'] as List).map((e) => '$e').toList(),
        correctIndex: (j['correctIndex'] as num).toInt(),
        explanation: j['explanation'] as String? ?? '',
      );
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
  final bool signatureOptional;
  final String signatureOptionalHint;

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
    required this.signatureOptionalHint,
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
  String declineNoteFor(String date) => declineNote.replaceAll('{{datum}}', date);

  factory PrivacyAckCopy.fromJson(Map<String, dynamic> j) => PrivacyAckCopy(
    headline: j['headline'] as String? ?? '',
    intro: j['intro'] as String? ?? '',
    statement: j['statement'] as String? ?? '',
    clarification: j['clarification'] as String? ?? '',
    systemNote: j['systemNote'] as String? ?? '',
    checkboxLabel: j['checkboxLabel'] as String? ?? '',
    signatureHint: j['signatureHint'] as String? ?? '',
    signatureOptional: j['signatureOptional'] as bool? ?? true,
    signatureOptionalHint: j['signatureOptionalHint'] as String? ?? '',
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
class PrivacyObjectionCopy {
  final String headline;
  final String intro;
  final String statement;
  final String reasonLabel;
  final String reasonHint;
  final String consequences;
  final String submitLabel;
  final String withdrawLabel;
  final String successTitle;
  final String successText;
  final String activeTitle;
  final String withdrawnTitle;
  final String withdrawnText;

  const PrivacyObjectionCopy({
    required this.headline,
    required this.intro,
    required this.statement,
    required this.reasonLabel,
    required this.reasonHint,
    required this.consequences,
    required this.submitLabel,
    required this.withdrawLabel,
    required this.successTitle,
    required this.successText,
    required this.activeTitle,
    required this.withdrawnTitle,
    required this.withdrawnText,
  });

  factory PrivacyObjectionCopy.fromJson(Map<String, dynamic> j) =>
      PrivacyObjectionCopy(
        headline: j['headline'] as String? ?? '',
        intro: j['intro'] as String? ?? '',
        statement: j['statement'] as String? ?? '',
        reasonLabel: j['reasonLabel'] as String? ?? '',
        reasonHint: j['reasonHint'] as String? ?? '',
        consequences: j['consequences'] as String? ?? '',
        submitLabel: j['submitLabel'] as String? ?? '',
        withdrawLabel: j['withdrawLabel'] as String? ?? '',
        successTitle: j['successTitle'] as String? ?? '',
        successText: j['successText'] as String? ?? '',
        activeTitle: j['activeTitle'] as String? ?? '',
        withdrawnTitle: j['withdrawnTitle'] as String? ?? '',
        withdrawnText: j['withdrawnText'] as String? ?? '',
      );
}

@immutable
class PrivacyCenterCopy {
  final String headline;
  final String intro;
  final String documentsTitle;
  final String courseTitle;
  final String objectionTitle;
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
    required this.objectionTitle,
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
        objectionTitle: j['objectionTitle'] as String? ?? '',
        contactTitle: j['contactTitle'] as String? ?? '',
        contactIntro: j['contactIntro'] as String? ?? '',
        contactEmail: j['contactEmail'] as String? ?? '',
        contactPlaceholderHint: j['contactPlaceholderHint'] as String? ?? '',
        contactMailSubject: j['contactMailSubject'] as String? ?? '',
      );
}

// ── Laden ───────────────────────────────────────────────────────────

/// Lädt Kurs + Volltexte einmal und hält sie im Speicher. Die Inhalte
/// sind Assets und ändern sich zur Laufzeit nicht.
class PrivacyCourseBundle {
  final PrivacyCourse course;
  final Map<String, PrivacyDocument> documents;

  const PrivacyCourseBundle({required this.course, required this.documents});

  PrivacyDocument get primaryDocument =>
      documents[course.documentRefs.first]!;

  static final Map<String, PrivacyCourseBundle> _cache = {};

  /// Lädt die Inhalte für [languageCode] und fällt auf Deutsch zurück,
  /// solange keine Übersetzung ausgeliefert wird.
  static Future<PrivacyCourseBundle> load(String languageCode) async {
    final lang = languageCode.trim().toLowerCase();
    final cached = _cache[lang];
    if (cached != null) return cached;

    String raw;
    try {
      raw = await rootBundle.loadString(privacyCourseAssetFor(lang));
    } catch (_) {
      raw = await rootBundle.loadString(
        privacyCourseAssetFor(kPrivacyCourseFallbackLanguage),
      );
    }
    final course = PrivacyCourse.fromJson(
      (jsonDecode(raw) as Map).cast<String, dynamic>(),
    );

    final docs = <String, PrivacyDocument>{};
    for (final entry in course.documents.entries) {
      final text = await rootBundle.loadString(entry.value.asset);
      docs[entry.key] = PrivacyDocument(
        ref: entry.value,
        markdown: text,
        // Prüfsumme des exakt ausgelieferten Textes — belegt später,
        // WELCHEN Wortlaut der Fahrer gesehen hat.
        contentSha256: sha256.convert(utf8.encode(text)).toString(),
      );
    }

    final bundle = PrivacyCourseBundle(course: course, documents: docs);
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
    case 'block':
      return Icons.block_flipped;
    case 'directions_walk':
      return Icons.directions_walk_rounded;
    case 'description':
      return Icons.description_outlined;
    default:
      return Icons.article_outlined;
  }
}
