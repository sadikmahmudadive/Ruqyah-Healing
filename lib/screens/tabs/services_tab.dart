import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/hijama_cupping_icon.dart';
import '../../widgets/ruqyah_dua_icon.dart';
import '../video_consultation_screen.dart';

class ServicesTab extends StatelessWidget {
  const ServicesTab({super.key});

  @override
  Widget build(BuildContext context) {
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
          titleSpacing: 20,
          title: const Text(
            'SERVICES',
            style: TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: Color(0xFF15221D),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: IconButton(
                icon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF15221D),
                  size: 24,
                ),
                onPressed: () {
                  HapticFeedback.selectionClick();
                },
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
              // 1. RUQYAH Service Card
              _buildMainServiceCard(
                title: 'RUQYAH',
                description:
                    'Qur\'anic healing for protection and relief from spiritual distress.',
                customIcon: const RuqyahDuaIcon(
                  color: Color(0xFF0B4632),
                  size: 28,
                ),
                iconBgColor: const Color(0xFFEBF7F0),
                iconColor: const Color(0xFF0B4632),
                onTap: () {
                  HapticFeedback.selectionClick();
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const VideoConsultationScreen(
                        doctorName: 'Dr. Saifur Rahman',
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
              ),

              const SizedBox(height: 16),

              // 2. HIJAMA Service Card
              _buildMainServiceCard(
                title: 'HIJAMA',
                description:
                    'Cupping therapy for natural detoxification and physical restoration.',
                customIcon: const HijamaCuppingIcon(
                  color: Color(0xFFE67E22),
                  size: 28,
                ),
                iconBgColor: const Color(0xFFFFF3E8),
                iconColor: const Color(0xFFE67E22),
                onTap: () {
                  HapticFeedback.selectionClick();
                },
              ),

              const SizedBox(height: 16),

              // 3. ACUPUNCTURE Service Card
              _buildMainServiceCard(
                title: 'ACUPUNCTURE',
                description:
                    'Holistic healing practices to maintain physical balance and energy wellness.',
                icon: Icons.show_chart_rounded,
                iconBgColor: const Color(0xFFE6F7FF),
                iconColor: const Color(0xFF2980B9),
                onTap: () {
                  HapticFeedback.selectionClick();
                },
              ),

              const SizedBox(height: 16),

              // 4. Bottom Bento Row: Courses & Store
              Row(
                children: [
                  Expanded(
                    child: _buildSubServiceCard(
                      title: 'Courses',
                      description: 'Learn protection',
                      icon: Icons.menu_book_rounded,
                      iconBgColor: const Color(0xFFFFF3E8),
                      iconColor: const Color(0xFFE67E22),
                      onTap: () {
                        HapticFeedback.selectionClick();
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildSubServiceCard(
                      title: 'Store',
                      description: 'Natural remedies',
                      icon: Icons.shopping_bag_outlined,
                      iconBgColor: const Color(0xFFEBF7F0),
                      iconColor: const Color(0xFF0B4632),
                      onTap: () {
                        HapticFeedback.selectionClick();
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // Full-Width Main Service Card
  Widget _buildMainServiceCard({
    required String title,
    required String description,
    IconData? icon,
    Widget? customIcon,
    required Color iconBgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
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
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon Container
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: customIcon ??
                        Icon(
                          icon,
                          color: iconColor,
                          size: 26,
                        ),
                  ),
                ),

                const SizedBox(width: 16),

                // Text Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Cinzel',
                          fontSize: 16.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: Color(0xFF15221D),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF6E7E77),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Right Chevron
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFB0BEC5),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Half-Width Sub-Service Card (Courses / Store)
  Widget _buildSubServiceCard({
    required String title,
    required String description,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
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
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 16.0),
            child: Row(
              children: [
                // Icon Container
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 20,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Title & Subtitle
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
                          color: Color(0xFF15221D),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11.5,
                          color: Color(0xFF6E7E77),
                        ),
                      ),
                    ],
                  ),
                ),

                // Right Chevron
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFB0BEC5),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
