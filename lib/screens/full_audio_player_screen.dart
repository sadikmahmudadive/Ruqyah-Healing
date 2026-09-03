import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_gradients.dart';

class FullAudioPlayerScreen extends StatefulWidget {
  final String title;
  final String verses;
  final String reciter;

  const FullAudioPlayerScreen({
    super.key,
    this.title = 'SURAH AL-BAQARAH',
    this.verses = 'Ayet 1–5, 163–164, 255',
    this.reciter = 'Sheikh Al-Afasy',
  });

  @override
  State<FullAudioPlayerScreen> createState() => _FullAudioPlayerScreenState();
}

class _FullAudioPlayerScreenState extends State<FullAudioPlayerScreen> {
  bool _isPlaying = true;
  bool _isLooping = false;
  double _playbackSpeed = 1.0;
  int _currentSeconds = 6 * 60 + 42; // 06:42
  final int _totalSeconds = 24 * 60 + 20; // 24:20
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPlaying && mounted) {
        setState(() {
          if (_currentSeconds < _totalSeconds) {
            _currentSeconds++;
          } else {
            _currentSeconds = 0;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  void _togglePlayPause() {
    HapticFeedback.heavyImpact();
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double progress = _currentSeconds / _totalSeconds;

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
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 8.0,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),

                      // 1. Arabic Calligraphy Scripture Card
                      _buildScriptureCard(),

                      const SizedBox(height: 18),

                      // 2. Translation & Citation Quote
                      _buildTranslationSection(),

                      const SizedBox(height: 24),

                      // 3. Audio Quick Utility Actions Row (5 Buttons)
                      _buildUtilityActionsRow(),

                      const SizedBox(height: 28),

                      // 4. Animated Waveform & Progress Bar
                      _buildWaveformProgressBar(progress),

                      const SizedBox(height: 28),

                      // 5. Primary Playback Controls (5 Buttons)
                      _buildPlaybackControlsRow(),

                      const SizedBox(height: 20),

                      // 6. Queue Pill Button
                      _buildQueuePillButton(),

                      const SizedBox(height: 20),
                    ],
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
                      color: Color(0xFFD49E35),
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
                      color: Color(0xFF81C784),
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

  // 1. Arabic Scripture Calligraphy Card
  Widget _buildScriptureCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: const Color(0xFF0F3A29).withValues(alpha: 0.80),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFD49E35).withValues(alpha: 0.60),
          width: 1.2,
        ),
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
          // Top Golden Decorative Ornament Line
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 40, height: 1, color: const Color(0xFFD49E35)),
              const SizedBox(width: 8),
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: Color(0xFFD49E35),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Container(width: 40, height: 1, color: const Color(0xFFD49E35)),
            ],
          ),

          const SizedBox(height: 20),

          // Quranic Arabic Text Calligraphy
          const Text(
            'ذَٰلِكَ الْكِتَابُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًى لِّلْمُتَّقِينَ',
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Color(0xFFF3C06B),
              height: 1.8,
              shadows: [
                Shadow(
                  offset: Offset(0, 2),
                  blurRadius: 8,
                  color: Color(0x99000000),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Bottom Golden Decorative Ornament Line
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 40, height: 1, color: const Color(0xFFD49E35)),
              const SizedBox(width: 8),
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: Color(0xFFD49E35),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Container(width: 40, height: 1, color: const Color(0xFFD49E35)),
            ],
          ),
        ],
      ),
    );
  }

  // 2. Translation & Citation Quote
  Widget _buildTranslationSection() {
    return Column(
      children: const [
        Text(
          '"This is the Book about which there is no doubt, a guidance for those conscious of Allah."',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14.5,
            fontStyle: FontStyle.italic,
            color: Colors.white,
            height: 1.45,
          ),
        ),
        SizedBox(height: 8),
        Text(
          '— AL-BAQARAH (2:2) —',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: Color(0xFFD49E35),
          ),
        ),
      ],
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
          isActive: _isLooping,
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _isLooping = !_isLooping);
          },
        ),
        _buildUtilityButton(
          icon: Icons.play_arrow_outlined,
          label: 'Speed ${_playbackSpeed}x',
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              _playbackSpeed = _playbackSpeed == 1.0 ? 1.25 : 1.0;
            });
          },
        ),
        _buildUtilityButton(
          icon: Icons.access_time_rounded,
          label: '30m Timer',
          onTap: () {
            HapticFeedback.selectionClick();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('30-minute sleep timer set'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
        _buildUtilityButton(
          icon: Icons.download_rounded,
          label: 'Download',
          onTap: () {
            HapticFeedback.selectionClick();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Downloading recitation for offline playback...'),
                behavior: SnackBarBehavior.floating,
              ),
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
              color: isActive
                  ? const Color(0xFFD49E35)
                  : Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive
                    ? const Color(0xFFD49E35)
                    : Colors.white.withValues(alpha: 0.15),
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

  // 4. Waveform & Progress Bar Area
  Widget _buildWaveformProgressBar(double progress) {
    return Column(
      children: [
        // Waveform Bars Graphic
        SizedBox(
          height: 38,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(24, (index) {
              final heights = [
                14, 22, 34, 18, 26, 38, 20, 30, 16, 28, 36, 22,
                18, 32, 24, 14, 28, 38, 22, 16, 26, 34, 18, 12
              ];
              final barHeight = heights[index % heights.length].toDouble();
              final isPlayed = (index / 24.0) <= progress;

              return Container(
                width: 4,
                height: barHeight,
                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                decoration: BoxDecoration(
                  color: isPlayed
                      ? const Color(0xFFD49E35)
                      : Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 10),

        // Timestamps Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDuration(_currentSeconds),
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF81C784),
              ),
            ),
            Text(
              _formatDuration(_totalSeconds),
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF81C784),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 5. Playback Controls Row (5 Buttons)
  Widget _buildPlaybackControlsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Previous Track
        IconButton(
          icon: const Icon(
            Icons.skip_previous_rounded,
            color: Colors.white,
            size: 28,
          ),
          onPressed: () {
            HapticFeedback.selectionClick();
          },
        ),

        // Rewind 10s
        IconButton(
          icon: const Icon(
            Icons.fast_rewind_rounded,
            color: Colors.white,
            size: 28,
          ),
          onPressed: () {
            HapticFeedback.selectionClick();
            setState(() {
              _currentSeconds = (_currentSeconds - 10).clamp(0, _totalSeconds);
            });
          },
        ),

        // Main Play / Pause Button
        GestureDetector(
          onTap: _togglePlayPause,
          child: Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: const Color(0xFFD49E35),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD49E35).withValues(alpha: 0.40),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                _isPlaying
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
          icon: const Icon(
            Icons.fast_forward_rounded,
            color: Colors.white,
            size: 28,
          ),
          onPressed: () {
            HapticFeedback.selectionClick();
            setState(() {
              _currentSeconds = (_currentSeconds + 10).clamp(0, _totalSeconds);
            });
          },
        ),

        // Next Track
        IconButton(
          icon: const Icon(
            Icons.skip_next_rounded,
            color: Colors.white,
            size: 28,
          ),
          onPressed: () {
            HapticFeedback.selectionClick();
          },
        ),
      ],
    );
  }

  // 6. Queue Pill Button
  Widget _buildQueuePillButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF133F2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD49E35).withValues(alpha: 0.35),
          width: 1.0,
        ),
      ),
      child: const Text(
        'Queue (5)',
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: Color(0xFFD49E35),
        ),
      ),
    );
  }
}
