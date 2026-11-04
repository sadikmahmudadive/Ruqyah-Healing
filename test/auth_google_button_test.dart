import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruqyahhealing/theme/app_theme.dart';
import 'package:ruqyahhealing/widgets/auth_ui.dart';

void main() {
  testWidgets('Google button fills the width and centres its label', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                AuthButton(label: 'Sign In', onPressed: () {}),
                const SizedBox(height: 12),
                AuthGoogleButton(
                  label: 'Continue with Google',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final signIn = tester.getRect(find.byType(AuthButton));
    final google = tester.getRect(find.byType(AuthGoogleButton));
    expect(google.width, signIn.width);

    final label = tester.getCenter(find.text('Continue with Google'));
    expect(label.dx, closeTo(google.center.dx, 0.5));
  });

  testWidgets('divider text is centred in the row', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: Padding(
            padding: EdgeInsets.all(24),
            child: AuthDivider('or continue with'),
          ),
        ),
      ),
    );

    final row = tester.getRect(find.byType(AuthDivider));
    final label = tester.getCenter(find.text('or continue with'));
    expect(label.dx, closeTo(row.center.dx, 0.5));
  });
}
