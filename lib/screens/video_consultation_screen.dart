import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/app_toast.dart';

class VideoConsultationScreen extends StatefulWidget {
  final String doctorName;
  final String doctorRole;

  const VideoConsultationScreen({
    super.key,
    this.doctorName = 'Dr. Saifur Rahman',
    this.doctorRole = 'Ruqyah & Islamic Counselor',
  });

  @override
  State<VideoConsultationScreen> createState() =>
      _VideoConsultationScreenState();
}

class _VideoConsultationScreenState extends State<VideoConsultationScreen> {
  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _isSpeakerOn = true;

  int _callSeconds = 28 * 60 + 47; // 28:47
  Timer? _callTimer;

  @override
  void initState() {
    super.initState();
    _startCallTimer();
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _callSeconds++;
        });
      }
    });
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _handleEndCall() {
    HapticFeedback.heavyImpact();
    Navigator.of(context).pop();
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
        backgroundColor: const Color(0xFF101418),
        body: Column(
          children: [
            // 1. Fullscreen Doctor Video Feed Area
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Main Doctor Stream Background Image
                  Image.asset(
                    'assets/background/bg_onboarding_1.jpg',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFF1E2832),
                    ),
                  ),

                  // Atmospheric Dark Vignette Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.50),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.20),
                          Colors.black.withValues(alpha: 0.75),
                        ],
                        stops: const [0.0, 0.25, 0.65, 1.0],
                      ),
                    ),
                  ),

                  // Top Status Header Bar
                  SafeArea(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                        child: Row(
                          children: [
                            // End-to-end Encrypted Glassmorphic Badge
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.40),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.20),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 7,
                                        height: 7,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF2ECC71),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        'End-to-end Encrypted',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const Spacer(),

                            // Call Timer Badge
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD32F2F)
                                        .withValues(alpha: 0.35),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFFD32F2F)
                                          .withValues(alpha: 0.50),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Text(
                                    _formatDuration(_callSeconds),
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFFF8A80),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            // More Options Button
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.35),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.20),
                                  width: 1.0,
                                ),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.more_vert_rounded,
                                  color: Colors.white,
                                  size: 18,
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
                    ),
                  ),

                  // Floating Picture-in-Picture Patient Camera Preview (Bottom-Right)
                  Positioned(
                    right: 20,
                    bottom: 120,
                    child: Container(
                      width: 105,
                      height: 140,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2832),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.40),
                          width: 1.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.40),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            if (!_isCameraOff)
                              Image.asset(
                                'assets/background/bg_onboarding_2.jpg',
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(color: const Color(0xFF121820)),
                              )
                            else
                              Container(
                                color: const Color(0xFF121820),
                                child: const Center(
                                  child: Icon(
                                    Icons.videocam_off_rounded,
                                    color: Colors.white54,
                                    size: 24,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Bottom Left: Doctor Name & Privacy Warning
                  Positioned(
                    left: 20,
                    right: 140,
                    bottom: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Doctor Name & Verified Check
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.doctorName,
                                style: const TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 21,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0, 2),
                                      blurRadius: 10,
                                      color: Color(0xCC000000),
                                    ),
                                  ],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFFD49E35),
                              size: 18,
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Privacy Warning Banner
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F1B17)
                                    .withValues(alpha: 0.82),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFF2ECC71)
                                      .withValues(alpha: 0.25),
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.warning_amber_rounded,
                                    color: Color(0xFFD49E35),
                                    size: 15,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'No screenshots or recordings. Please respect privacy.',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white
                                            .withValues(alpha: 0.85),
                                        height: 1.25,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. Bottom Call Controls Bar (Dark #101418)
            Container(
              padding: EdgeInsets.only(
                top: 18,
                bottom: MediaQuery.of(context).padding.bottom + 16,
                left: 20,
                right: 20,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF101418),
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Row of 5 In-Call Control Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Mute Button
                      _buildCallControlButton(
                        icon: _isMuted
                            ? Icons.mic_off_rounded
                            : Icons.mic_rounded,
                        label: 'Mute',
                        isActive: _isMuted,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _isMuted = !_isMuted;
                          });
                        },
                      ),

                      // Camera Button
                      _buildCallControlButton(
                        icon: _isCameraOff
                            ? Icons.videocam_off_rounded
                            : Icons.videocam_rounded,
                        label: 'Camera',
                        isActive: _isCameraOff,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _isCameraOff = !_isCameraOff;
                          });
                        },
                      ),

                      // Speaker Button
                      _buildCallControlButton(
                        icon: _isSpeakerOn
                            ? Icons.graphic_eq_rounded
                            : Icons.volume_off_rounded,
                        label: 'Speaker',
                        isActive: _isSpeakerOn,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _isSpeakerOn = !_isSpeakerOn;
                          });
                        },
                      ),

                      // Chat Button
                      _buildCallControlButton(
                        icon: Icons.chat_bubble_outline_rounded,
                        label: 'Chat',
                        isActive: false,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          AppToast.show(
                            context,
                            title: 'Live Chat',
                            message: 'Opening live in-session chat...',
                            type: ToastType.info,
                          );
                        },
                      ),

                      // Emergency Button
                      _buildCallControlButton(
                        icon: Icons.error_outline_rounded,
                        label: 'Emergency',
                        isEmergency: true,
                        onTap: () {
                          HapticFeedback.heavyImpact();
                          AppToast.show(
                            context,
                            title: 'Emergency Triggered',
                            message: 'Emergency protocol triggered. Support alerted.',
                            type: ToastType.error,
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // End Call Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _handleEndCall,
                      child: const Text(
                        'End Call',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 16.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallControlButton({
    required IconData icon,
    required String label,
    bool isActive = false,
    bool isEmergency = false,
    required VoidCallback onTap,
  }) {
    final bgColor = isEmergency
        ? const Color(0xFF2C1618)
        : isActive
            ? Colors.white
            : const Color(0xFF222A30);

    final iconColor = isEmergency
        ? const Color(0xFFEF5350)
        : isActive
            ? const Color(0xFF101418)
            : Colors.white;

    final borderColor = isEmergency
        ? const Color(0xFFD32F2F).withValues(alpha: 0.50)
        : Colors.transparent;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(26),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: borderColor,
                width: isEmergency ? 1.5 : 0.0,
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                color: iconColor,
                size: 22,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }
}
