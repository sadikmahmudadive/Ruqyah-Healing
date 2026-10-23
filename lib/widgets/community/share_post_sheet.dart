import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/community_models.dart';
import '../../theme/app_theme.dart';
import '../app_toast.dart';

class SharePostSheet extends StatelessWidget {
  final CommunityPost post;
  final VoidCallback onBookmarkToggled;

  const SharePostSheet({
    super.key,
    required this.post,
    required this.onBookmarkToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: context.pageBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: context.cardBorderStrong,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Share Post',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Share with friends, family, or your social groups',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.5,
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 20),

          // Action Options
          _buildShareOption(
            context,
            icon: Icons.link_rounded,
            iconColor: const Color(0xFF0B4632),
            title: 'Copy Link',
            subtitle: 'Copy link to clipboard',
            onTap: () {
              HapticFeedback.lightImpact();
              Clipboard.setData(ClipboardData(text: 'https://ruqyah.app/post/${post.id}'));
              Navigator.of(context).pop();
              AppToast.show(
                context,
                title: 'Link Copied',
                message: 'Post link copied to clipboard.',
                type: ToastType.success,
              );
            },
          ),
          _buildShareOption(
            context,
            icon: Icons.bookmark_border_rounded,
            iconColor: AppColors.accentGold,
            title: post.isSaved ? 'Remove from Saved' : 'Save Post',
            subtitle: post.isSaved
                ? 'Remove from your saved bookmarks'
                : 'Save to read later in your bookmarks',
            onTap: () {
              HapticFeedback.lightImpact();
              onBookmarkToggled();
              Navigator.of(context).pop();
              AppToast.show(
                context,
                title: post.isSaved ? 'Post Saved' : 'Removed from Saved',
                message: post.isSaved
                    ? 'Saved to your personal collection.'
                    : 'Removed from bookmarks.',
                type: ToastType.info,
              );
            },
          ),
          _buildShareOption(
            context,
            icon: Icons.chat_rounded,
            iconColor: const Color(0xFF25D366), // WhatsApp green
            title: 'Share via WhatsApp',
            subtitle: 'Send to contacts or study circles',
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
              AppToast.show(
                context,
                title: 'WhatsApp Share',
                message: 'Opening WhatsApp share dialog...',
                type: ToastType.info,
              );
            },
          ),
          _buildShareOption(
            context,
            icon: Icons.copy_rounded,
            iconColor: context.textSecondary,
            title: 'Copy Post Text',
            subtitle: 'Copy reflection and verses',
            onTap: () {
              HapticFeedback.lightImpact();
              Clipboard.setData(ClipboardData(text: '${post.title}\n\n${post.content}'));
              Navigator.of(context).pop();
              AppToast.show(
                context,
                title: 'Text Copied',
                message: 'Post text copied to clipboard.',
                type: ToastType.success,
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildShareOption(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.cardBorder),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: context.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: context.textSecondary,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: context.textSecondary.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
