import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruqyahhealing/services/prayer_times_service.dart';
import 'package:ruqyahhealing/theme/app_theme.dart';
import 'package:ruqyahhealing/widgets/app_toast.dart';
import 'package:ruqyahhealing/widgets/auth_ui.dart';
import 'package:ruqyahhealing/widgets/flowing_gradient.dart';
import 'package:ruqyahhealing/widgets/hijri_date_card.dart';
import 'package:ruqyahhealing/widgets/islamic_pattern.dart';
import 'package:ruqyahhealing/widgets/modern_card.dart';
import 'package:ruqyahhealing/widgets/next_prayer_tile.dart';
import 'package:ruqyahhealing/widgets/qibla_compass.dart';

const _long =
    'An unusually long label that a translation or a user setting could '
    'easily produce, to make sure the component copes';

/// Builds [child] in a narrow, large-text, right-to-left frame, the harshest
/// combination, and expects no layout errors.
Future<void> _stress(
  WidgetTester tester,
  Widget child, {
  double width = 300,
  double textScale = 2.0,
  bool rtl = true,
  bool dark = false,
}) async {
  final errors = <FlutterErrorDetails>[];
  final previous = FlutterError.onError;
  FlutterError.onError = errors.add;
  addTearDown(() => FlutterError.onError = previous);
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
      builder: (context, c) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: Directionality(
          textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
          child: c!,
        ),
      ),
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
  await tester.pump(const Duration(milliseconds: 800));
  FlutterError.onError = previous;
  expect(
    errors.map((e) => e.toDiagnosticsNode().toStringDeep()).join('\n---\n'),
    isEmpty,
  );
  await tester.pumpWidget(const SizedBox());
}

void main() {
  testWidgets('AuthField copes with a very long hint and label', (t) async {
    final c = TextEditingController();
    await _stress(
      t,
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const AuthLabel(_long),
            AuthField(controller: c, hint: _long, icon: Icons.mail_outline),
            AuthField(controller: c, hint: _long, isPassword: true),
          ],
        ),
      ),
    );
  });

  testWidgets('AuthSegmented and AuthCarousel cope with long labels', (
    t,
  ) async {
    await _stress(
      t,
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AuthSegmented<int>(
              selected: 0,
              onChanged: (_) {},
              options: const [
                AuthOption(0, _long, Icons.mail),
                AuthOption(1, _long, Icons.phone),
              ],
            ),
            const SizedBox(height: 12),
            AuthCarousel<int>(
              selected: 0,
              onChanged: (_) {},
              options: const [
                AuthOption(0, _long, Icons.person),
                AuthOption(1, 'Raki', Icons.mic),
                AuthOption(2, 'Doctor', Icons.local_hospital),
              ],
            ),
          ],
        ),
      ),
    );
  });

  testWidgets('AuthButton, divider and Google button cope with long text', (
    t,
  ) async {
    await _stress(
      t,
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AuthButton(label: _long, onPressed: () {}),
            AuthButton(label: _long, tonal: true, onPressed: () {}),
            AuthButton(label: _long, loading: true, onPressed: () {}),
            const AuthDivider(_long),
            AuthGoogleButton(label: _long, onPressed: () {}),
          ],
        ),
      ),
    );
  });

  testWidgets('HijriDateCard copes with the longest month at 2x text', (
    t,
  ) async {
    await _stress(
      t,
      // 25 Jumada al-Thani is one of the longest English dates.
      HijriDateCard(now: () => DateTime(2026, 11, 14)),
    );
  });

  testWidgets('NextPrayerTile copes with 2x text and narrow width', (t) async {
    await _stress(
      t,
      NextPrayerTile(
        future: Future.value(PrayerTimesModel.fallback()),
        onTap: () {},
      ),
    );
  });

  testWidgets('QiblaCompassSection copes with 2x text and narrow width', (
    t,
  ) async {
    await _stress(t, const QiblaCompassSection(), width: 320);
  });

  testWidgets('ModernCard and the pattern widgets handle odd sizes', (t) async {
    await _stress(
      t,
      Column(
        children: [
          ModernCard(child: const Text(_long)),
          const SizedBox(width: 0, height: 0, child: IslamicPattern()),
          const SizedBox(
            width: 1,
            height: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(),
              child: SizedBox.shrink(),
            ),
          ),
          Container(
            width: 0,
            height: 0,
            foregroundDecoration: const IslamicPatternDecoration(),
          ),
          const SizedBox(
            height: 80,
            child: FlowingGradient(colors: [Colors.green, Colors.black]),
          ),
        ],
      ),
    );
  });

  testWidgets('AppToast copes with long text at 2x', (t) async {
    await _stress(
      t,
      Builder(
        builder: (context) => TextButton(
          onPressed: () => AppToast.show(
            context,
            title: _long,
            message: '$_long $_long',
            type: ToastType.warning,
          ),
          child: const Text('go'),
        ),
      ),
    );
  });
}
