import 'package:flutter/material.dart';

/// A custom vector icon depicting open praying hands (Ruqyah Dua / Supplication palms)
/// created directly from the provided Android Vector Drawable specification.
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

  static const String _pathData =
      'M28.3 66.74c0-0.53-0.28-1.01-0.74-1.28-2.1-1.27-7.54-4.7-12.84-9.18-5.2-4.4-9.98-9.56-11.58-14.47L3 41.34c-1.59-5.6-1.69-14.29-1.33-22C2.03 11.66 2.83 5.2 2.96 4.16V4.03C2.97 4 2.99 3.94 3 3.9c0.02-0.04 0.04-0.08 0.08-0.1 1.94-1.7 3.38-2.23 4.38-2.3 0.94-0.05 1.7 0.3 2.36 0.9 1.43 1.34 2.11 3.61 2.23 4.06l0.02 0.07 0.02 0.1v22.38c0 0.11 0.01 0.23 0.04 0.35l0.66 2.78c0.03 0.14 0.09 0.28 0.16 0.4l1 1.73c0.1 0.18 0.24 0.33 0.4 0.45l7.3 5.42c0.6 0.45 1.43 0.39 1.95-0.14 0.53-0.52 0.6-1.35 0.15-1.95l-5.02-6.8-0.09-0.1-0.04-0.06-0.03-0.07c-1.05-3.93-1-6.18-0.58-7.39 0.2-0.57 0.46-0.88 0.72-1.07 0.26-0.2 0.62-0.33 1.1-0.39 0.98-0.1 2.24 0.18 3.44 0.62 1.16 0.42 2.1 0.92 2.42 1.1l0.05 0.02 0.03 0.02 0.07 0.07 0.02 0.03L51.9 52.28l0.07 0.07 0.08 0.11c0.02 0.04 0.03 0.09 0.03 0.13V84v0.02c0 0.05-0.01 0.1-0.03 0.13l-0.07 0.11-0.11 0.08-0.13 0.02H28.63c-0.05 0-0.1 0-0.13-0.02l-0.11-0.08-0.07-0.1L28.29 84V84 66.74ZM101.12 6.6V6.5h0.01c0.12-0.45 0.8-2.73 2.23-4.06 0.66-0.6 1.42-0.96 2.36-0.9 1 0.06 2.44 0.6 4.4 2.29l0.09 0.12c0.02 0.04 0.03 0.08 0.03 0.13v0.14c0.14 1.02 0.95 7.49 1.31 15.14 0.35 7.48 0.27 15.87-1.18 21.46l-0.14 0.53c-1.44 5.04-6.36 10.4-11.73 14.94-5.3 4.47-10.76 7.91-12.86 9.18-0.45 0.27-0.73 0.75-0.73 1.28v17.27c0 0.05 0 0.09-0.02 0.13l-0.07 0.11-0.11 0.08-0.13 0.02H61.52c-0.17 0-0.34-0.14-0.34-0.36V52.6c0-0.04 0.01-0.09 0.03-0.13 0.02-0.04 0.04-0.08 0.08-0.11l0.07-0.07 25.99-28.23 0.03-0.03 0.1-0.08 0.07-0.04c0.3-0.16 1.24-0.67 2.4-1.1 1.2-0.43 2.46-0.71 3.45-0.6 0.47 0.05 0.83 0.18 1.1 0.38 0.25 0.2 0.52 0.5 0.71 1.07 0.41 1.21 0.46 3.46-0.6 7.4v0.02c-0.01 0.05-0.03 0.1-0.07 0.13l-0.06 0.08-5.02 6.79c-0.44 0.6-0.38 1.43 0.15 1.95 0.53 0.53 1.36 0.59 1.95 0.15l7.3-5.42c0.17-0.13 0.3-0.28 0.4-0.46l1-1.72c0.07-0.13 0.13-0.26 0.16-0.4l0.67-2.8c0.02-0.1 0.04-0.22 0.04-0.34V6.59Z';

  static Path? _cachedPath;

  _RuqyahDuaIconPainter({required this.color});

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

    final double scale = size.width / 114.0;
    canvas.scale(scale, scale * (86.0 / 114.0) * (size.height / size.width));

    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(rawPath, paint);
  }

  @override
  bool shouldRepaint(covariant _RuqyahDuaIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
