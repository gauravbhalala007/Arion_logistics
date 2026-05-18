import 'package:cloud_firestore/cloud_firestore.dart';

/// Field types the form builder supports. Kept intentionally small —
/// the public form has to render every type, so we resist exotic
/// answer surfaces.
enum RecruitingFieldType {
  shortText('short_text'),
  longText('long_text'),
  dropdown('dropdown'),
  yesNo('yes_no'),
  date('date');

  const RecruitingFieldType(this.value);
  final String value;

  static RecruitingFieldType fromValue(dynamic v) {
    final s = (v ?? '').toString().trim().toLowerCase();
    switch (s) {
      case 'long_text':
        return RecruitingFieldType.longText;
      case 'dropdown':
        return RecruitingFieldType.dropdown;
      case 'yes_no':
        return RecruitingFieldType.yesNo;
      case 'date':
        return RecruitingFieldType.date;
      case 'short_text':
      default:
        return RecruitingFieldType.shortText;
    }
  }

  String get label {
    switch (this) {
      case RecruitingFieldType.shortText:
        return 'Short text';
      case RecruitingFieldType.longText:
        return 'Long text';
      case RecruitingFieldType.dropdown:
        return 'Dropdown';
      case RecruitingFieldType.yesNo:
        return 'Yes / No';
      case RecruitingFieldType.date:
        return 'Date';
    }
  }
}

/// A single custom question the DSP adds to their form.
class RecruitingCustomField {
  const RecruitingCustomField({
    required this.id,
    required this.label,
    required this.type,
    this.options = const <String>[],
    this.required = false,
  });

  /// Stable client-generated ID (used as the answer key on submission).
  final String id;
  final String label;
  final RecruitingFieldType type;
  final List<String> options;
  final bool required;

  RecruitingCustomField copyWith({
    String? label,
    RecruitingFieldType? type,
    List<String>? options,
    bool? required,
  }) =>
      RecruitingCustomField(
        id: id,
        label: label ?? this.label,
        type: type ?? this.type,
        options: options ?? this.options,
        required: required ?? this.required,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'label': label,
        'type': type.value,
        'options': options,
        'required': required,
      };

  factory RecruitingCustomField.fromMap(Map<String, dynamic> m) =>
      RecruitingCustomField(
        id: (m['id'] ?? '').toString(),
        label: (m['label'] ?? '').toString(),
        type: RecruitingFieldType.fromValue(m['type']),
        options: (m['options'] is List)
            ? (m['options'] as List).map((e) => e.toString()).toList()
            : const <String>[],
        required: m['required'] == true,
      );
}

/// The set of custom questions the DSP added for a given channel.
/// Stored per admin under `users/{adminUid}/settings/recruiting_form_{channel}`.
class RecruitingFormConfig {
  const RecruitingFormConfig({
    required this.fields,
    required this.updatedAt,
  });

  final List<RecruitingCustomField> fields;
  final DateTime? updatedAt;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'fields': fields.map((f) => f.toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  factory RecruitingFormConfig.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? const <String, dynamic>{};
    final raw = d['fields'];
    return RecruitingFormConfig(
      fields: raw is List
          ? raw
              .whereType<Map>()
              .map((m) => RecruitingCustomField.fromMap(
                  Map<String, dynamic>.from(m)))
              .toList()
          : const <RecruitingCustomField>[],
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  static RecruitingFormConfig empty() =>
      const RecruitingFormConfig(fields: <RecruitingCustomField>[], updatedAt: null);
}
