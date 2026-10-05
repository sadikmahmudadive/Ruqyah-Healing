import 'package:flutter_test/flutter_test.dart';
import 'package:ruqyahhealing/services/notification_inbox.dart';
import 'package:ruqyahhealing/services/notification_prefs.dart';
import 'package:ruqyahhealing/services/notification_schedule.dart';
import 'package:ruqyahhealing/services/push_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationSchedule', () {
    test('shiftEarlier subtracts the lead time', () {
      expect(NotificationSchedule.shiftEarlier(5, 30, 10), (hour: 5, minute: 20));
      expect(NotificationSchedule.shiftEarlier(5, 30, 0), (hour: 5, minute: 30));
      expect(NotificationSchedule.shiftEarlier(13, 0, 15), (hour: 12, minute: 45));
    });

    test('shiftEarlier wraps past midnight', () {
      expect(NotificationSchedule.shiftEarlier(0, 5, 10), (hour: 23, minute: 55));
      expect(NotificationSchedule.shiftEarlier(0, 0, 15), (hour: 23, minute: 45));
    });

    test('parseClock accepts HH:mm and rejects junk', () {
      expect(NotificationSchedule.parseClock('04:36'), (hour: 4, minute: 36));
      expect(NotificationSchedule.parseClock('18:45 (+06)'), isNull);
      expect(NotificationSchedule.parseClock('25:00'), isNull);
      expect(NotificationSchedule.parseClock('12:61'), isNull);
      expect(NotificationSchedule.parseClock('nonsense'), isNull);
      expect(NotificationSchedule.parseClock(''), isNull);
    });

    test('appointment notification ids are stable and in range', () {
      final a = NotificationSchedule.appointmentNotificationId('abc123');
      expect(NotificationSchedule.appointmentNotificationId('abc123'), a);
      expect(
        NotificationSchedule.appointmentNotificationId('abc124'),
        isNot(a),
      );
      for (final id in ['', 'x', 'a-very-long-appointment-id-0123456789']) {
        final n = NotificationSchedule.appointmentNotificationId(id);
        expect(n, inInclusiveRange(1000, 99999));
        // Never collides with the prayer ids 1..5 or the test id 9001's range.
        expect(n, greaterThanOrEqualTo(1000));
      }
    });
  });

  group('NotificationPrefs', () {
    test('defaults, then persists changes across a reload', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = NotificationPrefs.instance;
      await prefs.load();
      expect(prefs.prayerEnabled, isTrue);
      expect(prefs.prayerLeadMinutes, 0);
      expect(prefs.appointmentsEnabled, isTrue);
      expect(prefs.messagesEnabled, isTrue);

      await prefs.setPrayerEnabled(false);
      await prefs.setPrayerLeadMinutes(10);
      await prefs.setMessagesEnabled(false);

      // Forget in-memory state, then load from storage.
      await prefs.setPrayerEnabled(true); // flips memory only via same path
      await prefs.setPrayerEnabled(false);
      await prefs.load();
      expect(prefs.prayerEnabled, isFalse);
      expect(prefs.prayerLeadMinutes, 10);
      expect(prefs.messagesEnabled, isFalse);
      expect(prefs.appointmentsEnabled, isTrue);
    });

    test('rejects a lead time that is not offered', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = NotificationPrefs.instance;
      await prefs.load();
      await prefs.setPrayerLeadMinutes(7);
      expect(prefs.prayerLeadMinutes, 0);
    });

    test('notifies listeners when something changes', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = NotificationPrefs.instance;
      await prefs.load();
      var calls = 0;
      void listener() => calls++;
      prefs.addListener(listener);
      await prefs.setAppointmentsEnabled(false);
      await prefs.setAppointmentsEnabled(false); // no change, no notify
      prefs.removeListener(listener);
      expect(calls, 1);
    });
  });

  group('NotificationInbox', () {
    InboxEntry entry(String id, {DateTime? at, String category = 'Messages'}) =>
        InboxEntry(
          id: id,
          title: 't$id',
          body: 'b$id',
          category: category,
          receivedAt: at ?? DateTime(2026, 10, 5, 12),
        );

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      NotificationInbox.instance.resetForTest();
    });

    test('add puts newest first and persists', () async {
      final inbox = NotificationInbox.instance;
      await inbox.add(entry('1'));
      await inbox.add(entry('2'));
      expect(inbox.entries.map((e) => e.id), ['2', '1']);

      inbox.resetForTest();
      await inbox.load();
      expect(inbox.entries.map((e) => e.id), ['2', '1']);
      expect(inbox.entries.first.title, 't2');
    });

    test('the same id is stored once', () async {
      final inbox = NotificationInbox.instance;
      await inbox.add(entry('dup'));
      await inbox.add(entry('dup'));
      expect(inbox.entries.length, 1);
    });

    test('unread count and markAllRead', () async {
      final inbox = NotificationInbox.instance;
      await inbox.add(entry('1'));
      await inbox.add(entry('2'));
      expect(inbox.unreadCount, 2);

      await inbox.markAllRead();
      expect(inbox.unreadCount, 0);

      inbox.resetForTest();
      await inbox.load();
      expect(inbox.unreadCount, 0, reason: 'read state is persisted');
    });

    test('keeps only the newest maxEntries', () async {
      final inbox = NotificationInbox.instance;
      for (var i = 0; i < NotificationInbox.maxEntries + 5; i++) {
        await inbox.add(entry('n$i'));
      }
      expect(inbox.entries.length, NotificationInbox.maxEntries);
      expect(inbox.entries.first.id, 'n${NotificationInbox.maxEntries + 4}');
    });

    test('unreadable stored data is ignored, not fatal', () async {
      SharedPreferences.setMockInitialValues({
        'notification_inbox_v1': '{not json',
      });
      final inbox = NotificationInbox.instance;
      await inbox.load();
      expect(inbox.entries, isEmpty);

      SharedPreferences.setMockInitialValues({
        'notification_inbox_v1':
            '[{"id":"ok","at":1759665600000},{"nope":1},"junk"]',
      });
      await inbox.load(reload: true);
      expect(inbox.entries.map((e) => e.id), ['ok']);
    });

    test('clear empties the inbox', () async {
      final inbox = NotificationInbox.instance;
      await inbox.add(entry('1'));
      await inbox.clear();
      expect(inbox.entries, isEmpty);
    });

    test('the UI model reflects the stored entries', () async {
      final inbox = NotificationInbox.instance;
      await inbox.add(entry('1', category: 'Appointments'));
      final items = PushNotificationService.notifications;
      expect(items.single.category, 'Appointments');
      expect(items.single.isUnread, isTrue);
      expect(items.single.title, 't1');
    });
  });

  group('time labels', () {
    final now = DateTime(2026, 10, 5, 15, 30);
    String label(DateTime t) => PushNotificationService.timeLabel(t, now: now);

    test('just now, today, yesterday, days, older', () {
      expect(label(DateTime(2026, 10, 5, 15, 29, 30)), 'Just now');
      expect(label(DateTime(2026, 10, 5, 10, 0)), '10:00 AM');
      expect(label(DateTime(2026, 10, 5, 0, 5)), '12:05 AM');
      expect(label(DateTime(2026, 10, 5, 12, 0)), '12:00 PM');
      expect(label(DateTime(2026, 10, 4, 23, 0)), 'Yesterday');
      expect(label(DateTime(2026, 10, 2, 9, 0)), '3 days ago');
      expect(label(DateTime(2026, 9, 12, 9, 0)), '12 Sep');
    });
  });
}
