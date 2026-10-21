import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/firebase_service.dart';
import '../widgets/animations/animations.dart';
import 'language_onboarding_screen.dart';
import 'main_navigation_shell.dart';
import '../widgets/islamic_pattern.dart';

const Color _gold = Color(0xFFD49E35);
const Color _goldSoft = Color(0xFFE5B860);
const Color _emerald = Color(0xFF0F593D);
const Color _mint = Color(0xFF81C784);
const Color _ink = Color(0xFF06100C);

const String _bgAsset = 'assets/background/bg_splash_screen.jpg';
const String _logoAsset = 'assets/logo/logo_app.png';

/// Animated splash, built to stay smooth on mid-range phones:
///   - Images are decoded before the first animated frame, so nothing hitches
///     while it plays.
///   - Nothing rebuilds per frame. Every moving part is a transition or a
///     painter listening straight to its animation, and each layer sits in its
///     own [RepaintBoundary] so one layer's motion never repaints another.
///   - No blur filters (they re-blur whatever is behind them on every frame).
///
/// What you see: a slow aurora of emerald and gold light over a darkened
/// photo, drifting gold dust, an eight-point star that draws itself and then
/// turns, the logo emerging inside it, the title in two beats with one gold
/// shimmer, and a slim progress bar. Respects reduced motion.
class SplashScreen extends StatefulWidget {
  final VoidCallback? onFinished;

  const SplashScreen({super.key, this.onFinished});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const Duration _total = Duration(milliseconds: 3000);

  /// One-shot timeline for the entrance choreography.
  late final AnimationController _master;

  /// Endless loop for ambient motion (aurora, dust, star spin, glow breath).
  late final AnimationController _ambient;

  late final Animation<double> _bgFade;
  late final Animation<double> _bgZoom;
  late final Animation<double> _starDraw;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _wordOne;
  late final Animation<double> _wordTwo;
  late final Animation<double> _tagline;
  late final Animation<double> _progress;
  late final Animation<double> _sweep;

  Timer? _timer;
  bool _started = false;
  bool _ticked = false;

  @override
  void initState() {
    super.initState();

    _master = AnimationController(vsync: this, duration: _total);
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    );

    Animation<double> slice(double a, double b, Curve c) => CurvedAnimation(
      parent: _master,
      curve: Interval(a, b, curve: c),
    );

    _bgFade = slice(0.0, 0.3, Curves.easeOut);
    _bgZoom = Tween<double>(
      begin: 1.05,
      end: 1.11,
    ).animate(CurvedAnimation(parent: _master, curve: Curves.linear));
    _starDraw = slice(0.04, 0.5, Curves.easeInOutCubic);
    _logoFade = slice(0.18, 0.42, Curves.easeOut);
    _logoScale = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(slice(0.18, 0.55, AppMotion.expressive));
    _wordOne = slice(0.38, 0.62, Curves.easeOutCubic);
    _wordTwo = slice(0.46, 0.7, Curves.easeOutCubic);
    _tagline = slice(0.62, 0.84, Curves.easeOut);
    _progress = slice(0.2, 0.97, Curves.easeInOutCubic);
    _sweep = slice(0.66, 1.0, Curves.easeInOut);

    _master.addStatusListener((s) {
      if (s == AnimationStatus.completed) _navigate();
    });
    _master.addListener(_hapticOnce);
  }

  void _hapticOnce() {
    if (!_ticked && _master.value >= 0.42) {
      _ticked = true;
      HapticFeedback.lightImpact();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.of(context).disableAnimations) {
      _master.value = 1.0;
      _timer = Timer(const Duration(milliseconds: 900), _navigate);
    } else {
      _begin();
    }
  }

  /// Decode the images first, then let the first frame land, then animate.
  Future<void> _begin() async {
    try {
      await Future.wait([
        precacheImage(const AssetImage(_bgAsset), context),
        precacheImage(const AssetImage(_logoAsset), context),
      ]).timeout(const Duration(milliseconds: 600));
    } catch (_) {
      // Slow disk or missing asset: start anyway.
    }
    if (!mounted) return;
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    _ambient.repeat();
    _master.forward();
  }

  void _navigate() {
    if (!mounted) return;
    _timer?.cancel();
    if (widget.onFinished != null) {
      widget.onFinished!();
      return;
    }
    final bool isLoggedIn = FirebaseService.currentUser != null;
    final Widget target = isLoggedIn
        ? const MainNavigationShell()
        : const LanguageOnboardingScreen();
    Navigator.of(context)
        .pushReplacement(AppPageRoute.fade(target, duration: AppMotion.extra));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _master.dispose();
    _ambient.dispose();
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
        backgroundColor: _ink,
        body: Stack(
          fit: StackFit.expand,
          children: [
            _photo(),
            FadeTransition(
              opacity: _bgFade,
              child: const IslamicPattern(
                color: _goldSoft,
                opacity: 0.07,
                cell: 80,
              ),
            ),
            _aurora(),
            _dust(),
            SafeArea(child: _content()),
          ],
        ),
      ),
    );
  }

  // ─── Background layers ─────────────────────────────────────

  /// Darkened photo with a very slow push-in. The photo and its scrim are one
  /// cached layer; only its transform and opacity change.
  Widget _photo() {
    return RepaintBoundary(
      child: FadeTransition(
        opacity: _bgFade,
        child: ScaleTransition(
          scale: _bgZoom,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                _bgAsset,
                fit: BoxFit.cover,
                color: _ink.withValues(alpha: 0.55),
                colorBlendMode: BlendMode.srcOver,
                errorBuilder: (_, _, _) => const SizedBox(),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _ink.withValues(alpha: 0.8),
                      _ink.withValues(alpha: 0.35),
                      _ink.withValues(alpha: 0.88),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _aurora() {
    return RepaintBoundary(
      child: FadeTransition(
        opacity: _bgFade,
        child: CustomPaint(
          size: Size.infinite,
          painter: _AuroraPainter(_ambient),
        ),
      ),
    );
  }

  Widget _dust() {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: _DustPainter(_ambient, _bgFade),
      ),
    );
  }

  // ─── Foreground ────────────────────────────────────────────

  Widget _content() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(flex: 5),
          SizedBox(
            width: 300,
            height: 300,
            child: Stack(
              alignment: Alignment.center,
              children: [
                RepaintBoundary(
                  child: CustomPaint(
                    size: const Size(300, 300),
                    painter: _StarPainter(draw: _starDraw, spin: _ambient),
                  ),
                ),
                _glow(),
                _logo(),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _title(),
          const SizedBox(height: 14),
          _taglineRow(),
          const Spacer(flex: 4),
          _progressBar(),
          const SizedBox(height: 36),
        ],
      ),
    );
  }

  /// Soft emerald glow that swells and settles. A fixed-size gradient that is
  /// only scaled, so there is nothing to re-layout.
  Widget _glow() {
    return RepaintBoundary(
      child: FadeTransition(
        opacity: _logoFade,
        child: AnimatedBuilder(
          animation: _ambient,
          builder: (context, child) {
            final breathe =
                0.5 + 0.5 * math.sin(_ambient.value * math.pi * 2 * 6);
            return Transform.scale(scale: 0.93 + 0.07 * breathe, child: child);
          },
          child: Container(
            width: 204,
            height: 204,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _emerald.withValues(alpha: 0.55),
                  _emerald.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _logo() {
    return RepaintBoundary(
      child: FadeTransition(
        opacity: _logoFade,
        child: ScaleTransition(
          scale: _logoScale,
          // Translucent disc (no backdrop blur): same look, a fraction of the
          // cost, since it never has to re-blur the moving aurora behind it.
          child: Container(
            width: 132,
            height: 132,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.14),
                  Colors.white.withValues(alpha: 0.04),
                ],
              ),
              border: Border.all(
                color: _goldSoft.withValues(alpha: 0.45),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _emerald.withValues(alpha: 0.55),
                  blurRadius: 36,
                ),
              ],
            ),
            child: Image.asset(
              _logoAsset,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const SizedBox(),
            ),
          ),
        ),
      ),
    );
  }

  /// Two words that rise in one after the other, then one gold shimmer
  /// sweeps across them. Only this layer repaints during the shimmer.
  Widget _title() {
    Widget word(String text, Animation<double> a) {
      return FadeTransition(
        opacity: a,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.35),
            end: Offset.zero,
          ).animate(a),
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 30,
              fontWeight: FontWeight.w700,
              letterSpacing: 5,
              height: 1.1,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _sweep,
        builder: (context, child) {
          final sweep = _sweep.value * 3.0 - 1.0;
          return ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (rect) => LinearGradient(
              begin: Alignment(sweep - 0.5, -0.3),
              end: Alignment(sweep + 0.5, 0.3),
              colors: const [Colors.white, _goldSoft, Colors.white],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(rect),
            child: child,
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            word('RUQYAH', _wordOne),
            const SizedBox(height: 2),
            word('HEALING', _wordTwo),
          ],
        ),
      ),
    );
  }

  Widget _taglineRow() {
    Widget hairline(bool left) => Container(
      width: 28,
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: left
              ? [_gold.withValues(alpha: 0.0), _gold]
              : [_gold, _gold.withValues(alpha: 0.0)],
        ),
      ),
    );

    return RepaintBoundary(
      child: FadeTransition(
        opacity: _tagline,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.5),
            end: Offset.zero,
          ).animate(_tagline),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              hairline(true),
              const SizedBox(width: 12),
              const Text(
                'Faith, Care & Wellbeing',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.1,
                  color: _goldSoft,
                ),
              ),
              const SizedBox(width: 12),
              hairline(false),
            ],
          ),
        ),
      ),
    );
  }

  /// The fill is a full-width bar scaled along x, so its growth is a
  /// transform, not a layout change.
  Widget _progressBar() {
    return RepaintBoundary(
      child: FadeTransition(
        opacity: _logoFade,
        child: Container(
          width: 148,
          height: 5,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(99),
          ),
          child: AnimatedBuilder(
            animation: _progress,
            builder: (context, child) => Transform(
              alignment: Alignment.centerLeft,
              transform: Matrix4.diagonal3Values(_progress.value, 1, 1),
              child: child,
            ),
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [_gold, _goldSoft]),
              ),
              child: SizedBox.expand(),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Painters ────────────────────────────────────────────────
//
// Each painter is handed its animations and passes them to `super(repaint:)`,
// so the render object repaints on every tick without any widget rebuilding.

/// Soft mesh-gradient aurora: a few big radial blobs drifting on slow
/// Lissajous paths.
class _AuroraPainter extends CustomPainter {
  final Animation<double> t;
  _AuroraPainter(this.t) : super(repaint: t);

  @override
  void paint(Canvas canvas, Size size) {
    final a = t.value * math.pi * 2;
    void blob(Offset c, double r, Color color) {
      final rect = Rect.fromCircle(center: c, radius: r);
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = RadialGradient(colors: [color, color.withValues(alpha: 0)])
              .createShader(rect),
      );
    }

    final w = size.width, h = size.height;
    blob(
      Offset(
        w * (0.2 + 0.12 * math.sin(a * 2)),
        h * (0.22 + 0.06 * math.cos(a * 3)),
      ),
      w * 0.9,
      _emerald.withValues(alpha: 0.55),
    );
    blob(
      Offset(
        w * (0.85 + 0.08 * math.cos(a * 3)),
        h * (0.5 + 0.08 * math.sin(a * 2)),
      ),
      w * 0.75,
      _mint.withValues(alpha: 0.16),
    );
    blob(
      Offset(
        w * (0.5 + 0.15 * math.sin(a * 2 + 1)),
        h * (0.88 + 0.04 * math.cos(a * 4)),
      ),
      w * 0.8,
      _gold.withValues(alpha: 0.20),
    );
  }

  @override
  bool shouldRepaint(_AuroraPainter old) => false;
}

/// Eight-point star (two overlapping squares) inside a ring. [draw] traces
/// the outline from 0 to 1; [spin] then turns it slowly.
class _StarPainter extends CustomPainter {
  final Animation<double> draw;
  final Animation<double> spin;
  _StarPainter({required this.draw, required this.spin})
    : super(repaint: Listenable.merge([draw, spin]));

  @override
  void paint(Canvas canvas, Size size) {
    final progress = draw.value;
    if (progress <= 0) return;
    final rotation = spin.value * math.pi * 2 * 2; // 2 turns per 18s loop
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 8;

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [
          _goldSoft.withValues(alpha: 0.9),
          _gold.withValues(alpha: 0.25),
          _goldSoft.withValues(alpha: 0.9),
        ],
        transform: GradientRotation(rotation),
      ).createShader(Rect.fromCircle(center: c, radius: r));

    void trace(Path p) {
      for (final m in p.computeMetrics()) {
        canvas.drawPath(m.extractPath(0, m.length * progress), stroke);
      }
    }

    trace(Path()..addOval(Rect.fromCircle(center: c, radius: r)));
    trace(Path()..addOval(Rect.fromCircle(center: c, radius: r * 0.78)));

    Path square(double angle) {
      final p = Path();
      for (var i = 0; i < 4; i++) {
        final a = angle + i * math.pi / 2;
        final o = c + Offset(math.cos(a), math.sin(a)) * (r * 0.9);
        i == 0 ? p.moveTo(o.dx, o.dy) : p.lineTo(o.dx, o.dy);
      }
      return p..close();
    }

    trace(square(rotation + math.pi / 4));
    trace(square(rotation));

    if (progress > 0.6) {
      final dot = Paint()
        ..color = _goldSoft.withValues(
          alpha: ((progress - 0.6) / 0.4).clamp(0.0, 1.0),
        );
      for (var i = 0; i < 8; i++) {
        final a = rotation + i * math.pi / 4 + math.pi / 4;
        canvas.drawCircle(
          c + Offset(math.cos(a), math.sin(a)) * (r * 0.9),
          2.2,
          dot,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_StarPainter old) => false;
}

/// Sparse gold dust drifting upward. Positions come from the loop value, so
/// there is no per-frame state.
class _DustPainter extends CustomPainter {
  final Animation<double> t;
  final Animation<double> fade;
  _DustPainter(this.t, this.fade) : super(repaint: Listenable.merge([t, fade]));

  static const int _count = 22;

  @override
  void paint(Canvas canvas, Size size) {
    final f = fade.value;
    if (f <= 0) return;
    final tv = t.value;
    final paint = Paint();
    for (var i = 0; i < _count; i++) {
      final seed = (i * 9301 + 49297) % 233280 / 233280.0;
      final seed2 = (i * 7919 + 1237) % 104729 / 104729.0;
      final speed = 1 + (i % 3); // whole loops per cycle -> seamless wrap
      final y = 1.0 - ((tv * speed + seed2) % 1.0);
      final x = seed + 0.03 * math.sin((tv * 6 + seed2 * 6) * math.pi * 2);
      final twinkle = 0.5 + 0.5 * math.sin((tv * 12 + seed) * math.pi * 2);
      paint.color = _goldSoft.withValues(
        alpha: (0.10 + 0.35 * twinkle) * f * math.sin(y * math.pi),
      );
      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        0.8 + 1.6 * seed2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DustPainter old) => false;
}
