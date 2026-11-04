import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../theme/app_theme.dart';
import '../animations/press.dart';
import 'preview_limiter.dart';
import 'unlock_card.dart';

/// Network video player for lessons and course previews.
///
/// * Unlocked: plays everything, with a seek bar, and calls [onEnded] once
///   when the video reaches its end.
/// * Locked: plays at most the preview limit, then pauses at the limit and
///   covers the video with an [UnlockCard]. Seeking is clamped to the limit
///   and pressing play past it cannot run on.
///
/// An empty [url] or a load failure shows an inline message with Retry. The
/// controller is released when the widget leaves the tree.
class CourseVideoPlayer extends StatefulWidget {
  const CourseVideoPlayer({
    super.key,
    required this.url,
    this.locked = false,
    this.priceLabel,
    this.onUnlock,
    this.onEnded,
    this.title,
  });

  final String url;
  final bool locked;
  final String? priceLabel;
  final VoidCallback? onUnlock;
  final VoidCallback? onEnded;
  final String? title;

  static const String noVideoMessage =
      'No video is available for this lesson yet.';
  static const String loadFailedMessage =
      'This video could not be loaded. Check your connection and try again.';
  static const String retryLabel = 'Retry';

  @override
  State<CourseVideoPlayer> createState() => _CourseVideoPlayerState();
}

class _CourseVideoPlayerState extends State<CourseVideoPlayer> {
  final PreviewLimiter _limiter = PreviewLimiter();

  VideoPlayerController? _controller;
  int _loadId = 0;
  bool _ready = false;
  bool _failed = false;
  bool _emptyUrl = false;
  bool _showCard = false;
  bool _endedFired = false;
  bool _holding = false;
  double? _dragMs;

  @override
  void initState() {
    super.initState();
    _begin();
  }

  @override
  void didUpdateWidget(CourseVideoPlayer old) {
    super.didUpdateWidget(old);
    if (old.url != widget.url) {
      _begin();
    } else if (old.locked != widget.locked) {
      // Unlocking lifts the limit; locking again re-arms it from the current
      // position on the next tick.
      _limiter.reset();
      _showCard = false;
      _endedFired = false;
    }
  }

  @override
  void dispose() {
    _loadId++;
    _release();
    super.dispose();
  }

  /// Drops the current controller (listener first) and disposes it.
  void _release() {
    final c = _controller;
    _controller = null;
    if (c == null) return;
    c.removeListener(_onTick);
    c.dispose().catchError((Object _) {});
  }

  /// Resets state and starts loading [CourseVideoPlayer.url]. Does not call
  /// setState; callers either are in initState/didUpdateWidget or wrap it.
  void _begin() {
    final id = ++_loadId;
    _release();
    _ready = false;
    _failed = false;
    _emptyUrl = false;
    _showCard = false;
    _endedFired = false;
    _holding = false;
    _dragMs = null;
    _limiter.reset();

    final raw = widget.url.trim();
    final uri = raw.isEmpty ? null : Uri.tryParse(raw);
    if (uri == null) {
      _failed = true;
      _emptyUrl = raw.isEmpty;
      return;
    }
    final c = VideoPlayerController.networkUrl(uri);
    _controller = c;
    _connect(c, id);
  }

  Future<void> _connect(VideoPlayerController c, int id) async {
    try {
      await c.initialize();
    } catch (_) {
      if (id != _loadId || !mounted) return;
      _release();
      setState(() => _failed = true);
      return;
    }
    // Superseded or disposed while loading: the new owner already released c.
    if (id != _loadId || !mounted) return;
    c.addListener(_onTick);
    setState(() => _ready = true);
  }

  void _retry() => setState(_begin);

  void _fail() {
    _release();
    if (mounted) setState(() => _failed = true);
  }

  void _onTick() {
    final c = _controller;
    if (c == null || !mounted) return;
    final v = c.value;
    if (v.hasError) {
      _fail();
      return;
    }
    if (widget.locked) {
      _enforceLimit(c, v);
    } else {
      _watchForEnd(v);
    }
  }

  void _enforceLimit(VideoPlayerController c, VideoPlayerValue v) {
    if (_limiter.reached) {
      // Anything that restarts playback, or lets the position drift past the
      // limit, is pulled straight back.
      if (v.isPlaying || v.position > _limiter.limit) _holdAtLimit(c);
      return;
    }
    // A video shorter than the limit counts as fully previewed once it ends.
    final finishedShort = v.isCompleted && v.duration > Duration.zero;
    final position = finishedShort ? _limiter.limit : v.position;
    if (_limiter.onPosition(position)) {
      _holdAtLimit(c);
      setState(() => _showCard = true);
    }
  }

  Future<void> _holdAtLimit(VideoPlayerController c) async {
    if (_holding) return;
    _holding = true;
    try {
      await c.pause();
      await c.seekTo(_limiter.limit);
    } finally {
      _holding = false;
    }
  }

  void _watchForEnd(VideoPlayerValue v) {
    final ended = v.duration > Duration.zero && v.isCompleted;
    if (ended && !_endedFired) {
      _endedFired = true;
      widget.onEnded?.call();
    } else if (!ended) {
      _endedFired = false;
    }
  }

  Future<void> _togglePlay() async {
    final c = _controller;
    if (c == null || !_ready) return;
    if (c.value.isPlaying) {
      await c.pause();
    } else if (!(widget.locked && _limiter.reached)) {
      await c.play();
    }
  }

  Future<void> _seek(Duration target) async {
    final c = _controller;
    if (c == null || !_ready) return;
    final clamped = widget.locked ? _limiter.clampSeek(target) : target;
    await c.seekTo(clamped);
  }

  /// Restarts the preview from the beginning.
  Future<void> _replay() async {
    final c = _controller;
    if (c == null || !_ready) return;
    // Seek first: resetting the limiter while still parked at the limit would
    // make it fire again on the next tick.
    await c.seekTo(Duration.zero);
    if (!mounted || _controller != c) return;
    _limiter.reset();
    setState(() => _showCard = false);
    await c.play();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: ColoredBox(color: Colors.black, child: _buildBody(context)),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_failed) {
      return _InlineMessage(
        message: _emptyUrl
            ? CourseVideoPlayer.noVideoMessage
            : CourseVideoPlayer.loadFailedMessage,
        onRetry: _retry,
      );
    }
    final c = _controller;
    if (!_ready || c == null) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            color: AppColors.accentGold,
          ),
        ),
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: AspectRatio(
            aspectRatio: c.value.aspectRatio,
            child: VideoPlayer(c),
          ),
        ),
        ValueListenableBuilder<VideoPlayerValue>(
          valueListenable: c,
          builder: (context, value, _) => _Controls(
            value: value,
            title: widget.title,
            locked: widget.locked,
            limit: _limiter.limit,
            dragMs: _dragMs,
            onToggle: _togglePlay,
            onDrag: (ms) => setState(() => _dragMs = ms),
            onSeek: (ms) {
              setState(() => _dragMs = null);
              _seek(Duration(milliseconds: ms.round()));
            },
          ),
        ),
        if (_showCard && widget.locked)
          ColoredBox(
            color: Colors.black.withValues(alpha: 0.72),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Center(
                child: UnlockCard(
                  priceLabel: widget.priceLabel ?? '',
                  onUnlock: widget.onUnlock ?? () {},
                  onReplay: _replay,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.value,
    required this.title,
    required this.locked,
    required this.limit,
    required this.dragMs,
    required this.onToggle,
    required this.onDrag,
    required this.onSeek,
  });

  final VideoPlayerValue value;
  final String? title;
  final bool locked;
  final Duration limit;
  final double? dragMs;
  final VoidCallback onToggle;
  final ValueChanged<double> onDrag;
  final ValueChanged<double> onSeek;

  static String _format(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final total = locked && value.duration > limit ? limit : value.duration;
    final maxMs = total.inMilliseconds < 1 ? 1.0 : total.inMilliseconds * 1.0;
    final posMs = (dragMs ?? value.position.inMilliseconds * 1.0).clamp(
      0.0,
      maxMs,
    );
    final caption = AppType.caption.copyWith(color: Colors.white70);

    return Stack(
      fit: StackFit.expand,
      children: [
        if (title != null && title!.isNotEmpty)
          Positioned(
            left: 12,
            right: 12,
            top: 10,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppType.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (locked)
                  Text('Preview', style: caption.copyWith(letterSpacing: 0.4)),
              ],
            ),
          ),
        Center(
          child: PressScale(
            onTap: onToggle,
            child: Semantics(
              button: true,
              label: value.isPlaying ? 'Pause' : 'Play',
              excludeSemantics: true,
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  value.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 12,
          right: 12,
          bottom: 4,
          child: Row(
            children: [
              Text(
                _format(Duration(milliseconds: posMs.round())),
                style: caption,
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    activeTrackColor: AppColors.accentGold,
                    inactiveTrackColor: Colors.white24,
                    thumbColor: AppColors.accentGold,
                    overlayShape: SliderComponentShape.noOverlay,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                  ),
                  child: Slider(
                    value: posMs,
                    min: 0,
                    max: maxMs,
                    onChanged: onDrag,
                    onChangeEnd: onSeek,
                  ),
                ),
              ),
              Text(_format(total), style: caption),
            ],
          ),
        ),
      ],
    );
  }
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    // Same strategy as UnlockCard: text capped at 1.3x, and the content
    // scales down rather than overflowing a short 16:9 box.
    return ColoredBox(
      color: context.cardBg,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : 320.0;
          return Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(
                width: width,
                child: MediaQuery.withClampedTextScaling(
                  maxScaleFactor: 1.3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    child: _content(context),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _content(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.videocam_off_outlined, size: 24, color: context.textMuted),
        const SizedBox(height: 6),
        Text(
          message,
          textAlign: TextAlign.center,
          style: AppType.caption.copyWith(color: context.textSecondary),
        ),
        const SizedBox(height: 8),
        PressScale(
          onTap: onRetry,
          child: Semantics(
            button: true,
            label: CourseVideoPlayer.retryLabel,
            excludeSemantics: true,
            child: Container(
              constraints: const BoxConstraints(minHeight: 44, minWidth: 96),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: context.cardBorderStrong),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                CourseVideoPlayer.retryLabel,
                style: AppType.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
