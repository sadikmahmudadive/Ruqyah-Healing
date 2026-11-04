import 'package:flutter/material.dart';

import '../../localization/app_localizations.dart';
import '../../models/learn_lesson_model.dart';
import '../../theme/app_theme.dart';
import '../modern_card.dart';
import 'learn_thumbnail.dart';

/// One free lesson in the Learn list: thumbnail, title, a video or article
/// badge, minutes, a green "Free" tag and a tick once it is done.
///
/// Learn is always free, so this card deliberately has no price, lock,
/// preview or certificate.
class LessonCard extends StatelessWidget {
  const LessonCard({
    super.key,
    required this.lesson,
    required this.done,
    required this.onTap,
  });

  final LearnLesson lesson;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isVideo = lesson.kind == LearnLessonKind.video;
    final kindLabel = context.tr(
      isVideo ? 'lesson_kind_video' : 'lesson_kind_article',
    );

    return Semantics(
      button: true,
      child: ModernCard(
        onTap: onTap,
        padding: const EdgeInsets.all(12),
        radius: 18,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            LearnThumbnail(
              categoryId: lesson.categoryId,
              thumbnailUrl: lesson.thumbnailUrl,
              width: 72,
              height: 72,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    lesson.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppType.body.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 10,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _KindBadge(
                        icon: isVideo
                            ? Icons.play_circle_outline_rounded
                            : Icons.article_outlined,
                        label: kindLabel,
                      ),
                      if (lesson.durationMinutes > 0)
                        Text(
                          context
                              .tr('minutes_short')
                              .replaceAll('{n}', '${lesson.durationMinutes}'),
                          style: AppType.caption.copyWith(
                            color: context.textMuted,
                          ),
                        ),
                      _FreeTag(label: context.tr('free_tag')),
                    ],
                  ),
                ],
              ),
            ),
            if (done) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.check_circle_rounded,
                size: 24,
                color: AppColors.success,
                semanticLabel: context.tr('lesson_done'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _KindBadge extends StatelessWidget {
  const _KindBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: context.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppType.caption.copyWith(
            fontWeight: FontWeight.w600,
            color: context.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _FreeTag extends StatelessWidget {
  const _FreeTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDarkMode;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: dark ? 0.22 : 0.12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: AppType.caption.copyWith(
          fontWeight: FontWeight.w700,
          color: dark ? AppColors.lightMint : AppColors.success,
        ),
      ),
    );
  }
}
