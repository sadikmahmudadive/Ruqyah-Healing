import 'package:flutter/material.dart';

import '../../localization/app_localizations.dart';
import '../../models/course_model.dart';
import '../../theme/app_theme.dart';
import '../animations/press.dart';
import '../modern_card.dart';
import 'learn_thumbnail.dart';

/// One paid course in the Courses list: thumbnail, title, instructor, level,
/// rating, price in Tk, a "Certificate" badge, a "Preview 10s" button (hidden
/// once the course is owned) and an "Owned" badge when it is.
class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.course,
    required this.owned,
    required this.onTap,
    required this.onPreview,
  });

  final CourseModel course;
  final bool owned;
  final VoidCallback onTap;
  final VoidCallback onPreview;

  /// `Tk 1200` for whole prices, `Tk 99.5` otherwise.
  static String priceLabel(double price) {
    final text = price == price.roundToDouble()
        ? price.toStringAsFixed(0)
        : price.toString();
    return 'Tk $text';
  }

  @override
  Widget build(BuildContext context) {
    final hasRating = course.rating > 0 || course.reviewCount > 0;
    final previewLabel = context
        .tr('preview_seconds')
        .replaceAll('{n}', '${kPreviewLimit.inSeconds}');
    final dark = context.isDarkMode;

    return Semantics(
      button: true,
      child: ModernCard(
        onTap: onTap,
        padding: const EdgeInsets.all(10),
        radius: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  LearnThumbnail(
                    categoryId: course.categoryId,
                    thumbnailUrl: course.thumbnailUrl,
                    radius: 14,
                  ),
                  if (owned)
                    PositionedDirectional(
                      top: 8,
                      start: 8,
                      child: _Pill(
                        icon: Icons.check_circle_rounded,
                        label: context.tr('owned_badge'),
                        background: AppColors.primaryGreen,
                        foreground: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    course.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppType.body.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      color: context.textPrimary,
                    ),
                  ),
                  if (course.instructorName.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            course.instructorName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppType.caption.copyWith(
                              color: context.textSecondary,
                            ),
                          ),
                        ),
                        if (course.isInstructorVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified_rounded,
                            size: 14,
                            color: AppColors.info,
                          ),
                        ],
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (hasRating)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: AppColors.accentGold,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              course.rating.toStringAsFixed(1),
                              style: AppType.caption.copyWith(
                                fontWeight: FontWeight.w700,
                                color: context.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '(${course.reviewCount})',
                              style: AppType.caption.copyWith(
                                color: context.textMuted,
                              ),
                            ),
                          ],
                        ),
                      if (course.level.isNotEmpty)
                        Text(
                          course.level,
                          style: AppType.caption.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      _Pill(
                        icon: Icons.workspace_premium_rounded,
                        label: context.tr('certificate_badge'),
                        background: AppColors.accentGold.withValues(
                          alpha: dark ? 0.2 : 0.16,
                        ),
                        foreground: dark
                            ? AppColors.accentGoldSoft
                            : const Color(0xFF8A6417),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      Text(
                        priceLabel(course.priceBdt),
                        style: AppType.title.copyWith(
                          color: dark
                              ? AppColors.lightMint
                              : AppColors.primaryGreen,
                        ),
                      ),
                      if (!owned)
                        _PreviewButton(label: previewLabel, onTap: onPreview),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppType.caption.copyWith(
                fontWeight: FontWeight.w700,
                color: foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewButton extends StatelessWidget {
  const _PreviewButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = context.isDarkMode
        ? AppColors.lightMint
        : AppColors.primaryGreen;
    return Semantics(
      button: true,
      excludeSemantics: true,
      label: label,
      onTap: onTap,
      child: PressScale(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: color, width: 1.2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.play_arrow_rounded, size: 18, color: color),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
