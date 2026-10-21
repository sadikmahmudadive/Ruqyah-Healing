import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/animations/animations.dart';
import '../widgets/onboarding_layout.dart';
import 'onboarding_screen_2.dart';
import 'onboarding_screen_3.dart';

class OnboardingScreen1 extends StatelessWidget {
  final VoidCallback? onNext;
  final VoidCallback? onSkip;

  const OnboardingScreen1({super.key, this.onNext, this.onSkip});

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(
      AppPageRoute.fade(page, duration: const Duration(milliseconds: 600)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingLayout(
      background: const OnboardingImageBackground(
        'assets/background/bg_onboarding_1.jpg',
      ),
      title: 'AUTHENTIC\nHEALING',
      description:
          'Discover Ruqyah, Hijama, and Acupuncture guided by qualified scholars and certified clinical therapists.',
      step: 0,
      ctaLabel: 'Next',
      onCta: () {
        HapticFeedback.lightImpact();
        onNext != null ? onNext!() : _push(context, const OnboardingScreen2());
      },
      onSkip: () {
        HapticFeedback.selectionClick();
        onSkip != null ? onSkip!() : _push(context, const OnboardingScreen3());
      },
    );
  }
}
