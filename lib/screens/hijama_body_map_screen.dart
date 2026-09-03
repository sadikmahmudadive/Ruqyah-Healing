import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HijamaPoint {
  final String code;
  final String name;
  final String location;
  final String purpose;
  final String evidence;
  final Offset frontPos;
  final Offset backPos;
  final String status; // 'Active', 'Treated', 'Secondary'

  const HijamaPoint({
    required this.code,
    required this.name,
    required this.location,
    required this.purpose,
    required this.evidence,
    required this.frontPos,
    required this.backPos,
    this.status = 'Active',
  });
}

class HijamaBodyMapScreen extends StatefulWidget {
  const HijamaBodyMapScreen({super.key});

  @override
  State<HijamaBodyMapScreen> createState() => _HijamaBodyMapScreenState();
}

class _HijamaBodyMapScreenState extends State<HijamaBodyMapScreen> {
  String _mode = 'General'; // 'General' or 'Personal'
  String _viewAngle = 'Front'; // 'Front' or 'Back'
  String _selectedBodyArea = 'All Areas';
  String _selectedCondition = 'All Concerns';
  String _activeRecommendation = 'Headaches';
  double _zoomLevel = 1.0;
  bool _isBookmarked = false;

  final List<String> _bodyAreas = const [
    'All Areas',
    'Head & Neck',
    'Upper Back',
    'Lower Back',
    'Legs & Feet',
  ];

  final List<String> _conditions = const [
    'All Concerns',
    'Headaches',
    'Back Pain',
    'Fatigue',
    'Stress Relief',
  ];

  final List<String> _recommendations = const [
    'Headaches',
    'Back Pain',
    'Fatigue',
  ];

  final List<HijamaPoint> _points = const [
    HijamaPoint(
      code: 'GB 43',
      name: 'Al-Kahil',
      location:
          'On the dorsum of the foot, in the depression anterior to the 4th and 5th metatarsal junction.',
      purpose: 'May support headaches, eye strain and tension relief.',
      evidence: 'Traditional use with moderate evidence',
      frontPos: Offset(0.35, 0.85),
      backPos: Offset(0.38, 0.88),
      status: 'Active',
    ),
    HijamaPoint(
      code: 'GV 14',
      name: 'Al-Katah',
      location:
          'Below the spinous process of the 7th cervical vertebra, at the base of the neck.',
      purpose: 'Primary Sunnah point for immune support and detox.',
      evidence: 'High clinical & traditional consensus',
      frontPos: Offset(0.50, 0.18),
      backPos: Offset(0.50, 0.16),
      status: 'Active',
    ),
    HijamaPoint(
      code: 'BL 23',
      name: 'Shenshu',
      location:
          '1.5 cun lateral to the lower border of the spinous process of the 2nd lumbar vertebra.',
      purpose: 'Supports kidney energy, lower back relief, and vitality.',
      evidence: 'Supported by clinical observational studies',
      frontPos: Offset(0.48, 0.48),
      backPos: Offset(0.52, 0.46),
      status: 'Treated',
    ),
    HijamaPoint(
      code: 'BL 13',
      name: 'Feishu',
      location:
          '1.5 cun lateral to the lower border of the spinous process of the 3rd thoracic vertebra.',
      purpose: 'Promotes respiratory wellness and stress relaxation.',
      evidence: 'Moderate evidence base',
      frontPos: Offset(0.42, 0.32),
      backPos: Offset(0.44, 0.30),
      status: 'Secondary',
    ),
  ];

  late HijamaPoint _selectedPoint;

  @override
  void initState() {
    super.initState();
    _selectedPoint = _points[0];
  }

  void _showBodyAreaPicker() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8E5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select Body Area',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF15221D),
              ),
            ),
            const SizedBox(height: 12),
            ..._bodyAreas.map((area) {
              final isSelected = area == _selectedBodyArea;
              return ListTile(
                title: Text(
                  area,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFF0B4632)
                        : const Color(0xFF15221D),
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle_rounded,
                        color: Color(0xFF0B4632))
                    : null,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedBodyArea = area);
                  Navigator.of(context).pop();
                },
              );
            }),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showConditionPicker() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8E5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select Health Concern',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF15221D),
              ),
            ),
            const SizedBox(height: 12),
            ..._conditions.map((cond) {
              final isSelected = cond == _selectedCondition;
              return ListTile(
                title: Text(
                  cond,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFF0B4632)
                        : const Color(0xFF15221D),
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle_rounded,
                        color: Color(0xFF0B4632))
                    : null,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedCondition = cond);
                  Navigator.of(context).pop();
                },
              );
            }),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
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
          title: const Text(
            'Hijama Body Map',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0B4632),
            ),
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
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Sub-Header Filter Segment Controls (General vs Personal | Front vs Back)
              _buildSegmentControlsRow(),

              const SizedBox(height: 16),

              // 2. 3D Human Anatomy Canvas Card
              _buildAnatomyCanvasCard(),

              const SizedBox(height: 16),

              // 3. Dropdown Pickers Row (Body Area & Condition)
              _buildDropdownPickersRow(),

              const SizedBox(height: 20),

              // 4. Condition-Based Recommendations
              _buildConditionRecommendationsSection(),

              const SizedBox(height: 16),

              // 5. Acupoint Detail Card
              _buildPointDetailCard(),

              const SizedBox(height: 16),

              // 6. Professional-Only Disclaimer Banner
              _buildProfessionalDisclaimerBanner(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Sub-Header Filter Segment Controls
  Widget _buildSegmentControlsRow() {
    return Row(
      children: [
        // Mode Segment (General / Personal)
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: const Color(0xFFE8EEEA),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              _buildSegmentPill(
                label: 'General',
                isSelected: _mode == 'General',
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _mode = 'General');
                },
              ),
              _buildSegmentPill(
                label: 'Personal',
                isSelected: _mode == 'Personal',
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _mode = 'Personal');
                },
              ),
            ],
          ),
        ),

        const Spacer(),

        // View Angle Segment (Front / Back)
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: const Color(0xFFE8EEEA),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              _buildSegmentPill(
                label: 'Front',
                isSelected: _viewAngle == 'Front',
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _viewAngle = 'Front');
                },
              ),
              _buildSegmentPill(
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
      ],
    );
  }

  Widget _buildSegmentPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0B4632) : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF52625B),
          ),
        ),
      ),
    );
  }

  // 2. 3D Human Anatomy Canvas Card
  Widget _buildAnatomyCanvasCard() {
    return Container(
      height: 310,
      width: double.infinity,
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
        children: [
          // Anatomy Body Graphic Background Representation
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Front Body View
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Opacity(
                        opacity: _viewAngle == 'Front' ? 1.0 : 0.40,
                        child: CustomPaint(
                          size: const Size(120, 260),
                          painter: _HumanBodyAnatomyPainter(isBack: false),
                        ),
                      ),
                      // Interactive Points Overlay on Front
                      ..._points.map((pt) {
                        final isSelected = pt == _selectedPoint;
                        return Positioned(
                          left: 120 * pt.frontPos.dx,
                          top: 260 * pt.frontPos.dy,
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedPoint = pt);
                            },
                            child: _buildPointDot(pt, isSelected),
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                // Back Body View
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Opacity(
                        opacity: _viewAngle == 'Back' ? 1.0 : 0.40,
                        child: CustomPaint(
                          size: const Size(120, 260),
                          painter: _HumanBodyAnatomyPainter(isBack: true),
                        ),
                      ),
                      // Interactive Points Overlay on Back
                      ..._points.map((pt) {
                        final isSelected = pt == _selectedPoint;
                        return Positioned(
                          left: 120 * pt.backPos.dx,
                          top: 260 * pt.backPos.dy,
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedPoint = pt);
                            },
                            child: _buildPointDot(pt, isSelected),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Zoom Controls (Top Left)
          Positioned(
            left: 14,
            top: 14,
            child: Column(
              children: [
                _buildZoomButton(
                  icon: Icons.add_rounded,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _zoomLevel = (_zoomLevel + 0.2).clamp(1.0, 2.0));
                  },
                ),
                const SizedBox(height: 6),
                _buildZoomButton(
                  icon: Icons.remove_rounded,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _zoomLevel = (_zoomLevel - 0.2).clamp(1.0, 2.0));
                  },
                ),
              ],
            ),
          ),

          // Bottom Left Legend Overlay Card
          Positioned(
            left: 14,
            bottom: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE2E8E5),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  _LegendItem(
                    color: Color(0xFF0B4632),
                    label: 'Active Point',
                  ),
                  SizedBox(height: 4),
                  _LegendItem(
                    color: Color(0xFFD49E35),
                    label: 'Previously Treated',
                  ),
                  SizedBox(height: 4),
                  _LegendItem(
                    color: Color(0xFF2ECC71),
                    label: 'Secondary',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointDot(HijamaPoint pt, bool isSelected) {
    final Color dotColor = pt.status == 'Active'
        ? const Color(0xFF0B4632)
        : pt.status == 'Treated'
            ? const Color(0xFFD49E35)
            : const Color(0xFF2ECC71);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isSelected ? 18 : 12,
      height: isSelected ? 18 : 12,
      decoration: BoxDecoration(
        color: dotColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: isSelected ? 2.5 : 1.5,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: dotColor.withValues(alpha: 0.50),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
    );
  }

  Widget _buildZoomButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8E5), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF15221D), size: 18),
      ),
    );
  }

  // 3. Dropdown Pickers Row
  Widget _buildDropdownPickersRow() {
    return Row(
      children: [
        Expanded(
          child: _buildPickerCard(
            label: 'Body Area',
            value: _selectedBodyArea,
            onTap: _showBodyAreaPicker,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildPickerCard(
            label: 'Condition',
            value: _selectedCondition,
            onTap: _showConditionPicker,
          ),
        ),
      ],
    );
  }

  Widget _buildPickerCard({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: Color(0xFF90A4AE),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF15221D),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF6E7E77),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // 4. Condition-Based Recommendations
  Widget _buildConditionRecommendationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Condition-Based Recommendations',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 15.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0B4632),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: _recommendations.map((rec) {
            final isSelected = rec == _activeRecommendation;
            return Container(
              margin: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _activeRecommendation = rec);
                },
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBF7F0),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF0B4632)
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    rec,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12.5,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: const Color(0xFF0B4632),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // 5. Acupoint Detail Card
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
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF0B4632),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${pt.name} (${pt.code})',
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0B4632),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _isBookmarked = !_isBookmarked);
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(6),
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

          const SizedBox(height: 14),

          // LOCATION Section
          const Text(
            'LOCATION',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: Color(0xFF90A4AE),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            pt.location,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.5,
              color: Color(0xFF6E7E77),
              height: 1.38,
            ),
          ),

          const SizedBox(height: 12),

          // PURPOSE Section
          const Text(
            'PURPOSE',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: Color(0xFF90A4AE),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            pt.purpose,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.5,
              color: Color(0xFF6E7E77),
              height: 1.38,
            ),
          ),

          const SizedBox(height: 14),
          Container(height: 1, color: const Color(0xFFE2E8E5)),
          const SizedBox(height: 12),

          // EVIDENCE Section
          Row(
            children: [
              const Text(
                'EVIDENCE',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: Color(0xFF90A4AE),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  pt.evidence,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0B4632),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 6. Professional-Only Disclaimer Banner
  Widget _buildProfessionalDisclaimerBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF7F0).withValues(alpha: 0.80),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF0B4632).withValues(alpha: 0.15),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFFE2E8E5),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'i',
                style: TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0B4632),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Professional-Only: App does not provide instructions for invasive procedures. Clinical use only - consult a qualified therapist.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11.5,
                color: Color(0xFF52625B),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF15221D),
          ),
        ),
      ],
    );
  }
}

// 3D Human Anatomy Vector Silhouette CustomPainter
class _HumanBodyAnatomyPainter extends CustomPainter {
  final bool isBack;

  _HumanBodyAnatomyPainter({required this.isBack});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB0BEC5).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = const Color(0xFFE2E8E5).withValues(alpha: 0.40)
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2;

    final Path bodyPath = Path()
      // Head
      ..addOval(Rect.fromCircle(
          center: Offset(centerX, size.height * 0.10), radius: 16))
      // Neck & Shoulders
      ..moveTo(centerX - 6, size.height * 0.16)
      ..lineTo(centerX - 28, size.height * 0.22)
      // Left Arm
      ..lineTo(centerX - 36, size.height * 0.48)
      ..lineTo(centerX - 30, size.height * 0.48)
      ..lineTo(centerX - 20, size.height * 0.32)
      // Left Torso & Leg
      ..lineTo(centerX - 18, size.height * 0.58)
      ..lineTo(centerX - 12, size.height * 0.90)
      ..lineTo(centerX - 2, size.height * 0.90)
      // Center Crotch
      ..lineTo(centerX, size.height * 0.58)
      // Right Leg
      ..lineTo(centerX + 2, size.height * 0.90)
      ..lineTo(centerX + 12, size.height * 0.90)
      ..lineTo(centerX + 18, size.height * 0.58)
      // Right Arm
      ..lineTo(centerX + 20, size.height * 0.32)
      ..lineTo(centerX + 30, size.height * 0.48)
      ..lineTo(centerX + 36, size.height * 0.48)
      ..lineTo(centerX + 28, size.height * 0.22)
      ..lineTo(centerX + 6, size.height * 0.16)
      ..close();

    canvas.drawPath(bodyPath, fillPaint);
    canvas.drawPath(bodyPath, paint);
  }

  @override
  bool shouldRepaint(covariant _HumanBodyAnatomyPainter oldDelegate) => false;
}
