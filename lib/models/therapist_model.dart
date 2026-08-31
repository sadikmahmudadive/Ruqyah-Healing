class TherapistModel {
  final String therapistId;
  final String name;
  final String profileImageUrl;
  final List<String> specialties; // ["Ruqyah", "Hijama", "Acupuncture"]
  final int experienceYears;
  final String verifiedStatus; // "pending", "verified_basic", "verified_gold"
  final double rating;
  final int totalReviews;
  final TherapistLocation location;
  final TherapistScheduling scheduling;
  final double pricePerSession;
  final DateTime createdAt;

  const TherapistModel({
    required this.therapistId,
    required this.name,
    required this.profileImageUrl,
    required this.specialties,
    required this.experienceYears,
    required this.verifiedStatus,
    required this.rating,
    required this.totalReviews,
    required this.location,
    required this.scheduling,
    required this.pricePerSession,
    required this.createdAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'therapist_id': therapistId,
      'name': name,
      'profile_image_url': profileImageUrl,
      'specialties': specialties,
      'experience_years': experienceYears,
      'verified_status': verifiedStatus,
      'rating': rating,
      'total_reviews': totalReviews,
      'location': location.toMap(),
      'scheduling': scheduling.toMap(),
      'price_per_session': pricePerSession,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory TherapistModel.fromMap(Map<String, dynamic> map, String docId) {
    return TherapistModel(
      therapistId: map['therapist_id'] ?? docId,
      name: map['name'] ?? '',
      profileImageUrl: map['profile_image_url'] ?? '',
      specialties: List<String>.from(map['specialties'] ?? []),
      experienceYears: map['experience_years'] ?? 0,
      verifiedStatus: map['verified_status'] ?? 'pending',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: map['total_reviews'] ?? 0,
      location: TherapistLocation.fromMap(
          Map<String, dynamic>.from(map['location'] ?? {})),
      scheduling: TherapistScheduling.fromMap(
          Map<String, dynamic>.from(map['scheduling'] ?? {})),
      pricePerSession: (map['price_per_session'] as num?)?.toDouble() ?? 0.0,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }
}

class TherapistLocation {
  final String city;
  final String chamberAddress;
  final double latitude;
  final double longitude;

  const TherapistLocation({
    required this.city,
    required this.chamberAddress,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'city': city,
      'chamber_address': chamberAddress,
      'geo_point': 'Latitude: $latitude, Longitude: $longitude',
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory TherapistLocation.fromMap(Map<String, dynamic> map) {
    return TherapistLocation(
      city: map['city'] ?? '',
      chamberAddress: map['chamber_address'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 23.7937,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 90.4066,
    );
  }
}

class TherapistScheduling {
  final Map<String, List<String>> weeklyHours;
  final List<DateTime> bookedSlots;

  const TherapistScheduling({
    required this.weeklyHours,
    required this.bookedSlots,
  });

  Map<String, dynamic> toMap() {
    return {
      'weekly_hours': weeklyHours,
      'booked_slots': bookedSlots.map((e) => e.toIso8601String()).toList(),
    };
  }

  factory TherapistScheduling.fromMap(Map<String, dynamic> map) {
    final hoursMap = <String, List<String>>{};
    if (map['weekly_hours'] != null) {
      (map['weekly_hours'] as Map).forEach((key, value) {
        hoursMap[key.toString()] = List<String>.from(value ?? []);
      });
    }

    final slots = (map['booked_slots'] as List? ?? [])
        .map((e) => DateTime.parse(e.toString()))
        .toList();

    return TherapistScheduling(
      weeklyHours: hoursMap,
      bookedSlots: slots,
    );
  }
}
