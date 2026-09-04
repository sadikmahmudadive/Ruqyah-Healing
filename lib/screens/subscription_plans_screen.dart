import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_gradients.dart';
import '../widgets/app_toast.dart';

class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  State<SubscriptionPlansScreen> createState() =>
      _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  String _selectedPlanId = 'monthly'; // 'free', 'monthly', 'yearly'

  void _handleContinue() {
    HapticFeedback.heavyImpact();
    AppToast.show(
      context,
      title: 'Subscription Updated',
      message: 'You have successfully selected the $_selectedPlanId plan.',
      type: ToastType.success,
    );
  }

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
            // 1. Top Dark Green Header Area
            _buildTopHeader(),

            // 2. Scrollable Body Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Choose a plan that supports your healing journey.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13.5,
                        color: Color(0xFF6E7E77),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Free Plan Card
                    _buildPlanCard(
                      id: 'free',
                      title: 'Free Plan',
                      price: '৳0',
                      period: '/month',
                      features: [
                        'Basic access',
                        'Free content',
                        'Progress tracking',
                        'Prayer reminders',
                      ],
                      isPremium: false,
                    ),

                    const SizedBox(height: 16),

                    // Healing Plus Monthly Card
                    _buildPlanCard(
                      id: 'monthly',
                      title: 'Healing Plus Monthly',
                      price: '৳249',
                      period: '/month',
                      tagLabel: 'Most Popular',
                      tagColor: const Color(0xFFEBF7F0),
                      tagTextColor: const Color(0xFF0B4632),
                      features: [
                        'Offline audio',
                        'Premium playlists',
                        'Discounts on sessions',
                        'Progress insights',
                      ],
                      isPremium: true,
                      footerText: 'Cancel anytime • Billed monthly',
                    ),

                    const SizedBox(height: 16),

                    // Healing Plus Yearly Card
                    _buildPlanCard(
                      id: 'yearly',
                      title: 'Healing Plus Yearly',
                      price: '৳2,388',
                      period: '/year',
                      subtitle: 'equiv. ৳199/month',
                      tagLabel: 'Save 20%',
                      tagColor: const Color(0xFFFFF8E1),
                      tagTextColor: const Color(0xFFD49E35),
                      isPremium: true,
                      footerText: 'Cancel anytime • Billed yearly',
                    ),

                    const SizedBox(height: 32),

                    // Trust Signals
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildTrustSignal('Transparent renewal'),
                        _buildTrustSignal('No hidden charges'),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Restore Purchase Link
                    Center(
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          AppToast.show(
                            context,
                            title: 'Restoring Purchases',
                            message: 'Looking for previous subscriptions...',
                            type: ToastType.info,
                          );
                        },
                        child: const Text(
                          'Restore Purchase',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0B4632),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Continue Button
                    Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: AppGradients.greenButtonGradient,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0B4632).withValues(alpha: 0.30),
                            offset: const Offset(0, 6),
                            blurRadius: 18,
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _handleContinue,
                          borderRadius: BorderRadius.circular(18),
                          splashColor: Colors.white.withValues(alpha: 0.15),
                          child: const Center(
                            child: Text(
                              'Continue',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Terms Footer
                    Center(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: 'By continuing, you agree to our ',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                color: Color(0xFF90A4AE),
                              ),
                            ),
                            TextSpan(
                              text: 'Terms of Service',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                color: Color(0xFF90A4AE),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const TextSpan(
                              text: '.',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                color: Color(0xFF90A4AE),
                              ),
                            ),
                          ],
                        ),
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

  // Top Dark Green Header Area
  Widget _buildTopHeader() {
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

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'WELLNESS',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: Color(0xFF81C784),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Subscription Plans',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required String id,
    required String title,
    required String price,
    required String period,
    String? subtitle,
    String? tagLabel,
    Color? tagColor,
    Color? tagTextColor,
    List<String>? features,
    required bool isPremium,
    String? footerText,
  }) {
    final isSelected = _selectedPlanId == id;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedPlanId = id);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF0B4632) : const Color(0xFFE2E8E5),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isPremium
                              ? const Color(0xFF0B4632)
                              : const Color(0xFF15221D),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            price,
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: isPremium
                                  ? const Color(0xFF0B4632)
                                  : const Color(0xFF52625B),
                            ),
                          ),
                          Text(
                            period,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              color: Color(0xFF2ECC71),
                            ),
                          ),
                        ],
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: Color(0xFF90A4AE),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Tags & Selection Circle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (tagLabel != null && tagColor != null && tagTextColor != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: tagColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          tagLabel,
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: tagTextColor,
                          ),
                        ),
                      ),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF0B4632)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF0B4632)
                              : const Color(0xFF90A4AE),
                          width: 2.0,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                  ],
                ),
              ],
            ),

            if (features != null) ...[
              const SizedBox(height: 16),
              ...features.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Icon(
                          isPremium ? Icons.check_circle_rounded : Icons.circle,
                          color: isPremium
                              ? const Color(0xFF2ECC71)
                              : const Color(0xFFB0BEC5),
                          size: isPremium ? 16 : 6,
                        ),
                        SizedBox(width: isPremium ? 8 : 12),
                        Text(
                          f,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12.5,
                            fontWeight: isPremium ? FontWeight.w600 : FontWeight.w400,
                            color: const Color(0xFF15221D),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],

            if (footerText != null) ...[
              const SizedBox(height: 12),
              Text(
                footerText,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: Color(0xFF90A4AE),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTrustSignal(String text) {
    return Row(
      children: [
        const Icon(
          Icons.check_rounded,
          color: Color(0xFF2ECC71),
          size: 14,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF52625B),
          ),
        ),
      ],
    );
  }
}
