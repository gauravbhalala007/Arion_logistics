import 'package:cloud_firestore/cloud_firestore.dart';

class Supplier {
  const Supplier({
    required this.id,
    required this.name,
    required this.contact,
    required this.notes,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String contact;
  final String notes;
  final DateTime? createdAt;

  factory Supplier.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const <String, dynamic>{};
    return Supplier(
      id: doc.id,
      name: (d['name'] ?? '').toString(),
      contact: (d['contact'] ?? '').toString(),
      notes: (d['notes'] ?? '').toString(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toCreatePayload() => <String, dynamic>{
        'name': name.trim(),
        'contact': contact.trim(),
        'notes': notes.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      };
}
