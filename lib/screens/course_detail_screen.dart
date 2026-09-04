import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_gradients.dart';
import '../widgets/app_toast.dart';
import 'quiz_certificate_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseTitle;
  final String instructorName;
  final String level;
  final double price;

  const CourseDetailScreen({
    super.key,
    this.courseTitle = 'Hijama Practitioner Foundation',
    this.instructorName = 'Dr. Salma Rahman',
    this.level = 'Intermediate',
    this.price = 49.99,
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  String _selectedTab = 'Curriculum'; // 'Curriculum', 'Overview', 'Instructor'
  bool _isBookmarked = false;
  bool _isPlayingVideo = false;

  void _handleEnroll() {
    HapticFeedback.heavyImpact();
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
        backgroundColor: const Color(0xFFF5F7F6),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5F7F6),
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8E5), width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Color(0xFF15221D),
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
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E8E5), width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    _isBookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_outline_rounded,
                    color: const Color(0xFF15221D),
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
              padding: const EdgeInsets.only(right: 16.0, top: 8.0, bottom: 8.0),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E8E5), width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.share_outlined,
                    color: Color(0xFF15221D),
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
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.level,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFE67E22),
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
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF15221D),
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
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF15221D),
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
                                  color: Color(0xFF90A4AE),
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
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF15221D),
                          ),
                        ),
                        const Text(
                          '(216)',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: Color(0xFF90A4AE),
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
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
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
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFF12241F),
              ),
            ),

            // Dark Overlay Layer
            Container(
              color: Colors.black.withValues(alpha: 0.45),
            ),

            // Top Left Tag: Lesson 3: Principles
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                HapticFeedback.heavyImpact();
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: const Color(0xFF082F21).withValues(alpha: 0.92),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: const [
                        Text(
                          'Principles of Cupping',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Spacer(),
                        Text(
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
                pageBuilder: (_, __, ___) => const QuizCertificateScreen(),
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
                pageBuilder: (_, __, ___) => const QuizCertificateScreen(),
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFEBF7F0),
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
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF15221D),
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
                color: Color(0xFF90A4AE),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
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
        Container(height: 1, color: const Color(0xFFE2E8E5)),
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
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected
                  ? const Color(0xFF0B4632)
                  : const Color(0xFF90A4AE),
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
    return Column(
      children: [
        // Module 1: Foundations
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFEBF7F0),
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
              const Text(
                'Module 1: Foundations',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF15221D),
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B4632),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '3/3 Complete',
                  style: TextStyle(
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

        // Module 2: Cupping Principles
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
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
              // Header Row
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE67E22),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Module 2: Cupping Principles',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF15221D),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '1/3 In Progress',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE67E22),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),
              Container(height: 1, color: const Color(0xFFE2E8E5)),
              const SizedBox(height: 10),

              // Lesson 1: Introduction to Hijama
              _buildLessonItem(
                icon: Icons.check_circle_outline_rounded,
                iconColor: const Color(0xFF0B4632),
                title: 'Introduction to Hijama',
                duration: '8 min',
                isCompleted: true,
              ),

              const SizedBox(height: 8),

              // Lesson 2: Principles of Cupping (Active Playing)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF7F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.volume_up_rounded,
                      color: Color(0xFF0B4632),
                      size: 18,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Principles of Cupping',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0B4632),
                        ),
                      ),
                    ),
                    Text(
                      '12 min',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0B4632),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Lesson 3: Safety & Contraindications
              _buildLessonItem(
                icon: Icons.play_circle_outline_rounded,
                iconColor: const Color(0xFF90A4AE),
                title: 'Safety & Contraindications',
                duration: '10 min',
              ),
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
                color: const Color(0xFF52625B),
              ),
            ),
          ),
          Text(
            duration,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: Color(0xFF90A4AE),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Comprehensive foundation course covering essential principles, hygienic sterilization techniques, and clinical application of Hijama cupping therapy.',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          color: Color(0xFF6E7E77),
          height: 1.45,
        ),
      ),
    );
  }

  Widget _buildInstructorSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Dr. Salma Rahman is a licensed Hijama specialist & Ruqyah consultant with over 12 years of clinical instruction experience.',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          color: Color(0xFF6E7E77),
          height: 1.45,
        ),
      ),
    );
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
        color: Colors.white,
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
                  color: Color(0xFF90A4AE),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Tk ${widget.price}',
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF15221D),
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
