class AppointmentModel {
  final String appointmentId;
  final String patientId;
  final String therapistId;
  final String therapyType; // "Ruqyah_Online", "Hijama_Physical", "Acupuncture_Physical"
  final DateTime scheduledTime;
  final String status; // "pending_payment", "scheduled", "completed", "canceled"
  final String paymentId;
  final LiveSession? liveSession;
  final SessionLog? sessionLog;
  final DateTime createdAt;

  const AppointmentModel({
    required this.appointmentId,
    required this.patientId,
    required this.therapistId,
    required this.therapyType,
    required this.scheduledTime,
    required this.status,
    required this.paymentId,
    this.liveSession,
    this.sessionLog,
    required this.createdAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'appointment_id': appointmentId,
      'patient_id': patientId,
      'therapist_id': therapistId,
      'therapy_type': therapyType,
      'scheduled_time': scheduledTime.toIso8601String(),
      'status': status,
      'payment_id': paymentId,
      'live_session': liveSession?.toMap(),
      'session_log': sessionLog?.toMap(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory AppointmentModel.fromMap(Map<String, dynamic> map, String docId) {
    return AppointmentModel(
      appointmentId: map['appointment_id'] ?? docId,
      patientId: map['patient_id'] ?? '',
      therapistId: map['therapist_id'] ?? '',
      therapyType: map['therapy_type'] ?? 'Hijama_Physical',
      scheduledTime: map['scheduled_time'] != null
          ? DateTime.parse(map['scheduled_time'])
          : DateTime.now(),
      status: map['status'] ?? 'pending_payment',
      paymentId: map['payment_id'] ?? '',
      liveSession: map['live_session'] != null
          ? LiveSession.fromMap(Map<String, dynamic>.from(map['live_session']))
          : null,
      sessionLog: map['session_log'] != null
          ? SessionLog.fromMap(Map<String, dynamic>.from(map['session_log']))
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }
}

class LiveSession {
  final String? roomId;
  final String? fallbackUrl;

  const LiveSession({this.roomId, this.fallbackUrl});

  Map<String, dynamic> toMap() {
    return {
      if (roomId != null) 'room_id': roomId,
      if (fallbackUrl != null) 'fallback_url': fallbackUrl,
    };
  }

  factory LiveSession.fromMap(Map<String, dynamic> map) {
    return LiveSession(
      roomId: map['room_id'],
      fallbackUrl: map['fallback_url'],
    );
  }
}

class SessionLog {
  final List<String> pointsTreated;
  final int? bloodQuantityMl;
  final int? needleDepthMm;
  final String? patientReaction;
  final String? practitionerRecommendations;
  final String? beforeImageUrl;
  final String? afterImageUrl;

  const SessionLog({
    this.pointsTreated = const [],
    this.bloodQuantityMl,
    this.needleDepthMm,
    this.patientReaction,
    this.practitionerRecommendations,
    this.beforeImageUrl,
    this.afterImageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'points_treated': pointsTreated,
      if (bloodQuantityMl != null) 'blood_quantity_ml': bloodQuantityMl,
      if (needleDepthMm != null) 'needle_depth_mm': needleDepthMm,
      if (patientReaction != null) 'patient_reaction': patientReaction,
      if (practitionerRecommendations != null)
        'practitioner_recommendations': practitionerRecommendations,
      if (beforeImageUrl != null) 'before_image_url': beforeImageUrl,
      if (afterImageUrl != null) 'after_image_url': afterImageUrl,
    };
  }

  factory SessionLog.fromMap(Map<String, dynamic> map) {
    return SessionLog(
      pointsTreated: List<String>.from(map['points_treated'] ?? []),
      bloodQuantityMl: map['blood_quantity_ml'],
      needleDepthMm: map['needle_depth_mm'],
      patientReaction: map['patient_reaction'],
      practitionerRecommendations: map['practitioner_recommendations'],
      beforeImageUrl: map['before_image_url'],
      afterImageUrl: map['after_image_url'],
    );
  }
}
