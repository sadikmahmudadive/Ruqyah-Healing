import 'package:flutter/material.dart';

/// A custom vector icon depicting Hijama cupping therapy
/// created directly from the provided Android Vector Drawable specification.
class HijamaCuppingIcon extends StatelessWidget {
  final Color color;
  final double size;

  const HijamaCuppingIcon({
    super.key,
    this.color = const Color(0xFFE07B39),
    this.size = 26.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _HijamaCuppingIconPainter(color: color),
      ),
    );
  }
}

class _HijamaCuppingIconPainter extends CustomPainter {
  final Color color;

  static const String _pathData =
      'M115.66 105.82h-2.46V79.98c0-27-21.3-49.1-47.99-50.39v-5.34c3.56-1.06 6.16-4.36 6.16-8.25V8.6C71.37 3.86 67.5 0 62.75 0c-4.75 0-8.6 3.86-8.6 8.61V16c0 3.89 2.59 7.19 6.14 8.25v5.34C33.61 30.88 12.3 53 12.3 80v25.83H9.84c-5.42 0-9.84 4.42-9.84 9.84 0 5.43 4.42 9.85 9.84 9.85h105.82c5.43 0 9.85-4.42 9.85-9.85 0-5.42-4.42-9.84-9.85-9.84Zm-52.9-71.37c25.1 0 45.52 20.43 45.52 45.53v13.54H17.23V79.98c0-25.1 20.42-45.53 45.52-45.53Zm52.9 86.14H9.84c-2.71 0-4.92-2.21-4.92-4.93 0-2.71 2.21-4.92 4.92-4.92h105.82c2.72 0 4.93 2.21 4.93 4.92 0 2.72-2.21 4.93-4.93 4.93Z';

  static Path? _cachedPath;

  _HijamaCuppingIconPainter({required this.color});

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

    final double scale = size.width / 126.0;
    canvas.scale(scale, scale * (size.height / size.width));

    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(rawPath, paint);
  }

  @override
  bool shouldRepaint(covariant _HijamaCuppingIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
