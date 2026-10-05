/// Pure scheduling helpers, kept free of plugins so they can be unit tested.
class NotificationSchedule {
  NotificationSchedule._();

  /// Shifts a daily clock time [leadMinutes] earlier, wrapping past midnight
  /// (e.g. 00:05 minus 10 minutes is 23:55).
  static ({int hour, int minute}) shiftEarlier(
    int hour,
    int minute,
    int leadMinutes,
  ) {
    final total = ((hour * 60 + minute - leadMinutes) % 1440 + 1440) % 1440;
    return (hour: total ~/ 60, minute: total % 60);
  }

  /// Parses "HH:mm" (24h). Returns null for anything else.
  static ({int hour, int minute})? parseClock(String value) {
    final parts = value.trim().split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null || h < 0 || h > 23 || m < 0 || m > 59) {
      return null;
    }
    return (hour: h, minute: m);
  }

  /// Notification id for an appointment reminder, stable for the same
  /// appointment so it can be re-scheduled or cancelled. Range 1000..99999.
  static int appointmentNotificationId(String appointmentId) {
    var hash = 0;
    for (final unit in appointmentId.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return 1000 + hash % 99000;
  }
}
