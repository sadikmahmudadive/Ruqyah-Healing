import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../localization/app_localizations.dart';
import '../../theme/app_gradients.dart';
import '../../theme/app_theme.dart';
import '../../widgets/acupuncture_icon.dart';
import '../../widgets/animations/animations.dart';
import '../../widgets/hijama_cupping_icon.dart';
import '../../widgets/modern_card.dart';
import '../../widgets/ruqyah_dua_icon.dart';
import '../acupuncture_hub_screen.dart';
import '../ai_symptom_guide_screen.dart';
import '../ayurvedic_hub_screen.dart';
import '../equipment_store_screen.dart';
import '../hijama_hub_screen.dart';
import '../pathology_hub_screen.dart';
import '../ruqyah_hub_screen.dart';

/// Modern Services tab.
///
/// Design updates:
///   - AI banner uses the emerald gradient + sweeping shine overlay.
///   - Each service card fades + slides in with a stagger.
///   - Cards use PressScale for a snappy tactile press.
///   - Trailing chevron glides to the right on press (via Transform).
class ServicesTab extends StatefulWidget {
  const ServicesTab({super.key});

  @override
  State<ServicesTab> createState() => _ServicesTabState();
}

class _ServicesTabState extends State<ServicesTab> {
  @override
  Widget build(BuildContext context) {
    final services = <_ServiceEntry>[
      _ServiceEntry(
        title: context.tr('ruqyah_title'),
        description: context.tr('ruqyah_sub'),
        customIcon: const RuqyahDuaIcon(
          color: AppColors.primaryGreen,
          size: 28,
        ),
        iconBg: const Color(0xFFEBF7F0),
        iconColor: AppColors.primaryGreen,
        target: const RuqyahHubScreen(),
      ),
      _ServiceEntry(
        title: context.tr('hijama_title'),
        description: context.tr('hijama_sub'),
        customIcon: const HijamaCuppingIcon(
          color: AppColors.warning,
          size: 28,
        ),
        iconBg: const Color(0xFFFFF3E8),
        iconColor: AppColors.warning,
        target: const HijamaHubScreen(),
      ),
      _ServiceEntry(
        title: context.tr('acupuncture_title'),
        description: context.tr('acupuncture_sub'),
        customIcon: const AcupunctureIcon(
          color: AppColors.info,
          size: 28,
        ),
        iconBg: const Color(0xFFE6F7FF),
        iconColor: AppColors.info,
        target: const AcupunctureHubScreen(),
      ),
      _ServiceEntry(
        title: context.tr('ayurvedic_title'),
        description: context.tr('ayurvedic_sub'),
        icon: Icons.spa_outlined,
        iconBg: const Color(0xFFE8F8F5),
        iconColor: const Color(0xFF27AE60),
        target: const AyurvedicHubScreen(),
      ),
      _ServiceEntry(
        title: context.tr('pathology_title'),
        description: context.tr('pathology_sub'),
        icon: Icons.biotech_outlined,
        iconBg: const Color(0xFFF4ECF7),
        iconColor: const Color(0xFF8E44AD),
        target: const PathologyHubScreen(),
      ),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.systemOverlayStyle,
      child: Scaffold(
        backgroundColor: context.pageBg,
        appBar: AppBar(
          backgroundColor: context.pageBg,
          elevation: 0,
          titleSpacing: 20,
          automaticallyImplyLeading: false,
          title: Text(
            context.tr('services').toUpperCase(),
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
              child: PressScale(
                onTap: () => HapticFeedback.selectionClick(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: context.cardBorder),
                    boxShadow: AppElevation.subtle,
                  ),
                  child: Icon(
                    Icons.search_rounded,
                    color: context.textPrimary,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 12.0,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // AI banner
                  FadeSlideIn(child: _buildAiBanner()),
                  const SizedBox(height: 20),

                  // Main services (staggered)
                  for (int i = 0; i < services.length; i++) ...[
                    FadeSlideIn(
                      delay: Duration(milliseconds: 80 + i * 60),
                      child: _buildMainServiceCard(services[i]),
                    ),
                    const SizedBox(height: 14),
                  ],

                  const SizedBox(height: 4),

                  // Bottom bento: courses + store
                  FadeSlideIn(
                    delay: Duration(milliseconds: 80 + services.length * 60),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildSubServiceCard(
                            title: context.tr('courses'),
                            description: context.tr('learn_protection'),
                            icon: Icons.menu_book_rounded,
                            iconBgColor: const Color(0xFFFFF3E8),
                            iconColor: AppColors.warning,
                            onTap: () =>
                                HapticFeedback.selectionClick(),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildSubServiceCard(
                            title: context.tr('store'),
                            description: context.tr('natural_remedies'),
                            icon: Icons.shopping_bag_outlined,
                            iconBgColor: const Color(0xFFEBF7F0),
                            iconColor: AppColors.primaryGreen,
                            onTap: () => Navigator.of(context).push(
                              AppPageRoute.sharedAxis(
                                const EquipmentStoreScreen(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 120),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiBanner() {
    return PressScale(
      hapticType: HapticFeedbackType.medium,
      onTap: () => Navigator.of(context).push(
        AppPageRoute.sharedAxis(const AISymptomGuideScreen()),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppGradients.emeraldGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppElevation.glow(
                  AppColors.primaryGreen,
                  strength: 0.25,
                ),
              ),
              child: Row(
                children: [
                  BreathingPulse(
                    maxScale: 1.06,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Text(
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('ai_symptom_guide'),
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.tr('ai_symptom_sub'),
                          style: const TextStyle(
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
            const Positioned.fill(
              child: ShineOverlay(
                opacity: 0.1,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainServiceCard(_ServiceEntry s) {
    return ModernCard(
      padding: const EdgeInsets.all(20),
      onTap: () =>
          Navigator.of(context).push(AppPageRoute.sharedAxis(s.target)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: context.isDarkMode
                  ? const Color(0xFF182E25)
                  : s.iconBg,
              borderRadius: BorderRadius.circular(16),
              boxShadow: context.isDarkMode
                  ? []
                  : [
                      BoxShadow(
                        color: s.iconColor.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            alignment: Alignment.center,
            child: s.customIcon ??
                Icon(s.icon, color: s.iconColor, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.title,
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
                  s.description,
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
          Icon(
            Icons.chevron_right_rounded,
            color: context.textMuted,
            size: 22,
          ),
        ],
      ),
    );
  }

  Widget _buildSubServiceCard({
    required String title,
    required String description,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return ModernCard(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 16.0),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.isDarkMode
                  ? const Color(0xFF182E25)
                  : iconBgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.5,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: context.textMuted,
            size: 18,
          ),
        ],
      ),
    );
  }
}

class _ServiceEntry {
  final String title;
  final String description;
  final IconData? icon;
  final Widget? customIcon;
  final Color iconBg;
  final Color iconColor;
  final Widget target;

  _ServiceEntry({
    required this.title,
    required this.description,
    this.icon,
    this.customIcon,
    required this.iconBg,
    required this.iconColor,
    required this.target,
  });
}
