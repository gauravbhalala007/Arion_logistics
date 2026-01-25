// lib/screens/driver_notification_detail_view.dart

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import '../widgets/notification_pin_dialogs.dart';


import '../models/driver_notification.dart';

class DriverNotificationDetailView extends StatefulWidget {
  final String dspUid;
  final String driverTransporterId;

  final DriverNotification notification;
  final VoidCallback onBack;

  const DriverNotificationDetailView({
    super.key,
    required this.dspUid,
    required this.driverTransporterId,
    required this.notification,
    required this.onBack,
  });

  @override
  State<DriverNotificationDetailView> createState() =>
      _DriverNotificationDetailViewState();
}

class _DriverNotificationDetailViewState
    extends State<DriverNotificationDetailView>
    with SingleTickerProviderStateMixin {
  bool _busyRead = false;
  bool _busyConfirm = false;

  // ✅ local UI state so the animation shows instantly after confirm
  bool _justConfirmed = false;

  late final AnimationController _confirmAnim;
  late final Animation<double> _confirmScale;
  late final Animation<double> _confirmFade;

  // ✅ local UI state for status pill + swipe enabled state (instant update)
  bool _confirmedLocal = false;

  Future<void> _markRead() async {
    if (_busyRead) return;
    if (!mounted) return;

    setState(() => _busyRead = true);
    try {
      final callable = FirebaseFunctions.instance.httpsCallable(
        'markDriverNotificationRead',
      );
      await callable.call({
        'dspUid': widget.dspUid,
        'transporterId': widget.driverTransporterId,
        'notificationId': widget.notification.id,
      });
    } catch (e) {
      // Don’t block UX; just show snack
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark read: $e')),
      );
    } finally {
      if (mounted) setState(() => _busyRead = false);
    }
  }

  Future<void> _confirm() async {
    if (_busyConfirm) return;
    if (!mounted) return;
    if (_confirmedLocal) return;

    setState(() => _busyConfirm = true);
    try {
      final callable = FirebaseFunctions.instance.httpsCallable(
        'confirmDriverNotification',
      );
      await callable.call({
        'dspUid': widget.dspUid,
        'transporterId': widget.driverTransporterId,
        'notificationId': widget.notification.id,
      });

      if (!mounted) return;

      // ✅ Instant UI update (pill + button state) without waiting stream refresh
      setState(() {
        _confirmedLocal = true;
        _justConfirmed = true;
      });

      // ✅ Trigger success animation immediately
      _confirmAnim.forward(from: 0);

      // Optional: small feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Confirmed')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Confirm failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _busyConfirm = false);
    }
  }

  @override
  void initState() {
    super.initState();

    _confirmAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );

    _confirmScale = CurvedAnimation(
      parent: _confirmAnim,
      curve: Curves.elasticOut,
    );

    _confirmFade = CurvedAnimation(
      parent: _confirmAnim,
      curve: Curves.easeOut,
    );

    // ✅ initialize local confirmed state
    _confirmedLocal = widget.notification.confirmed;

    // If unread, mark as read immediately when opening detail
    if (widget.notification.isUnread) {
      _markRead();
    }

    // If already confirmed when opening detail, keep UI consistent
    if (widget.notification.confirmed) {
      _justConfirmed = true;
      _confirmAnim.value = 1.0;
    }
  }

  @override
  void dispose() {
    _confirmAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.notification;

    final confirmedUi = _confirmedLocal || _justConfirmed;

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: widget.onBack,
              icon: const Icon(Icons.chevron_left),
            ),
            const SizedBox(width: 4),
            const Text(
              'Detail',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const Spacer(),
            if (_busyRead)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE1E4EA)),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: _StatusPillConfirmed(confirmed: confirmedUi),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    n.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF22252F),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    n.body,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: Color(0xFF4A4F59),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: confirmedUi
                ? _ConfirmedAnimatedButton(
                    key: const ValueKey('confirmed_btn'),
                    scaleAnim: _confirmScale,
                    fadeAnim: _confirmFade,
                  )
                : SwipeConfirmButton(
                    key: const ValueKey('swipe_btn'),
                    enabled: !_busyConfirm && !confirmedUi,
                    label: 'Reading confirmation',
                    onConfirmed: () async {
                      // If PIN not set (should not happen due to login prompt),
                      // this fallback handles it gracefully:
                      final existing = await NotificationPinService.getPin(
                        dspUid: widget.dspUid,
                        transporterId: widget.driverTransporterId.toUpperCase(),
                      );

                      if (!mounted) return;

                      if (existing == null) {
                        await showDialog<void>(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => SetNotificationPinDialog(
                            dspUid: widget.dspUid,
                            transporterId: widget.driverTransporterId.toUpperCase(),
                            force: true,
                          ),
                        );
                      }

                      if (!mounted) return;

                      final ok = await showDialog<bool>(
                        context: context,
                        barrierDismissible: true,
                        builder: (_) => VerifyNotificationPinDialog(
                          dspUid: widget.dspUid,
                          transporterId: widget.driverTransporterId.toUpperCase(),
                        ),
                      );

                      if (ok == true) {
                        await _confirm();
                      }
                    },
                    busy: _busyConfirm,
                  ),
          ),
        ),
      ],
    );
  }
}

class _StatusPillConfirmed extends StatelessWidget {
  final bool confirmed;
  const _StatusPillConfirmed({required this.confirmed});

  @override
  Widget build(BuildContext context) {
    final Color border =
        confirmed ? const Color(0xFF1D7F5A) : const Color(0xFFE9741A);
    final Color text =
        confirmed ? const Color(0xFF1D7F5A) : const Color(0xFFE9741A);

    final String label = confirmed ? 'confirmed' : 'confirmation required';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border, width: 1.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: text,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ConfirmedAnimatedButton extends StatelessWidget {
  final Animation<double> scaleAnim;
  final Animation<double> fadeAnim;

  const _ConfirmedAnimatedButton({
    super.key,
    required this.scaleAnim,
    required this.fadeAnim,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnim,
      child: ScaleTransition(
        scale: scaleAnim,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF1D7F5A),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text(
                'confirmed',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// Swipe to Confirm Button (improved, professional)
// ------------------------------------------------------------
class SwipeConfirmButton extends StatefulWidget {
  final bool enabled;
  final bool busy;
  final String label;
  final Future<void> Function() onConfirmed;

  const SwipeConfirmButton({
    super.key,
    required this.enabled,
    required this.label,
    required this.onConfirmed,
    this.busy = false,
  });

  @override
  State<SwipeConfirmButton> createState() => _SwipeConfirmButtonState();
}

class _SwipeConfirmButtonState extends State<SwipeConfirmButton> {
  double _t = 0.0; // 0..1
  bool _submitting = false;
  bool _dragging = false;

  bool get _isBusy => widget.busy || _submitting;

  // Tuned to look like your designer screenshot
  static const double _h = 64;
  static const double _pad = 6;
  static const double _knobSize = _h - (_pad * 2); // perfect circle
  static const double _commitT = 0.88;

  Future<void> _commit() async {
    if (_submitting) return;
    if (!mounted) return;

    setState(() => _submitting = true);
    try {
      await widget.onConfirmed();
    } finally {
      if (!mounted) return;
      setState(() => _submitting = false);
    }
  }

  void _reset() {
    if (!mounted) return;
    setState(() {
      _t = 0.0;
      _dragging = false;
    });
  }

  void _snapEnd() {
    if (!mounted) return;
    setState(() {
      _t = 1.0;
      _dragging = false;
    });
  }

  @override
  void didUpdateWidget(covariant SwipeConfirmButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If disabled permanently (confirmed), keep knob at end
    if (!widget.enabled) {
      _snapEnd();
      return;
    }

    // If re-enabled, reset
    if (widget.enabled && !oldWidget.enabled) {
      _reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled && !_isBusy;

    return LayoutBuilder(
      builder: (ctx, c) {
        final w = c.maxWidth;

        // Travel distance for knob (left padding to right padding)
        final maxDx = (w - (_pad * 2) - _knobSize).clamp(0.0, double.infinity);
        final dx = _pad + (maxDx * _t);

        final trackBorder = const Color(0xFFD1D5DB);
        final trackBg = Colors.white;

        // Green fill under the track to match the screenshot vibe
        final fillW = (_pad + _knobSize + (maxDx * _t)).clamp(0.0, w);

        // Label fades slightly as user swipes
        final labelOpacity = (1.0 - (_t * 0.55)).clamp(0.35, 1.0);

        // Right chevrons fade out as user swipes (avoids clutter)
        final chevronOpacity = (1.0 - (_t * 1.2)).clamp(0.0, 1.0);

        return AnimatedOpacity(
          duration: const Duration(milliseconds: 160),
          opacity: widget.enabled ? 1.0 : 0.65,
          child: Container(
            height: _h,
            decoration: BoxDecoration(
              color: trackBg,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: trackBorder, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Green "fill" behind the knob
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 80),
                      width: fillW,
                      height: _h,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D7F5A).withOpacity(0.12),
                      ),
                    ),
                  ),

                  // Center label (always centered)
                  IgnorePointer(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 80),
                      opacity: labelOpacity,
                      child: Text(
                        widget.label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),

                  // Right chevrons hint (fades out as you drag)
                  Positioned(
                    right: 18,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 80),
                      opacity: chevronOpacity,
                      child: const Icon(
                        Icons.keyboard_double_arrow_right,
                        size: 36,
                        color: Color(0xFFD1D5DB),
                      ),
                    ),
                  ),

                  // Draggable knob
                  Positioned(
                    left: dx,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragStart: !enabled
                          ? null
                          : (_) => setState(() => _dragging = true),
                      onHorizontalDragUpdate: !enabled
                          ? null
                          : (d) {
                              final denom = (maxDx == 0 ? 1 : maxDx);
                              final next =
                                  (_t + (d.delta.dx / denom)).clamp(0.0, 1.0);
                              setState(() => _t = next);
                            },
                      onHorizontalDragEnd: !enabled
                          ? null
                          : (_) async {
                              if (_t >= _commitT) {
                                _snapEnd();
                                await _commit();

                                // If still enabled after commit (backend failed), reset
                                if (mounted && widget.enabled) _reset();
                              } else {
                                _reset();
                              }
                            },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 140),
                        curve: Curves.easeOut,
                        width: _knobSize,
                        height: _knobSize,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1D7F5A),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                _dragging ? 0.14 : 0.10,
                              ),
                              blurRadius: _dragging ? 18 : 14,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: _isBusy
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.keyboard_double_arrow_right,
                                  size: 34,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
