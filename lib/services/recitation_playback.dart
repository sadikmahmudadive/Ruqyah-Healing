import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../data/recitation_data.dart';
import '../models/user_model.dart';
import 'firebase_service.dart';
import 'recitation_player_controller.dart';

/// The one recitation that is currently loaded, shared by every screen that
/// shows it: the Home mini player and the full player look at the same
/// [controller], so playback carries over instead of restarting.
///
/// Listeners are told when the controller is created or replaced. State
/// changes inside a controller notify the controller itself.
class RecitationPlayback extends ChangeNotifier {
  RecitationPlayback._();

  static final RecitationPlayback instance = RecitationPlayback._();

  /// Track the Home mini player shows while nothing has been started.
  static const String defaultTrackId = 'rec_1';

  static const int _minLoggedSeconds = 30;

  RecitationPlayerController? _controller;

  /// One player for the whole app: the playback notification (just_audio_
  /// background) supports a single instance. Created on first use, disposed
  /// when playback is stopped.
  AudioPlayer? _player;
  Future<void> _playerDisposed = Future.value();

  bool _wasPlaying = false;
  int _loggedSeconds = 0;
  bool _notifyScheduled = false;

  RecitationPlayerController? get controller => _controller;
  String? get trackId => _controller?.content.id;

  /// Returns the controller for [trackId], creating (and loading) it if a
  /// different track, or none, is loaded. Asking for the track that is
  /// already loaded reuses it; with [autoplay] it is resumed if paused.
  RecitationPlayerController open(String trackId, {bool autoplay = true}) {
    final content =
        kRecitationTracks[trackId] ?? kRecitationTracks[defaultTrackId]!;

    final existing = _controller;
    if (existing != null && existing.content.id == content.id) {
      if (autoplay && !existing.playing && !existing.loading) {
        existing.togglePlayPause();
      }
      return existing;
    }

    _releaseController();
    final created = RecitationPlayerController(
      content,
      player: _player ??= AudioPlayer(),
    );
    _controller = created;
    _wasPlaying = false;
    _loggedSeconds = 0;
    created.addListener(_onControllerChanged);
    created.init(autoplay: autoplay, after: _playerDisposed);
    _notifyLater();
    return created;
  }

  /// Stops playback and unloads the current recitation.
  void stop() {
    if (_controller == null) return;
    _releaseController();
    // Dropping the player also removes the playback notification.
    final player = _player;
    _player = null;
    if (player != null) {
      _playerDisposed = player.dispose().catchError((Object _) {});
    }
    _notifyLater();
  }

  void _onControllerChanged() {
    final c = _controller;
    if (c == null) return;
    // A pause (or the end of the recitation) closes a listening segment.
    if (_wasPlaying && !c.playing) _flushListening();
    _wasPlaying = c.playing;
  }

  /// Saves what was actually played since the last save, so Ruqyah listening
  /// feeds the Health Index. Fire and forget: it must never block playback.
  void _flushListening() {
    final c = _controller;
    final user = FirebaseService.currentUser;
    if (c == null || user == null) return;

    final pending = c.listenedSeconds - _loggedSeconds;
    if (pending < _minLoggedSeconds) return; // keep accumulating
    _loggedSeconds = c.listenedSeconds;

    unawaited(
      FirebaseService.logRuqyahSession(
        user.uid,
        RuqyahAudioLog(
          audioId: c.content.title,
          listenDurationSec: pending,
          date: DateTime.now().toIso8601String(),
        ),
      ).catchError((_) {}),
    );
  }

  void _releaseController() {
    final c = _controller;
    if (c == null) return;
    _flushListening();
    c.removeListener(_onControllerChanged);
    c.dispose();
    _controller = null;
    _wasPlaying = false;
  }

  /// open() and stop() are often called while a widget is being built or
  /// disposed, when other widgets may not be marked dirty. Notify afterwards.
  void _notifyLater() {
    if (_notifyScheduled) return;
    _notifyScheduled = true;
    scheduleMicrotask(() {
      _notifyScheduled = false;
      notifyListeners();
    });
  }
}
