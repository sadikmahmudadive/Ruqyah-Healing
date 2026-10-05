import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/prayer_location.dart';
import 'prayer_location_service.dart';

class PrayerTimesModel {
  final String fajr;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String jummah;
  final String fajr24;
  final String dhuhr24;
  final String asr24;
  final String maghrib24;
  final String isha24;

  /// IANA zone of the place these times are for (e.g. "Asia/Dhaka"). The
  /// times are local clock times in that zone.
  final String timezone;

  const PrayerTimesModel({
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.jummah,
    required this.fajr24,
    required this.dhuhr24,
    required this.asr24,
    required this.maghrib24,
    required this.isha24,
    this.timezone = 'Asia/Dhaka',
  });

  factory PrayerTimesModel.fallback() {
    return const PrayerTimesModel(
      fajr: '4:05',
      dhuhr: '12:30',
      asr: '4:45',
      maghrib: '6:45',
      isha: '8:15',
      jummah: '1:30',
      fajr24: '04:05',
      dhuhr24: '12:30',
      asr24: '16:45',
      maghrib24: '18:45',
      isha24: '20:15',
    );
  }
}

class PrayerTimesService {
  /// Countries whose authorities use the University of Islamic Sciences,
  /// Karachi method. Elsewhere the API picks the method for the location.
  static const _karachiMethodCountries = {'BD', 'PK', 'IN', 'AF'};

  @visibleForTesting
  static Uri buildUri(PrayerLocation location) {
    return Uri.https('api.aladhan.com', '/v1/timings', {
      'latitude': '${location.latitude}',
      'longitude': '${location.longitude}',
      if (_karachiMethodCountries.contains(location.countryCode)) 'method': '1',
    });
  }

  /// Prayer times for [location], or for the user's chosen place when omitted.
  static Future<PrayerTimesModel> fetchPrayerTimes({
    PrayerLocation? location,
    http.Client? client,
  }) async {
    final place = location ?? PrayerLocationService.instance.current;
    final http_ = client ?? http.Client();
    try {
      final response = await http_
          .get(buildUri(place))
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final parsed = parseResponse(json.decode(response.body));
        if (parsed != null) return parsed;
      }
    } catch (e) {
      debugPrint('Error fetching prayer times from API: $e');
    } finally {
      if (client == null) http_.close();
    }
    return PrayerTimesModel.fallback();
  }

  @visibleForTesting
  static PrayerTimesModel? parseResponse(Object? body) {
    if (body is! Map || body['data'] is! Map) return null;
    final data = body['data'] as Map;
    final timings = data['timings'];
    if (timings is! Map) return null;

    String t(String key, String fallback) =>
        _cleanTime24((timings[key] as String?) ?? fallback);

    final rawFajr = t('Fajr', '04:05');
    final rawDhuhr = t('Dhuhr', '12:30');
    final rawAsr = t('Asr', '16:45');
    final rawMaghrib = t('Maghrib', '18:45');
    final rawIsha = t('Isha', '20:15');

    final meta = data['meta'];
    final zone = meta is Map && meta['timezone'] is String
        ? meta['timezone'] as String
        : 'Asia/Dhaka';

    return PrayerTimesModel(
      fajr: _formatTime12(rawFajr),
      dhuhr: _formatTime12(rawDhuhr),
      asr: _formatTime12(rawAsr),
      maghrib: _formatTime12(rawMaghrib),
      isha: _formatTime12(rawIsha),
      jummah: '1:30',
      fajr24: rawFajr,
      dhuhr24: rawDhuhr,
      asr24: rawAsr,
      maghrib24: rawMaghrib,
      isha24: rawIsha,
      timezone: zone,
    );
  }

  static String _cleanTime24(String time) {
    return time.split(' ').first;
  }

  static String _formatTime12(String time24) {
    try {
      final parts = time24.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        final minute = parts[1];
        return '${hour % 12 == 0 ? 12 : hour % 12}:$minute';
      }
    } catch (_) {}
    return time24;
  }

  /// Calculates which prayer is active at [now].
  static String getActivePrayerName(PrayerTimesModel model, [DateTime? targetTime]) {
    final now = targetTime ?? _nowAt(model.timezone);
    final nowMinutes = now.hour * 60 + now.minute;

    final fajrMinutes = _timeToMinutes(model.fajr24);
    final dhuhrMinutes = _timeToMinutes(model.dhuhr24);
    final asrMinutes = _timeToMinutes(model.asr24);
    final maghribMinutes = _timeToMinutes(model.maghrib24);
    final ishaMinutes = _timeToMinutes(model.isha24);

    if (nowMinutes >= fajrMinutes && nowMinutes < dhuhrMinutes) {
      return 'Fajr';
    } else if (nowMinutes >= dhuhrMinutes && nowMinutes < asrMinutes) {
      return now.weekday == DateTime.friday ? 'Jummah' : 'Dhuhr';
    } else if (nowMinutes >= asrMinutes && nowMinutes < maghribMinutes) {
      return 'Asr';
    } else if (nowMinutes >= maghribMinutes && nowMinutes < ishaMinutes) {
      return 'Maghrib';
    } else {
      return 'Isha';
    }
  }

  static bool _zonesReady = false;

  /// The current time at a place, so "which prayer is it" is right even when
  /// the chosen city is in a different zone from the phone.
  static DateTime _nowAt(String zoneName) {
    try {
      if (!_zonesReady) {
        tzdata.initializeTimeZones();
        _zonesReady = true;
      }
      return tz.TZDateTime.now(tz.getLocation(zoneName));
    } catch (_) {
      return DateTime.now();
    }
  }

  static int _timeToMinutes(String time24) {
    try {
      final parts = time24.split(':');
      if (parts.length >= 2) {
        final hours = int.parse(parts[0]);
        final minutes = int.parse(parts[1]);
        return hours * 60 + minutes;
      }
    } catch (_) {}
    return 0;
  }
}
