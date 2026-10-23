import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/community_models.dart';
import '../../theme/app_gradients.dart';
import '../../theme/app_theme.dart';
import '../app_toast.dart';
import '../islamic_pattern.dart';

class CreatePostSheet extends StatefulWidget {
  final Function(CommunityPost post) onPostCreated;
  final String? initialCategory;

  const CreatePostSheet({
    super.key,
    required this.onPostCreated,
    this.initialCategory,
  });

  @override
  State<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<CreatePostSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  bool _isAnonymous = false;
  late String _selectedCategory;
  int _selectedBackgroundIndex = 0; // 0 = standard white/dark card
  String? _selectedAyah;
  String? _selectedAyahTranslation;

  final List<String> _categories = const [
    'Du\'a Request',
    'Healing Story',
    'Ruqyah Advice',
    'Question',
    'Reflection',
  ];

  final List<({String name, LinearGradient? gradient})> _backgroundOptions = [
    (name: 'Standard', gradient: null),
    (
      name: 'Emerald Forest',
      gradient: const LinearGradient(
        colors: [Color(0xFF082F21), Color(0xFF0F593D)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    (
      name: 'Warm Gold',
      gradient: const LinearGradient(
        colors: [Color(0xFF8A5A12), Color(0xFFD49E35)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    (
      name: 'Midnight Noor',
      gradient: const LinearGradient(
        colors: [Color(0xFF0B192C), Color(0xFF1E3E62)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    (
      name: 'Sage Haven',
      gradient: const LinearGradient(
        colors: [Color(0xFF1A3828), Color(0xFF326B4E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? _categories.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _submitPost() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (content.isEmpty && title.isEmpty) {
      AppToast.show(
        context,
        title: 'Empty Post',
        message: 'Please write your reflection or du\'a request before posting.',
        type: ToastType.warning,
      );
      return;
    }

    HapticFeedback.lightImpact();

    final chosenGradient = _backgroundOptions[_selectedBackgroundIndex].gradient;

    final newPost = CommunityPost(
      id: 'post_${DateTime.now().millisecondsSinceEpoch}',
      authorName: _isAnonymous ? 'Anonymous' : 'You',
      authorRole: _isAnonymous ? 'Community Member' : 'Member',
      timeAgo: 'Just now',
      isVerified: false,
      isAnonymous: _isAnonymous,
      category: _selectedCategory,
      title: title.isNotEmpty ? title : _selectedCategory,
      content: content.isNotEmpty ? content : title,
      arabicVerse: _selectedAyah,
      verseTranslation: _selectedAyahTranslation,
      bgGradient: chosenGradient,
      commentsCount: 0,
      sharesCount: 0,
      reactionCounts: {
        PostReactionType.like: 1,
        PostReactionType.ameen: 0,
        PostReactionType.alhamdulillah: 0,
        PostReactionType.subhanallah: 0,
        PostReactionType.care: 0,
      },
      tags: ['#${_selectedCategory.replaceAll(' ', '')}', '#RuqyahWellness'],
    );

    widget.onPostCreated(newPost);
    Navigator.of(context).pop();

    AppToast.show(
      context,
      title: 'Post Published',
      message: 'Your post is now visible to the community.',
      type: ToastType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeGrad = _backgroundOptions[_selectedBackgroundIndex].gradient;

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: BoxDecoration(
        color: context.pageBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: context.cardBorderStrong,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Create Community Post',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: context.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Divider(color: context.cardBorder, height: 1),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author & Anonymous bar
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
                            _isAnonymous ? 'A' : 'Y',
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
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
                            Text(
                              _isAnonymous ? 'Anonymous Member' : 'You',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: context.textPrimary,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.public_rounded,
                                  size: 13,
                                  color: context.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Public Community',
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

                      // Anonymous Toggle Pill
                      InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _isAnonymous = !_isAnonymous);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _isAnonymous
                                ? const Color(0xFF0B4632)
                                : context.cardBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _isAnonymous
                                  ? const Color(0xFF0B4632)
                                  : context.cardBorder,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isAnonymous
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                size: 14,
                                color: _isAnonymous
                                    ? Colors.white
                                    : context.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _isAnonymous ? 'Anonymous' : 'Identity visible',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: _isAnonymous
                                      ? Colors.white
                                      : context.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Category Selector Chips
                  Text(
                    'Select Category',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: _categories.map((cat) {
                        final isSelected = cat == _selectedCategory;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedCategory = cat);
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (context.isDarkMode
                                        ? const Color(0xFF182E25)
                                        : AppColors.tintMint)
                                    : context.cardBg,
                                borderRadius: BorderRadius.circular(16),
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
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? const Color(0xFF0B4632)
                                      : context.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Title (optional)
                  TextField(
                    controller: _titleController,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Headline / Title (e.g. Seeking du\'a for exam)',
                      hintStyle: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.textSecondary.withValues(alpha: 0.5),
                      ),
                      filled: true,
                      fillColor: context.cardBg,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
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
                        borderSide: const BorderSide(
                          color: Color(0xFF0B4632),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Facebook-style post content body (with preview if styled)
                  if (activeGrad != null) ...[
                    Container(
                      height: 170,
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: activeGrad,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          const Positioned.fill(
                            child: IslamicPattern(
                              color: Colors.white,
                              opacity: 0.12,
                              cell: 52,
                            ),
                          ),
                          Center(
                            child: TextField(
                              controller: _contentController,
                              maxLines: 4,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.45,
                              ),
                              decoration: InputDecoration(
                                hintText: 'What\'s on your mind? Share your thoughts...',
                                hintStyle: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.65),
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    TextField(
                      controller: _contentController,
                      maxLines: 6,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: context.textPrimary,
                        height: 1.45,
                      ),
                      decoration: InputDecoration(
                        hintText: 'What\'s on your mind? Share your recovery journey, du\'a request, or reflection...',
                        hintStyle: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13.5,
                          color: context.textSecondary.withValues(alpha: 0.6),
                        ),
                        filled: true,
                        fillColor: context.cardBg,
                        contentPadding: const EdgeInsets.all(16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(color: context.cardBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(color: context.cardBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: Color(0xFF0B4632),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Facebook-style post background style picker
                  Text(
                    'Card Style (Facebook Theme)',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 42,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _backgroundOptions.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final isSelected = index == _selectedBackgroundIndex;
                        final opt = _backgroundOptions[index];

                        return InkWell(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedBackgroundIndex = index);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              gradient: opt.gradient,
                              color: opt.gradient == null ? context.cardBg : null,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF0B4632)
                                    : context.cardBorder,
                                width: isSelected ? 2.5 : 1.0,
                              ),
                            ),
                            child: isSelected
                                ? Icon(
                                    Icons.check_rounded,
                                    size: 20,
                                    color: opt.gradient != null
                                        ? Colors.white
                                        : const Color(0xFF0B4632),
                                  )
                                : (opt.gradient == null
                                    ? const Icon(Icons.palette_outlined,
                                        size: 18, color: Colors.grey)
                                    : null),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Publish Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppGradients.greenButtonGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF082F21).withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _submitPost,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send_rounded,
                                color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Publish Post',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
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
        ],
      ),
    );
  }
}
