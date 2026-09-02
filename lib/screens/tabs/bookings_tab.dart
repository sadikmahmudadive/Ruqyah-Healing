import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/acupuncture_icon.dart';
import '../../widgets/hijama_cupping_icon.dart';
import '../../widgets/ruqyah_dua_icon.dart';
import '../therapist_marketplace_screen.dart';
import '../video_consultation_screen.dart';

class Therapist {
  final String id;
  final String name;
  final String title;
  final double rating;
  final int reviewsCount;
  final String experience;
  final String distance;
  final List<String> languages;
  final String nextSlot;
  final int price;
  final bool isVerified;
  final String avatarUrl;
  final String category;

  const Therapist({
    required this.id,
    required this.name,
    required this.title,
    required this.rating,
    required this.reviewsCount,
    required this.experience,
    required this.distance,
    required this.languages,
    required this.nextSlot,
    required this.price,
    this.isVerified = true,
    required this.avatarUrl,
    required this.category,
  });
}

class AppointmentSession {
  final String id;
  final String title;
  final String doctorName;
  final String dateTime;
  final String mode; // 'Online Video' or 'At Clinic'
  final String status; // 'Confirmed' or 'Pending'
  final Color accentColor;
  final Widget icon;

  const AppointmentSession({
    required this.id,
    required this.title,
    required this.doctorName,
    required this.dateTime,
    required this.mode,
    required this.status,
    required this.accentColor,
    required this.icon,
  });
}

class BookingsTab extends StatefulWidget {
  const BookingsTab({super.key});

  @override
  State<BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends State<BookingsTab> {
  String _selectedTab = 'Upcoming'; // 'Upcoming', 'Completed', 'Cancelled'

  final List<AppointmentSession> _upcomingSessions = [
    AppointmentSession(
      id: 'app_1',
      title: 'Ruqyah Session',
      doctorName: 'Dr. Salma Rahman',
      dateTime: 'Wed 15 May 2024 · 10:30 AM',
      mode: 'Online Video',
      status: 'Confirmed',
      accentColor: const Color(0xFF0B4632),
      icon: const RuqyahDuaIcon(color: Color(0xFF0B4632), size: 22),
    ),
    AppointmentSession(
      id: 'app_2',
      title: 'Hijama Session',
      doctorName: 'Hafiz Abdul Karim',
      dateTime: 'Thu 16 May 2024 · 9:00 AM',
      mode: 'At Clinic',
      status: 'Pending',
      accentColor: const Color(0xFFD49E35),
      icon: const HijamaCuppingIcon(color: Color(0xFFE67E22), size: 22),
    ),
    AppointmentSession(
      id: 'app_3',
      title: 'Acupuncture Session',
      doctorName: 'Dr. Aisha Noor',
      dateTime: 'Sat 18 May 2024 · 11:00 AM',
      mode: 'At Clinic',
      status: 'Confirmed',
      accentColor: const Color(0xFF0B4632),
      icon: const AcupunctureIcon(color: Color(0xFF2980B9), size: 22),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F6),
        body: Column(
          children: [
            // 1. Top Dark Green Header Area
            _buildTopHeader(),

            // 2. Scrollable Body Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(
                  left: 20.0,
                  right: 20.0,
                  top: 6.0,
                  bottom: 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Sub-Header
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        '${_upcomingSessions.length} UPCOMING SESSIONS',
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: Color(0xFF90A4AE),
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Session Cards List
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: _upcomingSessions.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final session = _upcomingSessions[index];
                        return _buildSessionCard(session);
                      },
                    ),

                    const SizedBox(height: 18),

                    // Info Disclaimer Box
                    _buildInfoDisclaimerBox(),

                    const SizedBox(height: 16),

                    // Add all upcoming to calendar row
                    _buildAddToCalendarRow(),

                    const SizedBox(height: 20),

                    // Primary Action Button: Book a New Appointment
                    _buildBookNewAppointmentButton(),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Top Dark Green Header
  Widget _buildTopHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 10,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0B4632),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Title & Calendar Button Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PATIENT PORTAL',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: Color(0xFF81C784),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'My Appointments',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Calendar Icon Button
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.calendar_month_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Filter Segment Tabs Pill Row
          Row(
            children: [
              _buildFilterPill('Upcoming'),
              const SizedBox(width: 8),
              _buildFilterPill('Completed'),
              const SizedBox(width: 8),
              _buildFilterPill('Cancelled'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPill(String label) {
    final isSelected = _selectedTab == label;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _selectedTab = label;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 40,
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF0B4632)
                    : Colors.white.withValues(alpha: 0.90),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Appointment Session Card
  Widget _buildSessionCard(AppointmentSession session) {
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // Top Accent Color Bar
            Container(
              height: 3.5,
              width: double.infinity,
              color: session.accentColor,
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon Container
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: session.title.contains('Ruqyah')
                          ? const Color(0xFFEBF7F0)
                          : session.title.contains('Hijama')
                              ? const Color(0xFFFFF3E8)
                              : const Color(0xFFE6F7FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(child: session.icon),
                  ),

                  const SizedBox(width: 14),

                  // Session Info Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.title,
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF15221D),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          session.doctorName,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6E7E77),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          session.dateTime,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12.5,
                            color: Color(0xFF90A4AE),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Mode & Status Line
                        Row(
                          children: [
                            Text(
                              '• ${session.mode}',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF15221D),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildStatusBadge(session.status),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Action Popup Menu (Three Dots)
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      color: Color(0xFF90A4AE),
                      size: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    onSelected: (value) {
                      HapticFeedback.selectionClick();
                      if (value == 'join' && session.mode == 'Online Video') {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) =>
                                VideoConsultationScreen(
                              doctorName: session.doctorName,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$value ${session.title}'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      if (session.mode == 'Online Video')
                        const PopupMenuItem(
                          value: 'join',
                          child: Row(
                            children: [
                              Icon(Icons.videocam_rounded,
                                  color: Color(0xFF0B4632), size: 18),
                              SizedBox(width: 8),
                              Text('Join Video Call'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'reschedule',
                        child: Row(
                          children: [
                            Icon(Icons.edit_calendar_rounded,
                                color: Color(0xFF15221D), size: 18),
                            SizedBox(width: 8),
                            Text('Reschedule'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'cancel',
                        child: Row(
                          children: [
                            Icon(Icons.cancel_outlined,
                                color: Color(0xFFE74C3C), size: 18),
                            SizedBox(width: 8),
                            Text('Cancel Appointment'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final isConfirmed = status == 'Confirmed';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isConfirmed ? const Color(0xFFEBF7F0) : const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isConfirmed ? Icons.check_rounded : Icons.hourglass_top_rounded,
            color: isConfirmed
                ? const Color(0xFF0B4632)
                : const Color(0xFFD49E35),
            size: 12,
          ),
          const SizedBox(width: 3),
          Text(
            status,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isConfirmed
                  ? const Color(0xFF0B4632)
                  : const Color(0xFFD49E35),
            ),
          ),
        ],
      ),
    );
  }

  // Info Disclaimer Box
  Widget _buildInfoDisclaimerBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF7F0).withValues(alpha: 0.80),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF0B4632).withValues(alpha: 0.15),
          width: 1.0,
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF0B4632),
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Free rescheduling or cancellation is allowed up to 24 hours prior to the scheduled session.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Color(0xFF52625B),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Add all upcoming to calendar row
  Widget _buildAddToCalendarRow() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All sessions added to calendar'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: Row(
            children: const [
              Icon(
                Icons.calendar_month_rounded,
                color: Color(0xFF0B4632),
                size: 20,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Add all upcoming to calendar',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF15221D),
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFB0BEC5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Primary Action Button: Book a New Appointment
  Widget _buildBookNewAppointmentButton() {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xFF0B4632),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B4632).withValues(alpha: 0.30),
            offset: const Offset(0, 6),
            blurRadius: 18,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.heavyImpact();
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) =>
                    const TherapistMarketplaceScreen(),
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
          borderRadius: BorderRadius.circular(18),
          splashColor: Colors.white.withValues(alpha: 0.15),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 22,
              ),
              SizedBox(width: 8),
              Text(
                'Book a New Appointment',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
