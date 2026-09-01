import 'package:flutter/material.dart';

/// A custom vector icon depicting cupped open hands (Ruqyah Dua / Supplication palms)
/// matching the exact design specification.
class RuqyahDuaIcon extends StatelessWidget {
  final Color color;
  final double size;

  const RuqyahDuaIcon({
    super.key,
    this.color = const Color(0xFF0B4632),
    this.size = 26.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RuqyahDuaIconPainter(color: color),
      ),
    );
  }
}

class _RuqyahDuaIconPainter extends CustomPainter {
  final Color color;

  _RuqyahDuaIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / 24.0;
    canvas.scale(scale, scale);

    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Single Left Hand Outline Path matching exact reference image
    final Path leftHand = Path()
      // Inner bottom wrist
      ..moveTo(11.0, 20.0)
      // Bottom wrist base
      ..lineTo(7.0, 20.0)
      // Outer vertical wrist
      ..lineTo(7.0, 14.0)
      // Outer palm upward curve to tall outer finger
      ..cubicTo(7.0, 10.5, 2.5, 8.5, 2.5, 4.8)
      // Tall outer finger top rounded tip
      ..cubicTo(2.5, 3.6, 4.5, 3.6, 4.5, 4.8)
      // Inner edge of tall finger
      ..lineTo(4.5, 8.2)
      // Inner thumb branch extending diagonally
      ..cubicTo(5.2, 9.2, 7.8, 10.5, 8.2, 11.2)
      // Inner thumb tip curve down to inner wrist
      ..cubicTo(8.5, 12.0, 11.0, 13.8, 11.0, 20.0)
      ..close();

    // Draw Left Hand
    canvas.drawPath(leftHand, paint);

    // Draw Right Hand (Mirrored horizontally across x = 24.0)
    canvas.save();
    canvas.translate(24.0, 0.0);
    canvas.scale(-1.0, 1.0);
    canvas.drawPath(leftHand, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RuqyahDuaIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
