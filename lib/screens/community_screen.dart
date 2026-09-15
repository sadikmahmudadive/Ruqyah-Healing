import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_gradients.dart';
import '../theme/app_theme.dart';
import '../widgets/app_toast.dart';

class CommunityPost {
  final String id;
  final String authorName;
  final String role;
  final String timeAgo;
  final bool isVerified;
  final String title;
  final String content;
  int likesCount;
  int commentsCount;
  final String tag; // 'Helpful', 'Question', 'Story'
  final String? topCommentAuthor;
  final String? topCommentTime;
  final String? topCommentText;

  CommunityPost({
    required this.id,
    required this.authorName,
    required this.role,
    required this.timeAgo,
    this.isVerified = false,
    required this.title,
    required this.content,
    required this.likesCount,
    required this.commentsCount,
    required this.tag,
    this.topCommentAuthor,
    this.topCommentTime,
    this.topCommentText,
  });
}

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  int _selectedTabIndex = 0; // 0 = Community, 1 = Stories
  bool _isAnonymous = false;
  String _selectedTopic = 'Ruqyah';

  final TextEditingController _questionController = TextEditingController();

  final List<String> _popularTopics = const [
    'Ruqyah',
    'Hijama',
    'Anxiety Relief',
    'Sleep',
    'Faith',
    'Children',
    'Stress',
    'Spiritual Wellness',
  ];

  final List<CommunityPost> _posts = [
    CommunityPost(
      id: 'post_1',
      authorName: 'Ust. Ahmad Idris',
      role: 'Ruqyah Therapist',
      timeAgo: '2h ago',
      isVerified: true,
      title: 'Tips for maintaining protection daily',
      content:
          'Always recite Ayat al-Kursi after each prayer and maintain your morning and evening Adhkar. Consistency is key to spiritual wellness...',
      likesCount: 24,
      commentsCount: 8,
      tag: 'Helpful',
      topCommentAuthor: 'Maryam A.',
      topCommentTime: '1h ago',
      topCommentText: 'JazakAllahu khair for these reminders.',
    ),
    CommunityPost(
      id: 'post_2',
      authorName: 'Abdullah M.',
      role: 'Community Member',
      timeAgo: '5h ago',
      isVerified: false,
      title: 'Alhamdulillah for 21 days of Ruqyah',
      content:
          'After following the daily protection playlist and listening to Surah Al-Baqarah, my sleep quality has improved significantly.',
      likesCount: 42,
      commentsCount: 15,
      tag: 'Story',
      topCommentAuthor: 'Dr. Salma Rahman',
      topCommentTime: '3h ago',
      topCommentText: 'May Allah keep you steadfast and grant full Shifa.',
    ),
  ];

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  void _showAskQuestionModal({required bool isQuestion}) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isQuestion ? 'Ask a Question' : 'Share an Update',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _questionController,
                maxLines: 4,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: context.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: isQuestion
                      ? 'Ask the community or scholars for advice...'
                      : 'Share your healing progress or inspiration...',
                  hintStyle: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13.5,
                    color: context.textSecondary.withValues(alpha: 0.60),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: context.cardBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: context.cardBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF0B4632), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppGradients.greenButtonGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      final text = _questionController.text.trim();
                      if (text.isNotEmpty) {
                        HapticFeedback.heavyImpact();
                        setState(() {
                          _posts.insert(
                            0,
                            CommunityPost(
                              id: 'post_${DateTime.now().millisecondsSinceEpoch}',
                              authorName: _isAnonymous ? 'Anonymous' : 'You',
                              role: 'Member',
                              timeAgo: 'Just now',
                              isVerified: false,
                              title: isQuestion ? 'Question from Community' : 'Community Update',
                              content: text,
                              likesCount: 1,
                              commentsCount: 0,
                              tag: isQuestion ? 'Question' : 'Story',
                            ),
                          );
                        });
                        _questionController.clear();
                        Navigator.of(context).pop();
                        AppToast.show(
                          context,
                          title: 'Post Published',
                          message: 'Your post has been shared with the community.',
                          type: ToastType.success,
                        );
                      }
                    },
                    child: const Text(
                      'Publish Post',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
        backgroundColor: context.pageBg,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Header Area
              _buildTopHeader(),

              const SizedBox(height: 12),

              // 2. Main Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Action Cards Row
                      _buildActionCardsRow(),

                      const SizedBox(height: 16),

                      // Anonymous Toggle Card
                      _buildAnonymousToggleCard(),

                      const SizedBox(height: 20),

                      // Popular Topics Section
                      _buildPopularTopicsSection(),

                      const SizedBox(height: 20),

                      // Community Posts Feed
                      ..._posts.map((post) => Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: _buildPostCard(post),
                          )),

                      const SizedBox(height: 12),

                      // Community Guidelines Banner
                      _buildGuidelinesCard(),

                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: context.textPrimary),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              Text(
                'Community',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 36.0),
            child: Text(
              'Learn, share & support each other.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13.5,
                color: context.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Tabs Row (Community / Stories)
          Row(
            children: [
              _buildHeaderTab('Community', 0),
              const SizedBox(width: 24),
              _buildHeaderTab('Stories', 1),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderTab(String title, int index) {
    final isSelected = _selectedTabIndex == index;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedTabIndex = index);
      },
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? const Color(0xFF0B4632) : context.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 2.5,
            width: 40,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF0B4632) : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  // 2 Action Cards Row
  Widget _buildActionCardsRow() {
    return Row(
      children: [
        // Ask a Question Card
        Expanded(
          child: _buildBentoCard(
            title: 'Ask a Question',
            subtitle: 'Get community advice',
            icon: Icons.help_outline_rounded,
            iconBgColor: const Color(0xFFEBF7F0),
            iconColor: const Color(0xFF0B4632),
            onTap: () => _showAskQuestionModal(isQuestion: true),
          ),
        ),
        const SizedBox(width: 14),

        // Share an Update Card
        Expanded(
          child: _buildBentoCard(
            title: 'Share an Update',
            subtitle: 'Inspire others',
            icon: Icons.edit_outlined,
            iconBgColor: const Color(0xFFFFF3E8),
            iconColor: const Color(0xFFE67E22),
            onTap: () => _showAskQuestionModal(isQuestion: false),
          ),
        ),
      ],
    );
  }

  Widget _buildBentoCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.cardBorder, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: context.isDarkMode
                      ? const Color(0xFF182E25)
                      : iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
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
            ],
          ),
        ),
      ),
    );
  }

  // Anonymous Toggle Card
  Widget _buildAnonymousToggleCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.cardBorder, width: 1.0),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: context.isDarkMode
                  ? const Color(0xFF182E25)
                  : const Color(0xFFEBF7F0),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: Color(0xFF0B4632),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Post as Anonymous',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Your identity will be hidden',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.5,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isAnonymous,
            activeColor: const Color(0xFF0B4632),
            onChanged: (val) {
              HapticFeedback.selectionClick();
              setState(() => _isAnonymous = val);
            },
          ),
        ],
      ),
    );
  }

  // Popular Topics Chips
  Widget _buildPopularTopicsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular Topics',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _popularTopics.map((topic) {
            final isSelected = topic == _selectedTopic;

            return InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedTopic = topic);
              },
              borderRadius: BorderRadius.circular(18),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (context.isDarkMode
                          ? const Color(0xFF182E25)
                          : const Color(0xFFEBF7F0))
                      : context.cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF0B4632)
                        : context.cardBorder,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Text(
                  topic,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFF0B4632)
                        : context.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Post Card Feed
  Widget _buildPostCard(CommunityPost post) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.cardBorder, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Row
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF0B4632).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    post.authorName.isNotEmpty ? post.authorName[0] : 'U',
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0B4632),
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
                            post.authorName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: context.textPrimary,
                            ),
                          ),
                        ),
                        if (post.isVerified == true) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF0B4632),
                            size: 16,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${post.role} • ${post.timeAgo}',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11.5,
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Options Button
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: context.isDarkMode
                      ? const Color(0xFF182E25)
                      : const Color(0xFFF5F7F6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.more_horiz_rounded,
                  color: Color(0xFF90A4AE),
                  size: 18,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Post Title
          Text(
            post.title,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: context.textPrimary,
            ),
          ),

          const SizedBox(height: 6),

          // Post Content
          Text(
            post.content,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13.5,
              height: 1.45,
              color: context.textSecondary,
            ),
          ),

          const SizedBox(height: 14),

          // Likes, Comments & Tag Pill Row
          Row(
            children: [
              Icon(Icons.thumb_up_alt_outlined, color: context.textSecondary, size: 16),
              const SizedBox(width: 6),
              Text(
                '${post.likesCount}',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: context.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.chat_bubble_outline_rounded, color: context.textSecondary, size: 16),
              const SizedBox(width: 6),
              Text(
                '${post.commentsCount}',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: context.textSecondary,
                ),
              ),
              const Spacer(),

              // Tag Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B4632),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  post.tag,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          if (post.topCommentAuthor != null && post.topCommentText != null) ...[
            const SizedBox(height: 14),
            // Top Comment Highlight Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.isDarkMode
                    ? const Color(0xFF182E25)
                    : const Color(0xFFF5F7F6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        post.topCommentAuthor!,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: context.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        post.topCommentTime ?? '',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    post.topCommentText!,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Guidelines Banner Card
  Widget _buildGuidelinesCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.isDarkMode
            ? const Color(0xFF182E25)
            : const Color(0xFFEBF7F0).withValues(alpha: 0.80),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF0B4632).withValues(alpha: 0.20),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.circle, color: Color(0xFF0B4632), size: 8),
              const SizedBox(width: 8),
              Text(
                'Community Guidelines',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: context.isDarkMode
                      ? const Color(0xFF81C784)
                      : const Color(0xFF0B4632),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildGuidelineItem('Be respectful & supportive'),
          _buildGuidelineItem('No personal attacks or judgment'),
          _buildGuidelineItem('No medical diagnoses or prescriptions'),
          _buildGuidelineItem('Reports reviewed by moderators'),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Read full guidelines',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: context.isDarkMode
                      ? const Color(0xFF81C784)
                      : const Color(0xFF0B4632),
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_forward_rounded,
                color: context.isDarkMode
                    ? const Color(0xFF81C784)
                    : const Color(0xFF0B4632),
                size: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          const Icon(Icons.check_rounded, color: Color(0xFF0B4632), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12.5,
                color: context.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
