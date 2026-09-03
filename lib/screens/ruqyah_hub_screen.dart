import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_gradients.dart';
import '../widgets/ruqyah_dua_icon.dart';
import 'video_consultation_screen.dart';

class RuqyahHubScreen extends StatefulWidget {
  const RuqyahHubScreen({super.key});

  @override
  State<RuqyahHubScreen> createState() => _RuqyahHubScreenState();
}

class _RuqyahHubScreenState extends State<RuqyahHubScreen> {
  String _selectedTopic = 'Protection';
  bool _isReminded = false;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _topics = const [
    'Protection',
    'Evil Eye',
    'Sihr',
    'Wasvas',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        backgroundColor: const Color(0xFFF5F7F6),
        body: Column(
          children: [
            // 1. Top Dark Green Header Area
            _buildTopHeader(),

            // 2. Scrollable Body Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Welcome Greeting Card
                    _buildWelcomeCard(),

                    const SizedBox(height: 16),

                    // 2. Search Bar
                    _buildSearchBar(),

                    const SizedBox(height: 14),

                    // 3. Topic Filter Pills
                    _buildTopicRow(),

                    const SizedBox(height: 20),

                    // 4. Featured Playlist Section
                    _buildFeaturedPlaylistSection(),

                    const SizedBox(height: 20),

                    // 5. Live Session Section
                    _buildLiveSessionSection(),

                    const SizedBox(height: 20),

                    // 6. Your Progress Section
                    _buildYourProgressSection(),

                    const SizedBox(height: 20),

                    // 7. PDF Guides Section
                    _buildPdfGuidesSection(),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Top Dark Green Header Area
  Widget _buildTopHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 20,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        gradient: AppGradients.greenHeaderGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          // Back Button
          Container(
            width: 44,
            height: 44,
            margin: const EdgeInsets.only(right: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: IconButton(
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
                  'RUQYAH HUB',
                  style: TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: Color(0xFFD49E35),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'May Allah grant you shifa and peace',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF81C784),
                  ),
                ),
              ],
            ),
          ),

          // Ruqyah Dua Icon Button Badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF0B4632),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFD49E35),
                width: 1.5,
              ),
            ),
            child: const Center(
              child: RuqyahDuaIcon(
                color: Color(0xFFD49E35),
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 1. Welcome Greeting Card
  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFEBF7F0),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFFD49E35),
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Peace be upon you',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF15221D),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Explore authentic spiritual remedies and live healing sessions.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.5,
                    color: Color(0xFF6E7E77),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. Search Bar
  Widget _buildSearchBar() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          const Icon(
            Icons.search_rounded,
            color: Color(0xFF90A4AE),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Color(0xFF15221D),
              ),
              decoration: const InputDecoration(
                hintText: 'Search recitations, duas, topics...',
                hintStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13.5,
                  color: Color(0xFF90A4AE),
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 3. Topic Filter Pills
  Widget _buildTopicRow() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _topics.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final topic = _topics[index];
          final isSelected = topic == _selectedTopic;

          return InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _selectedTopic = topic;
              });
            },
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0B4632) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF0B4632)
                      : const Color(0xFFE2E8E5),
                  width: 1.0,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color:
                              const Color(0xFF0B4632).withValues(alpha: 0.20),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  topic,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF52625B),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 4. Featured Playlist Section
  Widget _buildFeaturedPlaylistSection() {
    return Column(
      children: [
        Row(
          children: [
            const Text(
              'Featured Playlist',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF15221D),
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
              },
              child: const Text(
                'View all',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0B4632),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Arabic Calligraphy Badge
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFF0B4632),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    'الرقية',
                    style: TextStyle(
                      fontFamily: 'Cinzel',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFD49E35),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Protection',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF15221D),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Morning & Evening • 12 tracks • 48 min',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.5,
                        color: Color(0xFF6E7E77),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFFEBF7F0),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.play_arrow_rounded,
                    color: Color(0xFF0B4632),
                    size: 24,
                  ),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 5. Live Session Section
  Widget _buildLiveSessionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Live Session',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF15221D),
          ),
        ),

        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.circle,
                          color: Color(0xFFE74C3C),
                          size: 7,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'LIVE',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFE74C3C),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Starts in 2h 15m',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Color(0xFF90A4AE),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              const Text(
                'Ruqyah Live Session',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF15221D),
                ),
              ),

              const SizedBox(height: 2),

              const Text(
                'Ustazh Salim • Interactive healing & Q&A',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12.5,
                  color: Color(0xFF6E7E77),
                ),
              ),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 46,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppGradients.greenButtonGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      setState(() => _isReminded = !_isReminded);
                      if (_isReminded) {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) =>
                                const VideoConsultationScreen(
                              doctorName: 'Ustazh Salim',
                            ),
                          ),
                        );
                      }
                    },
                    child: Text(
                      _isReminded ? 'Joining Session...' : 'Remind me',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 6. Your Progress Section
  Widget _buildYourProgressSection() {
    return Column(
      children: [
        Row(
          children: [
            const Text(
              'Your Progress',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF15221D),
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
              },
              child: const Text(
                'View all',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0B4632),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MINUTES LISTENED',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: Color(0xFF90A4AE),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '112 min',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0B4632),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'This week\'s goal: 150 min',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11.5,
                        color: Color(0xFF90A4AE),
                      ),
                    ),
                  ],
                ),
              ),

              // Bar Chart Graphic Representation
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  _BarItem(height: 18, color: Color(0xFF81C784)),
                  SizedBox(width: 4),
                  _BarItem(height: 32, color: Color(0xFF0B4632)),
                  SizedBox(width: 4),
                  _BarItem(height: 22, color: Color(0xFF81C784)),
                  SizedBox(width: 4),
                  _BarItem(height: 42, color: Color(0xFFD49E35)),
                  SizedBox(width: 4),
                  _BarItem(height: 28, color: Color(0xFF0B4632)),
                  SizedBox(width: 4),
                  _BarItem(height: 36, color: Color(0xFF0B4632)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 7. PDF Guides Section
  Widget _buildPdfGuidesSection() {
    return Column(
      children: [
        Row(
          children: [
            const Text(
              'PDF Guides',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF15221D),
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
              },
              child: const Text(
                'View all',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0B4632),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Red Book Icon Container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: Color(0xFFE74C3C),
                    size: 24,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Ruqyah Guide',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF15221D),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'For protection & healing • 15 pages',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.5,
                        color: Color(0xFF6E7E77),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF7F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.download_rounded,
                    color: Color(0xFF0B4632),
                    size: 20,
                  ),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Downloading Daily Ruqyah Guide PDF...'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BarItem extends StatelessWidget {
  final double height;
  final Color color;

  const _BarItem({required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
