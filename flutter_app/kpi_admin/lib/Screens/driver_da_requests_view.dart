// lib/Screens/driver_da_requests_view.dart
//
// DA Requests — Fahrer können Anträge/Tickets stellen. Aktuell:
//   1. Vorschussantrag (Gehaltsvorschuss) — mit IBAN (vorbefüllt aus dem
//      Driver-Hub-Profil, sonst Eingabe + Speicherung), Zeitraum (nur
//      aktueller Monat), Pflicht-Hinweis "wird mit dem nächsten Gehalt
//      verrechnet", Unterschrift und generierter PDF-Quittung inkl.
//      EPC-QR-Code (Girocode) für das Onlinebanking des Admins.
//   2. Sonstiges Anliegen — Freitext-Ticket an den Admin.
//
// Storage: users/{dspUid}/da_requests/{id}
//   { type: 'advance'|'other', status: 'open'|'paid'|'done'|'rejected',
//     driverTransporterId, driverName, createdAt, ...
//     advance: amountCents, iban, periodFrom, periodTo, monthKey,
//              purpose, pdfBase64, pdfFilename }

import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:signature/signature.dart';

import '../localization/app_localizations.dart';
import 'driver_safety_training_page.dart' show kSignatureInkBlue;

class DriverDaRequestsView extends StatefulWidget {
  final String dspUid;
  final String driverTransporterId;
  final VoidCallback onBack;

  const DriverDaRequestsView({
    super.key,
    required this.dspUid,
    required this.driverTransporterId,
    required this.onBack,
  });

  @override
  State<DriverDaRequestsView> createState() => _DriverDaRequestsViewState();
}

class _DriverDaRequestsViewState extends State<DriverDaRequestsView> {
  static const _kText = Color(0xFF111827);
  static const _kMuted = Color(0xFF6B7280);
  static const _kGreen = Color(0xFF1D7F5A);

  bool get _de => Localizations.localeOf(context).languageCode == 'de';

  /// Übersetzung in der eingestellten App-Sprache (alle 11 Sprachen).
  String _t(String key) => AppLocalizations.of(context).t(key);
  String _tf(String key, Map<String, String> params) =>
      AppLocalizations.of(context).tf(key, params);

  CollectionReference<Map<String, dynamic>> get _col => FirebaseFirestore
      .instance
      .collection('users')
      .doc(widget.dspUid)
      .collection('da_requests');

  DocumentReference<Map<String, dynamic>> get _driverRef => FirebaseFirestore
      .instance
      .collection('users')
      .doc(widget.dspUid)
      .collection('drivers')
      .doc(widget.driverTransporterId);

  @override
  Widget build(BuildContext context) {
    final de = _de;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: widget.onBack,
              icon: const Icon(Icons.arrow_back_rounded, color: _kText),
            ),
            Expanded(
              child: Text(
                'DA Requests',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: _kText,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            _t('da_req_subtitle'),
            style: const TextStyle(fontSize: 13, color: _kMuted),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _openAdvanceForm,
                icon: const Icon(Icons.euro_rounded, size: 18),
                label: Text(
                  _t('da_req_btn_advance'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: _kGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Freie Schicht beantragen — Secondary-Button: weiß mit
            // grünem Icon + Schrift. Datum + Grund, geht als Ticket an
            // den Admin.
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _openFreeShiftForm,
                icon: const Icon(Icons.event_busy_rounded,
                    size: 18, color: _kGreen),
                label: Text(
                  _t('da_req_btn_free_shift'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _kGreen,
                  side: const BorderSide(color: _kGreen),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _openOtherForm,
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
            label: Text(
              _t('da_req_btn_other'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: _kGreen,
              side: const BorderSide(color: _kGreen),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _col
                .where(
                  'driverTransporterId',
                  isEqualTo: widget.driverTransporterId,
                )
                .snapshots(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Center(
                  child: Text(
                    _t('da_req_load_failed'),
                    style: const TextStyle(color: _kMuted),
                  ),
                );
              }
              final docs = (snap.data?.docs ?? []).toList()
                ..sort((a, b) {
                  final ta = a.data()['createdAt'];
                  final tb = b.data()['createdAt'];
                  final da = ta is Timestamp ? ta.toDate() : DateTime(2000);
                  final db = tb is Timestamp ? tb.toDate() : DateTime(2000);
                  return db.compareTo(da);
                });
              if (docs.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _t('da_req_empty'),
                      style: const TextStyle(
                        color: _kMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.only(bottom: 110),
                itemCount: docs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) => _RequestTile(
                  data: docs[i].data(),
                  de: de,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Sonstiges Anliegen ────────────────────────────────────────────

  Future<void> _openOtherForm() async {
    final subjectCtrl = TextEditingController();
    final messageCtrl = TextEditingController();
    final sent = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(_t('da_req_btn_other')),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: subjectCtrl,
                decoration: InputDecoration(
                  labelText: _t('da_req_subject'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: messageCtrl,
                minLines: 4,
                maxLines: 8,
                decoration: InputDecoration(
                  labelText: _t('da_req_message'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(_t('da_req_cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(_t('da_req_send')),
          ),
        ],
      ),
    );
    if (sent != true || !mounted) return;
    final message = messageCtrl.text.trim();
    if (message.isEmpty) return;
    try {
      final driverSnap = await _driverRef.get();
      final driverName =
          (driverSnap.data()?['driverName'] ?? '').toString().trim();
      await _col.add({
        'type': 'other',
        'status': 'open',
        'driverTransporterId': widget.driverTransporterId,
        'driverName': driverName,
        'subject': subjectCtrl.text.trim(),
        'message': message,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t('da_req_sent'))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_tf('da_req_send_failed', {'error': '$e'})),
        ),
      );
    }
  }

  // ── Freie Schicht beantragen ──────────────────────────────────────
  //
  // Datum + Grund, geht als Ticket (type 'free_shift') an den Admin.

  Future<void> _openFreeShiftForm() async {
    final reasonCtrl = TextEditingController();
    DateTime? picked;
    final sent = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(_t('da_req_fs_title')),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _t('da_req_fs_hint'),
                  style: const TextStyle(fontSize: 13, color: _kMuted),
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: () async {
                    final now = DateTime.now();
                    final result = await showDatePicker(
                      context: ctx,
                      initialDate: picked ?? now.add(const Duration(days: 1)),
                      firstDate: now,
                      lastDate: now.add(const Duration(days: 365)),
                    );
                    if (result != null) {
                      setDialogState(() => picked = result);
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: _t('da_req_date'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon:
                          const Icon(Icons.calendar_today_outlined, size: 18),
                    ),
                    child: Text(
                      picked == null
                          ? _t('da_req_pick_date')
                          : DateFormat('dd.MM.yyyy').format(picked!),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: picked == null ? _kMuted : _kText,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: reasonCtrl,
                  minLines: 3,
                  maxLines: 6,
                  decoration: InputDecoration(
                    labelText: _t('da_req_reason'),
                    hintText: _t('da_req_reason_hint'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(_t('da_req_cancel')),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _kGreen,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(_t('da_req_send')),
            ),
          ],
        ),
      ),
    );
    if (sent != true || !mounted) return;
    final reason = reasonCtrl.text.trim();
    if (picked == null || reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t('da_req_fill_all'))),
      );
      return;
    }
    final date = picked!;
    try {
      final driverSnap = await _driverRef.get();
      final driverName =
          (driverSnap.data()?['driverName'] ?? '').toString().trim();
      final dateLabel = DateFormat('dd.MM.yyyy').format(date);
      await _col.add({
        'type': 'free_shift',
        'status': 'open',
        'driverTransporterId': widget.driverTransporterId,
        'driverName': driverName,
        'date': Timestamp.fromDate(DateTime(date.year, date.month, date.day)),
        'dateLabel': dateLabel,
        'reason': reason,
        // Fallback für generische Anzeigen (Admin-Liste, Alt-Clients).
        'subject': 'Free Shift · $dateLabel',
        'message': reason,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t('da_req_sent'))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_tf('da_req_send_failed', {'error': '$e'})),
        ),
      );
    }
  }

  // ── Vorschussantrag ───────────────────────────────────────────────

  Future<void> _openAdvanceForm() async {
    // Fahrer-Profil laden: Name, Personalnummer, IBAN (Vorbefüllung) —
    // und die Firmendaten des DSP für den Briefkopf der Quittung.
    Map<String, dynamic> driverData = const {};
    Map<String, dynamic> companyData = const {};
    try {
      final snap = await _driverRef.get();
      driverData = snap.data() ?? const {};
    } catch (_) {}
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.dspUid)
          .get();
      companyData = snap.data() ?? const {};
    } catch (_) {}
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _AdvanceFormPage(
          dspUid: widget.dspUid,
          driverTransporterId: widget.driverTransporterId,
          driverData: driverData,
          companyData: companyData,
          requestsCol: _col,
          driverRef: _driverRef,
        ),
      ),
    );
  }
}

// ── Antrag-Kachel in der Liste ───────────────────────────────────────

class _RequestTile extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool de;

  const _RequestTile({required this.data, required this.de});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).t;
    final type = (data['type'] ?? 'other').toString();
    final status = (data['status'] ?? 'open').toString();
    final createdAt = data['createdAt'];
    final created = createdAt is Timestamp
        ? DateFormat('dd.MM.yyyy').format(createdAt.toDate())
        : '';

    final isAdvance = type == 'advance';
    final isFreeShift = type == 'free_shift';
    final title = isAdvance
        ? t('da_req_type_advance')
        : isFreeShift
            ? '${t('da_req_type_free_shift')} · ${data['dateLabel'] ?? ''}'
            : ((data['subject'] ?? '').toString().trim().isEmpty
                ? t('da_req_type_other')
                : (data['subject'] ?? '').toString());

    String subtitle;
    if (isAdvance) {
      final cents = (data['amountCents'] as num?)?.toInt() ?? 0;
      final amount = (cents / 100).toStringAsFixed(2).replaceAll('.', ',');
      subtitle = '$amount EUR · ${data['periodLabel'] ?? ''}';
    } else if (isFreeShift) {
      subtitle = (data['reason'] ?? '').toString();
    } else {
      subtitle = (data['message'] ?? '').toString();
    }

    final (chipBg, chipFg, chipLabel) = switch (status) {
      'paid' => (
          const Color(0xFFE4F5EC),
          const Color(0xFF1D7F5A),
          t('da_req_status_paid'),
        ),
      'done' => (
          const Color(0xFFE4F5EC),
          const Color(0xFF1D7F5A),
          t('da_req_status_done'),
        ),
      'rejected' => (
          const Color(0xFFFEE2E2),
          const Color(0xFFB91C1C),
          t('da_req_status_rejected'),
        ),
      _ => (
          const Color(0xFFFFEDD5),
          const Color(0xFF9A3412),
          t('da_req_status_open'),
        ),
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE4F5EC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isAdvance
                  ? Icons.euro_rounded
                  : isFreeShift
                      ? Icons.event_busy_rounded
                      : Icons.chat_bubble_outline,
              color: const Color(0xFF1D7F5A),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                    color: Color(0xFF111827),
                  ),
                ),
                if (subtitle.trim().isNotEmpty)
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                if (created.isNotEmpty)
                  Text(
                    created,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: chipBg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              chipLabel,
              style: TextStyle(
                color: chipFg,
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Vorschuss-Formular (eigene Seite) ────────────────────────────────

class _AdvanceFormPage extends StatefulWidget {
  final String dspUid;
  final String driverTransporterId;
  final Map<String, dynamic> driverData;
  final Map<String, dynamic> companyData;
  final CollectionReference<Map<String, dynamic>> requestsCol;
  final DocumentReference<Map<String, dynamic>> driverRef;

  const _AdvanceFormPage({
    required this.dspUid,
    required this.driverTransporterId,
    required this.driverData,
    required this.companyData,
    required this.requestsCol,
    required this.driverRef,
  });

  @override
  State<_AdvanceFormPage> createState() => _AdvanceFormPageState();
}

class _AdvanceFormPageState extends State<_AdvanceFormPage> {
  static const _kText = Color(0xFF111827);
  static const _kMuted = Color(0xFF6B7280);
  static const _kGreen = Color(0xFF1D7F5A);

  final _amountCtrl = TextEditingController();
  late final TextEditingController _ibanCtrl;
  late final SignatureController _signatureCtrl;

  /// Monatsanker des Antrags (immer der laufende Monat).
  late DateTime _from;
  bool _acceptedDeduction = false;
  bool _submitting = false;
  late final bool _ibanWasPrefilled;

  bool get _de => Localizations.localeOf(context).languageCode == 'de';

  String get _driverName =>
      (widget.driverData['driverName'] ?? '').toString().trim();

  String get _employeeNumber =>
      (widget.driverData['employeeNumber'] ?? '').toString().trim();

  // ── Firmendaten aus dem DSP-Profil (Einstellungen → Firmendaten) ──
  String get _companyName => (widget.companyData['companyName'] ??
          widget.companyData['dspName'] ??
          '')
      .toString()
      .trim();
  String get _companyAddress =>
      (widget.companyData['companyAddress'] ?? '').toString().trim();
  String get _companyPhone =>
      (widget.companyData['companyPhone'] ?? '').toString().trim();
  String get _companyEmail =>
      (widget.companyData['email'] ?? '').toString().trim();

  @override
  void initState() {
    super.initState();
    final onboarding =
        (widget.driverData['onboarding'] as Map?)?.cast<String, dynamic>() ??
            const {};
    final iban = (onboarding['bankIban'] ?? '').toString().trim();
    _ibanWasPrefilled = iban.isNotEmpty;
    _ibanCtrl = TextEditingController(text: iban);
    _signatureCtrl = SignatureController(
      penStrokeWidth: 2.6,
      penColor: kSignatureInkBlue,
      exportBackgroundColor: Colors.white,
    );
    final now = DateTime.now();
    _from = DateTime(now.year, now.month, 1);
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _ibanCtrl.dispose();
    _signatureCtrl.dispose();
    super.dispose();
  }

  int? _parseAmountCents() {
    final raw = _amountCtrl.text.trim().replaceAll(' ', '').replaceAll(',', '.');
    if (raw.isEmpty) return null;
    final value = double.tryParse(raw);
    if (value == null || value <= 0 || value > 5000) return null;
    return (value * 100).round();
  }

  static String _fmtDate(DateTime d) => DateFormat('dd.MM.yyyy').format(d);

  /// Deutsche Monatsnamen ohne Locale-Initialisierung (intl braucht dafür
  /// initializeDateFormatting, das hier nicht garantiert ist).
  static const List<String> _monthNamesDe = [
    'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
    'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember',
  ];

  String get _monthLabel => '${_monthNamesDe[_from.month - 1]} ${_from.year}';

  /// Verwendungszweck für die Überweisung — bewusst immer gleich
  /// aufgebaut, damit die Buchung im Onlinebanking eindeutig zuzuordnen
  /// ist: „Vorschuss <Monat> <Jahr>".
  String get _purpose => 'Vorschuss $_monthLabel';

  Future<void> _submit() async {
    final de = _de;
    final cents = _parseAmountCents();
    if (cents == null) {
      _snack(de
          ? 'Bitte einen gültigen Betrag eingeben (max. 5000 EUR).'
          : 'Please enter a valid amount (max. 5000 EUR).');
      return;
    }
    final iban = _ibanCtrl.text.trim().replaceAll(' ', '').toUpperCase();
    if (iban.length < 15 || !iban.startsWith(RegExp(r'[A-Z]{2}'))) {
      _snack(de
          ? 'Bitte eine gültige IBAN eingeben.'
          : 'Please enter a valid IBAN.');
      return;
    }
    if (!_acceptedDeduction) {
      _snack(de
          ? 'Bitte bestätige den Hinweis zum Gehaltsabzug.'
          : 'Please confirm the salary deduction notice.');
      return;
    }
    if (_signatureCtrl.isEmpty) {
      _snack(de ? 'Bitte unterschreiben.' : 'Please sign.');
      return;
    }

    setState(() => _submitting = true);
    try {
      final signaturePng = await _signatureCtrl.toPngBytes();
      if (signaturePng == null) {
        throw Exception(de
            ? 'Unterschrift konnte nicht gelesen werden.'
            : 'Could not read signature.');
      }

      final pdfBytes = await _buildPdf(signaturePng, cents, iban);
      final monthKey = DateFormat('yyyy-MM').format(_from);
      final filename =
          'Vorschuss_${_driverName.isEmpty ? widget.driverTransporterId : _driverName.replaceAll(' ', '_')}'
          '_$monthKey.pdf';

      await widget.requestsCol.add({
        'type': 'advance',
        'status': 'open',
        'driverTransporterId': widget.driverTransporterId,
        'driverName': _driverName,
        'employeeNumber': _employeeNumber,
        'amountCents': cents,
        'iban': iban,
        'periodLabel': _monthLabel,
        'monthKey': monthKey,
        'purpose': _purpose,
        'pdfBase64': base64Encode(pdfBytes),
        'pdfFilename': filename,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // IBAN im Fahrer-Profil speichern, wenn neu oder geändert —
      // beim nächsten Antrag ist sie dann vorbefüllt.
      final onboarding = (widget.driverData['onboarding'] as Map?)
              ?.cast<String, dynamic>() ??
          const {};
      if ((onboarding['bankIban'] ?? '').toString().trim() != iban) {
        await widget.driverRef.set({
          'onboarding': {'bankIban': iban},
        }, SetOptions(merge: true));
      }

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF067647),
          content: Text(de
              ? 'Vorschussantrag gesendet.'
              : 'Advance request submitted.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _snack(de ? 'Senden fehlgeschlagen: $e' : 'Failed to submit: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  /// A4-Quittung: Kopf, Antragsdaten, Verwendungszweck, Girocode
  /// (EPC-QR — Banking-App scannt Empfänger, IBAN, Betrag, Zweck),
  /// Abzugs-Hinweis, Unterschrift.
  /// Ersetzt Zeichen, die die PDF-Standardschrift (Latin-1) nicht
  /// darstellen kann — sie erschienen sonst als leere Kästchen.
  static String _pdfSafe(String input) {
    const map = {
      '\u2013': '-', // – Halbgeviertstrich
      '\u2014': '-', // — Geviertstrich
      '\u2010': '-',
      '\u2011': '-',
      '\u2012': '-',
      '\u2018': "'",
      '\u2019': "'",
      '\u201A': ',',
      '\u201C': '"',
      '\u201D': '"',
      '\u201E': '"',
      '\u2026': '...',
      '\u00A0': ' ',
      '\u202F': ' ',
      '\u2009': ' ',
      '\u20AC': 'EUR',
      '\u2192': '->',
      '\u2022': '-',
      '\u2713': 'x',
      '\u2714': 'x',
    };
    var out = input;
    map.forEach((k, v) => out = out.replaceAll(k, v));
    // Alles, was darüber hinaus außerhalb von Latin-1 liegt, entfernen.
    out = out.replaceAll(RegExp(r'[^\u0000-\u00FF]'), '');
    return out;
  }

  Future<Uint8List> _buildPdf(
    Uint8List signaturePng,
    int cents,
    String iban,
  ) async {
    final doc = pw.Document();
    final amountText =
        (cents / 100).toStringAsFixed(2).replaceAll('.', ',');
    final amountEpc = (cents / 100).toStringAsFixed(2);
    final name =
        _driverName.isEmpty ? widget.driverTransporterId : _driverName;
    final monthName = _monthLabel;

    // EPC069-12 "Girocode" — Version 002, UTF-8, SEPA Credit Transfer.
    final epc = [
      'BCD',
      '002',
      '1',
      'SCT',
      '',
      name,
      iban,
      'EUR$amountEpc',
      '',
      '',
      _purpose,
    ].join('\n');

    final sigImage = pw.MemoryImage(signaturePng);

    pw.Widget row(String label, String value, {bool bold = false}) =>
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 3),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(
                width: 150,
                child: pw.Text(
                  _pdfSafe(label),
                  style: pw.TextStyle(
                    fontSize: 10.5,
                    color: PdfColors.grey700,
                  ),
                ),
              ),
              pw.Expanded(
                child: pw.Text(
                  _pdfSafe(value),
                  style: pw.TextStyle(
                    fontSize: 11.5,
                    fontWeight:
                        bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        );

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(48, 46, 48, 40),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Briefkopf mit den Firmendaten aus dem DSP-Profil
            if (_companyName.isNotEmpty ||
                _companyAddress.isNotEmpty ||
                _companyPhone.isNotEmpty) ...[
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.only(bottom: 8),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.grey400, width: 1),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (_companyName.isNotEmpty)
                      pw.Text(
                        _pdfSafe(_companyName),
                        style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    if (_companyAddress.isNotEmpty)
                      pw.Text(
                        _pdfSafe(_companyAddress),
                        style: const pw.TextStyle(
                          fontSize: 9.5,
                          color: PdfColors.grey700,
                          lineSpacing: 1.5,
                        ),
                      ),
                    if (_companyPhone.isNotEmpty || _companyEmail.isNotEmpty)
                      pw.Text(
                        _pdfSafe([
                          if (_companyPhone.isNotEmpty) 'Tel. $_companyPhone',
                          if (_companyEmail.isNotEmpty) _companyEmail,
                        ].join('  |  ')),
                        style: const pw.TextStyle(
                          fontSize: 9.5,
                          color: PdfColors.grey700,
                        ),
                      ),
                  ],
                ),
              ),
              pw.SizedBox(height: 14),
            ],
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Vorschussquittung',
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'Gehaltsvorschuss / Salary advance',
                      style: pw.TextStyle(
                        fontSize: 11,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
                pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: epc,
                  width: 86,
                  height: 86,
                ),
              ],
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              _pdfSafe(
                'Girocode: In der Banking-App scannen - Empfänger, IBAN, '
                'Betrag und Verwendungszweck werden automatisch übernommen.',
              ),
              style: pw.TextStyle(fontSize: 8.5, color: PdfColors.grey600),
            ),
            pw.SizedBox(height: 16),
            pw.Divider(color: PdfColors.grey400),
            pw.SizedBox(height: 8),
            if (_companyName.isNotEmpty) row('Arbeitgeber', _companyName),
            row('Mitarbeiter / Empfänger', name, bold: true),
            if (_employeeNumber.isNotEmpty)
              row('Personalnummer', _employeeNumber),
            row('Transporter-ID', widget.driverTransporterId),
            row('IBAN', iban, bold: true),
            row('Betrag', '$amountText EUR', bold: true),
            row('Für Monat', monthName),
            row('Verwendungszweck', _purpose, bold: true),
            row('Antragsdatum', _fmtDate(DateTime.now())),
            pw.SizedBox(height: 10),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Text(
                _pdfSafe(
                  'Hinweis: Der Vorschuss wird mit der nächsten '
                  'Gehaltsabrechnung ($monthName) verrechnet und in voller '
                  'Höhe vom Gehalt abgezogen.',
                ),
                style: const pw.TextStyle(fontSize: 10, lineSpacing: 2),
              ),
            ),
            pw.SizedBox(height: 26),
            pw.Text(
              _pdfSafe(
                'Hiermit beantrage und bestätige ich den oben genannten '
                'Gehaltsvorschuss sowie dessen Verrechnung mit meinem '
                'nächsten Gehalt.',
              ),
              style: const pw.TextStyle(fontSize: 10.5, lineSpacing: 2),
            ),
            pw.SizedBox(height: 18),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      width: 260,
                      height: 95,
                      alignment: pw.Alignment.bottomLeft,
                      child: pw.Image(sigImage, fit: pw.BoxFit.contain),
                    ),
                    pw.Container(
                      width: 280,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          top: pw.BorderSide(
                            color: PdfColors.grey600,
                            width: 0.8,
                          ),
                        ),
                      ),
                      padding: const pw.EdgeInsets.only(top: 4),
                      child: pw.Text(
                        _pdfSafe(
                          'Unterschrift Mitarbeiter | '
                          '${_fmtDate(DateTime.now())}',
                        ),
                        style: pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.Spacer(),
                pw.Text(
                  _companyName.isEmpty
                      ? 'Erstellt mit CoDriver'
                      : _pdfSafe('$_companyName  |  Erstellt mit CoDriver'),
                  style: pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    return doc.save();
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final de = _de;
    final now = DateTime.now();
    final monthName = _monthNamesDe[now.month - 1] + ' ${now.year}';

    InputDecoration deco(String label) => InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7F9),
        foregroundColor: _kText,
        elevation: 0,
        title: Text(
          de ? 'Vorschuss beantragen' : 'Request advance',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          children: [
            Text(
              de
                  ? 'Vorschüsse sind nur für den laufenden Monat '
                      '($monthName) möglich.'
                  : 'Advances are only possible for the current month '
                      '($monthName).',
              style: const TextStyle(fontSize: 13, color: _kMuted),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: deco(de ? 'Betrag (EUR)' : 'Amount (EUR)'),
            ),
            const SizedBox(height: 12),
            InputDecorator(
              decoration: deco(de ? 'Für Monat' : 'For month'),
              child: Row(
                children: [
                  const Icon(Icons.event_rounded, size: 17, color: _kMuted),
                  const SizedBox(width: 8),
                  Text(
                    monthName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _kText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ibanCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: deco('IBAN').copyWith(
                helperText: _ibanWasPrefilled
                    ? (de
                        ? 'Aus deinem Profil übernommen.'
                        : 'Taken from your profile.')
                    : (de
                        ? 'Wird für zukünftige Anträge gespeichert.'
                        : 'Will be saved for future requests.'),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFCD34D)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 18, color: Color(0xFF92400E)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      de
                          ? 'Der Vorschuss wird mit deiner nächsten '
                              'Gehaltsabrechnung verrechnet und vom Gehalt '
                              'abgezogen.'
                          : 'The advance will be settled with your next '
                              'payroll and deducted from your salary.',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF92400E),
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            CheckboxListTile(
              value: _acceptedDeduction,
              onChanged: (v) =>
                  setState(() => _acceptedDeduction = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              activeColor: _kGreen,
              title: Text(
                de
                    ? 'Ich bestätige die Verrechnung mit meinem nächsten '
                        'Gehalt.'
                    : 'I confirm the deduction from my next salary.',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _kText,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              de ? 'Unterschrift' : 'Signature',
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: _kText,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  SizedBox(
                    height: 230,
                    child: Signature(
                      controller: _signatureCtrl,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  Container(
                    color: const Color(0xFFF8FAFC),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () => _signatureCtrl.clear(),
                          icon: const Icon(Icons.refresh_rounded, size: 16),
                          label: Text(de ? 'Löschen' : 'Clear'),
                          style: TextButton.styleFrom(
                            foregroundColor: _kMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _submitting ? null : _submit,
              icon: _submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.send_rounded, size: 18),
              label: Text(
                _submitting
                    ? (de ? 'Wird gesendet…' : 'Submitting…')
                    : (de ? 'Antrag senden' : 'Submit request'),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: _kGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
