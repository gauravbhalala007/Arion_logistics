// lib/models/recruiting_agency.dart
//
// A staffing agency ("Personalagentur") that sends candidate data for
// working-visa procedures. Arion has no direct contact with those
// candidates — the agency is the counterpart the team calls once the
// Vorabzustimmung arrives.

/// One saved agency contact. Persisted inside the DSP's recruiting
/// settings doc (see [RecruitingAgencyRepository]) rather than in its
/// own collection, because that doc is the only place the public,
/// login-less agency form is allowed to read from.
class RecruitingAgency {
  const RecruitingAgency({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String phone;
  final String email;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Dedupe key — agencies are matched case-insensitively by email.
  String get dedupeKey => email.trim().toLowerCase();

  RecruitingAgency copyWith({
    String? name,
    String? phone,
    String? email,
    DateTime? updatedAt,
  }) =>
      RecruitingAgency(
        id: id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'name': name.trim(),
        'phone': phone.trim(),
        'email': email.trim(),
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };

  static RecruitingAgency fromMap(Map<String, dynamic> m) {
    DateTime? parse(dynamic v) {
      if (v == null) return null;
      return DateTime.tryParse(v.toString());
    }

    return RecruitingAgency(
      id: (m['id'] ?? '').toString(),
      name: (m['name'] ?? '').toString(),
      phone: (m['phone'] ?? '').toString(),
      email: (m['email'] ?? '').toString(),
      createdAt: parse(m['createdAt']),
      updatedAt: parse(m['updatedAt']),
    );
  }

  /// Label shown in the picker — name plus email so two agencies with
  /// the same name stay distinguishable.
  String get pickerLabel =>
      email.trim().isEmpty ? name.trim() : '${name.trim()} · ${email.trim()}';
}
