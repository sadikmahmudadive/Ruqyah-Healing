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
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _HomeIconPainter(isSelected: isSelected, color: color),
        ),
      ),
    );
  }
}

class _HomeIconPainter extends CustomPainter {
  final bool isSelected;
  final Color color;

  _HomeIconPainter({required this.isSelected, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 21.0;
    canvas.scale(scale, scale * (size.height / size.width) * (21.0 / 23.0));

    final paint = Paint()..color = color;

    if (isSelected) {
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2.0;
      paint.strokeCap = StrokeCap.round;

      final path1 = Path()
        ..moveTo(13.67, 22)
        ..lineTo(13.67, 13.16)
        ..cubicTo(13.67, 12.86, 13.56, 12.58, 13.36, 12.38)
        ..cubicTo(13.16, 12.17, 12.89, 12.05, 12.61, 12.05)
        ..lineTo(8.4, 12.05)
        ..cubicTo(8.12, 12.05, 7.85, 12.17, 7.65, 12.38)
        ..cubicTo(7.45, 12.58, 7.35, 12.86, 7.35, 13.16)
        ..lineTo(7.35, 22)
        ..moveTo(1, 9.84)
        ..cubicTo(1, 9.52, 1.07, 9.2, 1.2, 8.91)
        ..cubicTo(1.33, 8.62, 1.5, 8.36, 1.75, 8.15)
        ..lineTo(9.14, 1.52)
        ..cubicTo(9.52, 1.2, 10, 1, 10.5, 1)
        ..cubicTo(11, 1, 11.48, 1.19, 11.86, 1.52)
        ..lineTo(19.26, 8.15)
        ..cubicTo(19.49, 8.36, 19.67, 8.62, 19.8, 8.91)
        ..cubicTo(19.93, 9.21, 20, 9.52, 20, 9.84)
        ..lineTo(20, 19.79)
        ..cubicTo(20, 20.38, 19.78, 20.94, 19.38, 21.35)
        ..cubicTo(18.98, 21.77, 18.45, 22, 17.88, 22)
        ..lineTo(3.12, 22)
        ..cubicTo(2.56, 22, 2.02, 21.77, 1.62, 21.35)
        ..cubicTo(1.23, 20.94, 1, 20.38, 1, 19.8)
        ..lineTo(1, 9.84)
        ..close();
      canvas.drawPath(path1, paint);
    } else {
      paint.style = PaintingStyle.fill;
      final path = Path()
        ..moveTo(1.2, 8.91)
        ..cubicTo(1.07, 9.21, 1, 9.52, 1, 9.84)
        ..lineTo(1, 19.79)
        ..cubicTo(1, 20.38, 1.22, 20.94, 1.62, 21.35)
        ..cubicTo(2.02, 21.77, 2.55, 22, 3.12, 22)
        ..lineTo(17.89, 22)
        ..cubicTo(18.45, 22, 18.99, 21.77, 19.39, 21.35)
        ..cubicTo(19.78, 20.94, 20, 20.38, 20, 19.79)
        ..lineTo(20, 9.84)
        ..cubicTo(20, 9.52, 19.93, 9.2, 19.8, 8.91)
        ..cubicTo(19.67, 8.62, 19.49, 8.36, 19.25, 8.15)
        ..lineTo(11.86, 1.52)
        ..cubicTo(11.48, 1.2, 11, 1, 10.5, 1)
        ..cubicTo(10, 1, 9.52, 1.19, 9.14, 1.52)
        ..lineTo(1.74, 8.15)
        ..cubicTo(1.52, 8.36, 1.34, 8.62, 1.2, 8.91)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _HomeIconPainter oldDelegate) {
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
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _ServicesIconPainter(isSelected: isSelected, color: color),
        ),
      ),
    );
  }
}

class _ServicesIconPainter extends CustomPainter {
  final bool isSelected;
  final Color color;

  _ServicesIconPainter({required this.isSelected, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 21.0;
    canvas.scale(scale, scale * (size.height / size.width));

    final paint = Paint()..color = color;

    if (isSelected) {
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2.0;
      paint.strokeCap = StrokeCap.round;

      final path1 = Path()
        ..moveTo(5, 1)
        ..lineTo(9, 1)
        ..lineTo(9, 9)
        ..lineTo(1, 9)
        ..lineTo(1, 5)
        ..cubicTo(1, 2.8, 2.8, 1, 5, 1)
        ..close();
      canvas.drawPath(path1, paint);

      final path2 = Path()
        ..moveTo(16, 1)
        ..cubicTo(18.2, 1, 20, 2.8, 20, 5)
        ..lineTo(20, 9)
        ..lineTo(12, 9)
        ..lineTo(12, 1)
        ..lineTo(16, 1)
        ..close();
      canvas.drawPath(path2, paint);

      final path3 = Path()
        ..moveTo(20, 12)
        ..lineTo(20, 16)
        ..cubicTo(20, 18.2, 18.2, 20, 16, 20)
        ..lineTo(12, 20)
        ..lineTo(12, 12)
        ..lineTo(20, 12)
        ..close();
      canvas.drawPath(path3, paint);

      final path4 = Path()
        ..moveTo(9, 12)
        ..lineTo(9, 20)
        ..lineTo(5, 20)
        ..cubicTo(2.8, 20, 1, 18.2, 1, 16)
        ..lineTo(1, 12)
        ..lineTo(9, 12)
        ..close();
      canvas.drawPath(path4, paint);
    } else {
      paint.style = PaintingStyle.fill;
      final path1 = Path()
        ..moveTo(0, 5)
        ..cubicTo(0, 2.24, 2.24, 0, 5, 0)
        ..lineTo(10, 0)
        ..lineTo(10, 10)
        ..lineTo(0, 10)
        ..lineTo(0, 5)
        ..close();
      canvas.drawPath(path1, paint);
      final path2 = Path()
        ..moveTo(11, 0)
        ..lineTo(16, 0)
        ..cubicTo(18.76, 0, 21, 2.24, 21, 5)
        ..lineTo(21, 10)
        ..lineTo(11, 10)
        ..lineTo(11, 0)
        ..close();
      canvas.drawPath(path2, paint);
      final path3 = Path()
        ..moveTo(11, 11)
        ..lineTo(21, 11)
        ..lineTo(21, 16)
        ..cubicTo(21, 18.76, 18.76, 21, 16, 21)
        ..lineTo(11, 21)
        ..lineTo(11, 11)
        ..close();
      canvas.drawPath(path3, paint);
      final path4 = Path()
        ..moveTo(0, 11)
        ..lineTo(10, 11)
        ..lineTo(10, 21)
        ..lineTo(5, 21)
        ..cubicTo(2.24, 21, 0, 18.76, 0, 16)
        ..lineTo(0, 11)
        ..close();
      canvas.drawPath(path4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ServicesIconPainter oldDelegate) {
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
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _BookingsIconPainter(isSelected: isSelected, color: color),
        ),
      ),
    );
  }
}

class _BookingsIconPainter extends CustomPainter {
  final bool isSelected;
  final Color color;

  _BookingsIconPainter({required this.isSelected, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    if (isSelected) {
      final scale = size.width / 22.0;
      canvas.scale(scale, scale * (size.height / size.width));

      paint.style = PaintingStyle.fill;
      final path1 = Path()
        ..moveTo(17.42, 1.83)
        ..lineTo(16.74, 1.83)
        ..lineTo(16.74, 0.92)
        ..cubicTo(16.74, 0.42, 16.33, 0, 15.82, 0)
        ..cubicTo(15.32, 0, 14.9, 0.41, 14.9, 0.92)
        ..lineTo(14.9, 1.83)
        ..lineTo(7.1, 1.83)
        ..lineTo(7.1, 0.92)
        ..cubicTo(7.1, 0.42, 6.67, 0, 6.17, 0)
        ..cubicTo(5.67, 0, 5.26, 0.41, 5.26, 0.92)
        ..lineTo(5.26, 1.83)
        ..lineTo(4.58, 1.83)
        ..cubicTo(2.05, 1.83, 0, 3.9, 0, 6.42)
        ..lineTo(0, 17.42)
        ..cubicTo(0, 19.95, 2.05, 22, 4.58, 22)
        ..lineTo(17.42, 22)
        ..cubicTo(19.95, 22, 22, 19.95, 22, 17.42)
        ..lineTo(22, 6.42)
        ..cubicTo(22, 3.89, 19.95, 1.83, 17.42, 1.83)
        ..close()
        ..moveTo(20.17, 17.42)
        ..cubicTo(20.17, 18.92, 18.93, 20.17, 17.42, 20.17)
        ..lineTo(4.58, 20.17)
        ..cubicTo(3.08, 20.17, 1.83, 18.93, 1.83, 17.42)
        ..lineTo(1.83, 6.42)
        ..cubicTo(1.83, 4.9, 3.07, 3.67, 4.58, 3.67)
        ..lineTo(5.26, 3.67)
        ..lineTo(5.26, 4.59)
        ..cubicTo(5.26, 5.09, 5.67, 5.51, 6.17, 5.51)
        ..cubicTo(6.67, 5.51, 7.09, 5.1, 7.09, 4.59)
        ..lineTo(7.09, 3.67)
        ..lineTo(14.89, 3.67)
        ..lineTo(14.89, 4.59)
        ..cubicTo(14.89, 5.09, 15.31, 5.51, 15.81, 5.51)
        ..cubicTo(16.31, 5.51, 16.73, 5.1, 16.73, 4.59)
        ..lineTo(16.73, 3.67)
        ..lineTo(17.41, 3.67)
        ..cubicTo(18.91, 3.67, 20.16, 4.9, 20.16, 6.42)
        ..lineTo(20.16, 17.42)
        ..close();
      canvas.drawPath(path1, paint);
      final path2 = Path()
        ..moveTo(16.48, 6.95)
        ..lineTo(5.52, 6.95)
        ..cubicTo(5.03, 6.95, 4.63, 7.47, 4.63, 8.11)
        ..cubicTo(4.63, 8.74, 5.03, 9.26, 5.52, 9.26)
        ..lineTo(16.48, 9.26)
        ..cubicTo(16.97, 9.26, 17.37, 8.74, 17.37, 8.11)
        ..cubicTo(17.37, 7.47, 16.97, 6.95, 16.48, 6.95)
        ..close();
      canvas.drawPath(path2, paint);
    } else {
      final scale = size.width / 24.42;
      canvas.scale(scale, scale * (size.height / size.width));
      canvas.translate(-5.85, -5.46);

      paint.style = PaintingStyle.fill;
      final path1 = Path()
        ..moveTo(12.88, 5.47)
        ..cubicTo(13.49, 5.47, 13.99, 5.96, 13.99, 6.57)
        ..lineTo(13.99, 6.93)
        ..lineTo(15.76, 6.93)
        ..lineTo(20.36, 6.93)
        ..lineTo(22.13, 6.93)
        ..lineTo(22.13, 6.56)
        ..cubicTo(22.13, 5.96, 22.63, 5.46, 23.24, 5.46)
        ..cubicTo(23.85, 5.46, 24.35, 5.96, 24.35, 6.56)
        ..lineTo(24.35, 7)
        ..lineTo(25.3, 7.1)
        ..cubicTo(26.63, 7.27, 27.76, 7.65, 28.65, 8.53)
        ..cubicTo(29.54, 9.41, 29.92, 10.51, 30.1, 11.83)
        ..lineTo(30.2, 12.76)
        ..lineTo(5.92, 12.76)
        ..cubicTo(5.94, 12.43, 5.97, 12.12, 6.02, 11.82)
        ..cubicTo(6.19, 10.52, 6.58, 9.41, 7.47, 8.52)
        ..cubicTo(8.36, 7.65, 9.48, 7.27, 10.81, 7.1)
        ..lineTo(11.77, 7)
        ..lineTo(11.77, 6.56)
        ..cubicTo(11.77, 5.96, 12.27, 5.46, 12.88, 5.46)
        ..close();
      canvas.drawPath(path1, paint);
      final path2 = Path()
        ..fillType = PathFillType.evenOdd
        ..moveTo(5.85, 16.7)
        ..lineTo(5.85, 14.95)
        ..lineTo(30.27, 14.95)
        ..lineTo(30.27, 16.69)
        ..lineTo(30.27, 21.19)
        ..cubicTo(30.27, 22.52, 30.27, 23.58, 30.19, 24.44)
        ..cubicTo(30.11, 25.32, 29.94, 26.1, 29.53, 26.8)
        ..cubicTo(29.04, 27.63, 28.34, 28.32, 27.5, 28.8)
        ..cubicTo(26.78, 29.2, 26, 29.37, 25.1, 29.45)
        ..cubicTo(24.23, 29.53, 23.15, 29.53, 21.81, 29.53)
        ..lineTo(15.76, 29.53)
        ..cubicTo(13.74, 29.53, 12.1, 29.53, 10.82, 29.36)
        ..cubicTo(9.49, 29.18, 8.37, 28.81, 7.48, 27.93)
        ..cubicTo(6.58, 27.05, 6.2, 25.95, 6.02, 24.63)
        ..cubicTo(5.85, 23.37, 5.85, 21.76, 5.85, 19.77)
        ..lineTo(5.85, 16.69)
        ..close()
        ..moveTo(10.73, 22.85)
        ..cubicTo(10.73, 22.25, 11.23, 21.76, 11.83, 21.76)
        ..lineTo(19.73, 21.76)
        ..cubicTo(20.35, 21.76, 20.85, 22.25, 20.85, 22.86)
        ..cubicTo(20.85, 23.46, 20.35, 23.95, 19.74, 23.95)
        ..lineTo(11.84, 23.95)
        ..cubicTo(11.22, 23.95, 10.73, 23.45, 10.73, 22.85)
        ..close()
        ..moveTo(11.83, 17.62)
        ..cubicTo(11.23, 17.62, 10.73, 18.11, 10.73, 18.72)
        ..cubicTo(10.73, 19.32, 11.23, 19.8, 11.83, 19.8)
        ..lineTo(16.28, 19.8)
        ..cubicTo(16.89, 19.8, 17.38, 19.32, 17.38, 18.71)
        ..cubicTo(17.38, 18.11, 16.89, 17.62, 16.28, 17.62)
        ..lineTo(11.84, 17.62)
        ..close();
      canvas.drawPath(path2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BookingsIconPainter oldDelegate) {
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
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _LearnIconPainter(isSelected: isSelected, color: color),
        ),
      ),
    );
  }
}

class _LearnIconPainter extends CustomPainter {
  final bool isSelected;
  final Color color;

  _LearnIconPainter({required this.isSelected, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 29.0;
    canvas.scale(scale, scale);

    final paint = Paint()..color = color;

    if (isSelected) {
      paint.style = PaintingStyle.fill;
      final path1 = Path()
        ..moveTo(14.2, 20.3)
        ..cubicTo(14.2, 20.49, 14.12, 20.67, 13.99, 20.8)
        ..cubicTo(13.86, 20.93, 13.69, 21, 13.5, 21)
        ..cubicTo(13.32, 21, 13.14, 20.93, 13.01, 20.8)
        ..cubicTo(12.88, 20.67, 12.8, 20.49, 12.8, 20.3)
        ..lineTo(12.8, 20.28)
        ..cubicTo(12.79, 20, 12.68, 19.74, 12.5, 19.54)
        ..lineTo(12.48, 19.52)
        ..cubicTo(12.28, 19.32, 11.99, 19.2, 11.7, 19.2)
        ..lineTo(2.48, 19.2)
        ..cubicTo(1.84, 19.2, 1.23, 18.95, 0.77, 18.5)
        ..lineTo(0.76, 18.5)
        ..lineTo(0.73, 18.47)
        ..cubicTo(0.26, 18.01, 0, 17.37, 0, 16.71)
        ..lineTo(0, 2.5)
        ..cubicTo(0, 2.17, 0.06, 1.85, 0.19, 1.54)
        ..cubicTo(0.31, 1.24, 0.49, 0.96, 0.72, 0.74)
        ..cubicTo(0.95, 0.5, 1.22, 0.32, 1.52, 0.19)
        ..cubicTo(1.84, 0.06, 2.16, 0, 2.49, 0)
        ..lineTo(11.72, 0)
        ..cubicTo(12.38, 0, 12.99, 0.27, 13.43, 0.7)
        ..lineTo(13.45, 0.72)
        ..lineTo(13.47, 0.73)
        ..lineTo(13.51, 0.77)
        ..lineTo(13.55, 0.73)
        ..cubicTo(13.78, 0.5, 14.05, 0.32, 14.35, 0.19)
        ..cubicTo(14.64, 0.07, 14.96, 0, 15.29, 0)
        ..lineTo(24.52, 0)
        ..cubicTo(24.85, 0, 25.17, 0.06, 25.47, 0.19)
        ..cubicTo(25.77, 0.32, 26.05, 0.5, 26.27, 0.73)
        ..cubicTo(26.51, 0.96, 26.69, 1.24, 26.81, 1.54)
        ..cubicTo(26.94, 1.84, 27.01, 2.17, 27, 2.5)
        ..lineTo(27, 16.7)
        ..cubicTo(27, 17.35, 26.75, 17.96, 26.3, 18.43)
        ..lineTo(26.29, 18.44)
        ..lineTo(26.27, 18.47)
        ..cubicTo(25.81, 18.93, 25.17, 19.2, 24.52, 19.2)
        ..lineTo(15.3, 19.2)
        ..cubicTo(15.01, 19.2, 14.74, 19.31, 14.53, 19.51)
        ..lineTo(14.53, 19.52)
        ..cubicTo(14.33, 19.72, 14.21, 20, 14.2, 20.28)
        ..lineTo(14.2, 20.3)
        ..close()
        ..moveTo(12.8, 18.07)
        ..lineTo(12.8, 2.47)
        ..cubicTo(12.8, 2.19, 12.69, 1.92, 12.49, 1.72)
        ..lineTo(12.46, 1.69)
        ..cubicTo(12.26, 1.5, 12, 1.4, 11.71, 1.4)
        ..lineTo(2.48, 1.4)
        ..cubicTo(2.19, 1.4, 1.9, 1.53, 1.7, 1.74)
        ..cubicTo(1.51, 1.93, 1.39, 2.2, 1.39, 2.5)
        ..lineTo(1.39, 16.7)
        ..cubicTo(1.39, 17.01, 1.51, 17.28, 1.7, 17.49)
        ..lineTo(1.72, 17.5)
        ..cubicTo(1.92, 17.69, 2.18, 17.81, 2.48, 17.81)
        ..lineTo(11.71, 17.81)
        ..cubicTo(12.11, 17.81, 12.48, 17.91, 12.81, 18.07)
        ..close()
        ..moveTo(14.2, 2.5)
        ..lineTo(14.2, 18.07)
        ..cubicTo(14.53, 17.9, 14.9, 17.81, 15.29, 17.81)
        ..lineTo(24.52, 17.81)
        ..cubicTo(24.82, 17.81, 25.1, 17.68, 25.29, 17.49)
        ..lineTo(25.31, 17.48)
        ..cubicTo(25.51, 17.27, 25.61, 16.99, 25.61, 16.7)
        ..lineTo(25.61, 2.5)
        ..cubicTo(25.61, 2.2, 25.5, 1.93, 25.29, 1.72)
        ..cubicTo(25.09, 1.52, 24.81, 1.4, 24.52, 1.4)
        ..lineTo(15.3, 1.4)
        ..cubicTo(15.01, 1.4, 14.73, 1.5, 14.53, 1.71)
        ..cubicTo(14.33, 1.91, 14.21, 2.19, 14.2, 2.47)
        ..lineTo(14.2, 2.5)
        ..close()
        ..moveTo(4.45, 6.37)
        ..cubicTo(4.29, 6.35, 4.13, 6.27, 4, 6.14)
        ..cubicTo(3.9, 6.01, 3.83, 5.84, 3.83, 5.67)
        ..cubicTo(3.83, 5.5, 3.9, 5.33, 4.01, 5.21)
        ..cubicTo(4.13, 5.08, 4.3, 5, 4.46, 4.98)
        ..lineTo(9.73, 4.98)
        ..cubicTo(9.91, 4.98, 10.09, 5.05, 10.22, 5.18)
        ..cubicTo(10.35, 5.32, 10.42, 5.49, 10.42, 5.68)
        ..cubicTo(10.42, 5.86, 10.35, 6.04, 10.22, 6.17)
        ..cubicTo(10.09, 6.3, 9.92, 6.38, 9.72, 6.38)
        ..lineTo(4.47, 6.38)
        ..close()
        ..moveTo(4.47, 10.3)
        ..cubicTo(4.28, 10.3, 4.11, 10.22, 3.97, 10.1)
        ..cubicTo(3.85, 9.96, 3.77, 9.79, 3.77, 9.6)
        ..cubicTo(3.77, 9.42, 3.85, 9.24, 3.97, 9.1)
        ..cubicTo(4.11, 8.98, 4.28, 8.9, 4.47, 8.9)
        ..lineTo(9.74, 8.9)
        ..cubicTo(9.92, 8.9, 10.1, 8.98, 10.23, 9.1)
        ..cubicTo(10.36, 9.24, 10.42, 9.42, 10.42, 9.6)
        ..cubicTo(10.42, 9.79, 10.35, 9.96, 10.22, 10.1)
        ..cubicTo(10.09, 10.22, 9.92, 10.3, 9.72, 10.3)
        ..lineTo(4.47, 10.3)
        ..close()
        ..moveTo(4.47, 14.23)
        ..cubicTo(4.28, 14.23, 4.11, 14.15, 3.97, 14.03)
        ..cubicTo(3.85, 13.89, 3.77, 13.72, 3.77, 13.53)
        ..cubicTo(3.77, 13.35, 3.85, 13.17, 3.97, 13.04)
        ..cubicTo(4.11, 12.91, 4.28, 12.83, 4.47, 12.83)
        ..lineTo(9.74, 12.83)
        ..cubicTo(9.92, 12.83, 10.1, 12.9, 10.23, 13.03)
        ..cubicTo(10.36, 13.17, 10.42, 13.33, 10.42, 13.53)
        ..cubicTo(10.42, 13.71, 10.35, 13.88, 10.22, 14.01)
        ..cubicTo(10.09, 14.14, 9.92, 14.23, 9.72, 14.23)
        ..lineTo(4.47, 14.23)
        ..close()
        ..moveTo(17.27, 6.37)
        ..cubicTo(17.1, 6.35, 16.95, 6.27, 16.83, 6.14)
        ..cubicTo(16.71, 6.01, 16.65, 5.84, 16.65, 5.67)
        ..cubicTo(16.65, 5.5, 16.71, 5.33, 16.83, 5.21)
        ..cubicTo(16.95, 5.08, 17.1, 5, 17.28, 4.98)
        ..lineTo(22.55, 4.98)
        ..cubicTo(22.73, 4.98, 22.91, 5.05, 23.04, 5.18)
        ..cubicTo(23.17, 5.32, 23.24, 5.49, 23.24, 5.68)
        ..cubicTo(23.24, 5.86, 23.17, 6.04, 23.04, 6.17)
        ..cubicTo(22.91, 6.3, 22.74, 6.38, 22.54, 6.38)
        ..lineTo(17.28, 6.38)
        ..close()
        ..moveTo(17.27, 10.3)
        ..cubicTo(17.09, 10.3, 16.92, 10.22, 16.79, 10.1)
        ..cubicTo(16.66, 9.96, 16.59, 9.79, 16.59, 9.6)
        ..cubicTo(16.59, 9.42, 16.66, 9.24, 16.79, 9.1)
        ..cubicTo(16.92, 8.98, 17.09, 8.9, 17.28, 8.9)
        ..lineTo(22.55, 8.9)
        ..cubicTo(22.73, 8.9, 22.91, 8.98, 23.04, 9.1)
        ..cubicTo(23.17, 9.24, 23.24, 9.42, 23.24, 9.6)
        ..cubicTo(23.24, 9.79, 23.17, 9.96, 23.04, 10.1)
        ..cubicTo(22.91, 10.22, 22.74, 10.3, 22.54, 10.3)
        ..lineTo(17.28, 10.3)
        ..close()
        ..moveTo(17.27, 14.23)
        ..cubicTo(17.09, 14.23, 16.92, 14.15, 16.79, 14.03)
        ..cubicTo(16.66, 13.89, 16.59, 13.72, 16.59, 13.53)
        ..cubicTo(16.59, 13.35, 16.66, 13.17, 16.79, 13.04)
        ..cubicTo(16.92, 12.91, 17.09, 12.83, 17.28, 12.83)
        ..lineTo(22.55, 12.83)
        ..cubicTo(22.73, 12.83, 22.91, 12.9, 23.04, 13.03)
        ..cubicTo(23.17, 13.17, 23.24, 13.33, 23.24, 13.53)
        ..cubicTo(23.24, 13.71, 23.17, 13.88, 23.04, 14.01)
        ..cubicTo(22.91, 14.14, 22.74, 14.23, 22.54, 14.23)
        ..lineTo(17.28, 14.23)
        ..close();
      canvas.drawPath(path1, paint);
    } else {
      paint.style = PaintingStyle.fill;
      final path1 = Path()
        ..moveTo(1.88, 15.94)
        ..lineTo(1.88, 3.75)
        ..cubicTo(1.38, 3.75, 0.9, 3.95, 0.55, 4.3)
        ..cubicTo(0.2, 4.65, 0, 5.13, 0, 5.63)
        ..lineTo(0, 18.75)
        ..cubicTo(0, 19.25, 0.2, 19.72, 0.55, 20.08)
        ..cubicTo(0.9, 20.43, 1.38, 20.63, 1.87, 20.63)
        ..lineTo(10.67, 20.63)
        ..cubicTo(8.91, 19.41, 6.83, 18.75, 4.69, 18.75)
        ..cubicTo(3.94, 18.75, 3.23, 18.45, 2.71, 17.93)
        ..cubicTo(2.19, 17.4, 1.9, 16.68, 1.9, 15.93)
        ..lineTo(1.88, 15.94)
        ..close()
        ..moveTo(26.25, 3.75)
        ..lineTo(26.25, 15.94)
        ..cubicTo(26.25, 16.68, 25.95, 17.4, 25.43, 17.93)
        ..cubicTo(24.9, 18.45, 24.18, 18.75, 23.43, 18.75)
        ..cubicTo(21.3, 18.75, 19.21, 19.41, 17.46, 20.63)
        ..lineTo(26.25, 20.63)
        ..cubicTo(26.75, 20.63, 27.22, 20.43, 27.58, 20.08)
        ..cubicTo(27.93, 19.72, 28.13, 19.25, 28.13, 18.75)
        ..lineTo(28.13, 5.62)
        ..cubicTo(28.13, 5.12, 27.93, 4.65, 27.58, 4.3)
        ..cubicTo(27.22, 3.95, 26.75, 3.75, 26.25, 3.75)
        ..close();
      canvas.drawPath(path1, paint);
      final path2 = Path()
        ..moveTo(4.69, 0)
        ..cubicTo(4.44, 0, 4.2, 0.1, 4.02, 0.27)
        ..cubicTo(3.85, 0.45, 3.75, 0.7, 3.75, 0.94)
        ..lineTo(3.75, 15.94)
        ..cubicTo(3.75, 16.19, 3.85, 16.42, 4.02, 16.6)
        ..cubicTo(4.2, 16.78, 4.44, 16.87, 4.69, 16.87)
        ..cubicTo(7.51, 16.87, 10.24, 17.84, 12.45, 19.59)
        ..lineTo(13.13, 20.14)
        ..lineTo(13.13, 0.17)
        ..cubicTo(12.82, 0.06, 12.5, 0, 12.19, 0)
        ..lineTo(4.69, 0)
        ..close()
        ..moveTo(24.37, 15.94)
        ..lineTo(24.37, 0.94)
        ..cubicTo(24.37, 0.69, 24.27, 0.45, 24.09, 0.27)
        ..cubicTo(23.92, 0.1, 23.69, 0, 23.44, 0)
        ..lineTo(15.94, 0)
        ..cubicTo(15.62, 0, 15.3, 0.06, 15, 0.17)
        ..lineTo(15, 20.14)
        ..lineTo(15.68, 19.59)
        ..cubicTo(17.88, 17.84, 20.62, 16.88, 23.44, 16.88)
        ..cubicTo(23.69, 16.88, 23.92, 16.78, 24.1, 16.6)
        ..cubicTo(24.28, 16.42, 24.37, 16.19, 24.37, 15.94)
        ..close();
      canvas.drawPath(path2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LearnIconPainter oldDelegate) {
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
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _ProfileIconPainter(isSelected: isSelected, color: color),
        ),
      ),
    );
  }
}

class _ProfileIconPainter extends CustomPainter {
  final bool isSelected;
  final Color color;

  _ProfileIconPainter({required this.isSelected, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 20.0;
    canvas.scale(scale, scale * (size.height / size.width) * (20.0 / 23.0));

    final paint = Paint()..color = color;

    if (isSelected) {
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2.0;
      paint.strokeCap = StrokeCap.round;

      final path1 = Path()
        ..moveTo(9.75, 11.5)
        ..cubicTo(12.65, 11.5, 15, 9.15, 15, 6.25)
        ..cubicTo(15, 3.35, 12.65, 1, 9.75, 1)
        ..cubicTo(6.85, 1, 4.5, 3.35, 4.5, 6.25)
        ..cubicTo(4.5, 9.15, 6.85, 11.5, 9.75, 11.5)
        ..close();
      canvas.drawPath(path1, paint);
      final path2 = Path()
        ..moveTo(9.75, 11.5)
        ..cubicTo(12.65, 11.5, 15, 9.15, 15, 6.25)
        ..cubicTo(15, 3.35, 12.65, 1, 9.75, 1)
        ..cubicTo(6.85, 1, 4.5, 3.35, 4.5, 6.25)
        ..cubicTo(4.5, 9.15, 6.85, 11.5, 9.75, 11.5)
        ..close();
      canvas.drawPath(path2, paint);
      final path3 = Path()
        ..moveTo(1, 22)
        ..cubicTo(1, 18.13, 3.92, 15, 7.53, 15)
        ..lineTo(11.97, 15)
        ..cubicTo(15.57, 15, 18.5, 18.13, 18.5, 22);
      canvas.drawPath(path3, paint);
      final path4 = Path()
        ..moveTo(1, 22)
        ..cubicTo(1, 18.13, 3.92, 15, 7.53, 15)
        ..lineTo(11.97, 15)
        ..cubicTo(15.57, 15, 18.5, 18.13, 18.5, 22);
      canvas.drawPath(path4, paint);
    } else {
      paint.style = PaintingStyle.fill;
      final path1 = Path()
        ..moveTo(15.04, 5.5)
        ..cubicTo(15.04, 6.58, 14.72, 7.64, 14.11, 8.55)
        ..cubicTo(13.5, 9.45, 12.63, 10.15, 11.62, 10.57)
        ..cubicTo(10.61, 10.99, 9.49, 11.1, 8.42, 10.88)
        ..cubicTo(7.34, 10.68, 6.36, 10.15, 5.58, 9.38)
        ..cubicTo(4.81, 8.61, 4.28, 7.63, 4.06, 6.57)
        ..cubicTo(3.86, 5.5, 3.96, 4.4, 4.38, 3.39)
        ..cubicTo(4.8, 2.39, 5.51, 1.53, 6.42, 0.93)
        ..cubicTo(7.33, 0.33, 8.4, 0, 9.5, 0)
        ..cubicTo(10.23, 0, 10.95, 0.14, 11.62, 0.42)
        ..cubicTo(12.29, 0.69, 12.9, 1.1, 13.42, 1.61)
        ..cubicTo(13.93, 2.12, 14.34, 2.73, 14.62, 3.39)
        ..cubicTo(14.9, 4.06, 15.04, 4.77, 15.04, 5.5)
        ..close()
        ..moveTo(9.5, 12.62)
        ..cubicTo(7.93, 12.62, 6.38, 12.94, 4.94, 13.56)
        ..cubicTo(3.5, 14.19, 2.22, 15.11, 1.16, 16.26)
        ..cubicTo(-0.71, 18.27, -0.26, 21.49, 2.1, 22.93)
        ..cubicTo(4.33, 24.28, 6.89, 25, 9.5, 25)
        ..cubicTo(12.11, 25, 14.67, 24.28, 16.9, 22.93)
        ..cubicTo(19.26, 21.49, 19.71, 18.27, 17.84, 16.25)
        ..cubicTo(16.78, 15.11, 15.49, 14.19, 14.06, 13.56)
        ..cubicTo(12.62, 12.94, 11.06, 12.61, 9.5, 12.62)
        ..close();
      canvas.drawPath(path1, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ProfileIconPainter oldDelegate) {
    return oldDelegate.isSelected != isSelected || oldDelegate.color != color;
  }
}
