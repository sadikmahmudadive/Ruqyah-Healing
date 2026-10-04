import 'dart:math' as math;

import 'package:flutter/cupertino.dart' show CupertinoSliverRefreshControl, RefreshIndicatorMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_theme.dart';
import 'motion.dart';

/// Pull-down-to-refresh sliver with an animated crescent icon.
///
/// Place it as the FIRST sliver of a [CustomScrollView] whose physics
/// allow overscroll at the top (e.g. `BouncingScrollPhysics`):
///
///   CustomScrollView(
///     physics: const BouncingScrollPhysics(
///       parent: AlwaysScrollableScrollPhysics(),
///     ),
///     slivers: [
///       AppRefreshSliver(onRefresh: _reload),
///       ...
///     ],
///   )
///
/// While pulling, a ring fills and the crescent turns with the finger.
/// Past the trigger distance it "arms" (small haptic + pop). Release and the
/// ring spins until [onRefresh] completes, then a check mark pops in and the
/// header folds away.
class AppRefreshSliver extends StatelessWidget {
  final Future<void> Function() onRefresh;

  /// Pull distance (px) at which releasing starts a refresh.
  final double triggerDistance;

  /// Height the header holds while refreshing.
  final double indicatorExtent;

  const AppRefreshSliver({
    super.key,
    required this.onRefresh,
    this.triggerDistance = 88,
    this.indicatorExtent = 64,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoSliverRefreshControl(
      onRefresh: onRefresh,
      refreshTriggerPullDistance: triggerDistance,
      refreshIndicatorExtent: indicatorExtent,
      builder: (context, mode, pulledExtent, triggerDist, extent) {
        return _RefreshHeader(
          mode: mode,
          pulledExtent: pulledExtent,
          triggerDistance: triggerDist,
        );
      },
    );
  }
}

class _RefreshHeader extends StatefulWidget {
  final RefreshIndicatorMode mode;
  final double pulledExtent;
  final double triggerDistance;

  const _RefreshHeader({
    required this.mode,
    required this.pulledExtent,
    required this.triggerDistance,
  });

  @override
  State<_RefreshHeader> createState() => _RefreshHeaderState();
}

class _RefreshHeaderState extends State<_RefreshHeader>
    with TickerProviderStateMixin {
  static const double _size = 40;

  // Continuous spin while refreshing.
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  // One-shot pop when the pull is armed and when it completes.
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: AppMotion.slow,
  );

  @override
  void didUpdateWidget(covariant _RefreshHeader old) {
    super.didUpdateWidget(old);
    if (old.mode == widget.mode) return;

    switch (widget.mode) {
      case RefreshIndicatorMode.armed:
        HapticFeedback.lightImpact();
        _pop.forward(from: 0);
      case RefreshIndicatorMode.refresh:
        _spin.repeat();
      case RefreshIndicatorMode.done:
        _spin.stop();
        _pop.forward(from: 0);
      case RefreshIndicatorMode.inactive:
      case RefreshIndicatorMode.drag:
        _spin.stop();
        _spin.value = 0;
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mode = widget.mode;
    final pull = (widget.pulledExtent / widget.triggerDistance).clamp(0.0, 1.0);
    final color = context.isDarkMode
        ? AppColors.accentGold
        : AppColors.primaryGreen;
    final refreshing = mode == RefreshIndicatorMode.refresh;
    final done = mode == RefreshIndicatorMode.done;

    return ClipRect(
      child: OverflowBox(
        minHeight: 0,
        maxHeight: _size + 8,
        alignment: Alignment.center,
        child: AnimatedBuilder(
          animation: Listenable.merge([_spin, _pop]),
          builder: (context, _) {
            // Fade and grow in over the first part of the pull.
            final appear = Curves.easeOut.transform((pull * 1.6).clamp(0.0, 1.0));

            // Small overshoot "pop" on armed / done.
            final pop = (mode == RefreshIndicatorMode.armed || done)
                ? 1 + 0.16 * math.sin(_pop.value * math.pi)
                : 1.0;

            final scale = (0.5 + 0.5 * appear) * pop;

            return Opacity(
              opacity: appear,
              child: Transform.scale(
                scale: scale,
                child: SizedBox(
                  width: _size,
                  height: _size,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.cardBg,
                          border: Border.all(color: context.cardBorder),
                        ),
                      ),
                      CustomPaint(
                        size: const Size.square(_size),
                        painter: _RingPainter(
                          color: color,
                          // Fills with the pull, then becomes a rotating arc.
                          progress: refreshing ? 0.28 : (done ? 1.0 : pull),
                          rotation: refreshing ? _spin.value * 2 * math.pi : 0,
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: AppMotion.base,
                        switchInCurve: AppMotion.expressive,
                        transitionBuilder: (child, anim) => ScaleTransition(
                          scale: anim,
                          child: FadeTransition(opacity: anim, child: child),
                        ),
                        child: done
                            ? Icon(
                                Icons.check_rounded,
                                key: const ValueKey('done'),
                                size: 20,
                                color: color,
                              )
                            : Transform.rotate(
                                key: const ValueKey('moon'),
                                // Turns with the finger, then counter-spins
                                // slowly so the moon stays calm in the ring.
                                angle: refreshing
                                    ? -_spin.value * math.pi
                                    : pull * math.pi,
                                child: Icon(
                                  Icons.nightlight_round,
                                  size: 19,
                                  color: color,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final Color color;
  final double progress; // 0..1 of a full circle
  final double rotation; // radians

  _RingPainter({
    required this.color,
    required this.progress,
    required this.rotation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 2.6;
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(stroke / 2 + 1);

    canvas.drawArc(
      arcRect,
      0,
      2 * math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = color.withValues(alpha: 0.14),
    );

    if (progress <= 0) return;
    canvas.drawArc(
      arcRect,
      -math.pi / 2 + rotation,
      2 * math.pi * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.color != color ||
      old.progress != progress ||
      old.rotation != rotation;
}
