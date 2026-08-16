import 'package:cloud_firestore/cloud_firestore.dart';

/// One time block inside a driver's daily shift assignment.
/// Drivers can have multiple blocks per day (e.g. morning + evening).
class ShiftBlock {
  const ShiftBlock({
    required this.serviceType,
    required this.startTime,
    required this.duration,
  });

  /// Free-form service label, e.g. "Standard Parcel - LEV".
  final String serviceType;

  /// Start time as printed in the source sheet, e.g. "11:20am".
  final String startTime;

  /// Duration label as printed, e.g. "9 Std." or "8 Std. 45 m".
  final String duration;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'serviceType': serviceType.trim(),
        'startTime': startTime.trim(),
        'duration': duration.trim(),
      };

  factory ShiftBlock.fromMap(Map<String, dynamic> m) => ShiftBlock(
        serviceType: (m['serviceType'] ?? '').toString(),
        startTime: (m['startTime'] ?? '').toString(),
        duration: (m['duration'] ?? '').toString(),
      );
}

enum ShiftKind {
  regular('REGULAR'),
  rescue('RESCUE'),
  extra('EXTRA');

  const ShiftKind(this.value);
  final String value;

  static ShiftKind fromValue(dynamic v) {
    final s = (v ?? '').toString().trim().toUpperCase();
    switch (s) {
      case 'RESCUE':
        return ShiftKind.rescue;
      case 'EXTRA':
        return ShiftKind.extra;
      case 'REGULAR':
      default:
        return ShiftKind.regular;
    }
  }
}

/// One audit log entry for a shift plan row. Every meaningful change
/// gets appended to [ShiftPlanEntry.auditTrail] after a confirm
/// dialog — providing a tamper-evident record for invoice control.
class AuditEvent {
  const AuditEvent({
    required this.userName,
    required this.timestamp,
    required this.action,
  });

  final String userName;
  final DateTime timestamp;
  final String action;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'userName': userName.trim(),
        'timestamp': Timestamp.fromDate(timestamp),
        'action': action.trim(),
      };

  factory AuditEvent.fromMap(Map<String, dynamic> m) => AuditEvent(
        userName: (m['userName'] ?? '').toString(),
        timestamp: (m['timestamp'] is Timestamp)
            ? (m['timestamp'] as Timestamp).toDate()
            : DateTime.now(),
        action: (m['action'] ?? '').toString(),
      );

  /// `Name hat am 23.05.26 um 12:30 [action]` — user-facing format.
  String describe() {
    String pad(int n) => n.toString().padLeft(2, '0');
    final yy = timestamp.year.toString().substring(2);
    final stamp = '${pad(timestamp.day)}.${pad(timestamp.month)}.$yy'
        ' um ${pad(timestamp.hour)}:${pad(timestamp.minute)}';
    final who = userName.isEmpty ? 'Unbekannt' : userName;
    return '$who hat am $stamp $action';
  }
}

/// One driver's full assignment for the selected day.
class ShiftPlanEntry {
  const ShiftPlanEntry({
    required this.transporterId,
    required this.driverName,
    required this.blocks,
    this.kind = ShiftKind.regular,
    this.meetingTime = '',
    this.personalNotes = '',
    this.menteeTransporterId = '',
    this.menteeName = '',
    this.lateCancel = false,
    this.lateCancelReason = '',
    this.auditTrail = const <AuditEvent>[],
  });

  bool get hasMentee => menteeTransporterId.trim().isNotEmpty;

  /// Driver's transporter ID. For manually-added rescue / extra rows
  /// the TID can stay empty until a driver is dropped onto the slot.
  final String transporterId;
  final String driverName;
  final List<ShiftBlock> blocks;

  /// Internal admin tag — REGULAR, RESCUE or EXTRA. The driver-facing
  /// view never exposes this; rescue and extra entries appear to the
  /// driver as a regular shift with a meeting time.
  final ShiftKind kind;

  /// Per-driver override of the daily meeting time. Empty = inherit
  /// the global `meetingTime` from [ShiftPlanDoc].
  final String meetingTime;

  /// Per-driver personal notes — visible only to THIS driver. Used
  /// for things like "Badge bei Security abholen 10:10", "Schlüssel
  /// nicht vergessen". Set via the click-to-edit driver dialog.
  final String personalNotes;

  /// Optional second driver riding along with the primary driver for
  /// training. The mentee sees the same shift entry as the mentor
  /// (driver-app filter matches both transporterIds).
  final String menteeTransporterId;
  final String menteeName;

  /// Late-cancel flag — true when the tour was confirmed in last
  /// night's plan but is no longer being driven today. Amazon pays
  /// for these; the invoice-control page later compares this against
  /// the billed amount.
  final bool lateCancel;

  /// Optional reason note for the late cancel, e.g. "Krankmeldung 06:30".
  final String lateCancelReason;

  /// Append-only audit trail — every meaningful change appends one
  /// entry, written after a confirm dialog.
  final List<AuditEvent> auditTrail;

  ShiftPlanEntry copyWith({
    String? transporterId,
    String? driverName,
    List<ShiftBlock>? blocks,
    ShiftKind? kind,
    String? meetingTime,
    String? personalNotes,
    String? menteeTransporterId,
    String? menteeName,
    bool clearMentee = false,
    bool? lateCancel,
    String? lateCancelReason,
    List<AuditEvent>? auditTrail,
    AuditEvent? appendAudit,
  }) =>
      ShiftPlanEntry(
        transporterId: transporterId ?? this.transporterId,
        driverName: driverName ?? this.driverName,
        blocks: blocks ?? this.blocks,
        kind: kind ?? this.kind,
        meetingTime: meetingTime ?? this.meetingTime,
        personalNotes: personalNotes ?? this.personalNotes,
        menteeTransporterId: clearMentee
            ? ''
            : (menteeTransporterId ?? this.menteeTransporterId),
        menteeName:
            clearMentee ? '' : (menteeName ?? this.menteeName),
        lateCancel: lateCancel ?? this.lateCancel,
        lateCancelReason: lateCancelReason ?? this.lateCancelReason,
        auditTrail: appendAudit != null
            ? <AuditEvent>[...this.auditTrail, appendAudit]
            : (auditTrail ?? this.auditTrail),
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'transporterId': transporterId.trim(),
        'driverName': driverName.trim(),
        // `kind` is admin-only metadata — never surface to the driver
        // app. Firestore rules can be tightened later to enforce it.
        'kind': kind.value,
        'meetingTime': meetingTime.trim(),
        'personalNotes': personalNotes.trim(),
        'menteeTransporterId': menteeTransporterId.trim(),
        'menteeName': menteeName.trim(),
        'blocks': blocks.map((b) => b.toMap()).toList(),
        'lateCancel': lateCancel,
        'lateCancelReason': lateCancelReason.trim(),
        'auditTrail': auditTrail.map((a) => a.toMap()).toList(),
      };

  factory ShiftPlanEntry.fromMap(Map<String, dynamic> m) => ShiftPlanEntry(
        transporterId: (m['transporterId'] ?? '').toString(),
        driverName: (m['driverName'] ?? '').toString(),
        kind: ShiftKind.fromValue(m['kind']),
        meetingTime: (m['meetingTime'] ?? '').toString(),
        personalNotes: (m['personalNotes'] ?? '').toString(),
        menteeTransporterId:
            (m['menteeTransporterId'] ?? '').toString(),
        menteeName: (m['menteeName'] ?? '').toString(),
        blocks: (m['blocks'] is List)
            ? (m['blocks'] as List)
                .whereType<Map>()
                .map((e) =>
                    ShiftBlock.fromMap(Map<String, dynamic>.from(e)))
                .toList()
            : <ShiftBlock>[],
        lateCancel: m['lateCancel'] == true,
        lateCancelReason: (m['lateCancelReason'] ?? '').toString(),
        auditTrail: (m['auditTrail'] is List)
            ? (m['auditTrail'] as List)
                .whereType<Map>()
                .map((e) =>
                    AuditEvent.fromMap(Map<String, dynamic>.from(e)))
                .toList()
            : <AuditEvent>[],
      );
}

/// All employees the source Excel knows about — used to power the
/// "available pool" sidebar even when they have no shift that day.
class ShiftRoster {
  const ShiftRoster({
    required this.transporterId,
    required this.driverName,
  });

  final String transporterId;
  final String driverName;
}

/// Parser result — the whole imported Excel grouped by day.
class ParsedShiftPlan {
  const ParsedShiftPlan({
    required this.assignmentsByDate,
    required this.roster,
    required this.station,
    required this.company,
  });

  /// Day key `'YYYY-MM-DD'` → driver assignments.
  final Map<String, List<ShiftPlanEntry>> assignmentsByDate;
  final List<ShiftRoster> roster;
  final String station;
  final String company;

  List<String> get availableDateKeys =>
      assignmentsByDate.keys.toList()..sort();
}

/// One day-level note with a [title] (used as a chip preview in the
/// right-rail and as the headline on the driver app) and a free-form
/// [body]. A plan can carry multiple notes — admins assemble them
/// from saved templates or write inline.
class ShiftPlanNote {
  const ShiftPlanNote({required this.title, required this.body});

  final String title;
  final String body;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'title': title.trim(),
        'body': body.trim(),
      };

  factory ShiftPlanNote.fromMap(Map<String, dynamic> m) => ShiftPlanNote(
        title: (m['title'] ?? '').toString(),
        body: (m['body'] ?? '').toString(),
      );

  ShiftPlanNote copyWith({String? title, String? body}) => ShiftPlanNote(
        title: title ?? this.title,
        body: body ?? this.body,
      );
}

/// Top-level shape persisted to Firestore at
/// `users/{adminUid}/shift_plans/{YYYY-MM-DD}`.
class ShiftPlanDoc {
  const ShiftPlanDoc({
    required this.dateKey,
    required this.entries,
    required this.station,
    required this.company,
    required this.dispatchers,
    required this.meetingTime,
    required this.publishedAt,
    this.parkingOffsetMinutes = 15,
    this.dispatcherShifts = const <String, List<String>>{},
    this.notes = const <ShiftPlanNote>[],
  });

  final String dateKey;
  final List<ShiftPlanEntry> entries;
  final String station;
  final String company;
  final List<String> dispatchers;

  /// Multiple per-day notes shown to every driver. Each note has its
  /// own title + body; the right-rail UI renders one chip per note.
  final List<ShiftPlanNote> notes;

  /// Per-entry override of the parking time as an absolute clock value
  /// (e.g. "10:45"). When empty, the driver's parking time is computed
  /// as `dispatch - parkingOffsetMinutes` from this doc.
  final String meetingTime;
  final DateTime? publishedAt;

  /// Default offset in minutes between parking-arrival and dispatch
  /// start. Standard is 15 min, set globally by the admin in the
  /// right-column control. Each driver row shows
  /// `Park HH:mm` = first dispatch - this offset.
  final int parkingOffsetMinutes;

  /// Per-dispatcher shift range — `{'Jana': ['06:00', '14:30']}`. The
  /// shift range comes from the Waveplan-style dispatcher bar in the
  /// shift plan and is mirrored back to Waveplan so both views stay in
  /// sync.
  final Map<String, List<String>> dispatcherShifts;

  Map<String, dynamic> toCreatePayload() => <String, dynamic>{
        'date': dateKey,
        'station': station.trim(),
        'company': company.trim(),
        'dispatchers': dispatchers.map((s) => s.trim()).toList(),
        'notes': notes.map((n) => n.toMap()).toList(),
        'meetingTime': meetingTime.trim(),
        'parkingOffsetMinutes': parkingOffsetMinutes,
        'dispatcherShifts': dispatcherShifts.map(
          (k, v) => MapEntry(k, v.map((s) => s.trim()).toList()),
        ),
        'entries': entries.map((e) => e.toMap()).toList(),
        'publishedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  /// Payload for an INTERNAL save (not published to drivers). Written to
  /// `users/{adminUid}/shift_plan_drafts/{dateKey}` — a collection drivers
  /// have no read rule for. Used to back-fill past weeks so they show up in
  /// Payment Check without ever notifying or exposing data to drivers.
  Map<String, dynamic> toDraftPayload() => <String, dynamic>{
        'date': dateKey,
        'station': station.trim(),
        'company': company.trim(),
        'dispatchers': dispatchers.map((s) => s.trim()).toList(),
        'notes': notes.map((n) => n.toMap()).toList(),
        'meetingTime': meetingTime.trim(),
        'parkingOffsetMinutes': parkingOffsetMinutes,
        'dispatcherShifts': dispatcherShifts.map(
          (k, v) => MapEntry(k, v.map((s) => s.trim()).toList()),
        ),
        'entries': entries.map((e) => e.toMap()).toList(),
        'status': 'draft',
        'publishedAt': null,
        'savedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  factory ShiftPlanDoc.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? const <String, dynamic>{};
    final raw = d['entries'];
    final disp = d['dispatchers'];
    final rawShifts = d['dispatcherShifts'];
    final parsedShifts = <String, List<String>>{};
    if (rawShifts is Map) {
      rawShifts.forEach((k, v) {
        if (v is List && v.length >= 2) {
          parsedShifts[k.toString()] =
              v.map((e) => e.toString()).toList();
        }
      });
    }
    return ShiftPlanDoc(
      dateKey: (d['date'] ?? doc.id).toString(),
      station: (d['station'] ?? '').toString(),
      company: (d['company'] ?? '').toString(),
      dispatchers: disp is List
          ? disp.map((e) => e.toString()).toList()
          : const <String>[],
      notes: _parseNotes(d['notes'], d['notesTitle']),
      meetingTime: (d['meetingTime'] ?? '').toString(),
      parkingOffsetMinutes: (d['parkingOffsetMinutes'] is int)
          ? d['parkingOffsetMinutes'] as int
          : (d['parkingOffsetMinutes'] is num)
              ? (d['parkingOffsetMinutes'] as num).toInt()
              : 15,
      dispatcherShifts: parsedShifts,
      entries: raw is List
          ? raw
              .whereType<Map>()
              .map(
                (e) =>
                    ShiftPlanEntry.fromMap(Map<String, dynamic>.from(e)),
              )
              .toList()
          : <ShiftPlanEntry>[],
      publishedAt: (d['publishedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Reads notes from the persisted doc. Accepts both shapes for
  /// backward compatibility: the new `[{title, body}, …]` array, and
  /// the legacy `notes: String` + `notesTitle: String` pair that older
  /// plans were written with.
  static List<ShiftPlanNote> _parseNotes(dynamic raw, dynamic legacyTitle) {
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((m) => ShiftPlanNote.fromMap(Map<String, dynamic>.from(m)))
          .where((n) => n.title.isNotEmpty || n.body.isNotEmpty)
          .toList();
    }
    final legacyBody = raw is String ? raw.trim() : '';
    final lt = legacyTitle is String ? legacyTitle.trim() : '';
    if (legacyBody.isEmpty && lt.isEmpty) return const <ShiftPlanNote>[];
    return <ShiftPlanNote>[
      ShiftPlanNote(title: lt, body: legacyBody),
    ];
  }
}
