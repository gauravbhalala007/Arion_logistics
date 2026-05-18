import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

/// CoDriver's canonical press-feedback wrapper.
///
/// Scales [child] down to 0.97 on press in 80 ms, then springs back
/// to 1.0 over ~150 ms with a soft overshoot. Wrap any tappable Card,
/// pill, list row or chip that is NOT a [CoButton] (buttons already
/// have Material's ripple + state layer).
///
/// Per Emil Kowalski's interaction rules:
/// • Spring physics, not linear / cubic-bezier.
/// • Interruptible: tap during animation takes over instantly.
/// • Subtle: 3 % scale, not bouncy. Productivity tool, not delight surface.
class CoPressable extends StatefulWidget {
  const CoPressable({
    super.key,
    required this.child,
    required this.onTap,
    this.onLongPress,
    this.pressedScale = 0.97,
    this.borderRadius,
    this.behavior = HitTestBehavior.opaque,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double pressedScale;
  final BorderRadius? borderRadius;
  final HitTestBehavior behavior;
  final bool enabled;

  @override
  State<CoPressable> createState() => _CoPressableState();
}

class _CoPressableState extends State<CoPressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late Animation<double> _scale;

  static const _spring = SpringDescription(
    mass: 1,
    stiffness: 320,
    damping: 22,
  );

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController.unbounded(vsync: this, value: 1.0);
    _scale = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _press() {
    if (!widget.enabled || widget.onTap == null) return;
    _ctrl.animateTo(widget.pressedScale,
        duration: const Duration(milliseconds: 80), curve: Curves.easeOut);
  }

  void _release() {
    if (!widget.enabled) return;
    final sim = SpringSimulation(_spring, _ctrl.value, 1.0, 0);
    _ctrl.animateWith(sim);
  }

  @override
  Widget build(BuildContext context) {
    final tappable = widget.enabled && widget.onTap != null;
    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: tappable ? (_) => _press() : null,
      onTapCancel: tappable ? _release : null,
      onTapUp: tappable ? (_) => _release() : null,
      onTap: tappable ? widget.onTap : null,
      onLongPress: widget.enabled ? widget.onLongPress : null,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(
          scale: _scale.value,
          alignment: Alignment.center,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

/// Wraps a list of children to fade-in + slide-in with a 40 ms stagger.
/// Drop-in replacement for `Column(children: [...])` or list bodies.
/// Stops staggering after 8 items so long lists don't feel sluggish —
/// per Emil's "cap cumulative stagger at ~300 ms" rule.
class CoStaggerList extends StatelessWidget {
  const CoStaggerList({
    super.key,
    required this.children,
    this.stagger = const Duration(milliseconds: 40),
    this.maxStagger = const Duration(milliseconds: 320),
    this.duration = const Duration(milliseconds: 280),
  });

  final List<Widget> children;
  final Duration stagger;
  final Duration maxStagger;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < children.length; i++)
          _StaggeredItem(
            key: ValueKey(i),
            delay: Duration(
              milliseconds:
                  (stagger.inMilliseconds * i).clamp(0, maxStagger.inMilliseconds),
            ),
            duration: duration,
            child: children[i],
          ),
      ],
    );
  }
}

class _StaggeredItem extends StatefulWidget {
  const _StaggeredItem({
    super.key,
    required this.delay,
    required this.duration,
    required this.child,
  });

  final Duration delay;
  final Duration duration;
  final Widget child;

  @override
  State<_StaggeredItem> createState() => _StaggeredItemState();
}

class _StaggeredItemState extends State<_StaggeredItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: widget.duration);

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(fade);
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: widget.child),
    );
  }
}

/// Canonical state morph: crossfade with a 0.96→1.0 scale-in on the
/// new child, 200 ms, ease-out/ease-in. Use whenever a region swaps
/// between idle ↔ loaded ↔ empty ↔ error.
class CoStateSwitcher extends StatelessWidget {
  const CoStateSwitcher({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 200),
  });

  final Widget child;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1.0).animate(anim),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
