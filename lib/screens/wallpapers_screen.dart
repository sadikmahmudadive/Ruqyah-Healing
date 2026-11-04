import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/wallpaper_model.dart';
import '../services/firebase_service.dart';
import '../services/wallpaper_downloader.dart';
import '../theme/app_gradients.dart';
import '../theme/app_theme.dart';
import '../widgets/animations/animations.dart';
import '../widgets/app_toast.dart';
import '../widgets/empty_state.dart';
import '../widgets/illustrations/ruqyah_illustrations.dart';
import '../widgets/islamic_pattern.dart';
import '../widgets/modern_card.dart';

/// Islamic wallpapers the admin team uploads. Browse by category, open one
/// full screen, and save it to the phone's gallery.
class WallpapersScreen extends StatefulWidget {
  /// Where the wallpapers come from. Defaults to the Firestore collection;
  /// tests pass their own.
  final Stream<List<WallpaperModel>>? stream;
  final WallpaperDownloader downloader;

  const WallpapersScreen({
    super.key,
    this.stream,
    this.downloader = const WallpaperDownloader(),
  });

  @override
  State<WallpapersScreen> createState() => _WallpapersScreenState();
}

class _WallpapersScreenState extends State<WallpapersScreen> {
  late Stream<List<WallpaperModel>> _stream = _open();
  String _category = 'All';
  final Set<String> _saving = {};

  Stream<List<WallpaperModel>> _open() =>
      widget.stream ?? FirebaseService.getWallpapersStream();

  Future<void> _download(WallpaperModel w) async {
    if (_saving.contains(w.id)) return;
    HapticFeedback.selectionClick();
    setState(() => _saving.add(w.id));
    final result = await widget.downloader.download(w);
    if (!mounted) return;
    setState(() => _saving.remove(w.id));

    switch (result) {
      case WallpaperSaveResult.saved:
        AppToast.show(
          context,
          title: 'Saved to your gallery',
          message: 'Open Photos to set it as your wallpaper.',
          type: ToastType.success,
        );
      case WallpaperSaveResult.permissionDenied:
        AppToast.show(
          context,
          title: 'Allow photo access',
          message: 'Saving needs permission to add to your gallery.',
          type: ToastType.warning,
        );
      case WallpaperSaveResult.failed:
        AppToast.show(
          context,
          title: 'Could not download',
          message: 'Check your connection and try again.',
          type: ToastType.error,
          actionLabel: 'Retry',
          onAction: () => _download(w),
        );
    }
  }

  void _openPreview(WallpaperModel w) {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      AppPageRoute.fade(
        _WallpaperPreview(wallpaper: w, onDownload: () => _download(w)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: context.pageBg,
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: StreamBuilder<List<WallpaperModel>>(
                stream: _stream,
                builder: (context, snap) {
                  if (snap.hasError) {
                    return EmptyState.error(
                      message: 'We could not load the wallpapers just now.',
                      onAction: () => setState(() => _stream = _open()),
                    );
                  }
                  if (!snap.hasData) return _buildLoading();

                  final all = WallpaperModel.visible(snap.data!);
                  if (all.isEmpty) {
                    return const EmptyState(
                      kind: FlatIllustrationKind.emptySearch,
                      title: 'No wallpapers yet',
                      message:
                          'Our team adds new Islamic wallpapers here. Please '
                          'check back soon.',
                    );
                  }
                  return _buildGallery(all);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 20,
        left: 20,
        right: 20,
      ),
      foregroundDecoration: IslamicPatternDecoration(),
      decoration: BoxDecoration(
        gradient: AppGradients.headerGradient(context),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            margin: const EdgeInsetsDirectional.only(end: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              tooltip: 'Back',
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
              padding: EdgeInsets.zero,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'WALLPAPERS',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: Color(0xFFD49E35),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Islamic wallpapers for your phone',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Semantics(
      label: 'Loading wallpapers',
      child: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.62,
        children: List.generate(
          6,
          (_) => const ShimmerBox(
            width: double.infinity,
            height: double.infinity,
            radius: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildGallery(List<WallpaperModel> all) {
    final categories = <String>{
      for (final w in all)
        if (w.category.isNotEmpty) w.category,
    }.toList()..sort();
    // The chosen category may vanish if the admin removes its last picture.
    final selected = categories.contains(_category) ? _category : 'All';
    final shown = selected == 'All'
        ? all
        : all.where((w) => w.category == selected).toList();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        if (categories.isNotEmpty)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 62,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                itemCount: categories.length + 1,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final label = i == 0 ? 'All' : categories[i - 1];
                  return ModernChip(
                    label: label,
                    selected: label == selected,
                    onTap: () => setState(() => _category = label),
                  );
                },
              ),
            ),
          ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            20,
            categories.isEmpty ? 20 : 8,
            20,
            32 + MediaQuery.paddingOf(context).bottom,
          ),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.62,
            ),
            delegate: SliverChildBuilderDelegate((context, i) {
              final w = shown[i];
              return FadeSlideIn(
                delay: AppMotion.staggerStep * (i < 6 ? i : 6),
                child: _WallpaperCard(
                  wallpaper: w,
                  saving: _saving.contains(w.id),
                  onOpen: () => _openPreview(w),
                  onDownload: () => _download(w),
                ),
              );
            }, childCount: shown.length),
          ),
        ),
      ],
    );
  }
}

/// The network picture with a skeleton while it loads and a quiet placeholder
/// if it cannot be fetched.
class _WallpaperImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  const _WallpaperImage({required this.url, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: fit,
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : const ShimmerBox(
              width: double.infinity,
              height: double.infinity,
              radius: 0,
            ),
      errorBuilder: (context, error, stack) => ColoredBox(
        color: context.containerBg,
        child: Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            color: context.textMuted,
            size: 30,
          ),
        ),
      ),
    );
  }
}

class _WallpaperCard extends StatelessWidget {
  final WallpaperModel wallpaper;
  final bool saving;
  final VoidCallback onOpen;
  final VoidCallback onDownload;

  const _WallpaperCard({
    required this.wallpaper,
    required this.saving,
    required this.onOpen,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final title = wallpaper.title.isEmpty ? 'Wallpaper' : wallpaper.title;
    return Semantics(
      button: true,
      label: '$title wallpaper. Opens a preview.',
      child: PressScale(
        onTap: onOpen,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _WallpaperImage(url: wallpaper.previewUrl),
              // Darkens the bottom so the title stays readable on any image.
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x00000000),
                      Color(0x00000000),
                      Color(0xB3000000),
                    ],
                    stops: [0.0, 0.6, 1.0],
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 56,
                bottom: 12,
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.25,
                  ),
                ),
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: _DownloadButton(
                  saving: saving,
                  onPressed: onDownload,
                  label: 'Download $title',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DownloadButton extends StatelessWidget {
  final bool saving;
  final VoidCallback onPressed;
  final String label;
  const _DownloadButton({
    required this.saving,
    required this.onPressed,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: true,
      label: label,
      enabled: !saving,
      child: Material(
        color: AppColors.accentGold,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: saving ? null : onPressed,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Center(
              child: saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Color(0xFF1A1405),
                      ),
                    )
                  : const Icon(
                      Icons.download_rounded,
                      size: 22,
                      color: Color(0xFF1A1405),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A wallpaper full screen, zoomable, with a download button.
class _WallpaperPreview extends StatefulWidget {
  final WallpaperModel wallpaper;
  final VoidCallback onDownload;

  const _WallpaperPreview({required this.wallpaper, required this.onDownload});

  @override
  State<_WallpaperPreview> createState() => _WallpaperPreviewState();
}

class _WallpaperPreviewState extends State<_WallpaperPreview> {
  @override
  Widget build(BuildContext context) {
    final w = widget.wallpaper;
    final top = MediaQuery.paddingOf(context).top;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            InteractiveViewer(
              maxScale: 4,
              child: _WallpaperImage(url: w.imageUrl, fit: BoxFit.contain),
            ),
            Positioned(
              top: top + 8,
              left: 16,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  tooltip: 'Close',
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 40, 20, 20 + bottom),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00000000), Color(0xCC000000)],
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            w.title.isEmpty ? 'Wallpaper' : w.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          if (w.category.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              w.category,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12.5,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: widget.onDownload,
                      icon: const Icon(Icons.download_rounded),
                      label: const Text('Download'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accentGold,
                        foregroundColor: const Color(0xFF1A1405),
                        minimumSize: const Size(48, 48),
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        textStyle: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
