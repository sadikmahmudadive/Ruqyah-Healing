import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruqyahhealing/models/learn_lesson_model.dart';
import 'package:ruqyahhealing/screens/learn/learn_free_view.dart';
import 'package:ruqyahhealing/screens/learn/learn_lesson_screen.dart';
import 'package:ruqyahhealing/services/learn_content_source.dart';
import 'package:ruqyahhealing/services/learn_progress_service.dart';
import 'package:ruqyahhealing/theme/app_theme.dart';
import 'package:ruqyahhealing/widgets/animations/shimmer.dart';
import 'package:ruqyahhealing/widgets/empty_state.dart';
import 'package:ruqyahhealing/widgets/learn/course_video_player.dart';
import 'package:ruqyahhealing/widgets/learn/lesson_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

import 'support/fake_video_player.dart';

const _video1 = LearnLesson(
  id: 'q1',
  title: 'Starting with the letters',
  categoryId: 'quran',
  kind: LearnLessonKind.video,
  videoUrl: 'https://example.com/q1.mp4',
  durationMinutes: 6,
  order: 1,
);

const _article2 = LearnLesson(
  id: 'q2',
  title: 'Why tajweed matters',
  categoryId: 'quran',
  kind: LearnLessonKind.article,
  body: 'Tajweed means giving every letter its due.',
  durationMinutes: 3,
  order: 2,
);

const _video3 = LearnLesson(
  id: 'q3',
  title: 'Short and long vowels',
  categoryId: 'quran',
  kind: LearnLessonKind.video,
  videoUrl: 'https://example.com/q3.mp4',
  durationMinutes: 8,
  order: 3,
);

const _hadis1 = LearnLesson(
  id: 'h1',
  title: 'Reading a hadith well',
  categoryId: 'hadis',
  kind: LearnLessonKind.article,
  body: 'A hadith has a chain and a text.',
  durationMinutes: 4,
  order: 1,
);

// Deliberately listed out of order to prove the view sorts by `order`.
const _all = [_video3, _hadis1, _article2, _video1];

/// The built-in `TextScaler` and a narrow width are applied through the view
/// size so full screens (with an AppBar) are laid out like a small phone.
Future<void> _pumpHost(
  WidgetTester tester,
  Widget home, {
  double width = 400,
  double textScale = 1.0,
}) async {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.lightTheme,
      builder: (context, c) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: c!,
      ),
      home: home,
    ),
  );
  for (var i = 0; i < 3; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _pumpView(
  WidgetTester tester,
  LearnProgressService progress, {
  String? categoryId,
  void Function(Map<String, int>)? onCounts,
  double width = 400,
  double textScale = 1.0,
}) async {
  await _pumpHost(
    tester,
    Scaffold(
      body: LearnFreeView(
        categoryId: categoryId,
        onCounts: onCounts ?? (_) {},
        progress: progress,
      ),
    ),
    width: width,
    textScale: textScale,
  );
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// The video_player package awaits futures outside the fake clock, so give the
/// real event loop a turn, then let the tree catch up.
Future<void> _flushPlatform(WidgetTester tester) async {
  await tester.runAsync(() => Future<void>.delayed(Duration.zero));
  await tester.pump(const Duration(milliseconds: 50));
}

Future<void> _dispose(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await _flushPlatform(tester);
}

Finder _inLessonScreen(Finder f) =>
    find.descendant(of: find.byType(LearnLessonScreen), matching: f);

void main() {
  late LearnProgressService progress;
  late VideoPlayerPlatform previousPlatform;
  late LearnContentSource previousSource;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    progress = LearnProgressService();
    previousPlatform = VideoPlayerPlatform.instance;
    VideoPlayerPlatform.instance = FakeVideoPlayer();
    previousSource = LearnContentSource.instance;
    LearnContentSource.instance = LearnContentSource(
      lessons: () => Stream.value(_all),
    );
  });

  tearDown(() {
    VideoPlayerPlatform.instance = previousPlatform;
    LearnContentSource.instance = previousSource;
  });

  testWidgets('lists lessons filtered by category', (tester) async {
    await _pumpView(tester, progress, categoryId: 'quran');

    expect(find.byType(LessonCard), findsNWidgets(3));
    expect(find.text('Starting with the letters'), findsOneWidget);
    expect(find.text('Why tajweed matters'), findsOneWidget);
    expect(find.text('Short and long vowels'), findsOneWidget);
    expect(find.text('Reading a hadith well'), findsNothing);

    // Ordered by `order`, not by the order the source emitted them.
    final y1 = tester.getTopLeft(find.text('Starting with the letters')).dy;
    final y2 = tester.getTopLeft(find.text('Why tajweed matters')).dy;
    final y3 = tester.getTopLeft(find.text('Short and long vowels')).dy;
    expect(y1, lessThan(y2));
    expect(y2, lessThan(y3));

    await _dispose(tester);
  });

  testWidgets('null category lists every lesson', (tester) async {
    await _pumpView(tester, progress);
    expect(find.byType(LessonCard), findsNWidgets(4));
    await _dispose(tester);
  });

  testWidgets('shows an empty state for a category with no lessons', (
    tester,
  ) async {
    await _pumpView(tester, progress, categoryId: 'sirat');

    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.text('No lessons here yet'), findsOneWidget);
    expect(find.byType(LessonCard), findsNothing);

    await _dispose(tester);
  });

  testWidgets('shows shimmer placeholders while loading', (tester) async {
    final never = StreamController<List<LearnLesson>>();
    addTearDown(never.close);
    LearnContentSource.instance = LearnContentSource(
      lessons: () => never.stream,
    );
    await _pumpView(tester, progress);

    expect(find.byType(ShimmerBox), findsWidgets);
    expect(find.byType(LessonCard), findsNothing);
    expect(find.byType(EmptyState), findsNothing);

    await _dispose(tester);
  });

  testWidgets('onCounts reports lessons per category over all lessons', (
    tester,
  ) async {
    final reports = <Map<String, int>>[];
    await _pumpView(
      tester,
      progress,
      categoryId: 'hadis',
      onCounts: reports.add,
    );

    expect(reports, isNotEmpty);
    // Counted over every lesson, not just the filtered "hadis" list.
    expect(reports.last, {'quran': 3, 'hadis': 1});

    await _dispose(tester);
  });

  testWidgets('onCounts is not called after the view is disposed', (
    tester,
  ) async {
    final source = StreamController<List<LearnLesson>>();
    addTearDown(source.close);
    LearnContentSource.instance = LearnContentSource(
      lessons: () => source.stream,
    );
    var calls = 0;
    await _pumpView(tester, progress, onCounts: (_) => calls++);

    source.add(_all);
    await tester.pumpWidget(const SizedBox());
    await _flushPlatform(tester);
    source.add([_video1]);
    await _flushPlatform(tester);

    expect(tester.takeException(), isNull);
    expect(calls, lessThanOrEqualTo(1));
  });

  testWidgets('shows a continue card for the last unfinished lesson', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'learn_last': 'q2'});
    await _pumpView(tester, progress);
    await _settle(tester);

    expect(find.text('Pick up where you left off'), findsOneWidget);

    await _dispose(tester);
  });

  testWidgets('no continue card once the last lesson is done', (tester) async {
    SharedPreferences.setMockInitialValues({
      'learn_last': 'q2',
      'learn_done': ['q2'],
    });
    await _pumpView(tester, progress);
    await _settle(tester);

    expect(find.text('Pick up where you left off'), findsNothing);

    await _dispose(tester);
  });

  testWidgets('tapping a lesson opens the lesson screen', (tester) async {
    await _pumpView(tester, progress, categoryId: 'quran');

    await tester.tap(find.text('Why tajweed matters'));
    await _settle(tester);

    expect(find.byType(LearnLessonScreen), findsOneWidget);
    expect(_inLessonScreen(find.text('Why tajweed matters')), findsWidgets);
    expect(
      _inLessonScreen(find.text('Tajweed means giving every letter its due.')),
      findsOneWidget,
    );
    expect(progress.lastOpenedId, 'q2');

    await _dispose(tester);
  });

  testWidgets('Mark as done persists and shows the tick on return', (
    tester,
  ) async {
    await _pumpView(tester, progress, categoryId: 'quran');
    expect(
      find.descendant(
        of: find.byType(LessonCard),
        matching: find.byIcon(Icons.check_circle_rounded),
      ),
      findsNothing,
    );

    await tester.tap(find.text('Why tajweed matters'));
    await _settle(tester);
    await tester.tap(find.text('Mark as done'));
    await _settle(tester);

    expect(progress.isDone('q2'), isTrue);
    expect(_inLessonScreen(find.text('Completed')), findsOneWidget);

    await tester.pageBack();
    await _settle(tester);

    expect(find.byType(LearnLessonScreen), findsNothing);
    expect(
      find.descendant(
        of: find.byType(LessonCard),
        matching: find.byIcon(Icons.check_circle_rounded),
      ),
      findsOneWidget,
    );

    // It was saved to storage, so a brand new service sees it.
    final reloaded = LearnProgressService();
    await tester.runAsync(reloaded.load);
    expect(reloaded.isDone('q2'), isTrue);

    await _dispose(tester);
  });

  testWidgets('tapping Completed marks the lesson not done again', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'learn_done': ['q2'],
    });
    await _pumpHost(
      tester,
      LearnLessonScreen(lesson: _article2, siblings: _all, progress: progress),
    );
    await _settle(tester);
    expect(find.text('Completed'), findsOneWidget);

    await tester.tap(find.text('Completed'));
    await _settle(tester);

    expect(progress.isDone('q2'), isFalse);
    expect(find.text('Mark as done'), findsOneWidget);

    await _dispose(tester);
  });

  testWidgets('Next lesson opens the following lesson and is absent on the '
      'last', (tester) async {
    await _pumpHost(
      tester,
      LearnLessonScreen(lesson: _video1, siblings: _all, progress: progress),
    );
    await _settle(tester);

    // q1 -> q2 (skipping the hadis lesson that is not in the same category).
    expect(find.text('Next lesson'), findsOneWidget);
    await tester.tap(find.text('Next lesson'));
    await _settle(tester);
    expect(
      _inLessonScreen(find.text('Tajweed means giving every letter its due.')),
      findsOneWidget,
    );
    expect(progress.lastOpenedId, 'q2');

    // q2 -> q3, the last in the category.
    await tester.tap(find.text('Next lesson'));
    await _settle(tester);
    expect(_inLessonScreen(find.text('Short and long vowels')), findsWidgets);
    expect(progress.lastOpenedId, 'q3');
    expect(find.text('Next lesson'), findsNothing);

    await _dispose(tester);
  });

  testWidgets('an article with an empty body shows an inline message', (
    tester,
  ) async {
    const empty = LearnLesson(
      id: 'e1',
      title: 'An empty article',
      categoryId: 'quran',
      kind: LearnLessonKind.article,
      body: '   ',
      order: 1,
    );
    await _pumpHost(
      tester,
      LearnLessonScreen(
        lesson: empty,
        siblings: const [empty],
        progress: progress,
      ),
    );
    await _settle(tester);

    expect(tester.takeException(), isNull);
    expect(
      find.text('There is nothing to read in this lesson yet.'),
      findsOneWidget,
    );
    expect(find.text('Next lesson'), findsNothing);

    await _dispose(tester);
  });

  testWidgets('a video lesson with an empty url shows an inline message', (
    tester,
  ) async {
    const noUrl = LearnLesson(
      id: 'v0',
      title: 'A video without a link',
      categoryId: 'quran',
      kind: LearnLessonKind.video,
      videoUrl: '',
      order: 1,
    );
    await _pumpHost(
      tester,
      LearnLessonScreen(
        lesson: noUrl,
        siblings: const [noUrl],
        progress: progress,
      ),
    );
    await _settle(tester);

    expect(tester.takeException(), isNull);
    expect(find.text(CourseVideoPlayer.noVideoMessage), findsOneWidget);

    await _dispose(tester);
  });

  testWidgets(
    "the lesson screen contains no 'Tk', lock icon or 'Certificate'",
    (tester) async {
      for (final lesson in [_video1, _article2]) {
        await _pumpHost(
          tester,
          LearnLessonScreen(lesson: lesson, siblings: _all, progress: progress),
        );
        await _settle(tester);

        expect(find.textContaining('Tk'), findsNothing);
        expect(find.textContaining('BDT'), findsNothing);
        expect(find.textContaining('Certificate'), findsNothing);
        expect(find.textContaining('Preview'), findsNothing);
        expect(find.byIcon(Icons.lock), findsNothing);
        expect(find.byIcon(Icons.lock_rounded), findsNothing);
        expect(find.byIcon(Icons.lock_outline), findsNothing);
        expect(find.byIcon(Icons.lock_outline_rounded), findsNothing);

        await _dispose(tester);
      }
    },
  );

  testWidgets('a video lesson plays unlocked', (tester) async {
    await _pumpHost(
      tester,
      LearnLessonScreen(lesson: _video1, siblings: _all, progress: progress),
    );
    await _settle(tester);

    final player = tester.widget<CourseVideoPlayer>(
      find.byType(CourseVideoPlayer),
    );
    expect(player.locked, isFalse);
    expect(player.url, 'https://example.com/q1.mp4');

    await _dispose(tester);
  });

  testWidgets('the view has no overflow at width 320 and text scale 2.0', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'learn_last': 'q2'});
    await _pumpView(tester, progress, width: 320, textScale: 2.0);
    await _settle(tester);

    expect(tester.takeException(), isNull);
    expect(find.byType(LessonCard), findsWidgets);
    expect(find.text('Pick up where you left off'), findsOneWidget);

    await _dispose(tester);
  });

  testWidgets('the empty state has no overflow at 320 and 2.0x', (
    tester,
  ) async {
    await _pumpView(
      tester,
      progress,
      categoryId: 'sirat',
      width: 320,
      textScale: 2.0,
    );
    await _settle(tester);

    expect(tester.takeException(), isNull);
    expect(find.byType(EmptyState), findsOneWidget);

    await _dispose(tester);
  });

  testWidgets('the lesson screen has no overflow at 320 and 2.0x', (
    tester,
  ) async {
    for (final lesson in [_video1, _article2]) {
      await _pumpHost(
        tester,
        LearnLessonScreen(lesson: lesson, siblings: _all, progress: progress),
        width: 320,
        textScale: 2.0,
      );
      await _settle(tester);

      expect(tester.takeException(), isNull);
      expect(find.text('Mark as done'), findsOneWidget);

      await _dispose(tester);
    }
  });

  testWidgets('buttons are at least 44 dp tall', (tester) async {
    await _pumpHost(
      tester,
      LearnLessonScreen(lesson: _video1, siblings: _all, progress: progress),
    );
    await _settle(tester);

    for (final label in ['Mark as done', 'Next lesson']) {
      final button = find.ancestor(
        of: find.text(label),
        matching: find.bySubtype<ButtonStyleButton>(),
      );
      expect(tester.getSize(button.first).height, greaterThanOrEqualTo(44));
    }

    await _dispose(tester);
  });
}
