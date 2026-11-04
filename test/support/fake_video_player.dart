import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

/// A stand-in for the native video engine. Nothing is decoded and nothing
/// touches the network: `create` hands out an id, the player reports itself
/// initialized with a size and [duration], and the test moves the clock by
/// calling [advance] while the fake is "playing".
///
/// Install per test with `VideoPlayerPlatform.instance = fake`.
class FakeVideoPlayer extends VideoPlayerPlatform {
  FakeVideoPlayer({
    this.duration = const Duration(seconds: 60),
    this.size = const Size(640, 360),
  });

  /// Length reported in the `initialized` event.
  Duration duration;
  final Size size;

  /// When true the next player reports a load failure instead of `initialized`.
  bool failLoad = false;

  /// Clock reported by [getPosition].
  Duration position = Duration.zero;

  bool playing = false;
  int playCalls = 0;
  int pauseCalls = 0;
  final seeks = <Duration>[];
  final createdUrls = <String>[];
  final disposedIds = <int>[];

  int _nextId = 1;
  final _events = <int, StreamController<VideoEvent>>{};

  /// Moves the reported position forward, as playback would. A paused video
  /// does not move, so this does nothing unless [playing].
  void advance(Duration by) {
    if (playing) position += by;
  }

  /// Reports that playback reached the end of the video.
  void emitCompleted(int playerId) {
    _events[playerId]?.add(VideoEvent(eventType: VideoEventType.completed));
  }

  /// Ids of players created and not yet disposed.
  Iterable<int> get livePlayers =>
      _events.keys.where((id) => !disposedIds.contains(id));

  @override
  Future<void> init() async {}

  @override
  Future<int?> createWithOptions(VideoCreationOptions options) async {
    final id = _nextId++;
    createdUrls.add(options.dataSource.uri ?? '');
    late final StreamController<VideoEvent> events;
    events = StreamController<VideoEvent>(
      onListen: () {
        scheduleMicrotask(() {
          if (events.isClosed) return;
          if (failLoad) {
            events.addError(
              PlatformException(code: 'VideoError', message: 'cannot load'),
            );
          } else {
            events.add(
              VideoEvent(
                eventType: VideoEventType.initialized,
                duration: duration,
                size: size,
              ),
            );
          }
        });
      },
    );
    _events[id] = events;
    return id;
  }

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) => _events[playerId]!.stream;

  @override
  Future<void> dispose(int playerId) async {
    disposedIds.add(playerId);
    await _events[playerId]?.close();
  }

  @override
  Future<void> play(int playerId) async {
    playing = true;
    playCalls++;
  }

  @override
  Future<void> pause(int playerId) async {
    playing = false;
    pauseCalls++;
  }

  @override
  Future<void> seekTo(int playerId, Duration position) async {
    this.position = position;
    seeks.add(position);
  }

  @override
  Future<Duration> getPosition(int playerId) async => position;

  @override
  Future<void> setLooping(int playerId, bool looping) async {}

  @override
  Future<void> setVolume(int playerId, double volume) async {}

  @override
  Future<void> setPlaybackSpeed(int playerId, double speed) async {}

  @override
  Future<void> setMixWithOthers(bool mixWithOthers) async {}

  @override
  Widget buildViewWithOptions(VideoViewOptions options) =>
      Texture(textureId: options.playerId);
}
