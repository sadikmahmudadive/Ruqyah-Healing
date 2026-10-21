import 'package:flutter/material.dart';

/// A custom vector icon depicting Holistic & Prophetic Medicine — featuring
/// a clinical remedy bottle with a healing cross/crescent and medicine capsule,
/// rendered as a clean, elegant stroke-based outline icon.
class MedicineIcon extends StatelessWidget {
  final Color color;
  final double size;

  const MedicineIcon({
    super.key,
    this.color = const Color(0xFF16A085),
    this.size = 26.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _MedicineIconPainter(color: color),
        ),
      ),
    );
  }
}

class _MedicineIconPainter extends CustomPainter {
  final Color color;

  _MedicineIconPainter({required this.color});

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

    // 1. Medicine bottle cap
    final capRRect = RRect.fromLTRBR(
      4.0,
      3.0,
      12.0,
      6.0,
      const Radius.circular(1.5),
    );
    canvas.drawRRect(capRRect, stroke);

    // 2. Medicine bottle body
    final bottleRRect = RRect.fromLTRBR(
      2.5,
      6.0,
      13.5,
      21.0,
      const Radius.circular(3.0),
    );
    canvas.drawRRect(bottleRRect, stroke);

    // 3. Plus / Medical symbol on the bottle
    canvas.drawLine(const Offset(8.0, 11.5), const Offset(8.0, 16.5), stroke);
    canvas.drawLine(const Offset(5.5, 14.0), const Offset(10.5, 14.0), stroke);

    // 4. Medicine capsule pill leaning beside the bottle
    canvas.save();
    canvas.translate(17.5, 14.0);
    canvas.rotate(0.5); // 30-degree tilt

    final capsuleRRect = RRect.fromLTRBR(
      -3.0,
      -7.0,
      3.0,
      7.0,
      const Radius.circular(3.0),
    );
    canvas.drawRRect(capsuleRRect, stroke);

    // Divider line across middle of capsule
    canvas.drawLine(const Offset(-3.0, 0.0), const Offset(3.0, 0.0), stroke);

    // Fill top half of capsule
    final topHalf = Path()
      ..moveTo(-3.0, 0.0)
      ..lineTo(-3.0, -4.0)
      ..quadraticBezierTo(-3.0, -7.0, 0.0, -7.0)
      ..quadraticBezierTo(3.0, -7.0, 3.0, -4.0)
      ..lineTo(3.0, 0.0)
      ..close();
    canvas.drawPath(topHalf, fill);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MedicineIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
