import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/animations/animations.dart';
import '../widgets/onboarding_layout.dart';
import 'onboarding_screen_3.dart';

class OnboardingScreen2 extends StatelessWidget {
  final VoidCallback? onNext;
  final VoidCallback? onSkip;

  const OnboardingScreen2({super.key, this.onNext, this.onSkip});

  void _toLast(BuildContext context) {
    Navigator.of(context).push(
      AppPageRoute.fade(
        const OnboardingScreen3(),
        duration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingLayout(
      background: const OnboardingImageBackground(
        'assets/background/bg_onboarding_2.jpg',
      ),
      title: 'YOUR SPIRITUAL\nJOURNEY',
      description:
          'Track your progress, attend live sessions, and access a curated audio library of serene prophetic recitations.',
      step: 1,
      ctaLabel: 'Next',
      onCta: () {
        HapticFeedback.lightImpact();
        onNext != null ? onNext!() : _toLast(context);
      },
      onSkip: () {
        HapticFeedback.selectionClick();
        onSkip != null ? onSkip!() : _toLast(context);
      },
    );
  }
}
