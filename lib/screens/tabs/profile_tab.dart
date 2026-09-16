import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../localization/app_localizations.dart';
import '../../models/user_model.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/global_bottom_navbar.dart';
import '../health_profile_detail_screen.dart';
import '../main_navigation_shell.dart';
import '../notification_screen.dart';
import '../settings_screen.dart';
import '../signin_screen.dart';
import '../subscription_plans_screen.dart';
import '../toast_showcase_screen.dart';

class ProfileTab extends StatelessWidget {
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseService.currentUser;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      value: context.systemOverlayStyle,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F6),
        backgroundColor: context.pageBg,
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5F7F6),
          backgroundColor: context.pageBg,
          elevation: 0,
          title: const Text(
            'HEALTH PROFILE',
          titleSpacing: 20,
          automaticallyImplyLeading: false,
          title: Text(
            'PROFILE',
            style: TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 20,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: Color(0xFF15221D),
              color: context.textPrimary,
            ),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            children: [
              // User Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B4632),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF2ECC71)
                              .withValues(alpha: 0.35),
                          width: 2.0,
                        ),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(
                right: 16.0,
                top: 8.0,
                bottom: 8.0,
              ),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.cardBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.cardBorder, width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currentUser?.displayName ?? 'Patient User',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF15221D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentUser?.email ??
                          currentUser?.phoneNumber ??
                          'patient@ruqyahhealing.com',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13.5,
                        color: Color(0xFF6E7E77),
                      ),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.settings_outlined,
                    color: context.textPrimary,
                    size: 20,
                  ),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (_, _, _) => const SettingsScreen(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeInOut,
                                ),
                                child: child,
                              );
                            },
                        transitionDuration: const Duration(milliseconds: 300),
                      ),
                    );
                  },
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
        body: currentUser == null
            ? _buildProfileContent(
                name: 'Guest User',
                email: 'Sign in to access full features',
                sessionsCompleted: '0',
                healthIndex: '--',
                daysActive: '0',
                isGuest: true,
              )
            : FutureBuilder<UserModel?>(
                future: FirebaseService.getUserProfile(currentUser.uid),
                builder: (context, snapshot) {
                  final userModel = snapshot.data;

              const SizedBox(height: 32),
                  String resolvedName = 'User';
                  if (userModel?.name.isNotEmpty == true) {
                    resolvedName = userModel!.name;
                  } else if (currentUser.displayName?.isNotEmpty == true) {
                    resolvedName = currentUser.displayName!;
                  } else if (currentUser.email?.isNotEmpty == true) {
                    final prefix = currentUser.email!.split('@').first;
                    resolvedName = prefix.isNotEmpty
                        ? prefix[0].toUpperCase() + prefix.substring(1)
                        : 'User';
                  } else if (currentUser.phoneNumber?.isNotEmpty == true) {
                    resolvedName = currentUser.phoneNumber!;
                  }

              // Profile Actions
              _buildProfileOption(
                icon: Icons.security_rounded,
                title: 'Women\'s Privacy Mode',
                subtitle: 'Restricts medical logs to female practitioners',
                  final resolvedEmail = userModel?.email.isNotEmpty == true
                      ? userModel!.email
                      : (currentUser.email?.isNotEmpty == true
                            ? currentUser.email!
                            : (currentUser.phoneNumber ?? ''));

                  final sessionsCount =
                      userModel?.healthProfile.ruqyahAudioLogs.length
                          .toString() ??
                      '0';
                  final healthScore = userModel?.healthProfile != null
                      ? '${100 - (userModel!.healthProfile.stressLevelIndex * 4)}'
                      : '80';
                  final activeDays = userModel?.createdAt != null
                      ? '${DateTime.now().difference(userModel!.createdAt).inDays + 1}'
                      : '1';

                  return _buildProfileContent(
                    name: resolvedName,
                    email: resolvedEmail,
                    sessionsCompleted: sessionsCount,
                    healthIndex: healthScore,
                    daysActive: activeDays,
                    isGuest: false,
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildProfileOption(
                icon: Icons.child_care_rounded,
                title: 'Child Mode',
                subtitle: 'Parent/Guardian account management',
              ),
              const SizedBox(height: 12),
              _buildProfileOption(
                icon: Icons.history_rounded,
                title: 'Clinical Allergy & Symptom Log',
                subtitle: 'View 3D body maps & Hijama history',
              ),
      ),
    );
  }

              const SizedBox(height: 32),
  Widget _buildProfileContent({
    required String name,
    required String email,
    required String sessionsCompleted,
    required String healthIndex,
    required String daysActive,
    required bool isGuest,
  }) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Column(
        children: [
          // 1. User Avatar & Identity Header
          _buildAvatarHeader(name, email),

              // Sign Out Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Colors.red.withValues(alpha: 0.40),
                      width: 1.0,
          const SizedBox(height: 20),

          // 2. Statistics Bento Cards (3 Columns)
          _buildStatsBentoRow(
            sessionsCompleted: sessionsCompleted,
            healthIndex: healthIndex,
            daysActive: daysActive,
          ),

          const SizedBox(height: 20),

          // 3. Settings Options List Card
          _buildSettingsListCard(),

          const SizedBox(height: 16),

          // 4. Logout or Sign-In Card
          isGuest ? _buildAuthCard() : _buildLogoutCard(),

          const SizedBox(height: 120),
        ],
      ),
    );
  }

  // 1. Avatar Header
  Widget _buildAvatarHeader(String name, String email) {
    return Column(
      children: [
        Stack(
          children: [
            // Circular Avatar Container with Golden Ring Border
            Container(
              width: 90,
              height: 90,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD49E35), width: 2.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(42),
                child: Image.asset(
                  'assets/logo/logo_app.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFF1E3A2F),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 40,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () async {
                    await FirebaseService.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const SignInScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: Colors.redAccent,
                  ),
                  label: const Text(
                    'Sign Out',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ),
            ],
            ),

            // Camera Badge at bottom right
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFD49E35),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.0),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Text(
          name,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: context.textPrimary,
          ),
        ),
      ),

        const SizedBox(height: 2),

        Text(
          email,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: context.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
  // 2. Statistics Bento Cards (3 Equal Columns)
  Widget _buildStatsBentoRow({
    required String sessionsCompleted,
    required String healthIndex,
    required String daysActive,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildBentoCard(
            number: sessionsCompleted,
            label: 'SESSIONS',
            subtitle: 'Completed',
            subtitleColor: context.textSecondary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, _, _) => const HealthProfileDetailScreen(),
                ),
              );
            },
            child: _buildBentoCard(
              number: healthIndex,
              label: 'HEALTH INDEX',
              subtitle: 'Good State',
              subtitleColor: const Color(0xFF1E6B45),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildBentoCard(
            number: daysActive,
            label: 'DAYS ACTIVE',
            subtitle: 'Streak Tracker',
            subtitleColor: context.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildBentoCard({
    required String number,
    required String label,
    required String subtitle,
    required Color subtitleColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.cardBorder, width: 1.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            number,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: subtitleColor,
            ),
          ),
        ],
      ),
    );
  }

  // 3. Settings Options List Card
  Widget _buildSettingsListCard() {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.cardBorder, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF0B4632), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
          _buildSettingsTile(
            icon: Icons.tune_rounded,
            title: context.tr('personal_info'),
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, _, _) => const ToastShowcaseScreen(),
                ),
              );
            },
          ),
          _buildDivider(),
          _buildSettingsTile(
            icon: Icons.calendar_today_outlined,
            title: context.tr('my_appointments'),
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).pushAndRemoveUntil(
                PageRouteBuilder(
                  pageBuilder: (_, _, _) =>
                      MainNavigationShell(initialTab: NavigationTab.bookings),
                ),
                (route) => false,
              );
            },
          ),
          _buildDivider(),
          _buildSettingsTile(
            icon: Icons.workspace_premium_rounded,
            title: context.tr('subscription_plans'),
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, _, _) => const SubscriptionPlansScreen(),
                ),
              );
            },
          ),
          _buildDivider(),
          _buildSettingsTile(
            icon: Icons.credit_card_outlined,
            title: context.tr('payment_methods'),
            onTap: () {
              HapticFeedback.selectionClick();
            },
          ),
          _buildDivider(),
          _buildSettingsTile(
            icon: Icons.notifications_none_rounded,
            title: context.tr('notifications'),
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, _, _) => const NotificationScreen(),
                ),
              );
            },
          ),
          _buildDivider(),
          _buildSettingsTile(
            icon: Icons.shield_outlined,
            title: context.tr('privacy_security'),
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, _, _) => const HealthProfileDetailScreen(),
                ),
              );
            },
          ),
          _buildDivider(),
          _buildSettingsTile(
            icon: Icons.help_outline_rounded,
            title: context.tr('help_support'),
            onTap: () {
              HapticFeedback.selectionClick();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.isDarkMode
                      ? const Color(0xFF182E25)
                      : const Color(0xFFEBF7F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: context.isDarkMode
                        ? const Color(0xFF81C784)
                        : const Color(0xFF0B4632),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF15221D),
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
              ),
              if (trailingText != null) ...[
                Text(
                  subtitle,
                  style: const TextStyle(
                  trailingText,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Color(0xFF6E7E77),
                    fontSize: 13,
                    color: context.textSecondary,
                  ),
                ),
                const SizedBox(width: 4),
              ],
              Icon(
                Icons.chevron_right_rounded,
                color: context.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 4. Guest Sign-In Action Card
  Widget _buildAuthCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E6B45),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E6B45).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.heavyImpact();
            Navigator.of(context).pushAndRemoveUntil(
              PageRouteBuilder(pageBuilder: (_, _, _) => const SignInScreen()),
              (route) => false,
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.login_rounded, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text(
                  'Sign In / Register',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF6E7E77)),
        ),
      ),
    );
  }

  // 4. Logout Action Card
  Widget _buildLogoutCard() {
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            HapticFeedback.heavyImpact();
            await FirebaseService.signOut();
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                PageRouteBuilder(
                  pageBuilder: (_, _, _) => const SignInScreen(),
                ),
                (route) => false,
              );
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.isDarkMode
                        ? const Color(0xFF321E1E)
                        : const Color(0xFFFFEBEB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.logout_rounded,
                      color: Color(0xFFE74C3C),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  context.tr('logout'),
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE74C3C),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(height: 1, color: context.cardBorder),
    );
  }
}
