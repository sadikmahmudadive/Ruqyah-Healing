import 'dart:async';

import 'package:flutter/material.dart';

import '../../localization/app_localizations.dart';
import '../../models/learn_category.dart';
import '../../models/learn_lesson_model.dart';
import '../../services/learn_content_source.dart';
import '../../services/learn_progress_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animations/animations.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/illustrations/ruqyah_illustrations.dart';
import '../../widgets/learn/lesson_card.dart';
import '../../widgets/modern_card.dart';
import 'learn_lesson_screen.dart';

/// The free side of Learn: a "pick up where you left off" card for the last
/// unfinished lesson, then the lessons of the chosen category (or all of them
/// when [categoryId] is null) in lesson order.
///
/// Learn is free, so nothing here shows a price, lock, preview or
/// certificate, and nothing needs an account.
///
/// This is a scrollable list that fills the space it is given, so place it
/// where it has a bounded height (for example inside an `Expanded`).
///
/// [onCounts] reports how many lessons each category holds, counted over ALL
/// lessons (not just the filtered list), after the first frame with data and
/// whenever the data changes. [progress] defaults to
/// [LearnProgressService.instance] and exists so tests can inject their own.
class LearnFreeView extends StatefulWidget {
  const LearnFreeView({
    super.key,
    required this.categoryId,
    required this.onCounts,
    this.progress,
  });

  final String? categoryId;
  final void Function(Map<String, int> counts) onCounts;
  final LearnProgressService? progress;

  @override
  State<LearnFreeView> createState() => _LearnFreeViewState();
}

class _LearnFreeViewState extends State<LearnFreeView> {
  late final LearnProgressService _progress =
      widget.progress ?? LearnProgressService.instance;

  StreamSubscription<List<LearnLesson>>? _sub;

  /// Null until the first emission, which is what the placeholders show for.
  List<LearnLesson>? _lessons;

  @override
  void initState() {
    super.initState();
    // Fire and forget: the view only reads progress. The lesson screen waits
    // for its own load before it writes any.
    unawaited(_progress.load());
    _sub = LearnContentSource.instance.lessons().listen(
      _onLessons,
      onError: (Object e) {
        debugPrint('LearnFreeView lessons failed: $e');
        if (mounted && _lessons == null) setState(() => _lessons = const []);
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _onLessons(List<LearnLesson> lessons) {
    if (!mounted) return;
    setState(() => _lessons = lessons);
    final counts = <String, int>{};
    for (final l in lessons) {
      counts[l.categoryId] = (counts[l.categoryId] ?? 0) + 1;
    }
    // Never call the parent while it may be building.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onCounts(counts);
    });
  }

  void _open(LearnLesson lesson) {
    Navigator.of(context).push(
      AppPageRoute.sharedAxis(
        LearnLessonScreen(
          lesson: lesson,
          siblings: _lessons ?? const [],
          progress: _progress,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final all = _lessons;
    if (all == null) return const _LoadingList();

    final shown =
        all
            .where(
              (l) =>
                  widget.categoryId == null ||
                  l.categoryId == widget.categoryId,
            )
            .toList()
          ..sort((a, b) => a.order.compareTo(b.order));

    if (shown.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          child: EmptyState(
            kind: FlatIllustrationKind.learn,
            title: context.tr('no_lessons_title'),
            message: context.tr('no_lessons_message'),
          ),
        ),
      );
    }

    return ListenableBuilder(
      listenable: _progress,
      builder: (context, _) {
        final resume = _resumeLesson(shown);
        return ListView.separated(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 24),
          itemCount: shown.length + (resume == null ? 0 : 1),
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            if (resume != null) {
              if (i == 0) {
                return FadeSlideIn(
                  child: _ContinueCard(
                    lesson: resume,
                    onTap: () => _open(resume),
                  ),
                );
              }
              i -= 1;
            }
            final lesson = shown[i];
            return LessonCard(
              lesson: lesson,
              done: _progress.isDone(lesson.id),
              onTap: () => _open(lesson),
            );
          },
        );
      },
    );
  }

  /// The last opened lesson, if it is still unfinished and in the list shown.
  LearnLesson? _resumeLesson(List<LearnLesson> shown) {
    final id = _progress.lastOpenedId;
    if (id == null || _progress.isDone(id)) return null;
    for (final l in shown) {
      if (l.id == id) return l;
    }
    return null;
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({required this.lesson, required this.onTap});

  final LearnLesson lesson;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDarkMode;
    final category = learnCategoryById(lesson.categoryId);
    final accent = dark ? AppColors.accentGold : AppColors.primaryGreen;
    return Semantics(
      button: true,
      child: ModernCard(
        onTap: onTap,
        padding: const EdgeInsets.all(14),
        radius: 18,
        color: dark
            ? AppColors.success.withValues(alpha: 0.14)
            : category?.tint ?? AppColors.tintMint,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
              child: Icon(
                lesson.kind == LearnLessonKind.video
                    ? Icons.play_arrow_rounded
                    : Icons.menu_book_rounded,
                color: dark ? AppColors.primaryGreen : Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.tr('continue_where_left'),
                    style: AppType.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
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
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              size: 24,
              color: context.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 24),
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) => const ShimmerBox(height: 96, radius: 18),
    );
  }
}
