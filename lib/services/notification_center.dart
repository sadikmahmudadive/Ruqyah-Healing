import 'dart:async';

import 'package:flutter/foundation.dart';

import 'appointment_reminder_service.dart';
import 'notification_inbox.dart';
import 'notification_prefs.dart';
import 'notification_service.dart';
import 'prayer_location_service.dart';
import 'prayer_notification_service.dart';

/// Starts the notification system and keeps scheduled alerts in step with the
/// user's preferences. Call [start] once at launch; [resync] after anything
/// that may change what should be scheduled (permission granted, refresh).
class NotificationCenter {
  NotificationCenter._();

  static bool _started = false;
  static bool _syncing = false;
  static bool _again = false;

  static Future<void> start() async {
    if (_started) return;
    _started = true;
    try {
      await NotificationPrefs.instance.load();
      await NotificationInbox.instance.load(reload: true);
      await NotificationService.initialize();
      await PrayerLocationService.instance.load();

      // Ask once, up front, so the first scheduling pass can succeed.
      if (!await NotificationService.areEnabled()) {
        await NotificationService.requestPermission();
      }

      NotificationPrefs.instance.addListener(resync);
      // A different city means different prayer times: reschedule the alerts.
      PrayerLocationService.instance.locationNotifier.addListener(resync);
      AppointmentReminderService.start();
      // Not awaited: fetching prayer times needs the network and must not hold
      // up whatever starts next (push setup shares the permission prompt).
      unawaited(resync());
    } catch (e) {
      debugPrint('NotificationCenter.start error: $e');
    }
  }

  /// Re-applies preferences to the scheduled prayer and appointment alerts.
  /// Overlapping calls are merged into one extra pass.
  static Future<void> resync() async {
    if (_syncing) {
      _again = true;
      return;
    }
    _syncing = true;
    try {
      do {
        _again = false;
        await PrayerNotificationService.schedulePrayerNotifications();
        await AppointmentReminderService.resync();
      } while (_again);
    } catch (e) {
      debugPrint('NotificationCenter.resync error: $e');
    } finally {
      _syncing = false;
    }
  }
}
