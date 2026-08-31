import 'package:flutter/material.dart';

/// A custom widget that renders the official 4-color Google "G" logo.
class GoogleLogo extends StatelessWidget {
  final double size;

  const GoogleLogo({super.key, this.size = 22.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / 24.0;
    canvas.scale(scale, scale);

    // 1. Red Top Arc (#EA4335)
    final Path redPath = Path()
      ..moveTo(12.0, 5.0)
      ..cubicTo(14.8, 5.0, 17.0, 6.0, 18.7, 7.5)
      ..lineTo(22.1, 4.1)
      ..cubicTo(19.4, 1.6, 16.0, 0.0, 12.0, 0.0)
      ..cubicTo(7.3, 0.0, 3.3, 2.7, 1.3, 6.6)
      ..lineTo(5.2, 9.7)
      ..cubicTo(6.2, 7.0, 8.9, 5.0, 12.0, 5.0)
      ..close();
    canvas.drawPath(redPath, Paint()..color = const Color(0xFFEA4335));

    // 2. Blue Right Arc & Horizontal Bar (#4285F4)
    final Path bluePath = Path()
      ..moveTo(23.5, 12.3)
      ..cubicTo(23.5, 11.5, 23.4, 10.7, 23.2, 10.0)
      ..lineTo(12.0, 10.0)
      ..lineTo(12.0, 14.6)
      ..lineTo(18.5, 14.6)
      ..cubicTo(17.9, 16.3, 16.9, 17.7, 15.4, 18.7)
      ..lineTo(19.2, 21.7)
      ..cubicTo(21.8, 19.6, 23.5, 16.3, 23.5, 12.3)
      ..close();
    canvas.drawPath(bluePath, Paint()..color = const Color(0xFF4285F4));

    // 3. Yellow Left-Bottom Arc (#FBBC05)
    final Path yellowPath = Path()
      ..moveTo(5.2, 14.3)
      ..cubicTo(4.8, 12.9, 4.8, 11.1, 5.2, 9.7)
      ..lineTo(1.3, 6.6)
      ..cubicTo(0.1, 9.0, -0.4, 11.8, 0.1, 14.6)
      ..cubicTo(0.5, 16.2, 1.1, 17.7, 2.0, 19.1)
      ..lineTo(6.0, 16.0)
      ..cubicTo(5.5, 15.5, 5.3, 14.9, 5.2, 14.3)
      ..close();
    canvas.drawPath(yellowPath, Paint()..color = const Color(0xFFFBBC05));

    // 4. Green Bottom Arc (#34A853)
    final Path greenPath = Path()
      ..moveTo(12.0, 19.0)
      ..cubicTo(8.9, 19.0, 6.2, 17.0, 5.2, 14.3)
      ..lineTo(1.3, 17.4)
      ..cubicTo(3.3, 21.3, 7.3, 24.0, 12.0, 24.0)
      ..cubicTo(15.2, 24.0, 18.1, 22.9, 20.3, 21.0)
      ..lineTo(16.5, 18.0)
      ..cubicTo(15.2, 18.8, 13.7, 19.0, 12.0, 19.0)
      ..close();
    canvas.drawPath(greenPath, Paint()..color = const Color(0xFF34A853));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
