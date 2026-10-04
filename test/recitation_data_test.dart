import 'package:flutter_test/flutter_test.dart';
import 'package:ruqyahhealing/data/recitation_data.dart';
import 'package:ruqyahhealing/models/recitation.dart';

void main() {
  // Al-Fatihah 1:1 is the Bismillah itself, so use it as the reference text.
  final bismillah = kRecitationTracks['emergency']!.ayahs
      .firstWhere((a) => a.ref == '1:1')
      .arabic;

  test('audio URL uses 3-digit surah + ayah (everyayah naming)', () {
    const a = Ayah(
      surah: 2,
      number: 255,
      surahName: 'Al-Baqarah',
      arabic: '',
      transliteration: '',
      meaning: '',
    );
    expect(
      a.audioUrl,
      'https://everyayah.com/data/Alafasy_128kbps/002255.mp3',
    );
    expect(a.ref, '2:255');
    expect(a.citation, 'AL-BAQARAH (2:255)');
  });

  test('every library track has a playable recitation', () {
    for (final id in ['rec_1', 'rec_2', 'rec_3', 'emergency']) {
      final track = kRecitationTracks[id];
      expect(track, isNotNull, reason: id);
      expect(track!.ayahs, isNotEmpty, reason: id);
    }
  });

  test('track contents match their descriptions', () {
    expect(kRecitationTracks['rec_1']!.ayahs.map((a) => a.ref), [
      '2:1', '2:2', '2:3', '2:4', '2:5', '2:163', '2:164', '2:255',
    ]);
    expect(kRecitationTracks['rec_2']!.ayahs.map((a) => a.ref), ['2:255']);
    expect(kRecitationTracks['rec_3']!.ayahs.length, 11); // 5 + 6
  });

  test('every ayah has Arabic, transliteration and meaning', () {
    for (final track in kRecitationTracks.values) {
      for (final a in track.ayahs) {
        expect(a.arabic.trim(), isNotEmpty, reason: a.ref);
        expect(a.transliteration.trim(), isNotEmpty, reason: a.ref);
        expect(a.meaning.trim(), isNotEmpty, reason: a.ref);
      }
    }
  });

  test('Bismillah is only present on Al-Fatihah 1:1, not prefixed elsewhere', () {
    for (final track in kRecitationTracks.values) {
      for (final a in track.ayahs) {
        if (a.ref != '1:1') {
          expect(a.arabic.startsWith(bismillah), isFalse, reason: a.ref);
        }
      }
    }
  });
}
