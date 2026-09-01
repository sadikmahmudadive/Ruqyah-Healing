import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/firebase_service.dart';
import '../../widgets/ruqyah_dua_icon.dart';
import '../book_appointment_screen.dart';
import '../health_profile_detail_screen.dart';
import '../notification_screen.dart';

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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F6),
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
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF15221D),
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
                ),
              ),
              const SizedBox(height: 2),
              Text(
                userName,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF15221D),
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
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE2E8E5), width: 1.0),
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
              Icons.notifications_none_rounded,
              color: Color(0xFF15221D),
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
      ],
    );
  }

  // Health Index Card
  Widget _buildHealthIndexCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
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
                    const Text(
                      'Health Index',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6E7E77),
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
                  ),
                ),
              ],
            ),
          ),
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
            ),
          ),
        ],
      ),
    );
  }

  // Audio Player Card
  Widget _buildAudioPlayerCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
                    const Text(
                      'Surah Al-Baqarah (Ayet 1–5)',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF15221D),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Recited by Sheikh Al-Afasy',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
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
            ),
          ),

          const SizedBox(height: 8),

          // Timestamps
          Row(
            children: [
              Text(
                '01:15',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: const Color(0xFF6E7E77),
                ),
              ),
              const Spacer(),
              Text(
                '05:42',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: const Color(0xFF6E7E77),
                ),
              ),
            ],
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
          customIcon: const RuqyahDuaIcon(
            color: Color(0xFF0B4632),
            size: 28,
          ),
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
    IconData? icon,
    Widget? customIcon,
    required Color bgColor,
    required Color iconColor,
  }) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          child: Center(
            child: customIcon ?? Icon(icon, color: iconColor, size: 26),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF15221D),
          ),
        ),
      ],
    );
  }
          ),
        ),
      ],
    );
  }

  // Today's Prayer Times Card
  Widget _buildPrayerTimesCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: const [
              Text(
                "Today's Prayer Times",
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF15221D),
                ),
              ),
              Spacer(),
              Text(
                'Dhaka, BD',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0B4632),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

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
        decoration: BoxDecoration(
          color: const Color(0xFF0B4632),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0B4632).withValues(alpha: 0.30),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              name,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.80),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
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
          ),
        ),
      ],
    );
  }

  // Featured Specialist Consultation Card
  Widget _buildSpecialistCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
                  'Dr. Salma Rahman',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF15221D),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Licensed Ruqyah Specialist',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: const Color(0xFF6E7E77),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: const [
                    Icon(
                      Icons.star_rounded,
                      color: Color(0xFFD49E35),
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
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
