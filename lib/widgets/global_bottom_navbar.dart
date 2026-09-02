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
  static const Color inactiveColor = Color(0xFF6E7E77);

  const GlobalBottomNavBar({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(
                color: const Color(0xFFE2E8E5).withValues(alpha: 0.80),
                width: 0.8,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0B4632).withValues(alpha: 0.06),
                offset: const Offset(0, -6),
                blurRadius: 24,
                spreadRadius: 0,
              ),
            ],
          ),
          padding: EdgeInsets.only(
            top: 6,
            bottom: bottomPadding > 0 ? bottomPadding + 2 : 8,
            left: 8,
            right: 8,
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
                  size: 21,
                ),
              ),
              _buildNavItem(
                tab: NavigationTab.services,
                label: 'Services',
                iconBuilder: (isSelected, color) => ServicesNavIcon(
                  isSelected: isSelected,
                  color: color,
                  size: 21,
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
          borderRadius: BorderRadius.circular(16),
          splashColor: activeColor.withValues(alpha: 0.08),
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Active Indicator Pill + Icon
                AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFE8F5EE)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: AnimatedScale(
                    scale: isSelected ? 1.08 : 1.0,
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutCubic,
                    child: iconBuilder(isSelected, color),
                  ),
                ),
                const SizedBox(height: 3),
                // Minimalist typography
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 240),
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: isSelected ? 11.5 : 11.0,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: color,
                    letterSpacing: isSelected ? 0.1 : 0.0,
                  ),
                  child: Text(label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
