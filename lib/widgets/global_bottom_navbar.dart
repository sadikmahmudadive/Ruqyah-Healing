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
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE2E8E5),
            width: 1.0,
          ),
        ),
      ),
      padding: EdgeInsets.only(
        top: 10,
        bottom: bottomPadding > 0 ? bottomPadding + 2 : 10,
        left: 6,
        right: 6,
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
