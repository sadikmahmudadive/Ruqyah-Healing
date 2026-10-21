import 'package:flutter/material.dart';

/// A custom vector icon depicting Acupressure therapy — finger pressure point
/// stimulation with concentric tactile pulse waves, rendered as a clean,
/// elegant stroke-based outline icon.
class AcupressureIcon extends StatelessWidget {
  final Color color;
  final double size;

  const AcupressureIcon({
    super.key,
    this.color = const Color(0xFFC86D51),
    this.size = 26.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _AcupressureIconPainter(color: color),
        ),
      ),
    );
  }
}

class _AcupressureIconPainter extends CustomPainter {
  final Color color;

  _AcupressureIconPainter({required this.color});

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

    // 1. Center focal acupoint (target pressure node)
    canvas.drawCircle(const Offset(12.0, 12.0), 2.2, fill);

    // 2. Inner concentric pressure wave
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(12.0, 12.0), radius: 5.2),
      -2.4,
      4.8,
      false,
      stroke,
    );

    // 3. Outer concentric resonance wave
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(12.0, 12.0), radius: 8.8),
      -2.2,
      4.4,
      false,
      Paint()
        ..color = color.withValues(alpha: 0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round,
    );

    // 4. Forefinger / Hand touch vector applying direct vertical pressure
    final fingerPath = Path()
      ..moveTo(9.5, 22.0)
      ..lineTo(9.5, 14.5)
      ..quadraticBezierTo(9.5, 12.0, 12.0, 12.0)
      ..quadraticBezierTo(14.5, 12.0, 14.5, 14.5)
      ..lineTo(14.5, 22.0);
    canvas.drawPath(fingerPath, stroke);

    // 5. Thumb support contour
    final thumbPath = Path()
      ..moveTo(6.0, 22.0)
      ..quadraticBezierTo(6.0, 17.0, 9.5, 16.0);
    canvas.drawPath(thumbPath, stroke);
  }

  @override
  bool shouldRepaint(covariant _AcupressureIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
