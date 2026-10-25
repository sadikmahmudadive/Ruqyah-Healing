import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_gradients.dart';
import '../theme/app_theme.dart';
import '../widgets/illustrations/ruqyah_illustrations.dart';
import '../widgets/islamic_pattern.dart';
import 'therapist_marketplace_screen.dart';

class AcupressureHubScreen extends StatefulWidget {
  const AcupressureHubScreen({super.key});

  @override
  State<AcupressureHubScreen> createState() => _AcupressureHubScreenState();
}

class _AcupressureHubScreenState extends State<AcupressureHubScreen> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: context.pageBg,
        body: Column(
          children: [
            _buildTopHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIntroCard(),
                    const SizedBox(height: 20),
                    _buildServicesSection(),
                    const SizedBox(height: 20),
                    _buildSelfCareTipsSection(),
                    const SizedBox(height: 20),
                    _buildBookSessionButton(),
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

  Widget _buildTopHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 20,
        left: 20,
        right: 20,
      ),
      foregroundDecoration: IslamicPatternDecoration(),
      decoration: BoxDecoration(
        gradient: AppGradients.headerGradient(context),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
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
              children: [
                const Text(
                  'ACUPRESSURE HUB',
                  style: TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: Color(0xFFD49E35),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Targeted pressure-point therapy & meridian flow',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.cardBorder, width: 1.0),
      ),
      child: Row(
        children: [
          const FlatIllustration(
            kind: FlatIllustrationKind.acupressure,
            size: 80,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manual Meridian Balancing',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Release muscle tension, relieve chronic pain, and calm anxiety through non-invasive physical touch.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.5,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Target Acupressure Points',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _buildServiceTile(
          'Yintang (Third Eye Point)',
          'Gentle circular forehead stimulation for mental fatigue, sinus relief, and deep calm.',
        ),
        const SizedBox(height: 12),
        _buildServiceTile(
          'Hegu (LI 4 - Union Valley)',
          'Firm pressure on the hand web space for severe headaches, stress, and neck stiffness.',
        ),
        const SizedBox(height: 12),
        _buildServiceTile(
          'Neiguan (P 6 - Inner Gate)',
          'Wrist meridian acupoint for relieving motion sickness, nausea, and racing thoughts.',
        ),
        const SizedBox(height: 12),
        _buildServiceTile(
          'Taichong (LV 3 - Great Surge)',
          'Foot meridian pressure point to lower blood pressure, soothe irritability, and release tension.',
        ),
      ],
    );
  }

  Widget _buildSelfCareTipsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.cardBorder, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.spa_rounded, color: Color(0xFFC86D51), size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Clinical Application Guidelines',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Apply gradual, steady thumb pressure for 1 to 2 minutes while taking calm, deep breaths. Stop immediately if acute sharp pain occurs. Avoid deep abdominal and hand points during pregnancy without professional consultation.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.5,
              color: context.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceTile(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.cardBorder, width: 1.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.5,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF90A4AE),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildBookSessionButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.greenButtonGradient,
          borderRadius: BorderRadius.circular(18),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (_, _, _) => const TherapistMarketplaceScreen(
                  initialCategory: 'Acupressure',
                ),
              ),
            );
          },
          child: const Text(
            'Book Acupressure Consultation',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
