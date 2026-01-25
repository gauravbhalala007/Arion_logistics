// lib/screens/driver_faq_page.dart
import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../data/driver_faq_keys.dart';

class DriverFaqPage extends StatefulWidget {
  const DriverFaqPage({super.key});

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

    // Filter tree (keeps hierarchy, but prunes to matches)
    final filteredTree = _filterTree(
      nodes: DriverFaqKeys.items,
      t: t,
      query: query,
    );

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
      body: ListView(
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

          if (filteredTree.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Text(
                t.t('faq_empty'),
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            ...filteredTree.map(
              (node) => _FaqNodeCard(
                node: node,
                t: t,
                depth: 0,
              ),
            ),
        ],
      ),
    );
  }

  /// Returns a pruned FAQ tree containing:
  /// - Any node that matches query in Q/A
  /// - Any node that has matching descendants (keeps parent so user can see context)
  List<DriverFaqNode> _filterTree({
    required List<DriverFaqNode> nodes,
    required AppLocalizations t,
    required String query,
  }) {
    if (query.isEmpty) return nodes;

    bool matchesNode(DriverFaqNode n) {
      final qText = t.t(n.qKey).toLowerCase();
      final aText = t.t(n.aKey).toLowerCase();
      return qText.contains(query) || aText.contains(query);
    }

    List<DriverFaqNode> recurse(List<DriverFaqNode> input) {
      final out = <DriverFaqNode>[];
      for (final n in input) {
        final prunedKids = recurse(n.children);
        final selfMatch = matchesNode(n);
        if (selfMatch || prunedKids.isNotEmpty) {
          out.add(
            DriverFaqNode(
              qKey: n.qKey,
              aKey: n.aKey,
              children: prunedKids,
            ),
          );
        }
      }
      return out;
    }

    return recurse(nodes);
  }
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
  final AppLocalizations t;
  final int depth;

  const _FaqNodeCard({
    required this.node,
    required this.t,
    required this.depth,
  });

  @override
  Widget build(BuildContext context) {
    final question = t.t(node.qKey);
    final answer = t.t(node.aKey);

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
                  t: t,
                  depth: depth + 1,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
