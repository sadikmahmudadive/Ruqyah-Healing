import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/firebase_service.dart';
import '../widgets/animations/animations.dart';
import 'language_onboarding_screen.dart';
import 'main_navigation_shell.dart';

/// Modern animated splash:
///   - Background image with slow Ken-Burns-style zoom
///   - Logo scales in with a soft bounce + fade
///   - Title letters fade in and tracking tightens from 6 → 2.8
///   - Gold tagline fades up and shimmers once
///   - Progress dot wave fades in at the bottom
///   - Everything orchestrated so each layer appears exactly on time
class SplashScreen extends StatefulWidget {
  final VoidCallback? onFinished;

  const SplashScreen({super.key, this.onFinished});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _master;
  late final AnimationController _bgZoom;

  // Each stage is a (begin, end) slice of the master timeline.
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _titleFade;
  late final Animation<double> _titleTracking;
  late final Animation<double> _taglineFade;
  late final Animation<double> _loaderFade;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _master = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _bgZoom = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..forward();

    _logoFade = CurvedAnimation(
      parent: _master,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _master,
        curve: const Interval(0.0, 0.4, curve: AppMotion.expressive),
      ),
    );
    _titleFade = CurvedAnimation(
      parent: _master,
      curve: const Interval(0.3, 0.65, curve: Curves.easeOut),
    );
    _titleTracking = Tween<double>(begin: 6.0, end: 2.8).animate(
      CurvedAnimation(
        parent: _master,
        curve: const Interval(0.3, 0.75, curve: Curves.easeOutCubic),
      ),
    );
    _taglineFade = CurvedAnimation(
      parent: _master,
      curve: const Interval(0.55, 0.85, curve: Curves.easeOut),
    );
    _loaderFade = CurvedAnimation(
      parent: _master,
      curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
    );

    _master.forward();

    _timer = Timer(const Duration(milliseconds: 2600), () {
      if (!mounted) return;
      if (widget.onFinished != null) {
        widget.onFinished!();
      } else {
        final bool isLoggedIn = FirebaseService.currentUser != null;
        final Widget targetScreen = isLoggedIn
            ? const MainNavigationShell()
            : const LanguageOnboardingScreen();
        Navigator.of(context).pushReplacement(
          AppPageRoute.fade(targetScreen, duration: AppMotion.extra),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _master.dispose();
    _bgZoom.dispose();
    super.dispose();
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
            // 1. Background image with slow zoom (Ken Burns)
            AnimatedBuilder(
              animation: _bgZoom,
              builder: (context, _) {
                final scale = 1.0 + 0.08 * _bgZoom.value;
                return Transform.scale(
                  scale: scale,
                  child: Image.asset(
                    'assets/background/bg_splash_screen.jpg',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (_, _, _) => const SizedBox(),
                  ),
                );
              },
            ),

            // 2. Blur layer
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                child: const SizedBox(),
              ),
            ),

            // 3. Vignette
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.15),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.45),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),

            // 4. Flowing green aura behind the logo (very subtle)
            Center(
              child: FadeTransition(
                opacity: _logoFade,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF0F593D).withValues(alpha: 0.35),
                        const Color(0xFF0F593D).withValues(alpha: 0.0),
                      ],
                      stops: const [0.0, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            // 5. Foreground content
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 7),

                      // Logo
                      FadeTransition(
                        opacity: _logoFade,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: _buildLogo(),
                        ),
                      ),

                      const SizedBox(height: 38),

                      // Title (fade in + letter-spacing tween)
                      AnimatedBuilder(
                        animation: _master,
                        builder: (context, _) {
                          return Opacity(
                            opacity: _titleFade.value,
                            child: Text(
                              'RUQYAH HEALING',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Cinzel',
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                letterSpacing: _titleTracking.value,
                                color: Colors.white,
                                shadows: const [
                                  Shadow(
                                    offset: Offset(0, 2),
                                    blurRadius: 10.0,
                                    color: Color(0x99000000),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 12),

                      // Tagline with star accents
                      FadeTransition(
                        opacity: _taglineFade,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star,
                                size: 13, color: Color(0xFFD49E35)),
                            const SizedBox(width: 8),
                            Text(
                              'Faith, Care & Wellbeing',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.6,
                                color: const Color(0xFFE5A93C),
                                shadows: [
                                  Shadow(
                                    offset: const Offset(0, 1),
                                    blurRadius: 6.0,
                                    color:
                                        Colors.black.withValues(alpha: 0.7),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.star,
                                size: 13, color: Color(0xFFD49E35)),
                          ],
                        ),
                      ),

                      const Spacer(flex: 7),

                      // Loader dots
                      FadeTransition(
                        opacity: _loaderFade,
                        child: const _LoaderDots(),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 145,
      height: 145,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F593D).withValues(alpha: 0.6),
            blurRadius: 44,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Image.asset(
        'assets/logo/logo_app.png',
        width: 145,
        height: 145,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) =>
            const SizedBox(width: 145, height: 145),
      ),
    );
  }
}

/// Three dots that pulse in a wave at the bottom of the splash.
class _LoaderDots extends StatefulWidget {
  const _LoaderDots();

  @override
  State<_LoaderDots> createState() => _LoaderDotsState();
}

class _LoaderDotsState extends State<_LoaderDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase = (_ctrl.value + i * 0.2) % 1.0;
            final scale = 0.6 + 0.6 * (1 - (phase - 0.5).abs() * 2).clamp(0, 1);
            final opacity =
                (0.35 + 0.65 * (1 - (phase - 0.5).abs() * 2).clamp(0, 1))
                    .toDouble();
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFD49E35).withValues(alpha: opacity),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
