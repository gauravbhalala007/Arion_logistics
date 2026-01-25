// lib/widgets/notification_pin_dialogs.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationPinService {
  static DocumentReference<Map<String, dynamic>> _driverRef({
    required String dspUid,
    required String transporterId,
  }) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(dspUid)
        .collection('drivers')
        .doc(transporterId.toUpperCase());
  }

  static Future<String?> getPin({
    required String dspUid,
    required String transporterId,
  }) async {
    final snap =
        await _driverRef(dspUid: dspUid, transporterId: transporterId).get();
    final data = snap.data() ?? <String, dynamic>{};
    final pin = (data['notificationPin'] ?? '').toString().trim();
    if (pin.isEmpty) return null;
    return pin;
  }

  static Future<void> setPin({
    required String dspUid,
    required String transporterId,
    required String pin,
  }) async {
    await _driverRef(dspUid: dspUid, transporterId: transporterId).set(
      {
        'notificationPin': pin,
        'notificationPinSetAt': FieldValue.serverTimestamp(),
        'notificationPinUpdatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  static Future<bool> verifyPin({
    required String dspUid,
    required String transporterId,
    required String pinAttempt,
  }) async {
    final pin = await getPin(dspUid: dspUid, transporterId: transporterId);
    if (pin == null) return false;
    return pin == pinAttempt.trim();
  }
}

/// ===========================================================================
/// Shared keypad UI (dots + numeric pad)
/// ===========================================================================

class _PinPadCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String pin; // current entered digits (0..4)
  final String? error;
  final bool busy;

  final ValueChanged<String> onDigit; // "0".."9"
  final VoidCallback onBackspace;

  final bool showClose;
  final VoidCallback? onClose;

  const _PinPadCard({
    required this.title,
    required this.subtitle,
    required this.pin,
    required this.onDigit,
    required this.onBackspace,
    this.error,
    this.busy = false,
    this.showClose = true,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    const bg = Colors.white;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: Container(
        width: 420,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.14),
              blurRadius: 24,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 6),

                  // Title
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Subtitle
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Dots
                  _PinDots(pinLength: pin.length),

                  if (error != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 10),
                  ],

                  const SizedBox(height: 10),

                  // Keypad
                  AbsorbPointer(
                    absorbing: busy,
                    child: Opacity(
                      opacity: busy ? 0.55 : 1,
                      child: _Keypad(
                        onDigit: onDigit,
                        onBackspace: onBackspace,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  if (busy) ...[
                    const SizedBox(height: 6),
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(height: 6),
                  ],
                ],
              ),
            ),

            // Close icon (optional)
            if (showClose)
              Positioned(
                right: 6,
                top: 6,
                child: IconButton(
                  tooltip: 'Close',
                  onPressed: onClose,
                  icon: const Icon(Icons.close, size: 20),
                  color: const Color(0xFF6B7280),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PinDots extends StatelessWidget {
  final int pinLength; // 0..4
  const _PinDots({required this.pinLength});

  @override
  Widget build(BuildContext context) {
    Widget dot(bool filled) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? const Color(0xFF111827) : const Color(0xFFE5E7EB),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        final filled = i < pinLength;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: dot(filled),
        );
      }),
    );
  }
}

class _Keypad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  const _Keypad({
    required this.onDigit,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    Widget key(String label, {VoidCallback? onTap}) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 74,
          height: 74,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFF3F4F6),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
        ),
      );
    }

    Widget backspace() {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onBackspace,
        child: Container(
          width: 74,
          height: 74,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFF3F4F6),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: const Icon(
            Icons.backspace_outlined,
            size: 22,
            color: Color(0xFF111827),
          ),
        ),
      );
    }

    Widget spacer() => const SizedBox(width: 74, height: 74);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            key('1', onTap: () => onDigit('1')),
            key('2', onTap: () => onDigit('2')),
            key('3', onTap: () => onDigit('3')),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            key('4', onTap: () => onDigit('4')),
            key('5', onTap: () => onDigit('5')),
            key('6', onTap: () => onDigit('6')),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            key('7', onTap: () => onDigit('7')),
            key('8', onTap: () => onDigit('8')),
            key('9', onTap: () => onDigit('9')),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            spacer(),
            key('0', onTap: () => onDigit('0')),
            backspace(),
          ],
        ),
      ],
    );
  }
}

/// ===========================================================================
/// Set PIN dialog (two-step: create -> confirm) using keypad UI
/// ===========================================================================

class SetNotificationPinDialog extends StatefulWidget {
  final String dspUid;
  final String transporterId;

  /// if true -> user cannot close dialog without setting pin
  final bool force;

  const SetNotificationPinDialog({
    super.key,
    required this.dspUid,
    required this.transporterId,
    this.force = false,
  });

  @override
  State<SetNotificationPinDialog> createState() =>
      _SetNotificationPinDialogState();
}

class _SetNotificationPinDialogState extends State<SetNotificationPinDialog> {
  String _pin = '';
  String? _firstPin; // step1 saved
  bool _busy = false;
  String? _error;

  bool get _isConfirmStep => _firstPin != null;

  void _addDigit(String d) {
    if (_busy) return;
    if (_pin.length >= 4) return;

    setState(() {
      _error = null;
      _pin = '$_pin$d';
    });

    if (_pin.length == 4) {
      _onPinComplete();
    }
  }

  void _backspace() {
    if (_busy) return;
    if (_pin.isEmpty) return;
    setState(() {
      _error = null;
      _pin = _pin.substring(0, _pin.length - 1);
    });
  }

  Future<void> _onPinComplete() async {
    final entered = _pin;

    // Step 1: capture first PIN
    if (_firstPin == null) {
      setState(() {
        _firstPin = entered;
        _pin = '';
        _error = null;
      });
      return;
    }

    // Step 2: compare and save
    if (entered != _firstPin) {
      setState(() {
        _error = 'PINs do not match. Try again.';
        _firstPin = null; // reset flow
        _pin = '';
      });
      return;
    }

    setState(() => _busy = true);
    try {
      await NotificationPinService.setPin(
        dspUid: widget.dspUid,
        transporterId: widget.transporterId,
        pin: entered,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Failed to save PIN: $e');
      setState(() {
        _firstPin = null;
        _pin = '';
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isConfirmStep ? 'Confirm your PIN code' : 'Create your PIN code';
    final subtitle = _isConfirmStep
        ? 'Enter the same 4-digit PIN again.'
        : 'This PIN is required to confirm important notifications.';

    return WillPopScope(
      onWillPop: () async => !widget.force && !_busy,
      child: _PinPadCard(
        title: title,
        subtitle: subtitle,
        pin: _pin,
        error: _error,
        busy: _busy,
        onDigit: _addDigit,
        onBackspace: _backspace,
        showClose: !widget.force,
        onClose: _busy ? null : () => Navigator.of(context).pop(false),
      ),
    );
  }
}

/// ===========================================================================
/// Verify PIN dialog (returns true/false) using keypad UI
/// ===========================================================================

class VerifyNotificationPinDialog extends StatefulWidget {
  final String dspUid;
  final String transporterId;

  const VerifyNotificationPinDialog({
    super.key,
    required this.dspUid,
    required this.transporterId,
  });

  @override
  State<VerifyNotificationPinDialog> createState() =>
      _VerifyNotificationPinDialogState();
}

class _VerifyNotificationPinDialogState
    extends State<VerifyNotificationPinDialog> {
  String _pin = '';
  bool _busy = false;
  String? _error;

  void _addDigit(String d) {
    if (_busy) return;
    if (_pin.length >= 4) return;

    setState(() {
      _error = null;
      _pin = '$_pin$d';
    });

    if (_pin.length == 4) {
      _verify();
    }
  }

  void _backspace() {
    if (_busy) return;
    if (_pin.isEmpty) return;
    setState(() {
      _error = null;
      _pin = _pin.substring(0, _pin.length - 1);
    });
  }

  Future<void> _verify() async {
    final attempt = _pin;

    setState(() => _busy = true);
    try {
      final ok = await NotificationPinService.verifyPin(
        dspUid: widget.dspUid,
        transporterId: widget.transporterId,
        pinAttempt: attempt,
      );

      if (!mounted) return;

      if (!ok) {
        setState(() {
          _busy = false;
          _error = 'Wrong PIN. Try again.';
          _pin = '';
        });
        return;
      }

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Verification failed: $e';
        _pin = '';
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _PinPadCard(
      title: 'Enter your PIN code',
      subtitle: 'Please enter your notification PIN to confirm.',
      pin: _pin,
      error: _error,
      busy: _busy,
      onDigit: _addDigit,
      onBackspace: _backspace,
      showClose: true,
      onClose: _busy ? null : () => Navigator.of(context).pop(false),
    );
  }
}
