import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:just_audio_platform_interface/just_audio_platform_interface.dart';
import 'package:ruqyahhealing/models/recitation.dart';
import 'package:ruqyahhealing/screens/full_audio_player_screen.dart';
import 'package:ruqyahhealing/services/recitation_downloads.dart';
import 'package:ruqyahhealing/services/recitation_playback.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_just_audio.dart';

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 15)),
    );
  }
}

/// Stops playback (which cancels the controller's timer) before the test
/// ends, as the framework requires no timers left pending.
Future<void> _finish(WidgetTester tester) async {
  RecitationPlayback.instance.stop();
  await _settle(tester);
}

const _content = RecitationContent(
  id: 'test_track',
  title: 'Test',
  ayahs: [
    Ayah(
      surah: 1,
      number: 1,
      surahName: 'Al-Fatihah',
      arabic: 'بِسْمِ',
      transliteration: 'Bismi',
      meaning: 'In the name',
    ),
    Ayah(
      surah: 1,
      number: 2,
      surahName: 'Al-Fatihah',
      arabic: 'ٱلْحَمْدُ',
      transliteration: 'Alhamdu',
      meaning: 'Praise',
    ),
  ],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RecitationDownloads', () {
    late Directory tmp;
    setUp(() => tmp = Directory.systemTemp.createTempSync('recit_test'));
    tearDown(() => tmp.deleteSync(recursive: true));

    test('file names are stable and safe', () {
      final a = RecitationDownloads.fileNameFor('https://x/1.mp3');
      expect(a, RecitationDownloads.fileNameFor('https://x/1.mp3'));
      expect(a, isNot(RecitationDownloads.fileNameFor('https://x/2.mp3')));
      expect(a, matches(RegExp(r'^[0-9a-f]+\.mp3$')));
    });

    test(
      'downloads every ayah, reports progress, and finds them after',
      () async {
        final calls = <String>[];
        final d = RecitationDownloads(
          folder: () async => tmp,
          client: MockClient((req) async {
            calls.add(req.url.toString());
            return http.Response('audio', 200);
          }),
        );
        expect(await d.isDownloaded(_content), isFalse);

        final progress = <(int, int)>[];
        await d.download(_content, onProgress: (a, b) => progress.add((a, b)));
        expect(progress, [(1, 2), (2, 2)]);
        expect(calls.length, 2);
        expect(await d.isDownloaded(_content), isTrue);
        expect(await d.localPath(_content.ayahs.first.playbackUrl), isNotNull);

        // A second run fetches nothing: everything is already saved.
        await d.download(_content);
        expect(calls.length, 2);
      },
    );

    test('a failed fetch throws and keeps what was already saved', () async {
      var n = 0;
      final d = RecitationDownloads(
        folder: () async => tmp,
        client: MockClient((req) async {
          n++;
          return n == 1
              ? http.Response('audio', 200)
              : http.Response('no', 500);
        }),
      );
      await expectLater(d.download(_content), throwsA(isA<HttpException>()));
      final s = await d.status(_content);
      expect((s.saved, s.total), (1, 2));
      expect(await d.isDownloaded(_content), isFalse);
    });

    test('remove deletes the saved audio', () async {
      final d = RecitationDownloads(
        folder: () async => tmp,
        client: MockClient((_) async => http.Response('audio', 200)),
      );
      await d.download(_content);
      await d.remove(_content);
      expect((await d.status(_content)).saved, 0);
    });
  });

  group('player buttons', () {
    late FakeJustAudio fake;

    late RecitationDownloads originalDownloads;
    late Directory store;

    setUp(() {
      originalDownloads = RecitationDownloads.instance;
      store = Directory.systemTemp.createTempSync('player_store');
      RecitationDownloads.instance = RecitationDownloads(
        folder: () async => store,
      );
      fake = FakeJustAudio();
      JustAudioPlatform.instance = fake;
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() async {
      RecitationPlayback.instance.stop();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      RecitationDownloads.instance = originalDownloads;
      store.deleteSync(recursive: true);
    });

    Future<void> open(
      WidgetTester tester, {
      RecitationDownloads? downloads,
    }) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(
        MaterialApp(
          home: FullAudioPlayerScreen(
            autoplay: false,
            continueInBackground: true,
            downloads: downloads,
          ),
        ),
      );
      await _settle(tester);
    }

    testWidgets('Forward 10s carries over into the next ayah', (tester) async {
      await open(tester);
      final p = fake.players.last;
      expect(p.index, 0);

      // Every ayah is 10s long in the fake, so +10s from the start of ayah 1
      // lands at the start of ayah 2, not at the end of ayah 1.
      await tester.tap(find.text('Forward 10s'));
      await _settle(tester);
      expect(p.index, 1);

      await tester.tap(find.text('Back 10s'));
      await _settle(tester);
      expect(p.index, 0);
      await _finish(tester);
    });

    testWidgets('the heart is remembered', (tester) async {
      await open(tester);
      await tester.tap(find.byTooltip('Add to favourites'));
      await _settle(tester);
      expect(find.byTooltip('Remove from favourites'), findsOneWidget);

      final id = RecitationPlayback.instance.controller!.content.id;
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('fav_recitations'), contains(id));

      // A fresh screen starts with the heart already on.
      RecitationPlayback.instance.stop();
      await tester.pumpWidget(const SizedBox());
      await _settle(tester);
      await open(tester);
      expect(find.byTooltip('Remove from favourites'), findsOneWidget);
      await _finish(tester);
    });

    testWidgets('the more menu changes speed and sleep timer', (tester) async {
      await open(tester);
      await tester.tap(find.byTooltip('More'));
      await _settle(tester);

      expect(find.text('PLAYBACK SPEED'), findsOneWidget);
      expect(find.text('SLEEP TIMER'), findsOneWidget);

      await tester.tap(find.text('1.5x').last);
      await _settle(tester);
      expect(RecitationPlayback.instance.controller!.speed, 1.5);

      await tester.tap(find.text('30 min'));
      await _settle(tester);
      expect(find.text('Sleep Timer: 30 Min Set'), findsOneWidget);

      await tester.tap(find.text('Repeat recitation'));
      await _settle(tester);
      expect(RecitationPlayback.instance.controller!.looping, isTrue);

      // Dismiss the sheet and clear the sleep timer so nothing stays pending.
      await tester.tap(find.text('Off'));
      await _settle(tester);
      await tester.pump(const Duration(seconds: 3));
      await _finish(tester);
    });

    testWidgets('the more menu copies the current verse', (tester) async {
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String?;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );

      await open(tester);
      await tester.tap(find.byTooltip('More'));
      await _settle(tester);
      await tester.tap(find.text('Copy this verse'));
      await _settle(tester);
      expect(copied, isNotNull);
      expect(copied, contains('\n'));
      await tester.pump(const Duration(seconds: 3));
      await _finish(tester);
    });

    testWidgets('Download saves the recitation and shows it as saved', (
      tester,
    ) async {
      final tmp = Directory.systemTemp.createTempSync('player_dl');
      addTearDown(() => tmp.deleteSync(recursive: true));
      final downloads = RecitationDownloads(
        folder: () async => tmp,
        client: MockClient((_) async => http.Response('audio', 200)),
      );

      await open(tester, downloads: downloads);
      expect(find.text('Download'), findsOneWidget);

      await tester.tap(find.text('Download'));
      await _settle(tester);
      await _settle(tester);
      // File writes happen in real time, so wait (briefly) until it is done.
      for (var i = 0; i < 60; i++) {
        if (find.text('Saved offline').evaluate().isNotEmpty) break;
        await _settle(tester);
      }
      expect(find.text('Saved offline'), findsOneWidget);

      await tester.pump(const Duration(seconds: 6));
    });
  });
}
