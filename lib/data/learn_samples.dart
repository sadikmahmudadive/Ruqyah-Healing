import '../models/learn_lesson_model.dart';
import 'course_samples.dart' show kSampleVideoUrl;

LearnLesson _video(String categoryId, int order, String title, int minutes) =>
    LearnLesson(
      id: '${categoryId}_$order',
      title: title,
      categoryId: categoryId,
      kind: LearnLessonKind.video,
      videoUrl: kSampleVideoUrl,
      durationMinutes: minutes,
      order: order,
    );

LearnLesson _article(
  String categoryId,
  int order,
  String title,
  int minutes,
  String body,
) => LearnLesson(
  id: '${categoryId}_$order',
  title: title,
  categoryId: categoryId,
  kind: LearnLessonKind.article,
  body: body,
  durationMinutes: minutes,
  order: order,
);

/// Sample free Learn lessons (two per category, one video and one article),
/// used until the Firestore `learn_lessons` collection has data.
final List<LearnLesson> kSampleLearnLessons = [
  _video('quran', 1, 'Starting with the Arabic letters', 6),
  _article(
    'quran',
    2,
    'Why tajweed matters',
    3,
    'Tajweed means giving every letter its due when reciting the Quran. '
        'Begin slowly, listen to a good reciter, and repeat after them. '
        'Short daily practice helps more than one long session a week.',
  ),
  _video('hadis', 1, 'How a hadith is preserved', 7),
  _article(
    'hadis',
    2,
    'Reading a hadith with care',
    4,
    'A hadith has a chain of narrators and a text. Scholars check both '
        'before accepting a report. When you read one, note its source and '
        'its grading, and ask a knowledgeable person if you are unsure.',
  ),
  _video('sirat', 1, 'The early life of the Prophet', 8),
  _article(
    'sirat',
    2,
    'Mercy in the Prophet\'s character',
    4,
    'The seerah shows a leader who was gentle with children, patient '
        'with the sick, and fair even to those who opposed him. These '
        'examples are a guide for how we treat one another.',
  ),
  _video('ruqyah', 1, 'What ruqyah is', 6),
  _article(
    'ruqyah',
    2,
    'A simple daily protection routine',
    3,
    'Many Muslims begin the day with Ayat al-Kursi and the last three '
        'surahs of the Quran, and repeat them in the evening. Keep the '
        'intention sincere and trust that healing is from Allah alone.',
  ),
  _video('hijama', 1, 'Hijama in the prophetic tradition', 7),
  _article(
    'hijama',
    2,
    'Safety before cupping',
    4,
    'Cupping should only be done by a trained practitioner using clean, '
        'single-use equipment. Tell them about any medicines or conditions, '
        'and avoid it on broken or infected skin.',
  ),
  _video('acupuncture', 1, 'The idea of meridians', 6),
  _article(
    'acupuncture',
    2,
    'What to expect at a first session',
    4,
    'A practitioner will first ask about your health history. Fine, '
        'sterile needles are placed at chosen points and left for a short '
        'time. Mention anything unusual so the session can be adjusted.',
  ),
  _video('acupressure', 1, 'Easing a tense neck with pressure', 5),
  _article(
    'acupressure',
    2,
    'Pressing safely at home',
    3,
    'Use the pad of your thumb and apply firm, steady pressure for about '
        'a minute while breathing slowly. It should feel comfortable, never '
        'sharp. If pain persists, speak to a doctor.',
  ),
  _video('homeopathy', 1, 'An introduction to homeopathy', 6),
  _article(
    'homeopathy',
    2,
    'How a homeopath takes your history',
    4,
    'A homeopathic consultation is a long conversation about your '
        'symptoms, sleep, appetite and mood. Use homeopathy alongside, not '
        'instead of, advice from your doctor for serious conditions.',
  ),
  _video('naturopathy', 1, 'Food as the first medicine', 7),
  _article(
    'naturopathy',
    2,
    'Dates, honey and water',
    3,
    'Dates, honey, olive oil and plenty of clean water appear often in '
        'prophetic guidance. Eat them in moderation as part of a balanced '
        'diet, and remember that moderation is itself a teaching.',
  ),
  _video('pathology', 1, 'Reading your first blood report', 8),
  _article(
    'pathology',
    2,
    'What a reference range means',
    4,
    'A reference range shows the values found in most healthy people. A '
        'result slightly outside it is not always a problem, so ask your '
        'doctor to explain it in the context of your health.',
  ),
];
