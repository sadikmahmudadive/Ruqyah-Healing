import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ruqyahhealing/services/ruqyah_api_service.dart';

void main() {
  group('RuqyahApiService Tests', () {
    setUp(() {
      RuqyahApiService.initialize();
    });

    test('initialize() registers playlists, Quran Ayats, and Prophetic Duas', () {
      final playlists = RuqyahApiService.getAllPlaylists();
      expect(playlists.isNotEmpty, isTrue);

      final fullRuqyah = RuqyahApiService.getTrack('ruqyah_full');
      expect(fullRuqyah, isNotNull);
      expect(fullRuqyah!.ayahs.length, greaterThan(15));

      final propheticDuasTrack = RuqyahApiService.getTrack('ruqyah_duas');
      expect(propheticDuasTrack, isNotNull);
      expect(propheticDuasTrack!.ayahs.length, greaterThanOrEqualTo(9));
    });

    test('getAllQuranAyats() returns all essential Quranic Ruqyah verses', () {
      final ayats = RuqyahApiService.getAllQuranAyats();
      expect(ayats.isNotEmpty, isTrue);

      // Verify Surah Al-Fatihah
      expect(ayats.any((a) => a.surah == 1 && a.number == 1), isTrue);

      // Verify Ayat Al-Kursi (2:255)
      final kursi = ayats.firstWhere((a) => a.surah == 2 && a.number == 255);
      expect(kursi.audioUrl, contains('002255.mp3'));
      expect(kursi.arabic, contains('ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ'));

      // Verify Sihr verse (Yunus 10:81)
      expect(ayats.any((a) => a.surah == 10 && a.number == 81), isTrue);

      // Verify Al-Mu'awwidhat (113 and 114)
      expect(ayats.any((a) => a.surah == 113 && a.number == 1), isTrue);
      expect(ayats.any((a) => a.surah == 114 && a.number == 1), isTrue);
    });

    test('getAllDuas() returns authentic Prophetic Duas with Hadith citations', () {
      final duas = RuqyahApiService.getAllDuas();
      expect(duas.isNotEmpty, isTrue);

      // Verify Dua of Jibril AS
      final jibrilDua = duas.firstWhere((d) => d.reference?.contains('Muslim 2186') ?? false);
      expect(jibrilDua.arabic, contains('بِسْمِ اللَّهِ أَرْقِيكَ'));
      expect(jibrilDua.isDua, isTrue);
      expect(jibrilDua.audioUrl.isNotEmpty, isTrue);

      // Verify Prophet's Dua for Healing
      final healingDua = duas.firstWhere((d) => d.reference?.contains('5743') ?? false);
      expect(healingDua.arabic, contains('اللَّهُمَّ رَبَّ النَّاسِ'));
      expect(healingDua.meaning, contains('Lord of mankind'));
    });

    test('parseAyahResponse() parses Al-Quran Cloud editions JSON format correctly', () {
      final mockJson = {
        'code': 200,
        'status': 'OK',
        'data': [
          {
            'number': 1,
            'text': 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
            'edition': {'identifier': 'quran-uthmani'},
            'surah': {'number': 1, 'englishName': 'Al-Faatiha'},
            'numberInSurah': 1,
          },
          {
            'number': 1,
            'text': 'Bismillaahir Rahmaanir Raheem',
            'edition': {'identifier': 'en.transliteration'},
            'surah': {'number': 1, 'englishName': 'Al-Faatiha'},
            'numberInSurah': 1,
          },
          {
            'number': 1,
            'text': 'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
            'edition': {'identifier': 'en.sahih'},
            'surah': {'number': 1, 'englishName': 'Al-Faatiha'},
            'numberInSurah': 1,
          },
          {
            'number': 1,
            'audio': 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/1.mp3',
            'edition': {'identifier': 'ar.alafasy'},
            'surah': {'number': 1, 'englishName': 'Al-Faatiha'},
            'numberInSurah': 1,
          },
        ],
      };

      final parsed = RuqyahApiService.parseAyahResponse(mockJson, surah: 1, number: 1);
      expect(parsed, isNotNull);
      expect(parsed!.surah, 1);
      expect(parsed.number, 1);
      expect(parsed.surahName, 'Al-Faatiha');
      expect(parsed.arabic, 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ');
      expect(parsed.transliteration, 'Bismillaahir Rahmaanir Raheem');
      expect(parsed.meaning, 'In the name of Allah, the Entirely Merciful, the Especially Merciful.');
      expect(parsed.audioUrl, 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/1.mp3');
    });

    test('fetchAyahFromApi() fetches with mock HTTP client', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('/v1/ayah/1:1')) {
          return http.Response(
            json.encode({
              'code': 200,
              'status': 'OK',
              'data': [
                {
                  'number': 1,
                  'text': 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                  'edition': {'identifier': 'quran-uthmani'},
                  'surah': {'number': 1, 'englishName': 'Al-Fatihah'},
                  'numberInSurah': 1,
                },
                {
                  'number': 1,
                  'text': 'Bismillah',
                  'edition': {'identifier': 'en.transliteration'},
                  'surah': {'number': 1, 'englishName': 'Al-Fatihah'},
                  'numberInSurah': 1,
                },
                {
                  'number': 1,
                  'text': 'In the name of Allah',
                  'edition': {'identifier': 'en.sahih'},
                  'surah': {'number': 1, 'englishName': 'Al-Fatihah'},
                  'numberInSurah': 1,
                },
                {
                  'number': 1,
                  'audio': 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/1.mp3',
                  'edition': {'identifier': 'ar.alafasy'},
                  'surah': {'number': 1, 'englishName': 'Al-Fatihah'},
                  'numberInSurah': 1,
                },
              ],
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final ayah = await RuqyahApiService.fetchAyahFromApi(1, 1, forceRefresh: true, client: mockClient);
      expect(ayah, isNotNull);
      expect(ayah!.arabic, contains('بِسْمِ ٱللَّهِ'));
      expect(ayah.audioUrl, contains('cdn.islamic.network'));
    });
  });
}
