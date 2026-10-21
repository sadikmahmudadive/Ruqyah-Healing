import 'package:flutter/material.dart';

/// Flat vector illustrations drawn in code, in the app's emerald and gold
/// palette, so they scale cleanly and need no image assets. Each one has a
/// light and a dark variant (dark swaps the pale tints for deep greens).
class _Palette {
  final Color tint; // soft circle behind the scene
  final Color deep;
  final Color mid;
  final Color light;
  final Color gold;
  final Color goldSoft;
  final Color ground;

  const _Palette({
    required this.tint,
    required this.deep,
    required this.mid,
    required this.light,
    required this.gold,
    required this.goldSoft,
    required this.ground,
  });

  static const lightMode = _Palette(
    tint: Color(0xFFEBF7F0),
    deep: Color(0xFF0B4632),
    mid: Color(0xFF1E6B45),
    light: Color(0xFF81C784),
    gold: Color(0xFFD49E35),
    goldSoft: Color(0xFFF3C06B),
    ground: Color(0xFFCFE8D9),
  );

  static const darkMode = _Palette(
    tint: Color(0xFF1B3A2E),
    deep: Color(0xFF0F5A3F),
    mid: Color(0xFF2E8B5E),
    light: Color(0xFF81C784),
    gold: Color(0xFFD49E35),
    goldSoft: Color(0xFFF3C06B),
    ground: Color(0xFF14513A),
  );

  static _Palette of(bool dark) => dark ? darkMode : lightMode;
}

Paint _fill(Color c) => Paint()..color = c;

/// Four-pointed sparkle centred on [c] with radius [r].
void _sparkle(Canvas canvas, Offset c, double r, Paint paint) {
  final k = r * 0.28;
  final p = Path()
    ..moveTo(c.dx, c.dy - r)
    ..quadraticBezierTo(c.dx + k, c.dy - k, c.dx + r, c.dy)
    ..quadraticBezierTo(c.dx + k, c.dy + k, c.dx, c.dy + r)
    ..quadraticBezierTo(c.dx - k, c.dy + k, c.dx - r, c.dy)
    ..quadraticBezierTo(c.dx - k, c.dy - k, c.dx, c.dy - r)
    ..close();
  canvas.drawPath(p, paint);
}

/// A crescent: a disc with a smaller, offset disc cut out of it.
void _crescent(Canvas canvas, Offset c, double r, Paint paint) {
  final disc = Path()..addOval(Rect.fromCircle(center: c, radius: r));
  final bite = Path()
    ..addOval(
      Rect.fromCircle(
        center: c.translate(r * 0.42, -r * 0.2),
        radius: r * 0.82,
      ),
    );
  canvas.drawPath(Path.combine(PathOperation.difference, disc, bite), paint);
}

/// Dome: the upper half of an ellipse sitting on [baseY].
Path _dome(double cx, double baseY, double rx, double ry) {
  return Path()
    ..moveTo(cx - rx, baseY)
    ..arcTo(
      Rect.fromCenter(center: Offset(cx, baseY), width: rx * 2, height: ry * 2),
      3.14159265,
      3.14159265,
      false,
    )
    ..close();
}

/// A minaret: shaft, balcony, and a pointed cap with a gold tip.
void _minaret(
  Canvas canvas,
  double cx,
  double baseY,
  double topY,
  double halfWidth,
  _Palette p,
) {
  // shaft
  canvas.drawRect(
    Rect.fromLTRB(cx - halfWidth, topY, cx + halfWidth, baseY),
    _fill(p.mid),
  );
  // balcony
  canvas.drawRRect(
    RRect.fromLTRBR(
      cx - halfWidth - 2.5,
      topY + 10,
      cx + halfWidth + 2.5,
      topY + 14,
      const Radius.circular(1.5),
    ),
    _fill(p.deep),
  );
  // cap
  final cap = Path()
    ..moveTo(cx - halfWidth - 1.5, topY)
    ..lineTo(cx, topY - 15)
    ..lineTo(cx + halfWidth + 1.5, topY)
    ..close();
  canvas.drawPath(cap, _fill(p.deep));
  canvas.drawCircle(Offset(cx, topY - 17), 1.8, _fill(p.gold));
  // window
  canvas.drawRRect(
    RRect.fromLTRBR(
      cx - 1.6,
      topY + 20,
      cx + 1.6,
      topY + 28,
      const Radius.circular(1.6),
    ),
    _fill(p.goldSoft),
  );
}

// ───────────────────────────── welcome scene ───────────────────────────

/// Mosque at dusk with a crescent and stars. Design size 160 x 120.
class MosqueSceneIllustration extends StatelessWidget {
  final double width;
  final double height;

  const MosqueSceneIllustration({super.key, this.width = 130, this.height = 98});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return CustomPaint(
      size: Size(width, height),
      painter: _MosqueScenePainter(dark),
    );
  }
}

class _MosqueScenePainter extends CustomPainter {
  final bool dark;
  _MosqueScenePainter(this.dark);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 160, size.height / 120);
    final p = _Palette.of(dark);

    // Sky disc
    canvas.drawCircle(const Offset(80, 64), 54, _fill(p.tint));

    // Crescent and stars
    _crescent(canvas, const Offset(112, 32), 14, _fill(p.gold));
    _sparkle(canvas, const Offset(30, 28), 5.5, _fill(p.goldSoft));
    _sparkle(canvas, const Offset(132, 62), 4, _fill(p.goldSoft));
    _sparkle(canvas, const Offset(54, 14), 3.2, _fill(p.gold));
    canvas.drawCircle(const Offset(138, 18), 1.6, _fill(p.goldSoft));
    canvas.drawCircle(const Offset(22, 52), 1.6, _fill(p.gold));

    // Hills
    final hill = Path()
      ..moveTo(0, 104)
      ..quadraticBezierTo(40, 88, 80, 100)
      ..quadraticBezierTo(122, 90, 160, 104)
      ..lineTo(160, 112)
      ..lineTo(0, 112)
      ..close();
    canvas.drawPath(hill, _fill(p.ground));

    // Minarets
    _minaret(canvas, 28, 106, 52, 4, p);
    _minaret(canvas, 132, 106, 52, 4, p);

    // Side halls with small domes
    canvas.drawRect(const Rect.fromLTRB(40, 90, 62, 106), _fill(p.mid));
    canvas.drawPath(_dome(51, 90, 11, 11), _fill(p.deep));
    canvas.drawRect(const Rect.fromLTRB(98, 90, 120, 106), _fill(p.mid));
    canvas.drawPath(_dome(109, 90, 11, 11), _fill(p.deep));

    // Main hall + big dome
    canvas.drawRect(const Rect.fromLTRB(58, 78, 102, 106), _fill(p.deep));
    canvas.drawPath(_dome(80, 78, 24, 26), _fill(p.mid));
    // dome highlight
    final shine = Path()
      ..moveTo(68, 70)
      ..quadraticBezierTo(72, 60, 80, 56);
    canvas.drawPath(
      shine,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..color = p.light.withValues(alpha: 0.7),
    );
    // finial
    canvas.drawRect(const Rect.fromLTRB(79.2, 44, 80.8, 54), _fill(p.gold));
    canvas.drawCircle(const Offset(80, 42), 2.6, _fill(p.gold));

    // Arched door and windows
    final door = Path()
      ..moveTo(73, 106)
      ..lineTo(73, 94)
      ..arcTo(
        Rect.fromCenter(center: const Offset(80, 94), width: 14, height: 14),
        3.14159265,
        3.14159265,
        false,
      )
      ..lineTo(87, 106)
      ..close();
    canvas.drawPath(door, _fill(p.goldSoft));
    for (final x in [64.0, 91.0]) {
      final w = Path()
        ..moveTo(x, 98)
        ..lineTo(x, 91)
        ..arcTo(
          Rect.fromCenter(center: Offset(x + 2.5, 91), width: 5, height: 6),
          3.14159265,
          3.14159265,
          false,
        )
        ..lineTo(x + 5, 98)
        ..close();
      canvas.drawPath(w, _fill(p.gold));
    }

    // Ground strip and bushes
    canvas.drawRRect(
      RRect.fromLTRBR(14, 106, 146, 112, const Radius.circular(3)),
      _fill(p.deep),
    );
    canvas.drawCircle(const Offset(20, 106), 5, _fill(p.light));
    canvas.drawCircle(const Offset(27, 107), 4, _fill(p.mid));
    canvas.drawCircle(const Offset(140, 106), 5, _fill(p.light));
    canvas.drawCircle(const Offset(133, 107), 4, _fill(p.mid));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MosqueScenePainter old) => old.dark != dark;
}

// ──────────────────────────── header skyline ───────────────────────────

/// Soft mosque skyline for the bottom of a green header. Drawn in a single
/// translucent colour so it sits quietly behind the title.
class SkylineIllustration extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const SkylineIllustration({
    super.key,
    this.width = 190,
    this.height = 64,
    this.color = const Color(0x1FFFFFFF),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _SkylinePainter(color),
    );
  }
}

class _SkylinePainter extends CustomPainter {
  final Color color;
  _SkylinePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 190, size.height / 64);
    final paint = _fill(color);
    const base = 64.0;

    // left minaret
    canvas.drawRect(const Rect.fromLTRB(14, 24, 22, base), paint);
    canvas.drawPath(
      Path()
        ..moveTo(12, 24)
        ..lineTo(18, 8)
        ..lineTo(24, 24)
        ..close(),
      paint,
    );
    // small hall + dome
    canvas.drawRect(const Rect.fromLTRB(30, 46, 62, base), paint);
    canvas.drawPath(_dome(46, 46, 14, 14), paint);
    // grand dome
    canvas.drawRect(const Rect.fromLTRB(70, 38, 126, base), paint);
    canvas.drawPath(_dome(98, 38, 28, 30), paint);
    canvas.drawRect(const Rect.fromLTRB(97.2, 2, 98.8, 10), paint);
    // second small dome
    canvas.drawRect(const Rect.fromLTRB(134, 48, 160, base), paint);
    canvas.drawPath(_dome(147, 48, 13, 12), paint);
    // right minaret
    canvas.drawRect(const Rect.fromLTRB(166, 20, 174, base), paint);
    canvas.drawPath(
      Path()
        ..moveTo(164, 20)
        ..lineTo(170, 4)
        ..lineTo(176, 20)
        ..close(),
      paint,
    );
    // crescent over the grand dome
    _crescent(canvas, const Offset(98, -2), 5, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SkylinePainter old) => old.color != color;
}

// ───────────────────────────── live session ────────────────────────────

/// Microphone with sound waves and a crescent: a live recitation / Q&A.
/// Design size 100 x 100.
class LiveSessionIllustration extends StatelessWidget {
  final double size;

  const LiveSessionIllustration({super.key, this.size = 84});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return CustomPaint(
      size: Size.square(size),
      painter: _LiveSessionPainter(dark),
    );
  }
}

class _LiveSessionPainter extends CustomPainter {
  final bool dark;
  _LiveSessionPainter(this.dark);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 100);
    final p = _Palette.of(dark);

    canvas.drawCircle(const Offset(50, 52), 44, _fill(p.tint));

    // sound waves
    final wave = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = p.gold;
    final faint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = p.goldSoft.withValues(alpha: 0.75);
    for (final entry in [(22.0, wave), (31.0, faint)]) {
      final r = entry.$1;
      final rect = Rect.fromCircle(center: const Offset(50, 40), radius: r);
      canvas.drawArc(rect, -0.62, 1.24, false, entry.$2); // right side
      canvas.drawArc(rect, 3.14159 - 0.62, 1.24, false, entry.$2); // left side
    }

    // stand: cradle arc, stem, base
    final stand = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = p.mid;
    canvas.drawArc(
      Rect.fromCenter(center: const Offset(50, 44), width: 36, height: 38),
      0.2,
      2.74,
      false,
      stand,
    );
    canvas.drawLine(const Offset(50, 63), const Offset(50, 76), stand);
    canvas.drawRRect(
      RRect.fromLTRBR(37, 76, 63, 81, const Radius.circular(2.5)),
      _fill(p.deep),
    );

    // mic capsule
    final capsule = RRect.fromLTRBR(41, 17, 59, 53, const Radius.circular(9));
    canvas.drawRRect(capsule, _fill(p.deep));
    // grille lines
    final grille = Paint()
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..color = p.light.withValues(alpha: 0.85);
    for (final y in [27.0, 33.0, 39.0]) {
      canvas.drawLine(Offset(45.5, y), Offset(54.5, y), grille);
    }

    // crescent + sparkle
    _crescent(canvas, const Offset(80, 22), 7.5, _fill(p.gold));
    _sparkle(canvas, const Offset(20, 24), 3.6, _fill(p.goldSoft));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LiveSessionPainter old) => old.dark != dark;
}

// ───────────────────────── service + empty-state set ───────────────────

enum FlatIllustrationKind {
  hijama,
  acupuncture,
  acupressure,
  ayurvedic,
  unani,
  medicine,
  pathology,
  emptyNotifications,
  emptyBookings,
  bookingSuccess,
  orderSuccess,
  certificate,
  learn,
  community,
  guest,
  premium,
}

/// One flat illustration per service hub, plus two for empty states. All are
/// drawn on a 100 x 100 canvas and tinted by the service's accent colour.
class FlatIllustration extends StatelessWidget {
  final FlatIllustrationKind kind;
  final double size;

  /// Force the dark (true) or light (false) palette instead of following the
  /// theme. For surfaces whose colour doesn't change with the theme, such as
  /// a green gradient banner (dark) or an always-white dialog (light).
  final bool? dark;

  const FlatIllustration({
    super.key,
    required this.kind,
    this.size = 84,
    this.dark,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = dark ?? Theme.of(context).brightness == Brightness.dark;
    return CustomPaint(
      size: Size.square(size),
      painter: _FlatPainter(kind, isDark),
    );
  }
}

class _FlatPainter extends CustomPainter {
  final FlatIllustrationKind kind;
  final bool dark;
  _FlatPainter(this.kind, this.dark);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 100);
    final p = _Palette.of(dark);
    switch (kind) {
      case FlatIllustrationKind.hijama:
        _drawHijama(canvas, p, dark);
      case FlatIllustrationKind.acupuncture:
        _drawAcupuncture(canvas, p, dark);
      case FlatIllustrationKind.acupressure:
        _drawAcupressure(canvas, p, dark);
      case FlatIllustrationKind.ayurvedic:
        _drawAyurvedic(canvas, p, dark);
      case FlatIllustrationKind.unani:
        _drawUnani(canvas, p, dark);
      case FlatIllustrationKind.medicine:
        _drawMedicine(canvas, p, dark);
      case FlatIllustrationKind.pathology:
        _drawPathology(canvas, p, dark);
      case FlatIllustrationKind.emptyNotifications:
        _drawBell(canvas, p, dark);
      case FlatIllustrationKind.emptyBookings:
        _drawCalendar(canvas, p, dark);
      case FlatIllustrationKind.bookingSuccess:
        _drawBookingSuccess(canvas, p, dark);
      case FlatIllustrationKind.orderSuccess:
        _drawOrderSuccess(canvas, p, dark);
      case FlatIllustrationKind.certificate:
        _drawCertificate(canvas, p, dark);
      case FlatIllustrationKind.learn:
        _drawLearn(canvas, p, dark);
      case FlatIllustrationKind.community:
        _drawCommunity(canvas, p, dark);
      case FlatIllustrationKind.guest:
        _drawGuest(canvas, p, dark);
      case FlatIllustrationKind.premium:
        _drawPremium(canvas, p, dark);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FlatPainter old) =>
      old.kind != kind || old.dark != dark;
}

Color _skin(bool dark) =>
    dark ? const Color(0xFFC99A6E) : const Color(0xFFF2CDA8);

void _tint(Canvas canvas, Color accent, bool dark) {
  canvas.drawCircle(
    const Offset(50, 52),
    44,
    _fill(accent.withValues(alpha: dark ? 0.2 : 0.14)),
  );
}

Paint _stroke(Color c, double w) => Paint()
  ..style = PaintingStyle.stroke
  ..strokeWidth = w
  ..strokeCap = StrokeCap.round
  ..color = c;

/// A leaf from [base] to [tip], bulging by [width] on both sides.
void _leaf(
  Canvas canvas,
  Offset base,
  Offset tip,
  double width,
  Color color,
  Color vein,
) {
  final d = tip - base;
  final len = d.distance;
  final n = Offset(-d.dy / len, d.dx / len);
  final mid = Offset.lerp(base, tip, 0.5)!;
  final path = Path()
    ..moveTo(base.dx, base.dy)
    ..quadraticBezierTo(
      mid.dx + n.dx * width * 1.6,
      mid.dy + n.dy * width * 1.6,
      tip.dx,
      tip.dy,
    )
    ..quadraticBezierTo(
      mid.dx - n.dx * width * 1.6,
      mid.dy - n.dy * width * 1.6,
      base.dx,
      base.dy,
    )
    ..close();
  canvas.drawPath(path, _fill(color));
  canvas.drawLine(base, Offset.lerp(base, tip, 0.85)!, _stroke(vein, 1.2));
}

// Hijama: three cupping cups on a back, warm orange.
void _drawHijama(Canvas canvas, _Palette p, bool dark) {
  const orange = Color(0xFFE07B39);
  const orangeDeep = Color(0xFFB9531C);
  _tint(canvas, orange, dark);

  canvas.drawRRect(
    RRect.fromLTRBR(14, 66, 86, 83, const Radius.circular(8.5)),
    _fill(_skin(dark)),
  );

  void cup(double cx, double baseY, double rx, double ry) {
    canvas.drawPath(_dome(cx, baseY, rx, ry), _fill(orange));
    canvas.drawPath(
      Path()
        ..moveTo(cx - rx * 0.6, baseY - ry * 0.3)
        ..quadraticBezierTo(
          cx - rx * 0.5,
          baseY - ry * 0.8,
          cx - rx * 0.1,
          baseY - ry * 0.88,
        ),
      _stroke(Colors.white.withValues(alpha: 0.6), 2),
    );
    canvas.drawRRect(
      RRect.fromLTRBR(
        cx - rx - 2,
        baseY - 1,
        cx + rx + 2,
        baseY + 4,
        const Radius.circular(2),
      ),
      _fill(orangeDeep),
    );
    // valve knob
    canvas.drawRRect(
      RRect.fromLTRBR(
        cx - 2.5,
        baseY - ry - 5,
        cx + 2.5,
        baseY - ry + 1,
        const Radius.circular(1.5),
      ),
      _fill(p.gold),
    );
  }

  cup(27, 69, 11, 14);
  cup(50, 68, 13, 19);
  cup(73, 69, 11, 14);

  _crescent(canvas, const Offset(80, 24), 7, _fill(p.gold));
  _sparkle(canvas, const Offset(22, 28), 3.8, _fill(p.goldSoft));
}

// Acupuncture: needles with gold handles, marking points on the skin.
void _drawAcupuncture(Canvas canvas, _Palette p, bool dark) {
  const blue = Color(0xFF2980B9);
  final steel = dark ? const Color(0xFFB8C7D3) : const Color(0xFFD5E0E9);
  _tint(canvas, blue, dark);

  canvas.drawRRect(
    RRect.fromLTRBR(16, 70, 84, 84, const Radius.circular(7)),
    _fill(_skin(dark)),
  );

  void needle(Offset base, Offset top) {
    canvas.drawLine(base, top, _stroke(steel, 2.2));
    final dir = (top - base) / (top - base).distance;
    // handle (gold, thicker) at the top end
    canvas.drawLine(top, top + dir * 9, _stroke(p.gold, 4));
    canvas.drawCircle(top + dir * 11, 2.4, _fill(p.goldSoft));
    // point marker on the skin
    canvas.drawCircle(base, 4.6, _stroke(blue.withValues(alpha: 0.65), 1.6));
    canvas.drawCircle(base, 1.8, _fill(blue));
  }

  needle(const Offset(32, 73), const Offset(22, 38));
  needle(const Offset(50, 73), const Offset(50, 32));
  needle(const Offset(68, 73), const Offset(78, 38));

  // qi ripple
  canvas.drawArc(
    Rect.fromCircle(center: const Offset(50, 73), radius: 12),
    3.4,
    2.6,
    false,
    _stroke(blue.withValues(alpha: 0.35), 1.6),
  );
  _crescent(canvas, const Offset(82, 22), 6.5, _fill(p.gold));
  _sparkle(canvas, const Offset(18, 24), 3.6, _fill(p.goldSoft));
}

// Acupressure: human palm with targeted pressure-point stimulation and energy pulse waves.
void _drawAcupressure(Canvas canvas, _Palette p, bool dark) {
  const coral = Color(0xFFC86D51);
  const coralDeep = Color(0xFFA04B32);
  _tint(canvas, coral, dark);

  // Stylized resting palm / hand
  final handPath = Path()
    ..moveTo(24, 76)
    ..quadraticBezierTo(20, 60, 28, 48)
    ..quadraticBezierTo(32, 42, 38, 46)
    ..lineTo(42, 54)
    ..lineTo(44, 38)
    ..quadraticBezierTo(46, 30, 52, 32)
    ..quadraticBezierTo(56, 34, 56, 42)
    ..lineTo(56, 54)
    ..lineTo(58, 36)
    ..quadraticBezierTo(60, 28, 66, 30)
    ..quadraticBezierTo(70, 32, 70, 42)
    ..lineTo(70, 58)
    ..lineTo(72, 44)
    ..quadraticBezierTo(74, 38, 80, 40)
    ..quadraticBezierTo(84, 42, 82, 52)
    ..lineTo(80, 68)
    ..quadraticBezierTo(78, 82, 60, 84)
    ..lineTo(36, 84)
    ..close();
  canvas.drawPath(handPath, _fill(_skin(dark)));

  // Center pressure focal point (e.g. PC 8 / Laogong point)
  const acupoint = Offset(52, 62);
  canvas.drawCircle(acupoint, 4.5, _fill(coralDeep));
  canvas.drawCircle(acupoint, 2.2, _fill(p.goldSoft));

  // Radiating tactile energy ripples
  for (int r = 10; r <= 22; r += 6) {
    canvas.drawArc(
      Rect.fromCircle(center: acupoint, radius: r.toDouble()),
      0,
      6.28318,
      false,
      _stroke(coral.withValues(alpha: 0.65 - (r - 10) * 0.025), 1.6),
    );
  }

  _crescent(canvas, const Offset(82, 22), 6.5, _fill(p.gold));
  _sparkle(canvas, const Offset(18, 26), 3.6, _fill(p.goldSoft));
}

// Ayurvedic: mortar and pestle with herbs and a flower.
void _drawAyurvedic(Canvas canvas, _Palette p, bool dark) {
  const leaf = Color(0xFF27AE60);
  const leafDeep = Color(0xFF1E8449);
  const wood = Color(0xFFD9A15B);
  _tint(canvas, leaf, dark);

  // herbs behind the bowl
  _leaf(canvas, const Offset(44, 62), const Offset(28, 34), 7, p.light, leafDeep);
  _leaf(canvas, const Offset(50, 62), const Offset(50, 24), 8, leaf, leafDeep);
  _leaf(canvas, const Offset(56, 62), const Offset(74, 36), 7, p.light, leafDeep);

  // pestle, leaning out of the bowl
  canvas.drawLine(const Offset(62, 70), const Offset(82, 40), _stroke(wood, 7));
  canvas.drawCircle(const Offset(82, 40), 4.2, _fill(const Color(0xFFC4883F)));

  // bowl
  final bowl = Path()
    ..moveTo(22, 60)
    ..lineTo(78, 60)
    ..cubicTo(78, 78, 66, 87, 50, 87)
    ..cubicTo(34, 87, 22, 78, 22, 60)
    ..close();
  canvas.drawPath(bowl, _fill(p.deep));
  canvas.drawPath(
    Path()
      ..moveTo(28, 66)
      ..quadraticBezierTo(31, 77, 40, 81),
    _stroke(p.light.withValues(alpha: 0.5), 2),
  );
  canvas.drawRRect(
    RRect.fromLTRBR(19, 57, 81, 63, const Radius.circular(3)),
    _fill(p.mid),
  );
  canvas.drawRRect(
    RRect.fromLTRBR(40, 86, 60, 90, const Radius.circular(2)),
    _fill(p.mid),
  );

  // flower
  const fc = Offset(22, 44);
  for (var i = 0; i < 5; i++) {
    final a = i * 6.2832 / 5;
    canvas.drawCircle(fc + Offset.fromDirection(a, 5), 3.6, _fill(p.goldSoft));
  }
  canvas.drawCircle(fc, 3, _fill(p.gold));

  _sparkle(canvas, const Offset(82, 20), 3.6, _fill(p.goldSoft));
}

// Unani: classical apothecary flask with herbal tonic, kalonji bloom and leaf.
void _drawUnani(Canvas canvas, _Palette p, bool dark) {
  const amber = Color(0xFFC59236);
  const amberDeep = Color(0xFF8D6E63);
  _tint(canvas, amber, dark);

  // Apothecary glass flask
  final flask = Path()
    ..moveTo(42, 34)
    ..lineTo(58, 34)
    ..lineTo(56, 44)
    ..lineTo(76, 76)
    ..cubicTo(78, 82, 72, 86, 64, 86)
    ..lineTo(36, 86)
    ..cubicTo(28, 86, 22, 82, 24, 76)
    ..lineTo(44, 44)
    ..close();
  canvas.drawPath(flask, _fill(dark ? const Color(0xFF1B3026) : const Color(0xFFFAF6EE)));
  canvas.drawPath(flask, _stroke(amberDeep, 2.0));

  // Liquid tonic inside flask
  final liquid = Path()
    ..moveTo(27, 72)
    ..quadraticBezierTo(40, 68, 50, 72)
    ..quadraticBezierTo(60, 76, 73, 72)
    ..lineTo(70, 78)
    ..cubicTo(68, 84, 62, 85, 50, 85)
    ..cubicTo(38, 85, 32, 84, 30, 78)
    ..close();
  canvas.drawPath(liquid, _fill(p.gold.withValues(alpha: 0.85)));

  // Flask stopper/lip
  canvas.drawRRect(
    RRect.fromLTRBR(39, 30, 61, 35, const Radius.circular(2.5)),
    _fill(amberDeep),
  );

  // Healing botanical sprig (olive / black seed leaf)
  _leaf(canvas, const Offset(50, 36), const Offset(68, 18), 6, p.light, p.deep);
  _leaf(canvas, const Offset(50, 36), const Offset(36, 20), 5, p.light, p.deep);

  // Nigella flower star
  _sparkle(canvas, const Offset(68, 18), 4.2, _fill(p.goldSoft));
  _crescent(canvas, const Offset(18, 22), 6.5, _fill(p.gold));
}

// Medicine: clinical remedy bottle with a healing cross, capsule, and olive leaf.
void _drawMedicine(Canvas canvas, _Palette p, bool dark) {
  const teal = Color(0xFF16A085);
  const tealDeep = Color(0xFF0E6655);
  _tint(canvas, teal, dark);

  // Medicine bottle body
  final bottle = RRect.fromLTRBR(24, 44, 58, 86, const Radius.circular(8));
  canvas.drawRRect(bottle, _fill(dark ? const Color(0xFF142E27) : const Color(0xFFEAF5F2)));
  canvas.drawRRect(bottle, _stroke(tealDeep, 2.0));

  // Bottle cap
  canvas.drawRRect(
    RRect.fromLTRBR(30, 36, 52, 44, const Radius.circular(3)),
    _fill(teal),
  );

  // Medical cross on bottle
  final crossPaint = _stroke(tealDeep, 3.2);
  canvas.drawLine(const Offset(41, 57), const Offset(41, 73), crossPaint);
  canvas.drawLine(const Offset(33, 65), const Offset(49, 65), crossPaint);

  // Capsule leaning on the right
  canvas.save();
  canvas.translate(72, 65);
  canvas.rotate(0.42);
  final cap = RRect.fromLTRBR(-9, -20, 9, 20, const Radius.circular(9));
  canvas.drawRRect(cap, _fill(p.deep));
  canvas.drawRRect(cap, _stroke(tealDeep, 1.8));
  canvas.drawLine(const Offset(-9, 0), const Offset(9, 0), _stroke(p.gold, 1.8));

  // Fill top half with gold
  final topCap = Path()
    ..moveTo(-9, 0)
    ..lineTo(-9, -11)
    ..quadraticBezierTo(-9, -20, 0, -20)
    ..quadraticBezierTo(9, -20, 9, -11)
    ..lineTo(9, 0)
    ..close();
  canvas.drawPath(topCap, _fill(p.gold));
  canvas.restore();

  // Botanical leaf sprout above
  _leaf(canvas, const Offset(41, 36), const Offset(26, 18), 6, p.light, tealDeep);
  _crescent(canvas, const Offset(82, 22), 6.5, _fill(p.gold));
  _sparkle(canvas, const Offset(18, 28), 3.6, _fill(p.goldSoft));
}

// Pathology: test tubes in a rack, a droplet and a crescent.
void _drawPathology(Canvas canvas, _Palette p, bool dark) {
  const purple = Color(0xFF8E44AD);
  const purpleDeep = Color(0xFF6C3483);
  _tint(canvas, purple, dark);

  final glass = dark ? const Color(0xFF2E3F39) : Colors.white;
  final outline = purple.withValues(alpha: 0.55);

  Path tube(double cx, double top, double bottomY) => Path()
    ..moveTo(cx - 6, top)
    ..lineTo(cx - 6, bottomY)
    ..arcTo(
      Rect.fromCircle(center: Offset(cx, bottomY), radius: 6),
      3.14159265,
      -3.14159265,
      false,
    )
    ..lineTo(cx + 6, top)
    ..close();

  void drawTube(double cx, double level, Color liquid) {
    final body = tube(cx, 28, 62);
    canvas.drawPath(body, _fill(glass));
    canvas.save();
    canvas.clipPath(body);
    canvas.drawRect(Rect.fromLTRB(cx - 7, level, cx + 7, 70), _fill(liquid));
    canvas.restore();
    canvas.drawPath(body, _stroke(outline, 1.6));
    canvas.drawRRect(
      RRect.fromLTRBR(cx - 7.5, 25, cx + 7.5, 29, const Radius.circular(2)),
      _fill(purpleDeep),
    );
    // bubbles
    canvas.drawCircle(
      Offset(cx - 1.5, level + 6),
      1.5,
      _fill(Colors.white.withValues(alpha: 0.7)),
    );
    canvas.drawCircle(
      Offset(cx + 2, level + 12),
      1.1,
      _fill(Colors.white.withValues(alpha: 0.7)),
    );
  }

  drawTube(32, 46, purple);
  drawTube(50, 40, p.gold);
  drawTube(68, 52, p.light);

  // rack
  canvas.drawRRect(
    RRect.fromLTRBR(20, 58, 80, 64, const Radius.circular(3)),
    _fill(purpleDeep),
  );
  canvas.drawRect(const Rect.fromLTRB(25, 64, 30, 76), _fill(purpleDeep));
  canvas.drawRect(const Rect.fromLTRB(70, 64, 75, 76), _fill(purpleDeep));

  // droplet
  final drop = Path()
    ..moveTo(86, 30)
    ..quadraticBezierTo(80, 40, 86, 44)
    ..quadraticBezierTo(92, 40, 86, 30)
    ..close();
  canvas.drawPath(drop, _fill(p.gold));

  _crescent(canvas, const Offset(20, 24), 6, _fill(p.gold));
  _sparkle(canvas, const Offset(80, 18), 3.4, _fill(p.goldSoft));
}

// Empty notifications: a bell with an "all caught up" check badge.
void _drawBell(Canvas canvas, _Palette p, bool dark) {
  canvas.drawCircle(const Offset(50, 52), 44, _fill(p.tint));

  final body = Path()
    ..moveTo(29, 68)
    ..cubicTo(34, 62, 36, 54, 36, 45)
    ..cubicTo(36, 33, 43, 27, 50, 27)
    ..cubicTo(57, 27, 64, 33, 64, 45)
    ..cubicTo(64, 54, 66, 62, 71, 68)
    ..close();
  canvas.drawPath(body, _fill(p.mid));
  canvas.drawPath(
    Path()
      ..moveTo(41, 60)
      ..quadraticBezierTo(42, 50, 42, 44),
    _stroke(Colors.white.withValues(alpha: 0.35), 2.2),
  );
  canvas.drawRRect(
    RRect.fromLTRBR(25, 66, 75, 72, const Radius.circular(3)),
    _fill(p.deep),
  );
  canvas.drawCircle(const Offset(50, 24), 3.2, _fill(p.gold));
  // clapper
  canvas.drawPath(
    Path()
      ..moveTo(44, 73)
      ..arcTo(
        Rect.fromCircle(center: const Offset(50, 73), radius: 6),
        3.14159265,
        -3.14159265,
        false,
      )
      ..close(),
    _fill(p.gold),
  );

  // check badge
  canvas.drawCircle(const Offset(70, 32), 11, _fill(p.gold));
  canvas.drawPath(
    Path()
      ..moveTo(64, 32)
      ..lineTo(68.5, 36.5)
      ..lineTo(76, 27.5),
    _stroke(Colors.white, 3),
  );

  _sparkle(canvas, const Offset(22, 34), 4, _fill(p.goldSoft));
  _sparkle(canvas, const Offset(82, 62), 3.2, _fill(p.gold));
  canvas.drawCircle(const Offset(18, 60), 1.7, _fill(p.goldSoft));
}

// Empty bookings: a calendar page with one highlighted day.
void _drawCalendar(Canvas canvas, _Palette p, bool dark) {
  canvas.drawCircle(const Offset(50, 52), 44, _fill(p.tint));

  final card = dark ? const Color(0xFF1B2A25) : Colors.white;
  canvas.drawRRect(
    RRect.fromLTRBR(22, 30, 78, 82, const Radius.circular(9)),
    _fill(card),
  );
  canvas.drawRRect(
    RRect.fromLTRBR(22, 30, 78, 82, const Radius.circular(9)),
    _stroke(p.deep.withValues(alpha: 0.35), 1.4),
  );
  canvas.drawRRect(
    RRect.fromLTRBAndCorners(
      22,
      30,
      78,
      46,
      topLeft: const Radius.circular(9),
      topRight: const Radius.circular(9),
    ),
    _fill(p.mid),
  );
  // binder rings
  canvas.drawRRect(
    RRect.fromLTRBR(33, 24, 38, 36, const Radius.circular(2.5)),
    _fill(p.gold),
  );
  canvas.drawRRect(
    RRect.fromLTRBR(62, 24, 67, 36, const Radius.circular(2.5)),
    _fill(p.gold),
  );

  // days
  final dot = _fill(p.ground);
  for (var r = 0; r < 3; r++) {
    for (var c = 0; c < 4; c++) {
      if (r == 1 && c == 2) continue; // the highlighted day
      canvas.drawCircle(Offset(33.5 + c * 11, 55 + r * 9), 2.4, dot);
    }
  }
  canvas.drawCircle(const Offset(55.5, 64), 5.2, _fill(p.gold));
  _sparkle(canvas, const Offset(55.5, 64), 3, _fill(Colors.white));

  _crescent(canvas, const Offset(84, 28), 6, _fill(p.gold));
  _sparkle(canvas, const Offset(17, 26), 3.6, _fill(p.goldSoft));
}

// ───────────────────── success, learning, account set ──────────────────

/// Small confetti pieces around a success scene.
void _confetti(Canvas canvas, _Palette p) {
  void bit(double x, double y, double w, double h, double angle, Color c) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(angle);
    canvas.drawRRect(
      RRect.fromLTRBR(-w / 2, -h / 2, w / 2, h / 2, const Radius.circular(1)),
      _fill(c),
    );
    canvas.restore();
  }

  bit(20, 30, 7, 3, 0.6, p.gold);
  bit(34, 16, 6, 3, -0.5, p.light);
  bit(70, 14, 7, 3, 0.9, p.goldSoft);
  bit(84, 32, 6, 3, -0.7, p.light);
  bit(14, 54, 6, 3, -0.4, p.goldSoft);
  canvas.drawCircle(const Offset(58, 10), 2, _fill(p.gold));
  canvas.drawCircle(const Offset(88, 54), 2, _fill(p.light));
  canvas.drawCircle(const Offset(12, 40), 1.8, _fill(p.light));
}

void _checkBadge(Canvas canvas, Offset c, double r, Color color) {
  canvas.drawCircle(c, r, _fill(color));
  canvas.drawPath(
    Path()
      ..moveTo(c.dx - r * 0.42, c.dy + r * 0.02)
      ..lineTo(c.dx - r * 0.08, c.dy + r * 0.38)
      ..lineTo(c.dx + r * 0.46, c.dy - r * 0.34),
    _stroke(Colors.white, r * 0.26),
  );
}

// Booking confirmed: calendar page with a check badge and confetti.
void _drawBookingSuccess(Canvas canvas, _Palette p, bool dark) {
  canvas.drawCircle(const Offset(50, 54), 40, _fill(p.tint));
  _confetti(canvas, p);

  final card = dark ? const Color(0xFF1B2A25) : Colors.white;
  canvas.drawRRect(
    RRect.fromLTRBR(24, 34, 74, 80, const Radius.circular(8)),
    _fill(card),
  );
  canvas.drawRRect(
    RRect.fromLTRBR(24, 34, 74, 80, const Radius.circular(8)),
    _stroke(p.deep.withValues(alpha: 0.35), 1.3),
  );
  canvas.drawRRect(
    RRect.fromLTRBAndCorners(
      24,
      34,
      74,
      48,
      topLeft: const Radius.circular(8),
      topRight: const Radius.circular(8),
    ),
    _fill(p.mid),
  );
  canvas.drawRRect(
    RRect.fromLTRBR(35, 29, 39.5, 39, const Radius.circular(2.2)),
    _fill(p.gold),
  );
  canvas.drawRRect(
    RRect.fromLTRBR(58.5, 29, 63, 39, const Radius.circular(2.2)),
    _fill(p.gold),
  );
  final dot = _fill(p.ground);
  for (var r = 0; r < 2; r++) {
    for (var c = 0; c < 4; c++) {
      canvas.drawCircle(Offset(33 + c * 10.5, 56 + r * 9), 2.2, dot);
    }
  }
  _checkBadge(canvas, const Offset(68, 72), 14, p.gold);
  _sparkle(canvas, const Offset(22, 76), 3.4, _fill(p.goldSoft));
}

// Order placed: a parcel with a check badge and confetti.
void _drawOrderSuccess(Canvas canvas, _Palette p, bool dark) {
  canvas.drawCircle(const Offset(50, 54), 40, _fill(p.tint));
  _confetti(canvas, p);

  const box = Color(0xFFD9A15B);
  const boxDark = Color(0xFFC4883F);
  const boxLight = Color(0xFFEBBE80);
  // body and lid
  canvas.drawRRect(
    RRect.fromLTRBR(25, 48, 75, 80, const Radius.circular(4)),
    _fill(box),
  );
  canvas.drawRRect(
    RRect.fromLTRBR(22, 40, 78, 52, const Radius.circular(3)),
    _fill(boxLight),
  );
  // shading on the right side
  canvas.drawRect(const Rect.fromLTRB(66, 52, 75, 80), _fill(boxDark.withValues(alpha: 0.35)));
  // tape
  canvas.drawRect(const Rect.fromLTRB(45, 40, 55, 80), _fill(const Color(0xFFF6E7C9)));
  // label
  canvas.drawRRect(
    RRect.fromLTRBR(29, 60, 42, 72, const Radius.circular(2)),
    _fill(Colors.white.withValues(alpha: 0.9)),
  );
  canvas.drawLine(const Offset(32, 64), const Offset(39, 64), _stroke(boxDark, 1.3));
  canvas.drawLine(const Offset(32, 68), const Offset(37, 68), _stroke(boxDark, 1.3));
  _crescent(canvas, const Offset(64, 66), 5, _fill(p.deep));

  _checkBadge(canvas, const Offset(72, 34), 13, p.mid);
  _sparkle(canvas, const Offset(22, 24), 3.4, _fill(p.goldSoft));
}

// Certificate: a gold medal on two ribbons. The centre is left plain so a
// score can be printed over it.
void _drawCertificate(Canvas canvas, _Palette p, bool dark) {
  canvas.drawCircle(const Offset(50, 52), 44, _fill(p.tint));

  // ribbon tails
  final left = Path()
    ..moveTo(33, 62)
    ..lineTo(51, 62)
    ..lineTo(45, 90)
    ..lineTo(39, 83)
    ..lineTo(31, 88)
    ..close();
  canvas.drawPath(left, _fill(p.mid));
  final right = Path()
    ..moveTo(67, 62)
    ..lineTo(49, 62)
    ..lineTo(55, 90)
    ..lineTo(61, 83)
    ..lineTo(69, 88)
    ..close();
  canvas.drawPath(right, _fill(p.deep));

  // medal
  canvas.drawCircle(const Offset(50, 46), 29, _fill(p.gold));
  canvas.drawCircle(const Offset(50, 46), 24, _fill(p.goldSoft));
  canvas.drawCircle(const Offset(50, 46), 21, _fill(p.gold));
  // scalloped rim dots
  for (var i = 0; i < 16; i++) {
    final a = i * 6.2832 / 16;
    canvas.drawCircle(
      const Offset(50, 46) + Offset.fromDirection(a, 26.5),
      1.4,
      _fill(p.goldSoft),
    );
  }
  _sparkle(canvas, const Offset(18, 30), 4, _fill(p.goldSoft));
  _sparkle(canvas, const Offset(84, 24), 3.4, _fill(p.gold));
  _crescent(canvas, const Offset(84, 66), 5.5, _fill(p.gold));
}

// Learn: an open Quran on a stand, with a crescent above.
void _drawLearn(Canvas canvas, _Palette p, bool dark) {
  canvas.drawCircle(const Offset(50, 54), 42, _fill(p.tint));

  const wood = Color(0xFFC4883F);
  // stand
  canvas.drawLine(const Offset(50, 64), const Offset(34, 88), _stroke(wood, 4.5));
  canvas.drawLine(const Offset(50, 64), const Offset(66, 88), _stroke(wood, 4.5));
  canvas.drawLine(const Offset(38, 82), const Offset(62, 82), _stroke(wood, 3.5));

  // book cover (slightly larger, behind the pages)
  final coverL = Path()
    ..moveTo(50, 40)
    ..quadraticBezierTo(34, 31, 15, 38)
    ..lineTo(15, 68)
    ..quadraticBezierTo(34, 62, 50, 70)
    ..close();
  final coverR = Path()
    ..moveTo(50, 40)
    ..quadraticBezierTo(66, 31, 85, 38)
    ..lineTo(85, 68)
    ..quadraticBezierTo(66, 62, 50, 70)
    ..close();
  canvas.drawPath(coverL, _fill(p.deep));
  canvas.drawPath(coverR, _fill(p.deep));

  // pages
  final page = dark ? const Color(0xFFE8E2D2) : const Color(0xFFFFFBF0);
  final pageL = Path()
    ..moveTo(49, 42)
    ..quadraticBezierTo(34, 34, 19, 40)
    ..lineTo(19, 64)
    ..quadraticBezierTo(34, 59, 49, 66)
    ..close();
  final pageR = Path()
    ..moveTo(51, 42)
    ..quadraticBezierTo(66, 34, 81, 40)
    ..lineTo(81, 64)
    ..quadraticBezierTo(66, 59, 51, 66)
    ..close();
  canvas.drawPath(pageL, _fill(page));
  canvas.drawPath(pageR, _fill(page));

  // lines of text
  final line = _stroke(p.gold.withValues(alpha: 0.85), 1.5);
  for (var i = 0; i < 4; i++) {
    final y = 44.0 + i * 4.8;
    canvas.drawLine(Offset(24, y + 0.5), Offset(44, y + 2.5), line);
    canvas.drawLine(Offset(56, y + 2.5), Offset(76, y + 0.5), line);
  }

  // glow above the book
  _crescent(canvas, const Offset(50, 21), 8, _fill(p.gold));
  _sparkle(canvas, const Offset(28, 20), 3.6, _fill(p.goldSoft));
  _sparkle(canvas, const Offset(74, 16), 3, _fill(p.goldSoft));
}

// Community: two overlapping speech bubbles.
void _drawCommunity(Canvas canvas, _Palette p, bool dark) {
  canvas.drawCircle(const Offset(50, 52), 44, _fill(p.tint));

  // big bubble with tail
  final big = Path()
    ..addRRect(RRect.fromLTRBR(16, 24, 66, 62, const Radius.circular(12)))
    ..moveTo(26, 60)
    ..lineTo(24, 74)
    ..lineTo(38, 61)
    ..close();
  canvas.drawPath(big, _fill(p.mid));
  for (final x in [30.0, 41.0, 52.0]) {
    canvas.drawCircle(Offset(x, 43), 3, _fill(Colors.white));
  }

  // small bubble
  final small = Path()
    ..addRRect(RRect.fromLTRBR(50, 48, 86, 76, const Radius.circular(10)))
    ..moveTo(74, 74)
    ..lineTo(80, 86)
    ..lineTo(66, 75)
    ..close();
  canvas.drawPath(small, _fill(p.gold));
  _crescent(canvas, const Offset(68, 62), 6.5, _fill(Colors.white));

  _sparkle(canvas, const Offset(80, 24), 4, _fill(p.goldSoft));
  _sparkle(canvas, const Offset(14, 80), 3, _fill(p.goldSoft));
}

// Guest account: an avatar with a gold key, for signing in.
void _drawGuest(Canvas canvas, _Palette p, bool dark) {
  canvas.drawCircle(const Offset(50, 52), 44, _fill(p.tint));

  // shoulders
  canvas.drawPath(
    Path()
      ..moveTo(22, 82)
      ..quadraticBezierTo(24, 62, 50, 62)
      ..quadraticBezierTo(76, 62, 78, 82)
      ..close(),
    _fill(p.mid),
  );
  // head
  canvas.drawCircle(const Offset(50, 40), 14, _fill(_skin(dark)));
  // hair / head covering
  canvas.drawPath(
    Path()
      ..moveTo(36, 40)
      ..arcTo(
        Rect.fromCircle(center: const Offset(50, 40), radius: 14),
        3.14159265,
        3.14159265,
        false,
      )
      ..quadraticBezierTo(50, 36, 36, 40)
      ..close(),
    _fill(p.deep),
  );

  // key
  canvas.drawCircle(const Offset(70, 72), 8, _stroke(p.gold, 3.6));
  canvas.drawLine(const Offset(75.5, 77.5), const Offset(88, 90), _stroke(p.gold, 3.6));
  canvas.drawLine(const Offset(82, 84), const Offset(85.5, 80.5), _stroke(p.gold, 3));

  _crescent(canvas, const Offset(20, 26), 6.5, _fill(p.gold));
  _sparkle(canvas, const Offset(80, 24), 3.6, _fill(p.goldSoft));
}

// Premium plan: a gold crown over a crescent, with sparkles.
void _drawPremium(Canvas canvas, _Palette p, bool dark) {
  canvas.drawCircle(const Offset(50, 52), 44, _fill(p.tint));

  _crescent(canvas, const Offset(50, 70), 18, _fill(p.mid));

  final crown = Path()
    ..moveTo(26, 64)
    ..lineTo(22, 36)
    ..lineTo(38, 50)
    ..lineTo(50, 28)
    ..lineTo(62, 50)
    ..lineTo(78, 36)
    ..lineTo(74, 64)
    ..close();
  canvas.drawPath(crown, _fill(p.gold));
  canvas.drawRRect(
    RRect.fromLTRBR(25, 62, 75, 71, const Radius.circular(3)),
    _fill(p.goldSoft),
  );
  for (final x in [36.0, 50.0, 64.0]) {
    canvas.drawCircle(Offset(x, 66.5), 2.3, _fill(p.deep));
  }
  for (final o in [
    const Offset(22, 34),
    const Offset(50, 26),
    const Offset(78, 34),
  ]) {
    canvas.drawCircle(o, 3.6, _fill(p.goldSoft));
  }

  _sparkle(canvas, const Offset(16, 62), 3.6, _fill(p.goldSoft));
  _sparkle(canvas, const Offset(86, 62), 3, _fill(p.gold));
}
