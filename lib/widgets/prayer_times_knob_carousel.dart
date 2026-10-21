import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_gradients.dart';
import '../theme/app_theme.dart';
import 'animations/animations.dart';
import 'prayer_time_icon.dart';

/// An interactive, radio-knob style carousel for Today's Prayer Times.
///
/// Features:
/// - Always positions the currently active prayer box directly in the middle.
/// - Operates like an analogue radio tuner dial with continuous cyclical looping,
///   detent snapping physics, graduation tick marks, and subtle haptic feedback.
/// - Flanking prayer times are gracefully scaled and faded for cylindrical depth.
/// - Tapping any off-center prayer smoothly animates it to the center knob.
/// - Tapping the center knob opens the full salah schedule.
/// - Soft edge vignette blending avoids hard-clipping at the card borders.
class PrayerTimesKnobCarousel extends StatefulWidget {
  final List<(String, String)> prayers;
  final String activePrayer;
  final VoidCallback? onOpenFullSchedule;

  const PrayerTimesKnobCarousel({
    super.key,
    required this.prayers,
    required this.activePrayer,
    this.onOpenFullSchedule,
  });

  @override
  State<PrayerTimesKnobCarousel> createState() =>
      _PrayerTimesKnobCarouselState();
}

class _PrayerTimesKnobCarouselState extends State<PrayerTimesKnobCarousel> {
  static const int _loops = 600;
  static const double _viewportFraction = 0.222;

  late final PageController _controller;
  int _currentPage = 0;
  Timer? _idleTimer;

  int get _activeIndex {
    if (widget.prayers.isEmpty) return 0;
    final idx = widget.prayers.indexWhere((p) => p.$1 == widget.activePrayer);
    return idx == -1 ? 0 : idx;
  }

  int _calculateInitialPage() {
    if (widget.prayers.isEmpty) return 0;
    return widget.prayers.length * (_loops ~/ 2) + _activeIndex;
  }

  @override
  void initState() {
    super.initState();
    _currentPage = _calculateInitialPage();
    _controller = PageController(
      initialPage: _currentPage,
      viewportFraction: _viewportFraction,
    );
    _controller.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(PrayerTimesKnobCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activePrayer != widget.activePrayer &&
        widget.prayers.isNotEmpty) {
      _animateToActivePrayer();
    }
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (mounted) setState(() {});
  }

  double _page() {
    if (_controller.hasClients && _controller.position.haveDimensions) {
      return _controller.page ?? _currentPage.toDouble();
    }
    return _currentPage.toDouble();
  }

  void _goTo(int page) {
    if (!_controller.hasClients) return;
    if (MediaQuery.of(context).disableAnimations) {
      _controller.jumpToPage(page);
    } else {
      _controller.animateToPage(
        page,
        duration: const Duration(milliseconds: 340),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _animateToActivePrayer() {
    if (!_controller.hasClients || widget.prayers.isEmpty) return;
    final currentNormalized = _currentPage % widget.prayers.length;
    final diff = _activeIndex - currentNormalized;
    _goTo(_currentPage + diff);
  }

  void _onPageChanged(int page) {
    if (_currentPage != page) {
      HapticFeedback.selectionClick();
      setState(() {
        _currentPage = page;
      });
    }

    _idleTimer?.cancel();
    if (widget.prayers.isNotEmpty &&
        (page % widget.prayers.length) != _activeIndex) {
      _idleTimer = Timer(const Duration(seconds: 8), () {
        if (mounted) {
          _animateToActivePrayer();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.prayers.isEmpty) {
      return const SizedBox(height: 124);
    }

    final cardBg = context.cardBg;
    final isDark = context.isDarkMode;
    final isCustomTuned =
        (_currentPage % widget.prayers.length) != _activeIndex;

    final accentColor =
        isDark ? AppColors.accentGold : AppColors.primaryGreen;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Carousel rotary viewport
        SizedBox(
          height: 104,
          child: Stack(
            children: [
              PageView.builder(
                controller: _controller,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: widget.prayers.length * _loops,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, i) {
                  final rawPrayer =
                      widget.prayers[i % widget.prayers.length];
                  final name = rawPrayer.$1;
                  final time = rawPrayer.$2;

                  final distance = (_page() - i).abs();
                  final proximity = (1.0 - distance).clamp(0.0, 1.0);
                  final isCentered = distance < 0.5;

                  return _buildKnobSlot(
                    index: i,
                    name: name,
                    time: time,
                    distance: distance,
                    proximity: proximity,
                    isCentered: isCentered,
                  );
                },
              ),

              // Left edge cylinder vignette fade
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 28,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          cardBg,
                          cardBg.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Right edge cylinder vignette fade
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: 28,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [
                          cardBg,
                          cardBg.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Quick return button if tuned away from clock active prayer
        if (isCustomTuned)
          Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 4),
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                _animateToActivePrayer();
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.replay_rounded,
                      size: 13,
                      color: accentColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Now: ${widget.activePrayer}',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildKnobSlot({
    required int index,
    required String name,
    required String time,
    required double distance,
    required double proximity,
    required bool isCentered,
  }) {
    final scale = (1.04 - (distance * 0.12)).clamp(0.86, 1.04);
    final opacity = (1.0 - (distance * 0.32)).clamp(0.55, 1.0);

    Widget content;

    if (isCentered) {
      final card = Container(
        constraints: const BoxConstraints(minWidth: 66, maxWidth: 84),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          gradient: AppGradients.greenButtonGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PrayerTimeIcon(prayerName: name, color: Colors.white, size: 20),
            const SizedBox(height: 5),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.92),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              time,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFFD49E35),
              ),
            ),
          ],
        ),
      );

      content = BreathingPulse(maxScale: 1.03, child: card);
    } else {
      content = Container(
        constraints: const BoxConstraints(minWidth: 64, maxWidth: 80),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PrayerTimeIcon(
              prayerName: name,
              color: context.isDarkMode
                  ? AppColors.darkTextMuted
                  : const Color(0xFF52625B),
              size: 20,
            ),
            const SizedBox(height: 5),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              time,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: context.textPrimary,
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: opacity,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (isCentered) {
                widget.onOpenFullSchedule?.call();
              } else {
                HapticFeedback.selectionClick();
                _goTo(index);
              }
            },
            child: content,
          ),
        ),
      ),
    );
  }
}
