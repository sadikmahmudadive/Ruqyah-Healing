import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:ruqyahhealing/data/course_samples.dart';
import 'package:ruqyahhealing/data/learn_samples.dart';
import 'package:ruqyahhealing/models/course_model.dart';
import 'package:ruqyahhealing/models/learn_lesson_model.dart';
import 'package:ruqyahhealing/services/learn_content_source.dart';

void main() {
  final realLesson = LearnLesson(
    id: 'real-l',
    title: 'Real lesson',
    categoryId: kSampleLearnLessons.first.categoryId,
    kind: LearnLessonKind.article,
  );
  final realCourse = kSampleCourses.first;

  group('courses', () {
    test('falls back to samples when the source is empty', () async {
      final source = LearnContentSource(
        courses: () => Stream.value(<CourseModel>[]),
      );
      expect(await source.courses().first, kSampleCourses);
    });

    test('falls back to samples when the stream errors', () async {
      final source = LearnContentSource(
        courses: () => Stream<List<CourseModel>>.error(StateError('boom')),
      );
      expect(await source.courses().first, kSampleCourses);
    });

    test('falls back to samples when the factory throws', () async {
      final source = LearnContentSource(
        courses: () => throw StateError('no firebase'),
      );
      expect(await source.courses().first, kSampleCourses);
    });

    test('real data wins when it is non-empty', () async {
      final source = LearnContentSource(
        courses: () => Stream.value([realCourse]),
      );
      expect(await source.courses().first, [realCourse]);
    });

    test('emits samples again when a later snapshot is empty', () async {
      final source = LearnContentSource(
        courses: () => Stream.fromIterable([
          [realCourse],
          <CourseModel>[],
        ]),
      );
      expect(await source.courses().toList(), [
        [realCourse],
        kSampleCourses,
      ]);
    });
  });

  group('lessons', () {
    test('falls back to samples when the source is empty', () async {
      final source = LearnContentSource(
        lessons: () => Stream.value(<LearnLesson>[]),
      );
      expect(await source.lessons().first, kSampleLearnLessons);
    });

    test('falls back to samples when the stream errors', () async {
      final source = LearnContentSource(
        lessons: () => Stream<List<LearnLesson>>.error(StateError('boom')),
      );
      expect(await source.lessons().first, kSampleLearnLessons);
    });

    test('falls back to samples when the factory throws', () async {
      final source = LearnContentSource(
        lessons: () => throw StateError('no firebase'),
      );
      expect(await source.lessons().first, kSampleLearnLessons);
    });

    test('real data wins when it is non-empty', () async {
      final source = LearnContentSource(
        lessons: () => Stream.value([realLesson]),
      );
      expect(await source.lessons().first, [realLesson]);
    });
  });

  test('default instance is safe with no Firebase initialised', () async {
    final c = await LearnContentSource.instance.courses().first;
    final l = await LearnContentSource.instance.lessons().first;
    expect(c, kSampleCourses);
    expect(l, kSampleLearnLessons);
  });

  group('silent source and error contract', () {
    const timeout = Duration(milliseconds: 30);
    const settle = Duration(milliseconds: 120);

    test('a never-emitting source yields samples after the timeout', () async {
      final ctrl = StreamController<List<CourseModel>>();
      addTearDown(ctrl.close);
      final source = LearnContentSource(
        courses: () => ctrl.stream,
        emptyTimeout: timeout,
      );
      expect(await source.courses().first, kSampleCourses);
    });

    test('real data arriving after the timeout is still emitted', () async {
      final ctrl = StreamController<List<CourseModel>>();
      addTearDown(ctrl.close);
      final source = LearnContentSource(
        courses: () => ctrl.stream,
        emptyTimeout: timeout,
      );
      final events = <List<CourseModel>>[];
      final sub = source.courses().listen(events.add);
      addTearDown(sub.cancel);
      await Future<void>.delayed(settle);
      expect(events, [kSampleCourses]);
      ctrl.add([realCourse]);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(events, [
        kSampleCourses,
        [realCourse],
      ]);
    });

    test(
      'the timeout does not emit samples after the source emitted',
      () async {
        final ctrl = StreamController<List<CourseModel>>();
        addTearDown(ctrl.close);
        final source = LearnContentSource(
          courses: () => ctrl.stream,
          emptyTimeout: timeout,
        );
        final events = <List<CourseModel>>[];
        final sub = source.courses().listen(events.add);
        addTearDown(sub.cancel);
        ctrl.add([realCourse]);
        await Future<void>.delayed(settle);
        expect(events, [
          [realCourse],
        ]);
      },
    );

    test(
      'after an error: samples are emitted, then the stream completes',
      () async {
        final source = LearnContentSource(
          lessons: () => Stream<List<LearnLesson>>.error(StateError('boom')),
        );
        expect(await source.lessons().toList(), [kSampleLearnLessons]);
      },
    );
  });
}
