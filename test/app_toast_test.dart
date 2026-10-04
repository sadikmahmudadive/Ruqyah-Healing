import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruqyahhealing/widgets/app_toast.dart';

Widget _app({String title = 'Saved'}) {
  return MaterialApp(
    builder: (context, child) => AppToastHost(child: child!),
    home: Scaffold(
      body: Builder(
        builder: (context) => Center(
          child: ElevatedButton(
            onPressed: () => AppToast.show(
              context,
              title: title,
              message: 'Check-in recorded.',
              type: ToastType.success,
            ),
            child: const Text('show'),
          ),
        ),
      ),
    ),
  );
}

/// The first pump after show() only starts the animation clock; the second
/// runs it past the 380ms slide-in.
Future<void> _slideIn(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  testWidgets('toast appears at the top and auto-dismisses', (tester) async {
    await tester.pumpWidget(_app());
    await tester.tap(find.text('show'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('Check-in recorded.'), findsOneWidget);
    // Top banner: sits in the upper part of the screen, not at the bottom.
    expect(tester.getTopLeft(find.text('Saved')).dy, lessThan(150));

    // Success toast lifetime is 3s; after that it is gone.
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.text('Saved'), findsNothing);
  });

  testWidgets('tapping the close button dismisses it', (tester) async {
    await tester.pumpWidget(_app());
    await tester.tap(find.text('show'));
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Saved'), findsNothing);
  });

  testWidgets('swiping up dismisses it', (tester) async {
    await tester.pumpWidget(_app());
    await tester.tap(find.text('show'));
    await tester.pump(const Duration(milliseconds: 500));

    await tester.fling(find.text('Saved'), const Offset(0, -200), 1500);
    await tester.pumpAndSettle();
    expect(find.text('Saved'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a new toast replaces the current one', (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => AppToastHost(child: child!),
        home: Builder(
          builder: (context) {
            ctx = context;
            return const Scaffold();
          },
        ),
      ),
    );

    AppToast.show(ctx, title: 'First', message: 'one');
    await _slideIn(tester);
    AppToast.show(ctx, title: 'Second', message: 'two', type: ToastType.error);
    await _slideIn(tester);

    expect(find.text('First'), findsNothing);
    expect(find.text('Second'), findsOneWidget);

    AppToast.dismiss();
    await tester.pumpAndSettle();
    expect(find.text('Second'), findsNothing);
  });

  testWidgets('action button runs the callback and dismisses', (tester) async {
    late BuildContext ctx;
    var retried = 0;
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => AppToastHost(child: child!),
        home: Builder(
          builder: (context) {
            ctx = context;
            return const Scaffold();
          },
        ),
      ),
    );

    AppToast.show(
      ctx,
      title: 'Audio unavailable',
      message: 'Could not load.',
      type: ToastType.error,
      actionLabel: 'Retry',
      onAction: () => retried++,
    );
    await _slideIn(tester);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(retried, 1);
    expect(find.text('Audio unavailable'), findsNothing);
  });

  testWidgets('long message does not overflow', (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => AppToastHost(child: child!),
        home: Builder(
          builder: (context) {
            ctx = context;
            return const Scaffold();
          },
        ),
      ),
    );

    AppToast.show(
      ctx,
      title: 'A fairly long title that needs to wrap onto a second line here',
      message: List.filled(12, 'This is a long explanatory sentence.').join(' '),
      type: ToastType.warning,
      actionLabel: 'Fix it',
    );
    await _slideIn(tester);
    expect(tester.takeException(), isNull);

    AppToast.dismiss();
    await tester.pumpAndSettle();
  });

  testWidgets('falls back to a SnackBar when no host is installed', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => AppToast.show(
                context,
                title: 'Fallback',
                message: 'still shown',
              ),
              child: const Text('go'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Fallback'), findsOneWidget);
  });
}
