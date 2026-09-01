import 'package:flutter/material.dart';

class HomeNavIcon extends StatelessWidget {
  final bool isSelected;
  final Color color;
  final double size;

  const HomeNavIcon({
    super.key,
    required this.isSelected,
    required this.color,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _HomeNavIconPainter(isSelected: isSelected, color: color),
      ),
    );
  }
}

class _HomeNavIconPainter extends CustomPainter {
  final bool isSelected;
  final Color color;

  _HomeNavIconPainter({required this.isSelected, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / 24.0;
    canvas.scale(scale, scale);

    final Paint paint = Paint()
      ..color = color
      ..style = isSelected ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = isSelected ? 0.0 : 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (isSelected) {
      final Path filledPath = Path()
        ..moveTo(12.0, 3.2)
        ..lineTo(21.0, 10.2)
        ..cubicTo(21.5, 10.6, 21.5, 11.2, 21.0, 11.6)
        ..lineTo(20.2, 12.3)
        ..cubicTo(19.8, 12.7, 19.2, 12.6, 18.8, 12.2)
        ..lineTo(18.0, 11.5)
        ..lineTo(18.0, 19.5)
        ..cubicTo(18.0, 20.6, 17.1, 21.5, 16.0, 21.5)
        ..lineTo(8.0, 21.5)
        ..cubicTo(6.9, 21.5, 6.0, 20.6, 6.0, 19.5)
        ..lineTo(6.0, 11.5)
        ..lineTo(5.2, 12.2)
        ..cubicTo(4.8, 12.6, 4.2, 12.7, 3.8, 12.3)
        ..lineTo(3.0, 11.6)
        ..cubicTo(2.5, 11.2, 2.5, 10.6, 3.0, 10.2)
        ..close();
      canvas.drawPath(filledPath, paint);
    } else {
      final Path outlinePath = Path()
        ..moveTo(12.0, 3.5)
        ..lineTo(20.0, 10.0)
        ..lineTo(20.0, 19.5)
        ..cubicTo(20.0, 20.3, 19.3, 21.0, 18.5, 21.0)
        ..lineTo(5.5, 21.0)
        ..cubicTo(4.7, 21.0, 4.0, 20.3, 4.0, 19.5)
        ..lineTo(4.0, 10.0)
        ..close();
      canvas.drawPath(outlinePath, paint);

      // Inner door outline
      final Path doorPath = Path()
        ..moveTo(10.0, 21.0)
        ..lineTo(10.0, 15.0)
        ..cubicTo(10.0, 13.9, 10.9, 13.0, 12.0, 13.0)
        ..cubicTo(13.1, 13.0, 14.0, 13.9, 14.0, 15.0)
        ..lineTo(14.0, 21.0);
      canvas.drawPath(doorPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _HomeNavIconPainter oldDelegate) {
    return oldDelegate.isSelected != isSelected || oldDelegate.color != color;
  }
}

class ServicesNavIcon extends StatelessWidget {
  final bool isSelected;
  final Color color;
  final double size;

  const ServicesNavIcon({
    super.key,
    required this.isSelected,
    required this.color,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ServicesNavIconPainter(isSelected: isSelected, color: color),
      ),
    );
  }
}

class _ServicesNavIconPainter extends CustomPainter {
  final bool isSelected;
  final Color color;

  _ServicesNavIconPainter({required this.isSelected, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / 24.0;
    canvas.scale(scale, scale);

    final Paint paint = Paint()
      ..color = color
      ..style = isSelected ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = isSelected ? 0.0 : 2.0;

    const double radius = 3.0;

    // 4 Bento Quadrants
    final RRect r1 = RRect.fromLTRBR(3.0, 3.0, 10.5, 10.5, const Radius.circular(radius));
    final RRect r2 = RRect.fromLTRBR(13.5, 3.0, 21.0, 10.5, const Radius.circular(radius));
    final RRect r3 = RRect.fromLTRBR(3.0, 13.5, 10.5, 21.0, const Radius.circular(radius));
    final RRect r4 = RRect.fromLTRBR(13.5, 13.5, 21.0, 21.0, const Radius.circular(radius));

    canvas.drawRRect(r1, paint);
    canvas.drawRRect(r2, paint);
    canvas.drawRRect(r3, paint);
    canvas.drawRRect(r4, paint);
  }

  @override
  bool shouldRepaint(covariant _ServicesNavIconPainter oldDelegate) {
    return oldDelegate.isSelected != isSelected || oldDelegate.color != color;
  }
}

class BookingsNavIcon extends StatelessWidget {
  final bool isSelected;
  final Color color;
  final double size;

  const BookingsNavIcon({
    super.key,
    required this.isSelected,
    required this.color,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BookingsNavIconPainter(isSelected: isSelected, color: color),
      ),
    );
  }
}

class _BookingsNavIconPainter extends CustomPainter {
  final bool isSelected;
  final Color color;

  _BookingsNavIconPainter({required this.isSelected, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / 24.0;
    canvas.scale(scale, scale);

    final Paint strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Paint fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Calendar Frame
    final RRect calRect =
        RRect.fromLTRBR(3.5, 5.0, 20.5, 21.0, const Radius.circular(4.0));

    if (isSelected) {
      canvas.drawRRect(calRect, fillPaint);
      // Top cut for hooks in white
      final Paint clearPaint = Paint()..color = const Color(0xFFFBFDFC);
      canvas.drawCircle(const Offset(8.0, 4.0), 1.5, clearPaint);
      canvas.drawCircle(const Offset(16.0, 4.0), 1.5, clearPaint);
    } else {
      canvas.drawRRect(calRect, strokePaint);
      // Top header line
      canvas.drawLine(
        const Offset(3.5, 10.0),
        const Offset(20.5, 10.0),
        strokePaint,
      );
      // Hooks
      canvas.drawLine(
        const Offset(8.0, 3.0),
        const Offset(8.0, 6.0),
        strokePaint,
      );
      canvas.drawLine(
        const Offset(16.0, 3.0),
        const Offset(16.0, 6.0),
        strokePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BookingsNavIconPainter oldDelegate) {
    return oldDelegate.isSelected != isSelected || oldDelegate.color != color;
  }
}

class LearnNavIcon extends StatelessWidget {
  final bool isSelected;
  final Color color;
  final double size;

  const LearnNavIcon({
    super.key,
    required this.isSelected,
    required this.color,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _LearnNavIconPainter(isSelected: isSelected, color: color),
      ),
    );
  }
}

class _LearnNavIconPainter extends CustomPainter {
  final bool isSelected;
  final Color color;

  _LearnNavIconPainter({required this.isSelected, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / 24.0;
    canvas.scale(scale, scale);

    final Paint strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Paint fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Left Page
    final Path leftPage = Path()
      ..moveTo(12.0, 6.0)
      ..cubicTo(9.0, 4.5, 5.0, 4.5, 3.0, 5.5)
      ..lineTo(3.0, 19.5)
      ..cubicTo(5.0, 18.5, 9.0, 18.5, 12.0, 20.0)
      ..close();

    // Right Page
    final Path rightPage = Path()
      ..moveTo(12.0, 6.0)
      ..cubicTo(15.0, 4.5, 19.0, 4.5, 21.0, 5.5)
      ..lineTo(21.0, 19.5)
      ..cubicTo(19.0, 18.5, 15.0, 18.5, 12.0, 20.0)
      ..close();

    if (isSelected) {
      canvas.drawPath(leftPage, fillPaint);
      canvas.drawPath(rightPage, fillPaint);
    } else {
      canvas.drawPath(leftPage, strokePaint);
      canvas.drawPath(rightPage, strokePaint);
      canvas.drawLine(
        const Offset(12.0, 6.0),
        const Offset(12.0, 20.0),
        strokePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LearnNavIconPainter oldDelegate) {
    return oldDelegate.isSelected != isSelected || oldDelegate.color != color;
  }
}

class ProfileNavIcon extends StatelessWidget {
  final bool isSelected;
  final Color color;
  final double size;

  const ProfileNavIcon({
    super.key,
    required this.isSelected,
    required this.color,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ProfileNavIconPainter(isSelected: isSelected, color: color),
      ),
    );
  }
}

class _ProfileNavIconPainter extends CustomPainter {
  final bool isSelected;
  final Color color;

  _ProfileNavIconPainter({required this.isSelected, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / 24.0;
    canvas.scale(scale, scale);

    final Paint strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Paint fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Head circle
    final Offset headCenter = const Offset(12.0, 7.5);
    const double headRadius = 4.0;

    // Shoulders Arc
    final Path shouldersPath = Path()
      ..moveTo(4.0, 20.5)
      ..cubicTo(4.0, 16.5, 7.5, 14.0, 12.0, 14.0)
      ..cubicTo(16.5, 14.0, 20.0, 16.5, 20.0, 20.5);

    if (isSelected) {
      canvas.drawCircle(headCenter, headRadius, fillPaint);
      final Path closedShoulders = Path.from(shouldersPath)
        ..lineTo(20.0, 21.0)
        ..lineTo(4.0, 21.0)
        ..close();
      canvas.drawPath(closedShoulders, fillPaint);
    } else {
      canvas.drawCircle(headCenter, headRadius, strokePaint);
      canvas.drawPath(shouldersPath, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ProfileNavIconPainter oldDelegate) {
    return oldDelegate.isSelected != isSelected || oldDelegate.color != color;
  }
}
