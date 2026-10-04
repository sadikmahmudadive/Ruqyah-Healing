import 'package:flutter/material.dart';

import 'motion.dart';

/// Fades + slides a child in from a direction when it mounts.
///
/// Default is a 12px upward slide with a fade — the de-facto modern "soft
/// entrance" look. Combine with [delay] for staggered lists.
///
/// Example:
///   FadeSlideIn(
///     delay: Duration(milliseconds: 120),
///     child: MyCard(),
///   )
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Offset beginOffset;
  final Curve curve;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.delay = Duration.zero,
    this.beginOffset = const Offset(0, 0.08),
    this.curve = AppMotion.standard,
  });

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _fade = CurvedAnimation(parent: _ctrl, curve: widget.curve);
    _slide = Tween<Offset>(begin: widget.beginOffset, end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: widget.curve));

    if (widget.delay == Duration.zero) {
      _ctrl.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _ctrl.forward();
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

/// Wraps a list of children so they enter one after another.
///
/// Each child gets a [FadeSlideIn] with its index multiplied by
/// [AppMotion.staggerStep] as the delay. Use for feed-like lists and
/// card grids on first render.
class StaggeredColumn extends StatelessWidget {
  final List<Widget> children;
  final Duration stagger;
  final Duration itemDuration;
  final Offset beginOffset;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;

  const StaggeredColumn({
    super.key,
    required this.children,
    this.stagger = AppMotion.staggerStep,
    this.itemDuration = const Duration(milliseconds: 500),
    this.beginOffset = const Offset(0, 0.08),
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: [
        for (int i = 0; i < children.length; i++)
          FadeSlideIn(
            delay: stagger * i,
            duration: itemDuration,
            beginOffset: beginOffset,
            child: children[i],
          ),
      ],
    );
  }
}

/// Horizontal variant for scrolling rows.
class StaggeredRow extends StatelessWidget {
  final List<Widget> children;
  final Duration stagger;
  final Duration itemDuration;
  final Offset beginOffset;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;

  const StaggeredRow({
    super.key,
    required this.children,
    this.stagger = AppMotion.staggerStep,
    this.itemDuration = const Duration(milliseconds: 500),
    this.beginOffset = const Offset(0.1, 0),
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: [
        for (int i = 0; i < children.length; i++)
          FadeSlideIn(
            delay: stagger * i,
            duration: itemDuration,
            beginOffset: beginOffset,
            child: children[i],
          ),
      ],
    );
  }
}

/// Scales a child up from 0.9 → 1.0 while fading in.
///
/// Nice for hero-ish entrances (dialogs, success states, feature cards).
class ScaleFadeIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final double beginScale;
  final Curve curve;

  const ScaleFadeIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 450),
    this.delay = Duration.zero,
    this.beginScale = 0.9,
    this.curve = AppMotion.standard,
  });

  @override
  State<ScaleFadeIn> createState() => _ScaleFadeInState();
}

class _ScaleFadeInState extends State<ScaleFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _fade = CurvedAnimation(parent: _ctrl, curve: widget.curve);
    _scale = Tween<double>(begin: widget.beginScale, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: widget.curve));

    if (widget.delay == Duration.zero) {
      _ctrl.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _ctrl.forward();
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
