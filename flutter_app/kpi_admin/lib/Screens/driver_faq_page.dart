// lib/screens/driver_faq_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../data/driver_faq_keys.dart';

const String _localizedFaqCollection = 'faqs_localized';
const String _insertAtStart = '__start__';
const String _insertAtEnd = '__end__';

class DriverFaqPage extends StatefulWidget {
  final String dspUid;

  const DriverFaqPage({super.key, required this.dspUid});

  @override
  State<DriverFaqPage> createState() => _DriverFaqPageState();
}

class _DriverFaqPageState extends State<DriverFaqPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _q = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final query = _q.trim().toLowerCase();

    final customFaqStream = widget.dspUid.isEmpty
        ? const Stream<QuerySnapshot<Map<String, dynamic>>>.empty()
        : FirebaseFirestore.instance
              .collection('users')
              .doc(widget.dspUid)
              .collection('faqs')
              .orderBy('order')
              .snapshots();
    final localizedOverrideStream = widget.dspUid.isEmpty
        ? const Stream<QuerySnapshot<Map<String, dynamic>>>.empty()
        : FirebaseFirestore.instance
              .collection('users')
              .doc(widget.dspUid)
              .collection(_localizedFaqCollection)
              .snapshots();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text(
          t.t('faq_title'),
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: localizedOverrideStream,
        builder: (context, overrideSnap) {
          final overrideDocs = overrideSnap.data?.docs ?? [];
          final overrides = <String, Map<String, dynamic>>{};
          for (final doc in overrideDocs) {
            overrides[doc.id] = doc.data();
          }

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: customFaqStream,
            builder: (context, snap) {
              final docs = snap.data?.docs ?? [];
              final langCode = Localizations.localeOf(context).languageCode;
              final customItems = docs
                  .map(
                    (d) => _FaqItem(
                      question: _localizedFaqValue(
                        d.data(),
                        'question',
                        langCode,
                      ),
                      answer: _localizedFaqValue(d.data(), 'answer', langCode),
                      insertAfterKey:
                          (d.data()['insertAfterKey'] ?? _insertAtEnd)
                              .toString(),
                      order:
                          (d.data()['order'] as num?)?.toInt() ??
                          DateTime.now().millisecondsSinceEpoch,
                    ),
                  )
                  .toList();

              String resolveText(DriverFaqNode node, bool isQuestion) {
                final overrideData = overrides[node.qKey];
                final overrideText = _overrideValue(
                  overrideData,
                  isQuestion ? 'question' : 'answer',
                  langCode,
                );
                if (overrideText.isNotEmpty) return overrideText;
                return t.t(isQuestion ? node.qKey : node.aKey);
              }

              final filteredCustom = _filterFaqItems(customItems, query);

              final visibleNodes = _pruneHiddenNodes(
                DriverFaqKeys.items,
                overrides,
              );

              // Filter tree (keeps hierarchy, but prunes to matches)
              final filteredTree = _filterTree(
                nodes: visibleNodes,
                resolveText: resolveText,
                query: query,
              );

              final hasResults =
                  filteredCustom.isNotEmpty || filteredTree.isNotEmpty;

              final customByInsert = <String, List<_FaqItem>>{};
              for (final item in filteredCustom) {
                final key = item.insertAfterKey.isEmpty
                    ? _insertAtEnd
                    : item.insertAfterKey;
                customByInsert.putIfAbsent(key, () => []).add(item);
              }

              for (final items in customByInsert.values) {
                items.sort((a, b) => a.order.compareTo(b.order));
              }

              final combinedWidgets = <Widget>[];
              final usedInsertKeys = <String>{};

              void addCustomGroup(String key) {
                final items = customByInsert[key];
                if (items == null || items.isEmpty) return;
                usedInsertKeys.add(key);
                combinedWidgets.addAll(
                  items.map((item) => _FaqItemCard(item: item)),
                );
                combinedWidgets.add(const SizedBox(height: 8));
              }

              addCustomGroup(_insertAtStart);

              if (filteredTree.isNotEmpty) {
                for (final node in filteredTree) {
                  combinedWidgets.add(
                    _FaqNodeCard(
                      node: node,
                      depth: 0,
                      resolveText: resolveText,
                    ),
                  );
                  combinedWidgets.add(const SizedBox(height: 8));
                  addCustomGroup(node.qKey);
                }
              }

              addCustomGroup(_insertAtEnd);

              for (final entry in customByInsert.entries) {
                if (usedInsertKeys.contains(entry.key)) continue;
                combinedWidgets.addAll(
                  entry.value.map((item) => _FaqItemCard(item: item)),
                );
                combinedWidgets.add(const SizedBox(height: 8));
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _SearchBar(
                    controller: _searchCtrl,
                    hint: t.t('faq_search_hint'),
                    onChanged: (v) => setState(() => _q = v),
                    onClear: () {
                      _searchCtrl.clear();
                      setState(() => _q = '');
                    },
                  ),
                  const SizedBox(height: 12),
                  if (!hasResults) _emptyCard(t.t('faq_empty')),
                  if (combinedWidgets.isNotEmpty) ...combinedWidgets,
                ],
              );
            },
          );
        },
      ),
    );
  }

  /// Returns a pruned FAQ tree containing:
  /// - Any node that matches query in Q/A
  /// - Any node that has matching descendants (keeps parent so user can see context)
  List<DriverFaqNode> _filterTree({
    required List<DriverFaqNode> nodes,
    required String Function(DriverFaqNode node, bool isQuestion) resolveText,
    required String query,
  }) {
    if (query.isEmpty) return nodes;

    bool matchesNode(DriverFaqNode n) {
      final qText = resolveText(n, true).toLowerCase();
      final aText = resolveText(n, false).toLowerCase();
      return qText.contains(query) || aText.contains(query);
    }

    List<DriverFaqNode> recurse(List<DriverFaqNode> input) {
      final out = <DriverFaqNode>[];
      for (final n in input) {
        final prunedKids = recurse(n.children);
        final selfMatch = matchesNode(n);
        if (selfMatch || prunedKids.isNotEmpty) {
          out.add(
            DriverFaqNode(qKey: n.qKey, aKey: n.aKey, children: prunedKids),
          );
        }
      }
      return out;
    }

    return recurse(nodes);
  }

  List<DriverFaqNode> _pruneHiddenNodes(
    List<DriverFaqNode> nodes,
    Map<String, Map<String, dynamic>> overrides,
  ) {
    List<DriverFaqNode> recurse(List<DriverFaqNode> input) {
      final out = <DriverFaqNode>[];
      for (final node in input) {
        final hidden = overrides[node.qKey]?['hidden'] == true;
        if (hidden) continue;
        final prunedChildren = recurse(node.children);
        out.add(
          DriverFaqNode(
            qKey: node.qKey,
            aKey: node.aKey,
            children: prunedChildren,
          ),
        );
      }
      return out;
    }

    return recurse(nodes);
  }

  List<_FaqItem> _filterFaqItems(List<_FaqItem> items, String query) {
    if (query.isEmpty) return items;
    return items.where((item) {
      final q = item.question.toLowerCase();
      final a = item.answer.toLowerCase();
      return q.contains(query) || a.contains(query);
    }).toList();
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

  String _localizedFaqValue(
    Map<String, dynamic> data,
    String field,
    String langCode,
  ) {
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

  Widget _emptyCard(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF6B7280),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;
  final String insertAfterKey;
  final int order;

  const _FaqItem({
    required this.question,
    required this.answer,
    required this.insertAfterKey,
    required this.order,
  });
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.hint,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF6B7280)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              final show = value.text.trim().isNotEmpty;
              if (!show) return const SizedBox.shrink();
              return IconButton(
                onPressed: onClear,
                icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FaqNodeCard extends StatelessWidget {
  final DriverFaqNode node;
  final int depth;
  final String Function(DriverFaqNode node, bool isQuestion) resolveText;

  const _FaqNodeCard({
    required this.node,
    required this.depth,
    required this.resolveText,
  });

  @override
  Widget build(BuildContext context) {
    final question = resolveText(node, true);
    final answer = resolveText(node, false);

    final bool hasChildren = node.children.isNotEmpty;

    // Visual indentation for sub-questions
    final leftIndent = (depth * 12).toDouble();
    final bg = Colors.white;
    final border = const Color(0xFFE5E7EB);

    return Container(
      margin: EdgeInsets.only(bottom: 12, left: leftIndent),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          iconColor: const Color(0xFF111827),
          collapsedIconColor: const Color(0xFF6B7280),
          title: Text(
            question,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111827),
              // Slightly smaller for deep nesting
              fontSize: depth == 0 ? 16 : (depth == 1 ? 15 : 14),
            ),
          ),
          children: [
            const SizedBox(height: 6),
            Text(
              answer,
              style: const TextStyle(
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            if (hasChildren) ...[
              const SizedBox(height: 10),
              ...node.children.map(
                (child) => _FaqNodeCard(
                  node: child,
                  depth: depth + 1,
                  resolveText: resolveText,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FaqItemCard extends StatelessWidget {
  final _FaqItem item;

  const _FaqItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          iconColor: const Color(0xFF111827),
          collapsedIconColor: const Color(0xFF6B7280),
          title: Text(
            item.question.isEmpty ? 'Question' : item.question,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
              fontSize: 16,
            ),
          ),
          children: [
            const SizedBox(height: 6),
            Text(
              item.answer,
              style: const TextStyle(
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
