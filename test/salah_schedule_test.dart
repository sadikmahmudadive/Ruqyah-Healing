import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ruqyahhealing/models/prayer_location.dart';
import 'package:ruqyahhealing/services/prayer_times_service.dart';
import 'package:ruqyahhealing/services/salah_schedule.dart';

String _aladhan() => jsonEncode({
  'code': 200,
  'data': {
    'timings': {
      'Fajr': '04:36 (+06)',
      'Sunrise': '05:55 (+06)',
      'Dhuhr': '11:47 (+06)',
      'Asr': '15:11 (+06)',
      'Sunset': '17:40 (+06)',
      'Maghrib': '17:43 (+06)',
      'Isha': '19:01 (+06)',
      'Midnight': '23:46 (+06)',
      'Lastthird': '02:57 (+06)',
    },
    'meta': {'timezone': 'Asia/Dhaka'},
  },
});

void main() {
  late PrayerTimesModel model;

  setUp(() {
    model = PrayerTimesService.parseResponse(jsonDecode(_aladhan()))!;
  });

  group('API response', () {
    test('keeps the sunrise, sunset and night timings', () {
      expect(model.sunrise24, '05:55');
      expect(model.sunset24, '17:40');
      expect(model.midnight24, '23:46');
      expect(model.lastThird24, '02:57');
    });

    test('a dated request goes to the dated endpoint', () {
      final uri = PrayerTimesService.buildUri(
        PrayerLocation.dhaka,
        date: DateTime(2026, 10, 3),
      );
      expect(uri.path, '/v1/timings/03-10-2026');
      expect(
        PrayerTimesService.buildUri(PrayerLocation.dhaka).path,
        '/v1/timings',
      );
    });

    test('fetching for a date asks the API for that date', () async {
      Uri? asked;
      final client = MockClient((req) async {
        asked = req.url;
        return http.Response(_aladhan(), 200);
      });
      final got = await PrayerTimesService.fetchPrayerTimes(
        location: PrayerLocation.dhaka,
        date: DateTime(2026, 1, 9),
        client: client,
      );
      expect(asked!.path, '/v1/timings/09-01-2026');
      expect(got.lastThird24, '02:57');
    });
  });

  group('SalahSchedule', () {
    // Wednesday 21 Oct 2026.
    final wed = DateTime(2026, 10, 21);

    test('has the five fard prayers in order, then three voluntary', () {
      final s = SalahSchedule.from(model, date: wed);
      expect(s.fard.map((e) => e.id), [
        'fajr',
        'dhuhr',
        'asr',
        'maghrib',
        'isha',
      ]);
      expect(s.nafl.map((e) => e.id), ['tahajjud', 'ishraq', 'chast']);
      expect(s.fard.every((e) => e.kind == SalahKind.fard), isTrue);
      expect(s.nafl.every((e) => e.kind == SalahKind.nafl), isTrue);
    });

    test('Tahajjud runs from the last third of the night to Fajr', () {
      final t = SalahSchedule.from(model, date: wed).nafl[0];
      expect(t.start, 2 * 60 + 57);
      expect(t.end, 4 * 60 + 36);
    });

    test('Ishraq opens 15 minutes after sunrise for 45 minutes', () {
      final i = SalahSchedule.from(model, date: wed).nafl[1];
      const sunrise = 5 * 60 + 55;
      expect(i.start, sunrise + 15);
      expect(i.end, sunrise + 60);
    });

    test('Chast opens a quarter into the daylight and ends before Dhuhr', () {
      final c = SalahSchedule.from(model, date: wed).nafl[2];
      const sunrise = 5 * 60 + 55;
      const sunset = 17 * 60 + 40;
      expect(c.start, sunrise + ((sunset - sunrise) / 4).round());
      expect(c.end, 11 * 60 + 47 - 10);
      expect(c.start, lessThan(c.end!));
    });

    test('the voluntary windows never overlap each other in order', () {
      final n = SalahSchedule.from(model, date: wed).nafl;
      expect(n[0].end!, lessThanOrEqualTo(n[1].start));
      expect(n[1].end!, lessThanOrEqualTo(n[2].start));
    });

    test("Friday swaps Dhuhr for Jumu'ah", () {
      final fri = SalahSchedule.from(model, date: DateTime(2026, 10, 23));
      expect(fri.fard[1].name, "Jumu'ah");
      expect(SalahSchedule.from(model, date: wed).fard[1].name, 'Dhuhr');
    });

    test('next prayer and the wait until it', () {
      final s = SalahSchedule.from(model, date: wed);
      final afternoon = 14 * 60 + 29; // before Asr at 15:11
      final next = s.nextFard(afternoon)!;
      expect(next.id, 'asr');
      expect(s.minutesUntil(next, afternoon), 42);

      // After Isha there is no next prayer today; Fajr is tomorrow.
      expect(s.nextFard(20 * 60), isNull);
      final fajr = s.fard.first;
      expect(s.minutesUntil(fajr, 20 * 60), 24 * 60 - 20 * 60 + 4 * 60 + 36);
    });

    test('formatting helpers', () {
      expect(SalahSchedule.describeWait(42), '42 min');
      expect(SalahSchedule.describeWait(65), '1 h 05 min');
      expect(SalahSchedule.describeWait(120), '2 h');
      expect(SalahSchedule.clock12(4 * 60 + 58), '4:58 AM');
      expect(SalahSchedule.clock12(12 * 60 + 18), '12:18 PM');
      expect(SalahSchedule.clock12(0), '12:00 AM');
      expect(SalahSchedule.minutesOf('19:22 (+06)'), 19 * 60 + 22);
    });
  });
}
