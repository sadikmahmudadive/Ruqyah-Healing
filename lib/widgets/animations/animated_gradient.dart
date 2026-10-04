import 'package:flutter/material.dart';

/// A slowly flowing linear gradient background.
///
/// The gradient's start/end alignments drift in a figure-eight so the
/// surface feels alive without being distracting. Use behind hero
/// headers and feature cards.
///
/// Example:
///   AnimatedFlowingGradient(
///     colors: [green, deepGreen, teal],
///     child: _heroContent(),
///   )
class AnimatedFlowingGradient extends StatefulWidget {
  final List<Color> colors;
  final Widget? child;
  final Duration duration;
  final BorderRadius? borderRadius;
  final List<double>? stops;

  const AnimatedFlowingGradient({
    super.key,
    required this.colors,
    this.child,
    this.duration = const Duration(seconds: 8),
    this.borderRadius,
    this.stops,
  });

  @override
  State<AnimatedFlowingGradient> createState() =>
      _AnimatedFlowingGradientState();
}

class _AnimatedFlowingGradientState extends State<AnimatedFlowingGradient>
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
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final t = _ctrl.value * 2 * 3.14159;
        // Figure-eight-ish drift of begin + end points
        final beginX = 0.5 * (1 + 0.6 * _sin(t));
        final beginY = 0.5 * (1 + 0.6 * _cos(t * 0.7));
        final endX = 0.5 * (1 - 0.6 * _sin(t * 0.9));
        final endY = 0.5 * (1 - 0.6 * _cos(t));
        return Container(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment(beginX * 2 - 1, beginY * 2 - 1),
              end: Alignment(endX * 2 - 1, endY * 2 - 1),
              colors: widget.colors,
              stops: widget.stops,
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }

  double _sin(double x) => _taylorSin(x);
  double _cos(double x) => _taylorSin(x + 1.5708);

  double _taylorSin(double x) {
    // Keep x in [-pi, pi] for stability
    const twoPi = 6.28318;
    x = x % twoPi;
    if (x > 3.14159) x -= twoPi;
    final x2 = x * x;
    return x - x * x2 / 6 + x * x2 * x2 / 120 - x * x2 * x2 * x2 / 5040;
  }
}

/// Small moving-shine overlay. Place on top of a gradient hero to add
/// a sweeping highlight. Non-interactive — passes taps through.
class ShineOverlay extends StatefulWidget {
  final Duration duration;
  final double opacity;
  final BorderRadius? borderRadius;

  const ShineOverlay({
    super.key,
    this.duration = const Duration(seconds: 5),
    this.opacity = 0.15,
    this.borderRadius,
  });

  @override
  State<ShineOverlay> createState() => _ShineOverlayState();
}

class _ShineOverlayState extends State<ShineOverlay>
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
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final t = _ctrl.value;
          return ClipRRect(
            borderRadius: widget.borderRadius ?? BorderRadius.zero,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-1 - 2 * (1 - t), -1),
                  end: Alignment(1 - 2 * (1 - t), 1),
                  colors: [
                    Colors.white.withValues(alpha: 0),
                    Colors.white.withValues(alpha: widget.opacity),
                    Colors.white.withValues(alpha: 0),
                  ],
                  stops: const [0.35, 0.5, 0.65],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
