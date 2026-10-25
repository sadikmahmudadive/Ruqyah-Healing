import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruqyahhealing/screens/audio_library_screen.dart';

void main() {
  testWidgets(
    'AudioLibraryScreen renders header, featured banner, tabs and playlists',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(const MaterialApp(home: AudioLibraryScreen()));
      // The featured banner's gradient drifts forever, so settle with a fixed
      // pump instead of pumpAndSettle.
      await tester.pump(const Duration(seconds: 1));

      // Check Header
      expect(find.text('RUQYAH AUDIO & DUAS'), findsOneWidget);

      // The status line is gone; syncing stays on the header icon.
      expect(find.text('Live Audio API Streaming'), findsNothing);
      expect(find.byTooltip('Sync live API data'), findsOneWidget);

      // Check Filter tabs
      expect(find.text('All'), findsWidgets);
      expect(find.text('Playlists'), findsOneWidget);
      expect(find.text('Quran Ayats'), findsOneWidget);

      // Scroll filter list to reveal 'Prophetic Duas'
      await tester.drag(find.text('Quran Ayats'), const Offset(-150, 0));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Prophetic Duas'), findsOneWidget);

      // Featured banner
      expect(find.text('Begin with a full Ruqyah'), findsOneWidget);

      // Check Section title
      expect(find.text('Ruqyah Audio Sessions'), findsOneWidget);
      expect(find.text('Full Ruqyah Ash-Shar\'iyyah'), findsOneWidget);
    },
  );

  // Overflow shows up as a test exception, so building at awkward widths (with
  // the test font, which is wider than the real ones) checks the cover cards,
  // tabs and track rows always fit.
  for (final w in [320.0, 360.0, 430.0]) {
    testWidgets('library lays out without overflow at ${w.toInt()}px', (
      tester,
    ) async {
      tester.view.physicalSize = Size(w, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const MaterialApp(home: AudioLibraryScreen()));
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);

      final scroll = find.byType(SingleChildScrollView).first;
      for (var i = 0; i < 6; i++) {
        await tester.drag(scroll, const Offset(0, -500));
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(tester.takeException(), isNull);
    });
  }
}
