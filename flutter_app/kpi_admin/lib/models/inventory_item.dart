import 'package:cloud_firestore/cloud_firestore.dart';

enum InventoryCategory {
  clothing('CLOTHING', 'Kleidung'),
  workshop('WORKSHOP', 'Werkstatt'),
  other('OTHER', 'Sonstiges');

  const InventoryCategory(this.value, this.label);

  final String value;
  final String label;

  static InventoryCategory fromFirestore(dynamic value) {
    final normalized = (value ?? '').toString().trim().toUpperCase();
    switch (normalized) {
      case 'CLOTHING':
        return InventoryCategory.clothing;
      case 'WORKSHOP':
        return InventoryCategory.workshop;
      case 'OTHER':
      default:
        return InventoryCategory.other;
    }
  }
}

class InventoryItem {
  const InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.sku,
    required this.unit,
    required this.stock,
    required this.lowStockThreshold,
    required this.sizeOptions,
    required this.stockBySize,
    required this.lowStockBySize,
    required this.supplier,
    required this.notes,
    required this.photoBase64,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final InventoryCategory category;
  final String sku;
  final String unit;
  /// Aggregate count across all sizes (sum of [stockBySize] when sizes
  /// are tracked, otherwise the only stock counter).
  final int stock;
  final int lowStockThreshold;
  final List<String> sizeOptions;
  /// Per-size stock breakdown. Empty when the item has no sizes.
  final Map<String, int> stockBySize;
  /// Per-size low-stock threshold. Items dip into the warning state
  /// once `stockBySize[size] <= lowStockBySize[size]`. Falls back to
  /// [lowStockThreshold] for sizes that have no explicit entry.
  final Map<String, int> lowStockBySize;
  final String supplier;
  final String notes;
  final String photoBase64;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isLowStock =>
      lowStockThreshold > 0 && stock <= lowStockThreshold;

  bool get isOutOfStock => stock <= 0;

  factory InventoryItem.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    final sizesRaw = data['sizeOptions'];
    final sizes = sizesRaw is List
        ? sizesRaw.map((e) => e.toString()).toList()
        : <String>[];
    final bySizeRaw = data['stockBySize'];
    final bySize = <String, int>{};
    if (bySizeRaw is Map) {
      for (final entry in bySizeRaw.entries) {
        bySize[entry.key.toString()] = _intOrZero(entry.value);
      }
    }
    final lowBySizeRaw = data['lowStockBySize'];
    final lowBySize = <String, int>{};
    if (lowBySizeRaw is Map) {
      for (final entry in lowBySizeRaw.entries) {
        lowBySize[entry.key.toString()] = _intOrZero(entry.value);
      }
    }
    return InventoryItem(
      id: doc.id,
      name: (data['name'] ?? '').toString(),
      category: InventoryCategory.fromFirestore(data['category']),
      sku: (data['sku'] ?? '').toString(),
      unit: (data['unit'] ?? 'Stück').toString(),
      stock: _intOrZero(data['stock']),
      lowStockThreshold: _intOrZero(data['lowStockThreshold']),
      sizeOptions: sizes,
      stockBySize: bySize,
      lowStockBySize: lowBySize,
      supplier: (data['supplier'] ?? '').toString(),
      notes: (data['notes'] ?? '').toString(),
      photoBase64: (data['photoBase64'] ?? '').toString(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toCreatePayload() {
    return <String, dynamic>{
      'name': name.trim(),
      'category': category.value,
      'sku': sku.trim(),
      'unit': unit.trim().isEmpty ? 'Stück' : unit.trim(),
      'stock': stock,
      'lowStockThreshold': lowStockThreshold,
      'sizeOptions': sizeOptions,
      'stockBySize': stockBySize,
      'lowStockBySize': lowStockBySize,
      'supplier': supplier.trim(),
      'notes': notes.trim(),
      'photoBase64': photoBase64,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdatePayload() {
    return <String, dynamic>{
      'name': name.trim(),
      'category': category.value,
      'sku': sku.trim(),
      'unit': unit.trim().isEmpty ? 'Stück' : unit.trim(),
      'stock': stock,
      'lowStockThreshold': lowStockThreshold,
      'sizeOptions': sizeOptions,
      'stockBySize': stockBySize,
      'lowStockBySize': lowStockBySize,
      'supplier': supplier.trim(),
      'notes': notes.trim(),
      'photoBase64': photoBase64,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

class CartLine {
  const CartLine({
    required this.id,
    required this.itemId,
    required this.name,
    required this.category,
    required this.quantity,
    required this.size,
    required this.unit,
    required this.note,
    required this.createdAt,
  });

  final String id;
  final String itemId;
  final String name;
  final InventoryCategory category;
  final int quantity;
  final String size;
  final String unit;
  final String note;
  final DateTime? createdAt;

  factory CartLine.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return CartLine(
      id: doc.id,
      itemId: (data['itemId'] ?? '').toString(),
      name: (data['name'] ?? '').toString(),
      category: InventoryCategory.fromFirestore(data['category']),
      quantity: _intOrZero(data['quantity']),
      size: (data['size'] ?? '').toString(),
      unit: (data['unit'] ?? 'Stück').toString(),
      note: (data['note'] ?? '').toString(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toPayload() {
    return <String, dynamic>{
      'itemId': itemId,
      'name': name,
      'category': category.value,
      'quantity': quantity,
      'size': size,
      'unit': unit,
      'note': note,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

enum GoodsReceiptStatus {
  pending('PENDING', 'Erwartet'),
  inReview('IN_REVIEW', 'In Prüfung'),
  accepted('ACCEPTED', 'Akzeptiert'),
  rejected('REJECTED', 'Beanstandet');

  const GoodsReceiptStatus(this.value, this.label);

  final String value;
  final String label;

  static GoodsReceiptStatus fromFirestore(dynamic value) {
    final normalized = (value ?? '').toString().trim().toUpperCase();
    switch (normalized) {
      case 'IN_REVIEW':
        return GoodsReceiptStatus.inReview;
      case 'ACCEPTED':
        return GoodsReceiptStatus.accepted;
      case 'REJECTED':
        return GoodsReceiptStatus.rejected;
      case 'PENDING':
      default:
        return GoodsReceiptStatus.pending;
    }
  }
}

class GoodsReceiptLine {
  const GoodsReceiptLine({
    required this.itemId,
    required this.name,
    required this.size,
    required this.expectedQty,
    required this.receivedQty,
    required this.unit,
    required this.ok,
    required this.note,
  });

  final String itemId;
  final String name;
  final String size;
  final int expectedQty;
  final int receivedQty;
  final String unit;
  final bool ok;
  final String note;

  factory GoodsReceiptLine.fromMap(Map<String, dynamic> map) {
    return GoodsReceiptLine(
      itemId: (map['itemId'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      size: (map['size'] ?? '').toString(),
      expectedQty: _intOrZero(map['expectedQty']),
      receivedQty: _intOrZero(map['receivedQty']),
      unit: (map['unit'] ?? 'Stück').toString(),
      ok: map['ok'] == true,
      note: (map['note'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'itemId': itemId,
      'name': name,
      'size': size,
      'expectedQty': expectedQty,
      'receivedQty': receivedQty,
      'unit': unit,
      'ok': ok,
      'note': note,
    };
  }

  GoodsReceiptLine copyWith({
    int? receivedQty,
    bool? ok,
    String? note,
  }) {
    return GoodsReceiptLine(
      itemId: itemId,
      name: name,
      size: size,
      expectedQty: expectedQty,
      receivedQty: receivedQty ?? this.receivedQty,
      unit: unit,
      ok: ok ?? this.ok,
      note: note ?? this.note,
    );
  }
}

class GoodsReceipt {
  const GoodsReceipt({
    required this.id,
    required this.supplier,
    required this.reference,
    required this.status,
    required this.lines,
    required this.notes,
    required this.createdAt,
    required this.completedAt,
  });

  final String id;
  final String supplier;
  final String reference;
  final GoodsReceiptStatus status;
  final List<GoodsReceiptLine> lines;
  final String notes;
  final DateTime? createdAt;
  final DateTime? completedAt;

  int get totalExpected =>
      lines.fold(0, (acc, l) => acc + l.expectedQty);
  int get totalReceived =>
      lines.fold(0, (acc, l) => acc + l.receivedQty);

  factory GoodsReceipt.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    final raw = data['lines'];
    final lines = raw is List
        ? raw
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .map(GoodsReceiptLine.fromMap)
            .toList()
        : <GoodsReceiptLine>[];
    return GoodsReceipt(
      id: doc.id,
      supplier: (data['supplier'] ?? '').toString(),
      reference: (data['reference'] ?? '').toString(),
      status: GoodsReceiptStatus.fromFirestore(data['status']),
      lines: lines,
      notes: (data['notes'] ?? '').toString(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }
}

int _intOrZero(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse((value ?? '').toString()) ?? 0;
}
