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

    final Paint fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Paint strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (isSelected) {
      // Solid pentagon house block matching reference image
      final Path houseBlock = Path()
        ..moveTo(12.0, 3.2)
        ..lineTo(20.5, 9.2)
        ..cubicTo(21.2, 9.7, 21.2, 10.4, 21.2, 11.0)
        ..lineTo(21.2, 18.5)
        ..cubicTo(21.2, 19.9, 20.1, 21.0, 18.7, 21.0)
        ..lineTo(5.3, 21.0)
        ..cubicTo(3.9, 21.0, 2.8, 19.9, 2.8, 18.5)
        ..lineTo(2.8, 11.0)
        ..cubicTo(2.8, 10.4, 2.8, 9.7, 3.5, 9.2)
        ..close();
      canvas.drawPath(houseBlock, fillPaint);
    } else {
      // Outlined pentagon house with door cutout inside
      final Path houseOutline = Path()
        ..moveTo(12.0, 3.5)
        ..lineTo(20.2, 9.5)
        ..lineTo(20.2, 18.5)
        ..cubicTo(20.2, 19.9, 19.1, 21.0, 17.8, 21.0)
        ..lineTo(6.2, 21.0)
        ..cubicTo(4.9, 21.0, 3.8, 19.9, 3.8, 18.5)
        ..lineTo(3.8, 9.5)
        ..close();
      canvas.drawPath(houseOutline, strokePaint);

      final Path doorPath = Path()
        ..moveTo(10.0, 21.0)
        ..lineTo(10.0, 15.2)
        ..cubicTo(10.0, 14.1, 10.9, 13.2, 12.0, 13.2)
        ..cubicTo(13.1, 13.2, 14.0, 14.1, 14.0, 15.2)
        ..lineTo(14.0, 21.0);
      canvas.drawPath(doorPath, strokePaint);
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

    const double radius = 3.5;

    // 4 Bento Quadrants matching reference image
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

    // Calendar Card Frame
    final RRect calRect =
        RRect.fromLTRBR(3.5, 5.0, 20.5, 21.0, const Radius.circular(4.0));

    if (isSelected) {
      canvas.drawRRect(calRect, fillPaint);
      // Top hooks cutouts in clear/white
      final Paint clearPaint = Paint()..color = const Color(0xFFFBFDFC);
      canvas.drawRRect(
        RRect.fromLTRBR(7.0, 2.5, 9.0, 6.5, const Radius.circular(1.0)),
        clearPaint,
      );
      canvas.drawRRect(
        RRect.fromLTRBR(15.0, 2.5, 17.0, 6.5, const Radius.circular(1.0)),
        clearPaint,
      );
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
        const Offset(8.0, 2.5),
        const Offset(8.0, 6.0),
        strokePaint,
      );
      canvas.drawLine(
        const Offset(16.0, 2.5),
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
