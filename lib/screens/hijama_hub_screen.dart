import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_gradients.dart';
import '../widgets/hijama_cupping_icon.dart';
import 'hijama_body_map_screen.dart';
import 'therapist_marketplace_screen.dart';

class HijamaHubScreen extends StatefulWidget {
  const HijamaHubScreen({super.key});

  @override
  State<HijamaHubScreen> createState() => _HijamaHubScreenState();
}

class _HijamaHubScreenState extends State<HijamaHubScreen> {
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Sunnah Healing Intro Card
                    _buildSunnahIntroCard(),

                    const SizedBox(height: 20),

                    // 2. Services Section Header & Cards List
                    _buildServicesSection(),

                    const SizedBox(height: 20),

                    // 3. Contraindications & Safety Disclaimer Banner
                    _buildSafetyDisclaimerBanner(),

                    const SizedBox(height: 16),

                    // 4. Next Sunnah Day Banner Card
                    _buildNextSunnahDayBanner(),

                    const SizedBox(height: 20),

                    // 5. Primary Action Button: Book a Session
                    _buildBookSessionButton(),

                    const SizedBox(height: 20),

                    // 6. Bottom Quick Actions Bento Row (3 Columns)
                    _buildQuickActionsRow(),

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

  // Top Dark Green Header Area
  Widget _buildTopHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 20,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        gradient: AppGradients.greenHeaderGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
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
                  'HIJAMA HUB',
                  style: TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: Color(0xFFD49E35),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'A Sunnah of Healing for Body & Soul',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
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
                color: Color(0xFFD49E35),
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
    );
  }

  // 1. Sunnah Healing Intro Card
  Widget _buildSunnahIntroCard() {
    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A Sunnah of Healing for Body & Soul',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF15221D),
                    height: 1.25,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Cupping therapy supports natural detox, balance and overall wellbeing when done by a qualified therapist.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.5,
                    color: Color(0xFF6E7E77),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          // Cupping Jars Graphic Container
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7F6),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: HijamaCuppingIcon(
                color: Color(0xFFE07B39),
                size: 48,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 2. Services Section
  Widget _buildServicesSection() {
    return Column(
      children: [
        Row(
          children: [
            const Text(
              'Services',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF15221D),
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
              },
              child: const Text(
                'See All',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFD49E35),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Service Item 1: Wet Cupping
        _buildServiceItemCard(
          title: 'Wet Cupping (Hijama)',
          subtitle: 'Detoxification & circulation support',
        ),

        const SizedBox(height: 12),

        // Service Item 2: Dry Cupping
        _buildServiceItemCard(
          title: 'Dry Cupping',
          subtitle: 'Muscle relief & relaxation',
        ),

        const SizedBox(height: 12),

        // Service Item 3: Fire Cupping Info
        _buildServiceItemCard(
          title: 'Fire Cupping Info',
          subtitle: 'Traditional method overview',
        ),
      ],
    );
  }

  Widget _buildServiceItemCard({
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
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
                pageBuilder: (_, __, ___) =>
                    const TherapistMarketplaceScreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF7F0),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: HijamaCuppingIcon(
                    color: Color(0xFF0B4632),
                    size: 22,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF15221D),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Color(0xFF6E7E77),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF7F0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF0B4632),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 3. Contraindications & Safety Disclaimer Banner
  Widget _buildSafetyDisclaimerBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE74C3C).withValues(alpha: 0.20),
          width: 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFE74C3C),
            size: 20,
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contraindications & Safety',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFC0392B),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Hijama may not be suitable for everyone. Screening by a qualified therapist is essential.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.5,
                    color: Color(0xFFC0392B),
                    height: 1.35,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Professional-Only: App does not provide instructions for invasive procedures.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFC0392B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 4. Next Sunnah Day Banner Card
  Widget _buildNextSunnahDayBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD49E35).withValues(alpha: 0.30),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Color(0xFFD49E35),
              size: 22,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next Sunnah Day (Recommended)',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFB78103),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Hijrah 17, 1446 AH • Thu, May 23, 2024',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF15221D),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Consider scheduling on this day for reward.',
                  style: TextStyle(
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
    );
  }

  // 5. Primary Action Button: Book a Session
  Widget _buildBookSessionButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        gradient: AppGradients.greenButtonGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF082F21).withValues(alpha: 0.30),
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
              ),
            );
          },
          borderRadius: BorderRadius.circular(18),
          child: Column(
            children: const [
              Text(
                'Book a Session',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Connect with a verified Hijama practitioner',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: Color(0xFF81C784),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 6. Bottom Quick Actions Bento Row (3 Columns)
  Widget _buildQuickActionsRow() {
    return Row(
      children: [
        // Find Therapist
        Expanded(
          child: _buildBentoActionCard(
            title: 'Find Therapist',
            subtitle: 'Verified professionals',
            icon: Icons.person_outline_rounded,
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) =>
                      const TherapistMarketplaceScreen(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 10),

        // My Sessions
        Expanded(
          child: _buildBentoActionCard(
            title: 'My Sessions',
            subtitle: 'View your history',
            icon: Icons.assignment_outlined,
            onTap: () {
              HapticFeedback.selectionClick();
            },
          ),
        ),
        const SizedBox(width: 10),

        // Body Map
        Expanded(
          child: _buildBentoActionCard(
            title: 'Body Map',
            subtitle: 'Point reference',
            icon: Icons.content_paste_rounded,
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const HijamaBodyMapScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBentoActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
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
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFEBF7F0),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: const Color(0xFF0B4632),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF15221D),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10.5,
                  color: Color(0xFF90A4AE),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
