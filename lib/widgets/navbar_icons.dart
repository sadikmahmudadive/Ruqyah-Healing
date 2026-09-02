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

  static const String _activePathData =
      'M51.22 20c0-11.05-8.96-20-20-20H0v31.22c0 11.04 8.95 20 20 20h31.22V20Z M56.78 20c0-11.05 8.96-20 20-20H108v31.22c0 11.04-8.95 20-20 20H56.78V20Z M20 56.78c-11.05 0-20 8.96-20 20V108h31.22c11.04 0 20-8.95 20-20V56.78H20Z M88 56.78c11.05 0 20 8.96 20 20V108H76.78c-11.04 0-20-8.95-20-20V56.78H88Z';

  static const String _inactivePathData =
      'M31.22 1.5H1.5v29.72c0 10.21 8.28 18.5 18.5 18.5h29.72V20c0-10.22-8.29-18.5-18.5-18.5Z M76.78 1.5h29.72v29.72c0 10.21-8.28 18.5-18.5 18.5H58.28V20c0-10.22 8.29-18.5 18.5-18.5Z M1.5 76.78v29.72h29.72c10.21 0 18.5-8.28 18.5-18.5V58.28H20c-10.22 0-18.5 8.29-18.5 18.5Z M106.5 76.78v29.72H76.78c-10.21 0-18.5-8.28-18.5-18.5V58.28H88c10.22 0 18.5 8.29 18.5 18.5Z';

  static Path? _cachedActivePath;
  static Path? _cachedInactivePath;

  _ServicesNavIconPainter({required this.isSelected, required this.color});

  static Path _parseSvgPath(String data) {
    final Path path = Path();
    double currentX = 0;
    double currentY = 0;
    double startX = 0;
    double startY = 0;

    final RegExp regExp =
        RegExp(r'([a-zA-Z])|([-+]?(?:\d*\.\d+|\d+)(?:[eE][-+]?\d+)?)');
    final matches = regExp.allMatches(data).toList();

    int i = 0;
    String command = '';

    double nextNum() {
      if (i < matches.length && matches[i].group(2) != null) {
        final val = double.parse(matches[i].group(2)!);
        i++;
        return val;
      }
      return 0.0;
    }

    while (i < matches.length) {
      final match = matches[i];
      if (match.group(1) != null) {
        command = match.group(1)!;
        i++;
      }

      switch (command) {
        case 'M':
          currentX = nextNum();
          currentY = nextNum();
          startX = currentX;
          startY = currentY;
          path.moveTo(currentX, currentY);
          command = 'L';
          break;
        case 'm':
          currentX += nextNum();
          currentY += nextNum();
          startX = currentX;
          startY = currentY;
          path.moveTo(currentX, currentY);
          command = 'l';
          break;
        case 'L':
          currentX = nextNum();
          currentY = nextNum();
          path.lineTo(currentX, currentY);
          break;
        case 'l':
          currentX += nextNum();
          currentY += nextNum();
          path.lineTo(currentX, currentY);
          break;
        case 'H':
          currentX = nextNum();
          path.lineTo(currentX, currentY);
          break;
        case 'h':
          currentX += nextNum();
          path.lineTo(currentX, currentY);
          break;
        case 'V':
          currentY = nextNum();
          path.lineTo(currentX, currentY);
          break;
        case 'v':
          currentY += nextNum();
          path.lineTo(currentX, currentY);
          break;
        case 'C':
          final x1 = nextNum();
          final y1 = nextNum();
          final x2 = nextNum();
          final y2 = nextNum();
          currentX = nextNum();
          currentY = nextNum();
          path.cubicTo(x1, y1, x2, y2, currentX, currentY);
          break;
        case 'c':
          final dx1 = nextNum();
          final dy1 = nextNum();
          final dx2 = nextNum();
          final dy2 = nextNum();
          final dx = nextNum();
          final dy = nextNum();
          path.cubicTo(
            currentX + dx1,
            currentY + dy1,
            currentX + dx2,
            currentY + dy2,
            currentX + dx,
            currentY + dy,
          );
          currentX += dx;
          currentY += dy;
          break;
        case 'Z':
        case 'z':
          path.close();
          currentX = startX;
          currentY = startY;
          break;
        default:
          i++;
          break;
      }
    }

    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / 108.0;
    canvas.scale(scale, scale);

    if (isSelected) {
      _cachedActivePath ??= _parseSvgPath(_activePathData);
      final Paint fillPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawPath(_cachedActivePath!, fillPaint);
    } else {
      _cachedInactivePath ??= _parseSvgPath(_inactivePathData);
      final Paint strokePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(_cachedInactivePath!, strokePaint);
    }
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
