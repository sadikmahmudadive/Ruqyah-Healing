import 'package:flutter/material.dart';

import 'motion.dart';

/// Modern page-route helpers.
///
/// Three shapes cover 99% of app navigation:
///
///   AppPageRoute.slide     — iOS-style right-to-left slide + fade.
///                            Default for all forward pushes.
///   AppPageRoute.sharedAxis — Shared-axis-X (Material M3 motion):
///                            incoming scales 0.92→1 and slides a bit,
///                            outgoing scales down and fades. Feels tied.
///   AppPageRoute.fade       — Pure fade. For splash → home transitions
///                            and modals where there is no spatial model.
///
/// Each returns a [PageRouteBuilder] you can drop straight into
/// `Navigator.of(context).push(...)`.
class AppPageRoute {
  AppPageRoute._();

  /// iOS-style slide (right-to-left) with a soft fade over the outgoing.
  static PageRouteBuilder<T> slide<T>(
    Widget page, {
    Duration duration = AppMotion.page,
    bool fullscreenDialog = false,
  }) {
    return PageRouteBuilder<T>(
      fullscreenDialog: fullscreenDialog,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (context, animation, secondary, child) {
        final slideIn = Tween<Offset>(
          begin: const Offset(0.08, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: animation, curve: AppMotion.smooth),
        );
        final slideOut = Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-0.04, 0),
        ).animate(
          CurvedAnimation(parent: secondary, curve: AppMotion.smooth),
        );
        return SlideTransition(
          position: slideOut,
          child: SlideTransition(
            position: slideIn,
            child: FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: AppMotion.smooth,
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }

  /// Material shared-axis-X. Great when the destination is "a step
  /// forward" in the same flow (list → detail, step 1 → step 2).
  static PageRouteBuilder<T> sharedAxis<T>(
    Widget page, {
    Duration duration = AppMotion.page,
  }) {
    return PageRouteBuilder<T>(
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (context, animation, secondary, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: AppMotion.smooth,
        );
        final secondaryCurved = CurvedAnimation(
          parent: secondary,
          curve: AppMotion.smooth,
        );

        return FadeTransition(
          opacity: Tween<double>(begin: 1.0, end: 0.0).animate(secondaryCurved),
          child: ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 1.08).animate(secondaryCurved),
            child: FadeTransition(
              opacity: curved,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Pure crossfade. Use sparingly — for splash → home and for
  /// bottom-sheet-like modals.
  static PageRouteBuilder<T> fade<T>(
    Widget page, {
    Duration duration = AppMotion.page,
    bool fullscreenDialog = false,
  }) {
    return PageRouteBuilder<T>(
      fullscreenDialog: fullscreenDialog,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (context, animation, _, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: AppMotion.smooth),
          child: child,
        );
      },
    );
  }

  /// Slides up from the bottom (modal / bottom-sheet style).
  static PageRouteBuilder<T> modal<T>(
    Widget page, {
    Duration duration = AppMotion.page,
  }) {
    return PageRouteBuilder<T>(
      fullscreenDialog: true,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (context, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: AppMotion.smooth,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.08),
            end: Offset.zero,
          ).animate(curved),
          child: FadeTransition(opacity: curved, child: child),
        );
      },
    );
  }
}
