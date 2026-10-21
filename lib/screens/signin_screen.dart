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
import 'signup_screen.dart';

class SignInScreen extends StatefulWidget {
  final VoidCallback? onSignInSuccess;

  const SignInScreen({super.key, this.onSignInSuccess});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _isPhoneLogin = false; // false = Email Login, true = Phone Login
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  CountryCode _selectedCountry = kDefaultCountryCodes[0];
  int _resendSeconds = 45;
  Timer? _resendTimer;
  bool _canResend = false;
  bool _isLoading = false;
  String? _verificationId;

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
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
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
    if (widget.onSignInSuccess != null) {
      widget.onSignInSuccess!();
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

  // Handle Sending Phone OTP Code
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
          try {
            final userCred = await FirebaseAuth.instance.signInWithCredential(
              credential,
            );
            if (userCred.user != null) {
              await _ensureUserProfile(userCred.user!);
              _showSnackBar('Phone verification completed automatically!');
              _navigateToHome();
            }
          } catch (e) {
            debugPrint('Auto verification error: $e');
          }
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

  Future<void> _ensureUserProfile(User user) async {
    try {
      final token = await PushNotificationService.getFcmToken() ?? '';
      final profile = await FirebaseService.getUserProfile(user.uid);
      if (profile == null) {
        final newUser = UserModel(
          userId: user.uid,
          email: user.email ?? '',
          phone: user.phoneNumber ?? '',
          name: user.displayName?.isNotEmpty == true
              ? user.displayName!
              : 'Ruqyah User',
          role: 'patient',
          fcmToken: token,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          healthProfile: HealthProfile.empty(),
          billing: BillingProfile.empty(),
        );
        await FirebaseService.saveUserProfile(newUser);
      } else if (token.isNotEmpty) {
        await FirebaseService.updateFcmToken(token);
      }
    } catch (e) {
      debugPrint('Error saving user profile: $e');
    }
  }

  // Handle Sign In (Email or Phone OTP)
  Future<void> _handleSignIn() async {
    HapticFeedback.lightImpact();

    if (_isPhoneLogin) {
      // --- PHONE OTP SIGN IN ---
      final otpCode = _otpController.text.trim();
      if (_verificationId == null) {
        _showSnackBar('Please request an OTP code first', isError: true);
        return;
      }
      if (otpCode.length < 6) {
        _showSnackBar('Please enter the 6-digit OTP code', isError: true);
        return;
      }

      setState(() => _isLoading = true);
      try {
        final userCred = await FirebaseService.signInWithOtp(
          verificationId: _verificationId!,
          smsCode: otpCode,
        );
        if (userCred.user != null) {
          await _ensureUserProfile(userCred.user!);
          _showSnackBar('Welcome back!');
          _navigateToHome();
        }
      } on FirebaseAuthException catch (e) {
        String msg = 'OTP Verification failed';
        if (e.code == 'invalid-verification-code') {
          msg = 'Incorrect OTP code. Please check and try again.';
        } else if (e.code == 'session-expired') {
          msg = 'OTP session expired. Please request a new code.';
        } else if (e.message != null) {
          msg = e.message!;
        }
        _showSnackBar(msg, isError: true);
      } catch (e) {
        _showSnackBar('Sign in failed: $e', isError: true);
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      // --- EMAIL & PASSWORD SIGN IN ---
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (email.isEmpty ||
          !RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        _showSnackBar('Please enter a valid email address', isError: true);
        return;
      }
      if (password.isEmpty || password.length < 6) {
        _showSnackBar('Password must be at least 6 characters', isError: true);
        return;
      }

      setState(() => _isLoading = true);
      try {
        final userCred = await FirebaseService.signInWithEmail(
          email: email,
          password: password,
        );
        if (userCred.user != null) {
          await _ensureUserProfile(userCred.user!);
          _showSnackBar('Sign in successful! Welcome back.');
          _navigateToHome();
        }
      } on FirebaseAuthException catch (e) {
        String message = 'Authentication failed';
        switch (e.code) {
          case 'user-not-found':
            message = 'No user account found with this email. Please sign up.';
            break;
          case 'wrong-password':
            message = 'Incorrect password. Please try again.';
            break;
          case 'invalid-credential':
            message = 'Invalid email or password. Please verify your details.';
            break;
          case 'invalid-email':
            message = 'Invalid email address format.';
            break;
          case 'user-disabled':
            message = 'This user account has been disabled.';
            break;
          case 'too-many-requests':
            message = 'Too many failed login attempts. Please try again later.';
            break;
          default:
            if (e.message != null) message = e.message!;
            break;
        }
        _showSnackBar(message, isError: true);
      } catch (e) {
        _showSnackBar('An unexpected error occurred: $e', isError: true);
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // Handle Google Sign In
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

  // Handle Forgot Password Reset Email
  Future<void> _handleForgotPassword() async {
    final emailController = TextEditingController(
      text: _emailController.text.trim(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF121B17),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF1E302A), width: 1),
        ),
        title: const Text(
          'Reset Password',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your registered email address below and we will send you a password reset link.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: Color(0xFF92A89F),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(fontFamily: 'Inter', color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter your email',
                hintStyle: const TextStyle(color: Color(0xFF627870)),
                filled: true,
                fillColor: const Color(0xFF182E25),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1E302A)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF92A89F)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0B4632),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final resetEmail = emailController.text.trim();
              if (resetEmail.isEmpty || !resetEmail.contains('@')) {
                _showSnackBar(
                  'Please enter a valid email address',
                  isError: true,
                );
                return;
              }
              Navigator.of(context).pop();
              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(
                  email: resetEmail,
                );
                _showSnackBar('Password reset email sent to $resetEmail');
              } catch (e) {
                _showSnackBar('Failed to send reset email: $e', isError: true);
              }
            },
            child: const Text(
              'Send Link',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _handleResendOtp() {
    if (!_canResend) return;
    _handleSendOtp();
  }

  void _navigateToSignUp() {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SignUpScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
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
      backgroundAsset: 'assets/background/bg_signin.jpg',
      title: context.tr('sign_in_account'),
      subtitle: _isPhoneLogin
          ? "We'll send a verification code to your phone."
          : "Sign in with your registered email and password.",
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AuthSegmented<bool>(
              selected: _isPhoneLogin,
              onChanged: (v) => setState(() => _isPhoneLogin = v),
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
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: _isPhoneLogin ? _buildPhoneForm() : _buildEmailForm(),
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
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: _navigateToHome,
            child: Text(
              'Continue as Guest',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.85),
                decoration: TextDecoration.underline,
                decorationColor: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
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
                  text: "Don't have an account? ",
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.70)),
                ),
                TextSpan(
                  text: 'Sign Up',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AuthColors.goldSoft,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = _navigateToSignUp,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text.rich(
              TextSpan(
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12.5,
                  height: 1.4,
                  color: Colors.white.withValues(alpha: 0.65),
                ),
                children: const [
                  TextSpan(text: 'By continuing, you agree to our '),
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  TextSpan(text: '.'),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailForm() {
    return Column(
      key: const ValueKey('email-form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthLabel(context.tr('email_address')),
        AuthField(
          controller: _emailController,
          hint: 'Enter your email address',
          icon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          enabled: !_isLoading,
        ),
        const SizedBox(height: 16),
        AuthLabel(context.tr('password')),
        AuthField(
          controller: _passwordController,
          hint: 'Enter your password',
          icon: Icons.lock_outline_rounded,
          isPassword: true,
          textInputAction: TextInputAction.done,
          enabled: !_isLoading,
          onSubmitted: (_) {
            if (!_isLoading) _handleSignIn();
          },
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _handleForgotPassword,
            style: TextButton.styleFrom(
              foregroundColor: AuthColors.goldSoft,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              context.tr('forgot_password'),
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildSignInButton(),
      ],
    );
  }

  Widget _buildPhoneForm() {
    return Column(
      key: const ValueKey('phone-form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AuthLabel('Phone Number'),
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
        const SizedBox(height: 20),
        const AuthLabel('OTP Code'),
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
        const SizedBox(height: 16),
        _buildSignInButton(),
      ],
    );
  }

  Widget _buildSignInButton() {
    return AuthButton(
      label: context.tr('sign_in'),
      loading: _isLoading,
      onPressed: _handleSignIn,
    );
  }
}
