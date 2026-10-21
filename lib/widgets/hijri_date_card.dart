import 'dart:async';

import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../services/hijri_date.dart';
import '../theme/app_theme.dart';
import 'animations/motion.dart';

/// Slim card for the top of Home showing today's Hijri date, e.g.
/// "9 Jumada al-Awwal 1448 AH". Follows the app language and rolls over to
/// the next day at midnight.
class HijriDateCard extends StatefulWidget {
  /// Replaceable clock, for tests.
  final DateTime Function() now;

  const HijriDateCard({super.key, this.now = DateTime.now});

  @override
  State<HijriDateCard> createState() => _HijriDateCardState();
}

class _HijriDateCardState extends State<HijriDateCard> {
  late DateTime _now;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _now = widget.now();
    _scheduleTick();
  }

  void _scheduleTick() {
    final n = widget.now();
    final midnight = DateTime(n.year, n.month, n.day + 1);
    _timer = Timer(midnight.difference(n) + const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _now = widget.now());
      _scheduleTick();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild when the user switches language.
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLocalizations.currentLocaleNotifier,
      builder: (context, locale, _) => _buildCard(context, locale.languageCode),
    );
  }

  Widget _buildCard(BuildContext context, String lang) {
    final hijri = HijriDate.fromGregorian(_now);
    final dateText =
        '${hijri.day} ${hijri.monthName(lang)} ${hijri.year} ${_era[lang] ?? _era['en']!}';

    return Semantics(
      container: true,
      label: dateText,
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.accentGold.withValues(alpha: 0.35),
            ),
            boxShadow: context.isDarkMode
                ? AppElevation.darkCard
                : AppElevation.subtle,
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.accentGoldSoft, AppColors.accentGold],
                  ),
                  boxShadow: AppElevation.glow(
                    AppColors.accentGold,
                    strength: 0.25,
                  ),
                ),
                child: const Icon(
                  Icons.nightlight_round,
                  size: 20,
                  color: Color(0xFF1A1405),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  dateText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const Map<String, String> _era = {
    'en': 'AH',
    'ar': 'هـ',
    'bn': 'হিজরি',
    'ur': 'ھ',
  };
}
