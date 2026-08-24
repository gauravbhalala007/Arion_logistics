import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as fb_storage;
import '../widgets/admin_scope.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../localization/app_localizations.dart';
import '../models/fleet_vehicle.dart';
import '../models/fleet_vehicle_document.dart';
import '../services/fleet_vehicle_document_service.dart';
import '../services/fleet_vehicle_repository.dart';
import '../services/cortex_vehicle_importer.dart';
import '../services/incident_reports.dart' show plateKeyOf;
import '../theme/app_colors.dart';
import '../widgets/clearable_search_field.dart';
import '../widgets/co_button.dart';
import '../widgets/license_plate.dart';
import '../widgets/mobile_filter_controls.dart';
import '../widgets/co_pressable.dart';
import 'fleet_vehicle_detail_page.dart';

class FleetStatusPage extends StatefulWidget {
  const FleetStatusPage({super.key});

  @override
  State<FleetStatusPage> createState() => _FleetStatusPageState();
}

class _FleetStatusPageState extends State<FleetStatusPage> {
  static const Color _kGreen = Color(0xFF1D7F5A);
  static const Color _kRed = Color(0xFFB91C1C);
  static const Color _kOrange = Color(0xFFD97706);
  static const Color _kText = Color(0xFF111827);
  static const Color _kMuted = Color(0xFF6B7280);
  static const Color _kBorder = Color(0xFFE5E7EB);
  static const Color _kPageBg = Color(0xFFF3F6F7);

  // ── Handoff-Tokens (design_handoff_fleet_hub) ────────────────────────────
  static const Color _kInk = Color(0xFF1A212B);
  static const Color _kSubtle = Color(0xFF5B6572);
  static const Color _kFaint = Color(0xFF8A93A0);
  static const Color _kLine = Color(0xFFE5E9EE);
  static const Color _kRowLine = Color(0xFFEEF1F4);
  static const Color _kAccentGreen = Color(0xFF0D8A60);
  static const Color _kAccentGreenTint = Color(0xFFE7F6EF);
  static const Color _kAccentRed = Color(0xFFB32F2F);
  static const Color _kAccentRedTint = Color(0xFFFDF0F0);
  static const Color _kAccentAmber = Color(0xFFB0731C);
  static const Color _kAccentAmberTint = Color(0xFFFDF6EC);
  static const Color _kAccentBlue = Color(0xFF2A5FA8);
  static const Color _kAccentBlueTint = Color(0xFFE9F0FA);
  static const Color _kAccentViolet = Color(0xFF7A4BB0);
  static const Color _kAccentOrange = Color(0xFFB45309);
  static const Color _kAccentOrangeTint = Color(0xFFFEF3C7);
  static const Color _kAccentVioletTint = Color(0xFFF3ECFA);

  static const String _tuvAllValue = '__all_tuv__';

  final FleetVehicleRepository _repository = FleetVehicleRepository();
  final FleetVehicleDocumentService _documentService =
      FleetVehicleDocumentService();
  final TextEditingController _searchCtrl = TextEditingController();
  // Horizontal scroller for the references chips row — a named controller
  // so a visible/draggable Scrollbar and a mouse-wheel handler can both
  // target it (plain SingleChildScrollView isn't mouse-draggable on
  // Flutter web desktop by default).
  final ScrollController _referencesScrollCtrl = ScrollController();

  String? get _uid {
    final scoped = AdminScope.maybeOf(context)?.adminUid;
    if (scoped != null && scoped.isNotEmpty) return scoped;
    return FirebaseAuth.instance.currentUser?.uid;
  }

  String? _resolvedDspUid;
  String _role = '';
  bool _isApproved = false;
  bool _loadingScope = true;
  bool _busyCortex = false;
  String _search = '';
  // Status filter pill: ALL | OPERATIV | GROUNDED | INAKTIV. GROUNDED
  // bundles all grounded reasons; the exact reason stays visible on
  // each vehicle row.
  String _statusPill = 'ALL';
  // Category filter driven by the hero counter tiles:
  // ALL | ARMADA | SESO | LMR | SELF_OWNED.
  String _categoryFilter = 'ALL';
  String _tuvFilter = _tuvAllValue;
  // Column sorting: null = default order (createdAt). Keys:
  // vehicle | model | status | serviceEnd | tuv.
  String? _sortColumn;
  bool _sortAsc = true;
  final Set<String> _updatingVehicleStatuses = <String>{};

  // Latest per-plate side data, refreshed on every stream build. Used to
  // seed dialogs (edit vehicle) and render workshop / TÜV info.
  Map<String, String> _workshopByPlate = <String, String>{};
  // Free-text "Bemerkungen / Remarks" per vehicle — same admin subtree as
  // the workshop field (fleet_vehicle_extras), not the vehicle doc itself.
  Map<String, String> _remarksByPlate = <String, String>{};
  // Leasing provider per plate (fleet_vehicle_extras.leasingProvider) — shown
  // as the handshake line inside each fleet row.
  Map<String, String> _leasingByPlate = <String, String>{};
  Map<String, FleetVehicleDocument> _tuvDocByPlate =
      <String, FleetVehicleDocument>{};
  // Plates with an uploaded vehicle registration ("Fahrzeugschein") — drives
  // the green/red chip in the fleet rows.
  Set<String> _registrationPlates = <String>{};
  // Solange der Dokumente-Stream noch keinen ersten Snapshot geliefert hat,
  // zeigen die TÜV-/Fahrzeugschein-Chips „…" statt fälschlich „fehlt" —
  // sonst sieht der erste Seitenaufbau kurz wie Datenverlust aus.
  bool _scopeDocsLoaded = false;

  /// Plate of the vehicle whose detail page is currently shown *inside* the
  /// shell content (no Navigator.push, so the side menu stays visible).
  /// `null` = the fleet list is visible.
  String? _detailPlate;

  @override
  void initState() {
    super.initState();
    _resolveScope();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _referencesScrollCtrl.dispose();
    super.dispose();
  }

  String? get _scopeUid {
    final uid = _uid;
    if (uid == null) return null;
    final dspUid = (_resolvedDspUid ?? '').trim();
    return dspUid.isEmpty ? uid : dspUid;
  }

  bool get _canViewVehicles =>
      _isApproved &&
      (_role == 'admin' || _role == 'user' || _role == 'developer');

  bool get _canManageVehicles => _canViewVehicles;

  Future<void> _resolveScope() async {
    final uid = _uid;
    if (uid == null) {
      if (!mounted) return;
      setState(() => _loadingScope = false);
      return;
    }

    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final data = snap.data() ?? const <String, dynamic>{};
      final dspUidRaw = (data['dspUid'] ?? '').toString().trim();
      final role = (data['role'] ?? '').toString().trim().toLowerCase();
      final approved = data['approved'] == true;

      if (!mounted) return;
      setState(() {
        _resolvedDspUid = dspUidRaw.isEmpty ? uid : dspUidRaw;
        _role = role;
        _isApproved = approved;
        _loadingScope = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _resolvedDspUid = uid;
        _loadingScope = false;
      });
    }
  }

  // ─── Per-vehicle extras (workshop) — admin subtree, no rules change ───
  //
  // The vehicle documents themselves have a strict field whitelist in the
  // Firestore rules, so the workshop of a "Grounded (Service)" vehicle is
  // stored in a sibling subcollection under the admin's own user doc
  // (users/{dspUid}/fleet_vehicle_extras/{plate}) — same pattern as the
  // maintenance section, which also works without a rules deploy.

  CollectionReference<Map<String, dynamic>> _extrasCollection(String scope) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(scope)
        .collection('fleet_vehicle_extras');
  }

  CollectionReference<Map<String, dynamic>> _referencesCollection(
    String scope,
  ) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(scope)
        .collection('fleet_references');
  }

  Future<void> _saveVehicleWorkshop(
    String scope,
    String plateNumber,
    String workshop,
  ) async {
    await _extrasCollection(
      scope,
    ).doc(normalizePlateNumber(plateNumber)).set(<String, dynamic>{
      'plateNumber': normalizePlateNumber(plateNumber),
      'workshop': workshop.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Free-text remarks for a vehicle, stored the same way as the workshop
  /// field (users/{dspUid}/fleet_vehicle_extras/{plate}) because the
  /// Firestore rules only allow a fixed field whitelist on the vehicle
  /// document itself.
  Future<void> _saveVehicleRemarks(
    String scope,
    String plateNumber,
    String remarks,
  ) async {
    await _extrasCollection(
      scope,
    ).doc(normalizePlateNumber(plateNumber)).set(<String, dynamic>{
      'plateNumber': normalizePlateNumber(plateNumber),
      'remarks': remarks.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Reads the current HU/TÜV certificate of a plate **straight from
  /// Firestore** instead of the list cache.
  ///
  /// [_tuvDocByPlate] is only filled while the fleet list's document stream
  /// runs — on the embedded detail page it doesn't, so a cache lookup came
  /// back empty and every save created *another* HU_TUV_CERTIFICATE document.
  Future<FleetVehicleDocument?> _loadTuvDocument(
    String scope,
    String normalizedPlate,
  ) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(scope)
        .collection('vehicles')
        .doc(normalizedPlate)
        .collection('documents')
        .where('isDeleted', isEqualTo: false)
        .get();

    FleetVehicleDocument? newest;
    for (final doc in snapshot.docs) {
      final document = FleetVehicleDocument.fromDoc(doc);
      if (_canonicalVehicleDocumentType(document.documentType) !=
          'HU_TUV_CERTIFICATE') {
        continue;
      }
      if (newest == null || _isDocumentNewer(document, newest)) {
        newest = document;
      }
    }
    return newest;
  }

  /// Creates or updates the HU/TÜV date of a vehicle. The date lives on the
  /// existing HU_TUV_CERTIFICATE document (expiryDate); if no certificate
  /// has been uploaded yet, a date-only document (without file) is created.
  Future<void> _saveTuvDate(
    String scope,
    String plateNumber,
    String tuvDate,
  ) async {
    final normalizedPlate = normalizePlateNumber(plateNumber);
    final existing = await _loadTuvDocument(scope, normalizedPlate);
    final trimmed = tuvDate.trim();

    final docsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(scope)
        .collection('vehicles')
        .doc(normalizedPlate)
        .collection('documents');

    if (trimmed.isEmpty) {
      // Clearing the date only removes date-only records; an uploaded
      // certificate is never deleted here.
      if (existing != null && existing.fileUrl.trim().isEmpty) {
        await docsCollection.doc(existing.documentId).update(<String, dynamic>{
          'isDeleted': true,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      return;
    }

    if (existing != null) {
      if (existing.expiryDate.trim() == trimmed) return;
      await docsCollection.doc(existing.documentId).update(<String, dynamic>{
        'expiryDate': trimmed,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return;
    }

    final docRef = docsCollection.doc();
    await docRef.set(<String, dynamic>{
      'documentId': docRef.id,
      'dspUid': scope,
      'plateNumber': normalizedPlate,
      'documentType': 'HU_TUV_CERTIFICATE',
      'documentNumber': '',
      'expiryDate': trimmed,
      'fileUrl': '',
      'fileName': 'TÜV-Termin',
      'fileType': 'DATE',
      'notes': '',
      'isDeleted': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  List<FleetVehicle> _filteredVehicles(
    List<FleetVehicle> vehicles,
    Map<String, _VehicleListComplianceSummary> complianceByPlate,
  ) {
    final query = _search.trim().toLowerCase();
    final filtered = vehicles.where((vehicle) {
      if (vehicle.isDeleted) return false;
      if (!_matchesStatusPill(vehicle.status)) return false;
      if (!_matchesCategoryFilter(vehicle)) return false;
      final compliance =
          complianceByPlate[vehicle.plateNumber] ?? _defaultComplianceSummary();
      if (_tuvFilter != _tuvAllValue &&
          compliance.tuvStatus.value != _tuvFilter) {
        return false;
      }
      if (query.isEmpty) return true;

      return vehicle.plateNumber.toLowerCase().contains(query) ||
          vehicle.brand.toLowerCase().contains(query) ||
          vehicle.model.toLowerCase().contains(query);
    }).toList();

    final sortColumn = _sortColumn;
    if (sortColumn == null) {
      filtered.sort((a, b) {
        final aDate = a.createdAt;
        final bDate = b.createdAt;
        if (aDate == null && bDate == null) {
          return a.plateNumber.compareTo(b.plateNumber);
        }
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        final byCreatedAt = aDate.compareTo(bDate);
        if (byCreatedAt != 0) return byCreatedAt;
        return a.plateNumber.compareTo(b.plateNumber);
      });
      return filtered;
    }

    int compare(FleetVehicle a, FleetVehicle b) {
      switch (sortColumn) {
        case 'model':
          return '${a.brand} ${a.model}'.trim().toLowerCase().compareTo(
            '${b.brand} ${b.model}'.trim().toLowerCase(),
          );
        case 'status':
          return a.status.index.compareTo(b.status.index);
        case 'serviceEnd':
          // ISO dates (YYYY-MM-DD) sort correctly as strings; vehicles
          // without a date always go last.
          final aDate = a.serviceEndDate.trim();
          final bDate = b.serviceEndDate.trim();
          if (aDate.isEmpty && bDate.isEmpty) return 0;
          if (aDate.isEmpty) return _sortAsc ? 1 : -1;
          if (bDate.isEmpty) return _sortAsc ? -1 : 1;
          return aDate.compareTo(bDate);
        case 'tuv':
          FleetVehicleDocumentStatus tuvOf(FleetVehicle v) =>
              (complianceByPlate[v.plateNumber] ?? _defaultComplianceSummary())
                  .tuvStatus;
          return tuvOf(a).index.compareTo(tuvOf(b).index);
        case 'vehicle':
        default:
          return a.plateNumber.compareTo(b.plateNumber);
      }
    }

    filtered.sort((a, b) {
      final result = _sortAsc ? compare(a, b) : compare(b, a);
      if (result != 0) return result;
      return a.plateNumber.compareTo(b.plateNumber);
    });
    return filtered;
  }

  bool _matchesCategoryFilter(FleetVehicle vehicle) {
    switch (_categoryFilter) {
      case 'ARMADA':
        return vehicle.category == VehicleCategory.armada;
      case 'SESO':
        return vehicle.category == VehicleCategory.sesoRental;
      case 'AMAZON':
        return vehicle.category == VehicleCategory.amazonPaidRental;
      case 'LMR':
        return vehicle.category == VehicleCategory.lmr;
      case 'SELF_OWNED':
        // Legacy self-sourced counts into Self-Owned (same as hero tiles).
        return vehicle.category == VehicleCategory.selfOwnedRental ||
            vehicle.category == VehicleCategory.selfSourcedRental;
      case 'ALL':
      default:
        return true;
    }
  }

  /// Handles taps on the hero counter tiles: Total resets all filters,
  /// Inaktiv toggles the status pill, every category tile toggles the
  /// category filter.
  void _onHeroTileTap(String key) {
    setState(() {
      switch (key) {
        case 'TOTAL':
          _categoryFilter = 'ALL';
          _statusPill = 'ALL';
          break;
        case 'INACTIVE':
          _statusPill = _statusPill == 'INAKTIV' ? 'ALL' : 'INAKTIV';
          break;
        default:
          _categoryFilter = _categoryFilter == key ? 'ALL' : key;
      }
    });
  }

  void _onSortTapped(String column) {
    setState(() {
      if (_sortColumn == column) {
        if (_sortAsc) {
          _sortAsc = false;
        } else {
          // Third tap resets to default order.
          _sortColumn = null;
          _sortAsc = true;
        }
      } else {
        _sortColumn = column;
        _sortAsc = true;
      }
    });
  }

  /// Secondary line under the service-end date: the workshop of a vehicle
  /// that is Grounded (Service). Empty for every other status.
  String? _workshopRowLabel(BuildContext context, FleetVehicle vehicle) {
    if (vehicle.status != VehicleStatus.groundedService) return null;
    final workshop =
        _workshopByPlate[normalizePlateNumber(vehicle.plateNumber)] ?? '';
    if (workshop.isEmpty) return null;
    final de = Localizations.localeOf(context).languageCode == 'de';
    return de ? 'Werkstatt: $workshop' : 'Workshop: $workshop';
  }

  /// True when [status] matches the active status pill. "Operativ" covers
  /// active + operational, "Grounded" covers all grounded reasons.
  bool _matchesStatusPill(VehicleStatus status) {
    switch (_statusPill) {
      case 'OPERATIV':
        return status == VehicleStatus.active ||
            status == VehicleStatus.operational;
      case 'GROUNDED':
        return status.isGrounded;
      case 'INAKTIV':
        return status == VehicleStatus.inactive;
      case 'ALL':
      default:
        return true;
    }
  }

  /// Status filter pills below the counter tiles: Alle · Operativ ·
  /// Grounded (all three reasons combined) · Inaktiv. Tapping the active
  /// pill again resets to "Alle".
  Widget _statusPillsRow(List<FleetVehicle> vehicles) {
    final operativ = vehicles
        .where(
          (v) =>
              v.status == VehicleStatus.active ||
              v.status == VehicleStatus.operational,
        )
        .length;
    final grounded = vehicles.where((v) => v.status.isGrounded).length;
    final inactive = vehicles
        .where((v) => v.status == VehicleStatus.inactive)
        .length;
    final de = Localizations.localeOf(context).languageCode == 'de';

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _statusPillChip('ALL', de ? 'Alle' : 'All', vehicles.length, _kInk),
          const SizedBox(width: 8),
          _statusPillChip(
            'OPERATIV',
            de ? 'Operativ' : 'Operational',
            operativ,
            _kAccentGreen,
          ),
          const SizedBox(width: 8),
          _statusPillChip('GROUNDED', 'Grounded', grounded, _kAccentRed),
          const SizedBox(width: 8),
          _statusPillChip(
            'INAKTIV',
            de ? 'Inaktiv' : 'Inactive',
            inactive,
            _kSubtle,
          ),
        ],
      ),
    );
  }

  /// Filter-Pill nach Handoff: aktiv = dunkle Fläche mit weißer Schrift,
  /// inaktiv = weiße Fläche, Zahl im Akzentton des jeweiligen Status.
  Widget _statusPillChip(String key, String label, int count, Color color) {
    final active = _statusPill == key;
    return Material(
      color: active ? _kInk : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(color: active ? _kInk : _kLine),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () =>
            setState(() => _statusPill = active && key != 'ALL' ? 'ALL' : key),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: active ? Colors.white : _kSubtle,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                  height: 1.35,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$count',
                style: TextStyle(
                  color: active ? Colors.white : color,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateString(BuildContext context, String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    return MaterialLocalizations.of(context).formatShortDate(parsed);
  }

  String _friendlyLoadError(AppLocalizations t, Object? error) {
    if (error is FirebaseException && error.code == 'permission-denied') {
      return t.t('fleet_status_permission_denied');
    }
    return t.tf('fleet_status_load_failed', {'error': '$error'});
  }

  /// Reads Amazon's Cortex VehiclesData XLSX and adds NEW vehicles only.
  /// Existing rows (matched by VIN/FIN or plate) are skipped untouched —
  /// re-running the import as Cortex grows the fleet just appends.
  Future<void> _importFromCortex() async {
    final scope = _scopeUid;
    if (scope == null || scope.isEmpty) return;
    if (!_canManageVehicles) {
      _showSnack(
        AppLocalizations.of(context).t('fleet_status_read_only'),
        error: true,
      );
      return;
    }

    // Pick the file first (interactive), then show a blocking progress popup.
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
      withData: true,
    );
    if (picked == null || picked.files.isEmpty) return;
    final f = picked.files.first;
    final bytes = f.bytes;
    if (!mounted) return;
    final de = Localizations.localeOf(context).languageCode == 'de';
    if (bytes == null) {
      _showSnack(
        de
            ? 'Datei konnte nicht gelesen werden. Bitte erneut versuchen '
                  '(ggf. kleinere Datei oder anderer Browser).'
            : 'Could not read the file. Please try again '
                  '(possibly a smaller file or a different browser).',
        error: true,
      );
      return;
    }

    final phase = ValueNotifier<String>(
      de ? 'Datei wird gelesen …' : 'Reading file …',
    );
    final prog = ValueNotifier<double?>(null);
    setState(() => _busyCortex = true);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              ValueListenableBuilder<double?>(
                valueListenable: prog,
                builder: (_, p, __) => SizedBox(
                  height: 48,
                  width: 48,
                  child: CircularProgressIndicator(value: p, strokeWidth: 4),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Cortex-Fleet-Import',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
              const SizedBox(height: 6),
              ValueListenableBuilder<String>(
                valueListenable: phase,
                builder: (_, s, __) => Text(
                  s,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    CortexImportReport? report;
    Object? error;
    try {
      report = await CortexVehicleImporter().importFromXlsx(
        dspUid: scope,
        bytes: bytes,
        filename: f.name,
        onPhase: (s) => phase.value = s,
        onProgress: (done, total) {
          prog.value = total == 0 ? null : done / total;
          phase.value = de
              ? 'Fahrzeuge werden gespeichert … ($done/$total)'
              : 'Saving vehicles … ($done/$total)';
        },
      );
    } catch (e) {
      error = e;
    } finally {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // close progress
        setState(() => _busyCortex = false);
      }
      phase.dispose();
      prog.dispose();
    }

    if (!mounted) return;
    if (error != null) {
      _showCortexResult(
        title: de ? 'Import fehlgeschlagen' : 'Import failed',
        color: const Color(0xFFB42318),
        lines: ['$error'],
      );
      return;
    }
    final r = report!;
    _showCortexResult(
      title: r.failed > 0
          ? (de
                ? 'Import mit Fehlern abgeschlossen'
                : 'Import finished with errors')
          : (de ? 'Import abgeschlossen' : 'Import finished'),
      color: r.failed > 0 ? const Color(0xFFB45309) : const Color(0xFF067647),
      lines: [
        de ? '✓ ${r.added} neu hinzugefügt' : '✓ ${r.added} newly added',
        de
            ? '• ${r.skippedDuplicate} bereits vorhanden'
            : '• ${r.skippedDuplicate} already present',
        if (r.failed > 0)
          de ? '✗ ${r.failed} fehlgeschlagen' : '✗ ${r.failed} failed',
        de ? '${r.total} Zeilen gelesen' : '${r.total} rows read',
      ],
      failures: r.failures,
    );
  }

  void _showCortexResult({
    required String title,
    required Color color,
    required List<String> lines,
    List<String> failures = const [],
  }) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          title,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 17,
          ),
        ),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final l in lines)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(l, style: const TextStyle(fontSize: 14)),
                ),
              if (failures.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  de ? 'Fehlgeschlagene Fahrzeuge:' : 'Failed vehicles:',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final fmsg in failures.take(15))
                          Text(
                            '• $fmsg',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFB42318),
                            ),
                          ),
                        if (failures.length > 15)
                          Text(
                            de
                                ? '… und ${failures.length - 15} weitere'
                                : '… and ${failures.length - 15} more',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Bestätigung vor dem Kennzeichen-Umzug. Nennt ausdrücklich, was mitzieht
  /// — und was bewusst nicht (Vorfälle bleiben historisch beim alten Schild).
  Future<bool?> _confirmPlateChange(String oldPlate, String newPlate) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          de ? 'Kennzeichen ändern?' : 'Change plate number?',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(child: LicensePlate.compact(plate: oldPlate)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: _kFaint,
                    ),
                  ),
                  Flexible(child: LicensePlate.compact(plate: newPlate)),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                de
                    ? 'Alle Dokumente (TÜV, Fahrzeugschein …), Events und '
                          'Bemerkungen ziehen mit um.'
                    : 'All documents (TÜV, registration …), events and '
                          'remarks move along.',
                style: const TextStyle(fontSize: 13.5, height: 1.4),
              ),
              const SizedBox(height: 8),
              Text(
                de
                    ? 'Vergangene Vorfälle bleiben unter dem alten '
                          'Kennzeichen.'
                    : 'Past incidents stay under the old plate number.',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: _kSubtle,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        actions: [
          CoButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            label: de ? 'Abbrechen' : 'Cancel',
            variant: CoButtonVariant.quiet,
          ),
          CoButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            label: de ? 'Umziehen' : 'Move',
          ),
        ],
      ),
    );
  }

  Future<void> _showVehicleEditor({FleetVehicle? vehicle}) async {
    final scope = _scopeUid;
    final t = AppLocalizations.of(context);

    if (!_canManageVehicles) {
      _showSnack(t.t('fleet_status_read_only'), error: true);
      return;
    }
    if (scope == null) {
      _showSnack(t.t('fleet_status_empty_scope'), error: true);
      return;
    }

    final normalizedPlate = vehicle == null
        ? ''
        : normalizePlateNumber(vehicle.plateNumber);
    final result = await showDialog<_VehicleEditorResult>(
      context: context,
      builder: (_) => _VehicleEditorDialog(
        vehicle: vehicle,
        initialWorkshop: _workshopByPlate[normalizedPlate] ?? '',
        initialTuvDate: _tuvDocByPlate[normalizedPlate]?.expiryDate ?? '',
        initialRemarks: _remarksByPlate[normalizedPlate] ?? '',
      ),
    );
    if (result == null) return;
    final draft = result.draft;

    // Kennzeichen geändert? Dann steht ein Umzug an, bevor die restlichen
    // Felder geschrieben werden — die Doc-ID ist das Kennzeichen.
    final oldPlate = vehicle == null
        ? ''
        : normalizePlateNumber(vehicle.plateNumber);
    final newPlate = normalizePlateNumber(draft.plateNumber);
    final isPlateChange = vehicle != null && oldPlate != newPlate;

    if (isPlateChange) {
      final confirmed = await _confirmPlateChange(oldPlate, newPlate);
      if (!mounted || confirmed != true) return;
    }

    try {
      if (vehicle == null) {
        await _repository.createVehicle(dspUid: scope, draft: draft);
        if (!mounted) return;
        _showSnack(
          t.tf('fleet_status_save_created', {
            'vehicleNumber': draft.plateNumber,
          }),
        );
      } else {
        if (isPlateChange) {
          await _repository.changePlateNumber(
            dspUid: scope,
            fromPlateNumber: oldPlate,
            toPlateNumber: newPlate,
          );
          if (!mounted) return;
          // Eine offene Detailseite zeigt sonst auf ein gelöschtes Dokument.
          if (_detailPlate == oldPlate) {
            setState(() => _detailPlate = newPlate);
          }
        }
        await _repository.updateVehicle(
          dspUid: scope,
          originalPlateNumber: newPlate,
          draft: draft,
        );
        if (!mounted) return;
        _showSnack(
          t.tf('fleet_status_save_updated', {
            'vehicleNumber': draft.plateNumber,
          }),
        );
      }
      // Side data (workshop + TÜV date) lives outside the vehicle doc —
      // save it best-effort after the main record went through.
      try {
        await _saveVehicleWorkshop(scope, draft.plateNumber, result.workshop);
        await _saveTuvDate(scope, draft.plateNumber, result.tuvDate);
        await _saveVehicleRemarks(scope, draft.plateNumber, result.remarks);
      } catch (_) {
        // Non-fatal: the vehicle itself was saved successfully.
      }
      if (!mounted) return;
      setState(() {
        _search = '';
        _searchCtrl.clear();
      });
    } on DuplicateVehicleException {
      _showSnack(t.t('fleet_status_vehicle_exists'), error: true);
    } on ImmutablePlateNumberException {
      _showSnack(t.t('fleet_status_plate_number_locked'), error: true);
    } on VehicleValidationException catch (e) {
      _showSnack(e.message, error: true);
    } on FirebaseException catch (e) {
      _showSnack(
        e.code == 'permission-denied'
            ? t.t('fleet_status_permission_denied')
            : t.tf('fleet_status_save_failed', {'error': '$e'}),
        error: true,
      );
    } catch (e) {
      _showSnack(
        t.tf('fleet_status_save_failed', {'error': '$e'}),
        error: true,
      );
    }
  }

  /// Opens the vehicle detail page **embedded** in the shell content — a
  /// state switch instead of a full-screen route, so the side menu stays
  /// visible (same pattern as the Drivers Hub detail page).
  void _showVehicleDetails(FleetVehicle vehicle) {
    final scope = _scopeUid;
    if (scope == null) {
      _showSnack(
        AppLocalizations.of(context).t('fleet_status_empty_scope'),
        error: true,
      );
      return;
    }
    setState(() => _detailPlate = normalizePlateNumber(vehicle.plateNumber));
  }

  Future<void> _deleteVehicle(FleetVehicle vehicle) async {
    final t = AppLocalizations.of(context);
    final scope = _scopeUid;
    if (scope == null) {
      _showSnack(t.t('fleet_status_empty_scope'), error: true);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.t('fleet_status_delete_title')),
        content: Text(
          t.tf('fleet_status_delete_body', {
            'vehicleNumber': vehicle.plateNumber,
          }),
        ),
        actions: [
          CoButton(
            onPressed: () => Navigator.of(context).pop(false),
            label: t.t('button_close'),
            variant: CoButtonVariant.quiet,
          ),
          CoButton(
            onPressed: () => Navigator.of(context).pop(true),
            label: t.t('fleet_status_action_delete'),
            variant: CoButtonVariant.destructive,
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _repository.softDeleteVehicle(
        dspUid: scope,
        plateNumber: vehicle.plateNumber,
      );
      if (!mounted) return;
      _showSnack(
        t.tf('fleet_status_delete_success', {
          'vehicleNumber': vehicle.plateNumber,
        }),
      );
    } on FirebaseException catch (e) {
      _showSnack(
        e.code == 'permission-denied'
            ? t.t('fleet_status_permission_denied')
            : t.tf('fleet_status_delete_failed', {'error': '$e'}),
        error: true,
      );
    } catch (e) {
      _showSnack(
        t.tf('fleet_status_delete_failed', {'error': '$e'}),
        error: true,
      );
    }
  }

  /// Deletes the ENTIRE fleet for the current DSP. Destructive — guarded by
  /// a type-to-confirm dialog. Each vehicle goes through the normal
  /// softDeleteVehicle path so documents/history are archived consistently.
  Future<void> _deleteAllVehicles() async {
    final t = AppLocalizations.of(context);
    final de = Localizations.localeOf(context).languageCode == 'de';
    final scope = _scopeUid;
    if (scope == null) {
      _showSnack(t.t('fleet_status_empty_scope'), error: true);
      return;
    }
    List<FleetVehicle> vehicles;
    try {
      vehicles = await _repository.watchVehicles(dspUid: scope).first;
    } catch (e) {
      _showSnack(
        de ? 'Konnte Fahrzeuge nicht laden: $e' : 'Could not load vehicles: $e',
        error: true,
      );
      return;
    }
    if (vehicles.isEmpty) {
      _showSnack(
        de
            ? 'Keine Fahrzeuge zum Löschen vorhanden.'
            : 'There are no vehicles to delete.',
      );
      return;
    }

    final confirmWord = de ? 'LÖSCHEN' : 'DELETE';
    final ctrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) {
          final match = ctrl.text.trim().toUpperCase() == confirmWord;
          return AlertDialog(
            title: Text(
              de ? 'Gesamten Fuhrpark löschen?' : 'Delete the entire fleet?',
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  de
                      ? 'Dies löscht ALLE ${vehicles.length} Fahrzeuge dieses DSP '
                            '(inkl. Dokumente & Historie). Diese Aktion kann nicht '
                            'einfach rückgängig gemacht werden.\n\n'
                            'Tippe zum Bestätigen LÖSCHEN ein:'
                      : 'This deletes ALL ${vehicles.length} vehicles of this DSP '
                            '(including documents & history). This action cannot '
                            'easily be undone.\n\n'
                            'Type DELETE to confirm:',
                  style: const TextStyle(height: 1.4),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ctrl,
                  autofocus: true,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: confirmWord,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (_) => setLocal(() {}),
                ),
              ],
            ),
            actions: [
              CoButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                label: t.t('button_close'),
                variant: CoButtonVariant.quiet,
              ),
              CoButton(
                onPressed: match ? () => Navigator.of(ctx).pop(true) : null,
                label: de
                    ? 'Alle ${vehicles.length} löschen'
                    : 'Delete all ${vehicles.length}',
                variant: CoButtonVariant.destructive,
              ),
            ],
          );
        },
      ),
    );
    if (confirmed != true) return;

    _showSnack(
      de
          ? 'Lösche ${vehicles.length} Fahrzeuge…'
          : 'Deleting ${vehicles.length} vehicles…',
    );
    var done = 0;
    var failed = 0;
    for (final v in vehicles) {
      try {
        await _repository.softDeleteVehicle(
          dspUid: scope,
          plateNumber: v.plateNumber,
        );
        done++;
      } catch (_) {
        failed++;
      }
    }
    if (!mounted) return;
    _showSnack(
      failed == 0
          ? (de ? '$done Fahrzeuge gelöscht.' : '$done vehicles deleted.')
          : (de
                ? '$done gelöscht, $failed fehlgeschlagen.'
                : '$done deleted, $failed failed.'),
      error: failed > 0,
    );
  }

  /// Returns `true` when the status write went through — callers use this
  /// to chain follow-up flows (e.g. the ungrounding upload dialog).
  Future<bool> _updateVehicleStatus(
    FleetVehicle vehicle,
    VehicleStatus status, {
    String? serviceEndDate,
  }) async {
    if (vehicle.status == status) return false;

    final scope = _scopeUid;
    final t = AppLocalizations.of(context);
    if (scope == null) {
      _showSnack(t.t('fleet_status_empty_scope'), error: true);
      return false;
    }

    final plateNumber = vehicle.plateNumber;
    setState(() => _updatingVehicleStatuses.add(plateNumber));
    try {
      await _repository.updateVehicleStatus(
        dspUid: scope,
        plateNumber: plateNumber,
        status: status,
        serviceEndDate: serviceEndDate,
      );
      if (mounted) {
        _showSnack(
          t.tf('fleet_status_save_updated', {'vehicleNumber': plateNumber}),
        );
      }
      return true;
    } on FirebaseException catch (e) {
      _showSnack(
        e.code == 'permission-denied'
            ? t.t('fleet_status_permission_denied')
            : t.tf('fleet_status_save_failed', {'error': '$e'}),
        error: true,
      );
      return false;
    } catch (e) {
      _showSnack(
        t.tf('fleet_status_save_failed', {'error': '$e'}),
        error: true,
      );
      return false;
    } finally {
      if (mounted) {
        setState(() => _updatingVehicleStatuses.remove(plateNumber));
      }
    }
  }

  Future<void> _handleVehicleStatusSelection(
    FleetVehicle vehicle,
    VehicleStatus status,
  ) async {
    if (vehicle.status == status) return;

    _GroundingDialogResult? grounding;
    if (status.isGrounded) {
      final normalizedPlate = normalizePlateNumber(vehicle.plateNumber);
      grounding = await showDialog<_GroundingDialogResult>(
        context: context,
        builder: (_) => _ServiceEndDateDialog(
          initialValue: vehicle.serviceEndDate,
          requiredValue: false,
          // Grounded (Service): additionally ask for the workshop the
          // vehicle was sent to.
          askWorkshop: status == VehicleStatus.groundedService,
          initialWorkshop: _workshopByPlate[normalizedPlate] ?? '',
        ),
      );
      if (!mounted || grounding == null) return;
    }

    final wasGrounded = vehicle.status.isGrounded;
    final updated = await _updateVehicleStatus(
      vehicle,
      status,
      serviceEndDate: status.isGrounded ? grounding?.serviceEndDate : null,
    );

    if (status == VehicleStatus.groundedService && grounding != null) {
      final scope = _scopeUid;
      if (scope != null) {
        try {
          await _saveVehicleWorkshop(
            scope,
            vehicle.plateNumber,
            grounding.workshop,
          );
        } catch (_) {
          // Non-fatal: the status change itself already went through.
        }
      }
    }

    // Ungrounding (grounded → operational/active): offer to attach the
    // service report / delivery note etc. as a vehicle event — optional,
    // skippable via "Später".
    if (updated &&
        wasGrounded &&
        !status.isGrounded &&
        status != VehicleStatus.inactive &&
        _canManageVehicles &&
        mounted) {
      await _showUngroundingUploadDialog(vehicle);
    }
  }

  // ─── Ungrounding: optionaler Service-Bericht-Upload ───────────────────
  //
  // Nach dem Statuswechsel grounded → operational kann der Admin direkt
  // Unterlagen (Servicebericht, Lieferschein, …) hochladen. Das Ergebnis
  // wird als Event in users/{scope}/fleet_events gespeichert — dieselbe
  // Collection, die der „+ Event"-Dialog der Detailseite nutzt — und der
  // Anhang liegt unter vehicles/{scope}/{plate}/events/… (der Storage-Pfad
  // ist für Admin + Dispatcher bereits freigegeben: PDF/Bilder, max 20 MB).

  Future<void> _showUngroundingUploadDialog(FleetVehicle vehicle) async {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final scope = _scopeUid;
    if (scope == null) return;

    final result = await showDialog<_ServiceUploadResult>(
      context: context,
      builder: (_) => _ServiceUploadDialog(de: de, plate: vehicle.plateNumber),
    );
    if (result == null || !mounted) return;

    try {
      String fileUrl = '';
      String fileName = '';
      String storagePath = '';
      final bytes = result.fileBytes;
      if (bytes != null && result.fileName.trim().isNotEmpty) {
        fileName = result.fileName.trim();
        final ref = fb_storage.FirebaseStorage.instance.ref().child(
          'vehicles/'
          '$scope/'
          '${normalizePlateNumber(vehicle.plateNumber)}/'
          'events/'
          '${DateTime.now().millisecondsSinceEpoch}_$fileName',
        );
        await ref.putData(
          bytes,
          fb_storage.SettableMetadata(
            contentType: _serviceUploadContentType(fileName),
          ),
        );
        fileUrl = await ref.getDownloadURL();
        storagePath = ref.fullPath;
      }

      final now = DateTime.now();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(scope)
          .collection('fleet_events')
          .add(<String, dynamic>{
            'plateKey': plateKeyOf(vehicle.plateNumber),
            'plate': vehicle.plateNumber,
            'type': 'other',
            'title': de ? 'Service / Entgrounding' : 'Service / ungrounding',
            'subtitle': result.note.trim(),
            'date': Timestamp.fromDate(DateTime(now.year, now.month, now.day)),
            'km': null,
            if (fileUrl.isNotEmpty) 'fileUrl': fileUrl,
            if (fileName.isNotEmpty) 'fileName': fileName,
            if (storagePath.isNotEmpty) 'storagePath': storagePath,
            'createdAt': FieldValue.serverTimestamp(),
            'createdBy': FirebaseAuth.instance.currentUser?.uid ?? '',
          });
      if (!mounted) return;
      _showSnack(
        de
            ? 'Service-Event gespeichert.'
            : 'Service event saved.',
      );
    } catch (e) {
      if (!mounted) return;
      _showSnack(
        de ? 'Speichern fehlgeschlagen: $e' : 'Could not save: $e',
        error: true,
      );
    }
  }

  /// Content type for the ungrounding upload — the Storage rules only
  /// accept images and PDFs on this path.
  static String _serviceUploadContentType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.pdf')) return 'application/pdf';
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  void _showSnack(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: error ? _kRed : null, content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    if (_uid == null) {
      return Center(child: Text(t.t('fleet_status_must_login')));
    }
    if (_loadingScope) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.codriverGreen),
        ),
      );
    }
    if (!_canViewVehicles) {
      return Center(child: Text(t.t('fleet_status_no_access')));
    }

    final scope = _scopeUid;
    if (scope == null) {
      return Center(child: Text(t.t('fleet_status_empty_scope')));
    }

    // Vehicle detail page rendered *inside* the shell content so the side
    // menu stays visible; the back arrow clears the state again.
    final detailPlate = _detailPlate;
    if (detailPlate != null) {
      return FleetVehicleDetailPage(
        key: ValueKey('fleet-detail-$scope-$detailPlate'),
        dspUid: scope,
        plateNumber: detailPlate,
        canManage: _canManageVehicles,
        actions: _detailActions(scope),
        onBack: () => setState(() => _detailPlate = null),
      );
    }

    // Tab bar + SESO temporarily hidden — show the vehicles view directly.
    // (SESO code kept in the tree for when it's re-enabled.)
    return _buildVehiclesTab(context, scope);
  }

  // ─── Brücke: Detailseite → bestehende Editor-Flows ────────────────────
  //
  // Die Detailseite (`fleet_vehicle_detail_page.dart`) enthält keine eigenen
  // Schreibpfade auf das Fahrzeug-Dokument — sie ruft die hier bereits
  // vorhandenen Dialoge über diese Closures auf.
  FleetVehicleDetailActions _detailActions(String scope) {
    return FleetVehicleDetailActions(
      editVehicle: (vehicle) => _showVehicleEditor(vehicle: vehicle),
      changeStatus: _handleVehicleStatusSelection,
      editTuvDate: (vehicle) => _editTuvDate(scope, vehicle),
      editNotes: _editVehicleNotes,
      editRemarks: (vehicle, current) =>
          _editVehicleRemarks(scope, vehicle, current),
      saveExtras: (plateNumber, data) =>
          _saveVehicleExtras(scope, plateNumber, data),
      statusLabel: _statusLabel,
      statusColor: _statusColor,
      categoryLabel: _categoryLabel,
      fuelLabel: _fuelTypeLabel,
      documentTypeLabel: _documentTypeLabel,
    );
  }

  /// Datepicker für das HU/TÜV-Datum — schreibt über den bestehenden
  /// [_saveTuvDate]-Pfad (Datum lebt auf dem HU_TUV_CERTIFICATE-Dokument).
  Future<void> _editTuvDate(String scope, FleetVehicle vehicle) async {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final plate = normalizePlateNumber(vehicle.plateNumber);
    // Direkt aus Firestore lesen — der Listen-Cache läuft auf der
    // Detailseite nicht (siehe [_loadTuvDocument]).
    final existing = await _loadTuvDocument(scope, plate);
    if (!mounted) return;
    final current = DateTime.tryParse((existing?.expiryDate ?? '').trim());
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(DateTime.now().year + 15),
      helpText: de ? 'TÜV / HU gültig bis' : 'TÜV / inspection valid until',
    );
    if (picked == null || !mounted) return;
    final iso =
        '${picked.year.toString().padLeft(4, '0')}-'
        '${picked.month.toString().padLeft(2, '0')}-'
        '${picked.day.toString().padLeft(2, '0')}';
    try {
      await _saveTuvDate(scope, vehicle.plateNumber, iso);
      _showSnack(de ? 'TÜV-Datum gespeichert.' : 'TÜV date saved.');
    } catch (e) {
      _showSnack(
        de ? 'Speichern fehlgeschlagen: $e' : 'Could not save: $e',
        error: true,
      );
    }
  }

  /// Notizen des Fahrzeug-Dokuments (`notes`) — geht über den bestehenden
  /// Repository-Update-Pfad, damit die Rules-Validierung greift.
  Future<void> _editVehicleNotes(FleetVehicle vehicle) async {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final scope = _scopeUid;
    if (scope == null) return;
    final text = await _showMultilineEditor(
      title: de ? 'Notizen' : 'Notes',
      initialValue: vehicle.notes,
    );
    if (text == null) return;
    try {
      await _repository.updateVehicle(
        dspUid: scope,
        originalPlateNumber: vehicle.plateNumber,
        draft: FleetVehicleDraft(
          plateNumber: vehicle.plateNumber,
          category: vehicle.category,
          brand: vehicle.brand,
          model: vehicle.model,
          manufacturingYear: vehicle.manufacturingYear,
          vinNumber: vehicle.vinNumber,
          fuelType: vehicle.fuelType,
          status: vehicle.status,
          serviceEndDate: vehicle.serviceEndDate,
          metadata: vehicle.metadata,
          notes: text,
        ),
      );
      if (!mounted) return;
      _showSnack(de ? 'Notizen gespeichert.' : 'Notes saved.');
    } catch (e) {
      _showSnack(
        de ? 'Speichern fehlgeschlagen: $e' : 'Could not save: $e',
        error: true,
      );
    }
  }

  Future<void> _editVehicleRemarks(
    String scope,
    FleetVehicle vehicle,
    String current,
  ) async {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final text = await _showMultilineEditor(
      title: de ? 'Bemerkungen' : 'Remarks',
      initialValue: current,
    );
    if (text == null) return;
    try {
      await _saveVehicleRemarks(scope, vehicle.plateNumber, text);
      if (!mounted) return;
      _showSnack(de ? 'Bemerkungen gespeichert.' : 'Remarks saved.');
    } catch (e) {
      _showSnack(
        de ? 'Speichern fehlgeschlagen: $e' : 'Could not save: $e',
        error: true,
      );
    }
  }

  /// Merge-Write in `users/{scope}/fleet_vehicle_extras/{plate}` — genutzt für
  /// die Detailseiten-Felder, die es auf dem Fahrzeug-Dokument (Rules-
  /// Whitelist!) nicht gibt: Leasinggeber, Bremsen-/Reifen-Spezifikation,
  /// Full-Maintenance-Kennzeichen.
  Future<void> _saveVehicleExtras(
    String scope,
    String plateNumber,
    Map<String, dynamic> data,
  ) async {
    await _extrasCollection(
      scope,
    ).doc(normalizePlateNumber(plateNumber)).set(<String, dynamic>{
      'plateNumber': normalizePlateNumber(plateNumber),
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<String?> _showMultilineEditor({
    required String title,
    required String initialValue,
  }) async {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final controller = TextEditingController(text: initialValue);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        content: SizedBox(
          width: 440,
          child: TextField(
            controller: controller,
            autofocus: true,
            minLines: 3,
            maxLines: 8,
            decoration: _referenceInputDecoration(title),
          ),
        ),
        actions: [
          CoButton(
            onPressed: () => Navigator.of(ctx).pop(),
            label: de ? 'Abbrechen' : 'Cancel',
            variant: CoButtonVariant.quiet,
          ),
          CoButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            label: de ? 'Speichern' : 'Save',
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  Stream<List<FleetVehicleDocument>>? _scopeDocsStream;
  String? _scopeDocsStreamFor_;

  /// Gecachter Dokumenten-Stream je Admin-Scope (siehe Kommentar am
  /// StreamBuilder — Neuerzeugung pro Build lässt die Chips leer laufen).
  Stream<List<FleetVehicleDocument>> _scopeDocumentsStreamFor(String scope) {
    if (_scopeDocsStreamFor_ != scope || _scopeDocsStream == null) {
      _scopeDocsStreamFor_ = scope;
      _scopeDocsStream = _documentService
          .watchScopeDocuments(dspUid: scope)
          .asBroadcastStream();
    }
    return _scopeDocsStream!;
  }

  Widget _buildVehiclesTab(BuildContext context, String scope) {
    final t = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 1024;
        final isMobile = constraints.maxWidth < 700;
        final body = Container(
          color: _kPageBg,
          child: StreamBuilder<List<FleetVehicle>>(
            stream: _repository.watchVehicles(dspUid: scope),
            builder: (context, snapshot) {
              final errorMessage = snapshot.hasError
                  ? _friendlyLoadError(t, snapshot.error)
                  : null;

              return StreamBuilder<List<FleetVehicleDocument>>(
                // WICHTIG: Stream cachen statt bei jedem Build neu erzeugen —
                // watchScopeDocuments baut 61 Sub-Abos auf und beginnt bei
                // jeder Neuerzeugung wieder leer. Ohne Cache blieben die
                // TÜV-/Fahrzeugschein-Chips dauerhaft auf „fehlt".
                stream: _scopeDocumentsStreamFor(scope),
                builder: (context, docsSnapshot) {
                  final scopeDocuments =
                      docsSnapshot.data ?? const <FleetVehicleDocument>[];
                  final complianceByPlate = _buildComplianceByPlate(
                    scopeDocuments,
                  );
                  _scopeDocsLoaded = docsSnapshot.hasData;
                  _tuvDocByPlate = _latestTuvDocsByPlate(scopeDocuments);
                  _registrationPlates = <String>{
                    for (final doc in scopeDocuments)
                      if (!doc.isDeleted &&
                          doc.fileUrl.trim().isNotEmpty &&
                          _canonicalVehicleDocumentType(doc.documentType) ==
                              'FAHRZEUGSCHEIN')
                        normalizePlateNumber(doc.plateNumber),
                  };

                  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _extrasCollection(scope).snapshots(),
                    builder: (context, extrasSnapshot) {
                      // Errors (e.g. exotic roles without access) degrade to
                      // "no workshop data" instead of breaking the page.
                      final workshopByPlate = <String, String>{};
                      final remarksByPlate = <String, String>{};
                      final leasingByPlate = <String, String>{};
                      if (extrasSnapshot.hasData) {
                        for (final doc in extrasSnapshot.data!.docs) {
                          final workshop = (doc.data()['workshop'] ?? '')
                              .toString()
                              .trim();
                          if (workshop.isNotEmpty) {
                            workshopByPlate[normalizePlateNumber(doc.id)] =
                                workshop;
                          }
                          final remarks = (doc.data()['remarks'] ?? '')
                              .toString()
                              .trim();
                          if (remarks.isNotEmpty) {
                            remarksByPlate[normalizePlateNumber(doc.id)] =
                                remarks;
                          }
                          final leasing = (doc.data()['leasingProvider'] ?? '')
                              .toString()
                              .trim();
                          if (leasing.isNotEmpty) {
                            leasingByPlate[normalizePlateNumber(doc.id)] =
                                leasing;
                          }
                        }
                      }
                      _workshopByPlate = workshopByPlate;
                      _remarksByPlate = remarksByPlate;
                      _leasingByPlate = leasingByPlate;

                      final vehicles = _filteredVehicles(
                        snapshot.data ?? const [],
                        complianceByPlate,
                      );

                      return Padding(
                        padding: EdgeInsets.all(isMobile ? 12 : 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isMobile) ...[
                              _buildHeader(context, isNarrow: isNarrow),
                              const SizedBox(height: 16),
                            ],
                            _FleetHero(
                              vehicles:
                                  (snapshot.data ?? const <FleetVehicle>[])
                                      .where((v) => !v.isDeleted)
                                      .toList(),
                              compliance: complianceByPlate,
                              isMobile: isMobile,
                              activeKeys: {
                                if (_categoryFilter == 'ALL' &&
                                    _statusPill == 'ALL')
                                  'TOTAL',
                                if (_categoryFilter != 'ALL') _categoryFilter,
                                if (_statusPill == 'INAKTIV') 'INACTIVE',
                              },
                              onTileTap: _onHeroTileTap,
                            ),
                            const SizedBox(height: 12),
                            _buildFilterBar(
                              context,
                              (snapshot.data ?? const <FleetVehicle>[])
                                  .where((v) => !v.isDeleted)
                                  .toList(),
                              scope,
                              isNarrow: isNarrow,
                              isMobile: isMobile,
                            ),
                            const SizedBox(height: 12),
                            // Mobil sitzen die Referenz-Links im Bottom-Sheet
                            // hinter dem Lesezeichen-Button — die horizontale
                            // Chip-Zeile entfällt dort.
                            if (!isMobile)
                              _buildReferencesSection(context, scope),
                            const SizedBox(height: 4),
                            Expanded(
                              child: CoStateSwitcher(
                                child:
                                    snapshot.connectionState ==
                                            ConnectionState.waiting &&
                                        !snapshot.hasData
                                    ? const Center(
                                        key: ValueKey('fleet-loading'),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                AppColors.codriverGreen,
                                              ),
                                        ),
                                      )
                                    : errorMessage != null
                                    ? KeyedSubtree(
                                        key: const ValueKey('fleet-error'),
                                        child: _buildErrorState(
                                          context,
                                          errorMessage,
                                        ),
                                      )
                                    : vehicles.isEmpty
                                    ? KeyedSubtree(
                                        key: const ValueKey('fleet-empty'),
                                        child: _buildEmptyState(context),
                                      )
                                    : KeyedSubtree(
                                        key: const ValueKey('fleet-table'),
                                        child: _buildVehicleTable(
                                          context,
                                          vehicles,
                                          complianceByPlate: complianceByPlate,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        );

        if (_canManageVehicles) {
          return Stack(
            children: [
              body,
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton(
                  onPressed: _busyCortex ? null : _showMobileAddSheet,
                  backgroundColor: const Color(0xFF1D7F5A),
                  foregroundColor: Colors.white,
                  elevation: 6,
                  child: _busyCortex
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.add_rounded, size: 28),
                ),
              ),
            ],
          );
        }
        return body;
      },
    );
  }

  Future<void> _showMobileAddSheet() async {
    final t = AppLocalizations.of(context);
    final de = Localizations.localeOf(context).languageCode == 'de';
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: const Icon(
                    Icons.cloud_download_outlined,
                    color: Color(0xFF1D7F5A),
                  ),
                  title: const Text(
                    'Cortex-Import',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    de
                        ? 'Aktuelle Flotte aus Cortex synchronisieren'
                        : 'Sync the current fleet from Cortex',
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _importFromCortex();
                  },
                ),
                const SizedBox(height: 4),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: const Icon(
                    Icons.add_circle_outline_rounded,
                    color: Color(0xFF1D7F5A),
                  ),
                  title: Text(
                    t.t('fleet_status_add_vehicle'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    de
                        ? 'Neues Fahrzeug manuell anlegen'
                        : 'Add a new vehicle manually',
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _showVehicleEditor();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, {required bool isNarrow}) {
    final t = AppLocalizations.of(context);
    final de = Localizations.localeOf(context).languageCode == 'de';
    final isSuperadmin = const {
      'info@arion-logistics.de',
      'admin@arion-logistics.de',
    }.contains(FirebaseAuth.instance.currentUser?.email?.toLowerCase() ?? '');
    // Title/subtitle removed. Compact action row, right-aligned: Ayvens Wissen
    // (superadmin) + an overflow (3-dot) menu that hides "Alle löschen".
    // Add-vehicle and Cortex-Import moved to the floating "+" button.
    return Row(
      children: [
        Text(
          'Fleethub',
          style: GoogleFonts.montserrat(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: _kInk,
          ),
        ),
        const Spacer(),
        if (isSuperadmin) ...[
          // Ayvens Wissen temporarily disabled — shown as "coming soon".
          CoButton(
            onPressed: null,
            icon: Icons.auto_awesome,
            label: 'Ayvens Wissen · Coming soon',
            variant: CoButtonVariant.quiet,
          ),
          const SizedBox(width: 8),
        ],
        if (_canManageVehicles)
          PopupMenuButton<String>(
            tooltip: de ? 'Mehr' : 'More',
            icon: const Icon(Icons.more_vert_rounded, color: _kMuted),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == 'deleteAll') _deleteAllVehicles();
            },
            // Cortex-Import und „Manuell anlegen" leben jetzt im grünen
            // „+ Neu"-Menü der Filterleiste (Handoff) — hier bleibt nur die
            // destruktive Aktion.
            itemBuilder: (ctx) => [
              PopupMenuItem<String>(
                value: 'deleteAll',
                child: Row(
                  children: [
                    const Icon(
                      Icons.delete_forever_outlined,
                      size: 18,
                      color: Color(0xFFB91C1C),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      de ? 'Alle löschen' : 'Delete all',
                      style: const TextStyle(
                        color: Color(0xFFB91C1C),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: _kBorder),
            ),
            child: Text(
              t.t('fleet_status_read_only'),
              style: const TextStyle(
                color: _kMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }

  // ─── Referenzen — named contacts (workshops, rental partners, …) ──────
  //
  // Stored under users/{dspUid}/fleet_references/{autoId} with
  // {name, url, email, phone, createdAt, updatedAt}; the admin's own
  // subtree, so the existing rules already allow admin + dispatcher
  // access. Only `name` is required — link, e-mail and phone are all
  // optional (older docs simply lack the newer fields).

  /// Chips row with all saved reference links; tapping a chip opens the URL
  /// in a new tab. Admins get a manage button (add / edit / delete).
  Widget _buildReferencesSection(BuildContext context, String scope) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _referencesCollection(scope).orderBy('name').snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.hasData
            ? snapshot.data!.docs
            : const <QueryDocumentSnapshot<Map<String, dynamic>>>[];
        if (docs.isEmpty && !_canManageVehicles) {
          return const SizedBox.shrink();
        }
        // Plain SingleChildScrollView isn't mouse-draggable on Flutter web
        // desktop and the mouse wheel scrolls the page, not this row — so
        // the chips ran off-screen with no way to reach them (customer
        // report). Fix: a visible/draggable Scrollbar bound to a named
        // controller, a ScrollConfiguration that allows mouse-drag, and a
        // wheel handler that maps vertical wheel delta onto this axis.
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ScrollConfiguration(
            behavior: _HorizontalDragScrollBehavior(),
            child: Listener(
              onPointerSignal: (event) {
                if (event is PointerScrollEvent &&
                    _referencesScrollCtrl.hasClients) {
                  final max = _referencesScrollCtrl.position.maxScrollExtent;
                  final target =
                      (_referencesScrollCtrl.offset + event.scrollDelta.dy)
                          .clamp(0.0, max);
                  _referencesScrollCtrl.jumpTo(target);
                }
              },
              child: Scrollbar(
                controller: _referencesScrollCtrl,
                thumbVisibility: true,
                trackVisibility: true,
                child: SingleChildScrollView(
                  controller: _referencesScrollCtrl,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Icon(
                        Icons.bookmarks_outlined,
                        size: 15,
                        color: _kMuted.withValues(alpha: 0.9),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        de ? 'Referenzen:' : 'References:',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: _kMuted,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (docs.isEmpty)
                        Text(
                          de
                              ? 'Noch keine Links (z. B. Werkstätten, Vermieter)'
                              : 'No links yet (e.g. workshops, rental partners)',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: _kMuted,
                          ),
                        ),
                      for (final doc in docs) ...[
                        _referenceChip(context, doc),
                        const SizedBox(width: 8),
                      ],
                      if (_canManageVehicles) ...[
                        const SizedBox(width: 4),
                        Tooltip(
                          message: de
                              ? 'Referenzen verwalten'
                              : 'Manage references',
                          child: InkWell(
                            onTap: () => _showReferencesManager(scope),
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: _kBorder),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.edit_outlined,
                                    size: 14,
                                    color: Color(0xFF1D7F5A),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    docs.isEmpty
                                        ? (de ? 'Hinzufügen' : 'Add')
                                        : (de ? 'Verwalten' : 'Manage'),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1D7F5A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _referenceChip(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final name = (data['name'] ?? '').toString().trim();
    final url = (data['url'] ?? '').toString().trim();
    final email = (data['email'] ?? '').toString().trim();
    final phone = (data['phone'] ?? '').toString().trim();
    final details = [url, email, phone].where((v) => v.isNotEmpty).toList();
    final tooltip = details.join('\n');
    final label = name.isEmpty
        ? (details.isEmpty ? '' : details.first)
        : name;
    return InkWell(
      onTap: () =>
          _openReference(name: name, url: url, email: email, phone: phone),
      borderRadius: BorderRadius.circular(999),
      child: Tooltip(
        message: tooltip.isEmpty ? name : tooltip,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: _kBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _referenceIcon(url: url, email: email, phone: phone),
                size: 13,
                color: const Color(0xFF2563EB),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Icon for a reference chip/row: link beats e-mail beats phone.
  IconData _referenceIcon({
    required String url,
    required String email,
    required String phone,
  }) {
    if (url.trim().isNotEmpty) return Icons.open_in_new_rounded;
    if (email.trim().isNotEmpty) return Icons.mail_outline_rounded;
    if (phone.trim().isNotEmpty) return Icons.phone_outlined;
    return Icons.bookmark_outline_rounded;
  }

  /// Opens a reference: with exactly one saved action (link, e-mail or
  /// phone) it launches directly — like the old link-only behaviour. With
  /// two or more, a small chooser dialog offers all of them as tappable
  /// actions (mailto: / tel: / URL).
  Future<void> _openReference({
    required String name,
    required String url,
    required String email,
    required String phone,
  }) async {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final trimmedUrl = url.trim();
    final trimmedEmail = email.trim();
    final trimmedPhone = phone.trim();
    final actionCount = [
      trimmedUrl,
      trimmedEmail,
      trimmedPhone,
    ].where((v) => v.isNotEmpty).length;

    if (actionCount == 0) {
      _showSnack(
        de
            ? 'Keine Kontaktdaten hinterlegt.'
            : 'No contact details saved.',
      );
      return;
    }
    if (actionCount == 1) {
      if (trimmedUrl.isNotEmpty) return _openReferenceUrl(trimmedUrl);
      if (trimmedEmail.isNotEmpty) return _openReferenceEmail(trimmedEmail);
      return _openReferencePhone(trimmedPhone);
    }

    await showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: _kBorder),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 8, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        name.isEmpty ? (de ? 'Referenz' : 'Reference') : name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _kText,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: de ? 'Schließen' : 'Close',
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(Icons.close, color: _kMuted, size: 20),
                    ),
                  ],
                ),
              ),
              if (trimmedUrl.isNotEmpty)
                ListTile(
                  leading: const Icon(
                    Icons.open_in_new_rounded,
                    size: 20,
                    color: Color(0xFF2563EB),
                  ),
                  title: Text(
                    de ? 'Link öffnen' : 'Open link',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    trimmedUrl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: _kMuted),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _openReferenceUrl(trimmedUrl);
                  },
                ),
              if (trimmedEmail.isNotEmpty)
                ListTile(
                  leading: const Icon(
                    Icons.mail_outline_rounded,
                    size: 20,
                    color: Color(0xFF1D7F5A),
                  ),
                  title: Text(
                    de ? 'E-Mail schreiben' : 'Send e-mail',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    trimmedEmail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: _kMuted),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _openReferenceEmail(trimmedEmail);
                  },
                ),
              if (trimmedPhone.isNotEmpty)
                ListTile(
                  leading: const Icon(
                    Icons.phone_outlined,
                    size: 20,
                    color: Color(0xFF1D7F5A),
                  ),
                  title: Text(
                    de ? 'Anrufen' : 'Call',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    trimmedPhone,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: _kMuted),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _openReferencePhone(trimmedPhone);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openReferenceEmail(String email) async {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final uri = Uri(scheme: 'mailto', path: email.trim());
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      _showSnack(
        de
            ? 'E-Mail-App konnte nicht geöffnet werden.'
            : 'Could not open the e-mail app.',
        error: true,
      );
    }
  }

  Future<void> _openReferencePhone(String phone) async {
    final de = Localizations.localeOf(context).languageCode == 'de';
    // Keep digits, "+" and common separators out — tel: URIs are picky
    // about spaces and slashes.
    final sanitized = phone.trim().replaceAll(RegExp(r'[\s/().-]'), '');
    final uri = Uri(scheme: 'tel', path: sanitized);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      _showSnack(
        de
            ? 'Telefon-App konnte nicht geöffnet werden.'
            : 'Could not open the phone app.',
        error: true,
      );
    }
  }

  Future<void> _openReferenceUrl(String url) async {
    final de = Localizations.localeOf(context).languageCode == 'de';
    var normalized = url.trim();
    if (normalized.isEmpty) return;
    if (!normalized.startsWith('http://') &&
        !normalized.startsWith('https://')) {
      normalized = 'https://$normalized';
    }
    final uri = Uri.tryParse(normalized);
    if (uri == null) {
      _showSnack(de ? 'Ungültiger Link.' : 'Invalid link.', error: true);
      return;
    }
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      _showSnack(
        de ? 'Link konnte nicht geöffnet werden.' : 'Could not open the link.',
        error: true,
      );
    }
  }

  Future<void> _showReferencesManager(String scope) async {
    final de = Localizations.localeOf(context).languageCode == 'de';
    await showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: _kBorder),
        ),
        insetPadding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 640),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        de ? 'Referenzen' : 'References',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _kText,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: de ? 'Schließen' : 'Close',
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(Icons.close, color: _kMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  de
                      ? 'Benannte Links, z. B. Werkstätten oder Vermieter '
                            '(gerne Google-Maps-Links).'
                      : 'Named links, e.g. workshops or rental partners '
                            '(Google Maps links work great).',
                  style: const TextStyle(fontSize: 12.5, color: _kMuted),
                ),
                const SizedBox(height: 14),
                Flexible(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _referencesCollection(
                      scope,
                    ).orderBy('name').snapshots(),
                    builder: (ctx2, snapshot) {
                      final docs = snapshot.hasData
                          ? snapshot.data!.docs
                          : const <
                              QueryDocumentSnapshot<Map<String, dynamic>>
                            >[];
                      if (docs.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: _kBorder),
                          ),
                          child: Text(
                            de
                                ? 'Noch keine Referenzen angelegt.'
                                : 'No references yet.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: _kMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        itemCount: docs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (ctx3, index) {
                          final doc = docs[index];
                          final data = doc.data();
                          final name = (data['name'] ?? '').toString().trim();
                          final url = (data['url'] ?? '').toString().trim();
                          final email = (data['email'] ?? '')
                              .toString()
                              .trim();
                          final phone = (data['phone'] ?? '')
                              .toString()
                              .trim();
                          final detailLine = [
                            url,
                            email,
                            phone,
                          ].where((v) => v.isNotEmpty).join(' · ');
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _kBorder),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name.isEmpty ? detailLine : name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: _kText,
                                          fontSize: 13.5,
                                        ),
                                      ),
                                      if (detailLine.isNotEmpty)
                                        Text(
                                          detailLine,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: _kMuted,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (detailLine.isNotEmpty)
                                  IconButton(
                                    tooltip: de ? 'Öffnen' : 'Open',
                                    onPressed: () => _openReference(
                                      name: name,
                                      url: url,
                                      email: email,
                                      phone: phone,
                                    ),
                                    visualDensity: VisualDensity.compact,
                                    icon: Icon(
                                      _referenceIcon(
                                        url: url,
                                        email: email,
                                        phone: phone,
                                      ),
                                      size: 18,
                                      color: const Color(0xFF2563EB),
                                    ),
                                  ),
                                IconButton(
                                  tooltip: de ? 'Bearbeiten' : 'Edit',
                                  onPressed: () => _showReferenceEditor(
                                    scope,
                                    documentId: doc.id,
                                    initialName: name,
                                    initialUrl: url,
                                    initialEmail: email,
                                    initialPhone: phone,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 18,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                IconButton(
                                  tooltip: de ? 'Löschen' : 'Delete',
                                  onPressed: () =>
                                      _deleteReference(scope, doc.id, name),
                                  visualDensity: VisualDensity.compact,
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 18,
                                    color: Color(0xFFDC2626),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: CoButton(
                    onPressed: () => _showReferenceEditor(scope),
                    icon: Icons.add,
                    label: de ? 'Referenz hinzufügen' : 'Add reference',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showReferenceEditor(
    String scope, {
    String? documentId,
    String initialName = '',
    String initialUrl = '',
    String initialEmail = '',
    String initialPhone = '',
  }) async {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final nameCtrl = TextEditingController(text: initialName);
    final urlCtrl = TextEditingController(text: initialUrl);
    final emailCtrl = TextEditingController(text: initialEmail);
    final phoneCtrl = TextEditingController(text: initialPhone);
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          documentId == null
              ? (de ? 'Referenz hinzufügen' : 'Add reference')
              : (de ? 'Referenz bearbeiten' : 'Edit reference'),
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        content: SizedBox(
          width: 400,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  autofocus: true,
                  decoration: _referenceInputDecoration(
                    de
                        ? 'Name (z. B. Werkstatt Müller)'
                        : 'Name (e.g. workshop)',
                  ),
                  validator: (value) => (value ?? '').trim().isEmpty
                      ? (de ? 'Name ist erforderlich.' : 'Name is required.')
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: urlCtrl,
                  decoration: _referenceInputDecoration(
                    de
                        ? 'Link / URL (optional, z. B. Google Maps)'
                        : 'Link / URL (optional)',
                  ),
                  validator: (value) {
                    final trimmed = (value ?? '').trim();
                    // Optional — empty is fine, only validate when set.
                    if (trimmed.isEmpty) return null;
                    final withScheme =
                        trimmed.startsWith('http://') ||
                            trimmed.startsWith('https://')
                        ? trimmed
                        : 'https://$trimmed';
                    final uri = Uri.tryParse(withScheme);
                    if (uri == null || uri.host.trim().isEmpty) {
                      return de ? 'Ungültiger Link.' : 'Invalid link.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _referenceInputDecoration(
                    de ? 'E-Mail (optional)' : 'E-mail (optional)',
                  ),
                  validator: (value) {
                    final trimmed = (value ?? '').trim();
                    // Optional — empty is fine, only validate when set.
                    if (trimmed.isEmpty) return null;
                    final valid = RegExp(
                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                    ).hasMatch(trimmed);
                    return valid
                        ? null
                        : (de
                              ? 'Ungültige E-Mail-Adresse.'
                              : 'Invalid e-mail address.');
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: _referenceInputDecoration(
                    de ? 'Telefon (optional)' : 'Phone (optional)',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          CoButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            label: de ? 'Abbrechen' : 'Cancel',
            variant: CoButtonVariant.quiet,
          ),
          CoButton(
            onPressed: () {
              if (!(formKey.currentState?.validate() ?? false)) return;
              Navigator.of(ctx).pop(true);
            },
            label: de ? 'Speichern' : 'Save',
          ),
        ],
      ),
    );

    if (saved == true) {
      var url = urlCtrl.text.trim();
      if (url.isNotEmpty &&
          !url.startsWith('http://') &&
          !url.startsWith('https://')) {
        url = 'https://$url';
      }
      try {
        if (documentId == null) {
          await _referencesCollection(scope).add(<String, dynamic>{
            'name': nameCtrl.text.trim(),
            'url': url,
            'email': emailCtrl.text.trim(),
            'phone': phoneCtrl.text.trim(),
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          await _referencesCollection(
            scope,
          ).doc(documentId).update(<String, dynamic>{
            'name': nameCtrl.text.trim(),
            'url': url,
            'email': emailCtrl.text.trim(),
            'phone': phoneCtrl.text.trim(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      } catch (e) {
        _showSnack(
          de ? 'Speichern fehlgeschlagen: $e' : 'Could not save: $e',
          error: true,
        );
      }
    }
    nameCtrl.dispose();
    urlCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
  }

  InputDecoration _referenceInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _kBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _kBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _kGreen),
      ),
    );
  }

  Future<void> _deleteReference(
    String scope,
    String documentId,
    String name,
  ) async {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(de ? 'Referenz löschen?' : 'Delete reference?'),
        content: Text(
          de
              ? '„$name" wird dauerhaft entfernt.'
              : '"$name" will be removed permanently.',
        ),
        actions: [
          CoButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            label: de ? 'Abbrechen' : 'Cancel',
            variant: CoButtonVariant.quiet,
          ),
          CoButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            label: de ? 'Löschen' : 'Delete',
            variant: CoButtonVariant.destructive,
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _referencesCollection(scope).doc(documentId).delete();
    } catch (e) {
      _showSnack(
        de ? 'Löschen fehlgeschlagen: $e' : 'Could not delete: $e',
        error: true,
      );
    }
  }

  /// Filterleiste nach Handoff: Status-Pills links, rechts Suche,
  /// TÜV-Status, Sortierung und der grüne „+ Neu"-Button mit Klick-Menü
  /// (CSV-Upload (Cortex) · Manuell anlegen).
  Widget _buildFilterBar(
    BuildContext context,
    List<FleetVehicle> vehicles,
    String scope, {
    required bool isNarrow,
    required bool isMobile,
  }) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final pills = _statusPillsRow(vehicles);
    final search = _buildSearchField(context, isMobile: isMobile);

    if (isMobile) {
      // Eine Zeile: Suchfeld füllt die Breite, daneben drei quadratische
      // 48er-Buttons (Filter · Sortierung · Referenzen). Der „+ Neu"-Button
      // entfällt hier — dafür gibt es den schwebenden FAB unten rechts.
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: search),
              const SizedBox(width: 8),
              MobileIconButton(
                icon: Icons.tune,
                tooltip: de ? 'Filter' : 'Filters',
                active: _tuvFilter != _tuvAllValue,
                onTap: _showMobileFilterSheet,
              ),
              const SizedBox(width: 8),
              MobileIconButton(
                icon: Icons.swap_vert,
                tooltip: de ? 'Sortieren' : 'Sort',
                active: _sortColumn != null,
                onTap: _showMobileSortSheet,
              ),
              const SizedBox(width: 8),
              MobileIconButton(
                icon: Icons.contacts_outlined,
                tooltip: de ? 'Referenzen' : 'References',
                active: false,
                onTap: () => _showMobileReferencesSheet(scope),
              ),
            ],
          ),
          const SizedBox(height: 12),
          pills,
        ],
      );
    }

    // Desktop / Tablet: Pills, Suche, TÜV-Filter, Sortierung und „+ Neu".
    final tuvFilter = _buildTuvFilterPill(context);
    final sort = _buildSortPill(context);
    final addButton = _canManageVehicles ? _buildAddMenu(context) : null;

    if (isNarrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          pills,
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: search),
              const SizedBox(width: 8),
              tuvFilter,
              const SizedBox(width: 8),
              sort,
              if (addButton != null) ...[const SizedBox(width: 8), addButton],
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        Flexible(child: pills),
        const SizedBox(width: 12),
        SizedBox(width: 280, child: search),
        const SizedBox(width: 8),
        tuvFilter,
        const SizedBox(width: 8),
        sort,
        if (addButton != null) ...[const SizedBox(width: 8), addButton],
      ],
    );
  }

  Widget _buildSearchField(BuildContext context, {bool isMobile = false}) {
    final t = AppLocalizations.of(context);
    return SizedBox(
      height: isMobile ? 48 : 38,
      child: TextField(
        controller: _searchCtrl,
        onChanged: (value) => setState(() => _search = value),
        style: TextStyle(fontSize: isMobile ? 14 : 12.5, color: _kInk),
        decoration: InputDecoration(
          hintText: t.t('fleet_status_search_hint'),
          hintStyle: TextStyle(fontSize: isMobile ? 14 : 12.5, color: _kFaint),
          prefixIcon: Icon(
            Icons.search,
            size: isMobile ? 20 : 16,
            color: _kFaint,
          ),
          prefixIconConstraints: BoxConstraints(
            minWidth: isMobile ? 46 : 38,
            minHeight: isMobile ? 48 : 38,
          ),
          suffixIcon: buildSearchClearButton(
            context: context,
            value: _search,
            iconSize: isMobile ? 18 : 16,
            onClear: () {
              _searchCtrl.clear();
              setState(() => _search = '');
            },
          ),
          // Desktop pill is only 38px tall — keep the X height-neutral there.
          suffixIconConstraints: isMobile
              ? kSearchClearConstraints
              : kSearchClearConstraintsCompact,
          isDense: true,
          contentPadding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: const BorderSide(color: _kLine),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: const BorderSide(color: _kLine),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: const BorderSide(color: _kAccentGreen, width: 1.4),
          ),
        ),
      ),
    );
  }

  // ─── Mobile Bottom-Sheets (Filter · Sortierung · Referenzen) ──────────
  //
  // Auf schmalen Bildschirmen sitzen TÜV-Filter, Sortierung und die
  // Referenz-Links nicht mehr als Pills bzw. Chip-Zeile in der Leiste,
  // sondern hinter je einem 48er-Icon-Button (siehe
  // `widgets/mobile_filter_controls.dart`).

  /// TÜV-Status-Filter (Platz für weitere Filter ist bewusst vorgesehen).
  Future<void> _showMobileFilterSheet() async {
    final t = AppLocalizations.of(context);
    final de = Localizations.localeOf(context).languageCode == 'de';
    await showMobileSheet<void>(
      context: context,
      title: de ? 'Filter' : 'Filters',
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
            child: Text(
              (de ? 'TÜV-Status' : 'TÜV status').toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: _kFaint,
              ),
            ),
          ),
          MobileSheetOption(
            label: t.t('fleet_status_tuv_filter_all'),
            selected: _tuvFilter == _tuvAllValue,
            onTap: () {
              setState(() => _tuvFilter = _tuvAllValue);
              Navigator.of(ctx).pop();
            },
          ),
          for (final status in FleetVehicleDocumentStatus.values)
            MobileSheetOption(
              label: _tuvStatusPresentationFor(context, status).label,
              selected: _tuvFilter == status.value,
              onTap: () {
                setState(() => _tuvFilter = status.value);
                Navigator.of(ctx).pop();
              },
            ),
        ],
      ),
    );
  }

  /// Sortierung — dieselbe [_onSortTapped]-Logik wie am Desktop: erneutes
  /// Wählen dreht die Richtung, ein dritter Tipp setzt zurück.
  Future<void> _showMobileSortSheet() async {
    final t = AppLocalizations.of(context);
    final de = Localizations.localeOf(context).languageCode == 'de';
    final labels = <String, String>{
      'vehicle': t.t('fleet_status_column_vehicle_number'),
      'model': t.t('fleet_status_column_model'),
      'status': t.t('fleet_status_column_status'),
      'serviceEnd': t.t('fleet_status_column_service_end'),
      'tuv': t.t('fleet_status_column_tuv_status'),
    };
    await showMobileSheet<void>(
      context: context,
      title: de ? 'Sortieren nach' : 'Sort by',
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final entry in labels.entries)
            MobileSheetOption(
              label: entry.value,
              selected: _sortColumn == entry.key,
              trailing: _sortColumn == entry.key
                  ? Icon(
                      _sortAsc
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 18,
                      color: _kAccentGreen,
                    )
                  : null,
              onTap: () {
                _onSortTapped(entry.key);
                Navigator.of(ctx).pop();
              },
            ),
          if (_sortColumn != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _sortColumn = null;
                    _sortAsc = true;
                  });
                  Navigator.of(ctx).pop();
                },
                icon: const Icon(Icons.restart_alt, size: 18),
                style: TextButton.styleFrom(foregroundColor: _kSubtle),
                label: Text(
                  de ? 'Standard-Reihenfolge' : 'Default order',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Referenz-Links (am Desktop die Chip-Zeile über der Liste).
  Future<void> _showMobileReferencesSheet(String scope) async {
    final de = Localizations.localeOf(context).languageCode == 'de';
    await showMobileSheet<void>(
      context: context,
      title: de ? 'Referenzen' : 'References',
      builder: (ctx) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _referencesCollection(scope).orderBy('name').snapshots(),
        builder: (ctx2, snapshot) {
          final docs = snapshot.hasData
              ? snapshot.data!.docs
              : const <QueryDocumentSnapshot<Map<String, dynamic>>>[];
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (docs.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Text(
                    de
                        ? 'Noch keine Links (z. B. Werkstätten, Vermieter).'
                        : 'No links yet (e.g. workshops, rental partners).',
                    style: const TextStyle(fontSize: 13, color: _kSubtle),
                  ),
                ),
              for (final doc in docs)
                MobileSheetOption(
                  icon: _referenceIcon(
                    url: (doc.data()['url'] ?? '').toString(),
                    email: (doc.data()['email'] ?? '').toString(),
                    phone: (doc.data()['phone'] ?? '').toString(),
                  ),
                  label: (doc.data()['name'] ?? '').toString().trim().isEmpty
                      ? (doc.data()['url'] ?? '').toString().trim()
                      : (doc.data()['name'] ?? '').toString().trim(),
                  selected: false,
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _openReference(
                      name: (doc.data()['name'] ?? '').toString().trim(),
                      url: (doc.data()['url'] ?? '').toString().trim(),
                      email: (doc.data()['email'] ?? '').toString().trim(),
                      phone: (doc.data()['phone'] ?? '').toString().trim(),
                    );
                  },
                ),
              if (_canManageVehicles)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: CoButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _showReferencesManager(scope);
                    },
                    icon: Icons.edit_outlined,
                    label: docs.isEmpty
                        ? (de ? 'Referenz hinzufügen' : 'Add reference')
                        : (de ? 'Referenzen verwalten' : 'Manage references'),
                    variant: CoButtonVariant.quiet,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTuvFilterPill(BuildContext context) {
    final t = AppLocalizations.of(context);
    final label = _tuvFilter == _tuvAllValue
        ? t.t('fleet_status_tuv_filter_all')
        : _tuvStatusPresentationFor(
            context,
            FleetVehicleDocumentStatus.values.firstWhere(
              (s) => s.value == _tuvFilter,
              orElse: () => FleetVehicleDocumentStatus.missing,
            ),
          ).label;

    return _FilterPill(
      label: label,
      active: _tuvFilter != _tuvAllValue,
      onSelected: (value) => setState(() => _tuvFilter = value),
      items: [
        PopupMenuItem<String>(
          value: _tuvAllValue,
          child: Text(t.t('fleet_status_tuv_filter_all')),
        ),
        ...FleetVehicleDocumentStatus.values.map(
          (status) => PopupMenuItem<String>(
            value: status.value,
            child: Text(_tuvStatusPresentationFor(context, status).label),
          ),
        ),
      ],
    );
  }

  /// Sortierung als Pill — ersetzt die klickbaren Tabellenköpfe der alten
  /// Liste, ohne die Funktion zu verlieren: dieselbe [_onSortTapped]-Logik
  /// (erneute Auswahl dreht die Richtung, dritte setzt zurück).
  Widget _buildSortPill(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final t = AppLocalizations.of(context);
    final labels = <String, String>{
      'vehicle': t.t('fleet_status_column_vehicle_number'),
      'model': t.t('fleet_status_column_model'),
      'status': t.t('fleet_status_column_status'),
      'serviceEnd': t.t('fleet_status_column_service_end'),
      'tuv': t.t('fleet_status_column_tuv_status'),
    };
    final column = _sortColumn;
    final label = column == null
        ? (de ? 'Sortierung' : 'Sort')
        : '${labels[column] ?? column} ${_sortAsc ? '↑' : '↓'}';

    return _FilterPill(
      label: label,
      active: column != null,
      leading: Icons.swap_vert_rounded,
      onSelected: _onSortTapped,
      items: [
        for (final entry in labels.entries)
          PopupMenuItem<String>(
            value: entry.key,
            child: Row(
              children: [
                Expanded(child: Text(entry.value)),
                if (column == entry.key)
                  Icon(
                    _sortAsc
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    size: 15,
                    color: _kAccentGreen,
                  ),
              ],
            ),
          ),
      ],
    );
  }

  /// Grüner „+ Neu"-Button mit Klick-Menü (Handoff): CSV-Upload (Cortex) und
  /// Manuell anlegen — beide Flows existieren bereits, hier nur neu verpackt.
  Widget _buildAddMenu(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    return PopupMenuButton<String>(
      tooltip: de ? 'Neues Fahrzeug' : 'New vehicle',
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 'cortex') _importFromCortex();
        if (value == 'manual') _showVehicleEditor();
      },
      itemBuilder: (ctx) => [
        PopupMenuItem<String>(
          value: 'cortex',
          child: Row(
            children: [
              const Icon(
                Icons.upload_file_outlined,
                size: 18,
                color: _kAccentGreen,
              ),
              const SizedBox(width: 9),
              Text(
                de ? 'CSV-Upload (Cortex)' : 'CSV upload (Cortex)',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'manual',
          child: Row(
            children: [
              const Icon(
                Icons.edit_note_rounded,
                size: 20,
                color: _kAccentGreen,
              ),
              const SizedBox(width: 9),
              Text(
                de ? 'Manuell anlegen' : 'Add manually',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: _busyCortex ? _kFaint : _kAccentGreen,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, size: 17, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              de ? 'Neu' : 'New',
              style: const TextStyle(
                fontSize: 12.5,
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

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _kBorder),
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: _kMuted, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _kBorder),
        ),
        child: Text(
          AppLocalizations.of(context).t('fleet_status_empty'),
          textAlign: TextAlign.center,
          style: const TextStyle(color: _kMuted, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// Fahrzeugliste im Handoff-Design: eine weiße Karte je Fahrzeug mit
  /// VIN-QR, Kennzeichen-Schild, Besitz-Badge, Leasingzeile, Modell,
  /// Status-Pill, Service-Ende, TÜV- und Fahrzeugschein-Chip.
  Widget _buildVehicleTable(
    BuildContext context,
    List<FleetVehicle> vehicles, {
    required Map<String, _VehicleListComplianceSummary> complianceByPlate,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Unterhalb dieser Breite stapeln sich die Spalten innerhalb der
        // Karte, statt horizontal zu scrollen; unter 700px greift die
        // aufgeräumte Mobile-Karte.
        final wide = constraints.maxWidth >= 1140;
        final mobile = constraints.maxWidth < 700;
        return ListView.separated(
          // Platz für den schwebenden „+"-Button.
          padding: const EdgeInsets.only(bottom: 84),
          itemCount: vehicles.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final vehicle = vehicles[index];
            final compliance =
                complianceByPlate[vehicle.plateNumber] ??
                _defaultComplianceSummary();
            if (mobile) {
              return _buildVehicleCardMobile(
                context,
                vehicle,
                compliance: compliance,
              );
            }
            return _buildVehicleRow(
              context,
              vehicle,
              compliance: compliance,
              wide: wide,
            );
          },
        );
      },
    );
  }

  /// Aufgeräumte Mobile-Karte: links der VIN-QR über die volle Kartenhöhe,
  /// rechts Kennzeichen-Schild, Status-Pill und Besitz-/Leasing-Info, darunter
  /// eine Trennlinie mit der TÜV-/Service-Zeile — ganz rechts ein Chevron.
  /// Ansehen/Bearbeiten/Löschen entfallen hier; alles läuft über die
  /// Detailseite, die durch einen Tipp auf die Karte aufgeht.
  Widget _buildVehicleCardMobile(
    BuildContext context,
    FleetVehicle vehicle, {
    required _VehicleListComplianceSummary compliance,
  }) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final plate = normalizePlateNumber(vehicle.plateNumber);
    final leasing = _leasingByPlate[plate] ?? '';
    final (badgeBg, badgeFg) = _ownerBadgeColors(vehicle.category);
    final modelName = '${vehicle.brand} ${vehicle.model}'.trim();
    final meta = <String>[
      if (modelName.isNotEmpty) modelName,
      _vehicleModelMeta(context, vehicle).replaceAll(' | ', ' · '),
    ].where((part) => part.trim().isNotEmpty).join(' · ');

    final status = _canManageVehicles
        ? _buildTableStatusDropdown(
            context,
            vehicle: vehicle,
            isBusy: _updatingVehicleStatuses.contains(vehicle.plateNumber),
            compact: true,
          )
        : _fleetChip(
            label: _statusLabel(context, vehicle.status),
            foreground: _statusColor(vehicle.status),
            background: _statusColor(vehicle.status).withValues(alpha: 0.12),
          );

    return _HoverRow(
      onTap: () => _showVehicleDetails(vehicle),
      builder: (hovered) => AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: hovered ? const Color(0xFFC6D9D1) : _kLine),
        ),
        clipBehavior: Clip.antiAlias,
        // Die Karte steht in einer ListView, hat also keine vorgegebene Höhe.
        // `IntrinsicHeight` leitet sie aus dem Inhalt ab — erst dadurch darf
        // die Zeile `stretch` benutzen und der QR-Block die volle Kartenhöhe
        // einnehmen.
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // QR-Block: quadratisch über die volle Kartenhöhe. `AspectRatio`
              // leitet die Breite aus der Höhe ab, `FittedBox` skaliert den
              // Code passgenau hinein (nach oben wie nach unten).
              // QR-Block: Tippen öffnet das große QR-Popup (Karte darunter
              // bleibt über den restlichen Bereich klickbar).
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _showQrPopup(context, vehicle),
                child: Container(
                  width: 112,
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(right: BorderSide(color: _kRowLine)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      VinQrTile(
                        size: 84,
                        bordered: false,
                        data: vehicle.vinNumber,
                        tooltip: vehicle.vinNumber.trim().isEmpty
                            ? (de ? 'Keine VIN hinterlegt' : 'No VIN on file')
                            : 'VIN ${vehicle.vinNumber.trim()}',
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'VIN',
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                          color: _kFaint,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 8, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Kennzeichen + Badge-Zeile teilen sich exakt dieselbe
                      // Breite: das Schild gibt sie vor (Höhe 40 → 520:110),
                      // auf sehr schmalen Geräten deckelt der LayoutBuilder.
                      LayoutBuilder(
                        builder: (context, c) {
                          final plateW = (40.0 * 520 / 110).clamp(
                            0.0,
                            c.maxWidth,
                          );
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: plateW,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: LicensePlate.compact(
                                    plate: vehicle.plateNumber,
                                    height: 40,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: plateW,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 22,
                                        child: status,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Container(
                                        height: 22,
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: badgeBg,
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                        child: Text(
                                          leasing.isEmpty
                                              ? _categoryLabel(
                                                  context,
                                                  vehicle.category,
                                                ).toUpperCase()
                                              : leasing.toUpperCase(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.3,
                                            color: badgeFg,
                                            height: 1.35,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      const Divider(height: 1, thickness: 1, color: _kRowLine),
                      const SizedBox(height: 8),
                      _mobileComplianceLine(context, vehicle, compliance),
                      if (meta.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          meta,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: _kFaint,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: Icon(Icons.chevron_right, size: 30, color: _kFaint),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Großes QR-Popup: abgedunkelter Hintergrund, QR groß, darunter
  /// Kennzeichen-Schild und VIN.
  void _showQrPopup(BuildContext context, FleetVehicle vehicle) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final vin = vehicle.vinNumber.trim();
    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) {
        final qrSize = (MediaQuery.of(ctx).size.width - 96).clamp(180.0, 320.0);
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                VinQrTile(size: qrSize, data: vehicle.vinNumber),
                const SizedBox(height: 18),
                LicensePlate.detail(
                  plate: vehicle.plateNumber,
                  width: qrSize.clamp(180.0, 260.0),
                ),
                const SizedBox(height: 14),
                SelectableText(
                  vin.isEmpty
                      ? (de ? 'Keine VIN hinterlegt' : 'No VIN on file')
                      : vin,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: vin.isEmpty ? null : 'monospace',
                    letterSpacing: vin.isEmpty ? 0 : 0.5,
                    color: vin.isEmpty ? _kFaint : _kInk,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// „TÜV 12/10/2026 · Service 01/09/2026" — fehlende Termine amber,
  /// abgelaufene rot, identisch zur Chip-Logik der Desktop-Liste.
  Widget _mobileComplianceLine(
    BuildContext context,
    FleetVehicle vehicle,
    _VehicleListComplianceSummary compliance,
  ) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final expiry =
        (_tuvDocByPlate[normalizePlateNumber(vehicle.plateNumber)]
                    ?.expiryDate ??
                '')
            .trim();
    final expired = compliance.tuvStatus == FleetVehicleDocumentStatus.expired;

    final String tuvValue;
    final Color tuvColor;
    if (expiry.isEmpty && !_scopeDocsLoaded) {
      // Dokumente laden noch — neutraler Platzhalter statt „fehlt".
      tuvValue = '…';
      tuvColor = _kFaint;
    } else if (expiry.isEmpty) {
      tuvValue = de ? 'fehlt' : 'missing';
      tuvColor = _kAccentAmber;
    } else {
      tuvValue = _formatDateString(context, expiry);
      tuvColor = expired
          ? _kAccentRed
          : compliance.tuvStatus == FleetVehicleDocumentStatus.active
          ? _kAccentGreen
          : _kAccentAmber;
    }

    final serviceRaw = vehicle.serviceEndDate.trim();
    final serviceValue = serviceRaw.isEmpty
        ? '—'
        : _formatDateString(context, serviceRaw);

    const labelStyle = TextStyle(
      fontSize: 11.5,
      fontWeight: FontWeight.w600,
      color: _kFaint,
      height: 1.35,
    );

    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(text: 'TÜV ', style: labelStyle),
          TextSpan(
            text: tuvValue,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: tuvColor,
              height: 1.35,
            ),
          ),
          const TextSpan(text: '  ·  ', style: labelStyle),
          TextSpan(text: de ? 'Service ' : 'Service ', style: labelStyle),
          TextSpan(
            text: serviceValue,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: serviceRaw.isEmpty ? _kFaint : _kInk,
              height: 1.35,
            ),
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildVehicleRow(
    BuildContext context,
    FleetVehicle vehicle, {
    required _VehicleListComplianceSummary compliance,
    required bool wide,
  }) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final isUpdatingStatus = _updatingVehicleStatuses.contains(
      vehicle.plateNumber,
    );

    final status = _canManageVehicles
        ? _buildTableStatusDropdown(
            context,
            vehicle: vehicle,
            isBusy: isUpdatingStatus,
          )
        : Align(
            alignment: Alignment.centerLeft,
            child: _fleetChip(
              label: _statusLabel(context, vehicle.status),
              foreground: _statusColor(vehicle.status),
              background: _statusColor(vehicle.status).withValues(alpha: 0.12),
            ),
          );

    final workshopLabel = _workshopRowLabel(context, vehicle);
    final serviceBlock = _rowCaptioned(
      caption: de ? 'Nächster Service' : 'Next service',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _serviceEndLabel(context, vehicle),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: vehicle.serviceEndDate.trim().isEmpty ? _kFaint : _kInk,
              height: 1.3,
            ),
          ),
          if (workshopLabel != null)
            Text(
              workshopLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: _kFaint,
                height: 1.35,
              ),
            ),
        ],
      ),
    );
    final tuvBlock = _rowCaptioned(
      caption: 'TÜV',
      child: _tuvChip(context, vehicle, compliance),
    );
    final registrationBlock = _rowCaptioned(
      caption: 'Fahrzeugschein',
      child: _registrationChip(context, vehicle),
    );

    final Widget content;
    if (wide) {
      content = Row(
        children: [
          VinQrTile(
            data: vehicle.vinNumber,
            tooltip: vehicle.vinNumber.trim().isEmpty
                ? (de ? 'Keine VIN hinterlegt' : 'No VIN on file')
                : 'VIN ${vehicle.vinNumber.trim()}',
          ),
          const SizedBox(width: 12),
          SizedBox(width: 176, child: _rowPlateBlock(context, vehicle)),
          const SizedBox(width: 12),
          Expanded(child: _rowModelBlock(context, vehicle)),
          const SizedBox(width: 12),
          SizedBox(width: 150, child: status),
          const SizedBox(width: 12),
          SizedBox(width: 126, child: serviceBlock),
          const SizedBox(width: 12),
          SizedBox(width: 104, child: tuvBlock),
          const SizedBox(width: 12),
          SizedBox(width: 120, child: registrationBlock),
          const SizedBox(width: 12),
          _rowActions(context, vehicle),
        ],
      );
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VinQrTile(size: 60, data: vehicle.vinNumber),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _rowPlateBlock(context, vehicle),
                    const SizedBox(height: 8),
                    _rowModelBlock(context, vehicle),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _rowActions(context, vehicle),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              SizedBox(width: 150, child: status),
              SizedBox(width: 126, child: serviceBlock),
              SizedBox(width: 104, child: tuvBlock),
              SizedBox(width: 120, child: registrationBlock),
            ],
          ),
        ],
      );
    }

    return _HoverRow(
      onTap: () => _showVehicleDetails(vehicle),
      builder: (hovered) => AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          // Handoff: Hover färbt den Rand grünlich ein.
          border: Border.all(color: hovered ? const Color(0xFFC6D9D1) : _kLine),
        ),
        child: content,
      ),
    );
  }

  /// Kennzeichen-Schild + Besitz-Badge + Leasingzeile.
  Widget _rowPlateBlock(BuildContext context, FleetVehicle vehicle) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final leasing =
        _leasingByPlate[normalizePlateNumber(vehicle.plateNumber)] ?? '';
    final (badgeBg, badgeFg) = _ownerBadgeColors(vehicle.category);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        LicensePlate.compact(plate: vehicle.plateNumber),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            _categoryLabel(context, vehicle.category).toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: badgeFg,
              height: 1.35,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.handshake_outlined, size: 13, color: _kFaint),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                leasing.isEmpty
                    ? (de ? 'Kein Leasinggeber' : 'No lessor')
                    : leasing,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: leasing.isEmpty ? _kFaint : _kSubtle,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _rowModelBlock(BuildContext context, FleetVehicle vehicle) {
    final t = AppLocalizations.of(context);
    final modelName = '${vehicle.brand} ${vehicle.model}'.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          modelName.isEmpty
              ? t.t('fleet_status_vehicle_details_not_set')
              : modelName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: _kInk,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _vehicleModelMeta(context, vehicle),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, color: _kFaint, height: 1.3),
        ),
      ],
    );
  }

  Widget _rowCaptioned({required String caption, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          caption.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
            color: _kFaint,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 3),
        child,
      ],
    );
  }

  Widget _rowActions(BuildContext context, FleetVehicle vehicle) {
    final t = AppLocalizations.of(context);
    if (!_canManageVehicles) {
      return _buildTableActionButton(
        tooltip: t.t('fleet_status_action_view_details'),
        icon: Icons.visibility_outlined,
        color: _kFaint,
        onPressed: () => _showVehicleDetails(vehicle),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTableActionButton(
          tooltip: t.t('fleet_status_action_view_details'),
          icon: Icons.visibility_outlined,
          color: _kFaint,
          onPressed: () => _showVehicleDetails(vehicle),
        ),
        const SizedBox(width: 6),
        _buildTableActionButton(
          tooltip: t.t('button_edit'),
          icon: Icons.edit_outlined,
          color: _kFaint,
          onPressed: () => _showVehicleEditor(vehicle: vehicle),
        ),
        const SizedBox(width: 6),
        _buildTableActionButton(
          tooltip: t.t('fleet_status_action_delete'),
          icon: Icons.delete_outline,
          color: const Color(0xFFC9A0A0),
          onPressed: () => _deleteVehicle(vehicle),
        ),
      ],
    );
  }

  /// TÜV-Chip: Datum in Grün/Amber/Rot je nach Gültigkeit, „fehlt" in Amber,
  /// wenn kein Termin hinterlegt ist.
  Widget _tuvChip(
    BuildContext context,
    FleetVehicle vehicle,
    _VehicleListComplianceSummary compliance,
  ) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final expiry =
        (_tuvDocByPlate[normalizePlateNumber(vehicle.plateNumber)]
                    ?.expiryDate ??
                '')
            .trim();
    if (expiry.isEmpty) {
      if (!_scopeDocsLoaded) {
        // Dokumente laden noch — neutraler Platzhalter statt „fehlt".
        return _fleetChip(
          label: '…',
          foreground: _kFaint,
          background: _kRowLine,
        );
      }
      return _fleetChip(
        label: de ? 'fehlt' : 'missing',
        foreground: _kAccentAmber,
        background: _kAccentAmberTint,
      );
    }
    final presentation = _tuvStatusPresentationFor(
      context,
      compliance.tuvStatus,
    );
    final expired = compliance.tuvStatus == FleetVehicleDocumentStatus.expired;
    return Tooltip(
      message: presentation.label,
      waitDuration: const Duration(milliseconds: 500),
      child: _fleetChip(
        label: _formatDateString(context, expiry),
        foreground: expired ? _kAccentRed : presentation.color,
        background: expired
            ? _kAccentRedTint
            : compliance.tuvStatus == FleetVehicleDocumentStatus.active
            ? _kAccentGreenTint
            : _kAccentAmberTint,
      ),
    );
  }

  Widget _registrationChip(BuildContext context, FleetVehicle vehicle) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final present = _registrationPlates.contains(
      normalizePlateNumber(vehicle.plateNumber),
    );
    if (!present && !_scopeDocsLoaded) {
      // Dokumente laden noch — neutraler Platzhalter statt „fehlt".
      return _fleetChip(label: '…', foreground: _kFaint, background: _kRowLine);
    }
    return _fleetChip(
      label: present
          ? (de ? 'vorhanden' : 'available')
          : (de ? 'fehlt' : 'missing'),
      icon: present ? Icons.check_circle_outline : Icons.error_outline,
      foreground: present ? _kAccentGreen : _kAccentRed,
      background: present ? _kAccentGreenTint : _kAccentRedTint,
    );
  }

  Widget _fleetChip({
    required String label,
    required Color foreground,
    required Color background,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: foreground),
            const SizedBox(width: 3),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: foreground,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Farbpaar des Besitz-Badges (Handoff): Armada grün, SESO Rental blau,
  /// Amazon Rental orange, LMR violett, alles Weitere grau.
  (Color, Color) _ownerBadgeColors(VehicleCategory category) {
    switch (category) {
      case VehicleCategory.armada:
        return (_kAccentGreenTint, _kAccentGreen);
      case VehicleCategory.sesoRental:
        return (_kAccentBlueTint, _kAccentBlue);
      case VehicleCategory.amazonPaidRental:
        return (_kAccentOrangeTint, _kAccentOrange);
      case VehicleCategory.lmr:
        return (_kAccentVioletTint, _kAccentViolet);
      case VehicleCategory.selfSourcedRental:
      case VehicleCategory.selfOwnedRental:
        return (const Color(0xFFEEF1F4), _kSubtle);
    }
  }

  /// Status-Pill mit Dropdown (Handoff) — dieselbe Auswahl-Logik wie zuvor,
  /// nur im neuen Chip-Design.
  Widget _buildTableStatusDropdown(
    BuildContext context, {
    required FleetVehicle vehicle,
    required bool isBusy,
    bool compact = false,
  }) {
    final statusColor = _statusColor(vehicle.status);
    final double fontSize = compact ? 9 : 12.5;
    return Container(
      height: compact ? 22 : 32,
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: statusColor.withValues(alpha: 0.22)),
      ),
      child: isBusy
          ? Row(
              children: [
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).t('fleet_status_loading'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: fontSize,
                    ),
                  ),
                ),
              ],
            )
          : DropdownButtonHideUnderline(
              child: DropdownButton<VehicleStatus>(
                value: vehicle.status,
                isDense: true,
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: statusColor,
                  size: compact ? 13 : 16,
                ),
                style: TextStyle(
                  color: statusColor,
                  fontWeight: compact ? FontWeight.w700 : FontWeight.w600,
                  fontSize: fontSize,
                  letterSpacing: compact ? 0.3 : 0,
                ),
                // Kompakt (Mobile): Anzeige wie die Kategorie-Pille —
                // uppercase, zentriert, bei Überlänge abgekürzt.
                selectedItemBuilder: !compact
                    ? null
                    : (ctx) => VehicleStatus.values
                          .map(
                            (status) => Center(
                              child: Text(
                                _statusLabel(ctx, status).toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                dropdownColor: Colors.white,
                elevation: 8,
                borderRadius: BorderRadius.circular(14),
                onChanged: (value) {
                  if (value == null) return;
                  _handleVehicleStatusSelection(vehicle, value);
                },
                items: VehicleStatus.values
                    .map(
                      (status) => DropdownMenuItem<VehicleStatus>(
                        value: status,
                        child: Text(
                          _statusLabel(context, status),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
    );
  }

  String _vehicleModelMeta(BuildContext context, FleetVehicle vehicle) {
    final parts = <String>[];
    if (vehicle.manufacturingYear > 0) {
      parts.add('${vehicle.manufacturingYear}');
    }
    parts.add(_fuelTypeLabel(context, vehicle.fuelType));

    return parts.join(' | ');
  }

  String _serviceEndLabel(BuildContext context, FleetVehicle vehicle) {
    return _optionalStoredDate(context, vehicle.serviceEndDate);
  }

  Widget _buildTableActionButton({
    required String tooltip,
    required IconData icon,
    required VoidCallback onPressed,
    Color color = const Color(0xFF4B5563),
  }) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(width: 28, height: 28),
      icon: Icon(icon, size: 20, color: color),
    );
  }
}

/// Kompakte Filter-Pill mit Klick-Menü (Handoff): heller Rahmen, Label,
/// Chevron — aktiv gesetzte Filter bekommen den grünen Akzent.
class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.items,
    required this.onSelected,
    this.active = false,
    this.leading,
  });

  final String label;
  final List<PopupMenuEntry<String>> items;
  final ValueChanged<String> onSelected;
  final bool active;
  final IconData? leading;

  @override
  Widget build(BuildContext context) {
    final foreground = active
        ? _FleetStatusPageState._kAccentGreen
        : _FleetStatusPageState._kSubtle;
    return PopupMenuButton<String>(
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: onSelected,
      itemBuilder: (_) => items,
      child: Container(
        height: 38,
        // Deckelt lange Labels (z. B. „Fahrzeugnummer ↑"), damit die
        // Filterleiste auf schmalen Bildschirmen nicht überläuft.
        constraints: const BoxConstraints(maxWidth: 210),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active
                ? _FleetStatusPageState._kAccentGreen
                : _FleetStatusPageState._kLine,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[
              Icon(leading, size: 15, color: foreground),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: foreground,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, size: 15, color: foreground),
          ],
        ),
      ),
    );
  }
}

/// Flutter web's default [ScrollBehavior] only lets touch/stylus/trackpad
/// drag a scroll view — a mouse click-and-drag does nothing on desktop
/// Chrome. The references chips row needs mouse-drag too, so it stays
/// reachable without relying on the (also added) Scrollbar thumb.
class _HorizontalDragScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => const {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.unknown,
  };
}

/// Result of the vehicle editor: the vehicle draft itself plus the side
/// data that is stored outside the vehicle document (workshop, TÜV date).
class _VehicleEditorResult {
  const _VehicleEditorResult({
    required this.draft,
    required this.workshop,
    required this.tuvDate,
    required this.remarks,
  });

  final FleetVehicleDraft draft;
  final String workshop;
  final String tuvDate;
  final String remarks;
}

class _VehicleEditorDialog extends StatefulWidget {
  const _VehicleEditorDialog({
    required this.vehicle,
    this.initialWorkshop = '',
    this.initialTuvDate = '',
    this.initialRemarks = '',
  });

  final FleetVehicle? vehicle;
  final String initialWorkshop;
  final String initialTuvDate;
  final String initialRemarks;

  @override
  State<_VehicleEditorDialog> createState() => _VehicleEditorDialogState();
}

class _VehicleEditorDialogState extends State<_VehicleEditorDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _plateNumberCtrl;
  late final TextEditingController _brandCtrl;
  late final TextEditingController _modelCtrl;
  late final TextEditingController _manufacturingYearCtrl;
  late final TextEditingController _vinCtrl;
  late final TextEditingController _serviceEndDateCtrl;
  late final TextEditingController _notesCtrl;

  late final TextEditingController _armadaIdCtrl;
  late final TextEditingController _armadaCompanyCtrl;
  late final TextEditingController _armadaStartCtrl;
  late final TextEditingController _armadaEndCtrl;

  late final TextEditingController _amazonCompanyCtrl;
  late final TextEditingController _amazonContractCtrl;
  late final TextEditingController _amazonStartCtrl;
  late final TextEditingController _amazonEndCtrl;

  late final TextEditingController _ownerNameCtrl;
  late final TextEditingController _ownerContactCtrl;
  late final TextEditingController _rentalAgreementCtrl;
  late final TextEditingController _selfSourcedStartCtrl;
  late final TextEditingController _selfSourcedEndCtrl;

  late final TextEditingController _ownershipTypeCtrl;
  late final TextEditingController _purchaseDateCtrl;

  late final TextEditingController _workshopCtrl;
  late final TextEditingController _tuvDateCtrl;
  late final TextEditingController _remarksCtrl;

  late VehicleCategory _category;
  late VehicleFuelType _fuelType;
  late VehicleStatus _status;

  bool get _isEditing => widget.vehicle != null;

  @override
  void initState() {
    super.initState();
    final vehicle = widget.vehicle;
    _plateNumberCtrl = TextEditingController(text: vehicle?.plateNumber ?? '');
    _brandCtrl = TextEditingController(text: vehicle?.brand ?? '');
    _modelCtrl = TextEditingController(text: vehicle?.model ?? '');
    _manufacturingYearCtrl = TextEditingController(
      text: vehicle == null || vehicle.manufacturingYear == 0
          ? ''
          : '${vehicle.manufacturingYear}',
    );
    _vinCtrl = TextEditingController(text: vehicle?.vinNumber ?? '');
    _serviceEndDateCtrl = TextEditingController(
      text: vehicle?.serviceEndDate ?? '',
    );
    _notesCtrl = TextEditingController(text: vehicle?.notes ?? '');

    _category = vehicle?.category ?? VehicleCategory.armada;
    _fuelType = vehicle?.fuelType ?? VehicleFuelType.diesel;
    _status = vehicle?.status ?? VehicleStatus.active;

    final armadaMetadata = vehicle?.metadata is ArmadaVehicleMetadata
        ? vehicle!.metadata as ArmadaVehicleMetadata
        : const ArmadaVehicleMetadata();
    _armadaIdCtrl = TextEditingController(text: armadaMetadata.armadaId);
    _armadaCompanyCtrl = TextEditingController(
      text: armadaMetadata.armadaCompanyName,
    );
    _armadaStartCtrl = TextEditingController(
      text: armadaMetadata.contractStartDate,
    );
    _armadaEndCtrl = TextEditingController(
      text: armadaMetadata.contractEndDate,
    );

    final amazonMetadata = vehicle?.metadata is AmazonPaidRentalMetadata
        ? vehicle!.metadata as AmazonPaidRentalMetadata
        : const AmazonPaidRentalMetadata();
    _amazonCompanyCtrl = TextEditingController(
      text: amazonMetadata.rentalCompanyName,
    );
    _amazonContractCtrl = TextEditingController(
      text: amazonMetadata.contractNumber,
    );
    _amazonStartCtrl = TextEditingController(
      text: amazonMetadata.rentalStartDate,
    );
    _amazonEndCtrl = TextEditingController(text: amazonMetadata.rentalEndDate);

    final selfSourcedMetadata = vehicle?.metadata is SelfSourcedRentalMetadata
        ? vehicle!.metadata as SelfSourcedRentalMetadata
        : const SelfSourcedRentalMetadata();
    _ownerNameCtrl = TextEditingController(text: selfSourcedMetadata.ownerName);
    _ownerContactCtrl = TextEditingController(
      text: selfSourcedMetadata.ownerContactNumber,
    );
    _rentalAgreementCtrl = TextEditingController(
      text: selfSourcedMetadata.rentalAgreementNumber,
    );
    _selfSourcedStartCtrl = TextEditingController(
      text: selfSourcedMetadata.rentalStartDate,
    );
    _selfSourcedEndCtrl = TextEditingController(
      text: selfSourcedMetadata.rentalEndDate,
    );

    final selfOwnedMetadata = vehicle?.metadata is SelfOwnedRentalMetadata
        ? vehicle!.metadata as SelfOwnedRentalMetadata
        : const SelfOwnedRentalMetadata();
    _ownershipTypeCtrl = TextEditingController(
      text: selfOwnedMetadata.ownershipType,
    );
    _purchaseDateCtrl = TextEditingController(
      text: selfOwnedMetadata.purchaseDate,
    );

    _workshopCtrl = TextEditingController(text: widget.initialWorkshop);
    _tuvDateCtrl = TextEditingController(text: widget.initialTuvDate);
    _remarksCtrl = TextEditingController(text: widget.initialRemarks);
  }

  @override
  void dispose() {
    for (final controller in [
      _plateNumberCtrl,
      _brandCtrl,
      _modelCtrl,
      _manufacturingYearCtrl,
      _vinCtrl,
      _serviceEndDateCtrl,
      _notesCtrl,
      _armadaIdCtrl,
      _armadaCompanyCtrl,
      _armadaStartCtrl,
      _armadaEndCtrl,
      _amazonCompanyCtrl,
      _amazonContractCtrl,
      _amazonStartCtrl,
      _amazonEndCtrl,
      _ownerNameCtrl,
      _ownerContactCtrl,
      _rentalAgreementCtrl,
      _selfSourcedStartCtrl,
      _selfSourcedEndCtrl,
      _ownershipTypeCtrl,
      _purchaseDateCtrl,
      _workshopCtrl,
      _tuvDateCtrl,
      _remarksCtrl,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final parsed = DateTime.tryParse(controller.text.trim());
    final picked = await showDatePicker(
      context: context,
      initialDate: parsed ?? now,
      firstDate: DateTime(now.year - 20),
      lastDate: DateTime(now.year + 20),
    );
    if (picked == null) return;
    controller.text =
        '${picked.year.toString().padLeft(4, '0')}-'
        '${picked.month.toString().padLeft(2, '0')}-'
        '${picked.day.toString().padLeft(2, '0')}';
    if (mounted) setState(() {});
  }

  void _submit() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    final manufacturingYear =
        int.tryParse(_manufacturingYearCtrl.text.trim()) ?? 0;

    Navigator.of(context).pop(
      _VehicleEditorResult(
        draft: FleetVehicleDraft(
          plateNumber: normalizePlateNumber(_plateNumberCtrl.text),
          category: _category,
          brand: _brandCtrl.text.trim(),
          model: _modelCtrl.text.trim(),
          manufacturingYear: manufacturingYear,
          vinNumber: _vinCtrl.text.trim(),
          fuelType: _fuelType,
          status: _status,
          serviceEndDate: _serviceEndDateCtrl.text.trim(),
          metadata: _metadataForCategory(),
          notes: _notesCtrl.text.trim(),
        ),
        workshop: _status == VehicleStatus.groundedService
            ? _workshopCtrl.text.trim()
            : widget.initialWorkshop.trim(),
        tuvDate: _tuvDateCtrl.text.trim(),
        remarks: _remarksCtrl.text.trim(),
      ),
    );
  }

  VehicleMetadata _metadataForCategory() {
    switch (_category) {
      case VehicleCategory.armada:
        return ArmadaVehicleMetadata(
          armadaId: _armadaIdCtrl.text,
          armadaCompanyName: _armadaCompanyCtrl.text,
          contractStartDate: _armadaStartCtrl.text,
          contractEndDate: _armadaEndCtrl.text,
        );
      case VehicleCategory.amazonPaidRental:
        return AmazonPaidRentalMetadata(
          rentalCompanyName: _amazonCompanyCtrl.text,
          contractNumber: _amazonContractCtrl.text,
          rentalStartDate: _amazonStartCtrl.text,
          rentalEndDate: _amazonEndCtrl.text,
        );
      case VehicleCategory.selfSourcedRental:
        return SelfSourcedRentalMetadata(
          ownerName: _ownerNameCtrl.text,
          ownerContactNumber: _ownerContactCtrl.text,
          rentalAgreementNumber: _rentalAgreementCtrl.text,
          rentalStartDate: _selfSourcedStartCtrl.text,
          rentalEndDate: _selfSourcedEndCtrl.text,
        );
      case VehicleCategory.selfOwnedRental:
        return SelfOwnedRentalMetadata(
          ownershipType: _ownershipTypeCtrl.text,
          purchaseDate: _purchaseDateCtrl.text,
        );
      case VehicleCategory.lmr:
      case VehicleCategory.sesoRental:
        return const GenericVehicleMetadata();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Dialog(
      elevation: 8,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 920),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.t(
                    _isEditing
                        ? 'fleet_status_form_edit_title'
                        : 'fleet_status_form_add_title',
                  ),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 18),
                _SectionTitle(text: t.t('fleet_status_section_general')),
                const SizedBox(height: 12),
                // Das Kennzeichen ist zugleich die Doc-ID. Es lässt sich
                // ändern — beim Speichern zieht dann der gesamte Anhang mit
                // (Dokumente, Events, Bemerkungen); der Bestätigungsdialog
                // erklärt das vor dem Umzug.
                TextFormField(
                  controller: _plateNumberCtrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: _inputDecoration(
                    label: t.t('fleet_status_field_plate_number'),
                    helperText: _isEditing
                        ? (Localizations.localeOf(context).languageCode == 'de'
                              ? 'Änderung zieht Dokumente, Events und '
                                    'Bemerkungen mit um.'
                              : 'Changing it moves documents, events and '
                                    'remarks along.')
                        : null,
                  ),
                  validator: (value) => _requiredText(
                    context,
                    value,
                    t.t('fleet_status_field_plate_number'),
                  ),
                ),
                const SizedBox(height: 14),
                // Vehicle category as a quick button (chip) selector.
                Text(
                  t.t('fleet_status_field_category'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Die fünf geführten Kategorien; die Metadatenfelder
                    // darunter richten sich nach der Auswahl.
                    for (final category in const [
                      VehicleCategory.armada,
                      VehicleCategory.sesoRental,
                      VehicleCategory.amazonPaidRental,
                      VehicleCategory.lmr,
                      VehicleCategory.selfOwnedRental,
                    ])
                      ChoiceChip(
                        label: Text(_categoryLabel(context, category)),
                        selected: _category == category,
                        showCheckmark: false,
                        onSelected: (sel) {
                          if (sel) setState(() => _category = category);
                        },
                        selectedColor: const Color(0xFF1D7F5A),
                        backgroundColor: const Color(0xFFF3F4F6),
                        labelStyle: TextStyle(
                          color: _category == category
                              ? Colors.white
                              : const Color(0xFF374151),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: _category == category
                                ? const Color(0xFF1D7F5A)
                                : const Color(0xFFE5E7EB),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _brandCtrl,
                        decoration: _inputDecoration(
                          label: t.t('fleet_status_field_brand'),
                        ),
                        validator: (value) => _requiredText(
                          context,
                          value,
                          t.t('fleet_status_field_brand'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: TextFormField(
                        controller: _modelCtrl,
                        decoration: _inputDecoration(
                          label: t.t('fleet_status_field_model'),
                        ),
                        validator: (value) => _requiredText(
                          context,
                          value,
                          t.t('fleet_status_field_model'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _manufacturingYearCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: _inputDecoration(
                          label: t.t('fleet_status_field_manufacturing_year'),
                        ),
                        validator: (value) {
                          if ((value ?? '').trim().isEmpty) {
                            return t.tf('error_required', {
                              'field': t.t(
                                'fleet_status_field_manufacturing_year',
                              ),
                            });
                          }
                          return int.tryParse((value ?? '').trim()) == null
                              ? t.t('fleet_status_number_invalid')
                              : null;
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: DropdownButtonFormField<VehicleFuelType>(
                        value: _fuelType,
                        decoration: _inputDecoration(
                          label: t.t('fleet_status_field_fuel_type'),
                        ),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _fuelType = value);
                        },
                        dropdownColor: Colors.white,
                        elevation: 8,
                        borderRadius: BorderRadius.circular(14),
                        items: VehicleFuelType.values
                            .map(
                              (fuel) => DropdownMenuItem<VehicleFuelType>(
                                value: fuel,
                                child: Text(_fuelTypeLabel(context, fuel)),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _vinCtrl,
                  decoration: _inputDecoration(
                    label: t.t('fleet_status_field_vin_number'),
                  ),
                  validator: (value) => _requiredText(
                    context,
                    value,
                    t.t('fleet_status_field_vin_number'),
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<VehicleStatus>(
                  value: _status,
                  decoration: _inputDecoration(
                    label: t.t('fleet_status_field_status'),
                  ),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _status = value);
                  },
                  dropdownColor: Colors.white,
                  elevation: 8,
                  borderRadius: BorderRadius.circular(14),
                  items: VehicleStatus.values
                      .map(
                        (status) => DropdownMenuItem<VehicleStatus>(
                          value: status,
                          child: Text(_statusLabel(context, status)),
                        ),
                      )
                      .toList(),
                ),
                if (_status.isGrounded) ...[
                  const SizedBox(height: 14),
                  _DateInputField(
                    controller: _serviceEndDateCtrl,
                    label: t.t('fleet_status_field_service_end_date'),
                    onPick: () => _pickDate(_serviceEndDateCtrl),
                    validator: (value) {
                      final trimmed = (value ?? '').trim();
                      if (trimmed.isEmpty) return null;
                      if (!isValidVehicleDate(trimmed)) {
                        return t.t('fleet_status_invalid_date');
                      }
                      return null;
                    },
                  ),
                  if (_serviceEndDateCtrl.text.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: CoButton(
                        onPressed: () =>
                            setState(() => _serviceEndDateCtrl.clear()),
                        label: t.t('fleet_status_clear_date'),
                        variant: CoButtonVariant.quiet,
                      ),
                    ),
                  ],
                ],
                if (_status == VehicleStatus.groundedService) ...[
                  const SizedBox(height: 14),
                  // Grounded (Service): where was the vehicle sent for
                  // repairs?
                  Builder(
                    builder: (context) {
                      final de =
                          Localizations.localeOf(context).languageCode == 'de';
                      return TextFormField(
                        controller: _workshopCtrl,
                        decoration: _inputDecoration(
                          label: de
                              ? 'Werkstatt (wohin wurde das Fahrzeug gebracht?)'
                              : 'Workshop (where was the vehicle sent?)',
                        ),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 18),
                Builder(
                  builder: (context) {
                    final de =
                        Localizations.localeOf(context).languageCode == 'de';
                    return _SectionTitle(
                      text: de ? 'TÜV / Hauptuntersuchung' : 'TÜV / inspection',
                    );
                  },
                ),
                const SizedBox(height: 12),
                Builder(
                  builder: (context) {
                    final de =
                        Localizations.localeOf(context).languageCode == 'de';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DateInputField(
                          controller: _tuvDateCtrl,
                          label: de
                              ? 'TÜV gültig bis (HU-Datum, optional)'
                              : 'TÜV valid until (inspection date, optional)',
                          onPick: () => _pickDate(_tuvDateCtrl),
                          validator: (value) {
                            final trimmed = (value ?? '').trim();
                            if (trimmed.isEmpty) return null;
                            if (!isValidVehicleDate(trimmed)) {
                              return t.t('fleet_status_invalid_date');
                            }
                            return null;
                          },
                        ),
                        if (_tuvDateCtrl.text.trim().isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerRight,
                            child: CoButton(
                              onPressed: () =>
                                  setState(() => _tuvDateCtrl.clear()),
                              label: t.t('fleet_status_clear_date'),
                              variant: CoButtonVariant.quiet,
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
                const SizedBox(height: 18),
                _SectionTitle(text: t.t('fleet_status_section_metadata')),
                const SizedBox(height: 12),
                _buildMetadataFields(context),
                const SizedBox(height: 18),
                _SectionTitle(text: t.t('fleet_status_section_notes')),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesCtrl,
                  minLines: 3,
                  maxLines: 5,
                  decoration: _inputDecoration(
                    label: t.t('fleet_status_field_notes'),
                  ),
                ),
                const SizedBox(height: 18),
                Builder(
                  builder: (context) {
                    final de =
                        Localizations.localeOf(context).languageCode == 'de';
                    return _SectionTitle(text: de ? 'Bemerkungen' : 'Remarks');
                  },
                ),
                const SizedBox(height: 12),
                Builder(
                  builder: (context) {
                    final de =
                        Localizations.localeOf(context).languageCode == 'de';
                    return TextFormField(
                      controller: _remarksCtrl,
                      minLines: 3,
                      maxLines: 5,
                      decoration: _inputDecoration(
                        label: de ? 'Bemerkungen / Remarks' : 'Remarks',
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CoButton(
                      onPressed: () => Navigator.of(context).pop(),
                      label: t.t('button_close'),
                      variant: CoButtonVariant.quiet,
                    ),
                    const SizedBox(width: 10),
                    CoButton(
                      onPressed: _submit,
                      label: t.t(
                        _isEditing
                            ? 'button_save'
                            : 'fleet_status_create_action',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetadataFields(BuildContext context) {
    switch (_category) {
      case VehicleCategory.armada:
        return Column(
          children: [
            TextFormField(
              controller: _armadaIdCtrl,
              decoration: _inputDecoration(
                label: AppLocalizations.of(
                  context,
                ).t('fleet_status_field_armada_id'),
              ),
              validator: (value) => _requiredText(
                context,
                value,
                AppLocalizations.of(context).t('fleet_status_field_armada_id'),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _armadaCompanyCtrl,
              decoration: _inputDecoration(
                label: AppLocalizations.of(
                  context,
                ).t('fleet_status_field_armada_company_name'),
              ),
              validator: (value) => _requiredText(
                context,
                value,
                AppLocalizations.of(
                  context,
                ).t('fleet_status_field_armada_company_name'),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _DateInputField(
                    controller: _armadaStartCtrl,
                    label: AppLocalizations.of(
                      context,
                    ).t('fleet_status_field_contract_start_date'),
                    onPick: () => _pickDate(_armadaStartCtrl),
                    validator: (value) => _requiredDate(
                      context,
                      value,
                      AppLocalizations.of(
                        context,
                      ).t('fleet_status_field_contract_start_date'),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _DateInputField(
                    controller: _armadaEndCtrl,
                    label: AppLocalizations.of(
                      context,
                    ).t('fleet_status_field_contract_end_date'),
                    onPick: () => _pickDate(_armadaEndCtrl),
                    validator: (value) => _requiredDate(
                      context,
                      value,
                      AppLocalizations.of(
                        context,
                      ).t('fleet_status_field_contract_end_date'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      case VehicleCategory.amazonPaidRental:
        return Column(
          children: [
            TextFormField(
              controller: _amazonCompanyCtrl,
              decoration: _inputDecoration(
                label: AppLocalizations.of(
                  context,
                ).t('fleet_status_field_rental_company_name'),
              ),
              validator: (value) => _requiredText(
                context,
                value,
                AppLocalizations.of(
                  context,
                ).t('fleet_status_field_rental_company_name'),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _amazonContractCtrl,
              decoration: _inputDecoration(
                label: AppLocalizations.of(
                  context,
                ).t('fleet_status_field_contract_number'),
              ),
              validator: (value) => _requiredText(
                context,
                value,
                AppLocalizations.of(
                  context,
                ).t('fleet_status_field_contract_number'),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _DateInputField(
                    controller: _amazonStartCtrl,
                    label: AppLocalizations.of(
                      context,
                    ).t('fleet_status_field_rental_start_date'),
                    onPick: () => _pickDate(_amazonStartCtrl),
                    validator: (value) => _requiredDate(
                      context,
                      value,
                      AppLocalizations.of(
                        context,
                      ).t('fleet_status_field_rental_start_date'),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _DateInputField(
                    controller: _amazonEndCtrl,
                    label: AppLocalizations.of(
                      context,
                    ).t('fleet_status_field_rental_end_date'),
                    onPick: () => _pickDate(_amazonEndCtrl),
                    validator: (value) => _requiredDate(
                      context,
                      value,
                      AppLocalizations.of(
                        context,
                      ).t('fleet_status_field_rental_end_date'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      case VehicleCategory.selfSourcedRental:
        return Column(
          children: [
            TextFormField(
              controller: _ownerNameCtrl,
              decoration: _inputDecoration(
                label: AppLocalizations.of(
                  context,
                ).t('fleet_status_field_owner_name'),
              ),
              validator: (value) => _requiredText(
                context,
                value,
                AppLocalizations.of(context).t('fleet_status_field_owner_name'),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _ownerContactCtrl,
              decoration: _inputDecoration(
                label: AppLocalizations.of(
                  context,
                ).t('fleet_status_field_owner_contact_number'),
              ),
              validator: (value) => _requiredText(
                context,
                value,
                AppLocalizations.of(
                  context,
                ).t('fleet_status_field_owner_contact_number'),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _rentalAgreementCtrl,
              decoration: _inputDecoration(
                label: AppLocalizations.of(
                  context,
                ).t('fleet_status_field_rental_agreement_number'),
              ),
              validator: (value) => _requiredText(
                context,
                value,
                AppLocalizations.of(
                  context,
                ).t('fleet_status_field_rental_agreement_number'),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _DateInputField(
                    controller: _selfSourcedStartCtrl,
                    label: AppLocalizations.of(
                      context,
                    ).t('fleet_status_field_rental_start_date'),
                    onPick: () => _pickDate(_selfSourcedStartCtrl),
                    validator: (value) => _requiredDate(
                      context,
                      value,
                      AppLocalizations.of(
                        context,
                      ).t('fleet_status_field_rental_start_date'),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _DateInputField(
                    controller: _selfSourcedEndCtrl,
                    label: AppLocalizations.of(
                      context,
                    ).t('fleet_status_field_rental_end_date'),
                    onPick: () => _pickDate(_selfSourcedEndCtrl),
                    validator: (value) => _requiredDate(
                      context,
                      value,
                      AppLocalizations.of(
                        context,
                      ).t('fleet_status_field_rental_end_date'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      case VehicleCategory.selfOwnedRental:
        return Column(
          children: [
            TextFormField(
              controller: _ownershipTypeCtrl,
              decoration: _inputDecoration(
                label: AppLocalizations.of(
                  context,
                ).t('fleet_status_field_ownership_type'),
              ),
              validator: (value) => _requiredText(
                context,
                value,
                AppLocalizations.of(
                  context,
                ).t('fleet_status_field_ownership_type'),
              ),
            ),
            const SizedBox(height: 14),
            _DateInputField(
              controller: _purchaseDateCtrl,
              label: AppLocalizations.of(
                context,
              ).t('fleet_status_field_purchase_date'),
              onPick: () => _pickDate(_purchaseDateCtrl),
              validator: (value) => _requiredDate(
                context,
                value,
                AppLocalizations.of(
                  context,
                ).t('fleet_status_field_purchase_date'),
              ),
            ),
          ],
        );
      case VehicleCategory.lmr:
      case VehicleCategory.sesoRental:
        return const SizedBox.shrink();
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    String? helperText,
  }) {
    return InputDecoration(
      labelText: label,
      helperText: helperText,
      helperMaxLines: 3,
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _FleetStatusPageState._kBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _FleetStatusPageState._kBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _FleetStatusPageState._kGreen),
      ),
    );
  }

  String? _requiredText(BuildContext context, String? value, String field) {
    if ((value ?? '').trim().isEmpty) {
      return AppLocalizations.of(
        context,
      ).tf('error_required', {'field': field});
    }
    return null;
  }

  String? _requiredDate(BuildContext context, String? value, String field) {
    final trimmed = (value ?? '').trim();
    if (trimmed.isEmpty) {
      return AppLocalizations.of(
        context,
      ).tf('error_required', {'field': field});
    }
    if (!isValidVehicleDate(trimmed)) {
      return AppLocalizations.of(context).t('fleet_status_invalid_date');
    }
    return null;
  }
}

class _DocumentStatusPresentation {
  const _DocumentStatusPresentation({required this.label, required this.color});

  final String label;
  final Color color;
}

class _VehicleListComplianceSummary {
  const _VehicleListComplianceSummary({
    required this.tuvStatus,
    required this.missingCount,
  });

  final FleetVehicleDocumentStatus tuvStatus;
  final int missingCount;
}

const List<String> _vehicleDocumentTypeOptions = <String>[
  'HU_TUV_CERTIFICATE',
  'FAHRZEUGSCHEIN',
  'INSURANCE_CERTIFICATE',
  'LEASE_CONTRACT',
  'SERVICE_REPORT',
];

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: _FleetStatusPageState._kText,
      ),
    );
  }
}

// ─── Wartung / Verschleißteile (Reifen, Bremsen, Öl …) ────────────────
//
// Speichert pro Fahrzeug Wechsel als Vehicle-Event mit
// eventType == 'MAINTENANCE' und metadata { component, label, kmStand }.
// Nutzt damit die bestehende events-Subcollection + Rules (keine
// Rules-Änderung nötig). Berechnet je Bauteil, wie viele km das
// vorige Teil gehalten hat (Differenz der KM-Stände beim nächsten
// Wechsel).

class _DateInputField extends StatelessWidget {
  const _DateInputField({
    required this.controller,
    required this.label,
    required this.onPick,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final VoidCallback onPick;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      validator: validator,
      onTap: onPick,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        suffixIcon: IconButton(
          onPressed: onPick,
          icon: const Icon(Icons.calendar_today_outlined),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _FleetStatusPageState._kBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _FleetStatusPageState._kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _FleetStatusPageState._kGreen),
        ),
      ),
    );
  }
}

/// Result of the grounding dialog: optional "back in service" date plus —
/// for Grounded (Service) — the workshop the vehicle was sent to.
class _GroundingDialogResult {
  const _GroundingDialogResult({
    required this.serviceEndDate,
    this.workshop = '',
  });

  final String serviceEndDate;
  final String workshop;
}

class _ServiceEndDateDialog extends StatefulWidget {
  const _ServiceEndDateDialog({
    required this.initialValue,
    required this.requiredValue,
    this.askWorkshop = false,
    this.initialWorkshop = '',
  });

  final String initialValue;
  final bool requiredValue;

  /// Grounded (Service): additionally show a workshop text field.
  final bool askWorkshop;
  final String initialWorkshop;

  @override
  State<_ServiceEndDateDialog> createState() => _ServiceEndDateDialogState();
}

class _ServiceEndDateDialogState extends State<_ServiceEndDateDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;
  late final TextEditingController _workshopController;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _workshopController = TextEditingController(text: widget.initialWorkshop);
  }

  @override
  void dispose() {
    _controller.dispose();
    _workshopController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final parsed = DateTime.tryParse(_controller.text.trim());
    final picked = await showDatePicker(
      context: context,
      initialDate: parsed ?? now,
      firstDate: DateTime(now.year - 20),
      lastDate: DateTime(now.year + 20),
    );
    if (picked == null) return;
    _controller.text =
        '${picked.year.toString().padLeft(4, '0')}-'
        '${picked.month.toString().padLeft(2, '0')}-'
        '${picked.day.toString().padLeft(2, '0')}';
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final de = Localizations.localeOf(context).languageCode == 'de';
    return AlertDialog(
      title: Text(t.t('fleet_status_field_service_end_date')),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DateInputField(
                controller: _controller,
                label: t.t('fleet_status_field_service_end_date'),
                onPick: _pickDate,
                validator: (value) {
                  final trimmed = (value ?? '').trim();
                  if (widget.requiredValue && trimmed.isEmpty) {
                    return t.tf('error_required', {
                      'field': t.t('fleet_status_field_service_end_date'),
                    });
                  }
                  if (trimmed.isNotEmpty && !isValidVehicleDate(trimmed)) {
                    return t.t('fleet_status_invalid_date');
                  }
                  return null;
                },
              ),
              if (widget.askWorkshop) ...[
                const SizedBox(height: 14),
                TextFormField(
                  controller: _workshopController,
                  decoration: InputDecoration(
                    labelText: de
                        ? 'Werkstatt (wohin wurde das Fahrzeug gebracht?)'
                        : 'Workshop (where was the vehicle sent?)',
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: _FleetStatusPageState._kBorder,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: _FleetStatusPageState._kBorder,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: _FleetStatusPageState._kGreen,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        CoButton(
          onPressed: () => Navigator.of(context).pop(),
          label: t.t('button_close'),
          variant: CoButtonVariant.quiet,
        ),
        CoButton(
          onPressed: () {
            if (!(_formKey.currentState?.validate() ?? false)) return;
            Navigator.of(context).pop(
              _GroundingDialogResult(
                serviceEndDate: _controller.text.trim(),
                workshop: _workshopController.text.trim(),
              ),
            );
          },
          label: t.t('button_save'),
        ),
      ],
    );
  }
}

Map<String, _VehicleListComplianceSummary> _buildComplianceByPlate(
  List<FleetVehicleDocument> documents,
) {
  final grouped = <String, Map<String, FleetVehicleDocument>>{};

  for (final document in documents) {
    final plateNumber = normalizePlateNumber(document.plateNumber);
    final perType = grouped.putIfAbsent(
      plateNumber,
      () => <String, FleetVehicleDocument>{},
    );
    final canonicalType = _canonicalVehicleDocumentType(document.documentType);
    final current = perType[canonicalType];
    if (current == null || _isDocumentNewer(document, current)) {
      perType[canonicalType] = document;
    }
  }

  final result = <String, _VehicleListComplianceSummary>{};
  final service = FleetVehicleDocumentService();
  for (final entry in grouped.entries) {
    final perType = entry.value;
    final missingCount = _vehicleDocumentTypeOptions.where((type) {
      final document = perType[type];
      return document == null || document.fileUrl.trim().isEmpty;
    }).length;

    final tuvDocument = perType['HU_TUV_CERTIFICATE'];

    result[entry.key] = _VehicleListComplianceSummary(
      tuvStatus: _tuvStatusForDocument(tuvDocument, service),
      missingCount: missingCount,
    );
  }

  return result;
}

/// TÜV status for the list/filter. Unlike the generic document status, a
/// TÜV record with a known HU date but no uploaded certificate still counts:
/// the date alone decides between active / expiring soon / expired. This is
/// what makes date-only TÜV entries (added via the vehicle editor) work.
FleetVehicleDocumentStatus _tuvStatusForDocument(
  FleetVehicleDocument? document,
  FleetVehicleDocumentService service,
) {
  if (document == null) return FleetVehicleDocumentStatus.missing;
  if (document.fileUrl.trim().isNotEmpty) {
    return service.getDocumentStatus(
      expiryDate: document.expiryDate,
      fileUrl: document.fileUrl,
    );
  }

  final parsedExpiry = DateTime.tryParse(document.expiryDate.trim());
  if (parsedExpiry == null) return FleetVehicleDocumentStatus.missing;

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final expiry = DateTime(
    parsedExpiry.year,
    parsedExpiry.month,
    parsedExpiry.day,
  );
  if (expiry.isBefore(today)) return FleetVehicleDocumentStatus.expired;
  if (!expiry.isAfter(today.add(const Duration(days: 30)))) {
    return FleetVehicleDocumentStatus.expiringSoon;
  }
  return FleetVehicleDocumentStatus.active;
}

/// Latest (non-deleted) HU/TÜV document per plate — used to pre-fill the
/// TÜV date in the vehicle editor and to update the right record.
Map<String, FleetVehicleDocument> _latestTuvDocsByPlate(
  List<FleetVehicleDocument> documents,
) {
  final result = <String, FleetVehicleDocument>{};
  for (final document in documents) {
    if (document.isDeleted) continue;
    if (_canonicalVehicleDocumentType(document.documentType) !=
        'HU_TUV_CERTIFICATE') {
      continue;
    }
    final plate = normalizePlateNumber(document.plateNumber);
    final current = result[plate];
    if (current == null || _isDocumentNewer(document, current)) {
      result[plate] = document;
    }
  }
  return result;
}

_VehicleListComplianceSummary _defaultComplianceSummary() {
  return _VehicleListComplianceSummary(
    tuvStatus: FleetVehicleDocumentStatus.missing,
    missingCount: _vehicleDocumentTypeOptions.length,
  );
}

bool _isDocumentNewer(
  FleetVehicleDocument candidate,
  FleetVehicleDocument current,
) {
  final candidateDate = candidate.updatedAt ?? candidate.createdAt;
  final currentDate = current.updatedAt ?? current.createdAt;
  if (candidateDate == null && currentDate == null) {
    return candidate.documentId.compareTo(current.documentId) > 0;
  }
  if (candidateDate == null) return false;
  if (currentDate == null) return true;
  return candidateDate.isAfter(currentDate);
}

_DocumentStatusPresentation _tuvStatusPresentationFor(
  BuildContext context,
  FleetVehicleDocumentStatus status,
) {
  switch (status) {
    case FleetVehicleDocumentStatus.expiringSoon:
      return _DocumentStatusPresentation(
        label: AppLocalizations.of(
          context,
        ).t('fleet_status_vehicle_documents_status_expiring_soon'),
        color: _FleetStatusPageState._kOrange,
      );
    case FleetVehicleDocumentStatus.expired:
      return _DocumentStatusPresentation(
        label: AppLocalizations.of(
          context,
        ).t('fleet_status_vehicle_documents_status_expired'),
        color: _FleetStatusPageState._kRed,
      );
    case FleetVehicleDocumentStatus.missing:
      return _DocumentStatusPresentation(
        label: AppLocalizations.of(
          context,
        ).t('fleet_status_vehicle_documents_status_missing'),
        color: _FleetStatusPageState._kOrange,
      );
    case FleetVehicleDocumentStatus.active:
      return _DocumentStatusPresentation(
        label: AppLocalizations.of(
          context,
        ).t('fleet_status_vehicle_documents_status_active'),
        color: _FleetStatusPageState._kGreen,
      );
  }
}

String _statusLabel(BuildContext context, VehicleStatus status) {
  final de = Localizations.localeOf(context).languageCode == 'de';
  switch (status) {
    case VehicleStatus.active:
      return de ? 'Aktiv' : 'Active';
    case VehicleStatus.operational:
      return de ? 'Operativ' : 'Operational';
    case VehicleStatus.groundedDefect:
      return de ? 'Grounded (Defekt)' : 'Grounded (defect)';
    case VehicleStatus.groundedSelfReported:
      return de
          ? 'Grounded (Selbst gemeldetes Problem)'
          : 'Grounded (self-reported issue)';
    case VehicleStatus.groundedTuvOverdue:
      return de ? 'Grounded (TÜV überfällig)' : 'Grounded (TÜV overdue)';
    case VehicleStatus.groundedVsa:
      return 'Grounded (VSA)';
    case VehicleStatus.groundedService:
      return 'Grounded (Service)';
    case VehicleStatus.inactive:
      return de ? 'Inaktiv' : 'Inactive';
  }
}

Color _statusColor(VehicleStatus status) {
  switch (status) {
    case VehicleStatus.active:
      return _FleetStatusPageState._kGreen;
    case VehicleStatus.operational:
      return const Color(0xFF16A34A);
    case VehicleStatus.groundedDefect:
      return _FleetStatusPageState._kRed;
    case VehicleStatus.groundedSelfReported:
      return const Color(0xFFDC2626);
    case VehicleStatus.groundedTuvOverdue:
      return const Color(0xFFEA580C);
    case VehicleStatus.groundedVsa:
      return const Color(0xFF9F1239);
    case VehicleStatus.groundedService:
      return const Color(0xFF1D4ED8);
    case VehicleStatus.inactive:
      return _FleetStatusPageState._kMuted;
  }
}

String _categoryLabel(BuildContext context, VehicleCategory category) {
  final t = AppLocalizations.of(context);
  switch (category) {
    case VehicleCategory.amazonPaidRental:
      // Markenname wie 'LMR' / 'SESO Rental' / 'Self Owned' — bewusst nicht
      // übersetzt, der Lokalisierungs-Eintrag hieße 'Amazon Paid Rental'.
      return 'Amazon Rental';
    case VehicleCategory.selfSourcedRental:
      return t.t('fleet_status_category_self_sourced_rental');
    case VehicleCategory.selfOwnedRental:
      return 'Self Owned';
    case VehicleCategory.armada:
      return t.t('fleet_status_category_armada');
    case VehicleCategory.lmr:
      return 'LMR';
    case VehicleCategory.sesoRental:
      return 'SESO Rental';
  }
}

String _fuelTypeLabel(BuildContext context, VehicleFuelType fuelType) {
  final t = AppLocalizations.of(context);
  switch (fuelType) {
    case VehicleFuelType.petrol:
      return t.t('fleet_status_fuel_type_petrol');
    case VehicleFuelType.electric:
      return t.t('fleet_status_fuel_type_electric');
    case VehicleFuelType.hybrid:
      return t.t('fleet_status_fuel_type_hybrid');
    case VehicleFuelType.diesel:
      return t.t('fleet_status_fuel_type_diesel');
  }
}

String _documentTypeLabel(String documentType) {
  final normalized = _canonicalVehicleDocumentType(documentType);
  if (normalized.isEmpty) return '-';
  if (normalized == 'FAHRZEUGSCHEIN') return 'Fahrzeugschein';
  return normalized
      .split('_')
      .where((part) => part.isNotEmpty)
      .map(
        (part) => '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
      )
      .join(' ');
}

String _canonicalVehicleDocumentType(String documentType) {
  final normalized = documentType.trim().toUpperCase();
  if (normalized == 'REGISTRATION_CERTIFICATE') {
    return 'FAHRZEUGSCHEIN';
  }
  return normalized;
}

String _formatStoredDate(BuildContext context, String value) {
  final parsed = DateTime.tryParse(value);
  if (parsed == null)
    return value.trim().isEmpty
        ? AppLocalizations.of(context).t('fleet_status_vehicle_details_not_set')
        : value;
  return MaterialLocalizations.of(context).formatShortDate(parsed);
}

String _optionalStoredDate(BuildContext context, String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return '-';
  }
  return _formatStoredDate(context, trimmed);
}

class _FleetHero extends StatelessWidget {
  final List<FleetVehicle> vehicles;
  final Map<String, _VehicleListComplianceSummary> compliance;
  final bool isMobile;

  /// Keys of the currently active filters ('TOTAL', 'ARMADA', 'SESO',
  /// 'LMR', 'SELF_OWNED', 'INACTIVE') — active tiles are highlighted.
  final Set<String> activeKeys;

  /// Called with the tile key when a counter tile is tapped (filtering).
  final ValueChanged<String>? onTileTap;

  const _FleetHero({
    required this.vehicles,
    required this.compliance,
    this.isMobile = false,
    this.activeKeys = const <String>{},
    this.onTileTap,
  });

  @override
  Widget build(BuildContext context) {
    final total = vehicles.length;
    final inactive = vehicles
        .where((v) => v.status == VehicleStatus.inactive)
        .length;

    int countByCat(VehicleCategory cat) =>
        vehicles.where((v) => v.category == cat).length;
    final armada = countByCat(VehicleCategory.armada);
    final lmr = countByCat(VehicleCategory.lmr);
    final seso = countByCat(VehicleCategory.sesoRental);
    final amazon = countByCat(VehicleCategory.amazonPaidRental);
    // Legacy self-sourced counts into Self-Owned so nothing gets lost.
    final selfOwned =
        countByCat(VehicleCategory.selfOwnedRental) +
        countByCat(VehicleCategory.selfSourcedRental);

    // Main categories only: Gesamt (dark green) + Armada, SESO, LMR,
    // Self-Owned, Inaktiv — all in white, slim tiles. Every tile is a
    // click-to-filter toggle.
    final de = Localizations.localeOf(context).languageCode == 'de';
    final tiles = <Widget>[
      _tile(
        de ? 'Gesamt' : 'Total',
        total,
        Icons.local_shipping_outlined,
        primary: true,
        filterKey: 'TOTAL',
      ),
      _tile(
        'Armada',
        armada,
        Icons.directions_car_filled_outlined,
        filterKey: 'ARMADA',
      ),
      _tile(
        'SESO Rental',
        seso,
        Icons.local_shipping_rounded,
        filterKey: 'SESO',
      ),
      _tile(
        'Amazon Rental',
        amazon,
        Icons.airport_shuttle_outlined,
        filterKey: 'AMAZON',
      ),
      _tile('LMR', lmr, Icons.commute_rounded, filterKey: 'LMR'),
      _tile(
        'Self-Owned',
        selfOwned,
        Icons.vpn_key_outlined,
        filterKey: 'SELF_OWNED',
      ),
      _tile(
        de ? 'Inaktiv' : 'Inactive',
        inactive,
        Icons.pause_circle_outline_rounded,
        filterKey: 'INACTIVE',
      ),
    ];

    return _tileRow(tiles);
  }

  /// Renders one row of counter tiles: expanded across the width on
  /// desktop/tablet, horizontally scrollable (fixed width) on mobile.
  Widget _tileRow(List<Widget> tiles) {
    if (tiles.isEmpty) return const SizedBox.shrink();
    if (!isMobile) {
      return LayoutBuilder(
        builder: (context, constraints) {
          // Sieben Kacheln brauchen Platz — wird es eng, scrollt die Reihe
          // mit fester Kachelbreite, statt Labels wie „Amazon Rental"
          // abzuschneiden.
          if (constraints.maxWidth < 1000) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int i = 0; i < tiles.length; i++) ...[
                    SizedBox(width: 138, child: tiles[i]),
                    if (i != tiles.length - 1) const SizedBox(width: 10),
                  ],
                ],
              ),
            );
          }
          return Row(
            children: [
              for (int i = 0; i < tiles.length; i++) ...[
                Expanded(child: tiles[i]),
                if (i != tiles.length - 1) const SizedBox(width: 10),
              ],
            ],
          );
        },
      );
    }
    // Mobil: schmale Kacheln — nur so breit, dass eine dreistellige Zahl
    // bequem sitzt. Feste Höhe, damit die Reihe trotz ein- oder zweizeiliger
    // Labels bündig bleibt.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < tiles.length; i++) ...[
            SizedBox(width: 76, height: 68, child: tiles[i]),
            if (i != tiles.length - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  /// Slim counter tile. "Gesamt" (primary) is the inverted dark-green tile of
  /// the handoff (#0D5C42); every other tile is a white box with a subtle
  /// border. Tiles act as filter toggles: the active one gets the handoff
  /// green (#0D8A60) as border + tinted background.
  Widget _tile(
    String label,
    int value,
    IconData icon, {
    bool primary = false,
    String? filterKey,
  }) {
    const primaryBg = Color(0xFF0D5C42);
    final active = filterKey != null && activeKeys.contains(filterKey);
    final highlight = active && !primary;
    final bg = primary
        ? primaryBg
        : highlight
        ? _FleetStatusPageState._kAccentGreenTint
        : Colors.white;
    final fg = primary
        ? Colors.white
        : highlight
        ? _FleetStatusPageState._kAccentGreen
        : _FleetStatusPageState._kSubtle;
    final numColor = primary
        ? Colors.white
        : highlight
        ? _FleetStatusPageState._kAccentGreen
        : _FleetStatusPageState._kInk;
    final borderColor = primary
        ? primaryBg
        : highlight
        ? _FleetStatusPageState._kAccentGreen
        : _FleetStatusPageState._kLine;

    // Desktop-Handoff: 12px/14px Innenabstand, Label 11px/600 mit Icon,
    // Zahl 22px/700. Mobil ohne Icon, Label oben klein/uppercase, Zahl
    // darunter — die Kachel ist dort nur noch „999"-breit.
    final tile = Container(
      padding: isMobile
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 8)
          : const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isMobile)
            Expanded(
              child: Text(
                label.toUpperCase(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                  color: fg,
                  height: 1.2,
                ),
              ),
            )
          else
            Row(
              children: [
                Icon(icon, size: 14, color: fg),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: fg,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 2),
          Text(
            '$value',
            maxLines: 1,
            style: TextStyle(
              fontSize: isMobile ? 20 : 22,
              fontWeight: FontWeight.w700,
              color: numColor,
              height: 1.2,
            ),
          ),
        ],
      ),
    );

    final onTap = onTileTap;
    if (filterKey == null || onTap == null) return tile;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(filterKey),
        child: tile,
      ),
    );
  }
}

/// Wraps a fleet row/card so it lifts slightly + shows a shadow on hover and
/// is clickable across its whole surface (inner controls still capture taps).
class _HoverRow extends StatefulWidget {
  /// Bekommt den Hover-Zustand, damit die Karte selbst den grünlichen Rand
  /// des Handoffs setzen kann (der Rand der Karte liegt über dem des
  /// Wrappers, deshalb kein eigenes Border-Painting hier).
  final Widget Function(bool hovered) builder;
  final VoidCallback onTap;
  const _HoverRow({required this.builder, required this.onTap});

  @override
  State<_HoverRow> createState() => _HoverRowState();
}

class _HoverRowState extends State<_HoverRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          transform: _hover
              ? (Matrix4.identity()..translate(0.0, -1.0))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            // Handoff-Hover: grünlicher Schatten statt neutralem Grau.
            boxShadow: _hover
                ? const [
                    BoxShadow(
                      color: Color(0x2E0D8A60),
                      blurRadius: 12,
                      offset: Offset(0, 3),
                    ),
                  ]
                : const [],
          ),
          child: widget.builder(_hover),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Ungrounding: „Servicebericht / Unterlagen hochladen?"-Dialog
// ---------------------------------------------------------------------------

/// Ergebnis des Upload-Dialogs — Notiz und/oder Datei, beides optional.
class _ServiceUploadResult {
  const _ServiceUploadResult({
    required this.note,
    required this.fileBytes,
    required this.fileName,
  });

  final String note;
  final Uint8List? fileBytes;
  final String fileName;
}

/// Optionaler Dialog nach dem Statuswechsel grounded → operational:
/// Servicebericht / Lieferschein etc. (PDF/Bild, max 20 MB — Limit der
/// Storage-Rules) plus Notiz. „Später" überspringt ohne Event.
class _ServiceUploadDialog extends StatefulWidget {
  const _ServiceUploadDialog({required this.de, required this.plate});

  final bool de;
  final String plate;

  @override
  State<_ServiceUploadDialog> createState() => _ServiceUploadDialogState();
}

class _ServiceUploadDialogState extends State<_ServiceUploadDialog> {
  static const Color _border = Color(0xFFE5E7EB);
  static const Color _green = Color(0xFF0D8A60);
  static const Color _muted = Color(0xFF6B7280);
  static const Color _red = Color(0xFFB32F2F);

  final TextEditingController _noteCtrl = TextEditingController();
  Uint8List? _fileBytes;
  String _fileName = '';
  String? _error;
  bool _picking = false;

  String _tr(String de, String en) => widget.de ? de : en;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    if (_picking) return;
    setState(() {
      _picking = true;
      _error = null;
    });
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
        withData: true,
      );
      if (picked == null || picked.files.isEmpty) return;
      final file = picked.files.first;
      final bytes = file.bytes;
      if (bytes == null) {
        setState(
          () => _error = _tr(
            'Datei konnte nicht gelesen werden.',
            'Could not read the file.',
          ),
        );
        return;
      }
      if (bytes.length >= 20 * 1024 * 1024) {
        setState(
          () => _error = _tr(
            'Datei ist zu groß (max. 20 MB).',
            'File is too large (max. 20 MB).',
          ),
        );
        return;
      }
      setState(() {
        _fileBytes = bytes;
        _fileName = file.name;
      });
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(
        _tr(
          'Servicebericht / Unterlagen hochladen?',
          'Upload service report / documents?',
        ),
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _tr(
                  '${widget.plate} ist wieder einsatzbereit. Optional können '
                      'Servicebericht, Lieferschein o. Ä. als Fahrzeug-Event '
                      'hinterlegt werden.',
                  '${widget.plate} is back in service. Optionally attach the '
                      'service report, delivery note etc. as a vehicle event.',
                ),
                style: const TextStyle(fontSize: 12.5, color: _muted),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: _picking ? null : _pickFile,
                icon: Icon(
                  _fileName.isEmpty
                      ? Icons.upload_file_outlined
                      : Icons.description_outlined,
                  size: 18,
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _fileName.isEmpty ? _muted : _green,
                  side: const BorderSide(color: _border),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                label: Text(
                  _fileName.isEmpty
                      ? _tr('Datei wählen (PDF/Bild)', 'Choose file (PDF/image)')
                      : _fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              if (_fileName.isNotEmpty) ...[
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => setState(() {
                      _fileBytes = null;
                      _fileName = '';
                    }),
                    icon: const Icon(Icons.close, size: 15),
                    style: TextButton.styleFrom(foregroundColor: _muted),
                    label: Text(
                      _tr('Datei entfernen', 'Remove file'),
                      style: const TextStyle(fontSize: 12.5),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              TextField(
                controller: _noteCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: _tr('Notiz (optional)', 'Note (optional)'),
                  hintText: _tr(
                    'z. B. Bremsen erneuert, Werkstatt Müller',
                    'e.g. brakes replaced, workshop',
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: _border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: _border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: _green, width: 1.4),
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: _red,
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
          child: Text(_tr('Später', 'Later')),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: _green),
          onPressed: () => Navigator.of(context).pop(
            _ServiceUploadResult(
              note: _noteCtrl.text.trim(),
              fileBytes: _fileBytes,
              fileName: _fileName,
            ),
          ),
          child: Text(_tr('Speichern', 'Save')),
        ),
      ],
    );
  }
}
