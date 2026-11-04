import 'package:flutter_test/flutter_test.dart';
import 'package:ruqyahhealing/data/course_samples.dart';
import 'package:ruqyahhealing/data/learn_samples.dart';
import 'package:ruqyahhealing/models/course_model.dart';
import 'package:ruqyahhealing/models/learn_category.dart';
import 'package:ruqyahhealing/models/learn_lesson_model.dart';

void main() {
  const expectedIds = [
    'quran',
    'hadis',
    'sirat',
    'ruqyah',
    'hijama',
    'acupuncture',
    'acupressure',
    'homeopathy',
    'naturopathy',
    'pathology',
  ];

  test('LearnLesson round-trips through toMap/fromMap', () {
    const lesson = LearnLesson(
      id: 'l1',
      title: 'Intro',
      categoryId: 'quran',
      kind: LearnLessonKind.video,
      videoUrl: 'https://example.com/v.mp4',
      body: 'text',
      durationMinutes: 7,
      thumbnailUrl: 'https://example.com/t.png',
      order: 3,
    );
    final copy = LearnLesson.fromMap(lesson.toMap(), 'l1');
    expect(copy.id, 'l1');
    expect(copy.title, 'Intro');
    expect(copy.categoryId, 'quran');
    expect(copy.kind, LearnLessonKind.video);
    expect(copy.videoUrl, 'https://example.com/v.mp4');
    expect(copy.body, 'text');
    expect(copy.durationMinutes, 7);
    expect(copy.thumbnailUrl, 'https://example.com/t.png');
    expect(copy.order, 3);

    final article = LearnLesson.fromMap(
      const LearnLesson(
        id: 'a',
        title: 'A',
        categoryId: 'hadis',
        kind: LearnLessonKind.article,
        body: 'b',
      ).toMap(),
      'a',
    );
    expect(article.kind, LearnLessonKind.article);
    expect(article.thumbnailUrl, isNull);
  });

  test('LearnLesson has no price, preview or certificate keys', () {
    final keys = kSampleLearnLessons.first.toMap().keys.map(
      (k) => k.toLowerCase(),
    );
    for (final bad in ['price', 'preview', 'certificate']) {
      expect(keys.where((k) => k.contains(bad)), isEmpty);
    }
  });

  test(
    'CourseModel.fromMap reads the new fields and defaults missing ones',
    () {
      final full = CourseModel.fromMap({
        'title': 'T',
        'category_id': 'ruqyah',
        'level': 'Beginner',
        'instructor_name': 'Sh. A',
        'instructor_verified': true,
        'thumbnail_url': 'https://example.com/t.png',
        'rating': 4,
        'review_count': 12,
        'preview_video_url': 'https://example.com/p.mp4',
      }, 'c1');
      expect(full.courseId, 'c1');
      expect(full.categoryId, 'ruqyah');
      expect(full.level, 'Beginner');
      expect(full.instructorName, 'Sh. A');
      expect(full.isInstructorVerified, isTrue);
      expect(full.thumbnailUrl, 'https://example.com/t.png');
      expect(full.rating, 4.0);
      expect(full.reviewCount, 12);
      expect(full.previewVideoUrl, 'https://example.com/p.mp4');

      final bare = CourseModel.fromMap({'title': 'T'}, 'c2');
      expect(bare.rating, 0);
      expect(bare.reviewCount, 0);
      expect(bare.categoryId, '');
      expect(bare.thumbnailUrl, isNull);
      expect(bare.previewVideoUrl, isNull);
      expect(bare.isInstructorVerified, isFalse);

      final round = CourseModel.fromMap(full.toFirestore(), 'c1');
      expect(round.categoryId, 'ruqyah');
      expect(round.reviewCount, 12);
      expect(round.previewVideoUrl, 'https://example.com/p.mp4');
    },
  );

  test("previewUrl falls back to the first lesson, and to '' with none", () {
    CourseModel make({String? preview, List<SyllabusModule>? syllabus}) =>
        CourseModel(
          courseId: 'c',
          title: 't',
          description: 'd',
          instructorId: 'i',
          priceBdt: 100,
          syllabus: syllabus ?? const [],
          quizzes: const [],
          previewVideoUrl: preview,
        );

    const modules = [
      SyllabusModule(
        moduleId: 'm1',
        moduleTitle: 'M1',
        lessons: [
          Lesson(lessonId: 'a', title: 'A', videoUrl: 'https://x/a.mp4'),
          Lesson(lessonId: 'b', title: 'B', videoUrl: 'https://x/b.mp4'),
        ],
      ),
      SyllabusModule(
        moduleId: 'm2',
        moduleTitle: 'M2',
        lessons: [
          Lesson(lessonId: 'c', title: 'C', videoUrl: 'https://x/c.mp4'),
        ],
      ),
    ];

    expect(
      make(preview: 'https://x/p.mp4', syllabus: modules).previewUrl,
      'https://x/p.mp4',
    );
    expect(make(syllabus: modules).previewUrl, 'https://x/a.mp4');
    expect(make().previewUrl, '');
    expect(make(syllabus: modules).allLessons.map((l) => l.lessonId), [
      'a',
      'b',
      'c',
    ]);
    expect(
      const Lesson(lessonId: 'a', title: 'A', videoUrl: '').durationSeconds,
      0,
    );
  });

  test('constants', () {
    expect(kPreviewLimit, const Duration(seconds: 10));
    expect(kQuizPassPercent, 70);
  });

  test('kLearnCategories has the 10 ids listed above, all unique', () {
    final ids = kLearnCategories.map((c) => c.id).toList();
    expect(ids, expectedIds);
    expect(ids.toSet().length, 10);
    for (final c in kLearnCategories) {
      expect(c.icon != null || c.iconBuilder != null, isTrue, reason: c.id);
    }
  });

  test('every sample course and lesson uses a known category id', () {
    final ids = kLearnCategories.map((c) => c.id).toSet();
    expect(kSampleCourses.length, 10);
    for (final c in kSampleCourses) {
      expect(ids, contains(c.categoryId));
      expect(c.allLessons.length, greaterThanOrEqualTo(3));
      expect(c.quizzes.length, 1);
      expect(c.quizzes.first.questions.length, 3);
    }
    expect(kSampleCourses.map((c) => c.categoryId).toSet(), ids);
    for (final l in kSampleLearnLessons) {
      expect(ids, contains(l.categoryId));
    }
    for (final id in ids) {
      expect(
        kSampleLearnLessons.where((l) => l.categoryId == id).length,
        greaterThanOrEqualTo(2),
        reason: id,
      );
    }
    expect(kSampleLearnLessons.map((l) => l.kind).toSet(), {
      LearnLessonKind.video,
      LearnLessonKind.article,
    });
  });

  test('CourseEnrollment round-trips paid, purchasedAt and paymentRef', () {
    final when = DateTime.utc(2026, 11, 5, 10, 30);
    final e = CourseEnrollment(
      userId: 'u',
      progressPercentage: 40,
      paid: true,
      purchasedAt: when,
      paymentRef: 'TX123',
    );
    final copy = CourseEnrollment.fromMap(e.toFirestore());
    expect(copy.paid, isTrue);
    expect(copy.purchasedAt?.toUtc(), when);
    expect(copy.paymentRef, 'TX123');

    final plain = CourseEnrollment.fromMap(
      const CourseEnrollment(userId: 'u', progressPercentage: 0).toFirestore(),
    );
    expect(plain.paid, isFalse);
    expect(plain.purchasedAt, isNull);
    expect(plain.paymentRef, isNull);
  });
}
