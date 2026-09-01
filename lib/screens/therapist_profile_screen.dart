import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tabs/bookings_tab.dart';

class TherapistProfileScreen extends StatefulWidget {
  final Therapist therapist;

  const TherapistProfileScreen({
    super.key,
    this.therapist = const Therapist(
      id: 'ther_1',
      name: 'Dr. Salma Rahman',
      title: 'Ruqyah Specialist',
      rating: 4.9,
      reviewsCount: 126,
      experience: '8+ Yrs',
      distance: '1.2 km away',
      languages: ['Bangla', 'English'],
      nextSlot: 'Today, 10:30 AM',
      price: 1200,
      isVerified: true,
      avatarUrl: 'assets/logo/logo_app.png',
      category: 'Ruqyah',
    ),
  });

  @override
  State<TherapistProfileScreen> createState() => _TherapistProfileScreenState();
}

class _TherapistProfileScreenState extends State<TherapistProfileScreen> {
  String _selectedConsultationType = 'Clinic Visit'; // 'Clinic Visit' or 'Video Call'
  String _selectedSlot = '10:30 AM';
  bool _isAboutExpanded = false;

  final List<String> _availableSlots = const [
    '10:30 AM',
    '12:30 PM',
    '3:00 PM',
    'More',
  ];

  @override
  Widget build(BuildContext context) {
    final t = widget.therapist;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F6),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5F7F6),
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8E5), width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Color(0xFF15221D),
                  size: 20,
                ),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
          centerTitle: true,
          title: const Text(
            'Therapist Profile',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF15221D),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0, top: 8.0, bottom: 8.0),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E8E5), width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: Color(0xFF15221D),
                    size: 20,
                  ),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                  },
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Practitioner Info Card
              _buildTopPractitionerCard(t),

              const SizedBox(height: 20),

              // 2. Offered Services Section
              _buildOfferedServicesSection(),

              const SizedBox(height: 16),

              // 3. Languages Section
              _buildLanguagesSection(t),

              const SizedBox(height: 18),

              // 4. About Doctor Section
              _buildAboutSection(t),

              const SizedBox(height: 20),

              // 5. Consultation Type Cards (Clinic Visit vs Video Call)
              _buildConsultationTypeCards(),

              const SizedBox(height: 20),

              // 6. Next Available Slots Section
              _buildAvailableSlotsSection(),

              const SizedBox(height: 20),

              // 7. Reviews Summary Header
              _buildReviewsHeader(t),

              const SizedBox(height: 24),

              // 8. Bottom Action Button: Book Appointment
              _buildBookAppointmentButton(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Top Practitioner Main Card
  Widget _buildTopPractitionerCard(Therapist t) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          // Profile Photo with Green Border
          Container(
            width: 88,
            height: 88,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF0B4632),
                width: 2.0,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Image.asset(
                t.avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF1E3A2F),
                  child: const Icon(Icons.person, color: Colors.white, size: 40),
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Name & Verified Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                t.name,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF15221D),
                ),
              ),
              if (t.isVerified) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_rounded,
                        color: Color(0xFFD49E35),
                        size: 13,
                      ),
                      SizedBox(width: 3),
                      Text(
                        'Verified',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFD49E35),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 4),

          // Subtitle / Title
          Text(
            t.title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13.5,
              color: Color(0xFF6E7E77),
            ),
          ),

          const SizedBox(height: 8),

          // Identity Verified Green Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5EE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Identity Verified',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0B4632),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Rating & Experience Split Box
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7F6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // Rating
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${t.rating}',
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF15221D),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFD49E35),
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${t.reviewsCount} Reviews',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: Color(0xFF6E7E77),
                        ),
                      ),
                    ],
                  ),
                ),

                // Vertical Divider Line
                Container(
                  width: 1,
                  height: 32,
                  color: const Color(0xFFE2E8E5),
                ),

                // Experience
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        t.experience,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF15221D),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Experience',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: Color(0xFF6E7E77),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Offered Services Row
  Widget _buildOfferedServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Offered Services',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF15221D),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildServiceChip(
              label: 'Ruqyah',
              icon: Icons.cancel_outlined,
              iconColor: const Color(0xFF0B4632),
            ),
            const SizedBox(width: 10),
            _buildServiceChip(
              label: 'Hijama',
              icon: Icons.favorite_border_rounded,
              iconColor: const Color(0xFFE67E22),
            ),
            const SizedBox(width: 10),
            _buildServiceChip(
              label: 'Counseling',
              icon: Icons.show_chart_rounded,
              iconColor: const Color(0xFF2980B9),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceChip({
    required String label,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF15221D),
            ),
          ),
        ],
      ),
    );
  }

  // Languages Section
  Widget _buildLanguagesSection(Therapist t) {
    return Row(
      children: [
        const Text(
          'Languages:',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF15221D),
          ),
        ),
        const SizedBox(width: 10),
        ...t.languages.map((lang) {
          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8E5).withValues(alpha: 0.50),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              lang,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF15221D),
              ),
            ),
          );
        }),
      ],
    );
  }

  // About Doctor Section
  Widget _buildAboutSection(Therapist t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About Doctor',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF15221D),
          ),
        ),
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13.5,
              color: Color(0xFF6E7E77),
              height: 1.45,
            ),
            children: [
              TextSpan(
                text:
                    '${t.name} is a compassionate Ruqyah practitioner and medical consultant specializing in holistic Quranic healing combined with modern psychological wellness counseling.',
              ),
              if (!_isAboutExpanded)
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isAboutExpanded = true;
                      });
                    },
                    child: const Text(
                      ' See more',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0B4632),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // Consultation Type Cards (Clinic Visit vs Video Call)
  Widget _buildConsultationTypeCards() {
    return Row(
      children: [
        Expanded(
          child: _buildConsultationCard(
            title: 'Clinic Visit',
            subtitle: 'Mirpur, Dhaka',
            icon: Icons.home_outlined,
            isSelected: _selectedConsultationType == 'Clinic Visit',
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _selectedConsultationType = 'Clinic Visit';
              });
            },
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _buildConsultationCard(
            title: 'Video Call',
            subtitle: 'Online Session',
            icon: Icons.videocam_outlined,
            isSelected: _selectedConsultationType == 'Video Call',
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _selectedConsultationType = 'Video Call';
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildConsultationCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF0B4632)
              : const Color(0xFFE2E8E5),
          width: isSelected ? 1.8 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5EE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: const Color(0xFF0B4632),
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF15221D),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11.5,
                          color: Color(0xFF6E7E77),
                        ),
                      ),
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

  // Next Available Slots Section
  Widget _buildAvailableSlotsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Next Available Slots',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF15221D),
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Today, May 19',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12.5,
            color: Color(0xFF6E7E77),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: _availableSlots.map((slot) {
            final isSelected = slot == _selectedSlot;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedSlot = slot;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? const Color(0xFF0B4632) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF0B4632)
                            : const Color(0xFFE2E8E5),
                        width: 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF0B4632)
                                    .withValues(alpha: 0.20),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                    child: Center(
                      child: Text(
                        slot,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12.5,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF15221D),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Reviews Summary Header
  Widget _buildReviewsHeader(Therapist t) {
    return Row(
      children: [
        Text(
          'Reviews (${t.reviewsCount})',
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF15221D),
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
          },
          child: const Row(
            children: [
              Text(
                'See all',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0B4632),
                ),
              ),
              SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_rounded,
                color: Color(0xFF0B4632),
                size: 16,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Bottom Action Button: Book Appointment
  Widget _buildBookAppointmentButton() {
    return Container(
      width: double.infinity,
      height: 56,
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Booking appointment with ${widget.therapist.name} for $_selectedSlot...',
                  style: const TextStyle(fontFamily: 'Inter'),
                ),
                backgroundColor: const Color(0xFF0B4632),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          borderRadius: BorderRadius.circular(18),
          splashColor: Colors.white.withValues(alpha: 0.15),
          child: const Center(
            child: Text(
              'Book Appointment',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 16.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
