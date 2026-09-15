import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'prayer_times_service.dart';

class PrayerNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  /// Initializes local notifications plugin
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          debugPrint('Prayer notification clicked: ${details.payload}');
        },
      );

      _isInitialized = true;
      debugPrint('PrayerNotificationService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing PrayerNotificationService: $e');
    }
  }

  /// Fetches prayer times and schedules local notifications for Fajr, Dhuhr, Asr, Maghrib, and Isha
  static Future<void> schedulePrayerNotifications() async {
    await initialize();

    try {
      final times = await PrayerTimesService.fetchPrayerTimes();

      // Schedule each prayer
      await _scheduleSinglePrayer('Fajr', times.fajr24, 1);
      await _scheduleSinglePrayer('Dhuhr', times.dhuhr24, 2);
      await _scheduleSinglePrayer('Asr', times.asr24, 3);
      await _scheduleSinglePrayer('Maghrib', times.maghrib24, 4);
      await _scheduleSinglePrayer('Isha', times.isha24, 5);

      debugPrint('All prayer time notifications successfully scheduled');
    } catch (e) {
      debugPrint('Error scheduling prayer notifications: $e');
    }
  }

  static Future<void> _scheduleSinglePrayer(
    String prayerName,
    String time24,
    int id,
  ) async {
    try {
      final parts = time24.split(':');
      if (parts.length < 2) return;

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // If time has already passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'prayer_times_channel',
        'Prayer Times Reminders',
        channelDescription: 'Notifications for daily Islamic prayer times',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      await _notificationsPlugin.zonedSchedule(
        id,
        'Prayer Time: $prayerName',
        "It's time for $prayerName prayer. May Allah accept your worship and prayers.",
        scheduledDate,
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      debugPrint('Scheduled $prayerName notification at $hour:$minute');
    } catch (e) {
      debugPrint('Error scheduling $prayerName: $e');
    }
  }
}
