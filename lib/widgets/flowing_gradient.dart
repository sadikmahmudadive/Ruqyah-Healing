import 'package:flutter/material.dart';

/// A gradient that drifts very slowly, so a hero surface feels alive without
/// asking for attention.
///
/// The colours never change, only the angle they are laid across the box, over
/// [period]. It sits in its own repaint boundary and stands still when the
/// device asks for reduced motion.
class FlowingGradient extends StatefulWidget {
  final List<Color> colors;
  final Widget? child;
  final BorderRadius? borderRadius;
  final Duration period;

  /// How far the gradient's end points travel, in alignment units (0 = none).
  final double drift;

  const FlowingGradient({
    super.key,
    required this.colors,
    this.child,
    this.borderRadius,
    this.period = const Duration(seconds: 14),
    this.drift = 0.6,
  });

  @override
  State<FlowingGradient> createState() => _FlowingGradientState();
}

class _FlowingGradientState extends State<FlowingGradient>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.period);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        child: widget.child,
        builder: (context, child) {
          final t = Curves.easeInOut.transform(_c.value);
          final d = widget.drift;
          return DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius,
              gradient: LinearGradient(
                begin: Alignment(-1 + d * t, -1 + d * (1 - t)),
                end: Alignment(1 - d * t, 1 - d * (1 - t)),
                colors: widget.colors,
              ),
            ),
            child: child,
          );
        },
      ),
    );
  }
}
