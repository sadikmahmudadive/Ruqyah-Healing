import 'package:flutter/material.dart';

import 'motion.dart';

/// Reveals a child by cross-fading between two values of the same widget.
///
/// Perfect for state swaps where you don't want a hard jump (number
/// changes, badge appearance, status chip flips).
class SwapReveal extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const SwapReveal({
    super.key,
    required this.child,
    this.duration = AppMotion.base,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: AppMotion.smooth,
      switchOutCurve: AppMotion.exit,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Fades + slides between two layouts.
///
/// Use when a card's interior changes shape (empty → filled, loading →
/// loaded) and you want a smooth morph rather than a jump cut.
class CrossfadeSwap extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const CrossfadeSwap({
    super.key,
    required this.child,
    this.duration = AppMotion.base,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: AppMotion.smooth,
      switchOutCurve: AppMotion.exit,
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      child: child,
    );
  }
}
