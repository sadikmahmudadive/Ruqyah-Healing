import 'package:flutter/material.dart';

/// Modern Home Navigation Icon with refined geometry and clean active/inactive states
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

    final Paint fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Paint strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.75
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (isSelected) {
      // Solid Modern House with smooth gable apex and arched door cutout
      final Path house = Path()
        ..moveTo(12.0, 2.8)
        ..cubicTo(12.5, 2.8, 13.0, 3.1, 13.4, 3.5)
        ..lineTo(20.4, 9.2)
        ..cubicTo(21.0, 9.7, 21.3, 10.4, 21.3, 11.2)
        ..lineTo(21.3, 19.0)
        ..cubicTo(21.3, 20.1, 20.4, 21.0, 19.3, 21.0)
        ..lineTo(4.7, 21.0)
        ..cubicTo(3.6, 21.0, 2.7, 20.1, 2.7, 19.0)
        ..lineTo(2.7, 11.2)
        ..cubicTo(2.7, 10.4, 3.0, 9.7, 3.6, 9.2)
        ..lineTo(10.6, 3.5)
        ..cubicTo(11.0, 3.1, 11.5, 2.8, 12.0, 2.8)
        ..close();

      // Arched Door Cutout
      final Path door = Path()
        ..moveTo(9.5, 21.0)
        ..lineTo(9.5, 15.2)
        ..cubicTo(9.5, 13.8, 10.6, 12.8, 12.0, 12.8)
        ..cubicTo(13.4, 12.8, 14.5, 13.8, 14.5, 15.2)
        ..lineTo(14.5, 21.0)
        ..close();

      final Path combined = Path.combine(PathOperation.difference, house, door);
      canvas.drawPath(combined, fillPaint);
    } else {
      // Crisp Monoline Outline
      final Path houseOutline = Path()
        ..moveTo(12.0, 3.2)
        ..lineTo(20.2, 9.7)
        ..cubicTo(20.6, 10.0, 20.8, 10.5, 20.8, 11.0)
        ..lineTo(20.8, 18.8)
        ..cubicTo(20.8, 19.8, 20.0, 20.6, 19.0, 20.6)
        ..lineTo(5.0, 20.6)
        ..cubicTo(4.0, 20.6, 3.2, 19.8, 3.2, 18.8)
        ..lineTo(3.2, 11.0)
        ..cubicTo(3.2, 10.5, 3.4, 10.0, 3.8, 9.7)
        ..close();
      canvas.drawPath(houseOutline, strokePaint);

      final Path doorPath = Path()
        ..moveTo(9.8, 20.6)
        ..lineTo(9.8, 15.5)
        ..cubicTo(9.8, 14.3, 10.8, 13.4, 12.0, 13.4)
        ..cubicTo(13.2, 13.4, 14.2, 14.3, 14.2, 15.5)
        ..lineTo(14.2, 20.6);
      canvas.drawPath(doorPath, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HomeNavIconPainter oldDelegate) {
    return oldDelegate.isSelected != isSelected || oldDelegate.color != color;
  }
}

/// Modern Services Bento Grid Navigation Icon
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
      ..strokeWidth = isSelected ? 0.0 : 1.75
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    const double radius = 3.2;

    // 4 Modern Bento Rounded Quadrants
    final RRect r1 =
        RRect.fromLTRBR(3.2, 3.2, 10.8, 10.8, const Radius.circular(radius));
    final RRect r2 =
        RRect.fromLTRBR(13.2, 3.2, 20.8, 10.8, const Radius.circular(radius));
    final RRect r3 =
        RRect.fromLTRBR(3.2, 13.2, 10.8, 20.8, const Radius.circular(radius));
    final RRect r4 =
        RRect.fromLTRBR(13.2, 13.2, 20.8, 20.8, const Radius.circular(radius));

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

/// Modern Bookings / Calendar Navigation Icon
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
      ..strokeWidth = 1.75
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Paint fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final RRect calRect =
        RRect.fromLTRBR(3.2, 5.0, 20.8, 21.0, const Radius.circular(4.5));

    if (isSelected) {
      canvas.drawRRect(calRect, fillPaint);

      // Contrast header line & binder rings cutout in white
      final Paint cutoutPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromLTRBR(6.8, 2.4, 9.2, 6.2, const Radius.circular(1.2)),
        cutoutPaint,
      );
      canvas.drawRRect(
        RRect.fromLTRBR(14.8, 2.4, 17.2, 6.2, const Radius.circular(1.2)),
        cutoutPaint,
      );

      // Clean date dots
      final Paint dotPaint = Paint()..color = Colors.white;
      canvas.drawCircle(const Offset(8.0, 13.0), 1.2, dotPaint);
      canvas.drawCircle(const Offset(12.0, 13.0), 1.2, dotPaint);
      canvas.drawCircle(const Offset(16.0, 13.0), 1.2, dotPaint);
      canvas.drawCircle(const Offset(8.0, 17.0), 1.2, dotPaint);
      canvas.drawCircle(const Offset(12.0, 17.0), 1.2, dotPaint);
      canvas.drawCircle(const Offset(16.0, 17.0), 1.2, dotPaint);
    } else {
      canvas.drawRRect(calRect, strokePaint);

      // Header separation line
      canvas.drawLine(
        const Offset(3.2, 10.0),
        const Offset(20.8, 10.0),
        strokePaint,
      );

      // Binder Hooks
      canvas.drawLine(
        const Offset(7.5, 2.4),
        const Offset(7.5, 6.0),
        strokePaint,
      );
      canvas.drawLine(
        const Offset(16.5, 2.4),
        const Offset(16.5, 6.0),
        strokePaint,
      );

      // Date dots
      final Paint dotPaint = Paint()..color = color;
      canvas.drawCircle(const Offset(8.0, 14.5), 1.1, dotPaint);
      canvas.drawCircle(const Offset(12.0, 14.5), 1.1, dotPaint);
      canvas.drawCircle(const Offset(16.0, 14.5), 1.1, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BookingsNavIconPainter oldDelegate) {
    return oldDelegate.isSelected != isSelected || oldDelegate.color != color;
  }
}

/// Modern Learn / Book of Wisdom Navigation Icon
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
      ..strokeWidth = 1.75
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Paint fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Left Page Flow
    final Path leftPage = Path()
      ..moveTo(12.0, 5.5)
      ..cubicTo(9.0, 4.0, 4.8, 4.2, 2.8, 5.2)
      ..cubicTo(2.4, 5.4, 2.2, 5.8, 2.2, 6.3)
      ..lineTo(2.2, 18.5)
      ..cubicTo(2.2, 19.0, 2.6, 19.4, 3.1, 19.3)
      ..cubicTo(5.2, 18.5, 9.0, 18.5, 12.0, 19.8)
      ..close();

    // Right Page Flow
    final Path rightPage = Path()
      ..moveTo(12.0, 5.5)
      ..cubicTo(15.0, 4.0, 19.2, 4.2, 21.2, 5.2)
      ..cubicTo(21.6, 5.4, 21.8, 5.8, 21.8, 6.3)
      ..lineTo(21.8, 18.5)
      ..cubicTo(21.8, 19.0, 21.4, 19.4, 20.9, 19.3)
      ..cubicTo(18.8, 18.5, 15.0, 18.5, 12.0, 19.8)
      ..close();

    if (isSelected) {
      canvas.drawPath(leftPage, fillPaint);
      canvas.drawPath(rightPage, fillPaint);

      // Spine division in white
      final Paint spinePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        const Offset(12.0, 6.0),
        const Offset(12.0, 19.5),
        spinePaint,
      );
    } else {
      canvas.drawPath(leftPage, strokePaint);
      canvas.drawPath(rightPage, strokePaint);
      canvas.drawLine(
        const Offset(12.0, 5.5),
        const Offset(12.0, 19.8),
        strokePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LearnNavIconPainter oldDelegate) {
    return oldDelegate.isSelected != isSelected || oldDelegate.color != color;
  }
}

/// Modern Profile / Avatar Navigation Icon
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
      ..strokeWidth = 1.75
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Paint fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Head Avatar
    final Offset headCenter = const Offset(12.0, 7.5);
    const double headRadius = 4.2;

    // Shoulders Arc
    final Path shouldersPath = Path()
      ..moveTo(3.6, 20.5)
      ..cubicTo(3.6, 16.2, 7.2, 14.0, 12.0, 14.0)
      ..cubicTo(16.8, 14.0, 20.4, 16.2, 20.4, 20.5);

    if (isSelected) {
      canvas.drawCircle(headCenter, headRadius, fillPaint);
      final Path closedShoulders = Path.from(shouldersPath)
        ..lineTo(20.4, 21.0)
        ..lineTo(3.6, 21.0)
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
