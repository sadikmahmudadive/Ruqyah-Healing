import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_gradients.dart';
import 'guidance_results_screen.dart';

class AISymptomGuideScreen extends StatefulWidget {
  const AISymptomGuideScreen({super.key});

  @override
  State<AISymptomGuideScreen> createState() => _AISymptomGuideScreenState();
}

class _AISymptomGuideScreenState extends State<AISymptomGuideScreen> {
  final TextEditingController _symptomController = TextEditingController();
  final Set<String> _selectedExperiences = {'Poor sleep'};
  bool _isRecordingVoice = false;

  final List<String> _commonExperiences = const [
    'Fear',
    'Poor sleep',
    'Stress',
    'Intrusive thoughts',
    'Low energy',
    'Anxiety',
  ];

  @override
  void dispose() {
    _symptomController.dispose();
    super.dispose();
  }

  void _handleGetGuidance() {
    HapticFeedback.heavyImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const GuidanceResultsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
  }

  Widget _buildRecommendationItem({
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFEBF7F0),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Color(0xFF0B4632), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF15221D),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Color(0xFF52625B),
                    ),
                  ),
                ],
              ),
            ),
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
                    // 1. Intro Greeting Card
                    _buildIntroCard(),

                    const SizedBox(height: 20),

                    // 2. Common Experiences Section
                    _buildSectionTitle('COMMON EXPERIENCES'),
                    const SizedBox(height: 10),
                    _buildCommonExperiencesWrap(),

                    const SizedBox(height: 20),

                    // 3. Describe in Detail Section
                    _buildSectionTitle('OR DESCRIBE IN DETAIL'),
                    const SizedBox(height: 10),
                    _buildDetailInputCard(),

                    const SizedBox(height: 12),

                    // 4. Record Voice Link
                    _buildRecordVoiceRow(),

                    const SizedBox(height: 20),

                    // 5. Medical Safety Disclaimer Banner
                    _buildDisclaimerBanner(),

                    const SizedBox(height: 20),

                    // 6. Primary Action Button: Get Guidance ->
                    _buildGetGuidanceButton(),

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                      'RUQYAH HEALING',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: Color(0xFF81C784),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'AI SYMPTOM GUIDE',
                      style: TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: Color(0xFFD49E35),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 2,
                      width: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD49E35),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 3.5,
          height: 14,
          decoration: BoxDecoration(
            color: const Color(0xFF0B4632),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: Color(0xFF90A4AE),
          ),
        ),
      ],
    );
  }

  // 1. Intro Greeting Card
  Widget _buildIntroCard() {
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Icon Avatar
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Color(0xFF0B4632),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'AI',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFD49E35),
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // Content Column
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How are you feeling today?',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF15221D),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Share your experience and we\'ll provide Islamic guidance, duas, and spiritual support.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Color(0xFF6E7E77),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. Common Experiences Wrap Pills
  Widget _buildCommonExperiencesWrap() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _commonExperiences.map((exp) {
        final isSelected = _selectedExperiences.contains(exp);

        return InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              if (isSelected) {
                _selectedExperiences.remove(exp);
              } else {
                _selectedExperiences.add(exp);
              }
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD49E35),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  exp,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF52625B),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // 3. Detail Text Input Card with Floating Mic Button
  Widget _buildDetailInputCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8E5), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 14.0,
              bottom: 48.0,
            ),
            child: TextField(
              controller: _symptomController,
              maxLines: 4,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Color(0xFF15221D),
              ),
              decoration: const InputDecoration(
                hintText: 'Describe in your own words what you are experiencing...',
                hintStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13.5,
                  color: Color(0xFFB0BEC5),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),

          // Floating Mic Button at Bottom Right
          Positioned(
            right: 12,
            bottom: 12,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _isRecordingVoice = !_isRecordingVoice);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_isRecordingVoice
                        ? 'Listening to your voice input...'
                        : 'Voice recording stopped.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _isRecordingVoice
                      ? const Color(0xFFE74C3C)
                      : const Color(0xFF0B4632),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0B4632).withValues(alpha: 0.30),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  _isRecordingVoice ? Icons.graphic_eq_rounded : Icons.mic_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 4. Record Voice Link Row
  Widget _buildRecordVoiceRow() {
    return Center(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _isRecordingVoice = !_isRecordingVoice);
        },
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.music_note_rounded,
              color: Color(0xFF6E7E77),
              size: 16,
            ),
            SizedBox(width: 6),
            Text(
              'Or record your voice',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6E7E77),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 5. Medical Safety Disclaimer Banner
  Widget _buildDisclaimerBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD49E35).withValues(alpha: 0.30),
          width: 1.0,
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFD49E35),
            size: 18,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Guidance only - not a medical diagnosis. If you are in crisis or experiencing severe symptoms, please seek professional medical help immediately.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Color(0xFFB78103),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 6. Primary Action Button: Get Guidance ->
  Widget _buildGetGuidanceButton() {
    return Container(
      width: double.infinity,
      height: 56,
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
          onTap: _handleGetGuidance,
          borderRadius: BorderRadius.circular(18),
          splashColor: Colors.white.withValues(alpha: 0.15),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Get Guidance',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
