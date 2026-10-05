import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/prayer_location.dart';

/// Why the phone's location could not be used for auto-detection.
enum AutoLocationStatus {
  /// Not tried yet, or auto-detection is off.
  idle,
  detecting,
  detected,
  serviceOff,
  permissionDenied,

  /// Permission was refused for good; only system settings can undo it.
  permissionDeniedForever,
  failed,
}

/// Which place prayer times are for: either the phone's location (kept up to
/// date automatically while location is on) or a city the user picked.
class PrayerLocationService extends ChangeNotifier {
  // ignore: prefer_initializing_formals
  PrayerLocationService._({http.Client? client}) : _client = client;

  static final PrayerLocationService instance = PrayerLocationService._();

  @visibleForTesting
  factory PrayerLocationService.forTest({http.Client? client}) =>
      PrayerLocationService._(client: client);

  static const _kLocation = 'prayer_location_v1';
  static const _kAuto = 'prayer_location_auto';

  final http.Client? _client;
  late final http.Client _http = _client ?? http.Client();

  /// Fires only when the place itself changes, not on status changes. Prayer
  /// times and alerts listen to this.
  final ValueNotifier<PrayerLocation> locationNotifier = ValueNotifier(
    PrayerLocation.dhaka,
  );

  bool _autoDetect = true;
  AutoLocationStatus _status = AutoLocationStatus.idle;
  bool _loaded = false;
  bool _started = false;
  StreamSubscription<ServiceStatus>? _serviceSub;

  PrayerLocation get current => locationNotifier.value;
  bool get autoDetect => _autoDetect;
  AutoLocationStatus get status => _status;

  // ───────────────────────────── lifecycle ───────────────────────────

  Future<void> load() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _autoDetect = prefs.getBool(_kAuto) ?? true;
      final raw = prefs.getString(_kLocation);
      if (raw != null) {
        final saved = PrayerLocation.fromJson(jsonDecode(raw));
        if (saved != null) locationNotifier.value = saved;
      }
    } catch (e) {
      // Storage unavailable or unreadable: carry on with Dhaka + auto-detect.
      debugPrint('PrayerLocationService: using defaults ($e)');
    }
    _loaded = true;
    notifyListeners();
  }

  /// Loads the saved choice, then follows the phone's location service: when
  /// it is (or becomes) available, the place is updated automatically.
  Future<void> start() async {
    await load();
    if (_started) return;
    _started = true;
    try {
      _serviceSub = Geolocator.getServiceStatusStream().listen((s) {
        if (s == ServiceStatus.enabled) syncAuto();
      }, onError: (Object _) {});
    } catch (e) {
      debugPrint('PrayerLocationService: no service status stream ($e)');
    }
    await syncAuto(requestPermission: true);
  }

  // ───────────────────────────── choosing ────────────────────────────

  /// The user picked a place; stop following the phone.
  Future<void> selectManual(PrayerLocation place) async {
    _autoDetect = false;
    _status = AutoLocationStatus.idle;
    await _save(place);
    locationNotifier.value = place;
    notifyListeners();
  }

  /// Turn automatic detection on (or off, keeping the current place).
  Future<void> setAutoDetect(bool value) async {
    if (_autoDetect == value) return;
    _autoDetect = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAuto, value);
    if (value) {
      notifyListeners();
      await syncAuto(requestPermission: true);
    } else {
      _status = AutoLocationStatus.idle;
      notifyListeners();
    }
  }

  // ───────────────────────────── auto detect ─────────────────────────

  /// Reads the phone's location and updates the place. Does nothing when
  /// auto-detection is off. With [requestPermission] it may show the system
  /// permission dialog.
  Future<void> syncAuto({bool requestPermission = false}) async {
    if (!_autoDetect || _status == AutoLocationStatus.detecting) return;

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _setStatus(AutoLocationStatus.serviceOff);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied && requestPermission) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        _setStatus(AutoLocationStatus.permissionDeniedForever);
        return;
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.unableToDetermine) {
        _setStatus(AutoLocationStatus.permissionDenied);
        return;
      }

      _setStatus(AutoLocationStatus.detecting);
      // City-level accuracy is plenty for prayer times, and is faster and
      // lighter on battery than a precise fix.
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 12),
        ),
      );

      final place = await reverseGeocode(position.latitude, position.longitude);
      if (!_autoDetect) return; // the user switched to manual meanwhile
      if (!place.isSamePlaceAs(current) || place.city != current.city) {
        await _save(place);
        locationNotifier.value = place;
      }
      _setStatus(AutoLocationStatus.detected);
    } catch (e) {
      debugPrint('PrayerLocationService auto-detect failed: $e');
      _setStatus(AutoLocationStatus.failed);
    }
  }

  void _setStatus(AutoLocationStatus s) {
    if (_status == s) return;
    _status = s;
    notifyListeners();
  }

  Future<void> openLocationSettings() => Geolocator.openLocationSettings();
  Future<void> openAppSettings() => Geolocator.openAppSettings();

  Future<void> _save(PrayerLocation place) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kLocation, jsonEncode(place.toJson()));
      await prefs.setBool(_kAuto, _autoDetect);
    } catch (e) {
      debugPrint('PrayerLocationService: could not save ($e)');
    }
  }

  // ───────────────────────────── network ─────────────────────────────

  /// Names a coordinate (city + country) using BigDataCloud's client-side
  /// reverse geocoder. If naming fails the coordinates still work for prayer
  /// times, so fall back to a generic name rather than failing.
  Future<PrayerLocation> reverseGeocode(double lat, double lon) async {
    try {
      final uri = Uri.https(
        'api.bigdatacloud.net',
        '/data/reverse-geocode-client',
        {
          'latitude': '$lat',
          'longitude': '$lon',
          'localityLanguage': 'en',
        },
      );
      final response = await _http.get(uri).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final parsed = parseReverseGeocode(
          jsonDecode(response.body),
          lat,
          lon,
        );
        if (parsed != null) return parsed;
      }
    } catch (e) {
      debugPrint('Reverse geocoding failed: $e');
    }
    return PrayerLocation(
      city: 'Current location',
      countryCode: '',
      latitude: lat,
      longitude: lon,
    );
  }

  @visibleForTesting
  static PrayerLocation? parseReverseGeocode(
    Object? json,
    double lat,
    double lon,
  ) {
    if (json is! Map) return null;
    String? pick(List<String> keys) {
      for (final k in keys) {
        final v = json[k];
        if (v is String && v.trim().isNotEmpty) return v.trim();
      }
      return null;
    }

    final city = pick(['city', 'locality', 'principalSubdivision']);
    if (city == null) return null;
    return PrayerLocation(
      city: city,
      countryCode: (json['countryCode'] as String? ?? '').toUpperCase(),
      latitude: lat,
      longitude: lon,
    );
  }

  /// Finds places by name (Open-Meteo's free geocoding API).
  Future<List<PrayerLocation>> searchPlaces(String query) async {
    final q = query.trim();
    if (q.length < 2) return const [];
    try {
      final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
        'name': q,
        'count': '8',
        'language': 'en',
        'format': 'json',
      });
      final response = await _http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return const [];
      return parseSearch(jsonDecode(response.body));
    } catch (e) {
      debugPrint('Place search failed: $e');
      return const [];
    }
  }

  @visibleForTesting
  static List<PrayerLocation> parseSearch(Object? json) {
    if (json is! Map || json['results'] is! List) return const [];
    final out = <PrayerLocation>[];
    for (final r in json['results'] as List) {
      if (r is! Map) continue;
      final name = r['name'];
      final lat = r['latitude'];
      final lon = r['longitude'];
      if (name is! String || lat is! num || lon is! num) continue;
      out.add(
        PrayerLocation(
          city: name,
          countryCode: (r['country_code'] as String? ?? '').toUpperCase(),
          latitude: lat.toDouble(),
          longitude: lon.toDouble(),
        ),
      );
    }
    return out;
  }

  @override
  void dispose() {
    _serviceSub?.cancel();
    locationNotifier.dispose();
    super.dispose();
  }
}
