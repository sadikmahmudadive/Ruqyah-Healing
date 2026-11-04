import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;

import '../models/wallpaper_model.dart';

enum WallpaperSaveResult { saved, permissionDenied, failed }

/// Saves a wallpaper to the phone's gallery. The two steps (fetching the
/// bytes and writing to the gallery) are passed in, so tests can run without
/// a network or a phone.
class WallpaperDownloader {
  final Future<Uint8List> Function(String url) fetch;
  final Future<bool> Function() ensureAccess;
  final Future<void> Function(Uint8List bytes, String name) save;

  const WallpaperDownloader({
    this.fetch = _fetchBytes,
    this.ensureAccess = _ensureGalleryAccess,
    this.save = _saveToGallery,
  });

  /// Downloads [w]'s full-size image into the gallery.
  Future<WallpaperSaveResult> download(WallpaperModel w) async {
    try {
      if (!await ensureAccess()) return WallpaperSaveResult.permissionDenied;
      final bytes = await fetch(w.imageUrl);
      if (bytes.isEmpty) return WallpaperSaveResult.failed;
      await save(bytes, w.fileName);
      return WallpaperSaveResult.saved;
    } catch (e) {
      debugPrint('Wallpaper download failed: $e');
      return WallpaperSaveResult.failed;
    }
  }

  static Future<Uint8List> _fetchBytes(String url) async {
    final res = await http
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 30));
    if (res.statusCode != 200) {
      throw http.ClientException('HTTP ${res.statusCode}', Uri.parse(url));
    }
    return res.bodyBytes;
  }

  static Future<bool> _ensureGalleryAccess() async {
    if (await Gal.hasAccess()) return true;
    return Gal.requestAccess();
  }

  static Future<void> _saveToGallery(Uint8List bytes, String name) =>
      Gal.putImageBytes(bytes, name: name);
}
