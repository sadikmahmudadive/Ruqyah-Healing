import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../theme/app_gradients.dart';
import '../theme/app_theme.dart';
import 'therapist_marketplace_screen.dart';

enum AnatomyLevel { region, organ }

class AnatomyPoint {
  final String id;
  final String label;
  final String position; // "x y z" in metres, model space
  final String normal; // "nx ny nz"
  final AnatomyLevel level;
  final String? parentRegionId; // null for regions
  final String about;
  final String commonCauses;
  final String evidence;
  final String safetyNotice;

  const AnatomyPoint({
    required this.id,
    required this.label,
    required this.position,
    required this.normal,
    required this.level,
    this.parentRegionId,
    required this.about,
    required this.commonCauses,
    required this.evidence,
    required this.safetyNotice,
  });
}

class AcupuncturePointMapScreen extends StatefulWidget {
  const AcupuncturePointMapScreen({super.key});

  @override
  State<AcupuncturePointMapScreen> createState() =>
      _AcupuncturePointMapScreenState();
}

class _AcupuncturePointMapScreenState
    extends State<AcupuncturePointMapScreen> {
  static const _defaultOrbit = '0deg 75deg 2.4m';
  static const _defaultTarget = '0m 0.9m 0m';

  AnatomyLevel _level = AnatomyLevel.region;
  String? _activeRegionId;
  AnatomyPoint? _selectedOrgan;
  String _cameraOrbit = _defaultOrbit;
  String _cameraTarget = _defaultTarget;

  final List<AnatomyPoint> _regions = const [
    AnatomyPoint(
      id: 'head',
      label: 'Head & Neck',
      position: '0 1.62 0.08',
      normal: '0 0 1',
      level: AnatomyLevel.region,
      about: 'Head, neck, and jaw.',
      commonCauses: 'Tension, migraine, sinus, TMJ.',
      evidence: 'General',
      safetyNotice: 'Sudden severe head pain warrants urgent care.',
    ),
    AnatomyPoint(
      id: 'chest',
      label: 'Chest',
      position: '0 1.32 0.14',
      normal: '0 0 1',
      level: AnatomyLevel.region,
      about: 'Ribcage, sternum, and thoracic organs.',
      commonCauses: 'Musculoskeletal strain, respiratory, cardiac.',
      evidence: 'General',
      safetyNotice:
          'Chest pain with shortness of breath or pressure needs emergency evaluation.',
    ),
    AnatomyPoint(
      id: 'abdomen',
      label: 'Abdomen',
      position: '0 1.02 0.14',
      normal: '0 0 1',
      level: AnatomyLevel.region,
      about: 'Stomach, liver, kidneys, and intestines.',
      commonCauses: 'Digestive, muscular, referred pain.',
      evidence: 'General',
      safetyNotice: 'Severe or worsening abdominal pain needs medical review.',
    ),
    AnatomyPoint(
      id: 'back',
      label: 'Back',
      position: '0 1.15 -0.14',
      normal: '0 0 -1',
      level: AnatomyLevel.region,
      about: 'Upper, mid, and lower back.',
      commonCauses: 'Posture, strain, disc-related.',
      evidence: 'General',
      safetyNotice: 'Consult a practitioner before manual therapy.',
    ),
    AnatomyPoint(
      id: 'arm_left',
      label: 'Left Arm',
      position: '-0.28 1.05 0.05',
      normal: '-1 0 0',
      level: AnatomyLevel.region,
      about: 'Shoulder to hand, left side.',
      commonCauses: 'Overuse, joint strain, nerve irritation.',
      evidence: 'General',
      safetyNotice: 'Numbness or weakness should be checked promptly.',
    ),
    AnatomyPoint(
      id: 'arm_right',
      label: 'Right Arm',
      position: '0.28 1.05 0.05',
      normal: '1 0 0',
      level: AnatomyLevel.region,
      about: 'Shoulder to hand, right side.',
      commonCauses: 'Overuse, joint strain, nerve irritation.',
      evidence: 'General',
      safetyNotice: 'Numbness or weakness should be checked promptly.',
    ),
    AnatomyPoint(
      id: 'leg_left',
      label: 'Left Leg',
      position: '-0.11 0.5 0.05',
      normal: '-1 0 0',
      level: AnatomyLevel.region,
      about: 'Hip to foot, left side.',
      commonCauses: 'Joint wear, muscular strain, sciatica.',
      evidence: 'General',
      safetyNotice:
          'Sudden swelling or inability to bear weight needs urgent care.',
    ),
    AnatomyPoint(
      id: 'leg_right',
      label: 'Right Leg',
      position: '0.11 0.5 0.05',
      normal: '1 0 0',
      level: AnatomyLevel.region,
      about: 'Hip to foot, right side.',
      commonCauses: 'Joint wear, muscular strain, sciatica.',
      evidence: 'General',
      safetyNotice:
          'Sudden swelling or inability to bear weight needs urgent care.',
    ),
  ];

  late final Map<String, List<AnatomyPoint>> _organsByRegion = {
    'chest': const [
      AnatomyPoint(
        id: 'heart',
        label: 'Heart',
        position: '-0.04 1.34 0.16',
        normal: '0 0 1',
        level: AnatomyLevel.organ,
        parentRegionId: 'chest',
        about: 'Cardiac region, left of sternum.',
        commonCauses: 'Cardiac, musculoskeletal, anxiety-related chest pain.',
        evidence: 'Consult required',
        safetyNotice:
            'Pressure, radiating pain, or shortness of breath: seek emergency care immediately.',
      ),
      AnatomyPoint(
        id: 'lungs',
        label: 'Lungs',
        position: '0.08 1.34 0.15',
        normal: '0 0 1',
        level: AnatomyLevel.organ,
        parentRegionId: 'chest',
        about: 'Respiratory region, either side of the sternum.',
        commonCauses: 'Respiratory infection, strain, pleuritic pain.',
        evidence: 'Consult required',
        safetyNotice: 'Sharp pain when breathing deeply should be evaluated.',
      ),
    ],
    'abdomen': const [
      AnatomyPoint(
        id: 'stomach',
        label: 'Stomach',
        position: '-0.03 1.06 0.15',
        normal: '0 0 1',
        level: AnatomyLevel.organ,
        parentRegionId: 'abdomen',
        about: 'Upper-left abdomen.',
        commonCauses: 'Indigestion, gastritis, ulcers.',
        evidence: 'General',
        safetyNotice: 'Persistent or severe pain needs medical review.',
      ),
      AnatomyPoint(
        id: 'liver',
        label: 'Liver',
        position: '0.1 1.08 0.15',
        normal: '0 0 1',
        level: AnatomyLevel.organ,
        parentRegionId: 'abdomen',
        about: 'Upper-right abdomen.',
        commonCauses: 'Referred pain, inflammation.',
        evidence: 'Consult required',
        safetyNotice: 'Right-upper pain with jaundice needs urgent evaluation.',
      ),
      AnatomyPoint(
        id: 'kidneys',
        label: 'Kidneys',
        position: '0.0 1.0 -0.1',
        normal: '0 0 -1',
        level: AnatomyLevel.organ,
        parentRegionId: 'abdomen',
        about: 'Flank region, either side of the spine.',
        commonCauses: 'Kidney stones, infection, referred back pain.',
        evidence: 'Consult required',
        safetyNotice:
            'Sudden severe flank pain needs prompt medical attention.',
      ),
    ],
  };

  List<AnatomyPoint> get _visibleHotspots {
    if (_level == AnatomyLevel.region) return _regions;
    return _organsByRegion[_activeRegionId] ?? const [];
  }

  void _handleHotspotTap(String payload) {
    final parts = payload.split(':');
    if (parts.length != 2) return;
    final kind = parts[0];
    final id = parts[1];

    HapticFeedback.selectionClick();

    if (kind == 'region') {
      final region = _regions.firstWhere((r) => r.id == id);
      final hasOrgans = _organsByRegion.containsKey(id);
      setState(() {
        _activeRegionId = id;
        _selectedOrgan = region;
        if (hasOrgans) {
          _level = AnatomyLevel.organ;
        }
        _cameraTarget = region.position;
        _cameraOrbit = '0deg 75deg 0.9m';
      });
    } else if (kind == 'organ') {
      final organs = _organsByRegion[_activeRegionId] ?? const [];
      final organ = organs.firstWhere((o) => o.id == id);
      setState(() => _selectedOrgan = organ);
    }
  }

  void _resetToRegions() {
    HapticFeedback.selectionClick();
    setState(() {
      _level = AnatomyLevel.region;
      _activeRegionId = null;
      _selectedOrgan = null;
      _cameraOrbit = _defaultOrbit;
      _cameraTarget = _defaultTarget;
    });
  }

  String _buildHotspotsHtml() {
    final buffer = StringBuffer();
    for (final pt in _visibleHotspots) {
      final kind = pt.level == AnatomyLevel.region ? 'region' : 'organ';
      final isActive = pt.id == _activeRegionId || pt == _selectedOrgan;
      buffer.write('''
        <button slot="hotspot-${pt.id}" class="anatomy-hotspot${isActive ? ' active' : ''}"
          data-position="${pt.position}" data-normal="${pt.normal}"
          onclick="AnatomyChannel.postMessage('$kind:${pt.id}')">
          <span class="label-badge">${pt.label}</span>
          <span class="dot"></span>
        </button>
      ''');
    }
    return buffer.toString();
  }

  String get _hotspotCss => '''
    .anatomy-hotspot {
      border: none;
      background: transparent;
      padding: 0;
      cursor: pointer;
      pointer-events: auto;
      display: flex;
      flex-direction: column;
      align-items: center;
      opacity: 0;
      transition: opacity 0.25s ease, transform 0.25s ease;
    }
    .anatomy-hotspot.active {
      opacity: 1;
    }
    .anatomy-hotspot .label-badge {
      background: #15221D;
      color: #FFFFFF;
      font-family: 'PlusJakartaSans', sans-serif;
      font-size: 11px;
      font-weight: 700;
      padding: 3px 8px;
      border-radius: 8px;
      margin-bottom: 4px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.35);
      white-space: nowrap;
      pointer-events: none;
    }
    .anatomy-hotspot .dot {
      display: block;
      width: 22px;
      height: 22px;
      border-radius: 50%;
      background: #0B4632;
      border: 3px solid #D49E35;
      box-shadow: 0 0 14px rgba(212, 158, 53, 0.85);
      transform: scale(0.9);
      transition: transform 0.2s ease;
    }
    .anatomy-hotspot.active .dot {
      transform: scale(1.15);
    }
  ''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: AppBar(
        backgroundColor: context.pageBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: context.textPrimary),
          onPressed: () {
            if (_level == AnatomyLevel.organ && _selectedOrgan == null) {
              _resetToRegions();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        centerTitle: true,
        title: Text(
          _level == AnatomyLevel.region
              ? 'Where does it hurt?'
              : 'Select an area',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: context.textPrimary,
          ),
        ),
        actions: [
          if (_activeRegionId != null)
            TextButton(
              onPressed: _resetToRegions,
              child: const Text('Reset view'),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ModelViewer(
              key: ValueKey('$_level-$_activeRegionId'),
              backgroundColor: Colors.transparent,
              src: 'assets/models/body_full.glb',
              alt: 'Interactive human body model',
              autoRotate: false,
              cameraControls: true,
              disableZoom: false,
              cameraOrbit: _cameraOrbit,
              cameraTarget: _cameraTarget,
              minHotspotOpacity: 0,
              maxHotspotOpacity: 1,
              innerModelViewerHtml: _buildHotspotsHtml(),
              relatedCss: _hotspotCss,
              javascriptChannels: {
                JavascriptChannel(
                  'AnatomyChannel',
                  onMessageReceived: (message) {
                    _handleHotspotTap(message.message);
                  },
                ),
              },
            ),
          ),
          if (_selectedOrgan != null) _buildDetailCard(_selectedOrgan!),
        ],
      ),
    );
  }

  Widget _buildDetailCard(AnatomyPoint pt) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.cardBorder, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  pt.label,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: context.isDarkMode
                        ? const Color(0xFF81C784)
                        : const Color(0xFF0B4632),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close_rounded, color: context.textSecondary),
                onPressed: () => setState(() => _selectedOrgan = null),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            pt.about,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.5,
              color: context.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Common causes: ${pt.commonCauses}',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.5,
              color: context.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.isDarkMode
                  ? const Color(0xFF2E2412)
                  : const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFD49E35).withValues(alpha: 0.30),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Color(0xFFD49E35), size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    pt.safetyNotice,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11.5,
                      color: context.isDarkMode
                          ? const Color(0xFFE5A93C)
                          : const Color(0xFFB78103),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              gradient: AppGradients.greenButtonGradient,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  HapticFeedback.heavyImpact();
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (_, _, _) =>
                          const TherapistMarketplaceScreen(),
                    ),
                  );
                },
                child: const Center(
                  child: Text(
                    'Consult a Practitioner',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
