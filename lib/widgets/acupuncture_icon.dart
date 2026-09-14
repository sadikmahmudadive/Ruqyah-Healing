import 'package:flutter/material.dart';

/// A custom vector icon depicting Acupuncture therapy needles with cushion base
/// rendered as a clean, elegant stroke-based outline icon.
class AcupunctureIcon extends StatelessWidget {
  final Color color;
  final double size;

  const AcupunctureIcon({
    super.key,
    this.color = const Color(0xFF2B99B9),
    this.size = 26.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _AcupunctureIconPainter(color: color),
        ),
      ),
    );
  }
}

class _AcupunctureIconPainter extends CustomPainter {
  final Color color;

  _AcupunctureIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.scale(scale, scale);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // 1. Cushion / Base Box
    final cushionRRect = RRect.fromLTRBR(
      2.5,
      14.5,
      21.5,
      21.5,
      const Radius.circular(3.5),
    );
    canvas.drawRRect(cushionRRect, paint);

    // 2. Needle Shafts & Pin Heads (4 Needles)
    // Needle 1 (slight left slant)
    canvas.drawLine(const Offset(6.2, 5.8), const Offset(7.8, 14.5), paint);
    canvas.drawCircle(const Offset(5.5, 4.8), 1.4, fillPaint);

    // Needle 2 (vertical center-left)
    canvas.drawLine(const Offset(10.2, 3.8), const Offset(10.2, 14.5), paint);
    canvas.drawCircle(const Offset(10.2, 2.8), 1.4, fillPaint);

    // Needle 3 (vertical center-right)
    canvas.drawLine(const Offset(14.2, 3.8), const Offset(14.2, 14.5), paint);
    canvas.drawCircle(const Offset(14.2, 2.8), 1.4, fillPaint);

    // Needle 4 (slight right slant)
    canvas.drawLine(const Offset(18.2, 5.8), const Offset(16.6, 14.5), paint);
    canvas.drawCircle(const Offset(18.9, 4.8), 1.4, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _AcupunctureIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
