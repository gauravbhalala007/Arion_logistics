// lib/services/incident_share_service.dart
//
// Öffentlicher Share-Link je Unfall-/Vorfallbericht (Ticket "INCIDENT
// REPORT"): jeder Fall bekommt einen eigenen, unerratbaren Link, der ohne
// Login geöffnet werden kann.
//
// Re-used infrastructure: die Snapshots landen als `type: 'incident'`
// Payload in `public_plans/{shareId}` (weltweit per get lesbar, kein
// list) — dieselben Firestore-Rules wie für geteilte Wave-/Schichtpläne.
// `users/{uid}/plan_shares/incident_{docId}` hält das Mapping, damit
// erneutes Teilen desselben Falls denselben Link aktualisiert statt
// einen neuen zu erzeugen.

import 'package:intl/intl.dart';

import 'incident_reports.dart';
import 'public_plan_service.dart';

class IncidentShareService {
  IncidentShareService({PublicPlanService? planService})
      : _planService = planService ?? PublicPlanService();

  final PublicPlanService _planService;

  /// Publishes (or refreshes) the public snapshot for one incident report
  /// and returns the share URL. Each report keeps its own stable link.
  Future<String> share({
    required String docId,
    required Map<String, dynamic> data,
  }) {
    return _planService.share(
      key: 'incident_$docId',
      payload: buildIncidentSharePayload(data, caseId: docId),
    );
  }
}

/// Self-contained, bilingual (DE/EN) snapshot of one incident report for
/// the public viewer — no auth, no follow-up reads except the photo /
/// attachment download URLs (token URLs, work without login).
Map<String, dynamic> buildIncidentSharePayload(
  Map<String, dynamic> data, {
  required String caseId,
}) {
  final workAccident = isWorkAccident(data);
  final rows = <Map<String, String>>[];

  void row(String labelDe, String labelEn, String valueDe, [String? valueEn]) {
    final de = valueDe.trim();
    final en = (valueEn ?? valueDe).trim();
    if (de.isEmpty && en.isEmpty) return;
    rows.add({
      'labelDe': labelDe,
      'labelEn': labelEn,
      'valueDe': de,
      'valueEn': en,
    });
  }

  final occurredAt = incidentOccurredAt(data);
  final timeText = (data['timeText'] ?? '').toString().trim();
  if (occurredAt != null) {
    final time = timeText.isNotEmpty
        ? timeText
        : (occurredAt.hour == 0 && occurredAt.minute == 0
            ? ''
            : DateFormat('HH:mm').format(occurredAt));
    final dateText = DateFormat('dd.MM.yyyy').format(occurredAt);
    row(
      'Datum',
      'Date',
      time.isEmpty ? dateText : '$dateText · $time',
    );
  }
  if (!workAccident) {
    row(
      'Vorfallart',
      'Incident type',
      incidentTypeLabel(incidentTypeOf(data), de: true),
      incidentTypeLabel(incidentTypeOf(data), de: false),
    );
  }
  row('Fahrer', 'Driver', incidentDriverName(data));
  row('Transporter-ID', 'Transporter ID', incidentDriverTid(data));
  row('Fahrzeug', 'Vehicle', incidentPlate(data));
  row('Ort', 'Location', incidentAddress(data));
  row('Hergang', 'Course of events', incidentDescription(data));
  row('Schaden', 'Damage', (data['damage'] ?? '').toString());

  if (workAccident) {
    row('Verletzung', 'Injury', incidentInjuryType(data));
    row('Körperteil', 'Body part', incidentBodyPart(data));
    row('Tätigkeit', 'Activity', incidentActivityAtTime(data));
    if (data['firstAid'] == true) {
      final by = (data['firstAidBy'] ?? '').toString().trim();
      row(
        'Erste Hilfe',
        'First aid',
        by.isEmpty ? 'Ja' : 'Ja (durch $by)',
        by.isEmpty ? 'Yes' : 'Yes (by $by)',
      );
    } else {
      row('Behandlung', 'Treatment', incidentDoctorText(data));
    }
    if (data['doctorVisited'] == true) {
      row('Durchgangsarzt', 'Designated doctor', 'Ja', 'Yes');
    }
    row('Zeugen', 'Witnesses', incidentWitnesses(data));
    final daysOff = data['expectedDaysOff'];
    if (daysOff is num && daysOff > 0) {
      row(
        'Voraussichtlicher Ausfall',
        'Expected days off',
        '${daysOff.toInt()} Tage',
        '${daysOff.toInt()} days',
      );
    }
    if (data['bgReportRequired'] == true) {
      row('BG-Meldung', 'BG report', 'erforderlich', 'required');
    }
  } else {
    row(
      'Schadenart',
      'Damage type',
      incidentDamageTypeLabel(data, de: true),
      incidentDamageTypeLabel(data, de: false),
    );
    row(
      'Polizei beteiligt',
      'Police involved',
      incidentPoliceLabel(data, de: true),
      incidentPoliceLabel(data, de: false),
    );
    final responsibility = incidentResponsibilityOf(data);
    if (responsibility != 'unknown') {
      row(
        'Schuldfrage',
        'Responsibility',
        responsibilityLabel(responsibility, de: true),
        responsibilityLabel(responsibility, de: false),
      );
    }
    final grounding = incidentGroundingOf(data);
    if (grounding != 'unknown') {
      final reason = (data['groundingReason'] ?? '').toString().trim();
      final labelDe = groundingLabel(grounding, de: true);
      final labelEn = groundingLabel(grounding, de: false);
      row(
        'Grounding',
        'Grounding',
        reason.isEmpty ? labelDe : '$labelDe ($reason)',
        reason.isEmpty ? labelEn : '$labelEn ($reason)',
      );
    }
    final tp = incidentMapOf(data['thirdParty']);
    final tpParts = <String>[
      (tp['name'] ?? '').toString(),
      (tp['plate'] ?? '').toString(),
      (tp['phone'] ?? '').toString(),
      (tp['email'] ?? '').toString(),
      (tp['insurance'] ?? '').toString(),
    ].map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (tpParts.isNotEmpty) {
      row('Gegenpartei', 'Third party', tpParts.join(' · '));
    }
  }

  row('Notizen', 'Notes', (data['notes'] ?? '').toString());
  row('Gemeldet von', 'Reported by', (data['reportedBy'] ?? '').toString());

  final photos = incidentPhotosOf(data)
      .map((p) => p.url)
      .where((u) => u.trim().isNotEmpty)
      .toList();
  final attachments = incidentAttachmentsOf(data)
      .where((a) => a.url.trim().isNotEmpty)
      .map((a) => {'name': a.name, 'url': a.url})
      .toList();

  final subtitleParts = <String>[
    if (occurredAt != null) DateFormat('dd.MM.yyyy').format(occurredAt),
    incidentDriverName(data),
    incidentPlate(data),
  ].where((e) => e.trim().isNotEmpty).toList();

  return <String, dynamic>{
    'type': 'incident',
    'caseId': caseId,
    'workAccident': workAccident,
    'titleDe': workAccident ? 'Arbeitsunfall' : 'Unfall- / Schadenbericht',
    'titleEn': workAccident ? 'Work accident' : 'Incident report',
    'subtitle': subtitleParts.join(' · '),
    'rows': rows,
    'photos': photos,
    'attachments': attachments,
  };
}
