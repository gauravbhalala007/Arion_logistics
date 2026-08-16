// lib/widgets/privacy_notice_gate.dart
//
// Login-Gate für die verpflichtende Datenschutzinformation nach
// Art. 13 DSGVO.
//
// Liegt für den Fahrer keine Bestätigung der AKTUELLEN Fassung vor,
// wird die Information angezeigt, bevor die Fahreroberfläche
// überhaupt aufgebaut wird. Damit erfasst der Gate automatisch auch
// alle Bestandsfahrer — für sie existiert schlicht kein Dokument.
//
// Versionierung: geprüft wird `version >= kPrivacyNoticeVersion`.
// Wird `kPrivacyNoticeVersion` erhöht, ist jede ältere gespeicherte
// Fassung zu klein, und die Information erscheint erneut.
//
// Ladeverhalten: solange der Status unbekannt ist, wird ausschließlich
// ein neutraler Ladescreen gerendert — nie kurz die App. Erst wenn die
// Prüfung entschieden ist, erscheint entweder [child] oder die
// Information.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Screens/driver_privacy_notice_page.dart';
import '../data/privacy_notice/privacy_notice_content.dart';
import '../data/privacy_notice/privacy_notice_texts.dart';

class PrivacyNoticeGate extends StatefulWidget {
  final String dspUid;
  final String driverTransporterId;

  /// Die eigentliche Fahreroberfläche — wird erst gebaut, wenn eine
  /// gültige Bestätigung vorliegt.
  final Widget child;

  const PrivacyNoticeGate({
    super.key,
    required this.dspUid,
    required this.driverTransporterId,
    required this.child,
  });

  @override
  State<PrivacyNoticeGate> createState() => _PrivacyNoticeGateState();
}

enum _GateStatus { checking, needsNotice, acknowledged, error }

class _PrivacyNoticeGateState extends State<PrivacyNoticeGate> {
  static const _kBg = Color(0xFFF3F6F7);
  static const _kAccent = Color(0xFF1E3A8A);
  static const _kMuted = Color(0xFF7A8699);

  _GateStatus _status = _GateStatus.checking;

  @override
  void initState() {
    super.initState();
    _check();
  }

  @override
  void didUpdateWidget(covariant PrivacyNoticeGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dspUid != widget.dspUid ||
        oldWidget.driverTransporterId != widget.driverTransporterId) {
      setState(() => _status = _GateStatus.checking);
      _check();
    }
  }

  Future<void> _check() async {
    // Ohne Fahreridentität lässt sich nichts prüfen — dann darf die
    // App auch nicht blockiert werden.
    if (widget.dspUid.isEmpty || widget.driverTransporterId.isEmpty) {
      if (mounted) setState(() => _status = _GateStatus.acknowledged);
      return;
    }
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.dspUid)
          .collection('academy_test_results')
          .doc(kPrivacyNoticeTestId)
          .collection('drivers')
          .doc(widget.driverTransporterId)
          .get();

      final data = snap.data();
      final version = (data?['version'] as num?)?.toInt() ?? 0;
      final acknowledged = data?['acknowledgedAt'] != null;
      final ok = snap.exists && acknowledged && version >= kPrivacyNoticeVersion;

      if (!mounted) return;
      setState(() => _status =
          ok ? _GateStatus.acknowledged : _GateStatus.needsNotice);
    } catch (_) {
      if (!mounted) return;
      setState(() => _status = _GateStatus.error);
    }
  }

  String _t(String key) =>
      privacyNoticeText(Localizations.localeOf(context).languageCode, key);

  @override
  Widget build(BuildContext context) {
    switch (_status) {
      case _GateStatus.acknowledged:
        return widget.child;
      case _GateStatus.needsNotice:
        return DriverPrivacyNoticePage(
          dspUid: widget.dspUid,
          driverTransporterId: widget.driverTransporterId,
          onAcknowledged: () {
            if (!mounted) return;
            setState(() => _status = _GateStatus.acknowledged);
          },
        );
      case _GateStatus.error:
        return _buildError();
      case _GateStatus.checking:
        return _buildLoading();
    }
  }

  Widget _buildLoading() {
    return Scaffold(
      backgroundColor: _kBg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.6,
                valueColor: AlwaysStoppedAnimation<Color>(_kAccent),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _t('gate_loading'),
              style: const TextStyle(fontSize: 13.5, color: _kMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Scaffold(
      backgroundColor: _kBg,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off_rounded, size: 44, color: _kMuted),
                const SizedBox(height: 14),
                Text(
                  _t('gate_error'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.55,
                    color: Color(0xFF3F4A5A),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () {
                    setState(() => _status = _GateStatus.checking);
                    _check();
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(_t('btn_retry')),
                  style: FilledButton.styleFrom(
                    backgroundColor: _kAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => FirebaseAuth.instance.signOut(),
                  icon: const Icon(Icons.logout_rounded, size: 16),
                  label: Text(_t('btn_logout')),
                  style: TextButton.styleFrom(foregroundColor: _kMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
