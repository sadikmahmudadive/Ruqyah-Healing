import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_gradients.dart';
import '../widgets/global_bottom_navbar.dart';
import 'therapist_marketplace_screen.dart';

class Acupoint {
  final String code;
  final String name;
  final String meridian;
  final String location;
  final String commonUse;
  final String evidence;
  final String safetyNotice;
  final Offset frontPos;
  final Offset backPos;

  const Acupoint({
    required this.code,
    required this.name,
    required this.meridian,
    required this.location,
    required this.commonUse,
    required this.evidence,
    required this.safetyNotice,
    required this.frontPos,
    required this.backPos,
  });
}

class AcupuncturePointMapScreen extends StatefulWidget {
  const AcupuncturePointMapScreen({super.key});

  @override
  State<AcupuncturePointMapScreen> createState() =>
      _AcupuncturePointMapScreenState();
}

class _AcupuncturePointMapScreenState
    extends State<AcupuncturePointMapScreen> {
  String _viewAngle = 'Front'; // 'Front' or 'Back'
  String _selectedMeridian = 'Lung (LU)';
  bool _isBookmarked = false;

  final List<String> _meridians = const [
    'All',
    'Lung (LU)',
    'L. Intest.',
    'Stomach',
    'Spleen',
    'Heart',
    'Kidney',
    'Others',
  ];

  final List<Acupoint> _points = const [
    Acupoint(
      code: 'LI4',
      name: 'Hegu',
      meridian: 'Large Intestine 4',
      location:
          'On the back of the hand, between the thumb and index finger.',
      commonUse:
          'May help with headaches, facial pain, stress and pain relief.',
      evidence: 'Moderate',
      safetyNotice:
          'Not recommended during pregnancy. Always consult a qualified practitioner.',
      frontPos: Offset(0.38, 0.22),
      backPos: Offset(0.40, 0.24),
    ),
    Acupoint(
      code: 'LU7',
      name: 'Lieque',
      meridian: 'Lung 7',
      location:
          '1.5 cun proximal to the wrist crease, above the styloid process of the radius.',
      commonUse: 'Supports respiratory function and neck stiffness relief.',
      evidence: 'High',
      safetyNotice:
          'Avoid deep insertion. Seek guidance from a certified practitioner.',
      frontPos: Offset(0.32, 0.35),
      backPos: Offset(0.34, 0.36),
    ),
    Acupoint(
      code: 'ST36',
      name: 'Zusanli',
      location: '3 cun below the knee, one finger-breadth lateral to the tibia.',
      commonUse: 'Boosts energy, digestive harmony, and overall immunity.',
      evidence: 'Strong',
      safetyNotice: 'Clinical use only - consult a verified acupuncturist.',
      frontPos: Offset(0.42, 0.72),
      backPos: Offset(0.44, 0.74),
    ),
  ];

  late Acupoint _selectedPoint;

  @override
  void initState() {
    super.initState();
    _selectedPoint = _points[0];
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F6),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5F7F6),
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8E5), width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Color(0xFF15221D),
                  size: 20,
                ),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
          centerTitle: true,
          title: Column(
            children: const [
              Text(
                'Acupuncture Point Map',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF15221D),
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Lung (LU) Meridian • 11 Points',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: Color(0xFF6E7E77),
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0, top: 8.0, bottom: 8.0),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E8E5), width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFF0B4632),
                    size: 20,
                  ),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                  },
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
          toolbarHeight: 68,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Sub-Header View Controls Row (View Label, Front/Back Toggle, Refresh Button)
              _buildViewControlsRow(),

              const SizedBox(height: 16),

              // 2. Meridian Sidebar + 3D Meridian Body Map Canvas Row
              _buildMeridianMapCanvasRow(),

              const SizedBox(height: 20),

              // 3. Acupoint Detail Card
              _buildPointDetailCard(),

              const SizedBox(height: 24),
            ],
          ),
        ),
        bottomNavigationBar: const GlobalBottomNavbar(
          selectedIndex: 1, // Services tab
        ),
      ),
    );
  }

  // 1. Sub-Header View Controls Row
  Widget _buildViewControlsRow() {
    return Row(
      children: [
        const Text(
          'View',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF6E7E77),
          ),
        ),

        const SizedBox(width: 14),

        // Front / Back Toggle Segment
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: const Color(0xFFE8EEEA),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              _buildViewPill(
                label: 'Front',
                isSelected: _viewAngle == 'Front',
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _viewAngle = 'Front');
                },
              ),
              _buildViewPill(
                label: 'Back',
                isSelected: _viewAngle == 'Back',
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _viewAngle = 'Back');
                },
              ),
            ],
          ),
        ),

        const Spacer(),

        // Refresh / Reset View Button
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8E5), width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(
              Icons.rotate_right_rounded,
              color: Color(0xFF15221D),
              size: 20,
            ),
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(() => _viewAngle = 'Front');
            },
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Widget _buildViewPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0B4632) : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF52625B),
          ),
        ),
      ),
    );
  }

  // 2. Meridian Sidebar + 3D Meridian Body Map Canvas Row
  Widget _buildMeridianMapCanvasRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Meridian Sidebar
        Container(
          width: 105,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
              const Padding(
                padding: EdgeInsets.only(left: 6.0, bottom: 8.0),
                child: Text(
                  'MERIDIAN',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: Color(0xFF90A4AE),
                  ),
                ),
              ),

              ..._meridians.map((m) {
                final isSelected = m == _selectedMeridian;

                return InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedMeridian = m);
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 4.0),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF0B4632)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      m,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF52625B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // Right 3D Meridian Body Canvas Card
        Expanded(
          child: Container(
            height: 350,
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
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 3D Human Body Anatomy with Meridian Channel Lines
                CustomPaint(
                  size: const Size(160, 320),
                  painter: _MeridianAnatomyPainter(isBack: _viewAngle == 'Back'),
                ),

                // Acupoint Markers Overlay
                ..._points.map((pt) {
                  final pos = _viewAngle == 'Back' ? pt.backPos : pt.frontPos;
                  final isSelected = pt == _selectedPoint;

                  return Positioned(
                    left: 160 * pos.dx,
                    top: 320 * pos.dy,
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedPoint = pt);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected) ...[
                            // Tag Tooltip
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF15221D),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                pt.code,
                                style: const TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                          ],

                          // Marker Circle
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: isSelected ? 22 : 14,
                            height: isSelected ? 22 : 14,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0B4632),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFD49E35),
                                width: isSelected ? 3.0 : 2.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0B4632)
                                      .withValues(alpha: 0.50),
                                  blurRadius: isSelected ? 12 : 6,
                                ),
                              ],
                            ),
                            child: isSelected
                                ? Center(
                                    child: Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFD49E35),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 3. Acupoint Detail Card
  Widget _buildPointDetailCard() {
    final pt = _selectedPoint;

    return Container(
      padding: const EdgeInsets.all(18),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFF0B4632),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD49E35),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${pt.code} ${pt.name}',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0B4632),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      pt.meridian,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Color(0xFF90A4AE),
                      ),
                    ),
                  ],
                ),
              ),

              InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _isBookmarked = !_isBookmarked);
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _isBookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_outline_rounded,
                    color: const Color(0xFFD49E35),
                    size: 18,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // LOCATION Row
          _buildDetailPillRow(
            label: 'LOCATION',
            value: pt.location,
          ),

          const SizedBox(height: 12),

          // COMMON USE Row
          _buildDetailPillRow(
            label: 'COMMON USE',
            value: pt.commonUse,
          ),

          const SizedBox(height: 12),

          // EVIDENCE Row
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF7F0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'EVIDENCE',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: Color(0xFF0B4632),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  pt.evidence,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFD49E35),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Safety Notice Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFD49E35).withValues(alpha: 0.30),
                width: 1.0,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFD49E35),
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Safety Notice',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFB78103),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        pt.safetyNotice,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11.5,
                          color: Color(0xFFB78103),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Primary Button: Consult a Verified Practitioner
          Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              gradient: AppGradients.greenButtonGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF082F21).withValues(alpha: 0.30),
                  offset: const Offset(0, 6),
                  blurRadius: 18,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.heavyImpact();
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) =>
                          const TherapistMarketplaceScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(18),
                splashColor: Colors.white.withValues(alpha: 0.15),
                child: const Center(
                  child: Text(
                    'Consult a Verified Practitioner',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailPillRow({
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFEBF7F0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: Color(0xFF0B4632),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.5,
              color: Color(0xFF6E7E77),
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

// CustomPainter for 3D Anatomy Figure with Glowing Meridian Channels
class _MeridianAnatomyPainter extends CustomPainter {
  final bool isBack;

  const _MeridianAnatomyPainter({required this.isBack});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final w = size.width;
    final h = size.height;

    // Body Fill Paint
    final Paint bodyFillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isBack
            ? [const Color(0xFFD6E2DD), const Color(0xFFB5C8C1)]
            : [const Color(0xFFE4EDE9), const Color(0xFFC2D4CD)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    // Outer Line Paint
    final Paint outlinePaint = Paint()
      ..color = const Color(0xFF425E57)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    // Glowing Green Meridian Lines Paint
    final Paint meridianPaint = Paint()
      ..color = const Color(0xFF2ECC71).withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Head
    final Path headPath = Path()
      ..addOval(
          Rect.fromCircle(center: Offset(centerX, h * 0.10), radius: w * 0.12));

    // Torso & Limbs
    final Path torsoPath = Path()
      ..moveTo(centerX - w * 0.08, h * 0.18)
      ..quadraticBezierTo(
          centerX - w * 0.28, h * 0.19, centerX - w * 0.32, h * 0.23)
      ..cubicTo(centerX - w * 0.38, h * 0.35, centerX - w * 0.40, h * 0.45,
          centerX - w * 0.38, h * 0.52)
      ..cubicTo(centerX - w * 0.33, h * 0.52, centerX - w * 0.30, h * 0.45,
          centerX - w * 0.26, h * 0.34)
      ..quadraticBezierTo(
          centerX - w * 0.20, h * 0.42, centerX - w * 0.18, h * 0.52)
      ..cubicTo(centerX - w * 0.22, h * 0.65, centerX - w * 0.16, h * 0.78,
          centerX - w * 0.12, h * 0.92)
      ..lineTo(centerX - w * 0.03, h * 0.92)
      ..quadraticBezierTo(
          centerX - w * 0.06, h * 0.75, centerX - w * 0.01, h * 0.55)
      ..lineTo(centerX + w * 0.01, h * 0.55)
      ..quadraticBezierTo(
          centerX + w * 0.06, h * 0.75, centerX + w * 0.03, h * 0.92)
      ..lineTo(centerX + w * 0.12, h * 0.92)
      ..cubicTo(centerX + w * 0.16, h * 0.78, centerX + w * 0.22, h * 0.65,
          centerX + w * 0.18, h * 0.52)
      ..quadraticBezierTo(
          centerX + w * 0.20, h * 0.42, centerX + w * 0.26, h * 0.34)
      ..cubicTo(centerX + w * 0.30, h * 0.45, centerX + w * 0.33, h * 0.52,
          centerX + w * 0.38, h * 0.52)
      ..cubicTo(centerX + w * 0.40, h * 0.45, centerX + w * 0.38, h * 0.35,
          centerX + w * 0.32, h * 0.23)
      ..quadraticBezierTo(
          centerX + w * 0.28, h * 0.19, centerX + w * 0.08, h * 0.18)
      ..close();

    canvas.drawPath(headPath, bodyFillPaint);
    canvas.drawPath(headPath, outlinePaint);

    canvas.drawPath(torsoPath, bodyFillPaint);
    canvas.drawPath(torsoPath, outlinePaint);

    // Glowing Meridian Channel Lines
    final Path meridianLineLeft = Path()
      ..moveTo(centerX - w * 0.10, h * 0.18)
      ..lineTo(centerX - w * 0.28, h * 0.23)
      ..lineTo(centerX - w * 0.34, h * 0.38)
      ..lineTo(centerX - w * 0.36, h * 0.50);

    final Path meridianLineRight = Path()
      ..moveTo(centerX + w * 0.10, h * 0.18)
      ..lineTo(centerX + w * 0.28, h * 0.23)
      ..lineTo(centerX + w * 0.34, h * 0.38)
      ..lineTo(centerX + w * 0.36, h * 0.50);

    final Path meridianLineCenter = Path()
      ..moveTo(centerX, h * 0.10)
      ..lineTo(centerX, h * 0.90);

    canvas.drawPath(meridianLineLeft, meridianPaint);
    canvas.drawPath(meridianLineRight, meridianPaint);
    canvas.drawPath(meridianLineCenter, meridianPaint);
  }

  @override
  bool shouldRepaint(covariant _MeridianAnatomyPainter oldDelegate) =>
      oldDelegate.isBack != isBack;
}
