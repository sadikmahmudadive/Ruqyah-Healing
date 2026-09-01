import 'package:flutter/material.dart';

/// A custom vector icon depicting two open praying hands (Dua / Supplication palms)
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
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Single Hand Path (Left Palm & 5 Digits)
    final Path hand = Path();

    // Wrist & Outer Palm Base
    hand.moveTo(11.0, 21.0);
    hand.cubicTo(6.5, 21.0, 2.8, 17.0, 2.8, 12.8);

    // 1. Thumb (outermost)
    hand.cubicTo(2.4, 11.0, 0.6, 9.2, 1.0, 7.8);
    hand.cubicTo(1.4, 6.6, 2.6, 7.0, 3.6, 8.5);
    hand.lineTo(4.6, 10.2);

    // 2. Pinky Finger
    hand.lineTo(4.6, 6.2);
    hand.cubicTo(4.6, 5.0, 5.3, 4.2, 6.2, 4.2);
    hand.cubicTo(7.1, 4.2, 7.8, 5.0, 7.8, 6.2);
    hand.lineTo(7.8, 10.2);

    // 3. Ring Finger
    hand.lineTo(7.8, 3.8);
    hand.cubicTo(7.8, 2.6, 8.5, 1.8, 9.4, 1.8);
    hand.cubicTo(10.3, 1.8, 11.0, 2.6, 11.0, 3.8);
    hand.lineTo(11.0, 10.2);

    // 4. Middle Finger (Tallest)
    hand.lineTo(11.0, 2.0);
    hand.cubicTo(11.0, 0.8, 11.7, 0.2, 12.6, 0.2);
    hand.cubicTo(13.5, 0.2, 14.2, 0.8, 14.2, 2.0);
    hand.lineTo(14.2, 10.2);

    // 5. Index Finger (Inner)
    hand.lineTo(14.2, 3.5);
    hand.cubicTo(14.2, 2.3, 14.9, 1.5, 15.8, 1.5);
    hand.cubicTo(16.7, 1.5, 17.4, 2.3, 17.4, 3.5);
    hand.lineTo(17.4, 12.0);

    // Inner Palm Edge to Wrist
    hand.cubicTo(17.4, 17.0, 14.5, 21.0, 11.0, 21.0);

    // Scaled & Shifted Path for Left Hand (fit x in [0.5, 11.2])
    final Matrix4 leftMatrix = Matrix4.identity()
      ..translate(0.2, 1.0)
      ..scale(0.60, 0.90);
    final Path leftHandPath = hand.transform(leftMatrix.storage);

    // Draw Left Hand
    canvas.drawPath(leftHandPath, paint);

    // Draw Right Hand by flipping across center x = 12.0
    canvas.save();
    canvas.translate(24.0, 0.0);
    canvas.scale(-1.0, 1.0);
    canvas.drawPath(leftHandPath, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RuqyahDuaIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
