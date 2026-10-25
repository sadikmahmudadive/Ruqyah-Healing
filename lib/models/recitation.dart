/// One ayah or prophetic dua with its subtitle text and the audio that recites it.
class Ayah {
  final int surah;
  final int number;
  final String surahName;
  final String arabic;
  final String transliteration;
  final String meaning;
  final String? customAudioUrl;
  final String? reference;

  const Ayah({
    required this.surah,
    required this.number,
    required this.surahName,
    required this.arabic,
    required this.transliteration,
    required this.meaning,
    this.customAudioUrl,
    this.reference,
  });

  /// True if this item is a Prophetic Dua (from Sunnah) rather than a Quranic ayah.
  bool get isDua => surah <= 0;

  /// e.g. "2:255" or "Dua 1"
  String get ref => surah > 0 ? '$surah:$number' : (reference ?? 'Dua $number');

  /// e.g. "AL-BAQARAH (2:255)" or "PROPHETIC DUA"
  String get citation =>
      surah > 0 ? '${surahName.toUpperCase()} ($ref)' : surahName.toUpperCase();

  /// Sheikh Mishary Al-Afasy, one MP3 per ayah (everyayah.com file naming:
  /// 3-digit surah + 3-digit ayah), or custom hosted audio url for Duas.
  String get audioUrl =>
      customAudioUrl ??
      (surah > 0
          ? 'https://everyayah.com/data/Alafasy_128kbps/'
            '${surah.toString().padLeft(3, '0')}${number.toString().padLeft(3, '0')}.mp3'
          : '');

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      surah: json['surah'] as int? ?? 0,
      number: json['number'] as int? ?? 0,
      surahName: json['surahName'] as String? ?? '',
      arabic: json['arabic'] as String? ?? '',
      transliteration: json['transliteration'] as String? ?? '',
      meaning: json['meaning'] as String? ?? '',
      customAudioUrl: json['customAudioUrl'] as String?,
      reference: json['reference'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'surah': surah,
    'number': number,
    'surahName': surahName,
    'arabic': arabic,
    'transliteration': transliteration,
    'meaning': meaning,
    if (customAudioUrl != null) 'customAudioUrl': customAudioUrl,
    if (reference != null) 'reference': reference,
  };
}

/// A playable recitation: an ordered list of ayahs and/or prophetic duas.
class RecitationContent {
  final String id;
  final String title;
  final String arabicTitle;
  final String subtitle;
  final String category;
  final String reciter;
  final List<Ayah> ayahs;

  const RecitationContent({
    required this.id,
    required this.title,
    this.arabicTitle = '',
    this.subtitle = '',
    this.category = 'Ruqyah',
    this.reciter = 'Sheikh Mishary Al-Afasy',
    required this.ayahs,
  });

  factory RecitationContent.fromJson(Map<String, dynamic> json) {
    return RecitationContent(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      arabicTitle: json['arabicTitle'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      category: json['category'] as String? ?? 'Ruqyah',
      reciter: json['reciter'] as String? ?? 'Sheikh Mishary Al-Afasy',
      ayahs: (json['ayahs'] as List<dynamic>? ?? [])
          .map((e) => Ayah.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'arabicTitle': arabicTitle,
    'subtitle': subtitle,
    'category': category,
    'reciter': reciter,
    'ayahs': ayahs.map((e) => e.toJson()).toList(),
  };
}
