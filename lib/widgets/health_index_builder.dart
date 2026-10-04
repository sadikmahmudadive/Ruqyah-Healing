import 'dart:async';

import 'package:flutter/material.dart';

import '../models/appointment_model.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../services/health_index_service.dart';
import '../theme/app_theme.dart';

extension HealthToneColor on HealthTone {
  Color get color => switch (this) {
    HealthTone.good => AppColors.success,
    HealthTone.moderate => AppColors.warning,
    HealthTone.poor => AppColors.danger,
  };
}

/// Rebuilds with a fresh [HealthIndexResult] whenever the signed-in user's
/// profile (and optionally their appointments) change in Firestore.
/// Guests, or a failed connection, get [HealthIndexResult.empty].
class HealthIndexBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, HealthIndexResult result) builder;

  /// Also listen to appointments, so completed Hijama / Acupuncture /
  /// Ruqyah sessions count towards the session totals.
  final bool withAppointments;

  const HealthIndexBuilder({
    super.key,
    required this.builder,
    this.withAppointments = false,
  });

  @override
  State<HealthIndexBuilder> createState() => _HealthIndexBuilderState();
}

class _HealthIndexBuilderState extends State<HealthIndexBuilder> {
  StreamSubscription<UserModel?>? _profileSub;
  StreamSubscription<List<AppointmentModel>>? _appointmentSub;

  HealthProfile? _profile;
  List<AppointmentModel> _appointments = const [];
  HealthIndexResult _result = const HealthIndexResult.empty();

  @override
  void initState() {
    super.initState();
    final user = FirebaseService.currentUser;
    if (user == null) return;

    _profileSub = FirebaseService.getUserProfileStream(user.uid).listen(
      (u) {
        _profile = u?.healthProfile;
        _recompute();
      },
      onError: (_) {},
    );
    if (widget.withAppointments) {
      _appointmentSub = FirebaseService.getPatientAppointments(user.uid).listen(
        (a) {
          _appointments = a;
          _recompute();
        },
        onError: (_) {},
      );
    }
  }

  void _recompute() {
    if (!mounted) return;
    final profile = _profile;
    setState(() {
      _result = profile == null
          ? const HealthIndexResult.empty()
          : HealthIndexService.compute(profile, appointments: _appointments);
    });
  }

  @override
  void dispose() {
    _profileSub?.cancel();
    _appointmentSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _result);
}
