import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_gradients.dart';
import 'order_tracking_screen.dart';
import 'secure_messages_screen.dart';
import 'settings_screen.dart';

class NotificationItem {
  final String id;
  final String title;
  final String subtitle;
  final String time;
  final String category; // 'Appointments', 'Messages', 'Reminders', 'Orders'
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final bool isUnread;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.category,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    this.isUnread = false,
  });
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = const [
    'All',
    'Appointments',
    'Messages',
    'Reminders',
    'Orders',
  ];

  final List<NotificationItem> _allNotifications = const [
    NotificationItem(
      id: 'notif_1',
      title: 'Appointment Reminder',
      subtitle:
          'Your session with Dr. Salma Rahman starts in 2 hours. Join the session.',
      time: '10:00 AM',
      category: 'Appointments',
      icon: Icons.calendar_today_outlined,
      iconBgColor: Color(0xFFEBF7F0),
      iconColor: Color(0xFF0B4632),
      isUnread: true,
    ),
    NotificationItem(
      id: 'notif_2',
      title: 'Daily Azkar Reminder',
      subtitle:
          'Take 5 minutes to read your morning protection supplications.',
      time: '08:00 AM',
      category: 'Reminders',
      icon: Icons.notifications_none_rounded,
      iconBgColor: Color(0xFFEBF7F0),
      iconColor: Color(0xFF0B4632),
      isUnread: true,
    ),
    NotificationItem(
      id: 'notif_3',
      title: 'New Message Received',
      subtitle:
          "Dr. Salma Rahman replied: 'Make sure to keep drinking the Ruqyah water...'",
      time: 'Yesterday',
      category: 'Messages',
      icon: Icons.mail_outline_rounded,
      iconBgColor: Color(0xFFE6F7FF),
      iconColor: Color(0xFF2980B9),
      isUnread: false,
    ),
    NotificationItem(
      id: 'notif_4',
      title: 'Order Complete',
      subtitle:
          'Your package containing organic Sidr leaves has been delivered.',
      time: '2 days ago',
      category: 'Orders',
      icon: Icons.shopping_bag_outlined,
      iconBgColor: Color(0xFFFFF3E8),
      iconColor: Color(0xFFE67E22),
      isUnread: false,
    ),
    NotificationItem(
      id: 'notif_5',
      title: 'Therapist Matched',
      subtitle:
          'A certified Hijama practitioner is now available near your area.',
      time: '3 days ago',
      category: 'Appointments',
      icon: Icons.person_outline_rounded,
      iconBgColor: Color(0xFFEBF7F0),
      iconColor: Color(0xFF0B4632),
      isUnread: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredNotifications = _selectedCategory == 'All'
        ? _allNotifications
        : _allNotifications
            .where((n) => n.category == _selectedCategory)
            .toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F6),
        body: Column(
          children: [
            // 1. Top Dark Green Header Area
            _buildTopHeader(),

            const SizedBox(height: 12),

            // 2. Horizontal Category Chips Bar
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = cat == _selectedCategory;

                  return InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF0B4632)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF0B4632)
                              : const Color(0xFFE2E8E5),
                          width: 1.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF0B4632)
                                      .withValues(alpha: 0.20),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 13.5,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF15221D),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // 3. Notifications List
            Expanded(
              child: filteredNotifications.isEmpty
                  ? Center(
                      child: Text(
                        'No notifications in $_selectedCategory',
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 14,
                          color: Color(0xFF6E7E77),
                        ),
                      ),
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 8.0),
                      itemCount: filteredNotifications.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final item = filteredNotifications[index];
                        return _buildNotificationCard(item);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Top Dark Green Header
  Widget _buildTopHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 16,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        gradient: AppGradients.greenHeaderGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          // Back Button
          Container(
            width: 44,
            height: 44,
            margin: const EdgeInsets.only(right: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
              padding: EdgeInsets.zero,
            ),
          ),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'NOTIFICATION CENTER',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: Color(0xFF81C784),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Notifications',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Settings Button
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.settings_outlined,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {
                HapticFeedback.selectionClick();
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const SettingsScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOut,
                        ),
                        child: child,
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            final targetWidget = item.category == 'Orders'
                ? const OrderTrackingScreen()
                : const SecureMessagesScreen();

            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    targetWidget,
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOut,
                    ),
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 400),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Container
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: item.iconBgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Icon(
                      item.icon,
                      color: item.iconColor,
                      size: 22,
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                // Content Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Time Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: const TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF15221D),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item.time,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: Color(0xFF6E7E77),
                                ),
                              ),
                              if (item.isUnread) ...[
                                const SizedBox(width: 6),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFD49E35),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Subtitle
                      Text(
                        item.subtitle,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF6E7E77),
                          height: 1.38,
                        ),
                      ),
                    ],
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
