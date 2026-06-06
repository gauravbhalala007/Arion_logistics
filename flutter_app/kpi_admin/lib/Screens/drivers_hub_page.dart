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
import 'package:http/http.dart' as http;

import '../localization/app_localizations.dart';
import '../models/driver_contract_type.dart';
import 'add_driver_dialog.dart';
import 'driver_residence_permit_form_page.dart';
import '../services/driver_csv.dart';
import '../services/driver_export_service.dart';
import '../widgets/admin_scope.dart';
import '../widgets/web_preview.dart'
    if (dart.library.html) '../widgets/web_preview_web.dart';
import '../widgets/notification_pin_dialogs.dart';

// Keep this out of source control by passing --dart-define=DEFAULT_DRIVER_PASSWORD=...
const String kDefaultDriverPassword = String.fromEnvironment(
  'DEFAULT_DRIVER_PASSWORD',
  defaultValue: '',
);

enum _DriverSort {
  newest,
  oldest,
  nameAsc,
  nameDesc,
  idAsc,
  statusActive,
  scoreLowToHigh,
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

  /// Wirksamer Admin-Namespace für alle Reads/Writes. Dispatcher liefern
  /// hier die UID ihres Parent-Admin zurück (über `AdminScope`); Admins
  /// fallen auf ihre eigene UID zurück.
  String? get _uid {
    final scoped = AdminScope.maybeOf(context)?.adminUid;
    if (scoped != null && scoped.isNotEmpty) return scoped;
    return _user?.uid;
  }

  bool _busyCsv = false;
  bool _busyList = false;
  // Export-Status für den ZIP-Download aller Fahrer-Stammdaten + Dokumente.
  bool _busyExport = false;
  String _exportProgress = '';

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
  // null = no filter; if filtering on "Unset", use the special sentinel.
  DriverContractType? _contractFilter;
  bool _filterUnsetContract = false;
  /// "Parttime" group filter — when active, all 2d / 3d / 4d part-time
  /// drivers are shown together (the three buckets were merged into a
  /// single summary tile per admin request).
  bool _filterParttimeGroup = false;

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
      case _DriverSort.statusActive:
        return 'Status (active first)';
      case _DriverSort.scoreLowToHigh:
        return 'Overall Score (low → high)';
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
          const SizedBox(height: 14),
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

    return _DetailRow(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 160,
            child: SelectableText(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: SelectableText(
                    hasText ? displayText : '—',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: hasText
                          ? const Color(0xFF111827)
                          : const Color(0xFFCBD5E1),
                    ),
                  ),
                ),

                // ✏️ Edit
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints.tightFor(width: 28, height: 28),
                  visualDensity: VisualDensity.compact,
                  splashRadius: 16,
                  color: const Color(0xFF6B7280),
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
                if (hasText)
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints.tightFor(width: 28, height: 28),
                    visualDensity: VisualDensity.compact,
                    splashRadius: 16,
                    color: const Color(0xFF6B7280),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRowReadOnly({required String label, required String value}) {
    final hasText = value.trim().isNotEmpty;

    return _DetailRow(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 160,
            child: SelectableText(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: SelectableText(
                    hasText ? value : '—',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: hasText
                          ? const Color(0xFF111827)
                          : const Color(0xFFCBD5E1),
                    ),
                  ),
                ),
                if (hasText)
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints.tightFor(width: 28, height: 28),
                    visualDensity: VisualDensity.compact,
                    splashRadius: 16,
                    color: const Color(0xFF6B7280),
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            t.t('drivers_hub_title'),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: isSmall ? 22 : 26,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1F2937),
              letterSpacing: -0.4,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        _NewActionButton(
          busyCsv: _busyCsv,
          busyList: _busyList,
          busyBulkLogins: _busyBulkLogins,
          onAddDriver: () => _createDriverManually(),
          onImportCsv: () => _onImportCsv(),
          onCreateLoginsForAll: () => _onCreateLoginsForAllDrivers(),
          labelAdd: t.t('drivers_hub_add_driver'),
          labelImport: t.t('drivers_hub_import_csv'),
          labelLogins: t.t('drivers_hub_create_login_for_all'),
          labelNew: 'New',
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Export a single driver's stammdaten + documents as ZIP
  // ---------------------------------------------------------------------------

  Future<void> _exportDriver({
    required DocumentReference<Map<String, dynamic>> driverRef,
    required String driverName,
    required String transporterId,
  }) async {
    final t = AppLocalizations.of(context);
    final uid = _uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.t('drivers_hub_must_login_import_csv'))),
      );
      return;
    }

    setState(() {
      _busyExport = true;
      _exportProgress = '…';
    });

    try {
      final bytes = await DriverExportService().buildSingleDriverZip(
        adminUid: uid,
        driverRef: driverRef,
        onProgress: (p) {
          if (!mounted) return;
          final pct = p.docsTotal == 0
              ? 0
              : ((p.docsDone / p.docsTotal) * 100).round();
          setState(() => _exportProgress = '$pct %');
        },
      );

      final folder = DriverExportService.driverFolderName(
        driverName: driverName,
        transporterId: transporterId,
      );
      await downloadWebBytes(bytes, 'codriver_$folder.zip');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.t('drivers_hub_export_success'))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export fehlgeschlagen: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _busyExport = false;
          _exportProgress = '';
        });
      }
    }
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

    final defaultPwd = _bulkPwdCtrl.text.trim().isEmpty
        ? kDefaultDriverPassword
        : _bulkPwdCtrl.text.trim();

    final ok = await showAddDriverDialog(
      context: context,
      dspUid: _uid!,
      defaultPassword: defaultPwd,
    );
    if (!ok || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fahrer angelegt.')),
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

    // Visibility starts ON so the admin can see + edit the prefilled
    // default password. Eye-toggle hides it again if needed.
    bool pwdVisible = true;

    InputDecoration pwdDecoration(
      String label,
      void Function() onToggle,
      VoidCallback onClear,
    ) {
      final base = _pillInputDecoration(label);
      return base.copyWith(
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Feld leeren',
              icon: const Icon(Icons.close_rounded, size: 18),
              splashRadius: 18,
              color: const Color(0xFF6B7280),
              onPressed: onClear,
            ),
            IconButton(
              tooltip: pwdVisible
                  ? 'Passwort verbergen'
                  : 'Passwort anzeigen',
              icon: Icon(
                pwdVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
              ),
              splashRadius: 18,
              color: const Color(0xFF6B7280),
              onPressed: onToggle,
            ),
            const SizedBox(width: 4),
          ],
        ),
      );
    }

    // --- Custom dialog with white background + pill fields ---
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final width = MediaQuery.of(ctx).size.width;
        final dialogWidth = width < 480 ? width - 32 : 480.0;

        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            void togglePwdVisible() =>
                setStateDialog(() => pwdVisible = !pwdVisible);

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
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
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
                        decoration: pwdDecoration(
                          t.t('drivers_hub_password'),
                          togglePwdVisible,
                          () => setStateDialog(() {
                            pwdCtrl.clear();
                            pwd2Ctrl.clear();
                          }),
                        ),
                        obscureText: !pwdVisible,
                        autocorrect: false,
                        enableSuggestions: false,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: pwd2Ctrl,
                        decoration: pwdDecoration(
                          t.t('drivers_hub_confirm_password'),
                          togglePwdVisible,
                          () => setStateDialog(pwd2Ctrl.clear),
                        ),
                        obscureText: !pwdVisible,
                        autocorrect: false,
                        enableSuggestions: false,
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
      },
    );

    if (ok != true) return;

    final newTidRaw = tidCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final pwd = pwdCtrl.text.trim();
    final pwd2 = pwd2Ctrl.text.trim();

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
    final hasNewTid = newTid.isNotEmpty;
    // Only treat as "tidChanged" when both old and new TID are non-empty and
    // differ. Adding/removing a TID is handled via merge on the same doc id
    // (no doc move) since the original doc id may already be an auto-id.
    final tidChanged = hasNewTid && oldTid.isNotEmpty && newTid != oldTid;

    try {
      // Decide which document we will finally use
      DocumentReference<Map<String, dynamic>> targetRef = driverDoc.reference;

      if (tidChanged) {
        // move driver document to new TID-based ID
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
        // just update email + transporterId (if provided)
        await driverDoc.reference.set({
          'email': email,
          if (hasNewTid) 'transporterId': newTid,
          if (hasNewTid) 'tidPending': false,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      // Call function — pass driverDocId so it works for both TID-based
      // doc ids and auto-id docs without a TID.
      final callable = FirebaseFunctions.instance.httpsCallable(
        'createDriverLogin',
      );
      await callable.call(<String, dynamic>{
        'dspUid': _uid!,
        if (hasNewTid) 'transporterId': newTid,
        'driverDocId': targetRef.id,
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
              if (hasNewTid)
                _CopyRow(
                  label: t.t('drivers_hub_transporter_id'),
                  value: newTid,
                ),
              if (hasNewTid) const SizedBox(height: 8),
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
    final hasTid = (data['transporterId'] ?? '').toString().trim().isNotEmpty;
    final hasLogin = data['hasLogin'] == true;
    final authUid = (data['authUid'] ?? '').toString().trim();

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
      // Drei Fälle:
      //  1. Driver hat sowohl TID als auch Login → Cloud Function nutzen
      //     (löscht Auth-User + Firestore-Doc + users/{authUid})
      //  2. Driver hat noch keinen Login (frisch angelegt, kein Auth-Account)
      //     → direkt Firestore-Doc löschen, keine Cloud Function nötig
      //  3. Driver hat keine TID (Auto-ID-Doc) → ebenfalls Direkt-Delete,
      //     weil die Cloud Function den Doc-Pfad sonst nicht findet.
      final needsCloudFunction = hasTid && (hasLogin || authUid.isNotEmpty);

      if (needsCloudFunction) {
        final tid = (data['transporterId'] as String).trim();
        final callable = FirebaseFunctions.instance.httpsCallable(
          'deleteDriverAccount',
        );
        await callable.call(<String, dynamic>{
          'dspUid': _uid,
          'transporterId': tid,
        });
      } else {
        // Direkter Firestore-Delete für Fahrer ohne Auth-User.
        await driverDoc.reference.delete();
      }
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

        // Only create logins for drivers that don't already have one
        if (hasLogin) {
          skipped++;
          continue;
        }

        final tid = tidRaw.toUpperCase();
        final hasTid = tid.isNotEmpty;

        // ✅ Ensure driver has an email before calling the function
        final existingEmail = (data['email'] ?? '').toString().trim();
        String emailToUse = existingEmail;

        if (emailToUse.isEmpty && hasTid) {
          final driverName = (data['driverName'] ?? '').toString();
          emailToUse = _buildSuggestedDriverEmail(
            driverName: driverName,
            transporterId: tid,
          );
        }

        // Need either a real email or a TID to derive one.
        if (emailToUse.isEmpty) {
          skipped++;
          continue;
        }

        // ✅ Update driver doc FIRST (same behavior as single-driver flow)
        await d.reference.set({
          if (hasTid) 'transporterId': tid,
          'email': emailToUse,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Call function — pass driverDocId so the function can resolve
        // both legacy TID-as-doc-id and newer auto-id docs.
        await callable.call(<String, dynamic>{
          'dspUid': _uid!,
          if (hasTid) 'transporterId': tid,
          'driverDocId': d.id,
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

  /// Inline-Edit der Transporter ID — öffnet ein Bottom Sheet mit Textfeld,
  /// validiert das neue Format (Buchstaben + Zahlen, optional leer um die
  /// TID zu entfernen) und verschiebt das Driver-Doc bei Änderung auf die
  /// neue ID. Vermeidet einen Konflikt, falls die Ziel-TID schon existiert.
  Future<void> _editTransporterId(
    DocumentSnapshot<Map<String, dynamic>> driverDoc,
    String currentTid,
  ) async {
    final ctrl = TextEditingController(text: currentTid);
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
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
              const Text(
                'Transporter ID bearbeiten',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Die TID identifiziert den Fahrer in Amazon-Reports. '
                'Buchstaben + Zahlen, ohne Leerzeichen. Wird beim '
                'Speichern automatisch in Großbuchstaben gewandelt.',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: ctrl,
                autofocus: true,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'[A-Za-z0-9]'),
                  ),
                  LengthLimitingTextInputFormatter(32),
                ],
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'Transporter ID',
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF1D7F5A)),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Abbrechen'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () =>
                        Navigator.of(ctx).pop(ctrl.text.trim().toUpperCase()),
                    icon: const Icon(Icons.save_outlined, size: 18),
                    label: const Text('Speichern'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (result == null) return;
    final newTid = result;
    final oldTid = currentTid.trim().toUpperCase();
    if (newTid == oldTid) return; // nothing changed
    if (_uid == null) return;

    try {
      final driversCol = driverDoc.reference.parent;
      // Check that target TID is free.
      if (newTid.isNotEmpty) {
        final existing = await driversCol.doc(newTid).get();
        if (existing.exists && existing.id != driverDoc.id) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFFB42318),
              content: Text(
                'Ein anderer Fahrer benutzt die TID "$newTid" bereits.',
              ),
            ),
          );
          return;
        }
      }

      final data = Map<String, dynamic>.from(driverDoc.data() ?? {});
      data['transporterId'] = newTid;
      data['updatedAt'] = FieldValue.serverTimestamp();

      // If the doc ID matches the OLD TID, we want to move it to the
      // new TID-based ID. Otherwise (auto-id doc) we just patch the
      // transporterId field in place.
      final docIsTidBased = driverDoc.id.toUpperCase() == oldTid;
      if (docIsTidBased && newTid.isNotEmpty && newTid != oldTid) {
        await driversCol.doc(newTid).set(data, SetOptions(merge: true));
        await driverDoc.reference.delete();
      } else if (docIsTidBased && newTid.isEmpty) {
        // User cleared the TID — we keep the existing doc id (since it
        // matched OLD TID) but blank out the field.
        await driverDoc.reference.set({
          'transporterId': '',
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        await driverDoc.reference.set({
          'transporterId': newTid,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newTid.isEmpty
                ? 'Transporter ID entfernt.'
                : 'Transporter ID auf "$newTid" geändert.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFB42318),
          content: Text('Konnte TID nicht ändern: $e'),
        ),
      );
    }
  }

  Future<void> _showAdminUploadDocDialog(
    DocumentReference<Map<String, dynamic>> driverRef,
  ) async {
    final t = AppLocalizations.of(context);
    String selected = 'contract';
    bool busy = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx2, setLocal) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 12,
                bottom: MediaQuery.of(ctx2).viewInsets.bottom + 20,
              ),
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
                    t.t('drivers_hub_upload_driver_document'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selected,
                    decoration: InputDecoration(
                      labelText: t.t('drivers_hub_document_type'),
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
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
                  const SizedBox(height: 10),
                  Text(
                    t.tf('drivers_hub_replace_slot_hint', {
                      'slot': 'documents/$selected',
                    }),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed:
                            busy ? null : () => Navigator.of(ctx2).pop(),
                        child: Text(t.t('admin_home_cancel')),
                      ),
                      const SizedBox(width: 8),
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
                  ),
                ],
              ),
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
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (ctx) {
        bool showPin = false;

        return StatefulBuilder(
          builder: (ctxState, setStateDialog) {
            return Scaffold(
              backgroundColor: const Color(0xFFF4F5FB),
              appBar: AppBar(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                elevation: 0,
                scrolledUnderElevation: 0.5,
                foregroundColor: const Color(0xFF111827),
                leading: IconButton(
                  tooltip: AppLocalizations.of(ctx).t('admin_home_close'),
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
                title: Text(
                  AppLocalizations.of(ctx)
                      .t('drivers_hub_tooltip_view_details'),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              body: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
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
                    final employeeNumber =
                        (data['employeeNumber'] ?? '').toString().trim();
                    final contractType = DriverContractType.fromValue(
                      data['contractType'],
                    );
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

                    final driverRef = snap.data!.reference;

                    final workPermitType = _normalizeWorkPermitType(
                      onboarding['workPermitType'],
                      fallbackExpiry: onboarding['residencePermitExpiry'],
                    );
                    final workVisaExpiryValue =
                        (onboarding['workVisaExpiry'] ??
                                onboarding['residencePermitExpiry'])
                            .toString();

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final isNarrow = constraints.maxWidth < 1100;

                                  Widget gridRow(Widget l, Widget r) =>
                                      isNarrow
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                l,
                                                const SizedBox(height: 12),
                                                r,
                                              ],
                                            )
                                          : Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(child: l),
                                                const SizedBox(width: 16),
                                                Expanded(child: r),
                                              ],
                                            );

                                  // ─── Hero card ────────────────────────
                                  final avatar = ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      width: 88,
                                      height: 88,
                                      color: const Color(0xFFE5E7EB),
                                      child: profileImage == null
                                          ? const Icon(
                                              Icons.person,
                                              size: 44,
                                              color: Color(0xFF9CA3AF),
                                            )
                                          : Image(
                                              image: profileImage,
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                  );

                                  final identityCol = Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SelectableText(
                                        name.isEmpty
                                            ? t.t('dash_no_name')
                                            : name,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF111827),
                                        ),
                                      ),
                                      if (email.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 2,
                                          ),
                                          child: SelectableText(
                                            email,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF6B7280),
                                            ),
                                          ),
                                        ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 2,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Flexible(
                                              child: SelectableText(
                                                t.tf(
                                                  'drivers_hub_transporter_id_line',
                                                  {
                                                    'id': tid.isEmpty
                                                        ? '—'
                                                        : tid,
                                                  },
                                                ),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF9CA3AF),
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              tooltip: 'TID bearbeiten',
                                              icon: const Icon(
                                                Icons.edit_outlined,
                                                size: 14,
                                                color: Color(0xFF6B7280),
                                              ),
                                              padding: EdgeInsets.zero,
                                              visualDensity:
                                                  VisualDensity.compact,
                                              constraints: const BoxConstraints
                                                  .tightFor(
                                                width: 24,
                                                height: 24,
                                              ),
                                              onPressed: () =>
                                                  _editTransporterId(
                                                snap.data!,
                                                tid,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: [
                                          _statusChipFromData(data, ctx2),
                                          _loginChipFromData(data, ctx2),
                                          _expiryChipDetailedFromOnboardingRaw(
                                            onboarding,
                                            ctx2,
                                          ),
                                        ],
                                      ),
                                    ],
                                  );

                                  // Single 44×44 settings affordance — every
                                  // hero-level action (PIN, password, …)
                                  // lives behind this menu so the hero stays
                                  // calm. Hit-target stays ≥ 44 even though
                                  // the visual is a 36 px chip.
                                  final canManageLogins =
                                      _uid != null && tid.isNotEmpty;
                                  final settingsButton = Material(
                                    color: const Color(0xFFF8FAFC),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: const BorderSide(
                                        color: Color(0xFFE5E7EB),
                                      ),
                                    ),
                                    child: PopupMenuButton<String>(
                                      tooltip: 'Einstellungen',
                                      position: PopupMenuPosition.under,
                                      offset: const Offset(0, 8),
                                      padding: EdgeInsets.zero,
                                      icon: const Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        child: Icon(
                                          Icons.settings_rounded,
                                          size: 20,
                                          color: Color(0xFF334155),
                                        ),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        side: const BorderSide(
                                          color: Color(0xFFE5E7EB),
                                        ),
                                      ),
                                      color: Colors.white,
                                      elevation: 8,
                                      onSelected: (value) async {
                                        switch (value) {
                                          case 'pin':
                                            if (!canEditPin) return;
                                            await showDialog<void>(
                                              context: ctx2,
                                              barrierDismissible: false,
                                              builder: (_) =>
                                                  SetNotificationPinDialog(
                                                dspUid: _uid!,
                                                transporterId:
                                                    tid.toUpperCase(),
                                                force: true,
                                              ),
                                            );
                                            break;
                                          case 'password':
                                            if (!canManageLogins) return;
                                            await _onCreateOrResetLogin(
                                              snap.data!,
                                            );
                                            break;
                                        }
                                      },
                                      itemBuilder: (_) => <
                                          PopupMenuEntry<String>>[
                                        PopupMenuItem<String>(
                                          value: 'pin',
                                          enabled: canEditPin,
                                          height: 44,
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 28,
                                                height: 28,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: pin.isEmpty
                                                      ? const Color(
                                                          0xFFF1F5F9,
                                                        )
                                                      : const Color(
                                                          0xFFECFDF5,
                                                        ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Icon(
                                                  pin.isEmpty
                                                      ? Icons.pin_outlined
                                                      : Icons.pin_rounded,
                                                  size: 16,
                                                  color: pin.isEmpty
                                                      ? const Color(
                                                          0xFF475569,
                                                        )
                                                      : const Color(
                                                          0xFF065F46,
                                                        ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    pin.isEmpty
                                                        ? t.t(
                                                            'drivers_hub_set_pin',
                                                          )
                                                        : t.t(
                                                            'drivers_hub_change_pin',
                                                          ),
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Color(0xFF0F172A),
                                                    ),
                                                  ),
                                                  Text(
                                                    pin.isEmpty
                                                        ? 'Push-Benachrichtigungen freischalten'
                                                        : 'Benachrichtigungs-PIN aktualisieren',
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      color: Color(0xFF64748B),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuDivider(height: 1),
                                        PopupMenuItem<String>(
                                          value: 'password',
                                          enabled: canManageLogins,
                                          height: 44,
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 28,
                                                height: 28,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFFEFF6FF,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: const Icon(
                                                  Icons.key_outlined,
                                                  size: 16,
                                                  color: Color(0xFF1D4ED8),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              const Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    'Passwort verwalten',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Color(0xFF0F172A),
                                                    ),
                                                  ),
                                                  Text(
                                                    'Login zurücksetzen oder neu vergeben',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: Color(0xFF64748B),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );

                                  // Tappable score chip — lives inside
                                  // `_EmploymentInfoCard` right under the
                                  // contract type. Tap toggles the inline
                                  // weekly-breakdown accordion below the
                                  // hero.
                                  final normTid = tid.trim().toUpperCase();
                                  final scoreExpanded =
                                      _expandedWeeklySummaries
                                          .contains(normTid);

                                  void toggleScoreExpanded() {
                                    setStateDialog(() {
                                      if (scoreExpanded) {
                                        _expandedWeeklySummaries
                                            .remove(normTid);
                                      } else {
                                        _expandedWeeklySummaries.add(normTid);
                                      }
                                    });
                                  }

                                  final scoreSection = (_uid == null ||
                                          normTid.isEmpty)
                                      ? null
                                      : StreamBuilder<
                                          QuerySnapshot<Map<String, dynamic>>>(
                                          stream: FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(_uid)
                                              .collection('scores')
                                              .where(
                                                'transporterId',
                                                isEqualTo: normTid,
                                              )
                                              .snapshots(),
                                          builder: (context, scoreSnap) {
                                            if (!scoreSnap.hasData) {
                                              return const SizedBox.shrink();
                                            }
                                            final agg =
                                                _aggregateDriverOverallScores(
                                              scoreSnap.data!.docs,
                                            )[normTid];
                                            if (agg == null ||
                                                agg.weeksCount <= 0) {
                                              return const SizedBox.shrink();
                                            }
                                            final bucket =
                                                _normalizedDriverScoreBucket(
                                              score: agg.averageScore,
                                            );
                                            final color =
                                                _driverScoreBucketColor(bucket);
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.bolt_rounded,
                                                      size: 14,
                                                      color: color,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      'GESAMTSCORE',
                                                      style: TextStyle(
                                                        fontFamily: 'Inter',
                                                        fontSize: 10.5,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        letterSpacing: 0.5,
                                                        color: Colors.grey
                                                            .shade600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                InkWell(
                                                  onTap: toggleScoreExpanded,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    999,
                                                  ),
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 10,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: color
                                                          .withOpacity(0.10),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        999,
                                                      ),
                                                      border: Border.all(
                                                        color: color
                                                            .withOpacity(0.35),
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          _formatOverallScorePercent(
                                                            agg.averageScore,
                                                          ),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Inter',
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.w800,
                                                            color: color,
                                                            letterSpacing: 0.1,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 6,
                                                        ),
                                                        Text(
                                                          '· ${agg.weeksCount} Wo.',
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: color
                                                                .withOpacity(
                                                              0.80,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Icon(
                                                          scoreExpanded
                                                              ? Icons
                                                                  .keyboard_arrow_up_rounded
                                                              : Icons
                                                                  .keyboard_arrow_down_rounded,
                                                          size: 16,
                                                          color: color,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );

                                  // Top strip = just the settings gear in
                                  // the right corner of the hero. The score
                                  // moved down into `_EmploymentInfoCard`.
                                  final heroTopStrip = Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Spacer(),
                                      settingsButton,
                                    ],
                                  );

                                  // Employment block (Personalnummer +
                                  // Vertragstyp + Score-Accordion-Handle).
                                  final employmentCard = _EmploymentInfoCard(
                                    employeeNumber: employeeNumber,
                                    contractType: contractType,
                                    scoreSection: scoreSection,
                                  );

                                  final hero = Container(
                                    padding: const EdgeInsets.fromLTRB(
                                      18,
                                      14,
                                      18,
                                      18,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(
                                            0.03,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: isNarrow
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              heroTopStrip,
                                              const SizedBox(height: 12),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  avatar,
                                                  const SizedBox(width: 14),
                                                  Expanded(
                                                      child: identityCol),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              employmentCard,
                                            ],
                                          )
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              heroTopStrip,
                                              const SizedBox(height: 12),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  avatar,
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                      child: identityCol),
                                                  const SizedBox(width: 12),
                                                  employmentCard,
                                                ],
                                              ),
                                            ],
                                          ),
                                  );

                                  // ─── Kacheln ──────────────────────────
                                  Widget originHeader() => _DetailKachelHeader(
                                        text: t.t(
                                          'drivers_hub_section_origin',
                                        ),
                                      );

                                  final personalKachel = _DetailKachel(
                                    title: t.t(
                                      'drivers_hub_section_personal_details',
                                    ),
                                    icon: Icons.person_rounded,
                                    children: [
                                      _detailRowEditable(
                                        driverRef: driverRef,
                                        label: t.t(
                                          'drivers_hub_field_full_name',
                                        ),
                                        value: onboarding['fullName'],
                                        fieldKey: 'fullName',
                                      ),
                                      _detailRowEditable(
                                        driverRef: driverRef,
                                        label: t.t(
                                          'drivers_hub_field_name_at_birth',
                                        ),
                                        value: onboarding['nameAtBirth'],
                                        fieldKey: 'nameAtBirth',
                                      ),
                                      _detailRowEditable(
                                        driverRef: driverRef,
                                        label: t.t(
                                          'drivers_hub_field_date_of_birth',
                                        ),
                                        value: onboarding['dateOfBirth'],
                                        fieldKey: 'dateOfBirth',
                                        isDate: true,
                                      ),
                                      _detailRowEditable(
                                        driverRef: driverRef,
                                        label: t.t('drivers_hub_field_phone'),
                                        value: onboarding['phone'],
                                        fieldKey: 'phone',
                                      ),
                                      originHeader(),
                                      _detailRowEditable(
                                        driverRef: driverRef,
                                        label: t.t(
                                          'drivers_hub_field_city_of_birth',
                                        ),
                                        value: onboarding['birthCity'],
                                        fieldKey: 'birthCity',
                                      ),
                                      _detailRowEditable(
                                        driverRef: driverRef,
                                        label: t.t(
                                          'drivers_hub_field_state_of_birth',
                                        ),
                                        value: onboarding['birthState'],
                                        fieldKey: 'birthState',
                                      ),
                                      _detailRowEditable(
                                        driverRef: driverRef,
                                        label: t.t(
                                          'drivers_hub_field_nationality_id_card',
                                        ),
                                        value:
                                            onboarding['nationalityIdCard'],
                                        fieldKey: 'nationalityIdCard',
                                      ),
                                    ],
                                  );

                                  final addressKachel = _DetailKachel(
                                    title:
                                        t.t('drivers_hub_section_address'),
                                    icon: Icons.home_rounded,
                                    children: [
                                      _detailRowEditable(
                                        driverRef: driverRef,
                                        label: t.t(
                                          'drivers_hub_field_street_address',
                                        ),
                                        value: onboarding['address'],
                                        fieldKey: 'address',
                                      ),
                                      _detailRowEditable(
                                        driverRef: driverRef,
                                        label: t.t('drivers_hub_field_city'),
                                        value: onboarding['city'],
                                        fieldKey: 'city',
                                      ),
                                      _detailRowEditable(
                                        driverRef: driverRef,
                                        label: t.t(
                                          'drivers_hub_field_postal_code',
                                        ),
                                        value: onboarding['postalCode'],
                                        fieldKey: 'postalCode',
                                      ),
                                      _detailRowEditable(
                                        driverRef: driverRef,
                                        label:
                                            t.t('drivers_hub_field_country'),
                                        value: onboarding['country'],
                                        fieldKey: 'country',
                                      ),
                                    ],
                                  );

                                  final licenseKachel = _DetailKachel(
                                    title: t.t(
                                      'drivers_hub_section_driving_license',
                                    ),
                                    icon: Icons.badge_rounded,
                                    children: [
                                      _detailRowEditable(
                                        driverRef: driverRef,
                                        label: t.t(
                                          'drivers_hub_field_driving_license_number',
                                        ),
                                        value: onboarding['licenseNumber'],
                                        fieldKey: 'licenseNumber',
                                      ),
                                      _detailRowEditable(
                                        driverRef: driverRef,
                                        label: t.t(
                                          'drivers_hub_field_license_expiry_date',
                                        ),
                                        value: onboarding['licenseExpiry'],
                                        fieldKey: 'licenseExpiry',
                                        isDate: true,
                                      ),
                                    ],
                                  );

                                  final permitsKachel = _DetailKachel(
                                    title: t.t(
                                      'drivers_hub_section_document_expiry_dates',
                                    ),
                                    icon: Icons.assignment_rounded,
                                    children: [
                                      _detailRowEditable(
                                        driverRef: driverRef,
                                        label: t.t(
                                          'drivers_hub_field_work_permit_type',
                                        ),
                                        value: workPermitType,
                                        fieldKey: 'workPermitType',
                                        displayValueBuilder: (_) =>
                                            _workPermitTypeLabel(
                                              t,
                                              workPermitType,
                                              fallbackExpiry: onboarding[
                                                  'residencePermitExpiry'],
                                            ),
                                        onEdit: () =>
                                            _adminEditWorkPermitType(
                                              driverRef: driverRef,
                                              initialValue: onboarding[
                                                  'workPermitType'],
                                              fallbackExpiry: onboarding[
                                                  'residencePermitExpiry'],
                                            ),
                                      ),
                                      _detailRowEditable(
                                        driverRef: driverRef,
                                        label: t.t(
                                          'drivers_hub_field_work_start_date',
                                        ),
                                        value: onboarding['workStartDate'],
                                        fieldKey: 'workStartDate',
                                        isDate: true,
                                      ),
                                      _detailRowEditable(
                                        driverRef: driverRef,
                                        label: t.t(
                                          'drivers_hub_field_annual_vacation_days',
                                        ),
                                        value: onboarding[
                                                'annualVacationDays'] ??
                                            20,
                                        fieldKey: 'annualVacationDays',
                                        isNumeric: true,
                                      ),
                                      _remainingVacationDaysRow(
                                        driverRef: driverRef,
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
                                              _probationEndFromStart(start);
                                          return end == null
                                              ? ''
                                              : _formatDate(end);
                                        })(),
                                      ),
                                      _detailRowEditable(
                                        driverRef: driverRef,
                                        label: t.t(
                                          'drivers_hub_field_contract_expiry',
                                        ),
                                        value: onboarding['contractExpiry'],
                                        fieldKey: 'contractExpiry',
                                        isDate: true,
                                      ),
                                      if (workPermitType == 'working_visa')
                                        _detailRowEditable(
                                          driverRef: driverRef,
                                          label: t.t(
                                            'drivers_hub_field_work_visa_expiry',
                                          ),
                                          value: workVisaExpiryValue,
                                          fieldKey: 'workVisaExpiry',
                                          isDate: true,
                                        ),
                                      if (workPermitType == 'working_visa')
                                        _detailRowEditable(
                                          driverRef: driverRef,
                                          label: t.t(
                                            'drivers_hub_field_zusatzblatt_expiry',
                                          ),
                                          value: onboarding[
                                              'zusatzblattExpiry'],
                                          fieldKey: 'zusatzblattExpiry',
                                          isDate: true,
                                        ),
                                      _detailRowEditable(
                                        driverRef: driverRef,
                                        label: t.t(
                                          'drivers_hub_field_id_card_passport_expiry',
                                        ),
                                        value: onboarding['idDocExpiry'],
                                        fieldKey: 'idDocExpiry',
                                        isDate: true,
                                      ),
                                    ],
                                  );

                                  final paymentKachel = _DetailKachel(
                                    title: t.t(
                                      'drivers_hub_section_payment_tax',
                                    ),
                                    icon: Icons.account_balance_rounded,
                                    children: [
                                      _detailRowEditable(
                                        driverRef: driverRef,
                                        label: t.t(
                                          'drivers_hub_field_bank_iban',
                                        ),
                                        value: onboarding['bankIban'],
                                        fieldKey: 'bankIban',
                                      ),
                                      _detailRowEditable(
                                        driverRef: driverRef,
                                        label: t.t(
                                          'drivers_hub_field_insurance_company',
                                        ),
                                        value:
                                            onboarding['insuranceCompany'],
                                        fieldKey: 'insuranceCompany',
                                      ),
                                      _detailRowEditable(
                                        driverRef: driverRef,
                                        label:
                                            t.t('drivers_hub_field_tax_id'),
                                        value: onboarding['taxId'],
                                        fieldKey: 'taxId',
                                      ),
                                    ],
                                  );

                                  final emergencyKachel = _DetailKachel(
                                    title: t.t(
                                      'drivers_hub_section_emergency_contact',
                                    ),
                                    icon: Icons.emergency_rounded,
                                    children: [
                                      _detailRowEditable(
                                        driverRef: driverRef,
                                        label: t.t(
                                          'drivers_hub_field_emergency_contact_name',
                                        ),
                                        value: onboarding[
                                            'emergencyContactName'],
                                        fieldKey: 'emergencyContactName',
                                      ),
                                      _detailRowEditable(
                                        driverRef: driverRef,
                                        label: t.t(
                                          'drivers_hub_field_emergency_contact_phone',
                                        ),
                                        value: onboarding[
                                            'emergencyContactPhone'],
                                        fieldKey: 'emergencyContactPhone',
                                      ),
                                    ],
                                  );

                                  final uniformKachel = _DetailKachel(
                                    title:
                                        t.t('drivers_hub_section_uniform'),
                                    icon: Icons.checkroom_rounded,
                                    children: [
                                      _detailRowEditable(
                                        driverRef: driverRef,
                                        label: t.t(
                                          'drivers_hub_field_tshirt_size',
                                        ),
                                        value: onboarding['tShirtSize'],
                                        fieldKey: 'tShirtSize',
                                      ),
                                      _detailRowEditable(
                                        driverRef: driverRef,
                                        label: t.t(
                                          'drivers_hub_field_shoe_size',
                                        ),
                                        value: onboarding['shoeSize'],
                                        fieldKey: 'shoeSize',
                                      ),
                                    ],
                                  );

                                  final notesKachel = _DetailKachel(
                                    title: t.t(
                                      'drivers_hub_section_other_notes',
                                    ),
                                    icon: Icons.sticky_note_2_rounded,
                                    children: [
                                      _detailRowEditable(
                                        driverRef: driverRef,
                                        label:
                                            t.t('drivers_hub_field_notes'),
                                        value: onboarding['notes'],
                                        fieldKey: 'notes',
                                      ),
                                    ],
                                  );

                                  // ─── Documents card ───────────────────
                                  final documentsCard = Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(
                                            0.02,
                                          ),
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
                                          dspUid: _uid,
                                          driverDocId: driverRef.id,
                                          onUploadDoc: () =>
                                              _showAdminUploadDocDialog(
                                                driverRef,
                                              ),
                                          onOpenResidencePermitForm:
                                              _uid == null
                                                  ? null
                                                  : () =>
                                                      openResidencePermitForm(
                                                        ctx2,
                                                        dspUid: _uid!,
                                                        driverDocId:
                                                            driverRef.id,
                                                      ),
                                        ),
                                        const SizedBox(height: 12),
                                        _DriverDocumentsList(
                                          driverRef: driverRef,
                                          driverName: name,
                                          onUploadDoc: (docType) =>
                                              _adminPickAndUploadDriverDoc(
                                                driverRef: driverRef,
                                                docType: docType,
                                              ),
                                        ),
                                      ],
                                    ),
                                  );

                                  return Column(
                                    children: [
                                      hero,
                                      // Weekly score accordion — opens via
                                      // the score handle inside the hero's
                                      // employment card.
                                      if (tid.isNotEmpty && scoreExpanded) ...[
                                        const SizedBox(height: 12),
                                        _buildWeeklyScoreSummaryCard(
                                          transporterId: tid,
                                          t: t,
                                          onToggleExpanded:
                                              toggleScoreExpanded,
                                        ),
                                      ],
                                      const SizedBox(height: 16),
                                      gridRow(
                                        personalKachel,
                                        addressKachel,
                                      ),
                                      const SizedBox(height: 16),
                                      gridRow(
                                        licenseKachel,
                                        permitsKachel,
                                      ),
                                      const SizedBox(height: 16),
                                      gridRow(
                                        paymentKachel,
                                        emergencyKachel,
                                      ),
                                      const SizedBox(height: 16),
                                      gridRow(uniformKachel, notesKachel),
                                      const SizedBox(height: 16),
                                      documentsCard,
                                      const SizedBox(height: 20),
                                      // Bottom action row — kept in scroll
                                      // body (instead of fixed bar) so it
                                      // never overlaps content on small
                                      // screens. The AppBar's leading
                                      // button is the primary close.
                                      Wrap(
                                        alignment: WrapAlignment.end,
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          OutlinedButton.icon(
                                            onPressed: () => _exportDriver(
                                              driverRef:
                                                  driverDoc.reference,
                                              driverName: name,
                                              transporterId: tid,
                                            ),
                                            icon: const Icon(
                                                Icons.download_rounded,
                                                size: 18),
                                            label: Text(t
                                                .t('drivers_hub_export_zip')),
                                          ),
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
                                            child: Text(t
                                                .t('drivers_hub_export_pdf')),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
                            );
                  },
                ),
                ),
              ),
            );
          },
        );
      },
    ));
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

          // 0-Delivery-Wochen herausfiltern — diese sollen weder im
          // wöchentlichen Score-Summary noch im Ranking erscheinen.
          final docs = [
            ...?snap.data?.docs.where((d) {
              final data = d.data();
              final kpis = (data['kpis'] as Map?) ?? const {};
              final raw = kpis['Delivered'] ??
                  kpis['DELIVERED'] ??
                  kpis['delivered'] ??
                  data['Delivered'] ??
                  data['delivered'];
              if (raw == null) return false;
              if (raw is num) return raw > 0;
              if (raw is String) {
                final n = double.tryParse(
                  raw.trim().replaceAll(',', '.'),
                );
                return n != null && n > 0;
              }
              return false;
            }),
          ];
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

  /// Holt für einen Fahrer alle hochgeladenen Dokumente aus Storage und
  /// bereitet sie für die PDF-Einbettung vor. Bilder werden direkt als
  /// PNG/JPG-Image-Provider zurückgegeben; PDFs werden seitenweise via
  /// `Printing.raster` zu Bildern rendert, damit sie in das Onboarding-
  /// PDF kopiert werden können.
  Future<List<_EmbeddedDoc>> _collectDriverDocsForPdf({
    required String transporterId,
  }) async {
    final uid = _uid;
    if (uid == null) return const [];
    final tid = transporterId.trim();
    if (tid.isEmpty) return const [];

    final driverRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('drivers')
        .doc(tid);

    final snap = await driverRef.collection('documents').get();
    if (snap.docs.isEmpty) return const [];

    // Stabile Reihenfolge wie im ZIP-Export
    const order = [
      'contract',
      'resident_permit',
      'tax_id',
      'insurance',
      'id_card_front',
      'id_card_back',
      'passport_front',
      'passport_back',
      'driver_license_front',
      'driver_license_back',
    ];
    const labels = {
      'contract': 'Arbeitsvertrag',
      'resident_permit': 'Aufenthaltsgenehmigung',
      'tax_id': 'Steuer-ID',
      'insurance': 'Krankenkasse',
      'id_card_front': 'Personalausweis (Vorne)',
      'id_card_back': 'Personalausweis (Hinten)',
      'passport_front': 'Reisepass (Vorne)',
      'passport_back': 'Reisepass (Hinten)',
      'driver_license_front': 'Führerschein (Vorne)',
      'driver_license_back': 'Führerschein (Hinten)',
    };

    final byType = <String, Map<String, dynamic>>{
      for (final d in snap.docs)
        (d.data()['docType'] ?? d.id).toString(): d.data(),
    };
    final orderedTypes = <String>[
      ...order.where(byType.containsKey),
      ...byType.keys.where((k) => !order.contains(k)),
    ];

    final out = <_EmbeddedDoc>[];
    final storage = fb.FirebaseStorage.instance;

    for (final type in orderedTypes) {
      final docData = byType[type]!;
      final storagePath = (docData['storagePath'] ?? '').toString();
      final downloadUrl = (docData['downloadUrl'] ?? '').toString();
      if (storagePath.isEmpty && downloadUrl.isEmpty) continue;

      final contentType =
          (docData['contentType'] ?? '').toString().toLowerCase();
      final fileName = (docData['fileName'] ?? '').toString();
      final label = labels[type] ?? type;

      try {
        // Primär direkter HTTP-GET auf die downloadUrl (umgeht den
        // Type-Cast-Bug im firebase_storage Web-SDK). Falls keine URL
        // gespeichert ist, fragen wir sie über das SDK ab.
        Uint8List? bytes;
        String urlToFetch = downloadUrl;
        if (urlToFetch.isEmpty && storagePath.isNotEmpty) {
          try {
            urlToFetch = await storage.ref(storagePath).getDownloadURL();
          } catch (_) {}
        }
        if (urlToFetch.isNotEmpty) {
          try {
            final resp = await http.get(Uri.parse(urlToFetch));
            if (resp.statusCode == 200) {
              bytes = resp.bodyBytes;
            }
          } catch (_) {}
        }
        if (bytes == null) continue;

        final isPdf = contentType == 'application/pdf' ||
            fileName.toLowerCase().endsWith('.pdf') ||
            storagePath.toLowerCase().endsWith('.pdf') ||
            downloadUrl.toLowerCase().contains('.pdf');

        if (isPdf) {
          // PDF-Seiten via printing.raster zu Bildern konvertieren — so
          // können sie als Bild-Pages ins Master-PDF eingebettet werden.
          final pages = <pw.MemoryImage>[];
          await for (final raster in Printing.raster(bytes, dpi: 150)) {
            final png = await raster.toPng();
            pages.add(pw.MemoryImage(png));
          }
          if (pages.isNotEmpty) {
            out.add(_EmbeddedDoc(label: label, pages: pages));
          }
        } else {
          // Bilddatei direkt einbetten
          out.add(_EmbeddedDoc(
            label: label,
            pages: [pw.MemoryImage(bytes)],
          ));
        }
      } catch (_) {
        // Datei nicht abrufbar — überspringen, Rest läuft weiter.
      }
    }

    return out;
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

    // ── Dokumente anhängen ──────────────────────────────────────────
    final embedded = await _collectDriverDocsForPdf(
      transporterId: transporterId,
    );
    for (final ed in embedded) {
      for (var i = 0; i < ed.pages.length; i++) {
        final page = ed.pages[i];
        final pageLabel = ed.pages.length > 1
            ? '${ed.label} — Seite ${i + 1}/${ed.pages.length}'
            : ed.label;
        doc.addPage(
          pw.Page(
            margin: const pw.EdgeInsets.all(24),
            build: (ctx) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  pageLabel,
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Expanded(
                  child: pw.Center(
                    child: pw.Image(page, fit: pw.BoxFit.contain),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

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
    final isNarrowControls = width < 720;

    final searchField = SizedBox(
      height: 44,
      child: TextField(
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1F2937),
        ),
        decoration: InputDecoration(
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF9CA3AF),
            size: 20,
          ),
          hintText: t.t('drivers_hub_search_name_or_email'),
          hintStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF9CA3AF),
          ),
          isDense: true,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: Color(0xFFE5E5EA), width: 0.6),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: Color(0xFFE5E5EA), width: 0.6),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: Color(0xFF00B287), width: 1.4),
          ),
        ),
        onChanged: (value) {
          setState(() => _search = value.toLowerCase());
        },
      ),
    );

    final sortField = _DriverSortPill(
      isSmall: false,
      valueLabel: _driverSortLabel(_driverSort),
      onSelected: (value) {
        setState(() => _driverSort = value);
      },
    );

    final passwordField = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Text(
            t.t('drivers_hub_default_driver_password'),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
        SizedBox(
          height: 44,
          child: TextField(
            controller: _bulkPwdCtrl,
            obscureText: !_bulkPwdVisible,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1F2937),
            ),
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.lock_outline_rounded,
                color: Color(0xFF9CA3AF),
                size: 18,
              ),
              hintText: '••••••••',
              hintStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF9CA3AF),
              ),
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: Color(0xFFE5E5EA), width: 0.6),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: Color(0xFFE5E5EA), width: 0.6),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: Color(0xFF00B287), width: 1.4),
              ),
              suffixIcon: IconButton(
                iconSize: 18,
                color: const Color(0xFF6B7280),
                icon: Icon(_bulkPwdVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined),
                onPressed: () =>
                    setState(() => _bulkPwdVisible = !_bulkPwdVisible),
              ),
            ),
          ),
        ),
      ],
    );

    return Column(
      children: [
        // 🔹 Top controls — Apple-Style: Suche links, Sortier-Pille
        //    rechts, darunter (optional) das Default-Passwort-Feld.
        if (isNarrowControls)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              searchField,
              const SizedBox(height: 10),
              sortField,
              const SizedBox(height: 10),
              passwordField,
            ],
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(flex: 3, child: searchField),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: sortField),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(width: 360, child: passwordField),
            ],
          ),
        const SizedBox(height: 16),

        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            // Bewusst ohne `orderBy('transporterId')` — Firestore schließt
            // Docs ohne dieses Feld aus dem Sort aus, was neu angelegte
            // Fahrer ohne TID (`tidPending: true`) komplett unsichtbar
            // machte. Sortierung passiert client-seitig im Code unten.
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(_uid!)
                .collection('drivers')
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

              // Contract-type filter — driven by the clickable stats
              // tiles at the top of the page. When a tile is selected,
              // only drivers of that contract type are shown.
              if (_contractFilter != null) {
                filtered = filtered.where((d) {
                  return DriverContractType.fromValue(
                          d.data()['contractType']) ==
                      _contractFilter;
                }).toList();
              } else if (_filterParttimeGroup) {
                filtered = filtered.where((d) {
                  final c = DriverContractType.fromValue(
                      d.data()['contractType']);
                  return c == DriverContractType.parttime4d ||
                      c == DriverContractType.parttime3d ||
                      c == DriverContractType.parttime2d;
                }).toList();
              } else if (_filterUnsetContract) {
                filtered = filtered.where((d) {
                  return DriverContractType.fromValue(
                          d.data()['contractType']) ==
                      null;
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

              // Expiry-first pre-sort: drivers with a document expiring
              // within 30 days (or already expired) bubble to the top,
              // sorted by closest expiry. The user's chosen sort
              // continues to apply as a tie-breaker for everyone else.
              int expiryRank(QueryDocumentSnapshot<Map<String, dynamic>> d) {
                final raw = d.data()['onboarding'];
                if (raw is! Map) return 999;
                int best = 999;
                for (final key in const [
                  'licenseExpiry',
                  'idDocExpiry',
                  'residencePermitExpiry',
                ]) {
                  final s = (raw[key] ?? '').toString().trim();
                  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(s);
                  if (m == null) continue;
                  final dt = DateTime.utc(
                    int.parse(m.group(1)!),
                    int.parse(m.group(2)!),
                    int.parse(m.group(3)!),
                  );
                  final now = DateTime.now().toUtc();
                  final today = DateTime.utc(now.year, now.month, now.day);
                  final days = dt.difference(today).inDays;
                  if (days < best) best = days;
                }
                return best;
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

                // 1) Expiring drivers (≤30 days) always at the top.
                final ar = expiryRank(a);
                final br = expiryRank(b);
                final aPrio = ar <= 30;
                final bPrio = br <= 30;
                if (aPrio != bPrio) return aPrio ? -1 : 1;
                if (aPrio && bPrio) {
                  final c = ar.compareTo(br);
                  if (c != 0) return c;
                }

                // 2) Active beats rejected — rejected (active=false)
                // sinks to the bottom regardless of the chosen sort,
                // so the visible workforce stays at the top.
                final aActive = (ad['active'] as bool?) ?? true;
                final bActive = (bd['active'] as bool?) ?? true;
                if (aActive != bActive) return aActive ? -1 : 1;

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
                  case _DriverSort.statusActive:
                    // active first, then onboarding, then inactive
                    int rank(Map<String, dynamic> d) {
                      final s = (d['status'] ?? '').toString().toLowerCase();
                      if (s == 'active' || s == 'approved') return 0;
                      if (s == 'pending' || s == 'onboarding') return 1;
                      if (s == 'inactive' || s == 'deleted') return 3;
                      return 2;
                    }
                    final c = rank(ad).compareTo(rank(bd));
                    return c == 0 ? byName() : c;
                  case _DriverSort.scoreLowToHigh:
                    double score(Map<String, dynamic> d) {
                      final v = d['overallScore'] ??
                          d['lastOverallScore'] ??
                          d['averageScore'];
                      if (v is num) return v.toDouble();
                      return 999.0; // missing = bottom
                    }
                    final cs = score(ad).compareTo(score(bd));
                    return cs == 0 ? byName() : cs;
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
                  // 0-Delivery-Wochen aus der Driver-Hub-Aggregation
                  // herausfiltern — sonst zaehlen Wochen ohne Pakete
                  // mit in die Driver-Score-Auswertung.
                  final filteredDocs = (scoresSnap.data?.docs ?? const [])
                      .where((d) {
                    final data = d.data();
                    final kpis = (data['kpis'] as Map?) ?? const {};
                    final raw = kpis['Delivered'] ??
                        kpis['DELIVERED'] ??
                        kpis['delivered'] ??
                        data['Delivered'] ??
                        data['delivered'];
                    if (raw == null) return false;
                    if (raw is num) return raw > 0;
                    if (raw is String) {
                      final n = double.tryParse(
                        raw.trim().replaceAll(',', '.'),
                      );
                      return n != null && n > 0;
                    }
                    return false;
                  }).toList();
                  final overallScores = _aggregateDriverOverallScores(
                    filteredDocs,
                  );

                  // Contract-type breakdown — counts every ACTIVE
                  // driver in the unfiltered set so the totals stay
                  // stable while the admin searches/filters. Rejected
                  // / inactive drivers (`active: false`) drop out of
                  // both the total and the per-type counts.
                  final contractCounts = <DriverContractType?, int>{};
                  var activeTotal = 0;
                  for (final d in docs) {
                    final data = d.data();
                    final active = (data['active'] as bool?) ?? true;
                    if (!active) continue;
                    activeTotal++;
                    final ct = DriverContractType.fromValue(
                      data['contractType'],
                    );
                    contractCounts[ct] = (contractCounts[ct] ?? 0) + 1;
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final isCompact = constraints.maxWidth < 720;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 4,
                              bottom: 12,
                            ),
                            child: _ContractTypeStatsRow(
                              counts: contractCounts,
                              totalDrivers: activeTotal,
                              compact: isCompact,
                              selected: _contractFilter,
                              selectedUnset: _filterUnsetContract,
                              selectedParttimeGroup: _filterParttimeGroup,
                              onSelect: (type, selectUnset, parttimeGroup) {
                                setState(() {
                                  _contractFilter = type;
                                  _filterUnsetContract = selectUnset;
                                  _filterParttimeGroup = parttimeGroup;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: ListView.separated(
                              padding: const EdgeInsets.only(
                                bottom: 24,
                              ),
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                          final d = filtered[index];
                          final data = d.data();
                          final name = (data['driverName'] ?? '').toString();
                          final hasTid =
                              (data['transporterId'] ?? '').toString().trim().isNotEmpty;
                          final tidPending = data['tidPending'] == true || !hasTid;
                          final transporterId = hasTid
                              ? (data['transporterId'] as String)
                                  .trim()
                                  .toUpperCase()
                              : '';
                          final hasLogin =
                              (data['hasLogin'] as bool?) ?? false;
                          final active = (data['active'] as bool?) ?? true;
                          final onboardingRaw = data['onboarding'];
                          final profileImage =
                              _profileImageFromOnboarding(onboardingRaw);
                          final overallScore = overallScores[transporterId];

                          return _DriverHubRow(
                            driverDoc: d,
                            displayName: name.isEmpty
                                ? t.t('dash_no_name')
                                : name,
                            transporterId: transporterId,
                            tidPending: tidPending,
                            active: active,
                            hasLogin: hasLogin,
                            profileImage: profileImage,
                            overallScore: overallScore,
                            contractType: DriverContractType.fromValue(
                              data['contractType'],
                            ),
                            isCompact: isCompact,
                            onTap: () => _openDriverDetails(d),
                            onToggleActive: () =>
                                _onToggleActiveDriver(d, active),
                            onCreateOrResetLogin: () =>
                                _onCreateOrResetLogin(d),
                            onDelete: () => _onDeleteDriver(d),
                          );
                              },
                            ),
                          ),
                        ],
                      );
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

/// One category card on the driver-detail dashboard. Renders a header
/// row (icon + uppercase title + optional trailing) and a stack of
/// detail rows below. Used by `_openDriverDetails` to group the
/// onboarding fields into "Kacheln" — Personal, Address, Driving
/// Licence, Documents & Permits, Payment / Tax, Emergency, Uniform,
/// Notes.
class _DetailKachel extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _DetailKachel({
    required this.title,
    required this.icon,
    required this.children,
  });

  /// No dividers — rows rely solely on their own internal padding for
  /// rhythm. Keeps the card visually quiet, in line with the impeccable
  /// "near-white, near-black, hairlines only when meaningful" guidance.
  List<Widget> _buildSeparated() => List<Widget>.from(children);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6F2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: const Color(0xFF0E5C45)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ..._buildSeparated(),
        ],
      ),
    );
  }
}

/// Single data row inside a `_DetailKachel`. Provides a calm 8-px
/// vertical rhythm — light enough that the page feels uncluttered, dense
/// enough to scan a long list quickly.
class _DetailRow extends StatelessWidget {
  final Widget child;
  const _DetailRow({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: child,
    );
  }
}

/// Section sub-header inside a `_DetailKachel` (e.g. "Origin" / "Herkunft").
/// Renders an uppercase eyebrow label; the parent `_DetailKachel` recognises
/// it so no divider is drawn around it.
class _DetailKachelHeader extends StatelessWidget {
  final String text;
  const _DetailKachelHeader({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 2),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          color: Color(0xFFA8A29E),
        ),
      ),
    );
  }
}

/// Ein Dokument, das ins PDF eingebettet werden kann — entweder ein
/// einzelnes Bild oder mehrere Seiten (für PDFs, die zu Bildern rastert
/// wurden). Der Label-String erscheint als Headline pro Seite.
class _EmbeddedDoc {
  final String label;
  final List<pw.MemoryImage> pages;
  const _EmbeddedDoc({required this.label, required this.pages});
}

/// Kompakte Warn-Pille neben dem Fahrernamen: zeigt wie viele
/// Onboarding-Dokumente noch fehlen. Beobachtet die `documents`-
/// Subcollection live — sobald hochgeladen wird, verschwindet das Badge.
///
/// Erwartete Doc-Set (8): Vertrag, Aufenthaltsgenehmigung, Steuer-ID,
/// Krankenkasse, Führerschein vorne/hinten, plus 2 Identitäts-Slots
/// (Personalausweis oder Reisepass je vorne/hinten).
class _MissingDocsBadge extends StatelessWidget {
  final DocumentReference<Map<String, dynamic>> driverRef;
  const _MissingDocsBadge({required this.driverRef});

  static const _required = {
    'contract',
    'resident_permit',
    'tax_id',
    'insurance',
    'driver_license_front',
    'driver_license_back',
  };
  static const _identitySlot = {
    'id_card_front',
    'id_card_back',
    'passport_front',
    'passport_back',
  };

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: driverRef.collection('documents').snapshots(),
      builder: (ctx, snap) {
        if (!snap.hasData) return const SizedBox.shrink();
        final t = AppLocalizations.of(context);
        final uploaded = snap.data!.docs.map((d) {
          final data = d.data();
          return (data['docType'] ?? d.id).toString();
        }).toSet();

        // 6 Pflicht-Slots prüfen
        var missing = 0;
        for (final type in _required) {
          if (!uploaded.contains(type)) missing++;
        }
        // 2 Identitäts-Slots (egal ob ID-Card oder Reisepass)
        final identityCount = uploaded
            .where((u) => _identitySlot.contains(u))
            .length
            .clamp(0, 2);
        missing += 2 - identityCount;

        if (missing <= 0) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4E5),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFFFB547), width: 0.6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 12,
                color: Color(0xFFB7791F),
              ),
              const SizedBox(width: 4),
              Text(
                t.tf('drivers_hub_missing_docs', {'count': '$missing'}),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFB7791F),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Apple-Style „+ New" Button oben rechts. Tap öffnet ein PopupMenu mit
/// den drei Hauptaktionen: Fahrer hinzufügen, CSV importieren, Logins
/// für alle anlegen.
class _NewActionButton extends StatelessWidget {
  final bool busyCsv;
  final bool busyList;
  final bool busyBulkLogins;
  final VoidCallback onAddDriver;
  final VoidCallback onImportCsv;
  final VoidCallback onCreateLoginsForAll;
  final String labelAdd;
  final String labelImport;
  final String labelLogins;
  final String labelNew;

  const _NewActionButton({
    required this.busyCsv,
    required this.busyList,
    required this.busyBulkLogins,
    required this.onAddDriver,
    required this.onImportCsv,
    required this.onCreateLoginsForAll,
    required this.labelAdd,
    required this.labelImport,
    required this.labelLogins,
    required this.labelNew,
  });

  @override
  Widget build(BuildContext context) {
    final busy = busyCsv || busyList || busyBulkLogins;

    return PopupMenuButton<String>(
      enabled: !busy,
      tooltip: labelNew,
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      onSelected: (v) {
        switch (v) {
          case 'add':
            onAddDriver();
            break;
          case 'import':
            onImportCsv();
            break;
          case 'logins':
            onCreateLoginsForAll();
            break;
        }
      },
      itemBuilder: (ctx) => [
        PopupMenuItem(
          value: 'add',
          child: Row(
            children: [
              const Icon(
                Icons.person_add_alt_1_outlined,
                size: 18,
                color: Color(0xFF00B287),
              ),
              const SizedBox(width: 12),
              Text(
                labelAdd,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'import',
          child: Row(
            children: [
              const Icon(
                Icons.file_upload_outlined,
                size: 18,
                color: Color(0xFF374151),
              ),
              const SizedBox(width: 12),
              Text(
                labelImport,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logins',
          child: Row(
            children: [
              const Icon(
                Icons.vpn_key_outlined,
                size: 18,
                color: Color(0xFF2563EB),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  labelLogins,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF00B287),
          borderRadius: BorderRadius.circular(999),
          boxShadow: const [
            BoxShadow(
              color: Color(0x2900B287),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            busy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : const Icon(
                    Icons.add_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
            const SizedBox(width: 6),
            Text(
              labelNew,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Apple-Card-Zeile für die Drivers-Hub-Übersicht. Saubere Oberfläche:
/// Avatar links, Name (groß) plus „X Dokumente fehlen"-Badge darunter,
/// rechts kompakter Score + Aktiv-Switch + 3-Punkt-Menü.
class _DriverHubRow extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> driverDoc;
  final String displayName;
  final String transporterId;
  final bool tidPending;
  final bool active;
  final bool hasLogin;
  final ImageProvider? profileImage;
  final _DriverOverallScoreData? overallScore;
  final DriverContractType? contractType;
  final bool isCompact;
  final VoidCallback onTap;
  final VoidCallback onToggleActive;
  final VoidCallback onCreateOrResetLogin;
  final VoidCallback onDelete;

  const _DriverHubRow({
    required this.driverDoc,
    required this.displayName,
    required this.transporterId,
    required this.tidPending,
    required this.active,
    required this.hasLogin,
    required this.profileImage,
    required this.overallScore,
    required this.contractType,
    required this.isCompact,
    required this.onTap,
    required this.onToggleActive,
    required this.onCreateOrResetLogin,
    required this.onDelete,
  });

  String _formatScore(double v) {
    final n = NumberFormatScore.format(v);
    return '$n %';
  }

  Color _scoreColor(double v) {
    if (v >= 93) return const Color(0xFF00B287);
    if (v >= 85) return const Color(0xFF0082AF);
    if (v >= 75) return const Color(0xFFF7AA00);
    if (v >= 65) return const Color(0xFFF47400);
    return const Color(0xFFCE4121);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final score = overallScore?.averageScore;

    final scoreBlock = score == null
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SCORE',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                '—',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SCORE',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatScore(score),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: _scoreColor(score),
                  letterSpacing: -0.3,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          );

    // Green = active, red = rejected. The red dot calls out drivers
    // the admin deactivated so they stand out against the active
    // pool at the top of the list.
    final activeIndicator = Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFF34C759)
            : const Color(0xFFEF4444),
        shape: BoxShape.circle,
      ),
    );

    final menuButton = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE5E5EA), width: 0.6),
      ),
      child: PopupMenuButton<String>(
        tooltip: t.t('drivers_hub_tooltip_view_details'),
        padding: EdgeInsets.zero,
        iconSize: 22,
        splashRadius: 22,
        icon: const Icon(
          Icons.more_horiz_rounded,
          color: Color(0xFF374151),
        ),
        color: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      onSelected: (v) {
        switch (v) {
          case 'view':
            onTap();
            break;
          case 'toggle':
            onToggleActive();
            break;
          case 'login':
            onCreateOrResetLogin();
            break;
          case 'delete':
            onDelete();
            break;
        }
      },
      itemBuilder: (ctx) => [
        PopupMenuItem(
          value: 'view',
          child: Row(
            children: [
              const Icon(Icons.remove_red_eye_outlined,
                  size: 18, color: Color(0xFF374151)),
              const SizedBox(width: 10),
              Text(t.t('drivers_hub_tooltip_view_details')),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'toggle',
          child: Row(
            children: [
              Icon(
                active
                    ? Icons.toggle_on_rounded
                    : Icons.toggle_off_outlined,
                size: 20,
                color: const Color(0xFF374151),
              ),
              const SizedBox(width: 10),
              Text(active
                  ? t.t('drivers_hub_switch_off')
                  : t.t('drivers_hub_switch_on')),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'login',
          child: Row(
            children: [
              const Icon(Icons.vpn_key_outlined,
                  size: 18, color: Color(0xFF2563EB)),
              const SizedBox(width: 10),
              Text(hasLogin
                  ? t.t('drivers_hub_tooltip_reset_login')
                  : t.t('drivers_hub_tooltip_create_login')),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              const Icon(Icons.delete_outline,
                  size: 18, color: Color(0xFFDC2626)),
              const SizedBox(width: 10),
              Text(
                t.t('drivers_hub_tooltip_delete_driver'),
                style: const TextStyle(
                    color: Color(0xFFDC2626),
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        ],
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 12 : 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE5E5EA),
              width: 0.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFFE5E7EB),
                    backgroundImage: profileImage,
                    child: profileImage == null
                        ? Text(
                            _initials(displayName),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: activeIndicator,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // Name + Warn-Badges (TID fehlt / Docs fehlen)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2937),
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _ContractTypePill(
                          type: contractType,
                          onChanged: (newType) async {
                            await driverDoc.reference.update(
                              <String, dynamic>{
                                if (newType == null)
                                  'contractType':
                                      FieldValue.delete()
                                else
                                  'contractType': newType.value,
                                'updatedAt':
                                    FieldValue.serverTimestamp(),
                              },
                            );
                          },
                        ),
                        if (tidPending)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'TID ausstehend',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF6B7280),
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        _MissingDocsBadge(driverRef: driverDoc.reference),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),
              scoreBlock,
              const SizedBox(width: 4),
              menuButton,
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact card surfacing the driver's employee number + contract
/// type next to the name in the detail-page hero row. Both fields
/// are read-only here — edits happen via the inline pill in the
/// driver list (contract) or by editing the driver doc (employee #).
class _EmploymentInfoCard extends StatelessWidget {
  const _EmploymentInfoCard({
    required this.employeeNumber,
    required this.contractType,
    this.scoreSection,
  });

  final String employeeNumber;
  final DriverContractType? contractType;

  /// Optional pre-built section appended below Vertragstyp. Used to host
  /// the overall-score accordion handle so the score lives next to the
  /// contract type instead of in the page header.
  final Widget? scoreSection;

  @override
  Widget build(BuildContext context) {
    final hasNumber = employeeNumber.trim().isNotEmpty;
    final hasContract = contractType != null;
    final hasScore = scoreSection != null;
    if (!hasNumber && !hasContract && !hasScore) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasNumber) ...[
            Row(
              children: [
                const Icon(
                  Icons.tag_rounded,
                  size: 14,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(width: 6),
                Text(
                  'PERSONALNUMMER',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            SelectableText(
              employeeNumber,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
                letterSpacing: -0.2,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
          if (hasNumber && hasContract)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(
                height: 1,
                color: Color(0xFFE5E7EB),
              ),
            ),
          if (hasContract) ...[
            Row(
              children: [
                Icon(
                  Icons.work_outline_rounded,
                  size: 14,
                  color: contractType!.pillColor,
                ),
                const SizedBox(width: 6),
                Text(
                  'VERTRAGSTYP',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: contractType!.pillColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color:
                      contractType!.pillColor.withValues(alpha: 0.35),
                ),
              ),
              child: Text(
                contractType!.label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: contractType!.pillColor,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ],
          if (hasScore) ...[
            if (hasContract || hasNumber)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(
                  height: 1,
                  color: Color(0xFFE5E7EB),
                ),
              ),
            scoreSection!,
          ],
        ],
      ),
    );
  }
}

/// Row of count-tiles, one per contract type, that sits above the
/// driver list. Desktop renders all six tiles side-by-side; below
/// 720 px they wrap into a responsive grid. The "Unset" tile
/// surfaces drivers without a contract assignment so the admin can
/// see how many still need to be classified.
class _ContractTypeStatsRow extends StatelessWidget {
  const _ContractTypeStatsRow({
    required this.counts,
    required this.totalDrivers,
    required this.compact,
    required this.selected,
    required this.selectedUnset,
    required this.selectedParttimeGroup,
    required this.onSelect,
  });

  final Map<DriverContractType?, int> counts;
  final int totalDrivers;
  final bool compact;
  final DriverContractType? selected;
  final bool selectedUnset;
  final bool selectedParttimeGroup;

  /// Called when the admin taps a tile.
  /// - `type`: the specific contract type filter, or null when clearing.
  /// - `unsetTapped`: true when the "Unset" tile is active.
  /// - `parttimeGroup`: true when the merged "Parttime" tile is active.
  final void Function(
    DriverContractType? type,
    bool unsetTapped,
    bool parttimeGroup,
  ) onSelect;

  bool _isAll() =>
      selected == null && !selectedUnset && !selectedParttimeGroup;
  bool _isType(DriverContractType c) => selected == c;

  /// Sum of every part-time bucket (2d / 3d / 4d).
  int get _parttimeTotal {
    return (counts[DriverContractType.parttime2d] ?? 0) +
        (counts[DriverContractType.parttime3d] ?? 0) +
        (counts[DriverContractType.parttime4d] ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[
      _ContractStatTile(
        label: 'Active',
        value: totalDrivers,
        accent: const Color(0xFF111827),
        icon: Icons.groups_rounded,
        compact: compact,
        isSelected: _isAll(),
        onTap: () => onSelect(null, false, false),
      ),
      _ContractStatTile(
        label: 'Fulltime',
        value: counts[DriverContractType.fulltime] ?? 0,
        accent: DriverContractType.fulltime.pillColor,
        icon: Icons.work_outline_rounded,
        compact: compact,
        isSelected: _isType(DriverContractType.fulltime),
        onTap: () {
          final clear = _isType(DriverContractType.fulltime);
          onSelect(
            clear ? null : DriverContractType.fulltime,
            false,
            false,
          );
        },
      ),
      // Merged Parttime tile — sums 2d / 3d / 4d into a single bucket.
      _ContractStatTile(
        label: 'Parttime',
        value: _parttimeTotal,
        accent: DriverContractType.parttime4d.pillColor,
        icon: Icons.access_time_rounded,
        compact: compact,
        isSelected: selectedParttimeGroup,
        onTap: () => onSelect(null, false, !selectedParttimeGroup),
      ),
      _ContractStatTile(
        label: 'Minijob',
        value: counts[DriverContractType.minijob] ?? 0,
        accent: DriverContractType.minijob.pillColor,
        icon: Icons.schedule_rounded,
        compact: compact,
        isSelected: _isType(DriverContractType.minijob),
        onTap: () {
          final clear = _isType(DriverContractType.minijob);
          onSelect(
            clear ? null : DriverContractType.minijob,
            false,
            false,
          );
        },
      ),
      _ContractStatTile(
        label: 'Dispatcher',
        value: counts[DriverContractType.dispatcher] ?? 0,
        accent: DriverContractType.dispatcher.pillColor,
        icon: Icons.headset_mic_outlined,
        compact: compact,
        isSelected: _isType(DriverContractType.dispatcher),
        onTap: () {
          final clear = _isType(DriverContractType.dispatcher);
          onSelect(
            clear ? null : DriverContractType.dispatcher,
            false,
            false,
          );
        },
      ),
      if ((counts[null] ?? 0) > 0)
        _ContractStatTile(
          label: 'Unset',
          value: counts[null] ?? 0,
          accent: const Color(0xFF6B7280),
          icon: Icons.help_outline_rounded,
          compact: compact,
          isSelected: selectedUnset,
          onTap: () => onSelect(null, !selectedUnset, false),
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Desktop: Kacheln nur so breit wie ihr Inhalt (Titel/Zahl),
        // links bündig statt über die volle Breite gestreckt.
        if (!compact && constraints.maxWidth >= 720) {
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in tiles) IntrinsicWidth(child: t),
            ],
          );
        }
        // Mobile: every tile gets the SAME fixed width so the strip
        // looks uniform. Horizontally scrollable when it doesn't fit.
        const tileWidth = 110.0;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var i = 0; i < tiles.length; i++) ...[
                SizedBox(width: tileWidth, child: tiles[i]),
                if (i < tiles.length - 1) const SizedBox(width: 8),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ContractStatTile extends StatelessWidget {
  const _ContractStatTile({
    required this.label,
    required this.value,
    required this.accent,
    required this.icon,
    this.compact = false,
    this.isSelected = false,
    this.onTap,
  });

  final String label;
  final int value;
  final Color accent;
  final IconData icon;
  final bool compact;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final padding = compact
        ? const EdgeInsets.fromLTRB(8, 6, 10, 6)
        : const EdgeInsets.fromLTRB(12, 10, 12, 10);
    final radius = BorderRadius.circular(compact ? 10 : 14);
    final tile = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: isSelected ? accent.withValues(alpha: 0.10) : Colors.white,
        borderRadius: radius,
        border: Border.all(
          color: isSelected
              ? accent
              : accent.withValues(alpha: 0.18),
          width: isSelected ? 1.6 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: compact
          // Compact (mobile): NO icon, label + big number stacked.
          // All tiles share the same fixed width from the parent
          // SizedBox, so they look uniform across the scrollable strip.
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: accent.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$value',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                    color: accent,
                    fontFeatures:
                        const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 14, color: accent),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        label.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: accent,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$value',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: accent,
                    letterSpacing: -0.5,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
    );
    if (onTap == null) return tile;
    return InkWell(
      onTap: onTap,
      borderRadius: radius,
      child: tile,
    );
  }
}

/// Tap-to-pick contract-type pill. Lives next to the driver name in
/// the row. When unset, shows a neutral "Set contract" placeholder
/// so the admin can classify legacy drivers inline without opening
/// a separate edit dialog. Selection writes to Firestore via
/// [onChanged]; the stats tiles above re-count on the next stream
/// emission.
class _ContractTypePill extends StatelessWidget {
  const _ContractTypePill({
    required this.type,
    required this.onChanged,
  });
  final DriverContractType? type;
  final Future<void> Function(DriverContractType? next) onChanged;

  static const _unsetAccent = Color(0xFF9CA3AF);

  @override
  Widget build(BuildContext context) {
    final isSet = type != null;
    final accent = isSet ? type!.pillColor : _unsetAccent;
    final label = isSet ? type!.shortLabel : 'Set contract';

    return PopupMenuButton<_ContractMenuChoice>(
      tooltip: 'Change contract type',
      position: PopupMenuPosition.under,
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      onSelected: (choice) async {
        if (choice.clear) {
          await onChanged(null);
        } else {
          await onChanged(choice.type);
        }
      },
      itemBuilder: (ctx) => [
        for (final c in DriverContractType.values)
          PopupMenuItem<_ContractMenuChoice>(
            value: _ContractMenuChoice(type: c),
            height: 38,
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: c.pillColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  c.label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: type == c
                        ? FontWeight.w800
                        : FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
                if (type == c) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: c.pillColor,
                  ),
                ],
              ],
            ),
          ),
        if (isSet) ...[
          const PopupMenuDivider(),
          const PopupMenuItem<_ContractMenuChoice>(
            value: _ContractMenuChoice(clear: true),
            height: 36,
            child: Row(
              children: [
                Icon(
                  Icons.clear_rounded,
                  size: 16,
                  color: Color(0xFFB91C1C),
                ),
                SizedBox(width: 10),
                Text(
                  'Clear contract type',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFB91C1C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 3, 6, 3),
        decoration: BoxDecoration(
          color: isSet
              ? accent.withValues(alpha: 0.10)
              : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: accent.withValues(alpha: isSet ? 0.35 : 0.5),
            style: isSet ? BorderStyle.solid : BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSet
                  ? Icons.work_outline_rounded
                  : Icons.add_circle_outline_rounded,
              size: 11,
              color: accent,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: accent,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: 3),
            Icon(
              Icons.arrow_drop_down_rounded,
              size: 14,
              color: accent,
            ),
          ],
        ),
      ),
    );
  }
}

/// Discriminated choice for the contract-type popup menu — either
/// pick a [type] or clear it.
class _ContractMenuChoice {
  const _ContractMenuChoice({this.type, this.clear = false});
  final DriverContractType? type;
  final bool clear;
}

/// Helper-Klasse, kapselt das Score-Formatting für die Driver-Row.
class NumberFormatScore {
  static String format(double v) {
    if (v.isNaN || v.isInfinite) return '—';
    final n = (v * 100).round() / 100;
    if (n == n.truncate().toDouble()) return n.toInt().toString();
    return n.toStringAsFixed(2).replaceAll('.', ',');
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

    return SizedBox(
      height: 44,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: const Color(0xFFE5E5EA), width: 0.6),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            popupMenuTheme: PopupMenuThemeData(
              color: Colors.white,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          child: PopupMenuButton<_DriverSort>(
            tooltip: '',
            splashRadius: 0,
            onSelected: onSelected,
            offset: const Offset(0, 50),
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
              const PopupMenuItem(
                value: _DriverSort.statusActive,
                child: Text('Status (active first)'),
              ),
              const PopupMenuItem(
                value: _DriverSort.scoreLowToHigh,
                child: Text('Overall Score (low → high)'),
              ),
              const PopupMenuDivider(),
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
                const Icon(
                  Icons.sort_rounded,
                  size: 18,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'SORT',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        valueLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: Color(0xFF1F2937),
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

class _AdminDriverToolsRow extends StatefulWidget {
  final VoidCallback onUploadDoc;
  final VoidCallback? onOpenResidencePermitForm;
  final String? dspUid;
  final String? driverDocId;

  const _AdminDriverToolsRow({
    required this.onUploadDoc,
    this.onOpenResidencePermitForm,
    this.dspUid,
    this.driverDocId,
  });

  @override
  State<_AdminDriverToolsRow> createState() => _AdminDriverToolsRowState();
}

class _AdminDriverToolsRowState extends State<_AdminDriverToolsRow> {
  bool _generatingPdf = false;

  Future<void> _generateResidencePermitPdf() async {
    if (widget.dspUid == null || widget.driverDocId == null) return;
    setState(() => _generatingPdf = true);
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'europe-west3')
          .httpsCallable('generateResidencePermitPdf');
      final res = await callable.call<Map<String, dynamic>>({
        'dspUid': widget.dspUid,
        'driverDocId': widget.driverDocId,
      });
      final url = (res.data['pdfUrl'] ?? '').toString();
      if (url.isEmpty) {
        throw Exception('Function returned no URL');
      }
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      final msg = e.code == 'not-found'
          ? 'Noch kein Antrag gespeichert — bitte den Fahrer zuerst das Formular ausfüllen lassen.'
          : 'PDF-Generierung fehlgeschlagen: ${e.message ?? e.code}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: const Color(0xFFB42318)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF-Generierung fehlgeschlagen: $e'),
          backgroundColor: const Color(0xFFB42318),
        ),
      );
    } finally {
      if (mounted) setState(() => _generatingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final canGeneratePdf =
        widget.dspUid != null && widget.driverDocId != null;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        Text(
          t.t('drivers_hub_admin_tools'),
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
        ),
        const SizedBox(width: 12),
        if (widget.onOpenResidencePermitForm != null)
          OutlinedButton.icon(
            onPressed: widget.onOpenResidencePermitForm,
            icon: const Icon(Icons.description_outlined, size: 18),
            label: const Text('Aufenthaltserlaubnis-Antrag'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1D7F5A),
              side: const BorderSide(color: Color(0xFF1D7F5A)),
            ),
          ),
        if (canGeneratePdf)
          OutlinedButton.icon(
            onPressed: _generatingPdf ? null : _generateResidencePermitPdf,
            icon: _generatingPdf
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.picture_as_pdf_outlined, size: 18),
            label: Text(
              _generatingPdf ? 'Wird erzeugt…' : 'PDF herunterladen',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF7C3AED),
              side: const BorderSide(color: Color(0xFF7C3AED)),
            ),
          ),
        FilledButton.icon(
          onPressed: widget.onUploadDoc,
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

  Future<void> _setOwnDriveFlag({
    required BuildContext context,
    required String docType,
    required bool value,
  }) async {
    try {
      await driverRef.collection('documents').doc(docType).set({
        'docType': docType,
        'availableInOwnDrive': value,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler: $e')),
      );
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
          final inOwnDrive = data['availableInOwnDrive'] == true;

          final subtitle = hasUrl
              ? name
              : (inOwnDrive
                    ? 'Im eigenen Drive vorhanden'
                    : t.t('drivers_hub_not_uploaded'));

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
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 6, 4, 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8F8),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE1E4EA)),
                ),
                child: Row(
                  children: [
                    // Leading icon: green checkmark when marked as "in own
                    // Drive", otherwise the neutral file icon.
                    Icon(
                      inOwnDrive
                          ? Icons.check_circle_rounded
                          : Icons.insert_drive_file,
                      size: inOwnDrive ? 18 : 16,
                      color: inOwnDrive
                          ? const Color(0xFF1D7F5A)
                          : const Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _docLabel(context, docType),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF374151),
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: inOwnDrive && !hasUrl
                                  ? const Color(0xFF1D7F5A)
                                  : const Color(0xFF6B7280),
                              fontWeight: inOwnDrive && !hasUrl
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (inOwnDrive)
                      Container(
                        margin: const EdgeInsets.only(right: 2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1FAE5),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_rounded,
                              size: 12,
                              color: Color(0xFF065F46),
                            ),
                            SizedBox(width: 2),
                            Text(
                              'Eigenes Drive',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF065F46),
                              ),
                            ),
                          ],
                        ),
                      ),
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert,
                        size: 18,
                        color: Color(0xFF6B7280),
                      ),
                      tooltip: 'Optionen',
                      padding: EdgeInsets.zero,
                      onSelected: (value) async {
                        switch (value) {
                          case 'upload':
                            await onUploadDoc(docType);
                            break;
                          case 'download':
                            await _downloadDoc(
                              context: context,
                              url: url,
                              fileName: _downloadNameForDoc(
                                context: context,
                                docType: docType,
                                url: url,
                                fileName: name,
                              ),
                            );
                            break;
                          case 'delete':
                            await _deleteDoc(
                              context: context,
                              docType: docType,
                              url: url,
                            );
                            break;
                          case 'toggle_drive':
                            await _setOwnDriveFlag(
                              context: context,
                              docType: docType,
                              value: !inOwnDrive,
                            );
                            break;
                        }
                      },
                      itemBuilder: (ctx) => [
                        PopupMenuItem<String>(
                          value: 'upload',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.upload_outlined,
                                size: 16,
                                color: Color(0xFF374151),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                hasUrl ? 'Datei ersetzen' : t.t('upload'),
                              ),
                            ],
                          ),
                        ),
                        if (hasUrl)
                          PopupMenuItem<String>(
                            value: 'download',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.download_rounded,
                                  size: 16,
                                  color: Color(0xFF374151),
                                ),
                                const SizedBox(width: 10),
                                Text(t.t('drivers_hub_download')),
                              ],
                            ),
                          ),
                        CheckedPopupMenuItem<String>(
                          value: 'toggle_drive',
                          checked: inOwnDrive,
                          child: const Text('Im eigenen Drive vorhanden'),
                        ),
                        if (hasUrl) const PopupMenuDivider(),
                        if (hasUrl)
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.delete_outline,
                                  size: 16,
                                  color: Color(0xFFE11D48),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  t.t('admin_home_delete'),
                                  style: const TextStyle(
                                    color: Color(0xFFE11D48),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final allDocTypes = <String>[
          ...docTypes,
          for (final pair in docPairs) ...pair,
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).t('drivers_hub_documents'),
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            const SizedBox(height: 6),
            for (final docType in allDocTypes)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: docTile(docType),
              ),
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
