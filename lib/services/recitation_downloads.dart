import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show MissingPluginException;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../models/recitation.dart';

/// Keeps a recitation's audio on the phone so it plays offline.
///
/// Each ayah is one MP3, saved under the app's documents folder. The player
/// asks [localPath] for every ayah when it loads and plays the saved file when
/// there is one, so a downloaded recitation needs no connection.
class RecitationDownloads {
  /// [folder] and [client] can be replaced, which lets tests run without a
  /// phone or a network.
  RecitationDownloads({
    Future<Directory> Function()? folder,
    // ignore: prefer_initializing_formals
    http.Client? client,
  }) : _folder = folder ?? _defaultFolder,
       _client = client;

  /// The app-wide store. Tests replace it to use a temporary folder.
  static RecitationDownloads instance = RecitationDownloads();

  final Future<Directory> Function() _folder;
  final http.Client? _client;

  static Future<Directory> _defaultFolder() async {
    final base = await getApplicationDocumentsDirectory();
    return Directory('${base.path}${Platform.pathSeparator}recitations');
  }

  Future<Directory> _dir() async {
    final d = await _folder();
    if (!await d.exists()) await d.create(recursive: true);
    return d;
  }

  /// A short, file-system-safe name for [url] (FNV-1a hash).
  @visibleForTesting
  static String fileNameFor(String url) {
    var h = 0xcbf29ce484222325;
    for (final unit in url.codeUnits) {
      h ^= unit;
      h = (h * 0x100000001b3) & 0x7fffffffffffffff;
    }
    return '${h.toRadixString(16)}.mp3';
  }

  Future<File> _fileFor(String url) async {
    final d = await _dir();
    return File('${d.path}${Platform.pathSeparator}${fileNameFor(url)}');
  }

  /// The saved file for [url], or null when it has not been downloaded (or
  /// storage is not available, e.g. on the web or in a test).
  Future<String?> localPath(String url) async {
    if (kIsWeb || url.isEmpty) return null;
    try {
      final f = await _fileFor(url);
      if (await f.exists() && await f.length() > 0) return f.path;
    } on MissingPluginException {
      // No storage plugin (a test, or a dev build without it): stream instead.
    } catch (e) {
      debugPrint('RecitationDownloads.localPath: $e');
    }
    return null;
  }

  static List<String> _urls(RecitationContent c) => {
    for (final a in c.ayahs)
      if (a.playbackUrl.isNotEmpty) a.playbackUrl,
  }.toList();

  /// How many of the recitation's audio files are saved.
  Future<({int saved, int total})> status(RecitationContent c) async {
    final urls = _urls(c);
    var saved = 0;
    for (final u in urls) {
      if (await localPath(u) != null) saved++;
    }
    return (saved: saved, total: urls.length);
  }

  Future<bool> isDownloaded(RecitationContent c) async {
    final s = await status(c);
    return s.total > 0 && s.saved == s.total;
  }

  /// Saves every ayah of [c] that is not saved yet, reporting how many are
  /// done. Throws if any file cannot be fetched; files already saved are kept,
  /// so trying again carries on where it stopped.
  Future<void> download(
    RecitationContent c, {
    void Function(int done, int total)? onProgress,
  }) async {
    final urls = _urls(c);
    final client = _client ?? http.Client();
    try {
      for (var i = 0; i < urls.length; i++) {
        if (await localPath(urls[i]) == null) {
          final res = await client
              .get(Uri.parse(urls[i]))
              .timeout(const Duration(seconds: 45));
          if (res.statusCode != 200 || res.bodyBytes.isEmpty) {
            throw HttpException(
              'HTTP ${res.statusCode}',
              uri: Uri.parse(urls[i]),
            );
          }
          final file = await _fileFor(urls[i]);
          // Write beside, then rename, so a half-written file is never played.
          final part = File('${file.path}.part');
          await part.writeAsBytes(res.bodyBytes, flush: true);
          await part.rename(file.path);
        }
        onProgress?.call(i + 1, urls.length);
      }
    } finally {
      if (_client == null) client.close();
    }
  }

  /// Deletes the saved audio of [c].
  Future<void> remove(RecitationContent c) async {
    for (final u in _urls(c)) {
      try {
        final f = await _fileFor(u);
        if (await f.exists()) await f.delete();
      } catch (e) {
        debugPrint('RecitationDownloads.remove: $e');
      }
    }
  }
}
