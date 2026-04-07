import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as fb;

const String _academyTestsCollection = 'academy_tests';
const Color _kAcademyGreen = Color(0xFF1D7F5A);
const Color _kAcademyText = Color(0xFF111827);
const Color _kAcademySubText = Color(0xFF4B5563);
const Color _kAcademyMuted = Color(0xFF6B7280);
const Color _kAcademyCardBg = Color(0xFFF9FAFB);
const Color _kAcademyCardBorder = Color(0xFFE5E7EB);

Future<String?> _resolveAcademyMediaUrl(String raw) async {
  final value = raw.trim();
  if (value.isEmpty) return null;
  final lower = value.toLowerCase();
  if (lower.startsWith('http://') || lower.startsWith('https://')) {
    return value;
  }
  try {
    if (lower.startsWith('gs://')) {
      return await fb.FirebaseStorage.instance
          .refFromURL(value)
          .getDownloadURL();
    }
    final normalized = value.startsWith('/') ? value.substring(1) : value;
    if (normalized.isNotEmpty) {
      return await fb.FirebaseStorage.instance
          .ref()
          .child(normalized)
          .getDownloadURL();
    }
  } catch (_) {
    // ignore resolution errors and return null
  }
  return null;
}

String _inferAcademyMediaTypeFromUrl(String raw) {
  final url = raw.trim().toLowerCase();
  if (url.isEmpty) return 'none';
  const videoHints = <String>[
    '.mp4',
    '.mov',
    '.m4v',
    '.webm',
    '.m3u8',
    'youtube.com',
    'youtu.be',
    'vimeo.com',
  ];
  for (final hint in videoHints) {
    if (url.contains(hint)) return 'video';
  }
  return 'image';
}

enum _AcademyTab { builder, results }

class AdminAcademyPage extends StatefulWidget {
  const AdminAcademyPage({super.key});

  @override
  State<AdminAcademyPage> createState() => _AdminAcademyPageState();
}

class _AdminAcademyPageState extends State<AdminAcademyPage> {
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;
  String? _resolvedDspUid;

  String _selectedTestId = '';
  String _previewStepId = '';
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
        final docById = <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};
        for (final doc in docs) {
          docById[doc.id] = doc;
        }
        final options = _resolveTestOptions(docs);
        final selectedExists =
            _selectedTestId.isNotEmpty &&
            options.any((o) => o.id == _selectedTestId);
        final effectiveSelected = selectedExists
            ? _selectedTestId
            : (options.isEmpty ? '' : options.first.id);

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
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: _kAcademyCardBorder),
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: _kAcademyText,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'DA Academy',
                      style: TextStyle(
                        fontSize: 42 / 2,
                        fontWeight: FontWeight.w900,
                        color: _kAcademyText,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _openCategoryEditor,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Category'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kAcademyGreen,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SegmentedButton<_AcademyTab>(
                segments: const [
                  ButtonSegment<_AcademyTab>(
                    value: _AcademyTab.builder,
                    icon: Icon(Icons.edit_outlined),
                    label: Text('Builder'),
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
              if (scopeUid.isNotEmpty) const SizedBox(height: 10),
              if (scopeUid.isNotEmpty)
                Text(
                  'DSP: $scopeUid',
                  style: const TextStyle(
                    color: _kAcademyMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F6F8),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _kAcademyCardBorder),
                ),
                child: options.isEmpty
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _kAcademyCardBorder),
                        ),
                        child: const Text(
                          'No categories yet. Click "Add Category" to create your first DA Academy category.',
                          style: TextStyle(
                            color: _kAcademySubText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 320),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: options.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final option = options[index];
                            final data =
                                docById[option.id]?.data() ??
                                const <String, dynamic>{};
                            final subtitle = _firstNonEmpty([
                              (data['subtitle_en'] ?? '').toString(),
                              (data['subtitle'] ?? '').toString(),
                              '',
                            ]);
                            final createdAt = data['createdAt'];
                            final isNew = createdAt is Timestamp
                                ? DateTime.now()
                                          .difference(createdAt.toDate())
                                          .inDays <=
                                      7
                                : false;
                            final palette = _categoryPalette(option.id);
                            final selected = option.id == effectiveSelected;
                            return _AdminCategoryTile(
                              title: option.label,
                              subtitle: subtitle,
                              icon: _iconForCategory(option.id),
                              iconColor: palette.iconColor,
                              iconBgColor: palette.iconBg,
                              selected: selected,
                              isNew: isNew,
                              onTap: () {
                                setState(() {
                                  _selectedTestId = option.id;
                                  _previewStepId = '';
                                });
                              },
                            );
                          },
                        ),
                      ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: effectiveSelected.isEmpty
                    ? _buildNoCategoryState()
                    : _activeTab == _AcademyTab.builder
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
            final questions = qDocs.map(_AcademyQuestion.fromDoc).toList()
              ..sort((a, b) => a.order.compareTo(b.order));
            final hasQuestions = questions.isNotEmpty;
            final hasSubcategorySteps = questions.any(
              (q) => q.isSubcategoryStep,
            );
            final hasRootPlayableSteps = questions.any(
              (q) => !q.isSubcategoryStep && q.parentId.trim().isEmpty,
            );
            final canAddSubcategoryAtRoot = !hasRootPlayableSteps;
            final canAddRootPlayable = !hasSubcategorySteps;
            final mixedRootStructure =
                hasSubcategorySteps && hasRootPlayableSteps;
            final langCode = Localizations.localeOf(
              context,
            ).languageCode.toLowerCase();
            final groups = _buildStepGroups(questions, langCode: langCode);
            final previewStep = _resolvePreviewStep(questions);
            final selectedStepId = previewStep?.id ?? '';

            Widget buildStepTile(
              _AcademyQuestion step, {
              bool indented = false,
            }) {
              if (step.isSubcategoryStep) {
                return Padding(
                  padding: EdgeInsets.only(left: indented ? 16 : 0, top: 8),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F3FF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFD6BCFA)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.folder_copy_outlined,
                          color: Color(0xFF6D28D9),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            step.statementFor(langCode).trim().isEmpty
                                ? '(Empty subcategory title)'
                                : step.statementFor(langCode).trim(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _kAcademyText,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _openQuestionEditor(
                            testId: testId,
                            existing: step,
                          ),
                          tooltip: 'Edit',
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.edit_outlined, size: 18),
                        ),
                        IconButton(
                          onPressed: () async {
                            await _deleteQuestion(
                              testId: testId,
                              question: step,
                            );
                          },
                          tooltip: 'Delete',
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.delete_outline, size: 18),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final isSelected = step.id == selectedStepId;
              final typeLabel = step.isSubcategoryStep
                  ? 'Subcategory'
                  : step.isQuestionStep
                  ? 'Question'
                  : 'Content';
              final typeColor = step.isSubcategoryStep
                  ? const Color(0xFF6D28D9)
                  : step.isQuestionStep
                  ? const Color(0xFF0369A1)
                  : const Color(0xFF047857);
              final statement = step.statementFor(langCode).trim();

              return Padding(
                padding: EdgeInsets.only(left: indented ? 16 : 0, top: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => setState(() => _previewStepId = step.id),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFEFF6FF)
                          : const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF3B82F6)
                            : _kAcademyCardBorder,
                        width: isSelected ? 1.4 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5E7EB),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${step.order}',
                                style: const TextStyle(
                                  color: _kAcademyText,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                statement.isEmpty
                                    ? '(Empty step text)'
                                    : statement,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: _kAcademyText,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _openQuestionEditor(
                                testId: testId,
                                existing: step,
                              ),
                              tooltip: 'Edit',
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.edit_outlined, size: 18),
                            ),
                            IconButton(
                              onPressed: () async {
                                await _deleteQuestion(
                                  testId: testId,
                                  question: step,
                                );
                              },
                              tooltip: 'Delete',
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.delete_outline, size: 18),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _BuilderPill(label: typeLabel, color: typeColor),
                            if (step.mediaType != 'none')
                              _BuilderPill(
                                label: step.mediaType == 'video'
                                    ? 'Video'
                                    : 'Image',
                                color: const Color(0xFF7C3AED),
                              ),
                            if (step.isQuestionStep)
                              _BuilderPill(
                                label: '${step.options.length} options',
                                color: const Color(0xFF2563EB),
                              ),
                            if (!step.isSubcategoryStep &&
                                step.parentId.trim().isNotEmpty)
                              _BuilderPill(
                                label: 'Parent ${step.parentId}',
                                color: const Color(0xFF4B5563),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return ListView(
              children: [
                _SectionCard(
                  title: 'Category Settings',
                  subtitle:
                      'Configure category title, subtitle, visibility, and pass threshold.',
                  icon: Icons.tune_outlined,
                  trailing: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: () => _syncTestToDrivers(testId: testId),
                        icon: const Icon(Icons.sync_outlined),
                        label: const Text('Sync to drivers'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _openCategoryEditor(
                          categoryId: testId,
                          initialData: testData,
                        ),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit category'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _deleteCategory(testId: testId),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Delete category'),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoRow(label: 'Title', value: titlePreview),
                      const SizedBox(height: 8),
                      _InfoRow(
                        label: 'Subtitle',
                        value: _firstNonEmpty([
                          (testData['subtitle_en'] ?? '').toString(),
                          (testData['subtitle'] ?? '').toString(),
                          '--',
                        ]),
                      ),
                      const SizedBox(height: 8),
                      _InfoRow(
                        label: 'Order',
                        value: '${(testData['order'] as num?)?.toInt() ?? 0}',
                      ),
                      const SizedBox(height: 8),
                      _InfoRow(label: 'Pass threshold', value: '$passPercent%'),
                      const SizedBox(height: 8),
                      _InfoRow(label: 'Items', value: '${questions.length}'),
                      const SizedBox(height: 12),
                      const Text(
                        'Build structure',
                        style: TextStyle(
                          color: _kAcademyMuted,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (mixedRootStructure) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Mixed root structure detected. Use either subcategories OR direct content/questions at root.',
                          style: TextStyle(
                            color: Color(0xFFB91C1C),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ] else if (hasSubcategorySteps) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'This category uses subcategories. Add content/questions inside subcategories.',
                          style: TextStyle(
                            color: _kAcademySubText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ] else if (hasRootPlayableSteps) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'This category uses direct root content/questions. Subcategories are disabled.',
                          style: TextStyle(
                            color: _kAcademySubText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ElevatedButton.icon(
                            onPressed: canAddSubcategoryAtRoot
                                ? () => _openQuestionEditor(
                                    testId: testId,
                                    initialStepType: 'subcategory',
                                  )
                                : null,
                            icon: const Icon(Icons.folder_copy_outlined),
                            label: const Text('Add subcategory'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6D28D9),
                              foregroundColor: Colors.white,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: canAddRootPlayable
                                ? () => _openQuestionEditor(
                                    testId: testId,
                                    initialStepType: 'content',
                                  )
                                : null,
                            icon: const Icon(Icons.article_outlined),
                            label: const Text('Add content'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF047857),
                              foregroundColor: Colors.white,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: canAddRootPlayable
                                ? () => _openQuestionEditor(
                                    testId: testId,
                                    initialStepType: 'question',
                                  )
                                : null,
                            icon: const Icon(Icons.quiz_outlined),
                            label: const Text('Add question'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0369A1),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Training Builder',
                  subtitle:
                      'Use structured groups to build steps in order. Driver-style preview is shown on the right.',
                  icon: Icons.view_timeline_outlined,
                  child: hasQuestions
                      ? LayoutBuilder(
                          builder: (context, constraints) {
                            final wide = constraints.maxWidth >= 1080;

                            final structure = Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: _kAcademyCardBg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: _kAcademyCardBorder),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _BuilderPill(
                                        label:
                                            '${questions.length} total steps',
                                        color: const Color(0xFF334155),
                                      ),
                                      _BuilderPill(
                                        label:
                                            '${questions.where((q) => q.isSubcategoryStep).length} subcategories',
                                        color: const Color(0xFF6D28D9),
                                      ),
                                      _BuilderPill(
                                        label:
                                            '${questions.where((q) => q.isContentStep).length} content',
                                        color: const Color(0xFF047857),
                                      ),
                                      _BuilderPill(
                                        label:
                                            '${questions.where((q) => q.isQuestionStep).length} questions',
                                        color: const Color(0xFF0369A1),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  ...groups.map((group) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          border: Border.all(
                                            color: _kAcademyCardBorder,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  group.subcategory == null
                                                      ? Icons.home_outlined
                                                      : Icons
                                                            .folder_copy_outlined,
                                                  color: _kAcademyGreen,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    group.title,
                                                    style: const TextStyle(
                                                      color: _kAcademyText,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ),
                                                if (group.subcategory != null ||
                                                    canAddRootPlayable)
                                                  PopupMenuButton<String>(
                                                    onSelected: (value) {
                                                      if (value == 'content') {
                                                        _openQuestionEditor(
                                                          testId: testId,
                                                          initialStepType:
                                                              'content',
                                                          initialParentId:
                                                              group
                                                                  .subcategory
                                                                  ?.id ??
                                                              '',
                                                        );
                                                      } else if (value ==
                                                          'question') {
                                                        _openQuestionEditor(
                                                          testId: testId,
                                                          initialStepType:
                                                              'question',
                                                          initialParentId:
                                                              group
                                                                  .subcategory
                                                                  ?.id ??
                                                              '',
                                                        );
                                                      }
                                                    },
                                                    itemBuilder: (context) =>
                                                        const [
                                                          PopupMenuItem(
                                                            value: 'content',
                                                            child: Text(
                                                              'Add content here',
                                                            ),
                                                          ),
                                                          PopupMenuItem(
                                                            value: 'question',
                                                            child: Text(
                                                              'Add question here',
                                                            ),
                                                          ),
                                                        ],
                                                    child: const Icon(
                                                      Icons.add_circle_outline,
                                                      color: _kAcademyGreen,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            if (group.subcategory != null)
                                              buildStepTile(group.subcategory!),
                                            if (group.subcategory != null) ...[
                                              const SizedBox(height: 8),
                                              Wrap(
                                                spacing: 8,
                                                runSpacing: 8,
                                                children: [
                                                  OutlinedButton.icon(
                                                    onPressed: () =>
                                                        _openQuestionEditor(
                                                          testId: testId,
                                                          initialStepType:
                                                              'content',
                                                          initialParentId: group
                                                              .subcategory!
                                                              .id,
                                                        ),
                                                    icon: const Icon(
                                                      Icons.article_outlined,
                                                      size: 18,
                                                    ),
                                                    label: const Text(
                                                      'Add content in this subcategory',
                                                    ),
                                                  ),
                                                  OutlinedButton.icon(
                                                    onPressed: () =>
                                                        _openQuestionEditor(
                                                          testId: testId,
                                                          initialStepType:
                                                              'question',
                                                          initialParentId: group
                                                              .subcategory!
                                                              .id,
                                                        ),
                                                    icon: const Icon(
                                                      Icons.quiz_outlined,
                                                      size: 18,
                                                    ),
                                                    label: const Text(
                                                      'Add question in this subcategory',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                            if (group.steps.isEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 8,
                                                ),
                                                child: Text(
                                                  'No content/questions in this subcategory yet.',
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              )
                                            else
                                              ...group.steps.map(
                                                (step) => buildStepTile(
                                                  step,
                                                  indented:
                                                      group.subcategory != null,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            );

                            final previewPanel = _AdminDriverPreviewCard(
                              moduleTitle: titlePreview,
                              langCode: langCode,
                              step: previewStep,
                              onEdit: previewStep == null
                                  ? null
                                  : () => _openQuestionEditor(
                                      testId: testId,
                                      existing: previewStep,
                                    ),
                              onDelete: previewStep == null
                                  ? null
                                  : () => _deleteQuestion(
                                      testId: testId,
                                      question: previewStep,
                                    ),
                            );

                            if (wide) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: structure),
                                  const SizedBox(width: 14),
                                  SizedBox(width: 390, child: previewPanel),
                                ],
                              );
                            }

                            return Column(
                              children: [
                                structure,
                                const SizedBox(height: 14),
                                previewPanel,
                              ],
                            );
                          },
                        )
                      : Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _kAcademyCardBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: _kAcademyCardBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'No content configured yet. Add subcategories, content, and questions to build this training.',
                                style: TextStyle(color: _kAcademySubText),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () => _openQuestionEditor(
                                      testId: testId,
                                      initialStepType: 'subcategory',
                                    ),
                                    icon: const Icon(
                                      Icons.folder_copy_outlined,
                                    ),
                                    label: const Text('Add subcategory'),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: () => _openQuestionEditor(
                                      testId: testId,
                                      initialStepType: 'content',
                                    ),
                                    icon: const Icon(Icons.article_outlined),
                                    label: const Text('Add content'),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: () => _openQuestionEditor(
                                      testId: testId,
                                      initialStepType: 'question',
                                    ),
                                    icon: const Icon(Icons.quiz_outlined),
                                    label: const Text('Add question'),
                                  ),
                                ],
                              ),
                            ],
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

  Widget _buildNoCategoryState() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 620),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kAcademyCardBorder),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No DA Academy category selected.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _kAcademyText,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Create a category first, then add subcategories, content, and questions.',
              style: TextStyle(color: _kAcademySubText),
            ),
          ],
        ),
      ),
    );
  }

  _AcademyQuestion? _resolvePreviewStep(List<_AcademyQuestion> steps) {
    if (steps.isEmpty) return null;
    for (final step in steps) {
      if (step.id == _previewStepId && !step.isSubcategoryStep) return step;
    }
    for (final step in steps) {
      if (!step.isSubcategoryStep) return step;
    }
    return null;
  }

  List<_AcademyStepGroup> _buildStepGroups(
    List<_AcademyQuestion> steps, {
    required String langCode,
  }) {
    final sorted = [...steps]..sort((a, b) => a.order.compareTo(b.order));
    final subcategories = sorted
        .where((step) => step.isSubcategoryStep)
        .toList();
    final subcategoryIds = subcategories.map((step) => step.id).toSet();

    final byParent = <String, List<_AcademyQuestion>>{};
    final rootSteps = <_AcademyQuestion>[];
    final orphanSteps = <_AcademyQuestion>[];

    for (final step in sorted.where((step) => !step.isSubcategoryStep)) {
      final parent = step.parentId.trim();
      if (parent.isEmpty) {
        rootSteps.add(step);
      } else if (subcategoryIds.contains(parent)) {
        byParent.putIfAbsent(parent, () => <_AcademyQuestion>[]).add(step);
      } else {
        orphanSteps.add(step);
      }
    }

    final groups = <_AcademyStepGroup>[];
    if (rootSteps.isNotEmpty) {
      groups.add(
        _AcademyStepGroup(
          title: 'Root content',
          subcategory: null,
          steps: rootSteps,
        ),
      );
    }

    for (final sub in subcategories) {
      final title = sub.statementFor(langCode).trim();
      groups.add(
        _AcademyStepGroup(
          title: title.isEmpty ? 'Subcategory #${sub.order}' : title,
          subcategory: sub,
          steps: byParent[sub.id] ?? const <_AcademyQuestion>[],
        ),
      );
    }

    if (orphanSteps.isNotEmpty) {
      groups.add(
        _AcademyStepGroup(
          title: 'Unlinked steps (parent missing)',
          subcategory: null,
          steps: orphanSteps,
        ),
      );
    }

    if (groups.isEmpty && sorted.isNotEmpty) {
      groups.add(
        _AcademyStepGroup(title: 'All steps', subcategory: null, steps: sorted),
      );
    }
    return groups;
  }

  Future<void> _openCategoryEditor({
    String? categoryId,
    Map<String, dynamic>? initialData,
  }) async {
    final testsCol = _testsCol;
    if (testsCol == null) {
      _showSnack('Session expired. Please sign in again.', error: true);
      return;
    }

    final locales = ['en', ..._supportedLocaleCodes().where((c) => c != 'en')];
    final isEdit = categoryId != null && categoryId.trim().isNotEmpty;
    final data = initialData ?? const <String, dynamic>{};
    final idCtrl = TextEditingController(text: categoryId ?? '');
    final titleCtrls = <String, TextEditingController>{};
    final subtitleCtrls = <String, TextEditingController>{};
    for (final code in locales) {
      titleCtrls[code] = TextEditingController(
        text: (data['title_$code'] ?? '').toString(),
      );
      subtitleCtrls[code] = TextEditingController(
        text: (data['subtitle_$code'] ?? '').toString(),
      );
    }
    final passCtrl = TextEditingController(
      text: _parsePassPercent(data['passPercent']).toString(),
    );
    final orderCtrl = TextEditingController(
      text: '${(data['order'] as num?)?.toInt() ?? 10}',
    );
    var enabled = data['enabled'] != false;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setInnerState) => AlertDialog(
          title: Text(isEdit ? 'Edit Category' : 'Add Category'),
          content: SizedBox(
            width: 680,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: idCtrl,
                    enabled: !isEdit,
                    decoration: const InputDecoration(
                      labelText: 'Category Id',
                      hintText: 'amazon_delivery',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: orderCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Order'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: passCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Pass threshold (%)',
                    ),
                  ),
                  const SizedBox(height: 6),
                  SwitchListTile(
                    value: enabled,
                    onChanged: (v) => setInnerState(() => enabled = v),
                    title: const Text('Category enabled'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 6),
                  ...locales.map((code) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TextField(
                        controller: titleCtrls[code],
                        decoration: InputDecoration(labelText: 'Title ($code)'),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  ...locales.map((code) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TextField(
                        controller: subtitleCtrls[code],
                        decoration: InputDecoration(
                          labelText: 'Subtitle ($code)',
                        ),
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
                var id = idCtrl.text.trim();
                if (id.isEmpty) {
                  final fallbackName = titleCtrls['en']!.text.trim();
                  id = fallbackName
                      .toLowerCase()
                      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
                      .replaceAll(RegExp(r'_+'), '_')
                      .replaceAll(RegExp(r'^_|_$'), '');
                }
                if (id.isEmpty) {
                  _showSnack('Category id is required.', error: true);
                  return;
                }

                final payload = <String, dynamic>{
                  'testId': id,
                  'enabled': enabled,
                  'passPercent': (int.tryParse(passCtrl.text.trim()) ?? 80)
                      .clamp(1, 100),
                  'order': int.tryParse(orderCtrl.text.trim()) ?? 10,
                  'updatedAt': FieldValue.serverTimestamp(),
                };
                for (final code in locales) {
                  payload['title_$code'] = titleCtrls[code]!.text.trim();
                  payload['subtitle_$code'] = subtitleCtrls[code]!.text.trim();
                }
                payload['title'] = _firstNonEmpty([
                  payload['title_en']?.toString() ?? '',
                  id,
                ]);
                payload['subtitle'] = _firstNonEmpty([
                  payload['subtitle_en']?.toString() ?? '',
                ]);
                if (!isEdit) {
                  payload['createdAt'] = FieldValue.serverTimestamp();
                }

                try {
                  await testsCol.doc(id).set(payload, SetOptions(merge: true));
                  if (!mounted || !ctx.mounted) return;
                  setState(() {
                    _selectedTestId = id;
                    _previewStepId = '';
                  });
                  Navigator.of(ctx).pop();
                  _showSnack(
                    isEdit ? 'Category updated.' : 'Category created.',
                  );
                } catch (e) {
                  _showSnack('Failed to save category: $e', error: true);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    idCtrl.dispose();
    passCtrl.dispose();
    orderCtrl.dispose();
    for (final c in titleCtrls.values) {
      c.dispose();
    }
    for (final c in subtitleCtrls.values) {
      c.dispose();
    }
  }

  Future<void> _deleteCategory({required String testId}) async {
    final testsCol = _testsCol;
    final driversCol = _driversCol;
    if (testsCol == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete category?'),
        content: Text(
          'This will remove category "$testId" and all of its steps.',
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
      final qSnap = await testsCol.doc(testId).collection('questions').get();
      const chunkSize = 350;
      final db = FirebaseFirestore.instance;
      final docs = qSnap.docs;
      for (var i = 0; i < docs.length; i += chunkSize) {
        final end = (i + chunkSize > docs.length) ? docs.length : i + chunkSize;
        final batch = db.batch();
        for (final q in docs.sublist(i, end)) {
          batch.delete(q.reference);
        }
        await batch.commit();
      }
      await testsCol.doc(testId).delete();

      if (driversCol != null) {
        final driversSnap = await driversCol.get();
        final drivers = driversSnap.docs;
        for (var i = 0; i < drivers.length; i += chunkSize) {
          final end = (i + chunkSize > drivers.length)
              ? drivers.length
              : i + chunkSize;
          final deleteBatch = db.batch();
          for (final driver in drivers.sublist(i, end)) {
            deleteBatch.delete(
              driver.reference.collection(_academyTestsCollection).doc(testId),
            );
          }
          await deleteBatch.commit();
        }
      }

      if (!mounted) return;
      setState(() {
        if (_selectedTestId == testId) {
          _selectedTestId = '';
          _previewStepId = '';
        }
      });
      _showSnack('Category deleted.');
    } catch (e) {
      _showSnack('Failed to delete category: $e', error: true);
    }
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
      final localizedSubtitles = <String, dynamic>{};
      for (final key in testData.keys) {
        if (key.startsWith('title_')) {
          localizedTitles[key] = testData[key];
        }
        if (key.startsWith('subtitle_')) {
          localizedSubtitles[key] = testData[key];
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
      final playableCount = questions.where((row) {
        final type = (row['stepType'] ?? '').toString().trim().toLowerCase();
        return type == 'question' || type == 'content';
      }).length;
      final title = _firstNonEmpty([
        (testData['title_en'] ?? '').toString(),
        (testData['title'] ?? '').toString(),
        testId,
      ]);
      final subtitle = _firstNonEmpty([
        (testData['subtitle_en'] ?? '').toString(),
        (testData['subtitle'] ?? '').toString(),
      ]);
      final order = (testData['order'] as num?)?.toInt() ?? 0;

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
            'subtitle': subtitle,
            ...localizedSubtitles,
            'order': order,
            'enabled': enabled,
            'passPercent': passPercent,
            'questionCount': playableCount,
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
    for (final d in docs) {
      final data = d.data();
      final id = d.id.trim();
      if (id.isEmpty) continue;
      final label = _firstNonEmpty([
        (data['title_en'] ?? '').toString(),
        (data['title'] ?? '').toString(),
        (data['name'] ?? '').toString(),
        id,
      ]);
      map[id] = _TestOption(
        id: id,
        label: label,
        order: (data['order'] as num?)?.toInt() ?? 0,
      );
    }

    map.removeWhere((_, value) => value.id.trim().isEmpty);
    final out = map.values.toList()
      ..sort((a, b) {
        if (a.order != b.order) return a.order.compareTo(b.order);
        return a.label.toLowerCase().compareTo(b.label.toLowerCase());
      });
    return out;
  }

  String _labelForTest(String testId, List<_TestOption> options) {
    return options
        .firstWhere(
          (o) => o.id == testId,
          orElse: () => _TestOption(id: testId, label: testId, order: 0),
        )
        .label;
  }

  IconData _iconForCategory(String categoryId) {
    final id = categoryId.trim().toLowerCase();
    if (id.contains('green')) return Icons.menu_book_rounded;
    if (id.contains('safety')) return Icons.shield_outlined;
    if (id.contains('delivery') || id.contains('amazon')) {
      return Icons.local_shipping_outlined;
    }
    if (id.contains('app')) return Icons.phone_android_rounded;
    return Icons.school_outlined;
  }

  _CategoryPalette _categoryPalette(String categoryId) {
    final id = categoryId.trim().toLowerCase();
    if (id.contains('green')) {
      return const _CategoryPalette(
        iconColor: Color(0xFF16A34A),
        iconBg: Color(0xFFE8F7EF),
      );
    }
    if (id.contains('safety')) {
      return const _CategoryPalette(
        iconColor: Color(0xFFEA580C),
        iconBg: Color(0xFFFFF2E8),
      );
    }
    if (id.contains('delivery') || id.contains('amazon')) {
      return const _CategoryPalette(
        iconColor: Color(0xFF059669),
        iconBg: Color(0xFFE8F7F1),
      );
    }
    if (id.contains('app')) {
      return const _CategoryPalette(
        iconColor: Color(0xFF2563EB),
        iconBg: Color(0xFFEAF0FF),
      );
    }
    return const _CategoryPalette(
      iconColor: Color(0xFF334155),
      iconBg: Color(0xFFE5E7EB),
    );
  }

  Future<void> _openQuestionEditor({
    required String testId,
    _AcademyQuestion? existing,
    String? initialStepType,
    String? initialParentId,
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
    final optionCtrlsById = <String, Map<String, TextEditingController>>{};
    for (final id in optionIds) {
      optionCtrlsById[id] = {
        for (final code in locales) code: TextEditingController(),
      };
    }

    var optionCount = 4;
    var correctOptionId = 'a';
    var stepType = existing != null
        ? switch (existing.stepType) {
            'content' => 'content',
            'subcategory' => 'subcategory',
            _ => 'question',
          }
        : switch ((initialStepType ?? '').trim().toLowerCase()) {
            'subcategory' => 'subcategory',
            'content' => 'content',
            _ => 'question',
          };
    var parentId = existing?.parentId ?? (initialParentId ?? '');
    var mediaType = (existing?.mediaType ?? 'none').trim().toLowerCase();
    if (!['none', 'image', 'video'].contains(mediaType)) {
      mediaType = 'none';
    }
    final mediaUrlCtrl = TextEditingController(text: existing?.mediaUrl ?? '');
    final buttonLabelCtrl = TextEditingController(
      text: existing?.buttonLabel ?? '',
    );
    var isUploadingMedia = false;
    if (existing != null && existing.options.isNotEmpty) {
      final prefilledCount = existing.options.length.clamp(0, 4);
      optionCount = prefilledCount >= 3 ? prefilledCount : 3;
      for (var i = 0; i < prefilledCount; i++) {
        final id = optionIds[i];
        final option = existing.options[i];
        for (final code in locales) {
          optionCtrlsById[id]![code]!.text = option.localizedTexts[code] ?? '';
        }
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
    final allSnap = await questionsRef.get();
    final allSteps = allSnap.docs.map(_AcademyQuestion.fromDoc).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    final existingId = existing?.id ?? '';
    final otherSteps = allSteps.where((step) => step.id != existingId).toList();
    final hasOtherSubcategories = otherSteps.any(
      (step) => step.isSubcategoryStep,
    );
    final hasOtherRootPlayable = otherSteps.any(
      (step) => !step.isSubcategoryStep && step.parentId.trim().isEmpty,
    );
    final parentCandidates = allSteps
        .where((step) => step.isSubcategoryStep && step.id != existingId)
        .toList();
    if (!parentCandidates.any((step) => step.id == parentId)) {
      parentId = '';
    }
    if (stepType != 'subcategory' &&
        hasOtherSubcategories &&
        parentId.trim().isEmpty &&
        parentCandidates.isNotEmpty) {
      parentId = parentCandidates.first.id;
    }

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
          title: Text(
            existing == null
                ? 'Add Content / Question'
                : 'Edit Content / Question',
          ),
          content: SizedBox(
            width: 680,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: stepType,
                    decoration: const InputDecoration(labelText: 'Step type'),
                    items: const [
                      DropdownMenuItem(
                        value: 'subcategory',
                        child: Text('Subcategory'),
                      ),
                      DropdownMenuItem(
                        value: 'question',
                        child: Text('Question'),
                      ),
                      DropdownMenuItem(
                        value: 'content',
                        child: Text('Content'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setInnerState(() {
                        stepType = value;
                        if (stepType == 'subcategory') {
                          parentId = '';
                          mediaType = 'none';
                          mediaUrlCtrl.clear();
                          buttonLabelCtrl.clear();
                        } else if (mediaType == 'none') {
                          mediaType = 'image';
                        }
                        if (stepType != 'subcategory' &&
                            hasOtherSubcategories &&
                            parentId.trim().isEmpty &&
                            parentCandidates.isNotEmpty) {
                          parentId = parentCandidates.first.id;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  if (stepType != 'subcategory')
                    DropdownButtonFormField<String>(
                      initialValue: parentId,
                      decoration: InputDecoration(
                        labelText: hasOtherSubcategories
                            ? 'Parent subcategory'
                            : 'Parent subcategory (optional)',
                      ),
                      items: [
                        if (!hasOtherSubcategories)
                          const DropdownMenuItem(
                            value: '',
                            child: Text('Root category'),
                          ),
                        ...parentCandidates.map((step) {
                          return DropdownMenuItem(
                            value: step.id,
                            child: Text(
                              '#${step.order} ${step.statementFor('en')}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setInnerState(() => parentId = value);
                      },
                    ),
                  if (stepType != 'subcategory') const SizedBox(height: 8),
                  TextField(
                    controller: orderCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Order'),
                  ),
                  const SizedBox(height: 8),
                  if (stepType == 'question')
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
                  if (stepType == 'question') const SizedBox(height: 12),
                  if (stepType != 'subcategory') ...[
                    DropdownButtonFormField<String>(
                      initialValue: mediaType,
                      decoration: const InputDecoration(
                        labelText: 'Media type',
                      ),
                      items: const [
                        DropdownMenuItem(value: 'none', child: Text('None')),
                        DropdownMenuItem(value: 'image', child: Text('Image')),
                        DropdownMenuItem(value: 'video', child: Text('Video')),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setInnerState(() {
                          mediaType = value;
                          if (mediaType == 'none') {
                            mediaUrlCtrl.clear();
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    if (mediaType != 'none')
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ElevatedButton.icon(
                              onPressed: isUploadingMedia
                                  ? null
                                  : () async {
                                      setInnerState(
                                        () => isUploadingMedia = true,
                                      );
                                      final uploadedUrl =
                                          await _pickAndUploadAcademyStepMedia(
                                            testId: testId,
                                            isVideo: mediaType == 'video',
                                          );
                                      if (!mounted || !ctx.mounted) return;
                                      setInnerState(() {
                                        if (uploadedUrl != null &&
                                            uploadedUrl.trim().isNotEmpty) {
                                          mediaUrlCtrl.text = uploadedUrl
                                              .trim();
                                        }
                                        isUploadingMedia = false;
                                      });
                                    },
                              icon: isUploadingMedia
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.upload_outlined),
                              label: Text(
                                mediaType == 'video'
                                    ? 'Upload video'
                                    : 'Upload image',
                              ),
                            ),
                            if (mediaUrlCtrl.text.trim().isNotEmpty)
                              OutlinedButton.icon(
                                onPressed: isUploadingMedia
                                    ? null
                                    : () => setInnerState(
                                        () => mediaUrlCtrl.clear(),
                                      ),
                                icon: const Icon(Icons.delete_outline),
                                label: const Text('Remove media'),
                              ),
                          ],
                        ),
                      ),
                    if (mediaType != 'none') const SizedBox(height: 8),
                    if (mediaType == 'video')
                      TextField(
                        controller: mediaUrlCtrl,
                        decoration: InputDecoration(labelText: 'Video URL'),
                      ),
                    if (mediaType == 'image' &&
                        mediaUrlCtrl.text.trim().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      FutureBuilder<String?>(
                        future: _resolveAcademyMediaUrl(mediaUrlCtrl.text),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container(
                              height: 180,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _kAcademyCardBorder),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                ),
                              ),
                            );
                          }
                          final resolved = snapshot.data?.trim() ?? '';
                          if (resolved.isEmpty) {
                            return Container(
                              height: 180,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _kAcademyCardBorder),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  color: Color(0xFF9CA3AF),
                                  size: 40,
                                ),
                              ),
                            );
                          }
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              resolved,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 180,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _kAcademyCardBorder,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    color: Color(0xFF9CA3AF),
                                    size: 40,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    if (mediaType == 'video' &&
                        mediaUrlCtrl.text.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            mediaUrlCtrl.text.trim(),
                            style: const TextStyle(color: _kAcademySubText),
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                  ],
                  if (stepType == 'content') ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextField(
                        controller: buttonLabelCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Button label',
                          hintText: 'Next',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Step text',
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
                                optionCtrlsById: optionCtrlsById,
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
                  if (stepType == 'question') ...[
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
                              child: Column(
                                children: [
                                  for (final code in locales)
                                    Padding(
                                      padding: EdgeInsets.only(
                                        bottom: code == locales.last ? 0 : 8,
                                      ),
                                      child: TextField(
                                        controller: optionCtrlsById[id]![code],
                                        decoration: InputDecoration(
                                          labelText: 'Option $letter ($code)',
                                          helperText:
                                              code == locales.first &&
                                                  correctOptionId == id
                                              ? 'Marked as correct answer'
                                              : null,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
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
                if (stepType == 'question') {
                  await _autoTranslateMissingQuestionFields(
                    localeCodes: locales,
                    statementCtrls: statementCtrls,
                    optionIds: optionIds.sublist(0, optionCount),
                    optionCtrlsById: optionCtrlsById,
                  );
                }

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

                final options = <Map<String, dynamic>>[];
                if (stepType == 'question') {
                  final activeOptionIds = optionIds.sublist(0, optionCount);
                  final normalizedOptionTexts = <String>{};
                  for (var i = 0; i < activeOptionIds.length; i++) {
                    final optionId = activeOptionIds[i];
                    final enText = optionCtrlsById[optionId]!['en']!.text
                        .trim();
                    if (enText.isEmpty) {
                      _showSnack(
                        'Please fill all answer options.',
                        error: true,
                      );
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

                    final optionPayload = <String, dynamic>{
                      'id': optionId,
                      'order': i + 1,
                      'text': enText,
                    };
                    for (final code in locales) {
                      final value = optionCtrlsById[optionId]![code]!.text
                          .trim();
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
                }

                final candidateParentId = parentId.trim();

                if (stepType == 'subcategory' && hasOtherRootPlayable) {
                  _showSnack(
                    'Cannot add subcategory. This category already has root content/questions.',
                    error: true,
                  );
                  return;
                }

                if (stepType != 'subcategory' &&
                    candidateParentId.isEmpty &&
                    hasOtherSubcategories) {
                  _showSnack(
                    'Cannot add root content/question while subcategories exist. Add it inside a subcategory.',
                    error: true,
                  );
                  return;
                }

                if (stepType != 'subcategory' &&
                    candidateParentId.isNotEmpty &&
                    !parentCandidates.any(
                      (step) => step.id == candidateParentId,
                    )) {
                  _showSnack(
                    'Selected parent subcategory no longer exists.',
                    error: true,
                  );
                  return;
                }

                final order =
                    int.tryParse(orderCtrl.text.trim()) ??
                    (existing?.order ?? 10);
                final payload = <String, dynamic>{
                  'order': order,
                  'stepType': stepType,
                  'parentId': stepType == 'subcategory'
                      ? ''
                      : candidateParentId,
                  'mediaType': stepType == 'subcategory' ? 'none' : mediaType,
                  'mediaUrl': stepType == 'subcategory'
                      ? ''
                      : mediaUrlCtrl.text.trim(),
                  'imageUrl':
                      (stepType != 'subcategory' && mediaType == 'image')
                      ? mediaUrlCtrl.text.trim()
                      : '',
                  'updatedAt': FieldValue.serverTimestamp(),
                };
                if (stepType == 'question') {
                  payload['correctOptionId'] = correctOptionId;
                  payload['options'] = options;
                } else {
                  payload['correctOptionId'] = '';
                  payload['options'] = const <Map<String, dynamic>>[];
                }
                payload['buttonLabel'] = stepType == 'content'
                    ? buttonLabelCtrl.text.trim()
                    : '';

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
                  if (ctx.mounted) {
                    Navigator.of(ctx).pop();
                  }
                  await target.set({
                    ...payload,
                    if (existing == null)
                      'createdAt': FieldValue.serverTimestamp(),
                  }, SetOptions(merge: true));
                  await _syncTestToDrivers(testId: testId);
                  if (!mounted) return;
                  _showSnack(
                    existing == null ? 'Step added.' : 'Step updated.',
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
    for (final byLocale in optionCtrlsById.values) {
      for (final c in byLocale.values) {
        c.dispose();
      }
    }
    mediaUrlCtrl.dispose();
    buttonLabelCtrl.dispose();
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
      if (mounted && _previewStepId == question.id) {
        setState(() => _previewStepId = '');
      }
      await _syncTestToDrivers(testId: testId);
      _showSnack('Question deleted.');
    } catch (e) {
      _showSnack('Failed to delete question: $e', error: true);
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

  String _academyMediaFileName(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return 'media';
    return trimmed
        .replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_');
  }

  String _academyMediaExtension(String fileName, {String fallback = ''}) {
    final fromName = fileName.trim().toLowerCase();
    final idx = fromName.lastIndexOf('.');
    if (idx >= 0 && idx < fromName.length - 1) {
      return fromName.substring(idx + 1);
    }
    return fallback.trim().toLowerCase();
  }

  String _academyContentTypeForExtension(String ext, {required bool isVideo}) {
    final normalized = ext.trim().toLowerCase();
    if (isVideo) {
      switch (normalized) {
        case 'mov':
          return 'video/quicktime';
        case 'webm':
          return 'video/webm';
        case 'm4v':
          return 'video/x-m4v';
        case 'mp4':
        default:
          return 'video/mp4';
      }
    }
    switch (normalized) {
      case 'jpeg':
      case 'jpg':
        return 'image/jpeg';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'png':
      default:
        return 'image/png';
    }
  }

  Future<String?> _pickAndUploadAcademyStepMedia({
    required String testId,
    required bool isVideo,
  }) async {
    final scopeUid = _scopeUid;
    if (scopeUid == null || scopeUid.trim().isEmpty) {
      _showSnack('Missing DSP scope.', error: true);
      return null;
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: isVideo
            ? const ['mp4', 'mov', 'm4v', 'webm']
            : const ['jpg', 'jpeg', 'png', 'webp', 'gif'],
        allowMultiple: false,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return null;

      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) {
        _showSnack(
          'Could not read ${isVideo ? 'video' : 'image'} bytes.',
          error: true,
        );
        return null;
      }

      final extension = _academyMediaExtension(
        file.name,
        fallback: file.extension ?? '',
      );
      final allowed = isVideo
          ? const {'mp4', 'mov', 'm4v', 'webm'}
          : const {'jpg', 'jpeg', 'png', 'webp', 'gif'};
      if (!allowed.contains(extension)) {
        _showSnack(
          isVideo
              ? 'Unsupported video format. Use MP4, MOV, M4V, or WEBM.'
              : 'Unsupported image format. Use JPG, PNG, WEBP, or GIF.',
          error: true,
        );
        return null;
      }

      final safeName = _academyMediaFileName(file.name);
      final ref = fb.FirebaseStorage.instance
          .ref()
          .child('academy_content')
          .child(scopeUid)
          .child(testId)
          .child('${DateTime.now().millisecondsSinceEpoch}_$safeName');

      await ref.putData(
        bytes,
        fb.SettableMetadata(
          contentType: _academyContentTypeForExtension(
            extension,
            isVideo: isVideo,
          ),
        ),
      );
      return await ref.getDownloadURL();
    } catch (e) {
      _showSnack(
        'Failed to upload ${isVideo ? 'video' : 'image'}: $e',
        error: true,
      );
      return null;
    }
  }

  Future<void> _autoTranslateMissingQuestionFields({
    required List<String> localeCodes,
    required Map<String, TextEditingController> statementCtrls,
    required List<String> optionIds,
    required Map<String, Map<String, TextEditingController>> optionCtrlsById,
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
        final localizedCtrls = optionCtrlsById[optionId];
        if (localizedCtrls == null) continue;
        final enText = localizedCtrls['en']?.text.trim() ?? '';
        if (enText.isEmpty) continue;

        final optionTargets = <String>[];
        for (final code in localeCodes) {
          if (code == 'en') continue;
          final current = localizedCtrls[code]?.text.trim() ?? '';
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
            localizedCtrls[code]?.text = translated;
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

class _TestOption {
  final String id;
  final String label;
  final int order;
  const _TestOption({
    required this.id,
    required this.label,
    required this.order,
  });
}

class _AcademyStepGroup {
  final String title;
  final _AcademyQuestion? subcategory;
  final List<_AcademyQuestion> steps;

  const _AcademyStepGroup({
    required this.title,
    required this.subcategory,
    required this.steps,
  });
}

class _AcademyQuestion {
  final String id;
  final int order;
  final String parentId;
  final Map<String, String> localizedStatements;
  final List<_AcademyOption> options;
  final String correctOptionId;
  final String stepType;
  final String mediaType;
  final String mediaUrl;
  final String buttonLabel;

  const _AcademyQuestion({
    required this.id,
    required this.order,
    required this.parentId,
    required this.localizedStatements,
    required this.options,
    required this.correctOptionId,
    required this.stepType,
    required this.mediaType,
    required this.mediaUrl,
    required this.buttonLabel,
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

    final stepType = (data['stepType'] ?? data['type'] ?? 'question')
        .toString()
        .trim()
        .toLowerCase();
    final normalizedStepType = switch (stepType) {
      'content' => 'content',
      'subcategory' => 'subcategory',
      _ => 'question',
    };
    final parentId = (data['parentId'] ?? '').toString().trim();
    final mediaTypeRaw = (data['mediaType'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
    final mediaUrl = _firstNonEmptyStatic([
      (data['mediaUrl'] ?? '').toString().trim(),
      (data['imageUrl'] ?? '').toString().trim(),
      (data['videoUrl'] ?? '').toString().trim(),
      (data['mediaPath'] ?? '').toString().trim(),
      (data['url'] ?? '').toString().trim(),
    ]);
    final mediaType = (mediaTypeRaw == 'image' || mediaTypeRaw == 'video')
        ? mediaTypeRaw
        : _inferAcademyMediaTypeFromUrl(mediaUrl);
    final buttonLabel = (data['buttonLabel'] ?? '').toString().trim();

    final parsedOptions = <_AcademyOption>[];
    if (normalizedStepType == 'question') {
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
    }
    parsedOptions.sort((a, b) => a.order.compareTo(b.order));

    final hasMcq = normalizedStepType == 'question' && parsedOptions.isNotEmpty;
    final options = hasMcq ? parsedOptions : const <_AcademyOption>[];

    final legacyCorrect =
        data['correctAnswer'] == true ||
        data['correct'] == true ||
        data['answer'] == true;
    var correctId = (data['correctOptionId'] ?? '').toString().trim();
    if (normalizedStepType != 'question') {
      correctId = '';
    } else if (correctId.isEmpty) {
      correctId = hasMcq ? options.first.id : (legacyCorrect ? 'a' : 'b');
    }
    if (normalizedStepType == 'question' &&
        options.isNotEmpty &&
        !options.any((o) => o.id == correctId)) {
      correctId = options.first.id;
    }

    return _AcademyQuestion(
      id: normalizedId,
      order: (data['order'] as num?)?.toInt() ?? 0,
      parentId: parentId,
      localizedStatements: localized,
      options: options,
      correctOptionId: correctId,
      stepType: normalizedStepType,
      mediaType: mediaType,
      mediaUrl: mediaUrl,
      buttonLabel: buttonLabel,
    );
  }

  bool get isContentStep => stepType == 'content';
  bool get isQuestionStep => stepType == 'question';
  bool get isSubcategoryStep => stepType == 'subcategory';

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
      'parentId': parentId,
      'stepType': stepType,
      'statement': statementFor('en'),
    };
    payload['mediaType'] = mediaType;
    if (mediaUrl.isNotEmpty) payload['mediaUrl'] = mediaUrl;
    if (mediaType == 'image' && mediaUrl.isNotEmpty) {
      payload['imageUrl'] = mediaUrl;
    }
    if (mediaType == 'video' && mediaUrl.isNotEmpty) {
      payload['videoUrl'] = mediaUrl;
    }
    if (buttonLabel.isNotEmpty) payload['buttonLabel'] = buttonLabel;
    if (isQuestionStep) {
      payload['correctOptionId'] = correctOptionId;
      payload['options'] = options.map((o) => o.toPayload()).toList();
    } else {
      payload['correctOptionId'] = '';
      payload['options'] = const <Map<String, dynamic>>[];
    }
    for (final entry in localizedStatements.entries) {
      final value = entry.value.trim();
      if (value.isEmpty) continue;
      payload['statement_${entry.key}'] = value;
    }
    return payload;
  }

  static String _firstNonEmptyStatic(List<String> values) {
    for (final raw in values) {
      final value = raw.trim();
      if (value.isNotEmpty) return value;
    }
    return '';
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

class _CategoryPalette {
  final Color iconColor;
  final Color iconBg;

  const _CategoryPalette({required this.iconColor, required this.iconBg});
}

class _AdminCategoryTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final bool selected;
  final bool isNew;
  final VoidCallback onTap;

  const _AdminCategoryTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.selected,
    required this.isNew,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? _kAcademyGreen : _kAcademyCardBorder,
              width: selected ? 1.4 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _kAcademyText,
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        if (isNew)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'NEW',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (subtitle.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF667085),
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: selected ? _kAcademyGreen : const Color(0xFF8A94A6),
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BuilderPill extends StatelessWidget {
  final String label;
  final Color color;

  const _BuilderPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _AdminDriverPreviewCard extends StatelessWidget {
  final String moduleTitle;
  final String langCode;
  final _AcademyQuestion? step;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _AdminDriverPreviewCard({
    required this.moduleTitle,
    required this.langCode,
    required this.step,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final currentStep = step;
    if (currentStep == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kAcademyCardBorder),
        ),
        child: const Text(
          'Select a step to preview it in driver layout.',
          style: TextStyle(
            color: _kAcademySubText,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    final statement = currentStep.statementFor(langCode).trim();
    final typeLabel = currentStep.isSubcategoryStep
        ? 'Subcategory'
        : currentStep.isQuestionStep
        ? 'Question'
        : 'Content';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kAcademyCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.phone_iphone_rounded, color: _kAcademyGreen),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Driver Preview',
                  style: TextStyle(
                    color: _kAcademyText,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              _BuilderPill(label: typeLabel, color: const Color(0xFF0369A1)),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: AspectRatio(
                aspectRatio: 9 / 19,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F6F7),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: _kAcademyCardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xFF1F2937),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(22),
                          ),
                        ),
                        child: Text(
                          moduleTitle.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (currentStep.mediaType == 'image' &&
                                  currentStep.mediaUrl.isNotEmpty)
                                FutureBuilder<String?>(
                                  future: _resolveAcademyMediaUrl(
                                    currentStep.mediaUrl,
                                  ),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Container(
                                        height: 180,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF3F4F6),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.2,
                                          ),
                                        ),
                                      );
                                    }
                                    final resolved =
                                        snapshot.data?.trim() ?? '';
                                    if (resolved.isEmpty) {
                                      return Container(
                                        height: 180,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF3F4F6),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.broken_image_outlined,
                                          size: 42,
                                          color: Color(0xFF9CA3AF),
                                        ),
                                      );
                                    }
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        resolved,
                                        height: 180,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          height: 180,
                                          color: const Color(0xFFF3F4F6),
                                          alignment: Alignment.center,
                                          child: const Icon(
                                            Icons.broken_image_outlined,
                                            size: 42,
                                            color: Color(0xFF9CA3AF),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              if (currentStep.mediaType == 'video' &&
                                  currentStep.mediaUrl.isNotEmpty)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _kAcademyCardBorder,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 130,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF111827),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.play_circle_fill_rounded,
                                          color: Colors.white,
                                          size: 54,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Video preview',
                                        style: TextStyle(
                                          color: _kAcademySubText,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (currentStep.mediaType != 'none' &&
                                  currentStep.mediaUrl.isNotEmpty)
                                const SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: _kAcademyCardBorder,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      statement.isEmpty
                                          ? '(Empty step text)'
                                          : statement,
                                      style: const TextStyle(
                                        color: _kAcademyText,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        height: 1.35,
                                      ),
                                    ),
                                    if (currentStep.isQuestionStep) ...[
                                      const SizedBox(height: 10),
                                      ...currentStep.orderedOptions().map((
                                        option,
                                      ) {
                                        final isCorrect =
                                            option.id ==
                                            currentStep.correctOptionId;
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Icon(
                                                isCorrect
                                                    ? Icons.check_circle_rounded
                                                    : Icons
                                                          .radio_button_unchecked,
                                                size: 18,
                                                color: isCorrect
                                                    ? const Color(0xFF059669)
                                                    : const Color(0xFF94A3B8),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  option.textFor(langCode),
                                                  style: TextStyle(
                                                    color: isCorrect
                                                        ? const Color(
                                                            0xFF065F46,
                                                          )
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
                              ),
                              const SizedBox(height: 10),
                              Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1788C3),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.chevron_right_rounded,
                                  color: Colors.white,
                                  size: 36,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit selected'),
              ),
              OutlinedButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete selected'),
              ),
            ],
          ),
        ],
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
