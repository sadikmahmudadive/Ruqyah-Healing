import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruqyahhealing/screens/acupuncture_point_map_screen.dart';

void main() {
  testWidgets(
      'AcupuncturePointMapScreen renders core UI controls, layers, and categories',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AcupuncturePointMapScreen(),
      ),
    );

    // Initial pump
    await tester.pump();

    // Verify Title and Subtitle in Header
    expect(find.text('3D Anatomy Pain Map'), findsOneWidget);
    expect(find.text('Tap the model where you feel discomfort'), findsOneWidget);

    // Verify Layer Segmented Controls
    expect(find.text('Surface Body'), findsOneWidget);
    expect(find.text('Skeleton'), findsOneWidget);
    expect(find.text('Organs'), findsWidgets);

    // Verify Quick Category Chips
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Head'), findsOneWidget);
    expect(find.text('Chest'), findsOneWidget);
    expect(find.text('Abdomen'), findsOneWidget);

    // Switch to Skeleton Layer
    await tester.tap(find.text('Skeleton'));
    await tester.pump();

    // Switch to Organs Layer (first occurrence is in layer dock)
    await tester.tap(find.text('Organs').first);
    await tester.pump();

    // Switch back to Surface Layer
    await tester.tap(find.text('Surface Body'));
    await tester.pump();
  });
}
