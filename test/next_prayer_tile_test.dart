import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruqyahhealing/services/prayer_times_service.dart';
import 'package:ruqyahhealing/theme/app_theme.dart';
import 'package:ruqyahhealing/widgets/flowing_gradient.dart';
import 'package:ruqyahhealing/widgets/next_prayer_tile.dart';

void main() {
  testWidgets('NextPrayerTile names a prayer, its wait, and opens on tap', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: NextPrayerTile(
            future: Future.value(PrayerTimesModel.fallback()),
            onTap: () => taps++,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('NEXT PRAYER'), findsOneWidget);
    expect(find.textContaining('begins in'), findsOneWidget);
    const names = ['Fajr', 'Dhuhr', "Jumu'ah", 'Asr', 'Maghrib', 'Isha'];
    expect(
      names.where((n) => find.text(n).evaluate().isNotEmpty),
      hasLength(1),
    );

    await tester.tap(find.byType(NextPrayerTile));
    expect(taps, 1);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('FlowingGradient stands still when animations are disabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: FlowingGradient(
            colors: [Colors.green, Colors.black],
            child: SizedBox(width: 100, height: 100),
          ),
        ),
      ),
    );
    // With no running ticker, settling returns at once instead of timing out.
    await tester.pumpAndSettle();
    expect(find.byType(FlowingGradient), findsOneWidget);
  });
}
