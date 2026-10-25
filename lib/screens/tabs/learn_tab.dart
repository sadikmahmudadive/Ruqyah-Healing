import 'package:flutter/material.dart';

import '../../widgets/illustrations/ruqyah_illustrations.dart';

import 'package:flutter/services.dart';

import '../../localization/app_localizations.dart';
import '../../theme/app_gradients.dart';
import '../../theme/app_theme.dart';
import '../../widgets/acupressure_icon.dart';
import '../../widgets/acupuncture_icon.dart';
import '../../widgets/hijama_cupping_icon.dart';
import '../../widgets/ruqyah_dua_icon.dart';
import '../community_screen.dart';
import '../course_detail_screen.dart';
import '../../widgets/islamic_pattern.dart';

class CourseModuleInfo {
  final String title;
  final String subtitle;
  final Widget customIcon;
  final Color iconBg;

  const CourseModuleInfo({
    required this.title,
    required this.subtitle,
    required this.customIcon,
    required this.iconBg,
  });
}

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
  final String module;

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
    this.module = 'General',
  });
}

class LearnTab extends StatefulWidget {
  const LearnTab({super.key});

  @override
  State<LearnTab> createState() => _LearnTabState();
}

class _LearnTabState extends State<LearnTab> {
  String _selectedCategory = 'All';

  final List<CourseModuleInfo> _courseModules = const [
    CourseModuleInfo(
      title: 'Quran Sikkha',
      subtitle: '16 Courses',
      customIcon: Icon(
        Icons.menu_book_rounded,
        color: Color(0xFF0B4632),
        size: 22,
      ),
      iconBg: AppColors.tintMint,
    ),
    CourseModuleInfo(
      title: 'Hadis Sikkha',
      subtitle: '14 Courses',
      customIcon: Icon(
        Icons.auto_stories_rounded,
        color: AppColors.warning,
        size: 22,
      ),
      iconBg: AppColors.tintSand,
    ),
    CourseModuleInfo(
      title: 'Sirat Sikkha',
      subtitle: '12 Courses',
      customIcon: Icon(
        Icons.history_edu_rounded,
        color: AppColors.info,
        size: 22,
      ),
      iconBg: AppColors.tintMist,
    ),
    CourseModuleInfo(
      title: 'Ruqyah',
      subtitle: '18 Courses',
      customIcon: RuqyahDuaIcon(color: Color(0xFF0B4632), size: 22),
      iconBg: AppColors.tintMint,
    ),
    CourseModuleInfo(
      title: 'Hijama',
      subtitle: '14 Courses',
      customIcon: HijamaCuppingIcon(color: AppColors.warning, size: 22),
      iconBg: AppColors.tintSand,
    ),
    CourseModuleInfo(
      title: 'Acupuncture',
      subtitle: '12 Courses',
      customIcon: AcupunctureIcon(color: AppColors.info, size: 22),
      iconBg: AppColors.tintMist,
    ),
    CourseModuleInfo(
      title: 'Acupressure',
      subtitle: '10 Courses',
      customIcon: AcupressureIcon(color: Color(0xFF4E8F62), size: 22),
      iconBg: AppColors.tintSage,
    ),
    CourseModuleInfo(
      title: 'Homeopathy',
      subtitle: '11 Courses',
      customIcon: Icon(
        Icons.medication_liquid_rounded,
        color: AppColors.accentLilac,
        size: 22,
      ),
      iconBg: AppColors.tintLilac,
    ),
    CourseModuleInfo(
      title: 'Naturopathy',
      subtitle: '13 Courses',
      customIcon: Icon(Icons.spa_rounded, color: AppColors.success, size: 22),
      iconBg: AppColors.tintMint,
    ),
    CourseModuleInfo(
      title: 'Pathology',
      subtitle: '9 Courses',
      customIcon: Icon(
        Icons.biotech_rounded,
        color: AppColors.danger,
        size: 22,
      ),
      iconBg: AppColors.tintRose,
    ),
  ];

  final List<CourseModel> _courses = const [
    CourseModel(
      id: 'course_1',
      title: 'Quran Recitation & Tajweed Mastery',
      instructor: 'Qari Abdul Rahman',
      module: 'Quran Sikkha',
      level: 'Beginner',
      price: 19.99,
      rating: 4.9,
      reviewsCount: 342,
      freeLessons: 8,
      imagePath: 'assets/logo/logo_app.png',
    ),
    CourseModel(
      id: 'course_2',
      title: 'Hadis Sikkha: Prophetic Traditions of Healing',
      instructor: 'Sh. Ismail Al-Madani',
      module: 'Hadis Sikkha',
      level: 'All Levels',
      price: 24.99,
      rating: 4.8,
      reviewsCount: 189,
      freeLessons: 6,
      imagePath: 'assets/logo/logo_app.png',
    ),
    CourseModel(
      id: 'course_3',
      title: 'Sirat Sikkha: The Prophetic Medical Ethics',
      instructor: 'Dr. Mustafa Azami',
      module: 'Sirat Sikkha',
      level: 'Beginner',
      price: 29.99,
      rating: 4.9,
      reviewsCount: 275,
      freeLessons: 10,
      imagePath: 'assets/logo/logo_app.png',
    ),
    CourseModel(
      id: 'course_4',
      title: 'Ruqyah Healing Essentials & Self-Treatment',
      instructor: 'Sh. Ahmad Al-Husayn',
      module: 'Ruqyah',
      level: 'Beginner',
      price: 29.99,
      rating: 4.8,
      reviewsCount: 128,
      freeLessons: 6,
      imagePath: 'assets/logo/logo_app.png',
    ),
    CourseModel(
      id: 'course_5',
      title: 'Hijama Practitioner Foundation & Cupping',
      instructor: 'Dr. Salma Rahman',
      module: 'Hijama',
      level: 'Intermediate',
      price: 49.99,
      rating: 4.9,
      reviewsCount: 216,
      freeLessons: 8,
      imagePath: 'assets/logo/logo_app.png',
    ),
    CourseModel(
      id: 'course_6',
      title: 'Clinical Acupuncture: Meridian Pathways',
      instructor: 'Dr. Chen Wei & Dr. Farhan',
      module: 'Acupuncture',
      level: 'Advanced',
      price: 59.99,
      rating: 4.7,
      reviewsCount: 94,
      freeLessons: 5,
      imagePath: 'assets/logo/logo_app.png',
    ),
    CourseModel(
      id: 'course_7',
      title: 'Acupressure for Pain Relief & Nervous Calm',
      instructor: 'Ust. Bilal Qasim',
      module: 'Acupressure',
      level: 'Beginner',
      price: 24.99,
      rating: 4.8,
      reviewsCount: 152,
      freeLessons: 7,
      imagePath: 'assets/logo/logo_app.png',
    ),
    CourseModel(
      id: 'course_8',
      title: 'Classical Homeopathy & Natural Remedies',
      instructor: 'Dr. Zahirul Islam',
      module: 'Homeopathy',
      level: 'Intermediate',
      price: 34.99,
      rating: 4.7,
      reviewsCount: 110,
      freeLessons: 6,
      imagePath: 'assets/logo/logo_app.png',
    ),
    CourseModel(
      id: 'course_9',
      title: 'Holistic Naturopathy & Prophetic Nutrition',
      instructor: 'Dr. Aamina Malik',
      module: 'Naturopathy',
      level: 'All Levels',
      price: 29.99,
      rating: 4.9,
      reviewsCount: 184,
      freeLessons: 8,
      imagePath: 'assets/logo/logo_app.png',
    ),
    CourseModel(
      id: 'course_10',
      title: 'Clinical Pathology: Diagnostic Interpretation',
      instructor: 'Dr. Rayhan Chowdhury',
      module: 'Pathology',
      level: 'Intermediate',
      price: 44.99,
      rating: 4.8,
      reviewsCount: 167,
      freeLessons: 6,
      imagePath: 'assets/logo/logo_app.png',
    ),
  ];

  List<CourseModel> get _filteredCourses {
    if (_selectedCategory == 'All') {
      return _courses;
    }
    return _courses.where((c) => c.module == _selectedCategory).toList();
  }

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

                    // Community & Support Banner Card
                    _buildCommunityBanner(),

                    const SizedBox(height: 32),

                    // 2. Browse by Category Section
                    _buildBrowseByCategorySection(),

                    const SizedBox(height: 32),

                    // 3. Featured Courses Section
                    _buildFeaturedCoursesSection(),

                    const SizedBox(height: 120),
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
        bottom: 28,
        left: 20,
        right: 20,
      ),
      foregroundDecoration: IslamicPatternDecoration(),
      decoration: BoxDecoration(
        gradient: AppGradients.headerGradient(context),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Row(
        children: [
          if (Navigator.of(context).canPop()) ...[
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.of(context).pop();
              },
              child: Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(right: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('learning'),
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.tr('learning_sub'),
                  style: const TextStyle(
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
                Icons.more_horiz_rounded,
                color: Colors.white,
                size: 22,
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
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 28,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Status Row
          Row(
            children: [
              const Icon(Icons.circle, color: Color(0xFF1E6B45), size: 8),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  context.tr('continue_learning'),
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: Color(0xFF1E6B45),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.tintSand,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '30% complete',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFD49E35),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hijama Practitioner Foundation',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
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
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const FlatIllustration(
                kind: FlatIllustrationKind.learn,
                size: 76,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress Bar & Continue Button Row
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.30,
                    backgroundColor: context.pageBg,
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
                      pageBuilder: (_, _, _) => const CourseDetailScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B4632),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.tr('continue'),
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
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

  // 2. Browse by Category Section (10 Course Modules)
  Widget _buildBrowseByCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      context.tr('browse_category'),
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: context.isDarkMode
                          ? const Color(0xFF182E25)
                          : AppColors.tintMint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_courseModules.length}',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0B4632),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (_selectedCategory != 'All')
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedCategory = 'All');
                },
                child: const Text(
                  'Reset',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.danger,
                  ),
                ),
              )
            else
              InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedCategory = 'All');
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: context.isDarkMode
                        ? const Color(0xFF182E25)
                        : AppColors.tintMint,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF0B4632)),
                  ),
                  child: const Text(
                    'All',
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

        SizedBox(
          // Taller when the user has enlarged their text, so labels never clip.
          height:
              126 +
              (MediaQuery.textScalerOf(context).scale(10) / 10 - 1).clamp(
                    0.0,
                    1.0,
                  ) *
                  70,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _courseModules.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final module = _courseModules[index];
              final isSelected = module.title == _selectedCategory;

              return _buildCategoryCard(
                title: module.title,
                subtitle: module.subtitle,
                customIcon: module.customIcon,
                iconBg: module.iconBg,
                isSelected: isSelected,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    if (_selectedCategory == module.title) {
                      _selectedCategory = 'All';
                    } else {
                      _selectedCategory = module.title;
                    }
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required String subtitle,
    required Widget customIcon,
    required Color iconBg,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return Container(
      width: 114,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? (context.isDarkMode
                  ? const Color(0xFF182E25)
                  : AppColors.tintMint)
            : context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? const Color(0xFF0B4632) : context.cardBorder,
          width: isSelected ? 1.8 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: context.isDarkMode ? 0.2 : 0.03,
            ),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: context.isDarkMode ? const Color(0xFF162E25) : iconBg,
                  shape: BoxShape.circle,
                ),
                child: Center(child: customIcon),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                  color: isSelected
                      ? const Color(0xFF0B4632)
                      : context.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
    final displayedCourses = _filteredCourses;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _selectedCategory == 'All'
                    ? context.tr('featured_courses')
                    : 'Courses: $_selectedCategory',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            if (_selectedCategory != 'All')
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedCategory = 'All');
                },
                child: const Text(
                  'Reset Filter',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.danger,
                  ),
                ),
              )
            else
              InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.tintMint,
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

        ...displayedCourses.map((course) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 18.0),
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
            pageBuilder: (context, anim, secAnim) => CourseDetailScreen(
              courseTitle: course.title,
              instructorName: course.instructor,
              level: course.level,
              price: course.price,
              module: course.module,
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
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 28,
              offset: const Offset(0, 8),
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isBeginner
                                        ? AppColors.tintMint
                                        : AppColors.tintSand,
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
                                          : AppColors.warning,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.isDarkMode
                                        ? const Color(0xFF182E25)
                                        : AppColors.tintMint,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    course.module,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0B4632),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tk ${course.price}',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: context.textPrimary,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Text(
                        course.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: context.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              course.instructor,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                color: context.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
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
                        fontWeight: FontWeight.w700,
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
                Text(
                  '${course.freeLessons} Free Lessons',
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
      ),
    );
  }

  Widget _buildCommunityBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      foregroundDecoration: IslamicPatternDecoration(
        radius: BorderRadius.circular(24),
      ),
      decoration: BoxDecoration(
        gradient: AppGradients.greenHeaderGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF082F21).withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const FlatIllustration(
            kind: FlatIllustrationKind.community,
            size: 62,
            dark: true, // sits on the green gradient
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Community & Dua',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Share duas, healing stories & scholar Q&A',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.80),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD49E35),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            onPressed: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, _, _) => const CommunityScreen(),
                ),
              );
            },
            child: const Text(
              'Join',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
