import 'package:flutter/foundation.dart';

import 'notification_prefs.dart';
import 'notification_schedule.dart';
import 'notification_service.dart';
import 'prayer_times_service.dart';

/// Daily prayer-time alerts. Each prayer is one repeating daily alarm, so it
/// keeps firing even if the app isn't opened; it is refreshed with the latest
/// times whenever the app starts, the user pulls to refresh, or a preference
/// changes.
class PrayerNotificationService {
  PrayerNotificationService._();

  /// Fixed ids so re-scheduling replaces rather than duplicates.
  static const Map<String, int> _ids = {
    'Fajr': 1,
    'Dhuhr': 2,
    'Asr': 3,
    'Maghrib': 4,
    'Isha': 5,
  };

  static Future<void> initialize() => NotificationService.initialize();

  /// Fetches today's times and (re)schedules the five prayer alerts, or
  /// cancels them when the user turned them off or the OS blocks them.
  static Future<void> schedulePrayerNotifications() async {
    try {
      await NotificationService.initialize();
      final prefs = NotificationPrefs.instance;

      if (!prefs.prayerEnabled || !await NotificationService.areEnabled()) {
        await NotificationService.cancelAll(_ids.values);
        return;
      }

      final times = await PrayerTimesService.fetchPrayerTimes();
      NotificationService.setTimeZone(times.timezone);
      final byName = {
        'Fajr': times.fajr24,
        'Dhuhr': times.dhuhr24,
        'Asr': times.asr24,
        'Maghrib': times.maghrib24,
        'Isha': times.isha24,
      };

      for (final entry in byName.entries) {
        await _scheduleOne(entry.key, entry.value, prefs.prayerLeadMinutes);
      }
    } catch (e) {
      debugPrint('Error scheduling prayer notifications: $e');
    }
  }

  static Future<void> _scheduleOne(
    String prayer,
    String time24,
    int leadMinutes,
  ) async {
    final clock = NotificationSchedule.parseClock(time24);
    if (clock == null) return;

    final at = NotificationSchedule.shiftEarlier(
      clock.hour,
      clock.minute,
      leadMinutes,
    );

    await NotificationService.schedule(
      id: _ids[prayer]!,
      title: leadMinutes == 0
          ? 'Prayer Time: $prayer'
          : '$prayer in $leadMinutes minutes',
      body: leadMinutes == 0
          ? "It's time for $prayer prayer. May Allah accept your worship and prayers."
          : 'Time to prepare for $prayer prayer.',
      when: NotificationService.nextDaily(at.hour, at.minute),
      channel: AppNotificationChannel.prayer,
      payload: 'prayer:$prayer',
      repeatDaily: true,
    );
  }
}
