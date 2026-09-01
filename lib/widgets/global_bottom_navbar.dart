import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      decoration: BoxDecoration(
        color: const Color(0xFFFBFDFC),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFE2E8E5).withValues(alpha: 0.80),
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            offset: const Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: 8,
        bottom: bottomPadding > 0 ? bottomPadding + 4 : 10,
        left: 8,
        right: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            tab: NavigationTab.home,
            label: 'Home',
            activeIcon: Icons.home_rounded,
            inactiveIcon: Icons.home_outlined,
          ),
          _buildNavItem(
            tab: NavigationTab.services,
            label: 'Services',
            activeIcon: Icons.grid_view_rounded,
            inactiveIcon: Icons.grid_view_outlined,
          ),
          _buildNavItem(
            tab: NavigationTab.bookings,
            label: 'Bookings',
            activeIcon: Icons.calendar_month_rounded,
            inactiveIcon: Icons.calendar_today_outlined,
          ),
          _buildNavItem(
            tab: NavigationTab.learn,
            label: 'Learn',
            activeIcon: Icons.menu_book_outlined,
            inactiveIcon: Icons.menu_book_outlined,
          ),
          _buildNavItem(
            tab: NavigationTab.profile,
            label: 'Profile',
            activeIcon: Icons.person_rounded,
            inactiveIcon: Icons.person_outline_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required NavigationTab tab,
    required String label,
    required IconData activeIcon,
    required IconData inactiveIcon,
  }) {
    final isSelected = currentTab == tab;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTabSelected(tab);
          },
          borderRadius: BorderRadius.circular(12),
          splashColor: activeColor.withValues(alpha: 0.08),
          highlightColor: activeColor.withValues(alpha: 0.04),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected ? activeIcon : inactiveIcon,
                  size: 24,
                  color: isSelected ? activeColor : inactiveColor,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? activeColor : inactiveColor,
                    letterSpacing: 0.1,
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
