import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

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
  static Future<PrayerTimesModel> fetchPrayerTimes({
    String city = 'Dhaka',
    String country = 'Bangladesh',
  }) async {
    try {
      final url = Uri.parse(
        'https://api.aladhan.com/v1/timingsByCity?city=$city&country=$country&method=1',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timings = data['data']['timings'];

        final rawFajr = _cleanTime24(timings['Fajr'] ?? '04:05');
        final rawDhuhr = _cleanTime24(timings['Dhuhr'] ?? '12:30');
        final rawAsr = _cleanTime24(timings['Asr'] ?? '16:45');
        final rawMaghrib = _cleanTime24(timings['Maghrib'] ?? '18:45');
        final rawIsha = _cleanTime24(timings['Isha'] ?? '20:15');

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
        );
      }
    } catch (e) {
      debugPrint('Error fetching prayer times from API: $e');
    }
    return PrayerTimesModel.fallback();
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
    final now = targetTime ?? DateTime.now();
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
