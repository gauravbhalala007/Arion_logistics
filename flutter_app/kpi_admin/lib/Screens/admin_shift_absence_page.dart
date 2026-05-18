import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminShiftAbsencePage extends StatefulWidget {
  const AdminShiftAbsencePage({super.key, this.requestType});

  /// When set ('vacation' or 'sick_leave'), this page only shows
  /// requests of that type — used by the Zeiten & Abwesenheiten
  /// tab shell to render two distinct pages from the same widget.
  /// Null = show all (legacy combined behaviour).
  final String? requestType;

  @override
  State<AdminShiftAbsencePage> createState() => _AdminShiftAbsencePageState();
}

class _AdminShiftAbsencePageState extends State<AdminShiftAbsencePage> {
  static const _kGreen = Color(0xFF1D7F5A);
  static const _kText = Color(0xFF111827);
  static const _kMuted = Color(0xFF6B7280);
  static const _kBorder = Color(0xFFE5E7EB);
  static const _kPageBg = Color(0xFFF4F5FB);
  static const _kOrange = Color(0xFFFF7A18);
  static const _kRed = Color(0xFFB91C1C);

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;
  String? _resolvedDspUid;
  bool _loadingScope = true;
  String _search = '';
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _resolveScope();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  String? get _scopeUid {
    final uid = _uid;
    if (uid == null) return null;
    final scoped = (_resolvedDspUid ?? '').trim();
    return scoped.isNotEmpty ? scoped : uid;
  }

  CollectionReference<Map<String, dynamic>>? get _rootAbsencesCol {
    final scope = _scopeUid;
    if (scope == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(scope)
        .collection('absence_requests');
  }

  void _setLoadingScope(bool value) {
    if (!mounted) return;
    setState(() => _loadingScope = value);
  }

  Future<void> _resolveScope() async {
    final uid = _uid;
    if (uid == null) {
      _setLoadingScope(false);
      return;
    }

    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (!mounted) return;
      final data = snap.data() ?? const <String, dynamic>{};
      final dspUid = (data['dspUid'] ?? '').toString().trim();
      _resolvedDspUid = dspUid.isEmpty ? uid : dspUid;
    } catch (_) {
      if (!mounted) return;
      _resolvedDspUid = uid;
    } finally {
      _setLoadingScope(false);
    }
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

      _showSnack(
        status == 'approved'
            ? 'Request approved successfully.'
            : 'Request rejected successfully.',
      );
    } catch (e) {
      _showSnack('Failed to update request: $e', error: true);
    }
  }

  Future<List<_DriverOption>> _loadDriverOptions() async {
    final scope = _scopeUid;
    if (scope == null) return const [];

    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(scope)
        .collection('drivers')
        .get();

    final items = <_DriverOption>[];
    for (final doc in snap.docs) {
      final data = doc.data();
      final transporterId = ((data['transporterId'] ?? doc.id).toString())
          .trim()
          .toUpperCase();
      if (transporterId.isEmpty) continue;
      final driverName = _AbsenceAdminItem._firstNonEmpty([
        (data['driverName'] ?? '').toString(),
        (data['name'] ?? '').toString(),
        (data['fullName'] ?? '').toString(),
        transporterId,
      ]);
      items.add(
        _DriverOption(
          driverId: transporterId,
          driverName: driverName,
        ),
      );
    }
    items.sort((a, b) => a.driverName.toLowerCase().compareTo(b.driverName.toLowerCase()));
    return items;
  }

  Future<void> _addManualPastLeave({
    required _DriverOption driver,
    required String type,
    required DateTime fromDate,
    required DateTime toDate,
    required String reason,
  }) async {
    final scope = _scopeUid;
    if (scope == null) {
      _showSnack('Missing DSP scope.', error: true);
      return;
    }

    final db = FirebaseFirestore.instance;
    final rootRef = db
        .collection('users')
        .doc(scope)
        .collection('absence_requests')
        .doc();
    final requestId = rootRef.id;
    final driverRef = db
        .collection('users')
        .doc(scope)
        .collection('drivers')
        .doc(driver.driverId)
        .collection('absence_requests')
        .doc(requestId);

    final now = FieldValue.serverTimestamp();
    final payload = <String, dynamic>{
      'requestId': requestId,
      'dspUid': scope,
      'driverUid': '',
      'driverTransporterId': driver.driverId,
      'driverName': driver.driverName,
      'type': type,
      'fromDate': Timestamp.fromDate(_dateOnly(fromDate)),
      'toDate': Timestamp.fromDate(_dateOnly(toDate)),
      'reason': reason.trim(),
      'status': 'approved',
      'submittedAt': now,
      'updatedAt': now,
      'reviewedAt': now,
      'reviewedBy': _uid,
      'source': 'admin_manual',
    };

    final batch = db.batch();
    batch.set(rootRef, payload, SetOptions(merge: true));
    batch.set(driverRef, payload, SetOptions(merge: true));
    await batch.commit();
  }

  Future<void> _openAddPastLeaveDialog() async {
    final driverOptions = await _loadDriverOptions();
    if (!mounted) return;
    if (driverOptions.isEmpty) {
      _showSnack('No drivers available yet.', error: true);
      return;
    }

    _DriverOption? selectedDriver = driverOptions.first;
    String type = widget.requestType ?? 'vacation';
    DateTime? fromDate;
    DateTime? toDate;
    final reasonCtrl = TextEditingController();
    var saving = false;

    Future<void> pickDate(
      BuildContext dialogContext,
      void Function(void Function()) setLocal, {
      required bool isFrom,
    }) async {
      final initialDate = isFrom
          ? (fromDate ?? DateTime.now())
          : (toDate ?? fromDate ?? DateTime.now());
      final picked = await showDatePicker(
        context: dialogContext,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
        initialDate: initialDate,
      );
      if (picked == null) return;
      setLocal(() {
        if (isFrom) {
          fromDate = picked;
          if (toDate != null && toDate!.isBefore(picked)) {
            toDate = picked;
          }
        } else {
          toDate = picked;
        }
      });
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: !saving,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setLocal) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE7F5EE),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.event_available_outlined,
                              color: _kGreen,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Add past leave',
                                  style: TextStyle(
                                    color: _kText,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Record vacation or leave that happened before CoDriver was introduced.',
                                  style: TextStyle(
                                    color: _kMuted,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<_DriverOption>(
                        initialValue: selectedDriver,
                        decoration: InputDecoration(
                          labelText: 'Driver',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        items: [
                          for (final item in driverOptions)
                            DropdownMenuItem<_DriverOption>(
                              value: item,
                              child: Text('${item.driverName} (${item.driverId})'),
                            ),
                        ],
                        onChanged: saving
                            ? null
                            : (value) => setLocal(() => selectedDriver = value),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: type,
                        decoration: InputDecoration(
                          labelText: 'Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'vacation',
                            child: Text('Vacation'),
                          ),
                          DropdownMenuItem(
                            value: 'sick_leave',
                            child: Text('Sick leave'),
                          ),
                          DropdownMenuItem(
                            value: 'special_leave',
                            child: Text('Special leave'),
                          ),
                        ],
                        onChanged: saving
                            ? null
                            : (value) {
                                if (value == null) return;
                                setLocal(() => type = value);
                              },
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: saving
                                  ? null
                                  : () => pickDate(
                                        dialogContext,
                                        setLocal,
                                        isFrom: true,
                                      ),
                              icon: const Icon(Icons.calendar_today_outlined),
                              label: Text(
                                fromDate == null
                                    ? 'From'
                                    : DateFormat('dd.MM.yyyy').format(fromDate!),
                              ),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: saving
                                  ? null
                                  : () => pickDate(
                                        dialogContext,
                                        setLocal,
                                        isFrom: false,
                                      ),
                              icon: const Icon(Icons.event_outlined),
                              label: Text(
                                toDate == null
                                    ? 'To'
                                    : DateFormat('dd.MM.yyyy').format(toDate!),
                              ),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: reasonCtrl,
                        enabled: !saving,
                        decoration: InputDecoration(
                          labelText: 'Reason',
                          hintText: 'Optional note',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          TextButton(
                            onPressed: saving
                                ? null
                                : () => Navigator.of(dialogContext).pop(),
                            child: const Text('Cancel'),
                          ),
                          const Spacer(),
                          FilledButton.icon(
                            onPressed: saving
                                ? null
                                : () async {
                                    if (selectedDriver == null) {
                                      _showSnack('Please choose a driver.', error: true);
                                      return;
                                    }
                                    if (fromDate == null || toDate == null) {
                                      _showSnack('Please select both dates.', error: true);
                                      return;
                                    }
                                    if (toDate!.isBefore(fromDate!)) {
                                      _showSnack('End date cannot be before start date.', error: true);
                                      return;
                                    }
                                    setLocal(() => saving = true);
                                    try {
                                      await _addManualPastLeave(
                                        driver: selectedDriver!,
                                        type: type,
                                        fromDate: fromDate!,
                                        toDate: toDate!,
                                        reason: reasonCtrl.text,
                                      );
                                      if (!dialogContext.mounted) return;
                                      Navigator.of(dialogContext).pop();
                                      _showSnack('Past leave added successfully.');
                                    } catch (e) {
                                      if (dialogContext.mounted) {
                                        setLocal(() => saving = false);
                                      }
                                      _showSnack('Failed to add past leave: $e', error: true);
                                    }
                                  },
                            icon: saving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.add_circle_outline),
                            label: Text(saving ? 'Saving...' : 'Add leave'),
                            style: FilledButton.styleFrom(
                              backgroundColor: _kGreen,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    reasonCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_uid == null) {
      return const Center(child: Text('You must be logged in as admin.'));
    }
    if (_loadingScope) {
      return const Center(child: CircularProgressIndicator());
    }

    final absencesCol = _rootAbsencesCol;
    if (absencesCol == null) {
      return const Center(child: Text('Missing DSP scope.'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 1080;
        final horizontalPadding = isCompact ? 14.0 : 24.0;

        return Container(
          color: _kPageBg,
          padding: EdgeInsets.all(horizontalPadding),
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: absencesCol
                .orderBy('submittedAt', descending: true)
                .limit(300)
                .snapshots(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Center(
                  child: Text('Failed to load absence requests: ${snap.error}'),
                );
              }

              final allItems = (snap.data?.docs ?? const [])
                  .map(_AbsenceAdminItem.fromDoc)
                  .where((it) =>
                      widget.requestType == null ||
                      it.type == widget.requestType)
                  .toList();
              final items = _applySearch(allItems, _search);
              final today = _dateOnly(DateTime.now());

              final pending =
                  items.where((item) => item.status == 'pending').toList()
                    ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
              final approvedUpcoming =
                  items
                      .where(
                        (item) =>
                            item.status == 'approved' &&
                            !item.toDate.isBefore(today),
                      )
                      .toList()
                    ..sort((a, b) => a.fromDate.compareTo(b.fromDate));
              final history =
                  items
                      .where(
                        (item) =>
                            item.status == 'rejected' ||
                            (item.status == 'approved' &&
                                item.toDate.isBefore(today)),
                      )
                      .toList()
                    ..sort((a, b) {
                      final aDate = a.reviewedAt ?? a.submittedAt;
                      final bDate = b.reviewedAt ?? b.submittedAt;
                      return bDate.compareTo(aDate);
                    });

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(isCompact: isCompact),
                  const SizedBox(height: 18),
                  _buildStatsRow(
                    isCompact: isCompact,
                    pendingCount: pending.length,
                    approvedUpcomingCount: approvedUpcoming.length,
                    historyCount: history.length,
                  ),
                  const SizedBox(height: 18),
                  _buildSearchBar(),
                  const SizedBox(height: 18),
                  Expanded(
                    child: isCompact
                        ? ListView(
                            children: [
                              _buildPendingSection(pending),
                              const SizedBox(height: 16),
                              _buildApprovedSection(approvedUpcoming),
                              const SizedBox(height: 16),
                              _buildHistorySection(history),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 6,
                                child: _buildPendingSection(pending),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 5,
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: _buildApprovedSection(
                                        approvedUpcoming,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Expanded(
                                      child: _buildHistorySection(history),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHeader({required bool isCompact}) {
    final isSick = widget.requestType == 'sick_leave';
    final isVacation = widget.requestType == 'vacation';
    final title = isSick
        ? 'Krankmeldungen'
        : isVacation
            ? 'Urlaubsanträge'
            : 'Absence Management';
    final subtitle = isSick
        ? 'Krankmeldungen prüfen — Pflicht-AU pro Fahrer einsehen, freigeben oder ablehnen.'
        : isVacation
            ? 'Urlaubsanträge prüfen, kommende Genehmigungen im Blick behalten, Historie pflegen.'
            : 'Review pending vacation requests, monitor upcoming approved leave, and keep a clear decision history.';
    final tileColor = isSick
        ? const Color(0xFFFEE2E2)
        : const Color(0xFFE7F5EE);
    final tileIcon = isSick
        ? Icons.medical_services_outlined
        : Icons.event_busy_outlined;
    final tileIconColor = isSick ? const Color(0xFFB91C1C) : _kGreen;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: tileColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            tileIcon,
            color: tileIconColor,
            size: 26,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: _kText,
                  fontSize: isCompact ? 22 : 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _kMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        FilledButton.icon(
          onPressed: _openAddPastLeaveDialog,
          icon: const Icon(Icons.add_circle_outline),
          label: Text(
            isSick ? 'Krankmeldung erfassen' : 'Urlaub nachtragen',
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow({
    required bool isCompact,
    required int pendingCount,
    required int approvedUpcomingCount,
    required int historyCount,
  }) {
    final children = [
      _StatCard(
        title: 'Pending review',
        value: '$pendingCount',
        caption: 'Requests waiting for decision',
        accent: _kOrange,
        icon: Icons.pending_actions_rounded,
      ),
      _StatCard(
        title: 'Approved upcoming',
        value: '$approvedUpcomingCount',
        caption: 'Upcoming or active approved leave',
        accent: _kGreen,
        icon: Icons.event_available_rounded,
      ),
      _StatCard(
        title: 'History',
        value: '$historyCount',
        caption: 'Reviewed or completed requests',
        accent: const Color(0xFF475569),
        icon: Icons.history_rounded,
      ),
    ];

    if (isCompact) {
      return Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1) const SizedBox(height: 12),
          ],
        ],
      );
    }

    return Row(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          Expanded(child: children[i]),
          if (i < children.length - 1) const SizedBox(width: 12),
        ],
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      key: const ValueKey('admin-absence-search'),
      controller: _searchCtrl,
      focusNode: _searchFocusNode,
      onChanged: (value) {
        if (_search == value) return;
        setState(() => _search = value);
      },
      decoration: InputDecoration(
        hintText: 'Search by driver name, ID, or reason',
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: _kBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: _kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: _kGreen),
        ),
      ),
    );
  }

  Widget _buildPendingSection(List<_AbsenceAdminItem> items) {
    return _SectionCard(
      title: 'Pending Requests',
      subtitle: 'Approve or reject new driver requests.',
      icon: Icons.pending_actions_rounded,
      child: items.isEmpty
          ? const _EmptyState(
              title: 'No pending requests',
              subtitle: 'Everything that needs review is already processed.',
            )
          : ListView.separated(
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                return _PendingAbsenceCard(
                  item: item,
                  onApprove: item.driverId.isEmpty
                      ? null
                      : () => _updateAbsenceStatus(
                          requestId: item.requestId,
                          driverId: item.driverId,
                          status: 'approved',
                        ),
                  onReject: item.driverId.isEmpty
                      ? null
                      : () => _updateAbsenceStatus(
                          requestId: item.requestId,
                          driverId: item.driverId,
                          status: 'rejected',
                        ),
                );
              },
            ),
    );
  }

  Widget _buildApprovedSection(List<_AbsenceAdminItem> items) {
    return _SectionCard(
      title: 'Approved Upcoming Leave',
      subtitle:
          'Drivers who already have approved vacation or sick leave ahead.',
      icon: Icons.event_available_rounded,
      child: items.isEmpty
          ? const _EmptyState(
              title: 'No upcoming approved leave',
              subtitle:
                  'Approved requests will appear here until their leave period ends.',
            )
          : ListView.separated(
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return _HistoryAbsenceTile(item: items[index]);
              },
            ),
    );
  }

  Widget _buildHistorySection(List<_AbsenceAdminItem> items) {
    return _SectionCard(
      title: 'History',
      subtitle: 'Past approved leave and rejected requests.',
      icon: Icons.history_rounded,
      child: items.isEmpty
          ? const _EmptyState(
              title: 'No history yet',
              subtitle: 'Reviewed requests will appear here over time.',
            )
          : ListView.separated(
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return _HistoryAbsenceTile(item: items[index]);
              },
            ),
    );
  }

  List<_AbsenceAdminItem> _applySearch(
    List<_AbsenceAdminItem> items,
    String search,
  ) {
    final needle = search.trim().toLowerCase();
    if (needle.isEmpty) return items;
    return items.where((item) {
      return item.driverName.toLowerCase().contains(needle) ||
          item.driverId.toLowerCase().contains(needle) ||
          item.reason.toLowerCase().contains(needle) ||
          item.typeLabel.toLowerCase().contains(needle);
    }).toList();
  }

  void _showSnack(String message, {bool error = false}) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(
      SnackBar(content: Text(message), backgroundColor: error ? _kRed : null),
    );
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, size: 20, color: const Color(0xFF334155)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (constraints.maxHeight.isFinite)
              Expanded(child: child)
            else
              child,
          ],
        );

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: content,
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String caption;
  final Color accent;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.caption,
    required this.accent,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  caption,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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

class _PendingAbsenceCard extends StatelessWidget {
  final _AbsenceAdminItem item;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const _PendingAbsenceCard({
    required this.item,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
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
                      item.driverName,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${item.driverId.isEmpty ? '-' : item.driverId}',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusChip(status: item.status),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetaPill(icon: Icons.category_outlined, text: item.typeLabel),
              _MetaPill(
                icon: Icons.calendar_today_outlined,
                text: '${item.fromDateText} - ${item.toDateText}',
              ),
              _MetaPill(icon: Icons.timelapse_rounded, text: item.daysLabel),
              _MetaPill(
                icon: Icons.schedule_send_outlined,
                text: 'Submitted ${item.submittedAtText}',
              ),
              if (item.type == 'sick_leave')
                _AuPill(item: item),
            ],
          ),
          if (item.reason.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Text(
                item.reason,
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onReject,
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Reject'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFB91C1C),
                    side: const BorderSide(color: Color(0xFFFCA5A5)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onApprove,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Approve'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1D7F5A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistoryAbsenceTile extends StatelessWidget {
  final _AbsenceAdminItem item;

  const _HistoryAbsenceTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.driverName,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _StatusChip(status: item.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${item.typeLabel} | ${item.fromDateText} - ${item.toDateText} | ${item.daysLabel}',
            style: const TextStyle(
              color: Color(0xFF334155),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (item.reason.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              item.reason,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            item.reviewLine,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: const Color(0xFF64748B)),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF334155),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    late final Color fg;
    late final Color bg;
    late final String label;

    switch (status) {
      case 'approved':
        fg = const Color(0xFF1D7F5A);
        bg = const Color(0xFFE4F5EC);
        label = 'APPROVED';
        break;
      case 'rejected':
        fg = const Color(0xFFB91C1C);
        bg = const Color(0xFFFEE2E2);
        label = 'REJECTED';
        break;
      default:
        fg = const Color(0xFF9A3412);
        bg = const Color(0xFFFFEDD5);
        label = 'PENDING';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptyState({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.inbox_outlined,
                color: Color(0xFF94A3B8),
                size: 28,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AbsenceAdminItem {
  final String requestId;
  final String driverId;
  final String driverName;
  final String type;
  final String status;
  final String reason;
  final DateTime fromDate;
  final DateTime toDate;
  final DateTime submittedAt;
  final DateTime? reviewedAt;

  /// Krankmeldung-AU upload (Arbeitsunfähigkeitsbescheinigung), only
  /// set for sick-leave requests. Stored as base64 inline in Firestore.
  final String auFileBase64;
  final String auFilename;
  final String auMimeType;

  const _AbsenceAdminItem({
    required this.requestId,
    required this.driverId,
    required this.driverName,
    required this.type,
    required this.status,
    required this.reason,
    required this.fromDate,
    required this.toDate,
    required this.submittedAt,
    required this.reviewedAt,
    this.auFileBase64 = '',
    this.auFilename = '',
    this.auMimeType = '',
  });

  bool get hasAuFile => auFileBase64.trim().isNotEmpty;

  factory _AbsenceAdminItem.fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final fromDate = _toDate(data['fromDate']) ?? DateTime.now();
    final toDate = _toDate(data['toDate']) ?? fromDate;
    final submittedAt = _toDate(data['submittedAt']) ?? fromDate;

    return _AbsenceAdminItem(
      requestId: doc.id,
      driverId: _stringOf(data['driverTransporterId']).toUpperCase(),
      driverName: _firstNonEmpty([
        _stringOf(data['driverName']),
        _stringOf(data['driverTransporterId']).toUpperCase(),
      ]),
      type: _stringOf(data['type']).toLowerCase(),
      status: _stringOf(data['status']).toLowerCase().isEmpty
          ? 'pending'
          : _stringOf(data['status']).toLowerCase(),
      reason: _stringOf(data['reason']),
      fromDate: fromDate,
      toDate: toDate,
      submittedAt: submittedAt,
      reviewedAt: _toDate(data['reviewedAt']),
      auFileBase64: _stringOf(data['auFileBase64']),
      auFilename: _stringOf(data['auFilename']),
      auMimeType: _stringOf(data['auMimeType']),
    );
  }

  String get typeLabel {
    switch (type) {
      case 'sick_leave':
        return 'Sick leave';
      case 'special_leave':
        return 'Special leave';
      default:
        return 'Vacation';
    }
  }

  int get totalDays {
    final start = DateTime(fromDate.year, fromDate.month, fromDate.day);
    final end = DateTime(toDate.year, toDate.month, toDate.day);
    if (end.isBefore(start)) return 0;
    return end.difference(start).inDays + 1;
  }

  String get daysLabel => totalDays == 1 ? '1 day' : '$totalDays days';

  String get fromDateText => DateFormat('dd.MM.yyyy').format(fromDate);
  String get toDateText => DateFormat('dd.MM.yyyy').format(toDate);
  String get submittedAtText => DateFormat('dd.MM.yyyy').format(submittedAt);

  String get reviewLine {
    final when = reviewedAt ?? submittedAt;
    final prefix = status == 'approved'
        ? 'Approved'
        : status == 'rejected'
        ? 'Rejected'
        : 'Submitted';
    return '$prefix on ${DateFormat('dd.MM.yyyy').format(when)}';
  }

  static DateTime? _toDate(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    if (raw is String && raw.trim().isNotEmpty) {
      return DateTime.tryParse(raw.trim());
    }
    return null;
  }

  static String _stringOf(dynamic value) => value?.toString().trim() ?? '';

  static String _firstNonEmpty(List<String> values) {
    for (final value in values) {
      if (value.trim().isNotEmpty) return value.trim();
    }
    return '';
  }
}

class _DriverOption {
  final String driverId;
  final String driverName;

  const _DriverOption({
    required this.driverId,
    required this.driverName,
  });
}

/// Compact AU-Bescheinigung pill — green "AU vorhanden" + open icon
/// when uploaded, red "AU fehlt" when missing. Tap-to-open opens the
/// base64 in a new tab (web) or share-sheet (mobile) via a data: URL.
class _AuPill extends StatelessWidget {
  const _AuPill({required this.item});
  final _AbsenceAdminItem item;

  Future<void> _openAu(BuildContext context) async {
    if (!item.hasAuFile) return;
    final mime = item.auMimeType.trim().isNotEmpty
        ? item.auMimeType.trim()
        : 'application/pdf';
    try {
      final uri = Uri.parse('data:$mime;base64,${item.auFileBase64}');
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('AU konnte nicht geöffnet werden: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final present = item.hasAuFile;
    final bg = present ? const Color(0xFFE7F5EE) : const Color(0xFFFEE2E2);
    final fg = present ? const Color(0xFF166534) : const Color(0xFFB91C1C);
    final icon = present
        ? Icons.medical_services_rounded
        : Icons.warning_amber_rounded;
    final label = present ? 'AU vorhanden' : 'AU fehlt';
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
          if (present) ...[
            const SizedBox(width: 6),
            Icon(Icons.open_in_new_rounded, size: 13, color: fg),
          ],
        ],
      ),
    );
    if (!present) return child;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () => _openAu(context),
      child: child,
    );
  }
}

