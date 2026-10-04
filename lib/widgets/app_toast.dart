import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'animations/motion.dart';

enum ToastType { success, error, warning, info }

/// App-wide toast.
///
///   AppToast.show(context, title: 'Saved', message: 'Check-in recorded.');
///
/// Toasts drop in from the top, below the status bar, so they never cover
/// bottom navigation or playback controls. They are hosted once above the
/// Navigator ([AppToastHost], installed in `MaterialApp.builder`), so they
/// survive route changes and don't depend on the caller's context staying
/// mounted.
///
///  * auto-dismiss, with a countdown bar; time depends on type and length
///  * hold to pause the countdown, swipe up or tap ✕ to dismiss
///  * optional action button (e.g. "Retry")
///  * a new toast replaces the current one instead of stacking
class AppToast {
  AppToast._();

  static _AppToastHostState? _host;

  static void show(
    BuildContext context, {
    required String title,
    required String message,
    ToastType type = ToastType.success,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _haptic(type);

    final request = _ToastRequest(
      title: title,
      message: message,
      type: type,
      duration:
          duration ??
          _defaultDuration(type, title, message, hasAction: actionLabel != null),
      actionLabel: actionLabel,
      onAction: onAction,
    );

    final host = _host;
    if (host != null && host.mounted) {
      host.present(request);
    } else {
      _showAsSnackBar(context, request);
    }
  }

  /// Hides the toast that is currently showing, if any.
  static void dismiss() => _host?.dismiss();

  static void _haptic(ToastType type) {
    switch (type) {
      case ToastType.success:
        HapticFeedback.lightImpact();
      case ToastType.error:
      case ToastType.warning:
        HapticFeedback.mediumImpact();
      case ToastType.info:
        HapticFeedback.selectionClick();
    }
  }

  /// Problems stay longer than confirmations; long text gets reading time.
  static Duration _defaultDuration(
    ToastType type,
    String title,
    String message, {
    required bool hasAction,
  }) {
    final int base = switch (type) {
      ToastType.success => 3000,
      ToastType.info => 3500,
      ToastType.warning => 5000,
      ToastType.error => 6000,
    };
    final int overflow = math.max<int>(0, title.length + message.length - 60);
    final int actionTime = hasAction ? 2000 : 0;
    return Duration(milliseconds: base + overflow * 25 + actionTime);
  }

  /// Fallback for trees without an [AppToastHost] (e.g. isolated widget tests).
  static void _showAsSnackBar(BuildContext context, _ToastRequest r) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          padding: EdgeInsets.zero,
          duration: r.duration,
          content: AppToastWidget(
            title: r.title,
            message: r.message,
            type: r.type,
            actionLabel: r.actionLabel,
            onAction: () {
              r.onAction?.call();
              messenger.hideCurrentSnackBar();
            },
            onDismiss: messenger.hideCurrentSnackBar,
          ),
        ),
      );
  }
}

class _ToastRequest {
  final String title;
  final String message;
  final ToastType type;
  final Duration duration;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Set by the presenter so the host can dismiss it with an animation.
  VoidCallback? dismiss;

  _ToastRequest({
    required this.title,
    required this.message,
    required this.type,
    required this.duration,
    this.actionLabel,
    this.onAction,
  });
}

// ─────────────────────────────── Host ────────────────────────────────

/// Wrap the app's content once, from `MaterialApp.builder`:
///
///   builder: (context, child) => AppToastHost(child: child!),
class AppToastHost extends StatefulWidget {
  final Widget child;

  const AppToastHost({super.key, required this.child});

  @override
  State<AppToastHost> createState() => _AppToastHostState();
}

class _AppToastHostState extends State<AppToastHost> {
  _ToastRequest? _request;

  @override
  void initState() {
    super.initState();
    AppToast._host = this;
  }

  @override
  void dispose() {
    if (AppToast._host == this) AppToast._host = null;
    super.dispose();
  }

  void present(_ToastRequest request) {
    void apply() {
      if (mounted) setState(() => _request = request);
    }

    // show() can be called while building; defer so setState is legal.
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) => apply());
    } else {
      apply();
    }
  }

  void dismiss() => _request?.dismiss?.call();

  void _closed(_ToastRequest request) {
    if (mounted && identical(_request, request)) {
      setState(() => _request = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = _request;
    return Stack(
      alignment: Alignment.topLeft,
      fit: StackFit.expand,
      children: [
        widget.child,
        if (request != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _ToastPresenter(
              // A new request gets a fresh state: instant swap, new countdown.
              key: ObjectKey(request),
              request: request,
              onClosed: () => _closed(request),
            ),
          ),
      ],
    );
  }
}

class _ToastPresenter extends StatefulWidget {
  final _ToastRequest request;
  final VoidCallback onClosed;

  const _ToastPresenter({
    super.key,
    required this.request,
    required this.onClosed,
  });

  @override
  State<_ToastPresenter> createState() => _ToastPresenterState();
}

class _ToastPresenterState extends State<_ToastPresenter>
    with TickerProviderStateMixin {
  late final bool _reduceMotion = WidgetsBinding
      .instance
      .platformDispatcher
      .accessibilityFeatures
      .disableAnimations;

  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: _reduceMotion ? Duration.zero : const Duration(milliseconds: 380),
    reverseDuration: _reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 240),
  );

  // Runs 0 -> 1 over the toast's lifetime; the bar shows the remainder.
  late final AnimationController _timer = AnimationController(
    vsync: this,
    duration: widget.request.duration,
  );
  late final Animation<double> _remaining = ReverseAnimation(_timer);

  bool _closing = false;

  @override
  void initState() {
    super.initState();
    widget.request.dismiss = dismiss;
    _timer.addStatusListener((status) {
      if (status == AnimationStatus.completed) dismiss();
    });
    _enter.forward();
    _timer.forward();
  }

  Future<void> dismiss() async {
    if (_closing || !mounted) return;
    _closing = true;
    _timer.stop();
    await _enter.reverse();
    if (mounted) widget.onClosed();
  }

  void _pause() => _timer.stop();

  void _resume() {
    if (!_closing && !_timer.isCompleted) _timer.forward();
  }

  @override
  void dispose() {
    widget.request.dismiss = null;
    _enter.dispose();
    _timer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    final top = MediaQuery.paddingOf(context).top;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, top + 8, 16, 0),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, -1.3), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: _enter,
                curve: Curves.easeOutCubic,
                reverseCurve: Curves.easeInCubic,
              ),
            ),
        child: FadeTransition(
          opacity: CurvedAnimation(
            parent: _enter,
            curve: const Interval(0, 0.7),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: Dismissible(
              key: const ValueKey('app-toast'),
              direction: DismissDirection.up,
              resizeDuration: null,
              onDismissed: (_) {
                _closing = true;
                widget.onClosed();
              },
              // Holding the toast pauses the countdown so it can be read.
              child: Listener(
                onPointerDown: (_) => _pause(),
                onPointerUp: (_) => _resume(),
                onPointerCancel: (_) => _resume(),
                child: Semantics(
                  liveRegion: true,
                  child: AppToastWidget(
                    title: r.title,
                    message: r.message,
                    type: r.type,
                    actionLabel: r.actionLabel,
                    progress: _remaining,
                    onAction: () {
                      r.onAction?.call();
                      dismiss();
                    },
                    onDismiss: dismiss,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────── Presentation ──────────────────────────

/// The toast card itself. Used by the host, and directly as a static preview
/// (see the toast showcase screen).
class AppToastWidget extends StatelessWidget {
  final String title;
  final String message;
  final ToastType type;
  final VoidCallback? onDismiss;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Fraction of the lifetime left (1 -> 0). Null hides the countdown bar.
  final Animation<double>? progress;

  const AppToastWidget({
    super.key,
    required this.title,
    required this.message,
    this.type = ToastType.success,
    this.onDismiss,
    this.actionLabel,
    this.onAction,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(type);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? style.darkAccent : style.accent;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1F1A) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: isDark ? 0.35 : 0.28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.10),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 6, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ToastIcon(
                    icon: style.icon,
                    color: accent,
                    background: isDark
                        ? accent.withValues(alpha: 0.18)
                        : style.iconBg,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF15221D),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            message,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12.5,
                              height: 1.35,
                              color: isDark
                                  ? const Color(0xFF9FB5AC)
                                  : const Color(0xFF5F6F68),
                            ),
                          ),
                          if (actionLabel != null) ...[
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                onAction?.call();
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Text(
                                  actionLabel!,
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: accent,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  // Dismiss: small, plain ✕ (distinct from the status icon).
                  // No tooltip: the host sits above the Navigator, so there is
                  // no Overlay for a Tooltip to attach to.
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints.tightFor(
                      width: 36,
                      height: 36,
                    ),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      if (onDismiss != null) {
                        onDismiss!();
                      } else {
                        ScaffoldMessenger.maybeOf(
                          context,
                        )?.hideCurrentSnackBar();
                      }
                    },
                    icon: Icon(
                      Icons.close_rounded,
                      semanticLabel: 'Dismiss',
                      size: 18,
                      color: isDark
                          ? const Color(0xFF7C948B)
                          : const Color(0xFF90A4AE),
                    ),
                  ),
                ],
              ),
            ),
            if (progress != null)
              SizedBox(
                height: 3,
                child: AnimatedBuilder(
                  animation: progress!,
                  builder: (context, _) => Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: progress!.value.clamp(0.0, 1.0),
                      child: Container(color: accent.withValues(alpha: 0.6)),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  ToastStyle _styleFor(ToastType type) {
    switch (type) {
      case ToastType.success:
        return const ToastStyle(
          accent: Color(0xFF0B4632),
          darkAccent: Color(0xFF81C784),
          iconBg: Color(0xFFEBF7F0),
          icon: Icons.check_rounded,
        );
      case ToastType.error:
        return const ToastStyle(
          accent: Color(0xFFD64535),
          darkAccent: Color(0xFFFF8A80),
          iconBg: Color(0xFFFFEBEB),
          icon: Icons.error_outline_rounded,
        );
      case ToastType.warning:
        return const ToastStyle(
          accent: Color(0xFFB87F12),
          darkAccent: Color(0xFFF3C06B),
          iconBg: Color(0xFFFFF8E1),
          icon: Icons.warning_amber_rounded,
        );
      case ToastType.info:
        return const ToastStyle(
          accent: Color(0xFF2980B9),
          darkAccent: Color(0xFF64B5F6),
          iconBg: Color(0xFFE6F7FF),
          icon: Icons.info_outline_rounded,
        );
    }
  }
}

/// Status icon that pops in with a slight overshoot.
class _ToastIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;

  const _ToastIcon({
    required this.icon,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.4, end: 1.0),
      duration: const Duration(milliseconds: 520),
      curve: AppMotion.expressive,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}

class ToastStyle {
  /// Accent on light surfaces and its lighter dark-mode counterpart.
  final Color accent;
  final Color darkAccent;
  final Color iconBg;
  final IconData icon;

  const ToastStyle({
    required this.accent,
    required this.darkAccent,
    required this.iconBg,
    required this.icon,
  });
}
