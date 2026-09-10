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
      value: context.systemOverlayStyle,
      child: Scaffold(
        backgroundColor: context.pageBg,
        appBar: AppBar(
          backgroundColor: context.pageBg,
          elevation: 0,
          titleSpacing: 20,
          automaticallyImplyLeading: false,
          title: const Text(
            'PROFILE',
            style: TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: Color(0xFF15221D),
            ),
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
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFE2E8E5),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.settings_outlined,
                    color: Color(0xFF15221D),
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

                  final resolvedEmail = userModel?.email.isNotEmpty == true
                      ? userModel!.email
                      : (currentUser.email?.isNotEmpty == true
                          ? currentUser.email!
                          : (currentUser.phoneNumber ?? ''));

                  final sessionsCount =
                      userModel?.healthProfile.ruqyahAudioLogs.length.toString() ??
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
      ),
    );
  }

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
                  ),
                ),
              ),
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
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0B4632),
          ),
        ),

        const SizedBox(height: 2),

        Text(
          email,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: Color(0xFF6E7E77),
          ),
        ),
      ],
    );
  }

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
            label: context.tr('sessions_completed'),
            subtitle: 'Completed',
            subtitleColor: const Color(0xFF6E7E77),
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
              label: context.tr('health_index_label'),
              subtitle: 'State',
              subtitleColor: const Color(0xFF1E6B45),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildBentoCard(
            number: daysActive,
            label: context.tr('days_active'),
            subtitle: 'Streak',
            subtitleColor: const Color(0xFF6E7E77),
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
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF7F0).withValues(alpha: 0.60),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8E5).withValues(alpha: 0.80),
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          Text(
            number,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF15221D),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              color: Color(0xFF15221D),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10.5,
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
      child: Column(
        children: [
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
                  color: const Color(0xFFEBF7F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(icon, color: const Color(0xFF0B4632), size: 20),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0B4632),
                  ),
                ),
              ),
              if (trailingText != null) ...[
                Text(
                  trailingText,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Color(0xFF90A4AE),
                  ),
                ),
                const SizedBox(width: 4),
              ],
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF6E7E77),
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
              PageRouteBuilder(
                pageBuilder: (_, _, _) => const SignInScreen(),
              ),
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
        ),
      ),
    );
  }

  // 4. Logout Action Card
  Widget _buildLogoutCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
                    color: const Color(0xFFFFEBEB),
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
      child: Container(
        height: 1,
        color: const Color(0xFFE2E8E5).withValues(alpha: 0.80),
      ),
    );
  }
}
