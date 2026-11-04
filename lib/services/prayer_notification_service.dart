import 'package:flutter/foundation.dart';

import 'notification_prefs.dart';
import 'notification_schedule.dart';
import 'notification_service.dart';
import 'prayer_times_service.dart';
import 'salah_schedule.dart';

/// One alert to schedule: what to say and the daily clock time to say it.
class PrayerAlert {
  final int id;
  final String name;
  final String title;
  final String body;
  final int hour;
  final int minute;

  const PrayerAlert({
    required this.id,
    required this.name,
    required this.title,
    required this.body,
    required this.hour,
    required this.minute,
  });
}

/// Daily prayer-time alerts for every prayer on the Daily Salah screen: the
/// five fard prayers and the voluntary Tahajjud, Ishraq and Chast. Each is one
/// repeating daily alarm, so it keeps firing even if the app isn't opened; it
/// is refreshed with the latest times whenever the app starts, the user pulls
/// to refresh, or a preference changes.
class PrayerNotificationService {
  PrayerNotificationService._();

  /// Fixed ids so re-scheduling replaces rather than duplicates.
  static const Map<String, int> _fardIds = {
    'fajr': 1,
    'dhuhr': 2,
    'asr': 3,
    'maghrib': 4,
    'isha': 5,
  };
  static const Map<String, int> _voluntaryIds = {
    'tahajjud': 6,
    'ishraq': 7,
    'chast': 8,
  };

  static Iterable<int> get _allIds => [
    ..._fardIds.values,
    ..._voluntaryIds.values,
  ];

  // The alert repeats daily, so the fard prayers keep their plain names
  // rather than "Jumu'ah", which only fits on Fridays.
  static const Map<String, String> _fardNames = {
    'fajr': 'Fajr',
    'dhuhr': 'Dhuhr',
    'asr': 'Asr',
    'maghrib': 'Maghrib',
    'isha': 'Isha',
  };

  static const Map<String, String> _voluntaryBody = {
    'tahajjud':
        'The last third of the night has begun, a quiet hour for prayer and dua.',
    'ishraq': 'The sun has risen. A good time for two rakat of Ishraq.',
    'chast': 'The morning is well under way. A good time for Chast (Duha).',
  };

  static Future<void> initialize() => NotificationService.initialize();

  /// The alerts for a day's [times], earlier by [leadMinutes]. Pure, so it can
  /// be tested without the notification plugin.
  static List<PrayerAlert> alertsFor(
    PrayerTimesModel times, {
    int leadMinutes = 0,
    bool includeVoluntary = true,
  }) {
    final schedule = SalahSchedule.from(
      times,
      date: PrayerTimesService.nowAt(times.timezone),
    );

    final out = <PrayerAlert>[];
    void add(int id, String name, String body, int startMinutes) {
      final at = NotificationSchedule.shiftEarlier(
        startMinutes ~/ 60,
        startMinutes % 60,
        leadMinutes,
      );
      out.add(
        PrayerAlert(
          id: id,
          name: name,
          title: leadMinutes == 0
              ? 'Prayer Time: $name'
              : '$name in $leadMinutes minutes',
          body: leadMinutes == 0 ? body : 'Time to prepare for $name prayer.',
          hour: at.hour,
          minute: at.minute,
        ),
      );
    }

    for (final e in schedule.fard) {
      final id = _fardIds[e.id];
      final name = _fardNames[e.id];
      if (id == null || name == null) continue;
      add(
        id,
        name,
        "It's time for $name prayer. May Allah accept your worship and prayers.",
        e.start,
      );
    }

    if (includeVoluntary) {
      for (final e in schedule.nafl) {
        final id = _voluntaryIds[e.id];
        if (id == null) continue;
        add(id, e.name, _voluntaryBody[e.id] ?? '', e.start);
      }
    }
    return out;
  }

  /// Fetches today's times and (re)schedules every prayer alert, or cancels
  /// them when the user turned them off or the OS blocks them.
  static Future<void> schedulePrayerNotifications() async {
    try {
      await NotificationService.initialize();
      final prefs = NotificationPrefs.instance;

      if (!prefs.prayerEnabled || !await NotificationService.areEnabled()) {
        await NotificationService.cancelAll(_allIds);
        return;
      }

      final times = await PrayerTimesService.fetchPrayerTimes();
      NotificationService.setTimeZone(times.timezone);

      final alerts = alertsFor(
        times,
        leadMinutes: prefs.prayerLeadMinutes,
        includeVoluntary: prefs.voluntaryPrayersEnabled,
      );
      for (final a in alerts) {
        await NotificationService.schedule(
          id: a.id,
          title: a.title,
          body: a.body,
          when: NotificationService.nextDaily(a.hour, a.minute),
          channel: AppNotificationChannel.prayer,
          payload: 'prayer:${a.name}',
          repeatDaily: true,
        );
      }

      if (!prefs.voluntaryPrayersEnabled) {
        await NotificationService.cancelAll(_voluntaryIds.values);
      }
    } catch (e) {
      debugPrint('Error scheduling prayer notifications: $e');
    }
  }
}
