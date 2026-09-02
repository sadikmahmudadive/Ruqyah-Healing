import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StoreProduct {
  final String id;
  final String title;
  final String subtitle;
  final double price;
  final double rating;
  final int reviewsCount;
  final bool isApproved;
  final String? badgeText;
  final String imagePath;
  final String category;

  const StoreProduct({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.rating,
    this.reviewsCount = 0,
    this.isApproved = true,
    this.badgeText,
    required this.imagePath,
    required this.category,
  });
}

class EquipmentStoreScreen extends StatefulWidget {
  const EquipmentStoreScreen({super.key});

  @override
  State<EquipmentStoreScreen> createState() => _EquipmentStoreScreenState();
}

class _EquipmentStoreScreenState extends State<EquipmentStoreScreen> {
  String _selectedCategory = 'Cups';
  int _cartCount = 2;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = const [
    'Cups',
    'Pumps',
    'Oils',
    'Herbal Kits',
    'Accessories',
  ];

  final StoreProduct _featuredProduct = const StoreProduct(
    id: 'prod_feat',
    title: 'Sterile Hijama Kit (Professional)',
    subtitle: 'Complete set for safe & hygienic practice',
    price: 89.99,
    rating: 4.9,
    reviewsCount: 178,
    isApproved: true,
    badgeText: '🔥 Best Seller',
    imagePath: 'assets/logo/logo_app.png',
    category: 'Kits',
  );

  final List<StoreProduct> _topPicks = const [
    StoreProduct(
      id: 'prod_1',
      title: 'Silicone Cups Set (12pcs)',
      subtitle: 'High quality medical grade',
      price: 34.99,
      rating: 4.8,
      isApproved: true,
      imagePath: 'assets/logo/logo_app.png',
      category: 'Cups',
    ),
    StoreProduct(
      id: 'prod_2',
      title: 'Manual Vacuum Pump',
      subtitle: 'Durable & easy to use',
      price: 24.99,
      rating: 4.7,
      isApproved: false,
      imagePath: 'assets/logo/logo_app.png',
      category: 'Pumps',
    ),
    StoreProduct(
      id: 'prod_3',
      title: 'Black Seed Oil (125ml)',
      subtitle: 'Pure & cold pressed',
      price: 16.99,
      rating: 4.9,
      isApproved: true,
      imagePath: 'assets/logo/logo_app.png',
      category: 'Oils',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addToCart(String itemTitle) {
    HapticFeedback.selectionClick();
    setState(() {
      _cartCount++;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$itemTitle added to cart'),
        backgroundColor: const Color(0xFF0B4632),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
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
                    // Search Bar
                    _buildSearchBar(),

                    const SizedBox(height: 14),

                    // Category Filter Pills
                    _buildCategoryRow(),

                    const SizedBox(height: 20),

                    // Featured Section
                    _buildFeaturedSection(),

                    const SizedBox(height: 24),

                    // Top Picks Section
                    _buildTopPicksSection(),

                    const SizedBox(height: 24),

                    // Affiliate Disclaimer Banner
                    _buildDisclaimerBanner(),

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
        color: Color(0xFF0B4632),
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
                  'Store',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD49E35),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Quality tools for safe practice.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFD49E35),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD49E35),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Shopping Cart Bag Icon Button with Badge
          Stack(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                  },
                ),
              ),
              if (_cartCount > 0)
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE74C3C),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$_cartCount',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Search Input Bar
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
                hintText: 'Search products...',
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Filter',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6E7E77),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Category Filter Pills Row
  Widget _buildCategoryRow() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
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
                  cat,
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

  // Featured Section
  Widget _buildFeaturedSection() {
    final p = _featuredProduct;

    return Column(
      children: [
        Row(
          children: [
            const Text(
              'Featured',
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
              child: const Row(
                children: [
                  Text(
                    'See all',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0B4632),
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFF0B4632),
                    size: 14,
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Featured Card Container
        Container(
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
          child: Column(
            children: [
              // Top Row: Image Thumbnail + Details
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: 95,
                      height: 95,
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

                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (p.badgeText != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEBEB),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              p.badgeText!,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFE74C3C),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],
                        Text(
                          'Tk ${p.price}',
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF15221D),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          p.title,
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF15221D),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          p.subtitle,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11.5,
                            color: Color(0xFF6E7E77),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Approved Wellness Product Banner
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFFD49E35),
                      size: 15,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Approved Wellness Product',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFD49E35),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Rating & Cart Button Row
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFD49E35),
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${p.rating} ',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF15221D),
                    ),
                  ),
                  Text(
                    '(${p.reviewsCount} reviews)',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Color(0xFF6E7E77),
                    ),
                  ),
                  const Spacer(),

                  // Add to Cart Button
                  GestureDetector(
                    onTap: () => _addToCart(p.title),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0B4632),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shopping_cart_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Top Picks Section
  Widget _buildTopPicksSection() {
    return Column(
      children: [
        Row(
          children: [
            const Text(
              'Top Picks',
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
              child: const Row(
                children: [
                  Text(
                    'See all',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0B4632),
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFF0B4632),
                    size: 14,
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Product Cards List
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: _topPicks.length,
          separatorBuilder: (context, index) => const SizedBox(width: 0, height: 12),
          itemBuilder: (context, index) {
            final p = _topPicks[index];
            return _buildTopPickCard(p);
          },
        ),
      ],
    );
  }

  Widget _buildTopPickCard(StoreProduct p) {
    return Container(
      padding: const EdgeInsets.all(14),
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
          // Image Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 72,
              height: 72,
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

          // Details Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.title,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF15221D),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  p.subtitle,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.5,
                    color: Color(0xFF6E7E77),
                  ),
                ),
                if (p.isApproved) ...[
                  const SizedBox(height: 4),
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
                          size: 11,
                        ),
                        SizedBox(width: 3),
                        Text(
                          'Approved Wellness Product',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFD49E35),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      'Tk ${p.price}',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF15221D),
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFD49E35),
                      size: 15,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${p.rating}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF15221D),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Add Button
                    GestureDetector(
                      onTap: () => _addToCart(p.title),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0B4632),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Affiliate Disclaimer Banner
  Widget _buildDisclaimerBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7F6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8E5), width: 1.0),
      ),
      child: const Row(
        children: [
          Text('🌙', style: TextStyle(fontSize: 13)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Affiliate store disclaimer: Sales support our free Ruqyah support line.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11.5,
                color: Color(0xFF90A4AE),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
