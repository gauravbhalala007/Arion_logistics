// lib/Screens/driver_privacy_notice_page.dart
//
// Verpflichtende Datenschutzinformation nach Art. 13 DSGVO für Fahrer —
// als GESTUFTES HINWEISMODELL (layered privacy notice), das
// Art. 12 Abs. 1 DSGVO ausdrücklich zulässt:
//
//   Ebene 1 — [DriverPrivacyNoticePage]: ein kompaktes Pop-up beim
//     Login — wie der übliche Datenschutzhinweis anderer Apps.
//     Kurzinformation in wenigen Stichpunkten und ein einziger
//     „Akzeptieren"-Button. Keine Checkbox, keine Unterschrift,
//     kein PDF.
//   Ebene 2 — [PrivacyNoticeDetailPage]: der vollständige Text mit
//     allen Abschnitten. Aus dem Pop-up einen Klick entfernt und
//     später jederzeit über das Fahrerprofil erreichbar.
//
// Die Abschnitte werden ausschließlich in [PrivacyNoticeDetailPage]
// gerendert — es gibt keine zweite Darstellung.
//
// Rechtlich weiterhin eine KENNTNISNAHME, keine Einwilligung: der
// Fahrer bestätigt, informiert worden zu sein; er erlaubt nichts. Die
// Verarbeitung stützt sich auf Art. 6 Abs. 1 lit. b, c und f DSGVO
// i. V. m. § 26 BDSG.
//
// Das Pop-up ist nicht wegklickbar: kein Zurück-Pfeil, kein
// System-Back (PopScope), kein Tippen daneben. Erhalten bleibt nur der
// Weg „Abmelden" — niemand wird in der App eingesperrt.
//
// Ablage:
//   - users/{dspUid}/academy_test_results/privacy_notice/drivers/{tid}
//     mit driverTransporterId + testId — beides verlangt die geltende
//     Firestore-Regel bei jedem Schreibvorgang:
//       allow create, update: if isDriverForUser(userId)
//         && isApproved(userId)
//         && driverTransporterId() == driverId
//         && request.resource.data.driverTransporterId == driverId
//         && request.resource.data.testId == testId;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/privacy_notice/privacy_notice_content.dart';
import '../data/privacy_notice/privacy_notice_texts.dart';
import '../widgets/safety_block_view.dart';

// ── Gemeinsame Farben beider Ebenen ─────────────────────────────────
const Color _kBg = Color(0xFFF5F7F9);
const Color _kText = Color(0xFF1A2233);
const Color _kMuted = Color(0xFF7A8699);
const Color _kAccent = Color(0xFF1E3A8A);
const Color _kTint = Color(0xFFEAEEF9);
const Color _kLine = Color(0xFFE3E8EF);

/// Backdrop hinter dem Pop-up — macht sichtbar, dass hier ein
/// modaler Schritt liegt, ohne dass daneben etwas anklickbar wäre.
const Color _kScrim = Color(0xFF101A33);

/// Öffnet den Volltext als eigene Route über dem aufrufenden Screen.
///
/// Wird sowohl aus dem Pop-up als auch aus dem Fahrerprofil benutzt;
/// der Aufrufer bleibt im Navigator-Stack bestehen.
Future<void> openPrivacyNoticeDetail(
  BuildContext context, {
  String companyName = '',
  DateTime? acknowledgedAt,
  bool showAckStatus = false,
}) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => PrivacyNoticeDetailPage(
        companyName: companyName,
        acknowledgedAt: acknowledgedAt,
        showAckStatus: showAckStatus,
      ),
    ),
  );
}

// ════════════════════════════════════════════════════════════════════
// Ebene 1 — Pop-up mit Kurzinformation
// ════════════════════════════════════════════════════════════════════

class DriverPrivacyNoticePage extends StatefulWidget {
  final String dspUid;
  final String driverTransporterId;

  /// Wird gerufen, sobald die Kenntnisnahme gespeichert ist — der
  /// Login-Gate schaltet danach auf die eigentliche App um.
  final VoidCallback onAcknowledged;

  const DriverPrivacyNoticePage({
    super.key,
    required this.dspUid,
    required this.driverTransporterId,
    required this.onAcknowledged,
  });

  @override
  State<DriverPrivacyNoticePage> createState() =>
      _DriverPrivacyNoticePageState();
}

class _DriverPrivacyNoticePageState extends State<DriverPrivacyNoticePage> {
  bool _submitting = false;

  /// Firmenname des Verantwortlichen — Kopfzeile der Information.
  String _companyName = '';

  final ScrollController _scrollCtrl = ScrollController();

  /// Sprache des Fahrers — steuert alle Bedientexte dieser Seite.
  String get _lang => Localizations.localeOf(context).languageCode;

  String _t(String key, [Map<String, String>? vars]) =>
      privacyNoticeText(_lang, key, vars: vars);

  DocumentReference<Map<String, dynamic>> get _driverRef => FirebaseFirestore
      .instance
      .collection('users')
      .doc(widget.dspUid)
      .collection('drivers')
      .doc(widget.driverTransporterId);

  /// users/{dspUid}/academy_test_results/privacy_notice/drivers/{tid}
  DocumentReference<Map<String, dynamic>> get _ackRef => FirebaseFirestore
      .instance
      .collection('users')
      .doc(widget.dspUid)
      .collection('academy_test_results')
      .doc(kPrivacyNoticeTestId)
      .collection('drivers')
      .doc(widget.driverTransporterId);

  @override
  void initState() {
    super.initState();
    _loadCompanyName();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCompanyName() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.dspUid)
          .get();
      final data = snap.data() ?? const <String, dynamic>{};
      final name =
          (data['companyName'] ?? data['dspName'] ?? '').toString().trim();
      if (!mounted || name.isEmpty) return;
      setState(() => _companyName = name);
    } catch (_) {
      // Ohne Firmenname bleibt die Kopfzeile schlicht — die Information
      // selbst ist davon nicht betroffen.
    }
  }

  @override
  Widget build(BuildContext context) {
    // Nicht überspringbar: System-Back darf das Pop-up nicht schließen.
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: _kScrim,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    child: _buildForm(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Pop-up-Inhalt ─────────────────────────────────────────────────

  Widget _buildForm() {
    final meta = _t('popup_meta', {
      'v': '$kPrivacyNoticeVersion',
      'date': kPrivacyNoticeIssuedOn,
    });
    final metaLine = _companyName.isEmpty
        ? meta
        : '$meta · ${_t('responsible_label')}: $_companyName';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Kopf: Titel + Abmelden. Kein Icon-Banner, keine zweite
        // Überschrift — Fassung und Stand als dezente Zeile darunter.
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                _t('popup_title'),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: _kText,
                  height: 1.2,
                ),
              ),
            ),
            const SizedBox(width: 6),
            SizedBox(
              height: 28,
              child: TextButton.icon(
                onPressed: () => FirebaseAuth.instance.signOut(),
                icon: const Icon(Icons.logout_rounded, size: 14),
                label: Text(
                  _t('btn_logout'),
                  style: const TextStyle(fontSize: 11.5),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: _kMuted,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          metaLine,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: _kMuted,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 12),

        // Einleitungssatz.
        Text(
          _t('popup_intro'),
          style: const TextStyle(
            fontSize: 13,
            height: 1.4,
            color: Color(0xFF3F4A5A),
          ),
        ),
        const SizedBox(height: 10),

        // Drei Stichpunkte statt Fließtext.
        _bullet(_t('popup_b_data')),
        const SizedBox(height: 5),
        _bullet(_t('popup_b_purpose')),
        const SizedBox(height: 5),
        _bullet(_t('popup_b_rights')),
        const SizedBox(height: 9),

        // Abgrenzung: diese Kenntnisnahme deckt nur die App ab.
        Text(
          _t('popup_scope'),
          style: const TextStyle(
            fontSize: 11.5,
            height: 1.35,
            color: _kMuted,
          ),
        ),
        const SizedBox(height: 12),

        // Der Weg zum Volltext — gut sichtbar, volle Breite.
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => openPrivacyNoticeDetail(
              context,
              companyName: _companyName,
            ),
            icon: const Icon(Icons.menu_book_rounded, size: 17),
            label: Text(
              _t('btn_read_full'),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: _kAccent,
              backgroundColor: _kTint,
              padding: const EdgeInsets.symmetric(vertical: 11),
              side: const BorderSide(color: _kAccent, width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Hinweiszeile: Was der Klick auf „Akzeptieren" bedeutet —
        // Kenntnisnahme, keine Einwilligung.
        Text(
          _t('accept_note'),
          style: const TextStyle(
            fontSize: 11.5,
            height: 1.35,
            color: _kMuted,
          ),
        ),
        const SizedBox(height: 10),

        // Ein einziger Button — wie der übliche Datenschutzhinweis
        // anderer Apps.
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _submitting ? null : _submitAcknowledgement,
            icon: _submitting
                ? const SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.check_rounded, size: 17),
            label: Text(_t('btn_accept')),
            style: FilledButton.styleFrom(
              backgroundColor: _kAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _bullet(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6.5),
          width: 5,
          height: 5,
          decoration: const BoxDecoration(
            color: _kAccent,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.35,
              color: _kText,
            ),
          ),
        ),
      ],
    );
  }

  /// Abschluss — ein Klick auf „Akzeptieren" speichert die
  /// Kenntnisnahme für den Login-Gate und die Admin-Übersicht.
  /// Keine Unterschrift, kein PDF, kein Storage-Upload mehr.
  Future<void> _submitAcknowledgement() async {
    setState(() => _submitting = true);
    try {
      // Stammdaten laden — Name/Personalnummer für die Admin-Übersicht.
      final driverSnap = await _driverRef.get();
      final driverData = driverSnap.data() ?? const <String, dynamic>{};
      final rawName = (driverData['driverName'] ?? '').toString().trim();
      final driverName = rawName.isEmpty ? widget.driverTransporterId : rawName;
      final employeeNumber =
          (driverData['employeeNumber'] ?? '').toString().trim();

      final now = DateTime.now();

      // Kenntnisnahme speichern — driverTransporterId und testId sind
      // Pflicht, ohne sie lehnt die Firestore-Regel den Schreibvorgang ab.
      await _ackRef.set({
        'driverTransporterId': widget.driverTransporterId,
        'testId': kPrivacyNoticeTestId,
        'driverName': driverName,
        'employeeNumber': employeeNumber,
        'version': kPrivacyNoticeVersion,
        'acknowledgedAt': Timestamp.fromDate(now),
        'language': _lang,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      widget.onAcknowledged();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t('err_save', {'error': '$e'}))),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

}

// ════════════════════════════════════════════════════════════════════
// Ebene 2 — Volltext (einzige Darstellung der Abschnitte)
// ════════════════════════════════════════════════════════════════════

/// Die vollständige Datenschutzinformation mit allen Abschnitten.
///
/// Reine Leseansicht — ohne Häkchen, ohne Unterschrift. Sie wird von
/// zwei Stellen benutzt:
///   - aus dem Pop-up beim Login („Vollständige Information lesen"),
///     wobei das Pop-up im Navigator-Stack erhalten bleibt und eine
///     bereits gesetzte Unterschrift damit nicht verlorengeht;
///   - später aus dem Fahrerprofil, dann mit [showAckStatus] und dem
///     Datum der Kenntnisnahme.
class PrivacyNoticeDetailPage extends StatelessWidget {
  final String companyName;

  /// Zeitpunkt der Kenntnisnahme — nur relevant, wenn
  /// [showAckStatus] gesetzt ist.
  final DateTime? acknowledgedAt;

  /// Blendet oben an, wann der Fahrer die Information bestätigt hat.
  final bool showAckStatus;

  const PrivacyNoticeDetailPage({
    super.key,
    this.companyName = '',
    this.acknowledgedAt,
    this.showAckStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    String t(String key, [Map<String, String>? vars]) =>
        privacyNoticeText(lang, key, vars: vars);

    final sections = privacyNoticeSectionsFor(lang);

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        foregroundColor: _kText,
        elevation: 0,
        title: Text(
          t('appbar_title'),
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).maybePop(),
            style: TextButton.styleFrom(foregroundColor: _kAccent),
            child: Text(t('btn_close')),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _kLine),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t('intro_title'),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: _kText,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    t('intro_meta', {
                      'n': '${sections.length}',
                      'v': '$kPrivacyNoticeVersion',
                      'date': kPrivacyNoticeIssuedOn,
                    }),
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: _kMuted,
                    ),
                  ),
                  if (companyName.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${t('responsible_label')}: $companyName',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        color: _kAccent,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Text(
                    t('detail_readonly_note'),
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.45,
                      color: Color(0xFF3F4A5A),
                    ),
                  ),
                  if (showAckStatus) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 11, vertical: 8),
                      decoration: BoxDecoration(
                        color: _kTint,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            acknowledgedAt == null
                                ? Icons.info_outline_rounded
                                : Icons.verified_user_rounded,
                            size: 16,
                            color: _kAccent,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              acknowledgedAt == null
                                  ? t('ack_not_yet')
                                  : t('ack_confirmed_on', {
                                      'date': DateFormat('dd.MM.yyyy')
                                          .format(acknowledgedAt!),
                                    }),
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: _kAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            for (var i = 0; i < sections.length; i++) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _kTint,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: _kAccent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Text(
                        sections[i].title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: _kText,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (final block in sections[i].blocks) SafetyBlockView(block),
              if (i < sections.length - 1) ...[
                const SizedBox(height: 8),
                const Divider(color: _kLine, height: 24),
              ],
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: const Border(
                  left: BorderSide(color: _kAccent, width: 3),
                ),
              ),
              child: Text(
                '${t('intro_note')}\n\n${t('ack_note')}',
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 1.5,
                  color: Color(0xFF3F4A5A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
