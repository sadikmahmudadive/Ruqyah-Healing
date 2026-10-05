import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/appointment_model.dart';
import 'firebase_service.dart';
import 'notification_prefs.dart';
import 'notification_schedule.dart';
import 'notification_service.dart';

/// Reminds the signed-in user one hour before each booked session.
///
/// Follows the user's appointments live: new bookings get a reminder,
/// cancelled or moved ones lose or change it, and signing out clears them.
class AppointmentReminderService {
  AppointmentReminderService._();

  static const _kScheduledIds = 'appointment_reminder_ids';
  static const Duration leadTime = Duration(hours: 1);

  static StreamSubscription<dynamic>? _authSub;
  static StreamSubscription<List<AppointmentModel>>? _appointmentSub;
  static List<AppointmentModel> _appointments = const [];
  static bool _started = false;

  static void start() {
    if (_started) return;
    _started = true;
    try {
      _authSub = FirebaseService.authStateChanges.listen((user) {
        _appointmentSub?.cancel();
        _appointments = const [];
        if (user == null) {
          resync(); // signed out: remove this user's reminders
          return;
        }
        _appointmentSub = FirebaseService.getPatientAppointments(user.uid)
            .listen((list) {
              _appointments = list;
              resync();
            }, onError: (Object e) => debugPrint('Reminder stream: $e'));
      }, onError: (Object e) => debugPrint('Reminder auth stream: $e'));
    } catch (e) {
      debugPrint('AppointmentReminderService start error: $e');
    }
  }

  static bool _syncing = false;
  static bool _resyncAgain = false;

  /// Makes the scheduled reminders match the current appointments. Calls that
  /// arrive mid-sync are coalesced into one follow-up pass.
  static Future<void> resync() async {
    if (_syncing) {
      _resyncAgain = true;
      return;
    }
    _syncing = true;
    try {
      do {
        _resyncAgain = false;
        await _sync();
      } while (_resyncAgain);
    } catch (e) {
      debugPrint('AppointmentReminderService sync error: $e');
    } finally {
      _syncing = false;
    }
  }

  static Future<void> _sync() async {
    final store = await SharedPreferences.getInstance();
    final previous = [
      for (final s in store.getStringList(_kScheduledIds) ?? const <String>[])
        ?int.tryParse(s),
    ];

    final wanted = <int>{};
    final enabled =
        NotificationPrefs.instance.appointmentsEnabled &&
        await NotificationService.areEnabled();

    if (enabled) {
      final now = DateTime.now();
      for (final a in _appointments) {
        if (a.status != 'scheduled') continue;
        final remindAt = a.scheduledTime.subtract(leadTime);
        if (!remindAt.isAfter(now)) continue;

        final id = NotificationSchedule.appointmentNotificationId(
          a.appointmentId,
        );
        wanted.add(id);
        await NotificationService.schedule(
          id: id,
          title: 'Your session starts in 1 hour',
          body:
              '${a.therapyType.replaceAll('_', ' ')} at ${_clock(a.scheduledTime)}.',
          when: tz.TZDateTime.from(remindAt, tz.local),
          channel: AppNotificationChannel.appointments,
          payload: 'appointment:${a.appointmentId}',
        );
      }
    }

    // Drop reminders for appointments that are gone, cancelled or past.
    await NotificationService.cancelAll(
      previous.where((id) => !wanted.contains(id)),
    );
    await store.setStringList(_kScheduledIds, [
      for (final id in wanted) '$id',
    ]);
  }

  static String _clock(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m ${t.hour >= 12 ? 'PM' : 'AM'}';
  }

  @visibleForTesting
  static Future<void> stop() async {
    await _authSub?.cancel();
    await _appointmentSub?.cancel();
    _started = false;
  }
}
