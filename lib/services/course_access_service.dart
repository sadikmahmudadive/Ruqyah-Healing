import '../models/course_model.dart';
import 'firebase_service.dart';

/// Where enrollments are read and written. A seam so the access rules can be
/// unit tested without Firebase.
abstract class CourseAccessStore {
  Stream<CourseEnrollment?> watch(String courseId, String uid);
  Future<void> save(String courseId, CourseEnrollment e);
}

/// Production store, backed by courses/{courseId}/enrollments/{uid}.
class FirestoreCourseAccessStore implements CourseAccessStore {
  const FirestoreCourseAccessStore();

  @override
  Stream<CourseEnrollment?> watch(String courseId, String uid) =>
      FirebaseService.watchCourseEnrollment(courseId, uid);

  @override
  Future<void> save(String courseId, CourseEnrollment e) =>
      FirebaseService.saveCourseEnrollment(courseId, e);
}

/// Thrown when an action needs a signed-in user and there is none.
class SignInRequiredException implements Exception {
  const SignInRequiredException();

  @override
  String toString() => 'SignInRequiredException: sign in to continue';
}

/// Decides whether a paid course is unlocked and whether a certificate may be
/// issued. Payment is mocked: [purchase] is the single place a real payment
/// gateway would later be wired in.
class CourseAccessService {
  CourseAccessService({CourseAccessStore? store, String? Function()? uid})
    : _store = store ?? const FirestoreCourseAccessStore(),
      _uid = uid ?? _defaultUid;

  static final CourseAccessService instance = CourseAccessService();

  final CourseAccessStore _store;
  final String? Function() _uid;

  // Read lazily so tests that inject a uid never touch Firebase.
  static String? _defaultUid() => FirebaseService.currentUser?.uid;

  /// The signed-in user's enrollment in [courseId]; null when signed out or
  /// not enrolled.
  Stream<CourseEnrollment?> enrollment(String courseId) {
    final uid = _uid();
    if (uid == null) return Stream<CourseEnrollment?>.value(null);
    return _store.watch(courseId, uid);
  }

  /// Mock purchase: records a paid enrollment, keeping any existing progress.
  Future<void> purchase(CourseModel c) async {
    final uid = _requireUid();
    final existing = await _current(c.courseId, uid);
    await _store.save(
      c.courseId,
      _copy(
        existing ?? _blank(uid),
        paid: true,
        purchasedAt: DateTime.now(),
        paymentRef: 'mock',
      ),
    );
  }

  Future<void> markLessonComplete(CourseModel c, String lessonId) async {
    final uid = _requireUid();
    final existing = await _current(c.courseId, uid) ?? _blank(uid);
    final completed = [...existing.completedLessons];
    if (!completed.contains(lessonId)) completed.add(lessonId);
    final total = c.allLessons.length;
    await _store.save(
      c.courseId,
      _copy(
        existing,
        completedLessons: completed,
        progressPercentage: total == 0 ? 0 : completed.length / total * 100,
      ),
    );
  }

  Future<void> saveExamResult(CourseModel c, int percent) async {
    final uid = _requireUid();
    final existing = await _current(c.courseId, uid) ?? _blank(uid);
    await _store.save(c.courseId, _copy(existing, examScore: percent));
  }

  static bool isUnlocked(CourseEnrollment? e) => e != null && e.paid;

  /// A certificate needs a paid enrollment, every lesson completed and a passing
  /// exam score. A course without lessons or quiz questions can never qualify.
  static bool certificateEligible(CourseModel c, CourseEnrollment? e) {
    if (e == null || !e.paid) return false;
    final lessons = c.allLessons;
    if (lessons.isEmpty) return false;
    if (!c.quizzes.any((q) => q.questions.isNotEmpty)) return false;
    final score = e.examScore;
    if (score == null || score < kQuizPassPercent) return false;
    return lessons.every((l) => e.completedLessons.contains(l.lessonId));
  }

  String _requireUid() {
    final uid = _uid();
    if (uid == null) throw const SignInRequiredException();
    return uid;
  }

  Future<CourseEnrollment?> _current(String courseId, String uid) =>
      _store.watch(courseId, uid).first;

  static CourseEnrollment _blank(String uid) =>
      CourseEnrollment(userId: uid, progressPercentage: 0);

  static CourseEnrollment _copy(
    CourseEnrollment e, {
    double? progressPercentage,
    List<String>? completedLessons,
    int? examScore,
    bool? paid,
    DateTime? purchasedAt,
    String? paymentRef,
  }) {
    return CourseEnrollment(
      userId: e.userId,
      progressPercentage: progressPercentage ?? e.progressPercentage,
      completedLessons: completedLessons ?? e.completedLessons,
      examScore: examScore ?? e.examScore,
      certificateIssued: e.certificateIssued,
      certificatePdfUrl: e.certificatePdfUrl,
      paid: paid ?? e.paid,
      purchasedAt: purchasedAt ?? e.purchasedAt,
      paymentRef: paymentRef ?? e.paymentRef,
    );
  }
}
