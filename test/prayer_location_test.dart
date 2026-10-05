import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ruqyahhealing/models/prayer_location.dart';
import 'package:ruqyahhealing/services/prayer_location_service.dart';
import 'package:ruqyahhealing/services/prayer_times_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _sylhet = PrayerLocation(
  city: 'Sylhet',
  countryCode: 'BD',
  latitude: 24.8949,
  longitude: 91.8687,
);

String _aladhan({String zone = 'Asia/Dhaka'}) => jsonEncode({
  'code': 200,
  'data': {
    'timings': {
      'Fajr': '04:36 (+06)',
      'Dhuhr': '11:47 (+06)',
      'Asr': '15:11 (+06)',
      'Maghrib': '17:43 (+06)',
      'Isha': '19:01 (+06)',
    },
    'meta': {'timezone': zone},
  },
});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PrayerLocation', () {
    test('label and JSON round trip', () {
      expect(PrayerLocation.dhaka.label, 'Dhaka, BD');
      const noCountry = PrayerLocation(
        city: 'Current location',
        countryCode: '',
        latitude: 1,
        longitude: 2,
      );
      expect(noCountry.label, 'Current location');

      final back = PrayerLocation.fromJson(
        jsonDecode(jsonEncode(_sylhet.toJson())),
      );
      expect(back!.city, 'Sylhet');
      expect(back.countryCode, 'BD');
      expect(back.latitude, 24.8949);
    });

    test('rejects invalid stored data', () {
      expect(PrayerLocation.fromJson(null), isNull);
      expect(PrayerLocation.fromJson({'city': 'X'}), isNull);
      expect(
        PrayerLocation.fromJson({'city': 'X', 'lat': 120, 'lon': 10}),
        isNull,
        reason: 'latitude out of range',
      );
      expect(
        PrayerLocation.fromJson({'city': '', 'lat': 1, 'lon': 1}),
        isNull,
      );
    });

    test('isSamePlaceAs ignores GPS jitter', () {
      const a = PrayerLocation(
        city: 'A',
        countryCode: 'BD',
        latitude: 23.8100,
        longitude: 90.4100,
      );
      const b = PrayerLocation(
        city: 'A',
        countryCode: 'BD',
        latitude: 23.8150,
        longitude: 90.4150,
      );
      expect(a.isSamePlaceAs(b), isTrue);
      expect(a.isSamePlaceAs(_sylhet), isFalse);
    });
  });

  group('geocoding parsers', () {
    test('search results', () {
      final results = PrayerLocationService.parseSearch({
        'results': [
          {
            'name': 'Sylhet',
            'latitude': 24.8949,
            'longitude': 91.8687,
            'country_code': 'bd',
          },
          {'name': 'No coords'},
          'junk',
        ],
      });
      expect(results.length, 1);
      expect(results.single.city, 'Sylhet');
      expect(results.single.countryCode, 'BD');
    });

    test('search with no results or junk is empty', () {
      expect(PrayerLocationService.parseSearch({}), isEmpty);
      expect(PrayerLocationService.parseSearch(null), isEmpty);
      expect(PrayerLocationService.parseSearch({'results': 5}), isEmpty);
    });

    test('reverse geocode prefers city, then locality, then region', () {
      final a = PrayerLocationService.parseReverseGeocode(
        {'city': 'Dhaka', 'locality': 'Mirpur', 'countryCode': 'bd'},
        23.8,
        90.4,
      );
      expect(a!.city, 'Dhaka');
      expect(a.countryCode, 'BD');

      final b = PrayerLocationService.parseReverseGeocode(
        {'city': '', 'locality': 'Mirpur', 'countryCode': 'BD'},
        1,
        2,
      );
      expect(b!.city, 'Mirpur');

      expect(
        PrayerLocationService.parseReverseGeocode({'countryCode': 'BD'}, 1, 2),
        isNull,
      );
    });

    test('reverseGeocode falls back to coordinates when the call fails', () async {
      final service = PrayerLocationService.forTest(
        client: MockClient((_) async => http.Response('boom', 500)),
      );
      final place = await service.reverseGeocode(10.5, 20.5);
      expect(place.city, 'Current location');
      expect(place.latitude, 10.5);
      expect(place.longitude, 20.5);
    });

    test('searchPlaces uses the API and ignores short queries', () async {
      var calls = 0;
      final service = PrayerLocationService.forTest(
        client: MockClient((req) async {
          calls++;
          expect(req.url.host, 'geocoding-api.open-meteo.com');
          expect(req.url.queryParameters['name'], 'sylhet');
          return http.Response(
            jsonEncode({
              'results': [
                {
                  'name': 'Sylhet',
                  'latitude': 24.9,
                  'longitude': 91.9,
                  'country_code': 'BD',
                },
              ],
            }),
            200,
          );
        }),
      );
      expect(await service.searchPlaces('s'), isEmpty);
      expect(calls, 0);
      final found = await service.searchPlaces('  sylhet ');
      expect(found.single.city, 'Sylhet');
      expect(calls, 1);
    });
  });

  group('PrayerLocationService choice', () {
    test('defaults to Dhaka with auto-detect on', () async {
      SharedPreferences.setMockInitialValues({});
      final service = PrayerLocationService.forTest();
      await service.load();
      expect(service.current.city, 'Dhaka');
      expect(service.autoDetect, isTrue);
    });

    test('a manual choice is saved, turns auto off, and notifies', () async {
      SharedPreferences.setMockInitialValues({});
      final service = PrayerLocationService.forTest();
      await service.load();

      var placeChanges = 0;
      service.locationNotifier.addListener(() => placeChanges++);

      await service.selectManual(_sylhet);
      expect(service.current.city, 'Sylhet');
      expect(service.autoDetect, isFalse);
      expect(placeChanges, 1);

      // A new instance reads the same choice back from storage.
      final again = PrayerLocationService.forTest();
      await again.load();
      expect(again.current.city, 'Sylhet');
      expect(again.autoDetect, isFalse);
    });

    test('ignores unreadable saved data', () async {
      SharedPreferences.setMockInitialValues({'prayer_location_v1': '{oops'});
      final service = PrayerLocationService.forTest();
      await service.load();
      expect(service.current.city, 'Dhaka');
    });
  });

  group('PrayerTimesService', () {
    test('requests by coordinates, with the Karachi method for Bangladesh', () {
      final uri = PrayerTimesService.buildUri(_sylhet);
      expect(uri.host, 'api.aladhan.com');
      expect(uri.path, '/v1/timings');
      expect(uri.queryParameters['latitude'], '24.8949');
      expect(uri.queryParameters['longitude'], '91.8687');
      expect(uri.queryParameters['method'], '1');
    });

    test('lets the API choose the method elsewhere', () {
      final uri = PrayerTimesService.buildUri(
        const PrayerLocation(
          city: 'London',
          countryCode: 'GB',
          latitude: 51.5,
          longitude: -0.12,
        ),
      );
      expect(uri.queryParameters.containsKey('method'), isFalse);
    });

    test('fetch parses times and the location time zone', () async {
      final client = MockClient((req) async {
        expect(req.url.queryParameters['latitude'], '21.3891');
        return http.Response(_aladhan(zone: 'Asia/Riyadh'), 200);
      });
      final times = await PrayerTimesService.fetchPrayerTimes(
        location: PrayerLocation.popular.firstWhere((p) => p.city == 'Makkah'),
        client: client,
      );
      expect(times.fajr24, '04:36');
      expect(times.fajr, '4:36');
      expect(times.isha, '7:01');
      expect(times.timezone, 'Asia/Riyadh');
    });

    test('falls back (Dhaka times) when the request fails', () async {
      final times = await PrayerTimesService.fetchPrayerTimes(
        location: _sylhet,
        client: MockClient((_) async => http.Response('nope', 500)),
      );
      expect(times.fajr24, '04:05');
      expect(times.timezone, 'Asia/Dhaka');
    });

    test('active prayer follows the given time', () async {
      final times = PrayerTimesService.parseResponse(jsonDecode(_aladhan()))!;
      String at(int h, int m) => PrayerTimesService.getActivePrayerName(
        times,
        DateTime(2026, 10, 5, h, m), // a Monday
      );
      expect(at(5, 0), 'Fajr');
      expect(at(12, 0), 'Dhuhr');
      expect(at(16, 0), 'Asr');
      expect(at(18, 0), 'Maghrib');
      expect(at(21, 0), 'Isha');
      expect(
        PrayerTimesService.getActivePrayerName(
          times,
          DateTime(2026, 10, 9, 12, 0), // a Friday
        ),
        'Jummah',
      );
    });

    test('without an explicit time, "now" is read in the location zone', () {
      final times = PrayerTimesService.parseResponse(
        jsonDecode(_aladhan(zone: 'Pacific/Kiritimati')),
      )!; // UTC+14
      // Must not throw, and must resolve to a real prayer name.
      expect(
        ['Fajr', 'Dhuhr', 'Jummah', 'Asr', 'Maghrib', 'Isha'],
        contains(PrayerTimesService.getActivePrayerName(times)),
      );
    });

    test('an unknown zone name falls back instead of throwing', () {
      final times = PrayerTimesService.parseResponse(
        jsonDecode(_aladhan(zone: 'Not/AZone')),
      )!;
      expect(
        ['Fajr', 'Dhuhr', 'Jummah', 'Asr', 'Maghrib', 'Isha'],
        contains(PrayerTimesService.getActivePrayerName(times)),
      );
    });
  });
}
