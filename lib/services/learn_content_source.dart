import 'package:flutter/foundation.dart';

import '../data/course_samples.dart';
import '../data/learn_samples.dart';
import '../models/course_model.dart';
import '../models/learn_lesson_model.dart';
import 'firebase_service.dart';

/// Where Courses and Learn read their content from.
///
/// Reads Firestore, but falls back to the built-in samples whenever the real
/// source is empty, errors, or cannot even be started (Firebase not
/// initialised, e.g. in widget tests). Every stream emits at least once, so a
/// screen never stays blank. Real, non-empty data always wins.
class LearnContentSource {
  LearnContentSource({
    Stream<List<CourseModel>> Function()? courses,
    Stream<List<LearnLesson>> Function()? lessons,
  }) : _courses = courses ?? FirebaseService.getCoursesStream,
       _lessons = lessons ?? FirebaseService.getLearnLessonsStream;

  static LearnContentSource instance = LearnContentSource();

  final Stream<List<CourseModel>> Function() _courses;
  final Stream<List<LearnLesson>> Function() _lessons;

  Stream<List<CourseModel>> courses() =>
      _withFallback<CourseModel>(_courses, kSampleCourses, 'courses');

  Stream<List<LearnLesson>> lessons() =>
      _withFallback<LearnLesson>(_lessons, kSampleLearnLessons, 'lessons');

  static Stream<List<T>> _withFallback<T>(
    Stream<List<T>> Function() source,
    List<T> samples,
    String label,
  ) async* {
    var emitted = false;
    try {
      // The factory call itself can throw synchronously (no Firebase app).
      await for (final items in source()) {
        emitted = true;
        yield items.isEmpty ? samples : items;
      }
    } catch (e) {
      debugPrint('LearnContentSource($label): falling back to samples: $e');
    }
    if (!emitted) yield samples;
    // An error after real data was emitted leaves that data on screen.
  }
}
