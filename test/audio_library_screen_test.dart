import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruqyahhealing/screens/audio_library_screen.dart';

void main() {
  testWidgets('AudioLibraryScreen renders header, banner, search bar, filters and playlists', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));

    await tester.pumpWidget(
      const MaterialApp(
        home: AudioLibraryScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Check Header
    expect(find.text('RUQYAH AUDIO & DUAS'), findsOneWidget);

    // Check API sync banner
    expect(find.text('Live Audio API Streaming'), findsOneWidget);
    expect(find.text('Sync API'), findsOneWidget);

    // Check Filter tabs
    expect(find.text('All'), findsWidgets);
    expect(find.text('Playlists'), findsOneWidget);
    expect(find.text('Quran Ayats'), findsOneWidget);

    // Scroll filter list to reveal 'Prophetic Duas'
    await tester.drag(find.text('Quran Ayats'), const Offset(-150, 0));
    await tester.pumpAndSettle();
    expect(find.text('Prophetic Duas'), findsOneWidget);

    // Check Section title
    expect(find.text('Ruqyah Audio Sessions'), findsOneWidget);
    expect(find.text('Full Ruqyah Ash-Shar\'iyyah'), findsOneWidget);
  });
}
