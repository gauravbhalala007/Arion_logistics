// lib/screens/drivers_hub_page.dart
import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_storage/firebase_storage.dart' as fb;

import '../localization/app_localizations.dart';
import '../services/driver_csv.dart';
import '../widgets/web_preview.dart'
    if (dart.library.html) '../widgets/web_preview_web.dart';
import '../widgets/notification_pin_dialogs.dart';

// Keep this out of source control by passing --dart-define=DEFAULT_DRIVER_PASSWORD=...
const String kDefaultDriverPassword = String.fromEnvironment(
  'DEFAULT_DRIVER_PASSWORD',
  defaultValue: 'Pommersfelden2024!',
);

enum _DriverSort {
  newest,
  oldest,
  nameAsc,
  nameDesc,
  idAsc,
  pending,
  approved,
  rejected,
}

class _DriverOverallScoreData {
  const _DriverOverallScoreData({
    required this.averageScore,
    required this.weeksCount,
  });

  final double averageScore;
  final int weeksCount;
}

class DriversHubPage extends StatefulWidget {
  const DriversHubPage({super.key});

  @override
  State<DriversHubPage> createState() => _DriversHubPageState();
}

class _DriversHubPageState extends State<DriversHubPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get _user => _auth.currentUser;
  String? get _uid => _user?.uid;

  bool _busyCsv = false;
  bool _busyList = false;

  // 🔹 New: bulk/default password controller + bulk action busy flag
  final TextEditingController _bulkPwdCtrl = TextEditingController(
    text: kDefaultDriverPassword,
  );
  bool _busyBulkLogins = false;
  final Set<String> _expandedWeeklySummaries = <String>{};
  // 🔹 New: visibility toggle for default password field
  bool _bulkPwdVisible = false;
  bool _defaultPwdLoaded = false;
  bool _loadingDefaultPwd = false;
  Timer? _defaultPwdSaveDebounce;

  String _search = '';
  _DriverSort _driverSort = _DriverSort.newest;

  String _driverSortLabel(_DriverSort s) {
    final t = AppLocalizations.of(context);
    switch (s) {
      case _DriverSort.newest:
        return t.t('drivers_hub_sort_newest');
      case _DriverSort.oldest:
        return t.t('drivers_hub_sort_oldest');
      case _DriverSort.nameAsc:
        return t.t('drivers_hub_sort_name_asc');
      case _DriverSort.nameDesc:
        return t.t('drivers_hub_sort_name_desc');
      case _DriverSort.idAsc:
        return t.t('drivers_hub_sort_id_asc');
      case _DriverSort.pending:
        return t.t('drivers_hub_sort_pending');
      case _DriverSort.approved:
        return t.t('drivers_hub_sort_approved');
      case _DriverSort.rejected:
        return t.t('drivers_hub_sort_rejected');
    }
  }

  @override
  void initState() {
    super.initState();
    _bulkPwdCtrl.addListener(_onDefaultPasswordChanged);
  }

  @override
  void dispose() {
    _defaultPwdSaveDebounce?.cancel();
    unawaited(_persistDefaultDriverPassword());
    _bulkPwdCtrl.removeListener(_onDefaultPasswordChanged);
    _bulkPwdCtrl.dispose();
    super.dispose();
  }

  void _onDefaultPasswordChanged() {
    if (!_defaultPwdLoaded) return;
    _defaultPwdSaveDebounce?.cancel();
    _defaultPwdSaveDebounce = Timer(const Duration(milliseconds: 450), () {
      _persistDefaultDriverPassword();
    });
  }

  Future<void> _loadDefaultDriverPasswordOnce() async {
    if (_defaultPwdLoaded || _loadingDefaultPwd) return;
    final uid = _uid;
    if (uid == null) return;

    _loadingDefaultPwd = true;
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final data = snap.data();
      final saved = (data?['defaultDriverPassword'] ?? '').toString().trim();
      if (saved.isNotEmpty) {
        _bulkPwdCtrl.text = saved;
      }
    } catch (_) {
      // Keep local fallback when read fails.
    } finally {
      _loadingDefaultPwd = false;
      _defaultPwdLoaded = true;
    }
  }

  Future<void> _persistDefaultDriverPassword() async {
    final uid = _uid;
    if (uid == null) return;

    final password = _bulkPwdCtrl.text.trim();
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'defaultDriverPassword': password,
      }, SetOptions(merge: true));
    } catch (e) {
      if (!mounted) return;
      final t = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t.tf('drivers_hub_failed_save_default_password', {'error': '$e'}),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _loadDefaultDriverPasswordOnce();
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          Expanded(child: _buildDriversList()),
        ],
      ),
    );
  }

  // ---------- Common pill-shaped text field decoration ----------
  InputDecoration _pillInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(999),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(999),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(999),
        borderSide: const BorderSide(color: Color(0xFF2563EB)),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ADMIN: Inline edit any onboarding field (pencil icon per row)
  // ---------------------------------------------------------------------------

  Future<void> _adminEditField({
    required DocumentReference<Map<String, dynamic>> driverRef,
    required String label,
    required String fieldKey,
    required String initialValue,
    bool isDate = false,
    bool isNumeric = false,
  }) async {
    final t = AppLocalizations.of(context);
    String _formatDate(DateTime d) {
      final day = d.day.toString().padLeft(2, '0');
      final m = d.month.toString().padLeft(2, '0');
      final y = d.year.toString().padLeft(4, '0');
      return '$day/$m/$y';
    }

    DateTime? _parseDate(String text) {
      final cleaned = text.trim();
      if (cleaned.isEmpty) return null;
      final slashMatch = RegExp(r'^(\d{1,2})\/(\d{1,2})\/(\d{4})$');
      final match = slashMatch.firstMatch(cleaned);
      if (match != null) {
        final d = int.tryParse(match.group(1)!);
        final m = int.tryParse(match.group(2)!);
        final y = int.tryParse(match.group(3)!);
        if (d != null && m != null && y != null) {
          return DateTime(y, m, d);
        }
      }
      try {
        return DateTime.parse(cleaned);
      } catch (_) {
        return null;
      }
    }

    String _normalizeDateText(String text) {
      final parsed = _parseDate(text);
      return parsed == null ? text : _formatDate(parsed);
    }

    num? _parseNumber(String text) {
      final normalized = text.trim().replaceAll(',', '.');
      if (normalized.isEmpty) return null;
      return num.tryParse(normalized);
    }

    DateTime _parseExistingOrNow(String text) {
      return _parseDate(text) ?? DateTime.now();
    }

    final ctrl = TextEditingController(
      text: isDate ? _normalizeDateText(initialValue) : initialValue,
    );

    Future<void> _pickDate() async {
      final initial = _parseExistingOrNow(ctrl.text);
      final picked = await showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: DateTime(1900),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        ctrl.text = _formatDate(picked);
      }
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.tf('drivers_hub_edit_label', {'label': label})),
        content: SizedBox(
          width: 520,
          child: TextFormField(
            controller: ctrl,
            readOnly: isDate,
            keyboardType: isNumeric
                ? const TextInputType.numberWithOptions(decimal: true)
                : null,
            decoration: InputDecoration(
              labelText: label,
              hintText: isDate ? t.t('drivers_hub_date_format_hint') : null,
              border: const OutlineInputBorder(),
              suffixIcon: isDate
                  ? IconButton(
                      icon: const Icon(Icons.calendar_today_outlined, size: 18),
                      onPressed: _pickDate,
                    )
                  : null,
            ),
            onTap: isDate ? _pickDate : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(t.t('admin_home_cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(t.t('button_save')),
          ),
        ],
      ),
    );

    if (ok != true) {
      ctrl.dispose();
      return;
    }

    try {
      final rawValue = ctrl.text.trim();
      dynamic storedValue = rawValue;
      if (isNumeric) {
        final parsed = _parseNumber(rawValue);
        if (parsed != null) {
          storedValue = parsed % 1 == 0 ? parsed.toInt() : parsed.toDouble();
        }
      }

      await driverRef.set({
        'onboarding': {fieldKey: storedValue},
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.tf('drivers_hub_label_updated', {'label': label})),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t.tf('drivers_hub_failed_update_label', {
              'label': label,
              'error': '$e',
            }),
          ),
        ),
      );
    } finally {
      ctrl.dispose();
    }
  }

  String _normalizeWorkPermitType(dynamic raw, {dynamic fallbackExpiry}) {
    final value = (raw ?? '').toString().trim().toLowerCase();
    if (value.isEmpty) {
      final hasLegacyExpiry = (fallbackExpiry ?? '')
          .toString()
          .trim()
          .isNotEmpty;
      return hasLegacyExpiry ? 'working_visa' : 'eu';
    }
    if (value == 'eu' || value == 'permit_eu_id' || value == 'eu_id') {
      return 'eu';
    }
    if (value == 'working_visa' ||
        value == 'work_visa' ||
        value == 'permit_work_visa' ||
        value == 'visa') {
      return 'working_visa';
    }
    return value;
  }

  bool _isWorkingVisaPermitType(dynamic raw, {dynamic fallbackExpiry}) {
    return _normalizeWorkPermitType(raw, fallbackExpiry: fallbackExpiry) ==
        'working_visa';
  }

  String _workPermitTypeLabel(
    AppLocalizations t,
    dynamic raw, {
    dynamic fallbackExpiry,
  }) {
    switch (_normalizeWorkPermitType(raw, fallbackExpiry: fallbackExpiry)) {
      case 'working_visa':
        return t.t('drivers_hub_work_permit_working_visa');
      case 'eu':
      default:
        return t.t('drivers_hub_work_permit_eu');
    }
  }

  Future<void> _adminEditWorkPermitType({
    required DocumentReference<Map<String, dynamic>> driverRef,
    required dynamic initialValue,
    dynamic fallbackExpiry,
  }) async {
    final t = AppLocalizations.of(context);
    String selected = _normalizeWorkPermitType(
      initialValue,
      fallbackExpiry: fallbackExpiry,
    );

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.t('drivers_hub_field_work_permit_type')),
        content: SizedBox(
          width: 420,
          child: DropdownButtonFormField<String>(
            value: selected,
            decoration: InputDecoration(
              labelText: t.t('drivers_hub_field_work_permit_type'),
              border: const OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(
                value: 'eu',
                child: Text(t.t('drivers_hub_work_permit_eu')),
              ),
              DropdownMenuItem(
                value: 'working_visa',
                child: Text(t.t('drivers_hub_work_permit_working_visa')),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                selected = value;
              }
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(t.t('admin_home_cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(t.t('button_save')),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      final update = <String, dynamic>{'workPermitType': selected};
      if (selected == 'eu') {
        update['workVisaExpiry'] = '';
        update['zusatzblattExpiry'] = '';
      }

      await driverRef.set({
        'onboarding': update,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t.tf('drivers_hub_label_updated', {
              'label': t.t('drivers_hub_field_work_permit_type'),
            }),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t.tf('drivers_hub_failed_update_label', {
              'label': t.t('drivers_hub_field_work_permit_type'),
              'error': '$e',
            }),
          ),
        ),
      );
    }
  }

  // ---------- Reusable detail row with copy & edit button ----------
  String _formatDisplayDate(String raw) {
    final parsed = _parseIsoDate(raw);
    if (parsed == null) return raw;
    final day = parsed.day.toString().padLeft(2, '0');
    final month = parsed.month.toString().padLeft(2, '0');
    final year = parsed.year.toString().padLeft(4, '0');
    return '$day/$month/$year';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString().padLeft(4, '0');
    return '$day/$month/$year';
  }

  Widget _detailRowEditable({
    required DocumentReference<Map<String, dynamic>> driverRef,
    required String label,
    required dynamic value,
    required String fieldKey,
    bool isDate = false,
    bool isNumeric = false,
    String Function(String rawText)? displayValueBuilder,
    VoidCallback? onEdit,
  }) {
    final rawText = (value ?? '').toString();
    final displayText = displayValueBuilder != null
        ? displayValueBuilder(rawText)
        : (isDate ? _formatDisplayDate(rawText) : rawText);
    final hasText = displayText.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: SelectableText(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SelectableText(
                    hasText ? displayText : '—',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),

                // ✏️ Edit
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: AppLocalizations.of(
                    context,
                  ).tf('drivers_hub_edit_label', {'label': label}),
                  onPressed:
                      onEdit ??
                      () => _adminEditField(
                        driverRef: driverRef,
                        label: label,
                        fieldKey: fieldKey,
                        initialValue: rawText,
                        isDate: isDate,
                        isNumeric: isNumeric,
                      ),
                ),

                // 📋 Copy
                if (hasText) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 16),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: AppLocalizations.of(
                      context,
                    ).tf('drivers_hub_copy_label', {'label': label}),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: displayText));
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(
                              context,
                            ).tf('drivers_hub_label_copied', {'label': label}),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRowReadOnly({required String label, required String value}) {
    final hasText = value.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: SelectableText(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SelectableText(
                    hasText ? value : '—',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                if (hasText) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 16),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: AppLocalizations.of(
                      context,
                    ).tf('drivers_hub_copy_label', {'label': label}),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: value));
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(
                              context,
                            ).tf('drivers_hub_label_copied', {'label': label}),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _remainingVacationDaysRow({
    required DocumentReference<Map<String, dynamic>> driverRef,
    required Map<String, dynamic> onboarding,
  }) {
    final t = AppLocalizations.of(context);
    final annualVacationDays = _annualVacationDaysFromOnboarding(onboarding);
    final workStartDate = _dateFromDynamic(onboarding['workStartDate']);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: driverRef.collection('absence_requests').snapshots(),
      builder: (context, snap) {
        if (snap.hasError) {
          return _detailRowReadOnly(
            label: t.t('drivers_hub_field_remaining_vacation_days'),
            value: '—',
          );
        }

        if (snap.connectionState == ConnectionState.waiting) {
          return _detailRowReadOnly(
            label: t.t('drivers_hub_field_remaining_vacation_days'),
            value: '...',
          );
        }

        final approvedVacationDays = _approvedVacationDaysFromRequests(
          snap.data?.docs ??
              const <QueryDocumentSnapshot<Map<String, dynamic>>>[],
        );
        final now = DateTime.now();
        final accruedDays = workStartDate == null
            ? annualVacationDays
            : (annualVacationDays / 12.0) *
                  _completedMonthsSince(workStartDate, now);
        final remainingDays = accruedDays - approvedVacationDays;

        return _detailRowReadOnly(
          label: t.t('drivers_hub_field_remaining_vacation_days'),
          value: _formatVacationDays(remainingDays < 0 ? 0 : remainingDays),
        );
      },
    );
  }

  double _annualVacationDaysFromOnboarding(Map<String, dynamic> onboarding) {
    final raw = onboarding['annualVacationDays'];
    if (raw is num && raw > 0) return raw.toDouble();
    if (raw is String) {
      final parsed = num.tryParse(raw.trim().replaceAll(',', '.'));
      if (parsed != null && parsed > 0) return parsed.toDouble();
    }
    return 20;
  }

  DateTime? _dateFromDynamic(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    return _parseIsoDate(raw?.toString());
  }

  double _approvedVacationDaysFromRequests(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    var total = 0.0;
    for (final doc in docs) {
      final data = doc.data();
      final type = (data['type'] ?? '').toString().trim().toLowerCase();
      final status = (data['status'] ?? '').toString().trim().toLowerCase();
      if (type != 'vacation' || status != 'approved') continue;

      total += _inclusiveDays(
        _dateFromDynamic(data['fromDate']),
        _dateFromDynamic(data['toDate']),
      );
    }
    return total;
  }

  static int _inclusiveDays(DateTime? from, DateTime? to) {
    if (from == null || to == null) return 0;
    final start = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day);
    if (end.isBefore(start)) return 0;
    return end.difference(start).inDays + 1;
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
    return months < 0 ? 0 : months;
  }

  String _formatVacationDays(double value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  // ---------------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------------

  Widget _buildHeader() {
    final t = AppLocalizations.of(context);
    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 800;
    final isNarrow = width < 980;

    final importBtn = SizedBox(
      height: isSmall ? 32 : 36,
      child: FilledButton.icon(
        onPressed: _busyCsv ? null : _onImportCsv,
        icon: _busyCsv
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.file_upload_outlined, size: 18),
        label: Text(
          t.t('drivers_hub_import_csv'),
          style: TextStyle(fontSize: isSmall ? 12 : 14),
        ),
      ),
    );

    final addDriverBtn = SizedBox(
      height: isSmall ? 32 : 36,
      child: OutlinedButton.icon(
        onPressed: _busyList ? null : _createDriverManually,
        icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
        label: Text(
          t.t('drivers_hub_add_driver'),
          style: TextStyle(fontSize: isSmall ? 12 : 14),
        ),
      ),
    );

    if (isNarrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.t('drivers_hub_title'),
            style: TextStyle(
              fontSize: isSmall ? 20 : 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [importBtn, addDriverBtn],
          ),
        ],
      );
    }

    return Row(
      children: [
        Text(
          t.t('drivers_hub_title'),
          style: TextStyle(
            fontSize: isSmall ? 20 : 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        importBtn,
        const SizedBox(width: 12),
        addDriverBtn,
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // CSV import
  // ---------------------------------------------------------------------------

  Future<void> _onImportCsv() async {
    final t = AppLocalizations.of(context);
    if (_uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.t('drivers_hub_must_login_import_csv'))),
      );
      return;
    }

    setState(() => _busyCsv = true);
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );
      if (picked == null || picked.files.isEmpty) {
        return;
      }
      final f = picked.files.first;
      final Uint8List? bytes = f.bytes;
      if (bytes == null)
        throw Exception(t.t('scorecard_overview_no_file_bytes'));

      final importResult = await DriverCsvService.importForUser(
        uid: _uid!,
        csvBytes: bytes,
      );

      if (mounted) {
        setState(() {
          _search = '';
          _driverSort = _DriverSort.idAsc;
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${t.tf('drivers_hub_csv_imported_for_dsp', {'file': f.name})} '
            'Parsed ${importResult.parsedRows}, '
            'matched ${importResult.mappedDrivers}, '
            'new ${importResult.newDrivers}, '
            'score rows updated ${importResult.updatedScores}.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.tf('drivers_hub_csv_import_failed', {'error': '$e'})),
        ),
      );
    } finally {
      if (mounted) setState(() => _busyCsv = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Manual driver creation
  // ---------------------------------------------------------------------------

  Future<int> _backfillMissingRuleNotificationsForDriver({
    required String dspUid,
    required DocumentReference<Map<String, dynamic>> driverRef,
  }) async {
    final db = FirebaseFirestore.instance;

    final adminRulesSnap = await db
        .collection('users')
        .doc(dspUid)
        .collection('notifications')
        .where('type', isEqualTo: 'rule')
        .get();

    if (adminRulesSnap.docs.isEmpty) return 0;

    final driverRulesSnap = await driverRef
        .collection('notifications')
        .where('type', isEqualTo: 'rule')
        .get();
    final existingRuleIds = driverRulesSnap.docs.map((d) => d.id).toSet();

    final missing = adminRulesSnap.docs
        .where((doc) => !existingRuleIds.contains(doc.id))
        .toList(growable: false);

    if (missing.isEmpty) return 0;

    final now = FieldValue.serverTimestamp();
    const chunkSize = 350;
    for (var i = 0; i < missing.length; i += chunkSize) {
      final end = (i + chunkSize > missing.length)
          ? missing.length
          : (i + chunkSize);
      final batch = db.batch();

      for (final adminDoc in missing.sublist(i, end)) {
        final adminData = adminDoc.data();
        final driverNotifRef = driverRef
            .collection('notifications')
            .doc(adminDoc.id);

        batch.set(driverNotifRef, {
          'notificationId': adminDoc.id,
          'type': 'rule',
          'title': (adminData['title'] ?? '').toString(),
          'body': (adminData['body'] ?? '').toString(),
          'sourceLang': (adminData['sourceLang'] ?? 'en').toString(),
          'translations': adminData['translations'] ?? const {},
          'status': 'unread',
          'createdAt': adminData['createdAt'] ?? now,
          'readAt': null,
          'confirmedAt': null,
          'requiresConfirmation': adminData['requiresConfirmation'] ?? true,
          'updatedAt': now,
        }, SetOptions(merge: true));

        batch.set(adminDoc.reference, {
          'targetCount': FieldValue.increment(1),
        }, SetOptions(merge: true));
      }

      await batch.commit();
    }

    return missing.length;
  }

  Future<void> _createDriverManually() async {
    final t = AppLocalizations.of(context);
    if (_uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.t('drivers_hub_must_login_add_driver'))),
      );
      return;
    }

    final nameCtrl = TextEditingController();
    final idCtrl = TextEditingController();
    final emailCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.t('drivers_hub_add_edit_driver')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: t.t('drivers_hub_driver_name'),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: idCtrl,
              decoration: InputDecoration(
                labelText: t.t('drivers_hub_transporter_id_login'),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: emailCtrl,
              decoration: InputDecoration(
                labelText: t.t('drivers_hub_email_optional'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(t.t('admin_home_cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(t.t('button_save')),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final name = nameCtrl.text.trim();
    final tid = idCtrl.text.trim();
    final email = emailCtrl.text.trim();

    if (tid.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.t('drivers_hub_name_and_transporter_id_required')),
        ),
      );
      return;
    }

    final db = FirebaseFirestore.instance;
    final doc = db
        .collection('users')
        .doc(_uid!)
        .collection('drivers')
        .doc(tid.toUpperCase());

    await doc.set({
      'transporterId': tid.toUpperCase(),
      'driverName': name,
      'email': email.isEmpty ? null : email,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'hasLogin': false,
      'active': true,
    }, SetOptions(merge: true));

    await _backfillMissingRuleNotificationsForDriver(
      dspUid: _uid!,
      driverRef: doc,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.tf('drivers_hub_driver_saved', {'name': name}))),
    );
  }

  // Helper: build suggested driver email from DSP email + driver name
  String _buildSuggestedDriverEmail({
    required String driverName,
    required String transporterId,
  }) {
    final dspEmail = _auth.currentUser?.email ?? '';
    final atIdx = dspEmail.indexOf('@');
    if (atIdx <= 0) return '';

    final domain = dspEmail.substring(atIdx + 1).trim();
    if (domain.isEmpty) return '';

    String local = driverName.trim().toLowerCase();
    if (local.isEmpty) {
      // fallback to transporterId if no name
      local = transporterId.toLowerCase();
    }

    // Replace non-alnum with '.', collapse dots, trim dots
    local = local
        .replaceAll(RegExp(r'[^a-z0-9]+'), '.')
        .replaceAll(RegExp(r'\.+'), '.')
        .replaceAll(RegExp(r'^\.|\.$'), '');

    if (local.isEmpty) {
      local = 'driver';
    }

    return '$local@$domain';
  }

  // ---------------------------------------------------------------------------
  // Row actions (create/reset login, suspend, delete)
  // ---------------------------------------------------------------------------

  Future<void> _onCreateOrResetLogin(
    DocumentSnapshot<Map<String, dynamic>> driverDoc,
  ) async {
    final t = AppLocalizations.of(context);
    if (_uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.t('drivers_hub_must_login_manage_logins'))),
      );
      return;
    }

    final data = driverDoc.data() ?? {};
    final name = (data['driverName'] ?? '').toString();
    final tidOriginal = (data['transporterId'] ?? '').toString();

    final existingEmail = (data['email'] ?? '').toString();
    final suggestedEmail = _buildSuggestedDriverEmail(
      driverName: name,
      transporterId: tidOriginal,
    );

    final tidCtrl = TextEditingController(text: tidOriginal);
    final emailCtrl = TextEditingController(
      text: existingEmail.isNotEmpty ? existingEmail : suggestedEmail,
    );
    // 🔹 Use the current default/bulk password from the top field, fallback to constant
    final defaultPwd = _bulkPwdCtrl.text.trim().isEmpty
        ? kDefaultDriverPassword
        : _bulkPwdCtrl.text.trim();

    final pwdCtrl = TextEditingController(text: defaultPwd);
    final pwd2Ctrl = TextEditingController(text: defaultPwd);

    // --- Custom dialog with white background + pill fields ---
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final width = MediaQuery.of(ctx).size.width;
        final dialogWidth = width < 480 ? width - 32 : 480.0;

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: dialogWidth),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.t('drivers_hub_set_driver_login'),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.tf('drivers_hub_driver_line', {
                      'name': name.isEmpty ? t.t('dash_no_name') : name,
                    }),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: tidCtrl,
                    decoration: _pillInputDecoration(
                      t.t('drivers_hub_transporter_id_login'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailCtrl,
                    decoration: _pillInputDecoration(
                      t.t('drivers_hub_driver_email'),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: pwdCtrl,
                    decoration: _pillInputDecoration(
                      t.t('drivers_hub_password'),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: pwd2Ctrl,
                    decoration: _pillInputDecoration(
                      t.t('drivers_hub_confirm_password'),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: Text(t.t('admin_home_cancel')),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: Text(t.t('button_save')),
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

    if (ok != true) return;

    final newTidRaw = tidCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final pwd = pwdCtrl.text.trim();
    final pwd2 = pwd2Ctrl.text.trim();

    if (newTidRaw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.t('drivers_hub_transporter_id_required'))),
      );
      return;
    }

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.t('drivers_hub_valid_driver_email_required'))),
      );
      return;
    }

    if (pwd.isEmpty || pwd2.isEmpty || pwd != pwd2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.t('drivers_hub_passwords_must_match'))),
      );
      return;
    }

    final newTid = newTidRaw.toUpperCase();
    final oldTid = tidOriginal.toUpperCase();
    final tidChanged = newTid != oldTid;

    try {
      // Decide which document we will finally use
      DocumentReference<Map<String, dynamic>> targetRef = driverDoc.reference;

      if (tidChanged) {
        // move driver document to new ID
        final driversCol = driverDoc.reference.parent;
        final newDocRef = driversCol.doc(newTid);

        final existingData = Map<String, dynamic>.from(data);
        existingData['transporterId'] = newTid;
        existingData['email'] = email;
        existingData['updatedAt'] = FieldValue.serverTimestamp();

        await newDocRef.set(existingData, SetOptions(merge: true));
        await driverDoc.reference.delete();

        targetRef = newDocRef;
      } else {
        // just update email + transporterId
        await driverDoc.reference.set({
          'email': email,
          'transporterId': newTid,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      // Call function with NEW transporterId
      final callable = FirebaseFunctions.instance.httpsCallable(
        'createDriverLogin',
      );
      await callable.call(<String, dynamic>{
        'dspUid': _uid!,
        'transporterId': newTid,
        'password': pwd,
      });

      // Mark login state on target doc
      await targetRef.set({
        'hasLogin': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      // Dialog with copy buttons for ID, Email, Password
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(t.t('drivers_hub_driver_login_created')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CopyRow(label: t.t('drivers_hub_transporter_id'), value: newTid),
              const SizedBox(height: 8),
              _CopyRow(label: t.t('drivers_hub_email'), value: email),
              const SizedBox(height: 8),
              _CopyRow(label: t.t('drivers_hub_password'), value: pwd),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(t.t('admin_home_close')),
            ),
          ],
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.t('drivers_hub_driver_login_saved'))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.tf('drivers_hub_failed_set_login', {'error': '$e'})),
        ),
      );
    }
  }

  /// Toggle active / suspended state.
  Future<void> _onToggleActiveDriver(
    DocumentSnapshot<Map<String, dynamic>> driverDoc,
    bool currentlyActive,
  ) async {
    final t = AppLocalizations.of(context);
    if (_uid == null) return;
    final newActive = !currentlyActive;

    await driverDoc.reference.set({
      'active': newActive,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (newActive) {
      await _backfillMissingRuleNotificationsForDriver(
        dspUid: _uid!,
        driverRef: driverDoc.reference,
      );
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newActive
              ? t.t('drivers_hub_driver_activated')
              : t.t('drivers_hub_driver_suspended'),
        ),
      ),
    );
  }

  Future<void> _onDeleteDriver(
    DocumentSnapshot<Map<String, dynamic>> driverDoc,
  ) async {
    final t = AppLocalizations.of(context);
    if (_uid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.t('admin_home_not_logged_in'))));
      return;
    }

    final data = driverDoc.data() ?? {};
    final name = (data['driverName'] ?? '').toString();
    final tid = (data['transporterId'] ?? driverDoc.id).toString().trim();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.t('drivers_hub_delete_driver_title')),
        content: Text(t.tf('drivers_hub_delete_driver_body', {'name': name})),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(t.t('admin_home_cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(t.t('admin_home_delete')),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final callable = FirebaseFunctions.instance.httpsCallable(
        'deleteDriverAccount',
      );
      await callable.call(<String, dynamic>{
        'dspUid': _uid,
        'transporterId': tid,
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.tf('drivers_hub_delete_failed', {'error': '$e'})),
        ),
      );
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(t.t('drivers_hub_driver_deleted'))));
  }

  Future<void> _onCreateLoginsForAllDrivers() async {
    final t = AppLocalizations.of(context);
    if (_uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.t('drivers_hub_must_login_manage_logins'))),
      );
      return;
    }

    final pwd = _bulkPwdCtrl.text.trim().isEmpty
        ? kDefaultDriverPassword
        : _bulkPwdCtrl.text.trim();

    if (pwd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.t('drivers_hub_default_password_cannot_be_empty')),
        ),
      );
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.t('drivers_hub_create_logins_for_all_drivers')),
        content: Text(
          t.tf('drivers_hub_create_logins_for_all_body', {'password': pwd}),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(t.t('admin_home_cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(t.t('continue')),
          ),
        ],
      ),
    );

    if (ok != true) return;

    setState(() => _busyBulkLogins = true);
    try {
      final db = FirebaseFirestore.instance;
      final driversSnap = await db
          .collection('users')
          .doc(_uid!)
          .collection('drivers')
          .get();

      if (driversSnap.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.t('drivers_hub_no_drivers_for_dsp'))),
        );
        return;
      }

      final callable = FirebaseFunctions.instance.httpsCallable(
        'createDriverLogin',
      );

      int created = 0;
      int skipped = 0;

      for (final d in driversSnap.docs) {
        final data = d.data();
        final hasLogin = (data['hasLogin'] as bool?) ?? false;
        final tidRaw = (data['transporterId'] ?? '').toString().trim();

        if (tidRaw.isEmpty) {
          skipped++;
          continue;
        }

        // Only create logins for drivers that don't already have one
        if (hasLogin) {
          skipped++;
          continue;
        }

        final tid = tidRaw.toUpperCase();

        // ✅ Ensure driver has an email before calling the function
        final existingEmail = (data['email'] ?? '').toString().trim();
        String emailToUse = existingEmail;

        if (emailToUse.isEmpty) {
          final driverName = (data['driverName'] ?? '').toString();
          emailToUse = _buildSuggestedDriverEmail(
            driverName: driverName,
            transporterId: tid,
          );
        }

        // If still empty, skip (avoids creating @drivers.dsp-copilot.local)
        if (emailToUse.isEmpty) {
          skipped++;
          continue;
        }

        // ✅ Update driver doc FIRST (same behavior as single-driver flow)
        await d.reference.set({
          'transporterId': tid,
          'email': emailToUse,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Call function
        await callable.call(<String, dynamic>{
          'dspUid': _uid!,
          'transporterId': tid,
          'password': pwd,
        });

        // Mark login state
        await d.reference.set({
          'hasLogin': true,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        created++;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t.tf('drivers_hub_created_logins_summary', {
              'created': '$created',
              'skipped': '$skipped',
            }),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t.tf('drivers_hub_failed_create_logins', {'error': '$e'}),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _busyBulkLogins = false);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // ADMIN: Upload docs + edit expiry dates (contract + other expiry)
  // ---------------------------------------------------------------------------

  String _adminDocTypeLabel(String docType) {
    final t = AppLocalizations.of(context);
    switch (docType) {
      case 'resident_permit':
        return t.t('work_permit');
      case 'driver_license_front':
        return t.t('driver_license_front');
      case 'driver_license_back':
        return t.t('driver_license_back');
      case 'id_card_front':
        return t.t('id_card_front');
      case 'id_card_back':
        return t.t('id_card_back');
      case 'passport_front':
        return t.t('passport_front');
      case 'passport_back':
        return t.t('passport_back');
      case 'tax_id':
        return t.t('doc_tax_id');
      case 'insurance':
        return t.t('doc_insurance');
      case 'contract':
        return t.t('admin_home_contract');
      default:
        return docType;
    }
  }

  Future<bool> _adminPickAndUploadDriverDoc({
    required DocumentReference<Map<String, dynamic>> driverRef,
    required String docType,
  }) async {
    final t = AppLocalizations.of(context);
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return false;

      final f = result.files.first;
      final bytes = f.bytes;
      if (bytes == null) {
        throw Exception(t.t('could_not_read_image_bytes'));
      }

      final originalName = f.name;
      final typeLabel = _adminDocTypeLabel(docType);

      String displayName = typeLabel;
      String? contentType;
      final dotIndex = originalName.lastIndexOf('.');
      if (dotIndex != -1 && dotIndex < originalName.length - 1) {
        final ext = originalName.substring(dotIndex + 1);
        displayName = '$typeLabel.$ext';
        switch (ext.toLowerCase()) {
          case 'pdf':
            contentType = 'application/pdf';
            break;
          case 'png':
            contentType = 'image/png';
            break;
          case 'jpg':
          case 'jpeg':
            contentType = 'image/jpeg';
            break;
          case 'webp':
            contentType = 'image/webp';
            break;
        }
      }

      final storage = fb.FirebaseStorage.instance;
      final docsCol = driverRef.collection('documents');

      final ref = storage
          .ref()
          .child('driver_docs')
          .child(driverRef.id)
          .child('${DateTime.now().millisecondsSinceEpoch}_$originalName');

      await ref.putData(
        bytes,
        contentType == null ? null : fb.SettableMetadata(contentType: contentType),
      );
      final url = await ref.getDownloadURL();

      await docsCol.doc(docType).set({
        'fileName': displayName,
        'downloadUrl': url,
        'storagePath': ref.fullPath,
        if (contentType != null) 'contentType': contentType,
        'uploadedAt': FieldValue.serverTimestamp(),
        'uploadedAtClient': Timestamp.now(),
        'size': f.size,
        'docType': docType,
        'uploadedBy': 'admin',
      }, SetOptions(merge: true));

      if (!mounted) return true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t.tf('drivers_hub_document_uploaded', {'document': typeLabel}),
          ),
        ),
      );
      return true;
    } catch (e) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t.tf('drivers_hub_failed_upload_document', {'error': '$e'}),
          ),
        ),
      );
      return false;
    }
    return false;
  }

  Future<void> _showAdminUploadDocDialog(
    DocumentReference<Map<String, dynamic>> driverRef,
  ) async {
    final t = AppLocalizations.of(context);
    String selected = 'contract';
    bool busy = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx2, setLocal) {
            return AlertDialog(
              title: Text(t.t('drivers_hub_upload_driver_document')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selected,
                    decoration: InputDecoration(
                      labelText: t.t('drivers_hub_document_type'),
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'contract',
                        child: Text(t.t('admin_home_contract')),
                      ),
                      DropdownMenuItem(
                        value: 'resident_permit',
                        child: Text(t.t('work_permit')),
                      ),
                      DropdownMenuItem(
                        value: 'id_card_front',
                        child: Text(t.t('id_card_front')),
                      ),
                      DropdownMenuItem(
                        value: 'id_card_back',
                        child: Text(t.t('id_card_back')),
                      ),
                      DropdownMenuItem(
                        value: 'passport_front',
                        child: Text(t.t('passport_front')),
                      ),
                      DropdownMenuItem(
                        value: 'passport_back',
                        child: Text(t.t('passport_back')),
                      ),
                      DropdownMenuItem(
                        value: 'driver_license_front',
                        child: Text(t.t('driver_license_front')),
                      ),
                      DropdownMenuItem(
                        value: 'driver_license_back',
                        child: Text(t.t('driver_license_back')),
                      ),
                      DropdownMenuItem(
                        value: 'tax_id',
                        child: Text(t.t('doc_tax_id')),
                      ),
                      DropdownMenuItem(
                        value: 'insurance',
                        child: Text(t.t('doc_insurance')),
                      ),
                    ],
                    onChanged: busy
                        ? null
                        : (v) {
                      if (v == null) return;
                      setLocal(() => selected = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      t.tf('drivers_hub_replace_slot_hint', {
                        'slot': 'documents/$selected',
                      }),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: busy ? null : () => Navigator.of(ctx2).pop(),
                  child: Text(t.t('admin_home_cancel')),
                ),
                FilledButton.icon(
                  onPressed: busy
                      ? null
                      : () async {
                    setLocal(() => busy = true);
                    final ok = await _adminPickAndUploadDriverDoc(
                      driverRef: driverRef,
                      docType: selected,
                    );
                    if (!ctx2.mounted) return;
                    if (ok) {
                      Navigator.of(ctx2).pop();
                      return;
                    }
                    setLocal(() => busy = false);
                  },
                  icon: busy
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.upload_outlined, size: 18),
                  label: Text(t.t('scorecard_overview_choose_file')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Driver details dialog: responsive layout (no stats / weekly scores)
  // ---------------------------------------------------------------------------

  Future<void> _openDriverDetails(
    DocumentSnapshot<Map<String, dynamic>> driverDoc,
  ) async {
    await showDialog(
      context: context,
      builder: (ctx) {
        final media = MediaQuery.of(ctx).size;
        bool showPin = false;

        return StatefulBuilder(
          builder: (ctxState, setStateDialog) {
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
                child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: driverDoc.reference.snapshots(),
                  builder: (ctx2, snap) {
                    if (!snap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final t = AppLocalizations.of(ctx2);

                    final data = snap.data!.data() ?? {};
                    final name = (data['driverName'] ?? '').toString();
                    final email = (data['email'] ?? '').toString();
                    final tid = (data['transporterId'] ?? '').toString();
                    final pin = (data['notificationPin'] ?? '')
                        .toString()
                        .trim();
                    final canEditPin = (_uid != null && tid.isNotEmpty);

                    // onboarding map
                    final raw = data['onboarding'];
                    Map<String, dynamic> onboarding = const {};
                    if (raw is Map<String, dynamic>) {
                      onboarding = raw;
                    } else if (raw is Map) {
                      onboarding = raw.map((k, v) => MapEntry(k.toString(), v));
                    }
                    final hasOnboarding = onboarding.isNotEmpty;
                    final profileImage = _profileImageFromOnboarding(
                      onboarding,
                    );

                    return Container(
                      color: const Color(0xFFF4F5FB),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Scrollable content
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  // ------------------------------------------------------------------
                                  // TOP CARD (responsive)
                                  // ------------------------------------------------------------------
                                  Container(
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
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        final isNarrow =
                                            constraints.maxWidth < 720;

                                        // LEFT: avatar + ID/licence preview
                                        final left = SizedBox(
                                          width: isNarrow
                                              ? double.infinity
                                              : 230,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                                child: Container(
                                                  height: 180,
                                                  width: double.infinity,
                                                  color: const Color(
                                                    0xFFE5E7EB,
                                                  ),
                                                  child: profileImage == null
                                                      ? const Icon(
                                                          Icons.person,
                                                          size: 72,
                                                          color: Color(
                                                            0xFF9CA3AF,
                                                          ),
                                                        )
                                                      : Image(
                                                          image: profileImage,
                                                          fit: BoxFit.cover,
                                                        ),
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                child:
                                                    StreamBuilder<
                                                      DocumentSnapshot<
                                                        Map<String, dynamic>
                                                      >
                                                    >(
                                                      stream: snap
                                                          .data!
                                                          .reference
                                                          .collection(
                                                            'documents',
                                                          )
                                                          .doc(
                                                            'driver_license_front',
                                                          )
                                                          .snapshots(),
                                                      builder: (context, docSnap) {
                                                        final docData =
                                                            docSnap.data
                                                                ?.data() ??
                                                            const <
                                                              String,
                                                              dynamic
                                                            >{};
                                                        final url =
                                                            (docData['downloadUrl'] ??
                                                                    '')
                                                                .toString();
                                                        final fileName =
                                                            (docData['fileName'] ??
                                                                    '')
                                                                .toString();
                                                        final hasUrl =
                                                            url.isNotEmpty;
                                                        final path =
                                                            Uri.tryParse(url)
                                                                ?.path
                                                                .toLowerCase() ??
                                                            '';
                                                        final isImage =
                                                            path.endsWith(
                                                              '.png',
                                                            ) ||
                                                            path.endsWith(
                                                              '.jpg',
                                                            ) ||
                                                            path.endsWith(
                                                              '.jpeg',
                                                            ) ||
                                                            path.endsWith(
                                                              '.webp',
                                                            );

                                                        Widget child;
                                                        if (!hasUrl) {
                                                          child = Row(
                                                            children: [
                                                              Container(
                                                                padding:
                                                                    const EdgeInsets.all(
                                                                      6,
                                                                    ),
                                                                decoration: BoxDecoration(
                                                                  color:
                                                                      const Color(
                                                                        0xFFE5E7EB,
                                                                      ).withOpacity(
                                                                        0.9,
                                                                      ),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        10,
                                                                      ),
                                                                ),
                                                                child: const Icon(
                                                                  Icons.badge,
                                                                  size: 24,
                                                                  color: Color(
                                                                    0xFF4B5563,
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  t.t(
                                                                    'drivers_hub_driving_licence_front_preview',
                                                                  ),
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        11,
                                                                    color: Color(
                                                                      0xFF6B7280,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        } else if (isImage) {
                                                          child = kIsWeb
                                                              ? buildWebImagePreview(
                                                                  url,
                                                                )
                                                              : Image.network(
                                                                  url,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  loadingBuilder:
                                                                      (
                                                                        context,
                                                                        child,
                                                                        loadingProgress,
                                                                      ) {
                                                                        if (loadingProgress ==
                                                                            null) {
                                                                          return child;
                                                                        }
                                                                        return const Center(
                                                                          child: CircularProgressIndicator(
                                                                            strokeWidth:
                                                                                2,
                                                                          ),
                                                                        );
                                                                      },
                                                                  errorBuilder:
                                                                      (
                                                                        context,
                                                                        error,
                                                                        stackTrace,
                                                                      ) {
                                                                        return const Center(
                                                                          child: Icon(
                                                                            Icons.image_not_supported_outlined,
                                                                            color: Color(
                                                                              0xFF9CA3AF,
                                                                            ),
                                                                          ),
                                                                        );
                                                                      },
                                                                );
                                                        } else {
                                                          child = Row(
                                                            children: [
                                                              const Icon(
                                                                Icons
                                                                    .insert_drive_file,
                                                                size: 18,
                                                                color: Color(
                                                                  0xFF6B7280,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 8,
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  fileName.isEmpty
                                                                      ? t.t(
                                                                          'driver_license_front',
                                                                        )
                                                                      : fileName,
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: const TextStyle(
                                                                    fontSize:
                                                                        11,
                                                                    color: Color(
                                                                      0xFF6B7280,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        }

                                                        return Container(
                                                          height: 80,
                                                          width:
                                                              double.infinity,
                                                          color: const Color(
                                                            0xFFF3F4F6,
                                                          ),
                                                          padding:
                                                              hasUrl && isImage
                                                              ? EdgeInsets.zero
                                                              : const EdgeInsets.all(
                                                                  10,
                                                                ),
                                                          child: child,
                                                        );
                                                      },
                                                    ),
                                              ),
                                            ],
                                          ),
                                        );

                                        // ---------- Onboarding details with sections ----------
                                        Widget buildOnboardingDetails(
                                          bool narrow,
                                        ) {
                                          // ----- full list of fields, grouped into sections -----

                                          final personalSection = Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                t.t(
                                                  'drivers_hub_section_personal_details',
                                                ),
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFFA8a29e),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              _detailRowEditable(
                                                driverRef: snap.data!.reference,
                                                label: t.t(
                                                  'drivers_hub_field_full_name',
                                                ),
                                                value: onboarding['fullName'],
                                                fieldKey: 'fullName',
                                              ),

                                              _detailRowEditable(
                                                driverRef: snap.data!.reference,
                                                label: t.t(
                                                  'drivers_hub_field_name_at_birth',
                                                ),
                                                value:
                                                    onboarding['nameAtBirth'],
                                                fieldKey: 'nameAtBirth',
                                              ),
                                              _detailRowEditable(
                                                driverRef: snap.data!.reference,
                                                label: t.t(
                                                  'drivers_hub_field_date_of_birth',
                                                ),
                                                value:
                                                    onboarding['dateOfBirth'],
                                                fieldKey: 'dateOfBirth',
                                                isDate: true,
                                              ),
                                              _detailRowEditable(
                                                driverRef: snap.data!.reference,
                                                label: t.t(
                                                  'drivers_hub_field_phone',
                                                ),
                                                value: onboarding['phone'],
                                                fieldKey: 'phone',
                                              ),
                                            ],
                                          );

                                          final originSection = Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 10),
                                              Text(
                                                t.t(
                                                  'drivers_hub_section_origin',
                                                ),
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFFA8a29e),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              _detailRowEditable(
                                                driverRef: snap.data!.reference,
                                                label: t.t(
                                                  'drivers_hub_field_city_of_birth',
                                                ),
                                                value: onboarding['birthCity'],
                                                fieldKey: 'birthCity',
                                              ),
                                              _detailRowEditable(
                                                driverRef: snap.data!.reference,
                                                label: t.t(
                                                  'drivers_hub_field_state_of_birth',
                                                ),
                                                value: onboarding['birthState'],
                                                fieldKey: 'birthState',
                                              ),
                                              _detailRowEditable(
                                                driverRef: snap.data!.reference,
                                                label: t.t(
                                                  'drivers_hub_field_nationality_id_card',
                                                ),
                                                value:
                                                    onboarding['nationalityIdCard'],
                                                fieldKey: 'nationalityIdCard',
                                              ),
                                            ],
                                          );

                                          final addressSection = Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 10),
                                              Text(
                                                t.t(
                                                  'drivers_hub_section_address',
                                                ),
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFFA8a29e),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              _detailRowEditable(
                                                driverRef: snap.data!.reference,
                                                label: t.t(
                                                  'drivers_hub_field_street_address',
                                                ),
                                                value: onboarding['address'],
                                                fieldKey: 'address',
                                              ),
                                              _detailRowEditable(
                                                driverRef: snap.data!.reference,
                                                label: t.t(
                                                  'drivers_hub_field_city',
                                                ),
                                                value: onboarding['city'],
                                                fieldKey: 'city',
                                              ),
                                              _detailRowEditable(
                                                driverRef: snap.data!.reference,
                                                label: t.t(
                                                  'drivers_hub_field_postal_code',
                                                ),
                                                value: onboarding['postalCode'],
                                                fieldKey: 'postalCode',
                                              ),
                                              _detailRowEditable(
                                                driverRef: snap.data!.reference,
                                                label: t.t(
                                                  'drivers_hub_field_country',
                                                ),
                                                value: onboarding['country'],
                                                fieldKey: 'country',
                                              ),
                                            ],
                                          );

                                          final workPermitType =
                                              _normalizeWorkPermitType(
                                                onboarding['workPermitType'],
                                                fallbackExpiry:
                                                    onboarding['residencePermitExpiry'],
                                              );
                                          final workVisaExpiryValue =
                                              (onboarding['workVisaExpiry'] ??
                                                      onboarding['residencePermitExpiry'])
                                                  .toString();

                                          final documentsDatesSection = Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 10),
                                              Text(
                                                t.t(
                                                  'drivers_hub_section_document_expiry_dates',
                                                ),
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFFA8a29e),
                                                ),
                                              ),
                                              const SizedBox(height: 4),

                                              _detailRowEditable(
                                                driverRef: snap.data!.reference,
                                                label: t.t(
                                                  'drivers_hub_field_work_permit_type',
                                                ),
                                                value: workPermitType,
                                                fieldKey: 'workPermitType',
                                                displayValueBuilder: (_) =>
                                                    _workPermitTypeLabel(
                                                      t,
                                                      workPermitType,
                                                      fallbackExpiry:
                                                          onboarding['residencePermitExpiry'],
                                                    ),
                                                onEdit: () => _adminEditWorkPermitType(
                                                  driverRef:
                                                      snap.data!.reference,
                                                  initialValue:
                                                      onboarding['workPermitType'],
                                                  fallbackExpiry:
                                                      onboarding['residencePermitExpiry'],
                                                ),
                                              ),

                                              _detailRowEditable(
                                                driverRef: snap.data!.reference,
                                                label: t.t(
                                                  'drivers_hub_field_work_start_date',
                                                ),
                                                value:
                                                    onboarding['workStartDate'],
                                                fieldKey: 'workStartDate',
                                                isDate: true,
                                              ),

                                              _detailRowEditable(
                                                driverRef: snap.data!.reference,
                                                label: t.t(
                                                  'drivers_hub_field_annual_vacation_days',
                                                ),
                                                value:
                                                    onboarding['annualVacationDays'] ??
                                                    20,
                                                fieldKey: 'annualVacationDays',
                                                isNumeric: true,
                                              ),

                                              _remainingVacationDaysRow(
                                                driverRef: snap.data!.reference,
                                                onboarding: onboarding,
                                              ),

                                              _detailRowReadOnly(
                                                label: t.t(
                                                  'drivers_hub_field_probezeit_end',
                                                ),
                                                value: (() {
                                                  final start = _parseIsoDate(
                                                    onboarding['workStartDate']
                                                        ?.toString(),
                                                  );
                                                  final end =
                                                      _probationEndFromStart(
                                                        start,
                                                      );
                                                  return end == null
                                                      ? ''
                                                      : _formatDate(end);
                                                })(),
                                              ),

                                              // ✅ Contract expiry now visible
                                              _detailRowEditable(
                                                driverRef: snap.data!.reference,
                                                label: t.t(
                                                  'drivers_hub_field_contract_expiry',
                                                ),
                                                value:
                                                    onboarding['contractExpiry'],
                                                fieldKey: 'contractExpiry',
                                                isDate: true,
                                              ),

                                              if (workPermitType ==
                                                  'working_visa')
                                                _detailRowEditable(
                                                  driverRef:
                                                      snap.data!.reference,
                                                  label: t.t(
                                                    'drivers_hub_field_work_visa_expiry',
                                                  ),
                                                  value: workVisaExpiryValue,
                                                  fieldKey: 'workVisaExpiry',
                                                  isDate: true,
                                                ),
                                              if (workPermitType ==
                                                  'working_visa')
                                                _detailRowEditable(
                                                  driverRef:
                                                      snap.data!.reference,
                                                  label: t.t(
                                                    'drivers_hub_field_zusatzblatt_expiry',
                                                  ),
                                                  value:
                                                      onboarding['zusatzblattExpiry'],
                                                  fieldKey: 'zusatzblattExpiry',
                                                  isDate: true,
                                                ),
                                              _detailRowEditable(
                                                driverRef: snap.data!.reference,
                                                label: t.t(
                                                  'drivers_hub_field_id_card_passport_expiry',
                                                ),
                                                value:
                                                    onboarding['idDocExpiry'],
                                                fieldKey: 'idDocExpiry',
                                                isDate: true,
                                              ),
                                            ],
                                          );

                                          final licenseSection = Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 10),
                                              Text(
                                                t.t(
                                                  'drivers_hub_section_driving_license',
                                                ),
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFFA8a29e),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              _detailRowEditable(
                                                driverRef: snap.data!.reference,
                                                label: t.t(
                                                  'drivers_hub_field_driving_license_number',
                                                ),
                                                value:
                                                    onboarding['licenseNumber'],
                                                fieldKey: 'licenseNumber',
                                              ),
                                              _detailRowEditable(
                                                driverRef: snap.data!.reference,
                                                label: t.t(
                                                  'drivers_hub_field_license_expiry_date',
                                                ),
                                                value:
                                                    onboarding['licenseExpiry'],
                                                fieldKey: 'licenseExpiry',
                                                isDate: true,
                                              ),
                                            ],
                                          );

                                          final emergencySection = Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 10),
                                              Text(
                                                t.t(
                                                  'drivers_hub_section_emergency_contact',
                                                ),
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFFA8a29e),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              _detailRowEditable(
                                                driverRef: snap.data!.reference,
                                                label: t.t(
                                                  'drivers_hub_field_emergency_contact_name',
                                                ),
                                                value:
                                                    onboarding['emergencyContactName'],
                                                fieldKey:
                                                    'emergencyContactName',
                                              ),
                                              _detailRowEditable(
                                                driverRef: snap.data!.reference,
                                                label: t.t(
                                                  'drivers_hub_field_emergency_contact_phone',
                                                ),
                                                value:
                                                    onboarding['emergencyContactPhone'],
                                                fieldKey:
                                                    'emergencyContactPhone',
                                              ),
                                            ],
                                          );

                                          final paymentSection = Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 10),
                                              Text(
                                                t.t(
                                                  'drivers_hub_section_payment_tax',
                                                ),
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFFA8a29e),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              _detailRowEditable(
                                                driverRef: snap.data!.reference,
                                                label: t.t(
                                                  'drivers_hub_field_bank_iban',
                                                ),
                                                value: onboarding['bankIban'],
                                                fieldKey: 'bankIban',
                                              ),
                                              _detailRowEditable(
                                                driverRef: snap.data!.reference,
                                                label: t.t(
                                                  'drivers_hub_field_insurance_company',
                                                ),
                                                value:
                                                    onboarding['insuranceCompany'],
                                                fieldKey: 'insuranceCompany',
                                              ),
                                              _detailRowEditable(
                                                driverRef: snap.data!.reference,
                                                label: t.t(
                                                  'drivers_hub_field_tax_id',
                                                ),
                                                value: onboarding['taxId'],
                                                fieldKey: 'taxId',
                                              ),
                                            ],
                                          );

                                          final uniformSection = Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 10),
                                              Text(
                                                t.t(
                                                  'drivers_hub_section_uniform',
                                                ),
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFFA8a29e),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              _detailRowEditable(
                                                driverRef: snap.data!.reference,
                                                label: t.t(
                                                  'drivers_hub_field_tshirt_size',
                                                ),
                                                value: onboarding['tShirtSize'],
                                                fieldKey: 'tShirtSize',
                                              ),
                                              _detailRowEditable(
                                                driverRef: snap.data!.reference,
                                                label: t.t(
                                                  'drivers_hub_field_shoe_size',
                                                ),
                                                value: onboarding['shoeSize'],
                                                fieldKey: 'shoeSize',
                                              ),
                                            ],
                                          );

                                          final notesSection = Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 10),
                                              Text(
                                                t.t(
                                                  'drivers_hub_section_other_notes',
                                                ),
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFFA8a29e),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              _detailRowEditable(
                                                driverRef: snap.data!.reference,
                                                label: t.t(
                                                  'drivers_hub_field_notes',
                                                ),
                                                value: onboarding['notes'],
                                                fieldKey: 'notes',
                                              ),
                                            ],
                                          );

                                          if (narrow) {
                                            // Mobile / narrow: all sections in ONE column
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                personalSection,
                                                originSection,
                                                addressSection,
                                                documentsDatesSection,
                                                licenseSection,
                                                emergencySection,
                                                paymentSection,
                                                uniformSection,
                                                notesSection,
                                              ],
                                            );
                                          } else {
                                            // Wide: split sections into two columns
                                            return Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      personalSection,
                                                      originSection,
                                                      addressSection,
                                                      // emergencySection,
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 20),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      documentsDatesSection,
                                                      licenseSection,
                                                      paymentSection,
                                                      uniformSection,
                                                      // notesSection,
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            );
                                          }
                                        }

                                        // ---------- RIGHT column: header + onboarding details ----------
                                        final rightColumn = Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      SelectableText(
                                                        name.isEmpty
                                                            ? t.t(
                                                                'dash_no_name',
                                                              )
                                                            : name,
                                                        style: const TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                      if (email.isNotEmpty)
                                                        SelectableText(
                                                          email,
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 13,
                                                                color: Color(
                                                                  0xFF6B7280,
                                                                ),
                                                              ),
                                                        ),
                                                      if (tid.isNotEmpty)
                                                        SelectableText(
                                                          t.tf(
                                                            'drivers_hub_transporter_id_line',
                                                            {'id': tid},
                                                          ),
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 12,
                                                                color: Color(
                                                                  0xFF9CA3AF,
                                                                ),
                                                              ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    _statusChipFromData(
                                                      data,
                                                      ctx2,
                                                    ),
                                                    const SizedBox(height: 6),
                                                    _loginChipFromData(
                                                      data,
                                                      ctx2,
                                                    ),
                                                    const SizedBox(height: 6),
                                                    _expiryChipDetailedFromOnboardingRaw(
                                                      onboarding,
                                                      ctx2,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Container(
                                              width: double.infinity,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 14,
                                                    vertical: 12,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                border: Border.all(
                                                  color: const Color(
                                                    0xFFE5E7EB,
                                                  ),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          t.t(
                                                            'drivers_hub_notification_pin',
                                                          ),
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: Color(
                                                              0xFF6B7280,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 6,
                                                        ),
                                                        Text(
                                                          pin.isEmpty
                                                              ? t.t(
                                                                  'drivers_hub_not_set',
                                                                )
                                                              : (showPin
                                                                    ? pin
                                                                    : '••••'),
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800,
                                                                color: Color(
                                                                  0xFF111827,
                                                                ),
                                                                letterSpacing:
                                                                    2,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  if (pin.isNotEmpty)
                                                    IconButton(
                                                      tooltip: showPin
                                                          ? t.t(
                                                              'drivers_hub_hide_pin',
                                                            )
                                                          : t.t(
                                                              'drivers_hub_show_pin',
                                                            ),
                                                      onPressed: () =>
                                                          setStateDialog(
                                                            () => showPin =
                                                                !showPin,
                                                          ),
                                                      icon: Icon(
                                                        showPin
                                                            ? Icons
                                                                  .visibility_off
                                                            : Icons.visibility,
                                                        color: const Color(
                                                          0xFF6B7280,
                                                        ),
                                                      ),
                                                    ),
                                                  const SizedBox(width: 6),
                                                  OutlinedButton(
                                                    onPressed: !canEditPin
                                                        ? null
                                                        : () async {
                                                            await showDialog<
                                                              void
                                                            >(
                                                              context: ctx2,
                                                              barrierDismissible:
                                                                  false,
                                                              builder: (_) =>
                                                                  SetNotificationPinDialog(
                                                                    dspUid:
                                                                        _uid!,
                                                                    transporterId:
                                                                        tid.toUpperCase(),
                                                                    force: true,
                                                                  ),
                                                            );
                                                          },
                                                    child: Text(
                                                      pin.isEmpty
                                                          ? t.t(
                                                              'drivers_hub_set_pin',
                                                            )
                                                          : t.t(
                                                              'drivers_hub_change_pin',
                                                            ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 18),
                                            buildOnboardingDetails(isNarrow),
                                          ],
                                        );

                                        // ---------- Layout: one column on narrow, side-by-side on wide ----------
                                        if (isNarrow) {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              left,
                                              const SizedBox(height: 16),
                                              rightColumn, // no Expanded here → avoids the flex error in scroll
                                            ],
                                          );
                                        } else {
                                          return Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              left,
                                              const SizedBox(width: 24),
                                              Expanded(child: rightColumn),
                                            ],
                                          );
                                        }
                                      },
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  if (tid.isNotEmpty)
                                    _buildWeeklyScoreSummaryCard(
                                      transporterId: tid,
                                      t: t,
                                      onToggleExpanded: () {
                                        setStateDialog(() {
                                          if (_expandedWeeklySummaries.contains(
                                            tid.trim().toUpperCase(),
                                          )) {
                                            _expandedWeeklySummaries.remove(
                                              tid.trim().toUpperCase(),
                                            );
                                          } else {
                                            _expandedWeeklySummaries.add(
                                              tid.trim().toUpperCase(),
                                            );
                                          }
                                        });
                                      },
                                    ),

                                  if (tid.isNotEmpty)
                                    const SizedBox(height: 16),

                                  // ------------------------------------------------------------------
                                  // DOCUMENTS CARD
                                  // ------------------------------------------------------------------
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.02),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _AdminDriverToolsRow(
                                          onUploadDoc: () =>
                                              _showAdminUploadDocDialog(
                                                snap.data!.reference,
                                              ),
                                        ),
                                        const SizedBox(height: 12),
                                        _DriverDocumentsList(
                                          driverRef: snap.data!.reference,
                                          driverName: name,
                                          onUploadDoc: (docType) =>
                                              _adminPickAndUploadDriverDoc(
                                                driverRef: snap.data!.reference,
                                                docType: docType,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: Text(t.t('admin_home_close')),
                              ),
                              const SizedBox(width: 8),
                              FilledButton(
                                onPressed: !hasOnboarding
                                    ? null
                                    : () {
                                        _exportOnboardingPdf(
                                          driverName: name,
                                          transporterId: tid,
                                          onboarding: onboarding,
                                        );
                                      },
                                child: Text(t.t('drivers_hub_export_pdf')),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWeeklyScoreSummaryCard({
    required String transporterId,
    required AppLocalizations t,
    required VoidCallback onToggleExpanded,
  }) {
    final uid = _uid;
    if (uid == null || transporterId.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final normalizedTid = transporterId.trim().toUpperCase();
    final expanded = _expandedWeeklySummaries.contains(normalizedTid);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('scores')
            .where('transporterId', isEqualTo: normalizedTid)
            .snapshots(),
        builder: (context, snap) {
          final title = Text(
            t.t('drivers_hub_weekly_score_summary'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          );

          if (snap.connectionState == ConnectionState.waiting &&
              !snap.hasData) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title,
                const SizedBox(height: 14),
                const Center(child: CircularProgressIndicator()),
              ],
            );
          }

          final docs = [...?snap.data?.docs];
          docs.sort((a, b) {
            final ad = a.data();
            final bd = b.data();
            final aYear = (ad['year'] as num?)?.toInt() ?? -1;
            final bYear = (bd['year'] as num?)?.toInt() ?? -1;
            if (aYear != bYear) return bYear.compareTo(aYear);

            final aWeek = (ad['weekNumber'] as num?)?.toInt() ?? -1;
            final bWeek = (bd['weekNumber'] as num?)?.toInt() ?? -1;
            if (aWeek != bWeek) return bWeek.compareTo(aWeek);

            final aDate =
                (ad['reportDate'] as Timestamp?)?.millisecondsSinceEpoch ??
                (ad['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ??
                0;
            final bDate =
                (bd['reportDate'] as Timestamp?)?.millisecondsSinceEpoch ??
                (bd['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ??
                0;
            return bDate.compareTo(aDate);
          });

          final visible = docs.take(8).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: visible.isEmpty
                    ? null
                    : onToggleExpanded,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Expanded(child: title),
                      if (visible.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${visible.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4B5563),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          expanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: const Color(0xFF6B7280),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              if (visible.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Text(
                    t.t('drivers_hub_no_scores_yet'),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                )
              else if (expanded)
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    children: [
                      for (var i = 0; i < visible.length; i++) ...[
                        _buildWeeklyScoreSummaryRow(
                          data: visible[i].data(),
                          t: t,
                        ),
                        if (i != visible.length - 1)
                          const Divider(height: 1, color: Color(0xFFE5E7EB)),
                      ],
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWeeklyScoreSummaryRow({
    required Map<String, dynamic> data,
    required AppLocalizations t,
  }) {
    final year = (data['year'] as num?)?.toInt();
    final week = (data['weekNumber'] as num?)?.toInt();
    final bucket = _normalizedDriverScoreBucket(
      raw: data['statusBucket'],
      score: ((data['comp'] as Map?)?['FinalScore'] as num?)?.toDouble(),
    );
    final label = _driverScoreBucketLabel(t, bucket);
    final color = _driverScoreBucketColor(bucket);

    String leftLabel;
    if (week != null && year != null) {
      leftLabel = t.tf(
        'dash_week_range',
        {'week': week.toString(), 'year': year.toString()},
      );
    } else if (week != null) {
      leftLabel = '${t.t('dash_week')} $week';
    } else {
      leftLabel = t.t('drivers_hub_not_set');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              leftLabel,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _normalizedDriverScoreBucket({dynamic raw, double? score}) {
    final value = (raw ?? '').toString().trim().toUpperCase();
    if (value.isNotEmpty) {
      switch (value) {
        case 'FANTASTIC_PLUS':
        case 'FANTASTIC PLUS':
          return 'FANTASTIC_PLUS';
        case 'FANTASTIC':
          return 'FANTASTIC';
        case 'GREAT':
          return 'GREAT';
        case 'FAIR':
          return 'FAIR';
        case 'POOR':
          return 'POOR';
      }
    }

    final finalScore = score ?? 0;
    if (finalScore >= 93) return 'FANTASTIC_PLUS';
    if (finalScore >= 86) return 'FANTASTIC';
    if (finalScore >= 70) return 'GREAT';
    if (finalScore >= 50) return 'FAIR';
    return 'POOR';
  }

  String _driverScoreBucketLabel(AppLocalizations t, String bucket) {
    switch (bucket) {
      case 'FANTASTIC_PLUS':
        return 'Fantastic Plus';
      case 'FANTASTIC':
        return 'Fantastic';
      case 'GREAT':
        return 'Great';
      case 'FAIR':
        return 'Fair';
      case 'POOR':
      default:
        return 'Poor';
    }
  }

  Color _driverScoreBucketColor(String bucket) {
    switch (bucket) {
      case 'FANTASTIC_PLUS':
        return const Color(0xFF14B8A6);
      case 'FANTASTIC':
        return const Color(0xFF0EA5E9);
      case 'GREAT':
        return const Color(0xFFF59E0B);
      case 'FAIR':
        return const Color(0xFFFB923C);
      case 'POOR':
      default:
        return const Color(0xFFEF4444);
    }
  }

  Map<String, _DriverOverallScoreData> _aggregateDriverOverallScores(
    Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final totals = <String, double>{};
    final counts = <String, int>{};

    for (final doc in docs) {
      final data = doc.data();
      final transporterId = (data['transporterId'] ?? '')
          .toString()
          .trim()
          .toUpperCase();
      if (transporterId.isEmpty) continue;

      final score = ((data['comp'] as Map?)?['FinalScore'] as num?)?.toDouble();
      if (score == null) continue;

      totals[transporterId] = (totals[transporterId] ?? 0) + score;
      counts[transporterId] = (counts[transporterId] ?? 0) + 1;
    }

    return totals.map((transporterId, total) {
      final count = counts[transporterId] ?? 0;
      return MapEntry(
        transporterId,
        _DriverOverallScoreData(
          averageScore: count == 0 ? 0 : total / count,
          weeksCount: count,
        ),
      );
    });
  }

  String _formatOverallScorePercent(double score) {
    return '${score.toStringAsFixed(1).replaceAll('.', ',')} %';
  }

  Widget _buildOverallScoreCell({
    required _DriverOverallScoreData? data,
    required AppLocalizations t,
  }) {
    if (data == null || data.weeksCount <= 0) {
      return const Text(
        '—',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF9CA3AF),
        ),
      );
    }

    final bucket = _normalizedDriverScoreBucket(score: data.averageScore);
    final bucketColor = _driverScoreBucketColor(bucket);
    final bucketLabel = _driverScoreBucketLabel(t, bucket);

    return Wrap(
      spacing: 12,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            _formatOverallScorePercent(data.averageScore),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            bucketLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: bucketColor,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _exportOnboardingPdf({
    required String driverName,
    required String transporterId,
    required Map<String, dynamic> onboarding,
  }) async {
    final t = AppLocalizations.of(context);
    final doc = pw.Document();
    final workPermitType = _normalizeWorkPermitType(
      onboarding['workPermitType'],
      fallbackExpiry: onboarding['residencePermitExpiry'],
    );
    final workVisaExpiry =
        (onboarding['workVisaExpiry'] ?? onboarding['residencePermitExpiry'])
            .toString();

    pw.Widget _field(String label, dynamic value) {
      final text = (value ?? '').toString();
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 4),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(
              width: 130,
              child: pw.Text(
                label,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Expanded(child: pw.Text(text.isEmpty ? '-' : text)),
          ],
        ),
      );
    }

    doc.addPage(
      pw.MultiPage(
        build: (ctx) => [
          pw.Text(
            t.t('drivers_hub_pdf_driver_onboarding'),
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          pw.Text(t.tf('drivers_hub_driver_line', {'name': driverName})),
          pw.Text(
            t.tf('drivers_hub_transporter_id_line', {'id': transporterId}),
          ),
          pw.SizedBox(height: 16),
          _field(t.t('drivers_hub_field_full_name'), onboarding['fullName']),
          _field(
            t.t('drivers_hub_field_name_at_birth'),
            onboarding['nameAtBirth'],
          ),
          _field(
            t.t('drivers_hub_field_date_of_birth'),
            onboarding['dateOfBirth'],
          ),
          _field(t.t('drivers_hub_field_phone'), onboarding['phone']),
          _field(
            t.t('drivers_hub_field_street_address'),
            onboarding['address'],
          ),
          _field(t.t('drivers_hub_field_city'), onboarding['city']),
          _field(
            t.t('drivers_hub_field_postal_code'),
            onboarding['postalCode'],
          ),
          _field(t.t('drivers_hub_field_country'), onboarding['country']),
          pw.SizedBox(height: 10),
          _field(
            t.t('drivers_hub_field_work_permit_type'),
            _workPermitTypeLabel(
              t,
              workPermitType,
              fallbackExpiry: onboarding['residencePermitExpiry'],
            ),
          ),
          if (workPermitType == 'working_visa')
            _field(t.t('drivers_hub_field_work_visa_expiry'), workVisaExpiry),
          if (workPermitType == 'working_visa')
            _field(
              t.t('drivers_hub_field_zusatzblatt_expiry'),
              onboarding['zusatzblattExpiry'],
            ),
          pw.SizedBox(height: 10),
          _field(
            t.t('drivers_hub_field_driving_license_number'),
            onboarding['licenseNumber'],
          ),
          _field(
            t.t('drivers_hub_field_license_expiry_date'),
            onboarding['licenseExpiry'],
          ),
          pw.SizedBox(height: 10),
          _field(
            t.t('drivers_hub_field_emergency_contact_name'),
            onboarding['emergencyContactName'],
          ),
          _field(
            t.t('drivers_hub_field_emergency_contact_phone'),
            onboarding['emergencyContactPhone'],
          ),
          pw.SizedBox(height: 10),
          _field(t.t('drivers_hub_field_bank_iban'), onboarding['bankIban']),
          _field(
            t.t('drivers_hub_field_insurance_company'),
            onboarding['insuranceCompany'],
          ),
          _field(t.t('drivers_hub_field_tax_id'), onboarding['taxId']),
          _field(
            t.t('drivers_hub_field_tshirt_size'),
            onboarding['tShirtSize'],
          ),
          _field(t.t('drivers_hub_field_notes'), onboarding['notes']),
        ],
      ),
    );

    await Printing.layoutPdf(
      name: 'onboarding_$transporterId.pdf',
      onLayout: (format) async => doc.save(),
    );
  }

  // ---------------------------------------------------------------------------
  // Driver list – unified desktop-style layout (for all screen sizes)
  // ---------------------------------------------------------------------------

  Widget _buildDriversList() {
    final t = AppLocalizations.of(context);
    if (_uid == null) {
      return Center(child: Text(t.t('drivers_hub_must_login_view_drivers')));
    }

    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 800;
    final isNarrowControls = width < 980;

    final searchField = TextField(
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: t.t('drivers_hub_search_name_or_email'),
        isDense: isSmall,
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (value) {
        setState(() {
          _search = value.toLowerCase();
        });
      },
    );

    final sortField = _DriverSortPill(
      isSmall: isSmall,
      valueLabel: _driverSortLabel(_driverSort),
      onSelected: (value) {
        setState(() {
          _driverSort = value;
        });
      },
    );

    final passwordField = TextField(
      controller: _bulkPwdCtrl,
      obscureText: !_bulkPwdVisible,
      decoration: InputDecoration(
        labelText: t.t('drivers_hub_default_driver_password'),
        isDense: isSmall,
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _bulkPwdVisible
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
          onPressed: () {
            setState(() {
              _bulkPwdVisible = !_bulkPwdVisible;
            });
          },
        ),
      ),
    );

    final createLoginsBtn = SizedBox(
      height: isSmall ? 32 : 36,
      child: FilledButton.icon(
        onPressed: _busyBulkLogins ? null : _onCreateLoginsForAllDrivers,
        icon: _busyBulkLogins
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.vpn_key_outlined, size: 18),
        label: Text(
          t.t('drivers_hub_create_login_for_all'),
          style: TextStyle(fontSize: isSmall ? 11 : 13),
        ),
      ),
    );

    return Column(
      children: [
        // 🔹 Top controls: stacked on narrow screens
        if (isNarrowControls)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              searchField,
              const SizedBox(height: 10),
              sortField,
              const SizedBox(height: 10),
              passwordField,
              const SizedBox(height: 10),
              SizedBox(width: double.infinity, child: createLoginsBtn),
            ],
          )
        else
          Row(
            children: [
              Expanded(flex: 3, child: searchField),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: sortField),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: passwordField),
              const SizedBox(width: 12),
              createLoginsBtn,
            ],
          ),
        const SizedBox(height: 16),

        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(_uid!)
                .collection('drivers')
                .orderBy('transporterId')
                .snapshots(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Center(
                  child: Text(
                    t.tf('admin_home_error_generic', {
                      'error': '${snap.error}',
                    }),
                  ),
                );
              }

              final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
                  (snap.data?.docs ??
                          <QueryDocumentSnapshot<Map<String, dynamic>>>[])
                      .toList();

              List<QueryDocumentSnapshot<Map<String, dynamic>>> filtered = docs;
              if (_search.isNotEmpty) {
                filtered = docs.where((d) {
                  final data = d.data();
                  final name = (data['driverName'] ?? '')
                      .toString()
                      .toLowerCase();
                  final email = (data['email'] ?? '').toString().toLowerCase();
                  return name.contains(_search) || email.contains(_search);
                }).toList();
              }

              if (_driverSort == _DriverSort.pending) {
                filtered = filtered.where((d) {
                  final data = d.data();
                  final onboardingRaw = data['onboarding'];
                  final hasOnboarding =
                      onboardingRaw is Map && onboardingRaw.isNotEmpty;
                  return !hasOnboarding;
                }).toList();
              } else if (_driverSort == _DriverSort.approved) {
                filtered = filtered.where((d) {
                  final data = d.data();
                  final onboardingRaw = data['onboarding'];
                  final hasOnboarding =
                      onboardingRaw is Map && onboardingRaw.isNotEmpty;
                  final active = (data['active'] as bool?) ?? true;
                  return hasOnboarding && active;
                }).toList();
              } else if (_driverSort == _DriverSort.rejected) {
                filtered = filtered.where((d) {
                  final data = d.data();
                  final onboardingRaw = data['onboarding'];
                  final hasOnboarding =
                      onboardingRaw is Map && onboardingRaw.isNotEmpty;
                  final active = (data['active'] as bool?) ?? true;
                  return hasOnboarding && !active;
                }).toList();
              }

              filtered.sort((a, b) {
                final ad = a.data();
                final bd = b.data();

                final aName = (ad['driverName'] ?? '').toString().toLowerCase();
                final bName = (bd['driverName'] ?? '').toString().toLowerCase();
                final aId = (ad['transporterId'] ?? a.id)
                    .toString()
                    .toUpperCase();
                final bId = (bd['transporterId'] ?? b.id)
                    .toString()
                    .toUpperCase();

                DateTime? asDate(dynamic v) {
                  if (v is Timestamp) return v.toDate();
                  if (v is DateTime) return v;
                  return null;
                }

                final aCreated = asDate(ad['createdAt']);
                final bCreated = asDate(bd['createdAt']);

                int byId() => aId.compareTo(bId);
                int byName() {
                  final c = aName.compareTo(bName);
                  return c == 0 ? byId() : c;
                }

                switch (_driverSort) {
                  case _DriverSort.newest:
                    if (aCreated == null && bCreated == null) return byId();
                    if (aCreated == null) return 1;
                    if (bCreated == null) return -1;
                    final c = bCreated.compareTo(aCreated);
                    return c == 0 ? byId() : c;
                  case _DriverSort.oldest:
                    if (aCreated == null && bCreated == null) return byId();
                    if (aCreated == null) return 1;
                    if (bCreated == null) return -1;
                    final c = aCreated.compareTo(bCreated);
                    return c == 0 ? byId() : c;
                  case _DriverSort.nameAsc:
                    return byName();
                  case _DriverSort.nameDesc:
                    return -byName();
                  case _DriverSort.idAsc:
                    return byId();
                  case _DriverSort.pending:
                  case _DriverSort.approved:
                  case _DriverSort.rejected:
                    return byName();
                }
              });

              if (filtered.isEmpty) {
                return Center(
                  child: Text(
                    t.t('drivers_hub_no_drivers_yet'),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(_uid!)
                    .collection('scores')
                    .snapshots(),
                builder: (context, scoresSnap) {
                  final overallScores = _aggregateDriverOverallScores(
                    scoresSnap.data?.docs ?? const [],
                  );

                  // Single desktop-style layout for all sizes.
                  // On very small screens user can scroll horizontally if needed.
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
                                _headerCell(
                                  t.t('drivers_hub_header_profile'),
                                  flex: 5,
                                ),
                                _headerCell(
                                  t.t('drivers_hub_header_overall'),
                                  flex: 3,
                                ),
                                _headerCell(
                                  t.t('drivers_hub_header_status'),
                                  flex: 2,
                                ),
                                _headerCell(
                                  t.t('drivers_hub_header_working'),
                                  flex: 2,
                                ),
                                _headerCell(
                                  t.t('drivers_hub_header_login'),
                                  flex: 2,
                                ),
                                _headerCell(
                                  t.t('drivers_hub_header_action'),
                                  flex: 3,
                                  alignment: Alignment.centerRight,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ListView.separated(
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 6),
                              itemBuilder: (context, index) {
                            final d = filtered[index];
                            final data = d.data();
                            final name = (data['driverName'] ?? '').toString();
                            final email = (data['email'] ?? '').toString();
                            final transporterId = (data['transporterId'] ?? d.id)
                                .toString()
                                .trim()
                                .toUpperCase();
                            final hasLogin =
                                (data['hasLogin'] as bool?) ?? false;
                            final active = (data['active'] as bool?) ?? true;

                            final onboardingRaw = data['onboarding'];
                            bool hasOnboarding = false;
                            if (onboardingRaw is Map &&
                                onboardingRaw.isNotEmpty) {
                              hasOnboarding = true;
                            }

                            final statusChip = _statusChipFromData(
                              data,
                              context,
                            );
                            final loginChip = _loginChipFromData(data, context);
                            final expiryChip = _expiryChipFromOnboardingRaw(
                              onboardingRaw,
                              context,
                            );

                            final profileImage = _profileImageFromOnboarding(
                              onboardingRaw,
                            );
                            final overallScore = overallScores[transporterId];

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                ),
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
                                    flex: 5,
                                    child: InkWell(
                                      onTap: () => _openDriverDetails(d),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 20,
                                            backgroundColor: const Color(
                                              0xFFE5E7EB,
                                            ),
                                            backgroundImage: profileImage,
                                            child: profileImage == null
                                                ? Text(
                                                    _initials(name),
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Color(0xFF111827),
                                                    ),
                                                  )
                                                : null,
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                name.isEmpty
                                                    ? t.t('dash_no_name')
                                                    : name,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF111827),
                                                ),
                                              ),
                                              if (email.isNotEmpty)
                                                Text(
                                                  email,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF6B7280),
                                                  ),
                                                ),
                                              if (hasOnboarding)
                                                Text(
                                                  t.t(
                                                    'drivers_hub_onboarding_completed',
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Color(0xFF9CA3AF),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: _buildOverallScoreCell(
                                      data: overallScore,
                                      t: t,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        statusChip,
                                        const SizedBox(height: 4),
                                        expiryChip,
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      children: [
                                        Switch(
                                          value: active,
                                          onChanged: (_) =>
                                              _onToggleActiveDriver(d, active),
                                          activeColor: const Color(0xFF2563EB),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          active
                                              ? t.t('drivers_hub_switch_on')
                                              : t.t('drivers_hub_switch_off'),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF4B5563),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(flex: 2, child: loginChip),
                                  Expanded(
                                    flex: 3,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          tooltip: t.t(
                                            'drivers_hub_tooltip_view_details',
                                          ),
                                          onPressed: () =>
                                              _openDriverDetails(d),
                                          icon: const Icon(
                                            Icons.remove_red_eye_outlined,
                                            size: 18,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: hasLogin
                                              ? t.t(
                                                  'drivers_hub_tooltip_reset_login',
                                                )
                                              : t.t(
                                                  'drivers_hub_tooltip_create_login',
                                                ),
                                          onPressed: () =>
                                              _onCreateOrResetLogin(d),
                                          icon: const Icon(
                                            Icons.vpn_key_outlined,
                                            size: 18,
                                            color: Color(0xFF2563EB),
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: t.t(
                                            'drivers_hub_tooltip_delete_driver',
                                          ),
                                          onPressed: () => _onDeleteDriver(d),
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            size: 18,
                                            color: Color(0xFFDC2626),
                                          ),
                                        ),
                                      ],
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
                      if (constraints.maxWidth < 860) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(width: 860, child: table),
                        );
                      }

                      return table;
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Small widgets & helpers
// ---------------------------------------------------------------------------

String _normalizeDriversHubWorkPermitType(
  dynamic raw, {
  dynamic fallbackExpiry,
}) {
  final value = (raw ?? '').toString().trim().toLowerCase();
  if (value.isEmpty) {
    final hasLegacyExpiry = (fallbackExpiry ?? '').toString().trim().isNotEmpty;
    return hasLegacyExpiry ? 'working_visa' : 'eu';
  }
  if (value == 'eu' || value == 'permit_eu_id' || value == 'eu_id') {
    return 'eu';
  }
  if (value == 'working_visa' ||
      value == 'work_visa' ||
      value == 'permit_work_visa' ||
      value == 'visa') {
    return 'working_visa';
  }
  return value;
}

bool _isDriversHubWorkingVisaPermitType(dynamic raw, {dynamic fallbackExpiry}) {
  return _normalizeDriversHubWorkPermitType(
        raw,
        fallbackExpiry: fallbackExpiry,
      ) ==
      'working_visa';
}

String _driversHubWorkPermitTypeLabel(
  AppLocalizations t,
  dynamic raw, {
  dynamic fallbackExpiry,
}) {
  switch (_normalizeDriversHubWorkPermitType(
    raw,
    fallbackExpiry: fallbackExpiry,
  )) {
    case 'working_visa':
      return t.t('drivers_hub_work_permit_working_visa');
    case 'eu':
    default:
      return t.t('drivers_hub_work_permit_eu');
  }
}

class _DriverActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _DriverActionButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 800;

    final double vPad = isSmall ? 6 : 10;
    final double hPad = isSmall ? 10 : 14;
    final double fontSize = isSmall ? 11 : 13;

    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
        minimumSize: Size(0, isSmall ? 30 : 36),
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _DriverSortPill extends StatelessWidget {
  final bool isSmall;
  final String valueLabel;
  final ValueChanged<_DriverSort> onSelected;

  const _DriverSortPill({
    required this.isSmall,
    required this.valueLabel,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    const borderColor = Color(0xFF1D7F5A);
    final height = isSmall ? 36.0 : 40.0;

    return SizedBox(
      height: height,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: borderColor, width: 1.4),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            popupMenuTheme: PopupMenuThemeData(
              color: Colors.white,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
          ),
          child: PopupMenuButton<_DriverSort>(
            tooltip: '',
            splashRadius: 18,
            onSelected: onSelected,
            offset: const Offset(0, 38),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: _DriverSort.newest,
                child: Text(t.t('drivers_hub_sort_newest')),
              ),
              PopupMenuItem(
                value: _DriverSort.oldest,
                child: Text(t.t('drivers_hub_sort_oldest')),
              ),
              PopupMenuItem(
                value: _DriverSort.nameAsc,
                child: Text(t.t('drivers_hub_sort_name_asc')),
              ),
              PopupMenuItem(
                value: _DriverSort.nameDesc,
                child: Text(t.t('drivers_hub_sort_name_desc')),
              ),
              PopupMenuItem(
                value: _DriverSort.idAsc,
                child: Text(t.t('drivers_hub_sort_id_asc')),
              ),
              PopupMenuItem(
                value: _DriverSort.pending,
                child: Text(t.t('drivers_hub_sort_pending')),
              ),
              PopupMenuItem(
                value: _DriverSort.approved,
                child: Text(t.t('drivers_hub_sort_approved')),
              ),
              PopupMenuItem(
                value: _DriverSort.rejected,
                child: Text(t.t('drivers_hub_sort_rejected')),
              ),
            ],
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Text(
                    valueLabel.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      letterSpacing: 0.6,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: Colors.black87,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Small reusable row with label, selectable value, and copy button
class _CopyRow extends StatelessWidget {
  final String label;
  final String value;

  const _CopyRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: SelectableText(
            '$label: $value',
            style: const TextStyle(fontSize: 14),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy, size: 18),
          tooltip: t.tf('drivers_hub_copy_label', {'label': label}),
          onPressed: () async {
            if (value.isEmpty) return;
            await Clipboard.setData(ClipboardData(text: value));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  t.tf('drivers_hub_label_copied', {'label': label}),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _AdminDriverToolsRow extends StatelessWidget {
  final VoidCallback onUploadDoc;

  const _AdminDriverToolsRow({required this.onUploadDoc});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Row(
      children: [
        Text(
          t.t('drivers_hub_admin_tools'),
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
        ),
        const Spacer(),
        FilledButton.icon(
          onPressed: onUploadDoc,
          icon: const Icon(Icons.upload_outlined, size: 18),
          label: Text(t.t('drivers_hub_upload_doc')),
        ),
      ],
    );
  }
}

class _DriverDocumentsList extends StatelessWidget {
  final DocumentReference<Map<String, dynamic>> driverRef;
  final String driverName;
  final Future<void> Function(String docType) onUploadDoc;

  const _DriverDocumentsList({
    required this.driverRef,
    required this.driverName,
    required this.onUploadDoc,
  });

  String _docLabel(BuildContext context, String docType) {
    final t = AppLocalizations.of(context);
    switch (docType) {
      case 'resident_permit':
        return t.t('work_permit');
      case 'driver_license_front':
        return t.t('driver_license_front');
      case 'driver_license_back':
        return t.t('driver_license_back');
      case 'id_card_front':
        return t.t('id_card_front');
      case 'id_card_back':
        return t.t('id_card_back');
      case 'passport_front':
        return t.t('passport_front');
      case 'passport_back':
        return t.t('passport_back');
      case 'tax_id':
        return t.t('doc_tax_id');
      case 'insurance':
        return t.t('doc_insurance');
      case 'contract':
        return t.t('admin_home_contract');
      default:
        return docType;
    }
  }

  String _fileExtension(String name) {
    final dot = name.lastIndexOf('.');
    if (dot == -1 || dot == name.length - 1) return '';
    return name.substring(dot + 1);
  }

  String _sanitizeToken(String value) {
    return value
        .trim()
        .replaceAll(RegExp(r'\s*/\s*'), '_')
        .replaceAll(RegExp(r'[()]'), '')
        .replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }

  String _downloadNameForDoc({
    required BuildContext context,
    required String docType,
    required String url,
    required String fileName,
  }) {
    final label = _docLabel(context, docType);
    var base = _sanitizeToken(label);
    if (base.isEmpty) base = _sanitizeToken(docType);
    final driver = _sanitizeToken(driverName);
    if (driver.isNotEmpty) {
      base = '${base}_$driver';
    }

    var ext = fileName.isNotEmpty ? _fileExtension(fileName) : '';
    if (ext.isEmpty) {
      final path = Uri.tryParse(url)?.path ?? '';
      ext = _fileExtension(path.split('/').last);
    }
    return ext.isEmpty ? base : '$base.$ext';
  }

  Future<void> _downloadDoc({
    required BuildContext context,
    required String url,
    required String fileName,
  }) async {
    if (url.isEmpty) return;
    if (kIsWeb) {
      try {
        final bytes = await fb.FirebaseStorage.instance
            .refFromURL(url)
            .getData(50 * 1024 * 1024);
        if (bytes != null) {
          await downloadWebBytes(bytes, fileName);
          return;
        }
      } catch (_) {
        // Fall back to URL download when blob access is blocked.
      }
    }
    try {
      await downloadWebFile(url, fileName);
    } catch (e) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              ).t('drivers_hub_could_not_launch_document_url'),
            ),
          ),
        );
      }
    }
  }

  Future<void> _deleteDoc({
    required BuildContext context,
    required String docType,
    required String url,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        final t = AppLocalizations.of(ctx);
        return AlertDialog(
          title: Text(t.t('drivers_hub_delete_document_title')),
          content: Text(
            t.tf('drivers_hub_delete_document_body', {
              'document': _docLabel(ctx, docType),
            }),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(t.t('admin_home_cancel')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48),
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(t.t('admin_home_delete')),
            ),
          ],
        );
      },
    );

    if (ok != true) return;

    try {
      if (url.isNotEmpty) {
        await fb.FirebaseStorage.instance.refFromURL(url).delete();
      }
      await driverRef.collection('documents').doc(docType).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).tf('drivers_hub_document_deleted', {
              'document': _docLabel(context, docType),
            }),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(
              context,
            ).tf('drivers_hub_failed_delete_document', {'error': '$e'}),
          ),
        ),
      );
    }
  }

  Future<void> _showDocPreview({
    required BuildContext context,
    required String docType,
    required String label,
    required String url,
    required String fileName,
  }) async {
    if (url.isEmpty) return;

    final uri = Uri.parse(url);
    final path = uri.path.toLowerCase();
    final normalizedFileName = fileName.toLowerCase();
    final isImage =
        normalizedFileName.endsWith('.png') ||
        normalizedFileName.endsWith('.jpg') ||
        normalizedFileName.endsWith('.jpeg') ||
        normalizedFileName.endsWith('.webp') ||
        path.endsWith('.png') ||
        path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.webp');
    final isPdf =
        normalizedFileName.endsWith('.pdf') || path.endsWith('.pdf');

    if (isImage) {
      await showDialog<void>(
        context: context,
        builder: (ctx) {
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 500),
                    child: InteractiveViewer(
                      child: kIsWeb
                          ? buildWebImagePreview(url)
                          : Image.network(
                              url,
                              fit: BoxFit.contain,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) {
                                final t = AppLocalizations.of(context);
                                return Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        t.t(
                                          'drivers_hub_preview_unavailable_image',
                                        ),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      OutlinedButton(
                                        onPressed: () => _downloadDoc(
                                          context: context,
                                          url: url,
                                          fileName: _downloadNameForDoc(
                                            context: context,
                                            docType: docType,
                                            url: url,
                                            fileName: fileName,
                                          ),
                                        ),
                                        child: Text(
                                          t.t('drivers_hub_download'),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
      return;
    }

    if (isPdf) {
      if (kIsWeb) {
        await showDialog<void>(
          context: context,
          builder: (ctx) {
            final t = AppLocalizations.of(ctx);
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 520,
                      child: FutureBuilder<Uint8List?>(
                        future: () async {
                          try {
                            final bytes = await fb.FirebaseStorage.instance
                                .refFromURL(url)
                                .getData(50 * 1024 * 1024);
                            if (bytes != null) return bytes;
                          } catch (_) {
                            // Fall through to URL fetch.
                          }
                          try {
                            final data = await NetworkAssetBundle(uri).load('');
                            return data.buffer.asUint8List();
                          } catch (_) {
                            return null;
                          }
                        }(),
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          }
                          if (snap.hasError || snap.data == null) {
                            return Center(
                              child: Text(
                                t.t('drivers_hub_failed_load_pdf_preview'),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            );
                          }
                          return SfPdfViewer.memory(
                            snap.data!,
                            canShowPaginationDialog: false,
                            canShowScrollHead: true,
                            canShowScrollStatus: true,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => _downloadDoc(
                          context: context,
                          url: url,
                          fileName: _downloadNameForDoc(
                            context: context,
                            docType: docType,
                            url: url,
                            fileName: fileName,
                          ),
                        ),
                        icon: const Icon(Icons.download_outlined, size: 16),
                        label: Text(t.t('drivers_hub_download')),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
        return;
      }

      await showDialog<void>(
        context: context,
        builder: (ctx) {
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 520,
                    child: FutureBuilder<Uint8List?>(
                      future: () async {
                        try {
                          final bytes = await fb.FirebaseStorage.instance
                              .refFromURL(url)
                              .getData(50 * 1024 * 1024);
                          if (bytes != null) return bytes;
                        } catch (_) {
                          // Fall through to URL fetch.
                        }
                        try {
                          final data = await NetworkAssetBundle(uri).load('');
                          return data.buffer.asUint8List();
                        } catch (_) {
                          return null;
                        }
                      }(),
                      builder: (context, snap) {
                        final t = AppLocalizations.of(context);
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        }
                        if (snap.hasError || snap.data == null) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  t.t('drivers_hub_failed_load_pdf_preview'),
                                ),
                                const SizedBox(height: 8),
                                OutlinedButton(
                                  onPressed: () => _downloadDoc(
                                    context: context,
                                    url: url,
                                    fileName: _downloadNameForDoc(
                                      context: context,
                                      docType: docType,
                                      url: url,
                                      fileName: fileName,
                                    ),
                                  ),
                                  child: Text(t.t('drivers_hub_download')),
                                ),
                              ],
                            ),
                          );
                        }
                        return PdfPreview(
                          build: (format) async => snap.data!,
                          canChangeOrientation: false,
                          canChangePageFormat: false,
                          allowPrinting: false,
                          allowSharing: false,
                          useActions: false,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        final t = AppLocalizations.of(ctx);
        return AlertDialog(
          title: Text(label),
          content: Text(t.t('drivers_hub_preview_not_available')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(t.t('admin_home_close')),
            ),
            ElevatedButton(
              onPressed: () async {
                await _downloadDoc(
                  context: context,
                  url: url,
                  fileName: _downloadNameForDoc(
                    context: context,
                    docType: docType,
                    url: url,
                    fileName: fileName,
                  ),
                );
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
              child: Text(t.t('drivers_hub_download')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: driverRef
          .collection('documents')
          .orderBy('uploadedAt', descending: true)
          .snapshots(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: LinearProgressIndicator(minHeight: 2),
          );
        }

        final docs = snap.data?.docs ?? [];
        final docsByType = <String, Map<String, dynamic>>{
          for (final d in docs)
            (d.data()['docType'] ?? d.id).toString(): d.data(),
        };

        const docTypes = <String>[
          'contract',
          'resident_permit',
          'tax_id',
          'insurance',
        ];

        const docPairs = <List<String>>[
          ['id_card_front', 'id_card_back'],
          ['passport_front', 'passport_back'],
          ['driver_license_front', 'driver_license_back'],
        ];

        Widget docTile(String docType) {
          final t = AppLocalizations.of(context);
          final data = docsByType[docType] ?? const <String, dynamic>{};
          final name = (data['fileName'] ?? t.t('drivers_hub_not_uploaded'))
              .toString();
          final url = (data['downloadUrl'] ?? '').toString();
          final hasUrl = url.isNotEmpty;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: !hasUrl
                  ? null
                  : () => _showDocPreview(
                      context: context,
                      docType: docType,
                      label: _docLabel(context, docType),
                      url: url,
                      fileName: name,
                    ),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8F8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE1E4EA)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.insert_drive_file, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _docLabel(context, docType),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF374151),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            name,
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
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => onUploadDoc(docType),
                      icon: const Icon(Icons.upload_outlined, size: 16),
                      label: Text(t.t('upload')),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      icon: const Icon(Icons.download, size: 18),
                      tooltip: t.t('drivers_hub_download'),
                      onPressed: !hasUrl
                          ? null
                          : () => _downloadDoc(
                              context: context,
                              url: url,
                              fileName: _downloadNameForDoc(
                                context: context,
                                docType: docType,
                                url: url,
                                fileName: name,
                              ),
                            ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      tooltip: t.t('admin_home_delete'),
                      onPressed: !hasUrl
                          ? null
                          : () => _deleteDoc(
                              context: context,
                              docType: docType,
                              url: url,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).t('drivers_hub_documents'),
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            const SizedBox(height: 6),
            ...docTypes.map((docType) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: docTile(docType),
              );
            }),
            ...docPairs.map((pair) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(child: docTile(pair[0])),
                    const SizedBox(width: 10),
                    Expanded(child: docTile(pair[1])),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

// helpers for Dribbble-style layout

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  final firstTwo = parts.take(2).toList();
  if (firstTwo.isEmpty) return '?';
  if (firstTwo.length == 1) {
    return firstTwo.first.characters.first.toUpperCase();
  }
  return (firstTwo[0].characters.first + firstTwo[1].characters.first)
      .toUpperCase();
}

Widget _headerCell(
  String text, {
  int flex = 1,
  Alignment alignment = Alignment.centerLeft,
}) {
  return Expanded(
    flex: flex,
    child: Align(
      alignment: alignment,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6B7280),
        ),
      ),
    ),
  );
}

Widget _statusChipFromData(Map<String, dynamic> data, BuildContext context) {
  final t = AppLocalizations.of(context);
  final active = (data['active'] as bool?) ?? true;
  final onboardingRaw = data['onboarding'];
  final hasOnboarding = onboardingRaw is Map && onboardingRaw.isNotEmpty;

  String label;
  Color bg;
  Color fg;

  if (!hasOnboarding) {
    label = t.t('drivers_hub_status_pending');
    bg = const Color(0xFFFDE68A);
    fg = const Color(0xFF92400E);
  } else if (active) {
    label = t.t('drivers_hub_status_approved');
    bg = const Color(0xFFD1FAE5);
    fg = const Color(0xFF065F46);
  } else {
    label = t.t('drivers_hub_status_rejected');
    bg = const Color(0xFFFEE2E2);
    fg = const Color(0xFF991B1B);
  }

  return Align(
    alignment: Alignment.centerLeft,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg),
      ),
    ),
  );
}

Widget _loginChipFromData(Map<String, dynamic> data, BuildContext context) {
  final t = AppLocalizations.of(context);
  final hasLogin = (data['hasLogin'] as bool?) ?? false;

  final label = hasLogin
      ? t.t('drivers_hub_login_created')
      : t.t('drivers_hub_no_login');
  final bg = hasLogin ? const Color(0xFFDCFCE7) : const Color(0xFFE5E7EB);
  final fg = hasLogin ? const Color(0xFF166534) : const Color(0xFF4B5563);

  return Align(
    alignment: Alignment.centerLeft,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Expiry helper + chip (licence / residence permit)
// ---------------------------------------------------------------------------

DateTime? _parseIsoDate(String? value) {
  final t = value?.trim();
  if (t == null || t.isEmpty) return null;
  final slashMatch = RegExp(r'^(\d{1,2})\/(\d{1,2})\/(\d{4})$');
  final match = slashMatch.firstMatch(t);
  if (match != null) {
    final d = int.tryParse(match.group(1)!);
    final m = int.tryParse(match.group(2)!);
    final y = int.tryParse(match.group(3)!);
    if (d != null && m != null && y != null) {
      return DateTime(y, m, d);
    }
  }
  try {
    return DateTime.parse(t);
  } catch (_) {
    return null;
  }
}

DateTime _addMonthsClamped(DateTime date, int months) {
  final totalMonths = (date.month - 1) + months;
  final year = date.year + (totalMonths ~/ 12);
  final month = (totalMonths % 12) + 1;
  final lastDay = DateTime(year, month + 1, 0).day;
  final day = date.day <= lastDay ? date.day : lastDay;
  return DateTime(year, month, day);
}

DateTime? _probationEndFromStart(DateTime? start) {
  if (start == null) return null;
  final sixMonthsLater = _addMonthsClamped(start, 6);
  return sixMonthsLater.subtract(const Duration(days: 1));
}

const int _kProbezeitExpiredGraceDays = 7;

bool _isProbezeitExpiredWithinGrace(DateTime probationEnd, DateTime today) {
  final daysSinceEnd = today.difference(probationEnd).inDays;
  return daysSinceEnd >= 1 && daysSinceEnd <= _kProbezeitExpiredGraceDays;
}

/// Returns 'expired', 'soon', or null
String? _expiryFlag(String? date1, String? date2) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  bool anyExpired = false;
  bool anySoon = false;

  void check(String? s) {
    final d = _parseIsoDate(s);
    if (d == null) return;
    final diff = d.difference(today).inDays;
    if (diff < 0) {
      anyExpired = true;
    } else if (diff <= 30) {
      anySoon = true;
    }
  }

  check(date1);
  check(date2);

  if (anyExpired) return 'expired';
  if (anySoon) return 'soon';
  return null;
}

Widget _expiryChipFromOnboardingRaw(
  dynamic onboardingRaw,
  BuildContext context,
) {
  final t = AppLocalizations.of(context);
  Map<String, dynamic> onboarding = const {};
  if (onboardingRaw is Map<String, dynamic>) {
    onboarding = onboardingRaw;
  } else if (onboardingRaw is Map) {
    onboarding = onboardingRaw.map((k, v) => MapEntry(k.toString(), v));
  }

  if (onboarding.isEmpty) return const SizedBox.shrink();

  final contractDate = _parseIsoDate(onboarding['contractExpiry']?.toString());
  final probationEnd = _probationEndFromStart(
    _parseIsoDate(onboarding['workStartDate']?.toString()),
  );
  final workPermitType = _normalizeDriversHubWorkPermitType(
    onboarding['workPermitType'],
    fallbackExpiry: onboarding['residencePermitExpiry'],
  );
  final workVisaDate =
      _isDriversHubWorkingVisaPermitType(
        workPermitType,
        fallbackExpiry: onboarding['residencePermitExpiry'],
      )
      ? _parseIsoDate(
          (onboarding['workVisaExpiry'] ?? onboarding['residencePermitExpiry'])
              ?.toString(),
        )
      : null;
  final zusatzblattDate =
      _isDriversHubWorkingVisaPermitType(
        workPermitType,
        fallbackExpiry: onboarding['residencePermitExpiry'],
      )
      ? _parseIsoDate(onboarding['zusatzblattExpiry']?.toString())
      : null;
  final licenseDate = _parseIsoDate(onboarding['licenseExpiry']?.toString());
  final idDocDate = _parseIsoDate(onboarding['idDocExpiry']?.toString());

  if (contractDate == null &&
      workVisaDate == null &&
      zusatzblattDate == null &&
      licenseDate == null &&
      idDocDate == null &&
      probationEnd == null) {
    return const SizedBox.shrink();
  }

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  int expiredCount = 0;
  int soonCount = 0;
  bool pExpired = false;
  bool pSoon = false;

  void check(DateTime? d) {
    if (d == null) return;
    final diff = d.difference(today).inDays;
    if (diff < 0) {
      expiredCount++;
    } else if (diff <= 30) {
      soonCount++;
    }
  }

  check(contractDate);
  check(workVisaDate);
  check(zusatzblattDate);
  check(licenseDate);
  check(idDocDate);
  if (probationEnd != null) {
    final diff = probationEnd.difference(today).inDays;
    if (_isProbezeitExpiredWithinGrace(probationEnd, today)) {
      pExpired = true;
      expiredCount++;
    } else if (diff >= 0 && diff <= 30) {
      pSoon = true;
      soonCount++;
    }
  }

  if (expiredCount == 0 && soonCount == 0) return const SizedBox.shrink();

  late String label;
  late Color bg;
  late Color fg;

  if (expiredCount > 0) {
    final onlyProbation = pExpired && expiredCount == 1 && soonCount == 0;
    label = onlyProbation
        ? t.t('drivers_hub_probezeit_expired')
        : t.tf('drivers_hub_documents_expired', {'count': '$expiredCount'});
    bg = const Color(0xFFFEE2E2);
    fg = const Color(0xFF991B1B);
  } else {
    final onlyProbation = pSoon && soonCount == 1;
    label = onlyProbation
        ? t.t('drivers_hub_probezeit_expiring_soon')
        : t.tf('drivers_hub_documents_expiring_soon', {'count': '$soonCount'});
    bg = const Color(0xFFFFEDD5);
    fg = const Color(0xFF9A3412);
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg),
    ),
  );
}

String _joinNames(List<String> names, BuildContext context) {
  final t = AppLocalizations.of(context);
  if (names.isEmpty) return '';
  if (names.length == 1) return names[0];
  if (names.length == 2) {
    return t.tf('drivers_hub_join_two', {'a': names[0], 'b': names[1]});
  }
  return names.join(', ');
}

Widget _expiryChipDetailedFromOnboardingRaw(
  dynamic onboardingRaw,
  BuildContext context,
) {
  final t = AppLocalizations.of(context);
  Map<String, dynamic> onboarding = const {};
  if (onboardingRaw is Map<String, dynamic>) {
    onboarding = onboardingRaw;
  } else if (onboardingRaw is Map) {
    onboarding = onboardingRaw.map((k, v) => MapEntry(k.toString(), v));
  }

  if (onboarding.isEmpty) return const SizedBox.shrink();

  final contractDate = _parseIsoDate(onboarding['contractExpiry']?.toString());
  final probationEnd = _probationEndFromStart(
    _parseIsoDate(onboarding['workStartDate']?.toString()),
  );
  final workPermitType = _normalizeDriversHubWorkPermitType(
    onboarding['workPermitType'],
    fallbackExpiry: onboarding['residencePermitExpiry'],
  );
  final workVisaDate =
      _isDriversHubWorkingVisaPermitType(
        workPermitType,
        fallbackExpiry: onboarding['residencePermitExpiry'],
      )
      ? _parseIsoDate(
          (onboarding['workVisaExpiry'] ?? onboarding['residencePermitExpiry'])
              ?.toString(),
        )
      : null;
  final zusatzblattDate =
      _isDriversHubWorkingVisaPermitType(
        workPermitType,
        fallbackExpiry: onboarding['residencePermitExpiry'],
      )
      ? _parseIsoDate(onboarding['zusatzblattExpiry']?.toString())
      : null;
  final licenseDate = _parseIsoDate(onboarding['licenseExpiry']?.toString());
  final idDocDate = _parseIsoDate(onboarding['idDocExpiry']?.toString());

  if (contractDate == null &&
      workVisaDate == null &&
      zusatzblattDate == null &&
      licenseDate == null &&
      idDocDate == null &&
      probationEnd == null) {
    return const SizedBox.shrink();
  }

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  bool cExpired = false, cSoon = false;
  bool wvExpired = false, wvSoon = false;
  bool zbExpired = false, zbSoon = false;
  bool licExpired = false, licSoon = false;
  bool idExpired = false, idSoon = false;
  bool pExpired = false, pSoon = false;

  void check(
    DateTime? d,
    void Function() markExpired,
    void Function() markSoon,
  ) {
    if (d == null) return;
    final diff = d.difference(today).inDays;
    if (diff < 0) {
      markExpired();
    } else if (diff <= 30) {
      markSoon();
    }
  }

  check(contractDate, () => cExpired = true, () => cSoon = true);
  check(workVisaDate, () => wvExpired = true, () => wvSoon = true);
  check(zusatzblattDate, () => zbExpired = true, () => zbSoon = true);
  check(licenseDate, () => licExpired = true, () => licSoon = true);
  check(idDocDate, () => idExpired = true, () => idSoon = true);
  if (probationEnd != null) {
    final diff = probationEnd.difference(today).inDays;
    if (_isProbezeitExpiredWithinGrace(probationEnd, today)) {
      pExpired = true;
    } else if (diff >= 0 && diff <= 30) {
      pSoon = true;
    }
  }

  final expiredDocs = <String>[];
  final soonDocs = <String>[];

  if (cExpired) expiredDocs.add(t.t('drivers_hub_expiry_contract'));
  if (wvExpired) expiredDocs.add(t.t('drivers_hub_expiry_work_visa'));
  if (zbExpired) expiredDocs.add(t.t('drivers_hub_expiry_zusatzblatt'));
  if (licExpired) expiredDocs.add(t.t('drivers_hub_expiry_driving_license'));
  if (idExpired) expiredDocs.add(t.t('drivers_hub_expiry_id_passport'));
  if (pExpired) expiredDocs.add(t.t('drivers_hub_expiry_probezeit'));

  if (!cExpired && cSoon) soonDocs.add(t.t('drivers_hub_expiry_contract'));
  if (!wvExpired && wvSoon) soonDocs.add(t.t('drivers_hub_expiry_work_visa'));
  if (!zbExpired && zbSoon) soonDocs.add(t.t('drivers_hub_expiry_zusatzblatt'));
  if (!licExpired && licSoon) {
    soonDocs.add(t.t('drivers_hub_expiry_driving_license'));
  }
  if (!idExpired && idSoon) soonDocs.add(t.t('drivers_hub_expiry_id_passport'));
  if (!pExpired && pSoon) soonDocs.add(t.t('drivers_hub_expiry_probezeit'));

  if (expiredDocs.isEmpty && soonDocs.isEmpty) return const SizedBox.shrink();

  Widget pill(String label, {required Color bg, required Color fg}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }

  // Build separate pills (red + orange), stacked neatly
  final pills = <Widget>[];

  if (expiredDocs.isNotEmpty) {
    pills.add(
      pill(
        t.tf('drivers_hub_expiry_items_expired', {
          'items': _joinNames(expiredDocs, context),
        }),
        bg: const Color(0xFFFEE2E2),
        fg: const Color(0xFF991B1B),
      ),
    );
  }

  if (soonDocs.isNotEmpty) {
    pills.add(
      pill(
        t.tf('drivers_hub_expiry_items_expiring_soon', {
          'items': _joinNames(soonDocs, context),
        }),
        bg: const Color(0xFFFFEDD5),
        fg: const Color(0xFF9A3412),
      ),
    );
  }

  if (pills.length == 1) return pills.first;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [pills[0], const SizedBox(height: 6), pills[1]],
  );
}

// ---------------------------------------------------------------------------
// Profile image helper (from onboarding.profilePhotoBase64)
// ---------------------------------------------------------------------------

ImageProvider? _profileImageFromOnboarding(dynamic onboardingRaw) {
  if (onboardingRaw == null) return null;

  Map<String, dynamic> onboarding;

  if (onboardingRaw is Map<String, dynamic>) {
    onboarding = onboardingRaw;
  } else if (onboardingRaw is Map) {
    onboarding = onboardingRaw.map((k, v) => MapEntry(k.toString(), v));
  } else {
    return null;
  }

  final val = onboarding['profilePhotoBase64'];
  if (val == null) return null;
  final s = val.toString();
  if (s.isEmpty) return null;

  try {
    final bytes = base64Decode(s);
    return MemoryImage(bytes);
  } catch (_) {
    return null;
  }
}
