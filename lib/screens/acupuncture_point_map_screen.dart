// acupuncture_point_map_screen.dart
//
// Tap anywhere on the 3D body -> nearest known part is identified ->
// shown in a confirm card -> user confirms or dismisses.
//
// HOW THE TAP DETECTION WORKS -------------------------------------------
// model-viewer exposes `positionAndNormalFromPoint(x, y)`, a documented
// public method that raycasts a 2D pixel coordinate into the 3D point on
// the model's surface (same coordinate space as hotspot `data-position`
// values). We attach a plain `click` listener to the <model-viewer>
// element itself via `relatedJs`, call that method, and post the hit
// point back to Flutter over a JavascriptChannel. Flutter then finds
// whichever AnatomyPoint is closest to that 3D point.
//
// This means matching accuracy is entirely dependent on how well the
// placeholder `position` values below match your actual .glb's real
// proportions -- until those are tuned to your model, "nearest match"
// can pick the wrong region. Tune by trial: tap a spot, see what it
// resolves to, and nudge the relevant AnatomyPoint's position.
//
// KNOWN CAVEAT: if the `ModelViewer` widget from model_viewer_plus does
// a full webview reload whenever cameraOrbit/cameraTarget/innerHtml
// change (rather than patching the existing page), you'll see the model
// flash/reset on every zoom-in. If that happens, the more robust fix is
// to drop model_viewer_plus's high-level widget and drive a persistent
// webview_flutter WebViewController directly, calling
// `controller.runJavaScript(...)` to update model-viewer's properties
// in place without reloading the page.
// -------------------------------------------------------------------------

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
  final String? parentRegionId;
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

  List<double> get xyz =>
      position.split(' ').map((s) => double.parse(s)).toList();
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

  // How far (metres) a tap's raycast hit may be from a point before we
  // stop treating it as a match. Loosen/tighten once real coordinates
  // are tuned.
  static const _matchThreshold = 0.6;

  AnatomyLevel _level = AnatomyLevel.region;
  String? _activeRegionId;
  AnatomyPoint? _pendingPoint; // tapped, awaiting confirm
  AnatomyPoint? _selectedOrgan; // confirmed, showing full detail
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

  double _distance(List<double> a, List<double> b) {
    var sum = 0.0;
    for (var i = 0; i < 3; i++) {
      final d = a[i] - b[i];
      sum += d * d;
    }
    return sum; // squared distance is enough for comparison
  }

  // Called with a raw "hit:x,y,z" message from the model-viewer raycast.
  void _handleModelTap(String payload) {
    if (!payload.startsWith('hit:')) return;
    final coords = payload
        .substring(4)
        .split(',')
        .map((s) => double.tryParse(s) ?? 0.0)
        .toList();
    if (coords.length != 3) return;

    final candidates = _visibleHotspots;
    if (candidates.isEmpty) return;

    AnatomyPoint? nearest;
    var nearestDist = double.infinity;
    for (final pt in candidates) {
      final d = _distance(coords, pt.xyz);
      if (d < nearestDist) {
        nearestDist = d;
        nearest = pt;
      }
    }

    if (nearest == null || nearestDist > _matchThreshold * _matchThreshold) {
      // Tapped somewhere with no close-enough known part yet.
      return;
    }

    HapticFeedback.selectionClick();
    setState(() => _pendingPoint = nearest);
  }

  void _confirmPending() {
    final pt = _pendingPoint;
    if (pt == null) return;
    HapticFeedback.mediumImpact();

    final hasOrgans = _organsByRegion.containsKey(pt.id);
    if (pt.level == AnatomyLevel.region && hasOrgans) {
      setState(() {
        _activeRegionId = pt.id;
        _level = AnatomyLevel.organ;
        _cameraTarget = pt.position;
        _cameraOrbit = '0deg 75deg 0.9m';
        _pendingPoint = null;
      });
    } else {
      setState(() {
        _selectedOrgan = pt;
        _pendingPoint = null;
      });
    }
  }

  void _dismissPending() {
    setState(() => _pendingPoint = null);
  }

  void _resetToRegions() {
    HapticFeedback.selectionClick();
    setState(() {
      _level = AnatomyLevel.region;
      _activeRegionId = null;
      _selectedOrgan = null;
      _pendingPoint = null;
      _cameraOrbit = _defaultOrbit;
      _cameraTarget = _defaultTarget;
    });
  }

  static const String _tapRaycastJs = '''
    (function () {
      function setup() {
        var mv = document.querySelector('model-viewer');
        if (!mv) { return; }
        mv.addEventListener('click', function (event) {
          var rect = mv.getBoundingClientRect();
          var x = event.clientX - rect.left;
          var y = event.clientY - rect.top;
          if (typeof mv.positionAndNormalFromPoint !== 'function') { return; }
          var hit = mv.positionAndNormalFromPoint(x, y);
          if (hit && hit.position) {
            var p = hit.position;
            AnatomyChannel.postMessage(
              'hit:' + p.x.toFixed(3) + ',' + p.y.toFixed(3) + ',' + p.z.toFixed(3)
            );
          }
        });
      }
      if (document.readyState === 'complete') { setup(); }
      else { window.addEventListener('load', setup); }
    })();
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
            if (_activeRegionId != null && _selectedOrgan == null) {
              _resetToRegions();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        centerTitle: true,
        title: Text(
          _level == AnatomyLevel.region
              ? 'Tap where it hurts'
              : 'Tap the specific spot',
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
              backgroundColor: Colors.transparent,
              src: 'assets/models/body_full.glb',
              alt: 'Interactive human body model',
              autoRotate: false,
              cameraControls: true,
              disableZoom: false,
              cameraOrbit: _cameraOrbit,
              cameraTarget: _cameraTarget,
              relatedJs: _tapRaycastJs,
              javascriptChannels: {
                JavascriptChannel(
                  'AnatomyChannel',
                  onMessageReceived: (message) {
                    _handleModelTap(message.message);
                  },
                ),
              },
            ),
          ),
          if (_pendingPoint != null) _buildConfirmBar(_pendingPoint!),
          if (_selectedOrgan != null) _buildDetailCard(_selectedOrgan!),
        ],
      ),
    );
  }

  // Shown right after a tap resolves to a candidate part, before the
  // user commits to it.
  Widget _buildConfirmBar(AnatomyPoint pt) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.cardBorder, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Color(0xFFD49E35),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Is it your ${pt.label}?',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: context.textPrimary,
              ),
            ),
          ),
          TextButton(
            onPressed: _dismissPending,
            child: const Text('No'),
          ),
          const SizedBox(width: 4),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0B4632),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _confirmPending,
            child: const Text('Yes'),
          ),
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
                      pageBuilder: (_, __, ___) =>
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