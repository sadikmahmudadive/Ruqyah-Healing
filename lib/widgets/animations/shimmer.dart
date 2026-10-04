import 'package:flutter/material.dart';

/// A shimmering placeholder box for loading skeletons.
///
/// A soft gradient sweeps left-to-right across a tinted base. Pair with
/// a rounded container to replace a card that is still loading.
///
/// Example:
///   isLoading
///     ? ShimmerBox(width: 160, height: 20, radius: 6)
///     : Text(name)
class ShimmerBox extends StatefulWidget {
  final double? width;
  final double? height;
  final double radius;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.radius = 12,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = widget.baseColor ??
        (isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.06));
    final highlight = widget.highlightColor ??
        (isDark
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.55));

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final progress = _ctrl.value;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-1 - 2 * progress, 0),
              end: Alignment(1 - 2 * progress, 0),
              colors: [base, highlight, base],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// Convenience preset: a card-shaped skeleton with a title + 2 lines.
class ShimmerCardSkeleton extends StatelessWidget {
  final double height;
  final EdgeInsets padding;
  final double radius;

  const ShimmerCardSkeleton({
    super.key,
    this.height = 120,
    this.padding = const EdgeInsets.all(16),
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ShimmerBox(width: 140, height: 14, radius: 4),
          ShimmerBox(width: double.infinity, height: 12, radius: 4),
          ShimmerBox(width: 200, height: 12, radius: 4),
        ],
      ),
    );
  }
}
