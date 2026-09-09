import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../screens/notification_screen.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling background message: ${message.messageId}");
}

class PushNotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final ValueNotifier<int> unreadCountNotifier = ValueNotifier<int>(2);

  static final List<NotificationItem> _notificationsList = [
    const NotificationItem(
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
    const NotificationItem(
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
    const NotificationItem(
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
    const NotificationItem(
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
    const NotificationItem(
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

  static List<NotificationItem> get notifications => List.unmodifiable(_notificationsList);

  /// Initializes Push Notifications permissions and handlers.
  static Future<void> initialize() async {
    try {
      // 1. Request User Notification Permissions
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('FCM Notification permission status: ${settings.authorizationStatus}');

      // 2. Fetch FCM Token for targeted push messages
      String? token = await _fcm.getToken();
      debugPrint('FCM Device Token: $token');

      // 3. Register Background Handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 4. Handle Foreground Push Messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Foreground FCM Message received: ${message.notification?.title}');
        _handleIncomingRemoteMessage(message);
      });

      // 5. Handle App Opened via Notification Click
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('App opened via FCM Push Notification: ${message.notification?.title}');
        _handleIncomingRemoteMessage(message);
      });

      // 6. Check Initial Message if app was launched from terminated state
      RemoteMessage? initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        _handleIncomingRemoteMessage(initialMessage);
      }
    } catch (e) {
      debugPrint('PushNotificationService initialize note: $e');
    }
  }

  static void _handleIncomingRemoteMessage(RemoteMessage message) {
    final title = message.notification?.title ?? message.data['title'] ?? 'Ruqyah Notification';
    final body = message.notification?.body ?? message.data['body'] ?? 'You have a new update.';
    final category = message.data['category'] ?? 'Reminders';

    final newItem = NotificationItem(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      subtitle: body,
      time: 'Just now',
      category: category,
      icon: _getIconForCategory(category),
      iconBgColor: const Color(0xFFEBF7F0),
      iconColor: const Color(0xFF0B4632),
      isUnread: true,
    );

    _notificationsList.insert(0, newItem);
    unreadCountNotifier.value++;
  }

  static IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Appointments':
        return Icons.calendar_today_outlined;
      case 'Messages':
        return Icons.mail_outline_rounded;
      case 'Orders':
        return Icons.shopping_bag_outlined;
      case 'Reminders':
      default:
        return Icons.notifications_none_rounded;
    }
  }

  static void markAllAsRead() {
    for (int i = 0; i < _notificationsList.length; i++) {
      final item = _notificationsList[i];
      if (item.isUnread) {
        _notificationsList[i] = NotificationItem(
          id: item.id,
          title: item.title,
          subtitle: item.subtitle,
          time: item.time,
          category: item.category,
          icon: item.icon,
          iconBgColor: item.iconBgColor,
          iconColor: item.iconColor,
          isUnread: false,
        );
      }
    }
    unreadCountNotifier.value = 0;
  }
}
