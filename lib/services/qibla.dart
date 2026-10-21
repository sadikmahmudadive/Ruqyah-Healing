import 'dart:math' as math;

/// Qibla maths: the great-circle bearing from a place to the Kaaba, the
/// distance to it, and small helpers for compass headings.
class Qibla {
  Qibla._();

  /// The Kaaba, Makkah.
  static const double kaabaLat = 21.4225;
  static const double kaabaLng = 39.8262;

  static double _rad(double d) => d * math.pi / 180;
  static double _deg(double r) => r * 180 / math.pi;

  /// Initial bearing in degrees (0 to 360, clockwise from true north) to face
  /// the Kaaba from [lat], [lng].
  static double bearing(double lat, double lng) {
    final p1 = _rad(lat);
    final p2 = _rad(kaabaLat);
    final dl = _rad(kaabaLng - lng);
    final y = math.sin(dl) * math.cos(p2);
    final x =
        math.cos(p1) * math.sin(p2) -
        math.sin(p1) * math.cos(p2) * math.cos(dl);
    return (_deg(math.atan2(y, x)) + 360) % 360;
  }

  /// Great-circle (haversine) distance to the Kaaba in kilometres.
  static double distanceKm(double lat, double lng) {
    final p1 = _rad(lat);
    final p2 = _rad(kaabaLat);
    final dl = _rad(kaabaLng - lng);
    final a =
        math.pow(math.sin((p2 - p1) / 2), 2) +
        math.cos(p1) * math.cos(p2) * math.pow(math.sin(dl / 2), 2);
    return 6371 * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  /// Shortest signed turn from [from] to [to], in degrees, in -180..180.
  /// Positive means turn right (clockwise).
  static double turn(double from, double to) =>
      ((to - from) % 360 + 540) % 360 - 180;

  static const List<String> _points = [
    'N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE', //
    'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW',
  ];

  /// 16-point compass name for a bearing, e.g. 278 becomes "W".
  static String cardinal(double degrees) {
    final d = ((degrees % 360) + 360) % 360;
    return _points[(d / 22.5).round() % 16];
  }

  /// "3,998" style thousands grouping for the distance line.
  static String groupThousands(int n) {
    final s = n.toString();
    final out = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) out.write(',');
      out.write(s[i]);
    }
    return out.toString();
  }
}
