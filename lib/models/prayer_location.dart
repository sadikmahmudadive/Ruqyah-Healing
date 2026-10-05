/// A place prayer times are calculated for.
class PrayerLocation {
  final String city;

  /// ISO 3166-1 alpha-2 country code, e.g. "BD". May be empty if unknown.
  final String countryCode;
  final double latitude;
  final double longitude;

  const PrayerLocation({
    required this.city,
    required this.countryCode,
    required this.latitude,
    required this.longitude,
  });

  /// "Dhaka, BD"
  String get label => countryCode.isEmpty ? city : '$city, $countryCode';

  static const dhaka = PrayerLocation(
    city: 'Dhaka',
    countryCode: 'BD',
    latitude: 23.8103,
    longitude: 90.4125,
  );

  /// Places offered without searching.
  static const popular = [
    dhaka,
    PrayerLocation(
      city: 'Chattogram',
      countryCode: 'BD',
      latitude: 22.3569,
      longitude: 91.7832,
    ),
    PrayerLocation(
      city: 'Sylhet',
      countryCode: 'BD',
      latitude: 24.8949,
      longitude: 91.8687,
    ),
    PrayerLocation(
      city: 'Khulna',
      countryCode: 'BD',
      latitude: 22.8456,
      longitude: 89.5403,
    ),
    PrayerLocation(
      city: 'Rajshahi',
      countryCode: 'BD',
      latitude: 24.3745,
      longitude: 88.6042,
    ),
    PrayerLocation(
      city: 'Makkah',
      countryCode: 'SA',
      latitude: 21.3891,
      longitude: 39.8579,
    ),
    PrayerLocation(
      city: 'Madinah',
      countryCode: 'SA',
      latitude: 24.5247,
      longitude: 39.5692,
    ),
  ];

  /// Same place, ignoring tiny coordinate differences (GPS jitter).
  bool isSamePlaceAs(PrayerLocation other) =>
      (latitude - other.latitude).abs() < 0.01 &&
      (longitude - other.longitude).abs() < 0.01;

  Map<String, dynamic> toJson() => {
    'city': city,
    'cc': countryCode,
    'lat': latitude,
    'lon': longitude,
  };

  static PrayerLocation? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final lat = raw['lat'];
    final lon = raw['lon'];
    final city = raw['city'];
    if (lat is! num || lon is! num || city is! String || city.isEmpty) {
      return null;
    }
    if (lat < -90 || lat > 90 || lon < -180 || lon > 180) return null;
    return PrayerLocation(
      city: city,
      countryCode: raw['cc'] as String? ?? '',
      latitude: lat.toDouble(),
      longitude: lon.toDouble(),
    );
  }
}
