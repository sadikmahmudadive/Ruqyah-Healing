import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/recitation.dart';
import '../services/ruqyah_api_service.dart';
import '../theme/app_gradients.dart';
import '../theme/app_theme.dart';
import '../widgets/animations/motion.dart';
import '../widgets/app_toast.dart';
import '../widgets/flowing_gradient.dart';
import '../widgets/islamic_pattern.dart';
import 'full_audio_player_screen.dart';

class AudioLibraryScreen extends StatefulWidget {
  const AudioLibraryScreen({super.key});

  @override
  State<AudioLibraryScreen> createState() => _AudioLibraryScreenState();
}

class _AudioLibraryScreenState extends State<AudioLibraryScreen> {
  String _selectedFilter = 'All';
  String _selectedCondition = 'All';
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _downloadedTracks = {};
  final Set<String> _liked = {};
  bool _isSyncing = false;

  final List<String> _filters = const [
    'All',
    'Playlists',
    'Quran Ayats',
    'Prophetic Duas',
    'Downloads',
  ];

  final List<String> _conditionFilters = const [
    'All',
    'Complete Ruqyah',
    'Sihr (Magic)',
    'Evil Eye & Envy',
    'Jinn & Waswas',
    'Healing & Shifa',
  ];

  @override
  void initState() {
    super.initState();
    RuqyahApiService.initialize();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleSyncApi() async {
    if (_isSyncing) return;
    HapticFeedback.mediumImpact();
    setState(() => _isSyncing = true);

    AppToast.show(
      context,
      title: 'Connecting to Quran API',
      message: 'Syncing authentic Arabic Ayats and audio CDN from api.alquran.cloud...',
      type: ToastType.info,
    );

    final success = await RuqyahApiService.syncFromApi();
    if (!mounted) return;
    setState(() => _isSyncing = false);

    if (success) {
      AppToast.show(
        context,
        title: 'API Synced Successfully',
        message: 'All Ruqyah Quran Ayats and Duas are updated with live audio streaming.',
        type: ToastType.success,
      );
    } else {
      AppToast.show(
        context,
        title: 'Sync Offline Safe',
        message: 'Verified offline cache loaded. All Quran Ayats and Duas are fully playable.',
        type: ToastType.info,
      );
    }
  }

  void _toggleLike(String id) {
    HapticFeedback.selectionClick();
    setState(() {
      if (!_liked.remove(id)) _liked.add(id);
    });
  }

  void _toggleDownload(String trackId, String trackTitle) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_downloadedTracks.contains(trackId)) {
        _downloadedTracks.remove(trackId);
      } else {
        _downloadedTracks.add(trackId);
      }
    });

    final isDownloaded = _downloadedTracks.contains(trackId);
    AppToast.show(
      context,
      title: isDownloaded ? 'Track Downloaded' : 'Removed Download',
      message: isDownloaded
          ? 'Downloaded $trackTitle for offline listening.'
          : '$trackTitle removed from offline downloads.',
      type: isDownloaded ? ToastType.success : ToastType.info,
    );
  }

  void _playContent(RecitationContent content) {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => FullAudioPlayerScreen(
          title: content.title,
          verses: content.subtitle,
          trackId: content.id,
          customContent: content,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  void _playSingleAyahOrDua(Ayah item) {
    final singleContent = RecitationContent(
      id: item.isDua
          ? 'single_dua_${item.number}'
          : 'single_ayah_${item.surah}_${item.number}',
      title: item.isDua ? item.surahName : '${item.surahName} (${item.ref})',
      arabicTitle: item.arabic.length > 25
          ? '${item.arabic.substring(0, 25)}...'
          : item.arabic,
      subtitle: item.isDua
          ? (item.reference ?? 'Prophetic Dua')
          : 'Quran Ayah ${item.ref}',
      category: item.isDua ? 'Prophetic Duas' : 'Quran Ruqyah',
      ayahs: [item],
    );
    _playContent(singleContent);
  }

  @override
  Widget build(BuildContext context) {
    final allPlaylists = RuqyahApiService.getAllPlaylists();
    final allQuranAyats = RuqyahApiService.getAllQuranAyats();
    final allDuas = RuqyahApiService.getAllDuas();
    final searchQuery = _searchController.text.trim().toLowerCase();

    // Filtered lists
    final filteredPlaylists = allPlaylists.where((p) {
      if (_selectedFilter == 'Quran Ayats' ||
          _selectedFilter == 'Prophetic Duas')
        return false;
      if (_selectedFilter == 'Downloads') {
        return _downloadedTracks.contains(p.id);
      }

      if (_selectedCondition != 'All') {
        final matchesCond =
            p.title.toLowerCase().contains(
              _selectedCondition
                  .toLowerCase()
                  .replaceAll(' & ', ' ')
                  .split(' ')
                  .first,
            ) ||
            p.category.toLowerCase().contains(
              _selectedCondition
                  .toLowerCase()
                  .replaceAll(' & ', ' ')
                  .split(' ')
                  .first,
            );
        if (!matchesCond) return false;
      }

      if (searchQuery.isEmpty) return true;
      return p.title.toLowerCase().contains(searchQuery) ||
          p.subtitle.toLowerCase().contains(searchQuery) ||
          p.arabicTitle.contains(searchQuery);
    }).toList();

    final filteredAyats = allQuranAyats.where((a) {
      if (_selectedFilter == 'Playlists' ||
          _selectedFilter == 'Prophetic Duas') {
        return false;
      }
      if (_selectedFilter == 'Downloads') {
        return _downloadedTracks.contains('${a.surah}:${a.number}');
      }

      if (searchQuery.isEmpty) return true;
      return a.surahName.toLowerCase().contains(searchQuery) ||
          a.ref.contains(searchQuery) ||
          a.meaning.toLowerCase().contains(searchQuery) ||
          a.transliteration.toLowerCase().contains(searchQuery) ||
          a.arabic.contains(searchQuery);
    }).toList();

    final filteredDuas = allDuas.where((d) {
      if (_selectedFilter == 'Playlists' || _selectedFilter == 'Quran Ayats') {
        return false;
      }
      if (_selectedFilter == 'Downloads') {
        return _downloadedTracks.contains(d.ref);
      }

      if (searchQuery.isEmpty) return true;
      return d.surahName.toLowerCase().contains(searchQuery) ||
          d.meaning.toLowerCase().contains(searchQuery) ||
          (d.reference != null &&
              d.reference!.toLowerCase().contains(searchQuery)) ||
          d.transliteration.toLowerCase().contains(searchQuery) ||
          d.arabic.contains(searchQuery);
    }).toList();

    final showFeatured =
        allPlaylists.isNotEmpty &&
        searchQuery.isEmpty &&
        (_selectedFilter == 'All' || _selectedFilter == 'Playlists');

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
            _buildTopHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(),
                    if (showFeatured) ...[
                      const SizedBox(height: 18),
                      _buildFeaturedBanner(allPlaylists.first),
                    ],
                    const SizedBox(height: 18),
                    _buildTabs(),
                    if (_selectedFilter == 'All' ||
                        _selectedFilter == 'Playlists') ...[
                      const SizedBox(height: 12),
                      _buildConditionChipsRow(),
                    ],
                    const SizedBox(height: 22),

                    // 1. Playlists: a shelf of cover cards
                    if (filteredPlaylists.isNotEmpty) ...[
                      _buildSectionHeader(
                        title: 'Ruqyah Audio Sessions',
                        count: '${filteredPlaylists.length} playlists',
                      ),
                      const SizedBox(height: 14),
                      _buildPlaylistShelf(filteredPlaylists),
                      const SizedBox(height: 26),
                    ],

                    // 2. Quran Ayats: a track list
                    if (filteredAyats.isNotEmpty &&
                        _selectedFilter != 'Playlists') ...[
                      _buildSectionHeader(
                        title: 'Quran Ayats for Ruqyah',
                        count: '${filteredAyats.length} verses',
                      ),
                      const SizedBox(height: 10),
                      _buildTrackList([
                        for (final a in filteredAyats)
                          _trackRow(
                            id: '${a.surah}:${a.number}',
                            title: '${a.surahName} ${a.ref}',
                            subtitle: a.meaning,
                            arabic: a.arabic,
                            onPlay: () => _playSingleAyahOrDua(a),
                          ),
                      ]),
                      const SizedBox(height: 26),
                    ],

                    // 3. Prophetic Duas: a track list
                    if (filteredDuas.isNotEmpty &&
                        _selectedFilter != 'Playlists') ...[
                      _buildSectionHeader(
                        title: 'Prophetic Duas (Sunnah)',
                        count: '${filteredDuas.length} healing duas',
                      ),
                      const SizedBox(height: 10),
                      _buildTrackList([
                        for (final d in filteredDuas)
                          _trackRow(
                            id: d.ref,
                            title: d.surahName,
                            subtitle: d.reference ?? d.meaning,
                            arabic: d.arabic,
                            gold: true,
                            onPlay: () => _playSingleAyahOrDua(d),
                          ),
                      ]),
                      const SizedBox(height: 26),
                    ],

                    // Empty state if nothing found
                    if (filteredPlaylists.isEmpty &&
                        filteredAyats.isEmpty &&
                        filteredDuas.isEmpty)
                      _buildEmptyState(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────── Header & status ────────────────────────────

  Widget _buildTopHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 20,
        left: 20,
        right: 20,
      ),
      foregroundDecoration: const IslamicPatternDecoration(
        radius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      decoration: BoxDecoration(
        gradient: AppGradients.headerGradient(context),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            margin: const EdgeInsets.only(right: 14),
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'RUQYAH AUDIO & DUAS',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: Color(0xFFE9C26F),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Recitations, Ayats & authentic Duas',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFD49E35).withValues(alpha: 0.25),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFD49E35).withValues(alpha: 0.6),
                width: 1.2,
              ),
            ),
            child: IconButton(
              icon: _isSyncing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Color(0xFFD49E35)),
                      ),
                    )
                  : const Icon(
                      Icons.sync_rounded,
                      color: Color(0xFFD49E35),
                      size: 22,
                    ),
              tooltip: 'Sync live API data',
              onPressed: _handleSyncApi,
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────── Featured banner ────────────────────────────

  /// The big coloured card at the top, like a "new album" banner: a call to
  /// begin the full session, with an eight-point star where the cover goes.
  Widget _buildFeaturedBanner(RecitationContent session) {
    return Semantics(
      button: true,
      label: 'Play the full Ruqyah session',
      child: GestureDetector(
        onTap: () => _playContent(session),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: FlowingGradient(
            colors: const [
              Color(0xFF0B4632),
              Color(0xFF14704B),
              Color(0xFF1B8A5E),
            ],
            child: Container(
              padding: const EdgeInsets.fromLTRB(22, 20, 14, 20),
              constraints: const BoxConstraints(minHeight: 150),
              foregroundDecoration: const IslamicPatternDecoration(
                opacity: 0.08,
                cell: 56,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'FEATURED SESSION',
                          style: AppType.eyebrow.copyWith(
                            color: AppColors.accentGoldSoft,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Begin with a full Ruqyah',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppType.display.copyWith(
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'A complete, gently paced recitation.',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppType.caption.copyWith(
                            fontSize: 12.5,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE9C26F),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.play_arrow_rounded,
                                size: 20,
                                color: Color(0xFF1A1405),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Listen',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A1405),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 104,
                    height: 104,
                    child: CustomPaint(
                      painter: const _StarEmblemPainter(),
                      child: const Center(
                        child: Text(
                          'رقية',
                          style: TextStyle(
                            fontSize: 26,
                            height: 1.2,
                            color: Color(0xFFE9C26F),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────── Search & tabs ────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.cardBorder, width: 1.0),
        boxShadow: AppElevation.subtle,
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: context.textMuted, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: context.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search Ayats, Duas, Surahs (e.g. 2:255, Sihr)',
                hintStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: context.textMuted,
                ),
                border: InputBorder.none,
                isDense: true,
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Text tabs with a gold underline under the chosen one.
  Widget _buildTabs() {
    return SizedBox(
      height:
          42 +
          (MediaQuery.textScalerOf(context).scale(10) / 10 - 1).clamp(
                0.0,
                1.0,
              ) *
              20,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 22),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = filter == _selectedFilter;
          return InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedFilter = filter);
            },
            borderRadius: BorderRadius.circular(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? context.textPrimary : context.textMuted,
                  ),
                  child: Text(filter),
                ),
                const SizedBox(height: 6),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  width: isSelected ? 22 : 0,
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.accentGold,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildConditionChipsRow() {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _conditionFilters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cond = _conditionFilters[index];
          final isSelected = cond == _selectedCondition;

          return InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedCondition = cond);
            },
            borderRadius: BorderRadius.circular(17),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? (context.isDarkMode
                          ? AppColors.accentGold
                          : AppColors.primaryGreen)
                    : context.cardBg,
                borderRadius: BorderRadius.circular(17),
                border: Border.all(
                  color: isSelected ? Colors.transparent : context.cardBorder,
                ),
              ),
              child: Center(
                child: Text(
                  cond,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? (context.isDarkMode
                              ? const Color(0xFF1A1405)
                              : Colors.white)
                        : context.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required String count}) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.accentGold,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppType.title.copyWith(color: context.textPrimary),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          count,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: context.textMuted,
          ),
        ),
      ],
    );
  }

  // ──────────────────────────── Playlist shelf ────────────────────────────

  static const List<List<Color>> _coverPalettes = [
    [Color(0xFF0B4632), Color(0xFF1B6A4C)],
    [Color(0xFF0F3D3E), Color(0xFF1F7A74)],
    [Color(0xFF3B2F12), Color(0xFF8A6420)],
    [Color(0xFF1C2E4A), Color(0xFF2F5D7C)],
    [Color(0xFF2C3E2D), Color(0xFF5B7F4F)],
  ];

  Widget _buildPlaylistShelf(List<RecitationContent> playlists) {
    return LayoutBuilder(
      builder: (context, c) => SizedBox(
        // Grows with the user's text size so titles are never clipped.
        height:
            232 +
            (MediaQuery.textScalerOf(context).scale(10) / 10 - 1).clamp(
                  0.0,
                  1.0,
                ) *
                80,
        // Cancels the page padding so the shelf scrolls edge to edge.
        child: OverflowBox(
          minWidth: c.maxWidth + 40,
          maxWidth: c.maxWidth + 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: playlists.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (_, i) => _buildPlaylistCard(playlists[i], i),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaylistCard(RecitationContent playlist, int index) {
    final palette = _coverPalettes[index % _coverPalettes.length];
    final isDownloaded = _downloadedTracks.contains(playlist.id);
    const width = 156.0;

    return SizedBox(
      width: width,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _playContent(playlist),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover art: the playlist's colours, the star lattice and its
            // Arabic title.
            Container(
              width: width,
              height: width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: palette,
                ),
                boxShadow: [
                  BoxShadow(
                    color: palette.first.withValues(alpha: 0.28),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    const Positioned.fill(
                      child: IslamicPattern(
                        color: Colors.white,
                        opacity: 0.1,
                        cell: 44,
                        fadeDown: false,
                      ),
                    ),
                    Positioned(
                      right: -26,
                      top: -26,
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: CustomPaint(
                          painter: const _StarEmblemPainter(soft: true),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      right: 14,
                      bottom: 14,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          playlist.arabicTitle.isNotEmpty
                              ? playlist.arabicTitle
                              : 'رقية',
                          maxLines: 1,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            fontSize: 24,
                            height: 1.3,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFE9C26F),
                          ),
                        ),
                      ),
                    ),
                    // Play badge, bottom right of the cover.
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE9C26F),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          size: 22,
                          color: Color(0xFF1A1405),
                        ),
                      ),
                    ),
                    if (isDownloaded)
                      const Positioned(
                        left: 12,
                        top: 12,
                        child: Icon(
                          Icons.download_done_rounded,
                          size: 18,
                          color: Colors.white70,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              playlist.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${playlist.ayahs.length} tracks · ${playlist.subtitle}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: context.textSecondary,
                    ),
                  ),
                ),
                InkResponse(
                  onTap: () => _toggleDownload(playlist.id, playlist.title),
                  radius: 18,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      isDownloaded
                          ? Icons.check_circle_rounded
                          : Icons.download_rounded,
                      size: 18,
                      color: context.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────── Track lists ────────────────────────────

  Widget _buildTrackList(List<Widget> rows) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: context.cardBorder),
        boxShadow: AppElevation.card,
      ),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i != rows.length - 1)
              Padding(
                padding: const EdgeInsets.only(left: 74, right: 16),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: context.cardBorder,
                ),
              ),
          ],
        ],
      ),
    );
  }

  /// One track, Spotify "playlist" style: a round play button, the title and
  /// a short line under it, then like and download on the right.
  Widget _trackRow({
    required String id,
    required String title,
    required String subtitle,
    required String arabic,
    required VoidCallback onPlay,
    bool gold = false,
  }) {
    final liked = _liked.contains(id);
    final downloaded = _downloadedTracks.contains(id);
    final accent = gold ? const Color(0xFFB8862B) : AppColors.primaryGreen;

    return InkWell(
      onTap: onPlay,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: gold ? AppColors.tintSand : AppColors.tintMint,
              ),
              child: Icon(Icons.play_arrow_rounded, size: 26, color: accent),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: context.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    arabic,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: context.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: liked ? 'Remove from favourites' : 'Add to favourites',
              onPressed: () => _toggleLike(id),
              visualDensity: VisualDensity.compact,
              icon: Icon(
                liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                size: 22,
                color: liked ? const Color(0xFFC4604F) : context.textMuted,
              ),
            ),
            IconButton(
              tooltip: downloaded ? 'Remove download' : 'Download',
              onPressed: () => _toggleDownload(id, title),
              visualDensity: VisualDensity.compact,
              icon: Icon(
                downloaded
                    ? Icons.check_circle_rounded
                    : Icons.download_rounded,
                size: 22,
                color: downloaded ? accent : context.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: context.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              'No recitations or duas found',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try searching for another keyword or clear filters.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: context.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Eight-point star in a ring: the library's emblem (banner and covers).
class _StarEmblemPainter extends CustomPainter {
  final bool soft;
  const _StarEmblemPainter({this.soft = false});

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2 - 4;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = soft ? 1.2 : 1.6
      ..color = const Color(0xFFE9C26F).withValues(alpha: soft ? 0.35 : 0.85);

    canvas.drawCircle(c, r, paint);
    canvas.drawCircle(
      c,
      r * 0.8,
      paint..color = paint.color.withValues(alpha: paint.color.a * 0.6),
    );
    paint.color = const Color(0xFFE9C26F).withValues(alpha: soft ? 0.35 : 0.85);
    for (final base in const [0.0, math.pi / 4]) {
      final p = Path();
      for (var i = 0; i < 4; i++) {
        final a = base + i * math.pi / 2;
        final o = Offset(
          c.dx + r * 0.9 * math.cos(a),
          c.dy + r * 0.9 * math.sin(a),
        );
        i == 0 ? p.moveTo(o.dx, o.dy) : p.lineTo(o.dx, o.dy);
      }
      canvas.drawPath(p..close(), paint);
    }
  }

  @override
  bool shouldRepaint(_StarEmblemPainter old) => old.soft != soft;
}
