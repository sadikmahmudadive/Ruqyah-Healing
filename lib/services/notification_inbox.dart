import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InboxEntry {
  final String id;
  final String title;
  final String body;

  /// 'Appointments', 'Messages', 'Reminders' or 'Orders'.
  final String category;
  final DateTime receivedAt;
  final bool read;

  const InboxEntry({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.receivedAt,
    this.read = false,
  });

  InboxEntry asRead() => InboxEntry(
    id: id,
    title: title,
    body: body,
    category: category,
    receivedAt: receivedAt,
    read: true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'category': category,
    'at': receivedAt.millisecondsSinceEpoch,
    'read': read,
  };

  static InboxEntry? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['id'];
    final at = raw['at'];
    if (id is! String || at is! int) return null;
    return InboxEntry(
      id: id,
      title: raw['title'] as String? ?? '',
      body: raw['body'] as String? ?? '',
      category: raw['category'] as String? ?? 'Reminders',
      receivedAt: DateTime.fromMillisecondsSinceEpoch(at),
      read: raw['read'] as bool? ?? false,
    );
  }
}

/// The notification inbox shown in the app. Persisted so it survives restarts,
/// and usable from a background isolate (it only needs SharedPreferences).
class NotificationInbox extends ChangeNotifier {
  NotificationInbox._();

  static final NotificationInbox instance = NotificationInbox._();

  static const _key = 'notification_inbox_v1';
  static const int maxEntries = 100;

  List<InboxEntry> _entries = [];
  bool _loaded = false;

  /// Newest first.
  List<InboxEntry> get entries => List.unmodifiable(_entries);
  int get unreadCount => _entries.where((e) => !e.read).length;

  /// Reads from storage. [reload] also refreshes the SharedPreferences cache,
  /// needed when another isolate may have written (e.g. a background push).
  Future<void> load({bool reload = false}) async {
    final prefs = await SharedPreferences.getInstance();
    if (reload) await prefs.reload();
    final raw = prefs.getString(_key);
    final parsed = <InboxEntry>[];
    if (raw != null) {
      try {
        for (final item in jsonDecode(raw) as List) {
          final entry = InboxEntry.fromJson(item);
          if (entry != null) parsed.add(entry);
        }
      } catch (e) {
        debugPrint('NotificationInbox: ignoring unreadable data ($e)');
      }
    }
    _entries = parsed;
    _loaded = true;
    notifyListeners();
  }

  /// Adds an entry at the top. An id that is already present is ignored, so a
  /// push seen twice (foreground + opened) is stored once.
  Future<void> add(InboxEntry entry) async {
    if (!_loaded) await load(reload: true);
    if (_entries.any((e) => e.id == entry.id)) return;
    _entries = [entry, ..._entries];
    if (_entries.length > maxEntries) {
      _entries = _entries.sublist(0, maxEntries);
    }
    notifyListeners();
    await _save();
  }

  Future<void> markAllRead() async {
    if (unreadCount == 0) return;
    _entries = [for (final e in _entries) e.read ? e : e.asRead()];
    notifyListeners();
    await _save();
  }

  Future<void> clear() async {
    _entries = [];
    notifyListeners();
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode([for (final e in _entries) e.toJson()]),
    );
  }

  @visibleForTesting
  void resetForTest() {
    _entries = [];
    _loaded = false;
  }
}
