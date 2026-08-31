class UserModel {
  final String userId;
  final String email;
  final String phone;
  final String name;
  final String role; // "patient", "therapist", "admin", "scholar"
  final DateTime createdAt;
  final DateTime updatedAt;
  final HealthProfile healthProfile;
  final BillingProfile billing;

  const UserModel({
    required this.userId,
    required this.email,
    required this.phone,
    required this.name,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    required this.healthProfile,
    required this.billing,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'email': email,
      'phone': phone,
      'name': name,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'health_profile': healthProfile.toMap(),
      'billing': billing.toMap(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    return UserModel(
      userId: map['user_id'] ?? docId,
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? 'patient',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : DateTime.now(),
      healthProfile: map['health_profile'] != null
          ? HealthProfile.fromMap(
              Map<String, dynamic>.from(map['health_profile']))
          : HealthProfile.empty(),
      billing: map['billing'] != null
          ? BillingProfile.fromMap(Map<String, dynamic>.from(map['billing']))
          : BillingProfile.empty(),
    );
  }
}

class HealthProfile {
  final List<String> medicalHistory;
  final List<String> allergies;
  final List<String> symptoms;
  final int stressLevelIndex; // 1-10
  final List<String> hijamaPointingHistory;
  final List<String> acupuncturePointLog;
  final List<RuqyahAudioLog> ruqyahAudioLogs;

  const HealthProfile({
    required this.medicalHistory,
    required this.allergies,
    required this.symptoms,
    required this.stressLevelIndex,
    required this.hijamaPointingHistory,
    required this.acupuncturePointLog,
    required this.ruqyahAudioLogs,
  });

  factory HealthProfile.empty() {
    return const HealthProfile(
      medicalHistory: [],
      allergies: [],
      symptoms: [],
      stressLevelIndex: 5,
      hijamaPointingHistory: [],
      acupuncturePointLog: [],
      ruqyahAudioLogs: [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'medical_history': medicalHistory,
      'allergies': allergies,
      'symptoms': symptoms,
      'stress_level_index': stressLevelIndex,
      'hijama_pointing_history': hijamaPointingHistory,
      'acupuncture_point_log': acupuncturePointLog,
      'ruqyah_audio_logs': ruqyahAudioLogs.map((e) => e.toMap()).toList(),
    };
  }

  factory HealthProfile.fromMap(Map<String, dynamic> map) {
    return HealthProfile(
      medicalHistory: List<String>.from(map['medical_history'] ?? []),
      allergies: List<String>.from(map['allergies'] ?? []),
      symptoms: List<String>.from(map['symptoms'] ?? []),
      stressLevelIndex: map['stress_level_index'] ?? 5,
      hijamaPointingHistory:
          List<String>.from(map['hijama_pointing_history'] ?? []),
      acupuncturePointLog:
          List<String>.from(map['acupuncture_point_log'] ?? []),
      ruqyahAudioLogs: (map['ruqyah_audio_logs'] as List? ?? [])
          .map((e) => RuqyahAudioLog.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class RuqyahAudioLog {
  final String audioId;
  final int listenDurationSec;
  final String date;

  const RuqyahAudioLog({
    required this.audioId,
    required this.listenDurationSec,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'audio_id': audioId,
      'listen_duration_sec': listenDurationSec,
      'date': date,
    };
  }

  factory RuqyahAudioLog.fromMap(Map<String, dynamic> map) {
    return RuqyahAudioLog(
      audioId: map['audio_id'] ?? '',
      listenDurationSec: map['listen_duration_sec'] ?? 0,
      date: map['date'] ?? '',
    );
  }
}

class BillingProfile {
  final String subscriptionType; // "free", "premium_monthly", "premium_yearly"
  final DateTime? subscriptionActiveUntil;
  final List<SavedPaymentMethod> savedPaymentMethods;

  const BillingProfile({
    required this.subscriptionType,
    this.subscriptionActiveUntil,
    required this.savedPaymentMethods,
  });

  factory BillingProfile.empty() {
    return const BillingProfile(
      subscriptionType: 'free',
      subscriptionActiveUntil: null,
      savedPaymentMethods: [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subscription_type': subscriptionType,
      'subscription_active_until': subscriptionActiveUntil?.toIso8601String(),
      'saved_payment_methods':
          savedPaymentMethods.map((e) => e.toMap()).toList(),
    };
  }

  factory BillingProfile.fromMap(Map<String, dynamic> map) {
    return BillingProfile(
      subscriptionType: map['subscription_type'] ?? 'free',
      subscriptionActiveUntil: map['subscription_active_until'] != null
          ? DateTime.parse(map['subscription_active_until'])
          : null,
      savedPaymentMethods: (map['saved_payment_methods'] as List? ?? [])
          .map((e) => SavedPaymentMethod.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class SavedPaymentMethod {
  final String gateway;
  final String token;

  const SavedPaymentMethod({
    required this.gateway,
    required this.token,
  });

  Map<String, dynamic> toMap() {
    return {
      'gateway': gateway,
      'token': token,
    };
  }

  factory SavedPaymentMethod.fromMap(Map<String, dynamic> map) {
    return SavedPaymentMethod(
      gateway: map['gateway'] ?? '',
      token: map['token'] ?? '',
    );
  }
}
