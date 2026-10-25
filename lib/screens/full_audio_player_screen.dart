import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/recitation.dart';
import '../services/recitation_playback.dart';
import '../services/recitation_player_controller.dart';
import '../theme/app_gradients.dart';
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

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: Container(
          foregroundDecoration: IslamicPatternDecoration(),
          decoration: const BoxDecoration(
            gradient: AppGradients.greenHeaderGradient,
          ),
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: ListenableBuilder(
                  listenable: _controller,
                  builder: (context, _) => SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                    child: Column(
                      children: [
                        _buildArtwork(),
                        const SizedBox(height: 28),
                        _buildTitleRow(),
                        const SizedBox(height: 8),
                        _buildSeekBar(),
                        const SizedBox(height: 4),
                        _buildActionIndicatorHud(),
                        const SizedBox(height: 4),
                        _buildTransportRow(),
                        const SizedBox(height: 18),
                        _buildUtilityRow(),
                        const SizedBox(height: 26),
                        _buildVersesCard(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Floating HUD badge showing the working action of tapped buttons for exactly 2 seconds.
  Widget _buildActionIndicatorHud() {
    return SizedBox(
      height: 38,
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.90, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                ),
                child: child,
              ),
            );
          },
          child: _activeActionMessage != null
              ? Container(
                  key: ValueKey(_activeActionMessage),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF041E15).withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: _gold.withValues(alpha: 0.85),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _gold.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 3),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_activeActionIcon != null) ...[
                        Icon(_activeActionIcon, color: _gold, size: 17),
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
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: _gold.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '2s',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: _goldSoft,
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

  Widget _buildTopBar() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                tooltip: 'Close',
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Now playing',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _content.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: _goldSoft.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'More',
              icon: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _activeButtonId == 'more'
                      ? _gold.withValues(alpha: 0.25)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _activeButtonId == 'more'
                        ? _gold
                        : Colors.transparent,
                    width: 1.2,
                  ),
                ),
                child: const Icon(
                  Icons.more_horiz_rounded,
                  color: Colors.white,
                ),
              ),
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

  /// The "album art": our emerald and gold card with the Arabic title. Eases
  /// down a little while paused, the way the Spotify cover does.
  Widget _buildArtwork() {
    return AnimatedScale(
      scale: _controller.playing ? 1.0 : 0.92,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF14513A), Color(0xFF082F21)],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: _gold.withValues(alpha: 0.65),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 30,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(27),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Positioned.fill(
                  child: IslamicPattern(
                    color: Colors.white,
                    opacity: 0.07,
                    cell: 52,
                    fadeDown: false,
                  ),
                ),
                // Large faint crescent as a watermark.
                Positioned(
                  right: -30,
                  top: -30,
                  child: Icon(
                    Icons.nightlight_round,
                    size: 190,
                    color: _gold.withValues(alpha: 0.07),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ornament(),
                      const SizedBox(height: 22),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _content.arabicTitle,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            fontSize: 46,
                            fontWeight: FontWeight.w700,
                            color: _goldSoft,
                            height: 1.4,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 3),
                                blurRadius: 10,
                                color: Color(0x99000000),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _content.title.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Cinzel',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                      const SizedBox(height: 22),
                      _ornament(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _ornament() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 44, height: 1, color: _gold),
        const SizedBox(width: 8),
        Container(
          width: 5,
          height: 5,
          decoration: const BoxDecoration(color: _gold, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Container(width: 44, height: 1, color: _gold),
      ],
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
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitleText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13.5,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          tooltip: _favourite ? 'Remove from favourites' : 'Add to favourites',
          icon: Icon(
            _favourite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: _favourite ? _gold : Colors.white.withValues(alpha: 0.9),
            size: 28,
          ),
          onPressed: () {
            HapticFeedback.selectionClick();
            setState(() => _favourite = !_favourite);
          },
        ),
      ],
    );
  }

  /// Slider across the whole recitation. Dragging previews the position;
  /// releasing seeks there.
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

        return Column(
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                activeTrackColor: _gold,
                inactiveTrackColor: Colors.white.withValues(alpha: 0.22),
                thumbColor: Colors.white,
                overlayColor: _gold.withValues(alpha: 0.18),
                thumbShape: RoundSliderThumbShape(
                  enabledThumbRadius: _dragValue == null ? 5.5 : 8,
                ),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              ),
              child: Slider(
                value: value,
                onChanged: (v) => setState(() => _dragValue = v),
                onChangeEnd: (v) {
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
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
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
    color: Colors.white.withValues(alpha: 0.7),
  );

  // ───────────────────────────── controls ────────────────────────────

  Widget _buildTransportRow() {
    final isLoopActive = _activeButtonId == 'loop';
    final isPrevActive = _activeButtonId == 'prev';
    final isPlayActive = _activeButtonId == 'play';
    final isNextActive = _activeButtonId == 'next';
    final isSpeedActive = _activeButtonId == 'speed';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Loop (Spotify's repeat)
        IconButton(
          tooltip: 'Loop recitation',
          iconSize: 26,
          icon: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isLoopActive
                  ? _gold.withValues(alpha: 0.25)
                  : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isLoopActive ? _gold : Colors.transparent,
                width: 1.2,
              ),
            ),
            child: Icon(
              _controller.looping
                  ? Icons.repeat_one_rounded
                  : Icons.repeat_rounded,
              color: (_controller.looping || isLoopActive)
                  ? _gold
                  : Colors.white.withValues(alpha: 0.85),
            ),
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
          iconSize: 40,
          icon: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isPrevActive
                  ? _gold.withValues(alpha: 0.25)
                  : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isPrevActive ? _gold : Colors.transparent,
                width: 1.2,
              ),
            ),
            child: Icon(
              Icons.skip_previous_rounded,
              color: isPrevActive ? _gold : Colors.white,
            ),
          ),
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
        GestureDetector(
          onTap: _togglePlayPause,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              color: _gold,
              shape: BoxShape.circle,
              border: Border.all(
                color: isPlayActive ? Colors.white : Colors.transparent,
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isPlayActive
                      ? _gold.withValues(alpha: 0.7)
                      : _gold.withValues(alpha: 0.4),
                  blurRadius: isPlayActive ? 30 : 22,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: _controller.loading
                  ? const SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: _deepGreen,
                      ),
                    )
                  : Icon(
                      _controller.playing
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: _deepGreen,
                      size: 42,
                    ),
            ),
          ),
        ),
        IconButton(
          tooltip: 'Next ayah',
          iconSize: 40,
          icon: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isNextActive
                  ? _gold.withValues(alpha: 0.25)
                  : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isNextActive ? _gold : Colors.transparent,
                width: 1.2,
              ),
            ),
            child: Icon(
              Icons.skip_next_rounded,
              color: isNextActive ? _gold : Colors.white,
            ),
          ),
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
        InkWell(
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: isSpeedActive
                  ? _gold.withValues(alpha: 0.25)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: (_controller.speed != 1.0 || isSpeedActive)
                    ? _gold
                    : Colors.white.withValues(alpha: 0.35),
                width: isSpeedActive ? 1.5 : 1.0,
              ),
            ),
            child: Text(
              '${_controller.speed}x',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: (_controller.speed == 1.0 && !isSpeedActive)
                    ? Colors.white
                    : _gold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUtilityRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
    );
  }

  Widget _utility({
    required String id,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isActive = _activeButtonId == id;
    // Equal-width slots, so four actions fit the row on any phone.
    return Expanded(
      child: Center(child: _utilityButton(isActive, icon, label, onTap)),
    );
  }

  Widget _utilityButton(
    bool isActive,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? _gold.withValues(alpha: 0.22) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? _gold : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? _gold : Colors.white.withValues(alpha: 0.9),
              size: 26,
            ),
            const SizedBox(height: 3),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? _gold : Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────── verse by verse (lyrics) ───────────────────

  /// Spotify's "Lyrics" card, for the recitation: every ayah with its
  /// meaning, the one being recited bright and the rest dimmed.
  Widget _buildVersesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
      decoration: BoxDecoration(
        color: const Color(0xFF14513A).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _gold.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Verse by verse',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          // Wrap, so the toggles move to a second line on narrow screens
          // instead of overflowing.
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _togglePill(
                id: 'translit',
                label: 'Transliteration',
                active: _showTransliteration,
                onTap: () {
                  setState(() => _showTransliteration = !_showTransliteration);
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
          const SizedBox(height: 14),
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
    final isActivePill = _activeButtonId == id;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? _gold : Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActivePill ? Colors.white : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: active ? _deepGreen : Colors.white,
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
        borderRadius: BorderRadius.circular(14),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: isCurrent ? 1.0 : 0.5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: ayah.isDua
                          ? const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2.5,
                            )
                          : EdgeInsets.zero,
                      decoration: ayah.isDua
                          ? BoxDecoration(
                              color: _gold.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: _gold.withValues(alpha: 0.45),
                                width: 0.8,
                              ),
                            )
                          : null,
                      child: Text(
                        ayah.isDua
                            ? (ayah.reference ?? ayah.ref)
                            : '${ayah.surahName} ${ayah.ref}',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                          color: isCurrent ? _gold : Colors.white70,
                        ),
                      ),
                    ),
                    if (isCurrent && _controller.playing) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.graphic_eq_rounded,
                        size: 16,
                        color: _gold,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
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
                      color: Colors.white.withValues(alpha: 0.95),
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
