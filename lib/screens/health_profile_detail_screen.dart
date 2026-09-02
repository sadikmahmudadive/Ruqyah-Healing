import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/acupuncture_icon.dart';
import '../widgets/global_bottom_navbar.dart';
import '../widgets/hijama_cupping_icon.dart';
import '../widgets/ruqyah_dua_icon.dart';
import 'main_navigation_shell.dart';

class HealthProfileDetailScreen extends StatefulWidget {
  const HealthProfileDetailScreen({super.key});

  @override
  State<HealthProfileDetailScreen> createState() =>
      _HealthProfileDetailScreenState();
}

class _HealthProfileDetailScreenState extends State<HealthProfileDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F6),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5F7F6),
          elevation: 0,
          titleSpacing: 8,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8E5), width: 1.0),
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
                  Icons.arrow_back_rounded,
                  color: Color(0xFF15221D),
                  size: 20,
                ),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B4632).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_user_outlined,
                  color: Color(0xFF0B4632),
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Health Profile',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF15221D),
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0, top: 8.0, bottom: 8.0),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E8E5), width: 1.0),
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
                  },
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Health Index Overview Card
              _buildHealthIndexOverviewCard(),

              const SizedBox(height: 20),

              // 2. Medical & Spiritual Wellness Logs Card
              _buildWellnessLogsCard(),

              const SizedBox(height: 24),

              // 3. Privacy & Controls Section Header
              const Text(
                'PRIVACY & CONTROLS',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: Color(0xFF90A4AE),
                ),
              ),

              const SizedBox(height: 10),

              // 4. Privacy & Controls Options Card
              _buildPrivacyControlsCard(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // Top Health Index Overview Card
  Widget _buildHealthIndexOverviewCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: HEALTH INDEX Score + Trend Line
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'HEALTH INDEX',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: Color(0xFF90A4AE),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          '78',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF15221D),
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEBF7F0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Good',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E6B45),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Trend Sparkline Curve Representation
                    SizedBox(
                      height: 24,
                      width: 100,
                      child: CustomPaint(
                        painter: _TrendLinePainter(),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Right Column: Breakdown Indicators
              Expanded(
                child: Column(
                  children: [
                    _buildMetricRow('Spiritual', 'Good', 0.85, const Color(0xFF0B4632)),
                    const SizedBox(height: 10),
                    _buildMetricRow('Sleep Quality', 'Good', 0.78, const Color(0xFF0B4632)),
                    const SizedBox(height: 10),
                    _buildMetricRow('Stress Level', 'Moderate', 0.55, const Color(0xFFE67E22)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Container(height: 1, color: const Color(0xFFE2E8E5)),
          const SizedBox(height: 12),

          // Footer Row
          Row(
            children: [
              Text(
                'Last updated: Today',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: const Color(0xFF90A4AE),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                },
                child: const Row(
                  children: [
                    Text(
                      'View full report',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0B4632),
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Color(0xFF0B4632),
                      size: 14,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(
    String label,
    String value,
    double progress,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11.5,
                color: Color(0xFF6E7E77),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFFE2E8E5),
            color: color,
            minHeight: 4,
          ),
        ),
      ],
    );
  }

  // Medical & Spiritual Wellness Logs Card
  Widget _buildWellnessLogsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          _buildLogTile(
            icon: Icons.show_chart_rounded,
            iconBg: const Color(0xFFEBF7F0),
            iconColor: const Color(0xFF0B4632),
            title: 'Medical History',
            badgeText: '2 records',
            badgeBg: const Color(0xFFEBF7F0),
            badgeColor: const Color(0xFF0B4632),
          ),
          _buildDivider(),
          _buildLogTile(
            icon: Icons.error_outline_rounded,
            iconBg: const Color(0xFFFFEBEB),
            iconColor: const Color(0xFFE74C3C),
            title: 'Allergies',
            badgeText: '1 allergy',
            badgeBg: const Color(0xFFFFEBEB),
            badgeColor: const Color(0xFFE74C3C),
          ),
          _buildDivider(),
          _buildLogTile(
            icon: Icons.notifications_none_rounded,
            iconBg: const Color(0xFFFFF3E8),
            iconColor: const Color(0xFFE67E22),
            title: 'Medications',
            badgeText: '2 active',
            badgeBg: const Color(0xFFFFF3E8),
            badgeColor: const Color(0xFFE67E22),
          ),
          _buildDivider(),
          _buildLogTile(
            icon: Icons.person_outline_rounded,
            iconBg: const Color(0xFFEBF7F0),
            iconColor: const Color(0xFF0B4632),
            title: 'Current Concerns',
            badgeText: 'Anxiety, Sleep',
            badgeBg: Colors.transparent,
            badgeColor: const Color(0xFF6E7E77),
          ),
          _buildDivider(),
          _buildLogTile(
            customIcon: const RuqyahDuaIcon(
              color: Color(0xFF0B4632),
              size: 20,
            ),
            iconBg: const Color(0xFFEBF7F0),
            iconColor: const Color(0xFF0B4632),
            title: 'Ruqyah Listening Log',
            badgeText: '12 sessions',
            badgeBg: const Color(0xFFEBF7F0),
            badgeColor: const Color(0xFF0B4632),
          ),
          _buildDivider(),
          _buildLogTile(
            customIcon: const HijamaCuppingIcon(
              color: Color(0xFFE67E22),
              size: 20,
            ),
            iconBg: const Color(0xFFFFF3E8),
            iconColor: const Color(0xFFE67E22),
            title: 'Hijama Session History',
            badgeText: '4 sessions',
            badgeBg: const Color(0xFFFFF3E8),
            badgeColor: const Color(0xFFE67E22),
          ),
          _buildDivider(),
          _buildLogTile(
            customIcon: const AcupunctureIcon(
              color: Color(0xFF2980B9),
              size: 20,
            ),
            iconBg: const Color(0xFFE6F7FF),
            iconColor: const Color(0xFF2980B9),
            title: 'Acupuncture Point Log',
            badgeText: '6 sessions',
            badgeBg: const Color(0xFFE6F7FF),
            badgeColor: const Color(0xFF2980B9),
          ),
          _buildDivider(),
          _buildLogTile(
            icon: Icons.calendar_today_outlined,
            iconBg: const Color(0xFFEBF7F0),
            iconColor: const Color(0xFF0B4632),
            title: 'Files & Documents',
            badgeText: '3 files',
            badgeBg: const Color(0xFFEBF7F0),
            badgeColor: const Color(0xFF0B4632),
          ),
        ],
      ),
    );
  }

  Widget _buildLogTile({
    IconData? icon,
    Widget? customIcon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String badgeText,
    required Color badgeBg,
    required Color badgeColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: customIcon ?? Icon(icon, color: iconColor, size: 20),
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
                    color: Color(0xFF15221D),
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: badgeColor,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFB0BEC5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Privacy & Controls Card
  Widget _buildPrivacyControlsCard() {
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
      child: Column(
        children: [
          _buildControlTile(
            icon: Icons.shield_outlined,
            title: 'Privacy Control',
            subtitle: 'Manage data access',
          ),
          _buildDivider(),
          _buildControlTile(
            icon: Icons.file_download_outlined,
            title: 'Export / Delete Data',
            subtitle: 'Download or delete',
          ),
        ],
      ),
    );
  }

  Widget _buildControlTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
        },
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
                child: const Center(
                  child: Icon(
                    Icons.shield_outlined,
                    color: Color(0xFF0B4632),
                    size: 20,
                  ),
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
                    color: Color(0xFF15221D),
                  ),
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: Color(0xFF6E7E77),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFB0BEC5),
                size: 20,
              ),
            ],
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

// Sparkline Trend Curve Painter
class _TrendLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0B4632)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, size.height * 0.70)
      ..lineTo(size.width * 0.25, size.height * 0.55)
      ..lineTo(size.width * 0.45, size.height * 0.65)
      ..lineTo(size.width * 0.65, size.height * 0.35)
      ..lineTo(size.width * 0.85, size.height * 0.40)
      ..lineTo(size.width, size.height * 0.15);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
