import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/inventory_seed.dart';
import '../models/inventory_item.dart';
import '../models/supplier.dart';

class InventoryRepository {
  InventoryRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _itemsCol(String adminUid) =>
      _firestore.collection('users').doc(adminUid).collection('inventory');

  CollectionReference<Map<String, dynamic>> _cartCol(String adminUid) =>
      _firestore
          .collection('users')
          .doc(adminUid)
          .collection('inventory_cart');

  CollectionReference<Map<String, dynamic>> _receiptsCol(String adminUid) =>
      _firestore
          .collection('users')
          .doc(adminUid)
          .collection('goods_receipts');

  CollectionReference<Map<String, dynamic>> _suppliersCol(String adminUid) =>
      _firestore.collection('users').doc(adminUid).collection('suppliers');

  // ─── Suppliers ────────────────────────────────────────────────────────

  Stream<List<Supplier>> watchSuppliers({required String adminUid}) {
    return _suppliersCol(adminUid).snapshots().map(
      (snap) => snap.docs.map(Supplier.fromDoc).toList()
        ..sort((a, b) =>
            a.name.toLowerCase().compareTo(b.name.toLowerCase())),
    );
  }

  Future<Supplier> createSupplier({
    required String adminUid,
    required String name,
    String contact = '',
    String notes = '',
  }) async {
    final ref = await _suppliersCol(adminUid).add(<String, dynamic>{
      'name': name.trim(),
      'contact': contact.trim(),
      'notes': notes.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    final snap = await ref.get();
    return Supplier.fromDoc(snap);
  }

  // ─── Items ────────────────────────────────────────────────────────────

  Stream<List<InventoryItem>> watchItems({required String adminUid}) {
    return _itemsCol(adminUid).snapshots().map(
      (snap) => snap.docs
          .map(InventoryItem.fromDoc)
          .toList()
        // Highest stock first; ties fall back to alphabetical by name.
        ..sort((a, b) {
          final byStock = b.stock.compareTo(a.stock);
          if (byStock != 0) return byStock;
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        }),
    );
  }

  Future<DocumentReference<Map<String, dynamic>>> createItem({
    required String adminUid,
    required InventoryItem item,
  }) async {
    return _itemsCol(adminUid).add(item.toCreatePayload());
  }

  Future<void> updateItem({
    required String adminUid,
    required InventoryItem item,
  }) async {
    await _itemsCol(adminUid).doc(item.id).update(item.toUpdatePayload());
  }

  /// Replace just the photo of [itemId] with a new pre-encoded base64
  /// string. Used by the drag-and-drop image hotspot on the card.
  Future<void> updatePhoto({
    required String adminUid,
    required String itemId,
    required String photoBase64,
  }) async {
    await _itemsCol(adminUid).doc(itemId).update(<String, dynamic>{
      'photoBase64': photoBase64,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteItem({
    required String adminUid,
    required String itemId,
  }) async {
    await _itemsCol(adminUid).doc(itemId).delete();
  }

  /// Upsert the canonical catalog by SKU. Existing items with a
  /// matching SKU get refreshed (name, supplier, photo, notes,
  /// sizeOptions, threshold) WITHOUT touching the admin-curated
  /// `stock` and `stockBySize` fields. New SKUs are created.
  Future<int> seedStandardCatalog({required String adminUid}) async {
    final existing = await _itemsCol(adminUid).get();
    final bySku = <String, DocumentReference<Map<String, dynamic>>>{};
    final lowMapBySku = <String, Map<String, int>>{};
    for (final d in existing.docs) {
      final data = d.data();
      final sku = (data['sku'] ?? '').toString().trim().toUpperCase();
      if (sku.isEmpty) continue;
      bySku[sku] = d.reference;
      final raw = data['lowStockBySize'];
      if (raw is Map) {
        lowMapBySku[sku] = <String, int>{
          for (final e in raw.entries)
            e.key.toString(): (e.value is num)
                ? (e.value as num).toInt()
                : int.tryParse('${e.value}') ?? 0,
        };
      }
    }

    final batches = <WriteBatch>[];
    WriteBatch current = _firestore.batch();
    var inBatch = 0;
    var touched = 0;
    for (final seed in kInventorySeedItems) {
      final skuKey = seed.sku.trim().toUpperCase();
      final existingRef = bySku[skuKey];
      if (existingRef != null) {
        current.update(existingRef, <String, dynamic>{
          'name': seed.name.trim(),
          'category': seed.category.value,
          'supplier': seed.supplier.trim(),
          'unit': seed.unit,
          'photoBase64': seed.photoBase64,
          'notes': seed.notes.trim(),
          'sizeOptions': seed.sizeOptions,
          'lowStockThreshold': seed.lowStockThreshold,
          // Seed default of 5 per size — only applied where the admin
          // hasn't already saved a custom threshold for that size.
          for (final s in seed.sizeOptions)
            if (!(lowMapBySku[skuKey]?.containsKey(s) ?? false))
              'lowStockBySize.$s': seed.lowStockBySize[s] ?? 5,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        final ref = _itemsCol(adminUid).doc();
        current.set(ref, seed.toItem().toCreatePayload());
      }
      touched++;
      inBatch++;
      if (inBatch >= 400) {
        batches.add(current);
        current = _firestore.batch();
        inBatch = 0;
      }
    }
    if (inBatch > 0) batches.add(current);
    for (final b in batches) {
      await b.commit();
    }
    return touched;
  }

  Future<void> adjustStock({
    required String adminUid,
    required String itemId,
    required int delta,
  }) async {
    await _itemsCol(adminUid).doc(itemId).update(<String, dynamic>{
      'stock': FieldValue.increment(delta),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Atomic increment/decrement of a single size bucket. Also updates
  /// the aggregate `stock` field so the card-level summary stays
  /// truthful without re-reading.
  Future<void> adjustStockForSize({
    required String adminUid,
    required String itemId,
    required String size,
    required int delta,
  }) async {
    await _itemsCol(adminUid).doc(itemId).update(<String, dynamic>{
      'stockBySize.$size': FieldValue.increment(delta),
      'stock': FieldValue.increment(delta),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Set the warning threshold for a single size on the given item.
  Future<void> setLowStockForSize({
    required String adminUid,
    required String itemId,
    required String size,
    required int threshold,
  }) async {
    await _itemsCol(adminUid).doc(itemId).update(<String, dynamic>{
      'lowStockBySize.$size': threshold,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ─── Cart ─────────────────────────────────────────────────────────────

  Stream<List<CartLine>> watchCart({required String adminUid}) {
    return _cartCol(adminUid).snapshots().map(
      (snap) {
        final list = snap.docs.map(CartLine.fromDoc).toList()
          ..sort((a, b) {
            final ad = a.createdAt;
            final bd = b.createdAt;
            if (ad == null && bd == null) return 0;
            if (ad == null) return 1;
            if (bd == null) return -1;
            return bd.compareTo(ad);
          });
        return list;
      },
    );
  }

  Future<void> addToCart({
    required String adminUid,
    required CartLine line,
  }) async {
    await _cartCol(adminUid).add(line.toPayload());
  }

  Future<void> updateCartQuantity({
    required String adminUid,
    required String lineId,
    required int quantity,
  }) async {
    await _cartCol(adminUid).doc(lineId).update(<String, dynamic>{
      'quantity': quantity,
    });
  }

  Future<void> removeFromCart({
    required String adminUid,
    required String lineId,
  }) async {
    await _cartCol(adminUid).doc(lineId).delete();
  }

  Future<void> clearCart({required String adminUid}) async {
    final snap = await _cartCol(adminUid).get();
    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // ─── Goods receipts (Eingangskontrolle) ───────────────────────────────

  Stream<List<GoodsReceipt>> watchReceipts({required String adminUid}) {
    return _receiptsCol(adminUid).snapshots().map(
      (snap) {
        final list = snap.docs.map(GoodsReceipt.fromDoc).toList()
          ..sort((a, b) {
            final ad = a.createdAt;
            final bd = b.createdAt;
            if (ad == null && bd == null) return 0;
            if (ad == null) return 1;
            if (bd == null) return -1;
            return bd.compareTo(ad);
          });
        return list;
      },
    );
  }

  /// Creates a goods receipt from the current cart. Each cart line becomes
  /// an expected line on the receipt. The cart is cleared in the same
  /// batch so the UI stays consistent.
  Future<DocumentReference<Map<String, dynamic>>> createReceiptFromCart({
    required String adminUid,
    required String supplier,
    required String reference,
    required String notes,
    required List<CartLine> cart,
  }) async {
    final ref = _receiptsCol(adminUid).doc();
    final batch = _firestore.batch();
    batch.set(ref, <String, dynamic>{
      'supplier': supplier.trim(),
      'reference': reference.trim(),
      'status': GoodsReceiptStatus.pending.value,
      'lines': cart
          .map(
            (l) => <String, dynamic>{
              'itemId': l.itemId,
              'name': l.name,
              'size': l.size,
              'unit': l.unit,
              'expectedQty': l.quantity,
              'receivedQty': l.quantity,
              'ok': true,
              'note': l.note,
            },
          )
          .toList(),
      'notes': notes.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'completedAt': null,
    });
    final cartSnap = await _cartCol(adminUid).get();
    for (final doc in cartSnap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    return ref;
  }

  /// Finalizes a goods receipt. Adjusts the stock for every line where
  /// `receivedQty > 0`, then sets the receipt status. Runs atomically.
  Future<void> finalizeReceipt({
    required String adminUid,
    required GoodsReceipt receipt,
    required GoodsReceiptStatus status,
    String? notes,
  }) async {
    final batch = _firestore.batch();
    final receiptRef = _receiptsCol(adminUid).doc(receipt.id);
    batch.update(receiptRef, <String, dynamic>{
      'status': status.value,
      'lines': receipt.lines.map((l) => l.toMap()).toList(),
      if (notes != null) 'notes': notes.trim(),
      'completedAt': FieldValue.serverTimestamp(),
    });
    if (status == GoodsReceiptStatus.accepted ||
        status == GoodsReceiptStatus.inReview) {
      for (final line in receipt.lines) {
        if (line.receivedQty <= 0) continue;
        if (line.itemId.isEmpty) continue;
        batch.update(_itemsCol(adminUid).doc(line.itemId), <String, dynamic>{
          'stock': FieldValue.increment(line.receivedQty),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }
    await batch.commit();
  }

  Future<void> deleteReceipt({
    required String adminUid,
    required String receiptId,
  }) async {
    await _receiptsCol(adminUid).doc(receiptId).delete();
  }
}
