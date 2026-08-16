// lib/Screens/admin_driver_reviews_page.dart
//
// Admin: monatliche Fahrerbewertung durch Dispatcher.
//
// - Pro Dispatcher einen Bewertungslink für den laufenden Monat erzeugen
//   (der Link enthält die Liste der aktiven Fahrer als Momentaufnahme).
// - Fortschritt je Dispatcher verfolgen.
// - Abgegebene Bewertungen lesen; sie erscheinen zusätzlich beim Fahrer
//   im Drivers Hub.

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../data/driver_review_model.dart';
import '../utils/driver_activity.dart';
import '../widgets/admin_scope.dart';

class AdminDriverReviewsPage extends StatefulWidget {
  const AdminDriverReviewsPage({super.key});

  @override
  State<AdminDriverReviewsPage> createState() => _AdminDriverReviewsPageState();
}

class _AdminDriverReviewsPageState extends State<AdminDriverReviewsPage> {
  static const _kText = Color(0xFF1A2233);
  static const _kMuted = Color(0xFF7A8699);
  static const _kGreen = Color(0xFF1D7F5A);
  static const _kMint = Color(0xFFEBF7F1);
  static const _kLine = Color(0xFFE3E8EF);

  String _period = currentReviewPeriod();
  bool _creating = false;

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
                  de ? 'Fahrerbewertung' : 'Driver reviews',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: _kText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  de
                      ? 'Jeder Manager bekommt einen eigenen Link und '
                          'bewertet damit einmal im Monat alle aktiven '
                          'Fahrer. Die Ergebnisse erscheinen beim Fahrer '
                          'im Drivers Hub.'
                      : 'Each manager gets their own link and rates all '
                          'active drivers once a month. Results appear with '
                          'the driver in the Drivers Hub.',
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: _kMuted,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                _periodBar(de),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    children: [
                      _linksSection(uid, de),
                      const SizedBox(height: 20),
                      _resultsSection(uid, de),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _periodBar(bool de) {
    final now = DateTime.now();
    final periods = <String>[
      for (var i = 0; i < 6; i++)
        currentReviewPeriod(DateTime(now.year, now.month - i, 1)),
    ];
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final p in periods)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(reviewPeriodLabel(p)),
                selected: _period == p,
                onSelected: (_) => setState(() => _period = p),
                selectedColor: _kMint,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                  color: _period == p ? _kGreen : _kMuted,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Links ─────────────────────────────────────────────────────────

  Widget _linksSection(String uid, bool de) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 16, height: 2.5, color: _kGreen),
            const SizedBox(width: 8),
            Text(
              de ? 'BEWERTUNGSLINKS' : 'REVIEW LINKS',
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
                color: _kGreen,
                letterSpacing: 1.1,
              ),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: _creating ? null : () => _createLinkDialog(uid, de),
              icon: const Icon(Icons.add_link_rounded, size: 17),
              label: Text(de ? 'Link erstellen' : 'Create link'),
              style: FilledButton.styleFrom(
                backgroundColor: _kGreen,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('dispatcher_review_links')
              .where('adminUid', isEqualTo: uid)
              .where('period', isEqualTo: _period)
              .snapshots(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final docs = snap.data?.docs ?? const [];
            if (docs.isEmpty) {
              return _emptyBox(
                de
                    ? 'Für ${reviewPeriodLabel(_period)} wurde noch kein '
                        'Link erstellt.'
                    : 'No link created for ${reviewPeriodLabel(_period)} yet.',
              );
            }
            return Column(
              children: [for (final d in docs) _linkTile(d, de)],
            );
          },
        ),
      ],
    );
  }

  Widget _linkTile(
      QueryDocumentSnapshot<Map<String, dynamic>> doc, bool de) {
    final data = doc.data();
    final drivers = (data['drivers'] as List?)?.length ?? 0;
    final completed = (data['completed'] as List?)?.length ?? 0;
    final active = data['active'] == true;
    final url = _reviewUrl(doc.id, (data['dispatcherName'] ?? '').toString());

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kLine),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _kMint,
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(Icons.headset_mic_rounded,
                  size: 18, color: _kGreen),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (data['dispatcherName'] ?? '—').toString(),
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: _kText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    de
                        ? '$completed von $drivers Fahrern bewertet'
                        : '$completed of $drivers drivers rated',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: completed >= drivers && drivers > 0
                          ? _kGreen
                          : _kMuted,
                      fontWeight: completed >= drivers && drivers > 0
                          ? FontWeight.w800
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: de ? 'Link kopieren' : 'Copy link',
              icon: const Icon(Icons.copy_rounded, size: 19, color: _kGreen),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: url));
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(de ? 'Link kopiert.' : 'Link copied.'),
                  ),
                );
              },
            ),
            IconButton(
              tooltip: active
                  ? (de ? 'Link deaktivieren' : 'Deactivate')
                  : (de ? 'Link aktivieren' : 'Activate'),
              icon: Icon(
                active ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
                size: 24,
                color: active ? _kGreen : _kMuted,
              ),
              onPressed: () => doc.reference.set(
                {'active': !active},
                SetOptions(merge: true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bewertungslink. Der Name des Managers steht als lesbarer Zusatz
  /// mit im Link, damit beim Verschicken auf einen Blick klar ist, wem
  /// welcher Link gehoert. Ausgewertet wird ausschliesslich der Token.
  String _reviewUrl(String token, [String name = '']) {
    final slug = _nameSlug(name);
    final suffix = slug.isEmpty ? '' : '&m=$slug';
    return 'https://dsp-codriver.de/review?t=$token$suffix';
  }

  /// „Anna Meier" → „anna-meier"; Umlaute werden aufgeloest, alles
  /// andere faellt weg, damit der Link ohne Escaping lesbar bleibt.
  static String _nameSlug(String name) {
    var s = name.trim().toLowerCase();
    const map = {
      'ä': 'ae', 'ö': 'oe', 'ü': 'ue', 'ß': 'ss',
      'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a', 'å': 'a',
      'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
      'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
      'ó': 'o', 'ò': 'o', 'ô': 'o', 'õ': 'o',
      'ú': 'u', 'ù': 'u', 'û': 'u',
      'ç': 'c', 'ñ': 'n', 'ș': 's', 'ş': 's', 'ț': 't',
      'č': 'c', 'ć': 'c', 'ž': 'z', 'š': 's', 'đ': 'd',
    };
    map.forEach((k, v) => s = s.replaceAll(k, v));
    s = s.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    s = s.replaceAll(RegExp(r'^-+|-+$'), '');
    return s.length > 40 ? s.substring(0, 40) : s;
  }

  Future<void> _createLinkDialog(String uid, bool de) async {
    final nameCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(de ? 'Bewertungslink erstellen' : 'Create review link'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                de
                    ? 'Für welchen Manager? Der Link gilt für '
                        '${reviewPeriodLabel(_period)} und enthält alle '
                        'aktiven Fahrer.'
                    : 'For which manager? The link covers '
                        '${reviewPeriodLabel(_period)} and all active drivers.',
                style: const TextStyle(fontSize: 13.5, color: _kMuted),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: de ? 'Name des Managers' : 'Manager name',
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
            child: Text(de ? 'Abbrechen' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(de ? 'Erstellen' : 'Create'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final name = nameCtrl.text.trim();
    if (name.isEmpty) return;

    setState(() => _creating = true);
    try {
      // Momentaufnahme der aktiven Fahrer — der öffentliche Link greift
      // dadurch nicht auf die Fahrerstammdaten zu.
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('drivers')
          .get();
      final drivers = <Map<String, String>>[];
      for (final d in snap.docs) {
        final data = d.data();
        if (!isDriverWorking(data)) continue;
        // Dispatcher gehören nicht in die Bewertung.
        final contract =
            (data['contractType'] ?? '').toString().toLowerCase();
        if (contract.contains('dispatcher')) continue;
        final tid = (data['transporterId'] ?? d.id).toString().trim();
        if (tid.isEmpty) continue;
        drivers.add({
          'tid': tid,
          'name': (data['driverName'] ?? tid).toString(),
        });
      }
      drivers.sort((a, b) =>
          (a['name'] ?? '').toLowerCase().compareTo((b['name'] ?? '').toLowerCase()));

      final token = _randomToken();
      await FirebaseFirestore.instance
          .collection('dispatcher_review_links')
          .doc(token)
          .set({
        'adminUid': uid,
        'dispatcherName': name,
        'period': _period,
        'active': true,
        'drivers': drivers,
        'completed': <String>[],
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      setState(() => _creating = false);
      await Clipboard.setData(ClipboardData(text: _reviewUrl(token, name)));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF067647),
          content: Text(
            de
                ? 'Link für $name erstellt (${drivers.length} Fahrer) und '
                    'in die Zwischenablage kopiert.'
                : 'Link for $name created (${drivers.length} drivers) and '
                    'copied to clipboard.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _creating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${de ? 'Fehlgeschlagen' : 'Failed'}: $e')),
      );
    }
  }

  static String _randomToken() {
    const chars = 'abcdefghijkmnpqrstuvwxyz23456789';
    final r = Random.secure();
    return List.generate(28, (_) => chars[r.nextInt(chars.length)]).join();
  }

  // ── Ergebnisse ────────────────────────────────────────────────────

  Widget _resultsSection(String uid, bool de) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 16, height: 2.5, color: _kGreen),
            const SizedBox(width: 8),
            Text(
              de ? 'ABGEGEBENE BEWERTUNGEN' : 'SUBMITTED REVIEWS',
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
                color: _kGreen,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('driver_reviews')
              .where('period', isEqualTo: _period)
              .snapshots(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final docs = (snap.data?.docs ?? []).toList()
              ..sort((a, b) => (a.data()['driverName'] ?? '')
                  .toString()
                  .toLowerCase()
                  .compareTo(
                      (b.data()['driverName'] ?? '').toString().toLowerCase()));
            if (docs.isEmpty) {
              return _emptyBox(
                de
                    ? 'Noch keine Bewertungen für '
                        '${reviewPeriodLabel(_period)}.'
                    : 'No reviews for ${reviewPeriodLabel(_period)} yet.',
              );
            }
            return Column(
              children: [for (final d in docs) _reviewTile(d.data(), de)],
            );
          },
        ),
      ],
    );
  }

  Widget _reviewTile(Map<String, dynamic> r, bool de) {
    final score = (r['score'] as num?)?.toDouble() ?? 0;
    final attitude = (r['attitude'] as num?)?.toInt();
    final created = r['createdAt'];
    final dateText = created is Timestamp
        ? DateFormat('dd.MM.yyyy').format(created.toDate())
        : '';


    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kLine),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    (r['driverName'] ?? '').toString(),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: _kText,
                    ),
                  ),
                ),
                Text(
                  '${(score * 100).round()} %',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: score >= 0.7
                        ? _kGreen
                        : score >= 0.5
                            ? const Color(0xFFB45309)
                            : const Color(0xFFC0392B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              [
                if ((r['dispatcherName'] ?? '').toString().isNotEmpty)
                  '${de ? 'von' : 'by'} ${r['dispatcherName']}',
                if (dateText.isNotEmpty) dateText,
                if (attitude != null)
                  (de ? kAttitudeOptionsDe : kAttitudeOptionsEn)[attitude],
              ].join('  ·  '),
              style: const TextStyle(fontSize: 12, color: _kMuted),
            ),
            if ((r['comment'] ?? '').toString().trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                (r['comment'] ?? '').toString(),
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.45,
                  color: Color(0xFF3F4A5A),
                ),
              ),
            ],
            if ((r['note'] ?? '').toString().trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${de ? 'Notiz' : 'Note'}: ${r['note']}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: Color(0xFF3F4A5A),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _emptyBox(String text) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kLine),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 13.5, color: _kMuted),
        ),
      );
}
