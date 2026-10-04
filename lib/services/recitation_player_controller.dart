import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show MissingPluginException;
import 'package:just_audio/just_audio.dart';

import '../models/recitation.dart';

/// Plays a [RecitationContent] one ayah at a time and exposes which ayah is
/// being recited, so subtitles are always in sync with the audio.
///
/// Discrete state (current ayah, playing, loading, error) notifies listeners.
/// The playhead lives in [position] instead, so the whole screen is not
/// rebuilt on every audio tick.
class RecitationPlayerController extends ChangeNotifier {
  RecitationPlayerController(this.content, {AudioPlayer? player})
    : _player = player ?? AudioPlayer(),
      _durations = List<Duration?>.filled(content.ayahs.length, null);

  final RecitationContent content;
  final AudioPlayer _player;

  /// Length of each ayah, filled in as the player learns them.
  final List<Duration?> _durations;

  /// Playhead inside the current ayah.
  final ValueNotifier<Duration> position = ValueNotifier(Duration.zero);

  final List<StreamSubscription<dynamic>> _subs = [];
  Timer? _listenTimer;

  int _index = 0;
  bool _playing = false;
  bool _loading = true;
  bool _loaded = false;
  bool _looping = false;
  bool _completing = false;
  bool _disposed = false;
  double _speed = 1.0;
  int _listenedSeconds = 0;
  String? _error;

  int get index => _index;
  Ayah get currentAyah => content.ayahs[_index];
  bool get playing => _playing;
  bool get loading => _loading;
  bool get looping => _looping;
  double get speed => _speed;
  String? get error => _error;

  /// Seconds actually played (real time), for the listening log.
  int get listenedSeconds => _listenedSeconds;

  /// Where we are across the whole recitation, 0..1.
  double get overallProgress {
    final n = content.ayahs.length;
    if (n == 0) return 0;
    final d = _durations[_index];
    final frac = (d == null || d == Duration.zero)
        ? 0.0
        : (position.value.inMilliseconds / d.inMilliseconds).clamp(0.0, 1.0);
    return (_index + frac) / n;
  }

  /// Time played so far across all ayahs before this one plus the playhead.
  Duration get elapsed {
    var total = position.value;
    for (var i = 0; i < _index; i++) {
      total += _durations[i] ?? Duration.zero;
    }
    return total;
  }

  /// Known ayah lengths plus an average-based guess for the ones not yet
  /// loaded.
  Duration get estimatedTotal {
    final known = _durations.whereType<Duration>().toList();
    if (known.isEmpty) return Duration.zero;
    final sum = known.fold(Duration.zero, (a, b) => a + b);
    final avg = sum.inMilliseconds / known.length;
    final unknown = _durations.length - known.length;
    return sum + Duration(milliseconds: (avg * unknown).round());
  }

  /// Loads the audio. [autoplay] false leaves it paused at the start.
  Future<void> init({bool autoplay = true}) async {
    if (_disposed) return;
    _bindOnce();
    _error = null;
    _loading = true;
    _notify();

    try {
      await _player.setAudioSources([
        for (final a in content.ayahs) AudioSource.uri(Uri.parse(a.audioUrl)),
      ]);
      _loaded = true;
      // play() completes only when playback stops, so don't await it.
      if (autoplay) unawaited(_player.play());
    } on PlayerInterruptedException {
      // A newer load superseded this one; nothing to report.
    } on MissingPluginException catch (e) {
      // Only happens in dev: the native plugin isn't in the installed build
      // (e.g. hot reload after adding the package).
      debugPrint('Recitation audio plugin missing: $e');
      _loading = false;
      _error =
          'The audio engine is not part of this build. Stop the app and run '
          'it again (hot reload cannot add it).';
      _notify();
    } catch (e) {
      debugPrint('Recitation audio failed to load: $e');
      _loading = false;
      _error = "Couldn't load the recitation audio. Check your connection.";
      _notify();
    }
  }

  void _bindOnce() {
    if (_subs.isNotEmpty) return;

    _subs.add(
      _player.playerStateStream.listen((s) {
        _playing = s.playing;
        _loading =
            s.processingState == ProcessingState.loading ||
            s.processingState == ProcessingState.buffering;
        if (s.processingState == ProcessingState.completed) _onCompleted();
        _notify();
      }),
    );

    // One event carries both the index and its duration, so a duration is
    // never filed under the wrong ayah when the index changes.
    _subs.add(
      _player.playbackEventStream.listen(
        (e) {
          final i = e.currentIndex;
          if (i == null || i < 0 || i >= _durations.length) return;
          var changed = false;
          if (i != _index) {
            _index = i;
            position.value = Duration.zero;
            changed = true;
          }
          final d = e.duration;
          if (d != null && _durations[i] != d) {
            _durations[i] = d;
            changed = true;
          }
          if (changed) _notify();
        },
        onError: (Object _, StackTrace _) {
          _loading = false;
          _error = 'Audio interrupted. Check your connection and try again.';
          _notify();
        },
      ),
    );

    _subs.add(_player.positionStream.listen((p) => position.value = p));

    _listenTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_player.playing && _player.processingState == ProcessingState.ready) {
        _listenedSeconds++;
      }
    });
  }

  Future<void> _onCompleted() async {
    if (_completing) return;
    _completing = true;
    try {
      await _player.seek(Duration.zero, index: 0);
      if (_looping) {
        unawaited(_player.play());
      } else {
        await _player.pause();
      }
    } finally {
      _completing = false;
    }
  }

  Future<void> togglePlayPause() async {
    if (!_loaded) {
      await init(); // retry after a failed load
      return;
    }
    if (_player.playing) {
      await _player.pause();
    } else {
      unawaited(_player.play());
    }
  }

  Future<void> playAyah(int i) async {
    if (!_loaded || i < 0 || i >= content.ayahs.length) return;
    await _player.seek(Duration.zero, index: i);
    if (!_player.playing) unawaited(_player.play());
  }

  Future<void> nextAyah() => playAyah(_index + 1);

  /// Restarts the current ayah if it has played for a few seconds, otherwise
  /// goes back one ayah.
  Future<void> previousAyah() {
    if (position.value > const Duration(seconds: 3) || _index == 0) {
      return _loaded ? _player.seek(Duration.zero) : Future.value();
    }
    return playAyah(_index - 1);
  }

  Future<void> skip(Duration by) async {
    if (!_loaded) return;
    final target = _player.position + by;
    final dur = _player.duration;
    if (target <= Duration.zero) {
      await _player.seek(Duration.zero);
    } else if (dur != null && target >= dur) {
      if (_index < content.ayahs.length - 1) await nextAyah();
    } else {
      await _player.seek(target);
    }
  }

  Future<void> setSpeed(double value) async {
    _speed = value;
    _notify();
    if (_loaded) await _player.setSpeed(value);
  }

  void toggleLooping() {
    _looping = !_looping;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _listenTimer?.cancel();
    for (final s in _subs) {
      s.cancel();
    }
    // Not awaited (dispose() can't be async); a failure while tearing down the
    // native player must not surface as an unhandled error.
    unawaited(_player.dispose().catchError((Object _) {}));
    position.dispose();
    super.dispose();
  }
}
