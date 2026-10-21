import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruqyahhealing/services/hijri_date.dart';
import 'package:ruqyahhealing/widgets/hijri_date_card.dart';

void main() {
  group('HijriDate.fromGregorian', () {
    test('1 Muharram 1446 is 8 July 2024 in the tabular calendar', () {
      expect(
        HijriDate.fromGregorian(DateTime(2024, 7, 8)),
        const HijriDate(1446, 1, 1),
      );
    });

    test('the day before is the last day of Dhu al-Hijjah 1445', () {
      final d = HijriDate.fromGregorian(DateTime(2024, 7, 7));
      expect((d.year, d.month, d.day), (1445, 12, 30));
    });

    test('Ramadan 1446 starts at the beginning of March 2025', () {
      final d = HijriDate.fromGregorian(DateTime(2025, 3, 1));
      expect((d.year, d.month), (1446, 9));
      expect(d.day, 1);
    });

    test('month names exist in every language and fall back to English', () {
      const d = HijriDate(1446, 9, 1);
      expect(d.monthName('en'), 'Ramadan');
      expect(d.monthName('ar'), 'رمضان');
      expect(d.monthName('bn'), 'রমজান');
      expect(d.monthName('ur'), 'رمضان');
      expect(d.monthName('fr'), 'Ramadan');
    });
  });

  testWidgets(
    'HijriDateCard shows the date only, in "9 Jumada al-Awwal 1448 AH" form',
    (tester) async {
      // Wednesday 21 October 2026, 4:30 PM.
      final fixed = DateTime(2026, 10, 21, 16, 30);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: HijriDateCard(now: () => fixed)),
        ),
      );

      expect(find.text('9 Jumada al-Awwal 1448 AH'), findsOneWidget);
      expect(find.text('Wednesday'), findsNothing);
      expect(find.textContaining('PM'), findsNothing);
      expect(find.textContaining('4:30'), findsNothing);

      // Remove the widget so its midnight timer is cancelled before the end.
      await tester.pumpWidget(const SizedBox());
    },
  );
}
