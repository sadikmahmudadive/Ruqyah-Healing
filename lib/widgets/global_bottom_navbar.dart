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
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.70),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.80),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavItem(
                    tab: NavigationTab.home,
                    label: 'Home',
                    iconBuilder: (isSelected, color) => HomeNavIcon(
                      isSelected: isSelected,
                      color: color,
                      size: 21,
                    ),
                  ),
                  _buildNavItem(
                    tab: NavigationTab.services,
                    label: 'Services',
                    iconBuilder: (isSelected, color) => ServicesNavIcon(
                      isSelected: isSelected,
                      color: color,
                      size: 18.5,
                    ),
                  ),
                  _buildNavItem(
                    tab: NavigationTab.bookings,
                    label: 'Bookings',
                    iconBuilder: (isSelected, color) => BookingsNavIcon(
                      isSelected: isSelected,
                      color: color,
                      size: 21,
                    ),
                  ),
                  _buildNavItem(
                    tab: NavigationTab.learn,
                    label: 'Learn',
                    iconBuilder: (isSelected, color) => LearnNavIcon(
                      isSelected: isSelected,
                      color: color,
                      size: 21,
                    ),
                  ),
                  _buildNavItem(
                    tab: NavigationTab.profile,
                    label: 'Profile',
                    iconBuilder: (isSelected, color) => ProfileNavIcon(
                      isSelected: isSelected,
                      color: color,
                      size: 21,
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

  Widget _buildNavItem({
    required NavigationTab tab,
    required String label,
    required Widget Function(bool isSelected, Color color) iconBuilder,
  }) {
    final isSelected = currentTab == tab;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTabSelected(tab);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: isSelected
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF13422E) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF13422E).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconBuilder(
                isSelected, isSelected ? Colors.white : const Color(0xFF13422E)),
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
