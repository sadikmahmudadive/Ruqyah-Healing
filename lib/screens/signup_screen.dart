import 'dart:async';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../localization/app_localizations.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../widgets/country_code_picker.dart';
import '../widgets/google_logo.dart';
import 'main_navigation_shell.dart';

class SignUpScreen extends StatefulWidget {
  final VoidCallback? onSignUpSuccess;

  const SignUpScreen({super.key, this.onSignUpSuccess});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isPhoneSignUp = false; // false = Email Sign Up, true = Phone Sign Up
  String _selectedRole = 'patient'; // 'patient' (User), 'raki' (Raki), 'therapist' (Therapist)

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  CountryCode _selectedCountry = kDefaultCountryCodes[0];
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  String? _verificationId;
  int _resendSeconds = 45;
  Timer? _resendTimer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );

    _animController.forward();
  }

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
    _animController.dispose();
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
        backgroundColor:
            isError ? const Color(0xFFC0392B) : const Color(0xFF1E6B45),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _navigateToHome() {
    HapticFeedback.heavyImpact();
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
            _showSnackBar(e.message ?? 'Phone verification failed', isError: true);
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
    HapticFeedback.mediumImpact();

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
      if (email.isEmpty || !RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        _showSnackBar('Please enter a valid email address', isError: true);
        return;
      }
      if (password.isEmpty || password.length < 6) {
        _showSnackBar('Password must be at least 6 characters long', isError: true);
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

          final newUser = UserModel(
            userId: user.uid,
            email: email,
            phone: '',
            name: fullName,
            role: _selectedRole,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            healthProfile: HealthProfile.empty(),
            billing: BillingProfile.empty(),
          );

          await FirebaseService.saveUserProfile(newUser);
          _showSnackBar('Account created successfully! Welcome to Ruqyah Healing.');
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
      final phone = _phoneController.text.trim();
      final otpCode = _otpController.text.trim();

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
        _showSnackBar('Password must be at least 6 characters long', isError: true);
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

          final fullPhone = '${_selectedCountry.code}$phone';
          final newUser = UserModel(
            userId: user.uid,
            email: user.email ?? '',
            phone: fullPhone,
            name: fullName,
            role: _selectedRole,
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
    HapticFeedback.mediumImpact();
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF0B0E13),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            Image.asset(
              'assets/background/bg_signup.jpg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox();
              },
            ),

            // Slight Blur Effect on Background
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                child: const SizedBox(),
              ),
            ),

            // Atmospheric Vignette Gradient Layer
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.35),
                    Colors.black.withValues(alpha: 0.20),
                    Colors.black.withValues(alpha: 0.45),
                    Colors.black.withValues(alpha: 0.75),
                  ],
                  stops: const [0.0, 0.35, 0.70, 1.0],
                ),
              ),
            ),

            // Foreground Scrollable Content
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: screenHeight * 0.15),

                        // Main Header Title
                        Text(
                          context.tr('create_account_title'),
                          style: const TextStyle(
                            fontFamily: 'Cinzel',
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.6,
                            color: Colors.white,
                            height: 1.25,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 2),
                                blurRadius: 10.0,
                                color: Color(0xCC000000),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Subtitle
                        Text(
                          _isPhoneSignUp
                              ? 'Sign up with your phone number and verify via OTP.'
                              : 'Join us to start your spiritual and physical wellness journey.',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.78),
                            height: 1.35,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Tab Switcher (Email vs Phone)
                        _buildSignUpTabSwitcher(),

                        const SizedBox(height: 24),

                        // Full Name Field (Common)
                        _buildFieldLabel(context.tr('full_name')),
                        const SizedBox(height: 8),
                        _buildInputField(
                          controller: _fullNameController,
                          icon: Icons.person_outline,
                          hintText: 'Enter your full name',
                          keyboardType: TextInputType.name,
                        ),

                        const SizedBox(height: 18),

                        if (!_isPhoneSignUp) ...[
                          // --- EMAIL SIGN UP FIELDS ---
                          _buildFieldLabel(context.tr('email_address')),
                          const SizedBox(height: 8),
                          _buildInputField(
                            controller: _emailController,
                            icon: Icons.email_outlined,
                            hintText: 'Enter your email address',
                            keyboardType: TextInputType.emailAddress,
                          ),

                          const SizedBox(height: 18),
                        ] else ...[
                          // --- PHONE SIGN UP FIELDS ---
                          _buildFieldLabel(context.tr('phone')),
                          const SizedBox(height: 8),
                          _buildPhoneInputField(),

                          const SizedBox(height: 12),

                          _buildSendOtpButton(),

                          const SizedBox(height: 18),

                          _buildFieldLabel(context.tr('otp_code')),
                          const SizedBox(height: 8),
                          _buildOtpInputField(),

                          const SizedBox(height: 18),
                        ],

                        // Password
                        _buildFieldLabel(context.tr('password')),
                        const SizedBox(height: 8),
                        _buildPasswordField(
                          controller: _passwordController,
                          hintText: 'Create strong password',
                          obscureText: _obscurePassword,
                          onToggleVisibility: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),

                        const SizedBox(height: 18),

                        // Confirm Password
                        _buildFieldLabel(context.tr('confirm_password')),
                        const SizedBox(height: 8),
                        _buildPasswordField(
                          controller: _confirmPasswordController,
                          hintText: 'Repeat your password',
                          obscureText: _obscureConfirmPassword,
                          onToggleVisibility: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),

                        const SizedBox(height: 18),

                        // Select Role Segment Switcher (User, Raki, Therapist)
                        _buildFieldLabel(context.tr('select_role')),
                        const SizedBox(height: 8),
                        _buildRoleSelector(),

                        const SizedBox(height: 26),

                        // Create Account Primary Emerald Button
                        _buildCreateAccountButton(),

                        const SizedBox(height: 24),

                        // Divider line with text "or continue with"
                        _buildOrDivider(),

                        const SizedBox(height: 20),

                        // Google Sign-In Button
                        _buildGoogleSignInButton(),

                        const SizedBox(height: 32),

                        // Footer: Already have an account? Sign In
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
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.70),
                                  ),
                                ),
                                TextSpan(
                                  text: 'Sign In',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2ECC71),
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = _navigateToSignIn,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Role Selector Switcher (User, Raki, Therapist)
  Widget _buildRoleSelector() {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.40),
          width: 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildRoleTabOption(
            roleKey: 'patient',
            label: context.tr('user'),
            icon: Icons.person_outline_rounded,
          ),
          _buildRoleTabOption(
            roleKey: 'raki',
            label: context.tr('raki'),
            icon: Icons.record_voice_over_outlined,
          ),
          _buildRoleTabOption(
            roleKey: 'therapist',
            label: context.tr('therapist'),
            icon: Icons.medical_services_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildRoleTabOption({
    required String roleKey,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedRole == roleKey;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedRole = roleKey);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF113E2E) : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.70),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Sign Up Method Tab Switcher Segment (Email vs Phone)
  Widget _buildSignUpTabSwitcher() {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEEA),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.60),
          width: 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email Tab
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _isPhoneSignUp = false);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: !_isPhoneSignUp
                      ? const Color(0xFF113E2E)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: !_isPhoneSignUp
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.mail_outline_rounded,
                      size: 20,
                      color: !_isPhoneSignUp
                          ? Colors.white
                          : const Color(0xFF4F6058),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Email',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 15,
                        fontWeight: !_isPhoneSignUp
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: !_isPhoneSignUp
                            ? Colors.white
                            : const Color(0xFF4F6058),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Phone Tab
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _isPhoneSignUp = true);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _isPhoneSignUp
                      ? const Color(0xFF113E2E)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: _isPhoneSignUp
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      size: 20,
                      color: _isPhoneSignUp
                          ? Colors.white
                          : const Color(0xFF4F6058),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Phone',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 15,
                        fontWeight: _isPhoneSignUp
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: _isPhoneSignUp
                            ? Colors.white
                            : const Color(0xFF4F6058),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF12181F).withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.white.withValues(alpha: 0.70),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  enabled: !_isLoading,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14.5,
                      color: Colors.white.withValues(alpha: 0.45),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
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
      setState(() {
        _selectedCountry = picked;
      });
    }
  }

  Widget _buildPhoneInputField() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF12181F).withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              InkWell(
                onTap: _handlePickCountry,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6.0,
                    vertical: 6.0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedCountry.flag,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _selectedCountry.code,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white.withValues(alpha: 0.75),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 1,
                height: 22,
                color: Colors.white.withValues(alpha: 0.20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  enabled: !_isLoading,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter phone number',
                    hintStyle: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14.5,
                      color: Colors.white.withValues(alpha: 0.45),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSendOtpButton() {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFF1E6B45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2ECC71).withValues(alpha: 0.35),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E6B45).withValues(alpha: 0.30),
            offset: const Offset(0, 4),
            blurRadius: 16,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _handleSendOtp,
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white.withValues(alpha: 0.15),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Send OTP',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpInputField() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF12181F).withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              // Key Icon
              Icon(
                Icons.vpn_key_outlined,
                color: Colors.white.withValues(alpha: 0.70),
                size: 20,
              ),

              const SizedBox(width: 12),

              // OTP Input Field
              Expanded(
                child: TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  enabled: !_isLoading,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter 6-digit code',
                    hintStyle: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14.5,
                      letterSpacing: 0,
                      color: Colors.white.withValues(alpha: 0.45),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),

              // Resend Timer / Button
              GestureDetector(
                onTap: (_canResend && !_isLoading) ? _handleResendOtp : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    _canResend ? 'Resend' : 'Resend (${_resendSeconds}s)',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: _canResend
                          ? const Color(0xFFE5A93C)
                          : const Color(0xFFE5A93C).withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF12181F).withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.lock_outline,
                color: Colors.white.withValues(alpha: 0.70),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscureText,
                  enabled: !_isLoading,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14.5,
                      color: Colors.white.withValues(alpha: 0.45),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onToggleVisibility,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Icon(
                    obscureText
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.white.withValues(alpha: 0.65),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateAccountButton() {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xFF1E6B45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2ECC71).withValues(alpha: 0.35),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E6B45).withValues(alpha: 0.35),
            offset: const Offset(0, 6),
            blurRadius: 18,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _handleCreateAccount,
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white.withValues(alpha: 0.15),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Create Account',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.18),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          child: Text(
            'or continue with',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.60),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.18),
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleSignInButton() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isLoading ? null : _handleGoogleSignIn,
            borderRadius: BorderRadius.circular(16),
            splashColor: Colors.white.withValues(alpha: 0.12),
            highlightColor: Colors.white.withValues(alpha: 0.06),
            child: Container(
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.22),
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  GoogleLogo(size: 20),
                  SizedBox(width: 12),
                  Text(
                    'Continue with Google',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
