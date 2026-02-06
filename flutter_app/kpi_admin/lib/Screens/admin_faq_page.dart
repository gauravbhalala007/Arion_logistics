import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../data/driver_faq_keys.dart';

const String _localizedFaqCollection = 'faqs_localized';
const String _insertAtStart = '__start__';
const String _insertAtEnd = '__end__';

class AdminFaqPage extends StatefulWidget {
  const AdminFaqPage({super.key});

  @override
  State<AdminFaqPage> createState() => _AdminFaqPageState();
}

class _LocaleFaqFields extends StatelessWidget {
  final String label;
  final TextEditingController questionCtrl;
  final TextEditingController answerCtrl;
  final bool initiallyExpanded;
  final String? questionHint;
  final String? answerHint;

  const _LocaleFaqFields({
    required this.label,
    required this.questionCtrl,
    required this.answerCtrl,
    required this.initiallyExpanded,
    this.questionHint,
    this.answerHint,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      initiallyExpanded: initiallyExpanded,
      title: Text('$label FAQ'),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Column(
            children: [
              TextField(
                controller: questionCtrl,
                decoration: InputDecoration(
                  labelText: 'Question',
                  hintText: questionHint,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: answerCtrl,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Answer',
                  hintText: answerHint,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FlatFaqNode {
  final DriverFaqNode node;
  final int depth;

  const _FlatFaqNode({
    required this.node,
    required this.depth,
  });
}

class _InsertOption {
  final String key;
  final String label;

  const _InsertOption({
    required this.key,
    required this.label,
  });
}

class _AdminFaqPageState extends State<AdminFaqPage> {
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? get _faqCol {
    final uid = _uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance.collection('users').doc(uid).collection('faqs');
  }

  CollectionReference<Map<String, dynamic>>? get _localizedFaqCol {
    final uid = _uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection(_localizedFaqCollection);
  }

  Future<void> _openFaqEditor({
    String? docId,
    Map<String, dynamic>? data,
    int? order,
  }) async {
    final t = AppLocalizations.of(context);
    final locales = AppLocalizations.supportedLocales;
    final qCtrls = <String, TextEditingController>{};
    final aCtrls = <String, TextEditingController>{};
    final insertOptions = _buildInsertOptions(t);
    final initialInsertKey =
        (data?['insertAfterKey'] ?? _insertAtEnd).toString();
    String selectedInsertKey = insertOptions.any((o) => o.key == initialInsertKey)
        ? initialInsertKey
        : _insertAtEnd;

    for (final locale in locales) {
      final code = locale.languageCode;
      final qValue = _localizedFaqValue(data, 'question', code);
      final aValue = _localizedFaqValue(data, 'answer', code);
      qCtrls[code] = TextEditingController(text: qValue);
      aCtrls[code] = TextEditingController(text: aValue);
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: Text(docId == null ? 'Add FAQ' : 'Edit FAQ'),
          content: SizedBox(
            width: 520,
            child: StatefulBuilder(
              builder: (context, setStateDialog) {
                return ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 560),
                  child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(top: 6, bottom: 6),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: DropdownButtonFormField<String>(
                          value: selectedInsertKey,
                          isExpanded: true,
                          selectedItemBuilder: (context) {
                            return insertOptions
                                .map(
                                  (option) => Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      option.label,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList();
                          },
                          items: insertOptions
                              .map(
                                (option) => DropdownMenuItem(
                                  value: option.key,
                                  child: Text(
                                    option.label,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setStateDialog(
                                () => selectedInsertKey = value ?? _insertAtEnd);
                          },
                          decoration: const InputDecoration(
                            labelText: 'Insert after',
                            labelStyle: TextStyle(height: 1.2),
                            border: OutlineInputBorder(),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...locales.map((locale) {
                        final code = locale.languageCode;
                        return _LocaleFaqFields(
                          label: code.toUpperCase(),
                          questionCtrl: qCtrls[code]!,
                          answerCtrl: aCtrls[code]!,
                          initiallyExpanded: code == 'en',
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (ok != true) {
      for (final ctrl in qCtrls.values) {
        ctrl.dispose();
      }
      for (final ctrl in aCtrls.values) {
        ctrl.dispose();
      }
      return;
    }

    final col = _faqCol;
    if (col == null) return;

    String firstNonEmpty(Map<String, TextEditingController> ctrls) {
      for (final locale in locales) {
        final code = locale.languageCode;
        final text = ctrls[code]?.text.trim() ?? '';
        if (text.isNotEmpty) return text;
      }
      return '';
    }

    final payload = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
      'order': order ?? DateTime.now().millisecondsSinceEpoch,
      'insertAfterKey': selectedInsertKey,
    };

    for (final locale in locales) {
      final code = locale.languageCode;
      final qText = qCtrls[code]?.text.trim() ?? '';
      final aText = aCtrls[code]?.text.trim() ?? '';
      payload['question_$code'] = qText;
      payload['answer_$code'] = aText;
    }

    final qEn = qCtrls['en']?.text.trim() ?? '';
    final aEn = aCtrls['en']?.text.trim() ?? '';
    payload['question'] = qEn.isNotEmpty ? qEn : firstNonEmpty(qCtrls);
    payload['answer'] = aEn.isNotEmpty ? aEn : firstNonEmpty(aCtrls);

    try {
      if (docId == null) {
        await col.add({
          ...payload,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await col.doc(docId).set(payload, SetOptions(merge: true));
      }
    } finally {
      for (final ctrl in qCtrls.values) {
        ctrl.dispose();
      }
      for (final ctrl in aCtrls.values) {
        ctrl.dispose();
      }
    }
  }

  Future<void> _openLocalizedFaqEditor({
    required DriverFaqNode node,
    Map<String, dynamic>? overrideData,
  }) async {
    final locales = AppLocalizations.supportedLocales;
    final qCtrls = <String, TextEditingController>{};
    final aCtrls = <String, TextEditingController>{};

    for (final locale in locales) {
      final code = locale.languageCode;
      final qOverride = _overrideValue(overrideData, 'question', code);
      final aOverride = _overrideValue(overrideData, 'answer', code);
      qCtrls[code] = TextEditingController(text: qOverride);
      aCtrls[code] = TextEditingController(text: aOverride);
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Edit Localized FAQ'),
          content: SizedBox(
            width: 600,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 560),
              child: ListView(
                shrinkWrap: true,
                children: [
                  const Text(
                    'Leave a field empty to use the built-in translation.',
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 12),
                  ...locales.map((locale) {
                    final code = locale.languageCode;
                    final t = AppLocalizations(locale);
                    return _LocaleFaqFields(
                      label: code.toUpperCase(),
                      questionCtrl: qCtrls[code]!,
                      answerCtrl: aCtrls[code]!,
                      initiallyExpanded: code == 'en',
                      questionHint: t.t(node.qKey),
                      answerHint: t.t(node.aKey),
                    );
                  }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (ok != true) {
      for (final ctrl in qCtrls.values) {
        ctrl.dispose();
      }
      for (final ctrl in aCtrls.values) {
        ctrl.dispose();
      }
      return;
    }

    final col = _localizedFaqCol;
    if (col == null) return;

    final payload = <String, dynamic>{
      'qKey': node.qKey,
      'aKey': node.aKey,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    var hasOverride = false;

    for (final locale in locales) {
      final code = locale.languageCode;
      final qText = qCtrls[code]?.text.trim() ?? '';
      final aText = aCtrls[code]?.text.trim() ?? '';
      final qField = 'question_$code';
      final aField = 'answer_$code';

      if (qText.isNotEmpty) {
        payload[qField] = qText;
        hasOverride = true;
      } else if (overrideData != null && overrideData.containsKey(qField)) {
        payload[qField] = FieldValue.delete();
      }

      if (aText.isNotEmpty) {
        payload[aField] = aText;
        hasOverride = true;
      } else if (overrideData != null && overrideData.containsKey(aField)) {
        payload[aField] = FieldValue.delete();
      }
    }

    try {
      if (!hasOverride) {
        if (overrideData != null) {
          await col.doc(node.qKey).delete();
        }
        return;
      }
      await col.doc(node.qKey).set(
            payload,
            SetOptions(merge: true),
          );
    } finally {
      for (final ctrl in qCtrls.values) {
        ctrl.dispose();
      }
      for (final ctrl in aCtrls.values) {
        ctrl.dispose();
      }
    }
  }

  String _overrideValue(
    Map<String, dynamic>? data,
    String field,
    String langCode,
  ) {
    if (data == null) return '';
    final raw = data['${field}_$langCode'];
    final text = raw?.toString().trim() ?? '';
    return text;
  }

  List<_FlatFaqNode> _flattenFaqNodes(
    List<DriverFaqNode> nodes, {
    int depth = 0,
  }) {
    final out = <_FlatFaqNode>[];
    for (final node in nodes) {
      out.add(_FlatFaqNode(node: node, depth: depth));
      if (node.children.isNotEmpty) {
        out.addAll(_flattenFaqNodes(node.children, depth: depth + 1));
      }
    }
    return out;
  }

  List<_InsertOption> _buildInsertOptions(AppLocalizations t) {
    final options = <_InsertOption>[
      const _InsertOption(key: _insertAtStart, label: 'Top'),
      ...DriverFaqKeys.items.map(
        (node) => _InsertOption(
          key: node.qKey,
          label: t.t(node.qKey),
        ),
      ),
      const _InsertOption(key: _insertAtEnd, label: 'End'),
    ];
    return options;
  }

  String _localizedFaqValue(
    Map<String, dynamic>? data,
    String field,
    String langCode,
  ) {
    if (data == null) return '';
    String? pick(String key) {
      final raw = data[key];
      if (raw == null) return null;
      final text = raw.toString().trim();
      return text.isEmpty ? null : text;
    }

    final fallbackKey = _firstLocalizedKey(data, field);

    return pick('${field}_$langCode') ??
        pick('${field}_en') ??
        pick(field) ??
        (fallbackKey != null ? pick(fallbackKey) : null) ??
        '';
  }

  String? _firstLocalizedKey(Map<String, dynamic> data, String field) {
    for (final entry in data.entries) {
      if (!entry.key.startsWith('${field}_')) continue;
      final text = entry.value?.toString().trim() ?? '';
      if (text.isNotEmpty) return entry.key;
    }
    return null;
  }

  Future<void> _confirmDelete(String docId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete FAQ?'),
        content: const Text('This will remove the FAQ for drivers.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok != true) return;
    final col = _faqCol;
    if (col == null) return;
    await col.doc(docId).delete();
  }

  String _localizedFaqText({
    required DriverFaqNode node,
    required Map<String, dynamic>? overrideData,
    required String langCode,
    required AppLocalizations t,
    required bool isQuestion,
  }) {
    final overrideText =
        _overrideValue(overrideData, isQuestion ? 'question' : 'answer', langCode);
    if (overrideText.isNotEmpty) return overrideText;
    return t.t(isQuestion ? node.qKey : node.aKey);
  }

  Widget _buildCustomFaqsSection(CollectionReference<Map<String, dynamic>> col) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: col.orderBy('order').snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('No custom FAQs yet.'),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final d = docs[i];
            final data = d.data();
            final langCode = Localizations.localeOf(context).languageCode;
            final question = _localizedFaqValue(data, 'question', langCode);
            final answer = _localizedFaqValue(data, 'answer', langCode);
            final order = (data['order'] as num?)?.toInt();

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          question.isEmpty ? 'Untitled question' : question,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Edit',
                        onPressed: () => _openFaqEditor(
                          docId: d.id,
                          data: data,
                          order: order,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Delete',
                        onPressed: () => _confirmDelete(d.id),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    answer,
                    style: const TextStyle(
                      color: Color(0xFF4B5563),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLocalizedFaqsSection() {
    final col = _localizedFaqCol;
    if (col == null) {
      return const Center(child: Text('You must be logged in.'));
    }

    final flatItems = _flattenFaqNodes(DriverFaqKeys.items);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: col.snapshots(),
      builder: (context, snap) {
        final docs = snap.data?.docs ?? [];
        final overrides = <String, Map<String, dynamic>>{};
        for (final d in docs) {
          overrides[d.id] = d.data();
        }

        final langCode = Localizations.localeOf(context).languageCode;
        final t = AppLocalizations.of(context);

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: flatItems.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final item = flatItems[i];
            final node = item.node;
            final overrideData = overrides[node.qKey];
            final isHidden = overrideData?['hidden'] == true;
            final question = _localizedFaqText(
              node: node,
              overrideData: overrideData,
              langCode: langCode,
              t: t,
              isQuestion: true,
            );
            final answer = _localizedFaqText(
              node: node,
              overrideData: overrideData,
              langCode: langCode,
              t: t,
              isQuestion: false,
            );

            return Container(
              margin: EdgeInsets.only(left: item.depth * 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          question,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Hide',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          Switch(
                            value: isHidden,
                            onChanged: (value) => _setHiddenForNode(
                              node.qKey,
                              value,
                              overrideData,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Edit',
                        onPressed: () => _openLocalizedFaqEditor(
                          node: node,
                          overrideData: overrideData,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    answer,
                    style: const TextStyle(
                      color: Color(0xFF4B5563),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _setHiddenForNode(
    String qKey,
    bool hidden,
    Map<String, dynamic>? overrideData,
  ) async {
    final col = _localizedFaqCol;
    if (col == null) return;
    final doc = col.doc(qKey);

    if (hidden) {
      await doc.set(
        {
          'hidden': true,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      return;
    }

    if (overrideData == null) {
      return;
    }

    await doc.set(
      {
        'hidden': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final col = _faqCol;
    if (col == null) {
      return const Center(child: Text('You must be logged in.'));
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'FAQs',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => _openFaqEditor(),
                icon: const Icon(Icons.add),
                label: const Text('Add Custom FAQ'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: [
                const _SectionHeader(title: 'Localized FAQs'),
                _buildLocalizedFaqsSection(),
                const SizedBox(height: 24),
                const _SectionHeader(title: 'Custom FAQs'),
                _buildCustomFaqsSection(col),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: Color(0xFF111827),
        ),
      ),
    );
  }
}
