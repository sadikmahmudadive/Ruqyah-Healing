import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'animations/animations.dart';
import 'illustrations/ruqyah_illustrations.dart';

/// A calm placeholder for lists with nothing in them, a failed load or no
/// connection: a gently floating illustration, a short title, one line of
/// help and an optional action. Use it instead of bare "No results" text.
class EmptyState extends StatelessWidget {
  final FlatIllustrationKind kind;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double illustrationSize;
  final EdgeInsets padding;

  const EmptyState({
    super.key,
    required this.kind,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.illustrationSize = 120,
    this.padding = const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
  });

  /// A failed load, with a retry button.
  const EmptyState.error({
    super.key,
    this.title = 'Something went wrong',
    this.message = 'We could not load this just now. Please try again.',
    this.actionLabel = 'Try again',
    this.onAction,
    this.illustrationSize = 120,
    this.padding = const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
  }) : kind = FlatIllustrationKind.error;

  /// No connection, with a retry button.
  const EmptyState.offline({
    super.key,
    this.title = 'You are offline',
    this.message = 'Check your connection and try again.',
    this.actionLabel = 'Retry',
    this.onAction,
    this.illustrationSize = 120,
    this.padding = const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
  }) : kind = FlatIllustrationKind.offline;

  @override
  Widget build(BuildContext context) {
    final accent = context.isDarkMode
        ? AppColors.accentGold
        : AppColors.primaryGreen;
    return Center(
      child: Padding(
        padding: padding,
        child: FadeSlideIn(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: FloatingIllustration(
                  child: FlatIllustration(kind: kind, size: illustrationSize),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppType.title.copyWith(color: context.textPrimary),
              ),
              if (message != null) ...[
                const SizedBox(height: 8),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: AppType.body.copyWith(color: context.textSecondary),
                ),
              ],
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 20),
                TextButton(
                  onPressed: onAction,
                  style: TextButton.styleFrom(
                    foregroundColor: accent,
                    minimumSize: const Size(48, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: Text(
                    actionLabel!,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Floats its child up and down a few pixels, slowly. Only a transform, so it
/// costs almost nothing, and it holds still when the user has asked for
/// reduced motion.
class FloatingIllustration extends StatefulWidget {
  final Widget child;
  final double distance;
  final Duration period;

  const FloatingIllustration({
    super.key,
    required this.child,
    this.distance = 4,
    this.period = const Duration(milliseconds: 3600),
  });

  @override
  State<FloatingIllustration> createState() => _FloatingIllustrationState();
}

class _FloatingIllustrationState extends State<FloatingIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.period,
  );

  bool _running = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (still && _running) {
      _c.stop();
      _running = false;
    } else if (!still && !_running) {
      _c.repeat(reverse: true);
      _running = true;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        child: widget.child,
        builder: (context, child) {
          final t = Curves.easeInOutSine.transform(_c.value);
          return Transform.translate(
            offset: Offset(0, (t - 0.5) * 2 * widget.distance),
            child: child,
          );
        },
      ),
    );
  }
}
