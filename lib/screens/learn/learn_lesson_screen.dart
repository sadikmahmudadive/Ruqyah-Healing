import 'dart:async';

import 'package:flutter/material.dart';

import '../../localization/app_localizations.dart';
import '../../models/learn_category.dart';
import '../../models/learn_lesson_model.dart';
import '../../services/learn_progress_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animations/animations.dart';
import '../../widgets/learn/course_video_player.dart';

/// One free lesson: a video (full playback) or an article, a "Mark as done"
/// toggle and a "Next lesson" button when there is one.
///
/// Learn is free and needs no account, so this screen deliberately shows no
/// price, lock, preview or certificate. [siblings] is any list of lessons
/// that includes this lesson's category; "next" is the following lesson of
/// the same category by `order`. [progress] defaults to
/// [LearnProgressService.instance] and exists so tests can inject their own.
class LearnLessonScreen extends StatefulWidget {
  const LearnLessonScreen({
    super.key,
    required this.lesson,
    required this.siblings,
    this.progress,
  });

  final LearnLesson lesson;
  final List<LearnLesson> siblings;
  final LearnProgressService? progress;

  @override
  State<LearnLessonScreen> createState() => _LearnLessonScreenState();
}

class _LearnLessonScreenState extends State<LearnLessonScreen> {
  late final LearnProgressService _progress =
      widget.progress ?? LearnProgressService.instance;

  /// Saved progress must be loaded before anything is written, or a write
  /// could replace what is stored with a half-empty set.
  late final Future<void> _ready = _init();

  Future<void> _init() async {
    await _progress.load();
    if (!mounted) return;
    await _progress.setLastOpened(widget.lesson.id);
  }

  @override
  void initState() {
    super.initState();
    unawaited(_ready);
  }

  Future<void> _toggleDone() async {
    await _ready;
    if (!mounted) return;
    await _progress.setDone(
      widget.lesson.id,
      !_progress.isDone(widget.lesson.id),
    );
  }

  /// The lesson after this one in the same category, by `order`, or null.
  LearnLesson? get _next {
    final same =
        widget.siblings
            .where((l) => l.categoryId == widget.lesson.categoryId)
            .toList()
          ..sort((a, b) => a.order.compareTo(b.order));
    final i = same.indexWhere((l) => l.id == widget.lesson.id);
    if (i >= 0) return i + 1 < same.length ? same[i + 1] : null;
    for (final l in same) {
      if (l.order > widget.lesson.order) return l;
    }
    return null;
  }

  void _openNext(LearnLesson next) {
    // Replace this screen so Back returns to the list, not the previous lesson.
    Navigator.of(context).pushReplacement(
      AppPageRoute.sharedAxis(
        LearnLessonScreen(
          lesson: next,
          siblings: widget.siblings,
          progress: _progress,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    final isVideo = lesson.kind == LearnLessonKind.video;
    final category = learnCategoryById(lesson.categoryId);
    final next = _next;
    final body = lesson.body.trim();

    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: AppBar(
        backgroundColor: context.pageBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text(
          category?.title ?? context.tr('lessons_count_noun'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppType.title.copyWith(color: context.textPrimary),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 24),
          children: [
            if (isVideo)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CourseVideoPlayer(
                  // Keyed so moving to another lesson starts a fresh player.
                  key: ValueKey('video_${lesson.id}'),
                  url: lesson.videoUrl,
                  title: lesson.title,
                ),
              ),
            if (isVideo) const SizedBox(height: 16),
            Text(
              lesson.title,
              style: AppType.title.copyWith(
                fontSize: 22,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            _MetaRow(lesson: lesson, isVideo: isVideo),
            const SizedBox(height: 16),
            if (body.isNotEmpty)
              Text(
                body,
                style: AppType.body.copyWith(
                  fontSize: 16,
                  height: 1.7,
                  color: context.textPrimary,
                ),
              )
            else if (!isVideo)
              _InlineMessage(text: context.tr('nothing_to_read')),
            const SizedBox(height: 24),
            ListenableBuilder(
              listenable: _progress,
              builder: (context, _) => _DoneButton(
                done: _progress.isDone(lesson.id),
                onPressed: _toggleDone,
              ),
            ),
            if (next != null) ...[
              const SizedBox(height: 12),
              _NextButton(onPressed: () => _openNext(next)),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.lesson, required this.isVideo});

  final LearnLesson lesson;
  final bool isVideo;

  @override
  Widget build(BuildContext context) {
    final style = AppType.caption.copyWith(
      fontWeight: FontWeight.w600,
      color: context.textSecondary,
    );
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isVideo
                  ? Icons.play_circle_outline_rounded
                  : Icons.article_outlined,
              size: 16,
              color: context.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              context.tr(isVideo ? 'lesson_kind_video' : 'lesson_kind_article'),
              style: style,
            ),
          ],
        ),
        if (lesson.durationMinutes > 0)
          Text(
            context
                .tr('minutes_short')
                .replaceAll('{n}', '${lesson.durationMinutes}'),
            style: style,
          ),
      ],
    );
  }
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.cardBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.menu_book_outlined, color: context.textMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppType.body.copyWith(color: context.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _DoneButton extends StatelessWidget {
  const _DoneButton({required this.done, required this.onPressed});

  final bool done;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final label = context.tr(done ? 'lesson_done' : 'mark_as_done');
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    );
    const size = Size(double.infinity, 48);
    final icon = Icon(
      done ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
      size: 20,
    );
    final text = Text(label, textAlign: TextAlign.center);
    if (done) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon,
        label: text,
        style: OutlinedButton.styleFrom(
          minimumSize: size,
          shape: shape,
          foregroundColor: context.isDarkMode
              ? AppColors.lightMint
              : AppColors.success,
          side: const BorderSide(color: AppColors.success),
        ),
      );
    }
    return FilledButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: text,
      style: FilledButton.styleFrom(minimumSize: size, shape: shape),
    );
  }
}

class _NextButton extends StatelessWidget {
  const _NextButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(context.tr('next_lesson'), textAlign: TextAlign.center),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_rounded, size: 20),
        ],
      ),
    );
  }
}
