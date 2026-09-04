import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'navbar_icons.dart';

enum NavigationTab {
  home,
  services,
  bookings,
  learn,
  profile,
}

class GlobalBottomNavBar extends StatelessWidget {
  final NavigationTab currentTab;
  final ValueChanged<NavigationTab> onTabSelected;

  static const Color activeColor = Color(0xFF0B4632);
  static const Color inactiveColor = Color(0xFF52625B);

  const GlobalBottomNavBar({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBgColor = isDark
        ? const Color(0xFF121B17).withValues(alpha: 0.70)
        : Colors.white.withValues(alpha: 0.60);
    final navBorderColor = isDark
        ? const Color(0xFF283B32).withValues(alpha: 0.80)
        : Colors.white.withValues(alpha: 0.70);

    return Padding(
      padding: const EdgeInsets.only(left: 14, right: 14, bottom: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: navBgColor,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: navBorderColor,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    context,
                    tab: NavigationTab.home,
                    label: 'Home',
                    iconBuilder: (isSelected, color) => HomeNavIcon(
                      isSelected: isSelected,
                      color: color,
                      size: 24,
                    ),
                  ),
                  _buildNavItem(
                    context,
                    tab: NavigationTab.services,
                    label: 'Services',
                    iconBuilder: (isSelected, color) => ServicesNavIcon(
                      isSelected: isSelected,
                      color: color,
                      size: 24,
                    ),
                  ),
                  _buildNavItem(
                    context,
                    tab: NavigationTab.bookings,
                    label: 'Bookings',
                    iconBuilder: (isSelected, color) => BookingsNavIcon(
                      isSelected: isSelected,
                      color: color,
                      size: 24,
                    ),
                  ),
                  _buildNavItem(
                    context,
                    tab: NavigationTab.learn,
                    label: 'Learn',
                    iconBuilder: (isSelected, color) => LearnNavIcon(
                      isSelected: isSelected,
                      color: color,
                      size: 24,
                    ),
                  ),
                  _buildNavItem(
                    context,
                    tab: NavigationTab.profile,
                    label: 'Profile',
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveIconColor =
        isDark ? const Color(0xFF81C784) : const Color(0xFF0B4632);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTabSelected(tab);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        height: 48,
        padding: isSelected
            ? const EdgeInsets.symmetric(horizontal: 14)
            : const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0B4632) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0B4632).withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconBuilder(
                isSelected, isSelected ? Colors.white : inactiveIconColor),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
