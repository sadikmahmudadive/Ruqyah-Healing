import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_gradients.dart';
import '../../theme/app_theme.dart';
import '../../widgets/acupuncture_icon.dart';
import '../../widgets/hijama_cupping_icon.dart';
import '../../widgets/ruqyah_dua_icon.dart';
import '../acupuncture_hub_screen.dart';
import '../ai_symptom_guide_screen.dart';
import '../equipment_store_screen.dart';
import '../hijama_hub_screen.dart';
import '../ruqyah_hub_screen.dart';
import '../video_consultation_screen.dart';

class ServicesTab extends StatefulWidget {
  const ServicesTab({super.key});

  @override
  State<ServicesTab> createState() => _ServicesTabState();
}

class _ServicesTabState extends State<ServicesTab> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: context.pageBg,
        appBar: AppBar(
          backgroundColor: context.pageBg,
          elevation: 0,
          titleSpacing: 20,
          automaticallyImplyLeading: false,
          leading: null,
          title: Text(
            'SERVICES',
            style: TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: context.textPrimary,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: IconButton(
                icon: Icon(
                  Icons.search_rounded,
                  color: context.textPrimary,
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
              // 0. AI Symptom Guide Banner Card
              Container(
                decoration: BoxDecoration(
                  gradient: AppGradients.greenHeaderGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF082F21).withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) =>
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
                          transitionDuration:
                              const Duration(milliseconds: 400),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text(
                                'AI',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFD49E35),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AI Symptom Guide',
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Get instant Islamic guidance & duas',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: Color(0xFF81C784),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

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
                          const RuqyahHubScreen(),
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
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const HijamaHubScreen(),
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

              // 3. ACUPUNCTURE Service Card
              _buildMainServiceCard(
                title: 'ACUPUNCTURE',
                description:
                    'Holistic healing practices to maintain physical balance and energy wellness.',
                customIcon: const AcupunctureIcon(
                  color: Color(0xFF2980B9),
                  size: 28,
                ),
                iconBgColor: const Color(0xFFE6F7FF),
                iconColor: const Color(0xFF2980B9),
                onTap: () {
                  HapticFeedback.selectionClick();
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const AcupunctureHubScreen(),
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
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const EquipmentStoreScreen(),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeInOut,
                                ),
                                child: child,
                              );
                            },
                            transitionDuration:
                                const Duration(milliseconds: 400),
                          ),
                        );
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
}
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
                        style: TextStyle(
                          fontFamily: 'Cinzel',
                          fontSize: 16.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w400,
                          color: context.textSecondary,
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
