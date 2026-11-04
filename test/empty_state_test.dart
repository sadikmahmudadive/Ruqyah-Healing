import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruqyahhealing/theme/app_theme.dart';
import 'package:ruqyahhealing/widgets/empty_state.dart';
import 'package:ruqyahhealing/widgets/illustrations/ruqyah_illustrations.dart';

Widget _host(Widget child, {bool reduceMotion = false}) => MaterialApp(
  theme: AppTheme.lightTheme,
  builder: (context, c) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
    child: c!,
  ),
  home: Scaffold(body: child),
);

void main() {
  testWidgets('EmptyState shows title, message and a working action', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      _host(
        EmptyState(
          kind: FlatIllustrationKind.emptySearch,
          title: 'Nothing here',
          message: 'Try again later.',
          actionLabel: 'Retry',
          onAction: () => taps++,
        ),
      ),
    );
    // The illustration floats forever, so use fixed pumps.
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Nothing here'), findsOneWidget);
    expect(find.text('Try again later.'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    expect(taps, 1);
  });

  testWidgets('error and offline variants carry their own copy', (
    tester,
  ) async {
    await tester.pumpWidget(_host(EmptyState.error(onAction: () {})));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);

    await tester.pumpWidget(_host(EmptyState.offline(onAction: () {})));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('You are offline'), findsOneWidget);
  });

  testWidgets('with reduced motion the illustration holds still', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const EmptyState(kind: FlatIllustrationKind.emptyAudio, title: 'Quiet'),
        reduceMotion: true,
      ),
    );
    // No looping animation, so this settles instead of timing out.
    await tester.pumpAndSettle();
    expect(find.text('Quiet'), findsOneWidget);
  });

  testWidgets('every illustration kind paints without error', (tester) async {
    await tester.pumpWidget(
      _host(
        SingleChildScrollView(
          child: Wrap(
            children: [
              for (final k in FlatIllustrationKind.values)
                FlatIllustration(kind: k, size: 64),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
