import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/community_models.dart';
import '../theme/app_theme.dart';
import '../widgets/community/post_card.dart';
import '../widgets/community/post_composer_bar.dart';
import '../widgets/community/stories_carousel_bar.dart';
import '../widgets/community/create_story_sheet.dart';

// Re-export models for backward compatibility
export '../models/community_models.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = const [
    'All',
    'Du\'a Request',
    'Healing Story',
    'Ruqyah Advice',
    'Question',
    'Saved',
  ];

  // Community Stories state
  final List<CommunityStory> _stories = [
    CommunityStory(
      id: 'story_1',
      authorName: 'Ust. Ahmad Idris',
      authorAvatar: 'A',
      authorRole: 'Ruqyah Therapist',
      isVerified: true,
      hasUnseen: true,
      slides: [
        StorySlide(
          id: 'slide_1_1',
          caption: 'Maintain your morning & evening Adhkar with sincere tawakkul. It is your daily shield.',
          arabicVerse: 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
          verseReference: 'Ali \'Imran 3:173',
          bgGradient: const LinearGradient(
            colors: [Color(0xFF082F21), Color(0xFF0F593D), Color(0xFF1B7A54)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          timestamp: '1h ago',
          reactions: {'🤲': 34, '💚': 28, '✨': 19},
        ),
        StorySlide(
          id: 'slide_1_2',
          caption: 'Drinking Ruqyah water with 7 crushed Sidr leaves is recommended in traditional Sunnah medicine.',
          bgGradient: const LinearGradient(
            colors: [Color(0xFF0B192C), Color(0xFF1E3E62), Color(0xFF132820)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          timestamp: '45m ago',
        ),
      ],
    ),
    CommunityStory(
      id: 'story_2',
      authorName: 'Sister Maryam',
      authorAvatar: 'M',
      authorRole: 'Community Member',
      isVerified: false,
      hasUnseen: true,
      slides: [
        StorySlide(
          id: 'slide_2_1',
          caption: 'Day 14 of Surah Al-Baqarah recitation. Alhamdulillah for peace of mind and deeper sleep.',
          arabicVerse: 'وَإِذَا مَرِضْتُ فَهُوَ يَشْفِينِ',
          verseReference: 'Ash-Shu\'ara 26:80',
          bgGradient: const LinearGradient(
            colors: [Color(0xFF7A4E0B), Color(0xFFC68A1F), Color(0xFFD49E35)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          timestamp: '3h ago',
          reactions: {'🤲': 62, '💚': 45, '❤️': 31},
        ),
      ],
    ),
    CommunityStory(
      id: 'story_3',
      authorName: 'Dr. Tariq Al-Banna',
      authorAvatar: 'T',
      authorRole: 'Hijama & Shifa Specialist',
      isVerified: true,
      hasUnseen: true,
      slides: [
        StorySlide(
          id: 'slide_3_1',
          caption: 'Cupping on the 17th, 19th, and 21st of the lunar month carries immense Sunnah healing virtues.',
          bgGradient: const LinearGradient(
            colors: [Color(0xFF1C3B2B), Color(0xFF2E6047), Color(0xFF4B8B67)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          timestamp: '5h ago',
          reactions: {'👍': 41, '🤲': 58},
        ),
      ],
    ),
    CommunityStory(
      id: 'story_4',
      authorName: 'Brother Bilal',
      authorAvatar: 'B',
      authorRole: 'Community Member',
      isVerified: false,
      hasUnseen: false,
      slides: [
        StorySlide(
          id: 'slide_4_1',
          caption: 'Please make du\'a for my mother who is undergoing surgery tomorrow morning. JazakAllahu khair.',
          arabicVerse:
              'أَنِّي مَسَّنِيَ الضُّرُّ وَأَنتَ أَرْحَمُ الرَّاحِمِينَ',
          verseReference: 'Al-Anbiya 21:83',
          bgGradient: const LinearGradient(
            colors: [Color(0xFF5C2C16), Color(0xFF9E4B27), Color(0xFFC97A3E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          timestamp: '7h ago',
          reactions: {'🤲': 142, '❤️': 89},
        ),
      ],
    ),
  ];

  // Community Posts feed state
  final List<CommunityPost> _posts = [
    CommunityPost(
      id: 'post_1',
      authorName: 'Ust. Ahmad Idris',
      authorRole: 'Senior Ruqyah Therapist',
      timeAgo: '2h ago',
      isVerified: true,
      category: 'Ruqyah Advice',
      title: 'Daily spiritual shield: The 3 essential foundations',
      content: 'Spiritual wellness requires constancy over intensity. Always recite Ayat al-Kursi right after each obligatory prayer and maintain your morning and evening Adhkar. Keep your tongue moist with Istighfar, and renew your intentions for Allah’s protection.',
      arabicVerse: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
      verseTranslation: 'Allah! There is no deity except Him, the Ever-Living, the Sustainer of all existence.',
      commentsCount: 14,
      sharesCount: 8,
      reactionCounts: {
        PostReactionType.like: 18,
        PostReactionType.ameen: 46,
        PostReactionType.alhamdulillah: 27,
        PostReactionType.subhanallah: 15,
        PostReactionType.care: 9,
      },
      tags: ['#RuqyahProtection', '#DailyAdhkar', '#SunnahHealing'],
      comments: [
        PostComment(
          id: 'c_1',
          authorName: 'Maryam A.',
          authorRole: 'Community Member',
          timeAgo: '1h ago',
          text: 'JazakAllahu Khairan for this reminder. This routine has brought so much calmness into our home.',
          likesCount: 6,
          isLiked: true,
        ),
        PostComment(
          id: 'c_2',
          authorName: 'Abdullah Omar',
          authorRole: 'Community Member',
          timeAgo: '45m ago',
          text: 'Is it recommended to recite Surah Al-Falaq and An-Nas three times before sleep as well?',
          likesCount: 3,
        ),
      ],
    ),
    CommunityPost(
      id: 'post_2',
      authorName: 'Fatima Z.',
      authorRole: 'Community Member',
      timeAgo: '4h ago',
      isVerified: false,
      category: 'Healing Story',
      title: 'Alhamdulillah: 21 Days of Ruqyah & Complete Peace',
      content: 'After weeks of severe insomnia and panic attacks, I committed to the daily protection playlist and listening to Surah Al-Baqarah. Today I slept 7 continuous hours with zero nightmares. Never lose hope in Allah\'s Shifa!',
      bgGradient: const LinearGradient(
        colors: [Color(0xFF082F21), Color(0xFF0F593D)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      commentsCount: 22,
      sharesCount: 11,
      reactionCounts: {
        PostReactionType.like: 29,
        PostReactionType.ameen: 85,
        PostReactionType.alhamdulillah: 74,
        PostReactionType.subhanallah: 38,
        PostReactionType.care: 19,
      },
      tags: ['#Alhamdulillah', '#HealingJourney', '#ShifaStory'],
      comments: [
        PostComment(
          id: 'c_3',
          authorName: 'Dr. Salma Rahman',
          authorRole: 'Medical Consultant & Ruqyah Guide',
          timeAgo: '3h ago',
          isVerified: true,
          text: 'SubhanAllah! May Allah keep you steadfast, shield you from every harm, and grant lasting wellness.',
          likesCount: 12,
          isLiked: true,
        ),
      ],
    ),
    CommunityPost(
      id: 'post_3',
      authorName: 'Brother Harun',
      authorRole: 'Community Member',
      timeAgo: '6h ago',
      isVerified: false,
      category: 'Du\'a Request',
      title:
          'Urgent Du\'a Request for our infant son who has unexplained fever',
      content: 'Our 8-month-old baby has been crying continuously with high fever for the last 48 hours. Doctors have checked him, but we ask the believers to recite the Sunnah du\'a for children: "U\'eedhuka bikalimatillahit-tammah..." Please remember him in your Tahajjud.',
      arabicVerse: 'أُعِيذُكَ بِكَلِمَاتِ اللَّهِ التَّامَّةِ مِنْ كُلِّ شَيْطَانٍ وَهَامَّةٍ',
      verseTranslation: 'I seek protection for you in the perfect words of Allah from every devil and poisonous creature.',
      commentsCount: 31,
      sharesCount: 19,
      reactionCounts: {
        PostReactionType.like: 8,
        PostReactionType.ameen: 148,
        PostReactionType.alhamdulillah: 12,
        PostReactionType.subhanallah: 7,
        PostReactionType.care: 62,
      },
      tags: ['#DuaRequest', '#ProtectionForChildren', '#Ameen'],
      comments: [
        PostComment(
          id: 'c_4',
          authorName: 'Umm Ayman',
          authorRole: 'Mother & Member',
          timeAgo: '5h ago',
          text: 'Ameen ya Rabb! Reciting on pure water and wiping his forehead will also bring immediate ease insha\'Allah.',
          likesCount: 15,
        ),
      ],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleStoryCreated(StorySlide newSlide) {
    setState(() {
      // Find existing myStory or create one
      final myStoryIndex = _stories.indexWhere((s) => s.isMyStory);
      if (myStoryIndex != -1) {
        _stories[myStoryIndex].slides.add(newSlide);
        _stories[myStoryIndex].hasUnseen = false;
      } else {
        _stories.insert(
          0,
          CommunityStory(
            id: 'my_story_${DateTime.now().millisecondsSinceEpoch}',
            authorName: 'You',
            authorAvatar: 'Y',
            authorRole: 'Community Member',
            isMyStory: true,
            hasUnseen: false,
            slides: [newSlide],
          ),
        );
      }
    });
  }

  void _handlePostCreated(CommunityPost newPost) {
    setState(() {
      _posts.insert(0, newPost);
    });
  }

  List<CommunityPost> get _filteredPosts {
    return _posts.where((post) {
      // Category filter
      if (_selectedCategory == 'Saved') {
        if (!post.isSaved) return false;
      } else if (_selectedCategory != 'All') {
        if (post.category != _selectedCategory) return false;
      }

      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesTitle = post.title.toLowerCase().contains(q);
        final matchesContent = post.content.toLowerCase().contains(q);
        final matchesAuthor = post.authorName.toLowerCase().contains(q);
        final matchesTags = post.tags.any((t) => t.toLowerCase().contains(q));
        if (!matchesTitle &&
            !matchesContent &&
            !matchesAuthor &&
            !matchesTags) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredPosts;

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
            children: [
              // 1. Facebook-style Top Navigation Header
              _buildTopHeader(),

              // 2. Main Scrollable Community Feed
              Expanded(
                child: RefreshIndicator(
                  color: const Color(0xFF0B4632),
                  onRefresh: () async {
                    HapticFeedback.lightImpact();
                    await Future.delayed(const Duration(milliseconds: 600));
                    setState(() {});
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),

                        // Post Composer Bar ("What's on your mind?")
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: PostComposerBar(
                            onPostCreated: _handlePostCreated,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Section Header: Stories
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'Community Stories',
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: context.textPrimary,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) => CreateStorySheet(
                                      onStoryCreated: _handleStoryCreated,
                                    ),
                                  );
                                },
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.add_circle_outline_rounded,
                                      size: 16,
                                      color: Color(0xFF0B4632),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Add Story',
                                      style: TextStyle(
                                        fontFamily: 'PlusJakartaSans',
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF0B4632),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Facebook-style Stories Carousel Bar
                        StoriesCarouselBar(
                          stories: _stories,
                          onStoryCreated: _handleStoryCreated,
                          onStorySeen: () => setState(() {}),
                        ),

                        const SizedBox(height: 16),

                        // Category Filter Pills
                        _buildCategoryFilterRow(),

                        const SizedBox(height: 16),

                        // Feed Posts
                        if (filtered.isEmpty) ...[
                          _buildEmptyState(),
                        ] else ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            child: Column(
                              children: filtered.map((post) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: PostCard(
                                    post: post,
                                    onPostUpdated: () => setState(() {}),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],

                        // Community Guidelines Card
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                          child: _buildGuidelinesCard(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Top Header
  Widget _buildTopHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      decoration: BoxDecoration(
        color: context.pageBg,
        border: Border(
          bottom: BorderSide(
            color: context.cardBorder.withValues(alpha: 0.5),
            width: 1.0,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: context.textPrimary,
                ),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Community',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: context.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Share reflections, stories & du\'as',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: context.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Search Button
              IconButton(
                icon: Icon(
                  _isSearching ? Icons.close_rounded : Icons.search_rounded,
                  color: context.textPrimary,
                ),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchQuery = '';
                      _searchController.clear();
                    }
                  });
                },
              ),

              // Filter or Notification Bell
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: context.cardBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.cardBorder),
                ),
                child: Center(
                  child: Stack(
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        color: context.textPrimary,
                        size: 20,
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF0B4632),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Search Field if active
          if (_isSearching) ...[
            const SizedBox(height: 10),
            Container(
              height: 42,
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.cardBorder),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13.5,
                  color: context.textPrimary,
                ),
                onChanged: (val) {
                  setState(() => _searchQuery = val.trim());
                },
                decoration: InputDecoration(
                  hintText: 'Search community by topic, author, or keyword...',
                  hintStyle: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.5,
                    color: context.textSecondary.withValues(alpha: 0.6),
                  ),
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 2. Category Filter Row
  Widget _buildCategoryFilterRow() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? (context.isDarkMode
                          ? const Color(0xFF182E25)
                          : AppColors.tintMint)
                    : context.cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF0B4632)
                      : context.cardBorder,
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected
                      ? const Color(0xFF0B4632)
                      : context.textPrimary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 3. Empty State
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24.0),
        child: Column(
          children: [
            Icon(
              Icons.forum_outlined,
              size: 48,
              color: context.textSecondary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 14),
            Text(
              'No posts found in $_selectedCategory',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try changing your filter or share the first reflection!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B4632),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                setState(() {
                  _selectedCategory = 'All';
                  _searchQuery = '';
                  _searchController.clear();
                });
              },
              child: const Text(
                'Show All Posts',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 4. Guidelines Card
  Widget _buildGuidelinesCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.isDarkMode
            ? const Color(0xFF182E25)
            : AppColors.tintMint.withValues(alpha: 0.80),
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
              Flexible(
                child: Text(
                  'Community Guidelines & Etiquette',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: context.isDarkMode
                        ? const Color(0xFF81C784)
                        : const Color(0xFF0B4632),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildGuidelineItem(
            'Maintain sincere Islamic brotherhood & supportive tone',
          ),
          _buildGuidelineItem('No unverified claims or non-Shar\'i practices'),
          _buildGuidelineItem(
            'Therapist consultation is advised for severe symptoms',
          ),
          _buildGuidelineItem('Moderators review flagged reports regularly'),
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
