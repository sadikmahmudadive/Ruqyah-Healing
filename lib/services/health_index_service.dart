import '../models/appointment_model.dart';
import '../models/user_model.dart';

enum HealthTone { good, moderate, poor }

/// One breakdown row (Spiritual / Sleep / Stress) on the health screens.
class HealthComponent {
  /// Bar fill, 0..1.
  final double fraction;
  final String label;
  final HealthTone tone;

  const HealthComponent({
    required this.fraction,
    required this.label,
    required this.tone,
  });
}

class HealthIndexResult {
  /// 0-100, or null when there isn't enough data yet.
  final int? score;
  final String label;
  final HealthTone tone;
  final HealthComponent? spiritual;
  final HealthComponent? sleep;
  final HealthComponent? stress;

  /// Recent index values, oldest first. The last entry equals [score].
  final List<int> trend;
  final DateTime? lastUpdated;
  final List<String> insights;

  final int medicalHistoryCount;
  final int allergyCount;
  final int medicationCount;
  final List<String> symptoms;
  final int ruqyahSessions;
  final int hijamaSessions;
  final int acupunctureSessions;

  const HealthIndexResult({
    required this.score,
    required this.label,
    required this.tone,
    this.spiritual,
    this.sleep,
    this.stress,
    this.trend = const [],
    this.lastUpdated,
    this.insights = const [],
    this.medicalHistoryCount = 0,
    this.allergyCount = 0,
    this.medicationCount = 0,
    this.symptoms = const [],
    this.ruqyahSessions = 0,
    this.hijamaSessions = 0,
    this.acupunctureSessions = 0,
  });

  /// Guests and new accounts: nothing to base a score on.
  const HealthIndexResult.empty()
    : this(
        score: null,
        label: 'No data yet',
        tone: HealthTone.moderate,
        insights: const [
          'Complete a daily check-in to get your wellness index.',
        ],
      );

  bool get hasData => score != null;
}

/// Turns a [HealthProfile] into a 0-100 wellness index.
///
/// This is a wellness estimate built from the user's own check-ins and
/// profile, not a medical diagnosis.
class HealthIndexService {
  HealthIndexService._();

  // Component weights; components without data are dropped and the rest
  // are renormalised.
  static const double _wStress = 0.30;
  static const double _wSleep = 0.25;
  static const double _wPain = 0.15;
  static const double _wSpiritual = 0.30;

  static const int _spiritualWindowDays = 14;
  static const int _trendDays = 7;

  static HealthIndexResult compute(
    HealthProfile profile, {
    List<AppointmentModel> appointments = const [],
    DateTime? now,
  }) {
    final at = now ?? DateTime.now();
    final checkIns = _sortedCheckIns(profile);
    final ruqyahLogs = profile.ruqyahAudioLogs;

    final completed = appointments.where((a) => a.status == 'completed');
    final ruqyahSessions =
        ruqyahLogs.length +
        completed.where((a) => a.therapyType.startsWith('Ruqyah')).length;
    final hijamaSessions =
        profile.hijamaPointingHistory.length +
        completed.where((a) => a.therapyType.startsWith('Hijama')).length;
    final acupunctureSessions =
        profile.acupuncturePointLog.length +
        completed.where((a) => a.therapyType.startsWith('Acupuncture')).length;

    final base = HealthIndexResult(
      score: null,
      label: 'No data yet',
      tone: HealthTone.moderate,
      medicalHistoryCount: profile.medicalHistory.length,
      allergyCount: profile.allergies.length,
      medicationCount: profile.medications.length,
      symptoms: profile.symptoms,
      ruqyahSessions: ruqyahSessions,
      hijamaSessions: hijamaSessions,
      acupunctureSessions: acupunctureSessions,
      insights: const ['Complete a daily check-in to get your wellness index.'],
    );

    if (checkIns.isEmpty && ruqyahLogs.isEmpty) return base;

    final current = _scoreAt(profile, checkIns, at);
    final score = current.score;

    // Trend: one point per recent check-in day, scored as of that day.
    final byDay = <String, HealthCheckIn>{};
    for (final c in checkIns) {
      final t = c.timestamp!;
      byDay['${t.year}-${t.month}-${t.day}'] = c;
    }
    final recentDays = byDay.values.toList();
    final trendSource = recentDays.length > _trendDays
        ? recentDays.sublist(recentDays.length - _trendDays)
        : recentDays;
    final trend = [
      for (final c in trendSource) _scoreAt(profile, checkIns, c.timestamp!).score,
    ];
    if (trend.isEmpty) {
      trend.add(score);
    } else {
      trend[trend.length - 1] = score;
    }

    DateTime? lastUpdated = checkIns.isEmpty ? null : checkIns.last.timestamp;
    for (final l in ruqyahLogs) {
      final t = DateTime.tryParse(l.date);
      if (t != null && (lastUpdated == null || t.isAfter(lastUpdated))) {
        lastUpdated = t;
      }
    }

    final tone = _toneForScore(score);
    return HealthIndexResult(
      score: score,
      label: _labelForScore(score),
      tone: tone,
      spiritual: current.spiritual,
      sleep: current.sleep,
      stress: current.stress,
      trend: trend,
      lastUpdated: lastUpdated,
      insights: _insights(current, checkIns, at),
      medicalHistoryCount: base.medicalHistoryCount,
      allergyCount: base.allergyCount,
      medicationCount: base.medicationCount,
      symptoms: base.symptoms,
      ruqyahSessions: ruqyahSessions,
      hijamaSessions: hijamaSessions,
      acupunctureSessions: acupunctureSessions,
    );
  }

  // ───────────────────────────── scoring ──────────────────────────────

  static _Scored _scoreAt(
    HealthProfile profile,
    List<HealthCheckIn> checkIns,
    DateTime asOf,
  ) {
    HealthCheckIn? latest;
    for (final c in checkIns) {
      if (!c.timestamp!.isAfter(asOf)) latest = c;
    }

    // Wellness of each signal, 0 (worst) .. 1 (best).
    final double? stressW = latest == null
        ? null
        : 1 - latest.stress.clamp(0, 10) / 10;
    final double? sleepW = latest == null
        ? null
        : latest.sleep.clamp(0, 10) / 10;
    final double? painW = latest == null
        ? null
        : 1 - latest.pain.clamp(0, 10) / 10;

    final windowStart = asOf.subtract(const Duration(days: _spiritualWindowDays));
    var sessions = 0;
    var seconds = 0;
    for (final l in profile.ruqyahAudioLogs) {
      final t = DateTime.tryParse(l.date);
      if (t != null && t.isAfter(windowStart) && !t.isAfter(asOf)) {
        sessions++;
        seconds += l.listenDurationSec;
      }
    }
    // Target: a session every other day, ~10 minutes each.
    final spiritualW =
        0.5 * (sessions / 7).clamp(0.0, 1.0) +
        0.5 * (seconds / (70 * 60)).clamp(0.0, 1.0);

    var weighted = 0.0;
    var weights = 0.0;
    void add(double? w, double weight) {
      if (w == null) return;
      weighted += w * weight;
      weights += weight;
    }

    add(stressW, _wStress);
    add(sleepW, _wSleep);
    add(painW, _wPain);
    add(spiritualW, _wSpiritual);

    var raw = weights == 0 ? 0.0 : weighted / weights * 100;

    // Ongoing conditions pull the index down a little.
    raw -= (profile.symptoms.length * 2).clamp(0, 10);
    raw -= (profile.medicalHistory.length * 1.5).clamp(0, 6);
    raw -= (profile.allergies.length * 1).clamp(0, 3);

    // A reported red flag in the last 24h is weighed heavily.
    final hasRecentFlag =
        latest != null &&
        latest.redFlags.isNotEmpty &&
        asOf.difference(latest.timestamp!) < const Duration(hours: 24);
    if (hasRecentFlag) raw -= 10;

    final score = raw.round().clamp(0, 100);

    return _Scored(
      score: score,
      spiritual: HealthComponent(
        fraction: spiritualW,
        label: _label(spiritualW, const ['Low', 'Moderate', 'Good']),
        tone: _tone(spiritualW),
      ),
      sleep: sleepW == null
          ? null
          : HealthComponent(
              fraction: sleepW,
              label: _label(sleepW, const ['Poor', 'Moderate', 'Good']),
              tone: _tone(sleepW),
            ),
      // Stress shows the stress level itself (higher bar = more stress).
      stress: stressW == null
          ? null
          : HealthComponent(
              fraction: 1 - stressW,
              label: _label(stressW, const ['High', 'Moderate', 'Low']),
              tone: _tone(stressW),
            ),
      sessionsInWindow: sessions,
      sleepW: sleepW,
      stressW: stressW,
      redFlags: hasRecentFlag ? latest.redFlags : const [],
    );
  }

  static List<HealthCheckIn> _sortedCheckIns(HealthProfile profile) {
    final list = profile.checkIns.where((c) => c.timestamp != null).toList()
      ..sort((a, b) => a.timestamp!.compareTo(b.timestamp!));
    return list;
  }

  static List<String> _insights(
    _Scored s,
    List<HealthCheckIn> checkIns,
    DateTime at,
  ) {
    final out = <String>[];
    if (s.redFlags.isNotEmpty) {
      out.add(
        'You reported a warning sign (${s.redFlags.join(', ').toLowerCase()}). '
        'Please contact a doctor or emergency services.',
      );
    }
    final today =
        checkIns.isNotEmpty &&
        _sameDay(checkIns.last.timestamp!, at);
    if (!today) {
      out.add("Complete today's check-in to keep your index up to date.");
    }
    if (s.stressW != null && s.stressW! < 0.4) {
      out.add(
        'Your stress level is high. A short Ruqyah listening session or '
        'slow breathing may help.',
      );
    }
    if (s.sleepW != null && s.sleepW! < 0.4) {
      out.add('Your sleep quality is low. Try winding down with evening adhkar.');
    }
    if (s.sessionsInWindow == 0) {
      out.add(
        'No Ruqyah sessions in the last $_spiritualWindowDays days. '
        'Regular listening raises your spiritual score.',
      );
    }
    return out.take(3).toList();
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // ───────────────────────────── labels ───────────────────────────────

  static String _labelForScore(int s) {
    if (s >= 80) return 'Excellent';
    if (s >= 65) return 'Good';
    if (s >= 50) return 'Moderate';
    return 'Needs attention';
  }

  static HealthTone _toneForScore(int s) {
    if (s >= 65) return HealthTone.good;
    if (s >= 50) return HealthTone.moderate;
    return HealthTone.poor;
  }

  // labels = [low, mid, high] wellness wording.
  static String _label(double wellness, List<String> labels) {
    if (wellness >= 0.7) return labels[2];
    if (wellness >= 0.4) return labels[1];
    return labels[0];
  }

  static HealthTone _tone(double wellness) {
    if (wellness >= 0.7) return HealthTone.good;
    if (wellness >= 0.4) return HealthTone.moderate;
    return HealthTone.poor;
  }
}

class _Scored {
  final int score;
  final HealthComponent spiritual;
  final HealthComponent? sleep;
  final HealthComponent? stress;
  final int sessionsInWindow;
  final double? sleepW;
  final double? stressW;
  final List<String> redFlags;

  const _Scored({
    required this.score,
    required this.spiritual,
    required this.sleep,
    required this.stress,
    required this.sessionsInWindow,
    required this.sleepW,
    required this.stressW,
    required this.redFlags,
  });
}
