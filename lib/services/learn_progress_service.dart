import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Remembers, on this phone only, which free Learn lessons the user has
/// finished and which one they opened last. Nothing leaves the device.
///
/// Preference errors are logged and swallowed: progress is a convenience, so
/// a storage failure must never break reading a lesson.
class LearnProgressService extends ChangeNotifier {
  LearnProgressService();

  static final LearnProgressService instance = LearnProgressService();

  static const _kDone = 'learn_done';
  static const _kLast = 'learn_last';

  final Set<String> _done = <String>{};

  /// The lesson opened most recently, or null if none yet.
  String? lastOpenedId;

  /// Ids of every lesson marked done.
  Set<String> get doneIds => Set.unmodifiable(_done);

  bool isDone(String lessonId) => _done.contains(lessonId);

  /// Loads saved progress. Safe to call more than once.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      _done
        ..clear()
        ..addAll(prefs.getStringList(_kDone) ?? const <String>[]);
      lastOpenedId = prefs.getString(_kLast);
    } catch (e) {
      debugPrint('LearnProgressService.load failed: $e');
    }
    notifyListeners();
  }

  Future<void> setDone(String lessonId, bool done) async {
    final changed = done ? _done.add(lessonId) : _done.remove(lessonId);
    if (!changed) return;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_kDone, _done.toList());
    } catch (e) {
      debugPrint('LearnProgressService.setDone failed: $e');
    }
  }

  Future<void> setLastOpened(String lessonId) async {
    if (lastOpenedId == lessonId) return;
    lastOpenedId = lessonId;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kLast, lessonId);
    } catch (e) {
      debugPrint('LearnProgressService.setLastOpened failed: $e');
    }
  }
}
