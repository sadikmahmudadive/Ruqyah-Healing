import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'motion.dart';

/// Wraps any tappable element with:
///   - a snappy 0.97× press-scale (standard iOS "squish" feel)
///   - selection haptic on tap down
///   - a soft 0→1 overlay for extra tactile feedback
///
/// Prefer this over wrapping buttons in Material/InkWell when you want
/// a clean borderless press feel on custom cards.
///
/// Example:
///   PressScale(
///     onTap: () => _openDetails(),
///     child: MyCard(),
///   )
class PressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scale;
  final Duration duration;
  final bool hapticOnTap;
  final HapticFeedbackType hapticType;
  final HitTestBehavior behavior;

  const PressScale({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scale = 0.97,
    this.duration = AppMotion.fast,
    this.hapticOnTap = true,
    this.hapticType = HapticFeedbackType.selection,
    this.behavior = HitTestBehavior.opaque,
  });

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: widget.duration,
      reverseDuration: const Duration(milliseconds: 220),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: widget.scale)
        .animate(CurvedAnimation(parent: _ctrl, curve: AppMotion.standard));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _handleTapDown(_) {
    _ctrl.forward();
    if (widget.hapticOnTap) {
      switch (widget.hapticType) {
        case HapticFeedbackType.selection:
          HapticFeedback.selectionClick();
          break;
        case HapticFeedbackType.light:
          HapticFeedback.lightImpact();
          break;
        case HapticFeedbackType.medium:
          HapticFeedback.mediumImpact();
          break;
        case HapticFeedbackType.heavy:
          HapticFeedback.heavyImpact();
          break;
      }
    }
  }

  void _handleTapUp(_) => _ctrl.reverse();
  void _handleTapCancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.behavior,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onTapDown: widget.onTap == null ? null : _handleTapDown,
      onTapUp: widget.onTap == null ? null : _handleTapUp,
      onTapCancel: widget.onTap == null ? null : _handleTapCancel,
      child: ScaleTransition(scale: _scaleAnim, child: widget.child),
    );
  }
}

enum HapticFeedbackType { selection, light, medium, heavy }
