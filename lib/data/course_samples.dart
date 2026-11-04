import '../models/course_model.dart';

/// One public test video used by every sample lesson until real course videos
/// are uploaded.
const String kSampleVideoUrl =
    'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';

QuizQuestion _q(
  String id,
  String question,
  List<String> options,
  int correct,
) => QuizQuestion(
  qId: id,
  question: question,
  options: options,
  correctIndex: correct,
);

CourseModel _course({
  required int n,
  required String categoryId,
  required String title,
  required String instructor,
  required String level,
  required double priceBdt,
  required double rating,
  required int reviewCount,
  required String description,
  required List<String> moduleOne,
  required List<String> moduleTwo,
  required List<QuizQuestion> questions,
}) {
  final id = 'course_$n';
  var lessonNo = 0;
  Lesson lesson(String title) {
    lessonNo++;
    return Lesson(
      lessonId: '${id}_l$lessonNo',
      title: title,
      videoUrl: kSampleVideoUrl,
      durationSeconds: 300 + lessonNo * 60,
    );
  }

  return CourseModel(
    courseId: id,
    title: title,
    description: description,
    instructorId: 'instructor_$n',
    priceBdt: priceBdt,
    categoryId: categoryId,
    level: level,
    instructorName: instructor,
    isInstructorVerified: true,
    rating: rating,
    reviewCount: reviewCount,
    syllabus: [
      SyllabusModule(
        moduleId: '${id}_m1',
        moduleTitle: 'Foundations',
        lessons: moduleOne.map(lesson).toList(),
      ),
      SyllabusModule(
        moduleId: '${id}_m2',
        moduleTitle: 'Practice',
        lessons: moduleTwo.map(lesson).toList(),
      ),
    ],
    quizzes: [
      Quiz(quizId: '${id}_quiz', title: 'Final quiz', questions: questions),
    ],
  );
}

/// Sample paid courses, one per Learn category, used until the Firestore
/// `courses` collection has data.
final List<CourseModel> kSampleCourses = [
  _course(
    n: 1,
    categoryId: 'quran',
    title: 'Quran Recitation & Tajweed Mastery',
    instructor: 'Qari Abdul Rahman',
    level: 'Beginner',
    priceBdt: 1999,
    rating: 4.9,
    reviewCount: 342,
    description:
        'Learn the rules of tajweed step by step and recite the Quran with '
        'confidence, starting from the letters and their points of exit.',
    moduleOne: ['Arabic letters and their sounds', 'Points of articulation'],
    moduleTwo: ['Noon sakinah and tanween', 'Practising short surahs'],
    questions: [
      _q('q1', 'What is the science of reciting the Quran correctly called?', [
        'Tajweed',
        'Tafsir',
        'Fiqh',
        'Seerah',
      ], 0),
      _q('q2', 'Which of these is a point of articulation?', [
        'Makhraj',
        'Mihrab',
        'Minbar',
        'Miqat',
      ], 0),
      _q('q3', 'How many letters are there in the Arabic alphabet?', [
        '26',
        '28',
        '30',
        '32',
      ], 1),
    ],
  ),
  _course(
    n: 2,
    categoryId: 'hadis',
    title: 'Hadis Sikkha: Prophetic Traditions of Healing',
    instructor: 'Sh. Ismail Al-Madani',
    level: 'All Levels',
    priceBdt: 2499,
    rating: 4.8,
    reviewCount: 189,
    description:
        'Study authentic narrations about health, cleanliness and treatment, '
        'and how scholars graded and understood them.',
    moduleOne: ['What is a hadith?', 'Chains and grading of narrations'],
    moduleTwo: ['Narrations on health', 'Applying the guidance today'],
    questions: [
      _q('q1', 'A hadith is a report of the words or actions of whom?', [
        'A companion only',
        'The Prophet, peace be upon him',
        'A scholar',
        'A king',
      ], 1),
      _q('q2', 'What do we call the chain of narrators?', [
        'Matn',
        'Isnad',
        'Mihrab',
        'Dua',
      ], 1),
      _q('q3', 'The text of a hadith is called its...', [
        'Matn',
        'Isnad',
        'Rawi',
        'Hukm',
      ], 0),
    ],
  ),
  _course(
    n: 3,
    categoryId: 'sirat',
    title: 'Sirat Sikkha: The Prophetic Medical Ethics',
    instructor: 'Dr. Mustafa Azami',
    level: 'Beginner',
    priceBdt: 2999,
    rating: 4.9,
    reviewCount: 275,
    description:
        'Follow the life of the Prophet, peace be upon him, and draw out '
        'lessons in mercy, honesty and care that every healer should keep.',
    moduleOne: ['Life in Makkah', 'The migration to Madinah'],
    moduleTwo: ['Mercy towards the sick', 'Trust and honesty in dealings'],
    questions: [
      _q('q1', 'Which city did the Prophet migrate to?', [
        'Taif',
        'Madinah',
        'Jerusalem',
        'Damascus',
      ], 1),
      _q('q2', 'The migration is known in Arabic as...', [
        'Hijrah',
        'Hajj',
        'Umrah',
        'Isra',
      ], 0),
      _q('q3', 'The Prophet was known before prophethood as Al-...', [
        'Amin',
        'Faruq',
        'Siddiq',
        'Ghani',
      ], 0),
    ],
  ),
  _course(
    n: 4,
    categoryId: 'ruqyah',
    title: 'Ruqyah Healing Essentials & Self-Treatment',
    instructor: 'Sh. Ahmad Al-Husayn',
    level: 'Beginner',
    priceBdt: 2999,
    rating: 4.8,
    reviewCount: 128,
    description:
        'The permissible forms of ruqyah, the verses and supplications used, '
        'and how to practise self-treatment with the right intention.',
    moduleOne: ['What ruqyah is and is not', 'Conditions of a valid ruqyah'],
    moduleTwo: ['Verses and supplications', 'Daily protection routine'],
    questions: [
      _q('q1', 'Which surah is commonly recited for ruqyah?', [
        'Al-Fatihah',
        'Al-Kahf only',
        'Al-Hajj',
        'An-Nur only',
      ], 0),
      _q('q2', 'Ruqyah must be free of...', [
        'Quranic verses',
        'Shirk',
        'Dua',
        'Dhikr',
      ], 1),
      _q('q3', 'Healing ultimately comes from...', [
        'The reciter',
        'Allah',
        'The remedy itself',
        'Luck',
      ], 1),
    ],
  ),
  _course(
    n: 5,
    categoryId: 'hijama',
    title: 'Hijama Practitioner Foundation & Cupping',
    instructor: 'Dr. Salma Rahman',
    level: 'Intermediate',
    priceBdt: 4999,
    rating: 4.9,
    reviewCount: 216,
    description:
        'Hygiene, safety, anatomy and technique for cupping, taught with '
        'the prophetic guidance on hijama.',
    moduleOne: ['History and guidance on hijama', 'Hygiene and safety'],
    moduleTwo: ['Cup types and preparation', 'Aftercare and contraindications'],
    questions: [
      _q('q1', 'Hijama is also known in English as...', [
        'Cupping',
        'Massage',
        'Steaming',
        'Fasting',
      ], 0),
      _q('q2', 'Which is the most important rule before any procedure?', [
        'Speed',
        'Hygiene and sterile tools',
        'Decoration',
        'Silence',
      ], 1),
      _q('q3', 'Cupping should be avoided on...', [
        'Healthy intact skin',
        'Broken or infected skin',
        'The upper back',
        'None of these',
      ], 1),
    ],
  ),
  _course(
    n: 6,
    categoryId: 'acupuncture',
    title: 'Clinical Acupuncture: Meridian Pathways',
    instructor: 'Dr. Chen Wei & Dr. Farhan',
    level: 'Advanced',
    priceBdt: 5999,
    rating: 4.7,
    reviewCount: 94,
    description:
        'A clinical walk through the main meridians, point location and '
        'safe needling practice.',
    moduleOne: ['Meridian theory', 'Locating points'],
    moduleTwo: ['Needle safety and technique', 'Case studies'],
    questions: [
      _q('q1', 'Acupuncture points lie along channels called...', [
        'Meridians',
        'Arteries',
        'Tendons',
        'Nerves only',
      ], 0),
      _q('q2', 'Needles must be...', [
        'Reused',
        'Sterile and single-use',
        'Unwashed',
        'Bent',
      ], 1),
      _q('q3', 'Before treatment a practitioner should take a...', [
        'Patient history',
        'Photograph',
        'Receipt only',
        'Break',
      ], 0),
    ],
  ),
  _course(
    n: 7,
    categoryId: 'acupressure',
    title: 'Acupressure for Pain Relief & Nervous Calm',
    instructor: 'Ust. Bilal Qasim',
    level: 'Beginner',
    priceBdt: 2499,
    rating: 4.8,
    reviewCount: 152,
    description:
        'Simple hand-pressure techniques you can use at home to ease '
        'tension and support relaxation.',
    moduleOne: ['How acupressure works', 'Finding pressure points'],
    moduleTwo: ['Points for headache and neck', 'Points for calm and sleep'],
    questions: [
      _q('q1', 'Acupressure uses...', [
        'Needles',
        'Finger pressure',
        'Heat only',
        'Cutting',
      ], 1),
      _q('q2', 'Pressure should feel...', [
        'Sharp and painful',
        'Firm but comfortable',
        'Absent',
        'Burning',
      ], 1),
      _q('q3', 'Persistent severe pain should lead you to...', [
        'Ignore it',
        'See a qualified doctor',
        'Press harder',
        'Wait a year',
      ], 1),
    ],
  ),
  _course(
    n: 8,
    categoryId: 'homeopathy',
    title: 'Classical Homeopathy & Natural Remedies',
    instructor: 'Dr. Zahirul Islam',
    level: 'Intermediate',
    priceBdt: 3499,
    rating: 4.7,
    reviewCount: 110,
    description:
        'An introduction to the principles of classical homeopathy, how '
        'remedies are prepared and how a case is taken.',
    moduleOne: ['Principles of homeopathy', 'Remedy preparation'],
    moduleTwo: ['Taking a case', 'Common acute remedies'],
    questions: [
      _q('q1', 'Homeopathy was founded by...', [
        'Samuel Hahnemann',
        'Ibn Sina',
        'Hippocrates',
        'Galen',
      ], 0),
      _q('q2', 'Homeopathic remedies are typically...', [
        'Highly diluted',
        'Undiluted poisons',
        'Fried',
        'Frozen solid',
      ], 0),
      _q('q3', 'A careful case history helps choose the...', [
        'Remedy',
        'Weather',
        'Colour',
        'Currency',
      ], 0),
    ],
  ),
  _course(
    n: 9,
    categoryId: 'naturopathy',
    title: 'Holistic Naturopathy & Prophetic Nutrition',
    instructor: 'Dr. Aamina Malik',
    level: 'All Levels',
    priceBdt: 2999,
    rating: 4.9,
    reviewCount: 184,
    description:
        'Food, water, rest and movement as the foundation of health, '
        'with the foods the Prophet, peace be upon him, recommended.',
    moduleOne: ['Principles of naturopathy', 'Prophetic foods'],
    moduleTwo: ['Balanced eating', 'Rest, water and movement'],
    questions: [
      _q('q1', 'Which of these is a prophetic food?', [
        'Dates',
        'Candy floss',
        'Soda',
        'Chips',
      ], 0),
      _q('q2', 'Moderation in eating is...', [
        'Discouraged',
        'Encouraged',
        'Forbidden',
        'Irrelevant',
      ], 1),
      _q('q3', 'Naturopathy focuses on supporting the body\'s own...', [
        'Healing ability',
        'Debts',
        'Clothes',
        'Furniture',
      ], 0),
    ],
  ),
  _course(
    n: 10,
    categoryId: 'pathology',
    title: 'Clinical Pathology: Diagnostic Interpretation',
    instructor: 'Dr. Rayhan Chowdhury',
    level: 'Intermediate',
    priceBdt: 4499,
    rating: 4.8,
    reviewCount: 167,
    description:
        'Read common lab reports, understand reference ranges and know '
        'when a result needs a doctor\'s attention.',
    moduleOne: ['Reading a blood report', 'Reference ranges'],
    moduleTwo: ['Urine and stool tests', 'When to refer'],
    questions: [
      _q('q1', 'A CBC test measures...', [
        'Blood cell counts',
        'Bone density',
        'Eyesight',
        'Hearing',
      ], 0),
      _q('q2', 'A result outside the reference range means...', [
        'Always disease',
        'It should be reviewed in context',
        'Nothing ever',
        'Panic',
      ], 1),
      _q('q3', 'Who should interpret serious abnormal results?', [
        'A qualified doctor',
        'A stranger online',
        'Nobody',
        'A salesman',
      ], 0),
    ],
  ),
];
