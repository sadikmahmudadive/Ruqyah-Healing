import 'package:flutter/material.dart';

import '../theme/app_gradients.dart';

/// Islamic wellness reactions corresponding to Facebook-style reactions
enum PostReactionType {
  like('Helpful', '👍', Color(0xFF0B4632)),
  ameen('Ameen', '🤲', Color(0xFFD49E35)),
  alhamdulillah('Alhamdulillah', '💚', Color(0xFF2F7D5B)),
  subhanallah('SubhanAllah', '✨', Color(0xFF6B4EAA)),
  care('Du\'a', '❤️', Color(0xFFC4604F));

  final String label;
  final String emoji;
  final Color color;

  const PostReactionType(this.label, this.emoji, this.color);
}

/// A single story slide within a user's story
class StorySlide {
  final String id;
  final String caption;
  final String? arabicVerse;
  final String? verseReference;
  final LinearGradient bgGradient;
  final String timestamp;
  int viewCount;
  final Map<String, int> reactions;

  StorySlide({
    required this.id,
    required this.caption,
    this.arabicVerse,
    this.verseReference,
    required this.bgGradient,
    required this.timestamp,
    this.viewCount = 0,
    Map<String, int>? reactions,
  }) : reactions = reactions ?? {'🤲': 12, '💚': 8, '❤️': 5};
}

/// User's community story (Facebook style story card)
class CommunityStory {
  final String id;
  final String authorName;
  final String authorAvatar;
  final String authorRole;
  final bool isVerified;
  final bool isMyStory;
  bool hasUnseen;
  final List<StorySlide> slides;

  CommunityStory({
    required this.id,
    required this.authorName,
    required this.authorAvatar,
    required this.authorRole,
    this.isVerified = false,
    this.isMyStory = false,
    this.hasUnseen = true,
    required this.slides,
  });

  StorySlide get latestSlide => slides.isNotEmpty
      ? slides.last
      : StorySlide(
          id: 'default',
          caption: '',
          bgGradient: AppGradients.greenHeaderGradient,
          timestamp: 'Just now',
        );
}

/// A comment on a community post
class PostComment {
  final String id;
  final String authorName;
  final String authorRole;
  final String timeAgo;
  final String text;
  int likesCount;
  bool isLiked;
  final bool isVerified;

  PostComment({
    required this.id,
    required this.authorName,
    required this.authorRole,
    required this.timeAgo,
    required this.text,
    this.likesCount = 0,
    this.isLiked = false,
    this.isVerified = false,
  });
}

/// A community post with Facebook-grade richness and Islamic wellness styling
class CommunityPost {
  final String id;
  final String authorName;
  final String authorRole;
  final String timeAgo;
  final bool isVerified;
  final bool isAnonymous;
  final String category; // 'Du\'a Request', 'Healing Story', 'Ruqyah Advice', 'Question'
  final String title;
  final String content;
  final String? arabicVerse;
  final String? verseTranslation;
  final LinearGradient? bgGradient; // For Facebook-style colored card posts
  int commentsCount;
  int sharesCount;
  PostReactionType? userReaction;
  final Map<PostReactionType, int> reactionCounts;
  final List<PostComment> comments;
  bool isSaved;
  final List<String> tags;

  CommunityPost({
    required this.id,
    required this.authorName,
    required this.authorRole,
    required this.timeAgo,
    this.isVerified = false,
    this.isAnonymous = false,
    required this.category,
    required this.title,
    required this.content,
    this.arabicVerse,
    this.verseTranslation,
    this.bgGradient,
    required this.commentsCount,
    this.sharesCount = 3,
    this.userReaction,
    Map<PostReactionType, int>? reactionCounts,
    List<PostComment>? comments,
    this.isSaved = false,
    this.tags = const [],
  })  : reactionCounts = reactionCounts ??
            {
              PostReactionType.like: 12,
              PostReactionType.ameen: 24,
              PostReactionType.alhamdulillah: 15,
            },
        comments = comments ?? [];

  int get totalReactions => reactionCounts.values.fold(0, (sum, count) => sum + count);

  /// Top 3 distinct reaction types present on this post for the stacked Facebook icon badge
  List<PostReactionType> get topReactionTypes {
    final sorted = reactionCounts.entries
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(3).map((e) => e.key).toList();
  }
}
