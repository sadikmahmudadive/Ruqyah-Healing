import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruqyahhealing/screens/tabs/services_tab.dart';
import 'package:ruqyahhealing/theme/app_theme.dart';

Future<void> _pump(WidgetTester tester, Size size, {bool dark = false}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
      home: const ServicesTab(),
    ),
  );
  // Let the staggered entrance finish; the gradient loops forever, so
  // pumpAndSettle would never return.
  await tester.pump(const Duration(seconds: 2));
}

void main() {
  // A flutter overflow shows up as a test exception, so building at awkward
  // widths is the check that the bento tiles always fit their content.
  for (final w in [320.0, 360.0, 390.0, 430.0]) {
    testWidgets('bento grid lays out without overflow at ${w.toInt()}px', (
      tester,
    ) async {
      await _pump(tester, Size(w, 900));
      expect(tester.takeException(), isNull);
      expect(find.byType(ServicesTab), findsOneWidget);
    });
  }

  testWidgets('bento grid also fits in dark mode on a small phone', (
    tester,
  ) async {
    await _pump(tester, const Size(320, 700), dark: true);
    expect(tester.takeException(), isNull);
  });

  testWidgets('every service is reachable by scrolling', (tester) async {
    await _pump(tester, const Size(390, 700));
    final list = find.byType(Scrollable).first;
    for (var i = 0; i < 12; i++) {
      await tester.drag(list, const Offset(0, -400));
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(tester.takeException(), isNull);
  });
}
