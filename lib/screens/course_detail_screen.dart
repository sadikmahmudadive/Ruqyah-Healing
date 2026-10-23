import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_gradients.dart';
import '../widgets/app_toast.dart';
import 'quiz_certificate_screen.dart';
import '../theme/app_theme.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseTitle;
  final String instructorName;
  final String level;
  final double price;
  final String module;

  const CourseDetailScreen({
    super.key,
    this.courseTitle = 'Hijama Practitioner Foundation',
    this.instructorName = 'Dr. Salma Rahman',
    this.level = 'Intermediate',
    this.price = 49.99,
    this.module = 'Hijama',
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  String _selectedTab = 'Curriculum'; // 'Curriculum', 'Overview', 'Instructor'
  bool _isBookmarked = false;
  bool _isPlayingVideo = false;

  void _handleEnroll() {
    HapticFeedback.lightImpact();
    AppToast.show(
      context,
      title: 'Enrolled Successfully',
      message: 'You have enrolled in ${widget.courseTitle}.',
      type: ToastType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.lightBackground,
        appBar: AppBar(
          backgroundColor: AppColors.lightBackground,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.lightCardBg,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.lightCardBorder, width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 26,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.lightTextPrimary,
                  size: 20,
                ),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
          actions: [
            // Bookmark Button
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 8.0),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.lightCardBg,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.lightCardBorder,
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 26,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    _isBookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_outline_rounded,
                    color: AppColors.lightTextPrimary,
                    size: 18,
                  ),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    setState(() => _isBookmarked = !_isBookmarked);
                  },
                  padding: EdgeInsets.zero,
                ),
              ),
            ),

            // Share Button
            Padding(
              padding: const EdgeInsets.only(
                right: 16.0,
                top: 8.0,
                bottom: 8.0,
              ),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.lightCardBg,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.lightCardBorder,
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 26,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.share_outlined,
                    color: AppColors.lightTextPrimary,
                    size: 18,
                  ),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                  },
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 12.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Level Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.tintSand,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.level,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.warning,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 2. Course Title
                    Text(
                      widget.courseTitle,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.lightTextPrimary,
                        height: 1.25,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 3. Instructor Profile Row
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: const BoxDecoration(
                              color: Color(0xFF1E3A2F),
                              image: DecorationImage(
                                image: AssetImage('assets/logo/logo_app.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      widget.instructorName,
                                      style: const TextStyle(
                                        fontFamily: 'PlusJakartaSans',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.lightTextPrimary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: Color(0xFF0B4632),
                                    size: 15,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Lead Instructor',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: AppColors.lightTextMuted,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFD49E35),
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '4.9 ',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.lightTextPrimary,
                          ),
                        ),
                        const Text(
                          '(216)',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: AppColors.lightTextMuted,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // 4. Video Player Preview Card
                    _buildVideoPlayerCard(),

                    const SizedBox(height: 18),

                    // 5. Quick Action Bento Cards Row (4 Columns)
                    _buildQuickActionBentoRow(),

                    const SizedBox(height: 20),

                    // 6. Tab Segment Bar
                    _buildTabSegmentBar(),

                    const SizedBox(height: 16),

                    if (_selectedTab == 'Curriculum') ...[
                      // 7. Curriculum Modules List
                      _buildCurriculumSection(),
                    ] else if (_selectedTab == 'Overview') ...[
                      _buildOverviewSection(),
                    ] else ...[
                      _buildInstructorSection(),
                    ],

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // 8. Sticky Bottom Enrollment Card
            _buildBottomEnrollmentCard(),
          ],
        ),
      ),
    );
  }

  // 4. Video Player Preview Card
  Widget _buildVideoPlayerCard() {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF12241F),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 26,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background Video Thumbnail Image
            Image.asset(
              'assets/logo/logo_app.png',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: const Color(0xFF12241F)),
            ),

            // Dark Overlay Layer
            Container(color: Colors.black.withValues(alpha: 0.45)),

            // Top Left Tag: Lesson 3: Principles
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.60),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Lesson 3: Principles',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Center Big Play Button
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _isPlayingVideo = !_isPlayingVideo);
              },
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.90),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.20),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Icon(
                  _isPlayingVideo
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: const Color(0xFF0B4632),
                  size: 32,
                ),
              ),
            ),

            // Bottom Control Overlay Bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                color: const Color(0xFF082F21).withValues(alpha: 0.92),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _getCurriculumData().activeLessonTitle,
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '04:15 / 12:35',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11.5,
                            color: Color(0xFF81C784),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: const LinearProgressIndicator(
                        value: 0.35,
                        backgroundColor: Color(0xFF133F2E),
                        color: Color(0xFF2ECC71),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 5. Quick Action Bento Cards Row (4 Columns)
  Widget _buildQuickActionBentoRow() {
    return Row(
      children: [
        _buildBentoItem(
          icon: Icons.description_outlined,
          title: 'Resources',
          subtitle: 'PDFs & Gui...',
        ),
        const SizedBox(width: 8),
        _buildBentoItem(
          icon: Icons.help_outline_rounded,
          title: 'Quiz',
          subtitle: 'Test Knowl...',
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (_, _, _) => const QuizCertificateScreen(),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
        _buildBentoItem(
          icon: Icons.edit_outlined,
          title: 'Notes',
          subtitle: 'Your Notes',
          onTap: () {
            HapticFeedback.selectionClick();
          },
        ),
        const SizedBox(width: 8),
        _buildBentoItem(
          icon: Icons.card_membership_rounded,
          title: 'Certificate',
          subtitle: 'Eligibility',
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (_, _, _) => const QuizCertificateScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBentoItem({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            color: AppColors.lightCardBg,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 26,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.tintMint,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFF0B4632), size: 18),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.lightTextPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  color: AppColors.lightTextMuted,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 6. Tab Segment Bar
  Widget _buildTabSegmentBar() {
    return Column(
      children: [
        Row(
          children: [
            _buildTabPill('Curriculum'),
            const SizedBox(width: 20),
            _buildTabPill('Overview'),
            const SizedBox(width: 20),
            _buildTabPill('Instructor'),
          ],
        ),
        const SizedBox(height: 6),
        Container(height: 1, color: AppColors.lightCardBorder),
      ],
    );
  }

  Widget _buildTabPill(String label) {
    final isSelected = label == _selectedTab;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedTab = label);
      },
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected
                  ? const Color(0xFF0B4632)
                  : AppColors.lightTextMuted,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 2.5,
            width: isSelected ? 48 : 0,
            decoration: BoxDecoration(
              color: const Color(0xFF0B4632),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  // 7. Curriculum Modules Section
  Widget _buildCurriculumSection() {
    final curriculum = _getCurriculumData();

    return Column(
      children: [
        // Module 1 Header
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.tintMint,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFF0B4632),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  curriculum.module1Title,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.lightTextPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B4632),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  curriculum.module1Status,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Module 2: Active Lessons Container
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.lightCardBg,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 26,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.warning,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      curriculum.module2Title,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.lightTextPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.tintSand,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      curriculum.module2Status,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),
              Container(height: 1, color: AppColors.lightCardBorder),
              const SizedBox(height: 10),

              // Render Lessons
              for (int i = 0; i < curriculum.module2Lessons.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                if (curriculum.module2Lessons[i].isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.tintMint,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.volume_up_rounded,
                          color: Color(0xFF0B4632),
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            curriculum.module2Lessons[i].title,
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0B4632),
                            ),
                          ),
                        ),
                        Text(
                          curriculum.module2Lessons[i].duration,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0B4632),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  _buildLessonItem(
                    icon: curriculum.module2Lessons[i].isCompleted
                        ? Icons.check_circle_outline_rounded
                        : Icons.play_circle_outline_rounded,
                    iconColor: curriculum.module2Lessons[i].isCompleted
                        ? const Color(0xFF0B4632)
                        : AppColors.lightTextMuted,
                    title: curriculum.module2Lessons[i].title,
                    duration: curriculum.module2Lessons[i].duration,
                    isCompleted: curriculum.module2Lessons[i].isCompleted,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLessonItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String duration,
    bool isCompleted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: isCompleted ? FontWeight.w600 : FontWeight.w400,
                color: AppColors.lightTextSecondary,
              ),
            ),
          ),
          Text(
            duration,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppColors.lightTextMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSection() {
    final curriculum = _getCurriculumData();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightCardBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        curriculum.overview,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          color: AppColors.lightTextSecondary,
          height: 1.45,
        ),
      ),
    );
  }

  Widget _buildInstructorSection() {
    final curriculum = _getCurriculumData();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightCardBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        curriculum.instructorBio,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          color: AppColors.lightTextSecondary,
          height: 1.45,
        ),
      ),
    );
  }

  _CurriculumData _getCurriculumData() {
    switch (widget.module) {
      case 'Quran Sikkha':
        return _CurriculumData(
          activeLessonTitle: 'Rules of Noon Sakin & Tanween',
          module1Title: 'Module 1: Makharij & Letter Articulation',
          module1Status: '3/3 Complete',
          module2Title: 'Module 2: Tilawat & Fluency',
          module2Status: '1/3 In Progress',
          module2Lessons: const [
            _LessonItemData(
              title: 'Surah Al-Fatihah with Precise Tajweed',
              duration: '12 min',
              isCompleted: true,
            ),
            _LessonItemData(
              title: 'Rules of Noon Sakin & Tanween',
              duration: '15 min',
              isActive: true,
            ),
            _LessonItemData(
              title: 'Stopping (Waqf) Signs & Rhythmic Recitation',
              duration: '14 min',
            ),
          ],
          overview:
              'Comprehensive Quran learning curriculum focusing on accurate letter articulation (Makharij), core Tajweed recitation rules, and fluent practice from beginner to advanced.',
          instructorBio:
              '${widget.instructorName} is an experienced Qari with authentic Ijazah in Hafs an Asim and extensive teaching experience in Quranic phonetics.',
        );

      case 'Hadis Sikkha':
        return _CurriculumData(
          activeLessonTitle: 'Selected Hadiths on Tibb al-Nabawi',
          module1Title: 'Module 1: Hadith Sciences (Mustalah)',
          module1Status: '3/3 Complete',
          module2Title: 'Module 2: Prophetic Medicine & Guidance',
          module2Status: '1/3 In Progress',
          module2Lessons: const [
            _LessonItemData(
              title: 'Introduction to Sahih al-Bukhari & Muslim',
              duration: '11 min',
              isCompleted: true,
            ),
            _LessonItemData(
              title: 'Selected Hadiths on Tibb al-Nabawi',
              duration: '18 min',
              isActive: true,
            ),
            _LessonItemData(
              title: 'Daily Adhkar & Sunnah Etiquette',
              duration: '15 min',
            ),
          ],
          overview:
              'In-depth study of prophetic traditions, principles of Hadith classification (Mustalah al-Hadith), authentic narration chains, and their medical and ethical wisdom.',
          instructorBio:
              '${widget.instructorName} holds advanced credentials in Hadith sciences and Islamic jurisprudence with scholarly contributions in prophetic wellness.',
        );

      case 'Sirat Sikkha':
        return _CurriculumData(
          activeLessonTitle: "The Prophet's Way of Healing & Empathy",
          module1Title: 'Module 1: The Makkan Era & Character',
          module1Status: '3/3 Complete',
          module2Title: 'Module 2: The Madinan Era & Sunnah Living',
          module2Status: '1/3 In Progress',
          module2Lessons: const [
            _LessonItemData(
              title: 'The Hijrah & Founding the Community',
              duration: '12 min',
              isCompleted: true,
            ),
            _LessonItemData(
              title: "The Prophet's Way of Healing & Empathy",
              duration: '20 min',
              isActive: true,
            ),
            _LessonItemData(
              title: 'The Farewell Pilgrimage & Enduring Legacy',
              duration: '15 min',
            ),
          ],
          overview:
              'Explore the noble life, sublime character (Akhlaq), and profound wisdom of the Prophet Muhammad (PBUH) from early Makkan struggles to the radiant Madinan society.',
          instructorBio:
              '${widget.instructorName} is a researcher and educator specializing in Islamic history, Seerah Nabawiyyah, and classical Prophetic biography.',
        );

      case 'Ruqyah':
        return _CurriculumData(
          activeLessonTitle: 'Comprehensive Ruqyah Recitation Protocols',
          module1Title: 'Module 1: Foundations of Shariah Ruqyah',
          module1Status: '3/3 Complete',
          module2Title: 'Module 2: Diagnosis & Treatment Protocols',
          module2Status: '1/3 In Progress',
          module2Lessons: const [
            _LessonItemData(
              title: 'Identifying Evil Eye (Ayn) & Afflictions',
              duration: '13 min',
              isCompleted: true,
            ),
            _LessonItemData(
              title: 'Comprehensive Ruqyah Recitation Protocols',
              duration: '22 min',
              isActive: true,
            ),
            _LessonItemData(
              title: 'Water & Olive Oil Preparation & Patient Care',
              duration: '16 min',
            ),
          ],
          overview:
              'Authentic, Shariah-compliant course on Ruqyah Ash-Shar\'iyyah for spiritual affliction, evil eye, black magic, and holistic spiritual well-being.',
          instructorBio:
              '${widget.instructorName} is a veteran Ruqyah practitioner and counselor specializing in Sunnah healing and spiritual psychotherapy.',
        );

      case 'Acupuncture':
        return _CurriculumData(
          activeLessonTitle: 'Pain Relief Protocols for Migraine & Sciatica',
          module1Title: 'Module 1: Meridians & Energy Flow',
          module1Status: '3/3 Complete',
          module2Title: 'Module 2: Clinical Point Selection',
          module2Status: '1/3 In Progress',
          module2Lessons: const [
            _LessonItemData(
              title: 'Top 20 Common Clinical Acupoints',
              duration: '12 min',
              isCompleted: true,
            ),
            _LessonItemData(
              title: 'Pain Relief Protocols for Migraine & Sciatica',
              duration: '20 min',
              isActive: true,
            ),
            _LessonItemData(
              title: 'Needle Retention, Stimulation & Removal',
              duration: '15 min',
            ),
          ],
          overview:
              'Evidence-based acupuncture certification exploring meridian mapping, vital energy balance, painless needling techniques, and pain management protocols.',
          instructorBio:
              '${widget.instructorName} is a licensed acupuncturist and pain specialist registered with international integrative medicine boards.',
        );

      case 'Acupressure':
        return _CurriculumData(
          activeLessonTitle: 'Acupressure for Sleep & Stress Release',
          module1Title: 'Module 1: Pressure Points & Reflexology',
          module1Status: '3/3 Complete',
          module2Title: 'Module 2: Therapeutic Protocols',
          module2Status: '1/3 In Progress',
          module2Lessons: const [
            _LessonItemData(
              title: 'Hegu (LI4) & Nei Guan (PC6) for Relief',
              duration: '10 min',
              isCompleted: true,
            ),
            _LessonItemData(
              title: 'Acupressure for Sleep & Stress Release',
              duration: '16 min',
              isActive: true,
            ),
            _LessonItemData(
              title: 'Self-Care Routine for Chronic Tension',
              duration: '14 min',
            ),
          ],
          overview:
              'Non-invasive pressure point therapy to stimulate vital bodily reflexes, relieve tension headaches, manage chronic stress, and restore bodily homeostasis.',
          instructorBio:
              '${widget.instructorName} is an acupressure master trainer and holistic therapist focusing on non-invasive somatic restoration.',
        );

      case 'Homeopathy':
        return _CurriculumData(
          activeLessonTitle: 'Homeopathic Case Taking & Symptom Repertory',
          module1Title: 'Module 1: Core Principles of Homeopathy',
          module1Status: '3/3 Complete',
          module2Title: 'Module 2: Materia Medica & Case Taking',
          module2Status: '1/3 In Progress',
          module2Lessons: const [
            _LessonItemData(
              title: 'Key Remedies in Materia Medica',
              duration: '14 min',
              isCompleted: true,
            ),
            _LessonItemData(
              title: 'Homeopathic Case Taking & Symptom Repertory',
              duration: '22 min',
              isActive: true,
            ),
            _LessonItemData(
              title: 'First Aid Protocols & Follow-up Assessment',
              duration: '16 min',
            ),
          ],
          overview:
              'Comprehensive study of classical homeopathy, constitutional remedies, Materia Medica therapeutics, and gentle non-toxic healing for chronic conditions.',
          instructorBio:
              '${widget.instructorName} is a seasoned Classical Homeopath (BHMS) with decades of clinical diagnosis and repertorization expertise.',
        );

      case 'Naturopathy':
        return _CurriculumData(
          activeLessonTitle: 'Lifestyle Regimen: Circadian Rhythm & Sleep',
          module1Title: 'Module 1: Natural Healing & Five Elements',
          module1Status: '3/3 Complete',
          module2Title: 'Module 2: Herbal Medicine & Lifestyle',
          module2Status: '1/3 In Progress',
          module2Lessons: const [
            _LessonItemData(
              title: 'Therapeutic Medicinal Herbs & Infusions',
              duration: '12 min',
              isCompleted: true,
            ),
            _LessonItemData(
              title: 'Lifestyle Regimen: Circadian Rhythm & Sleep',
              duration: '18 min',
              isActive: true,
            ),
            _LessonItemData(
              title: 'Designing a Preventive Wellness Routine',
              duration: '15 min',
            ),
          ],
          overview:
              'Harness the restorative power of nature through nutritional biochemistry, herbal remedies, botanical infusions, fasting therapies, and circadian rhythm alignment.',
          instructorBio:
              '${widget.instructorName} is a licensed Naturopathic Doctor (ND) passionate about lifestyle medicine, clinical herbs, and whole-body vitality.',
        );

      case 'Pathology':
        return _CurriculumData(
          activeLessonTitle: 'Correlating Lab Values with Holistic Therapies',
          module1Title: 'Module 1: Diagnostic Fundamentals & Panels',
          module1Status: '3/3 Complete',
          module2Title: 'Module 2: Clinical Pathology & Lab Reports',
          module2Status: '1/3 In Progress',
          module2Lessons: const [
            _LessonItemData(
              title: 'Lipid Profiles & Cardiovascular Risk Markers',
              duration: '12 min',
              isCompleted: true,
            ),
            _LessonItemData(
              title: 'Correlating Lab Values with Holistic Therapies',
              duration: '20 min',
              isActive: true,
            ),
            _LessonItemData(
              title: 'Red Flags & Urgent Clinical Referral Protocols',
              duration: '15 min',
            ),
          ],
          overview:
              'Master clinical lab report interpretation, biochemical biomarkers, pathology panels, and how to safely correlate medical diagnostic reports with complementary therapies.',
          instructorBio:
              '${widget.instructorName} is a consultant clinical pathologist and medical educator bridging conventional laboratory diagnostics and integrative medicine.',
        );

      case 'Hijama':
      default:
        return _CurriculumData(
          activeLessonTitle: 'Principles of Cupping',
          module1Title: 'Module 1: Foundations & Anatomy',
          module1Status: '3/3 Complete',
          module2Title: 'Module 2: Cupping Principles',
          module2Status: '1/3 In Progress',
          module2Lessons: const [
            _LessonItemData(
              title: 'Introduction to Hijama',
              duration: '8 min',
              isCompleted: true,
            ),
            _LessonItemData(
              title: 'Principles of Cupping',
              duration: '12 min',
              isActive: true,
            ),
            _LessonItemData(
              title: 'Safety & Contraindications',
              duration: '10 min',
            ),
          ],
          overview:
              'Comprehensive foundation course covering essential principles, hygienic sterilization techniques, and clinical application of Hijama cupping therapy.',
          instructorBio:
              '${widget.instructorName} is a licensed Hijama specialist & Ruqyah consultant with over 12 years of clinical instruction experience.',
        );
    }
  }

  // 8. Sticky Bottom Enrollment Card
  Widget _buildBottomEnrollmentCard() {
    return Container(
      padding: EdgeInsets.only(
        top: 14,
        bottom: MediaQuery.of(context).padding.bottom + 14,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.lightCardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Full Lifetime Access',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11.5,
                  color: AppColors.lightTextMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Tk ${widget.price}',
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Enroll & Continue Primary Button
          Container(
            height: 50,
            decoration: BoxDecoration(
              gradient: AppGradients.greenButtonGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF082F21).withValues(alpha: 0.30),
                  offset: const Offset(0, 4),
                  blurRadius: 14,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _handleEnroll,
                borderRadius: BorderRadius.circular(16),
                splashColor: Colors.white.withValues(alpha: 0.15),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        'Enroll & Continue',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurriculumData {
  final String activeLessonTitle;
  final String module1Title;
  final String module1Status;
  final String module2Title;
  final String module2Status;
  final List<_LessonItemData> module2Lessons;
  final String overview;
  final String instructorBio;

  const _CurriculumData({
    required this.activeLessonTitle,
    required this.module1Title,
    required this.module1Status,
    required this.module2Title,
    required this.module2Status,
    required this.module2Lessons,
    required this.overview,
    required this.instructorBio,
  });
}

class _LessonItemData {
  final String title;
  final String duration;
  final bool isCompleted;
  final bool isActive;

  const _LessonItemData({
    required this.title,
    required this.duration,
    this.isCompleted = false,
    this.isActive = false,
  });
}
