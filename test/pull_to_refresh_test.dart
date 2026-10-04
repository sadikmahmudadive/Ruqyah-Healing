import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruqyahhealing/widgets/animations/pull_to_refresh.dart';

void main() {
  testWidgets('pulling down runs onRefresh and settles without errors', (
    tester,
  ) async {
    var refreshed = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              AppRefreshSliver(
                onRefresh: () async {
                  refreshed++;
                  await Future<void>.delayed(const Duration(milliseconds: 300));
                },
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  for (var i = 0; i < 20; i++)
                    SizedBox(height: 80, child: Text('row $i')),
                ]),
              ),
            ],
          ),
        ),
      ),
    );

    // Drag well past the trigger distance, then release.
    await tester.fling(find.text('row 0'), const Offset(0, 300), 1000);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(CustomPaint), findsWidgets);

    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(refreshed, 1);
    expect(tester.takeException(), isNull);
  });
}
