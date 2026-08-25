// lib/Screens/fleet_vehicle_detail_page.dart
//
// Fleethub-Fahrzeugdetailseite im Kunden-Design „2a" (Design-Handoff
// `design_handoff_fleet_hub`): Header-Leiste, links (70 %) die Profilkarte mit
// Kennzeichen-Schild, VIN-QR, Status-Kacheln, Stammdaten, kopierbaren
// Fahrzeugdaten, Dokumenten und Notizen — rechts (30 %) eine eigene
// Events-Spalte mit fixierter „Wartung & Verschleiß"-Kachel.
//
// Die Seite wird **eingebettet** in den Shell-Inhalt gerendert (State-Wechsel
// in `fleet_status_page.dart`), damit das Seitenmenü sichtbar bleibt.
//
// Schreibende Bestandsflows (Fahrzeug-Editor, Statuswechsel inkl. Werkstatt,
// TÜV-Datum, Notizen, Bemerkungen) laufen über [FleetVehicleDetailActions]
// zurück nach `fleet_status_page.dart` — hier werden sie nicht dupliziert.
// Neu sind nur die Felder, die es dort noch nicht gab (Leasinggeber, Bremsen-
// und Reifen-Spezifikation, Full-Maintenance-Kennzeichen) sowie die
// Fahrzeug-Events.

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/fleet_vehicle.dart';
import '../models/fleet_vehicle_document.dart';
import '../models/fleet_vehicle_event.dart';
import '../services/fleet_vehicle_document_repository.dart';
import '../services/fleet_vehicle_document_service.dart';
import '../services/fleet_vehicle_event_service.dart';
import '../services/incident_reports.dart';
import '../services/vehicle_check_service.dart' show kVehicleCheckEventType;
import '../widgets/admin_scope.dart';
import '../widgets/license_plate.dart';
import 'admin_incident_reports_page.dart';
import 'admin_vehicle_check_detail_page.dart';

// ---------------------------------------------------------------------------
// Design-Tokens (1:1 aus dem Handoff — identisch zum Driver Hub)
// ---------------------------------------------------------------------------

class _C {
  static const pageBg = Color(0xFFF2F4F7);
  static const card = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF7F9FB);
  static const border = Color(0xFFE5E9EE);
  static const rowLine = Color(0xFFEEF1F4);
  static const text = Color(0xFF1A212B);
  static const text2 = Color(0xFF5B6572);
  static const text3 = Color(0xFF8A93A0);
  static const muted = Color(0xFFB6BEC8);

  static const green = Color(0xFF0D8A60);
  static const greenHover = Color(0xFF0A6E4D);
  static const greenTint = Color(0xFFE7F6EF);
  static const greenBorder = Color(0xFFBFE3D3);
  static const docBg = Color(0xFFF4FBF8);
  static const docBorder = Color(0xFFDFF0E8);

  static const amberText = Color(0xFF9A6B1F);
  static const amberValue = Color(0xFFB0731C);
  static const amberBg = Color(0xFFFDF6EC);
  static const amberBorder = Color(0xFFF1E3C6);

  static const redText = Color(0xFFA13C3C);
  static const redValue = Color(0xFFB32F2F);
  static const redBg = Color(0xFFFDF0F0);
  static const redBorder = Color(0xFFF0D4D4);

  static const blue = Color(0xFF2A5FA8);
  static const blueTint = Color(0xFFE9F0FA);

  static const dashed = Color(0xFFD5DBE2);
}

const double _kNarrowBreakpoint = 700;

/// Auswahl für das Feld „Leasinggeber" (Handoff). Frei erweiterbar — der
/// gespeicherte Wert ist ein einfacher String, „—" räumt das Feld.
const List<String> kFleetLeasingProviders = <String>[
  'Ayvens',
  'Arval',
  'Sixt',
  'ALD',
  'Self-Owned',
];

// ---------------------------------------------------------------------------
// Brücke zu den bestehenden Flows in fleet_status_page.dart
// ---------------------------------------------------------------------------

/// Alle Aktionen, deren Implementierung in `_FleetStatusPageState` lebt.
/// So bleibt die Detailseite frei von doppelten Dialogen und Firestore-Writes
/// auf das Fahrzeug-Dokument selbst.
class FleetVehicleDetailActions {
  const FleetVehicleDetailActions({
    required this.editVehicle,
    required this.changeStatus,
    required this.editTuvDate,
    required this.editNotes,
    required this.editRemarks,
    required this.saveExtras,
    required this.statusLabel,
    required this.statusColor,
    required this.categoryLabel,
    required this.fuelLabel,
    required this.documentTypeLabel,
  });

  /// `_showVehicleEditor(vehicle:)` — der bestehende Stammdaten-Dialog.
  final void Function(FleetVehicle vehicle) editVehicle;

  /// `_handleVehicleStatusSelection` — inkl. Grounding-/Werkstatt-Dialog.
  final void Function(FleetVehicle vehicle, VehicleStatus status) changeStatus;

  /// `_saveTuvDate` über einen Datepicker.
  final void Function(FleetVehicle vehicle) editTuvDate;

  /// Notizen auf dem Fahrzeug-Dokument (`notes`).
  final void Function(FleetVehicle vehicle) editNotes;

  /// Freitext-Bemerkungen (`fleet_vehicle_extras.remarks`).
  final void Function(FleetVehicle vehicle, String current) editRemarks;

  /// Merge-Write nach `users/{scope}/fleet_vehicle_extras/{plate}`.
  final Future<void> Function(String plateNumber, Map<String, dynamic> data)
  saveExtras;

  final String Function(BuildContext context, VehicleStatus status) statusLabel;
  final Color Function(VehicleStatus status) statusColor;
  final String Function(BuildContext context, VehicleCategory category)
  categoryLabel;
  final String Function(BuildContext context, VehicleFuelType fuel) fuelLabel;
  final String Function(String documentType) documentTypeLabel;
}

// ---------------------------------------------------------------------------
// Events
// ---------------------------------------------------------------------------

/// Fachliche Event-Typen der Detailseite (Handoff).
enum FleetEventType {
  oil,
  tires,
  brakes,
  tuv,
  accident,
  handover,
  document,

  /// Geführte Foto-Inspektion aus der Fahrer-App. Der Spiegel wird von der
  /// Cloud Function `onVehicleCheckCreated` geschrieben (wire:
  /// [kVehicleCheckEventType]).
  ///
  /// Bewusst NICHT auf das Legacy-Wire `'inspection'` gemappt: Bestands-
  /// Events aus `vehicles/{plate}/events` nutzen `eventType: 'INSPECTION'`
  /// im Sinne von TÜV/HU (siehe `models/fleet_vehicle_event.dart`) — die
  /// dürfen nicht plötzlich als Fahrzeug-Check erscheinen.
  vehicleCheck,
  other,
}

/// Top-Level-Felder eines Unfall-Events in `fleet_events` — identisch benannt
/// zu den `metadata`-Schlüsseln der Bestands-ACCIDENT-Events, damit Alt- und
/// Neubestand dieselbe Darstellung teilen.
const List<String> kFleetAccidentFields = <String>[
  'damageLevel',
  'location',
  'policeReportNumber',
  'insuranceClaimNumber',
];

String fleetAccidentFieldLabel(String field, bool de) {
  switch (field) {
    case 'damageLevel':
      return de ? 'Schadensgrad' : 'Damage level';
    case 'location':
      return de ? 'Ort' : 'Location';
    case 'policeReportNumber':
      return de ? 'Polizei-Aktenzeichen' : 'Police report no.';
    case 'insuranceClaimNumber':
      return de ? 'Versicherungs-Schadennr.' : 'Insurance claim no.';
    default:
      return field;
  }
}

String fleetDamageLevelLabel(String raw, bool de) {
  switch (raw.trim().toUpperCase()) {
    case 'MINOR':
      return de ? 'Gering' : 'Minor';
    case 'MEDIUM':
      return de ? 'Mittel' : 'Medium';
    case 'MAJOR':
      return de ? 'Schwer' : 'Major';
    case 'TOTAL_LOSS':
      return de ? 'Totalschaden' : 'Total loss';
    default:
      return raw.trim();
  }
}

extension _FleetEventTypeX on FleetEventType {
  String get wire => switch (this) {
    FleetEventType.oil => 'oil',
    FleetEventType.tires => 'tires',
    FleetEventType.brakes => 'brakes',
    FleetEventType.tuv => 'tuv',
    FleetEventType.accident => 'accident',
    FleetEventType.handover => 'handover',
    FleetEventType.document => 'document',
    FleetEventType.vehicleCheck => kVehicleCheckEventType,
    FleetEventType.other => 'other',
  };

  IconData get icon => switch (this) {
    // Standard-Material-Icons statt Material Symbols: die Symbols-Font
    // lädt im Web-Build nicht zuverlässig.
    FleetEventType.oil => Icons.oil_barrel_outlined,
    FleetEventType.tires => Icons.tire_repair,
    FleetEventType.brakes => Icons.album_outlined,
    FleetEventType.tuv => Icons.warning_amber_rounded,
    FleetEventType.accident => Icons.car_crash_outlined,
    FleetEventType.handover => Icons.swap_horiz,
    FleetEventType.document => Icons.description_outlined,
    FleetEventType.vehicleCheck => Icons.fact_check_outlined,
    FleetEventType.other => Icons.event_note_outlined,
  };

  Color get color => switch (this) {
    FleetEventType.tuv => _C.amberValue,
    FleetEventType.accident => _C.redValue,
    FleetEventType.handover => _C.text2,
    FleetEventType.document => _C.text2,
    FleetEventType.other => _C.text2,
    _ => _C.green,
  };

  String label(bool de) => switch (this) {
    FleetEventType.oil => de ? 'Ölwechsel' : 'Oil change',
    FleetEventType.tires => de ? 'Reifenwechsel' : 'Tire change',
    FleetEventType.brakes => de ? 'Bremsenwechsel' : 'Brake change',
    FleetEventType.tuv => de ? 'TÜV / HU' : 'TÜV / inspection',
    FleetEventType.accident => de ? 'Unfall' : 'Accident',
    FleetEventType.handover => de ? 'Fahrzeugübergabe' : 'Handover',
    FleetEventType.document => de ? 'Dokument' : 'Document',
    FleetEventType.vehicleCheck => de ? 'Fahrzeug-Check' : 'Vehicle check',
    FleetEventType.other => de ? 'Sonstiges' : 'Other',
  };

  static FleetEventType fromWire(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'oil':
        return FleetEventType.oil;
      case 'tires':
      case 'tyre_change':
      case 'tire':
        return FleetEventType.tires;
      case 'brakes':
      case 'brake':
        return FleetEventType.brakes;
      case 'tuv':
      case 'inspection':
        return FleetEventType.tuv;
      case 'accident':
        return FleetEventType.accident;
      case 'handover':
        return FleetEventType.handover;
      case 'document':
      case 'document_renewal':
        return FleetEventType.document;
      case kVehicleCheckEventType:
        return FleetEventType.vehicleCheck;
      default:
        return FleetEventType.other;
    }
  }
}

/// Ein Eintrag der Events-Spalte — entweder aus `users/{scope}/fleet_events`
/// (neu, mit Kilometerstand) oder aus dem Bestand
/// `users/{scope}/vehicles/{plate}/events` (nur lesend eingeblendet, damit
/// bereits erfasste Historie nicht verschwindet).
class _FleetEvent {
  const _FleetEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.km,
    required this.legacy,
    this.accident = const <String, String>{},
    this.fileUrl = '',
    this.fileName = '',
    this.checkPath = '',
  });

  final String id;
  final FleetEventType type;
  final String title;
  final String subtitle;
  final DateTime? date;
  final int? km;

  /// `true` = Bestandsdatensatz aus der Fahrzeug-Subcollection.
  final bool legacy;

  /// Unfall-Zusatzfelder ([kFleetAccidentFields]) — leere Werte sind bereits
  /// aussortiert.
  final Map<String, String> accident;

  /// Angehängte Datei (bislang nur bei Bestands-Events möglich).
  final String fileUrl;
  final String fileName;

  /// Firestore-Pfad des zugehörigen Fahrzeug-Check-Dokuments — nur bei
  /// [FleetEventType.vehicleCheck] gesetzt. Öffnet die Check-Detailansicht.
  final String checkPath;

  bool get hasDetails =>
      accident.isNotEmpty ||
      subtitle.isNotEmpty ||
      fileUrl.trim().isNotEmpty ||
      checkPath.trim().isNotEmpty;

  /// Datum tolerant lesen: reguläre Events tragen einen [Timestamp],
  /// importierte/ältere Datensätze teils einen ISO-String. Ein falsch
  /// getypter Wert darf nie das ganze Panel abstürzen lassen.
  static DateTime? _dateFrom(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    if (raw is String) return DateTime.tryParse(raw.trim());
    return null;
  }

  static Map<String, String> _accidentFrom(Map<String, dynamic> source) {
    final result = <String, String>{};
    for (final field in kFleetAccidentFields) {
      final value = (source[field] ?? '').toString().trim();
      if (value.isNotEmpty) result[field] = value;
    }
    return result;
  }

  static _FleetEvent fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final rawKm = data['km'];
    return _FleetEvent(
      id: doc.id,
      type: _FleetEventTypeX.fromWire((data['type'] ?? '').toString()),
      title: (data['title'] ?? '').toString().trim(),
      subtitle: (data['subtitle'] ?? '').toString().trim(),
      date: _dateFrom(data['date']),
      km: rawKm is num ? rawKm.toInt() : int.tryParse('${rawKm ?? ''}'.trim()),
      legacy: false,
      accident: _accidentFrom(data),
      fileUrl: (data['fileUrl'] ?? '').toString().trim(),
      fileName: (data['fileName'] ?? '').toString().trim(),
      checkPath: (data['checkPath'] ?? '').toString().trim(),
    );
  }

  static _FleetEvent fromLegacy(FleetVehicleEvent event) {
    return _FleetEvent(
      id: event.eventId,
      type: _FleetEventTypeX.fromWire(event.eventType),
      title: event.title.trim(),
      subtitle: event.notes.trim(),
      date: DateTime.tryParse(event.eventDate.trim()),
      km: null,
      legacy: true,
      // Bestands-Unfälle tragen ihre Zusatzfelder in `metadata`.
      accident: _accidentFrom(event.metadata),
      fileUrl: event.fileUrl.trim(),
      fileName: event.fileName.trim(),
    );
  }
}

// ---------------------------------------------------------------------------
// Seite
// ---------------------------------------------------------------------------

class FleetVehicleDetailPage extends StatefulWidget {
  const FleetVehicleDetailPage({
    super.key,
    required this.dspUid,
    required this.plateNumber,
    required this.canManage,
    required this.actions,
    this.onBack,
  });

  /// Wirksamer Admin-Namespace (`users/{scope}`).
  final String dspUid;

  final String plateNumber;
  final bool canManage;
  final FleetVehicleDetailActions actions;

  /// Eingebetteter Modus: räumt den Detail-State der umgebenden Seite.
  final VoidCallback? onBack;

  @override
  State<FleetVehicleDetailPage> createState() => _FleetVehicleDetailPageState();
}

class _FleetVehicleDetailPageState extends State<FleetVehicleDetailPage> {
  final FleetVehicleDocumentService _documentService =
      FleetVehicleDocumentService();
  final FleetVehicleEventService _legacyEventService =
      FleetVehicleEventService();

  final ScrollController _leftScroll = ScrollController();
  final ScrollController _eventScroll = ScrollController();

  String? _copiedKey;
  Timer? _copyTimer;
  bool _busyUpload = false;

  /// Mobile (<700px) zeigt statt „Daten + Events untereinander" zwei Tabs.
  /// `true` = Events-Tab.
  bool _mobileEventsTab = false;

  /// `null` = alle Typen.
  FleetEventType? _eventFilter;

  Future<int>? _damageFuture;
  String _damageKey = '';

  /// Cache für [_lastCheckFallback] — ohne ihn würde jeder Rebuild des
  /// Events-Panels eine neue Firestore-Abfrage auslösen.
  Future<_FleetEvent?>? _lastCheckFuture;
  String _lastCheckKey = '';

  String get _plate => normalizePlateNumber(widget.plateNumber);

  bool get _de => Localizations.localeOf(context).languageCode == 'de';

  String _tr(String de, String en) => _de ? de : en;

  @override
  void dispose() {
    _copyTimer?.cancel();
    _leftScroll.dispose();
    _eventScroll.dispose();
    super.dispose();
  }

  // ── Firestore-Referenzen ────────────────────────────────────────────────

  DocumentReference<Map<String, dynamic>> get _vehicleRef => FirebaseFirestore
      .instance
      .collection('users')
      .doc(widget.dspUid)
      .collection('vehicles')
      .doc(_plate);

  DocumentReference<Map<String, dynamic>> get _extrasRef => FirebaseFirestore
      .instance
      .collection('users')
      .doc(widget.dspUid)
      .collection('fleet_vehicle_extras')
      .doc(_plate);

  /// Fahrzeug-Events im Admin-Subtree. Bewusst **nicht** in
  /// `vehicles/{plate}/events`: die dortigen Rules erlauben nur bei Unfällen
  /// ein gefülltes `metadata`, ein Kilometerstand wäre nicht speicherbar.
  CollectionReference<Map<String, dynamic>> get _eventsRef => FirebaseFirestore
      .instance
      .collection('users')
      .doc(widget.dspUid)
      .collection('fleet_events');

  Future<int> _damages() {
    final key = '${widget.dspUid}|$_plate';
    if (key != _damageKey || _damageFuture == null) {
      _damageKey = key;
      _damageFuture = countVehicleIncidentsForPlate(
        dspUid: widget.dspUid,
        plate: _plate,
      );
    }
    return _damageFuture!;
  }

  // ── Hilfen ──────────────────────────────────────────────────────────────

  void _snack(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: error ? _C.redValue : null,
        content: Text(message),
      ),
    );
  }

  Future<void> _copy(String key, String value) async {
    if (value.trim().isEmpty) return;
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    setState(() => _copiedKey = key);
    _copyTimer?.cancel();
    _copyTimer = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() => _copiedKey = null);
    });
  }

  void _back() {
    final onBack = widget.onBack;
    if (onBack != null) {
      onBack();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  static String _fmtDate(DateTime? date) {
    if (date == null) return '';
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }

  static String _fmtIsoDate(String iso) {
    final parsed = DateTime.tryParse(iso.trim());
    return parsed == null ? iso.trim() : _fmtDate(parsed);
  }

  static String _fmtKm(int km) {
    final digits = km.abs().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return '${km < 0 ? '-' : ''}$buffer';
  }

  static String _fileTypeOf(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.pdf')) return 'PDF';
    if (lower.endsWith('.png')) return 'PNG';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'JPG';
    if (lower.endsWith('.webp')) return 'WEBP';
    return 'FILE';
  }

  static String _canonicalType(String documentType) {
    final normalized = documentType.trim().toUpperCase();
    if (normalized == 'REGISTRATION_CERTIFICATE') return 'FAHRZEUGSCHEIN';
    if (normalized == 'TUV' ||
        normalized == 'TUV_CERTIFICATE' ||
        normalized == 'HU_TUV') {
      return 'HU_TUV_CERTIFICATE';
    }
    return normalized;
  }

  static String _str(dynamic raw) => (raw ?? '').toString().trim();

  /// Tolerantes Datum-Lesen aus Firestore: `Timestamp`, `DateTime` oder
  /// ISO-String — alles andere (inkl. `null`) ergibt `null`.
  static DateTime? _asDateTime(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    if (raw is String) return DateTime.tryParse(raw.trim());
    return null;
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Theme(
      // Dünne, helle Scrollbar wie im Handoff (8 px, Thumb #D5DBE2).
      data: Theme.of(context).copyWith(
        scrollbarTheme: const ScrollbarThemeData(
          thickness: WidgetStatePropertyAll<double>(8),
          thumbColor: WidgetStatePropertyAll<Color>(_C.dashed),
          trackColor: WidgetStatePropertyAll<Color>(Colors.transparent),
          trackBorderColor: WidgetStatePropertyAll<Color>(Colors.transparent),
          radius: Radius.circular(99),
          crossAxisMargin: 2,
        ),
      ),
      child: ColoredBox(
        color: _C.pageBg,
        child: LayoutBuilder(
          builder: (context, outer) {
            final narrow = outer.maxWidth < _kNarrowBreakpoint;
            return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _vehicleRef.snapshots(),
              builder: (context, vehicleSnap) {
                final doc = vehicleSnap.data;
                if (doc == null) {
                  return Column(
                    children: [
                      _headerBar(null, narrow: narrow),
                      const Expanded(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  );
                }
                if (!doc.exists) {
                  return Column(
                    children: [
                      _headerBar(null, narrow: narrow),
                      Expanded(
                        child: Center(
                          child: Text(
                            _tr(
                              'Fahrzeug wurde nicht gefunden.',
                              'Vehicle not found.',
                            ),
                            style: const TextStyle(
                              color: _C.text2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
                final vehicle = FleetVehicle.fromDoc(doc);
                return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: _extrasRef.snapshots(),
                  builder: (context, extrasSnap) {
                    final extras =
                        extrasSnap.data?.data() ?? const <String, dynamic>{};
                    return Column(
                      children: [
                        _headerBar(vehicle, narrow: narrow),
                        Expanded(child: _body(vehicle, extras, narrow: narrow)),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _headerBar(FleetVehicle? vehicle, {required bool narrow}) {
    return Container(
      decoration: const BoxDecoration(
        color: _C.card,
        border: Border(bottom: BorderSide(color: _C.border)),
      ),
      padding: EdgeInsets.symmetric(horizontal: narrow ? 12 : 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _IconAction(
                icon: Icons.arrow_back,
                size: 20,
                color: _C.text2,
                tooltip: _tr('Zurück', 'Back'),
                onTap: _back,
              ),
            ),
          ),
          // Mobil sitzt in der Mitte die Zwei-Segment-Umschaltung
          // „Fahrzeug | Events"; am Desktop bleibt der Titel stehen.
          if (narrow)
            _mobileTabBar()
          else
            Flexible(
              child: Text(
                'Fleethub · ${vehicle?.plateNumber ?? _plate}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _C.text,
                ),
              ),
            ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (narrow) ...[
                  // Mobil nur noch ein quadratischer Edit-Button; das
                  // Schließen-Kreuz entfällt (Zurück-Pfeil links genügt).
                  if (vehicle != null && widget.canManage)
                    _SquareIconButton(
                      icon: Icons.edit,
                      tooltip: _tr('Fahrzeug bearbeiten', 'Edit vehicle'),
                      onTap: () => widget.actions.editVehicle(vehicle),
                    ),
                ] else ...[
                  if (vehicle != null && widget.canManage)
                    _IconAction(
                      icon: Icons.edit_outlined,
                      size: 19,
                      color: _C.text2,
                      tooltip: _tr('Fahrzeug bearbeiten', 'Edit vehicle'),
                      onTap: () => widget.actions.editVehicle(vehicle),
                    ),
                  _IconAction(
                    icon: Icons.close,
                    size: 20,
                    color: _C.text2,
                    tooltip: _tr('Schließen', 'Close'),
                    onTap: _back,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Zwei-Segment-Umschaltung der Mobile-Ansicht. Bewusst nur leicht
  /// abgerundet (Radius 10 außen / 8 innen) — keine Pille.
  Widget _mobileTabBar() {
    Widget segment(String label, bool active, VoidCallback onTap) {
      return Material(
        color: active ? _C.green : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 38,
            constraints: const BoxConstraints(minWidth: 84),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : _C.text2,
                height: 1.3,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _C.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          segment(
            _tr('Fahrzeug', 'Vehicle'),
            !_mobileEventsTab,
            () => setState(() => _mobileEventsTab = false),
          ),
          const SizedBox(width: 3),
          segment(
            'Events',
            _mobileEventsTab,
            () => setState(() => _mobileEventsTab = true),
          ),
        ],
      ),
    );
  }

  Widget _body(
    FleetVehicle vehicle,
    Map<String, dynamic> extras, {
    required bool narrow,
  }) {
    if (narrow) {
      // Genau zwei Tabs: „Fahrzeug" (Profil, Fahrzeugdaten, Dokumente,
      // Notizen) und „Events" (Wartungskachel, Filter, Liste, + Event).
      if (_mobileEventsTab) {
        return Padding(
          padding: const EdgeInsets.all(12),
          child: _eventsPanel(vehicle, scrollable: true),
        );
      }
      return SingleChildScrollView(
        controller: _leftScroll,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _profileCard(vehicle, extras, narrow: true),
            const SizedBox(height: 12),
            _mobileVehicleDataCard(vehicle, extras),
            const SizedBox(height: 12),
            _documentsCard(vehicle, extras),
            const SizedBox(height: 12),
            _notesCard(vehicle, extras),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 7,
            child: SingleChildScrollView(
              controller: _leftScroll,
              padding: const EdgeInsets.only(right: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _profileCard(vehicle, extras, narrow: false),
                  const SizedBox(height: 14),
                  _documentsCard(vehicle, extras),
                  const SizedBox(height: 14),
                  _notesCard(vehicle, extras),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(flex: 3, child: _eventsPanel(vehicle, scrollable: true)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Profilkarte
  // ═══════════════════════════════════════════════════════════════════════

  /// Profilkarte. Am Desktop trägt sie zusätzlich Stammdaten- und
  /// Copy-Raster; mobil wandern beide in die eigene Karte
  /// [_mobileVehicleDataCard], hier bleibt nur das Kopfband.
  Widget _profileCard(
    FleetVehicle vehicle,
    Map<String, dynamic> extras, {
    required bool narrow,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        border: Border.all(color: _C.border),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _profileHeaderBand(vehicle, extras),
          if (!narrow)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _masterDataGrid(vehicle, extras),
                  const SizedBox(height: 14),
                  const Divider(height: 1, thickness: 1, color: _C.rowLine),
                  const SizedBox(height: 12),
                  _vehicleDataBlock(vehicle, extras),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _profileHeaderBand(FleetVehicle vehicle, Map<String, dynamic> extras) {
    final leasing = _str(extras['leasingProvider']);

    final plateBlock = SizedBox(
      width: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          LicensePlate.detail(plate: vehicle.plateNumber),
          const SizedBox(height: 9),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [_statusBadge(vehicle), _leasingBadge(vehicle, leasing)],
          ),
        ],
      ),
    );

    final qr = VinQrTile(
      data: vehicle.vinNumber,
      tooltip: vehicle.vinNumber.trim().isEmpty
          ? _tr('Keine VIN hinterlegt', 'No VIN on file')
          : 'VIN ${vehicle.vinNumber.trim()}',
    );

    final groundedBanner = _groundedReasonBanner(vehicle, extras);

    return Container(
      decoration: const BoxDecoration(
        color: _C.surface,
        border: Border(bottom: BorderSide(color: _C.border)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              // Schmale Bänder halten die vier Kacheln als kompaktes 2×2 statt
              // sie zu vier vollbreiten Zeilen zu stapeln.
              final tiles = _statusTiles(
                vehicle,
                extras,
                twoColumns: constraints.maxWidth < 720,
              );
              if (constraints.maxWidth < 720) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(child: plateBlock),
                        const SizedBox(width: 16),
                        qr,
                      ],
                    ),
                    const SizedBox(height: 14),
                    tiles,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  plateBlock,
                  const SizedBox(width: 16),
                  qr,
                  const SizedBox(width: 20),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 620),
                        child: tiles,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          if (groundedBanner != null) ...[
            const SizedBox(height: 14),
            groundedBanner,
          ],
        ],
      ),
    );
  }

  /// Warum steht das Fahrzeug? Solange es stillgelegt ist, sitzt der Grund
  /// aus `fleet_vehicle_extras.groundedReason` gut sichtbar unter den
  /// Status-Kacheln — Fahrzeuge ohne Grund (Bestand) zeigen nichts.
  Widget? _groundedReasonBanner(
    FleetVehicle vehicle,
    Map<String, dynamic> extras,
  ) {
    if (!vehicle.status.isGrounded) return null;
    final reason = _str(extras['groundedReason']);
    if (reason.isEmpty) return null;

    final since = _asDateTime(extras['groundedAt']);
    final sinceLabel = since == null
        ? ''
        : '${_tr('seit', 'since')} ${_fmtDate(since)}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 11),
      decoration: BoxDecoration(
        color: _C.redBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _C.redBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(
              Icons.report_problem_outlined,
              size: 16,
              color: _C.redValue,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _tr('GRUND DER STILLLEGUNG', 'REASON FOR GROUNDING'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                          color: _C.redText,
                          height: 1.3,
                        ),
                      ),
                    ),
                    if (sinceLabel.isNotEmpty)
                      Text(
                        sinceLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _C.redText,
                          height: 1.3,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  reason,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: _C.redValue,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(FleetVehicle vehicle) {
    final color = widget.actions.statusColor(vehicle.status);
    final label = widget.actions.statusLabel(context, vehicle.status);
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            vehicle.status.isGrounded
                ? Icons.error_outline
                : vehicle.status == VehicleStatus.inactive
                ? Icons.pause_circle_outline
                : Icons.check,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
              height: 1.3,
            ),
          ),
          if (widget.canManage) ...[
            const SizedBox(width: 2),
            Icon(Icons.keyboard_arrow_down, size: 14, color: color),
          ],
        ],
      ),
    );

    if (!widget.canManage) return badge;
    return PopupMenuButton<VehicleStatus>(
      tooltip: _tr('Status ändern', 'Change status'),
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (status) => widget.actions.changeStatus(vehicle, status),
      itemBuilder: (ctx) => [
        for (final status in VehicleStatus.values)
          PopupMenuItem<VehicleStatus>(
            value: status,
            child: Text(widget.actions.statusLabel(ctx, status)),
          ),
      ],
      child: badge,
    );
  }

  Widget _leasingBadge(FleetVehicle vehicle, String leasing) {
    final hasValue = leasing.isNotEmpty;
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: hasValue ? _C.blueTint : _C.rowLine,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            hasValue
                ? '${_tr('Leasing', 'Leasing')}: ${leasing.toUpperCase()}'
                : _tr('Leasinggeber wählen', 'Pick lessor'),
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: hasValue ? _C.blue : _C.text3,
              height: 1.3,
            ),
          ),
          if (widget.canManage) ...[
            const SizedBox(width: 2),
            Icon(
              Icons.arrow_drop_down,
              size: 14,
              color: hasValue ? _C.blue : _C.text3,
            ),
          ],
        ],
      ),
    );
    if (!widget.canManage) {
      return hasValue ? badge : const SizedBox.shrink();
    }
    return _Hoverable(
      tooltip: _tr('Leasinggeber wählen', 'Pick lessor'),
      onTap: () => _pickLeasingProvider(leasing),
      child: badge,
    );
  }

  Widget _statusTiles(
    FleetVehicle vehicle,
    Map<String, dynamic> extras, {
    bool twoColumns = false,
  }) {
    final fullMaintenance = extras['fullMaintenance'] == true;
    final serviceEnd = vehicle.serviceEndDate.trim();

    return StreamBuilder<List<FleetVehicleDocument>>(
      stream: _documentService.watchDocuments(
        dspUid: widget.dspUid,
        plateNumber: _plate,
      ),
      builder: (context, snapshot) {
        final docs = snapshot.data ?? const <FleetVehicleDocument>[];
        final tuv = _latestOfType(docs, 'HU_TUV_CERTIFICATE');
        final tuvDate = tuv?.expiryDate.trim() ?? '';
        final tuvSet = tuvDate.isNotEmpty;
        final tuvExpired =
            tuvSet &&
            (DateTime.tryParse(tuvDate)?.isBefore(DateTime.now()) ?? false);

        return _Grid2(
          forceTwoColumns: twoColumns,
          children: [
            _statusTile(
              label: 'TÜV',
              value: tuvSet ? _fmtIsoDate(tuvDate) : _tr('fehlt', 'missing'),
              // Abgelaufen = rot (wie in der Liste), fehlend = amber.
              tone: tuvExpired
                  ? _Tone.red
                  : !tuvSet
                  ? _Tone.amber
                  : _Tone.green,
              onTap: widget.canManage
                  ? () => widget.actions.editTuvDate(vehicle)
                  : null,
              tooltip: widget.canManage
                  ? _tr('TÜV-Datum setzen', 'Set TÜV date')
                  : null,
            ),
            _statusTile(
              label: _tr('Nächster Service', 'Next service'),
              value: serviceEnd.isEmpty ? '—' : _fmtIsoDate(serviceEnd),
              tone: serviceEnd.isEmpty ? _Tone.empty : _Tone.neutral,
            ),
            FutureBuilder<int>(
              future: _damages(),
              builder: (context, damageSnap) {
                final count = damageSnap.data;
                return _statusTile(
                  label: _tr('Schäden', 'Damages'),
                  value: count == null ? '…' : '$count',
                  tone: (count ?? 0) > 0 ? _Tone.red : _Tone.neutral,
                  onTap: _openIncidentCenter,
                  tooltip: _tr(
                    'Fahrzeug-Vorfälle — Incident-Center öffnen',
                    'Vehicle incidents — open the incident center',
                  ),
                );
              },
            ),
            _statusTile(
              label: 'Full Maintenance',
              value: fullMaintenance ? _tr('Ja', 'Yes') : _tr('Nein', 'No'),
              tone: fullMaintenance ? _Tone.green : _Tone.neutral,
              onTap: widget.canManage
                  ? () => _saveExtras(
                      {'fullMaintenance': !fullMaintenance},
                      _tr(
                        'Full Maintenance aktualisiert.',
                        'Full maintenance updated.',
                      ),
                    )
                  : null,
              tooltip: widget.canManage ? _tr('Umschalten', 'Toggle') : null,
            ),
          ],
        );
      },
    );
  }

  Widget _statusTile({
    required String label,
    required String value,
    required _Tone tone,
    VoidCallback? onTap,
    String? tooltip,
  }) {
    final (bg, borderColor, labelColor, valueColor) = switch (tone) {
      _Tone.amber => (_C.amberBg, _C.amberBorder, _C.amberText, _C.amberValue),
      _Tone.green => (_C.greenTint, _C.greenBorder, _C.green, _C.green),
      _Tone.red => (_C.redBg, _C.redBorder, _C.redText, _C.redValue),
      _Tone.empty => (_C.card, _C.border, _C.text3, _C.muted),
      _Tone.neutral => (_C.card, _C.border, _C.text3, _C.text),
    };

    final tile = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
              color: labelColor,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: valueColor,
              height: 1.25,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return tooltip == null
          ? tile
          : Tooltip(
              message: tooltip,
              waitDuration: const Duration(milliseconds: 500),
              child: tile,
            );
    }
    return _Hoverable(
      onTap: onTap,
      tooltip: tooltip,
      borderRadius: BorderRadius.circular(10),
      child: tile,
    );
  }

  Widget _masterDataGrid(FleetVehicle vehicle, Map<String, dynamic> extras) {
    final leasing = _str(extras['leasingProvider']);
    final year = vehicle.manufacturingYear;
    return _Grid2(
      children: [
        _dataTile(_tr('Marke', 'Brand'), vehicle.brand),
        _dataTile(_tr('Modell', 'Model'), vehicle.model),
        _dataTile(_tr('Baujahr', 'Year'), year == 0 ? '—' : '$year'),
        _dataTile(
          _tr('Kraftstoff', 'Fuel'),
          widget.actions.fuelLabel(context, vehicle.fuelType),
        ),
        _dataTile(
          _tr('Kategorie', 'Category'),
          widget.actions.categoryLabel(context, vehicle.category),
        ),
        _dataTile(
          _tr('Leasinggeber', 'Lessor'),
          leasing.isEmpty ? '—' : leasing,
          onTap: widget.canManage ? () => _pickLeasingProvider(leasing) : null,
          trailing: widget.canManage
              ? const Icon(Icons.arrow_drop_down, size: 18, color: _C.text3)
              : null,
        ),
        // Kategorie-spezifische Vertrags-/Eigentümerdaten — nur was befüllt
        // ist. Bearbeitung läuft weiter über den bestehenden Fahrzeug-Editor.
        ..._categoryDataTiles(vehicle),
      ],
    );
  }

  /// Zusatzfelder aus `vehicle.metadata`, passend zur Kategorie. Leere Werte
  /// werden ausgelassen, damit das Raster nicht mit „—" zuwächst.
  /// Tupel: (Label, Wert, istDatum).
  List<(String, String, bool)> _categoryDataEntries(FleetVehicle vehicle) {
    final entries = <(String, String, bool)>[];
    final metadata = vehicle.metadata;

    if (metadata is ArmadaVehicleMetadata) {
      entries.addAll([
        ('Armada-ID', metadata.armadaId, false),
        (
          _tr('Armada-Firma', 'Armada company'),
          metadata.armadaCompanyName,
          false,
        ),
        (
          _tr('Vertragsbeginn', 'Contract start'),
          metadata.contractStartDate,
          true,
        ),
        (_tr('Vertragsende', 'Contract end'), metadata.contractEndDate, true),
      ]);
    } else if (metadata is AmazonPaidRentalMetadata) {
      entries.addAll([
        (_tr('Mietfirma', 'Rental company'), metadata.rentalCompanyName, false),
        (
          _tr('Vertragsnummer', 'Contract number'),
          metadata.contractNumber,
          false,
        ),
        (_tr('Mietbeginn', 'Rental start'), metadata.rentalStartDate, true),
        (_tr('Mietende', 'Rental end'), metadata.rentalEndDate, true),
      ]);
    } else if (metadata is SelfSourcedRentalMetadata) {
      entries.addAll([
        (_tr('Eigentümer', 'Owner'), metadata.ownerName, false),
        (_tr('Kontakt', 'Contact'), metadata.ownerContactNumber, false),
        (
          _tr('Mietvertragsnummer', 'Rental agreement no.'),
          metadata.rentalAgreementNumber,
          false,
        ),
        (_tr('Mietbeginn', 'Rental start'), metadata.rentalStartDate, true),
        (_tr('Mietende', 'Rental end'), metadata.rentalEndDate, true),
      ]);
    } else if (metadata is SelfOwnedRentalMetadata) {
      entries.addAll([
        (_tr('Eigentumsart', 'Ownership type'), metadata.ownershipType, false),
        (_tr('Kaufdatum', 'Purchase date'), metadata.purchaseDate, true),
      ]);
    }

    return entries.where((entry) => entry.$2.trim().isNotEmpty).toList();
  }

  List<Widget> _categoryDataTiles(FleetVehicle vehicle) {
    return [
      for (final entry in _categoryDataEntries(vehicle))
        _dataTile(
          entry.$1,
          entry.$3 ? _fmtIsoDate(entry.$2) : entry.$2,
          onTap: widget.canManage
              ? () => widget.actions.editVehicle(vehicle)
              : null,
        ),
    ];
  }

  Widget _dataTile(
    String label,
    String value, {
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    final display = value.trim().isEmpty ? '—' : value.trim();
    final tile = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                    color: _C.text3,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  display,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _C.text,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing],
        ],
      ),
    );
    if (onTap == null) return tile;
    return _Hoverable(
      onTap: onTap,
      tooltip: _tr('Bearbeiten', 'Edit'),
      child: tile,
    );
  }

  // ── Fahrzeugdaten — Mobile: Stammdaten + Copy-Raster in EINER Karte ────

  /// Mobile Variante: Stammdaten und kopierbare Kernwerte sitzen in einer
  /// gemeinsamen Karte. Reihenfolge nach Kundenvorgabe — Marke voll,
  /// Modell + Baujahr und Kraftstoff + Kategorie je halb, dann Leasinggeber,
  /// VIN, Kennzeichen, Bremsen, Reifen. Jede Zeile ist einzeln kopierbar,
  /// „Alle kopieren" sitzt im Karten-Header.
  Widget _mobileVehicleDataCard(
    FleetVehicle vehicle,
    Map<String, dynamic> extras,
  ) {
    final leasing = _str(extras['leasingProvider']);
    final brakes = _str(extras['brakeSpec']);
    final tires = _str(extras['tireSpec']);
    final year = vehicle.manufacturingYear;
    final allCopied = _copiedKey == 'all';

    Widget pair(Widget a, Widget b) => IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: a),
          const SizedBox(width: 8),
          Expanded(child: b),
        ],
      ),
    );

    return _card(
      title: _tr('Fahrzeugdaten', 'Vehicle data'),
      trailing: _Hoverable(
        onTap: () => _copyAll(vehicle, extras),
        tooltip: _tr('Alle Kernwerte kopieren', 'Copy all key values'),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                allCopied ? Icons.check : Icons.content_copy,
                size: 15,
                color: _C.green,
              ),
              const SizedBox(width: 5),
              Text(
                _tr('Alle kopieren', 'Copy all'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _C.green,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _mobileCopyTile(
            copyKey: 'brand',
            label: _tr('Marke', 'Brand'),
            value: vehicle.brand,
          ),
          const SizedBox(height: 8),
          pair(
            _mobileCopyTile(
              copyKey: 'model',
              label: _tr('Modell', 'Model'),
              value: vehicle.model,
            ),
            _mobileCopyTile(
              copyKey: 'year',
              label: _tr('Baujahr', 'Year'),
              value: year == 0 ? '' : '$year',
            ),
          ),
          const SizedBox(height: 8),
          pair(
            _mobileCopyTile(
              copyKey: 'fuel',
              label: _tr('Kraftstoff', 'Fuel'),
              value: widget.actions.fuelLabel(context, vehicle.fuelType),
            ),
            _mobileCopyTile(
              copyKey: 'category',
              label: _tr('Kategorie', 'Category'),
              value: widget.actions.categoryLabel(context, vehicle.category),
            ),
          ),
          const SizedBox(height: 8),
          _mobileCopyTile(
            copyKey: 'leasing',
            label: _tr('Leasinggeber', 'Lessor'),
            value: leasing,
            trailing: widget.canManage
                ? _IconAction(
                    icon: Icons.arrow_drop_down,
                    size: 20,
                    color: _C.text3,
                    tooltip: _tr('Leasinggeber wählen', 'Pick lessor'),
                    onTap: () => _pickLeasingProvider(leasing),
                  )
                : null,
          ),
          for (final tile in _mobileCategoryTiles(vehicle)) ...[
            const SizedBox(height: 8),
            tile,
          ],
          const SizedBox(height: 8),
          _mobileCopyTile(
            copyKey: 'vin',
            label: 'VIN',
            value: vehicle.vinNumber,
            mono: true,
            onEdit: widget.canManage
                ? () => widget.actions.editVehicle(vehicle)
                : null,
          ),
          const SizedBox(height: 8),
          _mobileCopyTile(
            copyKey: 'plate',
            label: _tr('Kennzeichen', 'Plate'),
            value: vehicle.plateNumber,
          ),
          const SizedBox(height: 8),
          _mobileCopyTile(
            copyKey: 'brakes',
            label: _tr('Bremsen', 'Brakes'),
            value: brakes,
            onEdit: widget.canManage
                ? () => _editExtraText(
                    field: 'brakeSpec',
                    title: _tr('Bremsen-Spezifikation', 'Brake specification'),
                    hint: 'Scheibe · ATE 300×28',
                    current: brakes,
                  )
                : null,
          ),
          const SizedBox(height: 8),
          _mobileCopyTile(
            copyKey: 'tires',
            label: _tr('Reifen', 'Tires'),
            value: tires,
            onEdit: widget.canManage
                ? () => _editExtraText(
                    field: 'tireSpec',
                    title: _tr('Reifen-Spezifikation', 'Tire specification'),
                    hint: '235/65 R16C 115/113R',
                    current: tires,
                  )
                : null,
          ),
        ],
      ),
    );
  }

  /// Kategorie-Zusatzfelder als kopierbare Mobile-Kacheln.
  List<Widget> _mobileCategoryTiles(FleetVehicle vehicle) {
    final entries = _categoryDataEntries(vehicle);
    return [
      for (var i = 0; i < entries.length; i++)
        _mobileCopyTile(
          copyKey: 'cat$i',
          label: entries[i].$1,
          value: entries[i].$3 ? _fmtIsoDate(entries[i].$2) : entries[i].$2,
          onEdit: widget.canManage
              ? () => widget.actions.editVehicle(vehicle)
              : null,
        ),
    ];
  }

  /// Label oben, Wert darunter, rechts Kopier- und optional Stift-/Dropdown-
  /// Icon. Ein Tipp auf die Kachel kopiert den Wert (1,5 s Häkchen).
  Widget _mobileCopyTile({
    required String copyKey,
    required String label,
    required String value,
    bool mono = false,
    VoidCallback? onEdit,
    Widget? trailing,
  }) {
    final display = value.trim();
    final copied = _copiedKey == copyKey;
    return _Hoverable(
      onTap: display.isEmpty ? null : () => _copy(copyKey, display),
      tooltip: display.isEmpty ? null : '$label — ${_tr('kopieren', 'copy')}',
      borderRadius: BorderRadius.circular(10),
      background: _C.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                      color: _C.text3,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    display.isEmpty ? '—' : display,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: display.isEmpty ? _C.muted : _C.text,
                      height: 1.3,
                      fontFamily: mono ? 'monospace' : null,
                      fontFamilyFallback: mono
                          ? const <String>['Menlo', 'Courier']
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              copied ? Icons.check : Icons.content_copy,
              size: 15,
              color: copied ? _C.green : _C.muted,
            ),
            if (onEdit != null)
              _IconAction(
                icon: Icons.edit_outlined,
                size: 15,
                color: _C.muted,
                tooltip: _tr('Bearbeiten', 'Edit'),
                onTap: onEdit,
              ),
            if (trailing != null) trailing,
            if (onEdit == null && trailing == null) const SizedBox(width: 6),
          ],
        ),
      ),
    );
  }

  // ── Fahrzeugdaten (kopierbar) ──────────────────────────────────────────

  Widget _vehicleDataBlock(FleetVehicle vehicle, Map<String, dynamic> extras) {
    final brakes = _str(extras['brakeSpec']);
    final tires = _str(extras['tireSpec']);
    final allCopied = _copiedKey == 'all';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _tr('Fahrzeugdaten', 'Vehicle data').toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: _C.text3,
                  height: 1.3,
                ),
              ),
            ),
            _Hoverable(
              onTap: () => _copyAll(vehicle, extras),
              tooltip: _tr('Alle Kernwerte kopieren', 'Copy all key values'),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      allCopied ? Icons.check : Icons.content_copy,
                      size: 14,
                      color: _C.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _tr('Alle kopieren', 'Copy all'),
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: _C.green,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _Grid2(
          children: [
            _copyRow(
              copyKey: 'vin',
              label: 'VIN',
              value: vehicle.vinNumber,
              mono: true,
              onEdit: widget.canManage
                  ? () => widget.actions.editVehicle(vehicle)
                  : null,
            ),
            _copyRow(
              copyKey: 'brakes',
              label: _tr('Bremsen', 'Brakes'),
              value: brakes,
              onEdit: widget.canManage
                  ? () => _editExtraText(
                      field: 'brakeSpec',
                      title: _tr(
                        'Bremsen-Spezifikation',
                        'Brake specification',
                      ),
                      hint: 'Scheibe · ATE 300×28',
                      current: brakes,
                    )
                  : null,
            ),
            _copyRow(
              copyKey: 'plate',
              label: _tr('Kennz.', 'Plate'),
              value: vehicle.plateNumber,
            ),
            _copyRow(
              copyKey: 'tires',
              label: _tr('Reifen', 'Tires'),
              value: tires,
              onEdit: widget.canManage
                  ? () => _editExtraText(
                      field: 'tireSpec',
                      title: _tr('Reifen-Spezifikation', 'Tire specification'),
                      hint: '235/65 R16C 115/113R',
                      current: tires,
                    )
                  : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _copyRow({
    required String copyKey,
    required String label,
    required String value,
    bool mono = false,
    VoidCallback? onEdit,
  }) {
    final display = value.trim();
    final copied = _copiedKey == copyKey;
    return _Hoverable(
      onTap: display.isEmpty ? null : () => _copy(copyKey, display),
      tooltip: display.isEmpty ? null : '$label — ${_tr('kopieren', 'copy')}',
      borderRadius: BorderRadius.circular(10),
      background: _C.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 56,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _C.text3,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                display.isEmpty ? '—' : display,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: display.isEmpty ? _C.muted : _C.text,
                  height: 1.3,
                  fontFamily: mono ? 'monospace' : null,
                  fontFamilyFallback: mono
                      ? const <String>['Menlo', 'Courier']
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              copied ? Icons.check : Icons.content_copy,
              size: 16,
              color: copied ? _C.green : _C.muted,
            ),
            if (onEdit != null) ...[
              const SizedBox(width: 2),
              _IconAction(
                icon: Icons.edit_outlined,
                size: 16,
                color: _C.muted,
                tooltip: _tr('Bearbeiten', 'Edit'),
                onTap: onEdit,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _copyAll(
    FleetVehicle vehicle,
    Map<String, dynamic> extras,
  ) async {
    final docs = await _documentService
        .watchDocuments(dspUid: widget.dspUid, plateNumber: _plate)
        .first
        .catchError((_) => const <FleetVehicleDocument>[]);
    final tuv = _latestOfType(docs, 'HU_TUV_CERTIFICATE')?.expiryDate.trim();
    final damages = await _damages().catchError((_) => 0);
    if (!mounted) return;

    String orDash(String? value) =>
        (value ?? '').trim().isEmpty ? '—' : value!.trim();

    final lines = <String>[
      '${_tr('Kennzeichen', 'Plate')}: ${vehicle.plateNumber}',
      'VIN: ${orDash(vehicle.vinNumber)}',
      '${_tr('Marke', 'Brand')}: ${orDash(vehicle.brand)}',
      '${_tr('Modell', 'Model')}: ${orDash(vehicle.model)}',
      'TÜV: ${(tuv ?? '').isEmpty ? _tr('fehlt', 'missing') : _fmtIsoDate(tuv!)}',
      '${_tr('Bremsen', 'Brakes')}: ${orDash(_str(extras['brakeSpec']))}',
      '${_tr('Reifen', 'Tires')}: ${orDash(_str(extras['tireSpec']))}',
      'Full Maintenance: '
          '${extras['fullMaintenance'] == true ? _tr('Ja', 'Yes') : _tr('Nein', 'No')}',
      '${_tr('Fahrzeugschäden', 'Vehicle damages')}: $damages',
    ];
    await _copy('all', lines.join('\n'));
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Dokumente
  // ═══════════════════════════════════════════════════════════════════════

  Widget _documentsCard(FleetVehicle vehicle, Map<String, dynamic> extras) {
    final leasing = _str(extras['leasingProvider']);
    return _card(
      title: _tr('Dokumente', 'Documents'),
      trailing: widget.canManage
          ? _greenPill(
              icon: Icons.file_upload_outlined,
              label: _tr('Hochladen', 'Upload'),
              onTap: _busyUpload ? null : () => _pickUploadType(leasing),
            )
          : null,
      child: StreamBuilder<List<FleetVehicleDocument>>(
        stream: _documentService.watchDocuments(
          dspUid: widget.dspUid,
          plateNumber: _plate,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text(
              _tr(
                'Dokumente konnten nicht geladen werden.',
                'Could not load documents.',
              ),
              style: const TextStyle(fontSize: 12.5, color: _C.text2),
            );
          }
          final docs = snapshot.data ?? const <FleetVehicleDocument>[];
          final registration = _latestOfType(docs, 'FAHRZEUGSCHEIN');
          final lease = _latestOfType(docs, 'LEASE_CONTRACT');
          final others = docs
              .where(
                (d) =>
                    _canonicalType(d.documentType) != 'FAHRZEUGSCHEIN' &&
                    _canonicalType(d.documentType) != 'LEASE_CONTRACT' &&
                    d.fileUrl.trim().isNotEmpty,
              )
              .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _documentRow(
                label: 'Fahrzeugschein',
                document: registration,
                uploadType: 'FAHRZEUGSCHEIN',
              ),
              const SizedBox(height: 8),
              _documentRow(
                label: leasing.isEmpty
                    ? _tr('Leasingvertrag', 'Lease contract')
                    : '${_tr('Leasingvertrag', 'Lease contract')} ($leasing)',
                document: lease,
                uploadType: 'LEASE_CONTRACT',
              ),
              for (final doc in others) ...[
                const SizedBox(height: 8),
                _documentRow(
                  label: widget.actions.documentTypeLabel(doc.documentType),
                  document: doc,
                  uploadType: _canonicalType(doc.documentType),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _documentRow({
    required String label,
    required FleetVehicleDocument? document,
    required String uploadType,
  }) {
    final hasFile = (document?.fileUrl.trim() ?? '').isNotEmpty;
    if (!hasFile) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _C.dashed),
        ),
        child: Row(
          children: [
            Container(
              width: 21,
              height: 21,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE9EDF1),
              ),
              alignment: Alignment.center,
              child: const Text(
                '–',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _C.text3,
                  height: 1,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _C.text3,
                      height: 1.3,
                    ),
                  ),
                  Text(
                    _tr('noch nicht hochgeladen', 'not uploaded yet'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: _C.muted,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.canManage) ...[
              const SizedBox(width: 8),
              _Hoverable(
                onTap: _busyUpload ? null : () => _uploadDocument(uploadType),
                borderRadius: BorderRadius.circular(99),
                background: Colors.white,
                border: _C.greenBorder,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 11, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.file_upload_outlined,
                        size: 13,
                        color: _C.green,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Upload',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: _C.green,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    final doc = document!;
    final uploaded = doc.updatedAt ?? doc.createdAt;
    final meta = <String>[
      if (doc.fileName.trim().isNotEmpty) doc.fileName.trim(),
      if (uploaded != null)
        '${_tr('hochgeladen', 'uploaded')} ${_fmtDate(uploaded)}',
      if (doc.expiryDate.trim().isNotEmpty)
        '${_tr('gültig bis', 'valid until')} ${_fmtIsoDate(doc.expiryDate)}',
    ].join(' · ');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: _C.docBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _C.docBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 21,
            height: 21,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _C.green,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.check, size: 13, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _C.text,
                    height: 1.3,
                  ),
                ),
                if (meta.isNotEmpty)
                  Text(
                    meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: _C.text2,
                      height: 1.35,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          _IconAction(
            icon: Icons.visibility_outlined,
            size: 18,
            color: _C.text3,
            tooltip: _tr('Öffnen', 'Open'),
            onTap: () => _openUrl(doc.fileUrl),
          ),
          _IconAction(
            icon: Icons.download_outlined,
            size: 18,
            color: _C.text3,
            tooltip: _tr('Herunterladen', 'Download'),
            onTap: () => _openUrl(doc.fileUrl),
          ),
          if (widget.canManage) ...[
            _IconAction(
              icon: Icons.file_upload_outlined,
              size: 18,
              color: _C.text3,
              tooltip: _tr('Datei ersetzen', 'Replace file'),
              onTap: _busyUpload ? () {} : () => _uploadDocument(uploadType),
            ),
            _IconAction(
              icon: Icons.edit_outlined,
              size: 18,
              color: _C.text3,
              tooltip: _tr('Angaben bearbeiten', 'Edit details'),
              onTap: () => _editDocumentMeta(doc),
            ),
            _IconAction(
              icon: Icons.delete_outline,
              size: 18,
              color: _C.muted,
              tooltip: _tr('Dokument löschen', 'Delete document'),
              onTap: () => _deleteDocument(doc, label),
            ),
          ],
        ],
      ),
    );
  }

  /// Metadaten eines Dokuments bearbeiten (Dokumentnummer, Ablaufdatum,
  /// Notizen). Typ und Datei bleiben unverändert — der Dokumenttyp ist im
  /// Bestand bewusst unveränderlich (`ImmutableVehicleDocumentTypeException`).
  Future<void> _editDocumentMeta(FleetVehicleDocument document) async {
    final numberCtrl = TextEditingController(text: document.documentNumber);
    final notesCtrl = TextEditingController(text: document.notes);
    var expiry = document.expiryDate.trim();

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            '${_tr('Dokument', 'Document')} · '
            '${widget.actions.documentTypeLabel(document.documentType)}',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
          ),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: numberCtrl,
                    decoration: _dialogDecoration(
                      _tr('Dokumentnummer', 'Document number'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final parsed = DateTime.tryParse(expiry);
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: parsed ?? now,
                        firstDate: DateTime(now.year - 20),
                        lastDate: DateTime(now.year + 20),
                      );
                      if (picked == null) return;
                      setLocal(() {
                        expiry =
                            '${picked.year.toString().padLeft(4, '0')}-'
                            '${picked.month.toString().padLeft(2, '0')}-'
                            '${picked.day.toString().padLeft(2, '0')}';
                      });
                    },
                    icon: const Icon(Icons.event_outlined, size: 18),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _C.text,
                      side: const BorderSide(color: _C.border),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    label: Text(
                      '${_tr('Ablaufdatum', 'Expiry date')}: '
                      '${expiry.isEmpty ? _tr('keines', 'none') : _fmtIsoDate(expiry)}',
                    ),
                  ),
                  if (expiry.isNotEmpty)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => setLocal(() => expiry = ''),
                        child: Text(
                          _tr('Datum entfernen', 'Clear date'),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesCtrl,
                    maxLines: 3,
                    decoration: _dialogDecoration(
                      _tr('Notizen (optional)', 'Notes (optional)'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(_tr('Abbrechen', 'Cancel')),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: _C.green),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(_tr('Speichern', 'Save')),
            ),
          ],
        ),
      ),
    );

    final number = numberCtrl.text.trim();
    final notes = notesCtrl.text.trim();
    numberCtrl.dispose();
    notesCtrl.dispose();
    if (saved != true) return;

    try {
      await _documentService.updateDocument(
        dspUid: widget.dspUid,
        plateNumber: _plate,
        documentId: document.documentId,
        existingDocument: document,
        draft: FleetVehicleDocumentDraft(
          documentType: document.documentType,
          documentNumber: number,
          expiryDate: expiry,
          fileName: document.fileName,
          fileType: document.fileType,
          notes: notes,
        ),
      );
      _snack(_tr('Dokument aktualisiert.', 'Document updated.'));
    } catch (e) {
      _snack(_documentErrorText(e), error: true);
    }
  }

  /// Soft-Delete wie im Bestand (`isDeleted`) — die Datei im Storage bleibt
  /// erhalten, das Dokument verschwindet aus allen Listen.
  Future<void> _deleteDocument(
    FleetVehicleDocument document,
    String label,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(_tr('Dokument löschen?', 'Delete document?')),
        content: Text(
          _tr(
            '„$label" wird aus der Fahrzeugakte entfernt.',
            '"$label" will be removed from the vehicle record.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(_tr('Abbrechen', 'Cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _C.redValue),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(_tr('Löschen', 'Delete')),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _documentService.softDeleteDocument(
        dspUid: widget.dspUid,
        plateNumber: _plate,
        documentId: document.documentId,
      );
      _snack(_tr('Dokument gelöscht.', 'Document deleted.'));
    } catch (e) {
      _snack(_documentErrorText(e), error: true);
    }
  }

  InputDecoration _dialogDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: _C.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _C.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _C.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _C.green, width: 1.4),
      ),
    );
  }

  FleetVehicleDocument? _latestOfType(
    List<FleetVehicleDocument> docs,
    String canonicalType,
  ) {
    FleetVehicleDocument? best;
    for (final doc in docs) {
      if (doc.isDeleted) continue;
      if (_canonicalType(doc.documentType) != canonicalType) continue;
      if (best == null) {
        best = doc;
        continue;
      }
      final a = doc.updatedAt ?? doc.createdAt;
      final b = best.updatedAt ?? best.createdAt;
      if (a != null && (b == null || a.isAfter(b))) best = doc;
    }
    return best;
  }

  Future<void> _pickUploadType(String leasing) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Text(
              _tr('Dokument hochladen', 'Upload document'),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _C.text,
              ),
            ),
            const SizedBox(height: 8),
            for (final entry in <(String, String)>[
              ('FAHRZEUGSCHEIN', 'Fahrzeugschein'),
              (
                'LEASE_CONTRACT',
                leasing.isEmpty
                    ? _tr('Leasingvertrag', 'Lease contract')
                    : '${_tr('Leasingvertrag', 'Lease contract')} ($leasing)',
              ),
              (
                'HU_TUV_CERTIFICATE',
                _tr('TÜV-Bescheinigung', 'TÜV certificate'),
              ),
              (
                'INSURANCE_CERTIFICATE',
                _tr('Versicherungsnachweis', 'Insurance certificate'),
              ),
              ('SERVICE_REPORT', _tr('Servicebericht', 'Service report')),
            ])
              ListTile(
                leading: const Icon(
                  Icons.description_outlined,
                  color: _C.green,
                  size: 20,
                ),
                title: Text(
                  entry.$2,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () => Navigator.of(ctx).pop(entry.$1),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (selected == null) return;
    await _uploadDocument(selected);
  }

  /// Echter Upload nach Firebase Storage über den Bestands-Service
  /// (`vehicles/{dspUid}/{plate}/documents/…`). Existiert bereits ein
  /// Dokument dieses Typs, wird dessen Datei ersetzt.
  Future<void> _uploadDocument(String documentType) async {
    if (!widget.canManage || _busyUpload) return;

    final picked = await FilePicker.platform.pickFiles(withData: true);
    if (picked == null || picked.files.isEmpty) return;
    final file = picked.files.first;
    final bytes = file.bytes;
    if (bytes == null) {
      _snack(
        _tr('Datei konnte nicht gelesen werden.', 'Could not read the file.'),
        error: true,
      );
      return;
    }

    setState(() => _busyUpload = true);
    try {
      final docs = await _documentService
          .watchDocuments(dspUid: widget.dspUid, plateNumber: _plate)
          .first;
      final existing = _latestOfType(docs, _canonicalType(documentType));
      final draft = FleetVehicleDocumentDraft(
        documentType: existing?.documentType ?? documentType,
        documentNumber: existing?.documentNumber ?? '',
        expiryDate: existing?.expiryDate ?? '',
        fileName: file.name,
        fileType: _fileTypeOf(file.name),
        notes: existing?.notes ?? '',
      );

      if (existing == null) {
        await _documentService.createDocument(
          dspUid: widget.dspUid,
          plateNumber: _plate,
          draft: draft,
          fileBytes: bytes,
          originalFileName: file.name,
        );
      } else {
        await _documentService.updateDocument(
          dspUid: widget.dspUid,
          plateNumber: _plate,
          documentId: existing.documentId,
          existingDocument: existing,
          draft: draft,
          fileBytes: bytes,
          originalFileName: file.name,
        );
      }
      _snack(_tr('Dokument hochgeladen.', 'Document uploaded.'));
    } catch (e) {
      _snack(_documentErrorText(e), error: true);
    } finally {
      if (mounted) setState(() => _busyUpload = false);
    }
  }

  /// Übersetzt die typisierten Dokument-Fehler in verständliche Meldungen —
  /// ohne diese Zuordnung landete „Instance of '…Exception'" im Snackbar.
  String _documentErrorText(Object error) {
    if (error is DuplicateVehicleDocumentTypeException) {
      final type = widget.actions.documentTypeLabel(error.documentType);
      return _tr(
        'Für „$type" existiert bereits ein Dokument. '
            'Bitte das vorhandene ersetzen statt ein neues anzulegen.',
        'A document of type "$type" already exists. '
            'Please replace the existing one instead of adding another.',
      );
    }
    if (error is ImmutableVehicleDocumentTypeException) {
      final type = widget.actions.documentTypeLabel(error.documentType);
      return _tr(
        'Der Dokumenttyp „$type" kann nachträglich nicht geändert werden.',
        'The document type "$type" cannot be changed afterwards.',
      );
    }
    if (error is FleetVehicleDocumentException) {
      return error.message;
    }
    if (error is FirebaseException) {
      return error.code == 'permission-denied'
          ? _tr('Keine Berechtigung.', 'Permission denied.')
          : _tr(
              'Aktion fehlgeschlagen: ${error.message ?? error.code}',
              'Action failed: ${error.message ?? error.code}',
            );
    }
    return _tr('Aktion fehlgeschlagen: $error', 'Action failed: $error');
  }

  /// Sprung ins Incident-Center. Die Seite lebt sonst als Tab im Shell und
  /// bringt kein eigenes Scaffold mit — deshalb hier als Route mit Kopfzeile,
  /// inklusive [AdminScope], damit Dispatcher weiterhin im Namespace ihres
  /// Admins landen.
  Future<void> _openIncidentCenter() async {
    final de = _de;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AdminScope(
          adminUid: widget.dspUid,
          child: Scaffold(
            backgroundColor: _C.pageBg,
            appBar: AppBar(
              backgroundColor: Colors.white,
              foregroundColor: _C.text,
              elevation: 0,
              scrolledUnderElevation: 0.5,
              title: Text(
                de ? 'Vorfälle · $_plate' : 'Incidents · $_plate',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
            // Vorgefiltert auf dieses Fahrzeug — der Titel verspricht es,
            // also muss die Liste es auch halten.
            body: AdminIncidentReportsPage(initialPlate: _plate),
          ),
        ),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final trimmed = url.trim();
    final uri = trimmed.isEmpty ? null : Uri.tryParse(trimmed);
    if (uri == null) {
      _snack(
        _tr('Datei konnte nicht geöffnet werden.', 'Could not open the file.'),
        error: true,
      );
      return;
    }
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      _snack(
        _tr('Datei konnte nicht geöffnet werden.', 'Could not open the file.'),
        error: true,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Notizen & Bemerkungen
  // ═══════════════════════════════════════════════════════════════════════

  Widget _notesCard(FleetVehicle vehicle, Map<String, dynamic> extras) {
    final remarks = _str(extras['remarks']);
    final created = vehicle.createdAt;
    final updated = vehicle.updatedAt;
    return _card(
      title: _tr('Notizen & Bemerkungen', 'Notes & remarks'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _textRow(
            label: _tr('Notizen', 'Notes'),
            value: vehicle.notes,
            onEdit: widget.canManage
                ? () => widget.actions.editNotes(vehicle)
                : null,
            divider: true,
          ),
          _textRow(
            label: _tr('Bemerkungen', 'Remarks'),
            value: remarks,
            onEdit: widget.canManage
                ? () => widget.actions.editRemarks(vehicle, remarks)
                : null,
            divider: true,
          ),
          _textRow(
            label: _tr('Angelegt / Aktualisiert', 'Created / updated'),
            value: [
              created == null ? '—' : _fmtDate(created),
              updated == null ? '—' : _fmtDate(updated),
            ].join(' · '),
            divider: false,
          ),
        ],
      ),
    );
  }

  Widget _textRow({
    required String label,
    required String value,
    required bool divider,
    VoidCallback? onEdit,
  }) {
    final display = value.trim();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: divider
            ? const Border(bottom: BorderSide(color: _C.rowLine))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                color: _C.text2,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              display.isEmpty ? _tr('— keine', '— none') : display,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: display.isEmpty ? _C.muted : _C.text,
                height: 1.35,
              ),
            ),
          ),
          if (onEdit != null) ...[
            const SizedBox(width: 4),
            _IconAction(
              icon: Icons.edit_outlined,
              size: 15,
              color: _C.muted,
              tooltip: _tr('Bearbeiten', 'Edit'),
              onTap: onEdit,
            ),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Events-Spalte
  // ═══════════════════════════════════════════════════════════════════════

  Widget _eventsPanel(FleetVehicle vehicle, {required bool scrollable}) {
    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        border: Border.all(color: _C.border),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _eventsRef
            .where('plateKey', isEqualTo: plateKeyOf(_plate))
            .snapshots(),
        builder: (context, ownSnap) {
          return StreamBuilder<List<FleetVehicleEvent>>(
            stream: _legacyEventService.watchEvents(
              dspUid: widget.dspUid,
              plateNumber: _plate,
            ),
            builder: (context, legacySnap) {
              final events =
                  <_FleetEvent>[
                    ...?ownSnap.data?.docs.map(_FleetEvent.fromDoc),
                    ...?legacySnap.data
                        ?.where((e) => !e.isDeleted)
                        .map(_FleetEvent.fromLegacy),
                  ]..sort((a, b) {
                    final ad = a.date;
                    final bd = b.date;
                    if (ad == null && bd == null) return 0;
                    if (ad == null) return 1;
                    if (bd == null) return -1;
                    return bd.compareTo(ad);
                  });

              final visible = _eventFilter == null
                  ? events
                  : events.where((e) => e.type == _eventFilter).toList();

              final list = visible.isEmpty
                  ? [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        alignment: Alignment.center,
                        child: Text(
                          _tr('Noch keine Events.', 'No events yet.'),
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: _C.text3,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ]
                  : [
                      for (var i = 0; i < visible.length; i++) ...[
                        if (i > 0) const SizedBox(height: 6),
                        _eventTile(visible[i]),
                      ],
                    ];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: scrollable ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  _cardHeader(
                    title: 'Events',
                    trailing: widget.canManage
                        ? _greenPill(
                            icon: Icons.add,
                            label: 'Event',
                            onTap: () => _addEvent(vehicle),
                          )
                        : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _maintenanceTile(events),
                        _lastCheckSection(events),
                        const SizedBox(height: 10),
                        _eventFilterPill(),
                      ],
                    ),
                  ),
                  if (scrollable)
                    Expanded(
                      child: ListView(
                        controller: _eventScroll,
                        padding: const EdgeInsets.fromLTRB(16, 10, 13, 16),
                        children: list,
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: list,
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  /// Fixierte Kachel „Wartung & Verschleiß · letzte Wechsel": jeweils das
  /// jüngste Event je Typ (Reifen / Bremsen / Öl).
  Widget _maintenanceTile(List<_FleetEvent> events) {
    _FleetEvent? latest(FleetEventType type) {
      for (final event in events) {
        if (event.type == type) return event;
      }
      return null;
    }

    Widget row(FleetEventType type, String label) {
      final event = latest(type);
      final parts = <String>[
        if (event?.date != null) _fmtDate(event!.date),
        if (event?.km != null) '${_fmtKm(event!.km!)} km',
      ];
      return Padding(
        padding: const EdgeInsets.only(top: 7),
        child: Row(
          children: [
            Icon(type.icon, size: 16, color: _C.green),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _C.text,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              parts.isEmpty ? '—' : parts.join(' · '),
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: parts.isEmpty ? _C.muted : _C.text2,
                height: 1.3,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.rowLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _tr(
              'Wartung & Verschleiß · letzte Wechsel',
              'Maintenance & wear · last changes',
            ).toUpperCase(),
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: _C.text3,
              height: 1.3,
            ),
          ),
          row(FleetEventType.tires, _tr('Reifen', 'Tires')),
          row(FleetEventType.brakes, _tr('Bremsen', 'Brakes')),
          row(FleetEventType.oil, _tr('Öl', 'Oil')),
        ],
      ),
    );
  }

  /// Fallback-Suche nach dem letzten Check, solange die Spiegel-Function
  /// noch keine `fleet_events` geschrieben hat.
  ///
  /// Der Fahrer legt beim Speichern zusätzlich `lastVehicleCheck` auf
  /// seinem eigenen Driver-Doc ab (das darf er laut Rules) — eine reine
  /// Gleichheitsabfrage auf ein Map-Feld, die Firestore ohne
  /// Composite-Index bedient.
  Future<_FleetEvent?> _lastCheckFallback() {
    final key = '${widget.dspUid}|$_plate';
    if (key != _lastCheckKey || _lastCheckFuture == null) {
      _lastCheckKey = key;
      _lastCheckFuture = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.dspUid)
          .collection('drivers')
          .where('lastVehicleCheck.plateKey', isEqualTo: plateKeyOf(_plate))
          .get()
          .then<_FleetEvent?>((snap) {
            _FleetEvent? best;
            for (final doc in snap.docs) {
              final raw = doc.data()['lastVehicleCheck'];
              if (raw is! Map) continue;
              final km = raw['odometerKm'];
              final candidate = _FleetEvent(
                id: '${raw['checkId'] ?? doc.id}',
                type: FleetEventType.vehicleCheck,
                title: 'Fahrzeug-Check',
                subtitle: <String>[
                  '${raw['photoCount'] ?? 0} '
                      '${_tr('Fotos', 'photos')}',
                  '${raw['damageCount'] ?? 0} '
                      '${_tr('Schäden', 'damages')}',
                  if (km is num) 'KM ${_fmtKm(km.toInt())}',
                  if ('${raw['driverName'] ?? ''}'.trim().isNotEmpty)
                    '${raw['driverName']}',
                ].join(' · '),
                date: _FleetEvent._dateFrom(raw['at']),
                km: km is num ? km.toInt() : null,
                legacy: false,
                checkPath: '${raw['path'] ?? ''}'.trim(),
              );
              final bestDate = best?.date;
              final candidateDate = candidate.date;
              if (best == null ||
                  (candidateDate != null &&
                      (bestDate == null || candidateDate.isAfter(bestDate)))) {
                best = candidate;
              }
            }
            return best;
          })
          .catchError((_) => null);
    }
    return _lastCheckFuture!;
  }

  /// Kachel „Letzter Fahrzeug-Check" — der jüngste Check aus der Fahrer-App.
  /// Primärquelle ist der Fleet-Event-Spiegel; ohne deployte Function
  /// greift [_lastCheckFallback].
  Widget _lastCheckSection(List<_FleetEvent> events) {
    for (final event in events) {
      if (event.type == FleetEventType.vehicleCheck) {
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: _lastCheckTile(event),
        );
      }
    }
    return FutureBuilder<_FleetEvent?>(
      future: _lastCheckFallback(),
      builder: (context, snap) {
        final event = snap.data;
        if (event == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: _lastCheckTile(event),
        );
      },
    );
  }

  Widget _lastCheckTile(_FleetEvent event) {
    final meta = <String>[
      if (event.date != null) _fmtDate(event.date),
      if (event.km != null) '${_fmtKm(event.km!)} km',
    ].join(' · ');

    final tile = Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.rowLine),
      ),
      child: Row(
        children: [
          const Icon(Icons.fact_check_outlined, size: 18, color: _C.green),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _tr('LETZTER FAHRZEUG-CHECK', 'LAST VEHICLE CHECK'),
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: _C.text3,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  event.subtitle.isEmpty ? meta : event.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _C.text,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            meta.isEmpty ? '—' : _fmtDate(event.date),
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: _C.text2,
            ),
          ),
          if (event.checkPath.isNotEmpty)
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(Icons.chevron_right, size: 17, color: _C.muted),
            ),
        ],
      ),
    );

    if (event.checkPath.isEmpty) return tile;
    return _Hoverable(
      onTap: () => _openVehicleCheck(event.checkPath),
      tooltip: _tr('Check öffnen', 'Open check'),
      borderRadius: BorderRadius.circular(12),
      child: tile,
    );
  }

  Future<void> _openVehicleCheck(String checkPath) =>
      openAdminVehicleCheckDetail(
        context,
        dspUid: widget.dspUid,
        checkPath: checkPath,
        canManage: widget.canManage,
      );

  Widget _eventFilterPill() {
    final label = _eventFilter == null
        ? _tr('Alle Event-Typen', 'All event types')
        : _eventFilter!.label(_de);
    return PopupMenuButton<String>(
      tooltip: _tr('Nach Typ filtern', 'Filter by type'),
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) => setState(
        () => _eventFilter = value == '__all__'
            ? null
            : FleetEventType.values.firstWhere((t) => t.wire == value),
      ),
      itemBuilder: (ctx) => [
        PopupMenuItem<String>(
          value: '__all__',
          child: Text(_tr('Alle Event-Typen', 'All event types')),
        ),
        for (final type in FleetEventType.values)
          PopupMenuItem<String>(
            value: type.wire,
            child: Row(
              children: [
                Icon(type.icon, size: 16, color: type.color),
                const SizedBox(width: 8),
                Text(type.label(_de)),
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: _C.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _C.text2,
                  height: 1.35,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, size: 14, color: _C.text2),
          ],
        ),
      ),
    );
  }

  /// Untertitel-Zeile eines Events: Notiz, Kilometerstand und — bei Unfällen —
  /// Schadensgrad und Ort, damit die Kachel nicht metadatenlos wirkt.
  String _eventSubtitle(_FleetEvent event) {
    final parts = <String>[
      if (event.subtitle.trim().isNotEmpty) event.subtitle.trim(),
      if (event.km != null) '${_fmtKm(event.km!)} km',
    ];
    final damage = event.accident['damageLevel'] ?? '';
    if (damage.isNotEmpty) {
      parts.insert(0, fleetDamageLevelLabel(damage, _de));
    }
    final location = event.accident['location'] ?? '';
    if (location.isNotEmpty) parts.add(location);
    return parts.join(' · ');
  }

  Widget _eventTile(_FleetEvent event) {
    final sub = _eventSubtitle(event);
    final hasFile = event.fileUrl.trim().isNotEmpty;

    final tile = Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _C.rowLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(event.type.icon, size: 19, color: event.type.color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  event.title.isEmpty ? event.type.label(_de) : event.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: _C.text,
                    height: 1.3,
                  ),
                ),
              ),
              if (hasFile)
                _IconAction(
                  icon: Icons.attach_file,
                  size: 15,
                  color: _C.text3,
                  tooltip: event.fileName.isEmpty
                      ? _tr('Datei öffnen', 'Open file')
                      : '${_tr('Datei öffnen', 'Open file')} — ${event.fileName}',
                  onTap: () => _openUrl(event.fileUrl),
                ),
              if (widget.canManage && !event.legacy)
                _IconAction(
                  icon: Icons.delete_outline,
                  size: 15,
                  color: _C.muted,
                  tooltip: _tr('Event löschen', 'Delete event'),
                  onTap: () => _deleteEvent(event),
                ),
            ],
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 27),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    sub,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: _C.text3,
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _fmtDate(event.date),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _C.text2,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (!event.hasDetails) return tile;
    return _Hoverable(
      onTap: () => _showEventDetails(event),
      tooltip: _tr('Details anzeigen', 'Show details'),
      borderRadius: BorderRadius.circular(10),
      child: tile,
    );
  }

  /// Volle Event-Ansicht — zeigt vor allem die Unfall-Zusatzfelder, die in
  /// der Kachel keinen Platz haben (auch für Bestands-ACCIDENT-Events).
  Future<void> _showEventDetails(_FleetEvent event) async {
    // Fahrzeug-Checks haben eine eigene Vollansicht (Fotogalerie,
    // NEU-Badges, KI-Befunde) — der generische Event-Dialog kann das nicht.
    if (event.checkPath.isNotEmpty) {
      await _openVehicleCheck(event.checkPath);
      return;
    }
    final hasFile = event.fileUrl.trim().isNotEmpty;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Icon(event.type.icon, size: 20, color: event.type.color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                event.title.isEmpty ? event.type.label(_de) : event.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _detailLine(_tr('Typ', 'Type'), event.type.label(_de)),
                _detailLine(_tr('Datum', 'Date'), _fmtDate(event.date)),
                if (event.km != null)
                  _detailLine(
                    _tr('Kilometerstand', 'Mileage'),
                    '${_fmtKm(event.km!)} km',
                  ),
                for (final field in kFleetAccidentFields)
                  if ((event.accident[field] ?? '').isNotEmpty)
                    _detailLine(
                      fleetAccidentFieldLabel(field, _de),
                      field == 'damageLevel'
                          ? fleetDamageLevelLabel(event.accident[field]!, _de)
                          : event.accident[field]!,
                    ),
                if (event.subtitle.trim().isNotEmpty)
                  _detailLine(_tr('Notiz', 'Note'), event.subtitle.trim()),
                if (hasFile) ...[
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _openUrl(event.fileUrl);
                      },
                      icon: const Icon(Icons.open_in_new, size: 16),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _C.green,
                        side: const BorderSide(color: _C.greenBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      label: Text(
                        event.fileName.isEmpty
                            ? _tr('Datei öffnen', 'Open file')
                            : event.fileName,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(_tr('Schließen', 'Close')),
          ),
        ],
      ),
    );
  }

  Widget _detailLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                color: _C.text2,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value.trim().isEmpty ? '—' : value.trim(),
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _C.text,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addEvent(FleetVehicle vehicle) async {
    final result = await showDialog<_FleetEventDraft>(
      context: context,
      builder: (_) => _FleetEventDialog(de: _de),
    );
    if (result == null) return;
    try {
      await _eventsRef.add(<String, dynamic>{
        'plateKey': plateKeyOf(vehicle.plateNumber),
        'plate': vehicle.plateNumber,
        'type': result.type.wire,
        'title': result.title,
        'subtitle': result.subtitle,
        'date': Timestamp.fromDate(result.date),
        'km': result.km,
        // Unfall-Zusatzfelder liegen top-level und heißen exakt wie die
        // `metadata`-Schlüssel der Bestands-ACCIDENT-Events (siehe
        // [kFleetAccidentFields]) — dieselben Namen beim Lesen.
        ...result.accident,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': FirebaseAuth.instance.currentUser?.uid ?? '',
      });
      _snack(_tr('Event gespeichert.', 'Event saved.'));
    } catch (e) {
      _snack(
        _tr('Speichern fehlgeschlagen: $e', 'Could not save: $e'),
        error: true,
      );
    }
  }

  Future<void> _deleteEvent(_FleetEvent event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(_tr('Event löschen?', 'Delete event?')),
        content: Text(
          _tr(
            'Der Eintrag wird dauerhaft entfernt.',
            'The entry will be removed permanently.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(_tr('Abbrechen', 'Cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _C.redValue),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(_tr('Löschen', 'Delete')),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _eventsRef.doc(event.id).delete();
    } catch (e) {
      _snack(
        _tr('Löschen fehlgeschlagen: $e', 'Could not delete: $e'),
        error: true,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Extras-Editoren (neue Felder — Bestand kennt sie noch nicht)
  // ═══════════════════════════════════════════════════════════════════════

  Future<void> _saveExtras(
    Map<String, dynamic> data,
    String successText,
  ) async {
    try {
      await widget.actions.saveExtras(_plate, data);
      _snack(successText);
    } catch (e) {
      _snack(
        _tr('Speichern fehlgeschlagen: $e', 'Could not save: $e'),
        error: true,
      );
    }
  }

  Future<void> _pickLeasingProvider(String current) async {
    final options = <String>{
      ...kFleetLeasingProviders,
      if (current.isNotEmpty) current,
    }.toList()..sort();

    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Text(
                _tr('Leasinggeber', 'Lessor'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _C.text,
                ),
              ),
              const SizedBox(height: 8),
              for (final option in options)
                ListTile(
                  leading: Icon(
                    option == current
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    size: 20,
                    color: option == current ? _C.green : _C.muted,
                  ),
                  title: Text(
                    option,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () => Navigator.of(ctx).pop(option),
                ),
              ListTile(
                leading: const Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: _C.text3,
                ),
                title: Text(_tr('Anderer Anbieter …', 'Other provider …')),
                onTap: () => Navigator.of(ctx).pop('__custom__'),
              ),
              ListTile(
                leading: const Icon(Icons.close, size: 20, color: _C.text3),
                title: Text(_tr('Kein Leasinggeber', 'No lessor')),
                onTap: () => Navigator.of(ctx).pop(''),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
    if (selected == null) return;
    if (selected == '__custom__') {
      await _editExtraText(
        field: 'leasingProvider',
        title: _tr('Leasinggeber', 'Lessor'),
        hint: 'Ayvens',
        current: current,
      );
      return;
    }
    await _saveExtras(<String, dynamic>{
      'leasingProvider': selected,
    }, _tr('Leasinggeber gespeichert.', 'Lessor saved.'));
  }

  Future<void> _editExtraText({
    required String field,
    required String title,
    required String hint,
    required String current,
  }) async {
    final controller = TextEditingController(text: current);
    final value = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        content: SizedBox(
          width: 400,
          child: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: _C.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _C.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _C.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _C.green, width: 1.4),
              ),
            ),
            onSubmitted: (text) => Navigator.of(ctx).pop(text),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(_tr('Abbrechen', 'Cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _C.green),
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: Text(_tr('Speichern', 'Save')),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value == null) return;
    await _saveExtras(<String, dynamic>{
      field: value.trim(),
    }, _tr('Gespeichert.', 'Saved.'));
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Karten-Bausteine
  // ═══════════════════════════════════════════════════════════════════════

  Widget _card({
    required String title,
    Widget? trailing,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        border: Border.all(color: _C.border),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _cardHeader(title: title, trailing: trailing),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _cardHeader({required String title, Widget? trailing}) {
    return Container(
      decoration: const BoxDecoration(
        color: _C.surface,
        border: Border(bottom: BorderSide(color: _C.rowLine)),
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        trailing == null ? 12 : 9,
        16,
        trailing == null ? 12 : 9,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: _C.green,
                height: 1.3,
              ),
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 10), trailing],
        ],
      ),
    );
  }

  Widget _greenPill({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return _Hoverable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      background: onTap == null ? _C.muted : _C.green,
      hoverColor: _C.greenHover,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _Tone { neutral, empty, green, amber, red }

// ---------------------------------------------------------------------------
// Kleine Bausteine
// ---------------------------------------------------------------------------

/// Zweispaltiges Raster mit 8 px Abstand; unter 420 px einspaltig.
class _Grid2 extends StatelessWidget {
  const _Grid2({required this.children, this.forceTwoColumns = false});

  final List<Widget> children;

  /// Hält das Raster auch unter 420px zweispaltig — genutzt für die
  /// Status-Kacheln, die mobil bewusst als kompaktes 2×2 stehen bleiben.
  final bool forceTwoColumns;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!forceTwoColumns && constraints.maxWidth < 420) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                children[i],
              ],
            ],
          );
        }
        final rows = <List<Widget?>>[];
        for (var i = 0; i < children.length; i += 2) {
          rows.add([
            children[i],
            i + 1 < children.length ? children[i + 1] : null,
          ]);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var r = 0; r < rows.length; r++) ...[
              if (r > 0) const SizedBox(height: 8),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: rows[r][0]!),
                    const SizedBox(width: 8),
                    Expanded(child: rows[r][1] ?? const SizedBox.shrink()),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Icon-Button mit mindestens 24 px Trefferfläche.
class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.size,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final double size;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hit = size < 24 ? 28.0 : size + 12;
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 400),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: hit,
            height: hit,
            child: Icon(icon, size: size, color: color),
          ),
        ),
      ),
    );
  }
}

/// Quadratischer Icon-Button der Mobile-Kopfzeile: 44×44, Radius 10, weiße
/// Fläche mit Handoff-Border.
class _SquareIconButton extends StatelessWidget {
  const _SquareIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 500),
      child: Material(
        color: _C.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: _C.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(icon, size: 19, color: _C.text2),
          ),
        ),
      ),
    );
  }
}

/// Klickbare Fläche mit dezenter Hover-Abdunklung (Handoff-Verhalten).
class _Hoverable extends StatelessWidget {
  const _Hoverable({
    required this.child,
    required this.onTap,
    this.tooltip,
    this.borderRadius,
    this.background,
    this.border,
    this.hoverColor,
  });

  final Widget child;
  final VoidCallback? onTap;
  final String? tooltip;
  final BorderRadius? borderRadius;
  final Color? background;
  final Color? border;
  final Color? hoverColor;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(99);
    Widget content = Material(
      color: background ?? Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: border == null ? BorderSide.none : BorderSide(color: border!),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        hoverColor: hoverColor ?? const Color(0x0F000000),
        child: child,
      ),
    );
    if (tooltip == null || tooltip!.isEmpty) return content;
    return Tooltip(
      message: tooltip!,
      waitDuration: const Duration(milliseconds: 500),
      child: content,
    );
  }
}

// ---------------------------------------------------------------------------
// „+ Event"-Dialog
// ---------------------------------------------------------------------------

class _FleetEventDraft {
  const _FleetEventDraft({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.km,
    this.accident = const <String, String>{},
  });

  final FleetEventType type;
  final String title;
  final String subtitle;
  final DateTime date;
  final int? km;

  /// Nur bei [FleetEventType.accident] befüllt — Schlüssel aus
  /// [kFleetAccidentFields].
  final Map<String, String> accident;
}

class _FleetEventDialog extends StatefulWidget {
  const _FleetEventDialog({required this.de});

  final bool de;

  @override
  State<_FleetEventDialog> createState() => _FleetEventDialogState();
}

class _FleetEventDialogState extends State<_FleetEventDialog> {
  FleetEventType _type = FleetEventType.oil;
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _kmCtrl = TextEditingController();
  final TextEditingController _noteCtrl = TextEditingController();
  // Unfall-Zusatzfelder (nur sichtbar bei Typ „Unfall").
  final TextEditingController _locationCtrl = TextEditingController();
  final TextEditingController _policeCtrl = TextEditingController();
  final TextEditingController _insuranceCtrl = TextEditingController();
  String _damageLevel = fleetVehicleAccidentDamageLevelOptions.first;
  DateTime _date = DateTime.now();
  String? _error;

  bool get _isAccident => _type == FleetEventType.accident;

  String _tr(String de, String en) => widget.de ? de : en;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _kmCtrl.dispose();
    _noteCtrl.dispose();
    _locationCtrl.dispose();
    _policeCtrl.dispose();
    _insuranceCtrl.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: _C.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _C.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _C.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _C.green, width: 1.4),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(DateTime.now().year + 10),
    );
    if (picked == null) return;
    setState(() => _date = picked);
  }

  void _submit() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      setState(
        () => _error = _tr(
          'Bitte einen Titel eingeben.',
          'Please enter a title.',
        ),
      );
      return;
    }
    final kmRaw = _kmCtrl.text.trim().replaceAll(RegExp(r'[.\s]'), '');
    int? km;
    if (kmRaw.isNotEmpty) {
      km = int.tryParse(kmRaw);
      if (km == null || km < 0) {
        setState(
          () => _error = _tr(
            'Bitte einen gültigen Kilometerstand eingeben.',
            'Please enter a valid mileage.',
          ),
        );
        return;
      }
    }
    final accident = <String, String>{};
    if (_isAccident) {
      accident['damageLevel'] = _damageLevel;
      final location = _locationCtrl.text.trim();
      final police = _policeCtrl.text.trim();
      final insurance = _insuranceCtrl.text.trim();
      if (location.isNotEmpty) accident['location'] = location;
      if (police.isNotEmpty) accident['policeReportNumber'] = police;
      if (insurance.isNotEmpty) accident['insuranceClaimNumber'] = insurance;
    }

    Navigator.of(context).pop(
      _FleetEventDraft(
        type: _type,
        title: title,
        subtitle: _noteCtrl.text.trim(),
        date: DateTime(_date.year, _date.month, _date.day),
        km: km,
        accident: accident,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}';
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(
        _tr('Event erfassen', 'Add event'),
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<FleetEventType>(
                initialValue: _type,
                decoration: _decoration(_tr('Typ', 'Type')),
                items: [
                  for (final type in FleetEventType.values)
                    DropdownMenuItem<FleetEventType>(
                      value: type,
                      child: Row(
                        children: [
                          Icon(type.icon, size: 17, color: type.color),
                          const SizedBox(width: 8),
                          Text(type.label(widget.de)),
                        ],
                      ),
                    ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _type = value;
                    if (_titleCtrl.text.trim().isEmpty) {
                      _titleCtrl.text = value.label(widget.de);
                    }
                  });
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _titleCtrl,
                decoration: _decoration(_tr('Titel', 'Title')),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.event_outlined, size: 18),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _C.text,
                        side: const BorderSide(color: _C.border),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      label: Text('${_tr('Datum', 'Date')}: $dateLabel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _kmCtrl,
                      keyboardType: TextInputType.number,
                      decoration: _decoration(
                        _tr('km (optional)', 'km (optional)'),
                        hint: '92400',
                      ),
                    ),
                  ),
                ],
              ),
              // Unfall-Zusatzfelder — dieselben vier Angaben wie im alten
              // ACCIDENT-Event, damit nichts verloren geht.
              if (_isAccident) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _damageLevel,
                  decoration: _decoration(_tr('Schadensgrad', 'Damage level')),
                  items: [
                    for (final level in fleetVehicleAccidentDamageLevelOptions)
                      DropdownMenuItem<String>(
                        value: level,
                        child: Text(fleetDamageLevelLabel(level, widget.de)),
                      ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _damageLevel = value);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _locationCtrl,
                  decoration: _decoration(
                    _tr('Ort (optional)', 'Location (optional)'),
                    hint: _tr('A3, Ausfahrt Erlangen', 'A3, exit Erlangen'),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _policeCtrl,
                  decoration: _decoration(
                    _tr(
                      'Polizei-Aktenzeichen (optional)',
                      'Police report no. (optional)',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _insuranceCtrl,
                  decoration: _decoration(
                    _tr(
                      'Versicherungs-Schadennummer (optional)',
                      'Insurance claim no. (optional)',
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              TextField(
                controller: _noteCtrl,
                maxLines: 2,
                decoration: _decoration(
                  _tr('Notiz (optional)', 'Note (optional)'),
                  hint: _tr('Werkstatt Erlangen', 'Workshop Erlangen'),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: _C.redValue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(_tr('Abbrechen', 'Cancel')),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: _C.green),
          onPressed: _submit,
          child: Text(_tr('Speichern', 'Save')),
        ),
      ],
    );
  }
}
