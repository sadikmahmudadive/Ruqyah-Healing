import 'dart:async';

import 'package:just_audio_platform_interface/just_audio_platform_interface.dart';

/// A stand-in for the native audio engine: every ayah is 10 seconds long and
/// seeks are recorded in [FakePlayer.index] and [FakePlayer.position].
class FakeJustAudio extends JustAudioPlatform {
  final players = <FakePlayer>[];

  @override
  Future<AudioPlayerPlatform> init(InitRequest request) async {
    final p = FakePlayer(request.id);
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

class FakePlayer extends AudioPlayerPlatform {
  FakePlayer(super.id);

  final _events = StreamController<PlaybackEventMessage>.broadcast(sync: true);
  int index = 0;
  Duration position = Duration.zero;
  bool playing = false;
  double speed = 1.0;

  void _emit(ProcessingStateMessage state) {
    _events.add(
      PlaybackEventMessage(
        processingState: state,
        updateTime: DateTime.now(),
        updatePosition: position,
        bufferedPosition: position,
        duration: const Duration(seconds: 10),
        icyMetadata: null,
        currentIndex: index,
        androidAudioSessionId: null,
      ),
    );
  }

  @override
  Stream<PlaybackEventMessage> get playbackEventMessageStream => _events.stream;

  @override
  Future<LoadResponse> load(LoadRequest request) async {
    index = request.initialIndex ?? 0;
    position = request.initialPosition ?? Duration.zero;
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
    position = request.position ?? Duration.zero;
    index = request.index ?? index;
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
