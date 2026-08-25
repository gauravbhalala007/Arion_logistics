// lib/Screens/driver_profile_sections.dart
//
// Zwei Sektionen für das Fahrer-eigene Profil (`driver_profile_page.dart`):
//
//   1. [DriverDrivingHistorySection] — „Deine Fahrhistorie":
//      alle Vorfälle dieses Fahrers (Unfälle, Bergungen, Arbeitsunfälle).
//
//   2. [DriverAttendanceSection] — „Deine Anwesenheit":
//      Überstunden je Monat, Krankmeldungen, Urlaub + Resturlaub.
//
// ─────────────────────────────────────────────────────────────────────
// DATENQUELLEN — alle unter dem Fahrer-Pfad, den die Firestore-Rules dem
// Fahrer freigeben (`firestore.rules`: `drivers/{driverId}` +
// Subcollections, jeweils `driverTransporterId() == driverId`).
// Die Root-Sammlungen `users/{dsp}/incident_reports` bzw.
// `users/{dsp}/absence_requests` sind bewusst NICHT angefasst: dort ist
// die Regel `resource.data`-gebunden, ein unfilterter `list` würde
// scheitern.
//
//   * Vorfälle   `users/{dsp}/drivers/{TID}/incident_reports`
//                (Spiegel der Root-Sammlung, dual-write aus
//                `driver_incident_report_page.dart` /
//                `work_accident_form.dart`).
//                Fahrzeug-Checks liegen in derselben Sammlung und
//                tragen `kind == kVehicleCheckKind` — sie werden
//                herausgefiltert.
//   * Überstunden Map-Feld `overtimeAccount` im Fahrer-Dokument
//                (`{ 'YYYY-MM': {target, worked, paid} }`, MINUTEN) —
//                genau die Quelle, die Dispatch über „Time & Absence"
//                bzw. den Zeitkonto-Import befüllt.
//                Fallback, wenn das Feld leer ist: die servergerechnete
//                Subcollection `time_account/{YYYY-MM}` mit `soll`/`ist`
//                in STUNDEN (CoTimer).
//   * Abwesenh.  `users/{dsp}/drivers/{TID}/absence_requests`
//                (`type` = 'vacation' | 'sick_leave' | 'special_leave').
//
// Der Urlaubs-Saldo wird NICHT selbst gerechnet, sondern über
// `computeVacationBalance` aus `utils/vacation_pools.dart` — dieselbe
// Formel wie Admin und Fahrer-Abwesenheitsseite.
//
// Mehrsprachigkeit: `data/driver_profile/driver_profile_history_texts.dart`
// (11 Sprachen, Fallback locale → en), Sprache aus
// `Localizations.localeOf(context)` — dieselbe Mechanik wie bei den
// übrigen Fahrer-Inhalten.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../data/driver_profile/driver_profile_history_texts.dart';
import '../services/incident_reports.dart';
import '../services/vehicle_check_service.dart' show kVehicleCheckKind;
import '../utils/vacation_days.dart';
import '../utils/vacation_pools.dart';

const Color _kText = Color(0xFF22252F);
const Color _kMuted = Color(0xFF6B7280);
const Color _kTileBg = Color(0xFFF9FAFB);
const Color _kBorder = Color(0xFFE5E7EB);
const Color _kAccent = Color(0xFF1D7F5A);

/// Wie viele Einträge je Liste ohne „Mehr anzeigen" sichtbar sind.
const int _kPreviewCount = 3;

// ═════════════════════════════════════════════════════════════════════
// Gemeinsame Bausteine
// ═════════════════════════════════════════════════════════════════════

/// Weiße Profilkarte — gleiche Optik wie die Bestandskarten im Profil.
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.children,
    this.badge,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? badge;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _kText,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.35,
                        color: _kMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

/// Graue Kachel für einen Listeneintrag — mobil-tauglich untereinander,
/// keine Tabelle.
class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _kTileBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: child,
    );
  }
}

/// Hinweiszeile, wenn eine Liste leer ist.
class _EmptyHint extends StatelessWidget {
  const _EmptyHint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: _kTileBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: _kMuted),
      ),
    );
  }
}

/// „Mehr anzeigen" / „Weniger anzeigen" — klappt die Liste an Ort und
/// Stelle auf. Gleiche Mechanik wie `_ExpandToggleButton` im
/// Admin-Bereich, hier mit großer Tap-Fläche fürs Handy.
class _ShowMoreButton extends StatelessWidget {
  const _ShowMoreButton({
    required this.expanded,
    required this.hidden,
    required this.lang,
    required this.onTap,
  });

  final bool expanded;
  final int hidden;
  final String lang;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = expanded
        ? driverProfileHistoryText(lang, 'show_less')
        : driverProfileHistoryText(
            lang,
            'show_more',
            vars: {'count': hidden.toString()},
          );

    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: onTap,
        icon: Icon(
          expanded
              ? Icons.keyboard_arrow_up_rounded
              : Icons.keyboard_arrow_down_rounded,
          size: 20,
        ),
        label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        style: TextButton.styleFrom(
          foregroundColor: _kAccent,
          padding: const EdgeInsets.symmetric(vertical: 12),
          minimumSize: const Size.fromHeight(44),
          textStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

/// Überschrift eines Unterabschnitts innerhalb der Anwesenheits-Karte.
class _SubHeader extends StatelessWidget {
  const _SubHeader(this.title, {this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
                color: Color(0xFFA8A29E),
              ),
            ),
          ),
          if (trailing != null)
            Text(
              trailing!,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: _kText,
              ),
            ),
        ],
      ),
    );
  }
}

/// Kleiner Status-Chip (genehmigt / abgelehnt / offen).
Widget _statusChip(String lang, String status) {
  final s = status.trim().toLowerCase();
  late final String label;
  late final Color bg;
  late final Color fg;
  if (s == 'approved') {
    label = driverProfileHistoryText(lang, 'status_approved');
    bg = const Color(0xFFD1FAE5);
    fg = const Color(0xFF065F46);
  } else if (s == 'rejected' || s == 'cancelled') {
    label = driverProfileHistoryText(lang, 'status_rejected');
    bg = const Color(0xFFFEE2E2);
    fg = const Color(0xFF991B1B);
  } else {
    label = driverProfileHistoryText(lang, 'status_pending');
    bg = const Color(0xFFFDE68A);
    fg = const Color(0xFF92400E);
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
    ),
  );
}

/// Label/Wert-Zeile innerhalb einer Kachel.
Widget _metaLine(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: _kMuted,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF374151),
            ),
          ),
        ),
      ],
    ),
  );
}

String _formatDate(DateTime? d) {
  if (d == null) return '';
  final day = d.day.toString().padLeft(2, '0');
  final month = d.month.toString().padLeft(2, '0');
  return '$day/$month/${d.year}';
}

/// Minuten → „3" bzw. „3:15" (volle Stunden ohne „:00").
String _formatHours(int minutes) {
  final negative = minutes < 0;
  final absolute = minutes.abs();
  final hours = absolute ~/ 60;
  final rest = absolute % 60;
  final body =
      rest == 0 ? '$hours' : '$hours:${rest.toString().padLeft(2, '0')}';
  return '${negative ? '-' : ''}$body';
}

String _formatDays(double value) {
  if (value % 1 == 0) return value.toInt().toString();
  return value
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}

CollectionReference<Map<String, dynamic>> _driverSubcollection(
  String dspUid,
  String transporterId,
  String name,
) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(dspUid)
      .collection('drivers')
      .doc(transporterIdOf(transporterId))
      .collection(name);
}

// ═════════════════════════════════════════════════════════════════════
// TICKET A — „Deine Fahrhistorie"
// ═════════════════════════════════════════════════════════════════════

/// Ein Vorfall, reduziert auf das, was der Fahrer sehen soll.
class _HistoryEntry {
  const _HistoryEntry({
    required this.occurredAt,
    required this.typeLabel,
    required this.plate,
    required this.description,
    required this.damageText,
    required this.responsibilityLabel,
    required this.isWorkAccident,
  });

  final DateTime? occurredAt;
  final String typeLabel;
  final String plate;
  final String description;
  final String damageText;
  final String responsibilityLabel;
  final bool isWorkAccident;
}

class DriverDrivingHistorySection extends StatefulWidget {
  const DriverDrivingHistorySection({
    super.key,
    required this.dspUid,
    required this.transporterId,
  });

  final String dspUid;
  final String transporterId;

  @override
  State<DriverDrivingHistorySection> createState() =>
      _DriverDrivingHistorySectionState();
}

class _DriverDrivingHistorySectionState
    extends State<DriverDrivingHistorySection> {
  bool _expanded = false;

  String get _lang => Localizations.localeOf(context).languageCode;

  String _t(String key, [Map<String, String>? vars]) =>
      driverProfileHistoryText(_lang, key, vars: vars);

  /// Kanonische Vorfallart in der Fahrersprache. `incidentTypeLabel` aus
  /// dem Service kann nur DE/EN — deshalb hier über die eigene Tabelle.
  String _typeLabel(Map<String, dynamic> data) {
    if (isWorkAccident(data)) return _t('history_work_accident');
    switch (incidentTypeOf(data)) {
      case 'recovery':
        return _t('type_recovery');
      case 'wear_defect':
        return _t('type_wear_defect');
      case 'third_party_damage':
        return _t('type_third_party_damage');
      case 'withdrawn':
        return _t('type_withdrawn');
      case 'unclear':
        return _t('type_unclear');
      case 'accident':
      default:
        return _t('type_accident');
    }
  }

  String _responsibilityLabel(Map<String, dynamic> data) {
    switch (incidentResponsibilityOf(data)) {
      case 'at_fault':
        return _t('resp_at_fault');
      case 'not_at_fault':
        return _t('resp_not_at_fault');
      case 'partial':
        return _t('resp_partial');
      case 'unclear':
        return _t('resp_unclear');
      case 'unknown':
      default:
        return '';
    }
  }

  /// Schadensangabe: bevorzugt der Freitext `damage` (dort trägt der
  /// Admin z. B. die Schadenshöhe ein), sonst die Schadensart.
  String _damageText(Map<String, dynamic> data) {
    final free = (data['damage'] ?? '').toString().trim();
    if (free.isNotEmpty) return free;
    switch ((data['damageType'] ?? '').toString().trim()) {
      case 'vehicle':
        return _t('damage_vehicle');
      case 'property':
        return _t('damage_property');
      case 'both':
        return _t('damage_both');
      default:
        return '';
    }
  }

  List<_HistoryEntry> _entriesOf(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final out = <_HistoryEntry>[];
    for (final doc in docs) {
      final data = doc.data();
      // Fahrzeug-Checks teilen sich die Sammlung mit den Vorfällen —
      // sie gehören nicht in die Unfall-Historie.
      if ((data['kind'] ?? '').toString().trim() == kVehicleCheckKind) {
        continue;
      }
      out.add(
        _HistoryEntry(
          occurredAt: incidentOccurredAt(data),
          typeLabel: _typeLabel(data),
          plate: incidentPlate(data),
          description: incidentDescription(data),
          damageText: _damageText(data),
          responsibilityLabel: _responsibilityLabel(data),
          isWorkAccident: isWorkAccident(data),
        ),
      );
    }
    // Neueste zuerst; Einträge ohne Datum ans Ende.
    out.sort((a, b) {
      final ad = a.occurredAt;
      final bd = b.occurredAt;
      if (ad == null && bd == null) return 0;
      if (ad == null) return 1;
      if (bd == null) return -1;
      return bd.compareTo(ad);
    });
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      // Bewusst ohne `orderBy`: Arbeitsunfälle tragen kein `occurredAt`
      // und würden aus einer sortierten Query herausfallen. Die Liste je
      // Fahrer ist klein, sortiert wird clientseitig.
      stream: _driverSubcollection(
        widget.dspUid,
        widget.transporterId,
        'incident_reports',
      ).snapshots(),
      builder: (context, snap) {
        final loading =
            snap.connectionState == ConnectionState.waiting && !snap.hasData;
        final entries = snap.hasError
            ? const <_HistoryEntry>[]
            : _entriesOf(snap.data?.docs ?? const []);

        final visible = _expanded
            ? entries
            : entries.take(_kPreviewCount).toList();
        final hidden = entries.length - visible.length;

        return _ProfileCard(
          icon: Icons.history_rounded,
          iconBg: const Color(0xFFFFF1E7),
          iconColor: const Color(0xFFB45309),
          title: _t('history_title'),
          subtitle: _t('history_subtitle'),
          badge: entries.isEmpty ? null : '${entries.length}',
          children: [
            if (loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: LinearProgressIndicator(minHeight: 2),
              )
            else if (entries.isEmpty)
              _EmptyHint(_t('history_empty'))
            else ...[
              for (final entry in visible) _buildEntry(entry),
              if (hidden > 0 || _expanded)
                _ShowMoreButton(
                  expanded: _expanded,
                  hidden: hidden,
                  lang: _lang,
                  onTap: () => setState(() => _expanded = !_expanded),
                ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildEntry(_HistoryEntry entry) {
    final dateText = entry.occurredAt == null
        ? _t('history_date_unknown')
        : _formatDate(entry.occurredAt);

    return _EntryTile(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  dateText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _kText,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: entry.isWorkAccident
                      ? const Color(0xFFFEE2E2)
                      : const Color(0xFFE0E7FF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  entry.typeLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: entry.isWorkAccident
                        ? const Color(0xFF991B1B)
                        : const Color(0xFF3730A3),
                  ),
                ),
              ),
            ],
          ),
          if (entry.plate.isNotEmpty)
            _metaLine(_t('history_vehicle_label'), entry.plate),
          if (entry.damageText.isNotEmpty)
            _metaLine(_t('history_damage_label'), entry.damageText),
          if (entry.responsibilityLabel.isNotEmpty)
            _metaLine(
              _t('history_responsibility_label'),
              entry.responsibilityLabel,
            ),
          if (entry.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              entry.description,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.35,
                color: _kMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════
// TICKET B — „Deine Anwesenheit"
// ═════════════════════════════════════════════════════════════════════

/// Ein Monat des Überstundenkontos. Feldnamen und Rechenweg identisch zu
/// `_DriverOvertimeMonth` im Admin (`admin_shift_absence_page.dart`),
/// damit Fahrer und Dispatch dieselbe Zahl sehen.
class _OvertimeMonth {
  const _OvertimeMonth({
    required this.month,
    required this.targetMinutes,
    required this.workedMinutes,
    required this.paidMinutes,
  });

  /// `YYYY-MM`.
  final String month;
  final int targetMinutes;
  final int workedMinutes;
  final int paidMinutes;

  int get overtimeMinutes => workedMinutes - targetMinutes;

  bool get isEmpty =>
      targetMinutes == 0 && workedMinutes == 0 && paidMinutes == 0;

  String label(String lang) {
    final parts = month.split('-');
    if (parts.length < 2) return month;
    final year = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (year == null || m == null || m < 1 || m > 12) return month;
    return '${driverProfileMonthName(lang, m)} $year';
  }
}

/// „H:MM" bzw. „-H:MM" → Minuten. Gleiche Konvention wie im
/// Zeitkonto-Tab, damit Bestandsdaten als String weiter lesbar sind.
int _minutesFromAny(dynamic value) {
  if (value is num) return value.round();
  final cleaned = value?.toString().trim().replaceAll(',', ':') ?? '';
  if (cleaned.isEmpty) return 0;
  final negative = cleaned.startsWith('-');
  final raw = negative ? cleaned.substring(1) : cleaned;
  final parts = raw.split(':');
  final hours = int.tryParse(parts.first) ?? 0;
  final minutes = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
  final total = hours * 60 + minutes;
  return negative ? -total : total;
}

/// Liest das Map-Feld `overtimeAccount` des Fahrer-Dokuments.
List<_OvertimeMonth> _overtimeMonthsOf(Map<String, dynamic> data) {
  final raw = data['overtimeAccount'];
  if (raw is! Map) return const <_OvertimeMonth>[];
  final out = <_OvertimeMonth>[];
  raw.forEach((key, value) {
    if (value is! Map) return;
    final map = value.map((k, v) => MapEntry(k.toString(), v));
    out.add(
      _OvertimeMonth(
        month: key.toString(),
        targetMinutes: _minutesFromAny(map['target']),
        workedMinutes: _minutesFromAny(map['worked']),
        paidMinutes: _minutesFromAny(map['paid']),
      ),
    );
  });
  out.sort((a, b) => b.month.compareTo(a.month));
  return out;
}

/// Fallback für DSPs ohne Zeitkonto-Import: die servergerechneten
/// Monatsdokumente aus `time_account/{YYYY-MM}` (Werte in STUNDEN).
List<_OvertimeMonth> _overtimeMonthsFromTimeAccount(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
) {
  final out = <_OvertimeMonth>[];
  for (final doc in docs) {
    final data = doc.data();
    final soll = (data['soll'] as num?)?.toDouble() ?? 0;
    final ist = (data['ist'] as num?)?.toDouble() ?? 0;
    if (soll == 0 && ist == 0) continue;
    out.add(
      _OvertimeMonth(
        month: (data['month'] ?? doc.id).toString(),
        targetMinutes: (soll * 60).round(),
        workedMinutes: (ist * 60).round(),
        paidMinutes: 0,
      ),
    );
  }
  out.sort((a, b) => b.month.compareTo(a.month));
  return out;
}

/// Ein Abwesenheitszeitraum für die Anzeige.
class _AbsenceEntry {
  const _AbsenceEntry({
    required this.from,
    required this.to,
    required this.days,
    required this.status,
    required this.reason,
  });

  final DateTime? from;
  final DateTime? to;
  final int days;
  final String status;
  final String reason;
}

class DriverAttendanceSection extends StatefulWidget {
  const DriverAttendanceSection({
    super.key,
    required this.dspUid,
    required this.transporterId,
    required this.driverData,
    required this.poolsConfig,
  });

  final String dspUid;
  final String transporterId;

  /// Das bereits geladene Fahrer-Dokument — liefert `overtimeAccount`
  /// und `onboarding` ohne zusätzlichen Read.
  final Map<String, dynamic> driverData;

  final VacationPoolsConfig poolsConfig;

  @override
  State<DriverAttendanceSection> createState() =>
      _DriverAttendanceSectionState();
}

class _DriverAttendanceSectionState extends State<DriverAttendanceSection> {
  bool _overtimeExpanded = false;
  bool _sickExpanded = false;
  bool _vacationExpanded = false;

  String get _lang => Localizations.localeOf(context).languageCode;

  String _t(String key, [Map<String, String>? vars]) =>
      driverProfileHistoryText(_lang, key, vars: vars);

  Map<String, dynamic> get _onboarding {
    final raw = widget.driverData['onboarding'];
    if (raw is Map) return raw.map((k, v) => MapEntry(k.toString(), v));
    return const <String, dynamic>{};
  }

  @override
  Widget build(BuildContext context) {
    return _ProfileCard(
      icon: Icons.event_available_outlined,
      iconBg: const Color(0xFFE6F4EE),
      iconColor: _kAccent,
      title: _t('attendance_title'),
      subtitle: _t('attendance_subtitle'),
      children: [
        _buildOvertimeBlock(),
        const SizedBox(height: 16),
        _buildAbsenceBlocks(),
      ],
    );
  }

  // ── Überstunden ───────────────────────────────────────────────────

  Widget _buildOvertimeBlock() {
    final months = _overtimeMonthsOf(widget.driverData)
        .where((m) => !m.isEmpty)
        .toList();

    if (months.isNotEmpty) return _overtimeList(months);

    // Kein Zeitkonto-Import vorhanden — auf die servergerechneten
    // Monatsdokumente zurückfallen.
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _driverSubcollection(
        widget.dspUid,
        widget.transporterId,
        'time_account',
      ).snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SubHeader(_t('overtime_title')),
              const LinearProgressIndicator(minHeight: 2),
            ],
          );
        }
        final fallback = snap.hasError
            ? const <_OvertimeMonth>[]
            : _overtimeMonthsFromTimeAccount(snap.data?.docs ?? const []);
        return _overtimeList(fallback);
      },
    );
  }

  Widget _overtimeList(List<_OvertimeMonth> months) {
    final visible =
        _overtimeExpanded ? months : months.take(_kPreviewCount).toList();
    final hidden = months.length - visible.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SubHeader(_t('overtime_title')),
        if (months.isEmpty)
          _EmptyHint(_t('no_overtime'))
        else ...[
          for (final month in visible) _buildOvertimeTile(month),
          if (hidden > 0 || _overtimeExpanded)
            _ShowMoreButton(
              expanded: _overtimeExpanded,
              hidden: hidden,
              lang: _lang,
              onTap: () =>
                  setState(() => _overtimeExpanded = !_overtimeExpanded),
            ),
        ],
      ],
    );
  }

  Widget _buildOvertimeTile(_OvertimeMonth month) {
    final overtime = month.overtimeMinutes;
    final overtimeColor = overtime > 0
        ? const Color(0xFF065F46)
        : overtime < 0
            ? const Color(0xFF991B1B)
            : _kMuted;

    return _EntryTile(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  month.label(_lang),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _kText,
                  ),
                ),
              ),
              Text(
                '${overtime > 0 ? '+' : ''}${_formatHours(overtime)} h',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: overtimeColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Kundenbeispiel: „3 Stunden Überstunden von 184 Sollstunden".
          Text(
            _t('overtime_summary', {
              'overtime': _formatHours(overtime),
              'target': _formatHours(month.targetMinutes),
            }),
            style: const TextStyle(fontSize: 12.5, color: _kMuted),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 14,
            runSpacing: 2,
            children: [
              _miniStat(_t('target_label'), '${_formatHours(month.targetMinutes)} h'),
              _miniStat(_t('worked_label'), '${_formatHours(month.workedMinutes)} h'),
              if (month.paidMinutes != 0)
                _miniStat(
                  _t('paid_out_label'),
                  '${_formatHours(month.paidMinutes)} h',
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label ',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _kMuted,
            ),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }

  // ── Krankmeldungen + Urlaub ───────────────────────────────────────

  Widget _buildAbsenceBlocks() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _driverSubcollection(
        widget.dspUid,
        widget.transporterId,
        'absence_requests',
      ).snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SubHeader(_t('sick_title')),
              const LinearProgressIndicator(minHeight: 2),
            ],
          );
        }

        final docs = snap.hasError
            ? const <QueryDocumentSnapshot<Map<String, dynamic>>>[]
            : (snap.data?.docs ?? const []);

        final sick = <_AbsenceEntry>[];
        final vacation = <_AbsenceEntry>[];
        for (final doc in docs) {
          final data = doc.data();
          final type = (data['type'] ?? '').toString().trim().toLowerCase();
          final status =
              (data['status'] ?? '').toString().trim().toLowerCase();
          final from = parseVacationDate(data['fromDate']);
          final to = parseVacationDate(data['toDate']);
          if (from == null || to == null) continue;
          final reason = (data['reason'] ?? '').toString().trim();

          if (type == 'sick_leave' || type == 'sick') {
            sick.add(
              _AbsenceEntry(
                from: from,
                to: to,
                days: inclusiveDays(from, to),
                status: status.isEmpty ? 'pending' : status,
                reason: reason,
              ),
            );
          } else if (type == 'vacation') {
            if (status == 'rejected' || status == 'cancelled') continue;
            vacation.add(
              _AbsenceEntry(
                from: from,
                to: to,
                days: vacationChargeableDays(from, to),
                status: status.isEmpty ? 'pending' : status,
                reason: reason,
              ),
            );
          }
        }

        int byDateDesc(_AbsenceEntry a, _AbsenceEntry b) =>
            (b.from ?? DateTime(1970)).compareTo(a.from ?? DateTime(1970));
        sick.sort(byDateDesc);
        vacation.sort(byDateDesc);

        // Saldo NICHT selbst rechnen — dieselbe Formel wie Admin und
        // Fahrer-Abwesenheitsseite.
        final onboarding = _onboarding;
        final absences = <VacationAbsence>[
          for (final doc in docs)
            if (VacationAbsence.fromMap(doc.data()) case final a?) a,
        ];
        final balance = computeVacationBalance(
          absences: absences,
          config: widget.poolsConfig.forDriver(onboarding),
          annualVacationDays: annualVacationDaysOf(onboarding),
          workStartDate: parseVacationDate(onboarding['workStartDate']),
          manualOverride: vacationOverrideOf(onboarding),
          manualOverrideAt: vacationOverrideAtOf(onboarding),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAbsenceList(
              title: _t('sick_title'),
              entries: sick,
              emptyText: _t('no_sick'),
              expanded: _sickExpanded,
              onToggle: () => setState(() => _sickExpanded = !_sickExpanded),
            ),
            const SizedBox(height: 16),
            _buildAbsenceList(
              title: _t('vacation_title'),
              trailing:
                  '${_t('balance_label')}: ${_formatDays(balance.totalRemaining)} '
                  '${_t('days_label')}',
              entries: vacation,
              emptyText: _t('no_vacation'),
              expanded: _vacationExpanded,
              onToggle: () =>
                  setState(() => _vacationExpanded = !_vacationExpanded),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAbsenceList({
    required String title,
    required List<_AbsenceEntry> entries,
    required String emptyText,
    required bool expanded,
    required VoidCallback onToggle,
    String? trailing,
  }) {
    final visible = expanded ? entries : entries.take(_kPreviewCount).toList();
    final hidden = entries.length - visible.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SubHeader(title, trailing: trailing),
        if (entries.isEmpty)
          _EmptyHint(emptyText)
        else ...[
          for (final entry in visible) _buildAbsenceTile(entry),
          if (hidden > 0 || expanded)
            _ShowMoreButton(
              expanded: expanded,
              hidden: hidden,
              lang: _lang,
              onTap: onToggle,
            ),
        ],
      ],
    );
  }

  Widget _buildAbsenceTile(_AbsenceEntry entry) {
    return _EntryTile(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '${_formatDate(entry.from)} – ${_formatDate(entry.to)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _kText,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _statusChip(_lang, entry.status),
            ],
          ),
          _metaLine(_t('days_label'), entry.days.toString()),
          if (entry.reason.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              entry.reason,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.35,
                color: _kMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
