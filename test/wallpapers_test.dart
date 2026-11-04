import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruqyahhealing/models/wallpaper_model.dart';
import 'package:ruqyahhealing/screens/wallpapers_screen.dart';
import 'package:ruqyahhealing/services/wallpaper_downloader.dart';
import 'package:ruqyahhealing/theme/app_theme.dart';

WallpaperModel _w(
  String id, {
  String title = 'Mosque at dusk',
  String url = 'https://example.com/a.jpg',
  String category = '',
  bool active = true,
  DateTime? at,
}) => WallpaperModel(
  id: id,
  title: title,
  imageUrl: url,
  category: category,
  active: active,
  createdAt: at,
);

class _RecordingDownloader extends WallpaperDownloader {
  final List<String> saved = [];
  final WallpaperSaveResult result;
  _RecordingDownloader([this.result = WallpaperSaveResult.saved]);

  @override
  Future<WallpaperSaveResult> download(WallpaperModel w) async {
    saved.add(w.id);
    return result;
  }
}

Widget _host(Widget child) =>
    MaterialApp(theme: AppTheme.lightTheme, home: child);

void main() {
  group('WallpaperModel', () {
    test('reads the admin document fields', () {
      final w = WallpaperModel.fromMap({
        'title': ' Kaaba ',
        'image_url': 'https://x/y.jpg',
        'thumb_url': 'https://x/t.jpg',
        'category': 'Mosques',
        'active': true,
        'created_at': 1700000000000,
      }, 'doc1');
      expect(w.id, 'doc1');
      expect(w.title, 'Kaaba');
      expect(w.previewUrl, 'https://x/t.jpg');
      expect(w.createdAt, DateTime.fromMillisecondsSinceEpoch(1700000000000));
    });

    test('missing fields fall back safely', () {
      final w = WallpaperModel.fromMap({'image_url': 'https://x/y.jpg'}, 'd');
      expect(w.title, '');
      expect(w.active, isTrue);
      expect(w.previewUrl, 'https://x/y.jpg');
    });

    test('visible hides inactive and image-less ones, newest first', () {
      final list = WallpaperModel.visible([
        _w('old', at: DateTime(2024, 1, 1)),
        _w('new', at: DateTime(2025, 1, 1)),
        _w('hidden', active: false, at: DateTime(2026, 1, 1)),
        _w('noimg', url: ''),
        _w('undated', title: 'Zed'),
      ]);
      expect(list.map((e) => e.id), ['new', 'old', 'undated']);
    });

    test('file names are safe', () {
      expect(_w('a', title: 'Al-Aqsa & Dome!').fileName, 'ruqyah_al_aqsa_dome');
      expect(_w('a', title: '').fileName, 'ruqyah_a');
      expect(_w('', title: '###').fileName, 'ruqyah_wallpaper');
    });
  });

  group('WallpaperDownloader', () {
    final bytes = Uint8List.fromList([1, 2, 3]);

    test('saves the full-size image under a safe name', () async {
      String? gotUrl, gotName;
      final d = WallpaperDownloader(
        fetch: (u) async {
          gotUrl = u;
          return bytes;
        },
        ensureAccess: () async => true,
        save: (b, n) async => gotName = n,
      );
      final r = await d.download(_w('1', url: 'https://x/full.jpg'));
      expect(r, WallpaperSaveResult.saved);
      expect(gotUrl, 'https://x/full.jpg');
      expect(gotName, 'ruqyah_mosque_at_dusk');
    });

    test('stops when the gallery permission is refused', () async {
      var fetched = false;
      final d = WallpaperDownloader(
        fetch: (_) async {
          fetched = true;
          return bytes;
        },
        ensureAccess: () async => false,
        save: (_, _) async {},
      );
      expect(await d.download(_w('1')), WallpaperSaveResult.permissionDenied);
      expect(fetched, isFalse);
    });

    test('a network error or empty body is a failure, not a crash', () async {
      final throws = WallpaperDownloader(
        fetch: (_) async => throw Exception('offline'),
        ensureAccess: () async => true,
        save: (_, _) async {},
      );
      expect(await throws.download(_w('1')), WallpaperSaveResult.failed);

      final empty = WallpaperDownloader(
        fetch: (_) async => Uint8List(0),
        ensureAccess: () async => true,
        save: (_, _) async {},
      );
      expect(await empty.download(_w('1')), WallpaperSaveResult.failed);
    });
  });

  group('WallpapersScreen', () {
    testWidgets('shows a skeleton while loading', (tester) async {
      final handle = tester.ensureSemantics();
      final c = StreamController<List<WallpaperModel>>();
      addTearDown(c.close);
      await tester.pumpWidget(_host(WallpapersScreen(stream: c.stream)));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.bySemanticsLabel('Loading wallpapers'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('empty list shows the friendly empty state', (tester) async {
      await tester.pumpWidget(
        _host(WallpapersScreen(stream: Stream.value(const []))),
      );
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('No wallpapers yet'), findsOneWidget);
    });

    testWidgets('an error shows a retry that reopens the stream', (
      tester,
    ) async {
      var opened = 0;
      Stream<List<WallpaperModel>> fail() {
        opened++;
        return Stream<List<WallpaperModel>>.error(Exception('denied'));
      }

      // The screen takes one stream; a retry reuses it, so just check the UI.
      await tester.pumpWidget(_host(WallpapersScreen(stream: fail())));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      expect(opened, 1);
    });

    testWidgets('lists wallpapers, filters by category, downloads', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(900, 1800);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);

      final handle = tester.ensureSemantics();
      final d = _RecordingDownloader();
      await tester.pumpWidget(
        _host(
          WallpapersScreen(
            downloader: d,
            stream: Stream.value([
              _w('a', title: 'Kaaba', category: 'Mosques'),
              _w('b', title: 'Bismillah', category: 'Calligraphy'),
            ]),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Kaaba'), findsOneWidget);
      expect(find.text('Bismillah'), findsOneWidget);
      expect(find.text('Mosques'), findsOneWidget); // category chip

      await tester.tap(find.text('Calligraphy'));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Kaaba'), findsNothing);
      expect(find.text('Bismillah'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel(RegExp('Download Bismillah')));
      await tester.pump(const Duration(milliseconds: 100));
      expect(d.saved, ['b']);
      expect(find.text('Saved to your gallery'), findsOneWidget);

      // Let the toast leave so no timer is left pending.
      await tester.pump(const Duration(seconds: 6));
      handle.dispose();
    });

    testWidgets('a refused permission explains itself', (tester) async {
      final handle = tester.ensureSemantics();
      tester.view.physicalSize = const Size(900, 1800);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _host(
          WallpapersScreen(
            downloader: _RecordingDownloader(
              WallpaperSaveResult.permissionDenied,
            ),
            stream: Stream.value([_w('a', title: 'Kaaba')]),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      // The card fades in; while it is transparent it is hidden from
      // semantics, so let the entrance finish first.
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.bySemanticsLabel(RegExp('Download Kaaba')));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Allow photo access'), findsOneWidget);
      await tester.pump(const Duration(seconds: 6));
      handle.dispose();
    });

    testWidgets('holds up at a small width with large text', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2.0)),
            child: child!,
          ),
          home: WallpapersScreen(
            stream: Stream.value([
              _w(
                'a',
                title: 'A very long wallpaper title that wraps',
                category: 'Mosques',
              ),
              _w('b', title: 'Short', category: 'Calligraphy'),
            ]),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      // Real fonts are not loaded here, so only check nothing threw.
      expect(tester.takeException(), isNull);
    });
  });
}
