import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/community_models.dart';
import '../../theme/app_theme.dart';
import '../app_toast.dart';
import '../islamic_pattern.dart';
import 'comments_sheet.dart';
import 'reaction_picker_overlay.dart';
import 'share_post_sheet.dart';

class PostCard extends StatefulWidget {
  final CommunityPost post;
  final VoidCallback onPostUpdated;

  const PostCard({
    super.key,
    required this.post,
    required this.onPostUpdated,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final TextEditingController _inlineCommentController = TextEditingController();
  final GlobalKey _reactButtonKey = GlobalKey();
  OverlayEntry? _reactionOverlayEntry;

  @override
  void dispose() {
    _removeReactionOverlay();
    _inlineCommentController.dispose();
    super.dispose();
  }

  void _removeReactionOverlay() {
    _reactionOverlayEntry?.remove();
    _reactionOverlayEntry = null;
  }

  void _showReactionPicker() {
    HapticFeedback.selectionClick();
    _removeReactionOverlay();

    final renderBox = _reactButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final overlay = Overlay.of(context);

    _reactionOverlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Barrier to dismiss
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _removeReactionOverlay,
                child: const SizedBox.expand(),
              ),
            ),
            // Floating reaction bar
            Positioned(
              left: offset.dx.clamp(16.0, MediaQuery.of(context).size.width - 270),
              top: offset.dy - 60,
              child: ReactionPickerOverlay(
                onDismiss: _removeReactionOverlay,
                onReactionSelected: (reaction) {
                  _handleSelectReaction(reaction);
                  _removeReactionOverlay();
                },
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_reactionOverlayEntry!);
  }

  void _handleSelectReaction(PostReactionType reaction) {
    HapticFeedback.lightImpact();
    setState(() {
      final oldReaction = widget.post.userReaction;
      if (oldReaction == reaction) {
        // Toggle off
        widget.post.userReaction = null;
        widget.post.reactionCounts[reaction] =
            (widget.post.reactionCounts[reaction] ?? 1) - 1;
      } else {
        if (oldReaction != null) {
          widget.post.reactionCounts[oldReaction] =
              (widget.post.reactionCounts[oldReaction] ?? 1) - 1;
        }
        widget.post.userReaction = reaction;
        widget.post.reactionCounts[reaction] =
            (widget.post.reactionCounts[reaction] ?? 0) + 1;
      }
    });
    widget.onPostUpdated();
  }

  void _toggleDefaultReaction() {
    HapticFeedback.selectionClick();
    if (widget.post.userReaction == null) {
      _handleSelectReaction(PostReactionType.like);
    } else {
      _handleSelectReaction(widget.post.userReaction!);
    }
  }

  void _openCommentsSheet() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsSheet(
        post: widget.post,
        onCommentAdded: (newComment) {
          setState(() {
            widget.post.comments.add(newComment);
            widget.post.commentsCount = widget.post.comments.length;
          });
          widget.onPostUpdated();
        },
      ),
    );
  }

  void _openShareSheet() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SharePostSheet(
        post: widget.post,
        onBookmarkToggled: () {
          setState(() {
            widget.post.isSaved = !widget.post.isSaved;
          });
          widget.onPostUpdated();
        },
      ),
    );
  }

  void _submitInlineComment([String? presetText]) {
    final text = presetText ?? _inlineCommentController.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.lightImpact();
    final newComment = PostComment(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      authorName: 'You',
      authorRole: 'Community Member',
      timeAgo: 'Just now',
      text: text,
      likesCount: 0,
      isLiked: false,
    );

    setState(() {
      widget.post.comments.add(newComment);
      widget.post.commentsCount = widget.post.comments.length;
    });
    _inlineCommentController.clear();
    widget.onPostUpdated();

    AppToast.show(
      context,
      title: 'Comment Added',
      message: 'Your comment was posted.',
      type: ToastType.success,
    );
  }

  void _showPostOptionsMenu() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: context.pageBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: context.cardBorderStrong,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(
                widget.post.isSaved
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                color: AppColors.accentGold,
              ),
              title: Text(
                widget.post.isSaved ? 'Unsave Post' : 'Save Post',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
              subtitle: Text(
                'Add this to your saved items',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: context.textSecondary,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                setState(() => widget.post.isSaved = !widget.post.isSaved);
                widget.onPostUpdated();
                AppToast.show(
                  context,
                  title: widget.post.isSaved ? 'Saved' : 'Unsaved',
                  message: widget.post.isSaved
                      ? 'Post saved to your bookmarks.'
                      : 'Post removed from saved.',
                  type: ToastType.info,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy_rounded, color: Color(0xFF0B4632)),
              title: Text(
                'Copy Post Text',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                Clipboard.setData(ClipboardData(
                    text: '${widget.post.title}\n\n${widget.post.content}'));
                AppToast.show(
                  context,
                  title: 'Text Copied',
                  message: 'Post content copied to clipboard.',
                  type: ToastType.success,
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.flag_outlined, color: AppColors.danger),
              title: Text(
                'Report Post',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontWeight: FontWeight.w700,
                  color: AppColors.danger,
                ),
              ),
              subtitle: Text(
                'Help keep the community safe and Islamic',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: context.textSecondary,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                AppToast.show(
                  context,
                  title: 'Report Submitted',
                  message: 'Our moderation team will review this post.',
                  type: ToastType.info,
                );
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topReactions = widget.post.topReactionTypes;

    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.cardBorder, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDarkMode ? 0.25 : 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Author Row & Category Tag
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Author Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B4632).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.post.isVerified
                          ? AppColors.accentGold
                          : const Color(0xFF0B4632).withValues(alpha: 0.2),
                      width: widget.post.isVerified ? 1.8 : 1.0,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      widget.post.authorName.isNotEmpty
                          ? widget.post.authorName[0]
                          : 'U',
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

                // Name & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              widget.post.authorName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: context.textPrimary,
                              ),
                            ),
                          ),
                          if (widget.post.isVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified_rounded,
                              color: Color(0xFF0B4632),
                              size: 16,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              '${widget.post.authorRole} • ${widget.post.timeAgo}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11.5,
                                color: context.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.public_rounded,
                            size: 12,
                            color: context.textSecondary.withValues(alpha: 0.7),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Category Tag Pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.isDarkMode
                        ? const Color(0xFF182E25)
                        : AppColors.tintMint,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF0B4632).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    widget.post.category,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0B4632),
                    ),
                  ),
                ),
                const SizedBox(width: 4),

                // Options Button
                IconButton(
                  icon: Icon(
                    Icons.more_horiz_rounded,
                    color: context.textSecondary,
                    size: 20,
                  ),
                  onPressed: _showPostOptionsMenu,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                ),
              ],
            ),
          ),

          // 2. Post Title (if not duplicate of content)
          if (widget.post.title.isNotEmpty &&
              widget.post.title != widget.post.content &&
              widget.post.bgGradient == null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                widget.post.title,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 6),
          ],

          // 3. Post Content (Facebook styled card or standard text)
          if (widget.post.bgGradient != null) ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              padding: const EdgeInsets.all(22.0),
              decoration: BoxDecoration(
                gradient: widget.post.bgGradient,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  const Positioned.fill(
                    child: IslamicPattern(
                      color: Colors.white,
                      opacity: 0.10,
                      cell: 52,
                    ),
                  ),
                  Center(
                    child: Text(
                      widget.post.content,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                        height: 1.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                widget.post.content,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13.5,
                  height: 1.5,
                  color: context.textPrimary,
                ),
              ),
            ),
          ],

          // 4. Quranic Ayah Card if attached
          if (widget.post.arabicVerse != null) ...[
            const SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.isDarkMode
                    ? const Color(0xFF182E25)
                    : AppColors.tintMint.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF0B4632).withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.post.arabicVerse!,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 18,
                      height: 1.7,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0B4632),
                    ),
                  ),
                  if (widget.post.verseTranslation != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      widget.post.verseTranslation!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          // 5. Tags Row
          if (widget.post.tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: widget.post.tags.map((tag) {
                  return Text(
                    tag,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0B4632),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],

          const SizedBox(height: 12),

          // 6. Facebook-style Social Proof & Reaction Counts Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                // Stacked mini-emojis
                if (widget.post.totalReactions > 0) ...[
                  Row(
                    children: topReactions.map((r) {
                      return Transform.translate(
                        offset: Offset(topReactions.indexOf(r) * -4.0, 0),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: context.cardBg,
                            shape: BoxShape.circle,
                          ),
                          child: Text(r.emoji, style: const TextStyle(fontSize: 13)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.post.totalReactions}',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: context.textSecondary,
                    ),
                  ),
                ] else ...[
                  Text(
                    'Be first to react',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: context.textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
                ],

                const Spacer(),

                // Comments & Shares count
                GestureDetector(
                  onTap: _openCommentsSheet,
                  child: Text(
                    '${widget.post.commentsCount} comments • ${widget.post.sharesCount} shares',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: context.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
          Divider(color: context.cardBorder, height: 1),

          // 7. Facebook 4-Action Bar (React, Comment, Share, Bookmark)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
            child: Row(
              children: [
                // React Button
                Expanded(
                  child: InkWell(
                    key: _reactButtonKey,
                    onTap: _toggleDefaultReaction,
                    onLongPress: _showReactionPicker,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.post.userReaction != null) ...[
                            Text(
                              widget.post.userReaction!.emoji,
                              style: const TextStyle(fontSize: 17),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.post.userReaction!.label,
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: widget.post.userReaction!.color,
                              ),
                            ),
                          ] else ...[
                            Icon(
                              Icons.thumb_up_alt_outlined,
                              size: 18,
                              color: context.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Helpful',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: context.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                // Comment Button
                Expanded(
                  child: InkWell(
                    onTap: _openCommentsSheet,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 18,
                            color: context.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Comment',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Share Button
                Expanded(
                  child: InkWell(
                    onTap: _openShareSheet,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.share_outlined,
                            size: 18,
                            color: context.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Share',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bookmark Toggle
                InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => widget.post.isSaved = !widget.post.isSaved);
                    widget.onPostUpdated();
                    AppToast.show(
                      context,
                      title: widget.post.isSaved ? 'Post Saved' : 'Removed',
                      message: widget.post.isSaved
                          ? 'Saved to your bookmarks.'
                          : 'Removed from bookmarks.',
                      type: ToastType.info,
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                    child: Icon(
                      widget.post.isSaved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      size: 20,
                      color: widget.post.isSaved
                          ? AppColors.accentGold
                          : context.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 8. Top Comment Snippet & Quick Inline Comment Input
          if (widget.post.comments.isNotEmpty) ...[
            Divider(color: context.cardBorder, height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Comment Bubble
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.isDarkMode
                          ? const Color(0xFF182E25)
                          : AppColors.lightBackground,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.post.comments.first.authorName,
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: context.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              widget.post.comments.first.timeAgo,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10.5,
                                color: context.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.post.comments.first.text,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // View all comments link
                  if (widget.post.comments.length > 1) ...[
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: _openCommentsSheet,
                      child: Text(
                        'View all ${widget.post.comments.length} comments',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0B4632),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          // Quick 1-tap comment input pill
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: context.pageBg,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: context.cardBorder),
                    ),
                    child: TextField(
                      controller: _inlineCommentController,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.5,
                        color: context.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Write a comment or du\'a...',
                        hintStyle: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: context.textSecondary.withValues(alpha: 0.6),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _submitInlineComment(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Quick Ameen chip
                InkWell(
                  onTap: () => _submitInlineComment('🤲 Ameen'),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: context.isDarkMode
                          ? const Color(0xFF182E25)
                          : AppColors.tintMint,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF0B4632).withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Text(
                      '🤲 Ameen',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0B4632),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
