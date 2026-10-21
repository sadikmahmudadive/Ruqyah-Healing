import 'package:flutter/material.dart';

/// A custom vector icon depicting Unani Tibb (Greco-Arabic & Prophetic herbal
/// medicine) — featuring a classical apothecary tincture flask with a healing
/// botanical leaf and humoral balance node.
class UnaniTibbIcon extends StatelessWidget {
  final Color color;
  final double size;

  const UnaniTibbIcon({
    super.key,
    this.color = const Color(0xFFC59236),
    this.size = 26.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _UnaniTibbIconPainter(color: color),
        ),
      ),
    );
  }
}

class _UnaniTibbIconPainter extends CustomPainter {
  final Color color;

  _UnaniTibbIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.scale(scale, scale);

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // 1. Classical apothecary flask rim
    canvas.drawLine(const Offset(8.5, 3.5), const Offset(15.5, 3.5), stroke);

    // 2. Flask neck
    canvas.drawLine(const Offset(10.0, 3.5), const Offset(10.0, 7.5), stroke);
    canvas.drawLine(const Offset(14.0, 3.5), const Offset(14.0, 7.5), stroke);

    // 3. Flask body (ergonomic conical apothecary vessel)
    final flaskBody = Path()
      ..moveTo(10.0, 7.5)
      ..lineTo(4.5, 17.5)
      ..quadraticBezierTo(4.0, 21.0, 7.5, 21.0)
      ..lineTo(16.5, 21.0)
      ..quadraticBezierTo(20.0, 21.0, 19.5, 17.5)
      ..lineTo(14.0, 7.5);
    canvas.drawPath(flaskBody, stroke);

    // 4. Liquid level line
    final liquidPath = Path()
      ..moveTo(6.5, 15.5)
      ..quadraticBezierTo(10.0, 14.5, 12.0, 15.5)
      ..quadraticBezierTo(14.0, 16.5, 17.5, 15.5);
    canvas.drawPath(
      liquidPath,
      Paint()
        ..color = color.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round,
    );

    // 5. Emerging medicinal sprout / Kalonji leaf from flask neck
    final leafPath = Path()
      ..moveTo(12.0, 7.0)
      ..quadraticBezierTo(14.0, 4.0, 17.5, 3.5)
      ..quadraticBezierTo(15.5, 6.5, 12.0, 7.0);
    canvas.drawPath(leafPath, fill);

    // 6. Healing droplet node
    canvas.drawCircle(const Offset(12.0, 18.0), 1.5, fill);
  }

  @override
  bool shouldRepaint(covariant _UnaniTibbIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
