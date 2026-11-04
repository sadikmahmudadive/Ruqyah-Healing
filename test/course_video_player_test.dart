import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruqyahhealing/models/course_model.dart';
import 'package:ruqyahhealing/widgets/learn/course_video_player.dart';
import 'package:ruqyahhealing/widgets/learn/unlock_card.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

import 'support/fake_video_player.dart';

const _url = 'https://example.com/lesson.mp4';

Future<void> _pumpPlayer(
  WidgetTester tester, {
  String url = _url,
  bool locked = false,
  VoidCallback? onUnlock,
  VoidCallback? onEnded,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: CourseVideoPlayer(
            url: url,
            locked: locked,
            priceLabel: 'BDT 500',
            onUnlock: onUnlock,
            onEnded: onEnded,
            title: 'Lesson one',
          ),
        ),
      ),
    ),
  );
  // Let the fake platform create the player and report `initialized`.
  for (var i = 0; i < 3; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> _tapPlay(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.play_arrow_rounded));
  await tester.pump(const Duration(milliseconds: 50));
}

/// Moves the fake clock by [seconds] one second at a time, giving the
/// controller's 100 ms poll a chance to see each step.
Future<void> _playFor(
  WidgetTester tester,
  FakeVideoPlayer fake,
  int seconds,
) async {
  for (var i = 0; i < seconds; i++) {
    fake.advance(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 150));
  }
}

VideoPlayerController _controller(WidgetTester tester) =>
    tester.widget<VideoPlayer>(find.byType(VideoPlayer)).controller;

/// The video_player package awaits futures that resolve outside the test's
/// fake clock (for example a cancelled stream subscription), so give the real
/// event loop a turn and then let the widget tree catch up.
Future<void> _flushPlatform(WidgetTester tester) async {
  await tester.runAsync(() => Future<void>.delayed(Duration.zero));
  await tester.pump(const Duration(milliseconds: 50));
}

Future<void> _dispose(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await _flushPlatform(tester);
}

void main() {
  late FakeVideoPlayer fake;
  late VideoPlayerPlatform previous;

  setUp(() {
    previous = VideoPlayerPlatform.instance;
    fake = FakeVideoPlayer();
    VideoPlayerPlatform.instance = fake;
  });

  tearDown(() => VideoPlayerPlatform.instance = previous);

  testWidgets('locked mode pauses at 10s and shows the Unlock card once', (
    tester,
  ) async {
    var unlocks = 0;
    await _pumpPlayer(tester, locked: true, onUnlock: () => unlocks++);

    expect(find.byType(UnlockCard), findsNothing);
    await _tapPlay(tester);
    expect(fake.playing, isTrue);

    await _playFor(tester, fake, 5);
    expect(find.byType(UnlockCard), findsNothing);
    expect(fake.playing, isTrue);

    await _playFor(tester, fake, 5);
    expect(find.byType(UnlockCard), findsOneWidget);
    expect(fake.playing, isFalse);
    expect(fake.position, kPreviewLimit);
    expect(fake.seeks.last, kPreviewLimit);

    // Further ticks must not stack a second card or replay the pause.
    final pauses = fake.pauseCalls;
    await _playFor(tester, fake, 3);
    expect(find.byType(UnlockCard), findsOneWidget);
    expect(fake.pauseCalls, pauses);

    await tester.tap(find.textContaining('BDT 500'));
    await tester.pump();
    expect(unlocks, 1);

    await _dispose(tester);
  });

  testWidgets('play after the limit stays at the limit', (tester) async {
    await _pumpPlayer(tester, locked: true);
    await _tapPlay(tester);
    await _playFor(tester, fake, 10);
    expect(find.byType(UnlockCard), findsOneWidget);

    // Something other than the card (e.g. a hardware key) asks to play on.
    final pausesBefore = fake.pauseCalls;
    _controller(tester).play();
    await tester.pump(const Duration(milliseconds: 50));
    fake.advance(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump(const Duration(milliseconds: 150));

    expect(fake.playing, isFalse);
    expect(fake.pauseCalls, greaterThan(pausesBefore));
    expect(fake.position, kPreviewLimit);
    expect(find.byType(UnlockCard), findsOneWidget);

    await _dispose(tester);
  });

  testWidgets('seeking past the limit is clamped to the limit', (tester) async {
    await _pumpPlayer(tester, locked: true);
    final slider = tester.widget<Slider>(find.byType(Slider));
    slider.onChanged!(30000);
    slider.onChangeEnd!(30000);
    await tester.pump(const Duration(milliseconds: 150));

    expect(fake.seeks.last, kPreviewLimit);
    expect(find.byType(UnlockCard), findsOneWidget);

    await _dispose(tester);
  });

  testWidgets('Replay restarts the preview and the card can appear again', (
    tester,
  ) async {
    await _pumpPlayer(tester, locked: true);
    await _tapPlay(tester);
    await _playFor(tester, fake, 10);
    expect(find.byType(UnlockCard), findsOneWidget);

    await tester.tap(find.text('Replay preview'));
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.byType(UnlockCard), findsNothing);
    expect(fake.seeks, contains(Duration.zero));
    expect(fake.playing, isTrue);

    await _playFor(tester, fake, 10);
    expect(find.byType(UnlockCard), findsOneWidget);
    expect(fake.playing, isFalse);

    await _dispose(tester);
  });

  testWidgets('unlocked mode does not show the Unlock card past 10s', (
    tester,
  ) async {
    await _pumpPlayer(tester);
    await _tapPlay(tester);
    await _playFor(tester, fake, 15);

    expect(find.byType(UnlockCard), findsNothing);
    expect(fake.playing, isTrue);
    expect(fake.position, const Duration(seconds: 15));

    await _dispose(tester);
  });

  testWidgets('unlocked mode calls onEnded at the end, once', (tester) async {
    fake.duration = const Duration(seconds: 20);
    var ended = 0;
    await _pumpPlayer(tester, onEnded: () => ended++);
    await _tapPlay(tester);

    await _playFor(tester, fake, 19);
    expect(ended, 0);

    await _playFor(tester, fake, 1);
    expect(ended, 1);

    // The platform's own `completed` event follows; it must not fire again.
    fake.emitCompleted(fake.livePlayers.single);
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump(const Duration(milliseconds: 150));
    expect(ended, 1);
    expect(find.byType(UnlockCard), findsNothing);

    await _dispose(tester);
  });

  testWidgets('empty url shows an inline message and no crash', (tester) async {
    await _pumpPlayer(tester, url: '');

    expect(tester.takeException(), isNull);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.byType(VideoPlayer), findsNothing);
    expect(fake.createdUrls, isEmpty);

    await tester.tap(find.text('Retry'));
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.takeException(), isNull);
    expect(find.text('Retry'), findsOneWidget);

    await _dispose(tester);
  });

  testWidgets('a load failure shows a message and Retry recovers', (
    tester,
  ) async {
    fake.failLoad = true;
    await _pumpPlayer(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.byType(VideoPlayer), findsNothing);
    // The failed controller is released, not leaked.
    await _flushPlatform(tester);
    expect(fake.livePlayers, isEmpty);

    fake.failLoad = false;
    await tester.tap(find.text('Retry'));
    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.text('Retry'), findsNothing);
    expect(find.byType(VideoPlayer), findsOneWidget);
    expect(fake.createdUrls, [_url, _url]);

    await _dispose(tester);
  });

  testWidgets('dispose releases the controller', (tester) async {
    await _pumpPlayer(tester, locked: true);
    await _tapPlay(tester);
    expect(fake.livePlayers, hasLength(1));

    await _dispose(tester);

    expect(fake.livePlayers, isEmpty);
    expect(fake.disposedIds, hasLength(1));
    // No poll timers survive the widget.
    fake.advance(const Duration(seconds: 5));
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
  });
}
