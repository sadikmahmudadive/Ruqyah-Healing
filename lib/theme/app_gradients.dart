import 'package:flutter/material.dart';

/// App-wide gradient tokens. Keep gradients defined here (not inline)
/// so swapping the hero palette is a one-line change.
class AppGradients {
  AppGradients._();

  /// Primary hero gradient — rich forest green.  #082F21 → #0F593D
  static const LinearGradient greenHeaderGradient = LinearGradient(
    colors: [Color(0xFF082F21), Color(0xFF0F593D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Dark-mode hero gradient (slightly deeper to stay legible on dark bg).
  static const LinearGradient darkHeaderGradient = LinearGradient(
    colors: [Color(0xFF051C14), Color(0xFF0B3B28)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Primary call-to-action button gradient.
  static const LinearGradient greenButtonGradient = LinearGradient(
    colors: [Color(0xFF082F21), Color(0xFF0F593D)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// 3-stop green with a hint of teal, for feature cards.
  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF082F21), Color(0xFF0F593D), Color(0xFF127A52)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.55, 1.0],
  );

  /// Warm gold gradient — for premium / featured highlights.
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFC68A1F), Color(0xFFE5B860), Color(0xFFD49E35)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  /// Soft ambient gradient for scroll backgrounds.
  static LinearGradient ambientGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? const LinearGradient(
            colors: [Color(0xFF08120E), Color(0xFF0A1812), Color(0xFF08120E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
        : const LinearGradient(
            colors: [Color(0xFFF5F7F6), Color(0xFFEEF4F0), Color(0xFFF5F7F6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );
  }

  /// Returns the header gradient for the current theme.
  static LinearGradient headerGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkHeaderGradient : greenHeaderGradient;
  }

  /// Vignette for use over hero images / splash backgrounds.
  static LinearGradient vignette({
    double topAlpha = 0.15,
    double bottomAlpha = 0.6,
  }) {
    return LinearGradient(
      colors: [
        Colors.black.withValues(alpha: topAlpha),
        Colors.transparent,
        Colors.black.withValues(alpha: bottomAlpha),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: const [0.0, 0.5, 1.0],
    );
  }
}
