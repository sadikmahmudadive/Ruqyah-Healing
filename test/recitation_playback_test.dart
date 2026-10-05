import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio_platform_interface/just_audio_platform_interface.dart';
import 'package:ruqyahhealing/screens/tabs/home_tab.dart';
import 'package:ruqyahhealing/services/recitation_playback.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stand-in for the native just_audio plugin: loads instantly, reports
/// "ready", and plays/pauses on request. Lets the shared playback state be
/// tested without a device.
class _FakeJustAudio extends JustAudioPlatform {
  final players = <_FakePlayer>[];

  @override
  Future<AudioPlayerPlatform> init(InitRequest request) async {
    final p = _FakePlayer(request.id);
    players.add(p);
    return p;
  }

  @override
  Future<DisposePlayerResponse> disposePlayer(
    DisposePlayerRequest request,
  ) async => DisposePlayerResponse();

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
  int seeks = 0;

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
  Stream<PlaybackEventMessage> get playbackEventMessageStream =>
      _events.stream;

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
    seeks++;
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

/// Widget tests run on a fake clock; the audio plugin fake also needs real
/// event-loop turns, so alternate the two.
Future<void> _pumpAudio(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
  }
}

Future<void> _settle() async {
  // Let streams and microtasks deliver.
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

  test('open() loads the track and starts playing', () async {
    final c = RecitationPlayback.instance.open('rec_1');
    expect(RecitationPlayback.instance.trackId, 'rec_1');
    expect(c.loading, isTrue);

    await _settle();
    expect(c.error, isNull);
    expect(c.playing, isTrue);
    expect(c.currentAyah.ref, '2:1');
    expect(fake.players.single.playing, isTrue);
  });

  test('opening the same track reuses the controller (no restart)', () async {
    final first = RecitationPlayback.instance.open('rec_1');
    await _settle();
    await first.playAyah(3);
    await _settle();
    final seeksBefore = fake.players.single.seeks;

    final second = RecitationPlayback.instance.open('rec_1', autoplay: false);
    await _settle();

    expect(identical(first, second), isTrue);
    expect(fake.players.length, 1, reason: 'no second player created');
    expect(fake.players.single.seeks, seeksBefore, reason: 'not restarted');
    expect(second.index, 3);
    expect(second.playing, isTrue, reason: 'autoplay:false must not pause');
  });

  test('opening a different track replaces the controller', () async {
    final a = RecitationPlayback.instance.open('rec_1');
    await _settle();
    final b = RecitationPlayback.instance.open('rec_2');
    await _settle();

    expect(identical(a, b), isFalse);
    expect(RecitationPlayback.instance.trackId, 'rec_2');
    expect(b.content.ayahs.length, 1);
  });

  test('autoplay:false loads but stays paused; toggle plays and pauses',
      () async {
    final c = RecitationPlayback.instance.open('rec_1', autoplay: false);
    await _settle();
    expect(c.playing, isFalse);
    expect(c.error, isNull);

    await c.togglePlayPause();
    await _settle();
    expect(c.playing, isTrue);

    await c.togglePlayPause();
    await _settle();
    expect(c.playing, isFalse);
  });

  test('playAyah and nextAyah move the current ayah', () async {
    final c = RecitationPlayback.instance.open('rec_1');
    await _settle();

    await c.playAyah(2);
    await _settle();
    expect(c.currentAyah.ref, '2:3');

    await c.nextAyah();
    await _settle();
    expect(c.currentAyah.ref, '2:4');
  });

  test('stop() unloads the recitation', () async {
    RecitationPlayback.instance.open('rec_1');
    await _settle();
    RecitationPlayback.instance.stop();
    await _settle();
    expect(RecitationPlayback.instance.controller, isNull);
  });

  test('speed changes reach the player', () async {
    final c = RecitationPlayback.instance.open('rec_1');
    await _settle();
    await c.setSpeed(1.5);
    expect(c.speed, 1.5);
    expect(fake.players.single.speed, 1.5);
  });

  testWidgets('Home mini player: idle, tap play, shows real state, pause',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    // No location plugin in the test runner: report "location off".
    final messenger = tester.binding.defaultBinaryMessenger;
    for (final name in [
      'flutter.baseflow.com/geolocator',
      'flutter.baseflow.com/geolocator_service_updates',
    ]) {
      messenger.setMockMethodCallHandler(MethodChannel(name), (call) async {
        if (call.method == 'isLocationServiceEnabled') return false;
        return null;
      });
      addTearDown(
        () => messenger.setMockMethodCallHandler(MethodChannel(name), null),
      );
    }
    await tester.binding.setSurfaceSize(const Size(420, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    // The test font is wider than the real one, so unrelated Home rows report
    // RenderFlex overflows that don't happen on a device. Ignore only those.
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exceptionAsString().contains('overflowed')) return;
      originalOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = originalOnError);

    await tester.pumpWidget(const MaterialApp(home: HomeTab()));
    await tester.pump(const Duration(seconds: 2));

    // Idle: nothing loaded, default recitation shown, no fake times.
    expect(RecitationPlayback.instance.controller, isNull);
    expect(find.text('سورة البقرة'), findsOneWidget);
    expect(find.text('Surah Al-Baqarah'), findsOneWidget);
    expect(find.text('01:15'), findsNothing);
    expect(find.text('--:--'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsWidgets);

    // Tap play on the card.
    await tester.tap(find.byIcon(Icons.play_arrow_rounded).first);
    await _pumpAudio(tester);

    final controller = RecitationPlayback.instance.controller;
    expect(controller, isNotNull);
    expect(controller!.playing, isTrue);
    expect(find.text('Surah Al-Baqarah · Ayah 2:1'), findsOneWidget);
    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);

    // Tap again: pauses.
    await tester.tap(find.byIcon(Icons.pause_rounded));
    await _pumpAudio(tester);
    expect(controller.playing, isFalse);
    expect(find.byIcon(Icons.play_arrow_rounded), findsWidgets);

    // Leave nothing running.
    RecitationPlayback.instance.stop();
    await _pumpAudio(tester);
  });
}
