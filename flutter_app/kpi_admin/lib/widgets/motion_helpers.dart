// lib/widgets/motion_helpers.dart
//
// Wiederverwendbare Motion-Primitives nach Emil-Kowalski-Pattern.
// Verwendet von:
//   • Driver Cotimer (Wochen-Strip Stagger)
//   • Driver Home (Card Stagger + Press-Feedback)
//   • Zeitkonto Übersicht (Monats-Zeilen Stagger)
//
// Regeln:
//   • Duration 150–400 ms (nie länger)
//   • Spring-Physik für user-getriggerte Bewegung
//   • Crossfade + leichter Scale für state morphs
//   • Stagger 30–50 ms je Item, kumulativ max 300 ms

import 'package:flutter/material.dart';

/// Mountet [child] mit Fade + leichter Aufwärtsbewegung, verzögert um
/// [delay]. Curve: easeOutCubic. Nutzt 260 ms Duration.
///
/// In Listen typischerweise mit `delay = Duration(milliseconds: 40 * i)`
/// für `i = 0..n` aufgerufen — bis max 300 ms kumulativ.
class StaggeredFadeIn extends StatefulWidget {
  final Duration delay;
  final Duration duration;
  final double slideOffsetY;
  final Widget child;

  const StaggeredFadeIn({
    super.key,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 260),
    this.slideOffsetY = 0.10,
    required this.child,
  });

  @override
  State<StaggeredFadeIn> createState() => _StaggeredFadeInState();
}

class _StaggeredFadeInState extends State<StaggeredFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.duration);
    _opacity = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: Offset(0, widget.slideOffsetY),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
    Future.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

/// Tap-Feedback nach Apple-HIG: scale down auf 0.97 beim Press, beim
/// Release spring-zurück mit hohem Stiffness. Total < 200 ms — fühlbar
/// aber nie aufdringlich.
class PressFeedback extends StatefulWidget {
  final VoidCallback? onTap;
  final BorderRadius borderRadius;
  final Widget child;

  const PressFeedback({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  State<PressFeedback> createState() => _PressFeedbackState();
}

class _PressFeedbackState extends State<PressFeedback> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap == null
          ? null
          : (_) => setState(() => _pressed = true),
      onTapUp: widget.onTap == null
          ? null
          : (_) => setState(() => _pressed = false),
      onTapCancel: widget.onTap == null
          ? null
          : () => setState(() => _pressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        // Down: schnell (Apple HIG: ~80 ms ease-out)
        // Up: etwas länger als Down (spring-back-Feel)
        duration: _pressed
            ? const Duration(milliseconds: 80)
            : const Duration(milliseconds: 160),
        curve: _pressed ? Curves.easeOut : Curves.easeOutBack,
        child: widget.child,
      ),
    );
  }
}
