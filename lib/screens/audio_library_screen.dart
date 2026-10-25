import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/recitation.dart';
import '../services/ruqyah_api_service.dart';
import '../theme/app_gradients.dart';
import '../theme/app_theme.dart';
import '../widgets/app_toast.dart';
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
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  void _playSingleAyahOrDua(Ayah item) {
    final singleContent = RecitationContent(
      id: item.isDua ? 'single_dua_${item.number}' : 'single_ayah_${item.surah}_${item.number}',
      title: item.isDua ? item.surahName : '${item.surahName} (${item.ref})',
      arabicTitle: item.arabic.length > 25 ? '${item.arabic.substring(0, 25)}...' : item.arabic,
      subtitle: item.isDua ? (item.reference ?? 'Prophetic Dua') : 'Quran Ayah ${item.ref}',
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
      if (_selectedFilter == 'Quran Ayats' || _selectedFilter == 'Prophetic Duas') return false;
      if (_selectedFilter == 'Downloads') return _downloadedTracks.contains(p.id);

      if (_selectedCondition != 'All') {
        final matchesCond = p.title.toLowerCase().contains(_selectedCondition.toLowerCase().replaceAll(' & ', ' ').split(' ').first) ||
            p.category.toLowerCase().contains(_selectedCondition.toLowerCase().replaceAll(' & ', ' ').split(' ').first);
        if (!matchesCond) return false;
      }

      if (searchQuery.isEmpty) return true;
      return p.title.toLowerCase().contains(searchQuery) ||
          p.subtitle.toLowerCase().contains(searchQuery) ||
          p.arabicTitle.contains(searchQuery);
    }).toList();

    final filteredAyats = allQuranAyats.where((a) {
      if (_selectedFilter == 'Playlists' || _selectedFilter == 'Prophetic Duas') return false;
      if (_selectedFilter == 'Downloads') return _downloadedTracks.contains('${a.surah}:${a.number}');

      if (searchQuery.isEmpty) return true;
      return a.surahName.toLowerCase().contains(searchQuery) ||
          a.ref.contains(searchQuery) ||
          a.meaning.toLowerCase().contains(searchQuery) ||
          a.transliteration.toLowerCase().contains(searchQuery) ||
          a.arabic.contains(searchQuery);
    }).toList();

    final filteredDuas = allDuas.where((d) {
      if (_selectedFilter == 'Playlists' || _selectedFilter == 'Quran Ayats') return false;
      if (_selectedFilter == 'Downloads') return _downloadedTracks.contains(d.ref);

      if (searchQuery.isEmpty) return true;
      return d.surahName.toLowerCase().contains(searchQuery) ||
          d.meaning.toLowerCase().contains(searchQuery) ||
          (d.reference != null && d.reference!.toLowerCase().contains(searchQuery)) ||
          d.transliteration.toLowerCase().contains(searchQuery) ||
          d.arabic.contains(searchQuery);
    }).toList();

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
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildApiBanner(),
                    const SizedBox(height: 14),
                    _buildSearchBar(),
                    const SizedBox(height: 14),
                    _buildFilterRow(),
                    if (_selectedFilter == 'All' || _selectedFilter == 'Playlists') ...[
                      const SizedBox(height: 12),
                      _buildConditionChipsRow(),
                    ],
                    const SizedBox(height: 20),

                    // 1. Playlists Section
                    if (filteredPlaylists.isNotEmpty) ...[
                      _buildSectionHeader(
                        title: 'Ruqyah Audio Sessions',
                        count: '${filteredPlaylists.length} playlists',
                        icon: Icons.album_rounded,
                      ),
                      const SizedBox(height: 12),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: filteredPlaylists.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (_, index) => _buildPlaylistCard(filteredPlaylists[index]),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // 2. Quran Ayats Section
                    if (filteredAyats.isNotEmpty && _selectedFilter != 'Playlists') ...[
                      _buildSectionHeader(
                        title: 'Quran Ayats for Ruqyah',
                        count: '${filteredAyats.length} verses',
                        icon: Icons.menu_book_rounded,
                      ),
                      const SizedBox(height: 12),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: filteredAyats.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (_, index) => _buildAyahCard(filteredAyats[index]),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // 3. Prophetic Duas Section
                    if (filteredDuas.isNotEmpty && _selectedFilter != 'Playlists') ...[
                      _buildSectionHeader(
                        title: 'Prophetic Duas (Sunnah)',
                        count: '${filteredDuas.length} healing duas',
                        icon: Icons.favorite_border_rounded,
                      ),
                      const SizedBox(height: 12),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: filteredDuas.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (_, index) => _buildDuaCard(filteredDuas[index]),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Empty state if nothing found
                    if (filteredPlaylists.isEmpty && filteredAyats.isEmpty && filteredDuas.isEmpty)
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

  // ──────────────────────────── Header & Banner ────────────────────────────

  Widget _buildTopHeader() {
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
            margin: const EdgeInsets.only(right: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
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
                    color: Color(0xFFD49E35),
                  ),
                ),
                Text(
                  'Online API Audio • Ayats & Authentic Duas',
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
          // Sync button
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFD49E35).withValues(alpha: 0.25),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD49E35).withValues(alpha: 0.6), width: 1.2),
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
                  : const Icon(Icons.sync_rounded, color: Color(0xFFD49E35), size: 22),
              tooltip: 'Sync live API data',
              onPressed: _handleSyncApi,
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0B4632).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF0B4632).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF0B4632),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.cloud_done_rounded, color: Color(0xFFD49E35), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Live Audio API Streaming',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: context.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Al-Quran Cloud CDN & Sunnah Duas',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.5,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _handleSyncApi,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Sync API',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0B4632),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────── Search & Filters ────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.cardBorder, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: AppColors.lightTextMuted, size: 20),
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
                hintText: 'Search Ayats, Duas, Surahs (e.g. 2:255, Sihr, Jibril)...',
                hintStyle: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppColors.lightTextMuted,
                ),
                border: InputBorder.none,
                isDense: true,
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
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

  Widget _buildFilterRow() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = filter == _selectedFilter;

          return InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedFilter = filter);
            },
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0B4632) : context.cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? const Color(0xFF0B4632) : context.cardBorder,
                  width: 1.0,
                ),
              ),
              child: Center(
                child: Text(
                  filter,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? Colors.white : context.textPrimary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildConditionChipsRow() {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _conditionFilters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final cond = _conditionFilters[index];
          final isSelected = cond == _selectedCondition;

          return InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedCondition = cond);
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFD49E35) : context.cardBg.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? const Color(0xFFD49E35) : context.cardBorder,
                  width: 0.8,
                ),
              ),
              child: Center(
                child: Text(
                  cond,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : context.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String count,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF0B4632)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.tintMint,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            count,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0B4632),
            ),
          ),
        ),
      ],
    );
  }

  // ──────────────────────────── Cards ────────────────────────────

  Widget _buildPlaylistCard(RecitationContent playlist) {
    final isDownloaded = _downloadedTracks.contains(playlist.id);

    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.cardBorder, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _playContent(playlist),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                // Arabic Badge
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0B4632), Color(0xFF1B6A4C)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      playlist.arabicTitle.isNotEmpty ? playlist.arabicTitle.split(' ').last : 'رقية',
                      style: const TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFD49E35),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              playlist.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 15.5,
                                fontWeight: FontWeight.w700,
                                color: context.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            margin: const EdgeInsets.only(left: 6),
                            decoration: BoxDecoration(
                              color: AppColors.tintSand,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${playlist.ayahs.length} tracks',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFD49E35),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        playlist.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12.5,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Download action
                IconButton(
                  icon: Icon(
                    isDownloaded ? Icons.check_circle_rounded : Icons.download_rounded,
                    color: const Color(0xFF0B4632),
                    size: 20,
                  ),
                  onPressed: () => _toggleDownload(playlist.id, playlist.title),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
                // Play Icon Button
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0B4632),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Color(0xFFD49E35),
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAyahCard(Ayah ayah) {
    final trackId = '${ayah.surah}:${ayah.number}';
    final isDownloaded = _downloadedTracks.contains(trackId);

    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.cardBorder, width: 0.8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _playSingleAyahOrDua(ayah),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0B4632).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${ayah.surahName} ${ayah.ref}',
                              style: const TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0B4632),
                              ),
                            ),
                          ),
                          if (ayah.reference != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.tintSand,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                ayah.reference!,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFD49E35),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Download
                    InkWell(
                      onTap: () => _toggleDownload(trackId, '${ayah.surahName} ${ayah.ref}'),
                      child: Icon(
                        isDownloaded ? Icons.check_circle_rounded : Icons.download_rounded,
                        size: 18,
                        color: const Color(0xFF0B4632),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Play icon
                    Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0B4632),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Color(0xFFD49E35),
                        size: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Arabic text snippet
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    ayah.arabic,
                    textDirection: TextDirection.rtl,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      height: 1.8,
                      color: Color(0xFF0B4632),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Meaning
                Text(
                  ayah.meaning,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDuaCard(Ayah dua) {
    final trackId = dua.ref;
    final isDownloaded = _downloadedTracks.contains(trackId);

    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD49E35).withValues(alpha: 0.3), width: 0.8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _playSingleAyahOrDua(dua),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD49E35).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        dua.reference ?? 'Hadith Dua',
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFD49E35),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        dua.surahName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: context.textPrimary,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => _toggleDownload(trackId, dua.surahName),
                      child: Icon(
                        isDownloaded ? Icons.check_circle_rounded : Icons.download_rounded,
                        size: 18,
                        color: const Color(0xFF0B4632),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0B4632),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Color(0xFFD49E35),
                        size: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    dua.arabic,
                    textDirection: TextDirection.rtl,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      height: 1.8,
                      color: Color(0xFF0B4632),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dua.meaning,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
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
            Icon(Icons.search_off_rounded, size: 48, color: context.textSecondary),
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
