import 'dart:ui';

import 'package:flutter/material.dart';
import 'package0/flutter/services.dart';
import 'package:flutter/services.dart';

class LearnTab extends StatefulWidget {
  const LearnTab({super.key});

  @override
  State<LearnTab> createState() => _LearnTabState();
}

class _LearnTabState extends State<LearnTab> {
  String _selectedTab = 'Community'; // 'Community' or 'Stories'
  bool _isAnonymous = false;
  String _selectedTopic = 'Ruqyah';
  final Map<String, bool> _likedPosts = {};

  final List<String> _topics = const [
    'Ruqyah',
    'Hijama',
    'Anxiety Relief',
    'Sleep',
    'Faith',
    'Children',
    'Stress',
    'Spiritual Wellness',
  ];

  final List<Map<String, dynamic>> _communityPosts = const [
    {
      'id': 'post_1',
      'authorName': 'Ust. Ahmad Idris',
      'authorRole': 'Ruqyah Therapist',
      'timeAgo': '2h ago',
      'isVerified': true,
      'title': 'Tips for maintaining protection daily',
      'body':
          'Always recite Ayat al-Kursi after each prayer and maintain your morning and evening Adhkar. Consistency is key to spiritual wellness...',
      'likesCount': 24,
      'commentsCount': 8,
      'badgeText': 'Helpful',
      'badgeIsGreen': true,
      'topCommentAuthor': 'Maryam A.',
      'topCommentTime': '1h ago',
      'topCommentText': 'JazakAllahu khair for these reminders.',
    },
    {
      'id': 'post_2',
      'authorName': 'Dr. Salma Rahman',
      'authorRole': 'Ruqyah Specialist',
      'timeAgo': '5h ago',
      'isVerified': true,
      'title': 'Understanding the symptoms of spiritual distress',
      'body':
          'Restlessness during Quran recitation and unexplained fatigue can be signs of spiritual burden. Seeking authentic Quranic Ruqyah brings peace and healing...',
      'likesCount': 42,
      'commentsCount': 15,
      'badgeText': 'Verified',
      'badgeIsGreen': false,
      'topCommentAuthor': 'Tariq H.',
      'topCommentTime': '3h ago',
      'topCommentText': 'Very informative guide, doctor.',
    },
  ];

  void _showAskQuestionDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                    color: const Color(0xFFE2E8E5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ask a Community Question',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF15221D),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                maxLines: 4,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Color(0xFF15221D),
                ),
                decoration: InputDecoration(
                  hintText: 'Type your question or spiritual concern here...',
                  hintStyle: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13.5,
                    color: const Color(0xFFB0BEC5),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF5F7F6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B4632),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Your question has been posted!'),
                        backgroundColor: Color(0xFF0B4632),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text(
                    'Post Question',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
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
          titleSpacing: 20,
          automaticallyImplyLeading: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Community',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF15221D),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Learn, share & support each other.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6E7E77),
                ),
              ),
            ],
          ),
          toolbarHeight: 68,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Tab Segment Bar (Community vs Stories)
              _buildTabSegmentBar(),

              const SizedBox(height: 16),

              if (_selectedTab == 'Community') ...[
                // 2. Action Cards Row (Ask a Question / Share an Update)
                _buildActionCardsRow(),

                const SizedBox(height: 14),

                // 3. Post as Anonymous Toggle Card
                _buildAnonymousCard(),

                const SizedBox(height: 20),

                // 4. Popular Topics Section
                _buildPopularTopicsSection(),

                const SizedBox(height: 20),

                // 5. Community Posts List
                ..._communityPosts.map((post) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _buildPostCard(post),
                  );
                }),

                const SizedBox(height: 4),

                // 6. Community Guidelines Card
                _buildGuidelinesCard(),

                const SizedBox(height: 24),
              ] else ...[
                // Healing Stories Feed View
                _buildStoriesFeedView(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // 1. Tab Segment Bar
  Widget _buildTabSegmentBar() {
    return Column(
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedTab = 'Community');
              },
              child: Column(
                children: [
                  Text(
                    'Community',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _selectedTab == 'Community'
                          ? const Color(0xFF0B4632)
                          : const Color(0xFF90A4AE),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 2.5,
                    width: 72,
                    decoration: BoxDecoration(
                      color: _selectedTab == 'Community'
                          ? const Color(0xFF0B4632)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedTab = 'Stories');
              },
              child: Column(
                children: [
                  Text(
                    'Stories',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _selectedTab == 'Stories'
                          ? const Color(0xFF0B4632)
                          : const Color(0xFF90A4AE),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 2.5,
                    width: 48,
                    decoration: BoxDecoration(
                      color: _selectedTab == 'Stories'
                          ? const Color(0xFF0B4632)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Container(height: 1, color: const Color(0xFFE2E8E5)),
      ],
    );
  }

  // 2. Action Cards Row
  Widget _buildActionCardsRow() {
    return Row(
      children: [
        // Ask a Question Card
        Expanded(
          child: _buildActionCard(
            title: 'Ask a Question',
            subtitle: 'Get community advice',
            icon: Icons.help_outline_rounded,
            iconBg: const Color(0xFFEBF7F0),
            iconColor: const Color(0xFF0B4632),
            onTap: _showAskQuestionDialog,
          ),
        ),
        const SizedBox(width: 12),
        // Share an Update Card
        Expanded(
          child: _buildActionCard(
            title: 'Share an Update',
            subtitle: 'Inspire others',
            icon: Icons.edit_outlined,
            iconBg: const Color(0xFFFFF3E8),
            iconColor: const Color(0xFFE67E22),
            onTap: () {
              HapticFeedback.selectionClick();
              _showAskQuestionDialog();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
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
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF15221D),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: Color(0xFF90A4AE),
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

  // 3. Post as Anonymous Toggle Card
  Widget _buildAnonymousCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7F6),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8E5), width: 1.0),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: Color(0xFF6E7E77),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Post as Anonymous',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF15221D),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Your identity will be hidden',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.5,
                    color: Color(0xFF90A4AE),
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: _isAnonymous,
              activeColor: Colors.white,
              activeTrackColor: const Color(0xFF0B4632),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: const Color(0xFFE2E8E5),
              onChanged: (val) {
                HapticFeedback.selectionClick();
                setState(() => _isAnonymous = val);
              },
            ),
          ),
        ],
      ),
    );
  }

  // 4. Popular Topics Section
  Widget _buildPopularTopicsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Popular Topics',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF15221D),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _topics.map((topic) {
            final isSelected = topic == _selectedTopic;
            return InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedTopic = topic);
              },
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFEBF7F0) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF0B4632)
                        : const Color(0xFFE2E8E5),
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Text(
                  topic,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12.5,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFF0B4632)
                        : const Color(0xFF52625B),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // 5. Community Post Card
  Widget _buildPostCard(Map<String, dynamic> post) {
    final postId = post['id'] as String;
    final isLiked = _likedPosts[postId] ?? false;
    final likesCount = (post['likesCount'] as int) + (isLiked ? 1 : 0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          // Author Header Row
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 44,
                  height: 44,
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
                            post['authorName'] as String,
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF15221D),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (post['isVerified'] == true) ...[
                          const SizedBox(width: 6),
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
                      '${post['authorRole']} • ${post['timeAgo']}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Color(0xFF90A4AE),
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
                  color: const Color(0xFFF2F5F4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.more_horiz_rounded,
                  color: Color(0xFF6E7E77),
                  size: 20,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Post Title & Body
          Text(
            post['title'] as String,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF15221D),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            post['body'] as String,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: Color(0xFF6E7E77),
              height: 1.4,
            ),
          ),

          const SizedBox(height: 14),
          Container(height: 1, color: const Color(0xFFE2E8E5)),
          const SizedBox(height: 12),

          // Reactions & Badge Row
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _likedPosts[postId] = !isLiked;
                  });
                },
                child: Row(
                  children: [
                    Icon(
                      isLiked ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
                      color: isLiked
                          ? const Color(0xFF0B4632)
                          : const Color(0xFF6E7E77),
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$likesCount',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight:
                            isLiked ? FontWeight.w700 : FontWeight.w600,
                        color: isLiked
                            ? const Color(0xFF0B4632)
                            : const Color(0xFF6E7E77),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 18),

              const Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: Color(0xFF6E7E77),
                    size: 18,
                  ),
                  SizedBox(width: 6),
                  Text(
                    '8',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6E7E77),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: post['badgeIsGreen'] == true
                      ? const Color(0xFF0B4632)
                      : const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  post['badgeText'] as String,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: post['badgeIsGreen'] == true
                        ? Colors.white
                        : const Color(0xFFD49E35),
                  ),
                ),
              ),
            ],
          ),

          // Top Comment Nested Card
          if (post['topCommentText'] != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7F6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        post['topCommentAuthor'] as String,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF15221D),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        post['topCommentTime'] as String,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: Color(0xFF90A4AE),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    post['topCommentText'] as String,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12.5,
                      color: Color(0xFF6E7E77),
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

  // 6. Community Guidelines Card
  Widget _buildGuidelinesCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF7F0),
        borderRadius: BorderRadius.circular(20),
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
                'Community Guidelines',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0B4632),
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

          InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
            },
            child: const Row(
              children: [
                Text(
                  'Read full guidelines',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0B4632),
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0xFF0B4632),
                  size: 14,
                ),
              ],
            ),
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
          const Icon(
            Icons.check_rounded,
            color: Color(0xFF0B4632),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF52625B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Healing Stories Feed View
  Widget _buildStoriesFeedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(18),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Inspiring Healing Testimonials',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF15221D),
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Real patient stories of spiritual recovery, Ruqyah peace, and Hijama wellness.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: Color(0xFF6E7E77),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
