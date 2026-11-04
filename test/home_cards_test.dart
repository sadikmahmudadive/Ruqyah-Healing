import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruqyahhealing/screens/tabs/home_tab.dart';
import 'package:ruqyahhealing/theme/app_theme.dart';
import 'package:ruqyahhealing/widgets/modern_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final width in [320.0, 360.0, 412.0]) {
    testWidgets('Health Index and Next Appointment cards match in height '
        '(${width.toInt()} wide)', (tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.lightTheme, home: const HomeTab()),
      );
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 1400));

      final health = find.ancestor(
        of: find.text('Health Index'),
        matching: find.byType(ModernCard),
      );
      final appointment = find.ancestor(
        of: find.byWidgetPredicate(
          (w) =>
              w is Text &&
              (w.data ?? '').toLowerCase().contains('next appointment'),
        ),
        matching: find.byType(ClipRRect),
      );
      expect(health, findsOneWidget);
      expect(appointment, findsWidgets);

      final h = tester.getSize(health.first).height;
      final a = tester.getSize(appointment.first).height;
      expect(a, closeTo(h, 0.5), reason: 'health $h vs appointment $a');

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
      tester.takeException();
    });
  }
}
