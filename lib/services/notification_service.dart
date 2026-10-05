import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../app_navigator.dart';
import '../screens/notification_screen.dart';

/// A notification channel (Android 8+ lets users mute each one separately).
class AppNotificationChannel {
  final String id;
  final String name;
  final String description;
  final Importance importance;

  const AppNotificationChannel(
    this.id,
    this.name,
    this.description,
    this.importance,
  );

  static const prayer = AppNotificationChannel(
    'prayer_times_channel',
    'Prayer Times Reminders',
    'Notifications for daily Islamic prayer times',
    Importance.max,
  );
  static const appointments = AppNotificationChannel(
    'appointments_channel',
    'Appointment Reminders',
    'Reminders before your booked sessions',
    Importance.high,
  );
  static const messages = AppNotificationChannel(
    'messages_channel',
    'Messages & Updates',
    'Messages from therapists, order updates and announcements',
    Importance.high,
  );
  static const reminders = AppNotificationChannel(
    'reminders_channel',
    'General Reminders',
    'Daily azkar and wellness reminders',
    Importance.defaultImportance,
  );

  static const all = [prayer, appointments, messages, reminders];

  /// Channel for an inbox category.
  static AppNotificationChannel forCategory(String category) {
    switch (category) {
      case 'Appointments':
        return appointments;
      case 'Messages':
      case 'Orders':
        return messages;
      default:
        return reminders;
    }
  }
}

/// Runs when a notification action is tapped while the app is in the
/// background (a separate isolate). It can't navigate, so it only needs to
/// exist; the tap is handled when the app opens.
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {}

/// Local notifications: channels, permission, scheduling and tap routing.
/// Everything here is safe to call repeatedly and never throws.
class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void>? _initFuture;

  /// Default zone until prayer times say otherwise (see [setTimeZone]).
  static const String _timeZoneName = 'Asia/Dhaka';

  static bool get _supported => !kIsWeb;

  static AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  static IOSFlutterLocalNotificationsPlugin? get _ios => _plugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >();

  static Future<void> initialize() => _initFuture ??= _initialize();

  /// Alerts are scheduled in the zone of the place prayer times are for, so a
  /// "04:36" prayer fires at 04:36 there. Falls back to Dhaka for unknown names.
  static void setTimeZone(String name) {
    try {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (e) {
      debugPrint('NotificationService: unknown time zone "$name" ($e)');
    }
  }

  static Future<void> _initialize() async {
    if (!_supported) return;
    try {
      tz.initializeTimeZones();
      try {
        tz.setLocalLocation(tz.getLocation(_timeZoneName));
      } catch (e) {
        debugPrint('NotificationService: time zone not set ($e)');
      }

      await _plugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          // Permission is requested explicitly, not as a side effect of init.
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
        onDidReceiveNotificationResponse: (r) => openFromPayload(r.payload),
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );

      final android = _android;
      if (android != null) {
        for (final c in AppNotificationChannel.all) {
          await android.createNotificationChannel(
            AndroidNotificationChannel(
              c.id,
              c.name,
              description: c.description,
              importance: c.importance,
            ),
          );
        }
      }

      // App was launched by tapping a notification.
      final launch = await _plugin.getNotificationAppLaunchDetails();
      if (launch?.didNotificationLaunchApp ?? false) {
        openFromPayload(launch!.notificationResponse?.payload);
      }
    } catch (e) {
      debugPrint('NotificationService init error: $e');
      _initFuture = null; // allow a retry
    }
  }

  // ───────────────────────────── permission ──────────────────────────

  /// True when the OS will actually show our notifications.
  static Future<bool> areEnabled() async {
    if (!_supported) return false;
    try {
      await initialize();
      final android = _android;
      if (android != null) return await android.areNotificationsEnabled() ?? true;
      final ios = _ios;
      if (ios != null) {
        final p = await ios.checkPermissions();
        return p?.isEnabled ?? false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Asks the user (Android 13+ / iOS). Returns whether it is now allowed.
  static Future<bool> requestPermission() async {
    if (!_supported) return false;
    try {
      await initialize();
      await _android?.requestNotificationsPermission();
      await _ios?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (e) {
      debugPrint('NotificationService permission error: $e');
    }
    return areEnabled();
  }

  /// Android 12+: whether alarms may fire at the exact minute. Without it we
  /// fall back to inexact alarms (can be a few minutes late).
  static Future<bool> canScheduleExact() async {
    try {
      return await _android?.canScheduleExactNotifications() ?? true;
    } catch (_) {
      return false;
    }
  }

  /// Opens the system screen where the user can allow exact alarms.
  static Future<void> requestExactAlarms() async {
    try {
      await _android?.requestExactAlarmsPermission();
    } catch (e) {
      debugPrint('NotificationService exact alarm request error: $e');
    }
  }

  // ───────────────────────────── showing ─────────────────────────────

  static NotificationDetails _details(AppNotificationChannel c, String body) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        c.id,
        c.name,
        channelDescription: c.description,
        importance: c.importance,
        priority: c.importance == Importance.max
            ? Priority.max
            : Priority.high,
        icon: '@mipmap/ic_launcher',
        // Long messages expand instead of being cut off.
        styleInformation: BigTextStyleInformation(body),
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  static Future<void> show({
    required int id,
    required String title,
    required String body,
    required AppNotificationChannel channel,
    String? payload,
  }) async {
    if (!_supported) return;
    try {
      await initialize();
      await _plugin.show(id, title, body, _details(channel, body), payload: payload);
    } catch (e) {
      debugPrint('NotificationService.show error: $e');
    }
  }

  /// Schedules at [when]; with [repeatDaily] it fires every day at that time.
  /// Uses exact alarms when allowed and inexact ones otherwise, so a missing
  /// permission delays a reminder instead of losing it.
  static Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime when,
    required AppNotificationChannel channel,
    String? payload,
    bool repeatDaily = false,
  }) async {
    if (!_supported) return;
    await initialize();

    Future<void> go(AndroidScheduleMode mode) => _plugin.zonedSchedule(
      id,
      title,
      body,
      when,
      _details(channel, body),
      androidScheduleMode: mode,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: repeatDaily ? DateTimeComponents.time : null,
      payload: payload,
    );

    try {
      final exact = await canScheduleExact();
      await go(
        exact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('NotificationService.schedule($id) exact failed: $e');
      try {
        await go(AndroidScheduleMode.inexactAllowWhileIdle);
      } catch (e2) {
        debugPrint('NotificationService.schedule($id) failed: $e2');
      }
    }
  }

  static Future<void> cancel(int id) async {
    if (!_supported) return;
    try {
      await _plugin.cancel(id);
    } catch (_) {}
  }

  static Future<void> cancelAll(Iterable<int> ids) async {
    for (final id in ids) {
      await cancel(id);
    }
  }

  /// Next time a daily [hour]:[minute] occurs in the notification time zone.
  static tz.TZDateTime nextDaily(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var at = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!at.isAfter(now)) at = at.add(const Duration(days: 1));
    return at;
  }

  /// A notification the user can trigger from settings, to check that
  /// alerts reach them.
  static Future<void> showTest() => show(
    id: 9001,
    title: 'Notifications are working',
    body: 'You will receive prayer times, appointment reminders and updates here.',
    channel: AppNotificationChannel.reminders,
    payload: 'inbox',
  );

  // ───────────────────────────── tap routing ─────────────────────────

  /// Payload format: `<kind>` or `<kind>:<id>`. Prayer alerts just open the
  /// app; everything else opens the notification inbox.
  static void openFromPayload(String? payload) {
    final kind = payload?.split(':').first;
    if (kind == null || kind.isEmpty || kind == 'prayer') return;
    _pushWhenReady(0);
  }

  // On a cold start the Navigator may not exist yet; retry for a few seconds.
  static void _pushWhenReady(int attempt) {
    final nav = appNavigatorKey.currentState;
    if (nav != null) {
      nav.push(
        MaterialPageRoute<void>(builder: (_) => const NotificationScreen()),
      );
      return;
    }
    if (attempt >= 25) return;
    Timer(const Duration(milliseconds: 200), () => _pushWhenReady(attempt + 1));
  }
}
