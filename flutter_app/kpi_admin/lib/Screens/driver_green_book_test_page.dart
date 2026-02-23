import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';

const Color _kTestText = Color(0xFF1F2937);
const Color _kTestSubText = Color(0xFF667085);
const Color _kTestGreen = Color(0xFF22AF66);
const String _academyTestsCollection = 'academy_tests';

class DriverGreenBookTestPage extends StatefulWidget {
  final String dspUid;
  final String driverTransporterId;
  final String testId;
  final VoidCallback onBack;

  const DriverGreenBookTestPage({
    super.key,
    required this.dspUid,
    required this.driverTransporterId,
    required this.onBack,
    this.testId = 'green_book',
  });

  @override
  State<DriverGreenBookTestPage> createState() =>
      _DriverGreenBookTestPageState();
}

class _DriverGreenBookTestPageState extends State<DriverGreenBookTestPage> {
  int _index = 0;
  final Map<String, String> _answers = <String, String>{};
  late Future<_RemoteTestPayload> _payloadFuture;
  String _lastLocaleCode = '';

  @override
  void initState() {
    super.initState();
    _payloadFuture = _fetchPayload();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final localeCode = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().trim();
    if (_lastLocaleCode == localeCode) return;
    _lastLocaleCode = localeCode;
    _payloadFuture = _fetchPayload();
  }

  @override
  void didUpdateWidget(covariant DriverGreenBookTestPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dspUid != widget.dspUid ||
        oldWidget.testId != widget.testId) {
      _payloadFuture = _fetchPayload();
      _index = 0;
      _answers.clear();
    }
  }

  String _fallbackLangCode() {
    final code = WidgetsBinding.instance.platformDispatcher.locale.languageCode
        .toLowerCase()
        .trim();
    return code.isEmpty ? 'en' : code;
  }

  String _safeProjectId() {
    try {
      if (Firebase.apps.isEmpty) return '';
      return Firebase.app().options.projectId;
    } catch (_) {
      return '';
    }
  }

  Set<String> _supportedLangCodes() {
    return AppLocalizations.supportedLocales
        .map((l) => l.languageCode.toLowerCase().trim())
        .where((c) => c.isNotEmpty)
        .toSet();
  }

  String _normalizeLanguageCode(String raw) {
    final trimmed = raw.trim().toLowerCase();
    if (trimmed.isEmpty) return '';
    final code = trimmed.split(RegExp(r'[-_]')).first;
    if (code.isEmpty) return '';
    final supported = _supportedLangCodes();
    return supported.contains(code) ? code : '';
  }

  String _extractLanguageCode(Map<String, dynamic> data) {
    final candidates = [
      (data['languageCode'] ?? '').toString(),
      (data['language'] ?? '').toString(),
      (data['locale'] ?? '').toString(),
      (data['preferredLanguage'] ?? '').toString(),
    ];
    for (final raw in candidates) {
      final normalized = _normalizeLanguageCode(raw);
      if (normalized.isNotEmpty) return normalized;
    }
    return '';
  }

  Future<String> _resolvePreferredLanguageCode({
    required String driverId,
  }) async {
    final authUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (authUid.isNotEmpty) {
      try {
        final userRef = FirebaseFirestore.instance
            .collection('users')
            .doc(authUid);
        DocumentSnapshot<Map<String, dynamic>> userSnap;
        try {
          userSnap = await userRef.get(const GetOptions(source: Source.server));
        } on FirebaseException {
          userSnap = await userRef.get();
        }
        final userLang = _extractLanguageCode(
          userSnap.data() ?? const <String, dynamic>{},
        );
        if (userLang.isNotEmpty) return userLang;
      } catch (_) {}
    }

    try {
      final driverRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.dspUid)
          .collection('drivers')
          .doc(driverId);
      DocumentSnapshot<Map<String, dynamic>> driverSnap;
      try {
        driverSnap = await driverRef.get(
          const GetOptions(source: Source.server),
        );
      } on FirebaseException {
        driverSnap = await driverRef.get();
      }
      return _extractLanguageCode(
        driverSnap.data() ?? const <String, dynamic>{},
      );
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final uiLangCode = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().trim();

    return FutureBuilder<_RemoteTestPayload>(
      future: _payloadFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final payload = snap.data ?? const _RemoteTestPayload();
        final contentLangCode = payload.resolvedLangCode.trim().isNotEmpty
            ? payload.resolvedLangCode
            : uiLangCode;
        final title = _localizedValue(
          data: payload.testData,
          baseKey: 'title',
          langCode: contentLangCode,
          fallback: t.t('driver_green_book_test_title'),
        );
        final passPercent = _parsePassPercent(payload.testData['passPercent']);

        final questions = payload.questions;

        if (questions.isEmpty) {
          final baseDetails = payload.testDocExists
              ? 'Path users/${widget.dspUid}/drivers/${widget.driverTransporterId.toUpperCase()}/academy_tests/${widget.testId} exists, but it has no questions array.'
              : 'No test document found at users/${widget.dspUid}/drivers/${widget.driverTransporterId.toUpperCase()}/academy_tests/${widget.testId}.';
          final diagnostic = [
            'project: ${payload.projectId}',
            'auth uid: ${payload.authUid}',
            'dsp uid: ${widget.dspUid}',
            'driver id: ${widget.driverTransporterId.toUpperCase()}',
            if (snap.hasError) 'future error: ${snap.error}',
            'Source: ${payload.source}',
            'questions type: ${payload.questionsFieldType}',
            'questions count: ${payload.questionsFieldCount}',
            'shared test exists: ${payload.sharedTestExists}',
            'shared questions count: ${payload.sharedQuestionsCount}',
            'resolved language: $contentLangCode',
            if (payload.warningMessage.trim().isNotEmpty)
              payload.warningMessage.trim(),
          ].join('\n');
          final details = '$baseDetails\n$diagnostic';
          return _CenteredMessage(
            message: t.t('driver_green_book_test_no_questions'),
            details: details,
            onBack: widget.onBack,
          );
        }

        if (_index >= questions.length) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() => _index = questions.length - 1);
          });
        }

        final safeIndex = _index.clamp(0, questions.length - 1);
        final current = questions[safeIndex];
        final selectedAnswerId = _answers[current.id];
        final progressValue = (safeIndex + 1) / questions.length;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _RoundIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: widget.onBack,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _kTestText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _RoundIconButton(
                    icon: Icons.refresh_rounded,
                    onTap: () =>
                        setState(() => _payloadFuture = _fetchPayload()),
                  ),
                ],
              ),
              if (payload.warningMessage.isNotEmpty || snap.hasError) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF59E0B)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.wifi_off_rounded,
                        color: Color(0xFF92400E),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          payload.warningMessage.isNotEmpty
                              ? payload.warningMessage
                              : t.t('driver_green_book_test_offline_fallback'),
                          style: const TextStyle(
                            color: Color(0xFF92400E),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            setState(() => _payloadFuture = _fetchPayload()),
                        child: Text(t.t('driver_green_book_test_retry')),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Text(
                t.tf('driver_green_book_test_progress', {
                  'current': '${safeIndex + 1}',
                  'total': '${questions.length}',
                }),
                style: const TextStyle(
                  color: _kTestSubText,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 10,
                  value: progressValue,
                  color: _kTestGreen,
                  backgroundColor: const Color(0xFFDDE3E7),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFDDE3E7), width: 2),
                ),
                child: Text(
                  current.statement,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _kTestText,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              ...current.options.map(
                (option) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _OptionAnswerCard(
                    label: option.text,
                    selected: selectedAnswerId == option.id,
                    onTap: () =>
                        setState(() => _answers[current.id] = option.id),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _ActionButton(
                label: safeIndex == questions.length - 1
                    ? t.t('driver_green_book_test_submit')
                    : t.t('driver_green_book_test_next'),
                enabled: selectedAnswerId != null,
                onTap: selectedAnswerId == null
                    ? null
                    : () => _onNextOrSubmit(
                        questions: questions,
                        currentIndex: safeIndex,
                        passPercent: passPercent,
                        title: title,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<_RemoteTestPayload> _fetchPayload({String? langCodeOverride}) async {
    final projectId = _safeProjectId();
    final authUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (widget.dspUid.trim().isEmpty) {
      return _RemoteTestPayload(projectId: projectId, authUid: authUid);
    }

    final driverId = widget.driverTransporterId.trim().toUpperCase();
    if (driverId.isEmpty) {
      return _RemoteTestPayload(
        warningMessage: 'Missing driver transporter ID.',
        projectId: projectId,
        authUid: authUid,
      );
    }
    final preferredLangCode = await _resolvePreferredLanguageCode(
      driverId: driverId,
    );
    final fallbackUi = _normalizeLanguageCode(
      langCodeOverride ?? _lastLocaleCode,
    );
    final fallbackPlatform = _normalizeLanguageCode(_fallbackLangCode());
    final langCode = _firstNonEmpty([
      preferredLangCode,
      fallbackUi,
      fallbackPlatform,
      'en',
    ]);

    final testRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.dspUid)
        .collection('drivers')
        .doc(driverId)
        .collection(_academyTestsCollection)
        .doc(widget.testId);
    final masterTestRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.dspUid)
        .collection(_academyTestsCollection)
        .doc(widget.testId);

    Map<String, dynamic> testData = const <String, dynamic>{};
    var testDocExists = false;
    List<_Question> questions = const [];
    String warningMessage = '';
    String source = 'driver_doc';
    String questionsFieldType = 'null';
    int questionsFieldCount = 0;
    bool sharedTestExists = false;
    int sharedQuestionsCount = 0;

    try {
      final testSnap = await testRef.get(
        const GetOptions(source: Source.server),
      );
      testData = testSnap.data() ?? const <String, dynamic>{};
      testDocExists = testSnap.exists;
    } on FirebaseException catch (e) {
      try {
        final testSnap = await testRef.get();
        testData = testSnap.data() ?? const <String, dynamic>{};
        testDocExists = testSnap.exists;
        warningMessage =
            'Using cached test settings (${e.code}). Pull to refresh when online.';
      } catch (_) {
        warningMessage = 'Could not load test settings (${e.code}).';
      }
    } catch (_) {
      warningMessage = 'Could not load test settings.';
    }

    questions = _questionsFromEmbeddedList(
      rawQuestions: testData['questions'],
      langCode: langCode,
    );
    questionsFieldType =
        testData['questions']?.runtimeType.toString() ?? 'null';
    questionsFieldCount = testData['questions'] is List
        ? (testData['questions'] as List).length
        : 0;

    // Backward-compatible fallback:
    // if driver-level academy test doc does not exist yet, read shared test doc
    // and self-heal by storing a driver-level copy.
    if (questions.isEmpty) {
      try {
        DocumentSnapshot<Map<String, dynamic>> masterSnap;
        try {
          masterSnap = await masterTestRef.get(
            const GetOptions(source: Source.server),
          );
        } on FirebaseException {
          masterSnap = await masterTestRef.get();
        }
        final masterData = masterSnap.data() ?? const <String, dynamic>{};
        if (masterSnap.exists) {
          sharedTestExists = true;
          var masterQuestions = _questionsRawFromEmbeddedList(
            masterData['questions'],
          );
          if (masterQuestions.isEmpty) {
            masterQuestions = await _loadMasterQuestions(masterTestRef);
          }
          sharedQuestionsCount = masterQuestions.length;
          if (masterQuestions.isNotEmpty) {
            testData = {
              ...masterData,
              'testId': widget.testId,
              'driverTransporterId': driverId,
              'questions': masterQuestions,
            };
            questions = _questionsFromEmbeddedList(
              rawQuestions: masterQuestions,
              langCode: langCode,
            );
            testDocExists = true;
            source = 'shared_doc_or_questions_subcollection';
            questionsFieldType =
                testData['questions']?.runtimeType.toString() ?? 'null';
            questionsFieldCount = testData['questions'] is List
                ? (testData['questions'] as List).length
                : 0;
            if (warningMessage.isEmpty) {
              warningMessage =
                  'Using shared academy test. Driver test copy will be created.';
            }
            unawaited(
              _seedDriverTestDocFromMaster(
                testRef: testRef,
                masterData: masterData,
                questions: masterQuestions,
                driverId: driverId,
              ).catchError((_) {}),
            );
          }
        }
      } on FirebaseException catch (e) {
        if (warningMessage.isEmpty) {
          warningMessage =
              'Could not load shared academy test (${e.code}). Check Firestore rules.';
        }
      } catch (_) {
        if (warningMessage.isEmpty) {
          warningMessage = 'Could not load shared academy test.';
        }
      }
    }

    try {
      return _RemoteTestPayload(
        testData: testData,
        testDocExists: testDocExists,
        questions: questions,
        warningMessage: warningMessage,
        source: source,
        questionsFieldType: questionsFieldType,
        questionsFieldCount: questionsFieldCount,
        sharedTestExists: sharedTestExists,
        sharedQuestionsCount: sharedQuestionsCount,
        resolvedLangCode: langCode,
        projectId: projectId,
        authUid: authUid,
      );
    } catch (e) {
      return _RemoteTestPayload(
        warningMessage: 'Unhandled payload build error: $e',
        source: 'loader_exception',
        resolvedLangCode: langCode,
        projectId: projectId,
        authUid: authUid,
      );
    }
  }

  List<_Question> _questionsFromEmbeddedList({
    required dynamic rawQuestions,
    required String langCode,
  }) {
    return _questionsRawFromEmbeddedList(rawQuestions)
        .asMap()
        .entries
        .map((entry) {
          final row = entry.value;
          final withFallbackId = <String, dynamic>{
            ...row,
            'id': (row['id'] ?? '').toString().trim().isEmpty
                ? 'q_${entry.key}'
                : row['id'],
          };
          return _Question.fromMap(withFallbackId, langCode: langCode);
        })
        .where((q) => q.statement.isNotEmpty)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  List<Map<String, dynamic>> _questionsRawFromEmbeddedList(
    dynamic rawQuestions,
  ) {
    if (rawQuestions is! List) return const [];
    return rawQuestions
        .whereType<Map>()
        .map((row) => row.cast<String, dynamic>())
        .toList();
  }

  List<Map<String, dynamic>> _normalizeOptions({required dynamic raw}) {
    if (raw is! List) return const [];
    final options = <Map<String, dynamic>>[];
    for (var i = 0; i < raw.length; i++) {
      final rowRaw = raw[i];
      if (rowRaw is! Map) continue;
      final row = rowRaw.cast<String, dynamic>();
      final id = (row['id'] ?? '').toString().trim();
      final option = <String, dynamic>{
        'id': id.isEmpty ? String.fromCharCode(97 + i) : id,
        'order': (row['order'] as num?)?.toInt() ?? (i + 1),
        'text': (row['text'] ?? '').toString(),
      };
      for (final entry in row.entries) {
        if (entry.key.startsWith('text_')) {
          option[entry.key] = entry.value?.toString() ?? '';
        }
      }
      options.add(option);
    }
    options.sort((a, b) {
      final aOrder = (a['order'] as num?)?.toInt() ?? 0;
      final bOrder = (b['order'] as num?)?.toInt() ?? 0;
      return aOrder.compareTo(bOrder);
    });
    return options;
  }

  Future<List<Map<String, dynamic>>> _loadMasterQuestions(
    DocumentReference<Map<String, dynamic>> masterTestRef,
  ) async {
    QuerySnapshot<Map<String, dynamic>> qSnap;
    try {
      qSnap = await masterTestRef
          .collection('questions')
          .orderBy('order')
          .get(const GetOptions(source: Source.server));
    } on FirebaseException {
      try {
        qSnap = await masterTestRef.collection('questions').get();
      } catch (_) {
        return const [];
      }
    } catch (_) {
      return const [];
    }

    final rows = qSnap.docs.map((doc) {
      final data = doc.data();
      final row = <String, dynamic>{
        'id': doc.id,
        'order': (data['order'] as num?)?.toInt() ?? 0,
        'statement': _stringOrEmpty(data['statement']),
      };
      final options = _normalizeOptions(raw: data['options']);
      if (options.isNotEmpty) {
        row['options'] = options;
        row['correctOptionId'] = (data['correctOptionId'] ?? '').toString();
      } else {
        final legacyCorrect =
            data['correctAnswer'] == true ||
            data['correct'] == true ||
            data['answer'] == true;
        row['correctOptionId'] = legacyCorrect ? 'a' : 'b';
        row['options'] = const [
          {'id': 'a', 'order': 1, 'text_en': 'True', 'text': 'True'},
          {'id': 'b', 'order': 2, 'text_en': 'False', 'text': 'False'},
        ];
      }
      for (final entry in data.entries) {
        if (entry.key.startsWith('statement_') ||
            entry.key.startsWith('question_')) {
          row[entry.key] = entry.value?.toString() ?? '';
        }
      }
      if ((row['statement'] as String).trim().isEmpty) {
        row['statement'] = _firstNonEmpty([
          _stringOrEmpty(data['question']),
          _stringOrEmpty(data['text']),
          _stringOrEmpty(data['title']),
        ]);
      }
      final statementMap = data['statement'];
      if (statementMap is Map) {
        for (final entry in statementMap.entries) {
          final code = entry.key.toString().trim().toLowerCase();
          if (code.isEmpty) continue;
          row['statement_$code'] = entry.value?.toString() ?? '';
        }
      }
      final questionMap = data['question'];
      if (questionMap is Map) {
        for (final entry in questionMap.entries) {
          final code = entry.key.toString().trim().toLowerCase();
          if (code.isEmpty) continue;
          row['question_$code'] = entry.value?.toString() ?? '';
          row['statement_$code'] ??= entry.value?.toString() ?? '';
        }
      }
      return row;
    }).toList();

    rows.sort((a, b) {
      final aOrder = (a['order'] as num?)?.toInt() ?? 0;
      final bOrder = (b['order'] as num?)?.toInt() ?? 0;
      return aOrder.compareTo(bOrder);
    });
    return rows;
  }

  Future<void> _seedDriverTestDocFromMaster({
    required DocumentReference<Map<String, dynamic>> testRef,
    required Map<String, dynamic> masterData,
    required List<Map<String, dynamic>> questions,
    required String driverId,
  }) async {
    final localizedTitles = <String, dynamic>{};
    for (final entry in masterData.entries) {
      if (entry.key.startsWith('title_')) {
        localizedTitles[entry.key] = entry.value;
      }
    }

    await testRef.set({
      'scope': 'driver',
      'dspUid': widget.dspUid,
      'driverTransporterId': driverId,
      'testId': widget.testId,
      'title': (masterData['title'] ?? '').toString().trim(),
      ...localizedTitles,
      'enabled': masterData['enabled'] != false,
      'passPercent': _parsePassPercent(masterData['passPercent']),
      'questionCount': questions.length,
      'questions': questions,
      'syncedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  String _stringOrEmpty(dynamic value) {
    if (value is String) return value.trim();
    return '';
  }

  String _firstNonEmpty(List<String> values) {
    for (final raw in values) {
      final value = raw.trim();
      if (value.isNotEmpty) return value;
    }
    return '';
  }

  Future<void> _onNextOrSubmit({
    required List<_Question> questions,
    required int currentIndex,
    required int passPercent,
    required String title,
  }) async {
    final currentQuestion = questions[currentIndex];
    final selected = _answers[currentQuestion.id];
    if (selected == null) return;

    final isLast = currentIndex >= questions.length - 1;
    if (!isLast) {
      setState(() => _index = currentIndex + 1);
      return;
    }

    final score = _calculateScore(questions);
    final total = questions.length;
    final percent = ((score * 100) / total).round();
    final passed = percent >= passPercent;

    await _saveResult(
      score: score,
      total: total,
      percent: percent,
      passed: passed,
      passPercent: passPercent,
      title: title,
    );

    if (!mounted) return;
    _showResultDialog(
      context,
      score: score,
      total: total,
      passed: passed,
      passPercent: passPercent,
    );
  }

  int _calculateScore(List<_Question> questions) {
    var score = 0;
    for (final q in questions) {
      final answer = _answers[q.id];
      if (answer != null && answer == q.correctOptionId) {
        score += 1;
      }
    }
    return score;
  }

  Future<void> _saveResult({
    required int score,
    required int total,
    required int percent,
    required bool passed,
    required int passPercent,
    required String title,
  }) async {
    if (widget.dspUid.trim().isEmpty ||
        widget.driverTransporterId.trim().isEmpty) {
      return;
    }

    final driverId = widget.driverTransporterId.trim().toUpperCase();
    final testRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.dspUid)
        .collection('drivers')
        .doc(driverId);
    final resultRef = testRef
        .collection(_academyTestsCollection)
        .doc(widget.testId);

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(resultRef);
      final data = snap.data() ?? const <String, dynamic>{};
      final attempts = (data['attempts'] as num?)?.toInt() ?? 0;
      final hadPassedBefore = data['passedEver'] == true;

      tx.set(resultRef, {
        'scope': 'driver',
        'dspUid': widget.dspUid,
        'driverTransporterId': driverId,
        'testId': widget.testId,
        'testTitle': title,
        'lastScore': score,
        'lastTotal': total,
        'lastPercent': percent,
        'passPercent': passPercent,
        'lastPassed': passed,
        'passedEver': hadPassedBefore || passed,
        'attempts': attempts + 1,
        'lastAttemptAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        if (!snap.exists) 'createdAt': FieldValue.serverTimestamp(),
        if (passed) 'lastPassedAt': FieldValue.serverTimestamp(),
        if (passed && !hadPassedBefore)
          'firstPassedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  void _showResultDialog(
    BuildContext context, {
    required int score,
    required int total,
    required bool passed,
    required int passPercent,
  }) {
    final t = AppLocalizations.of(context);

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          passed
              ? t.t('driver_green_book_test_result_pass_title')
              : t.t('driver_green_book_test_result_fail_title'),
        ),
        content: Text(
          passed
              ? t.tf('driver_green_book_test_result_pass_body', {
                  'score': '$score',
                  'total': '$total',
                })
              : t.tf('driver_green_book_test_result_fail_body', {
                  'score': '$score',
                  'total': '$total',
                }),
        ),
        actions: [
          if (!passed)
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                setState(() {
                  _index = 0;
                  _answers.clear();
                });
              },
              child: Text(t.t('driver_green_book_test_retry')),
            ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              if (passed) {
                widget.onBack();
              }
            },
            child: Text(
              passed
                  ? t.t('driver_green_book_test_back_to_green_book')
                  : t.t('driver_green_book_test_close'),
            ),
          ),
        ],
      ),
    );
  }

  String _localizedValue({
    required Map<String, dynamic> data,
    required String baseKey,
    required String langCode,
    required String fallback,
  }) {
    String pick(dynamic v) => v?.toString().trim() ?? '';

    final direct = pick(data['${baseKey}_${langCode.toLowerCase()}']);
    if (direct.isNotEmpty) return direct;

    final en = pick(data['${baseKey}_en']);
    if (en.isNotEmpty) return en;

    final generic = pick(data[baseKey]);
    if (generic.isNotEmpty) return generic;

    return fallback;
  }

  int _parsePassPercent(dynamic value) {
    final parsed =
        (value as num?)?.toInt() ?? int.tryParse(value?.toString() ?? '') ?? 80;
    return parsed.clamp(1, 100);
  }
}

class _RemoteTestPayload {
  final Map<String, dynamic> testData;
  final bool testDocExists;
  final List<_Question> questions;
  final String warningMessage;
  final String source;
  final String questionsFieldType;
  final int questionsFieldCount;
  final bool sharedTestExists;
  final int sharedQuestionsCount;
  final String resolvedLangCode;
  final String projectId;
  final String authUid;

  const _RemoteTestPayload({
    this.testData = const <String, dynamic>{},
    this.testDocExists = false,
    this.questions = const <_Question>[],
    this.warningMessage = '',
    this.source = 'driver_doc',
    this.questionsFieldType = 'null',
    this.questionsFieldCount = 0,
    this.sharedTestExists = false,
    this.sharedQuestionsCount = 0,
    this.resolvedLangCode = '',
    this.projectId = '',
    this.authUid = '',
  });
}

class _Question {
  final String id;
  final int order;
  final String statement;
  final List<_QuestionOption> options;
  final String correctOptionId;

  const _Question({
    required this.id,
    required this.order,
    required this.statement,
    required this.options,
    required this.correctOptionId,
  });

  factory _Question.fromMap(
    Map<String, dynamic> data, {
    required String langCode,
  }) {
    String pick(dynamic v) => v?.toString().trim() ?? '';
    final code = langCode.toLowerCase();

    String fromLocalizedMap(dynamic value, String key) {
      if (value is! Map) return '';
      return pick(value[key]);
    }

    final direct = _firstNonEmptyStatic([
      pick(data['statement_$code']),
      pick(data['question_$code']),
      fromLocalizedMap(data['statement'], code),
      fromLocalizedMap(data['question'], code),
    ]);
    final en = _firstNonEmptyStatic([
      pick(data['statement_en']),
      pick(data['question_en']),
      fromLocalizedMap(data['statement'], 'en'),
      fromLocalizedMap(data['question'], 'en'),
    ]);
    final generic = _firstNonEmptyStatic([
      pick(data['statement']),
      pick(data['question']),
      pick(data['text']),
      pick(data['title']),
    ]);

    final parsedOptions = <_QuestionOption>[];
    final rawOptions = data['options'];
    if (rawOptions is List) {
      for (var i = 0; i < rawOptions.length; i++) {
        final rowRaw = rawOptions[i];
        if (rowRaw is! Map) continue;
        final row = rowRaw.cast<String, dynamic>();
        final option = _QuestionOption.fromMap(row, index: i, langCode: code);
        if (option.text.trim().isEmpty) continue;
        parsedOptions.add(option);
      }
    }
    parsedOptions.sort((a, b) => a.order.compareTo(b.order));

    final hasMcqOptions = parsedOptions.isNotEmpty;
    final options = hasMcqOptions
        ? parsedOptions
        : const [
            _QuestionOption(id: 'a', order: 1, text: 'True'),
            _QuestionOption(id: 'b', order: 2, text: 'False'),
          ];

    final legacyCorrect =
        data['correctAnswer'] == true ||
        data['correct'] == true ||
        data['answer'] == true;
    var correctOptionId = (data['correctOptionId'] ?? '').toString().trim();
    if (correctOptionId.isEmpty) {
      correctOptionId = hasMcqOptions
          ? options.first.id
          : (legacyCorrect ? options.first.id : options.last.id);
    }
    if (!options.any((o) => o.id == correctOptionId)) {
      correctOptionId = options.first.id;
    }

    return _Question(
      id: _firstNonEmptyStatic([pick(data['id']), 'q_0']),
      order: (data['order'] as num?)?.toInt() ?? 0,
      statement: direct.isNotEmpty ? direct : (en.isNotEmpty ? en : generic),
      options: options,
      correctOptionId: correctOptionId,
    );
  }

  static String _firstNonEmptyStatic(List<String> values) {
    for (final raw in values) {
      final value = raw.trim();
      if (value.isNotEmpty) return value;
    }
    return '';
  }
}

class _QuestionOption {
  final String id;
  final int order;
  final String text;

  const _QuestionOption({
    required this.id,
    required this.order,
    required this.text,
  });

  factory _QuestionOption.fromMap(
    Map<String, dynamic> data, {
    required int index,
    required String langCode,
  }) {
    String pick(dynamic v) => v?.toString().trim() ?? '';

    String fromMap(dynamic value, String key) {
      if (value is! Map) return '';
      return pick(value[key]);
    }

    final id = pick(data['id']);
    final text = _Question._firstNonEmptyStatic([
      pick(data['text_$langCode']),
      pick(data['text_en']),
      fromMap(data['text'], langCode),
      fromMap(data['text'], 'en'),
      pick(data['text']),
      pick(data['label']),
      pick(data['value']),
    ]);
    return _QuestionOption(
      id: id.isNotEmpty ? id : String.fromCharCode(97 + index),
      order: (data['order'] as num?)?.toInt() ?? (index + 1),
      text: text,
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  final String message;
  final String? details;
  final VoidCallback onBack;

  const _CenteredMessage({
    required this.message,
    this.details,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _kTestSubText,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (details != null && details!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Text(
                details!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          TextButton(onPressed: onBack, child: const Text('Back')),
        ],
      ),
    );
  }
}

class _OptionAnswerCard extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _OptionAnswerCard({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final border = selected ? _kTestGreen : const Color(0xFFDDE3E7);
    final bg = selected ? const Color(0xFFE9F7F0) : Colors.white;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border, width: selected ? 2 : 1.4),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: _kTestText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = enabled ? _kTestGreen : const Color(0xFFB8DEC7);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          height: 56,
          width: double.infinity,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F3F5),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFDDE3E7), width: 1),
          ),
          child: Icon(icon, size: 24, color: _kTestText),
        ),
      ),
    );
  }
}
