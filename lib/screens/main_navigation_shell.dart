import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../widgets/animations/animations.dart';
import '../widgets/global_bottom_navbar.dart';
import 'tabs/bookings_tab.dart';
import 'tabs/home_tab.dart';
import 'tabs/learn_tab.dart';
import 'tabs/profile_tab.dart';
import 'tabs/services_tab.dart';

/// Main navigation shell for the authenticated app.
///
/// Keeps every tab mounted (via [IndexedStack]) so scroll positions and
/// in-flight requests survive tab switches, but overlays an
/// [AnimatedSwitcher] so switches crossfade softly instead of
/// snapping.
class MainNavigationShell extends StatefulWidget {
  final NavigationTab initialTab;

  const MainNavigationShell({
    super.key,
    this.initialTab = NavigationTab.home,
  });

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late NavigationTab _currentTab;

  final Map<NavigationTab, Widget> _tabPages = const {
    NavigationTab.home: HomeTab(),
    NavigationTab.services: ServicesTab(),
    NavigationTab.bookings: BookingsTab(),
    NavigationTab.learn: LearnTab(),
    NavigationTab.profile: ProfileTab(),
  };

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
  }

  void _handleTabSelected(NavigationTab tab) {
    if (_currentTab != tab) {
      setState(() => _currentTab = tab);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasDarkHeader = _currentTab == NavigationTab.bookings ||
        _currentTab == NavigationTab.learn;

    final overlayStyle = hasDarkHeader
        ? context.darkHeaderOverlayStyle
        : context.systemOverlayStyle;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        extendBody: true,
        body: AnimatedSwitcher(
          duration: AppMotion.base,
          switchInCurve: AppMotion.smooth,
          switchOutCurve: AppMotion.exit,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.015),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          layoutBuilder: (currentChild, previousChildren) {
            return Stack(
              alignment: Alignment.center,
              children: [
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
            );
          },
          child: KeyedSubtree(
            key: ValueKey<NavigationTab>(_currentTab),
            child: _tabPages[_currentTab]!,
          ),
        ),
        bottomNavigationBar: GlobalBottomNavBar(
          currentTab: _currentTab,
          onTabSelected: _handleTabSelected,
        ),
      ),
    );
  }
}
