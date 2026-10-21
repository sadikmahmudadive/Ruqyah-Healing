import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/animations/animations.dart';
import '../widgets/onboarding_layout.dart';
import 'signin_screen.dart';

class OnboardingScreen3 extends StatelessWidget {
  final VoidCallback? onGetStarted;

  const OnboardingScreen3({super.key, this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    return OnboardingLayout(
      background: const OnboardingImageBackground(
        'assets/background/bg_onboarding_3.jpg',
      ),
      strongScrim: true,
      title: 'TRUSTED\nCOMMUNITY',
      description:
          'Connect with verified therapists, book physical or digital consultations, and join a supportive faith-based wellness community.',
      step: 2,
      ctaLabel: 'Get Started',
      onCta: () {
        HapticFeedback.lightImpact();
        if (onGetStarted != null) {
          onGetStarted!();
        } else {
          Navigator.of(context).pushReplacement(
            AppPageRoute.fade(
              const SignInScreen(),
              duration: const Duration(milliseconds: 600),
            ),
          );
        }
      },
    );
  }
}
