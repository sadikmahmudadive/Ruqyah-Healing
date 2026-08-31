import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'onboarding_screen_1.dart';

class LanguageOption {
  final String code;
  final String nativeName;
  final String englishName;

  const LanguageOption({
    required this.code,
    required this.nativeName,
    required this.englishName,
  });
}

class LanguageOnboardingScreen extends StatefulWidget {
  final ValueChanged<String>? onLanguageSelected;
  final VoidCallback? onContinue;

  const LanguageOnboardingScreen({
    super.key,
    this.onLanguageSelected,
    this.onContinue,
  });

  @override
  State<LanguageOnboardingScreen> createState() =>
      _LanguageOnboardingScreenState();
}

class _LanguageOnboardingScreenState extends State<LanguageOnboardingScreen>
    with SingleTickerProviderStateMixin {
  final List<LanguageOption> _languages = const [
    LanguageOption(code: 'en', nativeName: 'English', englishName: 'English'),
    LanguageOption(code: 'bn', nativeName: 'বাংলা', englishName: 'Bangla'),
    LanguageOption(code: 'ar', nativeName: 'العربية', englishName: 'Arabic'),
    LanguageOption(code: 'fa', nativeName: 'فارسی', englishName: 'Farsi'),
  ];

  String _selectedLanguageCode = 'en';
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _selectLanguage(String code) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedLanguageCode = code;
    });
    widget.onLanguageSelected?.call(code);
  }

  void _handleContinue() {
    HapticFeedback.mediumImpact();
    if (widget.onContinue != null) {
      widget.onContinue!();
    } else {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const OnboardingScreen1(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF0B0E13),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Background Motif Image
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: size.height * 0.70,
              child: Image.asset(
                'assets/background/bg_language_onboarding.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),

            // Slight Blur Effect on Background Motif
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: size.height * 0.70,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                  child: const SizedBox(),
                ),
              ),
            ),

            // Atmospheric Dark Gradient Layer
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: size.height * 0.70,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      const Color(0xFF0B0E13).withValues(alpha: 0.35),
                      const Color(0xFF0B0E13).withValues(alpha: 0.85),
                      const Color(0xFF0B0E13),
                    ],
                    stops: const [0.0, 0.40, 0.75, 1.0],
                  ),
                ),
              ),
            ),

            // Content Area with Centered Alignment
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: IntrinsicHeight(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Top spacer to center content while showing background art
                                  const Spacer(flex: 3),

                                  // Header: WELCOME TO
                                  Text(
                                    'WELCOME TO',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 2.0,
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  // Brand Title: RUQYAH HEALING
                                  const Text(
                                    'RUQYAH HEALING',
                                    style: TextStyle(
                                      fontFamily: 'Cinzel',
                                      fontSize: 27,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.8,
                                      color: Colors.white,
                                      height: 1.2,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(0, 2),
                                          blurRadius: 10,
                                          color: Color(0x99000000),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  // Tagline
                                  Text(
                                    'Compassionate care for body, mind and soul',
                                    style: TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white.withValues(
                                        alpha: 0.68,
                                      ),
                                      height: 1.35,
                                    ),
                                  ),

                                  const SizedBox(height: 32),

                                  // Section Title: Choose your language
                                  const Text(
                                    'Choose your language',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.2,
                                      color: Colors.white,
                                    ),
                                  ),

                                  const SizedBox(height: 14),

                                  // Bento / Glassmorphic Language Options
                                  ..._languages.map((lang) {
                                    final isSelected =
                                        lang.code == _selectedLanguageCode;
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12.0,
                                      ),
                                      child: _buildLanguageCard(
                                        lang,
                                        isSelected,
                                      ),
                                    );
                                  }),

                                  // Bottom spacer
                                  const Spacer(flex: 3),

                                  // Spatial Glassmorphic Continue Button
                                  _buildContinueButton(),

                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageCard(LanguageOption lang, bool isSelected) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _selectLanguage(lang.code),
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(
                horizontal: 18.0,
                vertical: 16.0,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF1E2630).withValues(alpha: 0.78)
                    : const Color(0xFF151A21).withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF2ECC71).withValues(alpha: 0.35)
                      : Colors.white.withValues(alpha: 0.09),
                  width: isSelected ? 1.2 : 1.0,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF2ECC71)
                              .withValues(alpha: 0.08),
                          blurRadius: 16,
                          spreadRadius: 1,
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  // Radio Indicator
                  _buildRadioIndicator(isSelected),

                  const SizedBox(width: 16),

                  // Native Language Name
                  Expanded(
                    child: Text(
                      lang.nativeName,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),

                  // English Subtitle
                  Text(
                    lang.englishName,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRadioIndicator(bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected
              ? const Color(0xFF2ECC71)
              : Colors.white.withValues(alpha: 0.35),
          width: 1.8,
        ),
        color: isSelected ? const Color(0xFF0F141C) : Colors.transparent,
      ),
      child: Center(
        child: AnimatedScale(
          scale: isSelected ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: Container(
            width: 9,
            height: 9,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF2ECC71),
              boxShadow: [
                BoxShadow(
                  color: Color(0x662ECC71),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _handleContinue,
            borderRadius: BorderRadius.circular(20),
            splashColor: Colors.white.withValues(alpha: 0.15),
            highlightColor: Colors.white.withValues(alpha: 0.08),
            child: Container(
              height: 58,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.28),
                    Colors.white.withValues(alpha: 0.12),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.38),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    offset: const Offset(0, 6),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Row(
                children: const [
                  Text(
                    'Continue',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                      color: Colors.white,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
