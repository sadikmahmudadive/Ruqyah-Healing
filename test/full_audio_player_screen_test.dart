import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio_platform_interface/just_audio_platform_interface.dart';
import 'package:ruqyahhealing/screens/full_audio_player_screen.dart';
import 'package:ruqyahhealing/services/recitation_playback.dart';

class _FakeJustAudio extends JustAudioPlatform {
  final players = <_FakePlayer>[];

  @override
  Future<AudioPlayerPlatform> init(InitRequest request) async {
    final p = _FakePlayer(request.id);
    players.add(p);
    return p;
  }

  @override
  Future<DisposePlayerResponse> disposePlayer(DisposePlayerRequest request) async =>
      DisposePlayerResponse();

  @override
  Future<DisposeAllPlayersResponse> disposeAllPlayers(
    DisposeAllPlayersRequest request,
  ) async => DisposeAllPlayersResponse();
}

class _FakePlayer extends AudioPlayerPlatform {
  _FakePlayer(super.id);

  final _events = StreamController<PlaybackEventMessage>.broadcast(sync: true);
  int _index = 0;
  Duration _position = Duration.zero;
  bool playing = false;
  double speed = 1.0;

  void _emit(ProcessingStateMessage state) {
    _events.add(
      PlaybackEventMessage(
        processingState: state,
        updateTime: DateTime.now(),
        updatePosition: _position,
        bufferedPosition: _position,
        duration: const Duration(seconds: 10),
        icyMetadata: null,
        currentIndex: _index,
        androidAudioSessionId: null,
      ),
    );
  }

  @override
  Stream<PlaybackEventMessage> get playbackEventMessageStream => _events.stream;

  @override
  Future<LoadResponse> load(LoadRequest request) async {
    _index = request.initialIndex ?? 0;
    _position = request.initialPosition ?? Duration.zero;
    scheduleMicrotask(() => _emit(ProcessingStateMessage.ready));
    return LoadResponse(duration: const Duration(seconds: 10));
  }

  @override
  Future<PlayResponse> play(PlayRequest request) async {
    playing = true;
    return PlayResponse();
  }

  @override
  Future<PauseResponse> pause(PauseRequest request) async {
    playing = false;
    return PauseResponse();
  }

  @override
  Future<SeekResponse> seek(SeekRequest request) async {
    _position = request.position ?? Duration.zero;
    _index = request.index ?? _index;
    _emit(ProcessingStateMessage.ready);
    return SeekResponse();
  }

  @override
  Future<SetSpeedResponse> setSpeed(SetSpeedRequest request) async {
    speed = request.speed;
    return SetSpeedResponse();
  }

  @override
  Future<SetVolumeResponse> setVolume(SetVolumeRequest request) async =>
      SetVolumeResponse();

  @override
  Future<SetLoopModeResponse> setLoopMode(SetLoopModeRequest request) async =>
      SetLoopModeResponse();

  @override
  Future<SetShuffleModeResponse> setShuffleMode(
    SetShuffleModeRequest request,
  ) async => SetShuffleModeResponse();

  @override
  Future<DisposeResponse> dispose(DisposeRequest request) async {
    await _events.close();
    return DisposeResponse();
  }
}

Future<void> _settle() async {
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _FakeJustAudio fake;

  setUp(() {
    fake = _FakeJustAudio();
    JustAudioPlatform.instance = fake;
  });

  tearDown(() async {
    RecitationPlayback.instance.stop();
    await _settle();
  });

  testWidgets('Tapping controls displays 2-second action feedback HUD', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: FullAudioPlayerScreen(
          autoplay: false,
          continueInBackground: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Initial state: No 2s action badge visible
    expect(find.text('2s'), findsNothing);

    // 2. Tap Play / Pause button
    final playBtn = find.byIcon(Icons.play_arrow_rounded);
    expect(playBtn, findsOneWidget);
    await tester.tap(playBtn);
    await tester.pump();

    // Feedback shows "Playing Recitation" and "2s" tag
    expect(find.text('Playing Recitation'), findsOneWidget);
    expect(find.text('2s'), findsOneWidget);

    // 3. Tap Loop button
    final loopBtn = find.byTooltip('Loop recitation');
    await tester.tap(loopBtn);
    await tester.pump();

    expect(find.text('Repeat Recitation: ON'), findsOneWidget);
    expect(find.text('2s'), findsOneWidget);

    // 4. Tap Next ayah button
    final nextBtn = find.byTooltip('Next ayah');
    await tester.tap(nextBtn);
    await tester.pump();

    expect(find.textContaining('Next:'), findsOneWidget);
    expect(find.text('2s'), findsOneWidget);

    // 5. Tap Speed button (1.0x -> 1.25x)
    final speedBtn = find.text('1.0x');
    await tester.tap(speedBtn);
    await tester.pump();

    expect(find.text('Speed: 1.25x'), findsOneWidget);
    expect(find.text('2s'), findsOneWidget);

    // 6. Tap Back 10s
    final back10 = find.text('Back 10s');
    await tester.tap(back10);
    await tester.pump();

    expect(find.text('Rewound 10 Seconds (-10s)'), findsOneWidget);
    expect(find.text('2s'), findsOneWidget);

    // 7. Tap Forward 10s
    final forward10 = find.text('Forward 10s');
    await tester.tap(forward10);
    await tester.pump();

    expect(find.text('Forwarded 10 Seconds (+10s)'), findsOneWidget);
    expect(find.text('2s'), findsOneWidget);

    // 8. Tap Sleep timer
    final sleepBtn = find.text('Sleep timer');
    await tester.tap(sleepBtn);
    await tester.pump();

    expect(find.text('Sleep Timer: 15 Min Set'), findsOneWidget);
    expect(find.text('2s'), findsOneWidget);

    // 9. Advance time past 2 seconds (2000ms timer + 250ms fade-out animation)
    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('2s'), findsNothing);

    // Clean up playback and timers
    RecitationPlayback.instance.stop();
    await _pumpAudio(tester);
  });
}

Future<void> _pumpAudio(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
  }
}
