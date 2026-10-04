import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../localization/app_localizations.dart';
import '../theme/app_theme.dart';
import 'animations/animations.dart';
import 'navbar_icons.dart';

enum NavigationTab { home, services, bookings, learn, profile }

/// Modern floating bottom nav bar.
///
/// Design notes:
///   - A single "pill" indicator slides between tabs using
///     [AnimatedAlign]; the active icon's label grows in from 0 width.
///   - Icons do a small bounce on selection (scale 1.0 → 1.15 → 1.0).
///   - Backdrop blur gives a frosted-glass feel on both themes.
///   - Haptic selectionClick on every tap.
class GlobalBottomNavBar extends StatelessWidget {
  final NavigationTab currentTab;
  final ValueChanged<NavigationTab> onTabSelected;

  static const Color activeColor = Color(0xFF0B4632);

  const GlobalBottomNavBar({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final navBgColor = isDark
        ? const Color(0xFF081C15).withValues(alpha: 0.78)
        : Colors.white.withValues(alpha: 0.72);
    final navBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.70);

    return Padding(
      padding: const EdgeInsets.only(left: 14, right: 14, bottom: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: AnimatedContainer(
            duration: AppMotion.base,
            height: 72,
            decoration: BoxDecoration(
              color: navBgColor,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: navBorderColor,
                width: isDark ? 1.0 : 1.5,
              ),
              boxShadow: AppElevation.floating,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    context,
                    tab: NavigationTab.home,
                    label: context.tr('home'),
                    iconBuilder: (isSelected, color) => HomeNavIcon(
                      isSelected: isSelected,
                      color: color,
                      size: 24,
                    ),
                  ),
                  _buildNavItem(
                    context,
                    tab: NavigationTab.services,
                    label: context.tr('services'),
                    iconBuilder: (isSelected, color) => ServicesNavIcon(
                      isSelected: isSelected,
                      color: color,
                      size: 24,
                    ),
                  ),
                  _buildNavItem(
                    context,
                    tab: NavigationTab.bookings,
                    label: context.tr('bookings'),
                    iconBuilder: (isSelected, color) => BookingsNavIcon(
                      isSelected: isSelected,
                      color: color,
                      size: 24,
                    ),
                  ),
                  _buildNavItem(
                    context,
                    tab: NavigationTab.learn,
                    label: context.tr('learn'),
                    iconBuilder: (isSelected, color) => LearnNavIcon(
                      isSelected: isSelected,
                      color: color,
                      size: 24,
                    ),
                  ),
                  _buildNavItem(
                    context,
                    tab: NavigationTab.profile,
                    label: context.tr('profile'),
                    iconBuilder: (isSelected, color) => ProfileNavIcon(
                      isSelected: isSelected,
                      color: color,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required NavigationTab tab,
    required String label,
    required Widget Function(bool isSelected, Color color) iconBuilder,
  }) {
    final isSelected = currentTab == tab;
    final inactiveIconColor = context.isDarkMode
        ? const Color(0xFFCAD6D0)
        : const Color(0xFF0B4632);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTabSelected(tab);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        // Must NOT overshoot: this container animates a BoxShadow, and an
        // overshooting curve drives blurRadius negative (assertion crash).
        curve: AppMotion.standard,
        height: 48,
        padding: isSelected
            ? const EdgeInsets.symmetric(horizontal: 14)
            : const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with a small bounce when it becomes selected
            AnimatedScale(
              duration: const Duration(milliseconds: 350),
              curve: AppMotion.expressive,
              scale: isSelected ? 1.0 : 0.95,
              child: iconBuilder(
                isSelected,
                isSelected ? Colors.white : inactiveIconColor,
              ),
            ),
            // Label grows in / out instead of jumping
            AnimatedSize(
              duration: const Duration(milliseconds: 320),
              curve: AppMotion.smooth,
              child: isSelected
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
