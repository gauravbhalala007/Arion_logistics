// lib/Screens/admin_da_requests_page.dart
//
// Admin-Ansicht der DA Requests (Fahrer-Anträge, u. a. Gehaltsvorschüsse).
// - Liste aller Anträge (Filter: Offen / Erledigt / Alle)
// - Vorschuss: PDF (mit Unterschrift + Girocode) öffnen/herunterladen,
//   danach "Als überwiesen markieren".
// - Sonstige Anliegen: als erledigt markieren.
//
// Storage: users/{adminUid}/da_requests/{id} — siehe
// driver_da_requests_view.dart für das Schema.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../widgets/admin_scope.dart';

class AdminDaRequestsPage extends StatefulWidget {
  const AdminDaRequestsPage({super.key});

  @override
  State<AdminDaRequestsPage> createState() => _AdminDaRequestsPageState();
}

enum _Filter { open, closed, all }

class _AdminDaRequestsPageState extends State<AdminDaRequestsPage> {
  static const _kText = Color(0xFF111827);
  static const _kMuted = Color(0xFF6B7280);
  static const _kGreen = Color(0xFF1D7F5A);

  _Filter _filter = _Filter.open;

  bool get _de => Localizations.localeOf(context).languageCode == 'de';

  String? get _uid =>
      AdminScope.adminUidOf(context) ?? FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    final de = _de;
    final uid = _uid;
    if (uid == null) {
      return Center(child: Text(de ? 'Bitte einloggen.' : 'Please sign in.'));
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DA Requests',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: _kText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  de
                      ? 'Anträge deiner Fahrer — Vorschüsse mit fertiger '
                          'PDF-Quittung (Unterschrift + Girocode fürs '
                          'Onlinebanking).'
                      : 'Requests from your drivers — advances come with a '
                          'ready PDF receipt (signature + Girocode for '
                          'online banking).',
                  style: const TextStyle(fontSize: 13.5, color: _kMuted),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    for (final (f, label) in [
                      (_Filter.open, de ? 'Offen' : 'Open'),
                      (_Filter.closed, de ? 'Erledigt' : 'Closed'),
                      (_Filter.all, de ? 'Alle' : 'All'),
                    ]) ...[
                      ChoiceChip(
                        label: Text(label),
                        selected: _filter == f,
                        onSelected: (_) => setState(() => _filter = f),
                        selectedColor: const Color(0xFFE4F5EC),
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                          color: _filter == f ? _kGreen : _kMuted,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .collection('da_requests')
                        .snapshots(),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snap.hasError) {
                        return Center(
                          child: Text(
                            de
                                ? 'Anträge konnten nicht geladen werden:\n'
                                    '${snap.error}'
                                : 'Could not load requests:\n${snap.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Color(0xFFB42318)),
                          ),
                        );
                      }
                      final all = (snap.data?.docs ?? []).toList()
                        ..sort((a, b) {
                          final ta = a.data()['createdAt'];
                          final tb = b.data()['createdAt'];
                          final da =
                              ta is Timestamp ? ta.toDate() : DateTime(2000);
                          final db =
                              tb is Timestamp ? tb.toDate() : DateTime(2000);
                          return db.compareTo(da);
                        });
                      final docs = all.where((d) {
                        final status =
                            (d.data()['status'] ?? 'open').toString();
                        return switch (_filter) {
                          _Filter.open => status == 'open',
                          _Filter.closed => status != 'open',
                          _Filter.all => true,
                        };
                      }).toList();
                      if (docs.isEmpty) {
                        return Center(
                          child: Text(
                            de ? 'Keine Anträge.' : 'No requests.',
                            style: const TextStyle(
                              color: _kMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }
                      return ListView.separated(
                        itemCount: docs.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, i) => _AdminRequestCard(
                          doc: docs[i],
                          de: de,
                          onMarkPaid: () => _updateStatus(
                            docs[i].reference,
                            'paid',
                          ),
                          onMarkDone: () => _updateStatus(
                            docs[i].reference,
                            'done',
                          ),
                          onReject: () => _updateStatus(
                            docs[i].reference,
                            'rejected',
                          ),
                          onOpenPdf: () => _openPdf(docs[i].data()),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _updateStatus(
    DocumentReference<Map<String, dynamic>> ref,
    String status,
  ) async {
    final de = _de;
    try {
      await ref.set({
        'status': status,
        if (status == 'paid') 'paidAt': FieldValue.serverTimestamp(),
        if (status == 'paid')
          'paidByUid': FirebaseAuth.instance.currentUser?.uid,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF067647),
          content: Text(
            status == 'paid'
                ? (de ? 'Als überwiesen markiert.' : 'Marked as paid.')
                : status == 'done'
                    ? (de ? 'Als erledigt markiert.' : 'Marked as done.')
                    : (de ? 'Abgelehnt.' : 'Rejected.'),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            de ? 'Aktualisierung fehlgeschlagen: $e' : 'Update failed: $e',
          ),
        ),
      );
    }
  }

  Future<void> _openPdf(Map<String, dynamic> data) async {
    final de = _de;
    final b64 = (data['pdfBase64'] ?? '').toString();
    if (b64.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(de ? 'Kein PDF vorhanden.' : 'No PDF available.'),
        ),
      );
      return;
    }
    try {
      final bytes = base64Decode(b64);
      final filename = (data['pdfFilename'] ?? 'Vorschuss.pdf').toString();
      // Web: löst einen Download aus; Mobile: Share-Sheet.
      await Printing.sharePdf(bytes: bytes, filename: filename);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            de ? 'PDF konnte nicht geöffnet werden: $e' : 'Could not open PDF: $e',
          ),
        ),
      );
    }
  }
}

class _AdminRequestCard extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;
  final bool de;
  final VoidCallback onMarkPaid;
  final VoidCallback onMarkDone;
  final VoidCallback onReject;
  final VoidCallback onOpenPdf;

  const _AdminRequestCard({
    required this.doc,
    required this.de,
    required this.onMarkPaid,
    required this.onMarkDone,
    required this.onReject,
    required this.onOpenPdf,
  });

  @override
  Widget build(BuildContext context) {
    final data = doc.data();
    final type = (data['type'] ?? 'other').toString();
    final status = (data['status'] ?? 'open').toString();
    final isAdvance = type == 'advance';
    final isFreeShift = type == 'free_shift';
    final driver = (data['driverName'] ?? '').toString().trim().isEmpty
        ? (data['driverTransporterId'] ?? '').toString()
        : (data['driverName'] ?? '').toString();
    final createdAt = data['createdAt'];
    final created = createdAt is Timestamp
        ? DateFormat('dd.MM.yyyy HH:mm').format(createdAt.toDate())
        : '';

    final (chipBg, chipFg, chipLabel) = switch (status) {
      'paid' => (
          const Color(0xFFE4F5EC),
          const Color(0xFF1D7F5A),
          de ? 'ÜBERWIESEN' : 'PAID',
        ),
      'done' => (
          const Color(0xFFE4F5EC),
          const Color(0xFF1D7F5A),
          de ? 'ERLEDIGT' : 'DONE',
        ),
      'rejected' => (
          const Color(0xFFFEE2E2),
          const Color(0xFFB91C1C),
          de ? 'ABGELEHNT' : 'REJECTED',
        ),
      _ => (
          const Color(0xFFFFEDD5),
          const Color(0xFF9A3412),
          de ? 'OFFEN' : 'OPEN',
        ),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isAdvance
                    ? Icons.euro_rounded
                    : isFreeShift
                        ? Icons.event_busy_rounded
                        : Icons.chat_bubble_outline,
                size: 18,
                color: const Color(0xFF1D7F5A),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isAdvance
                      ? (de
                          ? 'Gehaltsvorschuss · $driver'
                          : 'Salary advance · $driver')
                      : isFreeShift
                          ? (de
                              ? 'Freie Schicht · ${data['dateLabel'] ?? ''} · $driver'
                              : 'Free shift · ${data['dateLabel'] ?? ''} · $driver')
                          : '${(data['subject'] ?? '').toString().trim().isEmpty ? (de ? 'Anliegen' : 'Request') : data['subject']} · $driver',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
          const SizedBox(height: 10),
          if (isAdvance)
            Wrap(
              spacing: 16,
              runSpacing: 6,
              children: [
                _kv(
                  de ? 'Betrag' : 'Amount',
                  '${(((data['amountCents'] as num?)?.toInt() ?? 0) / 100).toStringAsFixed(2).replaceAll('.', ',')} EUR',
                ),
                _kv('IBAN', (data['iban'] ?? '—').toString()),
                _kv(
                  de ? 'Zeitraum' : 'Period',
                  (data['periodLabel'] ?? '—').toString(),
                ),
                _kv(
                  de ? 'Verwendungszweck' : 'Payment reference',
                  (data['purpose'] ?? '—').toString(),
                ),
                if ((data['employeeNumber'] ?? '').toString().isNotEmpty)
                  _kv(
                    de ? 'Personalnr.' : 'Employee ID',
                    (data['employeeNumber'] ?? '').toString(),
                  ),
              ],
            )
          else if (isFreeShift)
            Wrap(
              spacing: 16,
              runSpacing: 6,
              children: [
                _kv(
                  de ? 'Datum' : 'Date',
                  (data['dateLabel'] ?? '—').toString(),
                ),
                _kv(
                  de ? 'Grund' : 'Reason',
                  (data['reason'] ?? '—').toString(),
                ),
              ],
            )
          else
            Text(
              (data['message'] ?? '').toString(),
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFF334155),
                height: 1.4,
              ),
            ),
          if (created.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              created,
              style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
            ),
          ],
          const SizedBox(height: 12),
          // Free Shift: Freigabe bewusst per Swipe-Bestätigung (kein
          // versehentlicher Klick), darunter der Ablehnen-Button.
          if (isFreeShift && status == 'open') ...[
            // Beide Aktionen über die ganze Kachelbreite.
            SizedBox(
              width: double.infinity,
              child: _SlideToConfirm(
                label: de
                    ? 'Schieben zum Bestätigen'
                    : 'Slide to confirm',
                onConfirmed: onMarkDone,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onReject,
                icon: const Icon(Icons.close_rounded, size: 16),
                label: Text(de ? 'Ablehnen' : 'Reject'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFB91C1C),
                  side: const BorderSide(color: Color(0xFFFECACA)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ] else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (isAdvance)
                  OutlinedButton.icon(
                    onPressed: onOpenPdf,
                    icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                    label: Text(de ? 'PDF herunterladen' : 'Download PDF'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1D7F5A),
                      side: const BorderSide(color: Color(0xFF1D7F5A)),
                    ),
                  ),
                if (status == 'open' && isAdvance)
                  FilledButton.icon(
                    onPressed: onMarkPaid,
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: Text(
                      de ? 'Als überwiesen markieren' : 'Mark as paid',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1D7F5A),
                      foregroundColor: Colors.white,
                    ),
                  ),
                if (status == 'open' && !isAdvance)
                  FilledButton.icon(
                    onPressed: onMarkDone,
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label:
                        Text(de ? 'Als erledigt markieren' : 'Mark as done'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1D7F5A),
                      foregroundColor: Colors.white,
                    ),
                  ),
                if (status == 'open')
                  TextButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: Text(de ? 'Ablehnen' : 'Reject'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFB91C1C),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _kv(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
      ],
    );
  }
}

// ── Swipe-Bestätigung für Free-Shift-Freigaben ───────────────────────
//
// Gleiches Muster wie im Fahrer-Waveplan: Der Thumb muss bis ~85 % der
// Strecke gezogen werden, sonst springt er zurück — verhindert
// versehentliche Freigaben durch einen einzelnen Klick.
class _SlideToConfirm extends StatefulWidget {
  final String label;
  final VoidCallback onConfirmed;

  const _SlideToConfirm({required this.label, required this.onConfirmed});

  @override
  State<_SlideToConfirm> createState() => _SlideToConfirmState();
}

class _SlideToConfirmState extends State<_SlideToConfirm> {
  static const double _trackHeight = 52;
  static const double _thumbSize = 44;
  static const _green = Color(0xFF1D7F5A);

  double _dragX = 0;
  bool _dragging = false;
  bool _confirmed = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxDrag =
            (constraints.maxWidth - _thumbSize - 8).clamp(0.0, double.infinity);
        final progress =
            maxDrag <= 0 ? 0.0 : (_dragX / maxDrag).clamp(0.0, 1.0);
        final active = !_confirmed;
        return GestureDetector(
          onHorizontalDragStart:
              active ? (_) => setState(() => _dragging = true) : null,
          onHorizontalDragUpdate: active
              ? (details) => setState(() {
                    _dragX = (_dragX + details.delta.dx).clamp(0.0, maxDrag);
                  })
              : null,
          onHorizontalDragEnd: active
              ? (_) {
                  setState(() => _dragging = false);
                  if (_dragX >= maxDrag * 0.85) {
                    setState(() {
                      _dragX = maxDrag;
                      _confirmed = true;
                    });
                    widget.onConfirmed();
                  } else {
                    setState(() => _dragX = 0);
                  }
                }
              : null,
          child: Container(
            height: _trackHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _green.withOpacity(0.08),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: _green.withOpacity(0.55), width: 1.2),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: _thumbSize + 8 + _dragX,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: _green.withOpacity(0.22 + 0.35 * progress),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: _thumbSize + 12),
                  child: Text(
                    widget.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _green,
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: _dragging
                      ? Duration.zero
                      : const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  left: 4 + _dragX,
                  top: (_trackHeight - _thumbSize) / 2,
                  child: Container(
                    width: _thumbSize,
                    height: _thumbSize,
                    decoration: const BoxDecoration(
                      color: _green,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _confirmed
                          ? Icons.check_rounded
                          : Icons.chevron_right_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
