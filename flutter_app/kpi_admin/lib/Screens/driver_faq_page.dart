// lib/screens/driver_faq_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as fb;
import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../data/driver_faq_keys.dart';
import '../data/faq_ordering.dart';
import '../widgets/web_preview.dart';
import '../widgets/motion_helpers.dart';

const String _localizedFaqCollection = 'faqs_localized';
const String _insertAtEnd = '__end__';

Future<String?> _resolveFaqImageUrl({
  required String rawUrl,
  required String rawPath,
}) async {
  final pathValue = rawPath.trim();
  if (pathValue.isNotEmpty) {
    try {
      final normalized = pathValue.startsWith('/')
          ? pathValue.substring(1)
          : pathValue;
      return await fb.FirebaseStorage.instance
          .ref()
          .child(normalized)
          .getDownloadURL();
    } catch (_) {
      // ignore and fall back to URL resolution
    }
  }

  final value = rawUrl.trim();
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
    // ignore resolution failures
  }
  return null;
}

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
    final faqOrderStream = widget.dspUid.isEmpty
        ? const Stream<DocumentSnapshot<Map<String, dynamic>>>.empty()
        : faqContentOrderDoc(widget.dspUid).snapshots();

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
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: faqOrderStream,
        builder: (context, orderSnap) {
          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: localizedOverrideStream,
            builder: (context, overrideSnap) {
              final overrideDocs =
                  overrideSnap.data?.docs ??
                  <QueryDocumentSnapshot<Map<String, dynamic>>>[];
              final overrides = <String, Map<String, dynamic>>{};
              for (final doc in overrideDocs) {
                overrides[doc.id] = doc.data();
              }

              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: customFaqStream,
                builder: (context, snap) {
                  final docs =
                      snap.data?.docs ??
                      <QueryDocumentSnapshot<Map<String, dynamic>>>[];
                  final langCode = Localizations.localeOf(context).languageCode;
                  final customItems = docs
                      .map(
                        (d) => _FaqItem(
                          id: d.id,
                          question: _localizedFaqValue(
                            d.data(),
                            'question',
                            langCode,
                          ),
                          answer: _localizedFaqValue(
                            d.data(),
                            'answer',
                            langCode,
                          ),
                          insertAfterKey:
                              (d.data()['insertAfterKey'] ?? _insertAtEnd)
                                  .toString(),
                          imageUrl: (d.data()['imageUrl'] ?? '')
                              .toString()
                              .trim(),
                          imagePath: (d.data()['imagePath'] ?? '')
                              .toString()
                              .trim(),
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

                  Map<String, String> resolveImage(DriverFaqNode node) {
                    final overrideData = overrides[node.qKey];
                    return {
                      'imageUrl': (overrideData?['imageUrl'] ?? '')
                          .toString()
                          .trim(),
                      'imagePath': (overrideData?['imagePath'] ?? '')
                          .toString()
                          .trim(),
                    };
                  }

                  final filteredCustom = _filterFaqItems(customItems, query);
                  final visibleNodes = _pruneHiddenNodes(
                    DriverFaqKeys.items,
                    overrides,
                  );
                  final filteredTree = _filterTree(
                    nodes: visibleNodes,
                    resolveText: resolveText,
                    query: query,
                  );
                  final combinedWidgets = _buildOrderedFaqWidgets(
                    filteredTopLevelNodes: filteredTree,
                    visibleCustomItems: filteredCustom,
                    allCustomItems: customItems,
                    savedOrder: parseFaqTopLevelOrder(orderSnap.data?.data()),
                    resolveText: resolveText,
                    resolveImage: resolveImage,
                  );
                  final hasResults =
                      filteredCustom.isNotEmpty || filteredTree.isNotEmpty;

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

  List<Widget> _buildOrderedFaqWidgets({
    required List<DriverFaqNode> filteredTopLevelNodes,
    required List<_FaqItem> visibleCustomItems,
    required List<_FaqItem> allCustomItems,
    required List<String> savedOrder,
    required String Function(DriverFaqNode node, bool isQuestion) resolveText,
    required Map<String, String> Function(DriverFaqNode node) resolveImage,
  }) {
    final filteredBuiltInById = {
      for (final node in filteredTopLevelNodes) node.qKey: node,
    };
    final visibleCustomById = {
      for (final item in visibleCustomItems) item.id: item,
    };

    final resolvedOrder = resolveFaqTopLevelOrder(
      builtInTopLevelKeys: topLevelBuiltInFaqKeys(),
      customFaqs: allCustomItems
          .map(
            (item) => CustomFaqOrderSource(
              docId: item.id,
              insertAfterKey: item.insertAfterKey,
              legacyOrder: item.order,
            ),
          )
          .toList(growable: false),
      savedOrder: savedOrder,
    );

    final widgets = <Widget>[];
    for (final id in resolvedOrder) {
      final builtInNode = filteredBuiltInById[id];
      if (builtInNode != null) {
        widgets.add(
          _FaqNodeCard(
            key: ValueKey('faq-node-$id'),
            node: builtInNode,
            depth: 0,
            resolveText: resolveText,
            resolveImage: resolveImage,
          ),
        );
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      final customItem = visibleCustomById[id];
      if (customItem != null) {
        widgets.add(
          _FaqItemCard(key: ValueKey('faq-custom-$id'), item: customItem),
        );
        widgets.add(const SizedBox(height: 8));
      }
    }
    return widgets;
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
  final String id;
  final String question;
  final String answer;
  final String insertAfterKey;
  final String imageUrl;
  final String imagePath;
  final int order;

  const _FaqItem({
    required this.id,
    required this.question,
    required this.answer,
    required this.insertAfterKey,
    required this.imageUrl,
    required this.imagePath,
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
        color: const Color(0xFFEFEFF4),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            color: Color(0xFF6B7280),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1C1C1E),
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF9CA3AF),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                isDense: true,
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              final show = value.text.trim().isNotEmpty;
              if (!show) return const SizedBox.shrink();
              return InkWell(
                onTap: onClear,
                borderRadius: BorderRadius.circular(999),
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(
                    Icons.close_rounded,
                    color: Color(0xFF6B7280),
                    size: 18,
                  ),
                ),
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
  final Map<String, String> Function(DriverFaqNode node) resolveImage;

  const _FaqNodeCard({
    super.key,
    required this.node,
    required this.depth,
    required this.resolveText,
    required this.resolveImage,
  });

  @override
  Widget build(BuildContext context) {
    final question = resolveText(node, true);
    final answer = resolveText(node, false);
    final image = resolveImage(node);

    final bool hasChildren = node.children.isNotEmpty;

    // Visual indentation for sub-questions
    final leftIndent = (depth * 12).toDouble();
    final bg = Colors.white;
    final border = const Color(0xFFE5E7EB);

    return Container(
      margin: EdgeInsets.only(bottom: 12, left: leftIndent),
      alignment: Alignment.centerLeft,
      width: double.infinity,
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
                    expandedAlignment: Alignment.centerLeft,

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

              textAlign: TextAlign.start,
              style: const TextStyle(
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),

            if ((image['imageUrl'] ?? '').isNotEmpty ||
                (image['imagePath'] ?? '').isNotEmpty) ...[
              const SizedBox(height: 12),
              _FaqSampleImage(
                imageUrl: image['imageUrl'] ?? '',
                imagePath: image['imagePath'] ?? '',
              ),
            ],
            if (hasChildren) ...[
              const SizedBox(height: 10),
              ...node.children.map(
                (child) => _FaqNodeCard(
                  node: child,
                  depth: depth + 1,
                  resolveText: resolveText,
                  resolveImage: resolveImage,
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

  const _FaqItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      width:double.infinity ,
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
          expandedAlignment: Alignment.centerLeft,
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
              textAlign: TextAlign.start,
              style: const TextStyle(
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            if (item.imageUrl.isNotEmpty || item.imagePath.isNotEmpty) ...[
              const SizedBox(height: 12),
              _FaqSampleImage(
                imageUrl: item.imageUrl,
                imagePath: item.imagePath,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FaqSampleImage extends StatelessWidget {
  final String imageUrl;
  final String imagePath;

  const _FaqSampleImage({required this.imageUrl, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: SizedBox(
          height: 320,
          width: double.infinity,
          child: FutureBuilder<String?>(
            future: _resolveFaqImageUrl(rawUrl: imageUrl, rawPath: imagePath),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const ColoredBox(
                  color: Color(0xFFF3F4F6),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final resolvedUrl = snapshot.data?.trim() ?? '';
              final effectiveUrl = resolvedUrl.isNotEmpty
                  ? resolvedUrl
                  : ((imageUrl.startsWith('http://') ||
                            imageUrl.startsWith('https://'))
                        ? imageUrl
                        : '');
              if (effectiveUrl.isEmpty) {
                return Container(
                  color: const Color(0xFFF3F4F6),
                  alignment: Alignment.center,
                  child: const Text(
                    'Sample image unavailable.',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }
              return Container(
                color: const Color(0xFFF3F4F6),
                alignment: Alignment.center,
                child: buildWebImagePreview(effectiveUrl),
              );
            },
          ),
        ),
      ),
    );
  }
}
