import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../localization/app_localizations.dart';
import '../../models/appointment_model.dart';
import '../../services/firebase_service.dart';
import '../../services/prayer_times_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/acupuncture_icon.dart';
import '../../widgets/ai_icon.dart';
import '../../widgets/hijama_cupping_icon.dart';
import '../../widgets/prayer_time_icon.dart';
import '../../widgets/ruqyah_dua_icon.dart';
import '../ai_symptom_guide_screen.dart';
import '../ayurvedic_hub_screen.dart';
import '../acupuncture_hub_screen.dart';
import '../book_appointment_screen.dart';
import '../emergency_ruqyah_screen.dart';
import '../full_audio_player_screen.dart';
import '../health_profile_detail_screen.dart';
import '../hijama_hub_screen.dart';
import '../notification_screen.dart';
import '../pathology_hub_screen.dart';
import '../ruqyah_hub_screen.dart';
import '../therapist_marketplace_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  bool _isPlaying = false;
  double _audioProgress = 0.22; // 01:15 out of 05:42

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseService.currentUser;
    final userName = currentUser?.displayName?.isNotEmpty == true
        ? currentUser!.displayName!
        : 'Amima';
    String userName = 'Guest User';
    if (currentUser != null) {
      if (currentUser.displayName?.isNotEmpty == true) {
        userName = currentUser.displayName!;
      } else if (currentUser.email?.isNotEmpty == true) {
        final emailPrefix = currentUser.email!.split('@').first;
        userName = emailPrefix.isNotEmpty
            ? emailPrefix[0].toUpperCase() + emailPrefix.substring(1)
            : 'User';
      } else if (currentUser.phoneNumber?.isNotEmpty == true) {
        userName = currentUser.phoneNumber!;
      } else {
        userName = 'User';
      }
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      value: context.systemOverlayStyle,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F6),
        backgroundColor: context.pageBg,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 12.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Bar Header (Avatar + Greeting + Notification Bell)
                _buildHeader(userName),

                const SizedBox(height: 20),

                // 2. Bento Grid: Health Index (Left) & Next Appointment (Right)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildHealthIndexCard()),
                    const SizedBox(width: 14),
                    Expanded(child: _buildNextAppointmentCard()),
                  ],
                ),

                const SizedBox(height: 18),

                // 3. Audio Engine Card (Surah Al-Baqarah Player)
                _buildAudioPlayerCard(),

                const SizedBox(height: 24),

                // 4. Holistic Services Section Title
                const Text(
                  'Holistic Services',
                Text(
                  context.tr('holistic_services'),
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF15221D),
                    color: context.textPrimary,
                  ),
                ),

                const SizedBox(height: 14),

                // 5. Services Row (4 Items)
                _buildServicesRow(),

                const SizedBox(height: 24),

                // 6. Today's Prayer Times Card
                _buildPrayerTimesCard(),

                const SizedBox(height: 20),

                // 7. Featured Specialist Consultation Card
                _buildSpecialistCard(),

                const SizedBox(height: 20),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Header Widget
  Widget _buildHeader(String userName) {
    return Row(
      children: [
        // User Avatar
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.0),
            border: Border.all(color: context.cardBorder, width: 2.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
            image: const DecorationImage(
              image: AssetImage('assets/logo/logo_app.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Greeting
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assalamu Alaikum,',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6E7E77),
                  color: context.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                userName,
                style: const TextStyle(
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF15221D),
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
        ),

        // Notification Bell
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            color: context.cardBg,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE2E8E5), width: 1.0),
            border: Border.all(color: context.cardBorder, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(
            icon: Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF15221D),
              color: context.textPrimary,
              size: 22,
            ),
            onPressed: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const NotificationScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut,
                          ),
                          child: child,
                        );
                      },
                  transitionDuration: const Duration(milliseconds: 400),
                ),
              );
            },
          ),
        ),

        const SizedBox(width: 10),

        // AI Assistant Button
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: context.cardBg,
            shape: BoxShape.circle,
            border: Border.all(color: context.cardBorder, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: AiIcon(color: context.textPrimary, size: 22),
            onPressed: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const AISymptomGuideScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut,
                          ),
                          child: child,
                        );
                      },
                  transitionDuration: const Duration(milliseconds: 400),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Health Index Card
  Widget _buildHealthIndexCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.cardBorder, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Health Index',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6E7E77),
                ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const HealthProfileDetailScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOut,
                        ),
                        child: child,
                      );
                    },
                transitionDuration: const Duration(milliseconds: 400),
              ),
              const Spacer(),
              const Icon(
                Icons.wb_sunny_outlined,
                color: Color(0xFFD49E35),
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: const [
              Text(
                '78',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF15221D),
                  height: 1.0,
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      context.tr('health_index'),
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.wb_sunny_outlined,
                      color: Color(0xFFD49E35),
                      size: 18,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Good',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E6B45),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '78',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: context.textPrimary,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.tr('good'),
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E6B45),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: const Color(0xFFE2E8E5)),
          const SizedBox(height: 10),
          Text(
            'Overall physical & spiritual wellness',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6E7E77),
              height: 1.3,
                const SizedBox(height: 14),
                Container(height: 1, color: context.cardBorder),
                const SizedBox(height: 10),
                Text(
                  'Overall physical & spiritual wellness',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: context.textSecondary,
                    height: 1.3,
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

  // Next Appointment Card
  Widget _buildNextAppointmentCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B4632),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B4632).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NEXT APPOINTMENT',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: Colors.white.withValues(alpha: 0.70),
    final currentUser = FirebaseService.currentUser;

    if (currentUser == null) {
      return _buildAppointmentCardUI(
        dateText: 'No Active Booking',
        timeText: 'Sign in or explore sessions',
        doctorText: 'Browse Therapists',
        onTap: () {
          HapticFeedback.selectionClick();
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (_, _, _) => const TherapistMarketplaceScreen(),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Mon, 20 May 2024',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
          );
        },
      );
    }

    return StreamBuilder<List<AppointmentModel>>(
      stream: FirebaseService.getPatientAppointments(currentUser.uid),
      builder: (context, snapshot) {
        final appointments = snapshot.data ?? [];
        if (appointments.isEmpty) {
          return _buildAppointmentCardUI(
            dateText: 'No Active Booking',
            timeText: 'Schedule a new session',
            doctorText: 'Book a Therapist',
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, _, _) => const TherapistMarketplaceScreen(),
                ),
              );
            },
          );
        }

        final nextApp = appointments.first;
        final formattedDate =
            '${nextApp.scheduledTime.day}/${nextApp.scheduledTime.month}/${nextApp.scheduledTime.year}';
        final formattedTime =
            '${nextApp.scheduledTime.hour}:${nextApp.scheduledTime.minute.toString().padLeft(2, '0')}';
        return _buildAppointmentCardUI(
          dateText: formattedDate,
          timeText: formattedTime,
          doctorText: nextApp.therapyType.replaceAll('_', ' '),
          onTap: () {
            HapticFeedback.selectionClick();
          },
        );
      },
    );
  }

  Widget _buildAppointmentCardUI({
    required String dateText,
    required String timeText,
    required String doctorText,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0B4632),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0B4632).withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '10:30 AM',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.75),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('next_appointment'),
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: Colors.white.withValues(alpha: 0.70),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.15)),
          const SizedBox(height: 10),
          const Text(
            'Dr. Salma Rahman',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFFD49E35),
            const SizedBox(height: 10),
            Text(
              dateText,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
            const SizedBox(height: 2),
            Text(
              timeText,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 14),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.15)),
            const SizedBox(height: 10),
            Text(
              doctorText,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFFD49E35),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Audio Player Card
  Widget _buildAudioPlayerCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.cardBorder, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const FullAudioPlayerScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOut,
                        ),
                        child: child,
                      );
                    },
                transitionDuration: const Duration(milliseconds: 400),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'سورة البقرة',
                      style: TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0B4632),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'سورة البقرة',
                            style: TextStyle(
                              fontFamily: 'Cinzel',
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0B4632),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Surah Al-Baqarah (Ayet 1–5)',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: context.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Recited by Sheikh Al-Afasy',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Surah Al-Baqarah (Ayet 1–5)',

                    // Play Button
                    InkWell(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        setState(() {
                          _isPlaying = !_isPlaying;
                        });
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0B4632),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _audioProgress,
                    backgroundColor: const Color(0xFFE2E8E5),
                    color: const Color(0xFF0B4632),
                    minHeight: 4,
                  ),
                ),

                const SizedBox(height: 8),

                // Timestamps
                Row(
                  children: [
                    Text(
                      '01:15',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF15221D),
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: const Color(0xFF6E7E77),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Spacer(),
                    Text(
                      'Recited by Sheikh Al-Afasy',
                      '05:42',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontSize: 11,
                        color: const Color(0xFF6E7E77),
                      ),
                    ),
                  ],
                ),
              ),

              // Play Button
              InkWell(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  setState(() {
                    _isPlaying = !_isPlaying;
                  });
                },
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0B4632),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _audioProgress,
              backgroundColor: const Color(0xFFE2E8E5),
              color: const Color(0xFF0B4632),
              minHeight: 4,
              ],
            ),
          ),
        ),
      ),
    );
  }

          const SizedBox(height: 8),
  // Holistic Services Row
  Widget _buildServicesRow() {
    final isDark = context.isDarkMode;
    final iconColorRuqyah = isDark
        ? const Color(0xFFD49E35)
        : const Color(0xFF0B4632);
    final iconColorHijama = isDark
        ? const Color(0xFFD49E35)
        : const Color(0xFFE67E22);
    final iconColorAcupuncture = isDark
        ? const Color(0xFFD49E35)
        : const Color(0xFF2980B9);
    final iconColorAyurvedic = isDark
        ? const Color(0xFFD49E35)
        : const Color(0xFF27AE60);
    final iconColorPathology = isDark
        ? const Color(0xFFD49E35)
        : const Color(0xFF8E44AD);
    final iconColorEmergency = isDark
        ? const Color(0xFFD49E35)
        : const Color(0xFFE74C3C);

          // Timestamps
          Row(
            children: [
              Text(
                '01:15',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: const Color(0xFF6E7E77),
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildServiceIconCard(
            label: context.tr('ruqyah'),
            customIcon: RuqyahDuaIcon(color: iconColorRuqyah, size: 30),
            bgColor: const Color(0xFFEBF7F0),
            iconColor: iconColorRuqyah,
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const RuqyahHubScreen(),
                ),
              ),
              const Spacer(),
              Text(
                '05:42',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: const Color(0xFF6E7E77),
              );
            },
          ),
          const SizedBox(width: 14),
          _buildServiceIconCard(
            label: context.tr('hijama'),
            customIcon: HijamaCuppingIcon(color: iconColorHijama, size: 30),
            bgColor: const Color(0xFFFFF3E8),
            iconColor: iconColorHijama,
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const HijamaHubScreen(),
                ),
              ),
            ],
              );
            },
          ),
          const SizedBox(width: 14),
          _buildServiceIconCard(
            label: context.tr('acupuncture'),
            customIcon: AcupunctureIcon(color: iconColorAcupuncture, size: 30),
            bgColor: const Color(0xFFE6F7FF),
            iconColor: iconColorAcupuncture,
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const AcupunctureHubScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 14),
          _buildServiceIconCard(
            label: context.tr('ayurvedic'),
            icon: Icons.spa_outlined,
            bgColor: const Color(0xFFE8F8F5),
            iconColor: iconColorAyurvedic,
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const AyurvedicHubScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 14),
          _buildServiceIconCard(
            label: context.tr('pathology'),
            icon: Icons.biotech_outlined,
            bgColor: const Color(0xFFF4ECF7),
            iconColor: iconColorPathology,
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const PathologyHubScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 14),
          _buildServiceIconCard(
            label: context.tr('emergency'),
            icon: Icons.error_outline_rounded,
            bgColor: const Color(0xFFFFEBEB),
            iconColor: iconColorEmergency,
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const EmergencyRuqyahScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Holistic Services Row
  Widget _buildServicesRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildServiceIconCard(
          label: 'Ruqyah',
          icon: Icons.cancel_outlined,
          bgColor: const Color(0xFFEBF7F0),
          iconColor: const Color(0xFF0B4632),
        ),
        _buildServiceIconCard(
          label: 'Hijama',
          icon: Icons.favorite_border_rounded,
          bgColor: const Color(0xFFFFF3E8),
          iconColor: const Color(0xFFE67E22),
        ),
        _buildServiceIconCard(
          label: 'Acupuncture',
          icon: Icons.show_chart_rounded,
          bgColor: const Color(0xFFE6F7FF),
          iconColor: const Color(0xFF2980B9),
        ),
        _buildServiceIconCard(
          label: 'Emergency',
          icon: Icons.error_outline_rounded,
          bgColor: const Color(0xFFFFEBEB),
          iconColor: const Color(0xFFE74C3C),
        ),
      ],
    );
  }

  Widget _buildServiceIconCard({
    required String label,
    required IconData icon,
    IconData? icon,
    Widget? customIcon,
    required Color bgColor,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          child: Center(child: Icon(icon, color: iconColor, size: 26)),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF15221D),
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: context.isDarkMode ? const Color(0xFF132620) : bgColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: customIcon ?? Icon(icon, color: iconColor, size: 30),
            ),
          ),
        ),
      ],
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // Today's Prayer Times Card
  Widget _buildPrayerTimesCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        color: context.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.cardBorder, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
            children: [
              Text(
                "Today's Prayer Times",
                context.tr('prayer_times'),
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF15221D),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: context.textPrimary,
                ),
              ),
              Spacer(),
              Text(
              const Spacer(),
              const Text(
                'Dhaka, BD',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0B4632),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const SizedBox(height: 18),

          // Prayer Times Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPrayerSlot(name: 'Fajr', time: '4:05', isActive: false),
              _buildPrayerSlot(name: 'Dhuhr', time: '12:30', isActive: true),
              _buildPrayerSlot(name: 'Asr', time: '4:45', isActive: false),
              _buildPrayerSlot(name: 'Maghrib', time: '6:45', isActive: false),
              _buildPrayerSlot(name: 'Isha', time: '8:15', isActive: false),
            ],
          // 6 Prayer Times Row (Fajr, Dhuhr, Asr, Maghrib, Isha, Jummah)
          FutureBuilder<PrayerTimesModel>(
            future: PrayerTimesService.fetchPrayerTimes(),
            builder: (context, snapshot) {
              final times = snapshot.data ?? PrayerTimesModel.fallback();
              final activePrayer = PrayerTimesService.getActivePrayerName(
                times,
              );

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPrayerSlot(
                      name: 'Fajr',
                      time: times.fajr,
                      isActive: activePrayer == 'Fajr',
                    ),
                    const SizedBox(width: 8),
                    _buildPrayerSlot(
                      name: 'Dhuhr',
                      time: times.dhuhr,
                      isActive: activePrayer == 'Dhuhr',
                    ),
                    const SizedBox(width: 8),
                    _buildPrayerSlot(
                      name: 'Asr',
                      time: times.asr,
                      isActive: activePrayer == 'Asr',
                    ),
                    const SizedBox(width: 8),
                    _buildPrayerSlot(
                      name: 'Maghrib',
                      time: times.maghrib,
                      isActive: activePrayer == 'Maghrib',
                    ),
                    const SizedBox(width: 8),
                    _buildPrayerSlot(
                      name: 'Isha',
                      time: times.isha,
                      isActive: activePrayer == 'Isha',
                    ),
                    const SizedBox(width: 8),
                    _buildPrayerSlot(
                      name: 'Jummah',
                      time: times.jummah,
                      isActive: activePrayer == 'Jummah',
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerSlot({
    required String name,
    required String time,
    required bool isActive,
  }) {
    if (isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        constraints: const BoxConstraints(minWidth: 58),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0B4632),
          borderRadius: BorderRadius.circular(14),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0B4632).withValues(alpha: 0.30),
              blurRadius: 10,
              offset: const Offset(0, 2),
              color: const Color(0xFF0B4632).withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PrayerTimeIcon(prayerName: name, color: Colors.white, size: 20),
            const SizedBox(height: 6),
            Text(
              name,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.80),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.90),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFFD49E35),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Text(
          name,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6E7E77),
    return Container(
      constraints: const BoxConstraints(minWidth: 58),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrayerTimeIcon(
            prayerName: name,
            color: const Color(0xFF52625B),
            size: 20,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          time,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF15221D),
          const SizedBox(height: 6),
          Text(
            name,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6E7E77),
            ),
          ),
        ),
      ],
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: context.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // Featured Specialist Consultation Card
  Widget _buildSpecialistCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.cardBorder, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Doctor Image Container
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(
                color: Color(0xFF1E3A2F),
                image: DecorationImage(
                  image: AssetImage('assets/logo/logo_app.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                Text(
                  'Dr. Salma Rahman',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF15221D),
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Licensed Ruqyah Specialist',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: const Color(0xFF6E7E77),
                    color: context.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: const [
                    Icon(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFD49E35),
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                    const SizedBox(width: 4),
                    const Text(
                      '4.9 ',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFD49E35),
                      ),
                    ),
                    Text(
                      '(120 reviews)',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Color(0xFF6E7E77),
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Book Button
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF0B4632),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const BookAppointmentScreen(
                            therapistName: 'Dr. Salma Rahman',
                            basePrice: 1200,
                          ),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeInOut,
                              ),
                              child: child,
                            );
                          },
                      transitionDuration: const Duration(milliseconds: 400),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: const Center(
                  child: Text(
                    'Book',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
