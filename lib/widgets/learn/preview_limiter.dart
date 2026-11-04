import '../../models/course_model.dart';

/// Decides when a locked (not yet purchased) video has played long enough.
///
/// Pure logic with no Flutter or video dependency, so the 10-second preview
/// rule can be unit-tested on its own. The player only feeds it positions.
class PreviewLimiter {
  PreviewLimiter({this.limit = kPreviewLimit});

  /// How much of the video may be watched before the Unlock card appears.
  final Duration limit;

  bool _reached = false;

  /// True once a position at or past [limit] has been seen (until [reset]).
  bool get reached => _reached;

  /// Feeds the current playback position. Returns true the first time [p]
  /// reaches [limit], and false on every call after that.
  bool onPosition(Duration p) {
    if (_reached || p < limit) return false;
    _reached = true;
    return true;
  }

  /// Keeps a requested seek target inside the allowed range `0..limit`.
  Duration clampSeek(Duration target) {
    if (target > limit) return limit;
    if (target < Duration.zero) return Duration.zero;
    return target;
  }

  /// Forgets that the limit was reached, so a replay can hit it again.
  void reset() => _reached = false;
}
