import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ServicesTab extends StatelessWidget {
  const ServicesTab({super.key});

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
          title: const Text(
            'CLINICAL SERVICES',
            style: TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: Color(0xFF15221D),
            ),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildServiceItem(
                title: 'Ruqyah Telehealth Consultations',
                description: '1-on-1 live session with qualified scholars.',
                icon: Icons.video_call_rounded,
                tag: 'Online & Digital',
              ),
              const SizedBox(height: 16),
              _buildServiceItem(
                title: 'Hijama Cupping Therapy',
                description: 'Sunnah points & clinical suction cupping.',
                icon: Icons.healing_rounded,
                tag: 'Chamber & Physical',
              ),
              const SizedBox(height: 16),
              _buildServiceItem(
                title: 'Acupuncture & Meridian Care',
                description: 'Pain relief & energy flow balancing.',
                icon: Icons.bubble_chart_rounded,
                tag: 'Clinical Therapy',
              ),
              const SizedBox(height: 16),
              _buildServiceItem(
                title: 'Interactive 3D Body Mapping',
                description: 'Explore treatment nodes and Sunnah points.',
                icon: Icons.threed_rotation_rounded,
                tag: 'Interactive Tool',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceItem({
    required String title,
    required String description,
    required IconData icon,
    required String tag,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEBF7F0),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF0B4632), size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tag,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E6B45),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF15221D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.5,
                    color: Color(0xFF6E7E77),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
