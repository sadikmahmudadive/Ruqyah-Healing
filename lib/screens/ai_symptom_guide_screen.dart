import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_gradients.dart';
import '../theme/app_theme.dart';
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
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _symptomController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _handleGetGuidance() {
    HapticFeedback.mediumImpact();

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
        const GuidanceResultsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.025),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                ),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 420),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
        isDark ? Brightness.light : Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: context.pageBg,
        systemNavigationBarIconBrightness:
        isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: context.pageBg,
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              _buildHeader(),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeCard(),

                      const SizedBox(height: 28),

                      _buildSectionHeader(
                        title: 'How are you feeling?',
                        subtitle: 'Select everything that feels relevant',
                      ),

                      const SizedBox(height: 14),

                      _buildExperienceChips(),

                      const SizedBox(height: 28),

                      _buildSectionHeader(
                        title: 'Tell us more',
                        subtitle: 'Describe what you are experiencing',
                      ),

                      const SizedBox(height: 14),

                      _buildSymptomComposer(),

                      const SizedBox(height: 18),

                      _buildSafetyNotice(),

                      const SizedBox(height: 24),

                      _buildGenerateButton(),

                      const SizedBox(height: 10),

                      Center(
                        child: Text(
                          'Your information is used only to personalize your guidance.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10.5,
                            height: 1.4,
                            color: context.textSecondary.withValues(
                              alpha: 0.65,
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
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------------------------

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 18,
        right: 18,
        bottom: 18,
      ),
      decoration: BoxDecoration(
        gradient: AppGradients.headerGradient(context),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(22),
        ),
      ),
      child: Row(
        children: [
          _buildHeaderButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD4A43A),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 7),
                    const Text(
                      'AI ASSISTANT',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: Color(0xFFD4A43A),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                const Text(
                  'AI Symptom Guide',
                  style: TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Ink(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // WELCOME CARD
  // ---------------------------------------------------------------------------

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: context.cardBorder.withValues(alpha: 0.75),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'A quiet space to share',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: context.textPrimary,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Tell us what you are going through. '
                'The AI will help you explore relevant Quranic duas '
                'and spiritual support.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.5,
              height: 1.55,
              color: context.textSecondary,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(
                Icons.verified_user_outlined,
                size: 14,
                color: Color(0xFF0B4632),
              ),
              const SizedBox(width: 5),
              Text(
                'Private & supportive',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION HEADER
  // ---------------------------------------------------------------------------

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 18,
              decoration: BoxDecoration(
                color: const Color(0xFFD4A43A),
                borderRadius: BorderRadius.circular(3),
              ),
            ),

            const SizedBox(width: 9),

            Text(
              title,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: context.textPrimary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 4),

        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Text(
            subtitle,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: context.textSecondary.withValues(alpha: 0.75),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // EXPERIENCE CHIPS
  // ---------------------------------------------------------------------------

  Widget _buildExperienceChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 9,
      children: _commonExperiences.map((experience) {
        final selected = _selectedExperiences.contains(experience);

        return _buildExperienceChip(
          label: experience,
          selected: selected,
          onTap: () {
            HapticFeedback.selectionClick();

            setState(() {
              if (selected) {
                _selectedExperiences.remove(experience);
              } else {
                _selectedExperiences.add(experience);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildExperienceChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return AnimatedScale(
      scale: selected ? 1.0 : 0.98,
      duration: const Duration(milliseconds: 160),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(13),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFF0B4632)
                  : context.cardBg,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: selected
                    ? const Color(0xFF0B4632)
                    : context.cardBorder.withValues(alpha: 0.85),
                width: 1,
              ),
              boxShadow: selected
                  ? [
                BoxShadow(
                  color: const Color(0xFF0B4632).withValues(
                    alpha: 0.18,
                  ),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 17,
                  height: 17,
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFD4A43A)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: selected
                        ? null
                        : Border.all(
                      color: context.textSecondary.withValues(
                        alpha: 0.35,
                      ),
                    ),
                  ),
                  child: selected
                      ? const Icon(
                    Icons.check_rounded,
                    size: 12,
                    color: Colors.white,
                  )
                      : null,
                ),

                const SizedBox(width: 7),

                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11.5,
                    fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w600,
                    color: selected
                        ? Colors.white
                        : context.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SYMPTOM COMPOSER
  // ---------------------------------------------------------------------------

  Widget _buildSymptomComposer() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _isRecordingVoice
              ? const Color(0xFF3F51B5).withValues(alpha: 0.60)
              : context.cardBorder.withValues(alpha: 0.85),
          width: _isRecordingVoice ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        children: [
          if (!_isRecordingVoice) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 15, 16, 8),
              child: TextField(
                controller: _symptomController,
                maxLines: 5,
                minLines: 4,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13.5,
                  height: 1.45,
                  color: context.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText:
                  'Write freely about what you are experiencing...',
                  hintStyle: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    height: 1.45,
                    color: context.textSecondary.withValues(
                      alpha: 0.55,
                    ),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ] else ...[
            // Active Voice Recording Bar view matching reference image
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Plus Button
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Colors.white70, size: 18),
                  ),
                  const SizedBox(width: 14),

                  // Dotted Waveform
                  Expanded(
                    child: Center(
                      child: Text(
                        '· · · · · · · · · · · · · · · · · · · · · · · · · ·',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                          letterSpacing: 2.0,
                          color: Colors.white.withValues(alpha: 0.60),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Stop Button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _isRecordingVoice = false);
                    },
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Submit Arrow Button (Blue/Indigo accent)
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      setState(() => _isRecordingVoice = false);
                      _handleGetGuidance();
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: Color(0xFF3F51B5),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_upward_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: Row(
              children: [
                if (!_isRecordingVoice) _buildVoiceButton(),

                const Spacer(),

                Text(
                  _isRecordingVoice ? 'Recording voice audio...' : 'AI assisted',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _isRecordingVoice
                        ? const Color(0xFF3F51B5)
                        : context.textSecondary.withValues(
                      alpha: 0.60,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceButton() {
    final isRecording = _isRecordingVoice;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();

          setState(() {
            _isRecordingVoice = !_isRecordingVoice;
          });

          AppToast.show(
            context,
            title: isRecording
                ? 'Recording Stopped'
                : 'Voice Recording Active',
            message: isRecording
                ? 'Voice recording saved.'
                : 'Listening to your voice input...',
            type: ToastType.info,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: isRecording
                ? const Color(0xFFE05245)
                : context.isDarkMode
                ? const Color(0xFF163328)
                : const Color(0xFFEDF7F1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isRecording
                  ? const Color(0xFFE05245)
                  : const Color(0xFF0B4632).withValues(alpha: 0.12),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isRecording
                    ? Icons.graphic_eq_rounded
                    : Icons.mic_none_rounded,
                size: 17,
                color: isRecording
                    ? Colors.white
                    : const Color(0xFF0B4632),
              ),

              const SizedBox(width: 6),

              Text(
                isRecording ? 'Listening...' : 'Voice',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: isRecording
                      ? Colors.white
                      : const Color(0xFF0B4632),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SAFETY NOTICE
  // ---------------------------------------------------------------------------

  Widget _buildSafetyNotice() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: context.isDarkMode
            ? const Color(0xFF292313)
            : const Color(0xFFFFFAEE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFD4A43A).withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFD4A43A).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: Color(0xFFD4A43A),
              size: 16,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              'This provides spiritual guidance and Ruqyah supplications, '
                  'not a medical diagnosis. For severe or persistent symptoms, '
                  'please consult a qualified healthcare professional.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10.5,
                height: 1.45,
                color: context.isDarkMode
                    ? const Color(0xFFE3B85A)
                    : const Color(0xFF80600F),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PRIMARY BUTTON
  // ---------------------------------------------------------------------------

  Widget _buildGenerateButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: AppGradients.greenButtonGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B4632).withValues(alpha: 0.24),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleGetGuidance,
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white.withValues(alpha: 0.10),
          highlightColor: Colors.white.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Generate Spiritual Guidance',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(width: 8),

                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}