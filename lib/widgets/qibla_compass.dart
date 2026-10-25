import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';

import '../services/prayer_location_service.dart';
import '../services/qibla.dart';
import '../theme/app_theme.dart';
import 'islamic_pattern.dart';

const Color _gold = Color(0xFFE2B75E);
const Color _deep = Color(0xFF0B3B2A);

/// Qibla direction: a title, a one-line instruction and a compass card.
///
/// The dial turns with the phone's compass so the gold Kaaba marker sits at
/// the top when you face Qibla. If the device has no compass sensor (some
/// tablets, emulators, the web), the dial can be dragged by hand instead, so
/// the section still works and is easy to try.
class QiblaCompassSection extends StatefulWidget {
  /// Degrees either side of Qibla that count as "facing the Kaaba".
  final double tolerance;

  const QiblaCompassSection({super.key, this.tolerance = 3});

  @override
  State<QiblaCompassSection> createState() => _QiblaCompassSectionState();
}

class _QiblaCompassSectionState extends State<QiblaCompassSection> {
  static const double _dial = 270;

  final ValueNotifier<double> _heading = ValueNotifier<double>(0);
  StreamSubscription<CompassEvent>? _sub;
  bool _sensor = false;
  bool _gotFirst = false;
  bool _wasAligned = false;
  double _lastAngle = 0;

  double get _qibla {
    final p = PrayerLocationService.instance.current;
    return Qibla.bearing(p.latitude, p.longitude);
  }

  double get _km {
    final p = PrayerLocationService.instance.current;
    return Qibla.distanceKm(p.latitude, p.longitude);
  }

  bool get _sensorSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  void initState() {
    super.initState();
    PrayerLocationService.instance.locationNotifier.addListener(_onLocation);
    _heading.addListener(_checkAligned);
    _startSensor();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _heading.removeListener(_checkAligned);
    PrayerLocationService.instance.locationNotifier.removeListener(_onLocation);
    _heading.dispose();
    super.dispose();
  }

  void _onLocation() {
    if (mounted) setState(() {});
  }

  void _startSensor() {
    if (!_sensorSupported) return;
    try {
      final stream = FlutterCompass.events;
      if (stream == null) return;
      _sub = stream.listen(
        (event) {
          final h = event.heading;
          if (h == null) return;
          final target = (h + 360) % 360;
          if (!_gotFirst) {
            _gotFirst = true;
            _heading.value = target;
            if (!_sensor && mounted) setState(() => _sensor = true);
            return;
          }
          // Ease towards the reading so the dial glides instead of jittering.
          _heading.value =
              (_heading.value +
                  Qibla.turn(_heading.value, target) * 0.25 +
                  360) %
              360;
        },
        onError: (_) {
          if (mounted) setState(() => _sensor = false);
        },
      );
    } catch (_) {
      // No sensor available: stay in drag mode.
    }
  }

  void _checkAligned() {
    final aligned =
        Qibla.turn(_heading.value, _qibla).abs() <= widget.tolerance;
    if (aligned && !_wasAligned) HapticFeedback.lightImpact();
    _wasAligned = aligned;
  }

  // ─── Manual turning (when there is no sensor) ──────────────

  double _angleOf(Offset p) =>
      math.atan2(p.dx - _dial / 2, -(p.dy - _dial / 2)) * 180 / math.pi;

  void _panStart(DragStartDetails d) => _lastAngle = _angleOf(d.localPosition);

  void _panUpdate(DragUpdateDetails d) {
    if (_sensor) return;
    final a = _angleOf(d.localPosition);
    final delta = Qibla.turn(_lastAngle, a);
    _lastAngle = a;
    _heading.value = (_heading.value - delta + 360) % 360;
  }

  void _nudge(double deg) {
    if (_sensor) return;
    _heading.value = (_heading.value + deg + 360) % 360;
  }

  // ─── UI ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final qibla = _qibla;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.accentGold,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                'Qibla direction',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                'القبلة',
                style: TextStyle(fontSize: 14, color: context.textSecondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Text(
            'Hold your phone flat and turn slowly until the gold arc closes at '
            'the top.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.5,
              height: 1.45,
              color: context.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 14),
        _card(context, qibla),
      ],
    );
  }

  Widget _card(BuildContext context, double qibla) {
    const radius = BorderRadius.all(Radius.circular(24));
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      foregroundDecoration: const IslamicPatternDecoration(
        radius: radius,
        opacity: 0.06,
        cell: 56,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0E4A34), _deep],
        ),
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0E2D20).withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Center(child: _dialView(qibla)),
          const SizedBox(height: 10),
          if (!_sensor) ...[
            Text(
              _sensorSupported
                  ? 'Looking for your compass. You can also drag the dial.'
                  : 'No compass sensor here. Drag the dial to try it.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
          ],
          ValueListenableBuilder<double>(
            valueListenable: _heading,
            builder: (context, h, _) {
              final style = TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.85),
              );
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Heading ${h.round() % 360}° ${Qibla.cardinal(h)}',
                      style: style,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      'Qibla ${qibla.round()}° ${Qibla.cardinal(qibla)}',
                      style: style,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.14)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.account_balance_outlined,
                      size: 18,
                      color: _gold,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        'Makkah · ${Qibla.groupThousands(_km.round())} km',
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  _showCalibrate(context);
                },
                style: TextButton.styleFrom(
                  foregroundColor: _gold,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  minimumSize: const Size(44, 44),
                ),
                child: const Text(
                  'Calibrate',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dialView(double qibla) {
    return ValueListenableBuilder<double>(
      valueListenable: _heading,
      builder: (context, h, _) {
        final diff = Qibla.turn(h, qibla);
        final aligned = diff.abs() <= widget.tolerance;
        return Semantics(
          slider: !_sensor,
          label: 'Compass heading',
          value:
              '${h.round() % 360} degrees, ${Qibla.cardinal(h)}. '
              '${aligned ? 'Facing Qibla' : '${diff.abs().round()} degrees ${diff > 0 ? 'right' : 'left'} of Qibla'}',
          // Screen readers need the value each nudge would produce.
          increasedValue: _sensor ? null : '${((h + 5) % 360).round()} degrees',
          decreasedValue: _sensor
              ? null
              : '${((h - 5 + 360) % 360).round()} degrees',
          onIncrease: _sensor ? null : () => _nudge(5),
          onDecrease: _sensor ? null : () => _nudge(-5),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: _panStart,
            onPanUpdate: _panUpdate,
            child: SizedBox(
              width: _dial,
              height: _dial,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  RepaintBoundary(
                    child: CustomPaint(
                      size: const Size(_dial, _dial),
                      painter: _DialPainter(
                        heading: _heading,
                        qibla: qibla,
                        tolerance: widget.tolerance,
                      ),
                    ),
                  ),
                  IgnorePointer(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: aligned
                          ? const [
                              Text(
                                'Qibla',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1.1,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'You are facing the Kaaba',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _gold,
                                ),
                              ),
                            ]
                          : [
                              Text(
                                '${diff.abs().round()}°',
                                style: const TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1.05,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                diff > 0
                                    ? 'Turn right to face Qibla'
                                    : 'Turn left to face Qibla',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _gold,
                                ),
                              ),
                            ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCalibrate(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _CalibrateSheet(),
    );
  }
}

// ─── The dial ────────────────────────────────────────────────

/// Draws the compass ring: tick marks and labels that turn with the phone, a
/// gold marker for the Kaaba, a gold arc showing how far to turn, and a fixed
/// index at the top. Repaints straight from the heading, with no rebuilds.
class _DialPainter extends CustomPainter {
  final ValueListenable<double> heading;
  final double qibla;
  final double tolerance;

  _DialPainter({
    required this.heading,
    required this.qibla,
    required this.tolerance,
  }) : super(repaint: heading);

  static const double _r = 132; // ring radius in the design's 300x300 space

  static double _rad(double d) => d * math.pi / 180;

  // Labels are laid out once.
  static final Map<int, TextPainter> _labels = () {
    final m = <int, TextPainter>{};
    const cardinals = {0: 'N', 90: 'E', 180: 'S', 270: 'W'};
    for (var a = 0; a < 360; a += 30) {
      final isCardinal = cardinals.containsKey(a);
      final tp = TextPainter(
        text: TextSpan(
          text: isCardinal ? cardinals[a] : '$a',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: isCardinal ? FontWeight.w800 : FontWeight.w500,
            fontSize: isCardinal ? 16 : 10,
            color: (a == 0 ? _gold : Colors.white).withValues(
              alpha: isCardinal ? 1 : 0.6,
            ),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      m[a] = tp;
    }
    return m;
  }();

  @override
  void paint(Canvas canvas, Size size) {
    final h = heading.value;
    final diff = Qibla.turn(h, qibla);
    final aligned = diff.abs() <= tolerance;

    // The design is a 300x300 box with its centre 8px below the middle.
    final s = size.width / 300;
    canvas.save();
    canvas.translate(150 * s, 158 * s);
    canvas.scale(s);

    // Fixed track.
    canvas.drawCircle(
      Offset.zero,
      _r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..color = aligned ? _gold : Colors.white.withValues(alpha: 0.18),
    );

    // Everything that turns with the phone.
    canvas.save();
    canvas.rotate(-_rad(h));

    final tick = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (var a = 0; a < 360; a += 5) {
      final major = a % 30 == 0;
      final len = major ? 10.0 : 5.0;
      const r0 = _r - 14;
      final sn = math.sin(_rad(a.toDouble()));
      final cs = -math.cos(_rad(a.toDouble()));
      tick
        ..strokeWidth = major ? 2 : 1
        ..color = Colors.white.withValues(alpha: major ? 0.7 : 0.3);
      canvas.drawLine(
        Offset(sn * r0, cs * r0),
        Offset(sn * (r0 - len), cs * (r0 - len)),
        tick,
      );
    }

    for (final e in _labels.entries) {
      canvas.save();
      canvas.rotate(_rad(e.key.toDouble()));
      canvas.translate(0, -(_r - 40));
      e.value.paint(canvas, Offset(-e.value.width / 2, -e.value.height / 2));
      canvas.restore();
    }

    // Kaaba marker, kept upright on screen.
    canvas.save();
    canvas.rotate(_rad(qibla));
    canvas.translate(0, -_r);
    canvas.drawCircle(Offset.zero, 15, Paint()..color = _gold);
    canvas.drawCircle(
      Offset.zero,
      15,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = _deep,
    );
    canvas.rotate(-_rad(qibla - h));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-6.5, -6.5, 13, 13),
        const Radius.circular(1.5),
      ),
      Paint()..color = _deep,
    );
    canvas.drawRect(
      const Rect.fromLTWH(-6.5, -3.5, 13, 2.5),
      Paint()..color = _gold,
    );
    canvas.restore();

    canvas.restore(); // end of the turning group

    // Gold arc from the top towards Qibla: how far to turn.
    if (!aligned && diff.abs() > 0.5) {
      final rect = Rect.fromCircle(center: Offset.zero, radius: _r);
      canvas.drawArc(
        rect,
        -math.pi / 2,
        _rad(diff),
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFC9932F), Color(0xFFF0CF85)],
          ).createShader(rect),
      );
    }

    // Fixed index at the top.
    canvas.drawPath(
      Path()
        ..moveTo(-7, -_r - 22)
        ..lineTo(7, -_r - 22)
        ..lineTo(0, -_r - 11)
        ..close(),
      Paint()..color = aligned ? _gold : Colors.white,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(_DialPainter old) =>
      old.qibla != qibla || old.tolerance != tolerance;
}

// ─── Calibrate sheet ─────────────────────────────────────────

class _CalibrateSheet extends StatefulWidget {
  const _CalibrateSheet();

  @override
  State<_CalibrateSheet> createState() => _CalibrateSheetState();
}

class _CalibrateSheetState extends State<_CalibrateSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 5));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + bottom),
      decoration: const BoxDecoration(
        color: Color(0xFF0B3B2A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Calibrate your compass',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: 160,
            height: 90,
            child: RepaintBoundary(
              child: CustomPaint(painter: _FigureEightPainter(_c)),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Move your phone slowly in a figure-eight a few times, then hold it '
            'flat. Keep away from magnets, speakers and metal cases.\n\n'
            'A phone compass points to magnetic north, which can differ a few '
            'degrees from true north depending on where you are.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13.5,
              height: 1.55,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _gold,
                foregroundColor: const Color(0xFF1A1405),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Done',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A figure-eight with a dot travelling around it.
class _FigureEightPainter extends CustomPainter {
  final Animation<double> t;
  _FigureEightPainter(this.t) : super(repaint: t);

  Offset _at(double u, Size size) {
    final a = u * math.pi * 2;
    return Offset(
      size.width / 2 + (size.width / 2 - 8) * math.sin(a),
      size.height / 2 + (size.height / 2 - 8) * math.sin(2 * a) / 2,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()..moveTo(_at(0, size).dx, _at(0, size).dy);
    for (var i = 1; i <= 120; i++) {
      final p = _at(i / 120, size);
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.25),
    );
    canvas.drawCircle(_at(t.value, size), 6, Paint()..color = _gold);
  }

  @override
  bool shouldRepaint(_FigureEightPainter old) => false;
}
