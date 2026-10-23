import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/community_models.dart';
import '../../theme/app_theme.dart';
import 'create_post_sheet.dart';

class PostComposerBar extends StatelessWidget {
  final Function(CommunityPost newPost) onPostCreated;

  const PostComposerBar({
    super.key,
    required this.onPostCreated,
  });

  void _openComposer(BuildContext context, [String? category]) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreatePostSheet(
        onPostCreated: onPostCreated,
        initialCategory: category,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.cardBorder, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDarkMode ? 0.25 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Input Row
          Row(
            children: [
              // User Avatar
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF0B4632).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF0B4632).withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Y',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0B4632),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // "What's on your mind?" Pill
              Expanded(
                child: InkWell(
                  onTap: () => _openComposer(context),
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: context.pageBg,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: context.cardBorder),
                    ),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'What\'s on your mind? Share a reflection...',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: context.textSecondary.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(color: context.cardBorder, height: 1),
          const SizedBox(height: 8),

          // Quick Action Buttons Row (Facebook style)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickAction(
                context,
                icon: Icons.volunteer_activism_outlined,
                iconColor: AppColors.accentGold,
                label: 'Du\'a Request',
                onTap: () => _openComposer(context, 'Du\'a Request'),
              ),
              Container(width: 1, height: 18, color: context.cardBorder),
              _buildQuickAction(
                context,
                icon: Icons.auto_awesome_rounded,
                iconColor: const Color(0xFF0B4632),
                label: 'Milestone',
                onTap: () => _openComposer(context, 'Healing Story'),
              ),
              Container(width: 1, height: 18, color: context.cardBorder),
              _buildQuickAction(
                context,
                icon: Icons.shield_outlined,
                iconColor: const Color(0xFF2F7D5B),
                label: 'Ask Raaqi',
                onTap: () => _openComposer(context, 'Ruqyah Advice'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
