import 'package:flutter/material.dart';

import '../../localization/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../animations/motion.dart';

enum LearnSide { learn, courses }

/// A two-option sliding control that flips between the free Learn lessons and
/// the paid Courses. The thumb moves with a transform only, and does not move
/// at all when the platform asks for reduced motion.
class LearnSwitch extends StatelessWidget {
  const LearnSwitch({super.key, required this.side, required this.onChanged});

  final LearnSide side;
  final ValueChanged<LearnSide> onChanged;

  static const double _minTapHeight = 44;
  static const double _inset = 4;

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final duration = reduceMotion ? Duration.zero : AppMotion.base;
    final dx = side == LearnSide.courses ? (rtl ? -1.0 : 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(_inset),
      decoration: BoxDecoration(
        color: context.isDarkMode
            ? Colors.white.withValues(alpha: 0.04)
            : AppColors.lightContainerBg,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: context.cardBorder, width: 1),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                heightFactor: 1,
                child: AnimatedSlide(
                  offset: Offset(dx, 0),
                  duration: duration,
                  curve: AppMotion.standard,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _Option(
                  text: context.tr('learn'),
                  semanticLabel: context.tr('learn_side_free'),
                  selected: side == LearnSide.learn,
                  duration: duration,
                  onTap: () => onChanged(LearnSide.learn),
                ),
              ),
              Expanded(
                child: _Option(
                  text: context.tr('courses'),
                  semanticLabel: context.tr('courses_side_paid'),
                  selected: side == LearnSide.courses,
                  duration: duration,
                  onTap: () => onChanged(LearnSide.courses),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.text,
    required this.semanticLabel,
    required this.selected,
    required this.duration,
    required this.onTap,
  });

  final String text;
  final String semanticLabel;
  final bool selected;
  final Duration duration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: LearnSwitch._minTapHeight,
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: AnimatedDefaultTextStyle(
                duration: duration,
                curve: AppMotion.standard,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : context.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                child: Text(text),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
