import 'package:cloud_firestore/cloud_firestore.dart';

/// Channel an applicant came through. Local/EU applicants don't need
/// a work-visa workflow; the visa branch collects extra documents the
/// admin needs to file the Arbeitsvisum request.
enum RecruitingChannel {
  local('local'),
  visa('visa');

  const RecruitingChannel(this.value);
  final String value;

  static RecruitingChannel fromValue(dynamic v) {
    final s = (v ?? '').toString().trim().toLowerCase();
    return s == 'visa' ? RecruitingChannel.visa : RecruitingChannel.local;
  }
}

/// Status of a submitted application as seen by the admin. Two
/// pipelines share the same enum:
///
///   • Local / EU:  newApp → contacted → scheduled → hired (or rejected)
///   • Non-EU:      newApp → zavRequest → preApproval → contractEzb
///                          → hired (or rejected)
///
/// The admin selector in [admin_recruiting_panel.dart] only surfaces
/// the statuses relevant to the application's channel.
enum RecruitingStatus {
  newApp('new'),
  contacted('contacted'),
  scheduled('scheduled'),
  zavRequest('zav_request'),
  preApproval('pre_approval'),
  contractEzb('contract_ezb'),
  hired('hired'),
  rejected('rejected');

  const RecruitingStatus(this.value);
  final String value;

  static RecruitingStatus fromValue(dynamic v) {
    final s = (v ?? '').toString().trim().toLowerCase();
    switch (s) {
      case 'contacted':
        return RecruitingStatus.contacted;
      case 'scheduled':
        return RecruitingStatus.scheduled;
      case 'zav_request':
        return RecruitingStatus.zavRequest;
      case 'pre_approval':
        return RecruitingStatus.preApproval;
      case 'contract_ezb':
        return RecruitingStatus.contractEzb;
      case 'hired':
        return RecruitingStatus.hired;
      case 'rejected':
        return RecruitingStatus.rejected;
      case 'new':
      default:
        return RecruitingStatus.newApp;
    }
  }

  /// Pipeline ordering used by the admin panel's chip strip.
  static List<RecruitingStatus> pipelineFor(RecruitingChannel c) {
    if (c == RecruitingChannel.visa) {
      return const <RecruitingStatus>[
        RecruitingStatus.newApp,
        RecruitingStatus.zavRequest,
        RecruitingStatus.preApproval,
        RecruitingStatus.contractEzb,
        RecruitingStatus.hired,
        RecruitingStatus.rejected,
      ];
    }
    return const <RecruitingStatus>[
      RecruitingStatus.newApp,
      RecruitingStatus.contacted,
      RecruitingStatus.scheduled,
      RecruitingStatus.hired,
      RecruitingStatus.rejected,
    ];
  }

  /// Short user-facing label.
  String get label {
    switch (this) {
      case RecruitingStatus.newApp:
        return 'Neu';
      case RecruitingStatus.contacted:
        return 'Contacted';
      case RecruitingStatus.scheduled:
        return 'Scheduled';
      case RecruitingStatus.zavRequest:
        return 'ZAV Anfrage';
      case RecruitingStatus.preApproval:
        return 'Vorabzustimmung';
      case RecruitingStatus.contractEzb:
        return 'Vertrag/EZB';
      case RecruitingStatus.hired:
        return 'Eingestellt';
      case RecruitingStatus.rejected:
        return 'Rejected';
    }
  }
}

/// One uploaded document attached to a recruiting application. The
/// canonical storage is Firebase Storage — only the [downloadUrl] +
/// [storagePath] live in Firestore so we stay under the 1 MB doc
/// ceiling. [fileBase64] is kept for legacy applications that were
/// submitted before the Storage migration.
class RecruitingDocument {
  const RecruitingDocument({
    required this.label,
    required this.filename,
    required this.mimeType,
    this.downloadUrl = '',
    this.storagePath = '',
    this.fileBase64 = '',
    this.sizeBytes = 0,
  });

  /// Short identifier ('passport', 'license_front', 'license_back').
  final String label;
  final String filename;
  final String mimeType;
  final String downloadUrl;
  final String storagePath;
  final String fileBase64; // legacy only
  final int sizeBytes;

  bool get hasUrl => downloadUrl.trim().isNotEmpty;
  bool get hasBase64 => fileBase64.trim().isNotEmpty;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'label': label,
        'filename': filename,
        'mimeType': mimeType,
        'downloadUrl': downloadUrl,
        'storagePath': storagePath,
        if (fileBase64.isNotEmpty) 'fileBase64': fileBase64,
        'sizeBytes': sizeBytes,
      };

  factory RecruitingDocument.fromMap(Map<String, dynamic> m) =>
      RecruitingDocument(
        label: (m['label'] ?? '').toString(),
        filename: (m['filename'] ?? '').toString(),
        mimeType: (m['mimeType'] ?? '').toString(),
        downloadUrl: (m['downloadUrl'] ?? '').toString(),
        storagePath: (m['storagePath'] ?? '').toString(),
        fileBase64: (m['fileBase64'] ?? '').toString(),
        sizeBytes: (m['sizeBytes'] is int)
            ? m['sizeBytes'] as int
            : (m['sizeBytes'] is num)
                ? (m['sizeBytes'] as num).toInt()
                : 0,
      );
}

/// All fields collected by the public Recruiting form. Mirrors the
/// Albanian/German Google-Form 1:1 plus the document uploads we ask
/// for at the end (passport / national ID + driver license front +
/// driver license back).
class RecruitingApplication {
  const RecruitingApplication({
    required this.id,
    required this.adminUid,
    required this.channel,
    required this.status,
    required this.submittedAt,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.birthPlace,
    required this.nationality,
    required this.street,
    required this.postalCode,
    required this.city,
    required this.livingHereSince,
    required this.shirtSize,
    required this.shoeSize,
    required this.phoneWhatsApp,
    required this.email,
    required this.truckLicense,
    required this.documents,
    this.adminNote = '',
    this.customAnswers = const <String, dynamic>{},
  });

  final String id;

  /// DSP / admin namespace this application belongs to. Set from the
  /// URL parameter on the public form so submissions land in the right
  /// admin's inbox.
  final String adminUid;
  final RecruitingChannel channel;
  final RecruitingStatus status;
  final DateTime submittedAt;

  // ── Personal info (Google Form Q1–9) ────────────────────────────
  final String firstName;
  final String lastName;
  final DateTime? birthDate;
  final String birthPlace;
  final String nationality;
  final String street;
  final String postalCode;
  final String city;
  final DateTime? livingHereSince;

  // ── Sizing (Q10–11) ─────────────────────────────────────────────
  final String shirtSize;
  final String shoeSize;

  // ── Contact (Q12–13) ────────────────────────────────────────────
  final String phoneWhatsApp;
  final String email;

  // ── Truck license (Q14) ─────────────────────────────────────────
  /// Free-form label — one of the multi-choice answers from the form.
  final String truckLicense;

  // ── Uploaded documents ──────────────────────────────────────────
  final List<RecruitingDocument> documents;

  // ── Admin annotations ───────────────────────────────────────────
  final String adminNote;

  /// Free-form answers to custom DSP-defined questions. Keyed by the
  /// custom-field ID; values are strings except for date (ISO) and
  /// yes/no (bool).
  final Map<String, dynamic> customAnswers;

  Map<String, dynamic> toCreatePayload() => <String, dynamic>{
        'adminUid': adminUid,
        'channel': channel.value,
        'status': status.value,
        'submittedAt': FieldValue.serverTimestamp(),
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'birthDate':
            birthDate != null ? Timestamp.fromDate(birthDate!) : null,
        'birthPlace': birthPlace.trim(),
        'nationality': nationality.trim(),
        'street': street.trim(),
        'postalCode': postalCode.trim(),
        'city': city.trim(),
        'livingHereSince': livingHereSince != null
            ? Timestamp.fromDate(livingHereSince!)
            : null,
        'shirtSize': shirtSize.trim(),
        'shoeSize': shoeSize.trim(),
        'phoneWhatsApp': phoneWhatsApp.trim(),
        'email': email.trim(),
        'truckLicense': truckLicense.trim(),
        'documents': documents.map((d) => d.toMap()).toList(),
        'adminNote': adminNote.trim(),
        'customAnswers': customAnswers,
      };

  factory RecruitingApplication.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? const <String, dynamic>{};
    return RecruitingApplication(
      id: doc.id,
      adminUid: (d['adminUid'] ?? '').toString(),
      channel: RecruitingChannel.fromValue(d['channel']),
      status: RecruitingStatus.fromValue(d['status']),
      submittedAt:
          (d['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      firstName: (d['firstName'] ?? '').toString(),
      lastName: (d['lastName'] ?? '').toString(),
      birthDate: (d['birthDate'] as Timestamp?)?.toDate(),
      birthPlace: (d['birthPlace'] ?? '').toString(),
      nationality: (d['nationality'] ?? '').toString(),
      street: (d['street'] ?? '').toString(),
      postalCode: (d['postalCode'] ?? '').toString(),
      city: (d['city'] ?? '').toString(),
      livingHereSince: (d['livingHereSince'] as Timestamp?)?.toDate(),
      shirtSize: (d['shirtSize'] ?? '').toString(),
      shoeSize: (d['shoeSize'] ?? '').toString(),
      phoneWhatsApp: (d['phoneWhatsApp'] ?? '').toString(),
      email: (d['email'] ?? '').toString(),
      truckLicense: (d['truckLicense'] ?? '').toString(),
      documents: (d['documents'] is List)
          ? (d['documents'] as List)
              .whereType<Map>()
              .map((e) => RecruitingDocument.fromMap(
                  Map<String, dynamic>.from(e)))
              .toList()
          : <RecruitingDocument>[],
      adminNote: (d['adminNote'] ?? '').toString(),
      customAnswers: (d['customAnswers'] is Map)
          ? Map<String, dynamic>.from(d['customAnswers'] as Map)
          : const <String, dynamic>{},
    );
  }

  String get displayName {
    final fn = firstName.trim();
    final ln = lastName.trim();
    if (fn.isEmpty && ln.isEmpty) return '— no name —';
    return '$fn $ln'.trim();
  }
}
