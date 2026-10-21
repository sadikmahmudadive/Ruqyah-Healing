import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Islamic geometric accents, drawn in code so they stay crisp at any size
/// and add nothing to the app's download.
///
/// The motif is the classic eight-point star (two overlapping squares, one
/// turned 45 degrees) on a square grid, with a small diamond at the centre of
/// every four stars. Kept thin and faint on purpose: it should read as
/// texture and craft, never as noise, which is what keeps the app calm.
///
/// Three ways to use it:
///   - [IslamicPatternDecoration] as a `foregroundDecoration` on a Container
///     (headers, cards): paints over the gradient, clipped to its corners.
///   - [IslamicPattern], a widget to put in a Stack behind or over content.
///   - [paintIslamicPattern] directly, from any painter.
void paintIslamicPattern(
  Canvas canvas,
  Size size, {
  Color color = Colors.white,
  double opacity = 0.07,
  double cell = 64,
  double strokeWidth = 0.8,
  bool fadeDown = false,
}) {
  if (size.isEmpty) return;
  final paint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth
    ..strokeJoin = StrokeJoin.miter;

  final r = cell * 0.34; // star radius
  final rows = (size.height / cell).ceil() + 1;
  final cols = (size.width / cell).ceil() + 1;

  Path star(Offset c) {
    final p = Path();
    for (final base in const [0.0, math.pi / 4]) {
      for (var i = 0; i < 4; i++) {
        final a = base + i * math.pi / 2;
        final o = Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a));
        i == 0 ? p.moveTo(o.dx, o.dy) : p.lineTo(o.dx, o.dy);
      }
      p.close();
    }
    return p;
  }

  Path diamond(Offset c, double d) => Path()
    ..moveTo(c.dx, c.dy - d)
    ..lineTo(c.dx + d, c.dy)
    ..lineTo(c.dx, c.dy + d)
    ..lineTo(c.dx - d, c.dy)
    ..close();

  for (var y = 0; y < rows; y++) {
    final fade = fadeDown
        ? (1 - (y * cell) / size.height).clamp(0.0, 1.0)
        : 1.0;
    if (fade <= 0) continue;
    paint.color = color.withValues(alpha: opacity * fade);
    for (var x = 0; x < cols; x++) {
      final c = Offset(x * cell, y * cell);
      canvas.drawPath(star(c), paint);
      canvas.drawPath(
        diamond(c + Offset(cell / 2, cell / 2), cell * 0.12),
        paint,
      );
    }
  }
}

/// Paints the pattern over a Container's gradient. Clipped to [radius] so it
/// never spills past a rounded header.
class IslamicPatternDecoration extends Decoration {
  final Color color;
  final double opacity;
  final double cell;
  final bool fadeDown;
  final BorderRadius? radius;

  const IslamicPatternDecoration({
    this.color = Colors.white,
    this.opacity = 0.07,
    this.cell = 64,
    this.fadeDown = false,
    this.radius,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) =>
      _PatternBoxPainter(this);
}

class _PatternBoxPainter extends BoxPainter {
  final IslamicPatternDecoration d;
  _PatternBoxPainter(this.d);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final size = configuration.size;
    if (size == null || size.isEmpty) return;
    canvas.save();
    if (d.radius != null) {
      canvas.clipRRect(d.radius!.toRRect(offset & size));
    } else {
      canvas.clipRect(offset & size);
    }
    canvas.translate(offset.dx, offset.dy);
    paintIslamicPattern(
      canvas,
      size,
      color: d.color,
      opacity: d.opacity,
      cell: d.cell,
      fadeDown: d.fadeDown,
    );
    canvas.restore();
  }
}

/// The pattern as a widget, for Stacks. Ignores touches and repaints only
/// when its settings change.
class IslamicPattern extends StatelessWidget {
  final Color color;
  final double opacity;
  final double cell;
  final bool fadeDown;

  const IslamicPattern({
    super.key,
    this.color = Colors.white,
    this.opacity = 0.06,
    this.cell = 72,
    this.fadeDown = true,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _PatternPainter(color, opacity, cell, fadeDown),
        ),
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final double cell;
  final bool fadeDown;
  const _PatternPainter(this.color, this.opacity, this.cell, this.fadeDown);

  @override
  void paint(Canvas canvas, Size size) => paintIslamicPattern(
    canvas,
    size,
    color: color,
    opacity: opacity,
    cell: cell,
    fadeDown: fadeDown,
  );

  @override
  bool shouldRepaint(_PatternPainter old) =>
      old.color != color ||
      old.opacity != opacity ||
      old.cell != cell ||
      old.fadeDown != fadeDown;
}
