import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_gradients.dart';
import '../theme/app_theme.dart';
import '../widgets/ai_icon.dart';
import '../widgets/app_toast.dart';
import 'guidance_results_screen.dart';

class AISymptomGuideScreen extends StatefulWidget {
  const AISymptomGuideScreen({super.key});

  @override
  State<AISymptomGuideScreen> createState() => _AISymptomGuideScreenState();
}

class _AISymptomGuideScreenState extends State<AISymptomGuideScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _symptomController = TextEditingController();
  final Set<String> _selectedExperiences = {'Poor sleep'};
  bool _isRecordingVoice = false;
  late AnimationController _pulseController;

  final List<String> _commonExperiences = const [
    'Fear',
    'Poor sleep',
    'Stress',
    'Intrusive thoughts',
    'Low energy',
    'Anxiety',
    'Restlessness',
    'Spiritual heaviness',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _symptomController.dispose();
    _pulseController.dispose();
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

  @override
  Widget build(BuildContext context) {
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
            // 1. Top Modern AI Header Area
            _buildTopHeader(),

            // 2. Scrollable Body Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 18.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Premium Intro Greeting Card
                    _buildIntroCard(),

                    const SizedBox(height: 22),

                    // 2. Common Experiences Section
                    _buildSectionTitle('COMMON EXPERIENCES'),
                    const SizedBox(height: 12),
                    _buildCommonExperiencesWrap(),

                    const SizedBox(height: 22),

                    // 3. Describe in Detail Section
                    _buildSectionTitle('DESCRIBE YOUR SYMPTOMS'),
                    const SizedBox(height: 12),
                    _buildDetailInputCard(),

                    const SizedBox(height: 22),

                    // 4. Medical Safety Disclaimer Banner
                    _buildDisclaimerBanner(),

                    const SizedBox(height: 24),

                    // 5. Primary Action Button: Get Guidance ->
                    _buildGetGuidanceButton(),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Top Modern AI Header Area
  Widget _buildTopHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 22,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        gradient: AppGradients.headerGradient(context),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF082F21).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD49E35).withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFFD49E35).withValues(alpha: 0.40),
                        ),
                      ),
                      child: const Text(
                        'AI ASSISTANT',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: Color(0xFFD49E35),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'AI SYMPTOM GUIDE',
                  style: TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Glowing AI Badge
          ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.05).animate(_pulseController),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0B4632), Color(0xFF1E6B45)],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD49E35), width: 1.8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD49E35).withValues(alpha: 0.40),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: const Center(
                child: AiIcon(color: Color(0xFFD49E35), size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 14,
          decoration: BoxDecoration(
            color: const Color(0xFFD49E35),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: context.textSecondary,
          ),
        ),
      ],
    );
  }

  // 1. Premium Intro Greeting Card
  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.cardBorder, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Glowing Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0B4632), Color(0xFF1E6B45)],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0B4632).withValues(alpha: 0.30),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: AiIcon(color: Color(0xFFD49E35), size: 28),
            ),
          ),

          const SizedBox(width: 16),

          // Content Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How are you feeling today?',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Share what you are experiencing and our AI will generate personalized Quranic duas and spiritual support.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: context.textSecondary,
                    height: 1.45,
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
      spacing: 10,
      runSpacing: 10,
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
          borderRadius: BorderRadius.circular(22),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF0B4632) : context.cardBg,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF0B4632)
                    : context.cardBorder,
                width: isSelected ? 1.5 : 1.0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF0B4632).withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  const Icon(Icons.check_rounded, color: Color(0xFFD49E35), size: 16),
                  const SizedBox(width: 6),
                ],
                Text(
                  exp,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? Colors.white : context.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // 3. Detail Text Input Card with Floating Mic & AI Sparkle
  Widget _buildDetailInputCard() {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.cardBorder, width: 1.0),
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
          Padding(
            padding: const EdgeInsets.only(
              left: 18.0,
              right: 18.0,
              top: 16.0,
              bottom: 56.0,
            ),
            child: TextField(
              controller: _symptomController,
              maxLines: 4,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14.5,
                color: context.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Describe in your own words what you are experiencing (e.g. heavy chest at night, bad dreams, continuous worry)...',
                hintStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13.5,
                  color: context.textSecondary.withValues(alpha: 0.70),
                  height: 1.4,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),

          // Bottom Action Row inside Card (Voice Record & AI Polish)
          Positioned(
            left: 16,
            right: 16,
            bottom: 12,
            child: Row(
              children: [
                // Voice Record Button with Wave Animation
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _isRecordingVoice = !_isRecordingVoice);
                    AppToast.show(
                      context,
                      title: _isRecordingVoice ? 'Voice Recording Active' : 'Recording Stopped',
                      message: _isRecordingVoice
                          ? 'Listening to your voice input...'
                          : 'Voice recording saved.',
                      type: ToastType.info,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _isRecordingVoice
                          ? const Color(0xFFE74C3C)
                          : (context.isDarkMode ? const Color(0xFF182E25) : const Color(0xFFEBF7F0)),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isRecordingVoice ? const Color(0xFFE74C3C) : const Color(0xFF0B4632).withValues(alpha: 0.20),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isRecordingVoice ? Icons.graphic_eq_rounded : Icons.mic_rounded,
                          color: _isRecordingVoice ? Colors.white : const Color(0xFF0B4632),
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isRecordingVoice ? 'Listening...' : 'Voice Input',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _isRecordingVoice ? Colors.white : const Color(0xFF0B4632),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Character count / AI badge
                Text(
                  'AI Powered',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: context.textSecondary.withValues(alpha: 0.60),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 4. Medical Safety Disclaimer Banner
  Widget _buildDisclaimerBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.isDarkMode
            ? const Color(0xFF2E2412)
            : const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFD49E35).withValues(alpha: 0.40),
          width: 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFD49E35),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Spiritual guidance & Ruqyah supplications only — not a formal medical diagnosis. If you are experiencing severe medical conditions, please consult a qualified healthcare professional.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: context.isDarkMode ? const Color(0xFFE5A93C) : const Color(0xFF8F630C),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 5. Primary Action Button: Get Guidance ->
  Widget _buildGetGuidanceButton() {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        gradient: AppGradients.greenButtonGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF082F21).withValues(alpha: 0.35),
            offset: const Offset(0, 6),
            blurRadius: 20,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleGetGuidance,
          borderRadius: BorderRadius.circular(20),
          splashColor: Colors.white.withValues(alpha: 0.15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'Generate Spiritual Guidance',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(width: 10),
              Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFFD49E35),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
