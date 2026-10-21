import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_gradients.dart';
import '../theme/app_theme.dart';
import '../widgets/illustrations/ruqyah_illustrations.dart';
import '../widgets/islamic_pattern.dart';
import 'equipment_store_screen.dart';
import 'therapist_marketplace_screen.dart';

class MedicineHubScreen extends StatefulWidget {
  const MedicineHubScreen({super.key});

  @override
  State<MedicineHubScreen> createState() => _MedicineHubScreenState();
}

class _MedicineHubScreenState extends State<MedicineHubScreen> {
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
                    _buildRemediesSection(),
                    const SizedBox(height: 20),
                    _buildPropheticPrinciplesCard(),
                    const SizedBox(height: 20),
                    _buildStoreButton(),
                    const SizedBox(height: 12),
                    _buildConsultationButton(),
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
                  'MEDICINE HUB',
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
                  'Prophetic medicine (Tibb an-Nabawi) & natural remedies',
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
            kind: FlatIllustrationKind.medicine,
            size: 80,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prophetic & Natural Medicine',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Authentic Sunnah botanical remedies and nutritional therapies rooted in the Quran and Hadith to restore physical, metabolic, and emotional vitality.',
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

  Widget _buildRemediesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Core Prophetic Remedies',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _buildRemedyTile(
          'Habbat al-Barakah (Black Seed)',
          'The blessed Nigella Sativa: “A cure for every illness except death” (Sahih al-Bukhari 5688).',
          Icons.eco_rounded,
          const Color(0xFF16A085),
        ),
        const SizedBox(height: 12),
        _buildRemedyTile(
          'Pure Raw Honey (Asal Shifa)',
          '“There comes forth from their bellies a drink of varying colors, wherein is healing for mankind” (An-Nahl: 69).',
          Icons.water_drop_rounded,
          const Color(0xFFD49E35),
        ),
        const SizedBox(height: 12),
        _buildRemedyTile(
          'Talbina (Barley & Milk Porridge)',
          'Prophetic remedy proven to comfort the heart of the sick and soothe grief, anxiety, and depression.',
          Icons.soup_kitchen_rounded,
          const Color(0xFF8D6E63),
        ),
        const SizedBox(height: 12),
        _buildRemedyTile(
          'Ajwa Dates of Madinah',
          'Rich in minerals and antioxidants; provides potent morning metabolic and spiritual shielding.',
          Icons.circle_rounded,
          const Color(0xFF5D4037),
        ),
        const SizedBox(height: 12),
        _buildRemedyTile(
          'Zayt Az-Zaytūn (Pure Olive Oil)',
          'Oil from a blessed tree for ingestion and recited therapeutic body massage (At-Tirmidhi 1851).',
          Icons.opacity_rounded,
          const Color(0xFF4E8F62),
        ),
      ],
    );
  }

  Widget _buildRemedyTile(
    String title,
    String subtitle,
    IconData icon,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.cardBorder, width: 1.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: 14),
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
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.5,
                    color: context.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF90A4AE),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildPropheticPrinciplesCard() {
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
              const Icon(
                Icons.health_and_safety_rounded,
                color: Color(0xFF16A085),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Prophetic Prescription Philosophy',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'In Islamic medicine, healing combines Tawakkul (complete reliance on Allah as Ash-Shafi) with seeking lawful, natural medical treatments (Asbab). Our remedies are 100% natural, ethically sourced, and free from synthetic additives.',
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

  Widget _buildStoreButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.greenButtonGradient,
          borderRadius: BorderRadius.circular(18),
        ),
        child: ElevatedButton.icon(
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
                pageBuilder: (_, _, _) => const EquipmentStoreScreen(),
              ),
            );
          },
          icon: const Icon(Icons.storefront_rounded, color: Colors.white, size: 20),
          label: const Text(
            'Order Natural Remedies in Store',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConsultationButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: context.cardBorderStrong, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (_, _, _) => const TherapistMarketplaceScreen(
                initialCategory: 'Medicine',
              ),
            ),
          );
        },
        icon: Icon(
          Icons.medical_services_outlined,
          color: context.textPrimary,
          size: 19,
        ),
        label: Text(
          'Consult Natural Medicine Specialist',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: context.textPrimary,
          ),
        ),
      ),
    );
  }
}
