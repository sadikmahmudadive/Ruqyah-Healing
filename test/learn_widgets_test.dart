import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruqyahhealing/models/course_model.dart';
import 'package:ruqyahhealing/models/learn_lesson_model.dart';
import 'package:ruqyahhealing/theme/app_theme.dart';
import 'package:ruqyahhealing/widgets/animations/press.dart';
import 'package:ruqyahhealing/widgets/learn/category_row.dart';
import 'package:ruqyahhealing/widgets/learn/course_card.dart';
import 'package:ruqyahhealing/widgets/learn/learn_switch.dart';
import 'package:ruqyahhealing/widgets/learn/lesson_card.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  double width = 360,
  double textScale = 1.0,
  TextDirection direction = TextDirection.ltr,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.lightTheme,
      builder: (context, c) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: Directionality(textDirection: direction, child: c!),
      ),
      home: Scaffold(
        body: Align(
          alignment: AlignmentDirectional.topStart,
          child: SizedBox(width: width, child: child),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 50));
}

const _lesson = LearnLesson(
  id: 'l1',
  title: 'Understanding the first chapter of the Quran',
  categoryId: 'quran',
  kind: LearnLessonKind.video,
  durationMinutes: 12,
);

const _article = LearnLesson(
  id: 'l2',
  title: 'A short article',
  categoryId: 'hadis',
  kind: LearnLessonKind.article,
  durationMinutes: 5,
);

const _course = CourseModel(
  courseId: 'c1',
  title: 'Foundations of Ruqyah Healing and Spiritual Care',
  description: 'desc',
  instructorId: 'i1',
  priceBdt: 1200,
  syllabus: [],
  quizzes: [],
  categoryId: 'ruqyah',
  instructorName: 'Dr. Example Instructor',
  rating: 4.5,
  reviewCount: 128,
);

void main() {
  group('LearnSwitch', () {
    testWidgets('tapping Courses fires onChanged(courses)', (tester) async {
      LearnSide? got;
      await _pump(
        tester,
        LearnSwitch(side: LearnSide.learn, onChanged: (s) => got = s),
      );
      await tester.tap(find.text('Courses'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(got, LearnSide.courses);
    });

    testWidgets('exposes semantic labels and selected state', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        LearnSwitch(side: LearnSide.learn, onChanged: (_) {}),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Learn, free')),
        isSemantics(
          label: 'Learn, free',
          isButton: true,
          hasSelectedState: true,
          isSelected: true,
        ),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Courses, paid')),
        isSemantics(
          label: 'Courses, paid',
          isButton: true,
          hasSelectedState: true,
          isSelected: false,
        ),
      );
      handle.dispose();
    });

    testWidgets('tap targets are at least 44 dp tall', (tester) async {
      await _pump(
        tester,
        LearnSwitch(side: LearnSide.courses, onChanged: (_) {}),
      );
      expect(
        tester.getSize(find.bySemanticsLabel('Learn, free')).height,
        greaterThanOrEqualTo(44),
      );
      expect(
        tester.getSize(find.bySemanticsLabel('Courses, paid')).height,
        greaterThanOrEqualTo(44),
      );
    });

    testWidgets('builds at width 320 with text scale 2.0', (tester) async {
      await _pump(
        tester,
        LearnSwitch(side: LearnSide.learn, onChanged: (_) {}),
        width: 320,
        textScale: 2.0,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('CategoryRow', () {
    testWidgets('shows All chip and categories with counts', (tester) async {
      await _pump(
        tester,
        CategoryRow(
          selectedId: null,
          onSelected: (_) {},
          counts: const {'quran': 3, 'hadis': 1},
          countNoun: 'Lessons',
        ),
        width: 400,
      );
      expect(find.text('All'), findsOneWidget);
      expect(find.text('3 Lessons'), findsOneWidget);
      expect(find.text('1 Lessons'), findsOneWidget);
      expect(find.text('0 Lessons'), findsWidgets);
    });

    testWidgets('renders the Courses noun', (tester) async {
      await _pump(
        tester,
        CategoryRow(
          selectedId: null,
          onSelected: (_) {},
          counts: const {'quran': 2},
          countNoun: 'Courses',
        ),
        width: 400,
      );
      expect(find.text('2 Courses'), findsOneWidget);
    });

    testWidgets('tap selects, tapping the selected one clears', (tester) async {
      final calls = <String?>[];
      String? selected;
      await _pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            return CategoryRow(
              selectedId: selected,
              onSelected: (id) {
                calls.add(id);
                setState(() => selected = id);
              },
              counts: const {'quran': 3},
              countNoun: 'Lessons',
            );
          },
        ),
        width: 400,
      );
      await tester.tap(find.text('3 Lessons'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(calls, ['quran']);
      await tester.tap(find.text('3 Lessons'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(calls, ['quran', null]);
      await tester.tap(find.text('All'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(calls, ['quran', null, null]);
    });

    testWidgets('builds at width 320 with text scale 2.0', (tester) async {
      await _pump(
        tester,
        CategoryRow(
          selectedId: 'quran',
          onSelected: (_) {},
          counts: const {'quran': 3},
          countNoun: 'Lessons',
        ),
        width: 320,
        textScale: 2.0,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('LessonCard', () {
    testWidgets('shows kind badge, minutes, Free tag and no price or lock', (
      tester,
    ) async {
      await _pump(
        tester,
        LessonCard(lesson: _lesson, done: false, onTap: () {}),
      );
      expect(find.text('Video'), findsOneWidget);
      expect(find.text('12 min'), findsOneWidget);
      expect(find.text('Free'), findsOneWidget);
      expect(find.textContaining('Tk'), findsNothing);
      expect(find.textContaining('Certificate'), findsNothing);
      expect(find.textContaining('Preview'), findsNothing);
      expect(find.byIcon(Icons.lock_rounded), findsNothing);
      expect(find.byIcon(Icons.lock_outline_rounded), findsNothing);
      expect(find.byIcon(Icons.lock), findsNothing);
      expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
    });

    testWidgets('article badge and done tick', (tester) async {
      await _pump(
        tester,
        LessonCard(lesson: _article, done: true, onTap: () {}),
      );
      expect(find.text('Article'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('tap fires onTap', (tester) async {
      var taps = 0;
      await _pump(
        tester,
        LessonCard(lesson: _lesson, done: false, onTap: () => taps++),
      );
      await tester.tap(find.byType(LessonCard));
      await tester.pump(const Duration(milliseconds: 400));
      expect(taps, 1);
    });

    testWidgets('builds at width 320 with text scale 2.0', (tester) async {
      await _pump(
        tester,
        LessonCard(lesson: _lesson, done: true, onTap: () {}),
        width: 320,
        textScale: 2.0,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('CategoryRow in real parents', () {
    Widget row() => CategoryRow(
      selectedId: null,
      onSelected: (_) {},
      counts: const {'quran': 3},
      countNoun: 'Lessons',
    );

    Future<void> pumpIn(WidgetTester tester, Widget body) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(body: body),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }

    void expectCompact(WidgetTester tester) {
      expect(tester.takeException(), isNull);
      final chips = find.descendant(
        of: find.byType(CategoryRow),
        matching: find.byType(PressScale),
      );
      expect(chips, findsWidgets);
      for (final e in chips.evaluate()) {
        final h = tester.getSize(find.byElementPredicate((x) => x == e)).height;
        expect(h, greaterThanOrEqualTo(44));
        expect(h, lessThan(140));
      }
      expect(tester.getSize(find.byType(CategoryRow)).height, lessThan(140));
    }

    testWidgets('inside a Column in a SingleChildScrollView', (tester) async {
      await pumpIn(
        tester,
        SingleChildScrollView(child: Column(children: [row()])),
      );
      expectCompact(tester);
    });

    testWidgets('inside a ListView', (tester) async {
      await pumpIn(tester, ListView(children: [row()]));
      expectCompact(tester);
    });

    testWidgets('inside a bounded 600 dp parent', (tester) async {
      await pumpIn(
        tester,
        SizedBox(height: 600, child: Column(children: [row()])),
      );
      expectCompact(tester);
    });
  });

  group('CourseCard', () {
    testWidgets('unowned shows price, rating, Certificate and Preview', (
      tester,
    ) async {
      await _pump(
        tester,
        CourseCard(
          course: _course,
          owned: false,
          onTap: () {},
          onPreview: () {},
        ),
      );
      expect(find.text('Tk 1200'), findsOneWidget);
      expect(find.text('4.5'), findsOneWidget);
      expect(find.text('(128)'), findsOneWidget);
      expect(find.text('Certificate'), findsOneWidget);
      expect(find.text('Preview ${kPreviewLimit.inSeconds}s'), findsOneWidget);
      expect(find.text('Owned'), findsNothing);
    });

    testWidgets('fractional price keeps its decimals', (tester) async {
      const c = CourseModel(
        courseId: 'c2',
        title: 't',
        description: '',
        instructorId: '',
        priceBdt: 99.5,
        syllabus: [],
        quizzes: [],
      );
      await _pump(
        tester,
        CourseCard(course: c, owned: false, onTap: () {}, onPreview: () {}),
      );
      expect(find.text('Tk 99.5'), findsOneWidget);
    });

    testWidgets('owned shows Owned and hides Preview', (tester) async {
      await _pump(
        tester,
        CourseCard(
          course: _course,
          owned: true,
          onTap: () {},
          onPreview: () {},
        ),
      );
      expect(find.text('Owned'), findsOneWidget);
      expect(find.textContaining('Preview'), findsNothing);
    });

    testWidgets('card tap and preview tap fire their own callbacks', (
      tester,
    ) async {
      var taps = 0;
      var previews = 0;
      await _pump(
        tester,
        CourseCard(
          course: _course,
          owned: false,
          onTap: () => taps++,
          onPreview: () => previews++,
        ),
      );
      await tester.tap(find.textContaining('Preview'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(previews, 1);
      expect(taps, 0);
      await tester.tap(find.text(_course.title));
      await tester.pump(const Duration(milliseconds: 400));
      expect(taps, 1);
    });

    testWidgets('builds at width 320 with text scale 2.0', (tester) async {
      for (final owned in [false, true]) {
        await _pump(
          tester,
          CourseCard(
            course: _course,
            owned: owned,
            onTap: () {},
            onPreview: () {},
          ),
          width: 320,
          textScale: 2.0,
        );
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('unknown category and RTL do not crash', (tester) async {
      const c = CourseModel(
        courseId: 'c3',
        title: 'x',
        description: '',
        instructorId: '',
        priceBdt: 10,
        syllabus: [],
        quizzes: [],
        categoryId: 'nope',
      );
      await _pump(
        tester,
        CourseCard(course: c, owned: false, onTap: () {}, onPreview: () {}),
        direction: TextDirection.rtl,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
