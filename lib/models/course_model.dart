/// How long a visitor may watch a paid course's preview video before the
/// player stops and asks them to enrol.
const Duration kPreviewLimit = Duration(seconds: 10);

/// Minimum quiz score (percent) needed to pass a course quiz.
const int kQuizPassPercent = 70;

class CourseModel {
  final String courseId;
  final String title;
  final String description;
  final String instructorId;
  final double priceBdt;
  final List<SyllabusModule> syllabus;
  final List<Quiz> quizzes;
  final String categoryId;
  final String level;
  final String instructorName;
  final bool isInstructorVerified;
  final String? thumbnailUrl;
  final double rating;
  final int reviewCount;
  final String? previewVideoUrl;

  const CourseModel({
    required this.courseId,
    required this.title,
    required this.description,
    required this.instructorId,
    required this.priceBdt,
    required this.syllabus,
    required this.quizzes,
    this.categoryId = '',
    this.level = '',
    this.instructorName = '',
    this.isInstructorVerified = false,
    this.thumbnailUrl,
    this.rating = 0,
    this.reviewCount = 0,
    this.previewVideoUrl,
  });

  /// Every lesson of every module, in syllabus order.
  List<Lesson> get allLessons => [for (final m in syllabus) ...m.lessons];

  /// The video shown as the free preview: the explicit preview url, else the
  /// first lesson's video, else an empty string.
  String get previewUrl {
    final explicit = previewVideoUrl;
    if (explicit != null && explicit.isNotEmpty) return explicit;
    final lessons = allLessons;
    return lessons.isEmpty ? '' : lessons.first.videoUrl;
  }

  Map<String, dynamic> toFirestore() {
    return {
      'course_id': courseId,
      'title': title,
      'description': description,
      'instructor_id': instructorId,
      'price_bdt': priceBdt,
      'syllabus': syllabus.map((e) => e.toMap()).toList(),
      'quizzes': quizzes.map((e) => e.toMap()).toList(),
      'category_id': categoryId,
      'level': level,
      'instructor_name': instructorName,
      'instructor_verified': isInstructorVerified,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      'rating': rating,
      'review_count': reviewCount,
      if (previewVideoUrl != null) 'preview_video_url': previewVideoUrl,
    };
  }

  factory CourseModel.fromMap(Map<String, dynamic> map, String docId) {
    return CourseModel(
      courseId: map['course_id'] ?? docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      instructorId: map['instructor_id'] ?? '',
      priceBdt: (map['price_bdt'] as num?)?.toDouble() ?? 0.0,
      syllabus: (map['syllabus'] as List? ?? [])
          .map((e) => SyllabusModule.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      quizzes: (map['quizzes'] as List? ?? [])
          .map((e) => Quiz.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      categoryId: map['category_id'] ?? '',
      level: map['level'] ?? '',
      instructorName: map['instructor_name'] ?? '',
      isInstructorVerified: map['instructor_verified'] ?? false,
      thumbnailUrl: map['thumbnail_url'],
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (map['review_count'] as num?)?.toInt() ?? 0,
      previewVideoUrl: map['preview_video_url'],
    );
  }
}

class SyllabusModule {
  final String moduleId;
  final String moduleTitle;
  final List<Lesson> lessons;

  const SyllabusModule({
    required this.moduleId,
    required this.moduleTitle,
    required this.lessons,
  });

  Map<String, dynamic> toMap() {
    return {
      'module_id': moduleId,
      'module_title': moduleTitle,
      'lessons': lessons.map((e) => e.toMap()).toList(),
    };
  }

  factory SyllabusModule.fromMap(Map<String, dynamic> map) {
    return SyllabusModule(
      moduleId: map['module_id'] ?? '',
      moduleTitle: map['module_title'] ?? '',
      lessons: (map['lessons'] as List? ?? [])
          .map((e) => Lesson.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class Lesson {
  final String lessonId;
  final String title;
  final String videoUrl; // Streamed securely via Cloudflare Stream CDN
  final int durationSeconds;

  const Lesson({
    required this.lessonId,
    required this.title,
    required this.videoUrl,
    this.durationSeconds = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'lesson_id': lessonId,
      'title': title,
      'video_url': videoUrl,
      'duration_seconds': durationSeconds,
    };
  }

  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(
      lessonId: map['lesson_id'] ?? '',
      title: map['title'] ?? '',
      videoUrl: map['video_url'] ?? '',
      durationSeconds: (map['duration_seconds'] as num?)?.toInt() ?? 0,
    );
  }
}

class Quiz {
  final String quizId;
  final String title;
  final List<QuizQuestion> questions;

  const Quiz({
    required this.quizId,
    required this.title,
    required this.questions,
  });

  Map<String, dynamic> toMap() {
    return {
      'quiz_id': quizId,
      'title': title,
      'questions': questions.map((e) => e.toMap()).toList(),
    };
  }

  factory Quiz.fromMap(Map<String, dynamic> map) {
    return Quiz(
      quizId: map['quiz_id'] ?? '',
      title: map['title'] ?? '',
      questions: (map['questions'] as List? ?? [])
          .map((e) => QuizQuestion.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class QuizQuestion {
  final String qId;
  final String question;
  final List<String> options;
  final int correctIndex;

  const QuizQuestion({
    required this.qId,
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  Map<String, dynamic> toMap() {
    return {
      'q_id': qId,
      'question': question,
      'options': options,
      'correct_index': correctIndex,
    };
  }

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      qId: map['q_id'] ?? '',
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctIndex: map['correct_index'] ?? 0,
    );
  }
}

class CourseEnrollment {
  final String userId;
  final double progressPercentage;
  final List<String> completedLessons;
  final int? examScore;
  final bool certificateIssued;
  final String? certificatePdfUrl;
  final bool paid;
  final DateTime? purchasedAt;
  final String? paymentRef;

  const CourseEnrollment({
    required this.userId,
    required this.progressPercentage,
    this.completedLessons = const [],
    this.examScore,
    this.certificateIssued = false,
    this.certificatePdfUrl,
    this.paid = false,
    this.purchasedAt,
    this.paymentRef,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'progress_percentage': progressPercentage,
      'completed_lessons': completedLessons,
      if (examScore != null) 'exam_score': examScore,
      'certificate_issued': certificateIssued,
      if (certificatePdfUrl != null) 'certificate_pdf_url': certificatePdfUrl,
      'paid': paid,
      // Firestore turns a DateTime into a Timestamp on write.
      if (purchasedAt != null) 'purchased_at': purchasedAt,
      if (paymentRef != null) 'payment_ref': paymentRef,
    };
  }

  factory CourseEnrollment.fromMap(Map<String, dynamic> map) {
    return CourseEnrollment(
      userId: map['user_id'] ?? '',
      progressPercentage:
          (map['progress_percentage'] as num?)?.toDouble() ?? 0.0,
      completedLessons: List<String>.from(map['completed_lessons'] ?? []),
      examScore: map['exam_score'],
      certificateIssued: map['certificate_issued'] ?? false,
      certificatePdfUrl: map['certificate_pdf_url'],
      paid: map['paid'] ?? false,
      purchasedAt: _readDate(map['purchased_at']),
      paymentRef: map['payment_ref'],
    );
  }
}

/// Reads a date that may be a DateTime, milliseconds, or a Firestore
/// Timestamp (duck-typed through toDate() so this file stays free of the
/// plugin and can be unit tested).
DateTime? _readDate(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  try {
    return (value as dynamic).toDate() as DateTime;
  } catch (_) {
    return null;
  }
}
