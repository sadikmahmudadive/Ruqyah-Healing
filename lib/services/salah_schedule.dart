import 'prayer_times_service.dart';

enum SalahKind { fard, nafl }

/// One prayer in a day's schedule. Times are minutes since midnight, in the
/// local time of the place the schedule is for.
class SalahEntry {
  final String id;
  final String name;
  final String arabic;
  final SalahKind kind;

  /// When the prayer's time opens.
  final int start;

  /// When it closes, or null if it has no fixed end worth showing.
  final int? end;

  /// Short line for the row, e.g. "4 rakat fard".
  final String summary;

  /// Longer notes for the voluntary prayers (empty for fard).
  final String howTo;
  final String note;

  const SalahEntry({
    required this.id,
    required this.name,
    required this.arabic,
    required this.kind,
    required this.start,
    required this.end,
    required this.summary,
    this.howTo = '',
    this.note = '',
  });
}

/// A day's prayers: the five fard prayers from the API, plus Tahajjud, Ishraq
/// and Chast (Duha), worked out from the same API response.
///
/// How the voluntary windows are set:
///   - Tahajjud: from the start of the last third of the night (the API's
///     `Lastthird`) until Fajr.
///   - Ishraq: from 15 minutes after sunrise, once the sun has cleared the
///     horizon, for the following 45 minutes.
///   - Chast (Duha): from a quarter of the way through the daylight hours
///     (sunrise to sunset), once the sun is well up, until 10 minutes before
///     Dhuhr, when prayer is discouraged as the sun is at its peak.
/// Scholars differ a little on these edges, so they are shown as windows, not
/// hard deadlines.
class SalahSchedule {
  /// Minutes after sunrise that Ishraq opens, and how long it stays open.
  static const int ishraqDelay = 15;
  static const int ishraqLength = 45;

  /// Minutes before Dhuhr that Chast ends.
  static const int chastEndsBeforeDhuhr = 10;

  final List<SalahEntry> fard;
  final List<SalahEntry> nafl;
  final int sunrise;

  const SalahSchedule({
    required this.fard,
    required this.nafl,
    required this.sunrise,
  });

  List<SalahEntry> get all => [...fard, ...nafl];

  factory SalahSchedule.from(PrayerTimesModel m, {required DateTime date}) {
    int mins(String t24) => minutesOf(t24);

    final fajr = mins(m.fajr24);
    final sunrise = mins(m.sunrise24);
    final dhuhr = mins(m.dhuhr24);
    final asr = mins(m.asr24);
    final maghrib = mins(m.maghrib24);
    final isha = mins(m.isha24);
    final sunset = mins(m.sunset24);
    final midnight = mins(m.midnight24);
    final lastThird = mins(m.lastThird24);
    final friday = date.weekday == DateTime.friday;

    final fard = <SalahEntry>[
      SalahEntry(
        id: 'fajr',
        name: 'Fajr',
        arabic: 'الفجر',
        kind: SalahKind.fard,
        start: fajr,
        end: sunrise,
        summary: '2 rakat fard',
      ),
      SalahEntry(
        id: 'dhuhr',
        name: friday ? "Jumu'ah" : 'Dhuhr',
        arabic: friday ? 'الجمعة' : 'الظهر',
        kind: SalahKind.fard,
        start: dhuhr,
        end: asr,
        summary: friday ? '2 rakat fard with khutbah' : '4 rakat fard',
      ),
      SalahEntry(
        id: 'asr',
        name: 'Asr',
        arabic: 'العصر',
        kind: SalahKind.fard,
        start: asr,
        end: maghrib,
        summary: '4 rakat fard',
      ),
      SalahEntry(
        id: 'maghrib',
        name: 'Maghrib',
        arabic: 'المغرب',
        kind: SalahKind.fard,
        start: maghrib,
        end: isha,
        summary: '3 rakat fard',
      ),
      SalahEntry(
        id: 'isha',
        name: 'Isha',
        arabic: 'العشاء',
        kind: SalahKind.fard,
        start: isha,
        end: midnight > isha ? midnight : null,
        summary: '4 rakat fard',
      ),
    ];

    final chastStart = sunrise + ((sunset - sunrise) / 4).round();
    final nafl = <SalahEntry>[
      SalahEntry(
        id: 'tahajjud',
        name: 'Tahajjud',
        arabic: 'التهجد',
        kind: SalahKind.nafl,
        start: lastThird,
        end: fajr,
        summary: '2 to 12 rakat, in pairs',
        howTo:
            'Pray after you wake in the last third of the night, before Fajr. '
            'Pray in pairs of two rakat and finish with Witr if you have not '
            'prayed it yet.',
        note:
            'A quiet hour many scholars recommend for dua, istighfar and '
            'private worship.',
      ),
      SalahEntry(
        id: 'ishraq',
        name: 'Ishraq',
        arabic: 'الإشراق',
        kind: SalahKind.nafl,
        start: sunrise + ishraqDelay,
        end: sunrise + ishraqDelay + ishraqLength,
        summary: '2 rakat, up to 4',
        howTo:
            'Stay in remembrance of Allah after Fajr until the sun has risen '
            "about a spear's length, then pray two rakat.",
        note:
            'It is traditionally linked with the reward of a complete Hajj '
            'and Umrah for the one who stays after Fajr in dhikr.',
      ),
      SalahEntry(
        id: 'chast',
        name: 'Chast (Duha)',
        arabic: 'الضحى',
        kind: SalahKind.nafl,
        start: chastStart,
        end: dhuhr - chastEndsBeforeDhuhr,
        summary: '2 to 8 rakat, in pairs',
        howTo:
            'Pray once the sun is well up and before it reaches its peak, '
            'in pairs of two rakat.',
        note:
            'Often prayed as a gift of gratitude for the day. It is a '
            'gentle habit to begin with two rakat.',
      ),
    ];

    return SalahSchedule(fard: fard, nafl: nafl, sunrise: sunrise);
  }

  /// "HH:mm" (or "HH:mm (+06)") to minutes since midnight.
  static int minutesOf(String t24) {
    final clean = t24.split(' ').first.split(':');
    if (clean.length < 2) return 0;
    return (int.tryParse(clean[0]) ?? 0) * 60 + (int.tryParse(clean[1]) ?? 0);
  }

  /// The next fard prayer after [nowMinutes], or null once Isha has begun,
  /// when the next prayer is tomorrow's Fajr.
  SalahEntry? nextFard(int nowMinutes) {
    for (final e in fard) {
      if (e.start > nowMinutes) return e;
    }
    return null;
  }

  /// Whole minutes until [e] opens, or until tomorrow's Fajr (about the same
  /// clock time as today's) when [e] is Fajr and has already passed.
  int minutesUntil(SalahEntry e, int nowMinutes) {
    final diff = e.start - nowMinutes;
    return diff >= 0 ? diff : diff + 24 * 60;
  }

  /// "42 min", "1 h 05 min" or "5 h".
  static String describeWait(int minutes) {
    if (minutes < 60) return '$minutes min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '$h h' : '$h h ${m.toString().padLeft(2, '0')} min';
  }

  /// "4:58 AM" from minutes since midnight.
  static String clock12(int minutes) {
    final m = ((minutes % (24 * 60)) + 24 * 60) % (24 * 60);
    final h = m ~/ 60;
    final mm = (m % 60).toString().padLeft(2, '0');
    final h12 = h % 12 == 0 ? 12 : h % 12;
    return '$h12:$mm ${h < 12 ? 'AM' : 'PM'}';
  }
}
