import 'package:flutter/material.dart';

/// A gently breathing pulse — scale oscillates 1.0 ↔ [maxScale].
///
/// Use for "active now", "live" indicators, breathing meditation dots,
/// and the active prayer-time slot.
///
/// Example:
///   BreathingPulse(child: _liveDot())
class BreathingPulse extends StatefulWidget {
  final Widget child;
  final double maxScale;
  final Duration duration;

  const BreathingPulse({
    super.key,
    required this.child,
    this.maxScale = 1.08,
    this.duration = const Duration(milliseconds: 1800),
  });

  @override
  State<BreathingPulse> createState() => _BreathingPulseState();
}

class _BreathingPulseState extends State<BreathingPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: widget.maxScale)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutSine));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _scale, child: widget.child);
  }
}

/// An expanding + fading ring behind a widget. Great for live indicators,
/// voice recorder buttons, notification bells with unread activity.
class PulseRing extends StatefulWidget {
  final Widget child;
  final Color color;
  final double maxRadius;
  final Duration duration;
  final int ringCount;

  const PulseRing({
    super.key,
    required this.child,
    required this.color,
    this.maxRadius = 36,
    this.duration = const Duration(milliseconds: 1600),
    this.ringCount = 2,
  });

  @override
  State<PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<PulseRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        for (int i = 0; i < widget.ringCount; i++)
          AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) {
              final phase =
                  ((_ctrl.value + i / widget.ringCount) % 1.0).clamp(0.0, 1.0);
              final radius = widget.maxRadius * phase;
              final opacity = (1 - phase) * 0.5;
              return IgnorePointer(
                child: Container(
                  width: radius * 2,
                  height: radius * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withValues(alpha: opacity),
                  ),
                ),
              );
            },
          ),
        widget.child,
      ],
    );
  }
}
