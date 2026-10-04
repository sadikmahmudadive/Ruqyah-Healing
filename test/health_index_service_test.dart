import 'package:flutter_test/flutter_test.dart';
import 'package:ruqyahhealing/models/user_model.dart';
import 'package:ruqyahhealing/services/health_index_service.dart';

void main() {
  final now = DateTime(2026, 10, 5, 12);

  HealthCheckIn checkIn({
    int pain = 0,
    int stress = 0,
    int sleep = 10,
    List<String> flags = const [],
    DateTime? at,
  }) => HealthCheckIn(
    date: (at ?? now).toIso8601String(),
    pain: pain,
    stress: stress,
    sleep: sleep,
    redFlags: flags,
  );

  HealthProfile profile({
    List<HealthCheckIn> checkIns = const [],
    List<RuqyahAudioLog> logs = const [],
    List<String> symptoms = const [],
    List<String> history = const [],
  }) => HealthProfile(
    medicalHistory: history,
    allergies: const [],
    symptoms: symptoms,
    stressLevelIndex: 5,
    hijamaPointingHistory: const [],
    acupuncturePointLog: const [],
    ruqyahAudioLogs: logs,
    checkIns: checkIns,
  );

  test('empty profile has no score', () {
    final r = HealthIndexService.compute(HealthProfile.empty(), now: now);
    expect(r.score, isNull);
    expect(r.hasData, isFalse);
  });

  test('best check-in with regular Ruqyah listening scores 100', () {
    final logs = [
      for (var i = 0; i < 7; i++)
        RuqyahAudioLog(
          audioId: 'a',
          listenDurationSec: 10 * 60,
          date: now.subtract(Duration(days: i)).toIso8601String(),
        ),
    ];
    final r = HealthIndexService.compute(
      profile(checkIns: [checkIn()], logs: logs),
      now: now,
    );
    expect(r.score, 100);
    expect(r.label, 'Excellent');
  });

  test('worse stress/sleep/pain lowers the score', () {
    final good = HealthIndexService.compute(
      profile(checkIns: [checkIn()]),
      now: now,
    );
    final bad = HealthIndexService.compute(
      profile(checkIns: [checkIn(pain: 8, stress: 9, sleep: 2)]),
      now: now,
    );
    expect(bad.score!, lessThan(good.score!));
    expect(bad.stress!.label, 'High');
    expect(bad.sleep!.label, 'Poor');
  });

  test('conditions reduce the score and are capped', () {
    final base = HealthIndexService.compute(
      profile(checkIns: [checkIn()]),
      now: now,
    );
    final withConditions = HealthIndexService.compute(
      profile(
        checkIns: [checkIn()],
        symptoms: List.filled(10, 's'),
        history: List.filled(10, 'h'),
      ),
      now: now,
    );
    expect(base.score! - withConditions.score!, 16); // 10 + 6 caps
  });

  test('recent red flag lowers the score and adds a warning insight', () {
    final plain = HealthIndexService.compute(
      profile(checkIns: [checkIn()]),
      now: now,
    );
    final flagged = HealthIndexService.compute(
      profile(checkIns: [checkIn(flags: ['Fever or unexplained weight loss'])]),
      now: now,
    );
    expect(plain.score! - flagged.score!, 10);
    expect(flagged.insights.first, contains('doctor'));
  });

  test('trend ends at the headline score', () {
    final r = HealthIndexService.compute(
      profile(
        checkIns: [
          checkIn(stress: 8, at: now.subtract(const Duration(days: 2))),
          checkIn(stress: 4, at: now.subtract(const Duration(days: 1))),
          checkIn(stress: 1),
        ],
      ),
      now: now,
    );
    expect(r.trend.length, 3);
    expect(r.trend.last, r.score);
    expect(r.trend.first, lessThan(r.trend.last));
  });
}
