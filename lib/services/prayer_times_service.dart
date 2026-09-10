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

  const PrayerTimesModel({
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.jummah,
  });

  factory PrayerTimesModel.fallback() {
    return const PrayerTimesModel(
      fajr: '4:05',
      dhuhr: '12:30',
      asr: '4:45',
      maghrib: '6:45',
      isha: '8:15',
      jummah: '1:30',
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

        return PrayerTimesModel(
          fajr: _formatTime(timings['Fajr'] ?? '04:05'),
          dhuhr: _formatTime(timings['Dhuhr'] ?? '12:30'),
          asr: _formatTime(timings['Asr'] ?? '16:45'),
          maghrib: _formatTime(timings['Maghrib'] ?? '18:45'),
          isha: _formatTime(timings['Isha'] ?? '20:15'),
          jummah: '1:30',
        );
      }
    } catch (e) {
      debugPrint('Error fetching prayer times from API: $e');
    }
    return PrayerTimesModel.fallback();
  }

  static String _formatTime(String time24) {
    try {
      final cleanTime = time24.split(' ').first;
      final parts = cleanTime.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        final minute = parts[1];
        return '${hour % 12 == 0 ? 12 : hour % 12}:$minute';
      }
    } catch (_) {}
    return time24;
  }
}
