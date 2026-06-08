import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/admin_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../localization/app_localizations.dart';
import '../models/fleet_vehicle.dart';
import '../models/fleet_vehicle_document.dart';
import '../models/fleet_vehicle_event.dart';
import '../services/fleet_vehicle_document_repository.dart';
import '../services/fleet_vehicle_document_service.dart';
import '../services/fleet_vehicle_event_repository.dart';
import '../services/fleet_vehicle_event_service.dart';
import '../services/fleet_vehicle_repository.dart';
import '../services/cortex_vehicle_importer.dart';
import '../theme/app_colors.dart';
import '../widgets/co_button.dart';
import '../widgets/co_pressable.dart';
import '../widgets/pill_tab_bar.dart';
import 'seso_overview_page.dart';

class FleetStatusPage extends StatefulWidget {
  const FleetStatusPage({super.key});

  @override
  State<FleetStatusPage> createState() => _FleetStatusPageState();
}

class _FleetStatusPageState extends State<FleetStatusPage> {
  static const Color _kGreen = Color(0xFF1D7F5A);
  static const Color _kBlue = Color(0xFF1D4ED8);
  static const Color _kRed = Color(0xFFB91C1C);
  static const Color _kOrange = Color(0xFFD97706);
  static const Color _kText = Color(0xFF111827);
  static const Color _kMuted = Color(0xFF6B7280);
  static const Color _kBorder = Color(0xFFE5E7EB);
  static const Color _kCardBg = Color(0xFFFFFFFF);
  static const Color _kPageBg = Color(0xFFF3F6F7);

  static const String _statusAllValue = '__all_status__';
  static const String _tuvAllValue = '__all_tuv__';

  final FleetVehicleRepository _repository = FleetVehicleRepository();
  final FleetVehicleDocumentService _documentService =
      FleetVehicleDocumentService();
  final TextEditingController _searchCtrl = TextEditingController();

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
  String _statusFilter = _statusAllValue;
  String _tuvFilter = _tuvAllValue;
  final Set<String> _updatingVehicleStatuses = <String>{};

  @override
  void initState() {
    super.initState();
    _resolveScope();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
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

  List<FleetVehicle> _filteredVehicles(
    List<FleetVehicle> vehicles,
    Map<String, _VehicleListComplianceSummary> complianceByPlate,
  ) {
    final query = _search.trim().toLowerCase();
    final filtered = vehicles.where((vehicle) {
      if (vehicle.isDeleted) return false;
      if (_statusFilter != _statusAllValue &&
          vehicle.status.value != _statusFilter) {
        return false;
      }
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

  String _formatDateString(BuildContext context, String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    return MaterialLocalizations.of(context).formatShortDate(parsed);
  }

  String _formatDateTime(BuildContext context, DateTime? value) {
    if (value == null) {
      return AppLocalizations.of(context).t('fleet_status_updated_fallback');
    }
    final material = MaterialLocalizations.of(context);
    return '${material.formatShortDate(value)} '
        '${material.formatTimeOfDay(TimeOfDay.fromDateTime(value))}';
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
    setState(() => _busyCortex = true);
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true,
      );
      if (picked == null || picked.files.isEmpty) {
        setState(() => _busyCortex = false);
        return;
      }
      final f = picked.files.first;
      final bytes = f.bytes;
      if (bytes == null) {
        setState(() => _busyCortex = false);
        return;
      }
      final report = await CortexVehicleImporter().importFromXlsx(
        dspUid: scope,
        bytes: bytes,
        filename: f.name,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: report.added > 0
              ? const Color(0xFF067647)
              : const Color(0xFFB45309),
          content: Text(
            'Cortex-Import: ${report.added} neu hinzugefügt, '
            '${report.skippedDuplicate} bereits vorhanden '
            '(${report.total} Zeilen gelesen).',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFB42318),
          content: Text('Cortex-Import fehlgeschlagen: $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => _busyCortex = false);
    }
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

    final draft = await showDialog<FleetVehicleDraft>(
      context: context,
      builder: (_) => _VehicleEditorDialog(vehicle: vehicle),
    );
    if (draft == null) return;

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
        await _repository.updateVehicle(
          dspUid: scope,
          originalPlateNumber: vehicle.plateNumber,
          draft: draft,
        );
        if (!mounted) return;
        _showSnack(
          t.tf('fleet_status_save_updated', {
            'vehicleNumber': draft.plateNumber,
          }),
        );
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

  Future<void> _showVehicleDetails(FleetVehicle vehicle) async {
    final scope = _scopeUid;
    if (scope == null) {
      _showSnack(
        AppLocalizations.of(context).t('fleet_status_empty_scope'),
        error: true,
      );
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _VehicleDetailsPage(
          vehicle: vehicle,
          dspUid: scope,
          canManageDocuments: _canManageVehicles,
        ),
      ),
    );
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

  Future<void> _updateVehicleStatus(
    FleetVehicle vehicle,
    VehicleStatus status, {
    String? serviceEndDate,
  }) async {
    if (vehicle.status == status) return;

    final scope = _scopeUid;
    final t = AppLocalizations.of(context);
    if (scope == null) {
      _showSnack(t.t('fleet_status_empty_scope'), error: true);
      return;
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
      if (!mounted) return;
      _showSnack(
        t.tf('fleet_status_save_updated', {'vehicleNumber': plateNumber}),
      );
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
    } finally {
      if (!mounted) return;
      setState(() => _updatingVehicleStatuses.remove(plateNumber));
    }
  }

  Future<void> _handleVehicleStatusSelection(
    FleetVehicle vehicle,
    VehicleStatus status,
  ) async {
    if (vehicle.status == status) return;

    String? serviceEndDate;
    if (status == VehicleStatus.inService) {
      serviceEndDate = await showDialog<String>(
        context: context,
        builder: (_) => _ServiceEndDateDialog(
          initialValue: vehicle.serviceEndDate,
          requiredValue: false,
        ),
      );
      if (!mounted || serviceEndDate == null) return;
    }

    await _updateVehicleStatus(
      vehicle,
      status,
      serviceEndDate: status == VehicleStatus.inService ? serviceEndDate : null,
    );
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

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Builder(
              builder: (ctx) => PillTabBar(
                controller: DefaultTabController.of(ctx),
                tabs: const ['Fahrzeuge', 'SESO'],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildVehiclesTab(context, scope),
                SesoOverviewPage(dspUid: scope),
              ],
            ),
          ),
        ],
      ),
    );
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
                stream: _documentService.watchScopeDocuments(dspUid: scope),
                builder: (context, docsSnapshot) {
                  final complianceByPlate = _buildComplianceByPlate(
                    docsSnapshot.data ?? const <FleetVehicleDocument>[],
                  );
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
                          vehicles: snapshot.data ?? const [],
                          compliance: complianceByPlate,
                          isMobile: isMobile,
                        ),
                        const SizedBox(height: 16),
                        _buildToolbar(context, isNarrow: isNarrow),
                        const SizedBox(height: 16),
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
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.codriverGreen,
                                      ),
                                    ),
                                  )
                                : errorMessage != null
                                ? KeyedSubtree(
                                    key: const ValueKey('fleet-error'),
                                    child: _buildErrorState(
                                        context, errorMessage),
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
          ),
        );

        if (isMobile && _canManageVehicles) {
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
                  subtitle: const Text(
                    'Aktuelle Flotte aus Cortex synchronisieren',
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
                  subtitle: const Text(
                    'Neues Fahrzeug manuell anlegen',
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
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: isNarrow ? double.infinity : 620,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.t('fleet_status_title'),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: _kText,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                t.t('fleet_status_subtitle'),
                style: const TextStyle(fontSize: 14, color: _kMuted),
              ),
            ],
          ),
        ),
        if (_canManageVehicles) ...[
          OutlinedButton.icon(
            onPressed: _busyCortex ? null : _importFromCortex,
            icon: _busyCortex
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cloud_download_outlined, size: 18),
            label: Text(_busyCortex
                ? 'Importiere…'
                : 'Cortex-Import'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1D7F5A),
              side: const BorderSide(color: Color(0xFF1D7F5A)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          CoButton(
            onPressed: () => _showVehicleEditor(),
            icon: Icons.add_rounded,
            label: t.t('fleet_status_add_vehicle'),
          ),
        ] else
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

  Widget _buildToolbar(BuildContext context, {required bool isNarrow}) {
    final t = AppLocalizations.of(context);

    final searchField = TextField(
      controller: _searchCtrl,
      onChanged: (value) => setState(() => _search = value),
      decoration: InputDecoration(
        hintText: t.t('fleet_status_search_hint'),
        prefixIcon: const Icon(Icons.search),
        isDense: isNarrow,
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(color: _kGreen, width: 1.4),
        ),
      ),
    );

    final statusFilter = _ToolbarDropdown(
      value: _statusFilter,
      onChanged: (value) {
        if (value == null) return;
        setState(() => _statusFilter = value);
      },
      items: [
        DropdownMenuItem(
          value: _statusAllValue,
          child: Text(t.t('fleet_status_filter_all')),
        ),
        ...VehicleStatus.values.map(
          (status) => DropdownMenuItem<String>(
            value: status.value,
            child: Text(_statusLabel(context, status)),
          ),
        ),
      ],
    );

    final tuvFilter = _ToolbarDropdown(
      value: _tuvFilter,
      onChanged: (value) {
        if (value == null) return;
        setState(() => _tuvFilter = value);
      },
      items: [
        DropdownMenuItem(
          value: _tuvAllValue,
          child: Text(t.t('fleet_status_tuv_filter_all')),
        ),
        ...FleetVehicleDocumentStatus.values.map(
          (status) => DropdownMenuItem<String>(
            value: status.value,
            child: Text(_tuvStatusPresentationFor(context, status).label),
          ),
        ),
      ],
    );

    if (isNarrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          searchField,
          const SizedBox(height: 12),
          statusFilter,
          const SizedBox(height: 12),
          tuvFilter,
        ],
      );
    }

    return Row(
      children: [
        Expanded(flex: 5, child: searchField),
        const SizedBox(width: 12),
        Expanded(flex: 2, child: statusFilter),
        const SizedBox(width: 12),
        Expanded(flex: 2, child: tuvFilter),
      ],
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

  Widget _buildVehicleTable(
    BuildContext context,
    List<FleetVehicle> vehicles, {
    required Map<String, _VehicleListComplianceSummary> complianceByPlate,
  }) {
    final t = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final table = Column(
          children: [
            // header row
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _VehicleTableHeaderCell(
                    label: t.t('fleet_status_column_vehicle_number'),
                    flex: 4,
                  ),
                  _VehicleTableHeaderCell(
                    label: t.t('fleet_status_column_model'),
                    flex: 4,
                  ),
                  _VehicleTableHeaderCell(
                    label: t.t('fleet_status_column_status'),
                    flex: 3,
                  ),
                  _VehicleTableHeaderCell(
                    label: t.t('fleet_status_column_service_end'),
                    flex: 3,
                  ),
                  _VehicleTableHeaderCell(
                    label: t.t('fleet_status_column_tuv_status'),
                    flex: 3,
                  ),
                  _VehicleTableHeaderCell(
                    label: t.t('fleet_status_column_actions'),
                    flex: 3,
                    alignment: Alignment.centerRight,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: vehicles.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final vehicle = vehicles[index];
                  final isUpdatingStatus = _updatingVehicleStatuses.contains(
                    vehicle.plateNumber,
                  );
                  final compliance =
                      complianceByPlate[vehicle.plateNumber] ??
                      _defaultComplianceSummary();
                  final tuvStatus = _tuvStatusPresentationFor(
                    context,
                    compliance.tuvStatus,
                  );
                  final modelName = '${vehicle.brand} ${vehicle.model}'.trim();
                  final modelLabel = modelName.isEmpty
                      ? t.t('fleet_status_vehicle_details_not_set')
                      : modelName;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: CoPressable(
                            onTap: () => _showVehicleDetails(vehicle),
                            borderRadius: BorderRadius.circular(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SelectableText(
                                  vehicle.plateNumber,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _categoryLabel(context, vehicle.category),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: _buildTableTextBlock(
                            primary: modelLabel,
                            secondary: _vehicleModelMeta(context, vehicle),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: _canManageVehicles
                              ? _buildTableStatusDropdown(
                                  context,
                                  vehicle: vehicle,
                                  isBusy: isUpdatingStatus,
                                )
                              : Align(
                                  alignment: Alignment.centerLeft,
                                  child: _SoftPill(
                                    label: _statusLabel(context, vehicle.status),
                                    textColor: _statusColor(vehicle.status),
                                    backgroundColor: _statusColor(
                                      vehicle.status,
                                    ).withOpacity(0.14),
                                  ),
                                ),
                        ),
                        Expanded(
                          flex: 3,
                          child: _buildTableTextBlock(
                            primary: _serviceEndLabel(context, vehicle),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _SoftPill(
                              label: tuvStatus.label,
                              textColor: tuvStatus.color,
                              backgroundColor: tuvStatus.color.withOpacity(
                                0.14,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: _canManageVehicles
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    _buildTableActionButton(
                                      tooltip: t.t(
                                        'fleet_status_action_view_details',
                                      ),
                                      icon: Icons.visibility_outlined,
                                      color: const Color(0xFF6B7280),
                                      onPressed: () =>
                                          _showVehicleDetails(vehicle),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildTableActionButton(
                                      tooltip: t.t('button_edit'),
                                      icon: Icons.edit_outlined,
                                      color: const Color(0xFF2563EB),
                                      onPressed: () =>
                                          _showVehicleEditor(vehicle: vehicle),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildTableActionButton(
                                      tooltip: t.t(
                                        'fleet_status_action_delete',
                                      ),
                                      icon: Icons.delete_outline,
                                      color: const Color(0xFFDC2626),
                                      onPressed: () => _deleteVehicle(vehicle),
                                    ),
                                  ],
                                )
                              : Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    t.t('fleet_status_read_only'),
                                    style: const TextStyle(
                                      color: _kMuted,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );

        // If screen is very narrow, allow horizontal scroll so layout stays same.
        if (constraints.maxWidth < 980) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(width: 980, child: table),
          );
        }

        return table;
      },
    );
  }

  Widget _buildTableTextBlock({required String primary, String? secondary}) {
    final secondaryText = (secondary ?? '').trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          primary,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
        ),
        if (secondaryText.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            secondaryText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
        ],
      ],
    );
  }

  Widget _buildTableStatusDropdown(
    BuildContext context, {
    required FleetVehicle vehicle,
    required bool isBusy,
  }) {
    final statusColor = _statusColor(vehicle.status);
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: 132,
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.14),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: statusColor.withOpacity(0.22)),
          ),
          child: isBusy
              ? Center(
                  child: Text(
                    AppLocalizations.of(context).t('fleet_status_loading'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                )
              : DropdownButtonHideUnderline(
                  child: DropdownButton<VehicleStatus>(
                    value: vehicle.status,
                    isDense: true,
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: statusColor,
                      size: 18,
                    ),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
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
        ),
      ),
    );
  }

  Widget _buildTablePillBlock({required Widget primary, Widget? secondary}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        primary,
        if (secondary != null) ...[const SizedBox(height: 6), secondary],
      ],
    );
  }

  Widget? _buildSecondaryLabel(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return Text(
      trimmed,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
    );
  }

  String _vehicleAvatarLabel(FleetVehicle vehicle) {
    final compact = vehicle.plateNumber.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
    if (compact.isEmpty) return '?';
    return compact.substring(0, compact.length >= 2 ? 2 : 1).toUpperCase();
  }

  String _vehicleModelMeta(BuildContext context, FleetVehicle vehicle) {
    final parts = <String>[];
    if (vehicle.manufacturingYear > 0) {
      parts.add('${vehicle.manufacturingYear}');
    }
    parts.add(_fuelTypeLabel(context, vehicle.fuelType));

    return parts.join(' | ');
  }

  String _vehicleVinSummary(FleetVehicle vehicle) {
    final vin = vehicle.vinNumber.trim();
    if (vin.isEmpty) return '';
    if (vin.length <= 10) return 'VIN $vin';
    return 'VIN ${vin.substring(0, 4)}...${vin.substring(vin.length - 4)}';
  }

  String _serviceMetaSummary(FleetVehicle vehicle) {
    switch (vehicle.category) {
      case VehicleCategory.armada:
        final metadata = vehicle.metadata as ArmadaVehicleMetadata;
        return metadata.armadaCompanyName.trim().isNotEmpty
            ? metadata.armadaCompanyName.trim()
            : metadata.armadaId.trim();
      case VehicleCategory.amazonPaidRental:
        final metadata = vehicle.metadata as AmazonPaidRentalMetadata;
        return metadata.rentalCompanyName.trim().isNotEmpty
            ? metadata.rentalCompanyName.trim()
            : metadata.contractNumber.trim();
      case VehicleCategory.selfSourcedRental:
        final metadata = vehicle.metadata as SelfSourcedRentalMetadata;
        return metadata.ownerName.trim().isNotEmpty
            ? metadata.ownerName.trim()
            : metadata.rentalAgreementNumber.trim();
      case VehicleCategory.selfOwnedRental:
        final metadata = vehicle.metadata as SelfOwnedRentalMetadata;
        return metadata.ownershipType.trim();
    }
  }

  String _serviceStartSecondary(FleetVehicle vehicle) {
    switch (vehicle.category) {
      case VehicleCategory.armada:
        final metadata = vehicle.metadata as ArmadaVehicleMetadata;
        return metadata.armadaCompanyName.trim();
      case VehicleCategory.amazonPaidRental:
        final metadata = vehicle.metadata as AmazonPaidRentalMetadata;
        return metadata.rentalCompanyName.trim();
      case VehicleCategory.selfSourcedRental:
        final metadata = vehicle.metadata as SelfSourcedRentalMetadata;
        return metadata.ownerName.trim();
      case VehicleCategory.selfOwnedRental:
        final metadata = vehicle.metadata as SelfOwnedRentalMetadata;
        return metadata.ownershipType.trim();
    }
  }

  String _serviceEndSecondary(FleetVehicle vehicle) {
    switch (vehicle.category) {
      case VehicleCategory.armada:
        final metadata = vehicle.metadata as ArmadaVehicleMetadata;
        return metadata.armadaId.trim();
      case VehicleCategory.amazonPaidRental:
        final metadata = vehicle.metadata as AmazonPaidRentalMetadata;
        return metadata.contractNumber.trim();
      case VehicleCategory.selfSourcedRental:
        final metadata = vehicle.metadata as SelfSourcedRentalMetadata;
        return metadata.rentalAgreementNumber.trim();
      case VehicleCategory.selfOwnedRental:
        final metadata = vehicle.metadata as SelfOwnedRentalMetadata;
        return metadata.purchaseDate.trim().isEmpty
            ? metadata.ownershipType.trim()
            : _formatStoredDate(context, metadata.purchaseDate);
    }
  }

  Widget _buildVehicleCards(
    BuildContext context,
    List<FleetVehicle> vehicles, {
    required Map<String, _VehicleListComplianceSummary> complianceByPlate,
  }) {
    final t = AppLocalizations.of(context);
    return ListView.separated(
      itemCount: vehicles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final vehicle = vehicles[index];
        final compliance =
            complianceByPlate[vehicle.plateNumber] ??
            _defaultComplianceSummary();
        final tuvStatus = _tuvStatusPresentationFor(
          context,
          compliance.tuvStatus,
        );
        return Container(
          decoration: BoxDecoration(
            color: _kCardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _kBorder),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: CoPressable(
                      onTap: () => _showVehicleDetails(vehicle),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          children: [
                            Text(
                              vehicle.plateNumber,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: _kText,
                              ),
                            ),
                            if (compliance.missingCount > 0)
                              _MissingDocumentsBadge(
                                label: t.tf(
                                  'fleet_status_missing_documents_count',
                                  {'count': '${compliance.missingCount}'},
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: t.t('fleet_status_action_view_details'),
                        onPressed: () => _showVehicleDetails(vehicle),
                        icon: const Icon(Icons.visibility_outlined),
                      ),
                      if (_canManageVehicles) ...[
                        const SizedBox(width: 4),
                        IconButton(
                          tooltip: t.t('button_edit'),
                          onPressed: () => _showVehicleEditor(vehicle: vehicle),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${vehicle.brand} ${vehicle.model}'.trim(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _kMuted,
                ),
              ),
              const SizedBox(height: 12),
              _InfoRow(
                label: t.t('fleet_status_field_category'),
                value: _categoryLabel(context, vehicle.category),
              ),
              const SizedBox(height: 8),
              _InfoRow(
                label: t.t('fleet_status_column_tuv_status'),
                value: tuvStatus.label,
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _SoftPill(
                    label: _statusLabel(context, vehicle.status),
                    textColor: _statusColor(vehicle.status),
                    backgroundColor: _statusColor(
                      vehicle.status,
                    ).withOpacity(0.14),
                  ),
                  // Make the TÜV pill clickable so admins can jump
                  // straight into the detail page when status is
                  // "missing" / "expired" / "expiring soon" and add
                  // the certificate.
                  InkWell(
                    onTap: () => _showVehicleDetails(vehicle),
                    borderRadius: BorderRadius.circular(999),
                    child: Tooltip(
                      message: 'Klicken um TÜV-Bescheinigung '
                          'hochzuladen / einzusehen',
                      child: _SoftPill(
                        label: tuvStatus.label,
                        textColor: tuvStatus.color,
                        backgroundColor:
                            tuvStatus.color.withOpacity(0.14),
                      ),
                    ),
                  ),
                ],
              ),
              // const SizedBox(height: 14),
              // _InfoRow(
              //   label: t.t('fleet_status_field_registration_date'),
              //   value: _formatDateString(context, vehicle.registrationDate),
              // ),
              const SizedBox(height: 8),
              _InfoRow(
                label: t.t('fleet_status_column_updated_at'),
                value: _formatDateTime(context, vehicle.updatedAt),
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: _canManageVehicles
                    ? CoButton(
                        onPressed: () => _deleteVehicle(vehicle),
                        icon: Icons.delete_outline,
                        label: t.t('fleet_status_action_delete'),
                        variant: CoButtonVariant.destructiveQuiet,
                      )
                    : Text(
                        t.t('fleet_status_read_only'),
                        style: const TextStyle(
                          color: _kMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _serviceStartLabel(BuildContext context, FleetVehicle vehicle) {
    switch (vehicle.category) {
      case VehicleCategory.armada:
        final metadata = vehicle.metadata as ArmadaVehicleMetadata;
        return _dateOrNotApplicable(context, metadata.contractStartDate);
      case VehicleCategory.amazonPaidRental:
        final metadata = vehicle.metadata as AmazonPaidRentalMetadata;
        return _dateOrNotApplicable(context, metadata.rentalStartDate);
      case VehicleCategory.selfSourcedRental:
        final metadata = vehicle.metadata as SelfSourcedRentalMetadata;
        return _dateOrNotApplicable(context, metadata.rentalStartDate);
      case VehicleCategory.selfOwnedRental:
        return AppLocalizations.of(context).t('fleet_status_not_applicable');
    }
  }

  String _serviceEndLabel(BuildContext context, FleetVehicle vehicle) {
    return _optionalStoredDate(context, vehicle.serviceEndDate);
  }

  String _dateOrNotApplicable(BuildContext context, String value) {
    if (value.trim().isEmpty) {
      return AppLocalizations.of(context).t('fleet_status_not_applicable');
    }
    return _formatStoredDate(context, value);
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

class _VehicleEditorDialog extends StatefulWidget {
  const _VehicleEditorDialog({required this.vehicle});

  final FleetVehicle? vehicle;

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
      FleetVehicleDraft(
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
                TextFormField(
                  controller: _plateNumberCtrl,
                  enabled: !_isEditing,
                  decoration: _inputDecoration(
                    label: t.t('fleet_status_field_plate_number'),
                  ),
                  validator: (value) => _requiredText(
                    context,
                    value,
                    t.t('fleet_status_field_plate_number'),
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<VehicleCategory>(
                  value: _category,
                  decoration: _inputDecoration(
                    label: t.t('fleet_status_field_category'),
                  ),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _category = value);
                  },
                  dropdownColor: Colors.white,
                  elevation: 8,
                  borderRadius: BorderRadius.circular(14),
                  items: VehicleCategory.values
                      .map(
                        (category) => DropdownMenuItem<VehicleCategory>(
                          value: category,
                          child: Text(_categoryLabel(context, category)),
                        ),
                      )
                      .toList(),
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
                if (_status == VehicleStatus.inService) ...[
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
                        onPressed: () => setState(() => _serviceEndDateCtrl.clear()),
                        label: t.t('fleet_status_clear_date'),
                        variant: CoButtonVariant.quiet,
                      ),
                    ),
                  ],
                ],
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
    }
  }

  InputDecoration _inputDecoration({required String label}) {
    return InputDecoration(
      labelText: label,
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

class _VehicleDetailsPage extends StatefulWidget {
  const _VehicleDetailsPage({
    required this.vehicle,
    required this.dspUid,
    required this.canManageDocuments,
  });

  final FleetVehicle vehicle;
  final String dspUid;
  final bool canManageDocuments;

  @override
  State<_VehicleDetailsPage> createState() => _VehicleDetailsPageState();
}

class _VehicleDetailsPageState extends State<_VehicleDetailsPage> {
  final FleetVehicleDocumentService _documentService =
      FleetVehicleDocumentService();
  final FleetVehicleEventService _eventService = FleetVehicleEventService();
  static const String _eventTypeAllValue = '__all_vehicle_events__';
  String _eventTypeFilter = _eventTypeAllValue;

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _showDocumentDialog({FleetVehicleDocument? document}) async {
    final result = await showModalBottomSheet<_VehicleDocumentDialogResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _VehicleDocumentDialog(document: document),
    );
    if (result == null) return;

    try {
      if (document == null) {
        final bytes = result.file.bytes;
        if (bytes == null) {
          _showSnack(
            AppLocalizations.of(
              context,
            ).t('fleet_status_vehicle_documents_file_required'),
            error: true,
          );
          return;
        }
        await _documentService.createDocument(
          dspUid: widget.dspUid,
          plateNumber: widget.vehicle.plateNumber,
          draft: result.draft,
          fileBytes: bytes,
          originalFileName: result.file.name,
        );
        _showSnack(
          AppLocalizations.of(
            context,
          ).t('fleet_status_vehicle_documents_create_success'),
        );
      } else {
        await _documentService.updateDocument(
          dspUid: widget.dspUid,
          plateNumber: widget.vehicle.plateNumber,
          documentId: document.documentId,
          existingDocument: document,
          draft: result.draft,
          fileBytes: result.file.bytes,
          originalFileName: result.file.name.trim().isEmpty
              ? null
              : result.file.name,
        );
        _showSnack(
          AppLocalizations.of(
            context,
          ).t('fleet_status_vehicle_documents_update_success'),
        );
      }
    } on DuplicateVehicleDocumentTypeException catch (e) {
      _showSnack(
        AppLocalizations.of(context).tf(
          'fleet_status_vehicle_documents_duplicate_type',
          {'documentType': _documentTypeLabel(e.documentType)},
        ),
        error: true,
      );
    } on ImmutableVehicleDocumentTypeException catch (e) {
      _showSnack(
        AppLocalizations.of(context).tf(
          'fleet_status_vehicle_documents_type_locked',
          {'documentType': _documentTypeLabel(e.documentType)},
        ),
        error: true,
      );
    } on FleetVehicleDocumentException catch (e) {
      _showSnack(e.message, error: true);
    } on FirebaseException catch (e) {
      _showSnack(
        e.code == 'permission-denied'
            ? AppLocalizations.of(context).t('fleet_status_permission_denied')
            : AppLocalizations.of(context).tf(
                'fleet_status_vehicle_documents_save_failed',
                {'error': '$e'},
              ),
        error: true,
      );
    } catch (e) {
      _showSnack(
        AppLocalizations.of(
          context,
        ).tf('fleet_status_vehicle_documents_save_failed', {'error': '$e'}),
        error: true,
      );
    }
  }

  Future<void> _deleteDocument(FleetVehicleDocument document) async {
    final t = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.t('fleet_status_vehicle_documents_delete_title')),
        content: Text(
          t.tf('fleet_status_vehicle_documents_delete_body', {
            'documentName': document.documentType,
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
            label: t.t('button_delete'),
            variant: CoButtonVariant.destructive,
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _documentService.softDeleteDocument(
        dspUid: widget.dspUid,
        plateNumber: widget.vehicle.plateNumber,
        documentId: document.documentId,
      );
      _showSnack(t.t('fleet_status_vehicle_documents_delete_success'));
    } on FirebaseException catch (e) {
      _showSnack(
        e.code == 'permission-denied'
            ? t.t('fleet_status_permission_denied')
            : t.tf('fleet_status_vehicle_documents_delete_failed', {
                'error': '$e',
              }),
        error: true,
      );
    } catch (e) {
      _showSnack(
        t.tf('fleet_status_vehicle_documents_delete_failed', {'error': '$e'}),
        error: true,
      );
    }
  }

  Future<void> _openDocument(FleetVehicleDocument document) async {
    final url = document.fileUrl.trim();
    if (url.isEmpty) {
      _showSnack(
        AppLocalizations.of(
          context,
        ).t('fleet_status_vehicle_documents_missing_file'),
        error: true,
      );
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null) {
      _showSnack(
        AppLocalizations.of(
          context,
        ).t('fleet_status_vehicle_documents_open_failed'),
        error: true,
      );
      return;
    }
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      _showSnack(
        AppLocalizations.of(
          context,
        ).t('fleet_status_vehicle_documents_open_failed'),
        error: true,
      );
    }
  }

  Future<void> _showVehicleEventDialog({FleetVehicleEvent? event}) async {
    final result = await showDialog<_VehicleEventDialogResult>(
      context: context,
      builder: (context) => _VehicleEventDialog(event: event),
    );
    if (result == null) return;

    try {
      if (event == null) {
        await _eventService.createEvent(
          dspUid: widget.dspUid,
          plateNumber: widget.vehicle.plateNumber,
          draft: result.draft,
          fileBytes: result.file?.bytes,
          originalFileName: result.file?.name,
        );
        _showSnack(
          AppLocalizations.of(
            context,
          ).t('fleet_status_vehicle_events_create_success'),
        );
      } else {
        await _eventService.updateEvent(
          dspUid: widget.dspUid,
          plateNumber: widget.vehicle.plateNumber,
          eventId: event.eventId,
          existingEvent: event,
          draft: result.draft,
          fileBytes: result.file?.bytes,
          originalFileName: result.file?.name,
        );
        _showSnack(
          AppLocalizations.of(
            context,
          ).t('fleet_status_vehicle_events_update_success'),
        );
      }
    } on FleetVehicleEventException catch (e) {
      _showSnack(e.message, error: true);
    } on FirebaseException catch (e) {
      _showSnack(
        e.code == 'permission-denied'
            ? AppLocalizations.of(context).t('fleet_status_permission_denied')
            : AppLocalizations.of(
                context,
              ).tf('fleet_status_vehicle_events_save_failed', {'error': '$e'}),
        error: true,
      );
    } catch (e) {
      _showSnack(
        AppLocalizations.of(
          context,
        ).tf('fleet_status_vehicle_events_save_failed', {'error': '$e'}),
        error: true,
      );
    }
  }

  Future<void> _deleteVehicleEvent(FleetVehicleEvent event) async {
    final t = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.t('fleet_status_vehicle_events_delete_title')),
        content: Text(
          t.tf('fleet_status_vehicle_events_delete_body', {
            'title': event.title,
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
            label: t.t('button_delete'),
            variant: CoButtonVariant.destructive,
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _eventService.softDeleteEvent(
        dspUid: widget.dspUid,
        plateNumber: widget.vehicle.plateNumber,
        eventId: event.eventId,
      );
      _showSnack(t.t('fleet_status_vehicle_events_delete_success'));
    } on FirebaseException catch (e) {
      _showSnack(
        e.code == 'permission-denied'
            ? t.t('fleet_status_permission_denied')
            : t.tf('fleet_status_vehicle_events_delete_failed', {
                'error': '$e',
              }),
        error: true,
      );
    } catch (e) {
      _showSnack(
        t.tf('fleet_status_vehicle_events_delete_failed', {'error': '$e'}),
        error: true,
      );
    }
  }

  Future<void> _openVehicleEventFile(FleetVehicleEvent event) async {
    final url = event.fileUrl.trim();
    if (url.isEmpty) {
      _showSnack(
        AppLocalizations.of(
          context,
        ).t('fleet_status_vehicle_events_missing_file'),
        error: true,
      );
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null) {
      _showSnack(
        AppLocalizations.of(
          context,
        ).t('fleet_status_vehicle_events_open_failed'),
        error: true,
      );
      return;
    }
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      _showSnack(
        AppLocalizations.of(
          context,
        ).t('fleet_status_vehicle_events_open_failed'),
        error: true,
      );
    }
  }

  List<FleetVehicleEvent> _filterEvents(List<FleetVehicleEvent> events) {
    return events.where((event) {
      // Wartungs-/Verschleißteil-Einträge haben ihre eigene Sektion.
      if (event.eventType.trim().toUpperCase() == 'MAINTENANCE') {
        return false;
      }
      if (_eventTypeFilter != _eventTypeAllValue &&
          event.eventType != _eventTypeFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  void _showSnack(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: error ? _FleetStatusPageState._kRed : null,
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        scrolledUnderElevation: 0.5,
        title: Text(
          widget.vehicle.plateNumber,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: AppLocalizations.of(context).t('button_close'),
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 1100;
          final left = SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfileStyleCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.t('fleet_status_vehicle_details_information_title'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _FleetStatusPageState._kText,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _InfoRow(
                    label: t.t('fleet_status_field_plate_number'),
                    value: widget.vehicle.plateNumber,
                  ),
                  const SizedBox(height: 10),
                  _InfoRow(
                    label: t.t('fleet_status_field_category'),
                    value: _categoryLabel(context, widget.vehicle.category),
                  ),
                  const SizedBox(height: 10),
                  _InfoRow(
                    label: t.t('fleet_status_field_brand'),
                    value: widget.vehicle.brand,
                  ),
                  const SizedBox(height: 10),
                  _InfoRow(
                    label: t.t('fleet_status_field_model'),
                    value: widget.vehicle.model,
                  ),
                  const SizedBox(height: 10),
                  _InfoRow(
                    label: t.t('fleet_status_field_manufacturing_year'),
                    value: widget.vehicle.manufacturingYear == 0
                        ? t.t('fleet_status_vehicle_details_not_set')
                        : '${widget.vehicle.manufacturingYear}',
                  ),
                  const SizedBox(height: 10),
                  _InfoRow(
                    label: t.t('fleet_status_field_vin_number'),
                    value: widget.vehicle.vinNumber,
                  ),
                  const SizedBox(height: 10),
                  _InfoRow(
                    label: t.t('fleet_status_field_fuel_type'),
                    value: _fuelTypeLabel(context, widget.vehicle.fuelType),
                  ),
                  // const SizedBox(height: 10),
                  // _InfoRow(
                  //   label: t.t('fleet_status_field_odometer_km'),
                  //   value: '${widget.vehicle.odometerKm} km',
                  // ),
                  // const SizedBox(height: 10),
                  // _InfoRow(
                  //   label: t.t('fleet_status_field_registration_date'),
                  //   value: _formatStoredDate(context, widget.vehicle.registrationDate),
                  // ),
                  const SizedBox(height: 10),
                  _InfoRow(
                    label: t.t('fleet_status_field_status'),
                    value: _statusLabel(context, widget.vehicle.status),
                  ),
                  const SizedBox(height: 10),
                  _InfoRow(
                    label: t.t('fleet_status_field_service_end_date'),
                    value: _serviceEndDetailsLabel(context, widget.vehicle),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _ProfileStyleCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.t('fleet_status_section_metadata'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _FleetStatusPageState._kText,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ..._metadataRows(context, widget.vehicle),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _ProfileStyleCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.t('fleet_status_section_notes'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _FleetStatusPageState._kText,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    widget.vehicle.notes.trim().isEmpty
                        ? t.t('fleet_status_vehicle_details_not_set')
                        : widget.vehicle.notes,
                    style: const TextStyle(
                      color: _FleetStatusPageState._kText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(
                    label: t.t('fleet_status_vehicle_details_created_at'),
                    value: _formatDateTime(context, widget.vehicle.createdAt),
                  ),
                  const SizedBox(height: 10),
                  _InfoRow(
                    label: t.t('fleet_status_vehicle_details_updated_at'),
                    value: _formatDateTime(context, widget.vehicle.updatedAt),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _ProfileStyleCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          t.t('fleet_status_vehicle_documents_title'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _FleetStatusPageState._kText,
                          ),
                        ),
                      ),
                      if (widget.canManageDocuments)
                        CoButton(
                          onPressed: () => _showDocumentDialog(),
                          icon: Icons.add,
                          label: t.t(
                            'fleet_status_vehicle_documents_add_action',
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  StreamBuilder<List<FleetVehicleDocument>>(
                    stream: _documentService.watchDocuments(
                      dspUid: widget.dspUid,
                      plateNumber: widget.vehicle.plateNumber,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting &&
                          !snapshot.hasData) {
                        return const CoStateSwitcher(
                          child: LinearProgressIndicator(
                            key: ValueKey('docs-loading'),
                            minHeight: 2,
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return CoStateSwitcher(
                          child: Text(
                            key: const ValueKey('docs-error'),
                            t.tf('fleet_status_vehicle_documents_load_failed', {
                              'error': '${snapshot.error}',
                            }),
                          ),
                        );
                      }
                      final docs =
                          snapshot.data ?? const <FleetVehicleDocument>[];
                      if (docs.isEmpty) {
                        return CoStateSwitcher(
                          child: Container(
                            key: const ValueKey('docs-empty'),
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: _FleetStatusPageState._kBorder,
                              ),
                            ),
                            child: Text(
                              t.t('fleet_status_vehicle_documents_empty'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: _FleetStatusPageState._kMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }
                      return CoStateSwitcher(
                        child: Column(
                          key: const ValueKey('docs-list'),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: docs.map((doc) {
                          final status = _documentStatusFor(
                            context,
                            _documentService.getDocumentStatus(
                              expiryDate: doc.expiryDate,
                              fileUrl: doc.fileUrl,
                            ),
                          );
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Material(
                              color: Colors.transparent,
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF7F8F8),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFE1E4EA),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Text(
                                              //   doc.documentName,
                                              //   style: const TextStyle(
                                              //     fontWeight: FontWeight.w800,
                                              //     color: _FleetStatusPageState
                                              //         ._kText,
                                              //   ),
                                              // ),
                                              // const SizedBox(height: 6),
                                              Wrap(
                                                spacing: 8,
                                                runSpacing: 8,
                                                children: [
                                                  _StatusBadge(
                                                    label: _documentTypeLabel(
                                                      doc.documentType,
                                                    ),
                                                    color: _FleetStatusPageState
                                                        ._kBlue,
                                                  ),
                                                  _StatusBadge(
                                                    label: status.label,
                                                    color: status.color,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              tooltip: t.t('button_open'),
                                              onPressed: () =>
                                                  _openDocument(doc),
                                              icon: const Icon(
                                                Icons.open_in_new_outlined,
                                              ),
                                            ),
                                            if (widget.canManageDocuments)
                                              const SizedBox(width: 4),
                                            if (widget.canManageDocuments) ...[
                                              IconButton(
                                                tooltip: t.t('button_edit'),
                                                onPressed: () =>
                                                    _showDocumentDialog(
                                                      document: doc,
                                                    ),
                                                icon: const Icon(
                                                  Icons.edit_outlined,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              IconButton(
                                                tooltip: t.t('button_delete'),
                                                onPressed: () =>
                                                    _deleteDocument(doc),
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    _InfoRow(
                                      label: t.t(
                                        'fleet_status_vehicle_documents_document_number',
                                      ),
                                      value: doc.documentNumber.trim().isEmpty
                                          ? t.t(
                                              'fleet_status_vehicle_details_not_set',
                                            )
                                          : doc.documentNumber,
                                    ),
                                    // const SizedBox(height: 8),
                                    // _InfoRow(
                                    //   label: t.t(
                                    //     'fleet_status_vehicle_documents_issue_date',
                                    //   ),
                                    //   value: _formatStoredDate(
                                    //     context,
                                    //     doc.issueDate,
                                    //   ),
                                    // ),
                                    const SizedBox(height: 8),
                                    _InfoRow(
                                      label: t.t(
                                        'fleet_status_vehicle_documents_expiry_date',
                                      ),
                                      value: _formatStoredDate(
                                        context,
                                        doc.expiryDate,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _InfoRow(
                                      label: t.t(
                                        'fleet_status_vehicle_documents_file_name',
                                      ),
                                      value: doc.fileName.trim().isEmpty
                                          ? t.t(
                                              'fleet_status_vehicle_details_not_set',
                                            )
                                          : doc.fileName,
                                    ),
                                    const SizedBox(height: 8),
                                    _InfoRow(
                                      label: t.t(
                                        'fleet_status_vehicle_documents_file_type',
                                      ),
                                      value: doc.fileType.trim().isEmpty
                                          ? t.t(
                                              'fleet_status_vehicle_details_not_set',
                                            )
                                          : doc.fileType,
                                    ),
                                    const SizedBox(height: 8),
                                    _InfoRow(
                                      label: t.t('fleet_status_field_notes'),
                                      value: doc.notes.trim().isEmpty
                                          ? t.t(
                                              'fleet_status_vehicle_details_not_set',
                                            )
                                          : doc.notes,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _VehicleMaintenanceSection(
              dspUid: widget.dspUid,
              plateNumber: widget.vehicle.plateNumber,
              eventService: _eventService,
              canManage: widget.canManageDocuments,
            ),
          ],
        ),
          );
          final right = SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(isWide ? 0 : 24, 24, 24, 24),
            child: _ProfileStyleCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          t.t('fleet_status_vehicle_events_title'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _FleetStatusPageState._kText,
                          ),
                        ),
                      ),
                      if (widget.canManageDocuments)
                        CoButton(
                          onPressed: () => _showVehicleEventDialog(),
                          icon: Icons.add,
                          label: t.t(
                            'fleet_status_vehicle_events_add_action',
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: 240,
                      child: DropdownButtonFormField<String>(
                        value: _eventTypeFilter,
                        decoration: InputDecoration(
                          labelText: t.t(
                            'fleet_status_vehicle_events_filter_type',
                          ),
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
                        items: [
                          DropdownMenuItem<String>(
                            value: _eventTypeAllValue,
                            child: Text(
                              t.t(
                                'fleet_status_vehicle_events_filter_all_types',
                              ),
                            ),
                          ),
                          ...fleetVehicleEventTypeOptions.map(
                            (type) => DropdownMenuItem<String>(
                              value: type,
                              child: Text(_eventTypeLabel(context, type)),
                            ),
                          ),
                        ],
                        dropdownColor: Colors.white,
                        elevation: 8,
                        borderRadius: BorderRadius.circular(14),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _eventTypeFilter = value);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  StreamBuilder<List<FleetVehicleEvent>>(
                    stream: _eventService.watchEvents(
                      dspUid: widget.dspUid,
                      plateNumber: widget.vehicle.plateNumber,
                      eventType: _eventTypeFilter == _eventTypeAllValue
                          ? null
                          : _eventTypeFilter,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting &&
                          !snapshot.hasData) {
                        return const CoStateSwitcher(
                          child: LinearProgressIndicator(
                            key: ValueKey('events-loading'),
                            minHeight: 2,
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return CoStateSwitcher(
                          child: Text(
                            key: const ValueKey('events-error'),
                            t.tf('fleet_status_vehicle_events_load_failed', {
                              'error': '${snapshot.error}',
                            }),
                          ),
                        );
                      }
                      final events = _filterEvents(
                        snapshot.data ?? const <FleetVehicleEvent>[],
                      );
                      if (events.isEmpty) {
                        return CoStateSwitcher(
                          child: Container(
                            key: const ValueKey('events-empty'),
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: _FleetStatusPageState._kBorder,
                              ),
                            ),
                            child: Text(
                              t.t('fleet_status_vehicle_events_empty'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: _FleetStatusPageState._kMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }
                      return CoStateSwitcher(
                        child: Column(
                          key: const ValueKey('events-list'),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: events.map((event) {
                            final metadata = event.metadata;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Material(
                              color: Colors.transparent,
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF7F8F8),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFE1E4EA),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                event.title,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  color: _FleetStatusPageState
                                                      ._kText,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Wrap(
                                                spacing: 8,
                                                runSpacing: 8,
                                                children: [
                                                  _StatusBadge(
                                                    label: _eventTypeLabel(
                                                      context,
                                                      event.eventType,
                                                    ),
                                                    color: event.isAccident
                                                        ? _FleetStatusPageState
                                                              ._kRed
                                                        : _FleetStatusPageState
                                                              ._kBlue,
                                                  ),
                                                  if (event.isAccident &&
                                                      (metadata['damageLevel'] ??
                                                              '')
                                                          .toString()
                                                          .trim()
                                                          .isNotEmpty)
                                                    _StatusBadge(
                                                      label:
                                                          metadata['damageLevel']
                                                              .toString(),
                                                      color:
                                                          _FleetStatusPageState
                                                              ._kOrange,
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (event.fileUrl.trim().isNotEmpty)
                                              IconButton(
                                                tooltip: t.t('button_open'),
                                                onPressed: () =>
                                                    _openVehicleEventFile(
                                                      event,
                                                    ),
                                                icon: const Icon(
                                                  Icons.open_in_new_outlined,
                                                ),
                                              ),
                                            if (event.fileUrl.trim().isNotEmpty &&
                                                widget.canManageDocuments)
                                              const SizedBox(width: 4),
                                            if (widget.canManageDocuments) ...[
                                              IconButton(
                                                tooltip: t.t('button_edit'),
                                                onPressed: () =>
                                                    _showVehicleEventDialog(
                                                      event: event,
                                                    ),
                                                icon: const Icon(
                                                  Icons.edit_outlined,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              IconButton(
                                                tooltip: t.t('button_delete'),
                                                onPressed: () =>
                                                    _deleteVehicleEvent(event),
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    _InfoRow(
                                      label: t.t(
                                        'fleet_status_vehicle_events_type',
                                      ),
                                      value: _eventTypeLabel(
                                        context,
                                        event.eventType,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _InfoRow(
                                      label: t.t(
                                        'fleet_status_vehicle_events_event_date',
                                      ),
                                      value: _formatStoredDate(
                                        context,
                                        event.eventDate,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (event.isAccident) ...[
                                      _InfoRow(
                                        label: t.t(
                                          'fleet_status_vehicle_events_location',
                                        ),
                                        value:
                                            (metadata['location'] ?? '')
                                                .toString()
                                                .trim()
                                                .isEmpty
                                            ? t.t(
                                                'fleet_status_vehicle_details_not_set',
                                              )
                                            : metadata['location'].toString(),
                                      ),
                                      const SizedBox(height: 8),
                                      _InfoRow(
                                        label: t.t(
                                          'fleet_status_vehicle_events_damage_level',
                                        ),
                                        value:
                                            (metadata['damageLevel'] ?? '')
                                                .toString()
                                                .trim()
                                                .isEmpty
                                            ? t.t(
                                                'fleet_status_vehicle_details_not_set',
                                              )
                                            : (metadata['damageLevel'] ?? '')
                                                  .toString(),
                                      ),
                                      const SizedBox(height: 8),
                                      _InfoRow(
                                        label: t.t(
                                          'fleet_status_vehicle_events_police_report_number',
                                        ),
                                        value:
                                            (metadata['policeReportNumber'] ??
                                                    '')
                                                .toString()
                                                .trim()
                                                .isEmpty
                                            ? t.t(
                                                'fleet_status_vehicle_details_not_set',
                                              )
                                            : metadata['policeReportNumber']
                                                  .toString(),
                                      ),
                                      const SizedBox(height: 8),
                                      _InfoRow(
                                        label: t.t(
                                          'fleet_status_vehicle_events_insurance_claim_number',
                                        ),
                                        value:
                                            (metadata['insuranceClaimNumber'] ??
                                                    '')
                                                .toString()
                                                .trim()
                                                .isEmpty
                                            ? t.t(
                                                'fleet_status_vehicle_details_not_set',
                                              )
                                            : metadata['insuranceClaimNumber']
                                                  .toString(),
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                    _InfoRow(
                                      label: t.t(
                                        'fleet_status_vehicle_documents_file_name',
                                      ),
                                      value: event.fileName.trim().isEmpty
                                          ? t.t(
                                              'fleet_status_vehicle_details_not_set',
                                            )
                                          : event.fileName,
                                    ),
                                    const SizedBox(height: 8),
                                    _InfoRow(
                                      label: t.t(
                                        'fleet_status_vehicle_documents_file_type',
                                      ),
                                      value: event.fileType.trim().isEmpty
                                          ? t.t(
                                              'fleet_status_vehicle_details_not_set',
                                            )
                                          : event.fileType,
                                    ),
                                    const SizedBox(height: 8),
                                    _InfoRow(
                                      label: t.t('fleet_status_field_notes'),
                                      value: event.notes.trim().isEmpty
                                          ? t.t(
                                              'fleet_status_vehicle_details_not_set',
                                            )
                                          : event.notes,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 7, child: left),
                Expanded(flex: 3, child: right),
              ],
            );
          }
          return SingleChildScrollView(
            child: Column(
              children: [left, right],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _metadataRows(BuildContext context, FleetVehicle vehicle) {
    final rows = <MapEntry<String, String>>[];
    switch (vehicle.category) {
      case VehicleCategory.armada:
        final metadata = vehicle.metadata as ArmadaVehicleMetadata;
        rows.add(
          MapEntry(
            AppLocalizations.of(context).t('fleet_status_field_armada_id'),
            metadata.armadaId,
          ),
        );
        rows.add(
          MapEntry(
            AppLocalizations.of(
              context,
            ).t('fleet_status_field_armada_company_name'),
            metadata.armadaCompanyName,
          ),
        );
        rows.add(
          MapEntry(
            AppLocalizations.of(
              context,
            ).t('fleet_status_field_contract_start_date'),
            _formatStoredDate(context, metadata.contractStartDate),
          ),
        );
        rows.add(
          MapEntry(
            AppLocalizations.of(
              context,
            ).t('fleet_status_field_contract_end_date'),
            _formatStoredDate(context, metadata.contractEndDate),
          ),
        );
        break;
      case VehicleCategory.amazonPaidRental:
        final metadata = vehicle.metadata as AmazonPaidRentalMetadata;
        rows.add(
          MapEntry(
            AppLocalizations.of(
              context,
            ).t('fleet_status_field_rental_company_name'),
            metadata.rentalCompanyName,
          ),
        );
        rows.add(
          MapEntry(
            AppLocalizations.of(
              context,
            ).t('fleet_status_field_contract_number'),
            metadata.contractNumber,
          ),
        );
        rows.add(
          MapEntry(
            AppLocalizations.of(
              context,
            ).t('fleet_status_field_rental_start_date'),
            _formatStoredDate(context, metadata.rentalStartDate),
          ),
        );
        rows.add(
          MapEntry(
            AppLocalizations.of(
              context,
            ).t('fleet_status_field_rental_end_date'),
            _formatStoredDate(context, metadata.rentalEndDate),
          ),
        );
        break;
      case VehicleCategory.selfSourcedRental:
        final metadata = vehicle.metadata as SelfSourcedRentalMetadata;
        rows.add(
          MapEntry(
            AppLocalizations.of(context).t('fleet_status_field_owner_name'),
            metadata.ownerName,
          ),
        );
        rows.add(
          MapEntry(
            AppLocalizations.of(
              context,
            ).t('fleet_status_field_owner_contact_number'),
            metadata.ownerContactNumber,
          ),
        );
        rows.add(
          MapEntry(
            AppLocalizations.of(
              context,
            ).t('fleet_status_field_rental_agreement_number'),
            metadata.rentalAgreementNumber,
          ),
        );
        rows.add(
          MapEntry(
            AppLocalizations.of(
              context,
            ).t('fleet_status_field_rental_start_date'),
            _formatStoredDate(context, metadata.rentalStartDate),
          ),
        );
        rows.add(
          MapEntry(
            AppLocalizations.of(
              context,
            ).t('fleet_status_field_rental_end_date'),
            _formatStoredDate(context, metadata.rentalEndDate),
          ),
        );
        break;
      case VehicleCategory.selfOwnedRental:
        final metadata = vehicle.metadata as SelfOwnedRentalMetadata;
        rows.add(
          MapEntry(
            AppLocalizations.of(context).t('fleet_status_field_ownership_type'),
            metadata.ownershipType,
          ),
        );
        rows.add(
          MapEntry(
            AppLocalizations.of(context).t('fleet_status_field_purchase_date'),
            _formatStoredDate(context, metadata.purchaseDate),
          ),
        );
        break;
    }

    return rows
        .map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _InfoRow(
              label: entry.key,
              value: entry.value.trim().isEmpty
                  ? AppLocalizations.of(
                      context,
                    ).t('fleet_status_vehicle_details_not_set')
                  : entry.value,
            ),
          ),
        )
        .toList();
  }
}

class _VehicleDocumentDialogResult {
  const _VehicleDocumentDialogResult({required this.draft, required this.file});

  final FleetVehicleDocumentDraft draft;
  final PlatformFile file;
}

class _VehicleEventDialogResult {
  const _VehicleEventDialogResult({required this.draft, required this.file});

  final FleetVehicleEventDraft draft;
  final PlatformFile? file;
}

class _VehicleEventDialog extends StatefulWidget {
  const _VehicleEventDialog({this.event});

  final FleetVehicleEvent? event;

  @override
  State<_VehicleEventDialog> createState() => _VehicleEventDialogState();
}

class _VehicleEventDialogState extends State<_VehicleEventDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _eventDateCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _policeReportCtrl;
  late final TextEditingController _insuranceClaimCtrl;
  late final TextEditingController _notesCtrl;
  late String _eventType;
  late String _damageLevel;
  PlatformFile? _selectedFile;

  bool get _isEditing => widget.event != null;

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    final metadata = event?.metadata ?? const <String, dynamic>{};
    _titleCtrl = TextEditingController(text: event?.title ?? '');
    _eventDateCtrl = TextEditingController(text: event?.eventDate ?? '');
    _locationCtrl = TextEditingController(
      text: (metadata['location'] ?? '').toString(),
    );
    _policeReportCtrl = TextEditingController(
      text: (metadata['policeReportNumber'] ?? '').toString(),
    );
    _insuranceClaimCtrl = TextEditingController(
      text: (metadata['insuranceClaimNumber'] ?? '').toString(),
    );
    _notesCtrl = TextEditingController(text: event?.notes ?? '');
    _eventType = _resolveInitialEventType(event?.eventType);
    _damageLevel = _resolveInitialDamageLevel(
      metadata['damageLevel']?.toString(),
    );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _eventDateCtrl.dispose();
    _locationCtrl.dispose();
    _policeReportCtrl.dispose();
    _insuranceClaimCtrl.dispose();
    _notesCtrl.dispose();
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

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    setState(() => _selectedFile = result.files.first);
  }

  String _resolveInitialDamageLevel(String? currentValue) {
    final normalized = (currentValue ?? '').trim();
    if (normalized.isNotEmpty) return normalized;
    return fleetVehicleAccidentDamageLevelOptions.first;
  }

  String _resolveInitialEventType(String? currentValue) {
    final normalized = (currentValue ?? '').trim();
    if (normalized.isNotEmpty) return normalized;
    return fleetVehicleEventTypeOptions.first;
  }

  List<String> _damageLevelItems() {
    final items = <String>[...fleetVehicleAccidentDamageLevelOptions];
    if (!items.contains(_damageLevel)) {
      items.insert(0, _damageLevel);
    }
    return items;
  }

  List<String> _eventTypeItems() {
    final items = <String>[...fleetVehicleEventTypeOptions];
    if (!items.contains(_eventType)) {
      items.insert(0, _eventType);
    }
    return items;
  }

  bool get _isAccidentType => _eventType.trim().toUpperCase() == 'ACCIDENT';

  void _submit() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    final existing = widget.event;
    final file = _selectedFile;
    final resolvedFileName = file?.name ?? existing?.fileName ?? '';
    Navigator.of(context).pop(
      _VehicleEventDialogResult(
        draft: FleetVehicleEventDraft(
          eventType: _eventType.trim(),
          title: _titleCtrl.text.trim(),
          eventDate: _eventDateCtrl.text.trim(),
          metadata: _isAccidentType
              ? {
                  'location': _locationCtrl.text.trim(),
                  'damageLevel': _damageLevel.trim(),
                  'policeReportNumber': _policeReportCtrl.text.trim(),
                  'insuranceClaimNumber': _insuranceClaimCtrl.text.trim(),
                }
              : const <String, dynamic>{},
          fileName: resolvedFileName,
          fileType: _detectFileType(resolvedFileName, existing?.fileType ?? ''),
          notes: _notesCtrl.text.trim(),
        ),
        file: file,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final existing = widget.event;
    return Dialog(
      elevation: 8,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
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
                        ? 'fleet_status_vehicle_events_edit_title'
                        : 'fleet_status_vehicle_events_add_title',
                  ),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _titleCtrl,
                  decoration: _documentInputDecoration(
                    t.t('fleet_status_vehicle_events_title_field'),
                  ),
                  validator: (value) => _requiredText(
                    context,
                    value,
                    t.t('fleet_status_vehicle_events_title_field'),
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _eventType,
                  decoration: _documentInputDecoration(
                    t.t('fleet_status_vehicle_events_type'),
                  ),
                  items: _eventTypeItems()
                      .map(
                        (type) => DropdownMenuItem<String>(
                          value: type,
                          child: Text(_eventTypeLabel(context, type)),
                        ),
                      )
                      .toList(),
                  dropdownColor: Colors.white,
                  elevation: 8,
                  borderRadius: BorderRadius.circular(14),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _eventType = value);
                  },
                ),
                const SizedBox(height: 14),
                _DateInputField(
                  controller: _eventDateCtrl,
                  label: t.t('fleet_status_vehicle_events_event_date'),
                  onPick: () => _pickDate(_eventDateCtrl),
                  validator: (value) => _requiredDate(
                    context,
                    value,
                    t.t('fleet_status_vehicle_events_event_date'),
                  ),
                ),
                const SizedBox(height: 14),
                if (_isAccidentType) ...[
                  TextFormField(
                    controller: _locationCtrl,
                    decoration: _documentInputDecoration(
                      t.t('fleet_status_vehicle_events_location'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: _damageLevel,
                    decoration: _documentInputDecoration(
                      t.t('fleet_status_vehicle_events_damage_level'),
                    ),
                    items: _damageLevelItems()
                        .map(
                          (level) => DropdownMenuItem<String>(
                            value: level,
                            child: Text(level),
                          ),
                        )
                        .toList(),
                    dropdownColor: Colors.white,
                    elevation: 8,
                    borderRadius: BorderRadius.circular(14),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _damageLevel = value);
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _policeReportCtrl,
                    decoration: _documentInputDecoration(
                      t.t('fleet_status_vehicle_events_police_report_number'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _insuranceClaimCtrl,
                    decoration: _documentInputDecoration(
                      t.t('fleet_status_vehicle_events_insurance_claim_number'),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    CoButton(
                      onPressed: _pickFile,
                      icon: Icons.upload_file_outlined,
                      label: _selectedFile == null
                          ? t.t('fleet_status_vehicle_events_pick_file')
                          : t.t('fleet_status_vehicle_events_change_file'),
                      variant: CoButtonVariant.secondaryOutlined,
                    ),
                    SizedBox(
                      width: 280,
                      child: Text(
                        _selectedFile?.name ??
                            existing?.fileName ??
                            t.t('fleet_status_vehicle_events_no_file'),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _FleetStatusPageState._kMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _notesCtrl,
                  minLines: 3,
                  maxLines: 5,
                  decoration: _documentInputDecoration(
                    t.t('fleet_status_field_notes'),
                  ),
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
                      label: t.t(_isEditing ? 'button_save' : 'button_add'),
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
}

class _VehicleDocumentDialog extends StatefulWidget {
  const _VehicleDocumentDialog({this.document});

  final FleetVehicleDocument? document;

  @override
  State<_VehicleDocumentDialog> createState() => _VehicleDocumentDialogState();
}

class _VehicleDocumentDialogState extends State<_VehicleDocumentDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _documentNumberCtrl;
  late final TextEditingController _expiryDateCtrl;
  late final TextEditingController _notesCtrl;
  late String _documentType;
  PlatformFile? _selectedFile;

  bool get _isEditing => widget.document != null;

  @override
  void initState() {
    super.initState();
    final document = widget.document;
    _documentType = _resolveInitialDocumentType(document?.documentType);
    _documentNumberCtrl = TextEditingController(
      text: document?.documentNumber ?? '',
    );
    _expiryDateCtrl = TextEditingController(text: document?.expiryDate ?? '');
    _notesCtrl = TextEditingController(text: document?.notes ?? '');
  }

  @override
  void dispose() {
    _documentNumberCtrl.dispose();
    _expiryDateCtrl.dispose();
    _notesCtrl.dispose();
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

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    setState(() => _selectedFile = result.files.first);
  }

  String _resolveInitialDocumentType(String? currentValue) {
    final normalized = _canonicalVehicleDocumentType(
      (currentValue ?? '').trim(),
    );
    if (normalized.isNotEmpty) {
      return normalized;
    }
    return _vehicleDocumentTypeOptions.first;
  }

  List<String> _documentTypeItems() {
    final items = <String>[..._vehicleDocumentTypeOptions];
    if (!items.contains(_documentType)) {
      items.insert(0, _documentType);
    }
    return items;
  }

  void _submit() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    if (!_isEditing &&
        (_selectedFile == null || _selectedFile!.bytes == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: _FleetStatusPageState._kRed,
          content: Text(
            AppLocalizations.of(
              context,
            ).t('fleet_status_vehicle_documents_file_required'),
          ),
        ),
      );
      return;
    }

    final existing = widget.document;
    final file =
        _selectedFile ??
        PlatformFile(name: existing?.fileName ?? '', size: 0, bytes: null);

    Navigator.of(context).pop(
      _VehicleDocumentDialogResult(
        draft: FleetVehicleDocumentDraft(
          documentType: _documentType.trim(),
          documentNumber: _documentNumberCtrl.text.trim(),
          expiryDate: _expiryDateCtrl.text.trim(),
          fileName: file.name.trim().isEmpty
              ? (existing?.fileName ?? '')
              : file.name,
          fileType: _detectFileType(file.name, existing?.fileType ?? ''),
          notes: _notesCtrl.text.trim(),
        ),
        file: file,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final existing = widget.document;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 680,
            maxHeight: MediaQuery.of(context).size.height * 0.92,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                Text(
                  t.t(
                    _isEditing
                        ? 'fleet_status_vehicle_documents_edit_title'
                        : 'fleet_status_vehicle_documents_add_title',
                  ),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 18),
                if (_isEditing)
                  InputDecorator(
                    decoration: _documentInputDecoration(
                      t.t('fleet_status_vehicle_documents_document_type'),
                    ),
                    child: Text(
                      _documentTypeLabel(_documentType),
                      style: const TextStyle(
                        color: _FleetStatusPageState._kText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else
                  DropdownButtonFormField<String>(
                    value: _documentType,
                    decoration: _documentInputDecoration(
                      t.t('fleet_status_vehicle_documents_document_type'),
                    ),
                    items: _documentTypeItems()
                        .map(
                          (type) => DropdownMenuItem<String>(
                            value: type,
                            child: Text(_documentTypeLabel(type)),
                          ),
                        )
                        .toList(),
                    dropdownColor: Colors.white,
                    elevation: 8,
                    borderRadius: BorderRadius.circular(14),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _documentType = value);
                    },
                  ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _documentNumberCtrl,
                  decoration: _documentInputDecoration(
                    t.t('fleet_status_vehicle_documents_document_number'),
                  ),
                ),
                const SizedBox(height: 14),
                _DateInputField(
                  controller: _expiryDateCtrl,
                  label: t.t(
                    'fleet_status_vehicle_documents_expiry_date',
                  ),
                  onPick: () => _pickDate(_expiryDateCtrl),
                  validator: (value) => _requiredDate(
                    context,
                    value,
                    t.t('fleet_status_vehicle_documents_expiry_date'),
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    CoButton(
                      onPressed: _pickFile,
                      icon: Icons.upload_file_outlined,
                      label: _selectedFile == null
                          ? t.t('fleet_status_vehicle_documents_pick_file')
                          : t.t('fleet_status_vehicle_documents_change_file'),
                      variant: CoButtonVariant.secondaryOutlined,
                    ),
                    SizedBox(
                      width: 280,
                      child: Text(
                        _selectedFile?.name ??
                            existing?.fileName ??
                            t.t('fleet_status_vehicle_documents_no_file'),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _FleetStatusPageState._kMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _notesCtrl,
                  minLines: 3,
                  maxLines: 5,
                  decoration: _documentInputDecoration(
                    t.t('fleet_status_field_notes'),
                  ),
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
                      label: t.t(_isEditing ? 'button_save' : 'button_add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }

  String _serviceStartLabel(BuildContext context, FleetVehicle vehicle) {
    switch (vehicle.category) {
      case VehicleCategory.armada:
        final metadata = vehicle.metadata as ArmadaVehicleMetadata;
        return _dateOrNotApplicable(context, metadata.contractStartDate);
      case VehicleCategory.amazonPaidRental:
        final metadata = vehicle.metadata as AmazonPaidRentalMetadata;
        return _dateOrNotApplicable(context, metadata.rentalStartDate);
      case VehicleCategory.selfSourcedRental:
        final metadata = vehicle.metadata as SelfSourcedRentalMetadata;
        return _dateOrNotApplicable(context, metadata.rentalStartDate);
      case VehicleCategory.selfOwnedRental:
        return AppLocalizations.of(context).t('fleet_status_not_applicable');
    }
  }

  String _serviceEndLabel(BuildContext context, FleetVehicle vehicle) {
    return _optionalStoredDate(context, vehicle.serviceEndDate);
  }

  String _dateOrNotApplicable(BuildContext context, String value) {
    if (value.trim().isEmpty) {
      return AppLocalizations.of(context).t('fleet_status_not_applicable');
    }
    return _formatStoredDate(context, value);
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

class _ToolbarDropdown extends StatelessWidget {
  const _ToolbarDropdown({
    required this.value,
    required this.onChanged,
    required this.items,
  });

  final String value;
  final ValueChanged<String?> onChanged;
  final List<DropdownMenuItem<String>> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Container(
        constraints: const BoxConstraints(minWidth: 210),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: _FleetStatusPageState._kBorder),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: value,
            dropdownColor: Colors.white,
            elevation: 8,
            borderRadius: BorderRadius.circular(14),
            onChanged: onChanged,
            items: items,
          ),
        ),
      ),
    );
  }
}

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

class _VehicleTableHeaderCell extends StatelessWidget {
  const _VehicleTableHeaderCell({
    required this.label,
    required this.flex,
    this.alignment = Alignment.centerLeft,
  });

  final String label;
  final int flex;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Align(
        alignment: alignment,
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}

class _SoftPill extends StatelessWidget {
  const _SoftPill({
    required this.label,
    required this.textColor,
    required this.backgroundColor,
  });

  final String label;
  final Color textColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _MissingDocumentsBadge extends StatelessWidget {
  const _MissingDocumentsBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFDE2E1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFDC2626),
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
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

const String _kMaintenanceEventType = 'MAINTENANCE';
const List<String> _kMaintenanceComponents = <String>[
  'TIRE',
  'BRAKE',
  'OIL',
  'OTHER',
];

String _maintComponentLabel(String code, String lang) {
  switch (code.trim().toUpperCase()) {
    case 'TIRE':
      return lang == 'de' ? 'Reifen' : 'Tires';
    case 'BRAKE':
      return lang == 'de' ? 'Bremsen' : 'Brakes';
    case 'OIL':
      return lang == 'de' ? 'Öl' : 'Oil';
    default:
      return lang == 'de' ? 'Sonstiges' : 'Other';
  }
}

IconData _maintComponentIcon(String code) {
  switch (code.trim().toUpperCase()) {
    case 'TIRE':
      return Icons.tire_repair;
    case 'BRAKE':
      return Icons.album_outlined;
    case 'OIL':
      return Icons.oil_barrel_outlined;
    default:
      return Icons.build_circle_outlined;
  }
}

String _fmtKm(int km) {
  final s = km.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return '${km < 0 ? '-' : ''}${buf.toString()}';
}

int? _maintKmOf(FleetVehicleEvent e) {
  final v = e.metadata['kmStand'];
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse('${v ?? ''}'.trim());
}

/// One maintenance row with computed lifetime (how long this part held).
class _MaintRow {
  _MaintRow({
    required this.event,
    required this.component,
    required this.label,
    required this.km,
    required this.kmHeld,
    required this.isCurrent,
  });

  final FleetVehicleEvent event;
  final String component;
  final String label;
  final int? km;
  final int? kmHeld; // km the part lasted until the next change of same component
  final bool isCurrent; // newest of its component → still mounted
}

List<_MaintRow> _computeMaintLifetimes(List<FleetVehicleEvent> records) {
  String compOf(FleetVehicleEvent e) =>
      (e.metadata['component'] ?? 'OTHER').toString().trim().toUpperCase();
  String labelOf(FleetVehicleEvent e) =>
      (e.metadata['label'] ?? '').toString().trim();

  final byComp = <String, List<FleetVehicleEvent>>{};
  for (final e in records) {
    byComp.putIfAbsent(compOf(e), () => <FleetVehicleEvent>[]).add(e);
  }

  final rows = <_MaintRow>[];
  for (final entry in byComp.entries) {
    final withKm = entry.value.where((e) => _maintKmOf(e) != null).toList()
      ..sort((a, b) => _maintKmOf(a)!.compareTo(_maintKmOf(b)!));
    for (var i = 0; i < withKm.length; i++) {
      final e = withKm[i];
      final isCurrent = i == withKm.length - 1;
      final held = isCurrent ? null : _maintKmOf(withKm[i + 1])! - _maintKmOf(e)!;
      rows.add(_MaintRow(
        event: e,
        component: entry.key,
        label: labelOf(e),
        km: _maintKmOf(e),
        kmHeld: held,
        isCurrent: isCurrent,
      ));
    }
    // Records without a KM value can't be computed — list them as-is.
    for (final e in entry.value.where((e) => _maintKmOf(e) == null)) {
      rows.add(_MaintRow(
        event: e,
        component: entry.key,
        label: labelOf(e),
        km: null,
        kmHeld: null,
        isCurrent: false,
      ));
    }
  }
  // Display newest first (highest KM first; unknown KM last).
  rows.sort((a, b) => (b.km ?? -1).compareTo(a.km ?? -1));
  return rows;
}

class _VehicleMaintenanceSection extends StatelessWidget {
  const _VehicleMaintenanceSection({
    required this.dspUid,
    required this.plateNumber,
    required this.eventService,
    required this.canManage,
  });

  final String dspUid;
  final String plateNumber;
  final FleetVehicleEventService eventService;
  final bool canManage;

  String _ml(BuildContext context, String en, String de) =>
      Localizations.localeOf(context).languageCode == 'de' ? de : en;

  Future<void> _add(BuildContext context) async {
    final lang = Localizations.localeOf(context).languageCode;
    final messenger = ScaffoldMessenger.of(context);
    final result = await showModalBottomSheet<_MaintDraftResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _MaintenanceDialog(lang: lang),
    );
    if (result == null) return;
    try {
      await eventService.createEvent(
        dspUid: dspUid,
        plateNumber: plateNumber,
        draft: FleetVehicleEventDraft(
          eventType: _kMaintenanceEventType,
          title: result.label.isNotEmpty
              ? result.label
              : _maintComponentLabel(result.component, lang),
          eventDate: result.date,
          metadata: <String, dynamic>{
            'component': result.component,
            'label': result.label,
            'kmStand': result.kmStand,
          },
          fileName: '',
          fileType: '',
          notes: result.notes,
        ),
      );
      messenger.showSnackBar(
        SnackBar(
          content: Text(_ml(context, 'Maintenance entry saved.',
              'Wartungseintrag gespeichert.')),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: _FleetStatusPageState._kRed,
          content: Text(_ml(context, 'Could not save: $e',
              'Speichern fehlgeschlagen: $e')),
        ),
      );
    }
  }

  Future<void> _delete(BuildContext context, FleetVehicleEvent event) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_ml(ctx, 'Delete entry', 'Eintrag löschen')),
        content: Text(_ml(ctx, 'Permanently remove this maintenance entry?',
            'Diesen Wartungseintrag dauerhaft entfernen?')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(_ml(ctx, 'Cancel', 'Abbrechen')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: _FleetStatusPageState._kRed,
            ),
            child: Text(_ml(ctx, 'Delete', 'Löschen')),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await eventService.softDeleteEvent(
        dspUid: dspUid,
        plateNumber: plateNumber,
        eventId: event.eventId,
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: _FleetStatusPageState._kRed,
          content: Text(_ml(context, 'Could not delete: $e',
              'Löschen fehlgeschlagen: $e')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    return _ProfileStyleCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _ml(context, 'Maintenance / wear parts',
                      'Wartung / Verschleißteile'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _FleetStatusPageState._kText,
                  ),
                ),
              ),
              if (canManage)
                CoButton(
                  onPressed: () => _add(context),
                  icon: Icons.add,
                  label: _ml(context, 'Add', 'Hinzufügen'),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _ml(
              context,
              'Log tire / brake / oil changes by mileage — the system computes how long each part lasted.',
              'Reifen-/Bremsen-/Öl-Wechsel nach Kilometerstand erfassen — das System berechnet, wie lange jedes Teil gehalten hat.',
            ),
            style: const TextStyle(
              fontSize: 12.5,
              color: _FleetStatusPageState._kMuted,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          StreamBuilder<List<FleetVehicleEvent>>(
            stream: eventService.watchEvents(
              dspUid: dspUid,
              plateNumber: plateNumber,
              eventType: _kMaintenanceEventType,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const CoStateSwitcher(
                  child: LinearProgressIndicator(
                    key: ValueKey('maint-loading'),
                    minHeight: 2,
                  ),
                );
              }
              if (snapshot.hasError) {
                return CoStateSwitcher(
                  child: Text(
                    key: const ValueKey('maint-error'),
                    _ml(context, 'Could not load maintenance records.',
                        'Wartungseinträge konnten nicht geladen werden.'),
                  ),
                );
              }
              final records = (snapshot.data ?? const <FleetVehicleEvent>[])
                  .where((e) => !e.isDeleted)
                  .toList();
              if (records.isEmpty) {
                return CoStateSwitcher(
                  child: Container(
                    key: const ValueKey('maint-empty'),
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: _FleetStatusPageState._kBorder,
                      ),
                    ),
                    child: Text(
                      _ml(context, 'No maintenance entries yet.',
                          'Noch keine Wartungseinträge.'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: _FleetStatusPageState._kMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }
              final rows = _computeMaintLifetimes(records);
              return CoStateSwitcher(
                child: Column(
                  key: const ValueKey('maint-list'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: rows
                      .map((r) => _MaintTile(
                            row: r,
                            lang: lang,
                            canManage: canManage,
                            onDelete: () => _delete(context, r.event),
                            ml: _ml,
                          ))
                      .toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MaintTile extends StatelessWidget {
  const _MaintTile({
    required this.row,
    required this.lang,
    required this.canManage,
    required this.onDelete,
    required this.ml,
  });

  final _MaintRow row;
  final String lang;
  final bool canManage;
  final VoidCallback onDelete;
  final String Function(BuildContext, String, String) ml;

  @override
  Widget build(BuildContext context) {
    final compLabel = _maintComponentLabel(row.component, lang);
    final title = row.label.isNotEmpty ? '$compLabel — ${row.label}' : compLabel;
    final kmText = row.km != null
        ? '${ml(context, 'Mileage', 'KM-Stand')}: ${_fmtKm(row.km!)} km'
        : ml(context, 'Mileage: not set', 'KM-Stand: nicht gesetzt');
    final date = row.event.eventDate.trim();

    Widget? lifetimeBadge;
    if (row.kmHeld != null) {
      final name = row.label.isNotEmpty ? row.label : compLabel;
      lifetimeBadge = _maintBadge(
        color: const Color(0xFF067647),
        bg: const Color(0xFFD1FAE5),
        border: const Color(0xFF34D399),
        icon: Icons.timelapse_rounded,
        text: ml(context, '$name lasted ${_fmtKm(row.kmHeld!)} km',
            '$name hat ${_fmtKm(row.kmHeld!)} km gehalten'),
      );
    } else if (row.isCurrent && row.km != null) {
      lifetimeBadge = _maintBadge(
        color: const Color(0xFF1D4ED8),
        bg: const Color(0xFFDBEAFE),
        border: const Color(0xFF93C5FD),
        icon: Icons.check_circle_outline,
        text: ml(context, 'Currently fitted (since ${_fmtKm(row.km!)} km)',
            'Aktuell montiert (seit ${_fmtKm(row.km!)} km)'),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8F8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE1E4EA)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_maintComponentIcon(row.component),
                    size: 20, color: _FleetStatusPageState._kText),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: _FleetStatusPageState._kText,
                    ),
                  ),
                ),
                if (date.isNotEmpty)
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 12,
                      color: _FleetStatusPageState._kMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (canManage) ...[
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: onDelete,
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.delete_outline_rounded,
                          size: 18, color: _FleetStatusPageState._kMuted),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Text(
              kmText,
              style: const TextStyle(
                fontSize: 13,
                color: _FleetStatusPageState._kText,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (row.event.notes.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                row.event.notes.trim(),
                style: const TextStyle(
                  fontSize: 12.5,
                  color: _FleetStatusPageState._kMuted,
                  height: 1.35,
                ),
              ),
            ],
            if (lifetimeBadge != null) ...[
              const SizedBox(height: 10),
              lifetimeBadge,
            ],
          ],
        ),
      ),
    );
  }

  Widget _maintBadge({
    required Color color,
    required Color bg,
    required Color border,
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MaintDraftResult {
  _MaintDraftResult({
    required this.component,
    required this.label,
    required this.kmStand,
    required this.date,
    required this.notes,
  });

  final String component;
  final String label;
  final int kmStand;
  final String date; // YYYY-MM-DD
  final String notes;
}

class _MaintenanceDialog extends StatefulWidget {
  const _MaintenanceDialog({required this.lang});
  final String lang;

  @override
  State<_MaintenanceDialog> createState() => _MaintenanceDialogState();
}

class _MaintenanceDialogState extends State<_MaintenanceDialog> {
  String _component = 'TIRE';
  final _labelCtrl = TextEditingController();
  final _kmCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  late DateTime _date = DateTime.now();
  String? _error;

  String get _lang => widget.lang;
  String _ml(String en, String de) => _lang == 'de' ? de : en;

  @override
  void dispose() {
    _labelCtrl.dispose();
    _kmCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String _fmtDate(DateTime d) {
    String two(int v) => v < 10 ? '0$v' : '$v';
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }

  void _submit() {
    final kmRaw = _kmCtrl.text.trim().replaceAll('.', '').replaceAll(' ', '');
    final km = int.tryParse(kmRaw);
    if (km == null || km < 0) {
      setState(() => _error =
          _ml('Enter a valid mileage (km).', 'Bitte gültigen KM-Stand eingeben.'));
      return;
    }
    Navigator.of(context).pop(
      _MaintDraftResult(
        component: _component,
        label: _labelCtrl.text.trim(),
        kmStand: km,
        date: _fmtDate(_date),
        notes: _notesCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _ml('Add maintenance entry', 'Wartungseintrag hinzufügen'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _component,
              decoration: InputDecoration(
                labelText: _ml('Component', 'Bauteil'),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _kMaintenanceComponents
                  .map((c) => DropdownMenuItem<String>(
                        value: c,
                        child: Text(_maintComponentLabel(c, _lang)),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _component = v ?? 'TIRE'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _labelCtrl,
              decoration: InputDecoration(
                labelText: _ml('Label / designation (e.g. "TireXY")',
                    'Bezeichnung (z. B. "ReifenXY")'),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _kmCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: _ml('Mileage at change (km)', 'KM-Stand beim Wechsel'),
                hintText: 'z. B. 45000',
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2015),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => _date = picked);
              },
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: _ml('Change date', 'Wechseldatum'),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_fmtDate(_date)),
                    const Icon(Icons.calendar_today_rounded, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesCtrl,
              maxLines: 3,
              minLines: 2,
              decoration: InputDecoration(
                labelText: _ml('Notes (optional)', 'Notizen (optional)'),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                style: const TextStyle(
                  color: Color(0xFFB91C1C),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(_ml('Cancel', 'Abbrechen')),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: Text(_ml('Save', 'Speichern')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileStyleCard extends StatelessWidget {
  const _ProfileStyleCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: child,
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: _FleetStatusPageState._kMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: _FleetStatusPageState._kText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

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

class _ServiceEndDateDialog extends StatefulWidget {
  const _ServiceEndDateDialog({
    required this.initialValue,
    required this.requiredValue,
  });

  final String initialValue;
  final bool requiredValue;

  @override
  State<_ServiceEndDateDialog> createState() => _ServiceEndDateDialogState();
}

class _ServiceEndDateDialogState extends State<_ServiceEndDateDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
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
    return AlertDialog(
      title: Text(t.t('fleet_status_field_service_end_date')),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: _DateInputField(
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
            Navigator.of(context).pop(_controller.text.trim());
          },
          label: t.t('button_save'),
        ),
      ],
    );
  }
}

InputDecoration _documentInputDecoration(String label) {
  return InputDecoration(
    labelText: label,
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
    return AppLocalizations.of(context).tf('error_required', {'field': field});
  }
  return null;
}

String? _requiredDate(BuildContext context, String? value, String field) {
  final trimmed = (value ?? '').trim();
  if (trimmed.isEmpty) {
    return AppLocalizations.of(context).tf('error_required', {'field': field});
  }
  if (!isValidVehicleDate(trimmed)) {
    return AppLocalizations.of(context).t('fleet_status_invalid_date');
  }
  return null;
}

String _detectFileType(String fileName, String fallback) {
  final lower = fileName.toLowerCase();
  if (lower.endsWith('.pdf')) return 'PDF';
  if (lower.endsWith('.png')) return 'PNG';
  if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'JPG';
  if (lower.endsWith('.webp')) return 'WEBP';
  return fallback.trim().isEmpty ? 'FILE' : fallback.trim().toUpperCase();
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
    final tuvStatus = tuvDocument == null
        ? FleetVehicleDocumentStatus.missing
        : service.getDocumentStatus(
            expiryDate: tuvDocument.expiryDate,
            fileUrl: tuvDocument.fileUrl,
          );

    result[entry.key] = _VehicleListComplianceSummary(
      tuvStatus: tuvStatus,
      missingCount: missingCount,
    );
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

_DocumentStatusPresentation _documentStatusFor(
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
        color: _FleetStatusPageState._kMuted,
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
  final t = AppLocalizations.of(context);
  switch (status) {
    case VehicleStatus.grounded:
      return t.t('fleet_status_status_grounded');
    case VehicleStatus.inService:
      return t.t('fleet_status_status_in_service');
    case VehicleStatus.vorControllable:
      return 'VOR · steuerbar';
    case VehicleStatus.vorUncontrollable:
      return 'VOR · nicht steuerbar';
    case VehicleStatus.defleeted:
      return t.t('fleet_status_status_defleeted');
    case VehicleStatus.active:
      return t.t('fleet_status_status_active');
  }
}

Color _statusColor(VehicleStatus status) {
  switch (status) {
    case VehicleStatus.grounded:
      return _FleetStatusPageState._kRed;
    case VehicleStatus.inService:
      return _FleetStatusPageState._kBlue;
    case VehicleStatus.vorControllable:
      return const Color(0xFFB45309); // amber — DSP can fix
    case VehicleStatus.vorUncontrollable:
      return const Color(0xFF7C3AED); // purple — external blocker
    case VehicleStatus.defleeted:
      return _FleetStatusPageState._kMuted;
    case VehicleStatus.active:
      return _FleetStatusPageState._kGreen;
  }
}

String _categoryLabel(BuildContext context, VehicleCategory category) {
  final t = AppLocalizations.of(context);
  switch (category) {
    case VehicleCategory.amazonPaidRental:
      return t.t('fleet_status_category_amazon_paid_rental');
    case VehicleCategory.selfSourcedRental:
      return t.t('fleet_status_category_self_sourced_rental');
    case VehicleCategory.selfOwnedRental:
      return t.t('fleet_status_category_self_owned_rental');
    case VehicleCategory.armada:
      return t.t('fleet_status_category_armada');
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

String _eventTypeLabel(BuildContext context, String eventType) {
  final t = AppLocalizations.of(context);
  switch (eventType.trim().toUpperCase()) {
    case 'SERVICE':
      return t.t('fleet_status_vehicle_events_type_service');
    case 'ACCIDENT':
      return t.t('fleet_status_vehicle_events_type_accident');
    case 'TYRE_CHANGE':
      return t.t('fleet_status_vehicle_events_type_tyre_change');
    case 'INSPECTION':
      return t.t('fleet_status_vehicle_events_type_inspection');
    case 'BREAKDOWN':
      return t.t('fleet_status_vehicle_events_type_breakdown');
    case 'REPAIR':
      return t.t('fleet_status_vehicle_events_type_repair');
    case 'DOCUMENT_RENEWAL':
      return t.t('fleet_status_vehicle_events_type_document_renewal');
    case 'CUSTOM':
      return t.t('fleet_status_vehicle_events_type_custom');
    default:
      return eventType.trim().isEmpty ? '-' : eventType;
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

String _serviceEndDetailsLabel(BuildContext context, FleetVehicle vehicle) {
  return _optionalStoredDate(context, vehicle.serviceEndDate);
}

String _formatDateTime(BuildContext context, DateTime? value) {
  if (value == null) {
    return AppLocalizations.of(context).t('fleet_status_updated_fallback');
  }
  final material = MaterialLocalizations.of(context);
  return '${material.formatShortDate(value)} '
      '${material.formatTimeOfDay(TimeOfDay.fromDateTime(value))}';
}

// =================================================================
//   Fleet Hero — top-of-page summary of the whole fleet
// =================================================================

class _FleetHero extends StatelessWidget {
  final List<FleetVehicle> vehicles;
  final Map<String, _VehicleListComplianceSummary> compliance;
  final bool isMobile;

  const _FleetHero({
    required this.vehicles,
    required this.compliance,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    int countByStatus(VehicleStatus s) =>
        vehicles.where((v) => v.status == s).length;

    final total = vehicles.length;
    final active = countByStatus(VehicleStatus.active);
    final grounded = countByStatus(VehicleStatus.grounded);
    final inService = countByStatus(VehicleStatus.inService);
    final vorCtrl = countByStatus(VehicleStatus.vorControllable);
    final vorUnctrl = countByStatus(VehicleStatus.vorUncontrollable);
    final defleeted = countByStatus(VehicleStatus.defleeted);

    int tuvExpired = 0;
    int tuvDueSoon = 0;
    for (final v in vehicles) {
      final c = compliance[normalizePlateNumber(v.plateNumber)];
      if (c == null) continue;
      switch (c.tuvStatus) {
        case FleetVehicleDocumentStatus.expired:
          tuvExpired++;
          break;
        case FleetVehicleDocumentStatus.expiringSoon:
          tuvDueSoon++;
          break;
        default:
          break;
      }
    }

    if (isMobile) {
      return Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Color(0xFF14532D), Color(0xFF1D7F5A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: LayoutBuilder(builder: (ctx, c) {
          // Two-column compact grid. "All" first, then statuses.
          final entries = <(String, int)>[
            ('All', total),
            ('Aktiv', active),
            ('Grounded', grounded),
            ('In Service', inService),
            ('VOR · steuerbar', vorCtrl),
            ('VOR · nicht steuerbar', vorUnctrl),
            ('Archiviert', defleeted),
            if (tuvExpired > 0) ('TÜV abgelaufen', tuvExpired),
            if (tuvDueSoon > 0) ('TÜV bald fällig', tuvDueSoon),
          ];
          const gap = 8.0;
          final tileWidth = (c.maxWidth - gap) / 2;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final e in entries)
                SizedBox(
                  width: tileWidth,
                  child: _mobileTile(label: e.$1, value: e.$2),
                ),
            ],
          );
        }),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF14532D), Color(0xFF1D7F5A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_shipping_outlined,
                  color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Text(
                t.t('fleet_status_title'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              _heroBigNumber(label: 'GESAMT', value: total),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(builder: (ctx, c) {
            final narrow = c.maxWidth < 720;
            final tiles = <Widget>[
              _heroTile('Aktiv', active,
                  color: const Color(0xFF6EE7B7), icon: Icons.check_circle),
              _heroTile('Grounded', grounded,
                  color: const Color(0xFFFCA5A5), icon: Icons.report_problem),
              _heroTile('In Service', inService,
                  color: const Color(0xFF93C5FD), icon: Icons.build_circle),
              _heroTile('VOR · steuerbar', vorCtrl,
                  color: const Color(0xFFFCD34D),
                  icon: Icons.error_outline_outlined),
              _heroTile('VOR · nicht steuerbar', vorUnctrl,
                  color: const Color(0xFFC4B5FD),
                  icon: Icons.block_outlined),
              _heroTile('Archiviert', defleeted,
                  color: const Color(0xFFCBD5E1),
                  icon: Icons.archive_outlined),
              if (tuvExpired > 0)
                _heroTile('TÜV abgelaufen', tuvExpired,
                    color: const Color(0xFFFECACA), icon: Icons.warning_amber),
              if (tuvDueSoon > 0)
                _heroTile('TÜV bald fällig', tuvDueSoon,
                    color: const Color(0xFFFED7AA),
                    icon: Icons.event_busy_outlined),
            ];
            if (narrow) {
              return Wrap(spacing: 8, runSpacing: 8, children: tiles);
            }
            return Row(
              children: tiles
                  .expand((w) => [Expanded(child: w), const SizedBox(width: 10)])
                  .toList()
                ..removeLast(),
            );
          }),
        ],
      ),
    );
  }

  /// Mobile-only compact tile: no icon, label on top + big number
  /// below. Slightly translucent white background to stay legible on
  /// the dark-green hero gradient.
  Widget _mobileTile({required String label, required int value}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$value',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroBigNumber({required String label, required int value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFD1FAE5),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          Text(
            '$value',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroTile(String label, int value,
      {required Color color, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$value',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
