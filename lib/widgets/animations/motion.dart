import 'package:flutter/material.dart';

/// Shared motion tokens for the whole app.
///
/// Durations follow Material 3's "expressive motion" guidance:
///   fast   — 150ms  (press feedback, color changes)
///   base   — 250ms  (most state changes, hover/press)
///   slow   — 400ms  (page transitions, significant layout changes)
///   extra  — 650ms  (hero entrances, splash, long reveals)
///
/// Curves follow the Material 3 "emphasized" style — they start briskly
/// and settle softly, which reads as premium instead of mechanical.
class AppMotion {
  AppMotion._();

  // ─── Durations ─────────────────────────────────────────────
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration extra = Duration(milliseconds: 650);
  static const Duration page = Duration(milliseconds: 420);

  // ─── Curves ────────────────────────────────────────────────
  /// Default curve for most movement. Firm start, gentle settle.
  static const Curve standard = Curves.easeOutCubic;

  /// For bouncy, playful motion (success states, "pop in" moments).
  static const Curve expressive = Cubic(0.2, 0.9, 0.3, 1.4);

  /// Smooth S-curve for symmetric motion (fades, dissolves).
  static const Curve smooth = Curves.easeInOutCubicEmphasized;

  /// For items leaving the screen. Fast start, slow end.
  static const Curve exit = Curves.easeInCubic;

  // ─── Stagger ───────────────────────────────────────────────
  /// Delay between staggered children in a list entrance.
  static const Duration staggerStep = Duration(milliseconds: 55);
}

/// Shared elevation + shadow tokens.
///
/// Soft, layered shadows read as modern. Harsh shadows read as dated.
class AppElevation {
  AppElevation._();

  /// Flush cards — subtle depth, almost flat.
  static List<BoxShadow> get subtle => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 12,
      offset: const Offset(0, 2),
    ),
  ];

  /// Standard raised card.
  static List<BoxShadow> get card => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 18,
      offset: const Offset(0, 6),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.02),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  /// Hovering / floating element (bottom nav, FAB).
  static List<BoxShadow> get floating => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 28,
      offset: const Offset(0, 10),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.03),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  /// Colored glow for primary action buttons.
  static List<BoxShadow> glow(Color color, {double strength = 0.3}) => [
    BoxShadow(
      color: color.withValues(alpha: strength),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  /// Dark-mode safe shadow (visible on dark surfaces).
  static List<BoxShadow> get darkCard => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.45),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
}
