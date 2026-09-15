import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_gradients.dart';
import '../theme/app_theme.dart';
import '../widgets/app_toast.dart';

class CommunityPost {
  final String id;
  final String authorName;
  final String roleBadge; // 'Member', 'Verified Raki', 'Scholar'
  final String timeAgo;
  final String category; // 'Dua Requests', 'Healing Stories', 'Scholar Q&A'
  final String content;
  int ameenCount;
  int commentsCount;
  bool hasAmeen;

  CommunityPost({
    required this.id,
    required this.authorName,
    required this.roleBadge,
    required this.timeAgo,
    required this.category,
    required this.content,
    required this.ameenCount,
    required this.commentsCount,
    this.hasAmeen = false,
  });
}

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  String _selectedCategory = 'All';
  final TextEditingController _postController = TextEditingController();

  final List<String> _categories = const [
    'All',
    'Dua Requests',
    'Healing Stories',
    'Scholar Q&A',
  ];

  final List<CommunityPost> _posts = [
    CommunityPost(
      id: 'post_1',
      authorName: 'Abdullah Al-Mamun',
      roleBadge: 'Member',
      timeAgo: '2 hours ago',
      category: 'Healing Stories',
      content:
          'Alhamdulillah! After consistently reciting Surah Al-Baqarah and drinking Ruqyah water for 21 days, my chronic chest tightness and anxiety have completely vanished. Trust in Allah’s timing and keep persistence!',
      ameenCount: 48,
      commentsCount: 12,
      hasAmeen: true,
    ),
    CommunityPost(
      id: 'post_2',
      authorName: 'Sister Fatema',
      roleBadge: 'Member',
      timeAgo: '5 hours ago',
      category: 'Dua Requests',
      content:
          'Please make heartfelt Dua for my mother who is undergoing surgery tomorrow. May Allah grant her complete Shifa, ease her pain, and bless the medical team. Jazakumullahu khairan.',
      ameenCount: 94,
      commentsCount: 29,
      hasAmeen: false,
    ),
    CommunityPost(
      id: 'post_3',
      authorName: 'Ustazh Salim',
      roleBadge: 'Verified Raki',
      timeAgo: '1 day ago',
      category: 'Scholar Q&A',
      content:
          'Reminder: When experiencing Wasvas (whispers), do not argue with them. Immediately seek refuge in Allah (A\'udhu billahi minash shaytanir rajim) and turn your heart to remembrance (Dhikr).',
      ameenCount: 156,
      commentsCount: 18,
      hasAmeen: true,
    ),
    CommunityPost(
      id: 'post_4',
      authorName: 'Ibrahim H.',
      roleBadge: 'Member',
      timeAgo: '2 days ago',
      category: 'Dua Requests',
      content:
          'Seeking Dua for job security and relief from overwhelming financial stress. May Allah open doors of halal provision for all struggling believers.',
      ameenCount: 67,
      commentsCount: 15,
      hasAmeen: false,
    ),
  ];

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  void _showCreatePostModal() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String category = 'Dua Requests';
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
                'Share with Community',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _postController,
                maxLines: 4,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: context.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Write your Dua request, healing story, or question...',
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
                      final text = _postController.text.trim();
                      if (text.isNotEmpty) {
                        HapticFeedback.heavyImpact();
                        setState(() {
                          _posts.insert(
                            0,
                            CommunityPost(
                              id: 'post_${DateTime.now().millisecondsSinceEpoch}',
                              authorName: 'You (Patient)',
                              roleBadge: 'Member',
                              timeAgo: 'Just now',
                              category: category,
                              content: text,
                              ameenCount: 1,
                              commentsCount: 0,
                              hasAmeen: true,
                            ),
                          );
                        });
                        _postController.clear();
                        Navigator.of(context).pop();
                        AppToast.show(
                          context,
                          title: 'Post Shared',
                          message: 'Your post was successfully published to the community.',
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
    final filteredPosts = _selectedCategory == 'All'
        ? _posts
        : _posts.where((p) => p.category == _selectedCategory).toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: context.pageBg,
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: const Color(0xFF0B4632),
          onPressed: _showCreatePostModal,
          icon: const Icon(Icons.edit_note_rounded, color: Colors.white),
          label: const Text(
            'Share Dua',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        body: Column(
          children: [
            // Top Header
            _buildTopHeader(),

            const SizedBox(height: 12),

            // Category Chips Bar
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = cat == _selectedCategory;

                  return InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedCategory = cat);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF0B4632)
                            : context.cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF0B4632)
                              : context.cardBorder,
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 13.5,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : context.textPrimary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Posts Feed List
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: filteredPosts.length,
                separatorBuilder: (context, index) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final post = filteredPosts[index];
                  return _buildPostCard(post);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

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
          Container(
            width: 44,
            height: 44,
            margin: const EdgeInsets.only(right: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
              onPressed: () => Navigator.of(context).pop(),
              padding: EdgeInsets.zero,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FAITH & HEALING',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: Color(0xFF81C784),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Community & Supplications',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(CommunityPost post) {
    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Row
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
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
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: post.roleBadge == 'Verified Raki'
                                ? const Color(0xFFFFF8E1)
                                : const Color(0xFFEBF7F0),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            post.roleBadge,
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: post.roleBadge == 'Verified Raki'
                                  ? const Color(0xFFD49E35)
                                  : const Color(0xFF0B4632),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      post.timeAgo,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11.5,
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F7FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  post.category,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2980B9),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Post Content
          Text(
            post.content,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13.5,
              height: 1.45,
              color: context.textPrimary,
            ),
          ),

          const SizedBox(height: 16),

          // Footer Actions (Ameen & Comments)
          Row(
            children: [
              InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    if (post.hasAmeen) {
                      post.hasAmeen = false;
                      post.ameenCount--;
                    } else {
                      post.hasAmeen = true;
                      post.ameenCount++;
                    }
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: post.hasAmeen
                        ? const Color(0xFF0B4632)
                        : (context.isDarkMode
                            ? const Color(0xFF182E25)
                            : const Color(0xFFEBF7F0)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        post.hasAmeen
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: post.hasAmeen
                            ? Colors.white
                            : const Color(0xFF0B4632),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${post.ameenCount} Ameen',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: post.hasAmeen
                              ? Colors.white
                              : const Color(0xFF0B4632),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Row(
                children: [
                  const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: Color(0xFF90A4AE),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${post.commentsCount} replies',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
