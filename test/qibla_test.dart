import 'package:flutter_test/flutter_test.dart';
import 'package:ruqyahhealing/services/qibla.dart';

void main() {
  group('Qibla bearing', () {
    test('Dhaka faces roughly west-north-west (about 278 degrees)', () {
      final b = Qibla.bearing(23.8103, 90.4125);
      expect(b, inInclusiveRange(276.0, 280.0));
    });

    test('London faces about south-east (about 119 degrees)', () {
      final b = Qibla.bearing(51.5074, -0.1278);
      expect(b, inInclusiveRange(117.0, 121.0));
    });

    test('New York faces about north-east (about 58 degrees)', () {
      final b = Qibla.bearing(40.7128, -74.006);
      expect(b, inInclusiveRange(56.0, 60.0));
    });

    test('Jakarta faces about north-west (about 295 degrees)', () {
      final b = Qibla.bearing(-6.2088, 106.8456);
      expect(b, inInclusiveRange(293.0, 297.0));
    });

    test('is always within 0 to 360', () {
      for (final p in const [
        [0.0, 0.0],
        [-33.9, 151.2],
        [64.1, -21.9],
        [35.7, 139.7],
      ]) {
        final b = Qibla.bearing(p[0], p[1]);
        expect(b, inInclusiveRange(0.0, 360.0));
      }
    });
  });

  group('Qibla distance', () {
    test('Dhaka to Makkah is about 5,170 km', () {
      expect(Qibla.distanceKm(23.8103, 90.4125), inInclusiveRange(5120, 5220));
    });

    test('Makkah to itself is zero', () {
      expect(
        Qibla.distanceKm(Qibla.kaabaLat, Qibla.kaabaLng),
        closeTo(0, 0.01),
      );
    });
  });

  group('helpers', () {
    test('turn takes the short way round', () {
      expect(Qibla.turn(350, 10), 20);
      expect(Qibla.turn(10, 350), -20);
      expect(Qibla.turn(0, 180).abs(), 180);
      expect(Qibla.turn(90, 90), 0);
    });

    test('cardinal names', () {
      expect(Qibla.cardinal(0), 'N');
      expect(Qibla.cardinal(90), 'E');
      expect(Qibla.cardinal(220), 'SW');
      expect(Qibla.cardinal(278), 'W');
      expect(Qibla.cardinal(359), 'N');
      expect(Qibla.cardinal(-10), 'N');
    });

    test('thousands grouping', () {
      expect(Qibla.groupThousands(3998), '3,998');
      expect(Qibla.groupThousands(12), '12');
      expect(Qibla.groupThousands(1234567), '1,234,567');
    });
  });
}
