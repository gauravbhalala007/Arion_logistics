import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

const String _academyTestsCollection = 'academy_tests';
const Color _kAcademyGreen = Color(0xFF1D7F5A);
const Color _kAcademyText = Color(0xFF111827);
const Color _kAcademySubText = Color(0xFF4B5563);
const Color _kAcademyMuted = Color(0xFF6B7280);
const Color _kAcademyCardBg = Color(0xFFF9FAFB);
const Color _kAcademyCardBorder = Color(0xFFE5E7EB);

enum _AcademyTab { builder, results }

class AdminAcademyPage extends StatefulWidget {
  const AdminAcademyPage({super.key});

  @override
  State<AdminAcademyPage> createState() => _AdminAcademyPageState();
}

class _AdminAcademyPageState extends State<AdminAcademyPage> {
  static const List<_TestPreset> _presets = [
    _TestPreset(id: 'green_book', label: 'Green Book Test'),
    _TestPreset(id: 'safety_training', label: 'Safety Training Test'),
    _TestPreset(id: 'amazon_delivery', label: 'Amazon Delivery Test'),
  ];

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;
  String? _resolvedDspUid;

  String _selectedTestId = _presets.first.id;
  _AcademyTab _activeTab = _AcademyTab.builder;

  @override
  void initState() {
    super.initState();
    _loadDspScope();
  }

  String? get _scopeUid {
    final uid = _uid;
    if (uid == null) return null;
    final scoped = (_resolvedDspUid ?? '').trim();
    if (scoped.isNotEmpty) return scoped;
    return uid;
  }

  Future<void> _loadDspScope() async {
    final uid = _uid;
    if (uid == null) return;
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final data = snap.data() ?? const <String, dynamic>{};
      final dspUid = (data['dspUid'] ?? '').toString().trim();
      if (!mounted) return;
      setState(() {
        _resolvedDspUid = dspUid.isNotEmpty ? dspUid : uid;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _resolvedDspUid = uid;
      });
    }
  }

  CollectionReference<Map<String, dynamic>>? get _testsCol {
    final uid = _scopeUid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection(_academyTestsCollection);
  }

  CollectionReference<Map<String, dynamic>>? get _driversCol {
    final uid = _scopeUid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('drivers');
  }

  void _showSnack(String message, {bool error = false}) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? const Color(0xFFB91C1C) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final col = _testsCol;
    if (col == null) {
      return const Center(child: Text('You must be logged in as admin.'));
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: col.snapshots(),
      builder: (context, snap) {
        final scopeUid = _scopeUid ?? _uid ?? '';
        final docs = snap.data?.docs ?? const [];
        final options = _resolveTestOptions(docs);
        final selectedExists = options.any((o) => o.id == _selectedTestId);
        final effectiveSelected = selectedExists
            ? _selectedTestId
            : (options.isEmpty ? _presets.first.id : options.first.id);

        if (!selectedExists && _selectedTestId != effectiveSelected) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() => _selectedTestId = effectiveSelected);
          });
        }

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                runSpacing: 8,
                children: const [
                  Icon(Icons.school_outlined, size: 22, color: _kAcademyGreen),
                  Text(
                    'DA Academy',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: _kAcademyText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (scopeUid.isNotEmpty)
                Text(
                  'DSP scope: $scopeUid',
                  style: const TextStyle(
                    color: _kAcademyMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (scopeUid.isNotEmpty) const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 280,
                      maxWidth: 380,
                    ),
                    child: DropdownButtonFormField<String>(
                      initialValue: effectiveSelected,
                      decoration: InputDecoration(
                        labelText: 'Test',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: _kAcademyCardBorder,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: _kAcademyCardBorder,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: _kAcademyGreen,
                            width: 1.2,
                          ),
                        ),
                      ),
                      items: options
                          .map(
                            (o) => DropdownMenuItem<String>(
                              value: o.id,
                              child: Text(o.label),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _selectedTestId = v);
                      },
                    ),
                  ),
                  SegmentedButton<_AcademyTab>(
                    segments: const [
                      ButtonSegment<_AcademyTab>(
                        value: _AcademyTab.builder,
                        icon: Icon(Icons.edit_outlined),
                        label: Text('Test Builder'),
                      ),
                      ButtonSegment<_AcademyTab>(
                        value: _AcademyTab.results,
                        icon: Icon(Icons.analytics_outlined),
                        label: Text('Results'),
                      ),
                    ],
                    selected: {_activeTab},
                    onSelectionChanged: (selection) {
                      setState(() => _activeTab = selection.first);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: _activeTab == _AcademyTab.builder
                    ? _buildTestBuilder(
                        testId: effectiveSelected,
                        testOptions: options,
                      )
                    : _buildResults(
                        testId: effectiveSelected,
                        testOptions: options,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTestBuilder({
    required String testId,
    required List<_TestOption> testOptions,
  }) {
    final col = _testsCol;
    if (col == null) {
      return const Center(
        child: Text('Session expired. Please sign in again.'),
      );
    }
    final testRef = col.doc(testId);
    final questionsRef = testRef.collection('questions');

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: testRef.snapshots(),
      builder: (context, testSnap) {
        final testData = testSnap.data?.data() ?? const <String, dynamic>{};
        final testLabel = _labelForTest(testId, testOptions);
        final passPercent = _parsePassPercent(testData['passPercent']);
        final titles = _collectLocalizedText(testData, 'title');
        final titlePreview = titles['en']?.trim().isNotEmpty == true
            ? titles['en']!.trim()
            : testLabel;

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: questionsRef.orderBy('order').snapshots(),
          builder: (context, qSnap) {
            final qDocs = qSnap.data?.docs ?? const [];
            final questions = qDocs.map(_AcademyQuestion.fromDoc).toList();
            final hasQuestions = questions.isNotEmpty;

            return ListView(
              children: [
                _SectionCard(
                  title: 'Test Settings',
                  subtitle: 'Configure title and pass threshold for this test.',
                  icon: Icons.tune_outlined,
                  trailing: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _syncTestToDrivers(testId: testId),
                        icon: const Icon(Icons.sync_outlined),
                        label: const Text('Sync to drivers'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _openTestSettingsEditor(
                          testId: testId,
                          initialData: testData,
                          fallbackLabel: testLabel,
                        ),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit settings'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _openQuestionEditor(testId: testId),
                        icon: const Icon(Icons.add),
                        label: const Text('Add question'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kAcademyGreen,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoRow(label: 'Title', value: titlePreview),
                      const SizedBox(height: 8),
                      _InfoRow(label: 'Pass threshold', value: '$passPercent%'),
                      const SizedBox(height: 8),
                      _InfoRow(
                        label: 'Questions',
                        value: '${questions.length}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Question Bank',
                  subtitle: hasQuestions
                      ? 'Manage ordering, answer key, and localized statements.'
                      : 'No questions configured yet.',
                  icon: Icons.quiz_outlined,
                  trailing: !hasQuestions
                      ? OutlinedButton.icon(
                          onPressed: () =>
                              _seedDefaultQuestions(testId: testId),
                          icon: const Icon(Icons.auto_fix_high_outlined),
                          label: const Text('Seed defaults'),
                        )
                      : null,
                  child: hasQuestions
                      ? Column(
                          children: questions
                              .map(
                                (q) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _QuestionCard(
                                    question: q,
                                    onEdit: () => _openQuestionEditor(
                                      testId: testId,
                                      existing: q,
                                    ),
                                    onDelete: () => _deleteQuestion(
                                      testId: testId,
                                      question: q,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        )
                      : Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _kAcademyCardBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: _kAcademyCardBorder),
                          ),
                          child: const Text(
                            'Drivers will see no questions until you add and sync them.',
                            style: TextStyle(color: _kAcademySubText),
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildResults({
    required String testId,
    required List<_TestOption> testOptions,
  }) {
    final driversCol = _driversCol;
    if (driversCol == null) {
      return const Center(
        child: Text('Session expired. Please sign in again.'),
      );
    }
    final driversStream = driversCol.snapshots();
    final testLabel = _labelForTest(testId, testOptions);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: driversStream,
      builder: (context, driversSnap) {
        final driverDocs = driversSnap.data?.docs ?? const [];
        return FutureBuilder<List<_DriverTestResult>>(
          future: _loadDriverResultsForTest(
            testId: testId,
            driverDocs: driverDocs,
          ),
          builder: (context, resultSnap) {
            final results = resultSnap.data ?? const <_DriverTestResult>[];
            final totalDrivers = driverDocs.length;
            final attempted = results.where((r) => r.attempts > 0).length;
            final neverAttempted = totalDrivers > attempted
                ? totalDrivers - attempted
                : 0;
            final passedEver = results.where((r) => r.passedEver).length;
            final lastPassed = results
                .where((r) => r.attempts > 0 && r.lastPassed)
                .length;

            return ListView(
              children: [
                _SectionCard(
                  title: 'Results: $testLabel',
                  subtitle:
                      'Completion per driver (notifications-style storage).',
                  icon: Icons.insights_outlined,
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _MetricChip(label: 'Drivers', value: '$totalDrivers'),
                      _MetricChip(label: 'Attempted', value: '$attempted'),
                      _MetricChip(
                        label: 'Never attempted',
                        value: '$neverAttempted',
                      ),
                      _MetricChip(
                        label: 'Last attempt passed',
                        value: '$lastPassed',
                      ),
                      _MetricChip(label: 'Passed ever', value: '$passedEver'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Driver Results',
                  subtitle: results.isEmpty
                      ? 'No drivers found for this DSP yet.'
                      : 'Each row is users/{dspUid}/drivers/{driverId}/academy_tests/$testId',
                  icon: Icons.person_search_outlined,
                  child: resultSnap.connectionState == ConnectionState.waiting
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : results.isEmpty
                      ? const Text(
                          'No results available for this test yet.',
                          style: TextStyle(color: _kAcademySubText),
                        )
                      : Column(
                          children: results
                              .map(
                                (r) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _ResultCard(result: r),
                                ),
                              )
                              .toList(),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<List<_DriverTestResult>> _loadDriverResultsForTest({
    required String testId,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> driverDocs,
  }) async {
    final out = <_DriverTestResult>[];
    for (final doc in driverDocs) {
      final driverId = doc.id.trim().toUpperCase();
      final driverName = _driverName(doc.data(), fallback: driverId);
      try {
        final snap = await doc.reference
            .collection(_academyTestsCollection)
            .doc(testId)
            .get();
        out.add(
          _DriverTestResult.fromDriverTestDoc(
            driverId: driverId,
            driverName: driverName,
            doc: snap,
          ),
        );
      } catch (_) {
        out.add(
          _DriverTestResult(
            driverTransporterId: driverId,
            driverName: driverName,
            lastPassed: false,
            passedEver: false,
            attempts: 0,
            score: 0,
            total: 0,
            percent: 0,
            lastAttemptAt: null,
          ),
        );
      }
    }

    out.sort((a, b) {
      final aAt = a.lastAttemptAt?.millisecondsSinceEpoch ?? -1;
      final bAt = b.lastAttemptAt?.millisecondsSinceEpoch ?? -1;
      if (aAt != bAt) return bAt.compareTo(aAt);
      return a.driverName.toLowerCase().compareTo(b.driverName.toLowerCase());
    });
    return out;
  }

  Future<void> _syncTestToDrivers({required String testId}) async {
    final scopeUid = _scopeUid;
    final testsCol = _testsCol;
    final driversCol = _driversCol;
    if (scopeUid == null || testsCol == null || driversCol == null) {
      _showSnack('Missing DSP scope.', error: true);
      return;
    }

    try {
      final testRef = testsCol.doc(testId);
      final testSnap = await testRef.get();
      final testData = testSnap.data() ?? const <String, dynamic>{};
      final passPercent = _parsePassPercent(testData['passPercent']);
      final enabled = testData['enabled'] != false;
      final localizedTitles = <String, dynamic>{};
      for (final key in testData.keys) {
        if (key.startsWith('title_')) {
          localizedTitles[key] = testData[key];
        }
      }

      final qSnap = await testRef.collection('questions').get();
      final qDocs = [...qSnap.docs]
        ..sort((a, b) {
          final aOrder = (a.data()['order'] as num?)?.toInt() ?? 0;
          final bOrder = (b.data()['order'] as num?)?.toInt() ?? 0;
          return aOrder.compareTo(bOrder);
        });

      final questions = qDocs.map(_questionPayloadFromDoc).toList();
      final title = _firstNonEmpty([
        (testData['title_en'] ?? '').toString(),
        (testData['title'] ?? '').toString(),
        _presetLabelFor(testId),
      ]);

      final driversSnap = await driversCol.get();
      final drivers = driversSnap.docs;
      if (drivers.isEmpty) {
        _showSnack('No drivers found to sync.');
        return;
      }

      const chunkSize = 350;
      final db = FirebaseFirestore.instance;
      for (var i = 0; i < drivers.length; i += chunkSize) {
        final end = (i + chunkSize > drivers.length)
            ? drivers.length
            : i + chunkSize;
        final batch = db.batch();
        for (final driver in drivers.sublist(i, end)) {
          final driverId = driver.id.trim().toUpperCase();
          final target = driver.reference
              .collection(_academyTestsCollection)
              .doc(testId);
          batch.set(target, {
            'scope': 'driver',
            'dspUid': scopeUid,
            'driverTransporterId': driverId,
            'testId': testId,
            'title': title,
            ...localizedTitles,
            'enabled': enabled,
            'passPercent': passPercent,
            'questionCount': questions.length,
            'questions': questions,
            'syncedAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
        await batch.commit();
      }

      _showSnack(
        'Synced "$title" to ${drivers.length} driver${drivers.length == 1 ? '' : 's'}.',
      );
    } catch (e) {
      _showSnack('Failed to sync test to drivers: $e', error: true);
    }
  }

  Map<String, dynamic> _questionPayloadFromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    final question = _AcademyQuestion.fromMap(id: doc.id, data: data);
    return question.toPayload();
  }

  List<_TestOption> _resolveTestOptions(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final map = <String, _TestOption>{};
    for (final preset in _presets) {
      map[preset.id] = _TestOption(id: preset.id, label: preset.label);
    }

    for (final d in docs) {
      final data = d.data();
      final id = d.id.trim();
      if (id.isEmpty) continue;
      final label = _firstNonEmpty([
        (data['title_en'] ?? '').toString(),
        (data['title'] ?? '').toString(),
        map[id]?.label ?? '',
        id,
      ]);
      map[id] = _TestOption(id: id, label: label);
    }

    final out = map.values.toList()
      ..sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));
    return out;
  }

  String _labelForTest(String testId, List<_TestOption> options) {
    return options
        .firstWhere(
          (o) => o.id == testId,
          orElse: () => _TestOption(id: testId, label: testId),
        )
        .label;
  }

  Future<void> _openTestSettingsEditor({
    required String testId,
    required Map<String, dynamic> initialData,
    required String fallbackLabel,
  }) async {
    final testsCol = _testsCol;
    if (testsCol == null) {
      _showSnack('Session expired. Please sign in again.', error: true);
      return;
    }

    final locales = ['en', ..._supportedLocaleCodes().where((c) => c != 'en')];
    final titleCtrls = <String, TextEditingController>{};
    for (final code in locales) {
      titleCtrls[code] = TextEditingController(
        text: (initialData['title_$code'] ?? '').toString(),
      );
    }
    final passCtrl = TextEditingController(
      text: _parsePassPercent(initialData['passPercent']).toString(),
    );
    bool enabled = initialData['enabled'] != false;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setInnerState) => AlertDialog(
          title: Text('Edit settings: $fallbackLabel'),
          content: SizedBox(
            width: 620,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: passCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Pass threshold (%)',
                    ),
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    value: enabled,
                    onChanged: (v) => setInnerState(() => enabled = v),
                    title: const Text('Test enabled'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 8),
                  ...locales.map((code) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TextField(
                        controller: titleCtrls[code],
                        decoration: InputDecoration(labelText: 'Title ($code)'),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final parsed = int.tryParse(passCtrl.text.trim()) ?? 80;
                final passPercent = parsed.clamp(1, 100);
                final payload = <String, dynamic>{
                  'testId': testId,
                  'passPercent': passPercent,
                  'enabled': enabled,
                  'updatedAt': FieldValue.serverTimestamp(),
                };
                for (final code in locales) {
                  payload['title_$code'] = titleCtrls[code]!.text.trim();
                }
                payload['title'] = _firstNonEmpty([
                  payload['title_en']?.toString() ?? '',
                  payload['title_de']?.toString() ?? '',
                  fallbackLabel,
                ]);

                try {
                  await testsCol
                      .doc(testId)
                      .set(payload, SetOptions(merge: true));
                  await _syncTestToDrivers(testId: testId);
                  if (!mounted) return;
                  if (!ctx.mounted) return;
                  Navigator.of(ctx).pop();
                  _showSnack('Test settings saved.');
                } catch (e) {
                  _showSnack('Failed to save settings: $e', error: true);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    passCtrl.dispose();
    for (final c in titleCtrls.values) {
      c.dispose();
    }
  }

  Future<void> _openQuestionEditor({
    required String testId,
    _AcademyQuestion? existing,
  }) async {
    final testsCol = _testsCol;
    if (testsCol == null) {
      _showSnack('Session expired. Please sign in again.', error: true);
      return;
    }

    final locales = ['en', ..._supportedLocaleCodes().where((c) => c != 'en')];
    final statementCtrls = <String, TextEditingController>{};
    for (final code in locales) {
      statementCtrls[code] = TextEditingController(
        text: existing?.localizedStatements[code] ?? '',
      );
    }

    const optionIds = ['a', 'b', 'c', 'd'];
    final optionEnCtrls = <String, TextEditingController>{};
    final optionLocalizedById = <String, Map<String, String>>{};
    for (final id in optionIds) {
      optionEnCtrls[id] = TextEditingController();
      optionLocalizedById[id] = <String, String>{};
    }

    var optionCount = 4;
    var correctOptionId = 'a';
    if (existing != null && existing.options.isNotEmpty) {
      final prefilledCount = existing.options.length.clamp(0, 4);
      optionCount = prefilledCount >= 3 ? prefilledCount : 3;
      for (var i = 0; i < prefilledCount; i++) {
        final id = optionIds[i];
        final option = existing.options[i];
        optionEnCtrls[id]!.text = option.textFor('en');
        optionLocalizedById[id] = Map<String, String>.from(
          option.localizedTexts,
        );
      }

      final correctIndex = existing.options.indexWhere(
        (o) => o.id == existing.correctOptionId,
      );
      if (correctIndex >= 0 && correctIndex < optionCount) {
        correctOptionId = optionIds[correctIndex];
      }
    }

    var isAutoTranslating = false;
    final questionsRef = testsCol.doc(testId).collection('questions');
    var initialOrder = existing?.order ?? 10;
    if (existing == null) {
      try {
        final last = await questionsRef
            .orderBy('order', descending: true)
            .limit(1)
            .get();
        final topOrder = (last.docs.isEmpty
            ? 0
            : (last.docs.first.data()['order'] as num?)?.toInt() ?? 0);
        initialOrder = topOrder + 10;
      } catch (_) {
        // Keep a safe default when permission/network/index checks fail.
        initialOrder = 10;
      }
    }
    if (!mounted) return;
    final orderCtrl = TextEditingController(text: '$initialOrder');

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setInnerState) => AlertDialog(
          title: Text(existing == null ? 'Add question' : 'Edit question'),
          content: SizedBox(
            width: 680,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: orderCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Order'),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    initialValue: optionCount,
                    decoration: const InputDecoration(
                      labelText: 'Option count',
                    ),
                    items: const [
                      DropdownMenuItem(value: 3, child: Text('3 options')),
                      DropdownMenuItem(value: 4, child: Text('4 options')),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      setInnerState(() {
                        optionCount = v;
                        if (!optionIds
                            .sublist(0, optionCount)
                            .contains(correctOptionId)) {
                          correctOptionId = optionIds.first;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Question Statement',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: _kAcademyText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: isAutoTranslating
                          ? null
                          : () async {
                              setInnerState(() => isAutoTranslating = true);
                              await _autoTranslateMissingQuestionFields(
                                localeCodes: locales,
                                statementCtrls: statementCtrls,
                                optionIds: optionIds.sublist(0, optionCount),
                                optionEnCtrls: optionEnCtrls,
                                optionLocalizedById: optionLocalizedById,
                              );
                              if (!mounted || !ctx.mounted) return;
                              setInnerState(() => isAutoTranslating = false);
                            },
                      icon: isAutoTranslating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.translate_outlined),
                      label: Text(
                        isAutoTranslating
                            ? 'Translating...'
                            : 'Auto translate missing',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...locales.map((code) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TextField(
                        controller: statementCtrls[code],
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Statement ($code)',
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Answer Options',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: _kAcademyText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(optionCount, (index) {
                    final id = optionIds[index];
                    final letter = String.fromCharCode(65 + index);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Radio<String>(
                            value: id,
                            groupValue: correctOptionId,
                            onChanged: (value) {
                              if (value == null) return;
                              setInnerState(() => correctOptionId = value);
                            },
                          ),
                          Expanded(
                            child: TextField(
                              controller: optionEnCtrls[id],
                              decoration: InputDecoration(
                                labelText: 'Option $letter (en)',
                                helperText: correctOptionId == id
                                    ? 'Marked as correct answer'
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _autoTranslateMissingQuestionFields(
                  localeCodes: locales,
                  statementCtrls: statementCtrls,
                  optionIds: optionIds.sublist(0, optionCount),
                  optionEnCtrls: optionEnCtrls,
                  optionLocalizedById: optionLocalizedById,
                );

                final enStatement = statementCtrls['en']!.text.trim();
                final firstFilled = statementCtrls.values
                    .map((c) => c.text.trim())
                    .firstWhere((v) => v.isNotEmpty, orElse: () => '');
                if (enStatement.isEmpty && firstFilled.isEmpty) {
                  _showSnack(
                    'Please enter at least one statement.',
                    error: true,
                  );
                  return;
                }

                final activeOptionIds = optionIds.sublist(0, optionCount);
                final options = <Map<String, dynamic>>[];
                final normalizedOptionTexts = <String>{};
                for (var i = 0; i < activeOptionIds.length; i++) {
                  final optionId = activeOptionIds[i];
                  final enText = optionEnCtrls[optionId]!.text.trim();
                  if (enText.isEmpty) {
                    _showSnack('Please fill all answer options.', error: true);
                    return;
                  }
                  final normalized = enText.toLowerCase();
                  if (!normalizedOptionTexts.add(normalized)) {
                    _showSnack(
                      'Options must be different from each other.',
                      error: true,
                    );
                    return;
                  }

                  final localized =
                      optionLocalizedById[optionId] ?? <String, String>{};
                  localized['en'] = enText;
                  final optionPayload = <String, dynamic>{
                    'id': optionId,
                    'order': i + 1,
                    'text': enText,
                  };
                  for (final code in locales) {
                    final value = code == 'en'
                        ? enText
                        : (localized[code] ?? '').trim();
                    if (value.isNotEmpty) {
                      optionPayload['text_$code'] = value;
                    }
                  }
                  options.add(optionPayload);
                }

                if (!activeOptionIds.contains(correctOptionId)) {
                  _showSnack('Select a correct answer option.', error: true);
                  return;
                }

                final order =
                    int.tryParse(orderCtrl.text.trim()) ??
                    (existing?.order ?? 10);
                final payload = <String, dynamic>{
                  'order': order,
                  'correctOptionId': correctOptionId,
                  'options': options,
                  'updatedAt': FieldValue.serverTimestamp(),
                };

                for (final code in locales) {
                  payload['statement_$code'] = statementCtrls[code]!.text
                      .trim();
                }
                payload['statement'] = _firstNonEmpty([
                  enStatement,
                  firstFilled,
                ]);

                try {
                  final target = existing == null
                      ? questionsRef.doc()
                      : questionsRef.doc(existing.id);
                  await target.set({
                    ...payload,
                    if (existing == null)
                      'createdAt': FieldValue.serverTimestamp(),
                  }, SetOptions(merge: true));
                  await _syncTestToDrivers(testId: testId);
                  if (!mounted) return;
                  if (!ctx.mounted) return;
                  Navigator.of(ctx).pop();
                  _showSnack(
                    existing == null ? 'Question added.' : 'Question updated.',
                  );
                } catch (e) {
                  _showSnack('Failed to save question: $e', error: true);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    orderCtrl.dispose();
    for (final c in statementCtrls.values) {
      c.dispose();
    }
    for (final c in optionEnCtrls.values) {
      c.dispose();
    }
  }

  Future<void> _deleteQuestion({
    required String testId,
    required _AcademyQuestion question,
  }) async {
    final testsCol = _testsCol;
    if (testsCol == null) {
      _showSnack('Session expired. Please sign in again.', error: true);
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete question?'),
        content: Text(
          question.statementFor(
            Localizations.localeOf(context).languageCode.toLowerCase(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await testsCol
          .doc(testId)
          .collection('questions')
          .doc(question.id)
          .delete();
      await _syncTestToDrivers(testId: testId);
      _showSnack('Question deleted.');
    } catch (e) {
      _showSnack('Failed to delete question: $e', error: true);
    }
  }

  Future<void> _seedDefaultQuestions({required String testId}) async {
    final testsCol = _testsCol;
    if (testsCol == null) {
      _showSnack('Session expired. Please sign in again.', error: true);
      return;
    }

    final questions = _defaultQuestionsFor(testId);
    if (questions.isEmpty) {
      _showSnack('No default set for this test. Add questions manually.');
      return;
    }

    try {
      final qCol = testsCol.doc(testId).collection('questions');
      final existing = await qCol.limit(1).get();
      if (existing.docs.isNotEmpty) {
        _showSnack('Questions already exist. Skipping default seed.');
        return;
      }

      await testsCol.doc(testId).set({
        'testId': testId,
        'title_en': _presetLabelFor(testId),
        'title': _presetLabelFor(testId),
        'enabled': true,
        'passPercent': 80,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final batch = FirebaseFirestore.instance.batch();
      for (final q in questions) {
        final ref = qCol.doc();
        final payload = q.toPayload();
        batch.set(ref, {
          ...payload,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
      await _syncTestToDrivers(testId: testId);
      _showSnack('Default questions added.');
    } catch (e) {
      _showSnack('Failed to seed defaults: $e', error: true);
    }
  }

  String _presetLabelFor(String testId) {
    return _presets
        .firstWhere(
          (p) => p.id == testId,
          orElse: () => _TestPreset(id: testId, label: testId),
        )
        .label;
  }

  List<_AcademyQuestion> _defaultQuestionsFor(String testId) {
    switch (testId) {
      case 'green_book':
        return [
          _AcademyQuestion(
            id: 'default_1',
            order: 10,
            localizedStatements: {
              'en': 'The Green Book must be completed before every shift.',
            },
            correctOptionId: 'a',
            options: const [
              _AcademyOption(id: 'a', order: 1, localizedTexts: {'en': 'True'}),
              _AcademyOption(
                id: 'b',
                order: 2,
                localizedTexts: {'en': 'False'},
              ),
              _AcademyOption(
                id: 'c',
                order: 3,
                localizedTexts: {'en': 'Only in winter'},
              ),
            ],
          ),
          _AcademyQuestion(
            id: 'default_2',
            order: 20,
            localizedStatements: {
              'en': 'Vehicle defects can be reported at the end of the week.',
            },
            correctOptionId: 'b',
            options: const [
              _AcademyOption(id: 'a', order: 1, localizedTexts: {'en': 'True'}),
              _AcademyOption(
                id: 'b',
                order: 2,
                localizedTexts: {'en': 'False'},
              ),
              _AcademyOption(
                id: 'c',
                order: 3,
                localizedTexts: {'en': 'Only if dispatcher agrees'},
              ),
            ],
          ),
          _AcademyQuestion(
            id: 'default_3',
            order: 30,
            localizedStatements: {
              'en': 'The first non-compliance consequence is a verbal warning.',
            },
            correctOptionId: 'a',
            options: const [
              _AcademyOption(id: 'a', order: 1, localizedTexts: {'en': 'True'}),
              _AcademyOption(
                id: 'b',
                order: 2,
                localizedTexts: {'en': 'False'},
              ),
              _AcademyOption(
                id: 'c',
                order: 3,
                localizedTexts: {'en': 'Only after 3 incidents'},
              ),
            ],
          ),
          _AcademyQuestion(
            id: 'default_4',
            order: 40,
            localizedStatements: {
              'en':
                  'Legal penalties can include a fine up to €5,000 for the driver.',
            },
            correctOptionId: 'a',
            options: const [
              _AcademyOption(id: 'a', order: 1, localizedTexts: {'en': 'True'}),
              _AcademyOption(
                id: 'b',
                order: 2,
                localizedTexts: {'en': 'False'},
              ),
              _AcademyOption(
                id: 'c',
                order: 3,
                localizedTexts: {'en': 'Only if vehicle is new'},
              ),
            ],
          ),
          _AcademyQuestion(
            id: 'default_5',
            order: 50,
            localizedStatements: {
              'en':
                  'Insurance coverage is always unaffected if the Green Book is missing.',
            },
            correctOptionId: 'b',
            options: const [
              _AcademyOption(id: 'a', order: 1, localizedTexts: {'en': 'True'}),
              _AcademyOption(
                id: 'b',
                order: 2,
                localizedTexts: {'en': 'False'},
              ),
              _AcademyOption(
                id: 'c',
                order: 3,
                localizedTexts: {'en': 'Only for minor incidents'},
              ),
            ],
          ),
        ];
      default:
        return const [];
    }
  }

  List<String> _supportedLocaleCodes() {
    const supported = ['en', 'de', 'sq', 'hu', 'ro', 'hr', 'ar', 'tr', 'ru'];
    return supported;
  }

  int _parsePassPercent(dynamic value) {
    final parsed =
        (value as num?)?.toInt() ?? int.tryParse(value?.toString() ?? '') ?? 80;
    return parsed.clamp(1, 100);
  }

  Map<String, String> _collectLocalizedText(
    Map<String, dynamic> data,
    String keyPrefix,
  ) {
    final out = <String, String>{};
    for (final code in _supportedLocaleCodes()) {
      final key = '${keyPrefix}_$code';
      final value = (data[key] ?? '').toString().trim();
      if (value.isNotEmpty) out[code] = value;
    }
    return out;
  }

  String _driverName(Map<String, dynamic> data, {required String fallback}) {
    final full = (data['driverName'] ?? data['fullName'] ?? '')
        .toString()
        .trim();
    if (full.isNotEmpty) return full;
    final first = (data['firstName'] ?? '').toString().trim();
    final last = (data['lastName'] ?? '').toString().trim();
    final merged = '$first $last'.trim();
    if (merged.isNotEmpty) return merged;
    return fallback;
  }

  String _firstNonEmpty(List<String> values) {
    for (final raw in values) {
      final value = raw.trim();
      if (value.isNotEmpty) return value;
    }
    return '';
  }

  Future<void> _autoTranslateMissingQuestionFields({
    required List<String> localeCodes,
    required Map<String, TextEditingController> statementCtrls,
    required List<String> optionIds,
    required Map<String, TextEditingController> optionEnCtrls,
    required Map<String, Map<String, String>> optionLocalizedById,
  }) async {
    String? sourceLang;
    for (final preferred in ['en', ...localeCodes]) {
      if (!localeCodes.contains(preferred)) continue;
      final statement = statementCtrls[preferred]?.text.trim() ?? '';
      if (statement.isNotEmpty) {
        sourceLang = preferred;
        break;
      }
    }
    if (sourceLang == null) return;

    final sourceStatement = statementCtrls[sourceLang]?.text.trim() ?? '';
    if (sourceStatement.isEmpty) return;

    final targets = <String>[];
    for (final code in localeCodes) {
      if (code == sourceLang) continue;
      final needsStatement = statementCtrls[code]?.text.trim().isEmpty ?? true;
      if (needsStatement) targets.add(code);
    }
    if (targets.isEmpty) return;

    try {
      final callable = FirebaseFunctions.instance.httpsCallable(
        'translateFaqText',
      );
      final response = await callable.call({
        'sourceLang': sourceLang,
        'targetLangs': targets,
        'question': sourceStatement,
        'answer': '',
      });

      final data = (response.data as Map?) ?? const {};
      final translations =
          (data['translations'] as Map?)?.cast<String, dynamic>() ??
          const <String, dynamic>{};

      for (final code in targets) {
        final raw = translations[code];
        if (raw is! Map) continue;
        final row = raw.cast<String, dynamic>();
        final translated = (row['question'] ?? '').toString().trim();
        final ctrl = statementCtrls[code];
        if (ctrl != null && ctrl.text.trim().isEmpty && translated.isNotEmpty) {
          ctrl.text = translated;
        }
      }

      for (final optionId in optionIds) {
        final enText = optionEnCtrls[optionId]?.text.trim() ?? '';
        if (enText.isEmpty) continue;
        final localized = optionLocalizedById.putIfAbsent(
          optionId,
          () => <String, String>{},
        );
        localized['en'] = enText;

        final optionTargets = <String>[];
        for (final code in localeCodes) {
          if (code == 'en') continue;
          final current = (localized[code] ?? '').trim();
          if (current.isEmpty) optionTargets.add(code);
        }
        if (optionTargets.isEmpty) continue;

        final optResponse = await callable.call({
          'sourceLang': 'en',
          'targetLangs': optionTargets,
          'question': enText,
          'answer': '',
        });
        final optData = (optResponse.data as Map?) ?? const {};
        final optTranslations =
            (optData['translations'] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{};

        for (final code in optionTargets) {
          final raw = optTranslations[code];
          if (raw is! Map) continue;
          final row = raw.cast<String, dynamic>();
          final translated = (row['question'] ?? '').toString().trim();
          if (translated.isNotEmpty) {
            localized[code] = translated;
          }
        }
      }
    } on FirebaseFunctionsException catch (e) {
      _showSnack(
        'Auto-translation failed: ${e.message ?? e.code}',
        error: true,
      );
    } catch (e) {
      _showSnack('Auto-translation failed: $e', error: true);
    }
  }
}

class _TestPreset {
  final String id;
  final String label;
  const _TestPreset({required this.id, required this.label});
}

class _TestOption {
  final String id;
  final String label;
  const _TestOption({required this.id, required this.label});
}

class _AcademyQuestion {
  final String id;
  final int order;
  final Map<String, String> localizedStatements;
  final List<_AcademyOption> options;
  final String correctOptionId;

  const _AcademyQuestion({
    required this.id,
    required this.order,
    required this.localizedStatements,
    required this.options,
    required this.correctOptionId,
  });

  factory _AcademyQuestion.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return _AcademyQuestion.fromMap(id: doc.id, data: data);
  }

  factory _AcademyQuestion.fromMap({
    required String id,
    required Map<String, dynamic> data,
  }) {
    final normalizedId = id.trim().isEmpty ? 'q_0' : id.trim();
    final localized = <String, String>{};
    for (final entry in data.entries) {
      if (!entry.key.startsWith('statement_')) continue;
      final code = entry.key
          .substring('statement_'.length)
          .trim()
          .toLowerCase();
      if (code.isEmpty) continue;
      final text = entry.value?.toString().trim() ?? '';
      if (text.isNotEmpty) localized[code] = text;
    }
    final fallback = (data['statement'] ?? '').toString().trim();
    if (!localized.containsKey('en') && fallback.isNotEmpty) {
      localized['en'] = fallback;
    }

    final statementMap = data['statement'];
    if (statementMap is Map) {
      for (final entry in statementMap.entries) {
        final code = entry.key.toString().trim().toLowerCase();
        if (code.isEmpty) continue;
        final text = entry.value?.toString().trim() ?? '';
        if (text.isNotEmpty) localized[code] = text;
      }
    }

    final parsedOptions = <_AcademyOption>[];
    final rawOptions = data['options'];
    if (rawOptions is List) {
      for (var i = 0; i < rawOptions.length; i++) {
        final rowRaw = rawOptions[i];
        if (rowRaw is! Map) continue;
        final row = rowRaw.cast<String, dynamic>();
        parsedOptions.add(
          _AcademyOption.fromMap(
            data: row,
            fallbackId: String.fromCharCode(97 + i),
            fallbackOrder: i + 1,
          ),
        );
      }
    }
    parsedOptions.sort((a, b) => a.order.compareTo(b.order));

    final hasMcq = parsedOptions.isNotEmpty;
    final options = hasMcq
        ? parsedOptions
        : const [
            _AcademyOption(id: 'a', order: 1, localizedTexts: {'en': 'True'}),
            _AcademyOption(id: 'b', order: 2, localizedTexts: {'en': 'False'}),
          ];

    final legacyCorrect =
        data['correctAnswer'] == true ||
        data['correct'] == true ||
        data['answer'] == true;
    var correctId = (data['correctOptionId'] ?? '').toString().trim();
    if (correctId.isEmpty) {
      correctId = hasMcq
          ? options.first.id
          : (legacyCorrect ? options.first.id : options.last.id);
    }
    if (!options.any((o) => o.id == correctId)) {
      correctId = options.first.id;
    }

    return _AcademyQuestion(
      id: normalizedId,
      order: (data['order'] as num?)?.toInt() ?? 0,
      localizedStatements: localized,
      options: options,
      correctOptionId: correctId,
    );
  }

  String statementFor(String langCode) {
    final normalized = langCode.trim().toLowerCase();
    final direct = (localizedStatements[normalized] ?? '').trim();
    if (direct.isNotEmpty) return direct;
    final english = (localizedStatements['en'] ?? '').trim();
    if (english.isNotEmpty) return english;
    for (final value in localizedStatements.values) {
      if (value.trim().isNotEmpty) return value.trim();
    }
    return '';
  }

  String correctLabelFor(String langCode) {
    for (final option in options) {
      if (option.id == correctOptionId) return option.textFor(langCode);
    }
    return options.isEmpty ? '' : options.first.textFor(langCode);
  }

  List<_AcademyOption> orderedOptions() {
    final out = [...options];
    out.sort((a, b) => a.order.compareTo(b.order));
    return out;
  }

  Map<String, dynamic> toPayload() {
    final payload = <String, dynamic>{
      'id': id,
      'order': order,
      'correctOptionId': correctOptionId,
      'options': options.map((o) => o.toPayload()).toList(),
      'statement': statementFor('en'),
    };
    for (final entry in localizedStatements.entries) {
      final value = entry.value.trim();
      if (value.isEmpty) continue;
      payload['statement_${entry.key}'] = value;
    }
    return payload;
  }
}

class _AcademyOption {
  final String id;
  final int order;
  final Map<String, String> localizedTexts;

  const _AcademyOption({
    required this.id,
    required this.order,
    required this.localizedTexts,
  });

  factory _AcademyOption.fromMap({
    required Map<String, dynamic> data,
    required String fallbackId,
    required int fallbackOrder,
  }) {
    final id = (data['id'] ?? '').toString().trim();
    final localized = <String, String>{};
    for (final entry in data.entries) {
      if (!entry.key.startsWith('text_')) continue;
      final code = entry.key.substring('text_'.length).trim().toLowerCase();
      if (code.isEmpty) continue;
      final text = entry.value?.toString().trim() ?? '';
      if (text.isNotEmpty) localized[code] = text;
    }

    final mapValue = data['text'];
    if (mapValue is Map) {
      for (final entry in mapValue.entries) {
        final code = entry.key.toString().trim().toLowerCase();
        if (code.isEmpty) continue;
        final text = entry.value?.toString().trim() ?? '';
        if (text.isNotEmpty) localized[code] = text;
      }
    }

    final generic = (data['text'] ?? '').toString().trim();
    if (generic.isNotEmpty && !localized.containsKey('en')) {
      localized['en'] = generic;
    }

    return _AcademyOption(
      id: id.isEmpty ? fallbackId : id,
      order: (data['order'] as num?)?.toInt() ?? fallbackOrder,
      localizedTexts: localized,
    );
  }

  String textFor(String langCode) {
    final code = langCode.toLowerCase().trim();
    final direct = (localizedTexts[code] ?? '').trim();
    if (direct.isNotEmpty) return direct;
    final en = (localizedTexts['en'] ?? '').trim();
    if (en.isNotEmpty) return en;
    for (final value in localizedTexts.values) {
      if (value.trim().isNotEmpty) return value.trim();
    }
    return '';
  }

  Map<String, dynamic> toPayload() {
    final payload = <String, dynamic>{
      'id': id,
      'order': order,
      'text': textFor('en'),
    };
    for (final entry in localizedTexts.entries) {
      final value = entry.value.trim();
      if (value.isEmpty) continue;
      payload['text_${entry.key}'] = value;
    }
    return payload;
  }
}

class _DriverTestResult {
  final String driverTransporterId;
  final String driverName;
  final bool lastPassed;
  final bool passedEver;
  final int attempts;
  final int score;
  final int total;
  final int percent;
  final Timestamp? lastAttemptAt;

  const _DriverTestResult({
    required this.driverTransporterId,
    required this.driverName,
    required this.lastPassed,
    required this.passedEver,
    required this.attempts,
    required this.score,
    required this.total,
    required this.percent,
    required this.lastAttemptAt,
  });

  factory _DriverTestResult.fromDriverTestDoc({
    required String driverId,
    required String driverName,
    required DocumentSnapshot<Map<String, dynamic>> doc,
  }) {
    final data = doc.data() ?? const <String, dynamic>{};
    final id = (data['driverTransporterId'] ?? driverId)
        .toString()
        .trim()
        .toUpperCase();
    return _DriverTestResult(
      driverTransporterId: id.isEmpty ? driverId : id,
      driverName: driverName,
      lastPassed: data['lastPassed'] == true,
      passedEver: data['passedEver'] == true,
      attempts: (data['attempts'] as num?)?.toInt() ?? 0,
      score: (data['lastScore'] as num?)?.toInt() ?? 0,
      total: (data['lastTotal'] as num?)?.toInt() ?? 0,
      percent: (data['lastPercent'] as num?)?.toInt() ?? 0,
      lastAttemptAt: data['lastAttemptAt'] as Timestamp?,
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _kAcademyCardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 8,
            children: [
              Icon(icon, color: _kAcademyGreen),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _kAcademyText,
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: _kAcademySubText,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              color: _kAcademyMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: _kAcademyText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final _AcademyQuestion question;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _QuestionCard({
    required this.question,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final langCode = Localizations.localeOf(context).languageCode.toLowerCase();
    final statement = question.statementFor(langCode);
    final orderedOptions = question.orderedOptions();
    final correctLabel = question.correctLabelFor(langCode);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kAcademyCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kAcademyCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '#${question.order}',
                style: const TextStyle(
                  color: _kAcademyMuted,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              _AnswerBadge(label: 'Correct: $correctLabel'),
              const Spacer(),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit',
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete',
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            statement.isEmpty ? '(Empty statement)' : statement,
            style: const TextStyle(
              color: _kAcademyText,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (orderedOptions.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...orderedOptions.map((option) {
              final isCorrect = option.id == question.correctOptionId;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${option.id.toUpperCase()}. ',
                      style: TextStyle(
                        color: isCorrect
                            ? const Color(0xFF047857)
                            : _kAcademySubText,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        option.textFor(langCode),
                        style: TextStyle(
                          color: isCorrect
                              ? const Color(0xFF047857)
                              : _kAcademySubText,
                          fontWeight: isCorrect
                              ? FontWeight.w700
                              : FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _AnswerBadge extends StatelessWidget {
  final String label;

  const _AnswerBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F8EF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF22AF66)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF047857),
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;

  const _MetricChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _kAcademyCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kAcademyCardBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _kAcademyMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: _kAcademyText,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final _DriverTestResult result;

  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final lastAt = result.lastAttemptAt?.toDate();
    final lastAtText = lastAt == null
        ? '--'
        : '${lastAt.year.toString().padLeft(4, '0')}-${lastAt.month.toString().padLeft(2, '0')}-${lastAt.day.toString().padLeft(2, '0')} ${lastAt.hour.toString().padLeft(2, '0')}:${lastAt.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kAcademyCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kAcademyCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  result.driverName,
                  style: const TextStyle(
                    color: _kAcademyText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _ResultBadge(
                attempted: result.attempts > 0,
                passed: result.lastPassed,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            result.driverTransporterId,
            style: const TextStyle(
              color: _kAcademyMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              Text(
                result.attempts > 0
                    ? 'Score: ${result.score}/${result.total} (${result.percent}%)'
                    : 'Score: --',
                style: const TextStyle(
                  color: _kAcademySubText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Attempts: ${result.attempts}',
                style: const TextStyle(
                  color: _kAcademySubText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Passed ever: ${result.passedEver ? 'Yes' : 'No'}',
                style: const TextStyle(
                  color: _kAcademySubText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Last attempt: $lastAtText',
                style: const TextStyle(
                  color: _kAcademySubText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResultBadge extends StatelessWidget {
  final bool attempted;
  final bool passed;

  const _ResultBadge({required this.attempted, required this.passed});

  @override
  Widget build(BuildContext context) {
    final bg = !attempted
        ? const Color(0xFFF3F4F6)
        : (passed ? const Color(0xFFE7F8EF) : const Color(0xFFFDECEC));
    final fg = !attempted
        ? const Color(0xFF6B7280)
        : (passed ? const Color(0xFF16A34A) : const Color(0xFFDC2626));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        !attempted ? 'Not attempted' : (passed ? 'Passed' : 'Not passed'),
        style: TextStyle(color: fg, fontWeight: FontWeight.w800),
      ),
    );
  }
}
