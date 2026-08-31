class CourseModel {
  final String courseId;
  final String title;
  final String description;
  final String instructorId;
  final double priceBdt;
  final List<SyllabusModule> syllabus;
  final List<Quiz> quizzes;

  const CourseModel({
    required this.courseId,
    required this.title,
    required this.description,
    required this.instructorId,
    required this.priceBdt,
    required this.syllabus,
    required this.quizzes,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'course_id': courseId,
      'title': title,
      'description': description,
      'instructor_id': instructorId,
      'price_bdt': priceBdt,
      'syllabus': syllabus.map((e) => e.toMap()).toList(),
      'quizzes': quizzes.map((e) => e.toMap()).toList(),
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

  const Lesson({
    required this.lessonId,
    required this.title,
    required this.videoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'lesson_id': lessonId,
      'title': title,
      'video_url': videoUrl,
    };
  }

  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(
      lessonId: map['lesson_id'] ?? '',
      title: map['title'] ?? '',
      videoUrl: map['video_url'] ?? '',
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

  const CourseEnrollment({
    required this.userId,
    required this.progressPercentage,
    this.completedLessons = const [],
    this.examScore,
    this.certificateIssued = false,
    this.certificatePdfUrl,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'progress_percentage': progressPercentage,
      'completed_lessons': completedLessons,
      if (examScore != null) 'exam_score': examScore,
      'certificate_issued': certificateIssued,
      if (certificatePdfUrl != null) 'certificate_pdf_url': certificatePdfUrl,
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
    );
  }
}
