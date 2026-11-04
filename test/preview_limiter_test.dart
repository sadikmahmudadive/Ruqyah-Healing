import 'package:flutter_test/flutter_test.dart';
import 'package:ruqyahhealing/models/course_model.dart';
import 'package:ruqyahhealing/widgets/learn/preview_limiter.dart';

void main() {
  test('defaults to the app-wide preview limit', () {
    expect(PreviewLimiter().limit, kPreviewLimit);
  });

  test('reached is false before 10s and true at 10s', () {
    final limiter = PreviewLimiter();
    expect(limiter.reached, isFalse);
    limiter.onPosition(const Duration(seconds: 9, milliseconds: 900));
    expect(limiter.reached, isFalse);
    limiter.onPosition(const Duration(seconds: 10));
    expect(limiter.reached, isTrue);
  });

  test('onPosition returns true only once', () {
    final limiter = PreviewLimiter();
    expect(limiter.onPosition(const Duration(seconds: 3)), isFalse);
    expect(limiter.onPosition(const Duration(seconds: 10)), isTrue);
    expect(limiter.onPosition(const Duration(seconds: 10)), isFalse);
    expect(limiter.onPosition(const Duration(seconds: 12)), isFalse);
  });

  test('clampSeek(30s) == 10s and clampSeek(4s) == 4s', () {
    final limiter = PreviewLimiter();
    expect(limiter.clampSeek(const Duration(seconds: 30)), kPreviewLimit);
    expect(
      limiter.clampSeek(const Duration(seconds: 4)),
      const Duration(seconds: 4),
    );
    expect(limiter.clampSeek(const Duration(seconds: -2)), Duration.zero);
  });

  test('reset clears reached so the limit can fire again', () {
    final limiter = PreviewLimiter();
    limiter.onPosition(const Duration(seconds: 11));
    expect(limiter.reached, isTrue);
    limiter.reset();
    expect(limiter.reached, isFalse);
    expect(limiter.onPosition(const Duration(seconds: 10)), isTrue);
  });

  test('honours a custom limit', () {
    final limiter = PreviewLimiter(limit: const Duration(seconds: 5));
    expect(limiter.limit, const Duration(seconds: 5));
    expect(limiter.onPosition(const Duration(seconds: 5)), isTrue);
    expect(
      limiter.clampSeek(const Duration(seconds: 8)),
      const Duration(seconds: 5),
    );
  });
}
