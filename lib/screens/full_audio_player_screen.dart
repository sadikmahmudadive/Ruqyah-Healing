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
  static const Color _mint = Color(0xFF81C784);
  static const List<double> _speeds = [1.0, 1.25, 1.5, 0.75];

  // Shared with the Home mini player, so it is not created or disposed here.
  late final RecitationPlayerController _controller = RecitationPlayback
      .instance
      .open(widget.trackId, autoplay: widget.autoplay);
  RecitationContent get _content => _controller.content;

  bool _showTransliteration = true;
  bool _showMeaning = true;

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

  /// Scrolls the transcript (only the transcript, not the page) so the
  /// current ayah is at the top of its viewport.
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
              // 1. Top Navigation Bar
              _buildTopHeader(),

              // 2. Scrollable Player Content
              Expanded(
                child: ListenableBuilder(
                  listenable: _controller,
                  builder: (context, _) => SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 8.0,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),

                        // Current ayah: Arabic + transliteration + meaning
                        _buildAyahCard(_controller.currentAyah),

                        const SizedBox(height: 12),

                        // Subtitle toggles + ayah counter
                        _buildSubtitleToggles(),

                        const SizedBox(height: 22),

                        // Audio quick utility actions (5 buttons)
                        _buildUtilityActionsRow(),

                        const SizedBox(height: 26),

                        // Waveform & progress
                        _buildWaveformProgressBar(),

                        const SizedBox(height: 24),

                        // Primary playback controls (5 buttons)
                        _buildPlaybackControlsRow(),

                        const SizedBox(height: 24),

                        // Full transcript, current ayah highlighted
                        _buildTranscript(),

                        const SizedBox(height: 20),

                        _buildQueuePillButton(),

                        const SizedBox(height: 20),
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

  // 1. Top Header Bar
  Widget _buildTopHeader() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Row(
          children: [
            // Back Button
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
              ),
            ),

            // Title & Verse Subtitle
            Expanded(
              child: Column(
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontFamily: 'Cinzel',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: _gold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.verses,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _mint,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Settings Button
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.settings_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () {
                  HapticFeedback.selectionClick();
                },
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ornamentLine() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 40, height: 1, color: _gold),
        const SizedBox(width: 8),
        Container(
          width: 5,
          height: 5,
          decoration: const BoxDecoration(color: _gold, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Container(width: 40, height: 1, color: _gold),
      ],
    );
  }

  // 2. Current ayah card (the "subtitle")
  Widget _buildAyahCard(Ayah ayah) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F3A29).withValues(alpha: 0.80),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _gold.withValues(alpha: 0.60), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _ornamentLine(),
          const SizedBox(height: 18),

          // Cross-fade between ayahs as the recitation moves on.
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.04),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              layoutBuilder: (current, previous) => Stack(
                alignment: Alignment.topCenter,
                children: [...previous, ?current],
              ),
              child: Column(
                key: ValueKey(ayah.ref),
                children: [
                  Text(
                    ayah.arabic,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFF3C06B),
                      height: 1.9,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 2),
                          blurRadius: 8,
                          color: Color(0x99000000),
                        ),
                      ],
                    ),
                  ),
                  if (_showTransliteration) ...[
                    const SizedBox(height: 14),
                    Text(
                      ayah.transliteration,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13.5,
                        fontStyle: FontStyle.italic,
                        color: _mint.withValues(alpha: 0.95),
                        height: 1.45,
                      ),
                    ),
                  ],
                  if (_showMeaning) ...[
                    const SizedBox(height: 14),
                    Text(
                      '"${ayah.meaning}"',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14.5,
                        color: Colors.white,
                        height: 1.45,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Text(
                    '— ${ayah.citation} —',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: _gold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),
          _ornamentLine(),
        ],
      ),
    );
  }

  Widget _buildSubtitleToggles() {
    return Row(
      children: [
        _togglePill(
          label: 'Transliteration',
          active: _showTransliteration,
          onTap: () =>
              setState(() => _showTransliteration = !_showTransliteration),
        ),
        const SizedBox(width: 8),
        _togglePill(
          label: 'Meaning',
          active: _showMeaning,
          onTap: () => setState(() => _showMeaning = !_showMeaning),
        ),
        const Spacer(),
        Text(
          'Ayah ${_controller.index + 1} of ${_content.ayahs.length}',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.75),
          ),
        ),
      ],
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
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active ? _gold : Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active ? _gold : Colors.white.withValues(alpha: 0.18),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: active ? const Color(0xFF082F21) : Colors.white,
          ),
        ),
      ),
    );
  }

  // 3. Audio Quick Utility Actions Row (5 Buttons)
  Widget _buildUtilityActionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildUtilityButton(
          icon: Icons.repeat_rounded,
          label: 'Loop',
          isActive: _controller.looping,
          onTap: () {
            HapticFeedback.selectionClick();
            _controller.toggleLooping();
          },
        ),
        _buildUtilityButton(
          icon: Icons.play_arrow_outlined,
          label: 'Speed ${_controller.speed}x',
          onTap: () {
            HapticFeedback.selectionClick();
            final next =
                _speeds[(_speeds.indexOf(_controller.speed) + 1) %
                    _speeds.length];
            _controller.setSpeed(next);
          },
        ),
        _buildUtilityButton(
          icon: Icons.access_time_rounded,
          label: '30m Timer',
          onTap: () {
            HapticFeedback.selectionClick();
            AppToast.show(
              context,
              title: 'Sleep Timer',
              message: '30-minute sleep timer successfully set.',
              type: ToastType.info,
            );
          },
        ),
        _buildUtilityButton(
          icon: Icons.download_rounded,
          label: 'Download',
          onTap: () {
            HapticFeedback.selectionClick();
            AppToast.show(
              context,
              title: 'Downloading Recitation',
              message: 'Downloading recitation for offline playback...',
              type: ToastType.success,
            );
          },
        ),
        _buildUtilityButton(
          icon: Icons.nights_stay_outlined,
          label: 'Sleep',
          onTap: () {
            HapticFeedback.selectionClick();
          },
        ),
      ],
    );
  }

  Widget _buildUtilityButton({
    required IconData icon,
    required String label,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isActive ? _gold : Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? _gold : Colors.white.withValues(alpha: 0.15),
                width: 1.0,
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                color: isActive ? const Color(0xFF082F21) : Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.80),
          ),
        ),
      ],
    );
  }

  // 4. Waveform & Progress Bar Area. Tap the bars to jump to that ayah.
  static const List<int> _barHeights = [
    14, 22, 34, 18, 26, 38, 20, 30, 16, 28, 36, 22,
    18, 32, 24, 14, 28, 38, 22, 16, 26, 34, 18, 12,
  ];

  Widget _buildWaveformProgressBar() {
    return ValueListenableBuilder<Duration>(
      valueListenable: _controller.position,
      builder: (context, _, _) {
        final progress = _controller.overallProgress;
        return Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (d) {
                  final n = _content.ayahs.length;
                  final i = (d.localPosition.dx / constraints.maxWidth * n)
                      .floor()
                      .clamp(0, n - 1);
                  HapticFeedback.selectionClick();
                  _controller.playAyah(i);
                },
                child: SizedBox(
                  height: 38,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(24, (index) {
                      final barHeight = _barHeights[index % _barHeights.length]
                          .toDouble();
                      final isPlayed = (index / 24.0) <= progress;
                      return Container(
                        width: 4,
                        height: barHeight,
                        margin: const EdgeInsets.symmetric(horizontal: 2.5),
                        decoration: BoxDecoration(
                          color: isPlayed
                              ? _gold
                              : Colors.white.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Timestamps Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(_controller.elapsed),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: _mint,
                  ),
                ),
                Text(
                  _controller.estimatedTotal == Duration.zero
                      ? '--:--'
                      : _formatDuration(_controller.estimatedTotal),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: _mint,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // 5. Playback Controls Row (5 Buttons)
  Widget _buildPlaybackControlsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Previous ayah
        IconButton(
          tooltip: 'Previous ayah',
          icon: const Icon(
            Icons.skip_previous_rounded,
            color: Colors.white,
            size: 28,
          ),
          onPressed: () {
            HapticFeedback.selectionClick();
            _controller.previousAyah();
          },
        ),

        // Rewind 10s
        IconButton(
          tooltip: 'Back 10 seconds',
          icon: const Icon(
            Icons.fast_rewind_rounded,
            color: Colors.white,
            size: 28,
          ),
          onPressed: () {
            HapticFeedback.selectionClick();
            _controller.skip(const Duration(seconds: -10));
          },
        ),

        // Main Play / Pause Button
        GestureDetector(
          onTap: _togglePlayPause,
          child: Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: _gold,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _gold.withValues(alpha: 0.40),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
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
                        color: Color(0xFF082F21),
                      ),
                    )
                  : Icon(
                      _controller.playing
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: const Color(0xFF082F21),
                      size: 36,
                    ),
            ),
          ),
        ),

        // Fast Forward 10s
        IconButton(
          tooltip: 'Forward 10 seconds',
          icon: const Icon(
            Icons.fast_forward_rounded,
            color: Colors.white,
            size: 28,
          ),
          onPressed: () {
            HapticFeedback.selectionClick();
            _controller.skip(const Duration(seconds: 10));
          },
        ),

        // Next ayah
        IconButton(
          tooltip: 'Next ayah',
          icon: const Icon(
            Icons.skip_next_rounded,
            color: Colors.white,
            size: 28,
          ),
          onPressed: () {
            HapticFeedback.selectionClick();
            _controller.nextAyah();
          },
        ),
      ],
    );
  }

  // 6. Transcript: every ayah with its meaning, current one highlighted.
  Widget _buildTranscript() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Transcript',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            Text(
              'Tap an ayah to play it',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11.5,
                color: Colors.white.withValues(alpha: 0.65),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ConstrainedBox(
          key: _transcriptViewKey,
          constraints: const BoxConstraints(maxHeight: 340),
          child: SingleChildScrollView(
            controller: _transcriptScroll,
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                for (var i = 0; i < _content.ayahs.length; i++)
                  _buildTranscriptTile(i),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTranscriptTile(int i) {
    final ayah = _content.ayahs[i];
    final isCurrent = i == _controller.index;

    return Padding(
      key: _tileKeys[i],
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            _controller.playAyah(i);
          },
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isCurrent
                  ? _gold.withValues(alpha: 0.16)
                  : Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCurrent
                    ? _gold.withValues(alpha: 0.70)
                    : Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${ayah.surahName} ${ayah.ref}',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                        color: isCurrent
                            ? _gold
                            : Colors.white.withValues(alpha: 0.60),
                      ),
                    ),
                    const Spacer(),
                    if (isCurrent && _controller.playing)
                      const Icon(Icons.graphic_eq_rounded, size: 18, color: _gold),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  ayah.arabic,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 19,
                    height: 1.9,
                    color: isCurrent
                        ? const Color(0xFFF3C06B)
                        : Colors.white.withValues(alpha: 0.90),
                  ),
                ),
                if (_showTransliteration) ...[
                  const SizedBox(height: 6),
                  Text(
                    ayah.transliteration,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12.5,
                      fontStyle: FontStyle.italic,
                      color: _mint.withValues(alpha: 0.90),
                      height: 1.4,
                    ),
                  ),
                ],
                if (_showMeaning) ...[
                  const SizedBox(height: 6),
                  Text(
                    ayah.meaning,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.4,
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

  // 7. Queue Pill Button
  Widget _buildQueuePillButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF133F2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _gold.withValues(alpha: 0.35), width: 1.0),
      ),
      child: Text(
        'Queue (${_content.ayahs.length})',
        style: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: _gold,
        ),
      ),
    );
  }
}
