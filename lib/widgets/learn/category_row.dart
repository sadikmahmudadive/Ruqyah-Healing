import 'package:flutter/material.dart';

import '../../localization/app_localizations.dart';
import '../../models/learn_category.dart';
import '../../theme/app_theme.dart';
import '../animations/press.dart';

/// A horizontal row of category chips: "All" first, then the ten categories.
///
/// [selectedId] of null means All. Tapping the selected category clears it
/// (calls [onSelected] with null). Each category chip shows how many lessons
/// or courses it holds, `counts[id] ?? 0`, followed by [countNoun].
class CategoryRow extends StatelessWidget {
  const CategoryRow({
    super.key,
    required this.selectedId,
    required this.onSelected,
    required this.counts,
    required this.countNoun,
  });

  final String? selectedId;
  final ValueChanged<String?> onSelected;
  final Map<String, int> counts;
  final String countNoun;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _Chip(
            selected: selectedId == null,
            title: context.tr('all_label'),
            leading: Icon(
              Icons.apps_rounded,
              size: 20,
              color: selectedId == null
                  ? AppColors.primaryGreen
                  : context.textSecondary,
            ),
            tint: AppColors.tintMint,
            onTap: () => onSelected(null),
          ),
          for (final c in kLearnCategories) ...[
            const SizedBox(width: 8),
            _Chip(
              selected: selectedId == c.id,
              title: c.title,
              subtitle: '${counts[c.id] ?? 0} $countNoun',
              leading: c.buildIcon(20),
              tint: c.tint,
              onTap: () => onSelected(selectedId == c.id ? null : c.id),
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.selected,
    required this.title,
    required this.leading,
    required this.tint,
    required this.onTap,
    this.subtitle,
  });

  final bool selected;
  final String title;
  final String? subtitle;
  final Widget leading;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDarkMode;
    final bg = selected
        ? (dark ? AppColors.darkContainerBg : tint)
        : context.cardBg;
    final borderColor = selected ? AppColors.primaryGreen : context.cardBorder;

    return Semantics(
      button: true,
      selected: selected,
      child: PressScale(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44, maxWidth: 190),
          padding: const EdgeInsetsDirectional.fromSTEB(10, 6, 14, 6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: selected ? 1.5 : 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: dark ? AppColors.darkIconCircleBg : tint,
                  shape: BoxShape.circle,
                ),
                child: leading,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppType.caption.copyWith(
                          fontSize: 11.5,
                          color: context.textMuted,
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
}
