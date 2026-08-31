import 'package:flutter_test/flutter_test.dart';
import 'package:ruqyahhealing/main.dart';

void main() {
  testWidgets(
      'Full flow test: SplashScreen -> LanguageOnboarding -> Onboarding 1, 2, 3 -> SignInScreen -> SignUpScreen',
      (WidgetTester tester) async {
    // 1. Launch App
    await tester.pumpWidget(const RuqyahHealingApp());
    await tester.pump(const Duration(milliseconds: 500));

    // 2. Verify Splash Screen elements
    expect(find.text('RUQYAH HEALING'), findsOneWidget);
    expect(find.text('Faith, Care & Wellbeing'), findsOneWidget);

    // 3. Advance clock by 5+ seconds for auto-transition
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    // 4. Verify Language Onboarding Screen elements
    expect(find.text('WELCOME TO'), findsOneWidget);
    expect(find.text('Choose your language'), findsOneWidget);
    expect(find.text('English'), findsWidgets);
    expect(find.text('বাংলা'), findsOneWidget);
    expect(find.text('العربية'), findsOneWidget);
    expect(find.text('فارسی'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);

    // 5. Tap Continue to navigate to OnboardingScreen1
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // 6. Verify OnboardingScreen1 elements
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('AUTHENTIC HEALING'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    // 7. Tap Next to navigate to OnboardingScreen2
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // 8. Verify OnboardingScreen2 elements
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('YOUR SPIRITUAL\nJOURNEY'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    // 9. Tap Next to navigate to OnboardingScreen3
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // 10. Verify OnboardingScreen3 elements
    expect(find.text('TRUSTED COMMUNITY'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);

    // 11. Tap Get Started to navigate to SignInScreen
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    // 12. Verify SignInScreen elements
    expect(find.text('SIGN IN TO YOUR ACCOUNT'), findsOneWidget);
    expect(
      find.text("We'll send a verification code to your phone."),
      findsOneWidget,
    );
    expect(find.text('Phone Number'), findsOneWidget);
    expect(find.text('Send OTP'), findsOneWidget);
    expect(find.text('OTP Code'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);

    // 13. Tap Sign Up to navigate to SignUpScreen
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    // 14. Verify SignUpScreen elements
    expect(find.text('CREATE YOUR ACCOUNT'), findsOneWidget);
    expect(
      find.text('Join us to start your spiritual and physical wellness journey.'),
      findsOneWidget,
    );
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}
