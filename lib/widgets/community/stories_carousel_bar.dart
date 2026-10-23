import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/community_models.dart';
import '../../theme/app_gradients.dart';
import '../../theme/app_theme.dart';
import '../islamic_pattern.dart';
import 'create_story_sheet.dart';
import 'story_viewer_modal.dart';

class StoriesCarouselBar extends StatelessWidget {
  final List<CommunityStory> stories;
  final Function(StorySlide newSlide) onStoryCreated;
  final VoidCallback onStorySeen;

  const StoriesCarouselBar({
    super.key,
    required this.stories,
    required this.onStoryCreated,
    required this.onStorySeen,
  });

  void _openCreateStory(BuildContext context) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateStorySheet(
        onStoryCreated: onStoryCreated,
      ),
    );
  }

  void _openStoryViewer(BuildContext context, int storyIndex) {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        pageBuilder: (ctx, anim, secAnim) => StoryViewerModal(
          stories: stories,
          initialStoryIndex: storyIndex,
          onStorySeen: onStorySeen,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 172,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: stories.length + 1, // +1 for "Create Story" card
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildCreateStoryCard(context);
          }
          final storyIndex = index - 1;
          final story = stories[storyIndex];
          return _buildCommunityStoryCard(context, story, storyIndex);
        },
      ),
    );
  }

  // 1. "Create Story" Card (Facebook Style)
  Widget _buildCreateStoryCard(BuildContext context) {
    return InkWell(
      onTap: () => _openCreateStory(context),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 106,
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: context.cardBorder, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: context.isDarkMode ? 0.25 : 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            children: [
              // Upper 60%: User Profile Background
              Expanded(
                flex: 6,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF0B4632).withValues(alpha: 0.25),
                        const Color(0xFF0B4632).withValues(alpha: 0.10),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF0B4632).withValues(alpha: 0.20),
                        border: Border.all(
                          color: const Color(0xFF0B4632).withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person_rounded,
                          color: Color(0xFF0B4632),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Lower 40%: Add Story Button & Label
              Expanded(
                flex: 4,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    // Floating Plus Icon Overlap
                    Positioned(
                      top: -16,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppGradients.greenButtonGradient,
                          border: Border.all(
                            color: context.cardBg,
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0B4632).withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),

                    // Label
                    const Positioned(
                      bottom: 8,
                      child: Text(
                        'Create Story',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0B4632),
                        ),
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

  // 2. Community Story Card
  Widget _buildCommunityStoryCard(
      BuildContext context, CommunityStory story, int storyIndex) {
    final latest = story.latestSlide;

    return InkWell(
      onTap: () => _openStoryViewer(context, storyIndex),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 106,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: context.isDarkMode ? 0.35 : 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              // Story Background Gradient
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: latest.bgGradient,
                  ),
                ),
              ),

              // Geometric Pattern
              const Positioned.fill(
                child: IslamicPattern(
                  color: Colors.white,
                  opacity: 0.12,
                  cell: 42,
                ),
              ),

              // Vignette Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.4),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.75),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),

              // Preview Text in Center
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 46, 10, 32),
                  child: Center(
                    child: Text(
                      latest.arabicVerse ?? latest.caption,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      textDirection: latest.arabicVerse != null
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      style: TextStyle(
                        fontFamily: latest.arabicVerse != null
                            ? 'Amiri'
                            : 'PlusJakartaSans',
                        fontSize: latest.arabicVerse != null ? 12.5 : 10.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.95),
                        height: 1.35,
                      ),
                    ),
                  ),
                ),
              ),

              // Top-Left: Author Avatar with unread ring
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: story.hasUnseen
                          ? AppColors.accentGold
                          : Colors.white.withValues(alpha: 0.4),
                      width: story.hasUnseen ? 2.0 : 1.0,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF082F21),
                      ),
                      child: Center(
                        child: Text(
                          story.authorName.isNotEmpty ? story.authorName[0] : 'U',
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom Author Name
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Text(
                  story.authorName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Color(0xCC000000),
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
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
}
