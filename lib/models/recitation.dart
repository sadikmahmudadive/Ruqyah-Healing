/// One ayah with its subtitle text and the audio that recites it.
class Ayah {
  final int surah;
  final int number;
  final String surahName;
  final String arabic;
  final String transliteration;
  final String meaning;

  const Ayah({
    required this.surah,
    required this.number,
    required this.surahName,
    required this.arabic,
    required this.transliteration,
    required this.meaning,
  });

  /// e.g. "2:255"
  String get ref => '$surah:$number';

  /// e.g. "AL-BAQARAH (2:255)"
  String get citation => '${surahName.toUpperCase()} ($ref)';

  /// Sheikh Mishary Al-Afasy, one MP3 per ayah (everyayah.com file naming:
  /// 3-digit surah + 3-digit ayah).
  String get audioUrl =>
      'https://everyayah.com/data/Alafasy_128kbps/'
      '${surah.toString().padLeft(3, '0')}${number.toString().padLeft(3, '0')}.mp3';
}

/// A playable recitation: an ordered list of ayahs.
class RecitationContent {
  final String id;
  final String title;
  final String arabicTitle;
  final List<Ayah> ayahs;

  const RecitationContent({
    required this.id,
    required this.title,
    this.arabicTitle = '',
    required this.ayahs,
  });
}
