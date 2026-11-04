import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:ruqyahhealing/models/course_model.dart';
import 'package:ruqyahhealing/services/course_access_service.dart';

class FakeStore implements CourseAccessStore {
  final Map<String, CourseEnrollment> data = {};
  final Map<String, StreamController<CourseEnrollment?>> _controllers = {};
  int saveCount = 0;

  String _key(String courseId, String uid) => '$courseId/$uid';

  @override
  Stream<CourseEnrollment?> watch(String courseId, String uid) async* {
    final key = _key(courseId, uid);
    yield data[key];
    final controller = _controllers.putIfAbsent(
      key,
      () => StreamController<CourseEnrollment?>.broadcast(),
    );
    yield* controller.stream;
  }

  @override
  Future<void> save(String courseId, CourseEnrollment e) async {
    saveCount++;
    final key = _key(courseId, e.userId);
    data[key] = e;
    _controllers[key]?.add(e);
  }
}

CourseModel course({int lessons = 2, int questions = 1, String id = 'c1'}) {
  return CourseModel(
    courseId: id,
    title: 'Course',
    description: '',
    instructorId: 'i',
    priceBdt: 100,
    syllabus: [
      SyllabusModule(
        moduleId: 'm1',
        moduleTitle: 'Module',
        lessons: [
          for (var i = 1; i <= lessons; i++)
            Lesson(lessonId: 'l$i', title: 'L$i', videoUrl: 'v$i'),
        ],
      ),
    ],
    quizzes: questions == 0
        ? const []
        : [
            Quiz(
              quizId: 'q1',
              title: 'Quiz',
              questions: [
                for (var i = 1; i <= questions; i++)
                  QuizQuestion(
                    qId: 'q$i',
                    question: 'Q$i',
                    options: const ['a', 'b'],
                    correctIndex: 0,
                  ),
              ],
            ),
          ],
  );
}

CourseEnrollment enrollment({
  bool paid = true,
  List<String> completed = const ['l1', 'l2'],
  int? score = 100,
}) {
  return CourseEnrollment(
    userId: 'u1',
    progressPercentage: 0,
    completedLessons: completed,
    examScore: score,
    paid: paid,
  );
}

void main() {
  late FakeStore store;
  late CourseAccessService service;

  setUp(() {
    store = FakeStore();
    service = CourseAccessService(store: store, uid: () => 'u1');
  });

  group('purchase', () {
    test('writes a paid enrollment with paymentRef "mock"', () async {
      await service.purchase(course());

      final e = store.data['c1/u1']!;
      expect(e.paid, isTrue);
      expect(e.paymentRef, 'mock');
      expect(e.purchasedAt, isNotNull);
      expect(e.userId, 'u1');
      expect(CourseAccessService.isUnlocked(e), isTrue);
    });

    test('with no signed-in user throws SignInRequiredException and writes nothing', () async {
      final signedOut = CourseAccessService(store: store, uid: () => null);

      await expectLater(
        signedOut.purchase(course()),
        throwsA(isA<SignInRequiredException>()),
      );
      expect(store.saveCount, 0);
      expect(store.data, isEmpty);
    });

    test('merges into an existing enrollment', () async {
      store.data['c1/u1'] = const CourseEnrollment(
        userId: 'u1',
        progressPercentage: 50,
        completedLessons: ['l1'],
        examScore: 80,
      );

      await service.purchase(course());

      final e = store.data['c1/u1']!;
      expect(e.paid, isTrue);
      expect(e.completedLessons, ['l1']);
      expect(e.examScore, 80);
      expect(e.progressPercentage, 50);
    });
  });

  group('isUnlocked', () {
    test('is false for null and for paid:false', () {
      expect(CourseAccessService.isUnlocked(null), isFalse);
      expect(CourseAccessService.isUnlocked(enrollment(paid: false)), isFalse);
      expect(CourseAccessService.isUnlocked(enrollment(paid: true)), isTrue);
    });
  });

  group('markLessonComplete', () {
    test('records the lesson once and updates progressPercentage', () async {
      final c = course(lessons: 4);

      await service.markLessonComplete(c, 'l1');
      await service.markLessonComplete(c, 'l1');

      var e = store.data['c1/u1']!;
      expect(e.completedLessons, ['l1']);
      expect(e.progressPercentage, 25);

      await service.markLessonComplete(c, 'l2');
      e = store.data['c1/u1']!;
      expect(e.completedLessons, ['l1', 'l2']);
      expect(e.progressPercentage, 50);
    });

    test('preserves paid and exam score', () async {
      store.data['c1/u1'] = enrollment(completed: const [], score: 90);

      await service.markLessonComplete(course(), 'l1');

      final e = store.data['c1/u1']!;
      expect(e.paid, isTrue);
      expect(e.examScore, 90);
      expect(e.completedLessons, ['l1']);
    });

    test('progress is 0 for a course with no lessons', () async {
      await service.markLessonComplete(course(lessons: 0), 'x');

      expect(store.data['c1/u1']!.progressPercentage, 0);
    });

    test('with no signed-in user throws and writes nothing', () async {
      final signedOut = CourseAccessService(store: store, uid: () => null);

      await expectLater(
        signedOut.markLessonComplete(course(), 'l1'),
        throwsA(isA<SignInRequiredException>()),
      );
      expect(store.saveCount, 0);
    });
  });

  group('saveExamResult', () {
    test('stores the percent and keeps existing progress', () async {
      store.data['c1/u1'] = enrollment(completed: const ['l1'], score: null);

      await service.saveExamResult(course(), 85);

      final e = store.data['c1/u1']!;
      expect(e.examScore, 85);
      expect(e.paid, isTrue);
      expect(e.completedLessons, ['l1']);
    });

    test('with no signed-in user throws and writes nothing', () async {
      final signedOut = CourseAccessService(store: store, uid: () => null);

      await expectLater(
        signedOut.saveExamResult(course(), 85),
        throwsA(isA<SignInRequiredException>()),
      );
      expect(store.saveCount, 0);
    });
  });

  group('enrollment stream', () {
    test('emits null when signed out', () async {
      final signedOut = CourseAccessService(store: store, uid: () => null);

      expect(await signedOut.enrollment('c1').first, isNull);
    });

    test('emits the stored enrollment', () async {
      store.data['c1/u1'] = enrollment();

      final e = await service.enrollment('c1').first;

      expect(e?.paid, isTrue);
    });
  });

  group('certificateEligible', () {
    final c = course();

    test('true when paid, all lessons done and score passes', () {
      expect(CourseAccessService.certificateEligible(c, enrollment()), isTrue);
    });

    test('false for a null enrollment', () {
      expect(CourseAccessService.certificateEligible(c, null), isFalse);
    });

    test('false when unpaid', () {
      expect(
        CourseAccessService.certificateEligible(c, enrollment(paid: false)),
        isFalse,
      );
    });

    test('false when a lesson is not completed', () {
      expect(
        CourseAccessService.certificateEligible(
          c,
          enrollment(completed: const ['l1']),
        ),
        isFalse,
      );
    });

    test('false when there is no exam score', () {
      expect(
        CourseAccessService.certificateEligible(c, enrollment(score: null)),
        isFalse,
      );
    });

    test('score 69 is false, 70 is true', () {
      expect(
        CourseAccessService.certificateEligible(c, enrollment(score: 69)),
        isFalse,
      );
      expect(
        CourseAccessService.certificateEligible(c, enrollment(score: 70)),
        isTrue,
      );
    });

    test('a course with zero lessons is never eligible', () {
      expect(
        CourseAccessService.certificateEligible(
          course(lessons: 0),
          enrollment(completed: const []),
        ),
        isFalse,
      );
    });

    test('a course with zero quiz questions is never eligible', () {
      expect(
        CourseAccessService.certificateEligible(
          course(questions: 0),
          enrollment(),
        ),
        isFalse,
      );
    });
  });
}
