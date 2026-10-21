import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../localization/app_localizations.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../services/push_notification_service.dart';
import '../widgets/auth_ui.dart';
import '../widgets/country_code_picker.dart';
import 'main_navigation_shell.dart';

class SignUpScreen extends StatefulWidget {
  final VoidCallback? onSignUpSuccess;

  const SignUpScreen({super.key, this.onSignUpSuccess});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _isPhoneSignUp = false; // false = Email Sign Up, true = Phone Sign Up
  // 'patient' (User), 'raki', 'therapist', 'doctor' or 'hakim'
  String _selectedRole = 'patient';

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  CountryCode _selectedCountry = kDefaultCountryCodes[0];
  bool _isLoading = false;

  String? _verificationId;
  int _resendSeconds = 45;
  Timer? _resendTimer;
  bool _canResend = false;

  void _startResendTimer() {
    _resendSeconds = 45;
    _canResend = false;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        if (mounted) {
          setState(() {
            _resendSeconds--;
          });
        }
      } else {
        _resendTimer?.cancel();
        if (mounted) {
          setState(() {
            _canResend = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Inter', color: Colors.white),
        ),
        backgroundColor: isError
            ? const Color(0xFFB4503F)
            : const Color(0xFF1E6B45),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _navigateToHome() {
    HapticFeedback.lightImpact();
    if (widget.onSignUpSuccess != null) {
      widget.onSignUpSuccess!();
    }
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainNavigationShell(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
      (route) => false,
    );
  }

  // Handle Sending Phone OTP
  Future<void> _handleSendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 6) {
      _showSnackBar('Please enter a valid phone number', isError: true);
      return;
    }

    final fullPhoneNumber = '${_selectedCountry.code}$phone';
    setState(() => _isLoading = true);
    HapticFeedback.selectionClick();

    try {
      await FirebaseService.verifyPhoneNumber(
        phoneNumber: fullPhoneNumber,
        onVerificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification handled
        },
        onVerificationFailed: (FirebaseAuthException e) {
          if (mounted) {
            setState(() => _isLoading = false);
            _showSnackBar(
              e.message ?? 'Phone verification failed',
              isError: true,
            );
          }
        },
        onCodeSent: (String verificationId, int? resendToken) {
          if (mounted) {
            setState(() {
              _verificationId = verificationId;
              _isLoading = false;
            });
            _startResendTimer();
            _showSnackBar('OTP verification code sent to $fullPhoneNumber');
          }
        },
        onCodeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar('Failed to send OTP: $e', isError: true);
      }
    }
  }

  void _handleResendOtp() {
    if (!_canResend) return;
    _handleSendOtp();
  }

  // Handle Account Creation
  Future<void> _handleCreateAccount() async {
    HapticFeedback.lightImpact();

    final fullName = _fullNameController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (fullName.isEmpty || fullName.length < 2) {
      _showSnackBar('Please enter your full name', isError: true);
      return;
    }

    if (!_isPhoneSignUp) {
      // --- EMAIL SIGN UP ---
      final email = _emailController.text.trim();
      if (email.isEmpty ||
          !RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        _showSnackBar('Please enter a valid email address', isError: true);
        return;
      }
      if (password.isEmpty || password.length < 6) {
        _showSnackBar(
          'Password must be at least 6 characters long',
          isError: true,
        );
        return;
      }
      if (password != confirmPassword) {
        _showSnackBar('Passwords do not match', isError: true);
        return;
      }

      setState(() => _isLoading = true);

      try {
        final userCred = await FirebaseService.signUpWithEmail(
          email: email,
          password: password,
        );

        final user = userCred.user;
        if (user != null) {
          await user.updateDisplayName(fullName);
          final token = await PushNotificationService.getFcmToken() ?? '';

          final newUser = UserModel(
            userId: user.uid,
            email: email,
            phone: '',
            name: fullName,
            role: _selectedRole,
            fcmToken: token,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            healthProfile: HealthProfile.empty(),
            billing: BillingProfile.empty(),
          );

          await FirebaseService.saveUserProfile(newUser);
          _showSnackBar(
            'Account created successfully! Welcome to Ruqyah Healing.',
          );
          _navigateToHome();
        }
      } on FirebaseAuthException catch (e) {
        String msg = 'Failed to create account';
        if (e.code == 'email-already-in-use') {
          msg = 'An account already exists for this email. Please sign in.';
        } else if (e.code == 'weak-password') {
          msg = 'The password provided is too weak.';
        } else if (e.code == 'invalid-email') {
          msg = 'The email address format is invalid.';
        } else if (e.message != null) {
          msg = e.message!;
        }
        _showSnackBar(msg, isError: true);
      } catch (e) {
        _showSnackBar('An unexpected error occurred: $e', isError: true);
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      // --- PHONE SIGN UP ---
      final email = _emailController.text.trim();
      final phone = _phoneController.text.trim();
      final otpCode = _otpController.text.trim();

      if (email.isEmpty ||
          !RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        _showSnackBar('Please enter a valid email address', isError: true);
        return;
      }
      if (phone.isEmpty || phone.length < 6) {
        _showSnackBar('Please enter a valid phone number', isError: true);
        return;
      }
      if (_verificationId == null) {
        _showSnackBar('Please request an OTP code first', isError: true);
        return;
      }
      if (otpCode.length < 6) {
        _showSnackBar('Please enter the 6-digit OTP code', isError: true);
        return;
      }
      if (password.isEmpty || password.length < 6) {
        _showSnackBar(
          'Password must be at least 6 characters long',
          isError: true,
        );
        return;
      }
      if (password != confirmPassword) {
        _showSnackBar('Passwords do not match', isError: true);
        return;
      }

      setState(() => _isLoading = true);

      try {
        final userCred = await FirebaseService.signInWithOtp(
          verificationId: _verificationId!,
          smsCode: otpCode,
        );

        final user = userCred.user;
        if (user != null) {
          await user.updateDisplayName(fullName);
          try {
            await user.verifyBeforeUpdateEmail(email);
          } catch (_) {}

          final token = await PushNotificationService.getFcmToken() ?? '';
          final fullPhone = '${_selectedCountry.code}$phone';
          final newUser = UserModel(
            userId: user.uid,
            email: email,
            phone: fullPhone,
            name: fullName,
            role: _selectedRole,
            fcmToken: token,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            healthProfile: HealthProfile.empty(),
            billing: BillingProfile.empty(),
          );

          await FirebaseService.saveUserProfile(newUser);
          _showSnackBar('Account verified and created successfully!');
          _navigateToHome();
        }
      } on FirebaseAuthException catch (e) {
        String msg = 'Verification failed';
        if (e.code == 'invalid-verification-code') {
          msg = 'Incorrect OTP code. Please check and try again.';
        } else if (e.message != null) {
          msg = e.message!;
        }
        _showSnackBar(msg, isError: true);
      } catch (e) {
        _showSnackBar('An unexpected error occurred: $e', isError: true);
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);

    try {
      final userCred = await FirebaseService.signInWithGoogle();
      if (userCred != null && userCred.user != null) {
        _showSnackBar('Signed in with Google successfully!');
        _navigateToHome();
      }
    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? 'Google Sign-In failed', isError: true);
    } catch (e) {
      _showSnackBar('Google Sign-In cancelled or failed', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToSignIn() {
    HapticFeedback.selectionClick();
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handlePickCountry() async {
    HapticFeedback.selectionClick();
    final picked = await showCountryCodePicker(
      context: context,
      selectedCountry: _selectedCountry,
    );
    if (picked != null && mounted) {
      setState(() => _selectedCountry = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      backgroundAsset: 'assets/background/bg_signup.jpg',
      title: context.tr('create_account_title'),
      subtitle: _isPhoneSignUp
          ? 'Sign up with your phone number and verify via OTP.'
          : 'Join us to start your spiritual and physical wellness journey.',
      onBack: _navigateToSignIn,
      heroFraction: 0.28,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AuthSegmented<bool>(
              selected: _isPhoneSignUp,
              onChanged: (v) => setState(() => _isPhoneSignUp = v),
              options: [
                AuthOption(
                  false,
                  context.tr('email'),
                  Icons.mail_outline_rounded,
                ),
                AuthOption(true, context.tr('phone'), Icons.phone_outlined),
              ],
            ),
            const SizedBox(height: 22),
            AuthLabel(context.tr('full_name')),
            AuthField(
              controller: _fullNameController,
              hint: 'Enter your full name',
              icon: Icons.person_outline,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
            AuthLabel(context.tr('email_address')),
            AuthField(
              controller: _emailController,
              hint: 'Enter your email address',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              enabled: !_isLoading,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: _isPhoneSignUp
                  ? _buildPhoneSection()
                  : const SizedBox(width: double.infinity),
            ),
            const SizedBox(height: 16),
            AuthLabel(context.tr('password')),
            AuthField(
              controller: _passwordController,
              hint: 'Create strong password',
              icon: Icons.lock_outline,
              isPassword: true,
              textInputAction: TextInputAction.next,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
            AuthLabel(context.tr('confirm_password')),
            AuthField(
              controller: _confirmPasswordController,
              hint: 'Repeat your password',
              icon: Icons.lock_outline,
              isPassword: true,
              textInputAction: TextInputAction.done,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
            AuthLabel(context.tr('select_role')),
            AuthCarousel<String>(
              selected: _selectedRole,
              onChanged: (v) => setState(() => _selectedRole = v),
              options: [
                AuthOption(
                  'patient',
                  context.tr('user'),
                  Icons.person_outline_rounded,
                ),
                AuthOption(
                  'raki',
                  context.tr('raki'),
                  Icons.record_voice_over_outlined,
                ),
                AuthOption(
                  'therapist',
                  context.tr('therapist'),
                  Icons.medical_services_outlined,
                ),
                AuthOption(
                  'doctor',
                  context.tr('doctor'),
                  Icons.local_hospital_outlined,
                ),
                AuthOption('hakim', context.tr('hakim'), Icons.eco_outlined),
              ],
            ),
            const SizedBox(height: 24),
            AuthButton(
              label: 'Create Account',
              loading: _isLoading,
              onPressed: _handleCreateAccount,
            ),
          ],
        ),
        const SizedBox(height: 24),
        AuthDivider(context.tr('or_continue_with')),
        const SizedBox(height: 20),
        AuthGoogleButton(
          label: context.tr('continue_google'),
          onPressed: _isLoading ? null : _handleGoogleSignIn,
        ),
        const SizedBox(height: 24),
        Center(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14.5,
                color: Colors.white70,
              ),
              children: [
                TextSpan(
                  text: 'Already have an account? ',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.70)),
                ),
                TextSpan(
                  text: 'Sign In',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AuthColors.goldSoft,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = _navigateToSignIn,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneSection() {
    return Column(
      key: const ValueKey('phone-section'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        AuthLabel(context.tr('phone')),
        AuthField(
          controller: _phoneController,
          hint: 'Enter phone number',
          keyboardType: TextInputType.phone,
          enabled: !_isLoading,
          prefix: AuthCountryPrefix(
            flag: _selectedCountry.flag,
            code: _selectedCountry.code,
            onTap: _handlePickCountry,
          ),
        ),
        const SizedBox(height: 12),
        AuthButton(
          tonal: true,
          label: context.tr('send_otp'),
          loading: _isLoading,
          onPressed: _handleSendOtp,
        ),
        const SizedBox(height: 16),
        AuthLabel(context.tr('otp_code')),
        AuthField(
          controller: _otpController,
          hint: 'Enter 6-digit code',
          icon: Icons.vpn_key_outlined,
          keyboardType: TextInputType.number,
          letterSpacing: 1.0,
          enabled: !_isLoading,
          suffix: GestureDetector(
            onTap: (_canResend && !_isLoading) ? _handleResendOtp : null,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                _canResend ? 'Resend' : 'Resend (${_resendSeconds}s)',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AuthColors.goldSoft.withValues(
                    alpha: _canResend ? 1 : 0.7,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
