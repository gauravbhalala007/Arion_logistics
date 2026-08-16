// lib/Screens/admin_safety_training_page.dart
//
// Admin-Übersicht der Sicherheitsunterweisung: welcher Fahrer ist
// aktuell unterwiesen, bei wem läuft die 12-Monats-Frist ab / ist
// abgelaufen, wer hat nie teilgenommen. Nachweis-PDF pro Fahrer
// direkt abrufbar (liegt zusätzlich im Drivers Hub als Dokument).
//
// Daten: users/{uid}/academy_test_results/safety_training/drivers/{tid}
//        + users/{uid}/drivers (aktive Fahrer).

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/safety_training/safety_training_data.dart';
import '../utils/driver_activity.dart';
import '../widgets/admin_scope.dart';

class AdminSafetyTrainingPage extends StatefulWidget {
  const AdminSafetyTrainingPage({super.key});

  @override
  State<AdminSafetyTrainingPage> createState() =>
      _AdminSafetyTrainingPageState();
}

enum _Filter { all, valid, dueSoon, expired, missing }

class _AdminSafetyTrainingPageState extends State<AdminSafetyTrainingPage> {
  static const _kText = Color(0xFF111827);
  static const _kMuted = Color(0xFF6B7280);
  static const _kGreen = Color(0xFF1D7F5A);

  _Filter _filter = _Filter.all;

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
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: userRef.collection('drivers').snapshots(),
              builder: (context, driverSnap) {
                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: userRef
                      .collection('academy_test_results')
                      .doc(kSafetyTrainingTestId)
                      .collection('drivers')
                      .snapshots(),
                  builder: (context, resultSnap) {
                    if (driverSnap.connectionState ==
                            ConnectionState.waiting ||
                        resultSnap.connectionState ==
                            ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final drivers = (driverSnap.data?.docs ?? [])
                        .where((d) => isDriverWorking(d.data()))
                        .toList();
                    final results = <String, Map<String, dynamic>>{
                      for (final d in resultSnap.data?.docs ?? [])
                        d.id.toUpperCase(): d.data(),
                    };
                    return _buildBody(de, drivers, results);
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    bool de,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> drivers,
    Map<String, Map<String, dynamic>> results,
  ) {
    final now = DateTime.now();
    final rows = <_Row>[];
    for (final d in drivers) {
      final data = d.data();
      final tid = (data['transporterId'] ?? d.id).toString().trim();
      final result = results[tid.toUpperCase()];
      DateTime? validUntil;
      final vu = result?['validUntil'];
      if (vu is Timestamp) validUntil = vu.toDate();
      final _RowStatus status;
      if (validUntil == null) {
        status = _RowStatus.missing;
      } else if (!validUntil.isAfter(now)) {
        status = _RowStatus.expired;
      } else if (validUntil.difference(now).inDays <= 30) {
        status = _RowStatus.dueSoon;
      } else {
        status = _RowStatus.valid;
      }
      rows.add(_Row(
        tid: tid,
        name: (data['driverName'] ?? tid).toString(),
        employeeNumber: (data['employeeNumber'] ?? '').toString().trim(),
        validUntil: validUntil,
        status: status,
        certificateUrl: (result?['certificateUrl'] ?? '').toString(),
        score: (result?['score'] as num?)?.toInt(),
        total: (result?['total'] as num?)?.toInt(),
      ));
    }
    rows.sort((a, b) {
      final byStatus = a.status.index.compareTo(b.status.index);
      if (byStatus != 0) return -byStatus; // missing/expired zuerst
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    int count(_RowStatus s) => rows.where((r) => r.status == s).length;

    final filtered = rows.where((r) {
      return switch (_filter) {
        _Filter.all => true,
        _Filter.valid => r.status == _RowStatus.valid,
        _Filter.dueSoon => r.status == _RowStatus.dueSoon,
        _Filter.expired => r.status == _RowStatus.expired,
        _Filter.missing => r.status == _RowStatus.missing,
      };
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          de ? 'Sicherheitsunterweisung' : 'Safety Instruction',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: _kText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          de
              ? 'Jährliche Unterweisung gem. § 12 ArbSchG / § 4 DGUV V1 — '
                  'Status aller aktiven Fahrer. Nachweise liegen zusätzlich '
                  'im Drivers Hub beim jeweiligen Fahrer.'
              : 'Annual instruction per § 12 ArbSchG / § 4 DGUV V1 — status '
                  'of all active drivers. Certificates are also filed with '
                  'each driver in the Drivers Hub.',
          style: const TextStyle(fontSize: 13.5, color: _kMuted),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (f, label, color) in [
              (_Filter.all, de ? 'Alle (${rows.length})' : 'All (${rows.length})', _kMuted),
              (
                _Filter.valid,
                de
                    ? 'Aktuell (${count(_RowStatus.valid)})'
                    : 'Valid (${count(_RowStatus.valid)})',
                _kGreen
              ),
              (
                _Filter.dueSoon,
                de
                    ? 'Läuft ab (${count(_RowStatus.dueSoon)})'
                    : 'Due soon (${count(_RowStatus.dueSoon)})',
                const Color(0xFFB45309)
              ),
              (
                _Filter.expired,
                de
                    ? 'Abgelaufen (${count(_RowStatus.expired)})'
                    : 'Expired (${count(_RowStatus.expired)})',
                const Color(0xFFB91C1C)
              ),
              (
                _Filter.missing,
                de
                    ? 'Nie geschult (${count(_RowStatus.missing)})'
                    : 'Never trained (${count(_RowStatus.missing)})',
                const Color(0xFF9A3412)
              ),
            ])
              ChoiceChip(
                label: Text(label),
                selected: _filter == f,
                onSelected: (_) => setState(() => _filter = f),
                selectedColor: const Color(0xFFE4F5EC),
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                  color: _filter == f ? _kGreen : color,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    de ? 'Keine Fahrer.' : 'No drivers.',
                    style: const TextStyle(
                      color: _kMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) =>
                      _driverTile(de, filtered[i]),
                ),
        ),
      ],
    );
  }

  Widget _driverTile(bool de, _Row r) {
    final (chipBg, chipFg, chipLabel) = switch (r.status) {
      _RowStatus.valid => (
          const Color(0xFFE4F5EC),
          _kGreen,
          de
              ? 'Gültig bis ${DateFormat('dd.MM.yyyy').format(r.validUntil!)}'
              : 'Valid until ${DateFormat('dd.MM.yyyy').format(r.validUntil!)}',
        ),
      _RowStatus.dueSoon => (
          const Color(0xFFFEF3C7),
          const Color(0xFFB45309),
          de
              ? 'Läuft ab ${DateFormat('dd.MM.yyyy').format(r.validUntil!)}'
              : 'Expires ${DateFormat('dd.MM.yyyy').format(r.validUntil!)}',
        ),
      _RowStatus.expired => (
          const Color(0xFFFEE2E2),
          const Color(0xFFB91C1C),
          de ? 'ABGELAUFEN' : 'EXPIRED',
        ),
      _RowStatus.missing => (
          const Color(0xFFFFEDD5),
          const Color(0xFF9A3412),
          de ? 'NIE GESCHULT' : 'NEVER TRAINED',
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                    color: _kText,
                  ),
                ),
                Text(
                  [
                    r.tid,
                    if (r.employeeNumber.isNotEmpty)
                      '${de ? 'Personalnr.' : 'Emp. ID'} ${r.employeeNumber}',
                    if (r.score != null && r.total != null)
                      'Test ${r.score}/${r.total}',
                  ].join(' · '),
                  style: const TextStyle(fontSize: 12, color: _kMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
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
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          if (r.certificateUrl.isNotEmpty) ...[
            const SizedBox(width: 6),
            IconButton(
              tooltip: de ? 'Nachweis-PDF öffnen' : 'Open certificate PDF',
              icon: const Icon(Icons.picture_as_pdf_outlined,
                  size: 20, color: _kGreen),
              onPressed: () async {
                final uri = Uri.tryParse(r.certificateUrl);
                if (uri != null) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}

enum _RowStatus { valid, dueSoon, expired, missing }

class _Row {
  final String tid;
  final String name;
  final String employeeNumber;
  final DateTime? validUntil;
  final _RowStatus status;
  final String certificateUrl;
  final int? score;
  final int? total;
  const _Row({
    required this.tid,
    required this.name,
    required this.employeeNumber,
    required this.validUntil,
    required this.status,
    required this.certificateUrl,
    required this.score,
    required this.total,
  });
}
