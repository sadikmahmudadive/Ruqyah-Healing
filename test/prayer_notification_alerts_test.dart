import 'package:flutter_test/flutter_test.dart';
import 'package:ruqyahhealing/services/notification_prefs.dart';
import 'package:ruqyahhealing/services/prayer_notification_service.dart';
import 'package:ruqyahhealing/services/prayer_times_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final times = PrayerTimesModel.fallback();

  test('every prayer gets an alert: five fard plus three voluntary', () {
    final alerts = PrayerNotificationService.alertsFor(times);
    expect(alerts.map((a) => a.name), [
      'Fajr',
      'Dhuhr',
      'Asr',
      'Maghrib',
      'Isha',
      'Tahajjud',
      'Ishraq',
      'Chast (Duha)',
    ]);
    // Distinct, stable ids, so re-scheduling replaces rather than duplicates.
    final ids = alerts.map((a) => a.id).toList();
    expect(ids.toSet().length, 8);
    expect(ids, [1, 2, 3, 4, 5, 6, 7, 8]);
  });

  test('voluntary alerts can be left out', () {
    final alerts = PrayerNotificationService.alertsFor(
      times,
      includeVoluntary: false,
    );
    expect(alerts.length, 5);
  });

  test('fard alerts fire at the prayer time', () {
    final fajr = PrayerNotificationService.alertsFor(times).first;
    expect((fajr.hour, fajr.minute), (4, 5));
    final dhuhr = PrayerNotificationService.alertsFor(times)[1];
    expect((dhuhr.hour, dhuhr.minute), (12, 30));
  });

  test('a lead time moves every alert earlier and changes the wording', () {
    final alerts = PrayerNotificationService.alertsFor(times, leadMinutes: 10);
    final fajr = alerts.first;
    expect((fajr.hour, fajr.minute), (3, 55));
    expect(fajr.title, 'Fajr in 10 minutes');
    expect(alerts.every((a) => a.title.endsWith('in 10 minutes')), isTrue);
  });

  test('an alert before midnight wraps to the day before', () {
    final alerts = PrayerNotificationService.alertsFor(times, leadMinutes: 15);
    for (final a in alerts) {
      expect(a.hour, inInclusiveRange(0, 23));
      expect(a.minute, inInclusiveRange(0, 59));
    }
  });

  test('the voluntary-prayer switch persists and defaults to on', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = NotificationPrefs.instance;
    await prefs.load();
    expect(prefs.voluntaryPrayersEnabled, isTrue);

    await prefs.setVoluntaryPrayersEnabled(false);
    await prefs.load();
    expect(prefs.voluntaryPrayersEnabled, isFalse);

    await prefs.setVoluntaryPrayersEnabled(true);
  });
}
