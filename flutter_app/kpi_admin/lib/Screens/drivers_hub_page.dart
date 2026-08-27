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
import 'package:material_symbols_icons/symbols.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_storage/firebase_storage.dart' as fb;
import 'package:http/http.dart' as http;

import '../localization/app_localizations.dart';
import '../models/driver_contract_type.dart';
import '../models/employment_period.dart';
import 'add_driver_dialog.dart';
import 'driver_hub_detail_page.dart';
import 'driver_residence_permit_form_page.dart';
import '../services/driver_csv.dart';
import '../services/driver_export_service.dart';
import '../services/driver_identity_service.dart';
import '../services/vacation_pools_repository.dart';
import '../utils/driver_remark.dart';
import '../utils/vacation_pools.dart';
import '../widgets/vacation_pool_lines.dart';
import '../widgets/app_side_menu.dart';
import '../widgets/admin_scope.dart';
import '../widgets/driver_reviews_card.dart';
import '../widgets/clearable_search_field.dart';
import '../widgets/incident_count_chip.dart';
import '../widgets/web_preview.dart'
    if (dart.library.html) '../widgets/web_preview_web.dart';

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
  tidPending,
  employeeIdMissing,
}

class _DriverOverallScoreData {
  const _DriverOverallScoreData({
    required this.averageScore,
    required this.weeksCount,
  });

  final double averageScore;
  final int weeksCount;
}

/// Result of the "switch driver off" dialog. Returned only when the admin
/// confirmed — `endDate == null` means "deactivate, leaving date still open".
class _DeactivateChoice {
  const _DeactivateChoice({required this.endDate});

  final DateTime? endDate;
}

class DriversHubPage extends StatefulWidget {
  const DriversHubPage({super.key, this.initialOpenTid, this.initialEditField});

  /// Ablaufdatum-Feld, dessen Editor nach dem Öffnen sofort aufgehen
  /// soll (aus den Benachrichtigungen heraus). Siehe
  /// [DriverHubDetailPage.autoEditField].
  final String? initialEditField;

  /// When set, the driver with this transporter ID is opened right after
  /// the page mounts (deep link from the home notifications).
  final String? initialOpenTid;

  @override
  State<DriversHubPage> createState() => _DriversHubPageState();
}

class _DriversHubPageState extends State<DriversHubPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _autoOpenHandled = false;

  /// Aktuell eingebettet geöffnete Fahrer-Detailseite (Design 2a) —
  /// gerendert im Shell-Inhalt, damit das Seitenmenü sichtbar bleibt.
  DocumentSnapshot<Map<String, dynamic>>? _detailDriverDoc;

  /// `true`, wenn die offene Detailseite per [initialOpenTid] direkt
  /// angesprungen wurde (z. B. aus einer Warnung der Startseite). Der
  /// Zurück-Pfeil verlässt dann die Route, statt die Fahrerliste zu
  /// zeigen — die hätte in dieser Route keinen eigenen Zurück-Weg.
  bool _detailFromDeepLink = false;

  Future<void> _maybeAutoOpenDriver() async {
    final tid = widget.initialOpenTid?.trim() ?? '';
    if (_autoOpenHandled || tid.isEmpty) return;
    _autoOpenHandled = true;
    final uid = _uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('drivers')
        .doc(tid)
        .get();
    if (!mounted) return;
    if (!doc.exists) {
      // Angesprungener Fahrer existiert nicht mehr: die Route hat außer
      // der Detailseite keinen eigenen Zurück-Weg — also schließen,
      // statt den Aufrufer auf der Liste stranden zu lassen.
      final de = Localizations.localeOf(context).languageCode == 'de';
      if (Navigator.of(context).canPop()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              de ? 'Fahrer nicht gefunden.' : 'Driver not found.',
            ),
          ),
        );
        Navigator.of(context).pop();
      }
      return;
    }
    await _openDriverDetails(doc, fromDeepLink: true);
  }

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

  /// Owned so the clear button (and the CSV import reset) can wipe the visible
  /// text, not just [_search].
  final TextEditingController _searchCtrl = TextEditingController();

  // Ticket "CTRL+F": Cmd/Ctrl+F fokussiert das Suchfeld der Seite
  // (Browser-Suche greift in Flutter-Web nicht).
  final FocusNode _searchFocus = FocusNode();

  bool _onGlobalKey(KeyEvent e) {
    if (e is KeyDownEvent &&
        e.logicalKey == LogicalKeyboardKey.keyF &&
        (HardwareKeyboard.instance.isControlPressed ||
            HardwareKeyboard.instance.isMetaPressed)) {
      if (_searchFocus.canRequestFocus) {
        _searchFocus.requestFocus();
        return true;
      }
    }
    return false;
  }
  // Archive view: inactive drivers are moved out of the main list into a
  // separate archive; toggled by the "Archiv" button.
  bool _showArchive = false;
  _DriverSort _driverSort = _DriverSort.nameAsc;
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
      case _DriverSort.tidPending:
        return 'TID ausstehend';
      case _DriverSort.employeeIdMissing:
        return 'Employee ID missing';
    }
  }

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onGlobalKey);
    _bulkPwdCtrl.addListener(_onDefaultPasswordChanged);
    // Deep link from the home notifications: open the driver directly.
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _maybeAutoOpenDriver());
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onGlobalKey);
    _searchCtrl.dispose();
    _searchFocus.dispose();
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

  // ── Urlaubs-Töpfe (DSP-weit) ────────────────────────────────────────
  // Einmal je Seitenaufruf geladen; ohne Konfigurationsdokument bleibt
  // es bei [VacationPoolsConfig.disabled] = bisheriges Ein-Topf-Verhalten.
  VacationPoolsConfig _vacationPoolsConfig = VacationPoolsConfig.disabled;
  bool _vacationPoolsRequested = false;

  Future<void> _loadVacationPoolsOnce() async {
    if (_vacationPoolsRequested) return;
    final uid = _uid;
    if (uid == null) return;
    _vacationPoolsRequested = true;
    final config = await VacationPoolsRepository.load(uid);
    if (!mounted) return;
    setState(() => _vacationPoolsConfig = config);
  }

  @override
  Widget build(BuildContext context) {
    _loadDefaultDriverPasswordOnce();
    unawaited(_loadVacationPoolsOnce());
    // Detailseite eingebettet rendern, damit das Shell-Menü links
    // sichtbar bleibt; Zurück-Pfeil der Detailseite räumt den State.
    final detailDoc = _detailDriverDoc;
    if (detailDoc != null) {
      return DriverHubDetailPage(
        key: ValueKey('driver-detail-${detailDoc.reference.path}'),
        driverRef: detailDoc.reference,
        dspUid: _uid,
        actions: _detailActionsFor(detailDoc.reference),
        autoEditField: _detailFromDeepLink ? widget.initialEditField : null,
        onBack: () {
          // Direkt angesprungen (Deep-Link): zurück zur aufrufenden
          // Seite. Sonst wie bisher zurück auf die Fahrerliste.
          if (_detailFromDeepLink && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
            return;
          }
          setState(() => _detailDriverDoc = null);
        },
      );
    }
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

  // ADMIN: Edit the driver's main display name (top-level `driverName`).
  // Feedback: admins had to delete + re-add a driver just to fix the name.
  Future<void> _adminEditDriverName({
    required DocumentReference<Map<String, dynamic>> driverRef,
    required String initialValue,
  }) async {
    final t = AppLocalizations.of(context);
    final label =
        Localizations.localeOf(context).languageCode == 'de'
            ? 'Anzeigename'
            : 'Display name';
    final ctrl = TextEditingController(text: initialValue);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.tf('drivers_hub_edit_label', {'label': label})),
        content: SizedBox(
          width: 520,
          child: TextFormField(
            controller: ctrl,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
            ),
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
      final v = ctrl.text.trim();
      if (v.isEmpty) {
        ctrl.dispose();
        return;
      }
      await driverRef.set({
        'driverName': v,
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
        SnackBar(content: Text('$e')),
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

  /// Admin picker for the driver's preferred language. Writes the language
  /// code to `onboarding.language` on the driver doc (same field the
  /// onboarding form uses; value is a `Locale.languageCode` like 'de'/'en').
  Future<void> _adminEditDriverLanguage({
    required DocumentReference<Map<String, dynamic>> driverRef,
    required dynamic initialValue,
  }) async {
    final t = AppLocalizations.of(context);
    final de = Localizations.localeOf(context).languageCode == 'de';
    final current = (initialValue ?? '').toString().trim();
    String selected = AppLocalizations.supportedLocales
            .any((l) => l.languageCode == current)
        ? current
        : Localizations.localeOf(context).languageCode;
    if (!AppLocalizations.supportedLocales
        .any((l) => l.languageCode == selected)) {
      selected = 'de';
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(de ? 'Fahrersprache' : 'Driver language'),
        content: SizedBox(
          width: 420,
          child: StatefulBuilder(
            builder: (ctx, setLocal) => DropdownButtonFormField<String>(
              value: selected,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: de ? 'Sprache' : 'Language',
                border: const OutlineInputBorder(),
              ),
              items: [
                for (final loc in AppLocalizations.supportedLocales)
                  DropdownMenuItem(
                    value: loc.languageCode,
                    child: Text(languageLabel(loc.languageCode)),
                  ),
              ],
              onChanged: (value) {
                if (value != null) setLocal(() => selected = value);
              },
            ),
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
      await driverRef.set({
        'onboarding': {'language': selected},
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(de
              ? 'Fahrersprache gespeichert: ${languageLabel(selected)}'
              : 'Driver language saved: ${languageLabel(selected)}'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${de ? 'Speichern fehlgeschlagen' : 'Save failed'}: $e'),
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

  /// Resturlaub-Zeile.
  ///
  /// Rechnet nicht mehr selbst, sondern über [computeVacationBalance] —
  /// dieselbe Quelle, aus der auch die Detailseite, die „DA Balance" und
  /// die Fahrer-App ihre Zahl ziehen. Damit kann Admin/Fahrer nicht mehr
  /// auseinanderlaufen.
  Widget _remainingVacationDaysRow({
    required DocumentReference<Map<String, dynamic>> driverRef,
    required Map<String, dynamic> onboarding,
  }) {
    final t = AppLocalizations.of(context);
    final label = t.t('drivers_hub_field_remaining_vacation_days');
    final config = _vacationPoolsConfig.forDriver(onboarding);

    // Manueller Admin-Override. Er ist KEIN eingefrorener Endwert mehr,
    // sondern eine Momentaufnahme zum Zeitpunkt
    // `remainingVacationDaysOverrideAt` — später erfasster Urlaub wird
    // davon abgezogen (siehe `utils/vacation_pools.dart`).
    final override = vacationOverrideOf(onboarding);
    final editedAt = vacationOverrideAtOf(onboarding);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: driverRef.collection('absence_requests').snapshots(),
      builder: (context, snap) {
        VacationBalance? balance;
        VacationBalance? withoutOverride;
        if (!snap.hasError &&
            snap.connectionState != ConnectionState.waiting) {
          final absences = <VacationAbsence>[
            for (final doc in snap.data?.docs ??
                const <QueryDocumentSnapshot<Map<String, dynamic>>>[])
              if (VacationAbsence.fromMap(doc.data()) case final a?) a,
          ];
          final annual = annualVacationDaysOf(onboarding);
          final workStartDate =
              parseVacationDate(onboarding['workStartDate']);
          balance = computeVacationBalance(
            absences: absences,
            config: config,
            annualVacationDays: annual,
            workStartDate: workStartDate,
            manualOverride: override,
            manualOverrideAt: editedAt,
          );
          withoutOverride = computeVacationBalance(
            absences: absences,
            config: config,
            annualVacationDays: annual,
            workStartDate: workStartDate,
          );
        }

        final valueText = balance == null
            ? (snap.hasError ? '—' : '...')
            : _formatVacationDays(balance.totalRemaining);

        return _remainingVacationRowUI(
          label: label,
          value: valueText,
          edited: override != null,
          editedAt: editedAt,
          computedText: withoutOverride == null
              ? null
              : _formatVacationDays(withoutOverride.totalRemaining),
          balance: balance,
          onEdit: () => _editRemainingVacationOverride(
            driverRef: driverRef,
            label: label,
            currentOverride: override,
            computed: withoutOverride?.totalRemaining,
          ),
        );
      },
    );
  }

  /// Row for "remaining vacation days": value + optional "edited" badge +
  /// admin edit pencil. The badge and pencil only ever render inside the
  /// admin Drivers Hub, so this is admin-only by construction.
  Widget _remainingVacationRowUI({
    required String label,
    required String value,
    required bool edited,
    required DateTime? editedAt,
    required String? computedText,
    required VoidCallback onEdit,
    VacationBalance? balance,
  }) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final hasText = value.trim().isNotEmpty && value != '—';
    final usedSince = balance?.usedSinceOverride ?? 0;

    String editedTooltip() {
      final parts = <String>[
        de ? 'Manuell gesetzt' : 'Manually set',
        if (balance?.overrideValue != null)
          de
              ? 'Startwert: ${_formatVacationDays(balance!.overrideValue!)} Tage'
              : 'Baseline: ${_formatVacationDays(balance!.overrideValue!)} days',
        if (editedAt != null)
          '${editedAt.day.toString().padLeft(2, '0')}.'
              '${editedAt.month.toString().padLeft(2, '0')}.${editedAt.year}',
        // Wichtig fürs Verständnis: seither erfasster Urlaub wird vom
        // Startwert abgezogen (früher blieb die Zahl einfach stehen).
        if (usedSince > 0)
          de
              ? 'seither ${_formatVacationDays(usedSince)} Tage Urlaub abgezogen'
              : '${_formatVacationDays(usedSince)} days deducted since',
        if (computedText != null)
          de ? 'Ohne Anpassung: $computedText' : 'Without override: $computedText',
      ];
      return parts.join(' · ');
    }

    return _DetailRow(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SelectableText(
                      hasText ? value : '—',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: hasText
                            ? const Color(0xFF111827)
                            : const Color(0xFFCBD5E1),
                      ),
                    ),
                    if (edited) ...[
                      const SizedBox(width: 8),
                      Tooltip(
                        message: editedTooltip(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: const Color(0xFFFDBA74)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.edit_note_rounded,
                                  size: 13, color: Color(0xFFC2410C)),
                              const SizedBox(width: 3),
                              Text(
                                de ? 'bearbeitet' : 'edited',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFC2410C),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints.tightFor(width: 28, height: 28),
                      visualDensity: VisualDensity.compact,
                      splashRadius: 16,
                      color: const Color(0xFF6B7280),
                      tooltip: AppLocalizations.of(context)
                          .tf('drivers_hub_edit_label', {'label': label}),
                      onPressed: onEdit,
                    ),
                  ],
                ),
                // Getrennte Töpfe mit eigenem Verfallsdatum — nur wenn
                // der DSP sie eingeschaltet hat.
                if (balance != null) VacationPoolLines(balance: balance),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Admin dialog to set or clear the manual remaining-vacation override.
  Future<void> _editRemainingVacationOverride({
    required DocumentReference<Map<String, dynamic>> driverRef,
    required String label,
    required double? currentOverride,
    required double? computed,
  }) async {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final t = AppLocalizations.of(context);
    final ctrl = TextEditingController(
      text: currentOverride != null
          ? _formatVacationDays(currentOverride)
          : (computed != null ? _formatVacationDays(computed) : ''),
    );

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.tf('drivers_hub_edit_label', {'label': label})),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 460,
              child: TextField(
                controller: ctrl,
                autofocus: true,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: de ? 'z. B. 12' : 'e.g. 12',
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              computed != null
                  ? (de
                      ? 'Automatisch berechnet: ${_formatVacationDays(computed)} Tage. '
                          'Der eingetragene Wert gilt als Stand von HEUTE — '
                          'jeder danach erfasste Urlaub wird davon abgezogen. '
                          'Leeren + Speichern setzt auf den berechneten Wert zurück.'
                      : 'Auto-calculated: ${_formatVacationDays(computed)} days. '
                          'The value you enter is the balance as of TODAY — '
                          'any leave booked afterwards is deducted from it. '
                          'Clear + Save reverts to the calculated value.')
                  : (de
                      ? 'Der eingetragene Wert gilt als Stand von HEUTE — jeder '
                          'danach erfasste Urlaub wird davon abgezogen. '
                          'Leeren + Speichern entfernt die manuelle Anpassung.'
                      : 'The value you enter is the balance as of TODAY — any '
                          'leave booked afterwards is deducted from it. '
                          'Clear + Save removes the manual override.'),
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('__cancel__'),
            child: Text(t.t('admin_home_cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()),
            child: Text(t.t('button_save')),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (result == null || result == '__cancel__') return;

    try {
      if (result.isEmpty) {
        // Clear the override → back to auto-calculation.
        await driverRef.set({
          'onboarding': {
            'remainingVacationDaysOverride': FieldValue.delete(),
            'remainingVacationDaysOverrideAt': FieldValue.delete(),
          },
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        final parsed =
            double.tryParse(result.replaceAll(',', '.'));
        if (parsed == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(de ? 'Ungültige Zahl.' : 'Invalid number.'),
            ),
          );
          return;
        }
        final stored = parsed % 1 == 0 ? parsed.toInt() : parsed;
        await driverRef.set({
          'onboarding': {
            'remainingVacationDaysOverride': stored,
            'remainingVacationDaysOverrideAt': FieldValue.serverTimestamp(),
          },
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
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
            t.tf('drivers_hub_failed_update_label',
                {'label': label, 'error': '$e'}),
          ),
        ),
      );
    }
  }

  // Bestandshelfer `_annualVacationDaysFromOnboarding`,
  // `_approvedVacationDaysFromRequests`, `_inclusiveDays` und
  // `_completedMonthsSince` sind nach `utils/vacation_pools.dart`
  // gewandert — dort liegt jetzt die EINE Urlaubs-Formel fuer Admin und
  // Fahrer-App.

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
        IconButton(
          onPressed: _openVacationPoolsSettings,
          icon: const Icon(Icons.beach_access_outlined, size: 20),
          color: const Color(0xFF6B7280),
          tooltip: Localizations.localeOf(context).languageCode == 'de'
              ? 'Urlaubstöpfe (Verfallsdaten)'
              : 'Leave pools (expiry dates)',
        ),
        const SizedBox(width: 4),
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
  // DSP-weite Urlaubs-Töpfe
  // ---------------------------------------------------------------------------

  /// Konfiguriert die Urlaubs-Töpfe für den ganzen DSP:
  /// Tageszahl + Verfallsdatum je Topf, plus An/Aus-Schalter.
  ///
  /// Ausgeschaltet (= kein Dokument) verhält sich die App exakt wie
  /// vorher: EIN Topf „Urlaub pro Jahr" ohne Verfallsdatum.
  Future<void> _openVacationPoolsSettings() async {
    final uid = _uid;
    if (uid == null) return;
    final de = Localizations.localeOf(context).languageCode == 'de';
    final t = AppLocalizations.of(context);

    final current = await VacationPoolsRepository.load(uid);
    if (!mounted) return;

    final base = current.enabled ? current : VacationPoolsConfig.defaults;
    var enabled = current.enabled;
    final ctrls = <String, TextEditingController>{};
    final expiry = <String, DateTime>{};
    final offsets = <String, int>{};
    for (final pool in base.pools) {
      ctrls[pool.key] =
          TextEditingController(text: formatVacationDays(pool.days));
      // Jahr ist Platzhalter — gespeichert werden nur Monat/Tag/Offset.
      expiry[pool.key] = DateTime(2000, pool.expiryMonth, pool.expiryDay);
      offsets[pool.key] = pool.expiryYearOffset;
    }

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(de ? 'Urlaubstöpfe' : 'Leave pools'),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    de
                        ? 'Getrennte Urlaubskontingente mit eigenem Verfallsdatum. '
                            'Genommene Tage werden zuerst vom Topf abgezogen, der '
                            'zuerst verfällt. Ausgeschaltet bleibt es beim '
                            'bisherigen einzelnen Kontingent „Urlaub pro Jahr".'
                        : 'Separate leave quotas, each with its own expiry date. '
                            'Days taken are deducted from the pool that expires '
                            'first. When switched off, the existing single '
                            '"Annual leave" quota stays in place.',
                    style: const TextStyle(
                        fontSize: 12.5, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: enabled,
                    onChanged: (v) => setLocal(() => enabled = v),
                    title: Text(
                      de ? 'Getrennte Töpfe verwenden' : 'Use separate pools',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const Divider(height: 20),
                  for (final pool in base.pools) ...[
                    Text(
                      vacationPoolLabel(ctx, pool.key),
                      style: const TextStyle(
                          fontSize: 13.5, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        SizedBox(
                          width: 110,
                          child: TextField(
                            controller: ctrls[pool.key],
                            enabled: enabled,
                            keyboardType: const TextInputType
                                .numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: de ? 'Tage' : 'Days',
                              isDense: true,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: !enabled
                                ? null
                                : () async {
                                    final picked = await showDatePicker(
                                      context: ctx,
                                      initialDate: DateTime(
                                        2000,
                                        expiry[pool.key]!.month,
                                        expiry[pool.key]!.day,
                                      ),
                                      firstDate: DateTime(2000, 1, 1),
                                      lastDate: DateTime(2000, 12, 31),
                                      helpText: de
                                          ? 'Verfallstag (Tag & Monat)'
                                          : 'Expiry (day & month)',
                                    );
                                    if (picked == null) return;
                                    setLocal(() => expiry[pool.key] = picked);
                                  },
                            icon: const Icon(Icons.event_outlined, size: 16),
                            label: Text(
                              '${expiry[pool.key]!.day.toString().padLeft(2, '0')}.'
                              '${expiry[pool.key]!.month.toString().padLeft(2, '0')}.',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<int>(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            value: 0,
                            groupValue: offsets[pool.key],
                            onChanged: !enabled
                                ? null
                                : (v) => setLocal(() => offsets[pool.key] = 0),
                            title: Text(
                              de ? 'gleiches Jahr' : 'same year',
                              style: const TextStyle(fontSize: 12.5),
                            ),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<int>(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            value: 1,
                            groupValue: offsets[pool.key],
                            onChanged: !enabled
                                ? null
                                : (v) => setLocal(() => offsets[pool.key] = 1),
                            title: Text(
                              de ? 'Folgejahr' : 'following year',
                              style: const TextStyle(fontSize: 12.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  Text(
                    de
                        ? 'Hinweis: Gesetzlicher Urlaub verfällt nur, wenn die '
                            'Beschäftigten rechtzeitig an den Resturlaub erinnert '
                            'wurden. Die App zeigt das Datum nur an — sie '
                            'verschickt keine Erinnerung.'
                        : 'Note: statutory leave only expires if employees were '
                            'reminded in time. The app only displays the date — '
                            'it does not send reminders.',
                    style: const TextStyle(
                        fontSize: 11.5, color: Color(0xFF9CA3AF)),
                  ),
                ],
              ),
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
      ),
    );

    final next = VacationPoolsConfig(
      enabled: enabled,
      pools: base.pools
          .map((pool) => VacationPoolDef(
                key: pool.key,
                days: double.tryParse(
                        ctrls[pool.key]!.text.trim().replaceAll(',', '.')) ??
                    pool.days,
                expiryMonth: expiry[pool.key]!.month,
                expiryDay: expiry[pool.key]!.day,
                expiryYearOffset: offsets[pool.key]!,
              ))
          .toList(growable: false),
    );
    for (final ctrl in ctrls.values) {
      ctrl.dispose();
    }
    if (saved != true) return;

    try {
      await VacationPoolsRepository.save(uid, next);
      if (!mounted) return;
      setState(() => _vacationPoolsConfig = next);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(de ? 'Gespeichert.' : 'Saved.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(de ? 'Speichern fehlgeschlagen: $e' : 'Save failed: $e'),
        ),
      );
    }
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
        SnackBar(
          content: Text(
            Localizations.localeOf(context).languageCode == 'de'
                ? 'Export fehlgeschlagen: $e'
                : 'Export failed: $e',
          ),
        ),
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
        _searchCtrl.clear();
        setState(() {
          _search = '';
          _driverSort = _DriverSort.idAsc;
        });
      }

      if (!mounted) return;
      final de = Localizations.localeOf(context).languageCode == 'de';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: importResult.hasWarnings
              ? const Duration(seconds: 10)
              : const Duration(seconds: 4),
          backgroundColor:
              importResult.hasWarnings ? const Color(0xFFB45309) : null,
          content: Text(
            '${t.tf('drivers_hub_csv_imported_for_dsp', {'file': f.name})} '
            '${importResult.summary(de: de)}',
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
      SnackBar(
        content: Text(
          Localizations.localeOf(context).languageCode == 'de'
              ? 'Fahrer angelegt.'
              : 'Driver created.',
        ),
      ),
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
    final hasNewTid = newTid.isNotEmpty;
    // Ein echter Umzug ist fällig, sobald eine TID vorliegt und die
    // Doc-ID nicht schon danach heißt — das gilt für Platzhalter-Docs
    // (`PENDING-XXXXXX`) genauso wie für alte Auto-ID-Dokumente.
    final tidChanged = hasNewTid && driverDoc.id.toUpperCase() != newTid;

    try {
      // Decide which document we will finally use
      DocumentReference<Map<String, dynamic>> targetRef = driverDoc.reference;
      var loginSyncWarning = false;

      if (tidChanged) {
        // Vollständiger Umzug auf die TID-basierte Doc-ID.
        //
        // Früher wurde hier nur das Fahrer-Dokument 1:1 kopiert: die
        // Subcollections (Dokumente, Zeitkonto, Nachweise) blieben an der
        // alten ID zurück und `tidPending: true` wurde mitkopiert, sodass
        // Fahrer mit echter TID weiter als „TID ausstehend" erschienen.
        // `migrateDriverToTid` nimmt alles mit und setzt das Flag korrekt.
        final moved = await migrateDriverToTid(
          dspUid: _uid!,
          fromDocId: driverDoc.id,
          toTid: newTid,
        );
        loginSyncWarning = moved.hasLoginSyncWarning;

        targetRef = driverDoc.reference.parent.doc(newTid);
        await targetRef.set({
          'email': email,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
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

      final de = Localizations.localeOf(context).languageCode == 'de';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor:
              loginSyncWarning ? const Color(0xFFB45309) : null,
          content: Text(
            loginSyncWarning
                ? (de
                    ? 'Gespeichert — der Fahrer-Login konnte aber nicht auf '
                        'die neue TID synchronisiert werden.'
                    : 'Saved — but the driver login could not be synced to '
                        'the new TID.')
                : t.t('drivers_hub_driver_login_saved'),
          ),
        ),
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

  /// Öffnet das Werkzeug „Profile zusammenführen".
  ///
  /// Bekommt die bereits geladenen Fahrer-Dokumente mit, damit der Dialog
  /// die Gegenüberstellung ohne erneute Fahrer-Query rendern kann. Nur die
  /// Zähler je Datenbereich holt er selbst nach.
  Future<void> _openMergeDuplicatesDialog(
    List<DuplicateDriverGroup> groups,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    if (_uid == null) return;
    final driverData = <String, Map<String, dynamic>>{
      for (final d in docs) d.id: d.data(),
    };
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _MergeDuplicateProfilesDialog(
        dspUid: _uid!,
        groups: groups,
        driverData: driverData,
      ),
    );
  }

  /// Ask for the contract end date before a driver is switched off.
  ///
  /// Returns `null` when the admin cancelled (the driver must stay active).
  /// A returned choice either carries the picked [DateTime] or says
  /// "deactivate without an end date" — a leaving date is not always known
  /// yet, so switching off must never be blocked by it.
  Future<_DeactivateChoice?> _askContractEndDateDialog({
    required String driverName,
    required DateTime? periodStart,
  }) async {
    final de = Localizations.localeOf(context).languageCode == 'de';
    String tr(String d, String e) => de ? d : e;

    final today = DateTime.now();
    DateTime endDate = DateTime(today.year, today.month, today.day);

    return showDialog<_DeactivateChoice>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            return AlertDialog(
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: Text(
                tr('Fahrer deaktivieren', 'Deactivate driver'),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              content: SizedBox(
                width: 380,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      driverName.trim().isEmpty
                          ? tr(
                              'Das Vertragsende wird im Beschäftigungszeitraum '
                                  'gespeichert und schließt den laufenden Vertrag ab.',
                              'The contract end date is stored on the employment '
                                  'period and closes the running contract.',
                            )
                          : tr(
                              '$driverName wird abgeschaltet. Das Vertragsende '
                                  'wird im Beschäftigungszeitraum gespeichert und '
                                  'schließt den laufenden Vertrag ab.',
                              '$driverName will be switched off. The contract end '
                                  'date is stored on the employment period and '
                                  'closes the running contract.',
                            ),
                      style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.35,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 14),
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: endDate,
                          firstDate: DateTime(1990),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setSheet(() => endDate = picked);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 11),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.event_rounded,
                                size: 16, color: Color(0xFF6B7280)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                tr('Vertragsende', 'Contract end'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ),
                            Text(
                              _formatDate(endDate),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.edit_calendar_rounded,
                                size: 15, color: Color(0xFF9CA3AF)),
                          ],
                        ),
                      ),
                    ),
                    if (periodStart != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        tr(
                          'Vertragsbeginn: ${_formatDate(periodStart)}',
                          'Contract start: ${_formatDate(periodStart)}',
                        ),
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          foregroundColor: const Color(0xFF6B7280),
                        ),
                        onPressed: () => Navigator.of(ctx)
                            .pop(const _DeactivateChoice(endDate: null)),
                        icon: const Icon(Icons.block_rounded, size: 15),
                        label: Text(
                          tr('Ohne Datum deaktivieren',
                              'Deactivate without a date'),
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(tr('Abbrechen', 'Cancel')),
                ),
                FilledButton(
                  onPressed: () {
                    if (periodStart != null && endDate.isBefore(periodStart)) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFFB42318),
                          content: Text(tr(
                              'Das Vertragsende liegt vor dem Beginn.',
                              'The contract end is before the start.')),
                        ),
                      );
                      return;
                    }
                    Navigator.of(ctx).pop(_DeactivateChoice(endDate: endDate));
                  },
                  child: Text(tr('Übernehmen', 'Apply')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Asks whether a still-set contract end date should be dropped when a
  /// driver is switched back on. Never removes anything on its own — an
  /// active driver with an end date in the past is contradictory, so we let
  /// the admin decide instead of silently rewriting the period.
  ///
  /// Returns `null` on cancel, `true` to clear the end date, `false` to keep it.
  Future<bool?> _askClearContractEndDialog(DateTime end) async {
    final de = Localizations.localeOf(context).languageCode == 'de';
    String tr(String d, String e) => de ? d : e;
    final shown = _formatDate(end);

    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          tr('Fahrer aktivieren', 'Activate driver'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        content: SizedBox(
          width: 380,
          child: Text(
            tr(
              'Für diesen Fahrer ist ein Vertragsende am $shown hinterlegt. '
                  'Soll das Enddatum entfernt werden, damit der Vertrag wieder '
                  'als laufend gilt?',
              'This driver has a contract end date on $shown. Remove the end '
                  'date so the contract counts as running again?',
            ),
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.35,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(tr('Abbrechen', 'Cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(tr('Datum behalten', 'Keep the date')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(tr('Enddatum entfernen', 'Remove end date')),
          ),
        ],
      ),
    );
  }

  /// Writes [endDate] (or `null` to reopen the contract) onto the driver's
  /// current employment period — always through [_saveEmploymentPeriods], so
  /// the legacy `onboarding.*` mirror stays in sync.
  Future<void> _setContractEndOnCurrentPeriod({
    required DocumentSnapshot<Map<String, dynamic>> driverDoc,
    required DateTime? endDate,
  }) async {
    final data = driverDoc.data() ?? <String, dynamic>{};
    final periods = employmentPeriodsOf(data);
    final currentTid = (data['transporterId'] ?? '').toString().trim();
    final iso = endDate == null ? '' : formatIsoDate(endDate);

    List<EmploymentPeriod> next;
    if (periods.isEmpty) {
      // No period and no legacy start date known. Reopening makes no sense
      // here, and we do not invent a contract out of nothing.
      if (endDate == null) return;
      // Seed one period so the end date has somewhere to live: the driver
      // document's creation day is the best start we have, clamped to the
      // end date when it is newer (or missing).
      final created = parseFlexibleDate(data['createdAt']);
      final start = (created == null || created.isAfter(endDate))
          ? endDate
          : created;
      next = [
        EmploymentPeriod(
          start: formatIsoDate(start),
          end: iso,
          transporterId: currentTid,
        ),
      ];
    } else {
      final current = currentEmploymentPeriod(periods);
      if (current == null) return;
      final index = periods.indexWhere((p) =>
          p.start == current.start &&
          p.end == current.end &&
          p.transporterId == current.transporterId);
      if (index < 0) return;
      next = [...periods];
      next[index] = current.copyWith(end: iso);
    }

    await _saveEmploymentPeriods(
      driverRef: driverDoc.reference,
      periods: next,
      previousTid: currentTid,
    );
  }

  /// Toggle active / suspended state.
  ///
  /// Switching a driver **off** first asks for the contract end date (feedback
  /// ticket): the date is stored on the running employment period, but the
  /// admin can also deactivate without one when the leaving date is still open.
  Future<void> _onToggleActiveDriver(
    DocumentSnapshot<Map<String, dynamic>> driverDoc,
    bool currentlyActive,
  ) async {
    final t = AppLocalizations.of(context);
    if (_uid == null) return;
    final newActive = !currentlyActive;

    final data = driverDoc.data() ?? <String, dynamic>{};
    final current = currentEmploymentPeriod(employmentPeriodsOf(data));

    DateTime? pendingEnd;
    var clearEnd = false;

    if (!newActive) {
      final choice = await _askContractEndDateDialog(
        driverName: (data['driverName'] ?? '').toString(),
        periodStart: current?.startDate,
      );
      if (choice == null) return; // cancelled — driver stays active
      pendingEnd = choice.endDate;
    } else {
      // Re-activating never drops the end date on its own; we only offer it,
      // because an active driver whose contract ended in the past would show
      // up as "expired" in every report that reads onboarding.contractExpiry.
      final existingEnd = current?.endDate;
      if (existingEnd != null) {
        final answer = await _askClearContractEndDialog(existingEnd);
        if (answer == null) return; // cancelled — driver stays inactive
        clearEnd = answer;
      }
    }

    if (!mounted) return;

    if (pendingEnd != null) {
      await _setContractEndOnCurrentPeriod(
        driverDoc: driverDoc,
        endDate: pendingEnd,
      );
    } else if (clearEnd) {
      await _setContractEndOnCurrentPeriod(
        driverDoc: driverDoc,
        endDate: null,
      );
    }

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
      case 'resident_permit_back':
        return Localizations.localeOf(context).languageCode == 'de'
            ? 'Aufenthaltstitel (Rückseite)'
            : 'Residence permit (back)';
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
      case 'safety_training_certificate':
        return Localizations.localeOf(context).languageCode == 'de'
            ? 'Sicherheitsunterweisung (Zertifikat)'
            : 'Safety instruction (certificate)';
      case 'privacy_training_certificate':
        return Localizations.localeOf(context).languageCode == 'de'
            ? 'Datenschutz-Schulung (Zertifikat)'
            : 'Privacy training (certificate)';
      case 'privacy_notice_ack':
        return Localizations.localeOf(context).languageCode == 'de'
            ? 'Datenschutzinformation (Kenntnisnahme)'
            : 'Privacy notice (acknowledgement)';
      case 'camera_privacy_ack_certificate':
        return Localizations.localeOf(context).languageCode == 'de'
            ? 'Kamera-Datenschutz (Kenntnisnahme)'
            : 'Camera privacy (acknowledgement)';
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
  /// Nach einem TID-Wechsel: fragt, ob damit eine neue Beschaeftigung
  /// beginnt. Sagt der Admin ja und nennt ein Startdatum, schliesst der
  /// bisherige Zeitraum am Vortag (die alte ID ist damit inaktiv) und ein
  /// neuer Zeitraum mit der neuen ID beginnt — der Fahrer wird wieder
  /// aktiv gesetzt.
  Future<void> _offerRehirePeriodAfterTidChange({
    required DocumentReference<Map<String, dynamic>> driverRef,
    required String oldTid,
    required String newTid,
  }) async {
    if (!mounted) return;
    final de = Localizations.localeOf(context).languageCode == 'de';

    final wantsNewPeriod = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          de ? 'Neue Beschäftigung?' : 'New employment?',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        content: Text(
          de
              ? 'Beginnt mit der ID "$newTid" ein neuer Vertrag? Dann wird '
                  '"$oldTid" als abgeschlossener Zeitraum abgelegt und damit '
                  'inaktiv, und ab dem gewählten Vertragsbeginn läuft die '
                  'neue ID.'
              : 'Does ID "$newTid" start a new contract? Then "$oldTid" is '
                  'filed as a closed period — and therefore inactive — and '
                  'the new ID runs from the contract start you pick.',
          style: const TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(de ? 'Nein, nur umbenannt' : 'No, just renamed'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(de ? 'Vertragsbeginn wählen' : 'Pick contract start'),
          ),
        ],
      ),
    );
    if (wantsNewPeriod != true || !mounted) return;

    final today = DateTime.now();
    final start = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: DateTime(today.year - 10),
      lastDate: DateTime(today.year + 2),
      helpText: de ? 'Vertragsbeginn' : 'Contract start',
    );
    if (start == null || !mounted) return;

    final snap = await driverRef.get();
    final data = snap.data() ?? <String, dynamic>{};
    final periods = employmentPeriodsOf(data);
    final dayBefore = start.subtract(const Duration(days: 1));

    final next = <EmploymentPeriod>[];
    for (final period in periods) {
      // Laufende Zeiträume vor dem neuen Start schliessen — offen bleiben
      // darf nur der neue.
      if (period.endDate == null &&
          (period.startDate == null || period.startDate!.isBefore(start))) {
        next.add(period.copyWith(
          end: formatIsoDate(dayBefore),
          transporterId:
              period.transporterId.trim().isEmpty ? oldTid : null,
        ));
      } else {
        next.add(period);
      }
    }
    next.add(EmploymentPeriod(
      start: formatIsoDate(start),
      end: '',
      transporterId: newTid,
    ));

    await _saveEmploymentPeriods(
      driverRef: driverRef,
      periods: next,
      previousTid: oldTid,
    );
    await driverRef.set(<String, dynamic>{
      'active': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          de
              ? '"$oldTid" endet am ${formatShortDate(dayBefore)}, '
                  '"$newTid" ist ab ${formatShortDate(start)} aktiv.'
              : '"$oldTid" ends on ${formatShortDate(dayBefore)}, '
                  '"$newTid" is active from ${formatShortDate(start)}.',
        ),
      ),
    );
  }

  /// Freie Bemerkung zum Fahrer (Ticket „DRIVER'S HUB").
  ///
  /// Liegt als Feld `remark` auf dem Fahrerdokument und erscheint im
  /// Monatsplan unter dem Namen. Leeres Feld = Bemerkung entfernen.
  Future<void> _editDriverRemark(
    DocumentSnapshot<Map<String, dynamic>> driverDoc,
    String currentRemark,
  ) async {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final ctrl = TextEditingController(text: currentRemark);

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          de ? 'Bemerkung' : 'Remark',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                de
                    ? 'Kurze Notiz zu diesem Fahrer — sie erscheint im '
                        'Monatsplan direkt unter dem Namen.'
                    : 'A short note about this driver — it appears in the '
                        'monthly plan right below the name.',
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                autofocus: true,
                minLines: 2,
                maxLines: 4,
                maxLength: kDriverRemarkMaxLength,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: de
                      ? 'z. B. nur Frühschicht, kein Kastenwagen'
                      : 'e.g. early shift only, no box van',
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
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(de ? 'Abbrechen' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()),
            child: Text(de ? 'Speichern' : 'Save'),
          ),
        ],
      ),
    );

    if (result == null) return; // abgebrochen
    if (result == currentRemark.trim()) return; // unveraendert

    try {
      await driverDoc.reference.set(<String, dynamic>{
        'remark': result,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.isEmpty
                ? (de ? 'Bemerkung entfernt.' : 'Remark removed.')
                : (de ? 'Bemerkung gespeichert.' : 'Remark saved.'),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFB42318),
          content: Text(
            de
                ? 'Bemerkung konnte nicht gespeichert werden: $e'
                : 'Could not save the remark: $e',
          ),
        ),
      );
    }
  }

  Future<void> _editTransporterId(
    DocumentSnapshot<Map<String, dynamic>> driverDoc,
    String currentTid,
  ) async {
    final de = Localizations.localeOf(context).languageCode == 'de';
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
              Text(
                de ? 'Transporter ID bearbeiten' : 'Edit Transporter ID',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                de
                    ? 'Die TID identifiziert den Fahrer in Amazon-Reports. '
                        'Buchstaben + Zahlen, ohne Leerzeichen. Wird beim '
                        'Speichern automatisch in Großbuchstaben gewandelt.'
                    : 'The TID identifies the driver in Amazon reports. '
                        'Letters + digits, no spaces. Converted to upper '
                        'case automatically on save.',
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
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
                    child: Text(de ? 'Abbrechen' : 'Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () =>
                        Navigator.of(ctx).pop(ctrl.text.trim().toUpperCase()),
                    icon: const Icon(Icons.save_outlined, size: 18),
                    label: Text(de ? 'Speichern' : 'Save'),
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
                de
                    ? 'Ein anderer Fahrer benutzt die TID "$newTid" bereits.'
                    : 'Another driver already uses the TID "$newTid".',
              ),
            ),
          );
          return;
        }
      }

      // Es gibt genau EINEN Weg für einen TID-Wechsel:
      // `migrateDriverToTid`. Der Umzug nimmt die Subcollections
      // (Dokumente, Zeitkonto, Abwesenheiten …) und die nach TID
      // geschlüsselten Academy-Nachweise mit, setzt `tidPending` korrekt
      // auf `false` und zieht das Fahrer-Login (users-Doc + Auth-Claims)
      // über `syncDriverLoginTransporterId` nach — sonst vergleichen die
      // Firestore-Rules weiter die alte ID und Fahrer-Schreibzugriffe
      // (z. B. Vorschussantrag) scheitern mit permission-denied.
      var loginSyncWarning = false;
      if (newTid.isNotEmpty && driverDoc.id.toUpperCase() != newTid) {
        final moved = await migrateDriverToTid(
          dspUid: _uid!,
          fromDocId: driverDoc.id,
          toTid: newTid,
        );
        loginSyncWarning = moved.hasLoginSyncWarning;
      } else if (newTid.isEmpty) {
        // Admin hat die TID geleert — die Doc-ID bleibt, nur das Feld
        // wird geblankt.
        await driverDoc.reference.set({
          'transporterId': '',
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        // Doc-ID heißt bereits wie die neue TID — nur die Felder
        // geraderücken.
        await driverDoc.reference.set({
          'transporterId': newTid,
          'tidPending': false,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      // Neue ID + neuer Vertragsbeginn = neue Beschaeftigung: die alte ID
      // wandert als abgeschlossener Zeitraum in die Historie (damit
      // inaktiv), die neue laeuft ab dem gewaehlten Datum. Der Admin
      // entscheidet, ob es ein Wiedereintritt ist — geraten wird nichts.
      if (newTid.isNotEmpty && oldTid.isNotEmpty) {
        await _offerRehirePeriodAfterTidChange(
          driverRef: driversCol.doc(newTid),
          oldTid: oldTid,
          newTid: newTid,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor:
              loginSyncWarning ? const Color(0xFFB45309) : null,
          content: Text(
            newTid.isEmpty
                ? (de
                    ? 'Transporter ID entfernt.'
                    : 'Transporter ID removed.')
                : loginSyncWarning
                    ? (de
                        ? 'Transporter ID auf "$newTid" geändert — Login-'
                            'Sync fehlgeschlagen, Fahrer-Login zeigt evtl. '
                            'noch auf die alte ID.'
                        : 'Transporter ID changed to "$newTid" — login '
                            'sync failed, the driver login may still '
                            'point to the old ID.')
                    : (de
                        ? 'Transporter ID auf "$newTid" geändert.'
                        : 'Transporter ID changed to "$newTid".'),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFB42318),
          content: Text(
            de ? 'Konnte TID nicht ändern: $e' : 'Could not change TID: $e',
          ),
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
                        child: Text(
                          Localizations.localeOf(context).languageCode == 'de'
                              ? 'Aufenthaltstitel (Vorderseite)'
                              : 'Residence permit (front)',
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'resident_permit_back',
                        child: Text(
                          Localizations.localeOf(context).languageCode == 'de'
                              ? 'Aufenthaltstitel (Rückseite)'
                              : 'Residence permit (back)',
                        ),
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

  /// Settings gear shown in the detail page's top AppBar — hosts every
  /// hero-level action (notification PIN, login/password).
  Widget _driverSettingsMenu(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    final tid = (data['transporterId'] ?? '').toString();
    final canManageLogins = _uid != null && tid.isNotEmpty;

    Widget menuIcon(IconData icon, Color bg, Color fg) => Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: fg),
        );

    return PopupMenuButton<String>(
      tooltip: _trText('Einstellungen', 'Settings'),
      position: PopupMenuPosition.under,
      offset: const Offset(0, 8),
      icon: const Icon(Symbols.settings, size: 23, color: Color(0xFF5B6572)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      color: Colors.white,
      elevation: 8,
      onSelected: (value) async {
        switch (value) {
          case 'password':
            if (!canManageLogins) return;
            await _onCreateOrResetLogin(doc);
            break;
          case 'email':
            if (_uid == null) return;
            await _onChangeDriverEmail(doc);
            break;
          case 'legacy':
            await _openLegacyDriverDetails(doc);
            break;
        }
      },
      itemBuilder: (_) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'password',
          enabled: canManageLogins,
          height: 44,
          child: Row(
            children: [
              menuIcon(Icons.key_outlined, const Color(0xFFEFF6FF),
                  const Color(0xFF1D4ED8)),
              const SizedBox(width: 12),
              const Text(
                'Passwort verwalten',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'email',
          enabled: _uid != null,
          height: 44,
          child: Row(
            children: [
              menuIcon(Icons.alternate_email_rounded,
                  const Color(0xFFECFDF5), const Color(0xFF047857)),
              const SizedBox(width: 12),
              Text(
                _trText('E-Mail ändern', 'Change email'),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
        // Zugang zur klassischen Ansicht: Dokumenten-Upload/-Vorschau,
        // Beschäftigungszeiträume und die Exporte leben weiter dort — das
        // 2a-Design zeigt Dokumente bewusst nur als Status.
        PopupMenuItem<String>(
          value: 'legacy',
          height: 44,
          child: Row(
            children: [
              menuIcon(Icons.folder_open_rounded, const Color(0xFFF1F5F9),
                  const Color(0xFF475569)),
              const SizedBox(width: 12),
              Text(
                _trText('Dokumente & Export', 'Documents & export'),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _trText(String de, String en) =>
      Localizations.localeOf(context).languageCode == 'de' ? de : en;

  /// Ticket: change a driver's (login) email in place. Calls the
  /// `updateDriverEmail` Cloud Function so the existing Auth user keeps
  /// its uid/claims instead of getting a duplicate account.
  Future<void> _onChangeDriverEmail(
    DocumentSnapshot<Map<String, dynamic>> driverDoc,
  ) async {
    final data = driverDoc.data() ?? const <String, dynamic>{};
    final currentEmail =
        (data['loginEmail'] ?? data['email'] ?? '').toString().trim();
    final hasLogin = data['hasLogin'] == true ||
        (data['authUid'] ?? '').toString().trim().isNotEmpty;
    final emailCtrl = TextEditingController(text: currentEmail);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          _trText('E-Mail ändern', 'Change email'),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hasLogin
                    ? _trText(
                        'Die Login-E-Mail dieses Fahrers wird geändert. '
                            'Der Fahrer meldet sich danach mit der neuen '
                            'E-Mail an (Passwort bleibt gleich).',
                        'This changes the driver\'s login email. The '
                            'driver signs in with the new email afterwards '
                            '(password stays the same).')
                    : _trText(
                        'Dieser Fahrer hat noch keinen Login — die E-Mail '
                            'wird im Profil gespeichert.',
                        'This driver has no login yet — the email is '
                            'stored on the profile.'),
                style: const TextStyle(
                    fontSize: 12.5, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: emailCtrl,
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                decoration: _pillInputDecoration(
                    _trText('Neue E-Mail', 'New email')),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(_trText('Abbrechen', 'Cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF00B287)),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(_trText('Speichern', 'Save')),
          ),
        ],
      ),
    );
    if (ok != true) return;

    final newEmail = emailCtrl.text.trim().toLowerCase();
    if (newEmail.isEmpty || !newEmail.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(_trText('Bitte eine gültige E-Mail eingeben.',
                'Please enter a valid email.'))),
      );
      return;
    }
    if (newEmail == currentEmail.toLowerCase()) return;

    try {
      final callable =
          FirebaseFunctions.instance.httpsCallable('updateDriverEmail');
      await callable.call(<String, dynamic>{
        'driverDocId': driverDoc.id,
        'email': newEmail,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF067647),
          content: Text(_trText(
              'E-Mail geändert: $newEmail', 'Email changed: $newEmail')),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(_trText('E-Mail-Änderung fehlgeschlagen: $e',
                'Email change failed: $e'))),
      );
    }
  }

  /// Normalized driving-licence type: 'eu' or 'non_eu'. Legacy drivers
  /// without the field count as non-EU when a first-day date exists.
  String _normalizeLicenseType(dynamic raw, Map<String, dynamic> onboarding) {
    final v = (raw ?? '').toString().trim().toLowerCase();
    if (v == 'eu') return 'eu';
    if (v == 'non_eu' || v == 'noneu' || v == 'non-eu') return 'non_eu';
    final firstDay =
        (onboarding['firstDayInGermany'] ?? '').toString().trim();
    return firstDay.isNotEmpty ? 'non_eu' : 'eu';
  }

  /// Compact date row inside the hero expiry panel. Red when expired,
  /// orange when due within 30 days.
  Widget _heroDateRow(String label, DateTime? date, {VoidCallback? onTap}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    Color valueColor = const Color(0xFF111827);
    if (date != null) {
      final diff = date.difference(today).inDays;
      if (diff < 0) {
        valueColor = const Color(0xFFB91C1C);
      } else if (diff <= 30) {
        valueColor = const Color(0xFFEA580C);
      }
    }
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
            Text(
              date == null ? '—' : _formatDate(date),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: date == null ? const Color(0xFFCBD5E1) : valueColor,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 5),
              const Icon(Icons.edit_outlined,
                  size: 12, color: Color(0xFF9CA3AF)),
            ],
          ],
        ),
      ),
    );
  }

  /// Date picker writing `onboarding.<fieldKey>` (dd/MM/yyyy), plus any
  /// extra onboarding fields in the same write.
  Future<void> _pickHeroDate({
    required DocumentReference<Map<String, dynamic>> driverRef,
    required String fieldKey,
    String? current,
    Map<String, String> Function(DateTime picked)? extraFields,
  }) async {
    final initial = _parseIsoDate(current) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    final update = <String, dynamic>{fieldKey: _formatDate(picked)};
    if (extraFields != null) update.addAll(extraFields(picked));
    await driverRef.set({'onboarding': update}, SetOptions(merge: true));
  }

  /// Expiry row that also supports an explicit "no expiry date" state
  /// (stored via a companion `<field>NoExpiry` bool). Shows the date, or
  /// "Kein Ablaufdatum", or "—".
  Widget _heroExpiryRow(
    String label,
    DateTime? date,
    bool noExpiry, {
    VoidCallback? onTap,
    String? noExpiryText,
  }) {
    if (!noExpiry) return _heroDateRow(label, date, onTap: onTap);
    final de = Localizations.localeOf(context).languageCode == 'de';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
            Text(
              noExpiryText ?? (de ? 'Kein Ablaufdatum' : 'No expiry date'),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF059669),
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 5),
              const Icon(Icons.edit_outlined,
                  size: 12, color: Color(0xFF9CA3AF)),
            ],
          ],
        ),
      ),
    );
  }

  /// Lets the admin pick an expiry date OR mark the document as having no
  /// expiry date. Writes `onboarding.<dateKey>` + `onboarding.<noExpiryKey>`.
  Future<void> _editExpiryOrNone({
    required DocumentReference<Map<String, dynamic>> driverRef,
    required String dateKey,
    required String noExpiryKey,
    String? currentDate,
    Map<String, dynamic> Function(DateTime picked)? extraFields,
    String? dialogTitle,
    String? pickDateLabel,
    String? noneLabel,
  }) async {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(dialogTitle ?? (de ? 'Ablaufdatum' : 'Expiry date'),
            style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, 'date'),
            child: Row(children: [
              const Icon(Icons.event_rounded,
                  size: 18, color: Color(0xFF374151)),
              const SizedBox(width: 10),
              Text(
                  pickDateLabel ??
                      (de ? 'Ablaufdatum wählen' : 'Pick expiry date'),
                  style: const TextStyle(fontSize: 14)),
            ]),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, 'none'),
            child: Row(children: [
              const Icon(Icons.all_inclusive_rounded,
                  size: 18, color: Color(0xFF059669)),
              const SizedBox(width: 10),
              Text(noneLabel ?? (de ? 'Kein Ablaufdatum' : 'No expiry date'),
                  style: const TextStyle(fontSize: 14)),
            ]),
          ),
        ],
      ),
    );
    if (choice == null) return;
    if (choice == 'none') {
      await driverRef.set({
        'onboarding': {dateKey: '', noExpiryKey: true},
      }, SetOptions(merge: true));
      return;
    }
    final initial = _parseIsoDate(currentDate) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    final update = <String, dynamic>{
      dateKey: _formatDate(picked),
      noExpiryKey: false,
    };
    if (extraFields != null) update.addAll(extraFields(picked));
    await driverRef.set({'onboarding': update}, SetOptions(merge: true));
  }

  /// Personalnummer / Employee-ID editor — writes the top-level
  /// `employeeNumber` field. Führende Nullen werden entfernt, damit die
  /// Nummer zum Zeiterfassungs-Export passt ("00023" → "23").
  Future<void> _editEmployeeNumber({
    required DocumentReference<Map<String, dynamic>> driverRef,
    required String current,
  }) async {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final ctrl = TextEditingController(text: current);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          de ? 'Personalnummer / Employee ID' : 'Employee ID',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        content: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                de
                    ? 'Employee ID aus dem Zeiterfassungsprogramm — wird '
                        'beim Stunden-Import zum Zuordnen der Fahrer '
                        'genutzt.'
                    : 'Employee ID from the time-tracking tool — used to '
                        'match drivers during the hours import.',
                style: const TextStyle(
                    fontSize: 12.5, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                autofocus: true,
                decoration: _pillInputDecoration(
                    de ? 'z. B. 23' : 'e.g. 23'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(de ? 'Abbrechen' : 'Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF00B287)),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(de ? 'Speichern' : 'Save'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    // "00023" → "23"; komplett leeres Feld löscht die Nummer.
    final cleaned =
        ctrl.text.trim().replaceFirst(RegExp(r'^0+(?=\d)'), '');
    await driverRef.set({
      'employeeNumber':
          cleaned.isEmpty ? FieldValue.delete() : cleaned,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Stations-Editor — schreibt das Top-Level-Feld `station`
  /// (Großbuchstaben, max. 10 Zeichen) auf dem Fahrerdokument.
  /// Vorbereitung für die Stations-Trennung der Scorecard.
  ///
  /// Zeigt als Vorschläge alle Stationen, die bei anderen Fahrern des DSP
  /// bereits gesetzt sind (einmaliger Read der drivers-Collection),
  /// plus ein Freitextfeld. Leeres Feld = Station entfernen.
  Future<void> _editDriverStation({
    required DocumentReference<Map<String, dynamic>> driverRef,
    required String current,
  }) async {
    final de = Localizations.localeOf(context).languageCode == 'de';

    // Distinct-Stationswerte aller Fahrer des DSP als Vorschlags-Chips.
    final existing = <String>{};
    try {
      final snap = await driverRef.parent.get();
      for (final doc in snap.docs) {
        final s = (doc.data()['station'] ?? '').toString().trim();
        if (s.isNotEmpty) existing.add(s.toUpperCase());
      }
    } catch (_) {
      // Vorschläge sind optional — Freitext funktioniert trotzdem.
    }
    if (!mounted) return;
    final suggestions = existing.toList()..sort();

    final ctrl = TextEditingController(text: current);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          de ? 'Station zuweisen' : 'Assign station',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        content: SizedBox(
          width: 320,
          child: StatefulBuilder(
            builder: (ctx2, setStateDialog) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  de
                      ? 'Station des Fahrers (z. B. DBY5) — Grundlage für '
                          'die Stations-Trennung der Scorecard. Leer '
                          'lassen, um die Station zu entfernen.'
                      : 'The driver\'s station (e.g. DBY5) — used to '
                          'split the scorecard by station. Leave empty '
                          'to remove the station.',
                  style: const TextStyle(
                      fontSize: 12.5, color: Color(0xFF6B7280)),
                ),
                if (suggestions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final s in suggestions)
                        InkWell(
                          onTap: () => setStateDialog(() {
                            ctrl.text = s;
                            ctrl.selection = TextSelection.collapsed(
                                offset: s.length);
                          }),
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: ctrl.text.trim().toUpperCase() == s
                                  ? const Color(0xFFE6F7F2)
                                  : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: ctrl.text.trim().toUpperCase() == s
                                    ? const Color(0xFF00B287)
                                    : const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: Text(
                              s,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: ctrl.text.trim().toUpperCase() == s
                                    ? const Color(0xFF00B287)
                                    : const Color(0xFF374151),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  controller: ctrl,
                  autofocus: true,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(10),
                  ],
                  onChanged: (_) => setStateDialog(() {}),
                  onSubmitted: (_) => Navigator.pop(ctx, true),
                  decoration: _pillInputDecoration(
                      de ? 'z. B. DBY5' : 'e.g. DBY5'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(de ? 'Abbrechen' : 'Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF00B287)),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(de ? 'Speichern' : 'Save'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final cleaned = ctrl.text.trim().toUpperCase();
    final station =
        cleaned.length > 10 ? cleaned.substring(0, 10) : cleaned;
    await driverRef.set({
      'station': station.isEmpty ? FieldValue.delete() : station,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Contract-type picker — writes the top-level `contractType` field.
  Future<void> _adminEditContractType({
    required DocumentReference<Map<String, dynamic>> driverRef,
    required DriverContractType? current,
  }) async {
    final picked = await showDialog<DriverContractType>(
      context: context,
      builder: (ctx) => SimpleDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Vertragstyp',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        children: [
          for (final c in DriverContractType.values)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, c),
              child: Row(
                children: [
                  Icon(
                    current == c
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    size: 18,
                    color: current == c
                        ? const Color(0xFF00B287)
                        : const Color(0xFF9CA3AF),
                  ),
                  const SizedBox(width: 10),
                  Text(c.label, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
        ],
      ),
    );
    if (picked == null || picked == current) return;
    await driverRef.set(
      {'contractType': picked.value},
      SetOptions(merge: true),
    );
  }

  Future<void> _adminEditLicenseType({
    required DocumentReference<Map<String, dynamic>> driverRef,
    required String current,
  }) async {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final picked = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          de ? 'Führerschein-Typ' : 'Driving licence type',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        children: [
          for (final opt in [
            ('eu', de ? 'EU-Führerschein' : 'EU licence'),
            ('non_eu', de ? 'Nicht-EU-Führerschein' : 'Non-EU licence'),
          ])
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, opt.$1),
              child: Row(
                children: [
                  Icon(
                    current == opt.$1
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    size: 18,
                    color: current == opt.$1
                        ? const Color(0xFF00B287)
                        : const Color(0xFF9CA3AF),
                  ),
                  const SizedBox(width: 10),
                  Text(opt.$2, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
        ],
      ),
    );
    if (picked == null || picked == current) return;
    await driverRef.set({
      'onboarding': {'licenseType': picked},
    }, SetOptions(merge: true));
  }

  /// Fixed-term vs. unlimited contract picker. Choosing "unlimited"
  /// clears the stored end date (no expiry alerts fire).
  Future<void> _adminEditContractEndMode({
    required DocumentReference<Map<String, dynamic>> driverRef,
    required bool unlimited,
  }) async {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final current = unlimited ? 'unlimited' : 'fixed';
    final picked = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          de ? 'Vertragsende' : 'Contract end',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        children: [
          for (final opt in [
            ('fixed', de ? 'Befristet (mit Datum)' : 'Fixed term (with date)'),
            ('unlimited', de ? 'Unbefristet' : 'Unlimited'),
          ])
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, opt.$1),
              child: Row(
                children: [
                  Icon(
                    current == opt.$1
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    size: 18,
                    color: current == opt.$1
                        ? const Color(0xFF00B287)
                        : const Color(0xFF9CA3AF),
                  ),
                  const SizedBox(width: 10),
                  Text(opt.$2, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
        ],
      ),
    );
    if (picked == null || picked == current) return;
    if (picked == 'unlimited') {
      await driverRef.set({
        'onboarding': {
          'contractUnlimited': true,
          'contractExpiry': FieldValue.delete(),
        },
      }, SetOptions(merge: true));
    } else {
      await driverRef.set({
        'onboarding': {'contractUnlimited': false},
      }, SetOptions(merge: true));
    }
  }

  /// Hero panel with the most important expiry dates: work permit
  /// (EU vs. work visa → passport / visa / Zusatzblatt) and driving
  /// licence (EU vs. non-EU → first day in Germany + derived 6-month
  /// validity).
  Widget _heroExpiryPanel({
    required DocumentReference<Map<String, dynamic>> driverRef,
    required Map<String, dynamic> onboarding,
  }) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    String tr(String d, String e) => de ? d : e;
    final t = AppLocalizations.of(context);

    final permitType = _normalizeWorkPermitType(
      onboarding['workPermitType'],
      fallbackExpiry: onboarding['residencePermitExpiry'],
    );
    final isVisa = permitType == 'working_visa';
    final licenseType =
        _normalizeLicenseType(onboarding['licenseType'], onboarding);
    final isNonEu = licenseType == 'non_eu';
    final firstDay =
        _parseIsoDate(onboarding['firstDayInGermany']?.toString());
    final licenseUntil =
        firstDay == null ? null : _addMonthsClamped(firstDay, 6);

    final driverLang = (onboarding['language'] ?? '').toString().trim();

    Widget sectionHeader(String label, String chipText, VoidCallback onTap) {
      return Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: Color(0xFF94A3B8),
              ),
            ),
          ),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    chipText,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      size: 14, color: Color(0xFF94A3B8)),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          sectionHeader(
            tr('FAHRERSPRACHE', 'DRIVER LANGUAGE'),
            driverLang.isEmpty
                ? tr('Wählen', 'Choose')
                : languageLabel(driverLang),
            () => _adminEditDriverLanguage(
              driverRef: driverRef,
              initialValue: onboarding['language'],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: Color(0xFFE5E7EB)),
          ),
          sectionHeader(
            'WORK PERMIT',
            isVisa
                ? t.t('drivers_hub_work_permit_working_visa')
                : t.t('drivers_hub_work_permit_eu'),
            () => _adminEditWorkPermitType(
              driverRef: driverRef,
              initialValue: onboarding['workPermitType'],
              fallbackExpiry: onboarding['residencePermitExpiry'],
            ),
          ),
          if (isVisa) ...[
            const SizedBox(height: 6),
            _heroDateRow(
              tr('Passport Expiry', 'Passport expiry'),
              _parseIsoDate(onboarding['idDocExpiry']?.toString()),
              onTap: () => _pickHeroDate(
                driverRef: driverRef,
                fieldKey: 'idDocExpiry',
                current: onboarding['idDocExpiry']?.toString(),
              ),
            ),
            _heroDateRow(
              tr('Visa Expiry', 'Visa expiry'),
              _parseIsoDate((onboarding['workVisaExpiry'] ??
                      onboarding['residencePermitExpiry'])
                  ?.toString()),
              onTap: () => _pickHeroDate(
                driverRef: driverRef,
                fieldKey: 'workVisaExpiry',
                current: (onboarding['workVisaExpiry'] ??
                        onboarding['residencePermitExpiry'])
                    ?.toString(),
              ),
            ),
            _heroExpiryRow(
              tr('Zusatzblatt Expiry', 'Zusatzblatt expiry'),
              _parseIsoDate(onboarding['zusatzblattExpiry']?.toString()),
              onboarding['zusatzblattNoExpiry'] == true,
              onTap: () => _editExpiryOrNone(
                driverRef: driverRef,
                dateKey: 'zusatzblattExpiry',
                noExpiryKey: 'zusatzblattNoExpiry',
                currentDate: onboarding['zusatzblattExpiry']?.toString(),
              ),
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: Color(0xFFE5E7EB)),
          ),
          sectionHeader(
            tr('FÜHRERSCHEIN', 'DRIVING LICENCE'),
            isNonEu ? tr('Nicht-EU', 'Non-EU') : 'EU',
            () => _adminEditLicenseType(
              driverRef: driverRef,
              current: licenseType,
            ),
          ),
          if (isNonEu) ...[
            const SizedBox(height: 6),
            _heroDateRow(
              tr('1. Tag in Deutschland', 'First day in Germany'),
              firstDay,
              onTap: () => _pickHeroDate(
                driverRef: driverRef,
                fieldKey: 'firstDayInGermany',
                current: onboarding['firstDayInGermany']?.toString(),
                // Non-EU licences are only valid for 6 months from the
                // first day in Germany — persist the derived expiry so
                // the notification center picks it up.
                extraFields: (picked) => {
                  'licenseExpiry':
                      _formatDate(_addMonthsClamped(picked, 6)),
                },
              ),
            ),
            _heroDateRow(
              tr('Führerschein gültig bis (6 Mon.)',
                  'Licence valid until (6 mo)'),
              licenseUntil,
            ),
          ] else ...[
            // EU licence: still ask for an expiry date, with a "no expiry"
            // option (some EU licences are open-ended).
            const SizedBox(height: 6),
            _heroExpiryRow(
              tr('Führerschein gültig bis', 'Licence valid until'),
              _parseIsoDate(onboarding['licenseExpiry']?.toString()),
              onboarding['licenseNoExpiry'] == true,
              onTap: () => _editExpiryOrNone(
                driverRef: driverRef,
                dateKey: 'licenseExpiry',
                noExpiryKey: 'licenseNoExpiry',
                currentDate: onboarding['licenseExpiry']?.toString(),
              ),
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: Color(0xFFE5E7EB)),
          ),
          Builder(builder: (context) {
            final contractUnlimited =
                onboarding['contractUnlimited'] == true;
            final contractEnd =
                _parseIsoDate(onboarding['contractExpiry']?.toString());
            final contractStart =
                _parseIsoDate(onboarding['workStartDate']?.toString());
            // Probation ends automatically 6 months after the contract start.
            final probationEnd = contractStart == null
                ? null
                : _addMonthsClamped(contractStart, 6);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                sectionHeader(
                  tr('VERTRAG', 'CONTRACT'),
                  contractUnlimited
                      ? tr('Unbefristet', 'Unlimited')
                      : tr('Befristet', 'Fixed term'),
                  () => _adminEditContractEndMode(
                    driverRef: driverRef,
                    unlimited: contractUnlimited,
                  ),
                ),
                const SizedBox(height: 6),
                _heroDateRow(
                  tr('Vertragsbeginn', 'Contract start'),
                  contractStart,
                  onTap: () => _pickHeroDate(
                    driverRef: driverRef,
                    fieldKey: 'workStartDate',
                    current: onboarding['workStartDate']?.toString(),
                  ),
                ),
                _heroDateRow(
                  tr('Probezeit-Ende (6 Mon.)', 'Probation ends (6 mo)'),
                  probationEnd,
                ),
                _heroExpiryRow(
                  tr('Vertragsende', 'Contract end'),
                  contractEnd,
                  contractUnlimited,
                  noExpiryText: tr('Unbefristet', 'Unlimited'),
                  onTap: () => _editExpiryOrNone(
                    driverRef: driverRef,
                    dateKey: 'contractExpiry',
                    noExpiryKey: 'contractUnlimited',
                    currentDate: onboarding['contractExpiry']?.toString(),
                    dialogTitle: tr('Vertragsende', 'Contract end'),
                    pickDateLabel:
                        tr('Vertragsende wählen', 'Pick contract end date'),
                    noneLabel: tr('Unbefristet', 'Unlimited'),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Employment periods (rehires): several contract spans + Transporter-IDs
  // ---------------------------------------------------------------------------

  /// Persists [periods] and mirrors the current one back into the legacy
  /// single-value fields (`transporterId`, `onboarding.workStartDate`,
  /// `onboarding.contractExpiry`, `onboarding.contractUnlimited`) so every
  /// existing report, filter and the wave-plan matching keeps working.
  Future<bool> _saveEmploymentPeriods({
    required DocumentReference<Map<String, dynamic>> driverRef,
    required List<EmploymentPeriod> periods,
    required String previousTid,
  }) async {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final update = employmentPeriodsMirror(periods);
    final nextTid = (update['transporterId'] ?? '').toString().trim();
    final oldTid = previousTid.trim().toUpperCase();

    // A TID must stay unique across the DSP — same guard the dedicated
    // Transporter-ID editor uses. We only patch the field here (never move
    // the document), which is the supported "auto-id doc" state.
    if (nextTid.isNotEmpty && nextTid != oldTid) {
      try {
        final existing = await driverRef.parent.doc(nextTid).get();
        if (existing.exists && existing.id != driverRef.id) {
          if (!mounted) return false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFFB42318),
              content: Text(
                de
                    ? 'Ein anderer Fahrer benutzt die TID "$nextTid" bereits.'
                    : 'Another driver already uses the TID "$nextTid".',
              ),
            ),
          );
          return false;
        }
      } catch (_) {
        // Read failure must not block the period edit — skip the guard.
      }
    }

    try {
      await driverRef.set({
        ...update,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFB42318),
          content: Text(
            de
                ? 'Beschäftigungszeitraum konnte nicht gespeichert werden: $e'
                : 'Could not save employment period: $e',
          ),
        ),
      );
      return false;
    }
  }

  /// Add / edit sheet for one employment period.
  Future<EmploymentPeriod?> _editEmploymentPeriodDialog({
    EmploymentPeriod? initial,
    required String fallbackTid,
  }) async {
    final de = Localizations.localeOf(context).languageCode == 'de';
    String tr(String d, String e) => de ? d : e;

    DateTime? start = initial?.startDate;
    DateTime? end = initial?.endDate;
    var ongoing = initial == null ? true : initial.isOngoing;
    final tidCtrl = TextEditingController(
      text: (initial?.transporterId.isNotEmpty ?? false)
          ? initial!.transporterId
          : fallbackTid,
    );

    final result = await showDialog<EmploymentPeriod>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            Widget dateField({
              required String label,
              required DateTime? value,
              required bool enabled,
              required ValueChanged<DateTime> onPicked,
            }) {
              return Opacity(
                opacity: enabled ? 1 : 0.45,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: !enabled
                      ? null
                      : () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: value ?? DateTime.now(),
                            firstDate: DateTime(1990),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) onPicked(picked);
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 11),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.event_rounded,
                            size: 16, color: Color(0xFF6B7280)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            label,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                        Text(
                          value == null ? '—' : _formatDate(value),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: value == null
                                ? const Color(0xFFCBD5E1)
                                : const Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              title: Text(
                initial == null
                    ? tr('Beschäftigungszeitraum hinzufügen',
                        'Add employment period')
                    : tr('Beschäftigungszeitraum bearbeiten',
                        'Edit employment period'),
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w800),
              ),
              content: SizedBox(
                width: 380,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    dateField(
                      label: tr('Vertragsbeginn', 'Contract start'),
                      value: start,
                      enabled: true,
                      onPicked: (d) => setSheet(() => start = d),
                    ),
                    const SizedBox(height: 10),
                    dateField(
                      label: tr('Vertragsende', 'Contract end'),
                      value: ongoing ? null : end,
                      enabled: !ongoing,
                      onPicked: (d) => setSheet(() => end = d),
                    ),
                    const SizedBox(height: 2),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      value: ongoing,
                      onChanged: (v) => setSheet(() => ongoing = v),
                      title: Text(
                        tr('Laufende Beschäftigung (kein Enddatum)',
                            'Ongoing employment (no end date)'),
                        style: const TextStyle(
                            fontSize: 12.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: tidCtrl,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[A-Za-z0-9-]')),
                        LengthLimitingTextInputFormatter(32),
                      ],
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        labelText: 'Transporter ID',
                        helperText: tr(
                          'Bei Wiedereinstellung kann die TID abweichen.',
                          'After a rehire the TID may differ.',
                        ),
                        helperMaxLines: 2,
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(tr('Abbrechen', 'Cancel')),
                ),
                FilledButton(
                  onPressed: () {
                    final s = start;
                    if (s == null) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFFB42318),
                          content: Text(tr('Bitte Vertragsbeginn wählen.',
                              'Please pick a contract start date.')),
                        ),
                      );
                      return;
                    }
                    final e = ongoing ? null : end;
                    if (e != null && e.isBefore(s)) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFFB42318),
                          content: Text(tr(
                              'Das Vertragsende liegt vor dem Beginn.',
                              'The contract end is before the start.')),
                        ),
                      );
                      return;
                    }
                    Navigator.of(ctx).pop(EmploymentPeriod(
                      start: formatIsoDate(s),
                      end: e == null ? '' : formatIsoDate(e),
                      transporterId: tidCtrl.text.trim().toUpperCase(),
                    ));
                  },
                  child: Text(tr('Speichern', 'Save')),
                ),
              ],
            );
          },
        );
      },
    );
    tidCtrl.dispose();
    return result;
  }

  /// Section listing every employment period of a driver. Stays a single
  /// slim row for the common case (one uninterrupted contract).
  Widget _employmentPeriodsKachel({
    required DocumentReference<Map<String, dynamic>> driverRef,
    required Map<String, dynamic> data,
  }) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    String tr(String d, String e) => de ? d : e;

    final periods = employmentPeriodsOf(data);
    final current = currentEmploymentPeriod(periods);
    final currentTid = (data['transporterId'] ?? '').toString().trim();

    Future<void> replaceAll(List<EmploymentPeriod> next) async {
      await _saveEmploymentPeriods(
        driverRef: driverRef,
        periods: next,
        previousTid: currentTid,
      );
    }

    Future<void> addPeriod() async {
      final created = await _editEmploymentPeriodDialog(
        fallbackTid: currentTid,
      );
      if (created == null) return;
      // A rehire implies the previous stint is over — but we never guess a
      // date for it, the admin closes it explicitly.
      await replaceAll([...periods, created]);
    }

    Future<void> editPeriod(int index) async {
      final edited = await _editEmploymentPeriodDialog(
        initial: periods[index],
        fallbackTid: currentTid,
      );
      if (edited == null) return;
      final next = [...periods];
      next[index] = edited;
      await replaceAll(next);
    }

    Future<void> deletePeriod(int index) async {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(
            tr('Zeitraum löschen?', 'Delete period?'),
            style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          content: Text(
            tr('Der Beschäftigungszeitraum wird aus dem Fahrer entfernt.',
                'The employment period will be removed from this driver.'),
            style: const TextStyle(fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(tr('Abbrechen', 'Cancel')),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFB42318)),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(tr('Löschen', 'Delete')),
            ),
          ],
        ),
      );
      if (ok != true) return;
      final next = [...periods]..removeAt(index);
      await replaceAll(next);
    }

    Widget periodRow(int index) {
      final p = periods[index];
      final s = p.startDate;
      final e = p.endDate;
      final isCurrent = current != null &&
          current.start == p.start &&
          current.end == p.end &&
          current.transporterId == p.transporterId;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.only(right: 9),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: p.isOngoing
                    ? const Color(0xFF16A34A)
                    : const Color(0xFFCBD5E1),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          s == null ? '—' : _formatDate(s),
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: Text('–',
                            style: TextStyle(
                                fontSize: 12.5, color: Color(0xFF9CA3AF))),
                      ),
                      if (p.isOngoing)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.play_circle_fill_rounded,
                                size: 13, color: Color(0xFF16A34A)),
                            const SizedBox(width: 4),
                            Text(
                              tr('aktiv', 'active'),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF16A34A),
                              ),
                            ),
                          ],
                        )
                      else
                        Flexible(
                          child: Text(
                            e == null ? '—' : _formatDate(e),
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (p.transporterId.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'TID ${p.transporterId}'
                        '${isCurrent && periods.length > 1 ? ' · ${tr('aktuell', 'current')}' : ''}',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              tooltip: tr('Bearbeiten', 'Edit'),
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints.tightFor(width: 32, height: 32),
              padding: EdgeInsets.zero,
              onPressed: () => editPeriod(index),
              icon: const Icon(Icons.edit_outlined,
                  size: 15, color: Color(0xFF6B7280)),
            ),
            IconButton(
              tooltip: tr('Löschen', 'Delete'),
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints.tightFor(width: 32, height: 32),
              padding: EdgeInsets.zero,
              onPressed: () => deletePeriod(index),
              icon: const Icon(Icons.delete_outline_rounded,
                  size: 15, color: Color(0xFFB91C1C)),
            ),
          ],
        ),
      );
    }

    return _DetailKachel(
      title: tr('BESCHÄFTIGUNGSZEITRÄUME', 'EMPLOYMENT PERIODS'),
      icon: Icons.work_history_rounded,
      children: [
        if (periods.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              tr('Noch kein Beschäftigungszeitraum hinterlegt.',
                  'No employment period recorded yet.'),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9CA3AF),
              ),
            ),
          )
        else
          for (var i = 0; i < periods.length; i++) periodRow(i),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: addPeriod,
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: const Color(0xFF0E5C45),
              ),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: Text(
                periods.isEmpty
                    ? tr('Zeitraum hinzufügen', 'Add period')
                    : tr('Wiedereinstellung hinzufügen', 'Add rehire'),
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Driver details dialog: responsive layout (no stats / weekly scores)
  // ---------------------------------------------------------------------------

  /// Fahrer-Detailseite im Kunden-Design „2a"
  /// (siehe `driver_hub_detail_page.dart`).
  ///
  /// Die Seite ist reine Darstellung — jedes Stift-Icon ruft über
  /// [DriverHubDetailActions] genau den Editor auf, der hier in dieser Datei
  /// schon existiert. Es wird **keine** Editor-Logik dupliziert.
  Future<void> _openDriverDetails(
    DocumentSnapshot<Map<String, dynamic>> driverDoc, {
    bool fromDeepLink = false,
  }) async {
    // Eingebettet statt als eigene Route — so bleibt das Seitenmenü der
    // Shell links sichtbar (gilt generell für alle Admin-Seiten).
    setState(() {
      _detailDriverDoc = driverDoc;
      _detailFromDeepLink = fromDeepLink;
    });
  }

  /// Aktions-Brücke der 2a-Detailseite auf die Bestandseditoren.
  DriverHubDetailActions _detailActionsFor(
    DocumentReference<Map<String, dynamic>> driverRef,
  ) {
    return DriverHubDetailActions(
          editOnboardingField: ({
            required String label,
            required String fieldKey,
            required String initialValue,
            bool isDate = false,
            bool isNumeric = false,
          }) =>
              _adminEditField(
            driverRef: driverRef,
            label: label,
            fieldKey: fieldKey,
            initialValue: initialValue,
            isDate: isDate,
            isNumeric: isNumeric,
          ),
          pickOnboardingDate: ({
            required String fieldKey,
            String? current,
            Map<String, String> Function(DateTime picked)? extraFields,
          }) =>
              _pickHeroDate(
            driverRef: driverRef,
            fieldKey: fieldKey,
            current: current,
            extraFields: extraFields,
          ),
          editExpiryOrNone: ({
            required String dateKey,
            required String noExpiryKey,
            String? currentDate,
            String? dialogTitle,
            String? pickDateLabel,
            String? noneLabel,
          }) =>
              _editExpiryOrNone(
            driverRef: driverRef,
            dateKey: dateKey,
            noExpiryKey: noExpiryKey,
            currentDate: currentDate,
            dialogTitle: dialogTitle,
            pickDateLabel: pickDateLabel,
            noneLabel: noneLabel,
          ),
          editDriverName: (initialValue) => _adminEditDriverName(
            driverRef: driverRef,
            initialValue: initialValue,
          ),
          editWorkPermitType: (initialValue, fallbackExpiry) =>
              _adminEditWorkPermitType(
            driverRef: driverRef,
            initialValue: initialValue,
            fallbackExpiry: fallbackExpiry,
          ),
          editDriverLanguage: (initialValue) => _adminEditDriverLanguage(
            driverRef: driverRef,
            initialValue: initialValue,
          ),
          editRemainingVacation: ({
            required String label,
            required double? currentOverride,
            required double? computed,
          }) =>
              _editRemainingVacationOverride(
            driverRef: driverRef,
            label: label,
            currentOverride: currentOverride,
            computed: computed,
          ),
          editEmployeeNumber: (current) => _editEmployeeNumber(
            driverRef: driverRef,
            current: current,
          ),
          editStation: (current) => _editDriverStation(
            driverRef: driverRef,
            current: current,
          ),
          editLicenseType: (current) => _adminEditLicenseType(
            driverRef: driverRef,
            current: current,
          ),
          editTransporterId: _editTransporterId,
          toggleActive: _onToggleActiveDriver,
          editRemark: _editDriverRemark,
          settingsMenuBuilder: _driverSettingsMenu,
          profileImage: _profileImageFromOnboarding,
          workPermitTypeLabel: (raw, fallbackExpiry) => _workPermitTypeLabel(
            AppLocalizations.of(context),
            raw,
            fallbackExpiry: fallbackExpiry,
          ),
          languageLabelOf: languageLabel,
    );
  }

  /// Klassische Detailansicht (alle Felder, Dokumenten-Upload/-Vorschau,
  /// Beschäftigungszeiträume, ZIP-/PDF-Export). Erreichbar über das
  /// Zahnrad-Menü der neuen Detailseite — das 2a-Design zeigt bewusst nur
  /// den Dokumenten-**Status**, ohne Upload/Download.
  Future<void> _openLegacyDriverDetails(
    DocumentSnapshot<Map<String, dynamic>> driverDoc,
  ) async {
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (ctx) {
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
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: StreamBuilder<
                        DocumentSnapshot<Map<String, dynamic>>>(
                      stream: driverDoc.reference.snapshots(),
                      builder: (c, s) {
                        final d = s.data;
                        if (d == null) return const SizedBox.shrink();
                        return _driverSettingsMenu(d);
                      },
                    ),
                  ),
                ],
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
                                              tooltip: _trText(
                                                  'TID bearbeiten', 'Edit TID'),
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
                                    ],
                                  );

                                  // Status chips side by side, full width
                                  // below the identity block.
                                  final chipsRow = Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      _statusChipFromData(data, ctx2),
                                      _loginChipFromData(data, ctx2),
                                      _expiryChipDetailedFromOnboardingRaw(
                                        onboarding,
                                        ctx2,
                                      ),
                                      // Fahrzeug-Unfälle dieses Fahrers —
                                      // dieselbe count()-Aggregation wie im
                                      // Incident-Center, damit beide Stellen
                                      // nie auseinanderlaufen.
                                      IncidentCountChip.driver(
                                        dspUid: _uid,
                                        transporterId: tid,
                                        dense: true,
                                      ),
                                    ],
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


                                  // Employment block (Personalnummer +
                                  // Vertragstyp + Score-Accordion-Handle).
                                  final employmentCard = _EmploymentInfoCard(
                                    employeeNumber: employeeNumber,
                                    contractType: contractType,
                                    scoreSection: scoreSection,
                                    onEditContractType: () =>
                                        _adminEditContractType(
                                      driverRef: driverRef,
                                      current: contractType,
                                    ),
                                    onEditNumber: () =>
                                        _editEmployeeNumber(
                                      driverRef: driverRef,
                                      current: employeeNumber,
                                    ),
                                  );

                                  // Key expiry dates (work permit +
                                  // driving licence) right in the hero.
                                  final expiryPanel = _heroExpiryPanel(
                                    driverRef: driverRef,
                                    onboarding: onboarding,
                                  );

                                  final heroDecoration = BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.black.withOpacity(0.03),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  );

                                  // Profile card: identity → chips →
                                  // employment, separated by subtle lines.
                                  final profileCard = Container(
                                    padding: const EdgeInsets.fromLTRB(
                                        18, 16, 18, 16),
                                    decoration: heroDecoration,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            avatar,
                                            const SizedBox(width: 16),
                                            Expanded(child: identityCol),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        const Divider(
                                            height: 1,
                                            color: Color(0xFFEDF0F3)),
                                        const SizedBox(height: 10),
                                        chipsRow,
                                        const SizedBox(height: 10),
                                        const Divider(
                                            height: 1,
                                            color: Color(0xFFEDF0F3)),
                                        const SizedBox(height: 12),
                                        employmentCard,
                                      ],
                                    ),
                                  );

                                  // Data card: the key expiry dates.
                                  final dataCard = Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.fromLTRB(
                                        18, 16, 18, 16),
                                    decoration: heroDecoration,
                                    child: expiryPanel,
                                  );

                                  final hero = isNarrow
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            profileCard,
                                            const SizedBox(height: 12),
                                            dataCard,
                                          ],
                                        )
                                      : Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(child: profileCard),
                                            const SizedBox(width: 16),
                                            Expanded(child: dataCard),
                                          ],
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
                                        label: Localizations.localeOf(context)
                                                    .languageCode ==
                                                'de'
                                            ? 'Anzeigename'
                                            : 'Display name',
                                        value: data['driverName'],
                                        fieldKey: 'driverName',
                                        onEdit: () => _adminEditDriverName(
                                          driverRef: driverRef,
                                          initialValue:
                                              (data['driverName'] ?? '')
                                                  .toString(),
                                        ),
                                      ),
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
                                      // Ein-Topf-Modus: „Urlaub pro Jahr"
                                      // wie bisher. Im Topf-Modus wird
                                      // stattdessen je Topf eine eigene
                                      // Tageszahl gepflegt.
                                      if (!_vacationPoolsConfig.enabled)
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
                                      if (_vacationPoolsConfig.enabled)
                                        for (final pool
                                            in _vacationPoolsConfig
                                                .forDriver(onboarding)
                                                .pools)
                                          _detailRowEditable(
                                            driverRef: driverRef,
                                            label: vacationPoolLabel(
                                              context,
                                              pool.key,
                                            ),
                                            value: formatVacationDays(
                                              pool.days,
                                            ),
                                            fieldKey: VacationPoolsConfig
                                                .driverDaysFieldKey(pool.key),
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

                                  // Rehires: every contract span with the
                                  // Transporter-ID used back then.
                                  final employmentPeriodsKachel =
                                      _employmentPeriodsKachel(
                                    driverRef: driverRef,
                                    data: data,
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
                                        // Monatliche Bewertungen — vorerst
                                        // ausgeblendet, siehe
                                        // kDriverReviewsEnabled.
                                        if (kDriverReviewsEnabled)
                                          DriverReviewsCard(
                                            adminUid: _uid!,
                                            driverTransporterId: driverRef.id,
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
                                      employmentPeriodsKachel,
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
    final de = Localizations.localeOf(context).languageCode == 'de';
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
    final labels = de
        ? const {
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
          }
        : const {
            'contract': 'Employment contract',
            'resident_permit': 'Residence permit',
            'tax_id': 'Tax ID',
            'insurance': 'Health insurance',
            'id_card_front': 'ID card (front)',
            'id_card_back': 'ID card (back)',
            'passport_front': 'Passport (front)',
            'passport_back': 'Passport (back)',
            'driver_license_front': 'Driver\'s licence (front)',
            'driver_license_back': 'Driver\'s licence (back)',
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

  // ---------------------------------------------------------------------------
  // Mobile-Leiste: 48er-Icon-Buttons + Bottom-Sheets (gleiches Muster wie im
  // Fleet Hub, `fleet_status_page.dart`).
  // ---------------------------------------------------------------------------

  static const Color _kMobileGreen = Color(0xFF0D8A60);
  static const Color _kMobileGreenTint = Color(0xFFE7F6EF);
  static const Color _kMobileLine = Color(0xFFE5E9EE);
  static const Color _kMobileInk = Color(0xFF1A212B);
  static const Color _kMobileFaint = Color(0xFF8A93A0);

  /// Quadratischer 48er-Icon-Button der Mobile-Leiste. Aktive Zustände
  /// bekommen den Grünton plus einen Punkt-Badge.
  Widget _mobileIconButton({
    required IconData icon,
    required String tooltip,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 500),
      child: Material(
        color: active ? _kMobileGreenTint : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: active ? _kMobileGreen : _kMobileLine),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              children: [
                Center(child: Icon(icon, size: 21, color: _kMobileGreen)),
                if (active)
                  Positioned(
                    top: 9,
                    right: 9,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: _kMobileGreen,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Rahmen aller Mobile-Sheets: Griff, Titel, Inhalt.
  Future<T?> _showMobileSheet<T>({
    required String title,
    required Widget Function(BuildContext ctx) builder,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _kMobileLine,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _kMobileInk,
                    ),
                  ),
                ),
                Flexible(child: SingleChildScrollView(child: builder(ctx))),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Auswahlzeile eines Sheets — 48px hoch, Häkchen für die aktive Option.
  Widget _mobileSheetOption({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      minVerticalPadding: 12,
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.circle_outlined,
        size: 20,
        color: selected ? _kMobileGreen : _kMobileFaint,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          color: selected ? _kMobileGreen : _kMobileInk,
        ),
      ),
      onTap: onTap,
    );
  }

  Future<void> _showMobileSortSheet() async {
    await _showMobileSheet<void>(
      title: _trText('Sortieren nach', 'Sort by'),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final option in _DriverSort.values)
            _mobileSheetOption(
              label: _driverSortLabel(option),
              selected: _driverSort == option,
              onTap: () {
                setState(() => _driverSort = option);
                Navigator.of(ctx).pop();
              },
            ),
        ],
      ),
    );
  }

  /// Standard-Fahrer-Passwort im Sheet — anzeigen/verbergen, bearbeiten
  /// (derselbe Controller, also dieselbe Speicherung wie in der
  /// Desktop-Zeile) und kopieren.
  Future<void> _showMobilePasswordSheet() async {
    final t = AppLocalizations.of(context);
    await _showMobileSheet<void>(
      title: t.t('drivers_hub_default_driver_password'),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _trText(
                  'Wird für neu angelegte Fahrer-Logins verwendet.',
                  'Used for newly created driver logins.',
                ),
                style: const TextStyle(fontSize: 12.5, color: _kMobileFaint),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: TextField(
                  controller: _bulkPwdCtrl,
                  obscureText: !_bulkPwdVisible,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _kMobileInk,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline,
                        size: 19, color: _kMobileFaint),
                    hintText: '••••••••',
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _kMobileLine),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _kMobileLine),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: _kMobileGreen, width: 1.4),
                    ),
                    suffixIcon: IconButton(
                      iconSize: 20,
                      color: _kMobileFaint,
                      tooltip: _bulkPwdVisible
                          ? _trText('Verbergen', 'Hide')
                          : _trText('Anzeigen', 'Show'),
                      icon: Icon(_bulkPwdVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      onPressed: () {
                        _bulkPwdVisible = !_bulkPwdVisible;
                        setSheet(() {});
                        if (mounted) setState(() {});
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: _bulkPwdCtrl.text),
                    );
                    if (!ctx.mounted) return;
                    Navigator.of(ctx).pop();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _trText('Passwort kopiert', 'Password copied'),
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _kMobileGreen,
                    side: const BorderSide(color: _kMobileLine),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: Text(_trText('Kopieren', 'Copy')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDriversList() {
    final t = AppLocalizations.of(context);
    if (_uid == null) {
      return Center(child: Text(t.t('drivers_hub_must_login_view_drivers')));
    }

    final width = MediaQuery.of(context).size.width;
    final isNarrowControls = width < 720;

    final searchField = SizedBox(
      height: isNarrowControls ? 48 : 44,
      child: TextField(
        controller: _searchCtrl,
        focusNode: _searchFocus,
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
          suffixIcon: buildSearchClearButton(
            context: context,
            value: _search,
            focusNode: _searchFocus,
            onClear: () {
              _searchCtrl.clear();
              setState(() => _search = '');
            },
          ),
          suffixIconConstraints: kSearchClearConstraints,
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

    // Archive toggle — moves inactive drivers out of the main list.
    final archiveToggle = Material(
      color: _showArchive ? const Color(0xFF111827) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _showArchive = !_showArchive),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: const Color(0xFFE5E5EA), width: 0.6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _showArchive
                    ? Icons.arrow_back_rounded
                    : Icons.archive_outlined,
                size: 18,
                color: _showArchive
                    ? Colors.white
                    : const Color(0xFF6B7280),
              ),
              const SizedBox(width: 6),
              Text(
                _showArchive ? 'Aktive Fahrer' : 'Archiv',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _showArchive
                      ? Colors.white
                      : const Color(0xFF374151),
                ),
              ),
            ],
          ),
        ),
      ),
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
          // Mobile: eine Zeile — Suchfeld plus drei 48er-Icon-Buttons
          // (Sortierung · Standard-Passwort · Archiv). Die drei bisherigen
          // Vollbreite-Zeilen wandern in Bottom-Sheets, gleiches Muster wie
          // im Fleet Hub.
          Row(
            children: [
              Expanded(child: searchField),
              const SizedBox(width: 8),
              _mobileIconButton(
                icon: Icons.swap_vert,
                tooltip: _trText('Sortieren', 'Sort'),
                active: _driverSort != _DriverSort.nameAsc,
                onTap: _showMobileSortSheet,
              ),
              const SizedBox(width: 8),
              _mobileIconButton(
                icon: Icons.lock_outline,
                tooltip: _trText(
                  'Standard-Passwort',
                  'Default password',
                ),
                active: false,
                onTap: _showMobilePasswordSheet,
              ),
              const SizedBox(width: 8),
              _mobileIconButton(
                icon: _showArchive
                    ? Icons.arrow_back_rounded
                    : Icons.archive_outlined,
                tooltip: _showArchive
                    ? _trText('Aktive Fahrer', 'Active drivers')
                    : _trText('Archiv', 'Archive'),
                active: _showArchive,
                onTap: () => setState(() => _showArchive = !_showArchive),
              ),
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
                  const SizedBox(width: 12),
                  archiveToggle,
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

              // Archive: inactive drivers live in the archive view; the
              // main list shows only active drivers.
              if (_showArchive) {
                filtered = filtered.where((d) {
                  return ((d.data()['active'] as bool?) ?? true) == false;
                }).toList();
              } else {
                filtered = filtered.where((d) {
                  return ((d.data()['active'] as bool?) ?? true) != false;
                }).toList();
              }

              // Pending / Approved / Rejected filtern nach den echten
              // Feldern (active, hasLogin) — im Archiv nicht anwenden.
              if (!_showArchive && _driverSort == _DriverSort.pending) {
                // Noch kein Login angelegt → Einrichtung ausstehend.
                filtered = filtered.where((d) {
                  return (d.data()['hasLogin'] as bool?) != true;
                }).toList();
              } else if (!_showArchive &&
                  _driverSort == _DriverSort.approved) {
                // Aktiv mit Login (grüner Punkt).
                filtered = filtered.where((d) {
                  final data = d.data();
                  final active = (data['active'] as bool?) ?? true;
                  return active && data['hasLogin'] == true;
                }).toList();
              } else if (!_showArchive &&
                  _driverSort == _DriverSort.rejected) {
                // Deaktiviert/abgelehnt (roter Punkt).
                filtered = filtered.where((d) {
                  return ((d.data()['active'] as bool?) ?? true) == false;
                }).toList();
              } else if (!_showArchive &&
                  _driverSort == _DriverSort.tidPending) {
                // Nur Fahrer ohne zugewiesene Transporter-ID. Maßgeblich
                // ist die wirksame TID (`isDriverTidPending`), nicht das
                // gern hängenbleibende Feld `tidPending`.
                filtered = filtered
                    .where((d) => isDriverTidPending(d.data(), d.id))
                    .toList();
              } else if (!_showArchive &&
                  _driverSort == _DriverSort.employeeIdMissing) {
                // Nur Fahrer ohne Personalnummer / Employee ID
                // (Zeiterfassung).
                filtered = filtered.where((d) {
                  return (d.data()['employeeNumber'] ?? '')
                      .toString()
                      .trim()
                      .isEmpty;
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

                // Die vom Nutzer gewählte Sortierung ist maßgeblich
                // (keine erzwungene Vorsortierung mehr).
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
                  case _DriverSort.tidPending:
                  case _DriverSort.employeeIdMissing:
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

                  // Overall-score sort needs the aggregated scores, which are
                  // only available here (not on the driver doc). Re-sort now
                  // so "Score (low → high)" actually orders by real score.
                  if (_driverSort == _DriverSort.scoreLowToHigh) {
                    double scoreOf(
                      QueryDocumentSnapshot<Map<String, dynamic>> d,
                    ) {
                      final tid = (d.data()['transporterId'] ?? d.id)
                          .toString()
                          .trim()
                          .toUpperCase();
                      return overallScores[tid]?.averageScore ?? 9999.0;
                    }

                    filtered.sort((a, b) {
                      final c = scoreOf(a).compareTo(scoreOf(b));
                      if (c != 0) return c;
                      final an = (a.data()['driverName'] ?? '')
                          .toString()
                          .toLowerCase();
                      final bn = (b.data()['driverName'] ?? '')
                          .toString()
                          .toLowerCase();
                      return an.compareTo(bn);
                    });
                  }

                  // Contract-type breakdown — counts every ACTIVE
                  // driver in the unfiltered set so the totals stay
                  // stable while the admin searches/filters. Rejected
                  // / inactive drivers (`active: false`) drop out of
                  // both the total and the per-type counts.
                  // Verdachtsfälle auf Doppel-Profile: gleicher
                  // normalisierter Name ODER gleiche Personalnummer.
                  // Läuft auf der unfilterten Liste, damit ein aktives
                  // und ein archiviertes Profil derselben Person nicht
                  // auseinanderfallen.
                  final duplicateGroups = findDuplicateDriverGroups(docs);

                  final contractCounts = <DriverContractType?, int>{};
                  var activeTotal = 0;
                  for (final d in docs) {
                    final data = d.data();
                    final active = (data['active'] as bool?) ?? true;
                    if (!active) continue;
                    final ct = DriverContractType.fromValue(
                      data['contractType'],
                    );
                    contractCounts[ct] = (contractCounts[ct] ?? 0) + 1;
                    // Ticket: drivers without a contract type ("unset") and
                    // "Out Soon" drivers are NOT counted in the active total.
                    if (ct != null && ct != DriverContractType.outSoon) {
                      activeTotal++;
                    }
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
                          // Verdacht auf Doppel-Profile — rein lesend aus
                          // der ohnehin geladenen Fahrerliste (`docs`),
                          // keine zusätzliche Query. Der Hinweis
                          // erscheint nur, wenn es wirklich etwas zu
                          // prüfen gibt.
                          if (duplicateGroups.isNotEmpty)
                            _DuplicateProfilesBanner(
                              count: duplicateGroups.length,
                              onTap: () => _openMergeDuplicatesDialog(
                                duplicateGroups,
                                docs,
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
                          // „TID ausstehend" richtet sich nach der
                          // wirksamen TID, nicht nach dem Flag — sonst
                          // erscheinen Fahrer mit längst echter TID
                          // weiter als ausstehend.
                          final tidPending =
                              isDriverTidPending(data, d.id);
                          final hasTid = (data['transporterId'] ?? '')
                              .toString()
                              .trim()
                              .isNotEmpty;
                          final transporterId = tidPending
                              ? ''
                              : (hasTid
                                  ? (data['transporterId'] as String)
                                      .trim()
                                      .toUpperCase()
                                  : d.id.trim().toUpperCase());
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

  /// Alternating white / light-grey row backgrounds for readability.
  /// Sub-headers (`_DetailKachelHeader`) reset the zebra counter so the
  /// first row under each header always starts white.
  List<Widget> _buildSeparated() {
    final out = <Widget>[];
    var i = 0;
    for (final c in children) {
      if (c is _DetailKachelHeader) {
        out.add(c);
        i = 0;
        continue;
      }
      out.add(Container(
        decoration: BoxDecoration(
          color: i.isOdd ? const Color(0xFFF6F7F9) : Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: c,
      ));
      i++;
    }
    return out;
  }

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
/// Normalizes a stored work-permit type to 'eu' | 'working_visa'. Mirrors
/// `_DriversHubPageState._normalizeWorkPermitType` so the stateless list-row
/// pill resolves the same value without needing the State.
String _driverWorkPermitType(dynamic raw, {dynamic fallbackExpiry}) {
  final value = (raw ?? '').toString().trim().toLowerCase();
  if (value.isEmpty) {
    final hasLegacyExpiry =
        (fallbackExpiry ?? '').toString().trim().isNotEmpty;
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

/// Normalizes a stored licence type to 'eu' | 'non_eu'. Mirrors
/// `_DriversHubPageState._normalizeLicenseType`.
String _driverLicenseType(dynamic raw, Map<String, dynamic> onboarding) {
  final v = (raw ?? '').toString().trim().toLowerCase();
  if (v == 'eu') return 'eu';
  if (v == 'non_eu' || v == 'noneu' || v == 'non-eu') return 'non_eu';
  final firstDay = (onboarding['firstDayInGermany'] ?? '').toString().trim();
  return firstDay.isNotEmpty ? 'non_eu' : 'eu';
}

/// A single choice in an [_InlineChoicePill].
class _PillOption {
  const _PillOption(this.value, this.label, this.color);
  final String value;
  final String label;
  final Color color;
}

/// Compact inline pill (driver list-row) that opens a popup to pick one of a
/// small set of [options] and writes the chosen value via [onChanged]. Visual
/// twin of [_ContractTypePill], reused for work-permit and driving-licence.
class _InlineChoicePill extends StatelessWidget {
  const _InlineChoicePill({
    required this.icon,
    required this.value,
    required this.options,
    required this.tooltip,
    required this.onChanged,
  });
  final IconData icon;
  final String value;
  final List<_PillOption> options;
  final String tooltip;
  final Future<void> Function(String value) onChanged;

  @override
  Widget build(BuildContext context) {
    final current = options.firstWhere(
      (o) => o.value == value,
      orElse: () => options.first,
    );
    final accent = current.color;

    return PopupMenuButton<String>(
      tooltip: tooltip,
      position: PopupMenuPosition.under,
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onSelected: (v) async {
        if (v != value) await onChanged(v);
      },
      itemBuilder: (ctx) => [
        for (final o in options)
          PopupMenuItem<String>(
            value: o.value,
            height: 38,
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: o.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  o.label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight:
                        o.value == value ? FontWeight.w800 : FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
                if (o.value == value) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.check_rounded, size: 16, color: o.color),
                ],
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 3, 6, 3),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: accent.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: accent),
            const SizedBox(width: 4),
            Text(
              current.label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: accent,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: 3),
            Icon(Icons.keyboard_arrow_down_rounded,
                size: 12, color: accent.withValues(alpha: 0.8)),
          ],
        ),
      ),
    );
  }
}

/// Kleines Pill in der Fahrerliste: zeigt die Personalnummer /
/// Employee ID (Zeiterfassung) und öffnet per Tap ein Eingabefeld.
/// Führende Nullen werden beim Speichern entfernt ("00023" → "23").
class _EmployeeNumberPill extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> driverDoc;
  const _EmployeeNumberPill({required this.driverDoc});

  Future<void> _edit(BuildContext context) async {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final current =
        (driverDoc.data()['employeeNumber'] ?? '').toString().trim();
    final ctrl = TextEditingController(text: current);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          de ? 'Personalnummer / Employee ID' : 'Employee ID',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                de
                    ? 'Employee ID aus dem Zeiterfassungsprogramm — wird '
                        'beim Stunden-Import zum Zuordnen genutzt.'
                    : 'Employee ID from the time-tracking tool — used to '
                        'match drivers during the hours import.',
                style: const TextStyle(
                    fontSize: 12.5, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: de ? 'z. B. 23' : 'e.g. 23',
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(de ? 'Abbrechen' : 'Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF00B287)),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(de ? 'Speichern' : 'Save'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final cleaned =
        ctrl.text.trim().replaceFirst(RegExp(r'^0+(?=\d)'), '');
    await driverDoc.reference.set({
      'employeeNumber': cleaned.isEmpty ? FieldValue.delete() : cleaned,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final number =
        (driverDoc.data()['employeeNumber'] ?? '').toString().trim();
    final hasNumber = number.isNotEmpty;
    return Tooltip(
      message: de
          ? 'Personalnummer / Employee ID'
          : 'Employee ID',
      child: InkWell(
        onTap: () => _edit(context),
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: hasNumber
                ? const Color(0xFFEEF2FF)
                : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.tag_rounded,
                size: 11,
                color: hasNumber
                    ? const Color(0xFF4338CA)
                    : const Color(0xFF9CA3AF),
              ),
              const SizedBox(width: 3),
              Text(
                hasNumber ? number : (de ? 'Nr.' : 'ID'),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: hasNumber
                      ? const Color(0xFF4338CA)
                      : const Color(0xFF6B7280),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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

  /// Score-Kreis der Mobile-Kachel — Ring in der Amazon-Bucket-Farbe der
  /// Liste (≥93 Teal · ≥86 Blau · ≥70 Amber · ≥50 Orange · sonst Rot), die
  /// Prozentzahl steht im Kreis. Ohne Score: neutraler Ring mit „—".
  Widget _mobileScoreCircle(double? score) {
    final color = score == null
        ? const Color(0xFF9CA3AF)
        : _driversHubBucketColor(score);
    return SizedBox(
      width: 58,
      height: 58,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 58,
            height: 58,
            child: CircularProgressIndicator(
              value: score == null ? 0.0 : (score / 100).clamp(0.0, 1.0),
              strokeWidth: 4,
              strokeCap: StrokeCap.round,
              backgroundColor: color.withOpacity(0.14),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          if (score == null)
            Text(
              '—',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  score.toStringAsFixed(1).replaceAll('.', ','),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: -0.3,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                Text(
                  '%',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: color.withOpacity(0.75),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final de = Localizations.localeOf(context).languageCode == 'de';
    final score = overallScore?.averageScore;

    final onboarding = (driverDoc.data()['onboarding'] as Map?)
            ?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    final workPermitType = _driverWorkPermitType(
      onboarding['workPermitType'],
      fallbackExpiry: onboarding['residencePermitExpiry'],
    );
    final licenseType =
        _driverLicenseType(onboarding['licenseType'], onboarding);

    // Stationszuweisung (z. B. „DBY5") — dezentes graues Badge in der
    // Chip-Zeile, nur wenn gesetzt (Optik wie „TID ausstehend").
    final station = (driverDoc.data()['station'] ?? '').toString().trim();
    final Widget? stationBadge = station.isEmpty
        ? null
        : Tooltip(
            message: 'Station',
            waitDuration: const Duration(milliseconds: 500),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 11,
                    color: Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    station,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF6B7280),
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          );

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
      width: isCompact ? 44 : 40,
      height: isCompact ? 44 : 40,
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

    // ── Mobile-Kachel ────────────────────────────────────────────────────
    // Links der Score-Kreis, in der Mitte Name + Chips, rechts das
    // 3-Punkte-Menü mit Chevron darunter. Desktop bleibt unverändert.
    if (isCompact) {
      final contractPill = _ContractTypePill(
        type: contractType,
        onChanged: (newType) async {
          await driverDoc.reference.update(<String, dynamic>{
            if (newType == null)
              'contractType': FieldValue.delete()
            else
              'contractType': newType.value,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        },
      );
      final licencePill = _InlineChoicePill(
        icon: Icons.directions_car_filled_outlined,
        tooltip: de ? 'Führerschein' : 'Driving licence',
        value: licenseType,
        options: const [
          _PillOption('eu', 'EU', Color(0xFF00B287)),
          _PillOption('non_eu', 'Non-EU', Color(0xFFF47400)),
        ],
        onChanged: (v) => driverDoc.reference.update(<String, dynamic>{
          'onboarding.licenseType': v,
          'updatedAt': FieldValue.serverTimestamp(),
        }),
      );
      final permitPill = _InlineChoicePill(
        icon: Icons.badge_outlined,
        tooltip: de ? 'Arbeitserlaubnis' : 'Work permit',
        value: workPermitType,
        options: [
          const _PillOption('eu', 'EU', Color(0xFF0082AF)),
          _PillOption(
            'working_visa',
            de ? 'Visum' : 'Visa',
            const Color(0xFFF59E0B),
          ),
        ],
        onChanged: (v) => driverDoc.reference.update(<String, dynamic>{
          'onboarding.workPermitType': v,
          'updatedAt': FieldValue.serverTimestamp(),
        }),
      );

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
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
                _mobileScoreCircle(score),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          // Aktivitätspunkt jetzt neben dem Namen.
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: active
                                  ? const Color(0xFF34C759)
                                  : const Color(0xFFEF4444),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
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
                          ),
                          const SizedBox(width: 6),
                          _EmployeeNumberPill(driverDoc: driverDoc),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          contractPill,
                          licencePill,
                          permitPill,
                          if (stationBadge != null) stationBadge,
                          if (tidPending)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                de ? 'TID ausstehend' : 'TID pending',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF6B7280),
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child:
                              _MissingDocsBadge(driverRef: driverDoc.reference),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    menuButton,
                    const SizedBox(height: 2),
                    Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: onTap,
                        child: SizedBox(
                          width: 44,
                          height: 44,
                          child: Tooltip(
                            message: t.t('drivers_hub_tooltip_view_details'),
                            waitDuration: const Duration(milliseconds: 500),
                            child: const Icon(
                              Icons.chevron_right,
                              size: 30,
                              color: Color(0xFF8A93A0),
                            ),
                          ),
                        ),
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
                        // Personalnummer / Employee ID — direkt in der
                        // Übersicht eintragbar (vor dem Vertragstyp).
                        _EmployeeNumberPill(driverDoc: driverDoc),
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
                        _InlineChoicePill(
                          icon: Icons.badge_outlined,
                          tooltip: de
                              ? 'Arbeitserlaubnis'
                              : 'Work permit',
                          value: workPermitType,
                          options: [
                            const _PillOption(
                                'eu', 'EU', Color(0xFF0082AF)),
                            _PillOption(
                                'working_visa',
                                de ? 'Visum' : 'Visa',
                                const Color(0xFFF59E0B)),
                          ],
                          onChanged: (v) => driverDoc.reference.update(
                            <String, dynamic>{
                              'onboarding.workPermitType': v,
                              'updatedAt':
                                  FieldValue.serverTimestamp(),
                            },
                          ),
                        ),
                        _InlineChoicePill(
                          icon: Icons.directions_car_filled_outlined,
                          tooltip: de
                              ? 'Führerschein'
                              : 'Driving licence',
                          value: licenseType,
                          options: const [
                            _PillOption('eu', 'EU', Color(0xFF00B287)),
                            _PillOption(
                                'non_eu', 'Non-EU', Color(0xFFF47400)),
                          ],
                          onChanged: (v) => driverDoc.reference.update(
                            <String, dynamic>{
                              'onboarding.licenseType': v,
                              'updatedAt':
                                  FieldValue.serverTimestamp(),
                            },
                          ),
                        ),
                        if (stationBadge != null) stationBadge,
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
    this.onEditContractType,
    this.onEditNumber,
  });

  final String employeeNumber;
  final DriverContractType? contractType;

  /// Optional pre-built section appended below Vertragstyp. Used to host
  /// the overall-score accordion handle so the score lives next to the
  /// contract type instead of in the page header.
  final Widget? scoreSection;

  /// When set, the Vertragstyp pill becomes tappable (opens the
  /// contract-type picker) and shows even without a stored value.
  final VoidCallback? onEditContractType;

  /// When set, the Personalnummer becomes editable (pencil) and the
  /// section shows even without a stored value.
  final VoidCallback? onEditNumber;

  @override
  Widget build(BuildContext context) {
    final hasNumber =
        employeeNumber.trim().isNotEmpty || onEditNumber != null;
    final hasContract = contractType != null || onEditContractType != null;
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
                  'PERSONALNUMMER / EMPLOYEE ID',
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
            InkWell(
              onTap: onEditNumber,
              borderRadius: BorderRadius.circular(6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SelectableText(
                    employeeNumber.trim().isEmpty
                        ? '—'
                        : employeeNumber,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: employeeNumber.trim().isEmpty
                          ? const Color(0xFFCBD5E1)
                          : const Color(0xFF111827),
                      letterSpacing: -0.2,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  if (onEditNumber != null) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.edit_outlined,
                        size: 14, color: Color(0xFF9CA3AF)),
                  ],
                ],
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
                  color: contractType?.pillColor ?? const Color(0xFF6B7280),
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
            Builder(builder: (context) {
              final pillColor =
                  contractType?.pillColor ?? const Color(0xFF6B7280);
              final pill = Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: pillColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: pillColor.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      contractType?.label ?? '—',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: pillColor,
                        letterSpacing: 0.1,
                      ),
                    ),
                    if (onEditContractType != null) ...[
                      const SizedBox(width: 5),
                      Icon(Icons.edit_outlined,
                          size: 12, color: pillColor),
                    ],
                  ],
                ),
              );
              if (onEditContractType == null) return pill;
              return Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: onEditContractType,
                  borderRadius: BorderRadius.circular(999),
                  child: pill,
                ),
              );
            }),
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
      if ((counts[DriverContractType.outSoon] ?? 0) > 0)
        _ContractStatTile(
          label: 'Out Soon',
          value: counts[DriverContractType.outSoon] ?? 0,
          accent: DriverContractType.outSoon.pillColor,
          icon: Icons.logout_rounded,
          compact: compact,
          isSelected: _isType(DriverContractType.outSoon),
          onTap: () {
            final clear = _isType(DriverContractType.outSoon);
            onSelect(
              clear ? null : DriverContractType.outSoon,
              false,
              false,
            );
          },
        ),
    ];

    // Desktop: über die volle Breite gleichmäßig verteilt.
    // Mobile: alle Kacheln in EINER Reihe, so kompakt wie nötig — kein
    // horizontales Scrollen, damit alle Counter sichtbar sind.
    final gap = compact ? 6.0 : 8.0;
    return Row(
      children: [
        for (var i = 0; i < tiles.length; i++) ...[
          Expanded(child: tiles[i]),
          if (i < tiles.length - 1) SizedBox(width: gap),
        ],
      ],
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

/// Bucket-Farbe der Fahrerliste (Amazon-Stufen) — identisch zu
/// `_normalizedDriverScoreBucket` + `_driverScoreBucketColor`.
Color _driversHubBucketColor(double score) {
  if (score >= 93) return const Color(0xFF14B8A6);
  if (score >= 86) return const Color(0xFF0EA5E9);
  if (score >= 70) return const Color(0xFFF59E0B);
  if (score >= 50) return const Color(0xFFFB923C);
  return const Color(0xFFEF4444);
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
              const PopupMenuItem(
                value: _DriverSort.tidPending,
                child: Text('TID ausstehend'),
              ),
              const PopupMenuItem(
                value: _DriverSort.employeeIdMissing,
                child: Text('Employee ID missing'),
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
    final de = Localizations.localeOf(context).languageCode == 'de';
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
          ? (de
              ? 'Noch kein Antrag gespeichert — bitte den Fahrer zuerst das Formular ausfüllen lassen.'
              : 'No application saved yet — please have the driver fill in the form first.')
          : (de
              ? 'PDF-Generierung fehlgeschlagen: ${e.message ?? e.code}'
              : 'PDF generation failed: ${e.message ?? e.code}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: const Color(0xFFB42318)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            de ? 'PDF-Generierung fehlgeschlagen: $e' : 'PDF generation failed: $e',
          ),
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
        // Neue Uploads deaktiviert — Dokumente leben künftig im Company
        // Drive; Bestandsdateien bleiben abrufbar.
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
      case 'resident_permit_back':
        return Localizations.localeOf(context).languageCode == 'de'
            ? 'Aufenthaltstitel (Rückseite)'
            : 'Residence permit (back)';
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
      case 'safety_training_certificate':
        return Localizations.localeOf(context).languageCode == 'de'
            ? 'Sicherheitsunterweisung (Zertifikat)'
            : 'Safety instruction (certificate)';
      case 'privacy_training_certificate':
        return Localizations.localeOf(context).languageCode == 'de'
            ? 'Datenschutz-Schulung (Zertifikat)'
            : 'Privacy training (certificate)';
      case 'privacy_notice_ack':
        return Localizations.localeOf(context).languageCode == 'de'
            ? 'Datenschutzinformation (Kenntnisnahme)'
            : 'Privacy notice (acknowledgement)';
      case 'camera_privacy_ack_certificate':
        return Localizations.localeOf(context).languageCode == 'de'
            ? 'Kamera-Datenschutz (Kenntnisnahme)'
            : 'Camera privacy (acknowledgement)';
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
      final de = Localizations.localeOf(context).languageCode == 'de';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(de ? 'Fehler: $e' : 'Error: $e')),
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
      // NO orderBy here: `orderBy('uploadedAt')` silently EXCLUDES docs
      // without that field — e.g. ones only marked "saved in own drive" —
      // which made the toggle look broken. Rows are keyed by docType, so
      // ordering is irrelevant anyway.
      stream: driverRef.collection('documents').snapshots(),
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
          'resident_permit_back',
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
                    ? 'Saved in own drive'
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
                    // Always-visible toggle: "saved in own drive". A tap
                    // flips the flag — green when on, grey outline when off.
                    Tooltip(
                      message: Localizations.localeOf(context).languageCode ==
                              'de'
                          ? (inOwnDrive
                              ? 'Saved in own drive — Klick zum Entfernen'
                              : 'Als "Saved in own drive" markieren')
                          : (inOwnDrive
                              ? 'Saved in own drive — tap to remove'
                              : 'Mark as "Saved in own drive"'),
                      child: InkWell(
                        onTap: () => _setOwnDriveFlag(
                          context: context,
                          docType: docType,
                          value: !inOwnDrive,
                        ),
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          margin: const EdgeInsets.only(right: 2),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: inOwnDrive
                                ? const Color(0xFFD1FAE5)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: inOwnDrive
                                  ? const Color(0xFF6EE7B7)
                                  : const Color(0xFFD1D5DB),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                inOwnDrive
                                    ? Icons.check_rounded
                                    : Icons.cloud_outlined,
                                size: 12,
                                color: inOwnDrive
                                    ? const Color(0xFF065F46)
                                    : const Color(0xFF9CA3AF),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'Saved in own drive',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: inOwnDrive
                                      ? const Color(0xFF065F46)
                                      : const Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          ),
                        ),
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
                        // Neue Uploads sind deaktiviert — Dokumente leben
                        // künftig im Company Drive. Bereits hochgeladene
                        // Dateien bleiben abrufbar (Vorschau/Download).
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
                          child: const Text('Saved in own drive'),
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

        // Nachweise aus Schulungen (Zertifikate, Kenntnisnahmen): alles,
        // was in `documents` liegt, aber keinem festen Upload-Slot
        // entspricht. Nur anzeigen, wenn tatsächlich eine Datei/URL da
        // ist — sonst blähen leere Platzhalter die Liste auf.
        final extraDocTypes = docsByType.keys
            .where((k) => !allDocTypes.contains(k))
            .where((k) =>
                (docsByType[k]!['downloadUrl'] ?? '').toString().isNotEmpty)
            .toList()
          ..sort();

        final isDe = Localizations.localeOf(context).languageCode == 'de';

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
            if (extraDocTypes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                isDe ? 'Nachweise & Zertifikate' : 'Certificates & records',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              for (final docType in extraDocTypes)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: docTile(docType),
                ),
            ],
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

// ---------------------------------------------------------------------------
// „Profile zusammenführen" — manuelles Werkzeug für Alt-Dubletten
// ---------------------------------------------------------------------------
//
// Durch den früheren Fehler (CSV-Import legte für eine neue TID blind ein
// zweites Dokument an, statt den Platzhalter-Fahrer umzuziehen) existieren
// im Bestand Personen mit zwei oder drei Profilen, deren Daten aufgeteilt
// sind: die Scorecard-Wochen am einen, die Dokumente am anderen.
//
// Der Automatik-Fix in `driver_identity_service.dart` verhindert neue
// Dubletten, räumt die alten aber bewusst NICHT von selbst auf — welches
// Profil bestehen bleibt, ist eine Entscheidung des Admins. Dieses
// Werkzeug stellt die Kandidaten gegenüber und führt sie auf Zuruf über
// `migrateDriverToTid` zusammen.

/// `dd.MM.yyyy` ohne `intl` — reicht für das Anlage-Datum im Vergleich.
String _formatDayMonthYear(DateTime d) {
  final day = d.day.toString().padLeft(2, '0');
  final month = d.month.toString().padLeft(2, '0');
  return '$day.$month.${d.year}';
}

/// Zähler je Datenbereich eines Profils — daran erkennt der Admin, welches
/// das gepflegte Profil ist.
class _DuplicateProfileStats {
  const _DuplicateProfileStats({
    this.documents = 0,
    this.timeAccount = 0,
    this.absences = 0,
    this.academyProofs = 0,
    this.scoreWeeks = 0,
  });

  final int documents;
  final int timeAccount;
  final int absences;
  final int academyProofs;
  final int scoreWeeks;

  int get total =>
      documents + timeAccount + absences + academyProofs + scoreWeeks;
}

/// Lädt die Zähler eines Profils.
///
/// Bewusst mit `count()`-Aggregaten statt vollständiger `get()`s — die
/// Scorecard-Wochen sind je Fahrer schnell dreistellig. Nur die
/// Academy-Nachweise brauchen einzelne Dokument-Reads, weil sie unter
/// `academy_test_results/{testId}/drivers/{TID}` liegen.
Future<_DuplicateProfileStats> _loadDuplicateProfileStats({
  required String dspUid,
  required String docId,
  required String tid,
}) async {
  final db = FirebaseFirestore.instance;
  final driverRef =
      db.collection('users').doc(dspUid).collection('drivers').doc(docId);

  Future<int> countOf(Query<Map<String, dynamic>> query) async {
    try {
      final snap = await query.count().get();
      return snap.count ?? 0;
    } catch (_) {
      return 0;
    }
  }

  final documents = await countOf(driverRef.collection('documents'));
  final timeAccount = await countOf(driverRef.collection('time_account'));
  final absences = await countOf(driverRef.collection('absence_requests'));

  var academyProofs = 0;
  for (final testId in kAcademyTestIdsForMigration) {
    try {
      final snap = await db
          .collection('users')
          .doc(dspUid)
          .collection('academy_test_results')
          .doc(testId)
          .collection('drivers')
          .doc(docId)
          .get();
      if (snap.exists) academyProofs++;
    } catch (_) {
      // Einzelner Nachweis nicht lesbar — Zähler bleibt konservativ.
    }
  }

  final scoreWeeks = tid.isEmpty
      ? 0
      : await countOf(
          db
              .collection('users')
              .doc(dspUid)
              .collection('scores')
              .where('transporterId', isEqualTo: tid),
        );

  return _DuplicateProfileStats(
    documents: documents,
    timeAccount: timeAccount,
    absences: absences,
    academyProofs: academyProofs,
    scoreWeeks: scoreWeeks,
  );
}

/// Dezenter Einstieg im Kopf der Fahrerliste — erscheint nur, wenn es
/// mindestens einen Verdachtsfall gibt. Kein Badge-Spam.
class _DuplicateProfilesBanner extends StatelessWidget {
  const _DuplicateProfilesBanner({
    required this.count,
    required this.onTap,
  });

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8EC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF2D9A8)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.people_alt_outlined,
                size: 18,
                color: Color(0xFFB45309),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  de
                      ? (count == 1
                          ? '1 mögliches Doppel-Profil prüfen'
                          : '$count mögliche Doppel-Profile prüfen')
                      : (count == 1
                          ? '1 possible duplicate profile'
                          : '$count possible duplicate profiles'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF92400E),
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: Color(0xFFB45309),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Der Zusammenführen-Dialog.
///
/// Zeigt je Verdachtsfall alle beteiligten Profile nebeneinander. Der
/// Admin wählt per Radio das ZIEL-Profil (dessen TID bleibt bestehen) und
/// führt die übrigen einzeln hinein. Damit funktioniert auch der Fall mit
/// drei Profilen: nach dem ersten Zusammenführen bleibt der Fall mit dem
/// verbleibenden Profil stehen.
class _MergeDuplicateProfilesDialog extends StatefulWidget {
  const _MergeDuplicateProfilesDialog({
    required this.dspUid,
    required this.groups,
    required this.driverData,
  });

  final String dspUid;
  final List<DuplicateDriverGroup> groups;

  /// Doc-ID → Fahrerdaten, aus dem Stream der Seite (keine neue Query).
  final Map<String, Map<String, dynamic>> driverData;

  @override
  State<_MergeDuplicateProfilesDialog> createState() =>
      _MergeDuplicateProfilesDialogState();
}

class _MergeDuplicateProfilesDialogState
    extends State<_MergeDuplicateProfilesDialog> {
  /// Fälle als veränderliche Kopie — nach einem Umzug fällt das
  /// Quell-Profil heraus.
  late List<List<String>> _cases;
  late List<Set<DuplicateDriverSignal>> _signals;
  late List<String> _labels;

  /// Fall-Index → gewählte Ziel-Doc-ID.
  final Map<int, String> _target = <int, String>{};

  /// Doc-ID → Zähler (null = lädt noch).
  final Map<String, _DuplicateProfileStats?> _stats =
      <String, _DuplicateProfileStats?>{};

  String? _busyDocId;

  @override
  void initState() {
    super.initState();
    _cases = widget.groups.map((g) => [...g.docIds]).toList();
    _signals = widget.groups.map((g) => g.signals).toList();
    _labels = widget.groups.map((g) => g.label).toList();
    for (var i = 0; i < _cases.length; i++) {
      // Vorschlag: das Profil mit den meisten Daten ist meistens das
      // gepflegte — bis die Zähler da sind, einfach das erste.
      _target[i] = _cases[i].first;
    }
    _loadAllStats();
  }

  Future<void> _loadAllStats() async {
    for (final docIds in _cases) {
      for (final docId in docIds) {
        if (_stats.containsKey(docId)) continue;
        _stats[docId] = null;
        final stats = await _loadDuplicateProfileStats(
          dspUid: widget.dspUid,
          docId: docId,
          tid: _tidOf(docId),
        );
        if (!mounted) return;
        setState(() => _stats[docId] = stats);
        _suggestTargets();
      }
    }
  }

  /// Sobald die Zähler eines Falls vollständig sind, das datenreichste
  /// Profil vorschlagen — der Admin kann es jederzeit ändern.
  void _suggestTargets() {
    for (var i = 0; i < _cases.length; i++) {
      final ids = _cases[i];
      if (ids.any((id) => _stats[id] == null)) continue;
      final best = ids.reduce((a, b) =>
          (_stats[a]!.total >= _stats[b]!.total) ? a : b);
      if (_target[i] != best && !_userPicked.contains(i)) {
        setState(() => _target[i] = best);
      }
    }
  }

  /// Fälle, in denen der Admin selbst gewählt hat — dann nie mehr
  /// automatisch umstellen.
  final Set<int> _userPicked = <int>{};

  String _tidOf(String docId) {
    final data = widget.driverData[docId] ?? const <String, dynamic>{};
    return effectiveDriverTid(data, docId);
  }

  String _nameOf(String docId) {
    final data = widget.driverData[docId] ?? const <String, dynamic>{};
    return (data['driverName'] ?? '').toString().trim();
  }

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final mediaW = MediaQuery.of(context).size.width;
    final dialogW = mediaW < 720 ? mediaW - 24 : 880.0;

    final visible = <int>[
      for (var i = 0; i < _cases.length; i++)
        if (_cases[i].length > 1) i,
    ];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: dialogW, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.merge_type,
                    size: 20,
                    color: Color(0xFFB45309),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      de
                          ? 'Profile zusammenführen'
                          : 'Merge duplicate profiles',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: de ? 'Schließen' : 'Close',
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                de
                    ? 'Diese Fahrer haben denselben Namen oder dieselbe '
                        'Personalnummer und sind vermutlich dieselbe Person. '
                        'Wähle je Fall das Profil, dessen Transporter-ID '
                        'bestehen bleiben soll, und führe die übrigen dort '
                        'hinein. Es wird nichts automatisch zusammengeführt.'
                    : 'These drivers share a name or an employee ID and are '
                        'most likely the same person. Pick the profile whose '
                        'transporter ID should remain, then merge the others '
                        'into it. Nothing is merged automatically.',
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 1.4,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: visible.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text(
                            de
                                ? 'Keine offenen Doppel-Profile mehr.'
                                : 'No duplicate profiles left.',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: visible.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (ctx, i) => _buildCase(visible[i], de),
                      ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(de ? 'Fertig' : 'Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCase(int index, bool de) {
    final ids = _cases[index];
    final signals = _signals[index];
    final target = _target[index] ?? ids.first;
    final isNarrow = MediaQuery.of(context).size.width < 720;

    final chips = <String>[
      if (signals.contains(DuplicateDriverSignal.driverName))
        de ? 'gleicher Name' : 'same name',
      if (signals.contains(DuplicateDriverSignal.employeeNumber))
        de ? 'gleiche Personalnummer' : 'same employee ID',
    ];

    final cards = <Widget>[
      for (final docId in ids)
        _buildProfileCard(
          caseIndex: index,
          docId: docId,
          isTarget: docId == target,
          targetDocId: target,
          de: de,
        ),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Text(
                _labels[index].isEmpty
                    ? (de ? 'Ohne Name' : 'No name')
                    : _labels[index],
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              for (final chip in chips)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Text(
                    chip,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1D4ED8),
                    ),
                  ),
                ),
              Text(
                de
                    ? '${ids.length} Profile'
                    : '${ids.length} profiles',
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isNarrow)
            Column(
              children: [
                for (var i = 0; i < cards.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  cards[i],
                ],
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < cards.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(child: cards[i]),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildProfileCard({
    required int caseIndex,
    required String docId,
    required bool isTarget,
    required String targetDocId,
    required bool de,
  }) {
    final data = widget.driverData[docId] ?? const <String, dynamic>{};
    final tid = _tidOf(docId);
    final pending = isDriverTidPending(data, docId);
    final employeeNumber = (data['employeeNumber'] ?? '').toString().trim();
    final email = (data['email'] ?? data['loginEmail'] ?? '').toString().trim();
    final active = (data['active'] as bool?) ?? true;
    final hasLogin = data['hasLogin'] == true;
    final createdRaw = data['createdAt'];
    final created = createdRaw is Timestamp
        ? _formatDayMonthYear(createdRaw.toDate())
        : '—';
    final stats = _stats[docId];
    final busy = _busyDocId != null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTarget ? const Color(0xFF00B287) : const Color(0xFFE5E7EB),
          width: isTarget ? 1.6 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Radio<String>(
                  value: docId,
                  groupValue: targetDocId,
                  activeColor: const Color(0xFF00B287),
                  onChanged: busy
                      ? null
                      : (v) {
                          if (v == null) return;
                          setState(() {
                            _target[caseIndex] = v;
                            _userPicked.add(caseIndex);
                          });
                        },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  pending
                      ? (de ? 'TID ausstehend' : 'TID pending')
                      : tid,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: pending
                        ? const Color(0xFFB45309)
                        : const Color(0xFF111827),
                  ),
                ),
              ),
              if (isTarget)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7F8F1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    de ? 'Ziel' : 'Target',
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F7A5A),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          _kv(de ? 'Name' : 'Name', _nameOf(docId)),
          _kv(de ? 'Personalnummer' : 'Employee ID', employeeNumber),
          _kv(de ? 'E-Mail' : 'Email', email),
          _kv(de ? 'Aktiv' : 'Active',
              active ? (de ? 'ja' : 'yes') : (de ? 'nein' : 'no')),
          _kv(de ? 'Login' : 'Login',
              hasLogin ? (de ? 'ja' : 'yes') : (de ? 'nein' : 'no')),
          _kv(de ? 'Angelegt' : 'Created', created),
          const Divider(height: 18),
          if (stats == null)
            Row(
              children: [
                const SizedBox(
                  width: 13,
                  height: 13,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Text(
                  de ? 'Daten werden gezählt …' : 'Counting data …',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            )
          else ...[
            _kv(de ? 'Dokumente' : 'Documents', '${stats.documents}'),
            _kv(de ? 'Zeitkonto-Monate' : 'Time account months',
                '${stats.timeAccount}'),
            _kv(de ? 'Abwesenheiten' : 'Absences', '${stats.absences}'),
            _kv(de ? 'Academy-Nachweise' : 'Academy proofs',
                '${stats.academyProofs}'),
            _kv(de ? 'Scorecard-Wochen' : 'Scorecard weeks',
                '${stats.scoreWeeks}'),
          ],
          if (!isTarget) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFB45309),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onPressed: busy
                    ? null
                    : () => _confirmAndMerge(
                          caseIndex: caseIndex,
                          sourceDocId: docId,
                          targetDocId: targetDocId,
                        ),
                icon: _busyDocId == docId
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.merge_type, size: 16),
                label: Text(
                  de ? 'In Ziel zusammenführen' : 'Merge into target',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _kv(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value.trim().isEmpty ? '—' : value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Sicherheitsnetz: klare Warnung mit Nennung der Quell-TID, bevor das
  /// Quell-Profil verschwindet.
  Future<void> _confirmAndMerge({
    required int caseIndex,
    required String sourceDocId,
    required String targetDocId,
  }) async {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final messenger = ScaffoldMessenger.of(context);
    final sourceTid = _tidOf(sourceDocId);
    final targetTid = _tidOf(targetDocId);
    final sourceStats = _stats[sourceDocId] ?? const _DuplicateProfileStats();

    if (isDriverTidPending(
      widget.driverData[targetDocId] ?? const <String, dynamic>{},
      targetDocId,
    )) {
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFB42318),
          content: Text(
            de
                ? 'Das Ziel-Profil hat noch keine echte Transporter-ID. '
                    'Wähle das Profil mit der echten TID als Ziel.'
                : 'The target profile has no real transporter ID yet. Pick '
                    'the profile with the real TID as the target.',
          ),
        ),
      );
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          de ? 'Profile zusammenführen?' : 'Merge profiles?',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        content: SizedBox(
          width: 400,
          child: Text(
            de
                ? 'Das Profil "$sourceTid" wird in "$targetTid" überführt und '
                    'danach GELÖSCHT. Dokumente, Zeitkonto, Abwesenheiten und '
                    'Academy-Nachweise wandern mit. Felder und Dokumente, die '
                    'im Ziel schon vorhanden sind, bleiben unverändert — leere '
                    'Felder im Ziel werden aus "$sourceTid" ergänzt.\n\n'
                    'Das lässt sich nicht rückgängig machen.'
                : 'Profile "$sourceTid" will be moved into "$targetTid" and '
                    'then DELETED. Documents, time account, absences and '
                    'academy proofs move along. Fields and documents that '
                    'already exist on the target stay untouched — empty '
                    'target fields are filled from "$sourceTid".\n\n'
                    'This cannot be undone.',
            style: const TextStyle(fontSize: 12.5, height: 1.4),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(de ? 'Abbrechen' : 'Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB45309),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(de ? 'Zusammenführen' : 'Merge'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _busyDocId = sourceDocId);
    try {
      final result = await migrateDriverToTid(
        dspUid: widget.dspUid,
        fromDocId: sourceDocId,
        toTid: targetTid,
      );

      if (!mounted) return;
      setState(() {
        _cases[caseIndex] = [
          for (final id in _cases[caseIndex])
            if (id != sourceDocId) id,
        ];
        _busyDocId = null;
      });

      final detail = de
          ? '${sourceStats.documents} Dokumente, '
              '${sourceStats.timeAccount} Zeitkonto-Einträge, '
              '${sourceStats.academyProofs} Academy-Nachweise übernommen'
          : '${sourceStats.documents} documents, '
              '${sourceStats.timeAccount} time-account entries, '
              '${sourceStats.academyProofs} academy proofs moved';

      messenger.showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 8),
          backgroundColor: result.hasLoginSyncWarning
              ? const Color(0xFFB45309)
              : null,
          content: Text(
            result.hasLoginSyncWarning
                ? (de
                    ? 'Profil $sourceTid → $targetTid zusammengeführt '
                        '($detail) — der Fahrer-Login konnte aber nicht auf '
                        'die neue TID synchronisiert werden.'
                    : 'Profile $sourceTid → $targetTid merged ($detail) — but '
                        'the driver login could not be synced to the new TID.')
                : (de
                    ? 'Profil $sourceTid → $targetTid zusammengeführt: $detail.'
                    : 'Profile $sourceTid → $targetTid merged: $detail.'),
          ),
        ),
      );

      // Nach dem Umzug liegen die Daten im Ziel — Zähler neu holen.
      final refreshed = await _loadDuplicateProfileStats(
        dspUid: widget.dspUid,
        docId: targetDocId,
        tid: targetTid,
      );
      if (!mounted) return;
      setState(() => _stats[targetDocId] = refreshed);

      // Keine offenen Fälle mehr → Dialog schließen.
      if (_cases.every((ids) => ids.length < 2)) {
        if (mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _busyDocId = null);
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFB42318),
          content: Text(
            de
                ? 'Zusammenführen fehlgeschlagen: $e'
                : 'Merge failed: $e',
          ),
        ),
      );
    }
  }
}
