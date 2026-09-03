import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_gradients.dart';
import '../widgets/app_toast.dart';

class ToastShowcaseScreen extends StatelessWidget {
  const ToastShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F6),
        body: Column(
          children: [
            // Top Dark Green Header Area
            _buildTopHeader(context),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOAST NOTIFICATION VARIANTS',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: Color(0xFF90A4AE),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 1. Success Toast
                    _buildInteractiveToastTrigger(
                      context,
                      title: 'Session Booked Successfully',
                      message: 'Your Hijama session is confirmed for May 20.',
                      type: ToastType.success,
                    ),

                    const SizedBox(height: 16),

                    // 2. Error / Danger Toast
                    _buildInteractiveToastTrigger(
                      context,
                      title: 'Payment Failed',
                      message: 'Please check your card details and try again.',
                      type: ToastType.error,
                    ),

                    const SizedBox(height: 16),

                    // 3. Warning Toast
                    _buildInteractiveToastTrigger(
                      context,
                      title: 'Session Starting Soon',
                      message: 'Your video consultation begins in 5 minutes.',
                      type: ToastType.warning,
                    ),

                    const SizedBox(height: 16),

                    // 4. Info Toast
                    _buildInteractiveToastTrigger(
                      context,
                      title: 'New Course Available',
                      message: 'Fundamentals of Ruqyah is now available.',
                      type: ToastType.info,
                    ),

                    const SizedBox(height: 28),

                    // Instructions Banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBF7F0),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF0B4632).withValues(alpha: 0.15),
                          width: 1.0,
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.touch_app_rounded,
                            color: Color(0xFF0B4632),
                            size: 22,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Tap any toast message card above to trigger a floating alert notification.',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12.5,
                                color: Color(0xFF52625B),
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 20,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        gradient: AppGradients.greenHeaderGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          // Back Button
          Container(
            width: 44,
            height: 44,
            margin: const EdgeInsets.only(right: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
              padding: EdgeInsets.zero,
            ),
          ),

          const Text(
            'Toast Messages',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveToastTrigger(
    BuildContext context, {
    required String title,
    required String message,
    required ToastType type,
  }) {
    return InkWell(
      onTap: () {
        AppToast.show(
          context,
          title: title,
          message: message,
          type: type,
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: AppToastWidget(
        title: title,
        message: message,
        type: type,
      ),
    );
  }
}
