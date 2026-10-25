import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../localization/app_localizations.dart';
import '../../theme/app_gradients.dart';
import '../../theme/app_theme.dart';
import '../../widgets/acupuncture_icon.dart';
import '../../widgets/acupressure_icon.dart';
import '../../widgets/animations/animations.dart';
import '../../widgets/flowing_gradient.dart';
import '../../widgets/hijama_cupping_icon.dart';
import '../../widgets/modern_card.dart';
import '../../widgets/ruqyah_dua_icon.dart';
import '../../widgets/unani_tibb_icon.dart';
import '../../widgets/medicine_icon.dart';
import '../acupuncture_hub_screen.dart';
import '../acupressure_hub_screen.dart';
import '../ai_symptom_guide_screen.dart';
import '../ayurvedic_hub_screen.dart';
import '../equipment_store_screen.dart';
import '../hijama_hub_screen.dart';
import '../medicine_hub_screen.dart';
import '../pathology_hub_screen.dart';
import '../ruqyah_hub_screen.dart';
import '../unani_hub_screen.dart';
import 'learn_tab.dart';
import '../../widgets/islamic_pattern.dart';

/// Modern Services tab.
///
/// Design updates:
///   - AI banner uses the emerald gradient (no moving shine: calm UX).
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
        iconBg: AppColors.tintMint,
        iconColor: AppColors.primaryGreen,
        target: const RuqyahHubScreen(),
      ),
      _ServiceEntry(
        title: context.tr('hijama_title'),
        description: context.tr('hijama_sub'),
        customIcon: const HijamaCuppingIcon(color: AppColors.warning, size: 28),
        iconBg: AppColors.tintSand,
        iconColor: AppColors.warning,
        target: const HijamaHubScreen(),
      ),
      _ServiceEntry(
        title: context.tr('acupuncture_title'),
        description: context.tr('acupuncture_sub'),
        customIcon: const AcupunctureIcon(color: AppColors.info, size: 28),
        iconBg: AppColors.tintMist,
        iconColor: AppColors.info,
        target: const AcupunctureHubScreen(),
      ),
      _ServiceEntry(
        title: context.tr('acupressure_title'),
        description: context.tr('acupressure_sub'),
        customIcon: const AcupressureIcon(color: Color(0xFFC86D51), size: 28),
        iconBg: AppColors.tintRose,
        iconColor: const Color(0xFFC86D51),
        target: const AcupressureHubScreen(),
      ),
      _ServiceEntry(
        title: context.tr('ayurvedic_title'),
        description: context.tr('ayurvedic_sub'),
        icon: Icons.spa_outlined,
        iconBg: AppColors.tintSage,
        iconColor: AppColors.accentSage,
        target: const AyurvedicHubScreen(),
      ),
      _ServiceEntry(
        title: context.tr('unani_title'),
        description: context.tr('unani_sub'),
        customIcon: const UnaniTibbIcon(color: Color(0xFFC59236), size: 28),
        iconBg: const Color(0xFFFBF4E6),
        iconColor: const Color(0xFFC59236),
        target: const UnaniHubScreen(),
      ),
      _ServiceEntry(
        title: context.tr('medicine_title'),
        description: context.tr('medicine_sub'),
        customIcon: const MedicineIcon(color: Color(0xFF16A085), size: 28),
        iconBg: const Color(0xFFEAF5F2),
        iconColor: const Color(0xFF16A085),
        target: const MedicineHubScreen(),
      ),
      _ServiceEntry(
        title: context.tr('pathology_title'),
        description: context.tr('pathology_sub'),
        icon: Icons.biotech_outlined,
        iconBg: AppColors.tintLilac,
        iconColor: AppColors.accentLilac,
        target: const PathologyHubScreen(),
      ),
      _ServiceEntry(
        title: context.tr('courses_title'),
        description: context.tr('courses_sub'),
        icon: Icons.menu_book_rounded,
        iconBg: AppColors.tintSand,
        iconColor: AppColors.warning,
        target: const LearnTab(),
      ),
      _ServiceEntry(
        title: context.tr('store_title'),
        description: context.tr('store_sub'),
        icon: Icons.shopping_bag_outlined,
        iconBg: AppColors.tintMint,
        iconColor: AppColors.primaryGreen,
        target: const EquipmentStoreScreen(),
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
                  const SizedBox(height: 28),

                  // Bento grid: one featured tile, pairs of squares, one wide
                  // tile, then the two everyday links side by side.
                  ..._buildBento(services),

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
      onTap: () =>
          Navigator.of(context)
              .push(AppPageRoute.sharedAxis(const AISymptomGuideScreen())),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              foregroundDecoration: IslamicPatternDecoration(),
              decoration: BoxDecoration(
                gradient: AppGradients.emeraldGradient,
                borderRadius: BorderRadius.circular(20),
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
                          fontWeight: FontWeight.w700,
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
                            fontWeight: FontWeight.w700,
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
          ],
        ),
      ),
    );
  }

  // ─── Bento layout ──────────────────────────────────────────

  static const double _gap = 14;

  /// Rhythm: [0] featured, then pairs, a wide tile when one is left over, and
  /// the last two entries (learning and shop) as a compact pair.
  List<Widget> _buildBento(List<_ServiceEntry> all) {
    if (all.length < 3) {
      return [for (final e in all) _wideTile(e), const SizedBox(height: _gap)];
    }
    final featured = all.first;
    final tail = all.sublist(all.length - 2);
    final middle = all.sublist(1, all.length - 2);

    var step = 0;
    Widget stagger(Widget child) => FadeSlideIn(
      delay: Duration(milliseconds: 60 + 50 * step++),
      child: child,
    );

    final out = <Widget>[
      stagger(_featuredTile(featured)),
      const SizedBox(height: _gap),
    ];
    for (var i = 0; i < middle.length; i += 2) {
      if (i + 1 < middle.length) {
        out.add(
          stagger(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _squareTile(middle[i])),
                  const SizedBox(width: _gap),
                  Expanded(child: _squareTile(middle[i + 1])),
                ],
              ),
            ),
          ),
        );
      } else {
        out.add(stagger(_wideTile(middle[i])));
      }
      out.add(const SizedBox(height: _gap));
    }
    out.add(
      stagger(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _compactTile(tail[0])),
              const SizedBox(width: _gap),
              Expanded(child: _compactTile(tail[1])),
            ],
          ),
        ),
      ),
    );
    return out;
  }

  void _open(_ServiceEntry s) =>
      Navigator.of(context).push(AppPageRoute.sharedAxis(s.target));

  Widget _iconBadge(_ServiceEntry s, {double size = 48, bool onDark = false}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: onDark
            ? Colors.white.withValues(alpha: 0.94)
            : (context.isDarkMode ? const Color(0xFF182E25) : s.iconBg),
        borderRadius: BorderRadius.circular(size * 0.34),
      ),
      alignment: Alignment.center,
      child: s.customIcon ?? Icon(s.icon, color: s.iconColor, size: size * 0.5),
    );
  }

  /// The main service: a wide tile on a slowly drifting emerald gradient.
  Widget _featuredTile(_ServiceEntry s) {
    return PressScale(
      onTap: () => _open(s),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: FlowingGradient(
          colors: const [
            Color(0xFF082F21),
            Color(0xFF0F593D),
            Color(0xFF127A52),
          ],
          child: Container(
            padding: const EdgeInsets.all(22),
            constraints: const BoxConstraints(minHeight: 132),
            foregroundDecoration: const IslamicPatternDecoration(
              opacity: 0.08,
              cell: 60,
            ),
            child: Row(
              children: [
                _iconBadge(s, size: 60, onDark: true),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        s.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Cinzel',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          height: 1.15,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        s.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 13,
                          height: 1.45,
                          color: Colors.white.withValues(alpha: 0.82),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.14),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFFE9C26F),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// A tile in a pair: icon on top, then title and a short line.
  Widget _squareTile(_ServiceEntry s) {
    return ModernCard(
      padding: const EdgeInsets.all(18),
      radius: 26,
      onTap: () => _open(s),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 138),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _iconBadge(s, size: 46),
                Icon(
                  Icons.north_east_rounded,
                  size: 18,
                  color: context.textMuted,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              s.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.9,
                height: 1.2,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              s.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                height: 1.4,
                color: context.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// A wide tile for a service that has no partner in its row.
  Widget _wideTile(_ServiceEntry s) {
    return ModernCard(
      padding: const EdgeInsets.all(18),
      radius: 26,
      onTap: () => _open(s),
      child: Row(
        children: [
          _iconBadge(s, size: 50),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  s.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  s.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12.5,
                    height: 1.4,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.north_east_rounded, size: 18, color: context.textMuted),
        ],
      ),
    );
  }

  /// Everyday links (learning, shop): small, side by side.
  Widget _compactTile(_ServiceEntry s) {
    return ModernCard(
      padding: const EdgeInsets.all(14),
      radius: 22,
      onTap: () => _open(s),
      child: Row(
        children: [
          _iconBadge(s, size: 40),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  s.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  s.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.5,
                    height: 1.3,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
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
