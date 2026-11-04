import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/recitation.dart';
import '../services/recitation_playback.dart';
import '../services/recitation_player_controller.dart';
import '../widgets/app_toast.dart';
import '../widgets/islamic_pattern.dart';

class FullAudioPlayerScreen extends StatefulWidget {
  final String title;
  final String verses;
  final String reciter;

  /// Key into [kRecitationTracks] or [RuqyahApiService]; unknown ids fall back to Al-Baqarah.
  final String trackId;

  /// Custom recitation content (e.g. dynamically fetched or individual Ayah/Dua)
  final RecitationContent? customContent;

  /// Start playing on open. If this track is already loaded (e.g. from the
  /// Home mini player) it is reused: true resumes it, false leaves it as is.
  final bool autoplay;

  /// Keep playing after this screen closes. Only for entry points that have a
  /// visible mini player (Home); otherwise leaving the screen stops playback,
  /// so audio never plays with no way to control it.
  final bool continueInBackground;

  const FullAudioPlayerScreen({
    super.key,
    this.title = 'SURAH AL-BAQARAH',
    this.verses = 'Ayet 1–5, 163–164, 255',
    this.reciter = 'Sheikh Al-Afasy',
    this.trackId = RecitationPlayback.defaultTrackId,
    this.customContent,
    this.autoplay = true,
    this.continueInBackground = false,
  });

  @override
  State<FullAudioPlayerScreen> createState() => _FullAudioPlayerScreenState();
}

class _FullAudioPlayerScreenState extends State<FullAudioPlayerScreen> {
  static const Color _gold = Color(0xFFD49E35);
  static const Color _goldSoft = Color(0xFFF3C06B);
  static const Color _mint = Color(0xFF81C784);
  static const Color _deepGreen = Color(0xFF082F21);
  static const List<double> _speeds = [1.0, 1.25, 1.5, 0.75];

  // Shared with the Home mini player, so it is not created or disposed here.
  late final RecitationPlayerController _controller = RecitationPlayback
      .instance
      .open(
        widget.trackId,
        autoplay: widget.autoplay,
        customContent: widget.customContent,
      );
  RecitationContent get _content => _controller.content;

  /// Heart on the title row (a personal favourite marker, kept per screen).
  bool _favourite = false;

  bool _showTransliteration = true;
  bool _showMeaning = true;

  /// 2-second button action feedback state
  String? _activeActionMessage;
  IconData? _activeActionIcon;
  String? _activeButtonId;
  Timer? _activeActionTimer;

  // Sleep timer state
  int _sleepTimerMinutes = 0;
  Timer? _sleepTimer;

  /// While the seek handle is being dragged, the value under the finger.
  double? _dragValue;

  final ScrollController _transcriptScroll = ScrollController();
  final GlobalKey _transcriptViewKey = GlobalKey();
  late final List<GlobalKey> _tileKeys = List.generate(
    _content.ayahs.length,
    (_) => GlobalKey(),
  );

  int _lastIndex = 0;
  String? _lastError;

  @override
  void initState() {
    super.initState();
    _lastIndex = _controller.index;
    _lastError = _controller.error;
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (!mounted) return;

    if (_controller.index != _lastIndex) {
      _lastIndex = _controller.index;
      _revealCurrentAyah();
    }

    final error = _controller.error;
    if (error != null && error != _lastError) {
      AppToast.show(
        context,
        title: 'Audio unavailable',
        message: error,
        type: ToastType.error,
        actionLabel: 'Retry',
        onAction: _controller.togglePlayPause, // re-runs the failed load
      );
    }
    _lastError = error;
  }

  /// Scrolls the verse list (only that list, not the page) so the current
  /// ayah is near the top of its viewport.
  void _revealCurrentAyah() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_transcriptScroll.hasClients) return;
      final tile =
          _tileKeys[_controller.index].currentContext?.findRenderObject()
              as RenderBox?;
      final view =
          _transcriptViewKey.currentContext?.findRenderObject() as RenderBox?;
      if (tile == null || view == null) return;

      final dy = tile.localToGlobal(Offset.zero, ancestor: view).dy;
      final target = (_transcriptScroll.offset + dy - 8).clamp(
        0.0,
        _transcriptScroll.position.maxScrollExtent,
      );
      _transcriptScroll.animateTo(
        target,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _activeActionTimer?.cancel();
    _sleepTimer?.cancel();
    _controller.removeListener(_onControllerChanged);
    // The service saves the listening log when playback stops or pauses.
    if (!widget.continueInBackground) RecitationPlayback.instance.stop();
    _transcriptScroll.dispose();
    super.dispose();
  }

  /// Triggers a 2-second visual HUD feedback and button highlight on screen.
  void _showButtonAction({
    required String buttonId,
    required String message,
    required IconData icon,
  }) {
    _activeActionTimer?.cancel();
    setState(() {
      _activeButtonId = buttonId;
      _activeActionMessage = message;
      _activeActionIcon = icon;
    });

    _activeActionTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _activeActionMessage = null;
          _activeActionIcon = null;
          _activeButtonId = null;
        });
      }
    });
  }

  void _cycleSleepTimer() {
    _sleepTimer?.cancel();
    const durations = [15, 30, 45, 60, 0];
    final currentIndex = durations.indexOf(_sleepTimerMinutes);
    final nextMinutes = durations[(currentIndex + 1) % durations.length];
    _sleepTimerMinutes = nextMinutes;

    if (nextMinutes > 0) {
      _sleepTimer = Timer(Duration(minutes: nextMinutes), () {
        if (mounted && _controller.playing) {
          _controller.togglePlayPause();
          AppToast.show(
            context,
            title: 'Sleep Timer Complete',
            message: 'Recitation stopped automatically.',
            type: ToastType.info,
            duration: const Duration(seconds: 2),
          );
        }
      });
      _showButtonAction(
        buttonId: 'sleep',
        message: 'Sleep Timer: $nextMinutes Min Set',
        icon: Icons.bedtime_rounded,
      );
      AppToast.show(
        context,
        title: 'Sleep Timer Active',
        message: 'Audio will pause automatically in $nextMinutes minutes.',
        type: ToastType.info,
        duration: const Duration(seconds: 2),
      );
    } else {
      _showButtonAction(
        buttonId: 'sleep',
        message: 'Sleep Timer: Cancelled (Off)',
        icon: Icons.bedtime_outlined,
      );
      AppToast.show(
        context,
        title: 'Sleep Timer Off',
        message: 'Audio will continue playing normally.',
        type: ToastType.info,
        duration: const Duration(seconds: 2),
      );
    }
  }

  String _formatDuration(Duration d) {
    final mins = d.inMinutes.toString().padLeft(2, '0');
    final secs = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  void _togglePlayPause() {
    HapticFeedback.lightImpact();
    final isCurrentlyPlaying = _controller.playing;
    _controller.togglePlayPause();
    _showButtonAction(
      buttonId: 'play',
      message: isCurrentlyPlaying ? 'Playback Paused' : 'Playing Recitation',
      icon: isCurrentlyPlaying
          ? Icons.pause_circle_filled_rounded
          : Icons.play_circle_fill_rounded,
    );
  }

  static const Color _bgTop = Color(0xFF0C3F2E);
  static const Color _bgBottom = Color(0xFF041710);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: _bgBottom,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _bgBottom,
        body: Stack(
          children: [
            // Ambient backdrop: a deep green wash with two soft glows.
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_bgTop, _bgBottom],
                  ),
                ),
              ),
            ),
            Positioned(top: -140, right: -120, child: _glow(_gold, 340, 0.20)),
            Positioned(top: 380, left: -160, child: _glow(_mint, 340, 0.13)),
            Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: ListenableBuilder(
                    listenable: _controller,
                    builder: (context, _) => SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                      child: Column(
                        children: [
                          _buildArtwork(),
                          const SizedBox(height: 28),
                          _buildTitleRow(),
                          const SizedBox(height: 18),
                          _buildSeekBar(),
                          _buildActionIndicatorHud(),
                          _buildTransportRow(),
                          const SizedBox(height: 22),
                          _buildUtilityRow(),
                          const SizedBox(height: 22),
                          _buildVersesCard(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _glow(Color color, double size, double alpha) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: alpha),
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }

  /// Quiet frosted surface used for the dock, the verse card and the small
  /// round buttons. A tint and a hairline, no blur and no shadow.
  BoxDecoration _glass({double radius = 24, double fill = 0.07}) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: fill),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
    );
  }

  /// A short note under the seek bar that names what the last tap did, then
  /// leaves by itself.
  Widget _buildActionIndicatorHud() {
    return SizedBox(
      height: 44,
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.25),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: _activeActionMessage != null
              ? Container(
                  key: ValueKey(_activeActionMessage),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _gold.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_activeActionIcon != null) ...[
                        Icon(_activeActionIcon, color: _goldSoft, size: 16),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Text(
                          _activeActionMessage!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }

  // ───────────────────────────── top bar ─────────────────────────────

  Widget _roundButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    double size = 44,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.09),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildTopBar() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Row(
          children: [
            _roundButton(
              icon: Icons.arrow_back_ios_new_rounded,
              tooltip: 'Close',
              onPressed: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'NOW PLAYING',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.8,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _content.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            _roundButton(
              icon: Icons.more_horiz_rounded,
              tooltip: 'More',
              onPressed: () {
                HapticFeedback.selectionClick();
                _showButtonAction(
                  buttonId: 'more',
                  message: 'Player Options Menu',
                  icon: Icons.more_horiz_rounded,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────── artwork ─────────────────────────────

  /// The "album art": a deep emerald card with the Arabic title and a live
  /// equalizer. It eases down a little while paused and its glow dims.
  Widget _buildArtwork() {
    final playing = _controller.playing;
    return AnimatedScale(
      scale: playing ? 1.0 : 0.94,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
      child: AspectRatio(
        aspectRatio: 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 380),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1D6E4F), Color(0xFF0A3626)],
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: _gold.withValues(alpha: playing ? 0.24 : 0.08),
                blurRadius: 56,
                offset: const Offset(0, 26),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Positioned.fill(
                  child: IslamicPattern(
                    color: Colors.white,
                    opacity: 0.055,
                    cell: 56,
                    fadeDown: false,
                  ),
                ),
                Positioned(
                  right: -44,
                  bottom: -44,
                  child: Icon(
                    Icons.nightlight_round,
                    size: 210,
                    color: _gold.withValues(alpha: 0.09),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 44),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 30,
                        height: 3,
                        decoration: BoxDecoration(
                          color: _gold,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 18),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _content.arabicTitle,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.w700,
                            color: _goldSoft,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _content.title.toUpperCase(),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Cinzel',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.4,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 22,
                  child: _Equalizer(active: playing, color: _goldSoft),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────── title + seek ──────────────────────────

  Widget _buildTitleRow() {
    final ayah = _controller.currentAyah;
    final titleText = ayah.isDua
        ? ayah.surahName
        : '${ayah.surahName} ${ayah.ref}';
    final subtitleText = ayah.isDua
        ? '${ayah.reference ?? "Prophetic Dua"} · Dua ${_controller.index + 1} of ${_content.ayahs.length}'
        : '${widget.reciter} · Ayah ${_controller.index + 1} of ${_content.ayahs.length}';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titleText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitleText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13.5,
                  color: Colors.white.withValues(alpha: 0.62),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _favourite
                ? _gold.withValues(alpha: 0.18)
                : Colors.white.withValues(alpha: 0.09),
          ),
          child: IconButton(
            tooltip: _favourite
                ? 'Remove from favourites'
                : 'Add to favourites',
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, a) =>
                  ScaleTransition(scale: a, child: child),
              child: Icon(
                _favourite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                key: ValueKey(_favourite),
                color: _favourite ? _goldSoft : Colors.white,
                size: 24,
              ),
            ),
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(() => _favourite = !_favourite);
            },
          ),
        ),
      ],
    );
  }

  /// A waveform scrubber across the whole recitation. Tap or drag to preview
  /// a position; releasing seeks there.
  Widget _buildSeekBar() {
    return ValueListenableBuilder<Duration>(
      valueListenable: _controller.position,
      builder: (context, _, _) {
        final live = _controller.overallProgress.clamp(0.0, 1.0);
        final value = _dragValue ?? live;
        final total = _controller.estimatedTotal;

        // Time shown follows the handle while dragging.
        final shownElapsed = _dragValue == null
            ? _controller.elapsed
            : Duration(milliseconds: (total.inMilliseconds * value).round());

        void commit(double v) {
          HapticFeedback.selectionClick();
          setState(() => _dragValue = null);
          _controller.seekToOverall(v);
          final target = Duration(
            milliseconds: (total.inMilliseconds * v).round(),
          );
          _showButtonAction(
            buttonId: 'seek',
            message: 'Seeked to ${_formatDuration(target)}',
            icon: Icons.timelapse_rounded,
          );
        }

        return Column(
          children: [
            Semantics(
              slider: true,
              label: 'Playback position',
              value:
                  '${_formatDuration(shownElapsed)} of '
                  '${total == Duration.zero ? 'unknown' : _formatDuration(total)}',
              increasedValue: _formatDuration(
                shownElapsed + const Duration(seconds: 10),
              ),
              decreasedValue: _formatDuration(
                shownElapsed - const Duration(seconds: 10) < Duration.zero
                    ? Duration.zero
                    : shownElapsed - const Duration(seconds: 10),
              ),
              onIncrease: () => _controller.skip(const Duration(seconds: 10)),
              onDecrease: () => _controller.skip(const Duration(seconds: -10)),
              child: LayoutBuilder(
                builder: (context, c) {
                  double at(double dx) =>
                      (dx / c.maxWidth).clamp(0.0, 1.0).toDouble();
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: (d) => commit(at(d.localPosition.dx)),
                    onHorizontalDragStart: (d) =>
                        setState(() => _dragValue = at(d.localPosition.dx)),
                    onHorizontalDragUpdate: (d) =>
                        setState(() => _dragValue = at(d.localPosition.dx)),
                    onHorizontalDragEnd: (_) => commit(_dragValue ?? live),
                    onHorizontalDragCancel: () =>
                        setState(() => _dragValue = null),
                    child: SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: _WaveformPainter(
                          progress: value,
                          seed: _content.title.hashCode,
                          active: _gold,
                          idle: Colors.white.withValues(alpha: 0.22),
                          dragging: _dragValue != null,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDuration(shownElapsed), style: _timeStyle),
                  Text(
                    total == Duration.zero ? '--:--' : _formatDuration(total),
                    style: _timeStyle,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  static final TextStyle _timeStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Colors.white.withValues(alpha: 0.62),
  );

  // ───────────────────────────── controls ────────────────────────────

  Widget _buildTransportRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Loop
        IconButton(
          tooltip: 'Loop recitation',
          iconSize: 24,
          // Tight padding so the row fits a 320px-wide phone.
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(),
          icon: Icon(
            _controller.looping
                ? Icons.repeat_one_rounded
                : Icons.repeat_rounded,
            color: _controller.looping
                ? _goldSoft
                : Colors.white.withValues(alpha: 0.75),
          ),
          onPressed: () {
            HapticFeedback.selectionClick();
            _controller.toggleLooping();
            _showButtonAction(
              buttonId: 'loop',
              message: _controller.looping
                  ? 'Repeat Recitation: ON'
                  : 'Repeat Recitation: OFF',
              icon: _controller.looping
                  ? Icons.repeat_one_rounded
                  : Icons.repeat_rounded,
            );
          },
        ),
        IconButton(
          tooltip: 'Previous ayah',
          iconSize: 34,
          // Tight padding so the row fits a 320px-wide phone.
          padding: const EdgeInsets.all(6),
          constraints: const BoxConstraints(),
          icon: const Icon(Icons.skip_previous_rounded, color: Colors.white),
          onPressed: () {
            HapticFeedback.selectionClick();
            _controller.previousAyah();
            final a = _controller.currentAyah;
            _showButtonAction(
              buttonId: 'prev',
              message: a.isDua
                  ? 'Previous: ${a.surahName}'
                  : 'Previous: ${a.surahName} ${a.ref}',
              icon: Icons.skip_previous_rounded,
            );
          },
        ),
        Semantics(
          button: true,
          label: _controller.playing ? 'Pause' : 'Play',
          child: GestureDetector(
            onTap: _togglePlayPause,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: _gold,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _gold.withValues(
                      alpha: _controller.playing ? 0.38 : 0.2,
                    ),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: _controller.loading
                    ? const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: _deepGreen,
                        ),
                      )
                    : AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        transitionBuilder: (child, a) =>
                            ScaleTransition(scale: a, child: child),
                        child: Icon(
                          _controller.playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          key: ValueKey(_controller.playing),
                          color: _deepGreen,
                          size: 42,
                        ),
                      ),
              ),
            ),
          ),
        ),
        IconButton(
          tooltip: 'Next ayah',
          iconSize: 34,
          // Tight padding so the row fits a 320px-wide phone.
          padding: const EdgeInsets.all(6),
          constraints: const BoxConstraints(),
          icon: const Icon(Icons.skip_next_rounded, color: Colors.white),
          onPressed: () {
            HapticFeedback.selectionClick();
            _controller.nextAyah();
            final a = _controller.currentAyah;
            _showButtonAction(
              buttonId: 'next',
              message: a.isDua
                  ? 'Next: ${a.surahName}'
                  : 'Next: ${a.surahName} ${a.ref}',
              icon: Icons.skip_next_rounded,
            );
          },
        ),
        // Speed (cycles through the options)
        Semantics(
          button: true,
          label: 'Playback speed ${_controller.speed}x',
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              final next =
                  _speeds[(_speeds.indexOf(_controller.speed) + 1) %
                      _speeds.length];
              _controller.setSpeed(next);
              _showButtonAction(
                buttonId: 'speed',
                message: 'Speed: ${next}x',
                icon: Icons.speed_rounded,
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              constraints: const BoxConstraints(minWidth: 48, minHeight: 36),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: _controller.speed != 1.0
                    ? _gold.withValues(alpha: 0.18)
                    : Colors.white.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${_controller.speed}x',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: _controller.speed == 1.0 ? Colors.white : _goldSoft,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// The four secondary actions in one frosted dock.
  Widget _buildUtilityRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: _glass(radius: 26),
      child: Row(
        children: [
          _utility(
            id: 'back10',
            icon: Icons.replay_10_rounded,
            label: 'Back 10s',
            onTap: () {
              _controller.skip(const Duration(seconds: -10));
              _showButtonAction(
                buttonId: 'back10',
                message: 'Rewound 10 Seconds (-10s)',
                icon: Icons.replay_10_rounded,
              );
            },
          ),
          _utility(
            id: 'forward10',
            icon: Icons.forward_10_rounded,
            label: 'Forward 10s',
            onTap: () {
              _controller.skip(const Duration(seconds: 10));
              _showButtonAction(
                buttonId: 'forward10',
                message: 'Forwarded 10 Seconds (+10s)',
                icon: Icons.forward_10_rounded,
              );
            },
          ),
          _utility(
            id: 'download',
            icon: Icons.download_for_offline_outlined,
            label: 'Download',
            onTap: () {
              _showButtonAction(
                buttonId: 'download',
                message: 'Downloading for Offline Listening...',
                icon: Icons.download_rounded,
              );
              AppToast.show(
                context,
                title: 'Downloading Recitation',
                message: 'Downloading recitation for offline playback...',
                type: ToastType.success,
                duration: const Duration(seconds: 2),
              );
            },
          ),
          _utility(
            id: 'sleep',
            icon: _sleepTimerMinutes > 0
                ? Icons.bedtime_rounded
                : Icons.bedtime_outlined,
            label: _sleepTimerMinutes > 0
                ? '${_sleepTimerMinutes}m timer'
                : 'Sleep timer',
            onTap: _cycleSleepTimer,
          ),
        ],
      ),
    );
  }

  Widget _utility({
    required String id,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isActive =
        _activeButtonId == id || (id == 'sleep' && _sleepTimerMinutes > 0);
    // Equal-width slots, so four actions fit the row on any phone.
    return Expanded(
      child: Semantics(
        button: true,
        label: label,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isActive
                      ? _goldSoft
                      : Colors.white.withValues(alpha: 0.9),
                  size: 24,
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive
                          ? _goldSoft
                          : Colors.white.withValues(alpha: 0.65),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────── verse by verse (lyrics) ───────────────────

  /// The recitation as "lyrics": every ayah with its meaning, the one being
  /// recited bright and the rest dimmed.
  Widget _buildVersesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      decoration: _glass(radius: 28, fill: 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Verse by verse',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Colors.white.withValues(alpha: 0.95),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Wrap, so the toggles move to a second line on narrow screens
          // instead of overflowing.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _togglePill(
                  id: 'translit',
                  label: 'Transliteration',
                  active: _showTransliteration,
                  onTap: () {
                    setState(
                      () => _showTransliteration = !_showTransliteration,
                    );
                    _showButtonAction(
                      buttonId: 'translit',
                      message: _showTransliteration
                          ? 'Transliteration: Shown'
                          : 'Transliteration: Hidden',
                      icon: Icons.subtitles_rounded,
                    );
                  },
                ),
                _togglePill(
                  id: 'meaning',
                  label: 'Meaning',
                  active: _showMeaning,
                  onTap: () {
                    setState(() => _showMeaning = !_showMeaning);
                    _showButtonAction(
                      buttonId: 'meaning',
                      message: _showMeaning
                          ? 'Meaning: Shown'
                          : 'Meaning: Hidden',
                      icon: Icons.translate_rounded,
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            key: _transcriptViewKey,
            constraints: const BoxConstraints(maxHeight: 420),
            child: SingleChildScrollView(
              controller: _transcriptScroll,
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  for (var i = 0; i < _content.ayahs.length; i++)
                    _buildVerse(i),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _togglePill({
    required String id,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      toggled: active,
      label: label,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          constraints: const BoxConstraints(minHeight: 36),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: active ? _gold : Colors.white.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: active ? _deepGreen : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerse(int i) {
    final ayah = _content.ayahs[i];
    final isCurrent = i == _controller.index;

    return Padding(
      key: _tileKeys[i],
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          _controller.playAyah(i);
          _showButtonAction(
            buttonId: 'verse_$i',
            message: ayah.isDua
                ? 'Playing: ${ayah.surahName}'
                : 'Playing: ${ayah.surahName} ${ayah.ref}',
            icon: Icons.play_circle_outline_rounded,
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          decoration: BoxDecoration(
            color: isCurrent
                ? Colors.white.withValues(alpha: 0.07)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isCurrent ? 1.0 : 0.55,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? _gold.withValues(alpha: 0.18)
                              : Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          ayah.isDua
                              ? (ayah.reference ?? ayah.ref)
                              : '${ayah.surahName} ${ayah.ref}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                            color: isCurrent ? _goldSoft : Colors.white70,
                          ),
                        ),
                      ),
                    ),
                    if (isCurrent && _controller.playing) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.graphic_eq_rounded,
                        size: 16,
                        color: _goldSoft,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: isCurrent ? 26 : 21,
                      fontWeight: FontWeight.w700,
                      height: 1.9,
                      color: isCurrent ? _goldSoft : Colors.white,
                    ),
                    child: Text(ayah.arabic, textDirection: TextDirection.rtl),
                  ),
                ),
                if (_showTransliteration) ...[
                  const SizedBox(height: 4),
                  Text(
                    ayah.transliteration,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                      color: _mint.withValues(alpha: 0.95),
                    ),
                  ),
                ],
                if (_showMeaning) ...[
                  const SizedBox(height: 6),
                  Text(
                    ayah.meaning,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: isCurrent ? 15 : 13.5,
                      height: 1.45,
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bars of a waveform with the played part in [active]. The shape is
/// pseudo-random but fixed per recitation (from [seed]), so it looks like a
/// real audio profile and does not jump around.
class _WaveformPainter extends CustomPainter {
  final double progress;
  final int seed;
  final Color active;
  final Color idle;
  final bool dragging;

  _WaveformPainter({
    required this.progress,
    required this.seed,
    required this.active,
    required this.idle,
    required this.dragging,
  });

  static const double _barW = 3;
  static const double _gap = 3;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final n = ((size.width + _gap) / (_barW + _gap)).floor().clamp(8, 200);
    final step = size.width / n;
    final mid = size.height / 2;
    var s = seed & 0x7fffffff;
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = _barW;
    final playedBars = progress.clamp(0.0, 1.0) * n;

    for (var i = 0; i < n; i++) {
      s = (s * 1103515245 + 12345) & 0x7fffffff;
      final r = (s % 1000) / 1000;
      // A soft swell across the track with some randomness on top.
      final swell = 0.72 + 0.28 * math.sin(i / n * 3 * math.pi);
      final h = (size.height * (0.2 + 0.7 * r) * swell).clamp(5.0, size.height);
      final x = step * i + step / 2;
      paint.color = i < playedBars ? active : idle;
      canvas.drawLine(Offset(x, mid - h / 2), Offset(x, mid + h / 2), paint);
    }

    // Playhead
    final px = (progress.clamp(0.0, 1.0) * size.width).clamp(0.0, size.width);
    canvas.drawCircle(
      Offset(px, mid),
      dragging ? 7 : 5,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter old) =>
      old.progress != progress ||
      old.seed != seed ||
      old.dragging != dragging ||
      old.active != active ||
      old.idle != idle;
}

/// Five bars that dance while [active] and rest low when not. One controller
/// drives a transform-free repaint, and it holds still under reduced motion.
class _Equalizer extends StatefulWidget {
  final bool active;
  final Color color;
  const _Equalizer({required this.active, required this.color});

  @override
  State<_Equalizer> createState() => _EqualizerState();
}

class _EqualizerState extends State<_Equalizer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  bool get _still => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  void _sync() {
    if (widget.active && !_still) {
      if (!_c.isAnimating) _c.repeat();
    } else {
      _c.stop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(covariant _Equalizer old) {
    super.didUpdateWidget(old);
    _sync();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: RepaintBoundary(
        child: CustomPaint(
          size: const Size(34, 18),
          painter: _EqualizerPainter(_c, widget.color, widget.active),
        ),
      ),
    );
  }
}

class _EqualizerPainter extends CustomPainter {
  final Animation<double> t;
  final Color color;
  final bool active;

  _EqualizerPainter(this.t, this.color, this.active) : super(repaint: t);

  @override
  void paint(Canvas canvas, Size size) {
    const bars = 5;
    final w = size.width / (bars * 2 - 1);
    final paint = Paint()..color = color.withValues(alpha: active ? 0.95 : 0.4);
    for (var i = 0; i < bars; i++) {
      final phase = t.value * 6.2831853 * (1 + i * 0.35) + i * 1.3;
      final level = active ? 0.35 + 0.65 * (0.5 + 0.5 * math.sin(phase)) : 0.22;
      final h = size.height * level;
      final x = i * w * 2;
      canvas.drawRRect(
        RRect.fromLTRBR(
          x,
          size.height - h,
          x + w,
          size.height,
          Radius.circular(w / 2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _EqualizerPainter old) =>
      old.color != color || old.active != active;
}
