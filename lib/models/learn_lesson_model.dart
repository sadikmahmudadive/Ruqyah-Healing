enum LearnLessonKind { video, article }

/// One free lesson in the Learn section, a document in the Firestore
/// `learn_lessons` collection. Learn is always free: there is deliberately no
/// price, lock, preview or certificate here (those belong to paid Courses).
///
///   title, category_id, kind ("video" | "article"), video_url, body,
///   duration_minutes, thumbnail_url (optional), order
class LearnLesson {
  final String id;
  final String title;
  final String categoryId;
  final LearnLessonKind kind;
  final String videoUrl;
  final String body;
  final int durationMinutes;
  final String? thumbnailUrl;
  final int order;

  const LearnLesson({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.kind,
    this.videoUrl = '',
    this.body = '',
    this.durationMinutes = 0,
    this.thumbnailUrl,
    this.order = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category_id': categoryId,
      'kind': kind.name,
      'video_url': videoUrl,
      'body': body,
      'duration_minutes': durationMinutes,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      'order': order,
    };
  }

  factory LearnLesson.fromMap(Map<String, dynamic> map, String docId) {
    return LearnLesson(
      id: docId,
      title: map['title'] ?? '',
      categoryId: map['category_id'] ?? '',
      kind: map['kind'] == 'article'
          ? LearnLessonKind.article
          : LearnLessonKind.video,
      videoUrl: map['video_url'] ?? '',
      body: map['body'] ?? '',
      durationMinutes: (map['duration_minutes'] as num?)?.toInt() ?? 0,
      thumbnailUrl: map['thumbnail_url'],
      order: (map['order'] as num?)?.toInt() ?? 0,
    );
  }
}
