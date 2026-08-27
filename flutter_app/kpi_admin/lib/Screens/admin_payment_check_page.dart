// lib/Screens/admin_payment_check_page.dart
//
// Payment Check (Beta) — Owner-PIN-protected reconciliation tool.
//
// Flow:
//   1. Owner-PIN gate. First visit lets the owner SET a PIN; later visits
//      require it. The PIN is stored only as a salted SHA-256 hash under
//      users/{adminUid}/settings/payment_check (never in plaintext).
//   2. The owner uploads the weekly Amazon invoice (PDF) and the Work
//      Summary Tool export (ZIP with CSVs, or the loose CSVs).
//   3. The tool reconciles both and shows ONLY what is MISSING on the
//      invoice — routes and parcels the WST reports but Amazon did not pay.
//
// ⚠ DATENSCHUTZ / PRIVACY — hard requirement
// ──────────────────────────────────────────
// Invoice and WST files contain sensitive data. They are NEVER stored or
// transmitted anywhere: no Firebase Storage, no Firestore, no parser_service,
// no HTTP call of any kind. Both files are parsed in-memory in the browser
// (see `../services/payment_check_parser.dart`) and only the derived results
// live in widget state — reloading the page discards everything. The previous
// server-side `ParserApi.parseInvoice` call and the Firestore roster streams
// were removed for exactly this reason.
//
// The parsing/reconciliation core is deliberately kept in a Flutter-free file
// so the standalone harness `tool/payment_check_parse_test.dart` verifies the
// very same code via `dart run`.

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;

import '../services/payment_check_parser.dart';
import '../services/shift_plan_payment_source.dart';
import '../widgets/admin_scope.dart';

const _kAccent = Color(0xFF00B287);
const _kInk = Color(0xFF0F172A);
const _kMuted = Color(0xFF64748B);

class AdminPaymentCheckPage extends StatefulWidget {
  const AdminPaymentCheckPage({super.key});

  @override
  State<AdminPaymentCheckPage> createState() => _AdminPaymentCheckPageState();
}

class _AdminPaymentCheckPageState extends State<AdminPaymentCheckPage> {
  bool _unlocked = false;

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final adminUid = AdminScope.adminUidOf(context);
    if (adminUid == null) {
      return _Centered(
        icon: Icons.lock_outline,
        title: de ? 'Nicht angemeldet' : 'Not signed in',
        subtitle: de ? 'Bitte melde dich erneut an.' : 'Please sign in again.',
      );
    }

    return Container(
      color: const Color(0xFFF1F5F9),
      child: _unlocked
          ? const _PaymentCheckBody()
          : _PinGate(
              adminUid: adminUid,
              onUnlocked: () => setState(() => _unlocked = true),
            ),
    );
  }
}

// ───────────────────────────── PIN helpers ─────────────────────────────

String _hashPin(String pin, String salt) =>
    sha256.convert(utf8.encode('$salt::$pin')).toString();

String _genSalt() {
  final r = Random.secure();
  return base64Url.encode(List<int>.generate(18, (_) => r.nextInt(256)));
}

DocumentReference<Map<String, dynamic>> _pinDocRef(String adminUid) =>
    FirebaseFirestore.instance
        .collection('users')
        .doc(adminUid)
        .collection('settings')
        .doc('payment_check');

// ───────────────────────────── PIN gate UI ─────────────────────────────

class _PinGate extends StatefulWidget {
  final String adminUid;
  final VoidCallback onUnlocked;
  const _PinGate({required this.adminUid, required this.onUnlocked});

  @override
  State<_PinGate> createState() => _PinGateState();
}

class _PinGateState extends State<_PinGate> {
  bool _loading = true;
  bool _hasPin = false;
  String? _salt;
  String? _hash;
  String? _error;
  bool _busy = false;

  final _pin = TextEditingController();
  final _pinConfirm = TextEditingController();

  /// Locale flag for messages produced outside `build` (async callbacks and
  /// button handlers — the widget is mounted and built by then).
  bool get _de => Localizations.localeOf(context).languageCode == 'de';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _pin.dispose();
    _pinConfirm.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final snap = await _pinDocRef(widget.adminUid).get();
      final data = snap.data();
      final hash = (data?['pinHash'] ?? '').toString();
      final salt = (data?['pinSalt'] ?? '').toString();
      if (!mounted) return;
      setState(() {
        _hasPin = hash.isNotEmpty && salt.isNotEmpty;
        _hash = hash;
        _salt = salt;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = _de
            ? 'Konnte PIN-Status nicht laden: $e'
            : 'Could not load PIN status: $e';
        _loading = false;
      });
    }
  }

  Future<void> _createPin() async {
    final pin = _pin.text.trim();
    final confirm = _pinConfirm.text.trim();
    if (pin.length < 4 || !RegExp(r'^\d+$').hasMatch(pin)) {
      setState(() => _error = _de
          ? 'PIN muss mindestens 4 Ziffern haben.'
          : 'The PIN must have at least 4 digits.');
      return;
    }
    if (pin != confirm) {
      setState(() => _error =
          _de ? 'Die PINs stimmen nicht überein.' : 'The PINs do not match.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final salt = _genSalt();
      await _pinDocRef(widget.adminUid).set({
        'pinHash': _hashPin(pin, salt),
        'pinSalt': salt,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (!mounted) return;
      widget.onUnlocked();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = _de ? 'Speichern fehlgeschlagen: $e' : 'Saving failed: $e';
      });
    }
  }

  void _verifyPin() {
    final pin = _pin.text.trim();
    if (pin.isEmpty) {
      setState(() =>
          _error = _de ? 'Bitte PIN eingeben.' : 'Please enter your PIN.');
      return;
    }
    if (_salt != null && _hashPin(pin, _salt!) == _hash) {
      widget.onUnlocked();
    } else {
      setState(() {
        _error = _de ? 'Falsche PIN.' : 'Wrong PIN.';
        _pin.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: _kAccent));
    }

    final de = Localizations.localeOf(context).languageCode == 'de';
    final setup = !_hasPin;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _kAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.lock_outline,
                      color: _kAccent, size: 28),
                ),
                const SizedBox(height: 18),
                Text(
                  setup
                      ? (de ? 'Owner-PIN vergeben' : 'Set owner PIN')
                      : (de ? 'Owner-PIN eingeben' : 'Enter owner PIN'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _kInk,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  setup
                      ? (de
                          ? 'Lege eine PIN fest, um den Payment Check zu schützen. '
                              'Du brauchst sie bei jedem Zugriff.'
                          : 'Set a PIN to protect Payment Check. '
                              'You will need it on every visit.')
                      : (de
                          ? 'Dieser Bereich ist PIN-geschützt.'
                          : 'This area is PIN-protected.'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13.5, color: _kMuted),
                ),
                const SizedBox(height: 22),
                _PinField(
                  controller: _pin,
                  label: setup
                      ? (de
                          ? 'Neue PIN (min. 4 Ziffern)'
                          : 'New PIN (min. 4 digits)')
                      : 'PIN',
                  onSubmitted: setup ? null : (_) => _verifyPin(),
                ),
                if (setup) ...[
                  const SizedBox(height: 12),
                  _PinField(
                    controller: _pinConfirm,
                    label: de ? 'PIN bestätigen' : 'Confirm PIN',
                    onSubmitted: (_) => _createPin(),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Color(0xFFDC2626),
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                ],
                const SizedBox(height: 22),
                SizedBox(
                  height: 48,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: _kAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _busy
                        ? null
                        : (setup ? _createPin : _verifyPin),
                    child: _busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            setup
                                ? (de
                                    ? 'PIN festlegen & öffnen'
                                    : 'Set PIN & open')
                                : (de ? 'Entsperren' : 'Unlock'),
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 15),
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
}

class _PinField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final ValueChanged<String>? onSubmitted;
  const _PinField({
    required this.controller,
    required this.label,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: true,
      keyboardType: TextInputType.number,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kAccent, width: 1.6),
        ),
      ),
    );
  }
}

// ─────────────────────────── Payment Check body ───────────────────────────

class _PaymentCheckBody extends StatefulWidget {
  const _PaymentCheckBody();

  @override
  State<_PaymentCheckBody> createState() => _PaymentCheckBodyState();
}

/// Which data feeds column 2: the classic WST upload or a saved shift plan
/// loaded from Firestore (drafts first, published fallback).
enum _WstSource { upload, shiftPlan }

class _PaymentCheckBodyState extends State<_PaymentCheckBody> {
  // ── in-memory only ──────────────────────────────────────────────────────
  // Nothing below is ever persisted. No Firestore write, no Storage upload,
  // no parser_service call. A page reload wipes all of it, by design.
  // (The shift-plan source only READS the admin's own, already-stored
  // shift_plan_drafts / shift_plans docs — it never writes anything.)
  InvoiceData? _invoice;
  String? _invoiceFileName;
  bool _invoiceLoading = false;
  String? _invoiceError;

  WstData? _wstUpload;
  List<String> _wstFileNames = const <String>[];
  bool _wstLoading = false;
  String? _wstError;

  _WstSource _wstSource = _WstSource.upload;
  ShiftPlanPaymentData? _planData;
  bool _planLoading = false;
  String? _planError;

  ReconResult? _result;

  bool get _de => Localizations.localeOf(context).languageCode == 'de';

  /// The WST-shaped data of the ACTIVE source tab.
  WstData? get _activeWst =>
      _wstSource == _WstSource.upload ? _wstUpload : _planData?.wst;

  void _recompute() {
    final inv = _invoice;
    final wst = _activeWst;
    _result = (inv != null && wst != null) ? reconcile(inv, wst) : null;
  }

  // ── Invoice (PDF) ───────────────────────────────────────────────────────

  /// Extracts the invoice text **locally**.
  ///
  /// Primary path is the pure-Dart extractor in `payment_check_parser.dart`
  /// (same code the verification harness runs). syncfusion_flutter_pdf is the
  /// fallback for PDFs with embedded subset fonts / CMaps that the compact
  /// extractor cannot decode. Both run entirely in the browser.
  String _extractInvoiceText(Uint8List bytes) {
    try {
      final local = extractPdfText(bytes);
      if (pdfTextLooksUsable(local)) return local;
    } catch (_) {
      // fall through to syncfusion
    }
    final doc = sf.PdfDocument(inputBytes: bytes);
    try {
      return sf.PdfTextExtractor(doc).extractText(layoutText: true);
    } finally {
      doc.dispose();
    }
  }

  Future<void> _pickInvoice() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      withData: true,
    );
    if (picked == null || picked.files.isEmpty) return;
    final f = picked.files.first;
    final bytes = f.bytes;
    if (bytes == null) return;

    setState(() {
      _invoiceLoading = true;
      _invoiceError = null;
    });
    try {
      final text = _extractInvoiceText(bytes);
      final parsed = parseInvoiceText(text);
      if (!mounted) return;
      if (parsed.isEmpty) {
        setState(() {
          _invoiceLoading = false;
          _invoiceError = _de
              ? 'In dieser PDF wurde keine Detailtabelle '
                  '„Details des Rechnungsdatums" gefunden.'
              : 'No "Details des Rechnungsdatums" detail table was found '
                  'in this PDF.';
        });
        return;
      }
      setState(() {
        _invoice = parsed;
        _invoiceFileName = f.name;
        _invoiceLoading = false;
        _recompute();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _invoiceLoading = false;
        _invoiceError = _de
            ? 'Rechnung konnte nicht gelesen werden: $e'
            : 'Could not read the invoice: $e';
      });
    }
  }

  // ── WST (ZIP / CSVs) ────────────────────────────────────────────────────

  Future<void> _pickWst() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['zip', 'csv'],
      allowMultiple: true,
      withData: true,
    );
    if (picked == null || picked.files.isEmpty) return;

    final input = <NamedBytes>[];
    for (final f in picked.files) {
      final b = f.bytes;
      if (b != null) input.add(NamedBytes(f.name, b));
    }
    if (input.isEmpty) return;

    setState(() {
      _wstLoading = true;
      _wstError = null;
    });
    try {
      final parsed = parseWstFiles(input);
      if (!mounted) return;
      if (parsed.isEmpty) {
        setState(() {
          _wstLoading = false;
          _wstError = _de
              ? 'Kein Weekly Report und kein Package Report erkannt. '
                  'Bitte das WST-ZIP oder die einzelnen CSVs hochladen.'
              : 'No Weekly Report and no Package Report detected. '
                  'Please upload the WST ZIP or the individual CSVs.';
        });
        return;
      }
      setState(() {
        // Uploads ergänzen sich: Weekly Report (Routen) und Package
        // Report (Pakete) dürfen nacheinander hochgeladen werden —
        // gleiche Komponente wird ersetzt, nie doppelt gezählt.
        _wstUpload = mergeWstData(_wstUpload, parsed);
        _wstFileNames = _wstUpload!.filesUsed;
        _wstLoading = false;
        _recompute();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _wstLoading = false;
        _wstError =
            _de ? 'WST konnte nicht gelesen werden: $e' : 'Could not read WST: $e';
      });
    }
  }

  void _clearAll() {
    setState(() {
      _invoice = null;
      _invoiceFileName = null;
      _invoiceError = null;
      _wstUpload = null;
      _wstFileNames = const <String>[];
      _wstError = null;
      _planData = null;
      _planError = null;
      _result = null;
    });
  }

  void _setWstSource(_WstSource source) {
    if (source == _wstSource) return;
    setState(() {
      _wstSource = source;
      _recompute();
    });
  }

  // ── Shiftplan source ────────────────────────────────────────────────────

  /// Default range for the shift-plan pick: the period the reconciliation
  /// concerns anyway (the invoice period), otherwise the Amazon week
  /// (Sunday–Saturday) that contains yesterday.
  DateTimeRange _defaultPlanRange() {
    final invStart = _invoice?.periodStart ?? _invoice?.minDate;
    final invEnd = _invoice?.periodEnd ?? _invoice?.maxDate;
    if (invStart != null && invEnd != null && !invEnd.isBefore(invStart)) {
      return DateTimeRange(start: invStart, end: invEnd);
    }
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 1));
    // Amazon weeks run Sunday–Saturday (see the invoice header).
    final start = yesterday.subtract(Duration(days: yesterday.weekday % 7));
    return DateTimeRange(
        start: start, end: start.add(const Duration(days: 6)));
  }

  Future<void> _pickShiftPlan() async {
    final de = _de;
    final adminUid = AdminScope.adminUidOf(context);
    if (adminUid == null) return;

    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2, 1, 1),
      lastDate: DateTime(now.year, now.month, now.day)
          .add(const Duration(days: 7)),
      initialDateRange: _defaultPlanRange(),
      helpText: de
          ? 'Zeitraum des Schichtplans wählen'
          : 'Select the shift plan period',
      saveText: de ? 'Übernehmen' : 'Apply',
    );
    if (range == null || !mounted) return;
    if (range.duration.inDays > 31) {
      setState(() => _planError = de
          ? 'Bitte höchstens 31 Tage auswählen.'
          : 'Please select at most 31 days.');
      return;
    }

    setState(() {
      _planLoading = true;
      _planError = null;
    });
    ShiftPlanPaymentData data;
    try {
      data = await loadShiftPlanPaymentData(
        adminUid: adminUid,
        start: range.start,
        end: range.end,
        de: de,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _planLoading = false;
        _planError = de
            ? 'Schichtplan konnte nicht geladen werden: $e'
            : 'Could not load the shift plan: $e';
      });
      return;
    }
    if (!mounted) return;

    if (data.days.isEmpty) {
      setState(() {
        _planLoading = false;
        _planError = range.start == range.end
            ? (de
                ? 'Kein gespeicherter Schichtplan für diesen Tag.'
                : 'No saved shift plan for this day.')
            : (de
                ? 'Kein gespeicherter Schichtplan für diesen Zeitraum.'
                : 'No saved shift plan for this period.');
      });
      return;
    }

    // Bestätigung — mit Fahrerzahl, die nach dem Lesen bekannt ist.
    // Bis zur Bestätigung wird nichts in den Vergleich übernommen.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) =>
          _PlanConfirmDialog(data: data, range: range, de: de),
    );
    if (!mounted) return;
    if (confirmed != true) {
      setState(() => _planLoading = false);
      return;
    }

    setState(() {
      _planData = data;
      _planLoading = false;
      _planError = null;
      _wstSource = _WstSource.shiftPlan;
      _recompute();
    });
  }

  @override
  Widget build(BuildContext context) {
    final de = _de;
    final hasAnything =
        _invoice != null || _wstUpload != null || _planData != null;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(
            hasData: hasAnything,
            onClear: _clearAll,
            invoice: _invoice,
            wst: _activeWst,
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, c) {
                final wide = c.maxWidth >= 1000;

                final invoiceCol = _InvoiceColumn(
                  invoice: _invoice,
                  fileName: _invoiceFileName,
                  loading: _invoiceLoading,
                  error: _invoiceError,
                  onPick: _pickInvoice,
                );
                final wstCol = _WstColumn(
                  wst: _wstUpload,
                  fileNames: _wstFileNames,
                  loading: _wstLoading,
                  error: _wstError,
                  onPick: _pickWst,
                  source: _wstSource,
                  onSourceChanged: _setWstSource,
                  planData: _planData,
                  planLoading: _planLoading,
                  planError: _planError,
                  onPickPlan: _pickShiftPlan,
                );
                final resultCol = _ResultColumn(
                  result: _result,
                  hasInvoice: _invoice != null,
                  hasWst: _activeWst != null,
                  fromShiftPlan: _wstSource == _WstSource.shiftPlan,
                  planMarks: _wstSource == _WstSource.shiftPlan
                      ? (_planData?.marks ?? const <ShiftPlanMark>[])
                      : const <ShiftPlanMark>[],
                  planData: _wstSource == _WstSource.shiftPlan
                      ? _planData
                      : null,
                );

                final banner = Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: _PrivacyBanner(de: de),
                );

                if (wide) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      banner,
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Gleichmaessige Drittelung (Ticket) — die
                              // Ergebnis-Spalte bekam vorher doppelte
                              // Breite und quetschte die Upload-Spalten.
                              Expanded(child: invoiceCol),
                              const SizedBox(width: 14),
                              Expanded(child: wstCol),
                              const SizedBox(width: 14),
                              Expanded(child: resultCol),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    banner,
                    const SizedBox(height: 12),
                    SizedBox(height: 460, child: invoiceCol),
                    const SizedBox(height: 14),
                    SizedBox(height: 460, child: wstCol),
                    const SizedBox(height: 14),
                    SizedBox(height: 560, child: resultCol),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────── Privacy banner ─────────────────────────────

/// Hard requirement: the operator must see, at all times, that neither the
/// invoice nor the WST export leaves the browser.
class _PrivacyBanner extends StatelessWidget {
  final bool de;
  const _PrivacyBanner({required this.de});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kAccent.withValues(alpha: 0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined, color: Color(0xFF0B8F6E), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  de
                      ? 'Rechnung & WST werden nicht gespeichert'
                      : 'Invoice & WST are never stored',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13.5,
                    color: Color(0xFF065F46),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  de
                      ? 'Verarbeitung ausschließlich lokal im Browser — kein Upload, '
                          'keine Cloud-Speicherung, kein Server. Beim Aktualisieren '
                          'der Seite werden die Daten verworfen.'
                      : 'Processed locally in your browser only — no upload, no cloud '
                          'storage, no server. Reloading the page discards the data.',
                  style: const TextStyle(fontSize: 12.5, color: Color(0xFF047857), height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────── Header ─────────────────────────────

class _Header extends StatelessWidget {
  final bool hasData;
  final VoidCallback onClear;
  final InvoiceData? invoice;
  final WstData? wst;

  const _Header({
    required this.hasData,
    required this.onClear,
    required this.invoice,
    required this.wst,
  });

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';

    // The "week" is now purely informative and derived from the uploaded
    // files — there is no week picker and no roster lookup any more.
    final invStart = invoice?.periodStart ?? invoice?.minDate;
    final invEnd = invoice?.periodEnd ?? invoice?.maxDate;
    final wstStart = wst?.minDate;
    final wstEnd = wst?.maxDate;
    final start = invStart ?? wstStart;
    final end = invEnd ?? wstEnd;

    String subtitle;
    if (start == null || end == null) {
      subtitle = de
          ? 'Rechnung und WST-Export hochladen — der Zeitraum wird automatisch erkannt.'
          : 'Upload the invoice and the WST export — the period is detected automatically.';
    } else {
      final kw = invoice?.weekNumber;
      subtitle = de
          ? '${kw != null ? 'KW $kw · ' : ''}'
              '${formatDay(start)} – ${formatDay(end)}'
          : '${kw != null ? 'Week $kw · ' : ''}'
              '${formatDay(start, de: false)} – ${formatDay(end, de: false)}';
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _kAccent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Icons.fact_check_outlined,
                color: _kAccent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Payment Check',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: _kInk,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const _TagPill(
                      text: 'BETA',
                      fg: Color(0xFF0B8F6E),
                      bg: Color(0xFFD1FAE5),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12.5, color: _kMuted),
                ),
              ],
            ),
          ),
          if (hasData)
            TextButton.icon(
              onPressed: onClear,
              style: TextButton.styleFrom(foregroundColor: _kMuted),
              icon: const Icon(Icons.delete_sweep_outlined, size: 18),
              label: Text(
                de ? 'Daten verwerfen' : 'Discard data',
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 12.5),
              ),
            ),
        ],
      ),
    );
  }
}

// ───────────────────────── Shared column chrome ─────────────────────────

/// Shared card frame for a Payment Check column: title row + scrollable body.
class _ColumnCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final Widget child;
  const _ColumnCard({
    required this.icon,
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                Icon(icon, color: _kAccent, size: 19),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: _kInk,
                        fontSize: 14.5),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// Compact `label — value` row used in the recognised-summary blocks.
class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool strong;
  const _SummaryRow(this.label, this.value, {this.strong = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12.5, color: _kMuted),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: strong ? FontWeight.w900 : FontWeight.w700,
                color: _kInk,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 6),
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
            color: _kMuted,
          ),
        ),
      );
}

class _ErrorNote extends StatelessWidget {
  final String message;
  const _ErrorNote(this.message);
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline,
                color: Color(0xFFB91C1C), size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                    fontSize: 12.5, color: Color(0xFF991B1B), height: 1.35),
              ),
            ),
          ],
        ),
      );
}

// ── Column 1: Invoice (Amazon Gutschrift) ──

class _InvoiceColumn extends StatelessWidget {
  final InvoiceData? invoice;
  final String? fileName;
  final bool loading;
  final String? error;
  final VoidCallback onPick;

  const _InvoiceColumn({
    required this.invoice,
    required this.fileName,
    required this.loading,
    required this.error,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final inv = invoice;

    return _ColumnCard(
      icon: Icons.receipt_long_outlined,
      title: de ? '1 · Amazon-Rechnung' : '1 · Amazon invoice',
      trailing: inv == null
          ? null
          : IconButton(
              tooltip: de ? 'Andere Rechnung' : 'Different invoice',
              onPressed: onPick,
              icon: const Icon(Icons.autorenew, size: 18, color: _kMuted),
            ),
      child: loading
          ? const Center(child: CircularProgressIndicator(color: _kAccent))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _UploadZone(
                    hasFile: inv != null,
                    primary: inv != null
                        ? (fileName ?? '')
                        : (de
                            ? 'Rechnung auswählen (PDF)'
                            : 'Select invoice (PDF)'),
                    secondary: de
                        ? 'Amazon-Gutschrift als PDF'
                        : 'Amazon credit note as PDF',
                    onPick: onPick,
                  ),
                  if (error != null) _ErrorNote(error!),
                  if (inv != null) ..._summary(context, de, inv),
                ],
              ),
            ),
    );
  }

  List<Widget> _summary(BuildContext context, bool de, InvoiceData inv) {
    final start = inv.periodStart ?? inv.minDate;
    final end = inv.periodEnd ?? inv.maxDate;

    // Aggregate the detail table by description for a readable overview.
    final byDesc = <String, ({double qty, double sum})>{};
    for (final l in inv.lines) {
      final k = normText(l.description);
      final prev = byDesc[k];
      byDesc[k] = (
        qty: (prev?.qty ?? 0) + l.quantity,
        sum: (prev?.sum ?? 0) + l.total,
      );
    }
    final rows = byDesc.entries.toList()
      ..sort((a, b) => b.value.sum.compareTo(a.value.sum));

    return [
      _SectionLabel(de ? 'Erkannt' : 'Recognised'),
      _SummaryRow(
        de ? 'Zeitraum' : 'Period',
        (start == null || end == null)
            ? '—'
            : '${formatDay(start, de: de)} – ${formatDay(end, de: de)}',
      ),
      if (inv.weekNumber != null)
        _SummaryRow(de ? 'Kalenderwoche' : 'Calendar week',
            de ? 'KW ${inv.weekNumber}' : 'Week ${inv.weekNumber}'),
      if (inv.invoiceNumber != null)
        _SummaryRow(de ? 'Rechnungsnr.' : 'Invoice no.', inv.invoiceNumber!),
      _SummaryRow(de ? 'Positionen' : 'Positions', '${inv.lines.length}'),
      _SummaryRow(
        de ? 'Gesamtbetrag' : 'Grand total',
        inv.grandTotal == null ? '—' : _eur(inv.grandTotal!, de),
        strong: true,
      ),
      _SectionLabel(de ? 'Positionen (aggregiert)' : 'Positions (aggregated)'),
      for (final e in rows)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  e.key,
                  style: const TextStyle(fontSize: 12, color: _kInk, height: 1.3),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${_qtyLabel(e.value.qty)}×',
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w800, color: _kMuted),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 82,
                child: Text(
                  _eur(e.value.sum, de),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w800, color: _kInk),
                ),
              ),
            ],
          ),
        ),
    ];
  }
}

// ── Column 2: Work Summary Tool export / saved shift plan ──

class _WstColumn extends StatelessWidget {
  final WstData? wst;
  final List<String> fileNames;
  final bool loading;
  final String? error;
  final VoidCallback onPick;

  final _WstSource source;
  final ValueChanged<_WstSource> onSourceChanged;
  final ShiftPlanPaymentData? planData;
  final bool planLoading;
  final String? planError;
  final VoidCallback onPickPlan;

  const _WstColumn({
    required this.wst,
    required this.fileNames,
    required this.loading,
    required this.error,
    required this.onPick,
    required this.source,
    required this.onSourceChanged,
    required this.planData,
    required this.planLoading,
    required this.planError,
    required this.onPickPlan,
  });

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final isPlan = source == _WstSource.shiftPlan;
    final w = wst;
    final p = planData;

    final Widget body;
    if (isPlan) {
      body = planLoading
          ? const Center(child: CircularProgressIndicator(color: _kAccent))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _UploadZone(
                    hasFile: p != null,
                    primary: p != null
                        ? (de
                            ? 'Schichtplan geladen — ${p.days.length} '
                                '${p.days.length == 1 ? 'Tag' : 'Tage'}'
                            : 'Shift plan loaded — ${p.days.length} '
                                '${p.days.length == 1 ? 'day' : 'days'}')
                        : (de
                            ? 'Gespeicherten Schichtplan laden'
                            : 'Load saved shift plan'),
                    secondary: de
                        ? 'Aus „Speichern"/„Save week" — Entwurf zuerst, sonst '
                            'veröffentlichter Plan. Laden nur nach Bestätigung.'
                        : 'From "Save"/"Save week" — draft first, else the '
                            'published plan. Loads only after confirmation.',
                    onPick: onPickPlan,
                  ),
                  // Ablauf kurz erklaert (Ticket): Vortag hochladen,
                  // am Tag danach Cuts/Drops markieren.
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      de
                          ? 'So läuft es: Schichtplan am Vortag hochladen '
                              'und speichern. Am nächsten Tag im '
                              'Schichtplan markieren, welche Touren als '
                              '„Cut · Late Cancel" storniert oder von '
                              'DSP-Seite „Dropped" wurden — beides '
                              'erscheint hier im Abgleich.'
                          : 'How it works: upload and save the shift plan '
                              'the day before. The next day, mark in the '
                              'shift plan which tours were cancelled as '
                              '"Cut · late cancel" or "Dropped" by the '
                              'DSP — both show up here in the '
                              'reconciliation.',
                      style: const TextStyle(
                          fontSize: 11.5, color: _kMuted, height: 1.4),
                    ),
                  ),
                  if (planError != null) _ErrorNote(planError!),
                  if (p != null) ..._planSummary(de, p),
                ],
              ),
            );
    } else {
      body = loading
          ? const Center(child: CircularProgressIndicator(color: _kAccent))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _UploadZone(
                    hasFile: w != null,
                    primary: w != null
                        ? fileNames.join(', ')
                        : (de
                            ? 'WST-Export auswählen (ZIP oder CSVs)'
                            : 'Select WST export (ZIP or CSVs)'),
                    secondary: de
                        ? 'ZIP aus dem WST — oder Weekly Report & Package Report als CSV'
                        : 'ZIP from WST — or Weekly Report & Package Report as CSV',
                    onPick: onPick,
                  ),
                  // Kurz erklaert, wo der Export herkommt (Ticket).
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      de
                          ? 'WST = Work Summary-Tool: in Cortex '
                              '(logistics.amazon.de) in der Navigations'
                              'leiste. Bei vollendeter Woche dort den '
                              'Button „Wöchentlicher Export" nutzen und '
                              'die Datei hier hochladen.'
                          : 'WST = Work Summary Tool: in Cortex '
                              '(logistics.amazon.de) in the navigation '
                              'bar. Once the week is complete, use the '
                              '"Weekly export" button there and upload '
                              'the file here.',
                      style: const TextStyle(
                          fontSize: 11.5, color: _kMuted, height: 1.4),
                    ),
                  ),
                  if (error != null) _ErrorNote(error!),
                  if (w != null) ..._summary(de, w),
                ],
              ),
            );
    }

    return _ColumnCard(
      icon: isPlan ? Icons.event_note_outlined : Icons.summarize_outlined,
      title: isPlan
          ? (de ? '2 · Schichtplan' : '2 · Shift plan')
          : '2 · Work Summary Tool',
      trailing: isPlan
          ? (p == null
              ? null
              : IconButton(
                  tooltip:
                      de ? 'Anderen Zeitraum laden' : 'Load different period',
                  onPressed: onPickPlan,
                  icon:
                      const Icon(Icons.autorenew, size: 18, color: _kMuted),
                ))
          : (w == null
              ? null
              : IconButton(
                  tooltip: de ? 'Anderen Export' : 'Different export',
                  onPressed: onPick,
                  icon:
                      const Icon(Icons.autorenew, size: 18, color: _kMuted),
                )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _SourceToggle(
              source: source,
              onChanged: onSourceChanged,
              de: de,
            ),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }

  /// Summary for the shift-plan source — mirrors the WST summary, but with
  /// plan-specific facts (drivers, cuts, ride-alongs) and clear notes about
  /// what the plan CANNOT provide (parcels, actually-driven counts).
  List<Widget> _planSummary(bool de, ShiftPlanPaymentData p) {
    final w = p.wst;
    final start = w.minDate;
    final end = w.maxDate;

    final routesByDay = <String, int>{};
    final dayOf = <String, DateTime>{};
    for (final r in w.routes) {
      routesByDay[dayKey(r.date)] =
          (routesByDay[dayKey(r.date)] ?? 0) + r.completed;
      dayOf[dayKey(r.date)] = r.date;
    }
    final days = dayOf.keys.toList()..sort();

    return [
      _SectionLabel(de ? 'Erkannt' : 'Recognised'),
      // Defaults sichtbar machen: der Plan kennt nur geplante Touren und
      // keine Pakete — beides klar sagen statt still anzunehmen.
      Container(
        margin: const EdgeInsets.only(top: 6, bottom: 4),
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF93C5FD)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline_rounded,
                size: 17, color: Color(0xFF1D4ED8)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                de
                    ? 'Vergleichsbasis sind GEPLANTE Touren aus dem Schichtplan '
                        '(je Block 1 Tour, Cuts ausgenommen). Paketzahlen '
                        'enthält der Plan nicht — der Paketabgleich entfällt.'
                    : 'The comparison uses PLANNED tours from the shift plan '
                        '(1 tour per block, cuts excluded). The plan has no '
                        'parcel counts — the parcel comparison is skipped.',
                style: const TextStyle(
                    fontSize: 11.5, color: Color(0xFF1E40AF), height: 1.35),
              ),
            ),
          ],
        ),
      ),
      _SummaryRow(
        de ? 'Zeitraum' : 'Period',
        (start == null || end == null)
            ? '—'
            : '${formatDay(start, de: de)} – ${formatDay(end, de: de)}',
      ),
      if (w.stations.isNotEmpty)
        _SummaryRow(de ? 'Station' : 'Station', w.stations.join('\n')),
      _SummaryRow(
        de ? 'Fahrer gesamt' : 'Total drivers',
        '${p.totalDrivers}',
      ),
      _SummaryRow(
        de ? 'Geplante Touren' : 'Planned tours',
        '${p.plannedRoutes}',
        strong: true,
      ),
      _SummaryRow(
        de ? 'Cuts (Late Cancel)' : 'Cuts (late cancel)',
        '${p.cutCount}',
      ),
      _SummaryRow(
        de ? 'Dropped (DSP)' : 'Dropped (DSP)',
        '${p.droppedCount}',
      ),
      _SummaryRow(
        de ? 'Ride-alongs' : 'Ride-alongs',
        '${p.rideAlongCount}',
      ),
      _SummaryRow(
        de ? 'DA Trainings (Tourencheck)' : 'DA trainings (tour check)',
        '${p.daTrainingsTotal}',
      ),
      _SummaryRow(
        de ? 'Geladene Tage' : 'Days loaded',
        w.filesUsed.isEmpty ? '—' : w.filesUsed.join('\n'),
      ),
      if (p.uncheckedDays.isNotEmpty)
        Container(
          margin: const EdgeInsets.only(top: 6),
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFDBA74)),
          ),
          child: Text(
            de
                ? 'Tourencheck fehlt für: '
                    '${p.uncheckedDays.map((d) => formatDay(d.date)).join(', ')} '
                    '— Cuts/Drops/Trainings dieser Tage sind evtl. '
                    'unvollständig.'
                : 'Tour check missing for: '
                    '${p.uncheckedDays.map((d) => formatDay(d.date, de: false)).join(', ')} '
                    '— cuts/drops/trainings for these days may be '
                    'incomplete.',
            style: const TextStyle(
              fontSize: 11.5,
              color: Color(0xFF92400E),
              height: 1.4,
            ),
          ),
        ),
      if (p.missingDayKeys.isNotEmpty)
        Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFCD34D)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  size: 17, color: Color(0xFFB45309)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  de
                      ? 'Ohne gespeicherten Plan: '
                          '${p.missingDayKeys.join(', ')}. Diese Tage fehlen '
                          'im Vergleich.'
                      : 'No saved plan for: '
                          '${p.missingDayKeys.join(', ')}. These days are '
                          'missing from the comparison.',
                  style: const TextStyle(
                      fontSize: 11.5, color: Color(0xFF92400E), height: 1.35),
                ),
              ),
            ],
          ),
        ),
      _SectionLabel(de ? 'Pro Tag' : 'Per day'),
      for (final k in days)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  formatDay(dayOf[k]!, de: de),
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700, color: _kInk),
                ),
              ),
              Text(
                de
                    ? '${routesByDay[k] ?? 0} geplante Touren'
                    : '${routesByDay[k] ?? 0} planned tours',
                style: const TextStyle(fontSize: 12, color: _kMuted),
              ),
            ],
          ),
        ),
    ];
  }

  List<Widget> _summary(bool de, WstData w) {
    final start = w.minDate;
    final end = w.maxDate;

    // Per-day roll-up so the operator can sanity-check the export at a glance.
    final routesByDay = <String, int>{};
    final dayOf = <String, DateTime>{};
    for (final r in w.routes) {
      routesByDay[dayKey(r.date)] = (routesByDay[dayKey(r.date)] ?? 0) + r.completed;
      dayOf[dayKey(r.date)] = r.date;
    }
    final pkgByDay = <String, int>{};
    for (final p in w.packages) {
      pkgByDay[dayKey(p.date)] = (pkgByDay[dayKey(p.date)] ?? 0) + p.delivered;
      dayOf[dayKey(p.date)] = p.date;
    }
    final days = dayOf.keys.toList()..sort();

    // Welche Report-Komponenten fehlen noch? Weekly = Routen,
    // Package = Pakete — beide kommen oft als getrennte Uploads.
    final missingRoutes = w.routes.isEmpty;
    final missingPackages = w.packages.isEmpty;

    return [
      _SectionLabel(de ? 'Erkannt' : 'Recognised'),
      if (missingRoutes || missingPackages)
        Container(
          margin: const EdgeInsets.only(top: 6, bottom: 4),
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF93C5FD)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 17, color: Color(0xFF1D4ED8)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  missingRoutes
                      ? (de
                          ? 'Noch keine Routen erkannt — lade zusätzlich den '
                              '„Weekly Report" hoch (Uploads ergänzen sich).'
                          : 'No routes recognised yet — also upload the '
                              '"Weekly Report" (uploads accumulate).')
                      : (de
                          ? 'Noch keine Pakete erkannt — lade zusätzlich den '
                              '„Package Report" hoch (Uploads ergänzen sich).'
                          : 'No parcels recognised yet — also upload the '
                              '"Package Report" (uploads accumulate).'),
                  style: const TextStyle(
                      fontSize: 11.5, color: Color(0xFF1E40AF), height: 1.35),
                ),
              ),
            ],
          ),
        ),
      _SummaryRow(
        de ? 'Zeitraum' : 'Period',
        (start == null || end == null)
            ? '—'
            : '${formatDay(start, de: de)} – ${formatDay(end, de: de)}',
      ),
      if (w.stations.isNotEmpty)
        _SummaryRow(de ? 'Station' : 'Station', w.stations.join('\n')),
      // The invoice is issued per station. Mixing several stations into one
      // reconciliation silently inflates the WST side against a single-station
      // invoice, so it has to be called out.
      if (w.stations.length > 1)
        Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFCD34D)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  size: 17, color: Color(0xFFB45309)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  de
                      ? 'Der Export enthält ${w.stations.length} Stationen. Die '
                          'Rechnung gilt in der Regel nur für eine Station — '
                          'bitte prüfen, ob der Abgleich so gewollt ist.'
                      : 'The export covers ${w.stations.length} stations. An '
                          'invoice usually applies to a single station — please '
                          'check whether this comparison is intended.',
                  style: const TextStyle(
                      fontSize: 11.5, color: Color(0xFF92400E), height: 1.35),
                ),
              ),
            ],
          ),
        ),
      _SummaryRow(
        de ? 'Routen gesamt' : 'Total routes',
        '${w.totalRoutes}',
        strong: true,
      ),
      _SummaryRow(
        de ? 'Pakete gesamt' : 'Total parcels',
        '${w.totalPackages}',
        strong: true,
      ),
      _SummaryRow(
        de ? 'Verwendete Dateien' : 'Files used',
        w.filesUsed.isEmpty ? '—' : w.filesUsed.join('\n'),
      ),
      if (w.filesIgnored.isNotEmpty)
        _SummaryRow(
          de ? 'Ignoriert' : 'Ignored',
          w.filesIgnored.join('\n'),
        ),
      _SectionLabel(de ? 'Pro Tag' : 'Per day'),
      for (final k in days)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  formatDay(dayOf[k]!, de: de),
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700, color: _kInk),
                ),
              ),
              Text(
                de
                    ? '${routesByDay[k] ?? 0} Routen'
                    : '${routesByDay[k] ?? 0} routes',
                style: const TextStyle(fontSize: 12, color: _kMuted),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 90,
                child: Text(
                  de
                      ? '${pkgByDay[k] ?? 0} Pakete'
                      : '${pkgByDay[k] ?? 0} parcels',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 12, color: _kMuted),
                ),
              ),
            ],
          ),
        ),
    ];
  }
}

/// Two-way segmented toggle: WST upload vs. saved shift plan.
class _SourceToggle extends StatelessWidget {
  final _WstSource source;
  final ValueChanged<_WstSource> onChanged;
  final bool de;
  const _SourceToggle({
    required this.source,
    required this.onChanged,
    required this.de,
  });

  @override
  Widget build(BuildContext context) {
    Widget seg({
      required _WstSource value,
      required IconData icon,
      required String label,
    }) {
      final selected = source == value;
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(9),
          onTap: () => onChanged(value),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: selected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(9),
              border: selected
                  ? Border.all(color: const Color(0xFFE2E8F0))
                  : null,
              boxShadow: selected
                  ? const [
                      BoxShadow(
                        color: Color(0x0F000000),
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    size: 15, color: selected ? _kAccent : _kMuted),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: selected ? _kInk : _kMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          seg(
            value: _WstSource.upload,
            icon: Icons.upload_file_outlined,
            label: de ? 'WTS-Upload' : 'WTS upload',
          ),
          const SizedBox(width: 3),
          seg(
            value: _WstSource.shiftPlan,
            icon: Icons.event_note_outlined,
            label: de ? 'Schichtplan' : 'Shift plan',
          ),
        ],
      ),
    );
  }
}

/// Confirmation dialog before a loaded shift plan is taken into the
/// comparison. Shows the range, the per-day sources and the driver count —
/// the range is read BEFORE this dialog, so the numbers are already known.
class _PlanConfirmDialog extends StatelessWidget {
  final ShiftPlanPaymentData data;
  final DateTimeRange range;
  final bool de;
  const _PlanConfirmDialog({
    required this.data,
    required this.range,
    required this.de,
  });

  @override
  Widget build(BuildContext context) {
    final singleDay = dayKey(range.start) == dayKey(range.end);
    final title = singleDay
        ? (de
            ? 'Gespeicherten Schichtplan vom '
                '${formatDay(range.start)} laden?'
            : 'Load the saved shift plan of '
                '${formatDay(range.start, de: false)}?')
        : (de
            ? 'Gespeicherte Schichtpläne '
                '${formatDay(range.start)} – ${formatDay(range.end)} laden?'
            : 'Load the saved shift plans '
                '${formatDay(range.start, de: false)} – '
                '${formatDay(range.end, de: false)}?');

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        title,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w900, color: _kInk),
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              de
                  ? '${data.totalDrivers} Fahrer · '
                      '${data.plannedRoutes} geplante Touren · '
                      '${data.cutCount} Cuts · '
                      '${data.droppedCount} Dropped · '
                      '${data.rideAlongCount} Ride-alongs · '
                      '${data.daTrainingsTotal} DA Trainings'
                  : '${data.totalDrivers} drivers · '
                      '${data.plannedRoutes} planned tours · '
                      '${data.cutCount} cuts · '
                      '${data.droppedCount} dropped · '
                      '${data.rideAlongCount} ride-alongs · '
                      '${data.daTrainingsTotal} DA trainings',
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w800, color: _kInk),
            ),
            const SizedBox(height: 10),
            for (final d in data.days)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Icon(
                      d.fromDraft
                          ? Icons.edit_note_outlined
                          : Icons.public_outlined,
                      size: 15,
                      color: _kMuted,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        '${formatDay(d.date, de: de)} · '
                        '${d.fromDraft ? (de ? 'Entwurf' : 'draft') : (de ? 'Veröffentlicht' : 'published')}',
                        style:
                            const TextStyle(fontSize: 12.5, color: _kInk),
                      ),
                    ),
                    Text(
                      de
                          ? '${d.driverCount} Fahrer'
                          : '${d.driverCount} drivers',
                      style: const TextStyle(fontSize: 12.5, color: _kMuted),
                    ),
                  ],
                ),
              ),
            if (data.missingDayKeys.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                de
                    ? 'Kein gespeicherter Schichtplan für: '
                        '${data.missingDayKeys.join(', ')}'
                    : 'No saved shift plan for: '
                        '${data.missingDayKeys.join(', ')}',
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFFB45309), height: 1.35),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(de ? 'Abbrechen' : 'Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: _kAccent),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(de ? 'Laden' : 'Load'),
        ),
      ],
    );
  }
}

// ── Column 3: Result — ONLY what is missing on the invoice ──

class _ResultColumn extends StatelessWidget {
  final ReconResult? result;
  final bool hasInvoice;
  final bool hasWst;

  /// `true` while the shift-plan source tab is active — switches a few
  /// labels and enables the marks section below.
  final bool fromShiftPlan;

  /// Cut / ride-along markings from the loaded shift plan; empty when the
  /// WST-upload source is active.
  final List<ShiftPlanMark> planMarks;

  /// Volle Plan-Daten (fuer DA-Trainings-Gegenueberstellung); null bei
  /// WST-Quelle.
  final ShiftPlanPaymentData? planData;

  const _ResultColumn({
    required this.result,
    required this.hasInvoice,
    required this.hasWst,
    this.fromShiftPlan = false,
    this.planMarks = const <ShiftPlanMark>[],
    this.planData,
  });

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final r = result;

    final Widget child;
    if (r == null && planMarks.isEmpty) {
      child = _Centered(
        icon: Icons.upload_file_outlined,
        title: de ? 'Noch nichts zu vergleichen' : 'Nothing to compare yet',
        subtitle: !hasInvoice && !hasWst
            ? (fromShiftPlan
                ? (de
                    ? 'Lade links die Amazon-Rechnung hoch und den '
                        'gespeicherten Schichtplan.'
                    : 'Upload the Amazon invoice and load the saved '
                        'shift plan on the left.')
                : (de
                    ? 'Lade links die Amazon-Rechnung und den WST-Export hoch.'
                    : 'Upload the Amazon invoice and the WST export on the left.'))
            : !hasInvoice
                ? (de
                    ? 'Es fehlt noch die Amazon-Rechnung.'
                    : 'The Amazon invoice is still missing.')
                : (fromShiftPlan
                    ? (de
                        ? 'Es fehlt noch der gespeicherte Schichtplan.'
                        : 'The saved shift plan is still missing.')
                    : (de
                        ? 'Es fehlt noch der WST-Export.'
                        : 'The WST export is still missing.')),
      );
    } else if (r == null) {
      // Plan geladen, Rechnung fehlt noch: die Markierungen (Cuts /
      // Ride-alongs) sind trotzdem schon sichtbar.
      child = SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Centered(
              icon: Icons.upload_file_outlined,
              title:
                  de ? 'Noch nichts zu vergleichen' : 'Nothing to compare yet',
              subtitle: de
                  ? 'Es fehlt noch die Amazon-Rechnung — die Markierungen '
                      'aus dem Schichtplan stehen schon unten.'
                  : 'The Amazon invoice is still missing — the shift-plan '
                      'markings are already listed below.',
            ),
            const SizedBox(height: 8),
            _SectionLabel(de
                ? 'Markierungen aus dem Schichtplan'
                : 'Markings from the shift plan'),
            _PlanMarksSection(
                marks: planMarks, result: null, de: de, planData: planData),
          ],
        ),
      );
    } else {
      child = SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!r.periodsOverlap)
              _OverlapWarning(
                result: r,
                de: de,
                unknown: !r.periodsKnown,
              ),
            // Tagesdetails: vollständige Übersicht je Tag (alle
            // Touren beider Seiten + Pakete), nicht nur Fehlendes.
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => _DailyDetailsDialog(result: r, de: de),
                ),
                icon: const Icon(Icons.calendar_view_day_outlined, size: 17),
                label: Text(
                  de ? 'Tagesdetails' : 'Daily details',
                  style: const TextStyle(
                      fontSize: 12.5, fontWeight: FontWeight.w800),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF067647),
                  side: const BorderSide(color: Color(0xFFD1D5DB)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (r.isComplete)
              _AllCompleteCard(de: de)
            else ...[
              _MissingSummary(result: r, de: de),
              if (r.missingRoutes.isNotEmpty) ...[
                _SectionLabel(de ? 'Fehlende Routen' : 'Missing routes'),
                _MissingRoutesTable(rows: r.missingRoutes, de: de),
              ],
              if (r.missingPackages.isNotEmpty) ...[
                _SectionLabel(de ? 'Fehlende Pakete' : 'Missing parcels'),
                _MissingPackagesTable(rows: r.missingPackages, de: de),
              ],
            ],
            // Markierungen aus dem Schichtplan (nur Schichtplan-Quelle):
            // Cuts (Late Cancel) und Ride-alongs — inkl. Gegenüberstellung
            // mit den Late-Cancel-Positionen der Rechnung.
            if (fromShiftPlan && planMarks.isNotEmpty) ...[
              _SectionLabel(de
                  ? 'Markierungen aus dem Schichtplan'
                  : 'Markings from the shift plan'),
              _PlanMarksSection(
                  marks: planMarks, result: r, de: de, planData: planData),
            ],
            // Bezahlt, aber nicht Teil des Routen-Abgleichs:
            // Late Cancels & Co. plus die Per-Shipment-Gebühren —
            // mit Anzahl und Betrag, damit die Rechnung vollständig
            // nachvollziehbar ist.
            if (r.paidExtras.isNotEmpty) ...[
              _SectionLabel(fromShiftPlan
                  ? (de
                      ? 'Weitere bezahlte Positionen (ohne Tourenbezug)'
                      : 'Other paid items (no tour counterpart)')
                  : (de
                      ? 'Weitere bezahlte Positionen (ohne WST-Routenbezug)'
                      : 'Other paid items (no WST route counterpart)')),
              _PaidExtrasTable(items: r.paidExtras, de: de),
            ],
          ],
        ),
      );
    }

    return _ColumnCard(
      icon: Icons.rule_folder_outlined,
      title: de ? '3 · Fehlt auf der Rechnung' : '3 · Missing on the invoice',
      child: child,
    );
  }
}

/// "Markierungen aus dem Schichtplan": one row per Cut (Late Cancel, mit
/// Grund) und Ride-along (mit Mentee-Name), plus — wenn eine Rechnung
/// geladen ist — die Gegenüberstellung Cuts im Plan vs. bezahlte
/// Late-Cancel-Positionen auf der Rechnung.
class _PlanMarksSection extends StatelessWidget {
  final List<ShiftPlanMark> marks;
  final ReconResult? result;
  final bool de;

  /// Fuer die DA-Trainings-Gegenueberstellung (Tourencheck).
  final ShiftPlanPaymentData? planData;

  const _PlanMarksSection({
    required this.marks,
    required this.result,
    required this.de,
    this.planData,
  });

  @override
  Widget build(BuildContext context) {
    final cuts = marks.where((m) => m.isLateCancel).length;

    // Bezahlte Late-Cancel-Positionen der Rechnung (paidExtras) aufsummieren
    // — Beschreibungen wie "AMZL Late Cancel".
    double? invoiceLateCancelQty;
    final r = result;
    if (r != null) {
      invoiceLateCancelQty = r.paidExtras
          .where((e) => normKey(e.description).contains('late cancel'))
          .fold<double>(0, (acc, e) => acc + e.quantity);
    }
    final qtyLabel = invoiceLateCancelQty == null
        ? null
        : _qtyLabel(invoiceLateCancelQty);
    final cutsMatch = invoiceLateCancelQty != null &&
        invoiceLateCancelQty.round() == cuts;

    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final m in marks) ...[
            if (m.isLateCancel)
              _markRow(
                icon: Icons.content_cut,
                iconColor: const Color(0xFFB42318),
                date: m.date,
                driver: m.driverName,
                badge: m.lateCancelReason.trim().isEmpty
                    ? (de ? 'Cut · Late Cancel' : 'Cut · late cancel')
                    : (de
                        ? 'Cut · Late Cancel — ${m.lateCancelReason.trim()}'
                        : 'Cut · late cancel — ${m.lateCancelReason.trim()}'),
                badgeColor: const Color(0xFFB42318),
                detail: m.serviceSummary,
              ),
            if (m.isDropped)
              _markRow(
                icon: Icons.remove_circle_outline,
                iconColor: const Color(0xFFB45309),
                date: m.date,
                driver: m.driverName,
                badge: m.droppedReason.trim().isEmpty
                    ? (de ? 'Dropped (DSP)' : 'Dropped (DSP)')
                    : 'Dropped (DSP) — ${m.droppedReason.trim()}',
                badgeColor: const Color(0xFFB45309),
                detail: m.serviceSummary,
              ),
            if (m.isRideAlong)
              _markRow(
                icon: Icons.group_outlined,
                iconColor: const Color(0xFF1D4ED8),
                date: m.date,
                driver: m.driverName,
                badge: m.menteeName.trim().isEmpty
                    ? 'Ride along'
                    : 'Ride along · ${m.menteeName.trim()}',
                badgeColor: const Color(0xFF1D4ED8),
                detail: m.serviceSummary,
              ),
          ],
          if (qtyLabel != null && (cuts > 0 || invoiceLateCancelQty! > 0)) ...[
            const Divider(height: 14, color: Color(0xFFE5E7EB)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  cutsMatch
                      ? Icons.check_circle_outline
                      : Icons.warning_amber_rounded,
                  size: 16,
                  color: cutsMatch
                      ? const Color(0xFF067647)
                      : const Color(0xFFB45309),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    de
                        ? 'Cuts im Schichtplan: $cuts · Bezahlte '
                            'Late-Cancel-Positionen auf der Rechnung: '
                            '$qtyLabel ×'
                            '${cutsMatch ? '' : ' — bitte prüfen.'}'
                        : 'Cuts in the shift plan: $cuts · Paid late-cancel '
                            'positions on the invoice: $qtyLabel ×'
                            '${cutsMatch ? '' : ' — please check.'}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                      color: cutsMatch
                          ? const Color(0xFF067647)
                          : const Color(0xFF92400E),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (planData != null && planData!.daTrainingsTotal > 0) ...[
            const Divider(height: 14, color: Color(0xFFE5E7EB)),
            Builder(builder: (context) {
              final trainings = planData!.daTrainingsTotal;
              double? invoiceTrainingQty;
              final rr = result;
              if (rr != null) {
                invoiceTrainingQty = rr.paidExtras
                    .where((e) => normKey(e.description).contains('training'))
                    .fold<double>(0, (acc, e) => acc + e.quantity);
              }
              final match = invoiceTrainingQty != null &&
                  invoiceTrainingQty.round() == trainings;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    invoiceTrainingQty == null
                        ? Icons.school_outlined
                        : match
                            ? Icons.check_circle_outline
                            : Icons.warning_amber_rounded,
                    size: 16,
                    color: invoiceTrainingQty == null
                        ? _kMuted
                        : match
                            ? const Color(0xFF067647)
                            : const Color(0xFFB45309),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      invoiceTrainingQty == null
                          ? (de
                              ? 'DA Trainings laut Tourencheck: $trainings'
                              : 'DA trainings per tour check: $trainings')
                          : (de
                              ? 'DA Trainings laut Tourencheck: $trainings · '
                                  'Bezahlte Training-Positionen auf der '
                                  'Rechnung: ${_qtyLabel(invoiceTrainingQty)} ×'
                                  '${match ? '' : ' — bitte prüfen.'}'
                              : 'DA trainings per tour check: $trainings · '
                                  'Paid training positions on the invoice: '
                                  '${_qtyLabel(invoiceTrainingQty)} ×'
                                  '${match ? '' : ' — please check.'}'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                        color: invoiceTrainingQty == null
                            ? _kMuted
                            : match
                                ? const Color(0xFF067647)
                                : const Color(0xFF92400E),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
          if (marks.any((m) => m.isDropped)) ...[
            const SizedBox(height: 6),
            Text(
              de
                  ? 'Dropped-Touren wurden von DSP-Seite zurückgegeben — sie '
                      'zählen weder als Tour noch als Late-Cancel-Position.'
                  : 'Dropped tours were given back by the DSP — they count '
                      'neither as a tour nor as a late-cancel position.',
              style: const TextStyle(
                  fontSize: 11, color: _kMuted, height: 1.35),
            ),
          ],
          if (marks.any((m) => m.isRideAlong)) ...[
            const SizedBox(height: 6),
            Text(
              de
                  ? 'Ride-alongs zählen nicht als eigene Tour — der Mentee '
                      'fährt im Fahrzeug des Mentors mit.'
                  : 'Ride-alongs do not count as their own tour — the mentee '
                      'rides in the mentor\'s van.',
              style: const TextStyle(
                  fontSize: 11, color: _kMuted, height: 1.35),
            ),
          ],
        ],
      ),
    );
  }

  Widget _markRow({
    required IconData icon,
    required Color iconColor,
    required DateTime date,
    required String driver,
    required String badge,
    required Color badgeColor,
    required String detail,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: iconColor),
          const SizedBox(width: 8),
          SizedBox(
            width: 76,
            child: Text(
              formatDay(date, de: de),
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: _kInk),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver.trim().isEmpty ? '—' : driver.trim(),
                  style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: _kInk),
                ),
                Text(
                  badge,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: badgeColor,
                    height: 1.3,
                  ),
                ),
                if (detail.trim().isNotEmpty)
                  Text(
                    detail,
                    style: const TextStyle(
                        fontSize: 11, color: _kMuted, height: 1.3),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tabelle der bezahlten Positionen außerhalb des Routen-Abgleichs —
/// je Zeile Beschreibung, Menge und Betrag, unten die Summe.
class _PaidExtrasTable extends StatelessWidget {
  final List<PaidExtraItem> items;
  final bool de;
  const _PaidExtrasTable({required this.items, required this.de});

  String _qty(double q) {
    final isInt = q == q.roundToDouble();
    final s = isInt ? q.round().toString() : q.toStringAsFixed(1);
    return de ? s.replaceAll('.', ',') : s;
  }

  @override
  Widget build(BuildContext context) {
    final total = items.fold<double>(0, (acc, e) => acc + e.amount);
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          for (final e in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      e.description,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF374151), height: 1.3),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${_qty(e.quantity)} ×',
                    style: const TextStyle(fontSize: 12, color: _kMuted),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 84,
                    child: Text(
                      _eur(e.amount, de),
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const Divider(height: 14, color: Color(0xFFE5E7EB)),
          Row(
            children: [
              Expanded(
                child: Text(
                  de ? 'Summe' : 'Total',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w800, color: _kMuted),
                ),
              ),
              Text(
                _eur(total, de),
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverlapWarning extends StatelessWidget {
  final ReconResult result;
  final bool de;

  /// `true` when at least one side yielded no date range at all — then we
  /// cannot claim the weeks mismatch, only that we could not verify them.
  final bool unknown;

  const _OverlapWarning({
    required this.result,
    required this.de,
    required this.unknown,
  });

  @override
  Widget build(BuildContext context) {
    String range(DateTime? a, DateTime? b) =>
        (a == null || b == null) ? '—' : '${formatDay(a, de: de)} – ${formatDay(b, de: de)}';
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xFFFCD34D)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Color(0xFFB45309), size: 20),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  unknown
                      ? (de ? 'Zeitraum unklar' : 'Period unclear')
                      : (de
                          ? 'Zeiträume überschneiden sich nicht'
                          : 'Periods do not overlap'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  unknown
                      ? (de
                          ? 'Rechnung: ${range(result.invoiceStart, result.invoiceEnd)} · '
                              'WST: ${range(result.wstStart, result.wstEnd)}. '
                              'Mindestens ein Zeitraum konnte nicht gelesen werden — '
                              'ob beide Dateien zur selben Woche gehören, ist nicht geprüft.'
                          : 'Invoice: ${range(result.invoiceStart, result.invoiceEnd)} · '
                              'WST: ${range(result.wstStart, result.wstEnd)}. '
                              'At least one period could not be read — whether both files '
                              'belong to the same week is unverified.')
                      : (de
                          ? 'Rechnung: ${range(result.invoiceStart, result.invoiceEnd)} · '
                              'WST: ${range(result.wstStart, result.wstEnd)}. '
                              'Vermutlich gehören die beiden Dateien zu verschiedenen Wochen.'
                          : 'Invoice: ${range(result.invoiceStart, result.invoiceEnd)} · '
                              'WST: ${range(result.wstStart, result.wstEnd)}. '
                              'The two files are probably from different weeks.'),
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF92400E), height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AllCompleteCard extends StatelessWidget {
  final bool de;
  const _AllCompleteCard({required this.de});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kAccent.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          const Icon(Icons.verified_outlined, color: _kAccent, size: 40),
          const SizedBox(height: 12),
          Text(
            de ? 'Alles vollständig' : 'Everything complete',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 17,
              color: Color(0xFF065F46),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            de
                ? 'Jede vom WST gemeldete Route und jedes Paket ist auf der '
                    'Rechnung enthalten. Es fehlt nichts.'
                : 'Every route and every parcel reported by WST appears on the '
                    'invoice. Nothing is missing.',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 13, color: Color(0xFF047857), height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _MissingSummary extends StatelessWidget {
  final ReconResult result;
  final bool de;
  const _MissingSummary({required this.result, required this.de});

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    if (result.totalMissingRoutes > 0) {
      parts.add(de
          ? '${result.totalMissingRoutes} Routen'
          : '${result.totalMissingRoutes} routes');
    }
    if (result.totalMissingPackages > 0) {
      // The parcel COUNT is per parcel, not per fee line — a parcel can carry
      // both the plain and the branding fee. The amount does cover both.
      final kinds = result.missingPackageFeeKinds;
      final feeHint = kinds > 1
          ? (de ? ' ($kinds Gebühren je Paket)' : ' ($kinds fees per parcel)')
          : '';
      parts.add(de
          ? '${result.totalMissingPackages} Pakete$feeHint'
          : '${result.totalMissingPackages} parcels$feeHint');
    }
    parts.add(_eur(result.totalMissingAmount, de));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.report_problem_outlined,
              color: Color(0xFFB91C1C), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  de ? 'Fehlend gesamt' : 'Total missing',
                  style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                      color: Color(0xFF991B1B)),
                ),
                const SizedBox(height: 3),
                Text(
                  parts.join(' · '),
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF7F1D1D)),
                ),
                if (result.hasAnyPriceGap) ...[
                  const SizedBox(height: 4),
                  Text(
                    de
                        ? 'Für einzelne Positionen gibt es keinen Stückpreis auf der '
                            'Rechnung — diese sind im Betrag nicht enthalten.'
                        : 'Some positions have no unit price on the invoice — they '
                            'are not included in the amount.',
                    style: const TextStyle(
                        fontSize: 11.5, color: Color(0xFF991B1B), height: 1.3),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MissingRoutesTable extends StatelessWidget {
  final List<MissingRouteRow> rows;
  final bool de;
  const _MissingRoutesTable({required this.rows, required this.de});

  @override
  Widget build(BuildContext context) {
    return _DataTableFrame(
      headers: de
          ? const ['Datum', 'Servicetyp', 'WST', 'Rechnung', 'Diff.', 'Fehlt']
          : const ['Date', 'Service type', 'WST', 'Invoice', 'Diff.', 'Missing'],
      flex: const [3, 8, 2, 2, 2, 3],
      rows: [
        for (final r in rows)
          [
            formatDay(r.date, de: de),
            '${r.serviceType} · ${r.hours} '
                '${de ? 'Std.' : 'hrs'}',
            '${r.wstCount}',
            '${r.invoiceCount}',
            '+${r.diff}',
            r.missingAmount == null
                ? '—'
                : '${_eur(r.missingAmount!, de)}${r.priceIsFallback ? '*' : ''}',
          ],
      ],
      note: rows.any((r) => r.priceIsFallback)
          ? (de
              ? '* Stückpreis eines gleichartigen Blocks derselben Dauer, da dieser '
                  'Servicetyp nicht auf der Rechnung steht.'
              : '* Unit price borrowed from a comparable block of the same duration, '
                  'because this service type is not on the invoice.')
          : null,
    );
  }
}

class _MissingPackagesTable extends StatelessWidget {
  final List<MissingPackageRow> rows;
  final bool de;
  const _MissingPackagesTable({required this.rows, required this.de});

  @override
  Widget build(BuildContext context) {
    return _DataTableFrame(
      headers: de
          ? const ['Datum', 'Position', 'WST', 'Rechnung', 'Diff.', 'Fehlt']
          : const ['Date', 'Position', 'WST', 'Invoice', 'Diff.', 'Missing'],
      flex: const [3, 8, 2, 2, 2, 3],
      rows: [
        for (final r in rows)
          [
            formatDay(r.date, de: de),
            r.kind,
            '${r.wstCount}',
            '${r.invoiceCount}',
            '+${r.diff}',
            r.missingAmount == null ? '—' : _eur(r.missingAmount!, de),
          ],
      ],
      note: null,
    );
  }
}

/// Lightweight table: header strip + rows, all column widths flex-based so the
/// result column stays readable at any width.
class _DataTableFrame extends StatelessWidget {
  final List<String> headers;
  final List<int> flex;
  final List<List<String>> rows;
  final String? note;

  const _DataTableFrame({
    required this.headers,
    required this.flex,
    required this.rows,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    Widget cell(String text, int f, {bool header = false, bool right = false}) =>
        Expanded(
          flex: f,
          child: Text(
            text,
            textAlign: right ? TextAlign.right : TextAlign.left,
            style: TextStyle(
              fontSize: header ? 10.5 : 12,
              fontWeight: header ? FontWeight.w900 : FontWeight.w600,
              letterSpacing: header ? 0.5 : 0,
              color: header ? _kMuted : _kInk,
              height: 1.3,
            ),
          ),
        );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            color: const Color(0xFFF8FAFC),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                for (var i = 0; i < headers.length; i++) ...[
                  cell(headers[i].toUpperCase(), flex[i],
                      header: true, right: i >= headers.length - 4),
                  if (i < headers.length - 1) const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          for (var rIdx = 0; rIdx < rows.length; rIdx++)
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < rows[rIdx].length; i++) ...[
                    cell(rows[rIdx][i], flex[i],
                        right: i >= rows[rIdx].length - 4),
                    if (i < rows[rIdx].length - 1) const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
          if (note != null)
            Container(
              width: double.infinity,
              color: const Color(0xFFF8FAFC),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                note!,
                style: const TextStyle(
                    fontSize: 11, color: _kMuted, height: 1.35),
              ),
            ),
        ],
      ),
    );
  }
}

/// Invoice positions without a WST counterpart are EXPECTED (Late Cancel and
/// friends). They are never listed as errors — only counted here.

// ───────────────────────────── Sub-widgets ─────────────────────────────

class _UploadZone extends StatelessWidget {
  final bool hasFile;
  final String primary;
  final String secondary;
  final VoidCallback onPick;

  const _UploadZone({
    required this.hasFile,
    required this.primary,
    required this.secondary,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onPick,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
        decoration: BoxDecoration(
          color: hasFile
              ? _kAccent.withValues(alpha: 0.06)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasFile ? _kAccent : const Color(0xFFCBD5E1),
            width: 1.4,
          ),
        ),
        child: Row(
          children: [
            Icon(
              hasFile ? Icons.check_circle : Icons.upload_file_outlined,
              color: hasFile ? _kAccent : _kMuted,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    primary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: _kInk),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    secondary,
                    style: const TextStyle(fontSize: 11.5, color: _kMuted, height: 1.3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  final String text;
  final Color fg;
  final Color bg;
  const _TagPill({required this.text, required this.fg, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: 9.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _Centered extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _Centered({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: _kMuted),
            const SizedBox(height: 14),
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: _kInk)),
            const SizedBox(height: 6),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: _kMuted, fontSize: 13.5)),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────── Formatting ─────────────────────────────

/// German uses a comma decimal separator, English a dot.
String _eur(double v, bool de) {
  final s = v.toStringAsFixed(2);
  return de ? '${s.replaceAll('.', ',')} €' : '$s €';
}

String _qtyLabel(double q) =>
    q == q.roundToDouble() ? q.toInt().toString() : q.toStringAsFixed(1);

/// Tagesdetail-Dialog: je Tag alle Touren (WST vs. Rechnung) und die
/// Paketzahlen — vollständige Ansicht, nicht nur Fehlendes.
class _DailyDetailsDialog extends StatelessWidget {
  final ReconResult result;
  final bool de;
  const _DailyDetailsDialog({required this.result, required this.de});

  @override
  Widget build(BuildContext context) {
    // Gruppierung nach Tag.
    final byDay = <String, List<DailyRouteDetail>>{};
    final dayDates = <String, DateTime>{};
    for (final r in result.dailyRoutes) {
      final k = dayKey(r.date);
      byDay.putIfAbsent(k, () => []).add(r);
      dayDates[k] = r.date;
    }
    final pkgByDay = <String, DailyPackageDetail>{};
    for (final p in result.dailyPackages) {
      pkgByDay[dayKey(p.date)] = p;
      dayDates.putIfAbsent(dayKey(p.date), () => p.date);
    }
    final days = dayDates.keys.toList()..sort();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 8, 8),
              child: Row(
                children: [
                  const Icon(Icons.calendar_view_day_outlined,
                      size: 19, color: Color(0xFF067647)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      de
                          ? 'Tagesdetails — Touren & Pakete'
                          : 'Daily details — routes & parcels',
                      style: const TextStyle(
                          fontSize: 15.5, fontWeight: FontWeight.w900),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
                children: [
                  for (final k in days) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 6),
                      child: Text(
                        formatDay(dayDates[k]!, de: de),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                    for (final r in byDay[k] ?? const <DailyRouteDetail>[])
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              r.matches
                                  ? Icons.check_circle_rounded
                                  : Icons.error_rounded,
                              size: 15,
                              color: r.matches
                                  ? const Color(0xFF067647)
                                  : const Color(0xFFB42318),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${r.serviceType} · ${r.hours} '
                                '${de ? 'Std.' : 'h'}',
                                style: const TextStyle(
                                    fontSize: 12.5,
                                    color: Color(0xFF374151),
                                    height: 1.3),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              de
                                  ? 'WST ${r.wstCount} · RG ${r.invoiceCount}'
                                  : 'WST ${r.wstCount} · INV ${r.invoiceCount}',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: r.matches
                                    ? const Color(0xFF067647)
                                    : const Color(0xFFB42318),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (pkgByDay[k] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 3, bottom: 2),
                        child: Row(
                          children: [
                            const Icon(Icons.inventory_2_outlined,
                                size: 14, color: _kMuted),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                de ? 'Pakete' : 'Parcels',
                                style: const TextStyle(
                                    fontSize: 12.5, color: _kMuted),
                              ),
                            ),
                            Text(
                              'WST ${pkgByDay[k]!.wstDelivered} · '
                              'VPS ${pkgByDay[k]!.invoiceVps} · '
                              'Branding ${pkgByDay[k]!.invoiceBranding}',
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF374151)),
                            ),
                          ],
                        ),
                      ),
                    // Tagessumme Touren.
                    Builder(builder: (context) {
                      final rows =
                          byDay[k] ?? const <DailyRouteDetail>[];
                      final wstSum = rows.fold<int>(
                          0, (acc, r) => acc + r.wstCount);
                      final invSum = rows.fold<int>(
                          0, (acc, r) => acc + r.invoiceCount);
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          de
                              ? 'Touren gesamt: WST $wstSum · Rechnung $invSum'
                              : 'Routes total: WST $wstSum · Invoice $invSum',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: wstSum == invSum
                                ? _kMuted
                                : const Color(0xFFB42318),
                          ),
                        ),
                      );
                    }),
                    const Divider(height: 18, color: Color(0xFFF3F4F6)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
