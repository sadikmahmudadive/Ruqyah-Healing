import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_gradients.dart';
import 'full_audio_player_screen.dart';
import '../widgets/islamic_pattern.dart';

class EmergencyRuqyahScreen extends StatefulWidget {
  const EmergencyRuqyahScreen({super.key});

  @override
  State<EmergencyRuqyahScreen> createState() => _EmergencyRuqyahScreenState();
}

class _EmergencyRuqyahScreenState extends State<EmergencyRuqyahScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _sleepMode = true;
  final String _sleepTimer = '30 minutes';
  bool _dimScreen = true;
  bool _quranOnly = true;
  bool _autoStop = true;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleStartPlaylist() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const FullAudioPlayerScreen(
          title: 'EMERGENCY RUQYAH',
          verses: 'Calming Spiritual Protection Playlist',
          trackId: 'emergency',
        ),
      ),
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
              // 1. Top Header Area
              _buildTopHeader(),

              // 2. Scrollable Emergency Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 12.0,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),

                      // 1. Breathing orb
                      _buildPulsingEmblem(),

                      const SizedBox(height: 18),

                      // 2. One-Tap Support Header & Button
                      _buildOneTapSupportSection(),

                      const SizedBox(height: 20),

                      // 3. Quick Utility Icons Row (3 Items)
                      _buildQuickUtilityRow(),

                      const SizedBox(height: 20),

                      // 4. Calming Ruqyah Session Banner Card
                      _buildCalmingSessionBanner(),

                      const SizedBox(height: 20),

                      // 5. Emergency Audio Settings Group Card
                      _buildSettingsGroupCard(),

                      const SizedBox(height: 20),

                      // 6. Crisis Disclaimer Banner
                      _buildCrisisDisclaimerBanner(),

                      const SizedBox(height: 14),

                      // 7. Spiritual Support Footer Text
                      const Text(
                        'This is a spiritual support tool, not a medical service.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: Color(0xB3FFFFFF),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 24),
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

  // Top Header Area
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
              margin: const EdgeInsets.only(right: 14),
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

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Emergency Ruqyah',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'We are here for you.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF81C784),
                    ),
                  ),
                ],
              ),
            ),

            // Help Button
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.help_outline_rounded,
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

  // 1. Breathing orb: a slow 8 second cycle (4 in, 4 out) to match the pace
  // of calm breathing. Tapping it starts the recitation.
  Widget _buildPulsingEmblem() {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return SizedBox(
      width: 220,
      height: 236,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final t = reduceMotion ? 0.25 : _pulseController.value;
          final breath = 0.5 - 0.5 * math.cos(t * 2 * math.pi); // 0 -> 1 -> 0
          final inhaling = t < 0.5;

          return Column(
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Soft outer glow that swells with the breath.
                    Container(
                      width: 130 + 64 * breath,
                      height: 130 + 64 * breath,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFE5B860)
                                .withValues(alpha: 0.10 + 0.14 * breath),
                            const Color(0xFFE5B860).withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                    // Thin ring.
                    Container(
                      width: 118 + 36 * breath,
                      height: 118 + 36 * breath,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF81C784)
                              .withValues(alpha: 0.25 + 0.2 * breath),
                          width: 1.2,
                        ),
                      ),
                    ),
                    // The orb itself.
                    Transform.scale(
                      scale: 0.94 + 0.10 * breath,
                      child: GestureDetector(
                        onTap: _handleStartPlaylist,
                        child: Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF1F5C44), Color(0xFF0F3D2C)],
                            ),
                            border: Border.all(
                              color: const Color(0xFFE5B860)
                                  .withValues(alpha: 0.55),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE5B860)
                                    .withValues(alpha: 0.18 + 0.12 * breath),
                                blurRadius: 28,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.self_improvement_rounded,
                              color: Color(0xFFE5B860),
                              size: 44,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                child: Text(
                  inhaling ? 'Breathe in...' : 'Breathe out...',
                  key: ValueKey<bool>(inhaling),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13.5,
                    letterSpacing: 0.4,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // 2. One-Tap Support Header & Button
  Widget _buildOneTapSupportSection() {
    return Column(
      children: [
        const Text(
          'One–Tap Support',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Calm your heart. Seek Allah\'s help.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: Color(0xFF81C784),
          ),
        ),
        const SizedBox(height: 16),

        // Start Emergency Playlist Primary Button
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE9C26F), Color(0xFFD49E35)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD49E35).withValues(alpha: 0.28),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _handleStartPlaylist,
              borderRadius: BorderRadius.circular(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1405).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Color(0xFF1A1405),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Begin calming recitation',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1405),
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 3. Quick Utility Icons Row (3 Items)
  Widget _buildQuickUtilityRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildUtilityItem(icon: Icons.wifi_off_rounded, label: 'Offline Ready'),
        _buildUtilityItem(icon: Icons.download_rounded, label: 'Downloaded'),
        _buildUtilityItem(icon: Icons.menu_book_rounded, label: 'Quran Only'),
      ],
    );
  }

  Widget _buildUtilityItem({required IconData icon, required String label}) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFF133F2E),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1.0,
            ),
          ),
          child: Icon(icon, color: const Color(0xFF81C784), size: 22),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }

  // 4. Calming Ruqyah Session Banner Card
  Widget _buildCalmingSessionBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0E3827),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF2ECC71).withValues(alpha: 0.20),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF1A4835),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.music_note_rounded,
              color: Color(0xFFD49E35),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Calming Ruqyah Session',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Recommended for you',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Color(0xFF81C784),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF133F2E),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              '45 min',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 5. Emergency Audio Settings Group Card
  Widget _buildSettingsGroupCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0E3827),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF2ECC71).withValues(alpha: 0.20),
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          _buildSwitchSettingTile(
            title: 'Sleep Mode',
            value: _sleepMode,
            onChanged: (val) => setState(() => _sleepMode = val),
          ),
          _buildDivider(),
          _buildTimerSettingTile(),
          _buildDivider(),
          _buildSwitchSettingTile(
            title: 'Dim Screen',
            subtitle: 'Reduce brightness',
            value: _dimScreen,
            onChanged: (val) => setState(() => _dimScreen = val),
          ),
          _buildDivider(),
          _buildSwitchSettingTile(
            title: 'Quran Recitation Only',
            subtitle: 'No ads, no music',
            value: _quranOnly,
            onChanged: (val) => setState(() => _quranOnly = val),
          ),
          _buildDivider(),
          _buildSwitchSettingTile(
            title: 'Auto Stop',
            subtitle: 'Stop when timer ends',
            value: _autoStop,
            onChanged: (val) => setState(() => _autoStop = val),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchSettingTile({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11.5,
                      color: Color(0xFF81C784),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              activeThumbColor: Colors.white,
              activeTrackColor: const Color(0xFF6FBF8F),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: const Color(0xFF133F2E),
              onChanged: (val) {
                HapticFeedback.selectionClick();
                onChanged(val);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerSettingTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sleep Timer',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _sleepTimer,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.5,
                    color: Color(0xFF81C784),
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF133F2E),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Text(
                    'Change',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 6. Crisis Disclaimer Banner
  Widget _buildCrisisDisclaimerBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0E3827),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE5B860).withValues(alpha: 0.35),
          width: 1.0,
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.favorite_border_rounded, color: Color(0xFFE5B860), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'If you feel you might harm yourself or someone else, please contact your local emergency services or someone you trust right now.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12.5,
                color: Color(0xFFF1E4C4),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 1, color: Colors.white.withValues(alpha: 0.08));
  }
}
