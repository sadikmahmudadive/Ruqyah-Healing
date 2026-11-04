import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/course_samples.dart';
import '../data/learn_samples.dart';
import '../models/course_model.dart';
import '../models/learn_lesson_model.dart';
import 'firebase_service.dart';

/// Where Courses and Learn read their content from.
///
/// Reads Firestore, but falls back to the built-in samples whenever the real
/// source is empty, errors, cannot even be started (Firebase not initialised,
/// e.g. in widget tests) or stays silent for [emptyTimeout]. Every stream
/// emits at least once, so a screen never stays blank. Real, non-empty data
/// always wins, including data that arrives after the timeout sample.
///
/// Error contract: there is deliberately no retry or backoff. If the source
/// errors before emitting, the stream emits the samples and then completes;
/// if it errors after real data was emitted, that data stays and the stream
/// completes. Consumers re-subscribe when their State is rebuilt (the tab
/// subtree is recreated on tab switch).
class LearnContentSource {
  LearnContentSource({
    Stream<List<CourseModel>> Function()? courses,
    Stream<List<LearnLesson>> Function()? lessons,
    this.emptyTimeout = const Duration(seconds: 4),
  }) : _courses = courses ?? FirebaseService.getCoursesStream,
       _lessons = lessons ?? FirebaseService.getLearnLessonsStream;

  static LearnContentSource instance = LearnContentSource();

  /// How long a silent source may stay silent before the samples are shown.
  final Duration emptyTimeout;

  final Stream<List<CourseModel>> Function() _courses;
  final Stream<List<LearnLesson>> Function() _lessons;

  Stream<List<CourseModel>> courses() =>
      _withFallback<CourseModel>(_courses, kSampleCourses, 'courses');

  Stream<List<LearnLesson>> lessons() =>
      _withFallback<LearnLesson>(_lessons, kSampleLearnLessons, 'lessons');

  Stream<List<T>> _withFallback<T>(
    Stream<List<T>> Function() source,
    List<T> samples,
    String label,
  ) {
    late final StreamController<List<T>> controller;
    StreamSubscription<List<T>>? sub;
    Timer? timer;
    var emitted = false;

    void emit(List<T> items) {
      emitted = true;
      timer?.cancel();
      if (!controller.isClosed) controller.add(items);
    }

    void finish() {
      timer?.cancel();
      if (!controller.isClosed) controller.close();
    }

    void fail(Object e) {
      debugPrint('LearnContentSource($label): falling back to samples: $e');
      if (!emitted) emit(samples);
      finish();
    }

    controller = StreamController<List<T>>(
      onListen: () {
        timer = Timer(emptyTimeout, () {
          // Keep the subscription: real data still replaces the samples.
          if (!emitted) emit(samples);
        });
        try {
          // The factory call itself can throw synchronously (no Firebase app).
          sub = source().listen(
            (items) => emit(items.isEmpty ? samples : items),
            onError: fail,
            onDone: () {
              if (!emitted) emit(samples);
              finish();
            },
          );
        } catch (e) {
          fail(e);
        }
      },
      onPause: () => sub?.pause(),
      onResume: () => sub?.resume(),
      onCancel: () {
        timer?.cancel();
        return sub?.cancel();
      },
    );
    return controller.stream;
  }
}
