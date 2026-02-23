import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum _AdminWorkTab { shifts, absences }

class AdminShiftAbsencePage extends StatefulWidget {
  const AdminShiftAbsencePage({super.key});

  @override
  State<AdminShiftAbsencePage> createState() => _AdminShiftAbsencePageState();
}

class _AdminShiftAbsencePageState extends State<AdminShiftAbsencePage> {
  static const _kGreen = Color(0xFF1D7F5A);
  static const _kText = Color(0xFF111827);
  static const _kMuted = Color(0xFF6B7280);
  static const _kBorder = Color(0xFFE5E7EB);
  static const _kPageBg = Color(0xFFF4F5FB);
  static const _kSoftBg = Color(0xFFF9FAFB);

  static final List<_ShiftTemplate> _templates = [
    _ShiftTemplate(
      id: 'off',
      label: 'FREI / Off Day',
      startHour: 0,
      startMinute: 0,
      endHour: 0,
      endMinute: 0,
      bgColor: Color(0xFFE5E7EB),
      fgColor: Color(0xFF4B5563),
      status: 'off',
    ),
    _ShiftTemplate(
      id: 'nd_1',
      label: 'ND-1',
      startHour: 10,
      startMinute: 0,
      endHour: 18,
      endMinute: 30,
      bgColor: Color(0xFFC9E8FA),
      fgColor: Color(0xFF0F5C8A),
    ),
    _ShiftTemplate(
      id: 'nd_2',
      label: 'ND-2',
      startHour: 10,
      startMinute: 20,
      endHour: 18,
      endMinute: 50,
      bgColor: Color(0xFFB7E1F8),
      fgColor: Color(0xFF0F5C8A),
    ),
    _ShiftTemplate(
      id: 'nd_3',
      label: 'ND-3',
      startHour: 10,
      startMinute: 40,
      endHour: 19,
      endMinute: 10,
      bgColor: Color(0xFFA9DCF6),
      fgColor: Color(0xFF0F5C8A),
    ),
    _ShiftTemplate(
      id: 'sd_a1_sd_c',
      label: 'SD A-1 & SD C',
      startHour: 6,
      startMinute: 30,
      endHour: 17,
      endMinute: 45,
      bgColor: Color(0xFFD9F3CB),
      fgColor: Color(0xFF2E6B2E),
    ),
    _ShiftTemplate(
      id: 'sd_c',
      label: 'SD C',
      startHour: 17,
      startMinute: 30,
      endHour: 22,
      endMinute: 0,
      bgColor: Color(0xFFF8D06F),
      fgColor: Color(0xFF7A4E00),
    ),
    _ShiftTemplate(
      id: 'ride_along_nd_1',
      label: 'Ride Along | ND-1',
      startHour: 10,
      startMinute: 0,
      endHour: 18,
      endMinute: 30,
      bgColor: Color(0xFFFDE047),
      fgColor: Color(0xFF7A4E00),
    ),
  ];

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;
  String? _resolvedDspUid;
  bool _loadingScope = true;

  _AdminWorkTab _tab = _AdminWorkTab.shifts;
  DateTime _planDate = DateTime.now();
  String _search = '';
  String _bulkTemplateId = _templates[1].id;
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final Map<String, String> _draftTemplateByDriver = <String, String>{};
  final Set<String> _selectedDriverIds = <String>{};
  bool _savingShift = false;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _driversStream;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _shiftsStream;
  String? _driversStreamScopeUid;
  String? _shiftsStreamScopeUid;
  String? _shiftsStreamDateKey;

  @override
  void initState() {
    super.initState();
    _resolveScope();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  String? get _scopeUid {
    final uid = _uid;
    if (uid == null) return null;
    final scoped = (_resolvedDspUid ?? '').trim();
    return scoped.isNotEmpty ? scoped : uid;
  }

  CollectionReference<Map<String, dynamic>>? get _driversCol {
    final scope = _scopeUid;
    if (scope == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(scope)
        .collection('drivers');
  }

  CollectionReference<Map<String, dynamic>>? get _rootShiftsCol {
    final scope = _scopeUid;
    if (scope == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(scope)
        .collection('shift_plans');
  }

  CollectionReference<Map<String, dynamic>>? get _rootAbsencesCol {
    final scope = _scopeUid;
    if (scope == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(scope)
        .collection('absence_requests');
  }

  Future<void> _resolveScope() async {
    final uid = _uid;
    if (uid == null) {
      if (mounted) setState(() => _loadingScope = false);
      return;
    }

    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final data = snap.data() ?? const <String, dynamic>{};
      final dspUid = (data['dspUid'] ?? '').toString().trim();
      _resolvedDspUid = dspUid.isEmpty ? uid : dspUid;
    } catch (_) {
      _resolvedDspUid = uid;
    } finally {
      if (mounted) {
        setState(() {
          _loadingScope = false;
          _syncShiftStreams(force: true);
        });
      }
    }
  }

  DateTime get _dayStart =>
      DateTime(_planDate.year, _planDate.month, _planDate.day);
  DateTime get _dayEnd => _dayStart.add(const Duration(days: 1));

  Future<void> _pickPlanDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
      initialDate: _planDate,
    );
    if (selected == null || !mounted) return;
    setState(() {
      _planDate = selected;
      _selectedDriverIds.clear();
      _syncShiftStreams(force: true);
    });
  }

  void _syncShiftStreams({bool force = false}) {
    final scope = _scopeUid;
    if (scope == null) {
      _driversStream = null;
      _shiftsStream = null;
      _driversStreamScopeUid = null;
      _shiftsStreamScopeUid = null;
      _shiftsStreamDateKey = null;
      return;
    }

    if (force || _driversStream == null || _driversStreamScopeUid != scope) {
      _driversStreamScopeUid = scope;
      _driversStream = FirebaseFirestore.instance
          .collection('users')
          .doc(scope)
          .collection('drivers')
          .snapshots();
    }

    final dayKey = _dateKey(_dayStart);
    if (force ||
        _shiftsStream == null ||
        _shiftsStreamScopeUid != scope ||
        _shiftsStreamDateKey != dayKey) {
      _shiftsStreamScopeUid = scope;
      _shiftsStreamDateKey = dayKey;
      _shiftsStream = FirebaseFirestore.instance
          .collection('users')
          .doc(scope)
          .collection('shift_plans')
          .where(
            'shiftStart',
            isGreaterThanOrEqualTo: Timestamp.fromDate(_dayStart),
          )
          .where('shiftStart', isLessThan: Timestamp.fromDate(_dayEnd))
          .snapshots();
    }
  }

  Future<void> _upsertShift({
    required String driverId,
    required String driverName,
    required String templateId,
    required String? existingDocId,
    required Map<String, dynamic>? existingData,
  }) async {
    final scope = _scopeUid;
    final driversCol = _driversCol;
    final rootShifts = _rootShiftsCol;
    if (scope == null || driversCol == null || rootShifts == null) {
      _showSnack('Missing DSP scope.', error: true);
      return;
    }

    final template = _templateById(templateId);
    if (template == null) {
      _showSnack('Unknown shift template.', error: true);
      return;
    }

    final docId = (existingDocId != null && existingDocId.trim().isNotEmpty)
        ? existingDocId.trim()
        : '${driverId}_${_dateKey(_dayStart)}';

    final start = DateTime(
      _dayStart.year,
      _dayStart.month,
      _dayStart.day,
      template.startHour,
      template.startMinute,
    );
    final end = DateTime(
      _dayStart.year,
      _dayStart.month,
      _dayStart.day,
      template.endHour,
      template.endMinute,
    );

    final payload = <String, dynamic>{
      'shiftId': docId,
      'dspUid': scope,
      'driverTransporterId': driverId,
      'driverName': driverName,
      'templateId': template.id,
      'templateLabel': template.label,
      'templateBgColor': template.bgColor.toARGB32(),
      'templateFgColor': template.fgColor.toARGB32(),
      'shiftDateKey': _dateKey(_dayStart),
      'shiftStart': Timestamp.fromDate(start),
      'shiftEnd': Timestamp.fromDate(end),
      'status': template.status,
      'notes': _stringOf(existingData?['notes']),
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': existingData == null
          ? FieldValue.serverTimestamp()
          : existingData['createdAt'] ?? FieldValue.serverTimestamp(),
      'createdBy': existingData == null
          ? _uid
          : _stringOf(existingData['createdBy']).isEmpty
          ? _uid
          : _stringOf(existingData['createdBy']),
    };

    final rootRef = rootShifts.doc(docId);
    final driverRef = driversCol.doc(driverId).collection('shifts').doc(docId);

    final batch = FirebaseFirestore.instance.batch();
    batch.set(rootRef, payload, SetOptions(merge: true));
    batch.set(driverRef, payload, SetOptions(merge: true));
    await batch.commit();
  }

  Future<void> _applyTemplateToAll({
    required List<_DriverRow> drivers,
    required Map<String, QueryDocumentSnapshot<Map<String, dynamic>>>
    existingByDriver,
  }) async {
    if (drivers.isEmpty) {
      _showSnack('No drivers in current filter.');
      return;
    }

    setState(() => _savingShift = true);
    try {
      for (final driver in drivers) {
        final existing = existingByDriver[driver.id];
        await _upsertShift(
          driverId: driver.id,
          driverName: driver.name,
          templateId: _bulkTemplateId,
          existingDocId: existing?.id,
          existingData: existing?.data(),
        );
      }
      _showSnack('Template applied to ${drivers.length} driver(s).');
    } catch (e) {
      _showSnack('Failed to apply template: $e', error: true);
    } finally {
      if (mounted) setState(() => _savingShift = false);
    }
  }

  Future<void> _setDriverTemplate({
    required _DriverRow driver,
    required Map<String, QueryDocumentSnapshot<Map<String, dynamic>>>
    existingByDriver,
  }) async {
    final templateId =
        _draftTemplateByDriver[driver.id] ??
        existingByDriver[driver.id]?.data()['templateId']?.toString() ??
        _bulkTemplateId;

    setState(() => _savingShift = true);
    try {
      final existing = existingByDriver[driver.id];
      await _upsertShift(
        driverId: driver.id,
        driverName: driver.name,
        templateId: templateId,
        existingDocId: existing?.id,
        existingData: existing?.data(),
      );
      _showSnack('Shift updated for ${driver.name}.');
    } catch (e) {
      _showSnack('Failed to update shift: $e', error: true);
    } finally {
      if (mounted) setState(() => _savingShift = false);
    }
  }

  Future<void> _applyTemplateToSelected({
    required List<_DriverRow> drivers,
    required Map<String, QueryDocumentSnapshot<Map<String, dynamic>>>
    existingByDriver,
  }) async {
    final selectedDrivers = drivers
        .where((d) => _selectedDriverIds.contains(d.id))
        .toList();
    if (selectedDrivers.isEmpty) {
      _showSnack('Select at least one driver first.');
      return;
    }

    await _applyTemplateToAll(
      drivers: selectedDrivers,
      existingByDriver: existingByDriver,
    );
  }

  void _setDriverSelected(String driverId, bool selected) {
    setState(() {
      if (selected) {
        _selectedDriverIds.add(driverId);
      } else {
        _selectedDriverIds.remove(driverId);
      }
    });
  }

  void _setAllFilteredSelected({
    required List<_DriverRow> filteredDrivers,
    required bool selected,
  }) {
    setState(() {
      for (final d in filteredDrivers) {
        if (selected) {
          _selectedDriverIds.add(d.id);
        } else {
          _selectedDriverIds.remove(d.id);
        }
      }
    });
  }

  Future<void> _updateAbsenceStatus({
    required String requestId,
    required String driverId,
    required String status,
  }) async {
    final scope = _scopeUid;
    if (scope == null) {
      _showSnack('Missing DSP scope.', error: true);
      return;
    }

    try {
      final db = FirebaseFirestore.instance;
      final rootRef = db
          .collection('users')
          .doc(scope)
          .collection('absence_requests')
          .doc(requestId);
      final driverRef = db
          .collection('users')
          .doc(scope)
          .collection('drivers')
          .doc(driverId.toUpperCase())
          .collection('absence_requests')
          .doc(requestId);

      final payload = <String, dynamic>{
        'status': status,
        'reviewedBy': _uid,
        'reviewedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      final batch = db.batch();
      batch.set(rootRef, payload, SetOptions(merge: true));
      batch.set(driverRef, payload, SetOptions(merge: true));
      await batch.commit();

      _showSnack('Request marked as ${status.toUpperCase()}.');
    } catch (e) {
      _showSnack('Failed to update request: $e', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_uid == null) {
      return const Center(child: Text('You must be logged in as admin.'));
    }
    if (_loadingScope) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 980;
        final padding = isCompact ? 12.0 : 24.0;
        final titleSize = isCompact ? 20.0 : 24.0;

        return Container(
          color: _kPageBg,
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isCompact) ...[
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      color: _kGreen,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Shift Plan & Absence',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w900,
                        color: _kText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildTabSelector(),
              ] else
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      color: _kGreen,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Shift Plan & Absence',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w900,
                        color: _kText,
                      ),
                    ),
                    const Spacer(),
                    _buildTabSelector(),
                  ],
                ),
              const SizedBox(height: 4),
              const Text(
                'Manage daily shift assignments and approve driver leave requests.',
                style: TextStyle(color: _kMuted, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _tab == _AdminWorkTab.shifts
                    ? _buildShiftsTab(isCompact: isCompact)
                    : _buildAbsencesTab(isCompact: isCompact),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabSelector() {
    return SegmentedButton<_AdminWorkTab>(
      segments: const [
        ButtonSegment(
          value: _AdminWorkTab.shifts,
          label: Text('Shifts'),
          icon: Icon(Icons.calendar_today_rounded),
        ),
        ButtonSegment(
          value: _AdminWorkTab.absences,
          label: Text('Absence Requests'),
          icon: Icon(Icons.event_busy_outlined),
        ),
      ],
      selected: {_tab},
      onSelectionChanged: (selection) {
        if (selection.isEmpty) return;
        setState(() => _tab = selection.first);
      },
    );
  }

  Widget _buildShiftsTab({required bool isCompact}) {
    final scope = _scopeUid;
    if (scope == null) {
      return const Center(child: Text('Missing DSP scope.'));
    }
    _syncShiftStreams();
    final driversStream = _driversStream;
    final shiftsStream = _shiftsStream;
    if (driversStream == null || shiftsStream == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: driversStream,
      builder: (context, driversSnap) {
        if (driversSnap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (driversSnap.hasError) {
          return Text('Failed to load drivers: ${driversSnap.error}');
        }

        final rawDrivers = driversSnap.data?.docs ?? const [];
        final drivers =
            rawDrivers.map((d) {
              final data = d.data();
              final id = d.id.toUpperCase();
              final name = _firstNonEmpty([
                _stringOf(data['name']),
                _stringOf(data['fullName']),
                _stringOf(data['driverName']),
                id,
              ]);
              return _DriverRow(id: id, name: name);
            }).toList()..sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
            );

        final needle = _search.toLowerCase().trim();
        final filtered = needle.isEmpty
            ? drivers
            : drivers
                  .where(
                    (d) =>
                        d.name.toLowerCase().contains(needle) ||
                        d.id.toLowerCase().contains(needle),
                  )
                  .toList();
        final selectedInFilterCount = filtered
            .where((d) => _selectedDriverIds.contains(d.id))
            .length;
        final allFilteredSelected =
            filtered.isNotEmpty && selectedInFilterCount == filtered.length;

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: shiftsStream,
          builder: (context, shiftsSnap) {
            if (shiftsSnap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (shiftsSnap.hasError) {
              return Text('Failed to load shifts: ${shiftsSnap.error}');
            }

            final shifts = shiftsSnap.data?.docs ?? const [];
            final existingByDriver =
                <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};
            for (final s in shifts) {
              final driverId = _stringOf(
                s.data()['driverTransporterId'],
              ).toUpperCase();
              if (driverId.isEmpty) continue;
              existingByDriver[driverId] = s;
            }

            return Container(
              decoration: _panelDecoration(radius: 24),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_month_outlined,
                              size: 18,
                              color: _kGreen,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Daily Shift Planner',
                              style: TextStyle(
                                fontSize: isCompact ? 16 : 18,
                                fontWeight: FontWeight.w900,
                                color: _kText,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${filtered.length} drivers',
                              style: const TextStyle(
                                color: _kMuted,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '$selectedInFilterCount selected',
                              style: const TextStyle(
                                color: _kGreen,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (isCompact)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              OutlinedButton.icon(
                                onPressed: _pickPlanDate,
                                icon: const Icon(Icons.calendar_month_outlined),
                                label: Text(
                                  DateFormat(
                                    'EEE, dd.MM.yyyy',
                                  ).format(_dayStart),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _searchCtrl,
                                focusNode: _searchFocus,
                                onChanged: (value) =>
                                    setState(() => _search = value),
                                decoration: _pillInputDecoration(
                                  hint: 'Search driver name or ID',
                                  prefixIcon: Icons.search,
                                ),
                              ),
                              const SizedBox(height: 10),
                              DropdownButtonFormField<String>(
                                initialValue: _bulkTemplateId,
                                decoration: _pillInputDecoration(
                                  label: 'Quick template',
                                ),
                                items: _templates
                                    .map(
                                      (t) => DropdownMenuItem(
                                        value: t.id,
                                        child: Text(t.label),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value == null) return;
                                  setState(() => _bulkTemplateId = value);
                                },
                              ),
                              const SizedBox(height: 10),
                              FilledButton.icon(
                                onPressed:
                                    _savingShift || selectedInFilterCount == 0
                                    ? null
                                    : () => _applyTemplateToSelected(
                                        drivers: filtered,
                                        existingByDriver: existingByDriver,
                                      ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: _kGreen,
                                  foregroundColor: Colors.white,
                                ),
                                icon: _savingShift
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.playlist_add_check),
                                label: Text(
                                  _savingShift
                                      ? 'Applying...'
                                      : 'Apply to Selected ($selectedInFilterCount)',
                                ),
                              ),
                            ],
                          )
                        else
                          Row(
                            children: [
                              OutlinedButton.icon(
                                onPressed: _pickPlanDate,
                                icon: const Icon(Icons.calendar_month_outlined),
                                label: Text(
                                  DateFormat(
                                    'EEE, dd.MM.yyyy',
                                  ).format(_dayStart),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 3,
                                child: TextField(
                                  controller: _searchCtrl,
                                  focusNode: _searchFocus,
                                  onChanged: (value) =>
                                      setState(() => _search = value),
                                  decoration: _pillInputDecoration(
                                    hint: 'Search driver name or ID',
                                    prefixIcon: Icons.search,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: DropdownButtonFormField<String>(
                                  initialValue: _bulkTemplateId,
                                  decoration: _pillInputDecoration(
                                    label: 'Quick template',
                                  ),
                                  items: _templates
                                      .map(
                                        (t) => DropdownMenuItem(
                                          value: t.id,
                                          child: Text(t.label),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    if (value == null) return;
                                    setState(() => _bulkTemplateId = value);
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              FilledButton.icon(
                                onPressed:
                                    _savingShift || selectedInFilterCount == 0
                                    ? null
                                    : () => _applyTemplateToSelected(
                                        drivers: filtered,
                                        existingByDriver: existingByDriver,
                                      ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: _kGreen,
                                  foregroundColor: Colors.white,
                                ),
                                icon: _savingShift
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.playlist_add_check),
                                label: Text(
                                  _savingShift
                                      ? 'Applying...'
                                      : 'Apply to Selected ($selectedInFilterCount)',
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(
                            child: Text('No drivers for current filter.'),
                          )
                        : Padding(
                            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                            child: Column(
                              children: [
                                if (!isCompact)
                                  Container(
                                    height: 42,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _kSoftBg,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: _kBorder),
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 48,
                                          child: Checkbox(
                                            value: allFilteredSelected,
                                            onChanged: filtered.isEmpty
                                                ? null
                                                : (value) {
                                                    _setAllFilteredSelected(
                                                      filteredDrivers: filtered,
                                                      selected: value == true,
                                                    );
                                                  },
                                          ),
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: const Text(
                                            'Driver',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: _kMuted,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: const Text(
                                            'Assigned Shift',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: _kMuted,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: const Text(
                                            'Template',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: _kMuted,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 102),
                                      ],
                                    ),
                                  ),
                                if (!isCompact) const SizedBox(height: 8),
                                Expanded(
                                  child: ListView.separated(
                                    itemCount: filtered.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 8),
                                    itemBuilder: (context, index) {
                                      final driver = filtered[index];
                                      final existing =
                                          existingByDriver[driver.id];
                                      final existingData =
                                          existing?.data() ??
                                          const <String, dynamic>{};
                                      final existingTemplateId = _stringOf(
                                        existingData['templateId'],
                                      );
                                      final selectedTemplateId =
                                          _draftTemplateByDriver[driver.id] ??
                                          (existingTemplateId.isNotEmpty
                                              ? existingTemplateId
                                              : _bulkTemplateId);
                                      final selectedTemplate =
                                          _templateById(selectedTemplateId) ??
                                          _templates.first;
                                      final dropdownValue = selectedTemplate.id;
                                      final status =
                                          _stringOf(
                                            existingData['status'],
                                          ).isEmpty
                                          ? '-'
                                          : _stringOf(
                                              existingData['status'],
                                            ).toUpperCase();
                                      final start = _toDate(
                                        existingData['shiftStart'],
                                      );
                                      final end = _toDate(
                                        existingData['shiftEnd'],
                                      );
                                      final label = _shiftSummaryLabel(
                                        existingData: existingData,
                                        fallbackTemplate: selectedTemplate,
                                        start: start,
                                        end: end,
                                        status: status,
                                        assigned: existing != null,
                                      );
                                      final isSelected = _selectedDriverIds
                                          .contains(driver.id);

                                      if (isCompact) {
                                        return Container(
                                          key: ValueKey(
                                            'shift_row_compact_${driver.id}',
                                          ),
                                          padding: const EdgeInsets.all(12),
                                          decoration: _rowDecoration(),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Checkbox(
                                                    value: isSelected,
                                                    onChanged: (value) {
                                                      _setDriverSelected(
                                                        driver.id,
                                                        value == true,
                                                      );
                                                    },
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      '${driver.name} (${driver.id})',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color: _kText,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      selectedTemplate.bgColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        999,
                                                      ),
                                                ),
                                                child: Text(
                                                  label,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w800,
                                                    color: selectedTemplate
                                                        .fgColor,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              DropdownButtonFormField<String>(
                                                key: ValueKey(
                                                  'shift_template_compact_${driver.id}',
                                                ),
                                                initialValue: dropdownValue,
                                                decoration:
                                                    _pillInputDecoration(),
                                                items: _templates
                                                    .map(
                                                      (t) => DropdownMenuItem(
                                                        value: t.id,
                                                        child: Text(t.label),
                                                      ),
                                                    )
                                                    .toList(),
                                                onChanged: (value) {
                                                  if (value == null) return;
                                                  setState(
                                                    () =>
                                                        _draftTemplateByDriver[driver
                                                                .id] =
                                                            value,
                                                  );
                                                },
                                              ),
                                              const SizedBox(height: 10),
                                              SizedBox(
                                                width: double.infinity,
                                                child: FilledButton.icon(
                                                  onPressed: _savingShift
                                                      ? null
                                                      : () => _setDriverTemplate(
                                                          driver: driver,
                                                          existingByDriver:
                                                              existingByDriver,
                                                        ),
                                                  style: FilledButton.styleFrom(
                                                    backgroundColor: _kGreen,
                                                    foregroundColor:
                                                        Colors.white,
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 12,
                                                        ),
                                                  ),
                                                  icon: const Icon(
                                                    Icons.check_rounded,
                                                    size: 16,
                                                  ),
                                                  label: const Text(
                                                    'Save Shift',
                                                    maxLines: 1,
                                                    overflow: TextOverflow.fade,
                                                    softWrap: false,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }

                                      return Container(
                                        key: ValueKey(
                                          'shift_row_desktop_${driver.id}',
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 12,
                                        ),
                                        decoration: _rowDecoration(),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 40,
                                              child: Checkbox(
                                                value: isSelected,
                                                onChanged: (value) {
                                                  _setDriverSelected(
                                                    driver.id,
                                                    value == true,
                                                  );
                                                },
                                              ),
                                            ),
                                            Expanded(
                                              flex: 4,
                                              child: Text(
                                                '${driver.name} (${driver.id})',
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  color: _kText,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              flex: 4,
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 6,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: selectedTemplate
                                                        .bgColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          999,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    label,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: selectedTemplate
                                                          .fgColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              flex: 3,
                                              child: DropdownButtonFormField<String>(
                                                key: ValueKey(
                                                  'shift_template_desktop_${driver.id}',
                                                ),
                                                initialValue: dropdownValue,
                                                decoration:
                                                    _pillInputDecoration(),
                                                items: _templates
                                                    .map(
                                                      (t) => DropdownMenuItem(
                                                        value: t.id,
                                                        child: Text(t.label),
                                                      ),
                                                    )
                                                    .toList(),
                                                onChanged: (value) {
                                                  if (value == null) return;
                                                  setState(
                                                    () =>
                                                        _draftTemplateByDriver[driver
                                                                .id] =
                                                            value,
                                                  );
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            SizedBox(
                                              width: 92,
                                              child: FilledButton.icon(
                                                onPressed: _savingShift
                                                    ? null
                                                    : () => _setDriverTemplate(
                                                        driver: driver,
                                                        existingByDriver:
                                                            existingByDriver,
                                                      ),
                                                style: FilledButton.styleFrom(
                                                  backgroundColor: _kGreen,
                                                  foregroundColor: Colors.white,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 12,
                                                      ),
                                                ),
                                                icon: const Icon(
                                                  Icons.check_rounded,
                                                  size: 15,
                                                ),
                                                label: const Text(
                                                  'Save',
                                                  maxLines: 1,
                                                  overflow: TextOverflow.fade,
                                                  softWrap: false,
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
  }

  Widget _buildAbsencesTab({required bool isCompact}) {
    final absencesCol = _rootAbsencesCol;
    if (absencesCol == null) {
      return const Center(child: Text('Missing DSP scope.'));
    }

    return Container(
      decoration: _panelDecoration(radius: 24),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.event_busy_outlined, size: 18, color: _kGreen),
              SizedBox(width: 8),
              Text(
                'Absence Requests',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: _kText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: absencesCol
                  .orderBy('submittedAt', descending: true)
                  .limit(200)
                  .snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Text('Failed to load requests: ${snap.error}');
                }

                final docs = snap.data?.docs ?? const [];
                if (docs.isEmpty) {
                  return const Center(child: Text('No absence requests yet.'));
                }

                if (isCompact) {
                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data();
                      final driverId = _stringOf(data['driverTransporterId']);
                      final name = _firstNonEmpty([
                        _stringOf(data['driverName']),
                        driverId,
                      ]);
                      final status = _stringOf(data['status']).isEmpty
                          ? 'pending'
                          : _stringOf(data['status']);
                      final type = _stringOf(data['type']) == 'sick_leave'
                          ? 'Sick leave'
                          : 'Vacation';
                      final from = _toDate(data['fromDate']);
                      final to = _toDate(data['toDate']);
                      final reason = _stringOf(data['reason']);

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: _rowDecoration(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                _statusChip(status),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '$type | ${_date(from)} - ${_date(to)}',
                              style: const TextStyle(
                                color: Color(0xFF374151),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (reason.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                reason,
                                style: const TextStyle(color: _kMuted),
                              ),
                            ],
                            if (status.toLowerCase().trim() == 'pending' &&
                                driverId.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => _updateAbsenceStatus(
                                        requestId: doc.id,
                                        driverId: driverId,
                                        status: 'approved',
                                      ),
                                      child: const Text('Approve'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => _updateAbsenceStatus(
                                        requestId: doc.id,
                                        driverId: driverId,
                                        status: 'rejected',
                                      ),
                                      child: const Text('Reject'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  );
                }

                return Column(
                  children: [
                    Container(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: _kSoftBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _kBorder),
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Driver',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: _kMuted,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Leave Period',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: _kMuted,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Reason',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: _kMuted,
                              ),
                            ),
                          ),
                          SizedBox(width: 170),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.separated(
                        itemCount: docs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final data = doc.data();
                          final driverId = _stringOf(
                            data['driverTransporterId'],
                          );
                          final name = _firstNonEmpty([
                            _stringOf(data['driverName']),
                            driverId,
                          ]);
                          final status = _stringOf(data['status']).isEmpty
                              ? 'pending'
                              : _stringOf(data['status']);
                          final type = _stringOf(data['type']) == 'sick_leave'
                              ? 'Sick leave'
                              : 'Vacation';
                          final from = _toDate(data['fromDate']);
                          final to = _toDate(data['toDate']);
                          final reason = _stringOf(data['reason']);

                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: _rowDecoration(),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: _kText,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    '$type | ${_date(from)} - ${_date(to)}',
                                    style: const TextStyle(
                                      color: Color(0xFF374151),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    reason.isEmpty ? '-' : reason,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: _kMuted,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _statusChip(status),
                                const SizedBox(width: 8),
                                if (status.toLowerCase().trim() == 'pending' &&
                                    driverId.isNotEmpty)
                                  Row(
                                    children: [
                                      TextButton(
                                        onPressed: () => _updateAbsenceStatus(
                                          requestId: doc.id,
                                          driverId: driverId,
                                          status: 'approved',
                                        ),
                                        child: const Text('Approve'),
                                      ),
                                      TextButton(
                                        onPressed: () => _updateAbsenceStatus(
                                          requestId: doc.id,
                                          driverId: driverId,
                                          status: 'rejected',
                                        ),
                                        child: const Text('Reject'),
                                      ),
                                    ],
                                  )
                                else
                                  const SizedBox(width: 110),
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
          ),
        ],
      ),
    );
  }

  String _shiftSummaryLabel({
    required Map<String, dynamic> existingData,
    required _ShiftTemplate fallbackTemplate,
    required DateTime? start,
    required DateTime? end,
    required String status,
    required bool assigned,
  }) {
    if (!assigned) return 'UNASSIGNED';
    final label = _stringOf(existingData['templateLabel']).isEmpty
        ? fallbackTemplate.label
        : _stringOf(existingData['templateLabel']);
    return '$label | ${_time(start)} - ${_time(end)} | $status';
  }

  InputDecoration _pillInputDecoration({
    String? hint,
    String? label,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      labelText: label,
      prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
      isDense: true,
      filled: true,
      fillColor: _kSoftBg,
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
        borderSide: const BorderSide(color: _kGreen),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  BoxDecoration _panelDecoration({double radius = 20}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: _kBorder),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  BoxDecoration _rowDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _kBorder),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _statusChip(String status) {
    final s = status.toLowerCase().trim();
    Color fg;
    Color bg;
    if (s == 'approved') {
      fg = const Color(0xFF1D7F5A);
      bg = const Color(0xFFE4F5EC);
    } else if (s == 'rejected') {
      fg = const Color(0xFFB91C1C);
      bg = const Color(0xFFFEE2E2);
    } else {
      fg = const Color(0xFF8A6200);
      bg = const Color(0xFFFEF3C7);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        s.toUpperCase(),
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w800),
      ),
    );
  }

  void _showSnack(String message, {bool error = false}) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? const Color(0xFFB91C1C) : null,
      ),
    );
  }

  static _ShiftTemplate? _templateById(String id) {
    for (final t in _templates) {
      if (t.id == id) return t;
    }
    return null;
  }

  static String _dateKey(DateTime value) =>
      DateFormat('yyyyMMdd').format(value);

  static String _time(DateTime? value) {
    if (value == null) return '--:--';
    return DateFormat('HH:mm').format(value);
  }

  static String _date(DateTime? value) {
    if (value == null) return '--.--.----';
    return DateFormat('dd.MM.yyyy').format(value);
  }

  static DateTime? _toDate(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    return null;
  }

  static String _stringOf(dynamic value) => value?.toString().trim() ?? '';

  static String _firstNonEmpty(List<String> values) {
    for (final raw in values) {
      final v = raw.trim();
      if (v.isNotEmpty) return v;
    }
    return '';
  }
}

class _DriverRow {
  final String id;
  final String name;

  const _DriverRow({required this.id, required this.name});
}

class _ShiftTemplate {
  final String id;
  final String label;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final Color bgColor;
  final Color fgColor;
  final String status;

  const _ShiftTemplate({
    required this.id,
    required this.label,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.bgColor,
    required this.fgColor,
    this.status = 'scheduled',
  });
}
