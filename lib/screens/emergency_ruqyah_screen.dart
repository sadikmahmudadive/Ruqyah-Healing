import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_gradients.dart';
import 'full_audio_player_screen.dart';

class EmergencyRuqyahScreen extends StatefulWidget {
  const EmergencyRuqyahScreen({super.key});

  @override
  State<EmergencyRuqyahScreen> createState() => _EmergencyRuqyahScreenState();
}

class _EmergencyRuqyahScreenState extends State<EmergencyRuqyahScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _sleepMode = true;
  String _sleepTimer = '30 minutes';
  bool _dimScreen = true;
  bool _quranOnly = true;
  bool _autoStop = true;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleStartPlaylist() {
    HapticFeedback.heavyImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const FullAudioPlayerScreen(
          title: 'EMERGENCY RUQYAH',
          verses: 'Calming Spiritual Protection Playlist',
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

                      // 1. Pulsing Warning Emblem
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
                          fontSize: 11.5,
                          color: Color(0x8881C784),
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
                      fontWeight: FontWeight.w800,
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

  // 1. Pulsing Warning Emblem
  Widget _buildPulsingEmblem() {
    return SizedBox(
      width: 180,
      height: 180,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final progress = _pulseController.value;
          final wave1Val = progress;
          final wave2Val = (progress + 0.5) % 1.0;

          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer Expanding Wave 2
              Transform.scale(
                scale: 1.0 + (wave2Val * 0.50),
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE74C3C)
                          .withValues(alpha: (1.0 - wave2Val) * 0.45),
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              // Inner Expanding Wave 1
              Transform.scale(
                scale: 1.0 + (wave1Val * 0.40),
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE74C3C)
                        .withValues(alpha: (1.0 - wave1Val) * 0.18),
                    border: Border.all(
                      color: const Color(0xFFE74C3C)
                          .withValues(alpha: (1.0 - wave1Val) * 0.60),
                      width: 1.8,
                    ),
                  ),
                ),
              ),

              // Center Breathing Emblem Button
              Transform.scale(
                scale: 1.0 + (math.sin(progress * 2 * math.pi) * 0.03),
                child: GestureDetector(
                  onTap: _handleStartPlaylist,
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD32F2F),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD32F2F)
                              .withValues(alpha: 0.50),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
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
            fontWeight: FontWeight.w800,
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
            color: const Color(0xFFE53935),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE53935).withValues(alpha: 0.40),
                blurRadius: 18,
                offset: const Offset(0, 6),
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
                      color: Colors.white.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Start Emergency Playlist',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
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
        _buildUtilityItem(
          icon: Icons.wifi_off_rounded,
          label: 'Offline Ready',
        ),
        _buildUtilityItem(
          icon: Icons.download_rounded,
          label: 'Downloaded',
        ),
        _buildUtilityItem(
          icon: Icons.menu_book_rounded,
          label: 'Quran Only',
        ),
      ],
    );
  }

  Widget _buildUtilityItem({
    required IconData icon,
    required String label,
  }) {
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
          child: Icon(
            icon,
            color: const Color(0xFF81C784),
            size: 22,
          ),
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
                    fontWeight: FontWeight.w800,
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
              activeColor: Colors.white,
              activeTrackColor: const Color(0xFF2ECC71),
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
        color: const Color(0xFF2A1618),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE74C3C).withValues(alpha: 0.30),
          width: 1.0,
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFEF5350),
            size: 18,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'If you may harm yourself or others, contact local emergency help immediately.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Color(0xFFEF5350),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: Colors.white.withValues(alpha: 0.08),
    );
  }
}
