import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/global_bottom_navbar.dart';
import 'tabs/bookings_tab.dart';
import 'tabs/home_tab.dart';
import 'tabs/learn_tab.dart';
import 'tabs/profile_tab.dart';
import 'tabs/services_tab.dart';

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
      setState(() {
        _currentTab = tab;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: IndexedStack(
          index: _currentTab.index,
          children: _tabPages.values.toList(),
        ),
        bottomNavigationBar: GlobalBottomNavBar(
          currentTab: _currentTab,
          onTabSelected: _handleTabSelected,
        ),
      ),
    );
  }
}
