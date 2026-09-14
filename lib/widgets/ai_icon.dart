import 'package:flutter/material.dart';

class AiIcon extends StatelessWidget {
  final Color color;
  final double size;

  const AiIcon({
    super.key,
    this.color = const Color(0xFF1B1B1B),
    this.size = 22.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _AiIconPainter(color: color),
      ),
    );
  }
}

class _AiIconPainter extends CustomPainter {
  final Color color;

  _AiIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 22.0;
    canvas.scale(scale, scale);

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Path 1
    final p1 = Path()
      ..moveTo(18.31, 14.38)
      ..lineTo(18.31, 15.99)
      ..cubicTo(18.31, 17.18, 17.32, 18.14, 16.11, 18.14)
      ..lineTo(14.56, 18.14)
      ..moveTo(3.76, 14.38)
      ..lineTo(3.76, 15.99)
      ..cubicTo(3.76, 17.18, 4.74, 18.14, 5.96, 18.14)
      ..lineTo(7.4, 18.14)
      ..moveTo(3.76, 7.19)
      ..lineTo(3.76, 5.9)
      ..cubicTo(3.76, 4.72, 4.74, 3.76, 5.96, 3.76)
      ..lineTo(7.4, 3.76)
      ..moveTo(18.32, 7.19)
      ..lineTo(18.32, 5.9)
      ..cubicTo(18.32, 4.72, 17.33, 3.76, 16.12, 3.76)
      ..lineTo(14.57, 3.76)
      ..moveTo(3.76, 12.16)
      ..lineTo(3.76, 10.79)
      ..lineTo(3.76, 9.42)
      ..moveTo(18.31, 12.15)
      ..lineTo(18.31, 10.79)
      ..lineTo(18.31, 9.42)
      ..moveTo(12.21, 3.76)
      ..lineTo(10.76, 3.76)
      ..lineTo(9.52, 3.76)
      ..moveTo(12.21, 18.14)
      ..lineTo(10.75, 18.14)
      ..lineTo(9.51, 18.14)
      ..moveTo(7.06, 13.4)
      ..lineTo(9.73, 8.3)
      ..cubicTo(9.74, 8.28, 9.77, 8.26, 9.8, 8.26)
      ..cubicTo(9.84, 8.26, 9.87, 8.28, 9.88, 8.31)
      ..lineTo(12.36, 13.41)
      ..moveTo(8.39, 12.13)
      ..lineTo(10.81, 12.13)
      ..moveTo(12.36, 13.41)
      ..lineTo(12.36, 8.26)
      ..moveTo(15.89, 14.27)
      ..lineTo(17.43, 14.27)
      ..moveTo(7.5, 18.14)
      ..lineTo(7.5, 19.85);
    canvas.drawPath(p1, strokePaint);

    // Path 2
    canvas.drawLine(const Offset(3.76, 14.49), const Offset(2.15, 14.49), strokePaint);
    // Path 3
    canvas.drawLine(const Offset(7.51, 3.76), const Offset(7.51, 2.15), strokePaint);
    // Path 4
    canvas.drawLine(const Offset(18.24, 7.51), const Offset(19.85, 7.51), strokePaint);
    // Path 5
    canvas.drawLine(const Offset(14.49, 18.24), const Offset(14.49, 19.85), strokePaint);

    // Path 6 (Fill nodes)
    final p6 = Path()
      ..addRect(const Rect.fromLTWH(18.33, 10.47, 0.65, 1.28))
      ..addRect(const Rect.fromLTWH(20.05, 11.11, 0.65, 0.64)) // approx nodes
      ..addRect(const Rect.fromLTWH(10.13, 18.36, 1.3, 0.64))
      ..addRect(const Rect.fromLTWH(2.37, 10.47, 0.65, 1.28))
      ..addRect(const Rect.fromLTWH(10.13, 2.36, 1.3, 0.64));
    canvas.drawPath(p6, fillPaint);

    // Path 7
    canvas.drawLine(const Offset(3.76, 7.51), const Offset(2.15, 7.51), strokePaint);
    // Path 8
    canvas.drawLine(const Offset(14.49, 3.76), const Offset(14.49, 2.15), strokePaint);
  }

  @override
  bool shouldRepaint(covariant _AiIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
