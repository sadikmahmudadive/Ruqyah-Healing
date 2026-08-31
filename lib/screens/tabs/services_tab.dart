import 'package:flutter/material.dart';

class ServicesTab extends StatelessWidget {
  const ServicesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E13),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0E13),
        elevation: 0,
        title: const Text(
          'CLINICAL SERVICES',
          style: TextStyle(
            fontFamily: 'Cinzel',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: Colors.white,
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
        color: const Color(0xFF141A22).withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0B4632).withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF2ECC71), size: 26),
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
                    color: Color(0xFF2ECC71),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.5,
                    color: Colors.white.withValues(alpha: 0.65),
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
