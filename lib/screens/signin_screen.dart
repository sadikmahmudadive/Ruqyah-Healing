import 'dart:async';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../widgets/country_code_picker.dart';
import '../widgets/google_logo.dart';
import 'main_navigation_shell.dart';
import 'signup_screen.dart';

class SignInScreen extends StatefulWidget {
  final VoidCallback? onSignInSuccess;

  const SignInScreen({super.key, this.onSignInSuccess});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
  bool _isPasswordVisible = false;

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
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    HapticFeedback.heavyImpact();
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

  Future<void> _handleSendOtp() async {
    _startResendTimer();
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('OTP verification code sent to your phone'),
        backgroundColor: Color(0xFF1E6B45),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleSignIn() async {
    _navigateToHome();
  }

  Future<void> _handleGoogleSignIn() async {
    _navigateToHome();
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
              'assets/background/bg_signin.jpg',
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
                    Colors.black.withValues(alpha: 0.25),
                    Colors.black.withValues(alpha: 0.15),
                    Colors.black.withValues(alpha: 0.40),
                    Colors.black.withValues(alpha: 0.75),
                  ],
                  stops: const [0.0, 0.35, 0.70, 1.0],
                ),
              ),
            ),

            // Foreground Scrollable Form Content
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
                        // Top spacing to position content below artwork
                        SizedBox(height: screenHeight * 0.20),

                        // Main Header Title
                        const Text(
                          'SIGN IN TO YOUR ACCOUNT',
                          style: TextStyle(
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
                          _isPhoneLogin
                              ? "We'll send a verification code to your phone."
                              : "Sign in with your registered email and password.",
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.78),
                            height: 1.35,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Login Method Tab Switcher Segment (Email vs Phone)
                        _buildLoginTabSwitcher(),

                        const SizedBox(height: 24),

                        if (!_isPhoneLogin) ...[
                          // --- EMAIL LOGIN FORM ---
                          _buildFieldLabel('Email Address'),
                          const SizedBox(height: 8),
                          _buildEmailInputField(),

                          const SizedBox(height: 16),

                          _buildFieldLabel('Password'),
                          const SizedBox(height: 8),
                          _buildPasswordInputField(),

                          const SizedBox(height: 8),

                          // Forgot Password
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Password reset link sent to your email'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFE5A93C),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          _buildSignInButton(),
                        ] else ...[
                          // --- PHONE OTP LOGIN FORM ---
                          _buildFieldLabel('Phone Number'),
                          const SizedBox(height: 8),
                          _buildPhoneInputField(),

                          const SizedBox(height: 12),

                          _buildSendOtpButton(),

                          const SizedBox(height: 20),

                          _buildFieldLabel('OTP Code'),
                          const SizedBox(height: 8),
                          _buildOtpInputField(),

                          const SizedBox(height: 12),

                          _buildSignInButton(),
                        ],

                        const SizedBox(height: 24),

                        // Divider line with text "or continue with"
                        _buildOrDivider(),

                        const SizedBox(height: 20),

                        // Google Sign-In Button
                        _buildGoogleSignInButton(),

                        const SizedBox(height: 32),

                        // Footer: Don't have an account? Sign Up
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
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.70),
                                  ),
                                ),
                                TextSpan(
                                  text: 'Sign Up',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFE5A93C),
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = _navigateToSignUp,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Terms & Privacy Disclaimer
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
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

                        const SizedBox(height: 24),
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

  // Login Method Tab Switcher Segment (Email vs Phone)
  Widget _buildLoginTabSwitcher() {
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
        children: [
          // Email Tab
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _isPhoneLogin = false);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: !_isPhoneLogin
                      ? const Color(0xFF113E2E)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: !_isPhoneLogin
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
                      color: !_isPhoneLogin
                          ? Colors.white
                          : const Color(0xFF4F6058),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Email',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14.5,
                        fontWeight: !_isPhoneLogin
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: !_isPhoneLogin
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
                setState(() => _isPhoneLogin = true);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: _isPhoneLogin
                      ? const Color(0xFF113E2E)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: _isPhoneLogin
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
                      color: _isPhoneLogin
                          ? Colors.white
                          : const Color(0xFF4F6058),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Phone',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14.5,
                        fontWeight: _isPhoneLogin
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: _isPhoneLogin
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
                    setState(() => _isPhoneLogin = true);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: _isPhoneLogin
                          ? const Color(0xFF1E6B45)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.phone_iphone_rounded,
                          size: 18,
                          color: _isPhoneLogin
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.65),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Phone',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 14,
                            fontWeight: _isPhoneLogin
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: _isPhoneLogin
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.65),
                          ),
                        ),
                      ],
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

  Widget _buildEmailInputField() {
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
                Icons.mail_outline_rounded,
                color: Colors.white.withValues(alpha: 0.70),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isLoading,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter your email address',
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

  Widget _buildPasswordInputField() {
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
                Icons.lock_outline_rounded,
                color: Colors.white.withValues(alpha: 0.70),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  enabled: !_isLoading,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
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
              IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.white.withValues(alpha: 0.70),
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
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
              // Interactive Country Dropdown Selector
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

              // Vertical Divider
              Container(
                width: 1,
                height: 22,
                color: Colors.white.withValues(alpha: 0.20),
              ),

              const SizedBox(width: 12),

              // Phone Text Input
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

  Widget _buildSignInButton() {
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
          onTap: _isLoading ? null : _handleSignIn,
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
                    'Sign In',
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
