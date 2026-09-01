import 'package:flutter/material.dart';

/// A custom vector icon depicting Acupuncture therapy needles
/// created directly from the provided Android Vector Drawable specification.
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
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _AcupunctureIconPainter(color: color),
      ),
    );
  }
}

class _AcupunctureIconPainter extends CustomPainter {
  final Color color;

  static const String _pathData =
      'M138.6 57.98c-8.38-2.88-16.97-4.67-25.6-5.41l6.35-27.49c3.38-0.39 6.31-2.86 7.12-6.35 1.02-4.45-1.75-8.88-6.2-9.9-4.44-1.04-8.88 1.74-9.9 6.18-0.81 3.5 0.74 7 3.61 8.83l-6.56 28.4c-4.76-0.15-9.53 0.01-14.26 0.5l4.47-36.37c3.33-0.73 5.98-3.49 6.42-7.06 0.55-4.52-2.68-8.65-7.2-9.2-4.52-0.56-8.65 2.67-9.2 7.19-0.44 3.57 1.46 6.89 4.51 8.4l-4.64 37.77c-5.21 0.81-10.37 2.02-15.42 3.6v-31.9c3.2-1.13 5.5-4.2 5.5-7.78 0-4.56-3.7-8.26-8.25-8.26-4.56 0-8.27 3.7-8.27 8.26 0 3.59 2.3 6.65 5.51 7.79v33.7c-4.27 1.33-8.62 2.38-13.02 3.13l-9.35-30.58c2.74-2.02 4.05-5.62 3-9.06-1.34-4.37-5.96-6.82-10.32-5.48-4.36 1.33-6.82 5.96-5.49 10.31 1.05 3.44 4.15 5.69 7.55 5.84l9.1 29.76C38.1 63.94 28 63.6 18.13 61.79l8-45.38c3.35-0.56 6.16-3.17 6.78-6.71 0.8-4.5-2.2-8.78-6.7-9.57-4.5-0.8-8.78 2.2-9.57 6.7-0.63 3.53 1.11 6.95 4.07 8.62l-7.97 45.19c-3.07-0.74-6.1-1.62-9.1-2.66C1.87 57.37 0 58.7 0 60.58v38.56c0 6.08 4.94 11.02 11.02 11.02h118.41c6.08 0 11.02-4.94 11.02-11.02V60.6c0-1.18-0.75-2.22-1.86-2.6Zm-3.66 41.16c0 3.04-2.47 5.5-5.5 5.5H11.01c-3.04 0-5.51-2.46-5.51-5.5V64.38c2.08 0.63 4.18 1.2 6.28 1.7l-0.72 4.08c-0.26 1.5 0.74 2.93 2.24 3.2 1.49 0.26 2.92-0.74 3.19-2.24l0.68-3.9c10.75 2 21.7 2.31 32.52 0.95l5.5 18c0.44 1.45 1.98 2.27 3.44 1.82 1.45-0.44 2.27-1.98 1.83-3.44L55.2 67.34c3.83-0.69 7.63-1.59 11.4-2.7v16.09c0 1.52 1.23 2.75 2.75 2.75s2.75-1.23 2.75-2.75V62.86c4.82-1.6 9.74-2.83 14.72-3.68L85.4 70.84c-0.18 1.5 0.89 2.88 2.4 3.07 1.5 0.18 2.88-0.89 3.07-2.4l1.61-13.13c4.54-0.52 9.12-0.73 13.68-0.63l-4.67 20.22c-0.34 1.48 0.59 2.96 2.07 3.3 1.48 0.34 2.96-0.57 3.3-2.06l4.9-21.19c7.85 0.6 15.65 2.12 23.2 4.55v36.57Z';

  static Path? _cachedPath;

  _AcupunctureIconPainter({required this.color});

  static Path _parseSvgPath(String data) {
    if (_cachedPath != null) return _cachedPath!;

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

    _cachedPath = path;
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Path rawPath = _parseSvgPath(_pathData);

    final double scale = size.width / 141.0;
    canvas.scale(scale, scale * (111.0 / 141.0) * (size.height / size.width));

    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(rawPath, paint);
  }

  @override
  bool shouldRepaint(covariant _AcupunctureIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
