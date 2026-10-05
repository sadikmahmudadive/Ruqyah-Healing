import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../screens/notification_screen.dart';
import 'firebase_service.dart';
import 'notification_inbox.dart';
import 'notification_prefs.dart';
import 'notification_service.dart';

/// Shared by the foreground and background paths so both build the same
/// inbox entry (and the same id, which de-duplicates a push seen twice).
InboxEntry _entryFromMessage(RemoteMessage message) {
  return InboxEntry(
    id: message.messageId ?? 'push_${DateTime.now().microsecondsSinceEpoch}',
    title:
        message.notification?.title ??
        message.data['title'] as String? ??
        'Ruqyah Notification',
    body:
        message.notification?.body ??
        message.data['body'] as String? ??
        'You have a new update.',
    category: _normalizeCategory(message.data['category'] as String?),
    receivedAt: message.sentTime ?? DateTime.now(),
  );
}

String _normalizeCategory(String? raw) {
  switch (raw) {
    case 'Appointments':
    case 'Messages':
    case 'Orders':
    case 'Reminders':
      return raw!;
    default:
      return 'Reminders';
  }
}

/// Runs in a separate isolate when a push arrives while the app is in the
/// background or closed. Pushes with a `notification` block are shown by the
/// system; data-only pushes are not, so show those here. Either way keep them
/// in the inbox.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    final entry = _entryFromMessage(message);
    await NotificationInbox.instance.add(entry);

    if (message.notification == null) {
      await NotificationPrefs.instance.load();
      if (NotificationPrefs.instance.messagesEnabled) {
        await NotificationService.show(
          id: entry.id.hashCode & 0x7fffffff,
          title: entry.title,
          body: entry.body,
          channel: AppNotificationChannel.forCategory(entry.category),
          payload: 'inbox',
        );
      }
    }
  } catch (e) {
    debugPrint('Background push handler error: $e');
  }
}

class PushNotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  /// Inbox as the UI model, newest first.
  static List<NotificationItem> get notifications => [
    for (final e in NotificationInbox.instance.entries) _toItem(e),
  ];

  static Future<void> markAllAsRead() => NotificationInbox.instance.markAllRead();

  /// Helper to safely retrieve current FCM token
  static Future<String?> getFcmToken() async {
    try {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        final apnsToken = await _fcm.getAPNSToken();
        if (apnsToken == null) {
          debugPrint(
            'APNs token unavailable (running on iOS Simulator). Skipping FCM token request.',
          );
          return null;
        }
      }
      return await _fcm.getToken();
    } catch (e) {
      debugPrint('Note fetching FCM token: $e');
      return null;
    }
  }

  /// Initializes push permissions and handlers.
  static Future<void> initialize() async {
    try {
      // 1. Permission (shared with local notifications on Android 13+)
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint(
        'FCM Notification permission status: ${settings.authorizationStatus}',
      );

      // 2. FCM token for targeted pushes, saved to Firestore
      final token = await getFcmToken();
      if (token != null && token.isNotEmpty) {
        await FirebaseService.updateFcmToken(token);
      }
      _fcm.onTokenRefresh.listen(FirebaseService.updateFcmToken);

      // 3. Background / terminated delivery
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 4. App in the foreground: the OS shows nothing, so show it ourselves.
      FirebaseMessaging.onMessage.listen(_onForegroundMessage);

      // 5. Notification tapped while the app was in the background.
      FirebaseMessaging.onMessageOpenedApp.listen(_onOpenedFromPush);

      // 6. Notification tapped while the app was closed.
      final initial = await _fcm.getInitialMessage();
      if (initial != null) await _onOpenedFromPush(initial);
    } catch (e) {
      debugPrint('PushNotificationService initialize note: $e');
    }
  }

  static Future<void> _onForegroundMessage(RemoteMessage message) async {
    final entry = _entryFromMessage(message);
    await NotificationInbox.instance.add(entry);

    // The inbox always keeps it; only the pop-up respects the user's switch.
    if (!NotificationPrefs.instance.messagesEnabled) return;
    await NotificationService.show(
      id: entry.id.hashCode & 0x7fffffff,
      title: entry.title,
      body: entry.body,
      channel: AppNotificationChannel.forCategory(entry.category),
      payload: 'inbox',
    );
  }

  static Future<void> _onOpenedFromPush(RemoteMessage message) async {
    await NotificationInbox.instance.add(_entryFromMessage(message));
    NotificationService.openFromPayload('inbox');
  }

  // ───────────────────────── presentation mapping ────────────────────

  static NotificationItem _toItem(InboxEntry e) {
    final (icon, bg, fg) = _style(e.category);
    return NotificationItem(
      id: e.id,
      title: e.title,
      subtitle: e.body,
      time: _timeLabel(e.receivedAt),
      category: e.category,
      icon: icon,
      iconBgColor: bg,
      iconColor: fg,
      isUnread: !e.read,
    );
  }

  static (IconData, Color, Color) _style(String category) {
    switch (category) {
      case 'Appointments':
        return (
          Icons.calendar_today_outlined,
          const Color(0xFFEBF7F0),
          const Color(0xFF0B4632),
        );
      case 'Messages':
        return (
          Icons.mail_outline_rounded,
          const Color(0xFFE6F7FF),
          const Color(0xFF2980B9),
        );
      case 'Orders':
        return (
          Icons.shopping_bag_outlined,
          const Color(0xFFFFF3E8),
          const Color(0xFFE67E22),
        );
      default:
        return (
          Icons.notifications_none_rounded,
          const Color(0xFFEBF7F0),
          const Color(0xFF0B4632),
        );
    }
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// "Just now", "10:00 AM", "Yesterday", "3 days ago", "12 Mar".
  @visibleForTesting
  static String timeLabel(DateTime t, {DateTime? now}) =>
      _timeLabel(t, now: now);

  static String _timeLabel(DateTime t, {DateTime? now}) {
    final n = now ?? DateTime.now();
    if (n.difference(t).inSeconds < 60 && !t.isAfter(n)) return 'Just now';

    final today = DateTime(n.year, n.month, n.day);
    final day = DateTime(t.year, t.month, t.day);
    final days = today.difference(day).inDays;

    if (days <= 0) {
      final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
      final m = t.minute.toString().padLeft(2, '0');
      return '$h:$m ${t.hour >= 12 ? 'PM' : 'AM'}';
    }
    if (days == 1) return 'Yesterday';
    if (days < 7) return '$days days ago';
    return '${t.day} ${_months[t.month - 1]}';
  }
}
