import 'package:flutter/material.dart';

import 'motion.dart';

/// Animates a number counting from an old value to a new one.
///
/// Perfect for KPI numbers ("78" health score, cart item count, points).
/// Uses [TweenAnimationBuilder] so it survives rebuilds correctly.
///
/// Example:
///   AnimatedCounter(
///     value: healthScore,
///     style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
///   )
class AnimatedCounter extends StatelessWidget {
  final num value;
  final TextStyle? style;
  final int fractionDigits;
  final Duration duration;
  final Curve curve;
  final String prefix;
  final String suffix;
  final TextAlign? textAlign;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.fractionDigits = 0,
    this.duration = const Duration(milliseconds: 900),
    this.curve = AppMotion.smooth,
    this.prefix = '',
    this.suffix = '',
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      builder: (context, v, _) {
        final formatted = fractionDigits == 0
            ? v.round().toString()
            : v.toStringAsFixed(fractionDigits);
        return Text(
          '$prefix$formatted$suffix',
          style: style,
          textAlign: textAlign,
        );
      },
    );
  }
}

/// Animates a 0..1 bar fill. Use for progress and KPI bars.
class AnimatedBarFill extends StatelessWidget {
  final double value;
  final double height;
  final Color color;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final Duration duration;

  const AnimatedBarFill({
    super.key,
    required this.value,
    this.height = 6,
    required this.color,
    this.backgroundColor,
    this.borderRadius,
    this.duration = const Duration(milliseconds: 900),
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(height / 2);
    final bg = backgroundColor ??
        (Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.06));

    return ClipRRect(
      borderRadius: radius,
      child: Stack(
        children: [
          Container(height: height, color: bg),
          TweenAnimationBuilder<double>(
            duration: duration,
            curve: AppMotion.smooth,
            tween: Tween<double>(begin: 0, end: value.clamp(0.0, 1.0)),
            builder: (context, v, _) {
              return FractionallySizedBox(
                widthFactor: v,
                child: Container(
                  height: height,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: radius,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
