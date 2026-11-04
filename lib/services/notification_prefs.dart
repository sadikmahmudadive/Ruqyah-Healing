import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// What the user wants to be notified about. Persisted, and observable so
/// schedulers can react when a switch changes.
class NotificationPrefs extends ChangeNotifier {
  NotificationPrefs._();

  static final NotificationPrefs instance = NotificationPrefs._();

  static const _kPrayer = 'notif_prayer';
  static const _kPrayerLead = 'notif_prayer_lead_min';
  static const _kNafl = 'notif_prayer_nafl';
  static const _kAppointments = 'notif_appointments';
  static const _kMessages = 'notif_messages';

  /// Lead times offered for prayer reminders (minutes before the prayer).
  static const List<int> leadOptions = [0, 5, 10, 15];

  bool _prayer = true;
  bool _nafl = true;
  int _prayerLeadMinutes = 0;
  bool _appointments = true;
  bool _messages = true;
  bool _loaded = false;

  bool get prayerEnabled => _prayer;
  int get prayerLeadMinutes => _prayerLeadMinutes;

  /// Alerts for the voluntary prayers (Tahajjud, Ishraq, Chast), on top of
  /// the five fard prayers.
  bool get voluntaryPrayersEnabled => _nafl;
  bool get appointmentsEnabled => _appointments;
  bool get messagesEnabled => _messages;

  /// Loads saved values. Safe to call more than once.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload(); // a background isolate may have written since
    _prayer = prefs.getBool(_kPrayer) ?? true;
    _prayerLeadMinutes = prefs.getInt(_kPrayerLead) ?? 0;
    _nafl = prefs.getBool(_kNafl) ?? true;
    _appointments = prefs.getBool(_kAppointments) ?? true;
    _messages = prefs.getBool(_kMessages) ?? true;
    _loaded = true;
    notifyListeners();
  }

  Future<void> setPrayerEnabled(bool value) =>
      _set(_kPrayer, value, () => _prayer = value, _prayer != value);

  Future<void> setVoluntaryPrayersEnabled(bool value) =>
      _set(_kNafl, value, () => _nafl = value, _nafl != value);

  Future<void> setAppointmentsEnabled(bool value) => _set(
    _kAppointments,
    value,
    () => _appointments = value,
    _appointments != value,
  );

  Future<void> setMessagesEnabled(bool value) =>
      _set(_kMessages, value, () => _messages = value, _messages != value);

  Future<void> setPrayerLeadMinutes(int minutes) async {
    if (!leadOptions.contains(minutes) || minutes == _prayerLeadMinutes) return;
    _prayerLeadMinutes = minutes;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kPrayerLead, minutes);
  }

  Future<void> _set(
    String key,
    bool value,
    VoidCallback apply,
    bool changed,
  ) async {
    if (!changed) return;
    apply();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @visibleForTesting
  bool get isLoaded => _loaded;
}
