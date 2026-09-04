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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
    );
  }

  Widget _buildNavItem({
    required NavigationTab tab,
    required String label,
    required Widget Function(bool isSelected, Color color) iconBuilder,
  }) {
    final isSelected = currentTab == tab;
    final color = isSelected ? activeColor : inactiveColor;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTabSelected(tab);
          },
          borderRadius: BorderRadius.circular(12),
          splashColor: activeColor.withValues(alpha: 0.06),
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                iconBuilder(isSelected, color),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
