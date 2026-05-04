import 'package:cloud_firestore/cloud_firestore.dart';

import 'driver_faq_keys.dart';

const String faqOrderSettingsCollection = 'settings';
const String faqContentOrderDocId = 'content_order';
const String faqTopLevelOrderField = 'faqTopLevelOrder';

const String _faqInsertAtStart = '__start__';
const String _faqInsertAtEnd = '__end__';

class CustomFaqOrderSource {
  final String docId;
  final String insertAfterKey;
  final int legacyOrder;

  const CustomFaqOrderSource({
    required this.docId,
    required this.insertAfterKey,
    required this.legacyOrder,
  });
}

DocumentReference<Map<String, dynamic>> faqContentOrderDoc(String dspUid) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(dspUid)
      .collection(faqOrderSettingsCollection)
      .doc(faqContentOrderDocId);
}

List<String> parseFaqTopLevelOrder(Map<String, dynamic>? data) {
  final raw = data?[faqTopLevelOrderField];
  if (raw is! List) return const [];
  return raw
      .map((item) => item.toString().trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}

Future<void> saveFaqTopLevelOrder({
  required String dspUid,
  required List<String> order,
}) {
  final normalized = order
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
  return faqContentOrderDoc(dspUid).set({
    faqTopLevelOrderField: normalized,
    'updatedAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
}

Future<void> appendFaqTopLevelOrderEntryIfConfigured({
  required String dspUid,
  required String entryId,
}) async {
  final normalized = entryId.trim();
  if (normalized.isEmpty) return;

  final ref = faqContentOrderDoc(dspUid);
  final snap = await ref.get();
  if (!snap.exists) return;

  final current = parseFaqTopLevelOrder(snap.data());
  if (current.contains(normalized)) return;

  await saveFaqTopLevelOrder(dspUid: dspUid, order: [...current, normalized]);
}

Future<void> removeFaqTopLevelOrderEntry({
  required String dspUid,
  required String entryId,
}) async {
  final normalized = entryId.trim();
  if (normalized.isEmpty) return;

  final ref = faqContentOrderDoc(dspUid);
  final snap = await ref.get();
  if (!snap.exists) return;

  final current = parseFaqTopLevelOrder(snap.data());
  if (!current.contains(normalized)) return;

  await saveFaqTopLevelOrder(
    dspUid: dspUid,
    order: current.where((item) => item != normalized).toList(growable: false),
  );
}

Map<String, String> _faqTopLevelParentMap() {
  final out = <String, String>{};

  void visit(DriverFaqNode node, String topLevelKey) {
    out[node.qKey] = topLevelKey;
    for (final child in node.children) {
      visit(child, topLevelKey);
    }
  }

  for (final node in DriverFaqKeys.items) {
    visit(node, node.qKey);
  }

  return out;
}

String? faqTopLevelParentForKey(String rawKey) {
  final key = rawKey.trim();
  if (key.isEmpty) return null;
  return _faqTopLevelParentMap()[key];
}

List<String> topLevelBuiltInFaqKeys() {
  return DriverFaqKeys.items
      .map((node) => node.qKey)
      .toList(growable: false);
}

int _compareLegacyCustomFaqs(CustomFaqOrderSource a, CustomFaqOrderSource b) {
  final byOrder = a.legacyOrder.compareTo(b.legacyOrder);
  if (byOrder != 0) return byOrder;
  return a.docId.compareTo(b.docId);
}

List<String> resolveFaqTopLevelOrder({
  required List<String> builtInTopLevelKeys,
  required List<CustomFaqOrderSource> customFaqs,
  required List<String> savedOrder,
}) {
  final builtInSet = builtInTopLevelKeys.toSet();
  final customIds = customFaqs.map((item) => item.docId).toSet();

  if (savedOrder.isNotEmpty) {
    final out = <String>[];
    final used = <String>{};

    for (final raw in savedOrder) {
      final id = raw.trim();
      if (id.isEmpty) continue;
      if (!builtInSet.contains(id) && !customIds.contains(id)) continue;
      if (used.add(id)) out.add(id);
    }

    for (final key in builtInTopLevelKeys) {
      if (used.add(key)) out.add(key);
    }

    final missingCustoms = customFaqs
        .where((item) => !used.contains(item.docId))
        .toList(growable: false)
      ..sort(_compareLegacyCustomFaqs);
    out.addAll(missingCustoms.map((item) => item.docId));
    return out;
  }

  final byAnchor = <String, List<CustomFaqOrderSource>>{};
  final startItems = <CustomFaqOrderSource>[];
  final endItems = <CustomFaqOrderSource>[];
  final unknownItems = <CustomFaqOrderSource>[];

  for (final item in customFaqs) {
    final rawAnchor = item.insertAfterKey.trim();
    if (rawAnchor.isEmpty || rawAnchor == _faqInsertAtEnd) {
      endItems.add(item);
      continue;
    }
    if (rawAnchor == _faqInsertAtStart) {
      startItems.add(item);
      continue;
    }

    final topLevelParent = faqTopLevelParentForKey(rawAnchor);
    if (topLevelParent == null) {
      unknownItems.add(item);
      continue;
    }

    byAnchor.putIfAbsent(topLevelParent, () => <CustomFaqOrderSource>[]).add(
      item,
    );
  }

  startItems.sort(_compareLegacyCustomFaqs);
  endItems.sort(_compareLegacyCustomFaqs);
  unknownItems.sort(_compareLegacyCustomFaqs);
  for (final items in byAnchor.values) {
    items.sort(_compareLegacyCustomFaqs);
  }

  final out = <String>[
    ...startItems.map((item) => item.docId),
  ];

  for (final topLevelKey in builtInTopLevelKeys) {
    out.add(topLevelKey);
    out.addAll(
      (byAnchor[topLevelKey] ?? const <CustomFaqOrderSource>[])
          .map((item) => item.docId),
    );
  }

  out.addAll(endItems.map((item) => item.docId));
  out.addAll(unknownItems.map((item) => item.docId));
  return out;
}
