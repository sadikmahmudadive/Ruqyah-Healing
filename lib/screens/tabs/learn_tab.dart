import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_gradients.dart';
import '../../theme/app_theme.dart';
import '../../widgets/acupuncture_icon.dart';
import '../../widgets/hijama_cupping_icon.dart';
import '../../widgets/ruqyah_dua_icon.dart';
import '../course_detail_screen.dart';

class CourseModel {
  final String id;
  final String title;
  final String instructor;
  final bool isVerified;
  final String level;
  final double price;
  final double rating;
  final int reviewsCount;
  final int freeLessons;
  final String imagePath;

  const CourseModel({
    required this.id,
    required this.title,
    required this.instructor,
    this.isVerified = true,
    required this.level,
    required this.price,
    required this.rating,
    required this.reviewsCount,
    required this.freeLessons,
    required this.imagePath,
  });
}

class LearnTab extends StatefulWidget {
  const LearnTab({super.key});

  @override
  State<LearnTab> createState() => _LearnTabState();
}

class _LearnTabState extends State<LearnTab> {
  final List<CourseModel> _courses = const [
    CourseModel(
      id: 'course_1',
      title: 'Ruqyah Healing Essentials',
      instructor: 'Sh. Ahmad Al-Husayn',
      level: 'Beginner',
      price: 29.99,
      rating: 4.8,
      reviewsCount: 128,
      freeLessons: 6,
      imagePath: 'assets/logo/logo_app.png',
    ),
    CourseModel(
      id: 'course_2',
      title: 'Hijama Practitioner Foundation',
      instructor: 'Dr. Salma Rahman',
      level: 'Intermediate',
      price: 49.99,
      rating: 4.9,
      reviewsCount: 216,
      freeLessons: 8,
      imagePath: 'assets/logo/logo_app.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: context.pageBg,
        body: Column(
          children: [
            // 1. Top Dark Green Header Area
            _buildTopHeader(),

            // 2. Scrollable Body Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Continue Learning Hero Progress Card
                    _buildContinueLearningHeroCard(),

                    const SizedBox(height: 20),

                    // 2. Browse by Category Section
                    _buildBrowseByCategorySection(),

                    const SizedBox(height: 20),

                    // 3. Featured Courses Section
                    _buildFeaturedCoursesSection(),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Top Dark Green Header Area
  Widget _buildTopHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 20,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        gradient: AppGradients.headerGradient(context),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Learning',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Grow in knowledge, serve with sincerity.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF81C784),
                  ),
                ),
              ],
            ),
          ),

          // Options Button
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.cancel_outlined,
                color: Color(0xFFD49E35),
                size: 20,
              ),
              onPressed: () {
                HapticFeedback.selectionClick();
              },
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  // 1. Continue Learning Hero Progress Card
  Widget _buildContinueLearningHeroCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.cardBorder, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Status Row
          Row(
            children: [
              const Icon(
                Icons.circle,
                color: Color(0xFF1E6B45),
                size: 8,
              ),
              const SizedBox(width: 6),
              const Text(
                'CONTINUE LEARNING',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: Color(0xFF1E6B45),
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '30% DONE',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFD49E35),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            'Hijama Practitioner Foundation',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: context.textPrimary,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            'Lesson 3 of 10 • Cupping Principles',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.5,
              color: context.textSecondary,
            ),
          ),

          const SizedBox(height: 16),

          // Progress Bar & Continue Button Row
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(
                    value: 0.30,
                    backgroundColor: Color(0xFFF5F7F6),
                    color: Color(0xFF0B4632),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const CourseDetailScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B4632),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Continue',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. Browse by Category Section
  Widget _buildBrowseByCategorySection() {
    return Column(
      children: [
        Row(
          children: [
            Text(
              'Browse by Category',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: context.textPrimary,
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF7F0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'View all',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0B4632),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            // Category 1: Ruqyah
            Expanded(
              child: _buildCategoryCard(
                title: 'Ruqyah',
                subtitle: '18 Courses',
                customIcon: const RuqyahDuaIcon(
                  color: Color(0xFF0B4632),
                  size: 22,
                ),
                iconBg: const Color(0xFFEBF7F0),
              ),
            ),
            const SizedBox(width: 10),

            // Category 2: Hijama
            Expanded(
              child: _buildCategoryCard(
                title: 'Hijama',
                subtitle: '14 Courses',
                customIcon: const HijamaCuppingIcon(
                  color: Color(0xFFE67E22),
                  size: 22,
                ),
                iconBg: const Color(0xFFFFF3E8),
              ),
            ),
            const SizedBox(width: 10),

            // Category 3: Acupuncture
            Expanded(
              child: _buildCategoryCard(
                title: 'Acupuncture',
                subtitle: '12 Courses',
                customIcon: const AcupunctureIcon(
                  color: Color(0xFF2980B9),
                  size: 22,
                ),
                iconBg: const Color(0xFFE6F7FF),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required String subtitle,
    required Widget customIcon,
    required Color iconBg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.cardBorder, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: context.isDarkMode
                      ? const Color(0xFF162E25)
                      : iconBg,
                  shape: BoxShape.circle,
                ),
                child: Center(child: customIcon),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 3. Featured Courses Section
  Widget _buildFeaturedCoursesSection() {
    return Column(
      children: [
        Row(
          children: [
            Text(
              'Featured Courses',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: context.textPrimary,
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF7F0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'View all',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0B4632),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        ..._courses.map((course) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14.0),
            child: _buildCourseCard(course),
          );
        }),
      ],
    );
  }

  Widget _buildCourseCard(CourseModel course) {
    final bool isBeginner = course.level == 'Beginner';

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => CourseDetailScreen(
              courseTitle: course.title,
              instructorName: course.instructor,
              level: course.level,
              price: course.price,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: context.cardBorder, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
          // Top Row: Image + Details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E3A2F),
                    image: DecorationImage(
                      image: AssetImage('assets/logo/logo_app.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isBeginner
                                ? const Color(0xFFEBF7F0)
                                : const Color(0xFFFFF3E8),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            course.level,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: isBeginner
                                  ? const Color(0xFF0B4632)
                                  : const Color(0xFFE67E22),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Tk ${course.price}',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: context.textPrimary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Text(
                      course.title,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: context.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Row(
                      children: [
                        Text(
                          course.instructor,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: context.textSecondary,
                          ),
                        ),
                        if (course.isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF0B4632),
                            size: 14,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Container(height: 1, color: context.cardBorder),
          const SizedBox(height: 10),

          // Footer Info Row
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFD49E35),
                    size: 16,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '${course.rating} ',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: context.textPrimary,
                    ),
                  ),
                  Text(
                    '(${course.reviewsCount} reviews)',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11.5,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.school_outlined,
                    color: Color(0xFF0B4632),
                    size: 15,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Certificate',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11.5,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
                ],
              ),
              Text(
                '${course.freeLessons} Free Lessons',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11.5,
                  color: Color(0xFF6E7E77),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
}
