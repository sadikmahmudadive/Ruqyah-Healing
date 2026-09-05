import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_gradients.dart';
import '../theme/app_theme.dart';
import '../widgets/app_toast.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'English';
  String _textSize = 'Medium';
  bool _highContrast = false;
  bool _reduceMotion = false;
  bool _prayerReminders = true;
  String _audioDownloads = 'Wi-Fi Only';
  bool _biometricLock = true;

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
            // 1. Top Dark Green Header Area
            _buildTopHeader(),

            // 2. Scrollable Settings Groups
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
                    // Group 1: PREFERENCES
                    _buildSectionHeader('PREFERENCES'),
                    const SizedBox(height: 8),
                    _buildPreferencesCard(),

                    const SizedBox(height: 20),

                    // Group 2: SECURITY & PRIVACY
                    _buildSectionHeader('SECURITY & PRIVACY'),
                    const SizedBox(height: 8),
                    _buildSecurityPrivacyCard(),

                    const SizedBox(height: 20),

                    // Group 3: ABOUT & LEGAL
                    _buildSectionHeader('ABOUT & LEGAL'),
                    const SizedBox(height: 8),
                    _buildAboutLegalCard(),

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

  // Top Dark Green Header
  Widget _buildTopHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 20,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        gradient: AppGradients.headerGradient(context),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
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
            'Settings',
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: Color(0xFF90A4AE),
      ),
    );
  }

  // Group 1: PREFERENCES Card
  Widget _buildPreferencesCard() {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.cardBorder, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingItem(
            title: 'Theme Mode',
            trailingText: _getThemeModeLabel(AppTheme.themeModeNotifier.value),
            isTrailingActive: true,
            onTap: _showThemeModeDialog,
          ),
          _buildDivider(),
          _buildSettingItem(
            title: 'Language',
            trailingText: _selectedLanguage,
            onTap: () {
              HapticFeedback.selectionClick();
            },
          ),
          _buildDivider(),
          _buildSettingItem(
            title: 'Text Size',
            trailingText: _textSize,
            onTap: () {
              HapticFeedback.selectionClick();
            },
          ),
          _buildDivider(),
          _buildSettingItem(
            title: 'Display',
            trailingText: _highContrast ? 'High Contrast On' : 'High Contrast Off',
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _highContrast = !_highContrast);
            },
          ),
          _buildDivider(),
          _buildSettingItem(
            title: 'Reduce Motion',
            trailingText: _reduceMotion ? 'On' : 'Off',
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _reduceMotion = !_reduceMotion);
            },
          ),
          _buildDivider(),
          _buildSettingItem(
            title: 'Prayer Reminders',
            hasActiveDot: true,
            trailingText: _prayerReminders ? 'On' : 'Off',
            isTrailingActive: _prayerReminders,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _prayerReminders = !_prayerReminders);
            },
          ),
          _buildDivider(),
          _buildSettingItem(
            title: 'Audio Downloads',
            trailingText: _audioDownloads,
            onTap: () {
              HapticFeedback.selectionClick();
            },
          ),
        ],
      ),
    );
  }

  // Group 2: SECURITY & PRIVACY Card
  Widget _buildSecurityPrivacyCard() {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.cardBorder, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingItem(
            title: 'Biometric Lock',
            hasActiveDot: true,
            trailingText: _biometricLock ? 'On' : 'Off',
            isTrailingActive: _biometricLock,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _biometricLock = !_biometricLock);
            },
          ),
          _buildDivider(),
          _buildSettingItem(
            title: 'Connected Devices',
            badgeText: '2 devices',
            badgeBg: const Color(0xFFEBF7F0),
            badgeColor: const Color(0xFF0B4632),
            onTap: () {
              HapticFeedback.selectionClick();
            },
          ),
          _buildDivider(),
          _buildSettingItem(
            title: 'Health Connect',
            badgeText: 'Connected',
            badgeBg: const Color(0xFFEBF7F0),
            badgeColor: const Color(0xFF0B4632),
            onTap: () {
              HapticFeedback.selectionClick();
            },
          ),
          _buildDivider(),
          _buildSettingItem(
            title: 'Notification Settings',
            trailingText: 'Manage alerts',
            onTap: () {
              HapticFeedback.selectionClick();
            },
          ),
          _buildDivider(),
          _buildSettingItem(
            title: 'Export My Data',
            onTap: () {
              HapticFeedback.selectionClick();
            },
          ),
          _buildDivider(),
          _buildSettingItem(
            title: 'Delete Account',
            isDestructive: true,
            onTap: () {
              HapticFeedback.heavyImpact();
              _showDeleteAccountDialog();
            },
          ),
        ],
      ),
    );
  }

  // Group 3: ABOUT & LEGAL Card
  Widget _buildAboutLegalCard() {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.cardBorder, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingItem(
            title: 'Privacy Policy',
            onTap: () {
              HapticFeedback.selectionClick();
            },
          ),
          _buildDivider(),
          _buildSettingItem(
            title: 'Terms of Service',
            onTap: () {
              HapticFeedback.selectionClick();
            },
          ),
          _buildDivider(),
          _buildSettingItem(
            title: 'About Ruqyah Healing',
            trailingText: 'v1.2.0',
            onTap: () {
              HapticFeedback.selectionClick();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required String title,
    bool hasActiveDot = false,
    String? trailingText,
    bool isTrailingActive = false,
    String? badgeText,
    Color? badgeBg,
    Color? badgeColor,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            children: [
              if (hasActiveDot) ...[
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0B4632),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: isDestructive
                        ? const Color(0xFFE74C3C)
                        : context.textPrimary,
                  ),
                ),
              ),
              if (badgeText != null) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeBg ?? const Color(0xFFEBF7F0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: badgeColor ?? const Color(0xFF0B4632),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ] else if (trailingText != null) ...[
                Text(
                  trailingText,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: isTrailingActive
                        ? FontWeight.w800
                        : FontWeight.w500,
                    color: isTrailingActive
                        ? const Color(0xFF0B4632)
                        : const Color(0xFF90A4AE),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Icon(
                Icons.chevron_right_rounded,
                color: isDestructive
                    ? const Color(0xFFE74C3C)
                    : const Color(0xFF90A4AE),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getThemeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  void _showThemeModeDialog() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8E5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select Theme Mode',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF15221D),
              ),
            ),
            const SizedBox(height: 12),
            _buildThemeRadioOption('System Default (Auto)', ThemeMode.system),
            _buildThemeRadioOption('Light Mode', ThemeMode.light),
            _buildThemeRadioOption('Dark Mode', ThemeMode.dark),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeRadioOption(String label, ThemeMode mode) {
    final isSelected = AppTheme.themeModeNotifier.value == mode;

    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 15,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? const Color(0xFF0B4632) : const Color(0xFF15221D),
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: Color(0xFF0B4632))
          : null,
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          AppTheme.themeModeNotifier.value = mode;
        });
        Navigator.of(context).pop();
      },
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Delete Account',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w800,
            color: Color(0xFFE74C3C),
          ),
        ),
        content: const Text(
          'Are you sure you want to permanently delete your account and all associated health data? This action cannot be undone.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: Color(0xFF6E7E77),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE74C3C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              AppToast.show(
                context,
                title: 'Account Deletion Requested',
                message: 'Account deletion request submitted to support.',
                type: ToastType.warning,
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: 1,
        color: context.cardBorder,
      ),
    );
  }
}
