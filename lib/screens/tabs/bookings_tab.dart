import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../therapist_profile_screen.dart';

class Therapist {
  final String id;
  final String name;
  final String title;
  final double rating;
  final int reviewsCount;
  final String experience;
  final String distance;
  final List<String> languages;
  final String nextSlot;
  final int price;
  final bool isVerified;
  final String avatarUrl;
  final String category;

  const Therapist({
    required this.id,
    required this.name,
    required this.title,
    required this.rating,
    required this.reviewsCount,
    required this.experience,
    required this.distance,
    required this.languages,
    required this.nextSlot,
    required this.price,
    this.isVerified = true,
    required this.avatarUrl,
    required this.category,
  });
}

class BookingsTab extends StatefulWidget {
  const BookingsTab({super.key});

  @override
  State<BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends State<BookingsTab> {
  String _selectedCategory = 'Ruqyah';
  bool _verifiedOnly = true;
  String _viewMode = 'List'; // 'List' or 'Map'
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = const [
    'Ruqyah',
    'Hijama',
    'Acupuncture',
    'Counseling',
  ];

  final List<Therapist> _allTherapists = const [
    Therapist(
      id: 'ther_1',
      name: 'Dr. Salma Rahman',
      title: 'Ruqyah Specialist',
      rating: 4.9,
      reviewsCount: 126,
      experience: '8+ yrs exp',
      distance: '1.2 km away',
      languages: ['Bangla', 'English'],
      nextSlot: 'Today, 10:30 AM',
      price: 1200,
      isVerified: true,
      avatarUrl: 'assets/logo/logo_app.png',
      category: 'Ruqyah',
    ),
    Therapist(
      id: 'ther_2',
      name: 'Mufti Arif Hussain',
      title: 'Ruqyah & Islamic Counselor',
      rating: 4.8,
      reviewsCount: 98,
      experience: '6+ yrs exp',
      distance: '2.4 km away',
      languages: ['Bangla'],
      nextSlot: 'Tomorrow, 9:00 AM',
      price: 1000,
      isVerified: true,
      avatarUrl: 'assets/logo/logo_app.png',
      category: 'Ruqyah',
    ),
    Therapist(
      id: 'ther_3',
      name: 'Hafiz Imran Hasan',
      title: 'Ruqyah Specialist',
      rating: 4.7,
      reviewsCount: 74,
      experience: '5+ yrs exp',
      distance: '3.6 km away',
      languages: ['Bangla', 'English'],
      nextSlot: 'May 21, 11:00 AM',
      price: 900,
      isVerified: true,
      avatarUrl: 'assets/logo/logo_app.png',
      category: 'Ruqyah',
    ),
    Therapist(
      id: 'ther_4',
      name: 'Dr. Tariqul Islam',
      title: 'Certified Hijama Practitioner',
      rating: 4.9,
      reviewsCount: 142,
      experience: '9+ yrs exp',
      distance: '1.8 km away',
      languages: ['Bangla', 'English'],
      nextSlot: 'Today, 3:00 PM',
      price: 1500,
      isVerified: true,
      avatarUrl: 'assets/logo/logo_app.png',
      category: 'Hijama',
    ),
    Therapist(
      id: 'ther_5',
      name: 'Dr. Amina Begum',
      title: 'Acupuncture & Meridian Specialist',
      rating: 4.8,
      reviewsCount: 85,
      experience: '7+ yrs exp',
      distance: '2.1 km away',
      languages: ['Bangla', 'English'],
      nextSlot: 'Tomorrow, 2:00 PM',
      price: 1300,
      isVerified: true,
      avatarUrl: 'assets/logo/logo_app.png',
      category: 'Acupuncture',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredTherapists = _allTherapists.where((therapist) {
      final matchesCategory = therapist.category == _selectedCategory;
      final matchesVerified = !_verifiedOnly || therapist.isVerified;
      final query = _searchController.text.toLowerCase().trim();
      final matchesQuery = query.isEmpty ||
          therapist.name.toLowerCase().contains(query) ||
          therapist.title.toLowerCase().contains(query);
      return matchesCategory && matchesVerified && matchesQuery;
    }).toList();

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
            // 1. Top Header Container (Dark Green #0B4632)
            _buildTopHeader(),

            // 2. Scrollable Body Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // Category Filter Pills
                    _buildCategoryRow(),

                    const SizedBox(height: 14),

                    // Filter Controls Row (Verified Only Switch + List/Map Segment)
                    _buildFilterControlsRow(),

                    const SizedBox(height: 16),

                    // Therapist Cards List
                    if (filteredTherapists.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          'No specialists found matching your criteria',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 14,
                            color: const Color(0xFF6E7E77),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        itemCount: filteredTherapists.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final therapist = filteredTherapists[index];
                          return _buildTherapistCard(therapist);
                        },
                      ),

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

  // Top Dark Green Header
  Widget _buildTopHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 20,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0B4632),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title & Notification Bell Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Therapist Marketplace',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: Colors.white.withValues(alpha: 0.85),
                          size: 15,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Dhaka, Bangladesh',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Bell Button
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Search Bar
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: const Color(0xFF90A4AE),
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14.5,
                      color: Color(0xFF15221D),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search specialists, services...',
                      hintStyle: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: const Color(0xFF90A4AE),
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5EE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    color: const Color(0xFF0B4632),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Category Filter Row
  Widget _buildCategoryRow() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = cat == _selectedCategory;

          return InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _selectedCategory = cat;
              });
            },
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
              child: Text(
                cat,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF52625B),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Filter Controls Row (Verified Switch & List/Map Segment)
  Widget _buildFilterControlsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          // Verified Only Switch
          const Text(
            'Verified Only',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF15221D),
            ),
          ),
          const SizedBox(width: 8),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: _verifiedOnly,
              activeColor: Colors.white,
              activeTrackColor: const Color(0xFF0B4632),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: const Color(0xFFE2E8E5),
              onChanged: (val) {
                HapticFeedback.selectionClick();
                setState(() {
                  _verifiedOnly = val;
                });
              },
            ),
          ),

          const Spacer(),

          // List / Map Toggle Segment
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE2E8E5),
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                _buildSegmentButton('List'),
                _buildSegmentButton('Map'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton(String mode) {
    final isSelected = _viewMode == mode;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _viewMode = mode;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5EE) : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          mode,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? const Color(0xFF0B4632)
                : const Color(0xFF6E7E77),
          ),
        ),
      ),
    );
  }

  // Therapist Practitioner Card
  Widget _buildTherapistCard(Therapist therapist) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    TherapistProfileScreen(therapist: therapist),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOut,
                    ),
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 400),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
          // Top Row: Avatar + Info + Verified Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Image
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E3A2F),
                    image: DecorationImage(
                      image: AssetImage('assets/logo/logo_app.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // Info Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            therapist.name,
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF15221D),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (therapist.isVerified) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8E1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_rounded,
                                  color: Color(0xFFD49E35),
                                  size: 12,
                                ),
                                SizedBox(width: 2),
                                Text(
                                  'Verified',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFD49E35),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 2),

                    Text(
                      therapist.title,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.5,
                        color: Color(0xFF6E7E77),
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Rating & Experience Row
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFD49E35),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${therapist.rating} ',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF15221D),
                          ),
                        ),
                        Text(
                          '(${therapist.reviewsCount} reviews) • ',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: Color(0xFF6E7E77),
                          ),
                        ),
                        Text(
                          therapist.experience,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: Color(0xFF6E7E77),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Container(height: 1, color: const Color(0xFFE2E8E5)),
          const SizedBox(height: 12),

          // Bottom Row: Location/Slot Details & Price
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: const Color(0xFF6E7E77),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${therapist.distance} • ${therapist.languages.join(', ')}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11.5,
                            color: Color(0xFF6E7E77),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: Color(0xFF6E7E77),
                        ),
                        children: [
                          const TextSpan(text: 'Next: '),
                          TextSpan(
                            text: therapist.nextSlot,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF15221D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Price Display
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '৳${therapist.price}',
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF15221D),
                    ),
                  ),
                  const Text(
                    'per session',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: Color(0xFF6E7E77),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
