import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/recitation.dart';

/// Service to fetch and manage Quranic Ayats and Prophetic Duas for Ruqyah
/// with their online audio streams, Arabic texts, transliterations, and translations.
///
/// Integrates with the public Al-Quran Cloud API (api.alquran.cloud) and
/// EveryAyah CDN (everyayah.com) with complete offline fallback data.
class RuqyahApiService {
  static const String _apiAuthority = 'api.alquran.cloud';
  static final Map<String, Ayah> _cachedAyahs = {};
  static final Map<String, RecitationContent> _playlistRegistry = {};
  static bool _initialized = false;

  /// Ensures initial catalog of Ruqyah Ayats, Duas, and Playlists is populated.
  static void initialize() {
    if (_initialized) return;
    _registerDefaultData();
    _initialized = true;
  }

  /// Fetches an Ayah dynamically from the Al-Quran Cloud API with Arabic text,
  /// transliteration, English meaning, and Mishary Al-Afasy audio.
  static Future<Ayah?> fetchAyahFromApi(
    int surah,
    int ayahNumber, {
    bool forceRefresh = false,
    http.Client? client,
  }) async {
    final cacheKey = '$surah:$ayahNumber';
    if (!forceRefresh && _cachedAyahs.containsKey(cacheKey)) {
      return _cachedAyahs[cacheKey];
    }

    final httpClient = client ?? http.Client();
    try {
      final uri = Uri.https(
        _apiAuthority,
        '/v1/ayah/$surah:$ayahNumber/editions/quran-uthmani,en.transliteration,en.sahih,ar.alafasy',
      );

      final response = await httpClient.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        final ayah = parseAyahResponse(decoded, surah: surah, number: ayahNumber);
        if (ayah != null) {
          _cachedAyahs[cacheKey] = ayah;
          return ayah;
        }
      }
    } catch (e) {
      debugPrint('RuqyahApiService: Error fetching ayah $surah:$ayahNumber from API: $e');
    } finally {
      if (client == null) httpClient.close();
    }

    // Fall back to local registry if network call fails
    return _cachedAyahs[cacheKey] ?? _findLocalAyah(surah, ayahNumber);
  }

  /// Parses an Al-Quran Cloud API response containing multiple editions.
  @visibleForTesting
  static Ayah? parseAyahResponse(Object? body, {required int surah, required int number}) {
    if (body is! Map || body['data'] is! List) return null;
    final data = body['data'] as List;
    if (data.isEmpty) return null;

    String arabic = '';
    String transliteration = '';
    String meaning = '';
    String audioUrl = '';
    String surahName = 'Surah $surah';

    for (final item in data) {
      if (item is! Map) continue;
      final edition = item['edition'] as Map?;
      final identifier = edition?['identifier'] as String? ?? '';
      final text = item['text'] as String? ?? '';

      if (item['surah'] is Map) {
        final sMap = item['surah'] as Map;
        surahName = sMap['englishName'] as String? ?? surahName;
      }

      if (identifier == 'quran-uthmani') {
        arabic = text;
      } else if (identifier == 'en.transliteration') {
        transliteration = text;
      } else if (identifier == 'en.sahih') {
        meaning = text;
      } else if (identifier == 'ar.alafasy') {
        audioUrl = item['audio'] as String? ?? '';
      }
    }

    if (arabic.isEmpty && meaning.isEmpty) return null;

    return Ayah(
      surah: surah,
      number: number,
      surahName: surahName,
      arabic: arabic,
      transliteration: transliteration,
      meaning: meaning,
      customAudioUrl: audioUrl.isNotEmpty ? audioUrl : null,
    );
  }

  /// Fetches a full Surah with all verses from the API.
  static Future<List<Ayah>> fetchSurahFromApi(int surah, {http.Client? client}) async {
    final httpClient = client ?? http.Client();
    try {
      final uri = Uri.https(
        _apiAuthority,
        '/v1/surah/$surah/editions/quran-uthmani,en.transliteration,en.sahih,ar.alafasy',
      );

      final response = await httpClient.get(uri).timeout(const Duration(seconds: 12));
      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        final ayahs = parseSurahResponse(decoded, surah);
        if (ayahs.isNotEmpty) {
          for (final a in ayahs) {
            _cachedAyahs['${a.surah}:${a.number}'] = a;
          }
          return ayahs;
        }
      }
    } catch (e) {
      debugPrint('RuqyahApiService: Error fetching surah $surah from API: $e');
    } finally {
      if (client == null) httpClient.close();
    }

    // Return any locally available ayahs for this surah
    return _cachedAyahs.values.where((a) => a.surah == surah).toList();
  }

  @visibleForTesting
  static List<Ayah> parseSurahResponse(Object? body, int surah) {
    if (body is! Map || body['data'] is! List) return [];
    final data = body['data'] as List;
    if (data.length < 4) return [];

    final uthmaniEdition = data[0] as Map? ?? {};
    final transEdition = data[1] as Map? ?? {};
    final sahihEdition = data[2] as Map? ?? {};
    final audioEdition = data[3] as Map? ?? {};

    final uthmaniAyahs = uthmaniEdition['ayahs'] as List? ?? [];
    final transAyahs = transEdition['ayahs'] as List? ?? [];
    final sahihAyahs = sahihEdition['ayahs'] as List? ?? [];
    final audioAyahs = audioEdition['ayahs'] as List? ?? [];

    final surahName = uthmaniEdition['englishName'] as String? ?? 'Surah $surah';
    final List<Ayah> result = [];

    for (int i = 0; i < uthmaniAyahs.length; i++) {
      final u = uthmaniAyahs[i] as Map? ?? {};
      final numberInSurah = u['numberInSurah'] as int? ?? (i + 1);
      final arabicText = u['text'] as String? ?? '';

      final t = (i < transAyahs.length) ? transAyahs[i] as Map? ?? {} : {};
      final transliteration = t['text'] as String? ?? '';

      final s = (i < sahihAyahs.length) ? sahihAyahs[i] as Map? ?? {} : {};
      final meaning = s['text'] as String? ?? '';

      final a = (i < audioAyahs.length) ? audioAyahs[i] as Map? ?? {} : {};
      final audioUrl = a['audio'] as String? ?? '';

      result.add(
        Ayah(
          surah: surah,
          number: numberInSurah,
          surahName: surahName,
          arabic: arabicText,
          transliteration: transliteration,
          meaning: meaning,
          customAudioUrl: audioUrl.isNotEmpty ? audioUrl : null,
        ),
      );
    }

    return result;
  }

  /// Syncs/refreshes core Ruqyah tracks with live audio CDN links from Al-Quran Cloud.
  static Future<bool> syncFromApi({http.Client? client}) async {
    initialize();
    final httpClient = client ?? http.Client();
    try {
      // Sync Surah Al-Fatihah, Al-Falaq, An-Nas, and Al-Ikhlas
      await Future.wait([
        fetchSurahFromApi(1, client: httpClient),
        fetchSurahFromApi(112, client: httpClient),
        fetchSurahFromApi(113, client: httpClient),
        fetchSurahFromApi(114, client: httpClient),
      ]);
      return true;
    } catch (e) {
      debugPrint('RuqyahApiService: Sync completed with notes: $e');
      return false;
    } finally {
      if (client == null) httpClient.close();
    }
  }

  /// Look up a track or playlist by ID.
  static RecitationContent? getTrack(String id) {
    initialize();
    return _playlistRegistry[id];
  }

  /// Returns all available playlists and sessions.
  static List<RecitationContent> getAllPlaylists() {
    initialize();
    return _playlistRegistry.values.toList();
  }

  /// Returns all individual Quran Ayats for Ruqyah.
  static List<Ayah> getAllQuranAyats() {
    initialize();
    final all = <Ayah>[];
    final seen = <String>{};
    for (final playlist in _playlistRegistry.values) {
      for (final ayah in playlist.ayahs) {
        if (!ayah.isDua && seen.add('${ayah.surah}:${ayah.number}')) {
          all.add(ayah);
        }
      }
    }
    return all;
  }

  /// Returns all authentic Prophetic Duas for Ruqyah.
  static List<Ayah> getAllDuas() {
    initialize();
    final all = <Ayah>[];
    final seen = <String>{};
    for (final playlist in _playlistRegistry.values) {
      for (final ayah in playlist.ayahs) {
        if (ayah.isDua && seen.add(ayah.ref)) {
          all.add(ayah);
        }
      }
    }
    return all;
  }

  static Ayah? _findLocalAyah(int surah, int number) {
    for (final playlist in _playlistRegistry.values) {
      for (final ayah in playlist.ayahs) {
        if (ayah.surah == surah && ayah.number == number) {
          return ayah;
        }
      }
    }
    return null;
  }

  // ──────────────────────────── Catalog Data ────────────────────────────

  static void _registerDefaultData() {
    // 1. Surah Al-Fatihah (1:1–7)
    final fatihahAyahs = [
      const Ayah(
        surah: 1,
        number: 1,
        surahName: 'Al-Fatihah',
        arabic: 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
        transliteration: 'Bismillaahir Rahmaanir Raheem',
        meaning: 'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
      ),
      const Ayah(
        surah: 1,
        number: 2,
        surahName: 'Al-Fatihah',
        arabic: 'ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ',
        transliteration: 'Alhamdu lillaahi Rabbil \'aalameen',
        meaning: '[All] praise is [due] to Allah, Lord of the worlds -',
      ),
      const Ayah(
        surah: 1,
        number: 3,
        surahName: 'Al-Fatihah',
        arabic: 'ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
        transliteration: 'Ar-Rahmaanir-Raheem',
        meaning: 'The Entirely Merciful, the Especially Merciful,',
      ),
      const Ayah(
        surah: 1,
        number: 4,
        surahName: 'Al-Fatihah',
        arabic: 'مَٰلِكِ يَوْمِ ٱلدِّينِ',
        transliteration: 'Maaliki Yawmid-Deen',
        meaning: 'Sovereign of the Day of Recompense.',
      ),
      const Ayah(
        surah: 1,
        number: 5,
        surahName: 'Al-Fatihah',
        arabic: 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
        transliteration: 'Iyyaaka na\'budu wa lyyaaka nasta\'een',
        meaning: 'It is You we worship and You we ask for help.',
      ),
      const Ayah(
        surah: 1,
        number: 6,
        surahName: 'Al-Fatihah',
        arabic: 'ٱهْدِنَا ٱلصِّرَٰطَ ٱلْمُسْتَقِيمَ',
        transliteration: 'Ihdinas-Siraatal-Mustaqeem',
        meaning: 'Guide us to the straight path -',
      ),
      const Ayah(
        surah: 1,
        number: 7,
        surahName: 'Al-Fatihah',
        arabic: 'صِرَٰطَ ٱلَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ ٱلْمَغْضُوبِ عَلَيْهِمْ وَلَا ٱلضَّآلِّينَ',
        transliteration: 'Siraatal-lazeena an\'amta \'alaihim ghayril-maghdoobi \'alaihim wa lad-daaalleen',
        meaning: 'The path of those upon whom You have bestowed favor, not of those who have evoked [Your] anger or of those who are astray.',
      ),
    ];

    // 2. Surah Al-Baqarah Ruqyah Ayats
    const baqarah1_5 = [
      Ayah(
        surah: 2,
        number: 1,
        surahName: 'Al-Baqarah',
        arabic: 'الٓمٓ',
        transliteration: 'Alif-Laaam-Meeem',
        meaning: 'Alif, Lam, Meem.',
      ),
      Ayah(
        surah: 2,
        number: 2,
        surahName: 'Al-Baqarah',
        arabic: 'ذَٰلِكَ ٱلْكِتَٰبُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًۭى لِّلْمُتَّقِينَ',
        transliteration: 'Zaalikal Kitaabu laa raiba feeh; hudal lilmuttaqeen',
        meaning: 'This is the Book about which there is no doubt, a guidance for those conscious of Allah -',
      ),
      Ayah(
        surah: 2,
        number: 3,
        surahName: 'Al-Baqarah',
        arabic: 'ٱلَّذِينَ يُؤْمِنُونَ بِٱلْغَيْبِ وَيُقِيمُونَ ٱلصَّلَوٰةَ وَمِمَّا رَزَقْنَٰهُمْ يُنفِقُونَ',
        transliteration: 'Allazeena yu\'minoona bilghaibi wa yuqeemoonas salaata wa mimmaa razaqnaahum yunfiqoon',
        meaning: 'Who believe in the unseen, establish prayer, and spend out of what We have provided for them,',
      ),
      Ayah(
        surah: 2,
        number: 4,
        surahName: 'Al-Baqarah',
        arabic: 'وَٱلَّذِينَ يُؤْمِنُونَ بِمَآ أُنزِلَ إِلَيْكَ وَمَآ أُنزِلَ مِن قَبْلِكَ وَبِٱلْءَاخِرَةِ هُمْ يُوقِنُونَ',
        transliteration: 'Wallazeena yu\'minoona bimaaa unzila ilaika wa maaa unzila min qablika wa bil Aakhirati hum yooqinoon',
        meaning: 'And who believe in what has been revealed to you, [O Muhammad], and what was revealed before you, and of the Hereafter they are certain [in faith].',
      ),
      Ayah(
        surah: 2,
        number: 5,
        surahName: 'Al-Baqarah',
        arabic: 'أُو۟لَٰٓئِكَ عَلَىٰ هُدًۭى مِّن رَّبِّهِمْ ۖ وَأُو۟لَٰٓئِكَ هُمُ ٱلْمُفْلِحُونَ',
        transliteration: 'Ulaaa\'ika \'alaa hudam mir rabbihim wa ulaaa\'ika humul muflihoon',
        meaning: 'Those are upon [right] guidance from their Lord, and it is those who are the successful.',
      ),
    ];

    const baqarah102 = Ayah(
      surah: 2,
      number: 102,
      surahName: 'Al-Baqarah',
      arabic: 'وَٱتَّبَعُوا۟ مَا تَتْلُوا۟ ٱلشَّيَٰطِينُ عَلَىٰ مُلْكِ سُلَيْمَٰنَ ۖ وَمَا كَفَرَ سُلَيْمَٰنُ وَلَٰكِنَّ ٱلشَّيَٰطِينَ كَفَرُوا۟ يُعَلِّمُونَ ٱلنَّاسَ ٱلسِّحْرَ وَمَآ أُنزِلَ عَلَى ٱلْمَلَكَيْنِ بِبَابِلَ هَٰرُوتَ وَمَٰرُوتَ ۚ وَمَا يُعَلِّمَانِ مِنْ أَحَدٍ حَتَّىٰ يَقُولَآ إِنَّمَا نَحْنُ فِتْنَةٌۭ فَلَا تَكْفُرْ ۖ فَيَتَعَلَّمُونَ مِنْهُمَا مَا يُفَرِّقُونَ بِهِۦ بَيْنَ ٱلْمَرْءِ وَزَوْجِهِۦ ۚ وَمَا هُم بِضَآرِّينَ بِهِۦ مِنْ أَحَدٍ إِلَّا بِإِذْنِ ٱللَّهِ ۚ وَيَتَعَلَّمُونَ مَا يَضُرُّهُمْ وَلَا يَنفَعُهُمْ ۚ وَلَقَدْ عَلِمُوا۟ لَمَنِ ٱشْتَرَىٰهُ مَا لَهُۥ فِى ٱلْءَاخِرَةِ مِنْ خَلَٰقٍۢ ۚ وَلَبِئْسَ مَا شَرَوْا۟ بِهِۦٓ أَنفُسَهُمْ ۚ لَوْ كَانُوا۟ يَعْلَمُونَ',
      transliteration: 'Wattaba\'oo maa tatlush shayaateenu \'alaa mulki Sulaymaan; wa maa kafara Sulaymaanu wa laakinnash shayaateena kafaroo yu\'allimoonan naasas sihr...',
      meaning: 'And they followed [instead] what the devils had recited during the reign of Solomon... But the devils disbelieved, teaching people magic...',
      reference: 'Sihr Nullification',
    );

    const baqarah163_164 = [
      Ayah(
        surah: 2,
        number: 163,
        surahName: 'Al-Baqarah',
        arabic: 'وَإِلَٰهُكُمْ إِلَٰهٌۭ وَٰحِدٌۭ ۖ لَّآ إِلَٰهَ إِلَّا هُوَ ٱلرَّحْمَٰنُ ٱلرَّحِيمُ',
        transliteration: 'Wa ilaahukum illaahunw waahid, laaa ilaaha illaa Huwar Rahmaanur Raheem',
        meaning: 'And your god is one God. There is no deity [worthy of worship] except Him, the Entirely Merciful, the Especially Merciful.',
      ),
      Ayah(
        surah: 2,
        number: 164,
        surahName: 'Al-Baqarah',
        arabic: 'إِنَّ فِى خَلْقِ ٱلسَّمَٰوَٰتِ وَٱلْأَرْضِ وَٱخْتِلَٰفِ ٱلَّيْلِ وَٱلنَّهَارِ وَٱلْفُلْكِ ٱلَّتِى تَجْرِى فِى ٱلْبَحْرِ بِمَا يَنفَعُ ٱلنَّاسَ وَمَآ أَنزَلَ ٱللَّهُ مِنَ ٱلسَّمَآءِ مِن مَّآءٍۢ فَأَحْيَا بِهِ ٱلْأَرْضَ بَعْدَ مَوْتِهَا وَبَثَّ فِيهَا مِن كُلِّ دَآبَّةٍۢ وَتَصْرِيفِ ٱلرِّيَٰحِ وَٱلسَّحَابِ ٱلْمُسَخَّرِ بَيْنَ ٱلسَّمَآءِ وَٱلْأَرْضِ لَءَايَٰتٍۢ لِّقَوْمٍۢ يَعْقِلُونَ',
        transliteration: 'Inna fee khalqis samaawaati wal ardi wakhtilaafil laili wannahaari walfulkil latee tajree fil bahri...',
        meaning: 'Indeed, in the creation of the heavens and earth, and the alternation of the night and the day, and the ships which sail through the sea...',
      ),
    ];

    const baqarah255 = Ayah(
      surah: 2,
      number: 255,
      surahName: 'Al-Baqarah',
      arabic: 'ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ ٱلْحَىُّ ٱلْقَيُّومُ ۚ لَا تَأْخُذُهُۥ سِنَةٌۭ وَلَا نَوْمٌۭ ۚ لَّهُۥ مَا فِى ٱلسَّمَٰوَٰتِ وَمَا فِى ٱلْأَرْضِ ۗ مَن ذَا ٱلَّذِى يَشْفَعُ عِندَهُۥٓ إِلَّا بِإِذْنِهِۦ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَىْءٍۢ مِّنْ عِلْمِهِۦٓ إِلَّا بِمَا شَآءَ ۚ وَسِعَ كُرْسِيُّهُ ٱلسَّمَٰوَٰتِ وَٱلْأَرْضَ ۖ وَلَا يَـُٔودُهُۥ حِفْظُهُمَا ۚ وَهُوَ ٱلْعَلِىُّ ٱلْعَظِيمُ',
      transliteration: 'Allahu laaa ilaaha illaa Huwal Haiyul Qaiyoom; laa taakhuzuhoo sinatunw wa laa nawm...',
      meaning: 'Allah - there is no deity except Him, the Ever-Living, the Sustainer of [all] existence. Neither drowsiness overtakes Him nor sleep...',
      reference: 'Ayat Al-Kursi',
    );

    const baqarah284_286 = [
      Ayah(
        surah: 2,
        number: 284,
        surahName: 'Al-Baqarah',
        arabic: 'لِّلَّهِ مَا فِى ٱلسَّمَٰوَٰتِ وَمَا فِى ٱلْأَرْضِ ۗ وَإِن تُبْدُوا۟ مَا فِىٓ أَنفُسِكُمْ أَوْ تُخْفُوهُ يُحَاسِبْكُم بِهِ ٱللَّهُ ۖ فَيَغْفِرُ لِمَن يَشَآءُ وَيُعَذِّبُ مَن يَشَآءُ ۗ وَٱللَّهُ عَلَىٰ كُلِّ شَىْءٍۢ قَدِيرٌ',
        transliteration: 'Lillaahi maa fis samaawaati wa maa fil ard; wa in tubdoo maa feee anfusikum aw tukhfoohu yuhaasibkum bihil laah...',
        meaning: 'To Allah belongs whatever is in the heavens and whatever is in the earth. Whether you show what is within yourselves or conceal it, Allah will bring you to account for it...',
      ),
      Ayah(
        surah: 2,
        number: 285,
        surahName: 'Al-Baqarah',
        arabic: 'ءَامَنَ ٱلرَّسُولُ بِمَآ أُنزِلَ إِلَيْهِ مِن رَّبِّهِۦ وَٱلْمُؤْمِنُونَ ۚ كُلٌّ ءَامَنَ بِٱللَّهِ وَمَلَٰٓئِكَتِهِۦ وَكُتُبِهِۦ وَرُسُلِهِۦ لَا نُفَرِّقُ بَيْنَ أَحَدٍۢ مِّن رُّسُلِهِۦ ۚ وَقَالُوا۟ سَمِعْنَا وَأَطَعْنَا ۖ غُفْرَانَكَ رَبَّنَا وَإِلَيْكَ ٱلْمَصِيرُ',
        transliteration: 'Aamanar-Rasoolu bimaaa unzila ilaihi mir-Rabbihee walmu\'minoon...',
        meaning: 'The Messenger has believed in what was revealed to him from his Lord, and [so have] the believers. All of them have believed in Allah...',
      ),
      Ayah(
        surah: 2,
        number: 286,
        surahName: 'Al-Baqarah',
        arabic: 'لَا يُكَلِّفُ ٱللَّهُ نَفْسًا إِلَّا وُسْعَهَا ۚ لَهَا مَا كَسَبَتْ وَعَلَيْهَا مَا ٱكْتَسَبَتْ ۗ رَبَّنَا لَا تُؤَاخِذْنَآ إِن نَّسِينَآ أَوْ أَخْطَأْنَا ۚ رَبَّنَا وَلَا تَحْمِلْ عَلَيْنَآ إِصْرًۭا كَمَا حَمَلْتَهُۥ عَلَى ٱلَّذِينَ مِن قَبْلِنَا ۚ رَبَّنَا وَلَا تُحَمِّلْنَا مَا لَا طَاقَةَ لَنَا بِهِۦ ۖ وَٱعْفُ عَنَّا وَٱغْفِرْ لَنَا وَٱرْحَمْنَآ ۚ أَنتَ مَوْلَىٰنَا فَٱنصُرْنَا عَلَى ٱلْقَوْمِ ٱلْكَٰفِرِينَ',
        transliteration: 'Laa yukalliful-laahu nafsan illaa wus\'ahaa; lahaa maa kasabat wa \'alaihaa maktasabat...',
        meaning: 'Allah does not charge a soul except [with that within] its capacity... "Our Lord, do not impose blame upon us if we have forgotten or erred..."',
      ),
    ];

    // 3. Sihr Breaking & Cure Ayats
    final sihrAyahs = [
      const Ayah(
        surah: 7,
        number: 117,
        surahName: 'Al-A\'raf',
        arabic: 'وَأَوْحَيْنَآ إِلَىٰ مُوسَىٰٓ أَنْ أَلْقِ عَصَاكَ ۖ فَإِذَا هِىَ تَلْقَفُ مَا يَأْفِكُونَ',
        transliteration: 'Wa awhaynaaa ilaa Moosaaa an alqi \'asaaka fa-izaa hiya talqafu maa ya\'fikoon',
        meaning: 'And We inspired to Moses, "Throw your staff," and at once it devoured what they were falsifying.',
      ),
      const Ayah(
        surah: 7,
        number: 118,
        surahName: 'Al-A\'raf',
        arabic: 'فَوَقَعَ ٱلْحَقُّ وَبَطَلَ مَا كَانُوا۟ يَعْمَلُونَ',
        transliteration: 'Fawaqa\'al haqqu wa batala maa kaanoo ya\'maloon',
        meaning: 'So the truth was established, and that which they were doing was abolished.',
      ),
      const Ayah(
        surah: 7,
        number: 119,
        surahName: 'Al-A\'raf',
        arabic: 'فَغُلِبُوا۟ هُنَالِكَ وَٱنقَلَبُوا۟ صَٰغِرِينَ',
        transliteration: 'Faghuliboo hunaalika wanqalaboo saaghireen',
        meaning: 'And they [the magicians] were overcome right there and returned debased.',
      ),
      const Ayah(
        surah: 7,
        number: 120,
        surahName: 'Al-A\'raf',
        arabic: 'وَأُلْقِىَ ٱلسَّحَرَةُ سَٰجِدِينَ',
        transliteration: 'Wa ulqiyas saharatu saajideen',
        meaning: 'And the magicians fell down in prostration [to Allah].',
      ),
      const Ayah(
        surah: 10,
        number: 81,
        surahName: 'Yunus',
        arabic: 'فَلَمَّآ أَلْقَوْا۟ قَالَ مُوسَىٰ مَا جِئْتُم بِهِ ٱلسِّحْرُ ۖ إِنَّ ٱللَّهَ سَيُبْطِلُهُۥٓ ۖ إِنَّ ٱللَّهَ لَا يُصْلِحُ عَمَلَ ٱلْمُفْسِدِينَ',
        transliteration: 'Falammaaa alqaw qaala Moosaa maa ji\'tum bihis sihr; innallaaha sayubtiluh; innallaaha laa yuslihu \'amalal mufeideen',
        meaning: 'And when they had thrown, Moses said, "What you have brought is magic. Indeed, Allah will expose its worthlessness. Indeed, Allah does not amend the work of corrupters."',
        reference: 'Nullifying Magic',
      ),
      const Ayah(
        surah: 10,
        number: 82,
        surahName: 'Yunus',
        arabic: 'وَيُحِقُّ ٱللَّهُ ٱلْحَقَّ بِكَلِمَٰتِهِۦ وَلَوْ كَرِهَ ٱلْمُجْرِمُونَ',
        transliteration: 'Wa yuhiqqul laahul haqqa bikalimaatihee wa law karihal mujrimoon',
        meaning: 'And Allah will establish the truth by His words, even if the criminals dislike it.',
      ),
      const Ayah(
        surah: 20,
        number: 69,
        surahName: 'Ta-Ha',
        arabic: 'وَأَلْقِ مَا فِى يَمِينِكَ تَلْقَفْ مَا صَنَعُوٓا۟ ۖ إِنَّمَا صَنَعُوا۟ كَيْدُ سَٰحِرٍۢ ۖ وَلَا يُفْلِحُ ٱلسَّاحِرُ حَيْثُ أَتَىٰ',
        transliteration: 'Wa alqi maa fee yameenika talqaf maa sana\'oo; innamaa sana\'oo kaydu saahir; wa laa yuflihus saahiru haythu ataa',
        meaning: 'And throw what is in your right hand; it will swallow up what they have crafted. What they have crafted is but the trick of a magician, and the magician will not succeed wherever he is.',
        reference: 'Overcoming Sorcery',
      ),
    ];

    // 4. Jinn & Waswas Protection Ayats
    final jinnProtectionAyahs = [
      const Ayah(
        surah: 23,
        number: 115,
        surahName: 'Al-Mu\'minun',
        arabic: 'أَفَحَسِبْتُمْ أَنَّمَا خَلَقْنَٰكُمْ عَبَثًۭا وَأَنَّكُمْ إِلَيْنَا لَا تُرْجَعُونَ',
        transliteration: 'Afahasibtum annamaa khalaqnaakum \'abasanw wa annakum ilainaa laa turja\'oon',
        meaning: 'Then did you think that We created you uselessly and that to Us you would not be returned?',
      ),
      const Ayah(
        surah: 23,
        number: 116,
        surahName: 'Al-Mu\'minun',
        arabic: 'فَتَعَٰلَى ٱللَّهُ ٱلْمَلِكُ ٱلْحَقُّ ۖ لَآ إِلَٰهَ إِلَّا هُوَ رَبُّ ٱلْعَرْشِ ٱلْكَرِيمِ',
        transliteration: 'Fata\'aalal laahul Malikul Haqq; laaa ilaaha illaa Huwa Rabbul \'Arshil Kareem',
        meaning: 'So exalted is Allah, the True King; there is no deity except Him, Lord of the Noble Throne.',
      ),
      const Ayah(
        surah: 37,
        number: 1,
        surahName: 'As-Saffat',
        arabic: 'وَٱلصَّٰٓفَّٰتِ صَفًّۭا',
        transliteration: 'Wassaaffaati saffaa',
        meaning: 'By those [angels] lined up in rows,',
      ),
      const Ayah(
        surah: 37,
        number: 2,
        surahName: 'As-Saffat',
        arabic: 'فَٱلزَّٰجِرَٰتِ زَجْرًۭا',
        transliteration: 'Fazzaajiraati zajraa',
        meaning: 'And those who drive [the clouds],',
      ),
      const Ayah(
        surah: 37,
        number: 7,
        surahName: 'As-Saffat',
        arabic: 'وَحِفْظًۭا مِّن كُلِّ شَيْطَٰنٍۢ مَّارِدٍۢ',
        transliteration: 'Wa hifzam min kulli shaytaanim maarid',
        meaning: 'And as protection against every rebellious devil,',
        reference: 'Protection against Devils',
      ),
      const Ayah(
        surah: 59,
        number: 21,
        surahName: 'Al-Hashr',
        arabic: 'لَوْ أَنزَلْنَا هَٰذَا ٱلْقُرْءَانَ عَلَىٰ جَبَلٍۢ لَّرَأَيْتَهُۥ خَٰشِعًۭا مُّتَصَدِّعًۭا مِّنْ خَشْيَةِ ٱللَّهِ ۚ وَتِلْكَ ٱلْأَمْثَٰلُ نَضْرِبُهَا لِلنَّاسِ لَعَلَّهُمْ يَتَفَكَّرُونَ',
        transliteration: 'Law anzalnaa haazal quraana \'alaa jabalil lara aytahoo khaashi\'am mutasaddi\'am min khashyatil laah...',
        meaning: 'If We had sent down this Quran upon a mountain, you would have seen it humbled and split apart from fear of Allah...',
      ),
      const Ayah(
        surah: 72,
        number: 1,
        surahName: 'Al-Jinn',
        arabic: 'قُلْ أُوحِىَ إِلَىَّ أَنَّهُ ٱسْتَمَعَ نَفَرٌۭ مِّنَ ٱلْجِنِّ فَقَالُوٓا۟ إِنَّا سَمِعْنَا قُرْءَانًا عَجَبًۭا',
        transliteration: 'Qul oohiya ilaiya annahus tama\'a nafarum minal jinni faqoolooo innaa sami\'naa Quraanan \'ajabaa',
        meaning: 'Say, [O Muhammad], "It has been revealed to me that a group of the jinn listened and said, \'Indeed, we have heard an amazing Qur\'an.\'"',
      ),
    ];

    // 5. Evil Eye ('Ayn) & Hasad Protection
    const evilEyeAyahs = [
      Ayah(
        surah: 68,
        number: 51,
        surahName: 'Al-Qalam',
        arabic: 'وَإِن يَكَادُ ٱلَّذِينَ كَفَرُوا۟ لَيُزْلِقُونَكَ بِأَبْصَٰرِهِمْ لَمَّا سَمِعُوا۟ ٱلذِّكْرَ وَيَقُولُونَ إِنَّهُۥ لَمَجْنُونٌۭ',
        transliteration: 'Wa iny-yakaadul lazeena kafaroo layuzliqoonaka bi absaarihim lammaa sami\'uz Zikra wa yaqooloona innahoo lamajnoon',
        meaning: 'And indeed, those who disbelieve would almost make you slip with their eyes when they hear the message, and they say, "Indeed, he is mad."',
        reference: 'Protection against Evil Eye',
      ),
      Ayah(
        surah: 68,
        number: 52,
        surahName: 'Al-Qalam',
        arabic: 'وَمَا هُوَ إِلَّا ذِكْرٌۭ لِّلْعَٰلَمِينَ',
        transliteration: 'Wa maa huwa illaa zikrul lil\'aalameen',
        meaning: 'But it is not except a reminder to the worlds.',
      ),
    ];

    // 6. Al-Mu'awwidhat (Al-Ikhlas, Al-Falaq, An-Nas)
    final ikhlasAyahs = [
      const Ayah(
        surah: 112,
        number: 1,
        surahName: 'Al-Ikhlas',
        arabic: 'قُلْ هُوَ ٱللَّهُ أَحَدٌ',
        transliteration: 'Qul huwal laahu ahad',
        meaning: 'Say, "He is Allah, [who is] One,',
      ),
      const Ayah(
        surah: 112,
        number: 2,
        surahName: 'Al-Ikhlas',
        arabic: 'ٱللَّهُ ٱلصَّمَدُ',
        transliteration: 'Allah hus-samad',
        meaning: 'Allah, the Eternal Refuge.',
      ),
      const Ayah(
        surah: 112,
        number: 3,
        surahName: 'Al-Ikhlas',
        arabic: 'لَمْ يَلِدْ وَلَمْ يُولَدْ',
        transliteration: 'Lam yalid wa lam yoolad',
        meaning: 'He neither begets nor is born,',
      ),
      const Ayah(
        surah: 112,
        number: 4,
        surahName: 'Al-Ikhlas',
        arabic: 'وَلَمْ يَكُن لَّهُۥ كُفُوًا أَحَدٌۢ',
        transliteration: 'Wa lam yakul-lahu kufuwan ahad',
        meaning: 'Nor is there to Him any equivalent."',
      ),
    ];

    final falaqAyahs = [
      const Ayah(
        surah: 113,
        number: 1,
        surahName: 'Al-Falaq',
        arabic: 'قُلْ أَعُوذُ بِرَبِّ ٱلْفَلَقِ',
        transliteration: 'Qul a\'uzoo bi rabbil-falaq',
        meaning: 'Say, "I seek refuge in the Lord of daybreak',
      ),
      const Ayah(
        surah: 113,
        number: 2,
        surahName: 'Al-Falaq',
        arabic: 'مِن شَرِّ مَا خَلَقَ',
        transliteration: 'Min sharri ma khalaq',
        meaning: 'From the evil of that which He created',
      ),
      const Ayah(
        surah: 113,
        number: 3,
        surahName: 'Al-Falaq',
        arabic: 'وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ',
        transliteration: 'Wa min sharri ghasiqin iza waqab',
        meaning: 'And from the evil of darkness when it settles',
      ),
      const Ayah(
        surah: 113,
        number: 4,
        surahName: 'Al-Falaq',
        arabic: 'وَمِن شَرِّ ٱلنَّفَّٰثَٰتِ فِى ٱلْعُقَدِ',
        transliteration: 'Wa min sharrin-naffaa-thaati fil \'uqad',
        meaning: 'And from the evil of the blowers in knots',
      ),
      const Ayah(
        surah: 113,
        number: 5,
        surahName: 'Al-Falaq',
        arabic: 'وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ',
        transliteration: 'Wa min shar ri haasidin iza hasad',
        meaning: 'And from the evil of an envier when he envies."',
      ),
    ];

    final nasAyahs = [
      const Ayah(
        surah: 114,
        number: 1,
        surahName: 'An-Nas',
        arabic: 'قُلْ أَعُوذُ بِرَبِّ ٱلنَّاسِ',
        transliteration: 'Qul a\'uzu birabbin naas',
        meaning: 'Say, "I seek refuge in the Lord of mankind,',
      ),
      const Ayah(
        surah: 114,
        number: 2,
        surahName: 'An-Nas',
        arabic: 'مَلِكِ ٱلنَّاسِ',
        transliteration: 'Malikin naas',
        meaning: 'The Sovereign of mankind.',
      ),
      const Ayah(
        surah: 114,
        number: 3,
        surahName: 'An-Nas',
        arabic: 'إِلَٰهِ ٱلنَّاسِ',
        transliteration: 'Ilaahin naas',
        meaning: 'The God of mankind,',
      ),
      const Ayah(
        surah: 114,
        number: 4,
        surahName: 'An-Nas',
        arabic: 'مِن شَرِّ ٱلْوَسْوَاسِ ٱلْخَنَّاسِ',
        transliteration: 'Min sharril was waasil khannaas',
        meaning: 'From the evil of the retreating whisperer -',
      ),
      const Ayah(
        surah: 114,
        number: 5,
        surahName: 'An-Nas',
        arabic: 'ٱلَّذِى يُوَسْوِسُ فِى صُدُورِ ٱلنَّاسِ',
        transliteration: 'Al lazee yuwas wisu fee sudoorin naas',
        meaning: 'Who whispers [evil] into the breasts of mankind -',
      ),
      const Ayah(
        surah: 114,
        number: 6,
        surahName: 'An-Nas',
        arabic: 'مِنَ ٱلْجِنَّةِ وَٱلنَّاسِ',
        transliteration: 'Minal jinnati wan naas',
        meaning: 'From among the jinn and mankind."',
      ),
    ];

    // 7. Authentic Prophetic Duas for Ruqyah from Sunnah
    final propheticDuas = [
      const Ayah(
        surah: 0,
        number: 1,
        surahName: 'Dua of Jibril (AS) for the Prophet',
        arabic: 'بِسْمِ اللَّهِ أَرْقِيكَ، مِنْ كُلِّ شَيْءٍ يُؤْذِيكَ، مِنْ شَرِّ كُلِّ نَفْسٍ أَوْ عَيْنِ حَاسِدٍ، اللَّهُ يَشْفِيكَ، بِسْمِ اللَّهِ أَرْقِيكَ',
        transliteration: 'Bismillahi arqeek, min kulli shay\'in yu\'dheek, min sharri kulli nafsin aw \'ayni haasid, Allahu yashfeek, bismillahi arqeek.',
        meaning: 'In the Name of Allah I recite over you (for healing), from everything that harms you, from the evil of every soul or envious eye. May Allah cure you; in the Name of Allah I recite over you.',
        reference: 'Sahih Muslim 2186',
        customAudioUrl: 'https://everyayah.com/data/quran_dua/dua_jibril.mp3',
      ),
      const Ayah(
        surah: 0,
        number: 2,
        surahName: 'Prophetic Dua for Healing & Cure',
        arabic: 'اللَّهُمَّ رَبَّ النَّاسِ، أَذْهِبِ الْبَأْسَ، اشْفِ أَنْتَ الشَّافِي، لَا شِفَاءَ إِلَّا شِفَاؤُكَ، شِفَاءً لَا يُغَادِرُ سَقَمًا',
        transliteration: 'Allahumma Rabban-naas, adh-hibil-ba\'s, ishfi Antash-Shaafi, laa shifaa\'a illaa shifaa\'uk, shifaa\'an laa yughaadiru saqama.',
        meaning: 'O Allah, Lord of mankind, remove the illness and heal, for You are the Healer. There is no cure except Your cure, a cure that leaves behind no disease.',
        reference: 'Sahih Al-Bukhari 5743',
        customAudioUrl: 'https://everyayah.com/data/quran_dua/dua_shifa.mp3',
      ),
      const Ayah(
        surah: 0,
        number: 3,
        surahName: 'Dua for Physical Pain in the Body',
        arabic: 'بِسْمِ اللَّهِ (ثَلَاثًا)، أَعُوذُ بِاللَّهِ وَقُدْرَتِهِ مِنْ شَرِّ مَا أَجِدُ وَأُحَاذِرُ (سَبْعَ مَرَّاتٍ)',
        transliteration: 'Bismillah (3x), A\'udhu billahi wa qudratihi min sharri ma ajidu wa uhadhir (7x).',
        meaning: 'In the name of Allah (3 times). I seek refuge in Allah and His omnipotence from the evil of what I feel and fear (7 times).',
        reference: 'Sahih Muslim 2202',
        customAudioUrl: 'https://everyayah.com/data/quran_dua/dua_pain.mp3',
      ),
      const Ayah(
        surah: 0,
        number: 4,
        surahName: 'Dua Against Evil Eye & Poison',
        arabic: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّةِ مِنْ كُلِّ شَيْطَانٍ وَهَامَّةٍ، وَمِنْ كُلِّ عَيْنٍ لَامَّةٍ',
        transliteration: 'A\'udhu bi kalimatillahit-tammati min kulli shaytanin wa hammah, wa min kulli \'aynin lammah.',
        meaning: 'I seek refuge in the perfect words of Allah from every devil and poisonous creature, and from every evil envious eye.',
        reference: 'Sahih Al-Bukhari 3371',
        customAudioUrl: 'https://everyayah.com/data/quran_dua/dua_evil_eye.mp3',
      ),
      const Ayah(
        surah: 0,
        number: 5,
        surahName: 'Dua for Protection from All Harm',
        arabic: 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
        transliteration: 'Bismillahil-ladhee la yadurru ma\'asmihi shay\'un fil-ardi wa la fis-samaa\'i wa Huwas-Samee\'ul-\'Aleem.',
        meaning: 'In the Name of Allah with whose Name nothing can cause harm on earth nor in the heavens, and He is the All-Hearing, the All-Knowing.',
        reference: 'Sunan Abi Dawood 5088',
        customAudioUrl: 'https://everyayah.com/data/quran_dua/dua_protection.mp3',
      ),
      const Ayah(
        surah: 0,
        number: 6,
        surahName: 'Dua for Refuge in Creation',
        arabic: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
        transliteration: 'A\'udhu bi kalimatillahit-tammati min sharri ma khalaq.',
        meaning: 'I seek refuge in the perfect words of Allah from the evil of that which He has created.',
        reference: 'Sahih Muslim 2708',
        customAudioUrl: 'https://everyayah.com/data/quran_dua/dua_refuge.mp3',
      ),
      const Ayah(
        surah: 0,
        number: 7,
        surahName: 'Dua for Sick Person (7 Times)',
        arabic: 'أَسْأَلُ اللَّهَ الْعَظِيمَ رَبَّ الْعَرْشِ الْعَظِيمِ أَنْ يَشْفِيَكَ',
        transliteration: 'As\'alullahal-\'Azeema Rabbal-\'Arshil-\'Azeemi an yashfiyak.',
        meaning: 'I ask Allah the Almighty, Lord of the Magnificent Throne, to cure you.',
        reference: 'Jami\' at-Tirmidhi 2083',
        customAudioUrl: 'https://everyayah.com/data/quran_dua/dua_cure_seven.mp3',
      ),
      const Ayah(
        surah: 21,
        number: 87,
        surahName: 'Dua of Prophet Yunus (AS) in Distress',
        arabic: 'لَّآ إِلَٰهَ إِلَّآ أَنتَ سُبْحَٰنَكَ إِنِّى كُنتُ مِنَ ٱلظَّٰلِمِينَ',
        transliteration: 'Laaa ilaaha illaaa Anta subhaanaka innee kuntu minaz-zaalimeen.',
        meaning: 'There is no deity except You; exalted are You. Indeed, I have been of the wrongdoers.',
        reference: 'Surah Al-Anbiya 21:87',
      ),
      const Ayah(
        surah: 9,
        number: 129,
        surahName: 'Dua of Tawakkul & Deliverance',
        arabic: 'حَسْبِىَ ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ ۖ عَلَيْهِ تَوَكَّلْتُ ۖ وَهُوَ رَبُّ ٱلْعَرْشِ ٱلْعَظِيمِ',
        transliteration: 'Hasbiyallaahu laaa ilaaha illaa Huwa \'alayhi tawakkaltu wa Huwa Rabbul-\'Arshil-\'Azeem.',
        meaning: 'Sufficient for me is Allah; there is no deity except Him. On Him I have relied, and He is the Lord of the Great Throne.',
        reference: 'Surah At-Tawbah 9:129',
      ),
      const Ayah(
        surah: 0,
        number: 10,
        surahName: 'Dua of Great Relief in Calamity',
        arabic: 'لَا إِلَهَ إِلَّا اللَّهُ الْعَظِيمُ الْحَلِيمُ، لَا إِلَهَ إِلَّا اللَّهُ رَبُّ الْعَرْشِ الْعَظِيمِ، لَا إِلَهَ إِلَّا اللَّهُ رَبُّ السَّمَاوَاتِ وَرَبُّ الْأَرْضِ وَرَبُّ الْعَرْشِ الْكَرِيمِ',
        transliteration: 'Laa ilaaha illallaahul-\'Azeemul-Haleem, laa ilaaha illallaahu Rabbul-\'Arshil-\'Azeem, laa ilaaha illallaahu Rabbus-samaawaati wa Rabbul-ardi wa Rabbul-\'Arshil-Kareem.',
        meaning: 'There is no deity except Allah, the Magnificent, the Forbearing. There is no deity except Allah, Lord of the Magnificent Throne. There is no deity except Allah, Lord of the heavens and Lord of the earth, and Lord of the Noble Throne.',
        reference: 'Sahih Al-Bukhari 6345',
        customAudioUrl: 'https://everyayah.com/data/quran_dua/dua_calamity.mp3',
      ),
    ];

    // Build Curated Playlists
    _playlistRegistry['ruqyah_full'] = RecitationContent(
      id: 'ruqyah_full',
      title: 'Full Ruqyah Ash-Shar\'iyyah',
      arabicTitle: 'الرقية الشرعية الكاملة',
      subtitle: 'Complete Quran Ayats & Prophetic Duas',
      category: 'Complete Ruqyah',
      ayahs: [
        ...fatihahAyahs,
        ...baqarah1_5,
        baqarah102,
        ...baqarah163_164,
        baqarah255,
        ...baqarah284_286,
        ...sihrAyahs,
        ...jinnProtectionAyahs,
        ...evilEyeAyahs,
        ...ikhlasAyahs,
        ...falaqAyahs,
        ...nasAyahs,
        ...propheticDuas.take(4),
      ],
    );

    _playlistRegistry['ruqyah_duas'] = RecitationContent(
      id: 'ruqyah_duas',
      title: 'Prophetic Ruqyah Duas',
      arabicTitle: 'أدعية الرقية من السنة',
      subtitle: '10 Authentic Healing Duas from Hadith',
      category: 'Prophetic Duas',
      ayahs: propheticDuas,
    );

    _playlistRegistry['ruqyah_sihr'] = RecitationContent(
      id: 'ruqyah_sihr',
      title: 'Sihr (Magic) Nullification',
      arabicTitle: 'رقية إبطال السحر',
      subtitle: 'Verses of Moses & Divine Deliverance',
      category: 'By Condition',
      ayahs: [
        ...fatihahAyahs,
        baqarah102,
        ...sihrAyahs,
        ...falaqAyahs,
        ...nasAyahs,
      ],
    );

    _playlistRegistry['ruqyah_ayn'] = RecitationContent(
      id: 'ruqyah_ayn',
      title: 'Evil Eye & Envy Protection',
      arabicTitle: 'رقية العين والحسد',
      subtitle: 'Surah Al-Qalam & Al-Mu\'awwidhat',
      category: 'By Condition',
      ayahs: [
        ...fatihahAyahs,
        baqarah255,
        ...evilEyeAyahs,
        ...ikhlasAyahs,
        ...falaqAyahs,
        ...nasAyahs,
        propheticDuas[3], // Dua against evil eye
      ],
    );

    _playlistRegistry['ruqyah_jinn'] = RecitationContent(
      id: 'ruqyah_jinn',
      title: 'Jinn & Waswas Expulsion',
      arabicTitle: 'رقية طرد الجن والوسواس',
      subtitle: 'As-Saffat, Al-Hashr & An-Nas',
      category: 'By Condition',
      ayahs: [
        ...fatihahAyahs,
        baqarah255,
        ...jinnProtectionAyahs,
        ...nasAyahs,
        propheticDuas[4], // Bismillahil-ladhi la yadurru
      ],
    );

    _playlistRegistry['rec_1'] = RecitationContent(
      id: 'rec_1',
      title: 'Surah Al-Baqarah',
      arabicTitle: 'سورة البقرة',
      subtitle: 'Ayat 1–5, 163–164, 255, 285–286',
      category: 'Quran Ruqyah',
      ayahs: [
        ...baqarah1_5,
        ...baqarah163_164,
        baqarah255,
        baqarah284_286[1],
        baqarah284_286[2],
      ],
    );

    _playlistRegistry['rec_2'] = const RecitationContent(
      id: 'rec_2',
      title: 'Ayat Al-Kursi',
      arabicTitle: 'آية الكرسي',
      subtitle: 'The Greatest Verse of Protection',
      category: 'Quran Ruqyah',
      ayahs: [baqarah255],
    );

    _playlistRegistry['rec_3'] = RecitationContent(
      id: 'rec_3',
      title: 'Al-Mu\'awwidhatain',
      arabicTitle: 'المعوذتان',
      subtitle: 'Surah Al-Falaq & Surah An-Nas',
      category: 'Quran Ruqyah',
      ayahs: [...falaqAyahs, ...nasAyahs],
    );

    _playlistRegistry['rec_fatihah'] = RecitationContent(
      id: 'rec_fatihah',
      title: 'Surah Al-Fatihah',
      arabicTitle: 'سورة الفاتحة',
      subtitle: 'Ash-Shifa (The Curing Surah)',
      category: 'Quran Ruqyah',
      ayahs: fatihahAyahs,
    );

    _playlistRegistry['emergency'] = RecitationContent(
      id: 'emergency',
      title: 'Emergency Ruqyah',
      arabicTitle: 'الرقية الشرعية الطارئة',
      subtitle: 'Immediate Calming & Spiritual Shield',
      category: 'Complete Ruqyah',
      ayahs: [
        ...fatihahAyahs,
        baqarah255,
        baqarah284_286[1],
        baqarah284_286[2],
        ...ikhlasAyahs,
        ...falaqAyahs,
        ...nasAyahs,
        propheticDuas[0],
        propheticDuas[1],
      ],
    );

    // Also index every individual Ayah and Dua into cache
    for (final playlist in _playlistRegistry.values) {
      for (final a in playlist.ayahs) {
        final key = a.isDua ? a.ref : '${a.surah}:${a.number}';
        _cachedAyahs[key] = a;
      }
    }
  }
}
