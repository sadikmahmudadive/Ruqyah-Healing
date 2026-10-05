import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/recitation.dart';
import '../services/recitation_playback.dart';
import '../services/recitation_player_controller.dart';
import '../theme/app_gradients.dart';
import '../widgets/app_toast.dart';

class FullAudioPlayerScreen extends StatefulWidget {
  final String title;
  final String verses;
  final String reciter;

  /// Key into [kRecitationTracks]; unknown ids fall back to Al-Baqarah.
  final String trackId;

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
      .open(widget.trackId, autoplay: widget.autoplay);
  RecitationContent get _content => _controller.content;

  bool _showTransliteration = true;
  bool _showMeaning = true;

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
    _controller.removeListener(_onControllerChanged);
    // The service saves the listening log when playback stops or pauses.
    if (!widget.continueInBackground) RecitationPlayback.instance.stop();
    _transcriptScroll.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final mins = d.inMinutes.toString().padLeft(2, '0');
    final secs = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  void _togglePlayPause() {
    HapticFeedback.heavyImpact();
    _controller.togglePlayPause();
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

  // ───────────────────────────── top bar ─────────────────────────────

  Widget _buildTopBar() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Close',
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white,
                size: 32,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'PLAYING FROM',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: Colors.white.withValues(alpha: 0.65),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _content.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'More',
              icon: const Icon(Icons.more_horiz_rounded, color: Colors.white),
              onPressed: HapticFeedback.selectionClick,
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
            border: Border.all(color: _gold.withValues(alpha: 0.65), width: 1.4),
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
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${ayah.surahName} ${ayah.ref}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${widget.reciter} · Ayah ${_controller.index + 1} of '
                '${_content.ayahs.length}',
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
          tooltip: 'Download for offline',
          icon: Icon(
            Icons.download_for_offline_outlined,
            color: Colors.white.withValues(alpha: 0.9),
            size: 28,
          ),
          onPressed: () {
            HapticFeedback.selectionClick();
            AppToast.show(
              context,
              title: 'Downloading Recitation',
              message: 'Downloading recitation for offline playback...',
              type: ToastType.success,
            );
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Loop (Spotify's repeat)
        IconButton(
          tooltip: 'Loop recitation',
          iconSize: 26,
          icon: Icon(
            Icons.repeat_rounded,
            color: _controller.looping
                ? _gold
                : Colors.white.withValues(alpha: 0.85),
          ),
          onPressed: () {
            HapticFeedback.selectionClick();
            _controller.toggleLooping();
          },
        ),
        IconButton(
          tooltip: 'Previous ayah',
          iconSize: 40,
          icon: const Icon(Icons.skip_previous_rounded, color: Colors.white),
          onPressed: () {
            HapticFeedback.selectionClick();
            _controller.previousAyah();
          },
        ),
        GestureDetector(
          onTap: _togglePlayPause,
          child: Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              color: _gold,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _gold.withValues(alpha: 0.4),
                  blurRadius: 22,
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
          icon: const Icon(Icons.skip_next_rounded, color: Colors.white),
          onPressed: () {
            HapticFeedback.selectionClick();
            _controller.nextAyah();
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
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _controller.speed == 1.0
                    ? Colors.white.withValues(alpha: 0.35)
                    : _gold,
              ),
            ),
            child: Text(
              '${_controller.speed}x',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: _controller.speed == 1.0 ? Colors.white : _gold,
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
          icon: Icons.replay_10_rounded,
          label: 'Back 10s',
          onTap: () => _controller.skip(const Duration(seconds: -10)),
        ),
        _utility(
          icon: Icons.forward_10_rounded,
          label: 'Forward 10s',
          onTap: () => _controller.skip(const Duration(seconds: 10)),
        ),
        _utility(
          icon: Icons.bedtime_outlined,
          label: 'Sleep timer',
          onTap: () => AppToast.show(
            context,
            title: 'Sleep Timer',
            message: '30-minute sleep timer successfully set.',
            type: ToastType.info,
          ),
        ),
      ],
    );
  }

  Widget _utility({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 26),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.7),
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
              fontWeight: FontWeight.w800,
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
                label: 'Transliteration',
                active: _showTransliteration,
                onTap: () => setState(
                  () => _showTransliteration = !_showTransliteration,
                ),
              ),
              _togglePill(
                label: 'Meaning',
                active: _showMeaning,
                onTap: () => setState(() => _showMeaning = !_showMeaning),
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
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
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
                    Text(
                      ayah.ref,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                        color: isCurrent ? _gold : Colors.white70,
                      ),
                    ),
                    if (isCurrent && _controller.playing) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.graphic_eq_rounded, size: 16, color: _gold),
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
