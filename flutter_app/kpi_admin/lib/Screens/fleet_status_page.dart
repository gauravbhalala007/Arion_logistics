import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as fb_storage;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../localization/app_localizations.dart';

class FleetStatusPage extends StatefulWidget {
  const FleetStatusPage({super.key});

  @override
  State<FleetStatusPage> createState() => _FleetStatusPageState();
}

class _FleetStatusPageState extends State<FleetStatusPage> {
  static const Color _kGreen = Color(0xFF1D7F5A);
  static const Color _kBlue = Color(0xFF1D4ED8);
  static const Color _kRed = Color(0xFFB91C1C);
  static const Color _kText = Color(0xFF111827);
  static const Color _kMuted = Color(0xFF6B7280);
  static const Color _kBorder = Color(0xFFE5E7EB);
  static const Color _kCardBg = Color(0xFFFFFFFF);
  static const Color _kPageBg = Color(0xFFF3F6F7);

  final TextEditingController _searchCtrl = TextEditingController();

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  String? _resolvedDspUid;
  String _role = '';
  bool _isApproved = false;
  bool _loadingScope = true;
  String _search = '';
  String _statusFilter = _fleetStatusAllValue;
  String _tuvFilter = _fleetTuvAllValue;
  final Map<String, _VehicleCompliance> _vehicleComplianceById = {};
  final Set<String> _loadingVehicleCompliance = <String>{};

  static const String _fleetStatusAllValue = '__all__';
  static const String _fleetTuvAllValue = '__all_tuv__';

  CollectionReference<Map<String, dynamic>> _vehiclesColForScope(String scope) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(scope)
        .collection('vehicles');
  }

  CollectionReference<Map<String, dynamic>> _vehicleDocumentsCol({
    required String scope,
    required String vehicleNumber,
  }) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(scope)
        .collection('vehicles')
        .doc(vehicleNumber)
        .collection('documents');
  }

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
    final scoped = (_resolvedDspUid ?? '').trim();
    return scoped.isEmpty ? uid : scoped;
  }

  bool get _canViewVehicles =>
      _isApproved &&
      (_role == 'admin' || _role == 'user' || _role == 'developer');

  bool get _canManageVehicles =>
      _isApproved &&
      (_role == 'admin' || _role == 'user' || _role == 'developer');

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
        _isApproved = false;
        _loadingScope = false;
      });
    }
  }

  Query<Map<String, dynamic>>? _buildVehiclesQuery() {
    if (!_canViewVehicles) return null;
    final scope = _scopeUid;
    if (scope == null) return null;

    Query<Map<String, dynamic>> query = _vehiclesColForScope(scope);
    if (_statusFilter != _fleetStatusAllValue) {
      query = query.where('status', isEqualTo: _statusFilter);
    }
    return query;
  }

  String _formatDate(BuildContext context, DateTime? date) {
    if (date == null) {
      return AppLocalizations.of(context).t('fleet_status_date_not_set');
    }
    return MaterialLocalizations.of(context).formatShortDate(date);
  }

  String _formatDateTime(BuildContext context, DateTime? date) {
    if (date == null) {
      return AppLocalizations.of(context).t('fleet_status_updated_fallback');
    }
    final localizations = MaterialLocalizations.of(context);
    final formattedDate = localizations.formatShortDate(date);
    final formattedTime = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(date),
    );
    return '$formattedDate $formattedTime';
  }

  void _ensureVehicleCompliance(List<_VehicleRecord> vehicles) {
    for (final vehicle in vehicles) {
      if (_vehicleComplianceById.containsKey(vehicle.id) ||
          _loadingVehicleCompliance.contains(vehicle.id)) {
        continue;
      }
      final scope = vehicle.scopeId.isNotEmpty
          ? vehicle.scopeId
          : (_scopeUid ?? '');
      if (scope.isEmpty) continue;
      _loadingVehicleCompliance.add(vehicle.id);
      _vehicleDocumentsCol(scope: scope, vehicleNumber: vehicle.vehicleNumber)
          .orderBy('uploadedAt', descending: true)
          .get()
          .then((snapshot) {
            final compliance = _VehicleCompliance.fromRecords(
              snapshot.docs.map(_VehicleDocumentRecord.fromDoc).toList(),
            );
            if (!mounted) return;
            setState(() {
              _vehicleComplianceById[vehicle.id] = compliance;
              _loadingVehicleCompliance.remove(vehicle.id);
            });
          })
          .catchError((_) {
            if (!mounted) return;
            setState(() {
              _vehicleComplianceById[vehicle.id] = _VehicleCompliance.empty();
              _loadingVehicleCompliance.remove(vehicle.id);
            });
          });
    }
  }

  String _serviceDateValue(
    BuildContext context, {
    required String status,
    required DateTime? date,
  }) {
    if (status != 'in_service') {
      return AppLocalizations.of(context).t('fleet_status_not_applicable');
    }
    if (date == null) {
      return AppLocalizations.of(
        context,
      ).t('fleet_status_vehicle_details_not_set');
    }
    return _formatDate(context, date);
  }

  List<_VehicleRecord> _filteredVehicles(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final query = _search.trim().toLowerCase();
    final vehicles = docs.map(_VehicleRecord.fromDoc).where((vehicle) {
      if (query.isEmpty) return true;
      return vehicle.vehicleNumber.toLowerCase().contains(query) ||
          vehicle.model.toLowerCase().contains(query);
    }).toList();

    vehicles.sort((a, b) {
      final aDate = a.updatedAt ?? a.createdAt;
      final bDate = b.updatedAt ?? b.createdAt;
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });

    return vehicles;
  }

  List<_VehicleRecord> _applyTuvFilter(List<_VehicleRecord> vehicles) {
    if (_tuvFilter == _fleetTuvAllValue) return vehicles;
    return vehicles.where((vehicle) {
      final compliance = _vehicleComplianceById[vehicle.id];
      if (compliance == null) return false;
      return compliance.tuvStatus == _tuvFilter;
    }).toList();
  }

  String _statusLabel(BuildContext context, String status) {
    final t = AppLocalizations.of(context);
    switch (status) {
      case 'defleeted':
        return t.t('fleet_status_status_defleeted');
      case 'grounded':
        return t.t('fleet_status_status_grounded');
      case 'in_service':
        return t.t('fleet_status_status_in_service');
      case 'active':
      default:
        return t.t('fleet_status_status_active');
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'defleeted':
        return _kMuted;
      case 'grounded':
        return _kRed;
      case 'in_service':
        return _kBlue;
      case 'active':
      default:
        return _kGreen;
    }
  }

  Future<void> _showVehicleEditor({_VehicleRecord? vehicle}) async {
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

    final draft = await showDialog<_VehicleDraft>(
      context: context,
      builder: (_) => _VehicleEditorDialog(vehicle: vehicle),
    );
    if (draft == null) return;

    try {
      if (vehicle == null) {
        await _createVehicle(draft, scope);
        if (!mounted) return;
        _handleSuccessfulSave(
          vehicleNumber: draft.vehicleNumber,
          successMessageKey: 'fleet_status_save_created',
        );
      } else {
        await _updateVehicle(vehicle, draft, scope);
        if (!mounted) return;
        _handleSuccessfulSave(
          vehicleNumber: draft.vehicleNumber,
          successMessageKey: 'fleet_status_save_updated',
        );
      }
    } on _VehicleExistsException {
      _showSnack(t.t('fleet_status_vehicle_exists'), error: true);
    } on FirebaseException catch (e) {
      final recovered = await _recoverIfVehicleWasWritten(
        vehicleNumber: draft.vehicleNumber,
        scope: scope,
      );
      if (!mounted) return;

      if (recovered) {
        _handleSuccessfulSave(
          vehicleNumber: draft.vehicleNumber,
          successMessageKey: vehicle == null
              ? 'fleet_status_save_created'
              : 'fleet_status_save_updated',
        );
      } else {
        _showSnack(
          e.code == 'permission-denied'
              ? t.t('fleet_status_permission_denied')
              : t.tf('fleet_status_save_failed', {'error': '$e'}),
          error: true,
        );
      }
    } catch (e) {
      _showSnack(
        t.tf('fleet_status_save_failed', {'error': '$e'}),
        error: true,
      );
    }
  }

  Future<void> _createVehicle(_VehicleDraft draft, String scope) async {
    final normalizedVehicleNumber = _normalizeVehicleNumber(
      draft.vehicleNumber,
    );
    final docRef = _vehiclesColForScope(scope).doc(normalizedVehicleNumber);
    try {
      final existing = await docRef.get();
      if (existing.exists) {
        throw _VehicleExistsException();
      }
    } on FirebaseException catch (e) {
      if (e.code != 'permission-denied') rethrow;
    }

    await docRef.set({
      'vehicleNumber': normalizedVehicleNumber,
      'model': draft.model.trim(),
      'dspUid': scope,
      'status': draft.status,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'serviceStartDate': _timestampOrNull(draft.serviceStartDate),
      'serviceEndDate': _timestampOrNull(draft.serviceEndDate),
    });
  }

  Future<void> _updateVehicle(
    _VehicleRecord vehicle,
    _VehicleDraft draft,
    String scope,
  ) async {
    await _vehiclesColForScope(scope).doc(vehicle.id).update({
      'dspUid': scope,
      'model': draft.model.trim(),
      'status': draft.status,
      'updatedAt': FieldValue.serverTimestamp(),
      'serviceStartDate': _timestampOrNull(draft.serviceStartDate),
      'serviceEndDate': _timestampOrNull(draft.serviceEndDate),
    });
  }

  Future<bool> _recoverIfVehicleWasWritten({
    required String vehicleNumber,
    required String scope,
  }) async {
    try {
      final snap = await _vehiclesColForScope(
        scope,
      ).doc(_normalizeVehicleNumber(vehicleNumber)).get();
      final data = snap.data();
      if (!snap.exists || data == null) return false;
      return _vehicleScopeFromMap(data) == scope;
    } catch (_) {
      return false;
    }
  }

  String _vehicleScopeFromMap(Map<String, dynamic> data) {
    return (data['dspUid'] ?? '').toString().trim();
  }

  Future<void> _showVehicleDetails(_VehicleRecord vehicle) async {
    final scope = _scopeUid;
    if (scope == null) {
      _showSnack(
        AppLocalizations.of(
          context,
        ).t('fleet_status_vehicle_details_scope_unavailable'),
        error: true,
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final media = MediaQuery.of(dialogContext).size;
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 980,
              maxHeight: media.height - 32,
            ),
            child: _VehicleDetailsPage(
              vehicle: vehicle,
              scopeUid: scope,
              canManageDocuments: _canManageVehicles,
            ),
          ),
        );
      },
    );
    if (!mounted) return;
    setState(() {
      _vehicleComplianceById.remove(vehicle.id);
      _loadingVehicleCompliance.remove(vehicle.id);
    });
  }

  void _handleSuccessfulSave({
    required String vehicleNumber,
    required String successMessageKey,
  }) {
    if (!mounted) return;
    setState(() {
      _search = '';
      _searchCtrl.clear();
    });
    _showSnack(
      AppLocalizations.of(
        context,
      ).tf(successMessageKey, {'vehicleNumber': vehicleNumber}),
    );
  }

  Future<void> _deleteVehicle(_VehicleRecord vehicle) async {
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
            'vehicleNumber': vehicle.vehicleNumber,
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t.t('button_close')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _kRed),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(t.t('fleet_status_action_delete')),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final vehicleRef = _vehiclesColForScope(scope).doc(vehicle.id);
      final documentsSnap = await vehicleRef.collection('documents').get();
      final batch = FirebaseFirestore.instance.batch();

      for (final docSnap in documentsSnap.docs) {
        final record = _VehicleDocumentRecord.fromDoc(docSnap);
        if (record.storagePath.isNotEmpty) {
          try {
            await fb_storage.FirebaseStorage.instance
                .ref()
                .child(record.storagePath)
                .delete();
          } catch (_) {}
        }
        batch.delete(docSnap.reference);
      }

      await batch.commit();
      await vehicleRef.delete();

      if (!mounted) return;
      _showSnack(
        t.tf('fleet_status_delete_success', {
          'vehicleNumber': vehicle.vehicleNumber,
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
      return const Center(child: CircularProgressIndicator());
    }
    if (!_canViewVehicles) {
      return Center(child: Text(t.t('fleet_status_no_access')));
    }

    final query = _buildVehiclesQuery();
    if (query == null) {
      return Center(child: Text(t.t('fleet_status_empty_scope')));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 1024;
        return Container(
          color: _kPageBg,
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: query.snapshots(),
            builder: (context, snap) {
              final vehicles = _filteredVehicles(
                snap.data?.docs ??
                    const <QueryDocumentSnapshot<Map<String, dynamic>>>[],
              );
              _ensureVehicleCompliance(vehicles);
              final visibleVehicles = _applyTuvFilter(vehicles);
              final waitingForCompliance =
                  _tuvFilter != _fleetTuvAllValue &&
                  vehicles.isNotEmpty &&
                  vehicles.any(
                    (vehicle) =>
                        !_vehicleComplianceById.containsKey(vehicle.id),
                  );
              final errorMessage = snap.hasError
                  ? _friendlyLoadError(t, snap.error)
                  : null;

              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, isNarrow: isNarrow),
                    const SizedBox(height: 16),
                    _buildToolbar(context, isNarrow: isNarrow),
                    const SizedBox(height: 16),
                    Expanded(
                      child:
                          snap.connectionState == ConnectionState.waiting &&
                              !snap.hasData
                          ? const Center(child: CircularProgressIndicator())
                          : waitingForCompliance
                          ? const Center(child: CircularProgressIndicator())
                          : errorMessage != null
                          ? _buildErrorState(context, errorMessage)
                          : visibleVehicles.isEmpty
                          ? _buildEmptyState(context)
                          : _buildVehicleTable(
                              context,
                              visibleVehicles,
                              availableWidth: constraints.maxWidth,
                            ),
                    ),
                  ],
                ),
              );
            },
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
          width: isNarrow ? double.infinity : 560,
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
        if (_canManageVehicles)
          FilledButton.icon(
            onPressed: () => _showVehicleEditor(),
            icon: const Icon(Icons.add_rounded),
            style: FilledButton.styleFrom(
              backgroundColor: _kGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            ),
            label: Text(t.t('fleet_status_add_vehicle')),
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

  Widget _buildToolbar(BuildContext context, {required bool isNarrow}) {
    final t = AppLocalizations.of(context);

    final statusFilter = DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            borderRadius: BorderRadius.circular(12),

            value: _statusFilter,
            onChanged: (value) {
              if (value == null) return;
              setState(() => _statusFilter = value);
            },
            items: [
              DropdownMenuItem(
                value: _fleetStatusAllValue,
                child: Text(t.t('fleet_status_filter_all')),
              ),
              ..._vehicleStatuses.map(
                (status) => DropdownMenuItem<String>(
                  value: status,
                  child: Text(_statusLabel(context, status)),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final tuvFilter = DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonHideUnderline(

          child: DropdownButton<String>(
            borderRadius: BorderRadius.circular(12),

            value: _tuvFilter,
            onChanged: (value) {
              if (value == null) return;
              setState(() => _tuvFilter = value);
            },
            items: [
              DropdownMenuItem(
                value: _fleetTuvAllValue,
                child: Text(t.t('fleet_status_tuv_filter_all')),
              ),
              DropdownMenuItem(
                value: _vehicleTuvStatusValid,
                child: Text(t.t('fleet_status_tuv_valid')),
              ),
              DropdownMenuItem(
                value: _vehicleTuvStatusExpired,
                child: Text(t.t('fleet_status_tuv_expired')),
              ),
              DropdownMenuItem(
                value: _vehicleTuvStatusPending,
                child: Text(t.t('fleet_status_tuv_pending')),
              ),
              DropdownMenuItem(
                value: _vehicleTuvStatusMissing,
                child: Text(t.t('fleet_status_tuv_missing')),
              ),
            ],
          ),
        ),
      ),
    );

    final search = TextField(
      controller: _searchCtrl,
      onChanged: (value) => setState(() => _search = value),
      decoration: InputDecoration(
        hintText: t.t('fleet_status_search_hint'),
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _kBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _kGreen),
        ),
      ),
    );

    if (isNarrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          search,
          const SizedBox(height: 12),
          statusFilter,
          const SizedBox(height: 12),
          tuvFilter,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: search),
        const SizedBox(width: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 220, maxWidth: 260),
          child: statusFilter,
        ),
        const SizedBox(width: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 220, maxWidth: 260),
          child: tuvFilter,
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _kBorder),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            t.t('fleet_status_empty'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _kMuted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _kBorder),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 40,
                color: Color(0xFFB45309),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _kText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _friendlyLoadError(AppLocalizations t, Object? error) {
    if (error is FirebaseException && error.code == 'permission-denied') {
      return t.t('fleet_status_permission_denied');
    }
    final text = '$error';
    if (text.contains('permission-denied')) {
      return t.t('fleet_status_permission_denied');
    }
    return t.tf('fleet_status_load_failed', {'error': '$error'});
  }

  Widget _buildVehicleTable(
    BuildContext context,
    List<_VehicleRecord> vehicles, {
    required double availableWidth,
  }) {
    final t = AppLocalizations.of(context);
    final minTableWidth = math.max(availableWidth - 16, 1180.0);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _kBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(8),
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: minTableWidth),
            child: SingleChildScrollView(
              child: DataTable(
                columnSpacing: 24,
                headingRowHeight: 56,
                dataRowMinHeight: 68,
                dataRowMaxHeight: 84,
                columns: [
                  DataColumn(
                    label: Text(t.t('fleet_status_column_vehicle_number')),
                  ),
                  DataColumn(label: Text(t.t('fleet_status_column_model'))),
                  DataColumn(label: Text(t.t('fleet_status_column_status'))),
                  DataColumn(
                    label: Text(t.t('fleet_status_column_tuv_status')),
                  ),
                  DataColumn(
                    label: Text(t.t('fleet_status_column_service_start')),
                  ),
                  DataColumn(
                    label: Text(t.t('fleet_status_column_service_end')),
                  ),
                  DataColumn(
                    label: Text(t.t('fleet_status_column_updated_at')),
                  ),
                  DataColumn(label: Text(t.t('fleet_status_column_actions'))),
                ],
                rows: vehicles.map((vehicle) {
                  final compliance = _vehicleComplianceById[vehicle.id];
                  return DataRow(
                    cells: [
                      DataCell(
                        InkWell(
                          onTap: () => _showVehicleDetails(vehicle),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  vehicle.vehicleNumber,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                if (compliance != null &&
                                    compliance.missingCount > 0) ...[
                                  const SizedBox(width: 8),
                                  _MissingDocumentsBadge(
                                    count: compliance.missingCount,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                      DataCell(Text(vehicle.model)),
                      DataCell(
                        _StatusBadge(
                          label: _statusLabel(context, vehicle.status),
                          color: _statusColor(vehicle.status),
                        ),
                      ),
                      DataCell(
                        compliance == null
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : _StatusBadge(
                                label: _vehicleTuvStatusLabel(
                                  context,
                                  compliance.tuvStatus,
                                ),
                                color: _vehicleTuvStatusColor(
                                  compliance.tuvStatus,
                                ),
                              ),
                      ),
                      DataCell(
                        Text(
                          _serviceDateValue(
                            context,
                            status: vehicle.status,
                            date: vehicle.serviceStartDate,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          _serviceDateValue(
                            context,
                            status: vehicle.status,
                            date: vehicle.serviceEndDate,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(_formatDateTime(context, vehicle.updatedAt)),
                      ),
                      DataCell(
                        _canManageVehicles
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: t.t(
                                      'fleet_status_action_view_details',
                                    ),
                                    onPressed: () =>
                                        _showVehicleDetails(vehicle),
                                    icon: const Icon(Icons.visibility_outlined),
                                  ),
                                  IconButton(
                                    tooltip: t.t('button_edit'),
                                    onPressed: () =>
                                        _showVehicleEditor(vehicle: vehicle),
                                    icon: const Icon(Icons.edit_outlined),
                                  ),
                                  IconButton(
                                    tooltip: t.t('fleet_status_action_delete'),
                                    onPressed: () => _deleteVehicle(vehicle),
                                    icon: const Icon(Icons.delete_outline),
                                  ),
                                ],
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
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleCards(
    BuildContext context,
    List<_VehicleRecord> vehicles,
  ) {
    final t = AppLocalizations.of(context);
    return ListView.separated(
      itemCount: vehicles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final vehicle = vehicles[index];
        final compliance = _vehicleComplianceById[vehicle.id];
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
                    child: InkWell(
                      onTap: () => _showVehicleDetails(vehicle),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                vehicle.vehicleNumber,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: _kText,
                                ),
                              ),
                            ),
                            if (compliance != null &&
                                compliance.missingCount > 0) ...[
                              const SizedBox(width: 8),
                              _MissingDocumentsBadge(
                                count: compliance.missingCount,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: t.t('fleet_status_action_view_details'),
                    onPressed: () => _showVehicleDetails(vehicle),
                    icon: const Icon(Icons.visibility_outlined),
                  ),
                  if (_canManageVehicles)
                    IconButton(
                      tooltip: t.t('button_edit'),
                      onPressed: () => _showVehicleEditor(vehicle: vehicle),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                vehicle.model,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _kMuted,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _StatusBadge(
                    label: _statusLabel(context, vehicle.status),
                    color: _statusColor(vehicle.status),
                  ),
                  if (compliance != null)
                    _StatusBadge(
                      label: _vehicleTuvStatusLabel(
                        context,
                        compliance.tuvStatus,
                      ),
                      color: _vehicleTuvStatusColor(compliance.tuvStatus),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              _InfoRow(
                label: t.t('fleet_status_column_service_start'),
                value: _serviceDateValue(
                  context,
                  status: vehicle.status,
                  date: vehicle.serviceStartDate,
                ),
              ),
              const SizedBox(height: 8),
              _InfoRow(
                label: t.t('fleet_status_column_service_end'),
                value: _serviceDateValue(
                  context,
                  status: vehicle.status,
                  date: vehicle.serviceEndDate,
                ),
              ),
              const SizedBox(height: 8),
              _InfoRow(
                label: t.t('fleet_status_column_updated_at'),
                value: _formatDateTime(context, vehicle.updatedAt),
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: _canManageVehicles
                    ? TextButton.icon(
                        onPressed: () => _deleteVehicle(vehicle),
                        icon: const Icon(Icons.delete_outline),
                        label: Text(t.t('fleet_status_action_delete')),
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
}

class _VehicleEditorDialog extends StatefulWidget {
  const _VehicleEditorDialog({required this.vehicle});

  final _VehicleRecord? vehicle;

  @override
  State<_VehicleEditorDialog> createState() => _VehicleEditorDialogState();
}

class _VehicleEditorDialogState extends State<_VehicleEditorDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _vehicleNumberCtrl;
  late final TextEditingController _modelCtrl;

  late String _status;
  DateTime? _serviceStartDate;
  DateTime? _serviceEndDate;
  bool _submitted = false;

  bool get _isEditing => widget.vehicle != null;

  @override
  void initState() {
    super.initState();
    _vehicleNumberCtrl = TextEditingController(
      text: widget.vehicle?.vehicleNumber ?? '',
    );
    _modelCtrl = TextEditingController(text: widget.vehicle?.model ?? '');
    _status = widget.vehicle?.status ?? 'active';
    _serviceStartDate = widget.vehicle?.serviceStartDate;
    _serviceEndDate = widget.vehicle?.serviceEndDate;
  }

  @override
  void dispose() {
    _vehicleNumberCtrl.dispose();
    _modelCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickServiceStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _serviceStartDate ?? now,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 20),
    );
    if (picked == null) return;
    setState(() => _serviceStartDate = picked);
  }

  Future<void> _pickServiceEndDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _serviceEndDate ?? _serviceStartDate ?? now,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 20),
    );
    if (picked == null) return;
    setState(() => _serviceEndDate = picked);
  }

  void _submit() {
    setState(() => _submitted = true);
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;
    if (_status == 'in_service' && _serviceStartDate == null) return;

    Navigator.of(context).pop(
      _VehicleDraft(
        vehicleNumber: _normalizeVehicleNumber(_vehicleNumberCtrl.text),
        model: _modelCtrl.text.trim(),
        status: _status,
        serviceStartDate: _status == 'in_service' ? _serviceStartDate : null,
        serviceEndDate: _status == 'in_service' ? _serviceEndDate : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final showServiceFields = _status == 'in_service';
    final serviceStartMissing =
        _submitted && showServiceFields && _serviceStartDate == null;

    return Dialog(
      elevation: 8,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 760),
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
                TextFormField(
                  controller: _vehicleNumberCtrl,
                  enabled: !_isEditing,
                  decoration: _inputDecoration(
                    label: t.t('fleet_status_field_vehicle_number'),
                  ),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return t.tf('error_required', {
                        'field': t.t('fleet_status_field_vehicle_number'),
                      });
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _modelCtrl,
                  decoration: _inputDecoration(
                    label: t.t('fleet_status_field_model'),
                  ),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return t.tf('error_required', {
                        'field': t.t('fleet_status_field_model'),
                      });
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: _inputDecoration(
                    label: t.t('fleet_status_field_status'),
                  ),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _status = value;
                      if (_status != 'in_service') {
                        _serviceStartDate = null;
                        _serviceEndDate = null;
                      }
                    });
                  },
                  items: _vehicleStatuses
                      .map(
                        (status) => DropdownMenuItem<String>(
                          value: status,
                          child: Text(
                            _fleetStatusLabelFromContext(context, status),
                          ),
                        ),
                      )
                      .toList(),
                ),
                if (showServiceFields) ...[
                  const SizedBox(height: 18),
                  Text(
                    t.t('fleet_status_field_service_start_date'),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _FleetStatusPageState._kMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _pickServiceStartDate,
                        icon: const Icon(Icons.calendar_today_outlined),
                        label: Text(
                          _serviceStartDate == null
                              ? t.t('fleet_status_pick_date')
                              : t.t('fleet_status_change_date'),
                        ),
                      ),
                      Text(
                        _serviceStartDate == null
                            ? t.t('fleet_status_date_not_set')
                            : MaterialLocalizations.of(
                                context,
                              ).formatShortDate(_serviceStartDate!),
                      ),
                      if (_serviceStartDate != null)
                        TextButton(
                          onPressed: () =>
                              setState(() => _serviceStartDate = null),
                          child: Text(t.t('fleet_status_clear_date')),
                        ),
                    ],
                  ),
                  if (serviceStartMissing)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        t.t('fleet_status_service_start_required'),
                        style: const TextStyle(
                          color: _FleetStatusPageState._kRed,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(height: 14),
                  Text(
                    t.t('fleet_status_field_service_end_date'),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _FleetStatusPageState._kMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _pickServiceEndDate,
                        icon: const Icon(Icons.calendar_today_outlined),
                        label: Text(
                          _serviceEndDate == null
                              ? t.t('fleet_status_pick_date')
                              : t.t('fleet_status_change_date'),
                        ),
                      ),
                      Text(
                        _serviceEndDate == null
                            ? t.t('fleet_status_date_not_set')
                            : MaterialLocalizations.of(
                                context,
                              ).formatShortDate(_serviceEndDate!),
                      ),
                      if (_serviceEndDate != null)
                        TextButton(
                          onPressed: () =>
                              setState(() => _serviceEndDate = null),
                          child: Text(t.t('fleet_status_clear_date')),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(t.t('button_close')),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: _submit,
                      child: Text(
                        t.t(_isEditing ? 'button_save' : 'button_add'),
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
}

class _VehicleDetailsPage extends StatefulWidget {
  const _VehicleDetailsPage({
    required this.vehicle,
    required this.scopeUid,
    required this.canManageDocuments,
  });

  final _VehicleRecord vehicle;
  final String scopeUid;
  final bool canManageDocuments;

  @override
  State<_VehicleDetailsPage> createState() => _VehicleDetailsPageState();
}

class _VehicleDetailsPageState extends State<_VehicleDetailsPage> {
  static const Color _kPageBg = Color(0xFFF3F6F7);

  bool _resolvingDocumentsScope = true;
  String? _documentsScopeUid;
  Object? _documentsScopeError;

  @override
  void initState() {
    super.initState();
    _resolveDocumentsScope();
  }

  DocumentReference<Map<String, dynamic>> get _vehicleRef {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.scopeUid)
        .collection('vehicles')
        .doc(widget.vehicle.vehicleNumber);
  }

  List<String> get _documentsScopeCandidates {
    final authUid = FirebaseAuth.instance.currentUser?.uid?.trim() ?? '';
    return {
      widget.scopeUid.trim(),
      widget.vehicle.scopeId.trim(),
      authUid,
    }.where((value) => value.isNotEmpty).toList();
  }

  CollectionReference<Map<String, dynamic>> _documentsColForScope(
    String scope,
  ) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(scope)
        .collection('vehicles')
        .doc(widget.vehicle.vehicleNumber)
        .collection('documents');
  }

  CollectionReference<Map<String, dynamic>> get _documentsCol {
    final scope = _documentsScopeUid ?? widget.scopeUid;
    return _documentsColForScope(scope);
  }

  Future<void> _resolveDocumentsScope() async {
    FirebaseException? lastPermissionError;

    for (final scope in _documentsScopeCandidates) {
      try {
        await _documentsColForScope(scope).limit(1).get();
        if (!mounted) return;
        setState(() {
          _documentsScopeUid = scope;
          _documentsScopeError = null;
          _resolvingDocumentsScope = false;
        });
        return;
      } on FirebaseException catch (e) {
        if (e.code == 'permission-denied') {
          lastPermissionError = e;
          continue;
        }
        if (!mounted) return;
        setState(() {
          _documentsScopeUid = scope;
          _documentsScopeError = e;
          _resolvingDocumentsScope = false;
        });
        return;
      }
    }

    if (!mounted) return;
    setState(() {
      _documentsScopeUid = widget.scopeUid;
      _documentsScopeError = lastPermissionError;
      _resolvingDocumentsScope = false;
    });
  }

  Future<PlatformFile?> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;
    final file = result.files.first;
    if (file.bytes == null) {
      _showSnack(
        AppLocalizations.of(
          context,
        ).t('fleet_status_vehicle_details_file_bytes_error'),
        error: true,
      );
      return null;
    }
    return file;
  }

  Future<bool> _uploadDocument({
    required String type,
    required DateTime? expiryDate,
    required PlatformFile file,
  }) async {
    if (!widget.canManageDocuments) {
      _showSnack(
        AppLocalizations.of(
          context,
        ).t('fleet_status_vehicle_details_upload_not_allowed'),
        error: true,
      );
      return false;
    }
    if (_resolvingDocumentsScope) {
      _showSnack(
        AppLocalizations.of(
          context,
        ).t('fleet_status_vehicle_details_resolving_scope'),
        error: true,
      );
      return false;
    }
    final bytes = file.bytes;
    if (bytes == null) {
      _showSnack(
        AppLocalizations.of(
          context,
        ).t('fleet_status_vehicle_details_pick_file_first'),
        error: true,
      );
      return false;
    }

    try {
      final authUid = FirebaseAuth.instance.currentUser?.uid?.trim() ?? '';
      if (authUid.isEmpty) {
        _showSnack(
          AppLocalizations.of(context).t('fleet_status_must_login'),
          error: true,
        );
        return false;
      }
      final originalName = file.name.trim().isEmpty
          ? 'document'
          : file.name.trim();
      final safeName = '${DateTime.now().millisecondsSinceEpoch}_$originalName';
      final ref = fb_storage.FirebaseStorage.instance
          .ref()
          .child('vehicles')
          .child(authUid)
          .child(widget.vehicle.vehicleNumber)
          .child('documents')
          .child(safeName);

      await ref.putData(
        bytes,
        fb_storage.SettableMetadata(
          contentType: _vehicleDocumentContentType(originalName),
        ),
      );
      final fileUrl = await ref.getDownloadURL();

      await _documentsCol.add({
        'type': type,
        'fileUrl': fileUrl,
        'fileName': originalName,
        if (expiryDate != null) 'expiryDate': Timestamp.fromDate(expiryDate),
        'uploadedAt': FieldValue.serverTimestamp(),
        'storagePath': ref.fullPath,
      });

      if (!mounted) return false;
      _showSnack(
        AppLocalizations.of(
          context,
        ).t('fleet_status_vehicle_details_upload_success'),
      );
      return true;
    } catch (e) {
      _showSnack(
        AppLocalizations.of(
          context,
        ).tf('fleet_status_vehicle_details_upload_failed', {'error': '$e'}),
        error: true,
      );
      return false;
    }
  }

  Future<void> _showAddDocumentDialog() async {
    final t = AppLocalizations.of(context);
    var selectedType = _vehicleDocumentTypes.first;
    DateTime? expiryDate;
    PlatformFile? selectedFile;
    var uploading = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> pickExpiryDate() async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: dialogContext,
                initialDate: expiryDate ?? now,
                firstDate: DateTime(now.year - 10),
                lastDate: DateTime(now.year + 20),
              );
              if (picked == null) return;
              setDialogState(() => expiryDate = picked);
            }

            Future<void> pickFile() async {
              final file = await _pickFile();
              if (file == null) return;
              setDialogState(() => selectedFile = file);
            }

            Future<void> submit() async {
              final file = selectedFile;
              if (file == null) {
                _showSnack(
                  t.t('fleet_status_vehicle_details_pick_file_first'),
                  error: true,
                );
                return;
              }

              setDialogState(() => uploading = true);
              final uploaded = await _uploadDocument(
                type: selectedType,
                expiryDate: expiryDate,
                file: file,
              );
              if (!mounted || !dialogContext.mounted) return;
              setDialogState(() => uploading = false);
              if (uploaded) {
                Navigator.of(dialogContext).pop();
              }
            }

            return AlertDialog(
              title: Text(
                t.t('fleet_status_vehicle_details_add_document_title'),
              ),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: _inputDecoration(
                        label: t.t(
                          'fleet_status_vehicle_details_document_type',
                        ),
                      ),
                      items: _vehicleDocumentTypes
                          .map(
                            (type) => DropdownMenuItem<String>(
                              value: type,
                              child: Text(
                                _vehicleDocumentTypeLabel(context, type),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: uploading
                          ? null
                          : (value) {
                              if (value == null) return;
                              setDialogState(() => selectedType = value);
                            },
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: uploading ? null : pickFile,
                          icon: const Icon(Icons.upload_file_outlined),
                          label: Text(
                            selectedFile == null
                                ? t.t(
                                    'fleet_status_vehicle_details_choose_file',
                                  )
                                : t.t(
                                    'fleet_status_vehicle_details_change_file',
                                  ),
                          ),
                        ),
                        SizedBox(
                          width: 220,
                          child: Text(
                            selectedFile?.name ??
                                t.t(
                                  'fleet_status_vehicle_details_no_file_selected',
                                ),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _FleetStatusPageState._kMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: uploading ? null : pickExpiryDate,
                          icon: const Icon(Icons.calendar_today_outlined),
                          label: Text(
                            expiryDate == null
                                ? t.t(
                                    'fleet_status_vehicle_details_select_expiry_date',
                                  )
                                : t.t(
                                    'fleet_status_vehicle_details_change_expiry_date',
                                  ),
                          ),
                        ),
                        Text(
                          expiryDate == null
                              ? t.t(
                                  'fleet_status_vehicle_details_no_expiry_date',
                                )
                              : MaterialLocalizations.of(
                                  context,
                                ).formatShortDate(expiryDate!),
                        ),
                        if (expiryDate != null)
                          TextButton(
                            onPressed: uploading
                                ? null
                                : () => setDialogState(() => expiryDate = null),
                            child: Text(
                              t.t('fleet_status_vehicle_details_clear_expiry'),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: uploading
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: Text(t.t('button_close')),
                ),
                FilledButton.icon(
                  onPressed: uploading ? null : submit,
                  icon: uploading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.cloud_upload_outlined),
                  label: Text(
                    uploading
                        ? t.t('fleet_status_vehicle_details_uploading_action')
                        : t.t('fleet_status_vehicle_details_upload_action'),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _openDocument(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      _showSnack(
        AppLocalizations.of(
          context,
        ).t('fleet_status_vehicle_details_invalid_url'),
        error: true,
      );
      return;
    }
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      _showSnack(
        AppLocalizations.of(
          context,
        ).t('fleet_status_vehicle_details_open_failed'),
        error: true,
      );
    }
  }

  Future<void> _deleteDocument(_VehicleDocumentRecord document) async {
    if (!widget.canManageDocuments || _resolvingDocumentsScope) return;
    try {
      if (document.storagePath.isNotEmpty) {
        try {
          await fb_storage.FirebaseStorage.instance
              .ref()
              .child(document.storagePath)
              .delete();
        } catch (_) {}
      }
      await _documentsCol.doc(document.id).delete();
      if (!mounted) return;
      _showSnack(
        AppLocalizations.of(
          context,
        ).t('fleet_status_vehicle_details_delete_success'),
      );
    } catch (e) {
      _showSnack(
        AppLocalizations.of(
          context,
        ).tf('fleet_status_vehicle_details_delete_failed', {'error': '$e'}),
        error: true,
      );
    }
  }

  Future<void> _editDocumentExpiry(_VehicleDocumentRecord document) async {
    if (!widget.canManageDocuments || _resolvingDocumentsScope) return;
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: document.expiryDate ?? now,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 20),
    );
    if (picked == null) return;

    try {
      await _documentsCol.doc(document.id).update({
        'expiryDate': Timestamp.fromDate(picked),
      });
      if (!mounted) return;
      _showSnack(
        AppLocalizations.of(
          context,
        ).t('fleet_status_vehicle_details_edit_expiry_success'),
      );
    } catch (e) {
      _showSnack(
        AppLocalizations.of(context).tf(
          'fleet_status_vehicle_details_edit_expiry_failed',
          {'error': '$e'},
        ),
        error: true,
      );
    }
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

  String _formatDate(DateTime? date) {
    if (date == null) {
      return AppLocalizations.of(
        context,
      ).t('fleet_status_vehicle_details_not_set');
    }
    return MaterialLocalizations.of(context).formatShortDate(date);
  }

  String _formatDateTime(DateTime? date) {
    if (date == null) {
      return AppLocalizations.of(
        context,
      ).t('fleet_status_vehicle_details_not_set');
    }
    final localizations = MaterialLocalizations.of(context);
    final formattedDate = localizations.formatShortDate(date);
    final formattedTime = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(date),
    );
    return '$formattedDate $formattedTime';
  }

  String _serviceValue(_VehicleRecord vehicle, DateTime? date) {
    if (vehicle.status != 'in_service') {
      return AppLocalizations.of(context).t('fleet_status_not_applicable');
    }
    return _formatDate(date);
  }

  InputDecoration _inputDecoration({required String label}) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
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

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      color: _kPageBg,
      padding: const EdgeInsets.all(20),
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _vehicleRef.snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.data!.exists) {
            return Center(
              child: Text(
                t.t('fleet_status_vehicle_details_not_found'),
                style: const TextStyle(
                  color: _FleetStatusPageState._kMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }

          final vehicle = _VehicleRecord.fromSnapshot(snap.data!);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.t('fleet_status_vehicle_details_page_title'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: _FleetStatusPageState._kText,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          t.t('fleet_status_vehicle_details_page_subtitle'),
                          style: const TextStyle(
                            color: _FleetStatusPageState._kMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: t.t('button_close'),
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: _FleetStatusPageState._kText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _resolvingDocumentsScope
                    ? const Center(child: CircularProgressIndicator())
                    : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: _documentsCol
                            .orderBy('uploadedAt', descending: true)
                            .snapshots(),
                        builder: (context, documentSnapshot) {
                          if (documentSnapshot.connectionState ==
                                  ConnectionState.waiting &&
                              !documentSnapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final records =
                              documentSnapshot.data?.docs
                                  .map(_VehicleDocumentRecord.fromDoc)
                                  .toList() ??
                              const <_VehicleDocumentRecord>[];
                          final compliance = documentSnapshot.hasError
                              ? null
                              : _VehicleCompliance.fromRecords(records);

                          return SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTopCard(
                                  context,
                                  vehicle,
                                  compliance: compliance,
                                ),
                                const SizedBox(height: 16),
                                _buildDetailsCard(context, vehicle),
                                const SizedBox(height: 16),
                                _buildComplianceCard(
                                  context,
                                  compliance: compliance,
                                ),
                                const SizedBox(height: 16),
                                _buildDocumentsCard(
                                  context,
                                  records: records,
                                  error: documentSnapshot.hasError
                                      ? (_documentsScopeError ??
                                            documentSnapshot.error)
                                      : null,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopCard(
    BuildContext context,
    _VehicleRecord vehicle, {
    _VehicleCompliance? compliance,
  }) {
    final t = AppLocalizations.of(context);
    return _ProfileStyleCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 720;
          final left = Container(
            width: isNarrow ? double.infinity : 220,
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F2ED),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              size: 72,
              color: _FleetStatusPageState._kGreen,
            ),
          );

          final rightContent = Padding(
            padding: EdgeInsets.only(
              left: isNarrow ? 0 : 20,
              top: isNarrow ? 16 : 0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        vehicle.vehicleNumber,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: _FleetStatusPageState._kText,
                        ),
                      ),
                    ),
                    if (compliance != null && compliance.missingCount > 0)
                      _MissingDocumentsBadge(count: compliance.missingCount),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  vehicle.model,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _FleetStatusPageState._kMuted,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _StatusBadge(
                      label: _fleetStatusLabelFromContext(
                        context,
                        vehicle.status,
                      ),
                      color: _fleetStatusColor(vehicle.status),
                    ),
                    if (compliance != null)
                      _StatusBadge(
                        label: _vehicleTuvStatusLabel(
                          context,
                          compliance.tuvStatus,
                        ),
                        color: _vehicleTuvStatusColor(compliance.tuvStatus),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                _InfoRow(
                  label: t.t('fleet_status_vehicle_details_service_start'),
                  value: _serviceValue(vehicle, vehicle.serviceStartDate),
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  label: t.t('fleet_status_vehicle_details_service_end'),
                  value: _serviceValue(vehicle, vehicle.serviceEndDate),
                ),
              ],
            ),
          );

          return isNarrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [left, rightContent],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    left,
                    Expanded(child: rightContent),
                  ],
                );
        },
      ),
    );
  }

  Widget _buildComplianceCard(
    BuildContext context, {
    required _VehicleCompliance? compliance,
  }) {
    final t = AppLocalizations.of(context);
    if (compliance == null) {
      return _ProfileStyleCard(
        child: Text(
          t.t('fleet_status_vehicle_details_compliance_unavailable'),
          style: const TextStyle(
            color: _FleetStatusPageState._kMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return _ProfileStyleCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.t('fleet_status_vehicle_details_compliance_title'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _FleetStatusPageState._kText,
            ),
          ),
          const SizedBox(height: 14),
          ..._vehicleDocumentTypes.expand((type) {
            final document = compliance.latestByType[type];
            return [
              _buildComplianceRow(context, type: type, document: document),
              if (type != _vehicleDocumentTypes.last)
                const SizedBox(height: 10),
            ];
          }),
        ],
      ),
    );
  }

  Widget _buildComplianceRow(
    BuildContext context, {
    required String type,
    required _VehicleDocumentRecord? document,
  }) {
    final t = AppLocalizations.of(context);
    final status = _vehicleDocumentExpiryStatus(type, document);
    final isExpired = status == _vehicleDocumentExpiryExpired;
    final isMissing = status == _vehicleDocumentExpiryMissing;
    final accentColor = isExpired
        ? _FleetStatusPageState._kRed
        : isMissing
        ? const Color(0xFFD97706)
        : _FleetStatusPageState._kBorder;

    final valueText = document == null
        ? t.t('fleet_status_vehicle_details_missing')
        : document.expiryDate == null
        ? t.t('fleet_status_vehicle_details_not_set')
        : _formatDate(document.expiryDate);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isExpired ? const Color(0xFFFEF2F2) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _vehicleDocumentTypeLabel(context, type),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: _FleetStatusPageState._kText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  valueText,
                  style: TextStyle(
                    color: isExpired
                        ? _FleetStatusPageState._kRed
                        : _FleetStatusPageState._kText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _StatusBadge(
                label: _vehicleDocumentExpiryStatusLabel(context, status),
                color: isExpired
                    ? _FleetStatusPageState._kRed
                    : status == _vehicleDocumentExpiryMissing
                    ? const Color(0xFFD97706)
                    : status == _vehicleDocumentExpiryNotSet
                    ? const Color(0xFFB45309)
                    : _FleetStatusPageState._kGreen,
              ),
              if (widget.canManageDocuments && document != null) ...[
                const SizedBox(height: 8),
                IconButton(
                  tooltip: t.t('fleet_status_vehicle_details_edit_expiry'),
                  onPressed: () => _editDocumentExpiry(document),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context, _VehicleRecord vehicle) {
    final t = AppLocalizations.of(context);
    return _ProfileStyleCard(
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
            label: t.t('fleet_status_vehicle_details_vehicle_number'),
            value: vehicle.vehicleNumber,
          ),
          const SizedBox(height: 10),
          _InfoRow(
            label: t.t('fleet_status_vehicle_details_model'),
            value: vehicle.model,
          ),
          const SizedBox(height: 10),
          _InfoRow(
            label: t.t('fleet_status_vehicle_details_status'),
            value: _fleetStatusLabelFromContext(context, vehicle.status),
          ),
          const SizedBox(height: 10),
          _InfoRow(
            label: t.t('fleet_status_vehicle_details_service_start'),
            value: _serviceValue(vehicle, vehicle.serviceStartDate),
          ),
          const SizedBox(height: 10),
          _InfoRow(
            label: t.t('fleet_status_vehicle_details_service_end'),
            value: _serviceValue(vehicle, vehicle.serviceEndDate),
          ),
          const SizedBox(height: 10),
          _InfoRow(
            label: t.t('fleet_status_vehicle_details_created_at'),
            value: _formatDateTime(vehicle.createdAt),
          ),
          const SizedBox(height: 10),
          _InfoRow(
            label: t.t('fleet_status_vehicle_details_updated_at'),
            value: _formatDateTime(vehicle.updatedAt),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsCard(
    BuildContext context, {
    required List<_VehicleDocumentRecord> records,
    Object? error,
  }) {
    final t = AppLocalizations.of(context);
    return _ProfileStyleCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  t.t('fleet_status_vehicle_details_documents_title'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _FleetStatusPageState._kText,
                  ),
                ),
              ),
              if (widget.canManageDocuments)
                FilledButton.icon(
                  onPressed: _showAddDocumentDialog,
                  icon: const Icon(Icons.add),
                  label: Text(
                    t.t('fleet_status_vehicle_details_add_document_action'),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (error != null)
            Center(
              child: Text(
                t.tf('fleet_status_vehicle_details_load_failed', {
                  'scope': _documentsScopeUid == null
                      ? ''
                      : ' (scope: $_documentsScopeUid)',
                  'error': '$error',
                }),
                textAlign: TextAlign.center,
              ),
            )
          else if (records.isEmpty)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _FleetStatusPageState._kBorder),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  t.t('fleet_status_vehicle_details_empty_documents'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _FleetStatusPageState._kMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: records.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final record = records[index];
                return Container(
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
                          Expanded(
                            child: Text(
                              record.fileName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: _FleetStatusPageState._kText,
                              ),
                            ),
                          ),
                          _StatusBadge(
                            label: _vehicleDocumentTypeLabel(
                              context,
                              record.type,
                            ),
                            color: _FleetStatusPageState._kBlue,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _InfoRow(
                        label: t.t('fleet_status_vehicle_details_expiry_date'),
                        value: _formatDate(record.expiryDate),
                      ),
                      const SizedBox(height: 8),
                      _InfoRow(
                        label: t.t('fleet_status_vehicle_details_uploaded'),
                        value: _formatDateTime(record.uploadedAt),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: record.fileUrl.isEmpty
                                ? null
                                : () => _openDocument(record.fileUrl),
                            icon: const Icon(Icons.open_in_new),
                            label: Text(t.t('button_open')),
                          ),
                          if (widget.canManageDocuments)
                            TextButton.icon(
                              onPressed: () => _deleteDocument(record),
                              icon: const Icon(
                                Icons.delete_outline,
                                color: _FleetStatusPageState._kRed,
                              ),
                              label: Text(
                                t.t('button_delete'),
                                style: const TextStyle(
                                  color: _FleetStatusPageState._kRed,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _VehicleCompliance {
  const _VehicleCompliance({
    required this.latestByType,
    required this.missingCount,
    required this.tuvStatus,
  });

  final Map<String, _VehicleDocumentRecord?> latestByType;
  final int missingCount;
  final String tuvStatus;

  factory _VehicleCompliance.fromRecords(List<_VehicleDocumentRecord> records) {
    final sorted = [...records]
      ..sort((a, b) {
        final aTime = a.uploadedAt;
        final bTime = b.uploadedAt;
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return bTime.compareTo(aTime);
      });

    final latestByType = <String, _VehicleDocumentRecord?>{};
    for (final type in _vehicleDocumentTypes) {
      latestByType[type] = null;
    }
    for (final record in sorted) {
      if (!latestByType.containsKey(record.type)) continue;
      latestByType[record.type] ??= record;
    }

    final missingCount = _vehicleDocumentTypes
        .where((type) => latestByType[type] == null)
        .length;

    final tuvStatus = _deriveVehicleTuvStatus(latestByType['tuv']);

    return _VehicleCompliance(
      latestByType: latestByType,
      missingCount: missingCount,
      tuvStatus: tuvStatus,
    );
  }

  factory _VehicleCompliance.empty() {
    return _VehicleCompliance.fromRecords(const <_VehicleDocumentRecord>[]);
  }
}

class _ProfileStyleCard extends StatelessWidget {
  const _ProfileStyleCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: child,
    );
  }
}

class _MissingDocumentsBadge extends StatelessWidget {
  const _MissingDocumentsBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        AppLocalizations.of(
          context,
        ).tf('fleet_status_missing_documents_count', {'count': '$count'}),
        style: const TextStyle(
          color: _FleetStatusPageState._kRed,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
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

class _VehicleRecord {
  const _VehicleRecord({
    required this.id,
    required this.vehicleNumber,
    required this.model,
    required this.dspUid,
    required this.status,
    required this.serviceStartDate,
    required this.serviceEndDate,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String vehicleNumber;
  final String model;
  final String dspUid;
  final String status;
  final DateTime? serviceStartDate;
  final DateTime? serviceEndDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get scopeId => dspUid.trim();

  factory _VehicleRecord.fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return _VehicleRecord.fromMap(doc.id, doc.data());
  }

  factory _VehicleRecord.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return _VehicleRecord.fromMap(doc.id, doc.data() ?? const {});
  }

  factory _VehicleRecord.fromMap(String id, Map<String, dynamic> data) {
    return _VehicleRecord(
      id: id,
      vehicleNumber: (data['vehicleNumber'] ?? id).toString(),
      model: (data['model'] ?? '').toString(),
      dspUid: (data['dspUid'] ?? '').toString(),
      status: (data['status'] ?? 'active').toString(),
      serviceStartDate: (data['serviceStartDate'] as Timestamp?)?.toDate(),
      serviceEndDate: (data['serviceEndDate'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}

class _VehicleDraft {
  const _VehicleDraft({
    required this.vehicleNumber,
    required this.model,
    required this.status,
    required this.serviceStartDate,
    required this.serviceEndDate,
  });

  final String vehicleNumber;
  final String model;
  final String status;
  final DateTime? serviceStartDate;
  final DateTime? serviceEndDate;
}

class _VehicleDocumentRecord {
  const _VehicleDocumentRecord({
    required this.id,
    required this.type,
    required this.fileUrl,
    required this.fileName,
    required this.expiryDate,
    required this.uploadedAt,
    required this.storagePath,
  });

  final String id;
  final String type;
  final String fileUrl;
  final String fileName;
  final DateTime? expiryDate;
  final DateTime? uploadedAt;
  final String storagePath;

  factory _VehicleDocumentRecord.fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return _VehicleDocumentRecord(
      id: doc.id,
      type: (data['type'] ?? '').toString(),
      fileUrl: (data['fileUrl'] ?? '').toString(),
      fileName: (data['fileName'] ?? '').toString(),
      expiryDate: (data['expiryDate'] as Timestamp?)?.toDate(),
      uploadedAt: (data['uploadedAt'] as Timestamp?)?.toDate(),
      storagePath: (data['storagePath'] ?? '').toString(),
    );
  }
}

class _VehicleExistsException implements Exception {}

const List<String> _vehicleStatuses = <String>[
  'active',
  'grounded',
  'in_service',
  'defleeted',
];

const List<String> _vehicleDocumentTypes = <String>[
  'tuv',
  'insurance',
  'service',
  'rc',
];

const String _vehicleTuvStatusValid = 'valid';
const String _vehicleTuvStatusExpired = 'expired';
const String _vehicleTuvStatusPending = 'pending';
const String _vehicleTuvStatusMissing = 'missing';

const String _vehicleDocumentExpiryMissing = 'missing';
const String _vehicleDocumentExpiryExpired = 'expired';
const String _vehicleDocumentExpiryNotSet = 'not_set';
const String _vehicleDocumentExpiryValid = 'valid';

Timestamp? _timestampOrNull(DateTime? value) {
  return value == null ? null : Timestamp.fromDate(value);
}

String _normalizeVehicleNumber(String value) {
  return value.trim().toUpperCase();
}

Color _fleetStatusColor(String status) {
  switch (status) {
    case 'defleeted':
      return _FleetStatusPageState._kMuted;
    case 'grounded':
      return _FleetStatusPageState._kRed;
    case 'in_service':
      return _FleetStatusPageState._kBlue;
    case 'active':
    default:
      return _FleetStatusPageState._kGreen;
  }
}

String _vehicleDocumentTypeLabel(BuildContext context, String type) {
  final t = AppLocalizations.of(context);
  switch (type) {
    case 'tuv':
      return t.t('fleet_status_vehicle_document_type_tuv');
    case 'insurance':
      return t.t('fleet_status_vehicle_document_type_insurance');
    case 'service':
      return t.t('fleet_status_vehicle_document_type_service');
    case 'rc':
      return t.t('fleet_status_vehicle_document_type_rc');
    default:
      return type;
  }
}

String _vehicleDocumentContentType(String fileName) {
  final lower = fileName.toLowerCase();
  if (lower.endsWith('.pdf')) return 'application/pdf';
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
    return 'image/jpeg';
  }
  if (lower.endsWith('.webp')) return 'image/webp';
  return 'application/octet-stream';
}

String _deriveVehicleTuvStatus(_VehicleDocumentRecord? document) {
  if (document == null) return _vehicleTuvStatusMissing;
  final expiryDate = document.expiryDate;
  if (expiryDate == null) return _vehicleTuvStatusPending;
  return _isExpiredDate(expiryDate)
      ? _vehicleTuvStatusExpired
      : _vehicleTuvStatusValid;
}

bool _isExpiredDate(DateTime date) {
  final normalizedDate = DateTime(date.year, date.month, date.day);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return normalizedDate.isBefore(today);
}

String _vehicleTuvStatusLabel(BuildContext context, String status) {
  final t = AppLocalizations.of(context);
  switch (status) {
    case _vehicleTuvStatusExpired:
      return t.t('fleet_status_tuv_expired');
    case _vehicleTuvStatusPending:
      return t.t('fleet_status_tuv_pending');
    case _vehicleTuvStatusMissing:
      return t.t('fleet_status_tuv_missing');
    case _vehicleTuvStatusValid:
    default:
      return t.t('fleet_status_tuv_valid');
  }
}

Color _vehicleTuvStatusColor(String status) {
  switch (status) {
    case _vehicleTuvStatusExpired:
      return _FleetStatusPageState._kRed;
    case _vehicleTuvStatusPending:
      return const Color(0xFFB45309);
    case _vehicleTuvStatusMissing:
      return const Color(0xFFD97706);
    case _vehicleTuvStatusValid:
    default:
      return _FleetStatusPageState._kGreen;
  }
}

String _vehicleDocumentExpiryStatus(
  String type,
  _VehicleDocumentRecord? document,
) {
  if (document == null) return _vehicleDocumentExpiryMissing;
  if (document.expiryDate == null) return _vehicleDocumentExpiryNotSet;
  return _isExpiredDate(document.expiryDate!)
      ? _vehicleDocumentExpiryExpired
      : _vehicleDocumentExpiryValid;
}

String _vehicleDocumentExpiryStatusLabel(BuildContext context, String status) {
  final t = AppLocalizations.of(context);
  switch (status) {
    case _vehicleDocumentExpiryMissing:
      return t.t('fleet_status_vehicle_details_missing');
    case _vehicleDocumentExpiryExpired:
      return t.t('fleet_status_vehicle_details_expired');
    case _vehicleDocumentExpiryNotSet:
      return t.t('fleet_status_vehicle_details_not_set');
    case _vehicleDocumentExpiryValid:
    default:
      return t.t('fleet_status_tuv_valid');
  }
}

String _fleetStatusLabelFromContext(BuildContext context, String status) {
  final t = AppLocalizations.of(context);
  switch (status) {
    case 'defleeted':
      return t.t('fleet_status_status_defleeted');
    case 'grounded':
      return t.t('fleet_status_status_grounded');
    case 'in_service':
      return t.t('fleet_status_status_in_service');
    case 'active':
    default:
      return t.t('fleet_status_status_active');
  }
}
