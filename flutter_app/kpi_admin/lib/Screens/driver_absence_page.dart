import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../localization/app_localizations.dart';
import '../theme/app_button_style.dart';

class DriverAbsencePage extends StatefulWidget {
  final String dspUid;
  final String driverTransporterId;
  final VoidCallback onBack;

  const DriverAbsencePage({
    super.key,
    required this.dspUid,
    required this.driverTransporterId,
    required this.onBack,
  });

  @override
  State<DriverAbsencePage> createState() => _DriverAbsencePageState();
}

class _DriverAbsencePageState extends State<DriverAbsencePage> {
  static const double _defaultAnnualVacationDays = 20;

  final _reasonCtrl = TextEditingController();
  String _type = 'vacation';
  DateTime? _from;
  DateTime? _to;
  bool _saving = false;

  /// AU-Bescheinigung (Arbeitsunfähigkeitsbescheinigung) file, kept in
  /// memory until submit. Required for `_type == 'sick_leave'`.
  Uint8List? _auBytes;
  String _auFilename = '';
  String _auMime = '';

  String get _driverId => widget.driverTransporterId.toUpperCase().trim();

  DocumentReference<Map<String, dynamic>> get _driverRef {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.dspUid)
        .collection('drivers')
        .doc(_driverId);
  }

  CollectionReference<Map<String, dynamic>> _driverRequestsCol(
    String driverId,
  ) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.dspUid)
        .collection('drivers')
        .doc(driverId)
        .collection('absence_requests');
  }

  CollectionReference<Map<String, dynamic>> get _rootRequestsCol {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.dspUid)
        .collection('absence_requests');
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool from}) async {
    final initial = from
        ? (_from ?? DateTime.now())
        : (_to ?? _from ?? DateTime.now());
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 2),
      initialDate: initial,
    );
    if (selected == null || !mounted) return;

    setState(() {
      if (from) {
        _from = selected;
        if (_to != null && _to!.isBefore(selected)) {
          _to = selected;
        }
      } else {
        _to = selected;
      }
    });
  }

  Future<bool> _submit({required double availableVacationDays}) async {
    final auth = FirebaseAuth.instance.currentUser;
    final labels = _absenceLabels(context);

    if (auth == null) {
      _showSnack(labels.loginRequired, error: true);
      return false;
    }
    if (widget.dspUid.trim().isEmpty || _driverId.isEmpty) {
      _showSnack(labels.scopeMissing, error: true);
      return false;
    }
    if (_from == null || _to == null) {
      _showSnack(labels.pickDateValidation, error: true);
      return false;
    }
    if (_reasonCtrl.text.trim().isEmpty) {
      _showSnack(labels.reasonValidation, error: true);
      return false;
    }
    if (_type == 'vacation') {
      final requestedDays = _inclusiveDays(_from, _to).toDouble();
      if (requestedDays > availableVacationDays + 0.0001) {
        _showSnack(
          labels.vacationLimitExceeded(
            requested: _formatDaysValue(requestedDays),
            available: _formatDaysValue(availableVacationDays),
          ),
          error: true,
        );
        return false;
      }
    }
    if (_type == 'sick_leave' &&
        (_auBytes == null || _auBytes!.isEmpty)) {
      _showSnack(
        'AU-Bescheinigung ist Pflicht — bitte PDF oder Foto hochladen.',
        error: true,
      );
      return false;
    }

    setState(() => _saving = true);
    try {
      final db = FirebaseFirestore.instance;
      final driverSnap = await _driverRef.get();
      final driverData = driverSnap.data() ?? const <String, dynamic>{};
      final driverName = _firstNonEmpty([
        _stringOf(driverData['name']),
        _stringOf(driverData['fullName']),
        _stringOf(driverData['driverName']),
      ]);

      final rootRef = _rootRequestsCol.doc();
      final requestId = rootRef.id;
      final payload = <String, dynamic>{
        'requestId': requestId,
        'dspUid': widget.dspUid,
        'driverUid': auth.uid,
        'driverTransporterId': _driverId,
        'driverName': driverName,
        'type': _type,
        'fromDate': Timestamp.fromDate(_from!),
        'toDate': Timestamp.fromDate(_to!),
        'reason': _reasonCtrl.text.trim(),
        'status': 'pending',
        'submittedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        if (_type == 'sick_leave' && _auBytes != null) ...{
          'auFileBase64': base64Encode(_auBytes!),
          'auFilename': _auFilename,
          'auMimeType': _auMime,
        },
      };

      final driverDocRef = _driverRequestsCol(_driverId).doc(requestId);
      final batch = db.batch();
      batch.set(rootRef, payload, SetOptions(merge: true));
      batch.set(driverDocRef, payload, SetOptions(merge: true));
      await batch.commit();

      if (!mounted) return false;
      setState(() {
        _type = 'vacation';
        _from = null;
        _to = null;
        _reasonCtrl.clear();
        _auBytes = null;
        _auFilename = '';
        _auMime = '';
      });
      _showSnack(labels.submitSuccess);
      return true;
    } catch (e) {
      _showSnack(labels.submitFailed(e), error: true);
      return false;
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _openRequestSheet(double availableVacationDays) async {
    final labels = _absenceLabels(context);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> pickForSheet({required bool from}) async {
              await _pickDate(from: from);
              if (!mounted) return;
              setSheetState(() {});
            }

            Future<void> submitFromSheet() async {
              final navigator = Navigator.of(sheetContext);
              final success = await _submit(
                availableVacationDays: availableVacationDays,
              );
              if (!mounted || !success) return;
              if (navigator.canPop()) {
                navigator.pop();
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          labels.requestSheetTitle,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_type == 'vacation') ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFED7AA)),
                        ),
                        child: Text(
                          labels.availableVacationHint(
                            _formatDaysValue(availableVacationDays),
                          ),
                          style: const TextStyle(
                            color: Color(0xFF9A3412),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    DropdownButtonFormField<String>(
                      initialValue: _type,
                      decoration: InputDecoration(
                        labelText: labels.typeLabel,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'vacation',
                          child: Text(labels.vacationType),
                        ),
                        DropdownMenuItem(
                          value: 'sick_leave',
                          child: Text(labels.sickLeaveType),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _type = value);
                        setSheetState(() {});
                      },
                    ),
                    const SizedBox(height: 12),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      child: _type == 'sick_leave'
                          ? _AuUploadSection(
                              bytes: _auBytes,
                              filename: _auFilename,
                              onPick: () async {
                                final res = await FilePicker.platform.pickFiles(
                                  type: FileType.custom,
                                  allowedExtensions: const [
                                    'pdf', 'png', 'jpg', 'jpeg', 'heic',
                                  ],
                                  withData: true,
                                );
                                if (res == null || res.files.isEmpty) return;
                                final f = res.files.first;
                                if (f.bytes == null) return;
                                // Firestore-Dokumente sind auf ~1 MB
                                // limitiert. base64 fügt ~33 % hinzu,
                                // also blocken wir bei > 700 KB Rohgröße.
                                const maxBytes = 700 * 1024;
                                if (f.bytes!.lengthInBytes > maxBytes) {
                                  _showSnack(
                                    'Datei zu groß (max. 700 KB). Bitte als Foto neu '
                                    'aufnehmen oder PDF komprimieren.',
                                    error: true,
                                  );
                                  return;
                                }
                                setState(() {
                                  _auBytes = f.bytes;
                                  _auFilename = f.name;
                                  final ext =
                                      f.extension?.toLowerCase() ?? '';
                                  _auMime = ext == 'pdf'
                                      ? 'application/pdf'
                                      : ext == 'png'
                                          ? 'image/png'
                                          : ext == 'heic'
                                              ? 'image/heic'
                                              : 'image/jpeg';
                                });
                                setSheetState(() {});
                              },
                              onClear: () {
                                setState(() {
                                  _auBytes = null;
                                  _auFilename = '';
                                  _auMime = '';
                                });
                                setSheetState(() {});
                              },
                            )
                          : const SizedBox(width: double.infinity),
                    ),
                    if (_type == 'sick_leave') const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => pickForSheet(from: true),
                            icon: const Icon(Icons.event_available_outlined),
                            label: Text('${labels.fromLabel}: ${_date(_from)}'),
                            style: AppButtonStyle.of(
                              AppButtonVariant.subtle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => pickForSheet(from: false),
                            icon: const Icon(Icons.event_outlined),
                            label: Text('${labels.toLabel}: ${_date(_to)}'),
                            style: AppButtonStyle.of(
                              AppButtonVariant.subtle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _reasonCtrl,
                      minLines: 3,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: labels.reasonLabel,
                        hintText: labels.reasonHint,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saving ? null : submitFromSheet,
                        icon: _saving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send_rounded),
                        label: Text(
                          _saving ? labels.submittingLabel : labels.submitLabel,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7A18),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final labels = _absenceLabels(context);

    if (widget.dspUid.trim().isEmpty || _driverId.isEmpty) {
      return Center(
        child: Text(
          labels.scopeMissing,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _driverRef.snapshots(),
      builder: (context, driverSnap) {
        final driverData = driverSnap.data?.data() ?? const <String, dynamic>{};
        final workStartDate = _workStartDateFromDriver(driverData);

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _driverRequestsCol(
            _driverId,
          ).orderBy('fromDate', descending: true).snapshots(),
          builder: (context, requestsSnap) {
            if (driverSnap.connectionState == ConnectionState.waiting ||
                requestsSnap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (requestsSnap.hasError) {
              return Center(
                child: Text(
                  labels.loadFailed(requestsSnap.error),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            }

            final docs = requestsSnap.data?.docs ?? const [];
            final annualVacationDays = _annualVacationDaysFromDriver(
              driverData,
            );
            final overview = _buildOverview(
              docs,
              workStartDate,
              annualVacationDays,
            );
            final vacationCards = _buildVacationCards(docs);

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 20),
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      labels.pageEyebrow.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.3,
                      ),
                    ),
                    const SizedBox(height: 18),
                    InkWell(
                      onTap: widget.onBack,
                      borderRadius: BorderRadius.circular(999),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 18,
                              color: Color(0xFF64748B),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              t.t('back'),
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _InfoCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.work_outline_rounded,
                            color: Color(0xFF6B7280),
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t
                                      .t('drivers_hub_field_work_start_date')
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    color: Color(0xFF8A94A6),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _date(workStartDate),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${_formatDaysValue(annualVacationDays)} ${labels.daysPerYear}',
                            style: const TextStyle(
                              color: Color(0xFF8A94A6),
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _InfoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.spa_outlined,
                                color: Color(0xFFFF7A18),
                                size: 24,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                labels.overviewTitle,
                                style: const TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  labels.takenLabel,
                                  style: const TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Text(
                                '${_formatDaysValue(overview.takenDays)} ${labels.ofWord} ${_formatDaysValue(overview.totalDays)} ${labels.daysLabel}',
                                style: const TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: overview.progress,
                              minHeight: 18,
                              backgroundColor: const Color(0xFFE9ECEF),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFFF7A18),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: _SummaryTile(
                                  value: _formatDaysValue(overview.totalDays),
                                  label: labels.totalLabel,
                                  valueColor: const Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _SummaryTile(
                                  value: _formatDaysValue(overview.specialDays),
                                  label: labels.specialLabel,
                                  valueColor: const Color(0xFF3B82F6),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _SummaryTile(
                                  value: _formatDaysValue(overview.takenDays),
                                  label: labels.takenLabel,
                                  valueColor: const Color(0xFFFF7A18),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _SummaryTile(
                                  value: _formatDaysValue(
                                    overview.remainingDays,
                                  ),
                                  label: labels.availableVacationLabel,
                                  valueColor: const Color(0xFF22C55E),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _openRequestSheet(overview.remainingDays),
                        icon: const Icon(Icons.add_rounded),
                        label: Text(labels.requestButton),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7A18),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      labels.periodsTitle,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (vacationCards.isEmpty)
                      _InfoCard(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            labels.emptyVacationList,
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    for (final item in vacationCards) ...[
                      _VacationPeriodCard(item: item, labels: labels),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  _VacationOverview _buildOverview(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    DateTime? workStartDate,
    double annualVacationDays,
  ) {
    final now = DateTime.now();
    final approvedVacationDays = docs.fold<double>(0, (total, doc) {
      final data = doc.data();
      final type = _stringOf(data['type']).toLowerCase();
      final status = _stringOf(data['status']).toLowerCase();
      if (type != 'vacation' || status != 'approved') return total;
      return total +
          _inclusiveDays(
            _toDate(data['fromDate']),
            _toDate(data['toDate']),
          ).toDouble();
    });

    final approvedSpecialDays = docs.fold<double>(0, (total, doc) {
      final data = doc.data();
      final type = _stringOf(data['type']).toLowerCase();
      final status = _stringOf(data['status']).toLowerCase();
      if (type != 'special_leave' || status != 'approved') return total;
      return total +
          _inclusiveDays(
            _toDate(data['fromDate']),
            _toDate(data['toDate']),
          ).toDouble();
    });

    final completedMonths = workStartDate == null
        ? 12
        : _completedMonthsSince(workStartDate, now);
    final accruedVacationDays = workStartDate == null
        ? annualVacationDays
        : (annualVacationDays / 12.0) * completedMonths;
    final totalDays = math.max(
      accruedVacationDays + approvedSpecialDays,
      approvedVacationDays,
    );
    final remainingDays = math.max(totalDays - approvedVacationDays, 0.0);
    final progress = totalDays <= 0
        ? 0.0
        : (approvedVacationDays / totalDays).clamp(0.0, 1.0);

    return _VacationOverview(
      totalDays: totalDays,
      specialDays: approvedSpecialDays,
      takenDays: approvedVacationDays,
      remainingDays: remainingDays,
      progress: progress,
    );
  }

  List<_VacationPeriodItem> _buildVacationCards(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final items = <_VacationPeriodItem>[];

    for (final doc in docs) {
      final data = doc.data();
      final type = _stringOf(data['type']).toLowerCase();
      final status = _stringOf(data['status']).toLowerCase();
      if (type != 'vacation' || status == 'rejected') continue;

      final from = _toDate(data['fromDate']);
      final to = _toDate(data['toDate']);
      if (from == null || to == null) continue;

      items.add(
        _VacationPeriodItem(
          from: from,
          to: to,
          days: _inclusiveDays(from, to),
          status: status.isEmpty ? 'pending' : status,
        ),
      );
    }

    items.sort((a, b) => b.from.compareTo(a.from));
    return items;
  }

  Widget _statusChip(String status) {
    final t = AppLocalizations.of(context);
    final s = status.toLowerCase().trim();
    Color fg;
    Color bg;
    String label;

    if (s == 'approved') {
      fg = const Color(0xFF1D7F5A);
      bg = const Color(0xFFE4F5EC);
      label = t.t('drivers_hub_status_approved');
    } else if (s == 'rejected') {
      fg = const Color(0xFFB91C1C);
      bg = const Color(0xFFFEE2E2);
      label = t.t('drivers_hub_status_rejected');
    } else {
      fg = const Color(0xFF8A6200);
      bg = const Color(0xFFFEF3C7);
      label = t.t('drivers_hub_status_pending');
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w900),
      ),
    );
  }

  DateTime? _workStartDateFromDriver(Map<String, dynamic> data) {
    final onboarding = data['onboarding'];
    if (onboarding is Map) {
      final typed = Map<String, dynamic>.from(onboarding);
      final parsed = _toDate(typed['workStartDate']);
      if (parsed != null) return parsed;
    }
    return _toDate(data['workStartDate']);
  }

  double _annualVacationDaysFromDriver(Map<String, dynamic> data) {
    final onboarding = data['onboarding'];
    if (onboarding is Map) {
      final typed = Map<String, dynamic>.from(onboarding);
      final parsed = _toDouble(typed['annualVacationDays']);
      if (parsed != null && parsed > 0) return parsed;
    }
    final fallback = _toDouble(data['annualVacationDays']);
    if (fallback != null && fallback > 0) return fallback;
    return _defaultAnnualVacationDays;
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

  _AbsenceLabels _absenceLabels(BuildContext context) {
    final t = AppLocalizations.of(context);
    return _AbsenceLabels(
      pageEyebrow: t.t('driver_absence_page_eyebrow'),
      overviewTitle: t.t('driver_absence_overview_title'),
      periodsTitle: t.t('driver_absence_periods_title'),
      totalLabel: t.t('driver_absence_total_label'),
      specialLabel: t.t('driver_absence_special_label'),
      takenLabel: t.t('driver_absence_taken_label'),
      availableVacationLabel: t.t('driver_absence_available_vacation_label'),
      startLabel: t.t('driver_absence_start_label'),
      endLabel: t.t('driver_absence_end_label'),
      daysLabel: t.t('driver_absence_days_label'),
      dayLabel: t.t('driver_absence_day_label'),
      daysPerYear: t.t('driver_absence_days_per_year'),
      ofWord: t.t('driver_absence_of_word'),
      requestButton: t.t('driver_absence_request_button'),
      requestSheetTitle: t.t('driver_absence_request_sheet_title'),
      typeLabel: t.t('driver_absence_type_label'),
      vacationType: t.t('driver_absence_vacation_type'),
      sickLeaveType: t.t('driver_absence_sick_leave_type'),
      fromLabel: t.t('driver_absence_from_label'),
      toLabel: t.t('driver_absence_to_label'),
      reasonLabel: t.t('driver_absence_reason_label'),
      reasonHint: t.t('driver_absence_reason_hint'),
      submitLabel: t.t('driver_absence_submit_label'),
      submittingLabel: t.t('driver_absence_submitting_label'),
      emptyVacationList: t.t('driver_absence_empty_vacation_list'),
      submitSuccess: t.t('driver_absence_submit_success'),
      loginRequired: t.t('driver_absence_login_required'),
      scopeMissing: t.t('driver_absence_scope_missing'),
      pickDateValidation: t.t('driver_absence_pick_date_validation'),
      reasonValidation: t.t('driver_absence_reason_validation'),
      availableVacationHintLabel: t.t(
        'driver_absence_available_vacation_hint_label',
      ),
      vacationLimitExceededTemplate: t.t(
        'driver_absence_vacation_limit_exceeded_template',
      ),
      submitFailedTemplate: t.t('driver_absence_submit_failed_template'),
      loadFailedTemplate: t.t('driver_absence_load_failed_template'),
    );
  }

  String _date(DateTime? value) {
    if (value == null) return '--.--.----';
    return DateFormat('dd.MM.yyyy').format(value);
  }

  String _formatDaysValue(double value) {
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    return NumberFormat('0.##', localeTag).format(value);
  }

  static int _inclusiveDays(DateTime? from, DateTime? to) {
    if (from == null || to == null) return 0;
    final start = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day);
    if (end.isBefore(start)) return 0;
    return end.difference(start).inDays + 1;
  }

  static DateTime? _toDate(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    if (raw is String && raw.trim().isNotEmpty) {
      final value = raw.trim();
      final slashMatch = RegExp(r'^(\d{1,2})\/(\d{1,2})\/(\d{4})$');
      final match = slashMatch.firstMatch(value);
      if (match != null) {
        final day = int.tryParse(match.group(1)!);
        final month = int.tryParse(match.group(2)!);
        final year = int.tryParse(match.group(3)!);
        if (day != null && month != null && year != null) {
          return DateTime(year, month, day);
        }
      }
      return DateTime.tryParse(value);
    }
    return null;
  }

  static int _completedMonthsSince(DateTime start, DateTime now) {
    final safeStart = DateTime(start.year, start.month, start.day);
    final safeNow = DateTime(now.year, now.month, now.day);
    var months =
        (safeNow.year - safeStart.year) * 12 +
        (safeNow.month - safeStart.month);
    if (safeNow.day < safeStart.day) {
      months -= 1;
    }
    return math.max(months, 0);
  }

  static double? _toDouble(dynamic raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String && raw.trim().isNotEmpty) {
      return double.tryParse(raw.trim().replaceAll(',', '.'));
    }
    return null;
  }

  static String _stringOf(dynamic value) => value?.toString().trim() ?? '';

  static String _firstNonEmpty(List<String> values) {
    for (final raw in values) {
      final value = raw.trim();
      if (value.isNotEmpty) return value;
    }
    return '';
  }
}

class _InfoCard extends StatelessWidget {
  final Widget child;

  const _InfoCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE4E8EE)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x110F172A),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: child,
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;

  const _SummaryTile({
    required this.value,
    required this.label,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 118,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F8),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _VacationPeriodCard extends StatelessWidget {
  final _VacationPeriodItem item;
  final _AbsenceLabels labels;

  const _VacationPeriodCard({required this.item, required this.labels});

  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_DriverAbsencePageState>();
    final showStatus = item.status != 'approved';

    return _InfoCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _DateColumn(
                        label: labels.startLabel,
                        value: state?._date(item.from) ?? '',
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 18),
                      child: Text(
                        '–',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _DateColumn(
                        label: labels.endLabel,
                        value: state?._date(item.to) ?? '',
                      ),
                    ),
                  ],
                ),
                if (showStatus) ...[
                  const SizedBox(height: 12),
                  state?._statusChip(item.status) ?? const SizedBox.shrink(),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 78,
            height: 86,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1E8),
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${item.days}',
                  style: const TextStyle(
                    color: Color(0xFFFF7A18),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.days == 1 ? labels.dayLabel : labels.daysLabel,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
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

class _DateColumn extends StatelessWidget {
  final String label;
  final String value;

  const _DateColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF8A94A6),
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _VacationOverview {
  final double totalDays;
  final double specialDays;
  final double takenDays;
  final double remainingDays;
  final double progress;

  const _VacationOverview({
    required this.totalDays,
    required this.specialDays,
    required this.takenDays,
    required this.remainingDays,
    required this.progress,
  });
}

class _VacationPeriodItem {
  final DateTime from;
  final DateTime to;
  final int days;
  final String status;

  const _VacationPeriodItem({
    required this.from,
    required this.to,
    required this.days,
    required this.status,
  });
}

class _AbsenceLabels {
  final String pageEyebrow;
  final String overviewTitle;
  final String periodsTitle;
  final String totalLabel;
  final String specialLabel;
  final String takenLabel;
  final String availableVacationLabel;
  final String startLabel;
  final String endLabel;
  final String daysLabel;
  final String dayLabel;
  final String daysPerYear;
  final String ofWord;
  final String requestButton;
  final String requestSheetTitle;
  final String typeLabel;
  final String vacationType;
  final String sickLeaveType;
  final String fromLabel;
  final String toLabel;
  final String reasonLabel;
  final String reasonHint;
  final String submitLabel;
  final String submittingLabel;
  final String emptyVacationList;
  final String submitSuccess;
  final String loginRequired;
  final String scopeMissing;
  final String pickDateValidation;
  final String reasonValidation;
  final String availableVacationHintLabel;
  final String vacationLimitExceededTemplate;
  final String submitFailedTemplate;
  final String loadFailedTemplate;

  const _AbsenceLabels({
    required this.pageEyebrow,
    required this.overviewTitle,
    required this.periodsTitle,
    required this.totalLabel,
    required this.specialLabel,
    required this.takenLabel,
    required this.availableVacationLabel,
    required this.startLabel,
    required this.endLabel,
    required this.daysLabel,
    required this.dayLabel,
    required this.daysPerYear,
    required this.ofWord,
    required this.requestButton,
    required this.requestSheetTitle,
    required this.typeLabel,
    required this.vacationType,
    required this.sickLeaveType,
    required this.fromLabel,
    required this.toLabel,
    required this.reasonLabel,
    required this.reasonHint,
    required this.submitLabel,
    required this.submittingLabel,
    required this.emptyVacationList,
    required this.submitSuccess,
    required this.loginRequired,
    required this.scopeMissing,
    required this.pickDateValidation,
    required this.reasonValidation,
    required this.availableVacationHintLabel,
    required this.vacationLimitExceededTemplate,
    required this.submitFailedTemplate,
    required this.loadFailedTemplate,
  });

  String submitFailed(Object error) =>
      submitFailedTemplate.replaceAll('{error}', '$error');
  String loadFailed(Object? error) =>
      loadFailedTemplate.replaceAll('{error}', '$error');
  String availableVacationHint(String available) =>
      '$availableVacationHintLabel: $available';
  String vacationLimitExceeded({
    required String requested,
    required String available,
  }) {
    return vacationLimitExceededTemplate
        .replaceAll('{requested}', requested)
        .replaceAll('{available}', available);
  }
}

/// Driver-side AU-Bescheinigung upload card. Required for sick leave;
/// the parent form's `_submit` blocks until a file is attached. Uses
/// the canonical orange-accent (matches the sheet's submit button)
/// when empty, green-checkmark layout when a file is selected.
class _AuUploadSection extends StatelessWidget {
  const _AuUploadSection({
    required this.bytes,
    required this.filename,
    required this.onPick,
    required this.onClear,
  });

  final Uint8List? bytes;
  final String filename;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final hasFile = bytes != null && bytes!.isNotEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: BoxDecoration(
        color: hasFile
            ? const Color(0xFFE7F5EE)
            : const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hasFile
              ? const Color(0xFF86EFAC)
              : const Color(0xFFFED7AA),
          width: hasFile ? 1.4 : 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasFile
                    ? Icons.check_circle_rounded
                    : Icons.medical_services_outlined,
                size: 18,
                color: hasFile
                    ? const Color(0xFF166534)
                    : const Color(0xFF9A3412),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hasFile
                      ? 'AU-Bescheinigung hochgeladen'
                      : 'AU-Bescheinigung (Pflicht)',
                  style: TextStyle(
                    color: hasFile
                        ? const Color(0xFF166534)
                        : const Color(0xFF9A3412),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            hasFile
                ? filename.isNotEmpty
                    ? filename
                    : 'Datei bereit zum Senden.'
                : 'Bitte lade die AU als PDF oder Foto hoch. Ohne AU kann die Krankmeldung nicht eingereicht werden.',
            style: TextStyle(
              color: hasFile
                  ? const Color(0xFF166534)
                  : const Color(0xFF9A3412),
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPick,
                  icon: Icon(
                    hasFile
                        ? Icons.swap_horiz_rounded
                        : Icons.upload_file_rounded,
                    size: 18,
                  ),
                  label: Text(
                    hasFile ? 'Andere Datei' : 'Datei wählen',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: hasFile
                        ? const Color(0xFF166534)
                        : const Color(0xFF9A3412),
                    side: BorderSide(
                      color: hasFile
                          ? const Color(0xFF86EFAC)
                          : const Color(0xFFFED7AA),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              if (hasFile) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onClear,
                  icon: const Icon(Icons.close_rounded),
                  color: const Color(0xFF166534),
                  tooltip: 'Entfernen',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
