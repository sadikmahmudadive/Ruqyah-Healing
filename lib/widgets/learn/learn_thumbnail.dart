import 'package:flutter/material.dart';

import '../../models/learn_category.dart';
import '../../theme/app_theme.dart';

/// A rounded thumbnail for a lesson or course. With no [thumbnailUrl], or when
/// the image fails to load, it falls back to a placeholder tinted with the
/// category colour and showing the category icon.
class LearnThumbnail extends StatelessWidget {
  const LearnThumbnail({
    super.key,
    required this.categoryId,
    this.thumbnailUrl,
    this.width,
    this.height,
    this.radius = 14,
  });

  final String categoryId;
  final String? thumbnailUrl;
  final double? width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final url = thumbnailUrl;
    final placeholder = _Placeholder(categoryId: categoryId);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: width,
        height: height,
        child: (url == null || url.isEmpty)
            ? placeholder
            : Image.network(
                url,
                fit: BoxFit.cover,
                excludeFromSemantics: true,
                errorBuilder: (_, _, _) => placeholder,
              ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context) {
    final category = learnCategoryById(categoryId);
    final bg = context.isDarkMode
        ? AppColors.darkIconCircleBg
        : (category?.tint ?? AppColors.tintMint);
    return Container(
      color: bg,
      alignment: Alignment.center,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final shortest = constraints.biggest.shortestSide;
          final size = (shortest.isFinite ? shortest * 0.42 : 28.0)
              .clamp(16.0, 44.0)
              .toDouble();
          return category?.buildIcon(size) ??
              Icon(Icons.school_rounded, size: size, color: context.textMuted);
        },
      ),
    );
  }
}
