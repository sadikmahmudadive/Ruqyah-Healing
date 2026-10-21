import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'islamic_pattern.dart';

/// Shared frame for the three onboarding screens, so every page puts the
/// Skip row, heading, description, step dots and CTA at exactly the same
/// position regardless of how long the copy is.
class OnboardingLayout extends StatefulWidget {
  /// Full-bleed background, e.g. an image or a painted backdrop.
  final Widget background;

  /// Heading. Use a `\n` to split it over two lines; the heading area always
  /// reserves two lines so the description starts at the same y everywhere.
  final String title;
  final String description;

  /// 0-based index of the current page, out of [stepCount].
  final int step;
  final int stepCount;

  final String ctaLabel;
  final VoidCallback onCta;

  /// When null the Skip row keeps its space but is hidden.
  final VoidCallback? onSkip;

  /// Extra darkening from mid-screen down, for bright backgrounds where the
  /// default vignette is not enough for white text.
  final bool strongScrim;

  const OnboardingLayout({
    super.key,
    this.strongScrim = false,
    required this.background,
    required this.title,
    required this.description,
    required this.step,
    required this.ctaLabel,
    required this.onCta,
    this.onSkip,
    this.stepCount = 3,
  });

  @override
  State<OnboardingLayout> createState() => _OnboardingLayoutState();
}

class _OnboardingLayoutState extends State<OnboardingLayout>
    with SingleTickerProviderStateMixin {
  static const double _titleSize = 28;
  static const double _titleHeight = 1.25;
  static const double _bodySize = 15;
  static const double _bodyHeight = 1.45;

  late final AnimationController _anim;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _anim.dispose();
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
            widget.background,
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                child: const SizedBox(),
              ),
            ),
            // Vignette for text legibility.
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: widget.strongScrim
                      ? [
                          Colors.black.withValues(alpha: 0.30),
                          Colors.black.withValues(alpha: 0.05),
                          Colors.black.withValues(alpha: 0.50),
                          Colors.black.withValues(alpha: 0.78),
                        ]
                      : [
                          Colors.black.withValues(alpha: 0.25),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.15),
                          Colors.black.withValues(alpha: 0.35),
                        ],
                  stops: widget.strongScrim
                      ? const [0.0, 0.25, 0.55, 1.0]
                      : const [0.0, 0.30, 0.70, 1.0],
                ),
              ),
            ),
            const IslamicPattern(
              color: Color(0xFFE5B860),
              opacity: 0.08,
              cell: 80,
            ),
            SafeArea(
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSkip(),
                        const Spacer(flex: 4),
                        _buildHeading(),
                        const SizedBox(height: 14),
                        _buildDescription(),
                        const Spacer(flex: 5),
                        Center(child: _buildDots()),
                        const SizedBox(height: 20),
                        _buildCta(),
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

  Widget _buildSkip() {
    final skip = InkWell(
      onTap: widget.onSkip,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Text(
          'Skip',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.85),
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
    // Hidden on the last page but still occupying its space, so the rest of
    // the layout never shifts between pages.
    return Visibility(
      visible: widget.onSkip != null,
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      child: Align(alignment: Alignment.centerLeft, child: skip),
    );
  }

  Widget _buildHeading() {
    return SizedBox(
      height: _titleSize * _titleHeight * 2,
      width: double.infinity,
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Text(
          widget.title,
          style: const TextStyle(
            fontFamily: 'Cinzel',
            fontSize: _titleSize,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
            color: Colors.white,
            height: _titleHeight,
            shadows: [
              Shadow(
                offset: Offset(0, 2),
                blurRadius: 12.0,
                color: Color(0xCC000000),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDescription() {
    // Reserve three lines so the dots and CTA below never move.
    return SizedBox(
      height: _bodySize * _bodyHeight * 3,
      width: double.infinity,
      child: Text(
        widget.description,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: _bodySize,
          fontWeight: FontWeight.w400,
          color: Colors.white.withValues(alpha: 0.85),
          height: _bodyHeight,
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
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < widget.stepCount; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: i == widget.step ? 28 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: i == widget.step
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(3),
              boxShadow: i == widget.step
                  ? [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.4),
                        blurRadius: 4,
                      ),
                    ]
                  : null,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCta() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onCta,
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
                border: Border.all(color: Colors.white.withValues(alpha: 0.38)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    offset: const Offset(0, 6),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    widget.ctaLabel,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
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

/// Photo background used by onboarding pages 1 and 2.
class OnboardingImageBackground extends StatelessWidget {
  final String asset;
  const OnboardingImageBackground(this.asset, {super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, _, _) => const SizedBox(),
    );
  }
}
