import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/community_models.dart';
import '../../theme/app_gradients.dart';
import '../../theme/app_theme.dart';
import '../app_toast.dart';
import '../islamic_pattern.dart';

class StoryViewerModal extends StatefulWidget {
  final List<CommunityStory> stories;
  final int initialStoryIndex;
  final VoidCallback? onStorySeen;

  const StoryViewerModal({
    super.key,
    required this.stories,
    required this.initialStoryIndex,
    this.onStorySeen,
  });

  @override
  State<StoryViewerModal> createState() => _StoryViewerModalState();
}

class _StoryViewerModalState extends State<StoryViewerModal>
    with SingleTickerProviderStateMixin {
  late int _currentStoryIndex;
  late int _currentSlideIndex;
  late AnimationController _progressController;
  final TextEditingController _replyController = TextEditingController();
  final FocusNode _replyFocusNode = FocusNode();

  final List<String> _flyingReactions = [];
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _currentStoryIndex = widget.initialStoryIndex.clamp(0, widget.stories.length - 1);
    _currentSlideIndex = 0;

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _goToNextSlide();
      }
    });

    _markCurrentSeen();
    _startSlideTimer();
  }

  void _markCurrentSeen() {
    if (_currentStoryIndex < widget.stories.length) {
      widget.stories[_currentStoryIndex].hasUnseen = false;
      widget.onStorySeen?.call();
    }
  }

  void _startSlideTimer() {
    _progressController.stop();
    _progressController.reset();
    _progressController.forward();
  }

  void _goToNextSlide() {
    final currentStory = widget.stories[_currentStoryIndex];
    if (_currentSlideIndex < currentStory.slides.length - 1) {
      setState(() {
        _currentSlideIndex++;
      });
      _startSlideTimer();
    } else {
      // Go to next story or dismiss if last
      if (_currentStoryIndex < widget.stories.length - 1) {
        setState(() {
          _currentStoryIndex++;
          _currentSlideIndex = 0;
        });
        _markCurrentSeen();
        _startSlideTimer();
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  void _goToPreviousSlide() {
    if (_currentSlideIndex > 0) {
      setState(() {
        _currentSlideIndex--;
      });
      _startSlideTimer();
    } else {
      if (_currentStoryIndex > 0) {
        setState(() {
          _currentStoryIndex--;
          _currentSlideIndex = widget.stories[_currentStoryIndex].slides.length - 1;
        });
        _startSlideTimer();
      } else {
        _progressController.reset();
        _progressController.forward();
      }
    }
  }

  void _pauseTimer() {
    if (!_isPaused) {
      _isPaused = true;
      _progressController.stop();
    }
  }

  void _resumeTimer() {
    if (_isPaused && !_replyFocusNode.hasFocus) {
      _isPaused = false;
      _progressController.forward();
    }
  }

  void _sendReaction(String emoji) {
    HapticFeedback.lightImpact();
    setState(() {
      _flyingReactions.add(emoji);
    });
    // Remove flying reaction after animation
    Timer(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() {
          _flyingReactions.remove(emoji);
        });
      }
    });

    final currentStory = widget.stories[_currentStoryIndex];
    final slide = currentStory.slides[_currentSlideIndex];
    slide.reactions[emoji] = (slide.reactions[emoji] ?? 0) + 1;

    AppToast.show(
      context,
      title: 'Reaction Sent',
      message: 'Sent $emoji to ${currentStory.authorName}',
      type: ToastType.success,
    );
  }

  void _sendReply() {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.lightImpact();
    final author = widget.stories[_currentStoryIndex].authorName;
    _replyController.clear();
    _replyFocusNode.unfocus();
    _resumeTimer();

    AppToast.show(
      context,
      title: 'Reply Sent',
      message: 'Message delivered to $author',
      type: ToastType.success,
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    _replyController.dispose();
    _replyFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentStory = widget.stories[_currentStoryIndex];
    final currentSlide = currentStory.slides[_currentSlideIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (_) => _pauseTimer(),
        onTapUp: (details) {
          _resumeTimer();
          final screenWidth = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < screenWidth * 0.35) {
            _goToPreviousSlide();
          } else {
            _goToNextSlide();
          }
        },
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null && details.primaryVelocity! > 250) {
            Navigator.of(context).pop();
          }
        },
        child: Stack(
          children: [
            // Slide Background Gradient
            Container(
              decoration: BoxDecoration(
                gradient: currentSlide.bgGradient,
              ),
            ),

            // Islamic Geometric Pattern Background Accent
            const Positioned.fill(
              child: IslamicPattern(
                color: Colors.white,
                opacity: 0.12,
                cell: 72,
              ),
            ),

            // Subtle dark overlay to preserve contrast
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.55),
                      Colors.black.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.65),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),

            // Slide Center Content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (currentSlide.arabicVerse != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.accentGold.withValues(alpha: 0.4),
                            width: 1.2,
                          ),
                        ),
                        child: Text(
                          currentSlide.arabicVerse!,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 26,
                            height: 1.8,
                            color: Color(0xFFFDE68A),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (currentSlide.verseReference != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          currentSlide.verseReference!,
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.85),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                    ],

                    // Caption Card
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Text(
                        currentSlide.caption,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 18,
                          height: 1.55,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Top Header: Progress Bars & User Details
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Segmented Progress Bar
                    Row(
                      children: List.generate(
                        currentStory.slides.length,
                        (index) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2.5),
                            child: _buildProgressBar(index),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Author info & Close Button
                    Row(
                      children: [
                        // Author Avatar
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.accentGold, width: 2),
                            gradient: AppGradients.goldGradient,
                          ),
                          child: Center(
                            child: Text(
                              currentStory.authorName.isNotEmpty
                                  ? currentStory.authorName[0]
                                  : 'U',
                              style: const TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF082F21),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Name & Timestamp
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      currentStory.authorName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: 'PlusJakartaSans',
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  if (currentStory.isVerified) ...[
                                    const SizedBox(width: 5),
                                    const Icon(
                                      Icons.verified_rounded,
                                      color: Color(0xFF81C784),
                                      size: 16,
                                    ),
                                  ],
                                ],
                              ),
                              Text(
                                '${currentStory.authorRole} • ${currentSlide.timestamp}',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11.5,
                                  color: Colors.white.withValues(alpha: 0.75),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Close button
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 26),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Flying reaction animation
            ..._flyingReactions.map(
              (emoji) => Positioned(
                bottom: 120,
                right: 36,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: (1.0 - value).clamp(0.0, 1.0),
                      child: Transform.translate(
                        offset: Offset(0, -value * 220),
                        child: Transform.scale(
                          scale: 1.0 + value * 0.8,
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 44),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Bottom Interactive Bar (Reply & Quick Reactions)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.85),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Quick Reaction Chips
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildReactionBubble('🤲', 'Ameen'),
                          _buildReactionBubble('💚', 'Alhamdulillah'),
                          _buildReactionBubble('✨', 'SubhanAllah'),
                          _buildReactionBubble('❤️', 'Care'),
                          _buildReactionBubble('👍', 'Like'),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Reply Input Bar
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 46,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  width: 1,
                                ),
                              ),
                              child: TextField(
                                controller: _replyController,
                                focusNode: _replyFocusNode,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                                onSubmitted: (_) => _sendReply(),
                                onTap: () => _pauseTimer(),
                                decoration: InputDecoration(
                                  hintText: 'Send du\'a or reply...',
                                  hintStyle: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13.5,
                                    color: Colors.white.withValues(alpha: 0.65),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _sendReply,
                            icon: Container(
                              width: 42,
                              height: 42,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppGradients.greenButtonGradient,
                              ),
                              child: const Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(int index) {
    if (index < _currentSlideIndex) {
      return Container(
        height: 3,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(2),
        ),
      );
    } else if (index == _currentSlideIndex) {
      return AnimatedBuilder(
        animation: _progressController,
        builder: (context, child) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: _progressController.value,
              backgroundColor: Colors.white.withValues(alpha: 0.35),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 3,
            ),
          );
        },
      );
    } else {
      return Container(
        height: 3,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(2),
        ),
      );
    }
  }

  Widget _buildReactionBubble(String emoji, String tooltip) {
    return InkWell(
      onTap: () => _sendReaction(emoji),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
