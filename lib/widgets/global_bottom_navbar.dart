import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../localization/app_localizations.dart';
import 'navbar_icons.dart';

enum NavigationTab {
  home,
  services,
  bookings,
  learn,
  profile,
}
enum NavigationTab { home, services, bookings, learn, profile }

class GlobalBottomNavBar extends StatelessWidget {
  final NavigationTab currentTab;
  final ValueChanged<NavigationTab> onTabSelected;

  static const Color activeColor = Color(0xFF0B4632);
  static const Color inactiveColor = Color(0xFF70837B);
  static const Color activePillColor = Color(0xFFE8F2EC);
  static const Color inactiveColor = Color(0xFF52625B);

  const GlobalBottomNavBar({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBgColor = isDark
        ? const Color(0xFF081C15)
        : Colors.white.withValues(alpha: 0.60);
    final navBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.85)
        : Colors.white.withValues(alpha: 0.70);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFCFEFD).withValues(alpha: 0.92),
            border: Border(
              top: BorderSide(
                color: const Color(0xFFE1ECE6).withValues(alpha: 0.90),
                width: 0.9,
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
                width: isDark ? 1.2 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0B3022).withValues(alpha: 0.05),
                offset: const Offset(0, -6),
                blurRadius: 24,
                spreadRadius: 0,
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
            ],
            ),
          ),
          padding: EdgeInsets.only(
            top: 7,
            bottom: bottomPadding > 0 ? bottomPadding + 2 : 10,
            left: 10,
            right: 10,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                tab: NavigationTab.home,
                label: 'Home',
                iconBuilder: (isSelected, color) => HomeNavIcon(
                  isSelected: isSelected,
                  color: color,
                  size: 23,
                ),
              ),
              _buildNavItem(
                tab: NavigationTab.services,
                label: 'Services',
                iconBuilder: (isSelected, color) => ServicesNavIcon(
                  isSelected: isSelected,
                  color: color,
                  size: 22,
                ),
              ),
              _buildNavItem(
                tab: NavigationTab.bookings,
                label: 'Bookings',
                iconBuilder: (isSelected, color) => BookingsNavIcon(
                  isSelected: isSelected,
                  color: color,
                  size: 22,
                ),
              ),
              _buildNavItem(
                tab: NavigationTab.learn,
                label: 'Learn',
                iconBuilder: (isSelected, color) => LearnNavIcon(
                  isSelected: isSelected,
                  color: color,
                  size: 22,
                ),
              ),
              _buildNavItem(
                tab: NavigationTab.profile,
                label: 'Profile',
                iconBuilder: (isSelected, color) => ProfileNavIcon(
                  isSelected: isSelected,
                  color: color,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
  Widget _buildNavItem(
    BuildContext context, {
    required NavigationTab tab,
    required String label,
    required Widget Function(bool isSelected, Color color) iconBuilder,
  }) {
    final isSelected = currentTab == tab;
    final color = isSelected ? activeColor : inactiveColor;
    final inactiveIconColor = const Color(0xFF0B4632);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTabSelected(tab);
          },
          borderRadius: BorderRadius.circular(16),
          splashColor: activeColor.withValues(alpha: 0.08),
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated pill container behind the icon
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4.5,
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
                  decoration: BoxDecoration(
                    color: isSelected ? activePillColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: AnimatedScale(
                    scale: isSelected ? 1.06 : 1.0,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    child: iconBuilder(isSelected, color),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconBuilder(
              isSelected,
              isSelected ? Colors.white : inactiveIconColor,
            ),
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
                const SizedBox(height: 3),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11.2,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: color,
                    letterSpacing: 0.15,
                  ),
                  child: Text(label),
                ),
              ],
            ),
          ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
