import 'package:flutter/material.dart';

/// A custom vector icon depicting open praying hands (Dua / Supplication palms)
/// representing Ruqyah and spiritual healing.
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
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Left Palm Vector Path
    final Path leftPalm = Path()
      ..moveTo(11.2, 21.0)
      ..cubicTo(7.5, 21.0, 4.2, 17.5, 4.2, 13.0)
      ..cubicTo(3.0, 11.2, 1.5, 9.8, 2.2, 8.2)
      ..cubicTo(2.8, 7.2, 4.2, 7.5, 5.2, 9.0)
      ..lineTo(6.5, 11.2)
      ..moveTo(6.5, 9.2)
      ..lineTo(6.5, 5.5)
      ..cubicTo(6.5, 4.3, 7.3, 3.5, 8.2, 3.5)
      ..cubicTo(9.1, 3.5, 9.8, 4.3, 9.8, 5.5)
      ..lineTo(9.8, 12.5)
      ..moveTo(9.8, 4.8)
      ..lineTo(9.8, 2.8)
      ..cubicTo(9.8, 1.6, 10.6, 0.8, 11.5, 0.8)
      ..cubicTo(12.4, 0.8, 13.2, 1.6, 13.2, 2.8)
      ..lineTo(13.2, 13.5);

    // Right Palm Vector Path (Mirrored)
    final Path rightPalm = Path()
      ..moveTo(12.8, 21.0)
      ..cubicTo(16.5, 21.0, 19.8, 17.5, 19.8, 13.0)
      ..cubicTo(21.0, 11.2, 22.5, 9.8, 21.8, 8.2)
      ..cubicTo(21.2, 7.2, 19.8, 7.5, 18.8, 9.0)
      ..lineTo(17.5, 11.2)
      ..moveTo(17.5, 9.2)
      ..lineTo(17.5, 5.5)
      ..cubicTo(17.5, 4.3, 16.7, 3.5, 15.8, 3.5)
      ..cubicTo(14.9, 3.5, 14.2, 4.3, 14.2, 5.5)
      ..lineTo(14.2, 12.5)
      ..moveTo(14.2, 4.8)
      ..lineTo(14.2, 2.8)
      ..cubicTo(14.2, 1.6, 13.4, 0.8, 12.5, 0.8)
      ..cubicTo(11.6, 0.8, 10.8, 1.6, 10.8, 2.8)
      ..lineTo(10.8, 13.5);

    canvas.drawPath(leftPalm, paint);
    canvas.drawPath(rightPalm, paint);
  }

  @override
  bool shouldRepaint(covariant _RuqyahDuaIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
