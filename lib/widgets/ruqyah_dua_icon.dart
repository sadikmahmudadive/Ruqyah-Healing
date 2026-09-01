import 'package:flutter/material.dart';

/// A custom vector icon depicting cupped open hands (Ruqyah Dua / Supplication palms)
/// matching the exact Figma design specification.
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

    // Left Hand Path from Figma Vector
    final Path leftHand = Path()
      ..moveTo(11.0, 20.0)
      ..lineTo(7.0, 20.0)
      ..lineTo(7.0, 14.0)
      ..cubicTo(7.0, 10.0, 2.5, 8.0, 2.5, 4.5)
      ..cubicTo(2.5, 3.2, 4.5, 3.2, 4.5, 4.5)
      ..lineTo(4.5, 8.5)
      ..cubicTo(5.5, 9.5, 8.0, 10.5, 8.5, 11.5)
      ..cubicTo(9.0, 12.5, 11.0, 14.5, 11.0, 20.0)
      ..close();

    // Right Hand Path from Figma Vector
    final Path rightHand = Path()
      ..moveTo(13.0, 20.0)
      ..lineTo(17.0, 20.0)
      ..lineTo(17.0, 14.0)
      ..cubicTo(17.0, 10.0, 21.5, 8.0, 21.5, 4.5)
      ..cubicTo(21.5, 3.2, 19.5, 3.2, 19.5, 4.5)
      ..lineTo(19.5, 8.5)
      ..cubicTo(18.5, 9.5, 16.0, 10.5, 15.5, 11.5)
      ..cubicTo(15.0, 12.5, 13.0, 14.5, 13.0, 20.0)
      ..close();

    canvas.drawPath(leftHand, paint);
    canvas.drawPath(rightHand, paint);
  }

  @override
  bool shouldRepaint(covariant _RuqyahDuaIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
