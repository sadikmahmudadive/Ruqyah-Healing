import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/app_toast.dart';
import '../widgets/hijama_cupping_icon.dart';

class HijamaSessionDetailScreen extends StatefulWidget {
  const HijamaSessionDetailScreen({super.key});

  @override
  State<HijamaSessionDetailScreen> createState() =>
      _HijamaSessionDetailScreenState();
}

class _HijamaSessionDetailScreenState extends State<HijamaSessionDetailScreen> {
  final List<String> _supplies = const [
    'Cups (Various Sizes)',
    'Sterile Lancets',
    'Alcohol Swabs',
    'Gloves',
    'Gauze & Cotton',
  ];

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
                'Session Detail & Log',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF15221D),
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Wet Cupping • May 20, 2024',
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
                    Icons.more_horiz_rounded,
                    color: Color(0xFF15221D),
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
              // 1. Practitioner Info Card
              _buildPractitionerCard(),

              const SizedBox(height: 14),

              // 2. Date, Time & Status Bento Row
              _buildDateTimeStatusRow(),

              const SizedBox(height: 14),

              // 3. Procedure Type Card
              _buildProcedureTypeCard(),

              const SizedBox(height: 14),

              // 4. Treated Points Anatomy Card
              _buildTreatedPointsCard(),

              const SizedBox(height: 14),

              // 5. Blood Volume Record Card
              _buildBloodVolumeCard(),

              const SizedBox(height: 14),

              // 6. Supplies Checklist Card
              _buildSuppliesCard(),

              const SizedBox(height: 14),

              // 7. Session Notes Card
              _buildSessionNotesCard(),

              const SizedBox(height: 14),

              // 8. Before & After Photos Card
              _buildBeforeAfterPhotosCard(),

              const SizedBox(height: 14),

              // 9. Clinical Report Card
              _buildClinicalReportCard(),

              const SizedBox(height: 14),

              // 10. Amount Input Card
              _buildAmountInputCard(),

              const SizedBox(height: 14),

              // 11. Quick Action Bento Cards Row
              _buildActionBentoRow(),

              const SizedBox(height: 14),

              // 12. Scheduled Follow-up Banner Card
              _buildScheduledFollowUpBanner(),

              const SizedBox(height: 14),

              // 13. Professional Disclaimer Banner
              _buildProfessionalDisclaimerBanner(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Practitioner Info Card
  Widget _buildPractitionerCard() {
    return Container(
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
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 52,
              height: 52,
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

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dr. Saifur Rahman',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF15221D),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Ruqyah & Hijama Specialist',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Color(0xFF6E7E77),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: const [
                    Icon(
                      Icons.star_rounded,
                      color: Color(0xFFD49E35),
                      size: 15,
                    ),
                    SizedBox(width: 3),
                    Text(
                      '4.9 ',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF15221D),
                      ),
                    ),
                    Text(
                      '(126 sessions)',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11.5,
                        color: Color(0xFF90A4AE),
                      ),
                    ),
                  ],
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
                Icons.phone_outlined,
                color: Color(0xFF0B4632),
                size: 20,
              ),
              onPressed: () {
                HapticFeedback.selectionClick();
              },
            ),
          ),
        ],
      ),
    );
  }

  // 2. Date, Time & Status Bento Row
  Widget _buildDateTimeStatusRow() {
    return Row(
      children: [
        // Date Box
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DATE',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF90A4AE),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'May 20, 2024',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF15221D),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 10),

        // Time Box
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TIME',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF90A4AE),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '10:30 AM',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF15221D),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 10),

        // Status Box
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEBF7F0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STATUS',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0B4632),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Completed',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0B4632),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 3. Procedure Type Card
  Widget _buildProcedureTypeCard() {
    return Container(
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
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEBF7F0),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: HijamaCuppingIcon(
                color: Color(0xFF0B4632),
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
                  'PROCEDURE TYPE',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: Color(0xFF90A4AE),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Wet Cupping (Hijama)',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF15221D),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Detox & Relief Plan • 6 cups applied',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.5,
                    color: Color(0xFF6E7E77),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 4. Treated Points Anatomy Card
  Widget _buildTreatedPointsCard() {
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
            children: const [
              Text(
                'Treated Points',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF15221D),
                ),
              ),
              Spacer(),
              Text(
                '6 Points',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFD49E35),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Legend
          Row(
            children: const [
              _DotLegend(color: Color(0xFF0B4632), label: 'Primary'),
              SizedBox(width: 14),
              _DotLegend(color: Color(0xFF2ECC71), label: 'Secondary'),
              SizedBox(width: 14),
              _DotLegend(color: Color(0xFFD49E35), label: 'Previous'),
            ],
          ),

          const SizedBox(height: 16),

          // Miniature Body Silhouettes (Front & Back)
          Container(
            height: 180,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7F6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Front Body View with Points
                Stack(
                  alignment: Alignment.center,
                  children: const [
                    CustomPaint(
                      size: Size(80, 150),
                      painter: _MiniAnatomyPainter(isBack: false),
                    ),
                    Positioned(
                        top: 30,
                        left: 20,
                        child: _PointDot(color: Color(0xFF0B4632))),
                    Positioned(
                        top: 55,
                        right: 18,
                        child: _PointDot(color: Color(0xFF2ECC71))),
                    Positioned(
                        bottom: 40,
                        left: 15,
                        child: _PointDot(color: Color(0xFFD49E35))),
                  ],
                ),

                // Back Body View with Points
                Stack(
                  alignment: Alignment.center,
                  children: const [
                    CustomPaint(
                      size: Size(80, 150),
                      painter: _MiniAnatomyPainter(isBack: true),
                    ),
                    Positioned(
                        top: 25,
                        right: 22,
                        child: _PointDot(color: Color(0xFF0B4632))),
                    Positioned(
                        top: 45,
                        left: 20,
                        child: _PointDot(color: Color(0xFF0B4632))),
                    Positioned(
                        bottom: 50,
                        right: 18,
                        child: _PointDot(color: Color(0xFFD49E35))),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),
          Container(height: 1, color: const Color(0xFFE2E8E5)),
          const SizedBox(height: 12),

          // Consent Signed Row
          Row(
            children: const [
              Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF0B4632),
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'Consent',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: Color(0xFF6E7E77),
                ),
              ),
              Spacer(),
              Text(
                'Signed',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF15221D),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 5. Blood Volume Record Card
  Widget _buildBloodVolumeCard() {
    return Container(
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
          const Text(
            'Blood Volume Record',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF15221D),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              _buildStatBox(label: 'VOLUME', value: '45 ml'),
              const SizedBox(width: 10),
              _buildStatBox(label: 'COLOR', value: 'Dark Red'),
              const SizedBox(width: 10),
              _buildStatBox(label: 'CUPS', value: '6'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox({required String label, required String value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7F6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF90A4AE),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF15221D),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 6. Supplies Checklist Card
  Widget _buildSuppliesCard() {
    return Container(
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
          const Text(
            'Supplies (Sterile & Single Use)',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF15221D),
            ),
          ),

          const SizedBox(height: 12),

          ..._supplies.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF0B4632),
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    item,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: Color(0xFF52625B),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // 7. Session Notes Card
  Widget _buildSessionNotesCard() {
    return Container(
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
        children: const [
          Text(
            'Session Notes',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF15221D),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Well tolerated. Moderate cups used on upper back and shoulders. Good response noted. Patient reported relief post-session.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: Color(0xFF6E7E77),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // 8. Before & After Photos Card
  Widget _buildBeforeAfterPhotosCard() {
    return Container(
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
          const Text(
            'Before & After',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF15221D),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 110,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7F6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.camera_alt_outlined,
                          color: Color(0xFFB0BEC5),
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Before',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Color(0xFF6E7E77),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 110,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7F6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.camera_alt_outlined,
                          color: Color(0xFFB0BEC5),
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'After',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Color(0xFF6E7E77),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          const Row(
            children: [
              Icon(
                Icons.photo_library_outlined,
                color: Color(0xFF90A4AE),
                size: 16,
              ),
              SizedBox(width: 6),
              Text(
                '2 photos attached to this session',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: Color(0xFF6E7E77),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 9. Clinical Report Card
  Widget _buildClinicalReportCard() {
    return Container(
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
        children: [
          Row(
            children: [
              const Text(
                'Clinical Report',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF15221D),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  AppToast.show(
                    context,
                    title: 'Downloading Report',
                    message: 'Clinical session report PDF is downloading.',
                    type: ToastType.info,
                  );
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBF7F0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Download PDF',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0B4632),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: const [
              Text(
                'Aftercare Provided',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12.5,
                  color: Color(0xFF6E7E77),
                ),
              ),
              Spacer(),
              Text(
                'Yes – Guidance shared',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF15221D),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: const [
              Text(
                'Plan Type',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12.5,
                  color: Color(0xFF6E7E77),
                ),
              ),
              Spacer(),
              Text(
                'Detox & Relief',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF15221D),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Container(height: 1, color: const Color(0xFFE2E8E5)),
          const SizedBox(height: 12),

          Row(
            children: const [
              Text(
                'Total Cost',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF15221D),
                ),
              ),
              Spacer(),
              Text(
                '150 USD',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF15221D),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 10. Amount Input Card
  Widget _buildAmountInputCard() {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Amount (Optional)',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF15221D),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7F6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: const [
                Expanded(
                  child: Text(
                    '150',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF15221D),
                    ),
                  ),
                ),
                Text(
                  'USD',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF90A4AE),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 11. Quick Action Bento Cards Row
  Widget _buildActionBentoRow() {
    return Row(
      children: [
        // Aftercare Provided
        Expanded(
          child: _buildBentoCard(
            icon: Icons.description_outlined,
            title: 'Aftercare Provided',
            subtitle: 'Guidance shared',
          ),
        ),
        const SizedBox(width: 12),
        // Photos
        Expanded(
          child: _buildBentoCard(
            icon: Icons.camera_alt_outlined,
            title: 'Photos',
            subtitle: '2 photos',
          ),
        ),
      ],
    );
  }

  Widget _buildBentoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFEBF7F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF0B4632), size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF15221D),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: Color(0xFF90A4AE),
            ),
          ),
        ],
      ),
    );
  }

  // 12. Scheduled Follow-up Banner Card
  Widget _buildScheduledFollowUpBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF7F0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF0B4632).withValues(alpha: 0.20),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFF0B4632),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scheduled Follow–up',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0B4632),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Check-in on May 22, 2024',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.5,
                    color: Color(0xFF52625B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 13. Professional Disclaimer Banner
  Widget _buildProfessionalDisclaimerBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE74C3C).withValues(alpha: 0.20),
          width: 1.0,
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFE74C3C),
            size: 18,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Professional-Only: App does not provide instructions for invasive procedures.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11.5,
                color: Color(0xFFC0392B),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DotLegend extends StatelessWidget {
  final Color color;
  final String label;

  const _DotLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF52625B),
          ),
        ),
      ],
    );
  }
}

class _PointDot extends StatelessWidget {
  final Color color;

  const _PointDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.40),
            blurRadius: 6,
          ),
        ],
      ),
    );
  }
}

class _MiniAnatomyPainter extends CustomPainter {
  final bool isBack;

  const _MiniAnatomyPainter({required this.isBack});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB0BEC5).withValues(alpha: 0.30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final fillPaint = Paint()
      ..color = const Color(0xFFE2E8E5).withValues(alpha: 0.40)
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2;

    final Path bodyPath = Path()
      ..addOval(Rect.fromCircle(
          center: Offset(centerX, size.height * 0.12), radius: 10))
      ..moveTo(centerX - 4, size.height * 0.18)
      ..lineTo(centerX - 18, size.height * 0.24)
      ..lineTo(centerX - 22, size.height * 0.48)
      ..lineTo(centerX - 18, size.height * 0.48)
      ..lineTo(centerX - 12, size.height * 0.32)
      ..lineTo(centerX - 10, size.height * 0.58)
      ..lineTo(centerX - 8, size.height * 0.90)
      ..lineTo(centerX - 2, size.height * 0.90)
      ..lineTo(centerX, size.height * 0.58)
      ..lineTo(centerX + 2, size.height * 0.90)
      ..lineTo(centerX + 8, size.height * 0.90)
      ..lineTo(centerX + 10, size.height * 0.58)
      ..lineTo(centerX + 12, size.height * 0.32)
      ..lineTo(centerX + 18, size.height * 0.48)
      ..lineTo(centerX + 22, size.height * 0.48)
      ..lineTo(centerX + 18, size.height * 0.24)
      ..lineTo(centerX + 4, size.height * 0.18)
      ..close();

    canvas.drawPath(bodyPath, fillPaint);
    canvas.drawPath(bodyPath, paint);
  }

  @override
  bool shouldRepaint(covariant _MiniAnatomyPainter oldDelegate) => false;
}
