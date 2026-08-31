import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'main_navigation_shell.dart';

class OnboardingScreen3 extends StatefulWidget {
  final VoidCallback? onGetStarted;

  const OnboardingScreen3({super.key, this.onGetStarted});

  @override
  State<OnboardingScreen3> createState() => _OnboardingScreen3State();
}

class _OnboardingScreen3State extends State<OnboardingScreen3>
    with SingleTickerProviderStateMixin {
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
        Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleGetStarted() {
    HapticFeedback.heavyImpact();
    if (widget.onGetStarted != null) {
      widget.onGetStarted!();
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MainNavigationShell(),
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
            // Background Image
            Image.asset(
              'assets/background/bg_onboarding_3.jpg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('Error loading bg_onboarding_3.jpg: $error');
                return const SizedBox();
              },
            ),

            // Slight Blur Effect on Background
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                child: const SizedBox(),
              ),
            ),

            // Atmospheric Vignette Gradient Layer for Text Legibility
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.25),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.15),
                    Colors.black.withValues(alpha: 0.35),
                  ],
                  stops: const [0.0, 0.30, 0.70, 1.0],
                ),
              ),
            ),

            // Foreground Content
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Spacer for top alignment matching previous screens (where Skip button was)
                        const SizedBox(height: 37),

                        // Middle Spacer to position text at ~40% height
                        const Spacer(flex: 4),

                        // Main Heading
                        const Text(
                          'TRUSTED COMMUNITY',
                          style: TextStyle(
                            fontFamily: 'Cinzel',
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.8,
                            color: Colors.white,
                            height: 1.25,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 2),
                                blurRadius: 12.0,
                                color: Color(0xCC000000),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Subtitle / Description
                        Text(
                          'Connect with verified therapists, book physical or digital consultations, and join a supportive faith-based wellness community.',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.85),
                            height: 1.45,
                            letterSpacing: 0.2,
                            shadows: [
                              Shadow(
                                offset: const Offset(0, 1),
                                blurRadius: 8.0,
                                color: Colors.black.withValues(alpha: 0.8),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(flex: 5),

                        // Page Indicator Dots (Step 3 of 3)
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Inactive Indicator 1
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.45),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              // Inactive Indicator 2
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.45),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              // Active Indicator (Pill)
                              Container(
                                width: 28,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(3),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.white.withValues(alpha: 0.4),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Glassmorphic Get Started Button
                        _buildGetStartedButton(),

                        const SizedBox(height: 16),
                      ],
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

  Widget _buildGetStartedButton() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _handleGetStarted,
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
                    'Get Started',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                      color: Colors.white,
                    ),
                  ),
                  Spacer(),
                  Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
