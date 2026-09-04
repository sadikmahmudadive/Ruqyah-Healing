import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_gradients.dart';
import '../widgets/app_toast.dart';
import 'secure_messages_screen.dart';

class PainStressMonitorScreen extends StatefulWidget {
  const PainStressMonitorScreen({super.key});

  @override
  State<PainStressMonitorScreen> createState() =>
      _PainStressMonitorScreenState();
}

class _PainStressMonitorScreenState extends State<PainStressMonitorScreen> {
  double _painLevel = 6.0;
  double _stressLevel = 4.0;
  String _trendFilter = 'Pain';
  final TextEditingController _notesController = TextEditingController(
    text: 'Tight shoulders, dull headache, fatigue in the evening.',
  );

  bool _flagSeverePain = false;
  bool _flagNumbness = false;
  bool _flagFever = false;

  final List<double> _weeklyPainTrend = const [5.0, 4.0, 6.0, 5.0, 3.0, 6.0, 5.0];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _handleSaveCheckIn() {
    HapticFeedback.heavyImpact();
    AppToast.show(
      context,
      title: 'Check-in Saved',
      message:
          'Daily Pain Level (${_painLevel.toInt()}/10) & Stress (${_stressLevel.toInt()}/10) recorded.',
      type: ToastType.success,
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
          title: Column(
            children: const [
              Text(
                'Pain & Stress Monitor',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF15221D),
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Today • Daily Check-in',
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
                    Icons.settings_outlined,
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
              // 1. Body Pain Locator Card
              _buildBodyPainLocatorCard(),

              const SizedBox(height: 16),

              // 2. Current Levels Sliders Card
              _buildCurrentLevelsCard(),

              const SizedBox(height: 16),

              // 3. Trend – Last 7 Days Card
              _buildTrendChartCard(),

              const SizedBox(height: 16),

              // 4. Symptoms & Notes Input Card
              _buildSymptomsNotesCard(),

              const SizedBox(height: 16),

              // 5. Red Flag Check Box
              _buildRedFlagCheckBox(),

              const SizedBox(height: 20),

              // 6. Bottom Action Buttons Row (Ask Therapist & Save Check-in)
              _buildBottomButtonsRow(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Body Pain Locator Card
  Widget _buildBodyPainLocatorCard() {
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
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Body Pain Locator',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF15221D),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Tap areas to record pain intensity',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Color(0xFF90A4AE),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF7F0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Today',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0B4632),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Front & Back Body Silhouettes
          Row(
            children: [
              // Front View Box
              Expanded(
                child: Container(
                  height: 220,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7F6),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFFE2E8E5),
                      width: 1.0,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(100, 200),
                        painter: _BodyLocatorPainter(isBack: false),
                      ),

                      // Pain Marker Indicator Exclamation !
                      Positioned(
                        top: 40,
                        right: 32,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: Color(0xFFD32F2F),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x66D32F2F),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              '!',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // View Label Tag
                      Positioned(
                        bottom: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Front View',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Back View Box
              Expanded(
                child: Container(
                  height: 220,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7F6),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFFE2E8E5),
                      width: 1.0,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(100, 200),
                        painter: _BodyLocatorPainter(isBack: true),
                      ),

                      // View Label Tag
                      Positioned(
                        bottom: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Back View',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Severity Scale Legend Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _SeverityLegendDot(color: Color(0xFF2ECC71), label: 'None'),
              _SeverityLegendDot(color: Color(0xFFF1C40F), label: 'Mild'),
              _SeverityLegendDot(color: Color(0xFFE67E22), label: 'Moderate'),
              _SeverityLegendDot(color: Color(0xFFE74C3C), label: 'Severe'),
            ],
          ),
        ],
      ),
    );
  }

  // 2. Current Levels Sliders Card
  Widget _buildCurrentLevelsCard() {
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
            children: const [
              Text(
                'Current Levels',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF15221D),
                ),
              ),
              Spacer(),
              Text(
                'Drag to adjust',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: Color(0xFF90A4AE),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Pain Level Slider
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFFE74C3C),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Pain Level',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF15221D),
                ),
              ),
              const Spacer(),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${_painLevel.toInt()}',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFE74C3C),
                      ),
                    ),
                    const TextSpan(
                      text: ' /10',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.5,
                        color: Color(0xFF90A4AE),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFFE74C3C),
              inactiveTrackColor: const Color(0xFFF5F7F6),
              thumbColor: const Color(0xFFE74C3C),
              overlayColor: const Color(0xFFE74C3C).withValues(alpha: 0.15),
              trackHeight: 6,
            ),
            child: Slider(
              value: _painLevel,
              min: 0,
              max: 10,
              divisions: 10,
              onChanged: (val) {
                HapticFeedback.selectionClick();
                setState(() => _painLevel = val);
              },
            ),
          ),

          const SizedBox(height: 12),

          // Stress Level Slider
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFF0B4632),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Stress Level',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF15221D),
                ),
              ),
              const Spacer(),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${_stressLevel.toInt()}',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0B4632),
                      ),
                    ),
                    const TextSpan(
                      text: ' /10',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.5,
                        color: Color(0xFF90A4AE),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF0B4632),
              inactiveTrackColor: const Color(0xFFF5F7F6),
              thumbColor: const Color(0xFF0B4632),
              overlayColor: const Color(0xFF0B4632).withValues(alpha: 0.15),
              trackHeight: 6,
            ),
            child: Slider(
              value: _stressLevel,
              min: 0,
              max: 10,
              divisions: 10,
              onChanged: (val) {
                HapticFeedback.selectionClick();
                setState(() => _stressLevel = val);
              },
            ),
          ),
        ],
      ),
    );
  }

  // 3. Trend – Last 7 Days Line Chart Card
  Widget _buildTrendChartCard() {
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
          Row(
            children: [
              const Text(
                'Trend – Last 7 Days',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF15221D),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF7F0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Text(
                      _trendFilter,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0B4632),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF0B4632),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Line Trend Chart Representation
          SizedBox(
            height: 90,
            width: double.infinity,
            child: CustomPaint(
              painter: _TrendLineChartPainter(data: _weeklyPainTrend),
            ),
          ),

          const SizedBox(height: 8),

          // X-Axis Dates
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('14 May', style: _axisTextStyle),
              Text('15', style: _axisTextStyle),
              Text('16', style: _axisTextStyle),
              Text('17', style: _axisTextStyle),
              Text('18', style: _axisTextStyle),
              Text('19', style: _axisTextStyle),
              Text('20 May', style: _axisTextStyle),
            ],
          ),
        ],
      ),
    );
  }

  static const TextStyle _axisTextStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 11,
    color: Color(0xFF90A4AE),
  );

  // 4. Symptoms & Notes Input Card
  Widget _buildSymptomsNotesCard() {
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
          Row(
            children: [
              const Text(
                'Symptoms & Notes',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF15221D),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Optional',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: Color(0xFF90A4AE),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7F6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              controller: _notesController,
              maxLines: 3,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13.5,
                color: Color(0xFF15221D),
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 5. Red Flag Check Box
  Widget _buildRedFlagCheckBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD49E35).withValues(alpha: 0.30),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFD49E35),
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'Red Flag Check',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFB78103),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          _buildFlagCheckboxRow(
            label: 'Severe or worsening pain',
            value: _flagSeverePain,
            onChanged: (val) => setState(() => _flagSeverePain = val!),
          ),
          _buildFlagCheckboxRow(
            label: 'Numbness or muscle weakness',
            value: _flagNumbness,
            onChanged: (val) => setState(() => _flagNumbness = val!),
          ),
          _buildFlagCheckboxRow(
            label: 'Fever or unexplained weight loss',
            value: _flagFever,
            onChanged: (val) => setState(() => _flagFever = val!),
          ),
        ],
      ),
    );
  }

  Widget _buildFlagCheckboxRow({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: Checkbox(
              value: value,
              activeColor: const Color(0xFFD49E35),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              onChanged: onChanged,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12.5,
                color: Color(0xFF6E7E77),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 6. Bottom Dual Primary Action Buttons
  Widget _buildBottomButtonsRow() {
    return Row(
      children: [
        // Ask Therapist Outlined Button
        Expanded(
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF0B4632), width: 1.5),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) =>
                          const SecureMessagesScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: const Center(
                  child: Text(
                    'Ask Therapist',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0B4632),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Save Check-in Primary Button
        Expanded(
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              gradient: AppGradients.greenButtonGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF082F21).withValues(alpha: 0.30),
                  offset: const Offset(0, 4),
                  blurRadius: 14,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _handleSaveCheckIn,
                borderRadius: BorderRadius.circular(16),
                splashColor: Colors.white.withValues(alpha: 0.15),
                child: const Center(
                  child: Text(
                    'Save Check-in',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SeverityLegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _SeverityLegendDot({required this.color, required this.label});

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
        const SizedBox(width: 5),
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

class _BodyLocatorPainter extends CustomPainter {
  final bool isBack;

  _BodyLocatorPainter({required this.isBack});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = const Color(0xFFB0BEC5).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final fillPaint = Paint()
      ..color = const Color(0xFFE2E8E5).withValues(alpha: 0.40)
      ..style = PaintingStyle.fill;

    final Path bodyPath = Path()
      ..addOval(Rect.fromCircle(
          center: Offset(centerX, h * 0.12), radius: w * 0.10))
      ..moveTo(centerX - 4, h * 0.18)
      ..lineTo(centerX - 20, h * 0.24)
      ..lineTo(centerX - 24, h * 0.48)
      ..lineTo(centerX - 20, h * 0.48)
      ..lineTo(centerX - 14, h * 0.32)
      ..lineTo(centerX - 12, h * 0.58)
      ..lineTo(centerX - 9, h * 0.90)
      ..lineTo(centerX - 2, h * 0.90)
      ..lineTo(centerX, h * 0.58)
      ..lineTo(centerX + 2, h * 0.90)
      ..lineTo(centerX + 9, h * 0.90)
      ..lineTo(centerX + 12, h * 0.58)
      ..lineTo(centerX + 14, h * 0.32)
      ..lineTo(centerX + 20, h * 0.48)
      ..lineTo(centerX + 24, h * 0.48)
      ..lineTo(centerX + 20, h * 0.24)
      ..lineTo(centerX + 4, h * 0.18)
      ..close();

    canvas.drawPath(bodyPath, fillPaint);
    canvas.drawPath(bodyPath, paint);
  }

  @override
  bool shouldRepaint(covariant _BodyLocatorPainter oldDelegate) => false;
}

class _TrendLineChartPainter extends CustomPainter {
  final List<double> data;

  _TrendLineChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF0B4632)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = const Color(0xFF0B4632)
      ..style = PaintingStyle.fill;

    final gridLinePaint = Paint()
      ..color = const Color(0xFFE2E8E5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw baseline
    canvas.drawLine(
      Offset(0, size.height - 10),
      Offset(size.width, size.height - 10),
      gridLinePaint,
    );

    if (data.isEmpty) return;

    final double stepX = size.width / (data.length - 1);
    final Path linePath = Path();

    for (int i = 0; i < data.length; i++) {
      final double x = i * stepX;
      final double y = size.height - 10 - (data[i] / 10.0) * (size.height - 20);

      if (i == 0) {
        linePath.moveTo(x, y);
      } else {
        linePath.lineTo(x, y);
      }

      canvas.drawCircle(Offset(x, y), 3.5, dotPaint);
    }

    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant _TrendLineChartPainter oldDelegate) => false;
}
