import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../firebase_options.dart';
import '../models/appointment_model.dart';
import '../models/course_model.dart';
import '../models/order_model.dart';
import '../models/therapist_model.dart';
import '../models/user_model.dart';

/// Centralized service handling Firebase Authentication, Firestore NoSQL Database operations,
/// and Firebase Storage connections for the Ruqyah Healing Super-App.
class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Safely initializes Firebase Core with platform options.
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('Firebase initialized successfully');
    } catch (e) {
      debugPrint('Firebase initialization note: $e');
    }
  }

  // ===========================================================================
  // AUTHENTICATION API
  // ===========================================================================

  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Initiates Phone Number OTP Verification.
  static Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) onVerificationCompleted,
    required Function(FirebaseAuthException) onVerificationFailed,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(String verificationId) onCodeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: onVerificationCompleted,
      verificationFailed: onVerificationFailed,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
      timeout: const Duration(seconds: 60),
    );
  }

  /// Signs in using OTP code credential.
  static Future<UserCredential> signInWithOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return await _auth.signInWithCredential(credential);
  }

  /// Signs in with Google Authentication.
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final existingProfile = await getUserProfile(user.uid);
        if (existingProfile == null) {
          final newUser = UserModel(
            userId: user.uid,
            email: user.email ?? '',
            phone: user.phoneNumber ?? '',
            name: user.displayName ?? 'User',
            role: 'patient',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            healthProfile: HealthProfile.empty(),
            billing: BillingProfile.empty(),
          );
          await saveUserProfile(newUser);
        }
      }

      return userCredential;
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      rethrow;
    }
  }

  /// Creates a new user with Email & Password.
  static Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Signs in with Email & Password.
  static Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Sign Out current user.
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // ===========================================================================
  // FIRESTORE NO SQL DATABASE OPERATIONS
  // ===========================================================================

  // 1. Users Collection (/users/{user_id})
  static Future<UserModel?> getUserProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromMap(doc.data()!, doc.id);
  }

  static Future<void> saveUserProfile(UserModel user) async {
    await _firestore
        .collection('users')
        .doc(user.userId)
        .set(user.toFirestore(), SetOptions(merge: true));
  }

  static Future<void> updateHealthProfile(
    String userId,
    HealthProfile profile,
  ) async {
    await _firestore.collection('users').doc(userId).update({
      'health_profile': profile.toMap(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // 2. Therapists Collection (/therapists/{therapist_id})
  static Stream<List<TherapistModel>> getTherapistsStream({
    String? specialty,
    String? city,
  }) {
    Query query = _firestore.collection('therapists');
    if (specialty != null && specialty.isNotEmpty) {
      query = query.where('specialties', arrayContains: specialty);
    }
    if (city != null && city.isNotEmpty) {
      query = query.where('location.city', isEqualTo: city);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map(
            (doc) => TherapistModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    });
  }

  // 3. Appointments Collection (/appointments/{appointment_id})
  static Future<void> createAppointment(AppointmentModel appointment) async {
    await _firestore
        .collection('appointments')
        .doc(appointment.appointmentId)
        .set(appointment.toFirestore());
  }

  static Stream<List<AppointmentModel>> getPatientAppointments(
    String patientId,
  ) {
    return _firestore
        .collection('appointments')
        .where('patient_id', isEqualTo: patientId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => AppointmentModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  // 4. Courses Collection (/courses/{course_id})
  static Stream<List<CourseModel>> getCoursesStream() {
    return _firestore.collection('courses').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CourseModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  static Future<void> saveCourseEnrollment(
    String courseId,
    CourseEnrollment enrollment,
  ) async {
    await _firestore
        .collection('courses')
        .doc(courseId)
        .collection('enrollments')
        .doc(enrollment.userId)
        .set(enrollment.toFirestore(), SetOptions(merge: true));
  }

  // 5. Orders Collection (/orders/{order_id})
  static Future<void> createOrder(OrderModel order) async {
    await _firestore
        .collection('orders')
        .doc(order.orderId)
        .set(order.toFirestore());
  }
}
