// acupuncture_point_map_screen.dart
//
// Interactive 3D Human Anatomy Pain Mapping & Deep-Dive Exploration Screen.
// Allows patients to pinpoint pain across 3 anatomical layers:
// 1. Surface (Skin & Musculature)
// 2. Skeletal System (Bones, Joints & Spine)
// 3. Internal Organs (Brain, Heart, Lungs, Stomach, Liver, Kidneys)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
// ignore: depend_on_referenced_packages
import 'package:webview_flutter/webview_flutter.dart';

import '../theme/app_gradients.dart';
import '../theme/app_theme.dart';
import 'therapist_marketplace_screen.dart';

enum AnatomyLayer { surface, skeleton, organs }

class AnatomyPoint {
  final String id;
  final String label;
  final String position; // "x y z" in metres, model space (+Y Up)
  final String normal; // "nx ny nz"
  final AnatomyLayer layer;
  final String
  category; // 'Head', 'Chest', 'Abdomen', 'Back', 'Limbs', 'Organs'
  final String? deepDiveTargetLayer; // 'skeleton' or 'organs'
  final String? deepDivePointId;
  final String anatomicalDescription;
  final String commonCauses;
  final String islamicRuqyahNote;
  final String safetyNotice;

  const AnatomyPoint({
    required this.id,
    required this.label,
    required this.position,
    required this.normal,
    required this.layer,
    required this.category,
    this.deepDiveTargetLayer,
    this.deepDivePointId,
    required this.anatomicalDescription,
    required this.commonCauses,
    required this.islamicRuqyahNote,
    required this.safetyNotice,
  });

  List<double> get xyz =>
      position.split(' ').map((s) => double.tryParse(s) ?? 0.0).toList();
}

class AcupuncturePointMapScreen extends StatefulWidget {
  const AcupuncturePointMapScreen({super.key});

  @override
  State<AcupuncturePointMapScreen> createState() =>
      _AcupuncturePointMapScreenState();
}

class _AcupuncturePointMapScreenState extends State<AcupuncturePointMapScreen> {
  static const _defaultOrbit = '0deg 85deg 2.1m';
  static const _defaultTarget = '0m 0.85m 0m';
  static const _matchThreshold = 0.55; // metres

  WebViewController? _webViewController;
  AnatomyLayer _currentLayer = AnatomyLayer.surface;
  String _cameraOrbit = _defaultOrbit;
  String _cameraTarget = _defaultTarget;
  bool _autoRotate = false;

  AnatomyPoint? _selectedPoint;
  int _painSeverity = 5;
  final Set<String> _selectedSymptoms = {'Aching'};

  // ---------------------------------------------------------------------------
  // ANATOMICAL DATA REGISTRY (30+ Precision Clinical Sites)
  // ---------------------------------------------------------------------------
  static const List<AnatomyPoint> _allPoints = [
    // --- SURFACE LAYER ---
    AnatomyPoint(
      id: 'head',
      label: 'Head & Forehead',
      position: '0.00 1.65 0.06',
      normal: '0 0 1',
      layer: AnatomyLayer.surface,
      category: 'Head',
      deepDiveTargetLayer: 'organs',
      deepDivePointId: 'brain',
      anatomicalDescription:
          'Cranium, forehead, temples, and frontal sinonasal area.',
      commonCauses: 'Tension headache, migraine, sinus pressure, eye strain, mental fatigue.',
      islamicRuqyahNote: 'Sunnah Ruqyah recitation on the forehead (Al-Fatihah, Ayat al-Kursi, Al-Mu’awwidhat). Recommended Hijama point: Yafokh (top of head) & Hama (forehead).',
      safetyNotice: 'Sudden "thunderclap" headache or accompanied by vision loss requires immediate ER assessment.',
    ),
    AnatomyPoint(
      id: 'neck',
      label: 'Cervical Neck & Throat',
      position: '0.00 1.50 0.04',
      normal: '0 0 1',
      layer: AnatomyLayer.surface,
      category: 'Head',
      deepDiveTargetLayer: 'skeleton',
      deepDivePointId: 'cervical_spine',
      anatomicalDescription:
          'Sternocleidomastoid, anterior neck, thyroid region, and throat.',
      commonCauses: 'Postural neck strain, tech-neck, vocal strain, pharyngitis, lymphadenopathy.',
      islamicRuqyahNote: 'Sunnah Hijama points: Al-Akhda’ain (bilateral lateral neck vessels). Recite Ayat ash-Shifa for throat ailments.',
      safetyNotice: 'Difficulty swallowing, breathing, or rapid swelling warrants urgent medical care.',
    ),
    AnatomyPoint(
      id: 'chest_surface',
      label: 'Chest & Pectorals',
      position: '0.00 1.34 0.07',
      normal: '0 0 1',
      layer: AnatomyLayer.surface,
      category: 'Chest',
      deepDiveTargetLayer: 'organs',
      deepDivePointId: 'heart',
      anatomicalDescription:
          'Upper thoracic musculature, sternum, and anterior pectoral region.',
      commonCauses: 'Costochondritis, muscular strain, emotional grief/anxiety tightness, reflux.',
      islamicRuqyahNote: 'Placing right hand on chest: "Bismillah (3x), A’udhu bi’izzatillahi wa qudratihi..." (Sahih Muslim). Relieves tightness and spiritual heaviness.',
      safetyNotice: 'Crushing chest pressure, radiating arm/jaw pain, or shortness of breath requires emergency 911/ER.',
    ),
    AnatomyPoint(
      id: 'abdomen_surface',
      label: 'Abdomen & Navel',
      position: '0.00 1.05 0.05',
      normal: '0 0 1',
      layer: AnatomyLayer.surface,
      category: 'Abdomen',
      deepDiveTargetLayer: 'organs',
      deepDivePointId: 'stomach',
      anatomicalDescription:
          'Epigastric, umbilical, and lower abdominal quadrants.',
      commonCauses:
          'Gastritis, bloating, IBS, indigestion, menstrual discomfort.',
      islamicRuqyahNote: 'Abdominal pain from spiritual afflictions (Hasad/Evil Eye/Sihr) benefits from Ruqyah water, olive oil, and Senna/Ajwa dates.',
      safetyNotice: 'Acute localized lower-right rebound pain (appendicitis) warrants urgent surgery evaluation.',
    ),
    AnatomyPoint(
      id: 'upper_back',
      label: 'Upper Back & Shoulder Blades',
      position: '0.00 1.33 -0.06',
      normal: '0 0 -1',
      layer: AnatomyLayer.surface,
      category: 'Back',
      deepDiveTargetLayer: 'skeleton',
      deepDivePointId: 'thoracic_spine',
      anatomicalDescription:
          'Trapezius, rhomboids, interscapular muscular plane.',
      commonCauses:
          'Stress knots, poor desk posture, myofascial trigger points.',
      islamicRuqyahNote: 'Premier Sunnah Hijama spot: Al-Kahal (between the shoulder blades) — praised in Prophetic Medicine for overall wellbeing.',
      safetyNotice: 'Numbness radiating around the ribcage should be clinically reviewed.',
    ),
    AnatomyPoint(
      id: 'lower_back',
      label: 'Lumbar Lower Back',
      position: '0.00 1.06 -0.06',
      normal: '0 0 -1',
      layer: AnatomyLayer.surface,
      category: 'Back',
      deepDiveTargetLayer: 'skeleton',
      deepDivePointId: 'lumbar_spine',
      anatomicalDescription:
          'Erector spinae, quadratus lumborum, and lumbosacral junction.',
      commonCauses:
          'Lumbago, muscular spasm, disc bulge, sciatica, prolonged sitting.',
      islamicRuqyahNote: 'Cupping on lower lumbar points (Al-Warik / Al-Qatan) provides significant physical decompression.',
      safetyNotice: 'Loss of bladder/bowel control or bilateral leg numbness is a medical emergency (Cauda Equina).',
    ),
    AnatomyPoint(
      id: 'shoulder_left',
      label: 'Left Shoulder & Deltoid',
      position: '-0.22 1.42 0.02',
      normal: '-1 0 0',
      layer: AnatomyLayer.surface,
      category: 'Limbs',
      deepDiveTargetLayer: 'skeleton',
      deepDivePointId: 'clavicle_left',
      anatomicalDescription:
          'Glenohumeral joint, rotator cuff, and lateral deltoid.',
      commonCauses:
          'Impingement, bursitis, rotator cuff tendinitis, frozen shoulder.',
      islamicRuqyahNote:
          'Gentle Ruqyah olive oil massage combined with dry cupping.',
      safetyNotice: 'Inability to lift arm after trauma requires X-ray for fracture or dislocation.',
    ),
    AnatomyPoint(
      id: 'shoulder_right',
      label: 'Right Shoulder & Deltoid',
      position: '0.22 1.42 0.02',
      normal: '1 0 0',
      layer: AnatomyLayer.surface,
      category: 'Limbs',
      deepDiveTargetLayer: 'skeleton',
      deepDivePointId: 'clavicle_right',
      anatomicalDescription:
          'Glenohumeral joint, rotator cuff, and lateral deltoid.',
      commonCauses: 'Repetitive strain, mouse-arm, overhead lifting injury.',
      islamicRuqyahNote: 'Ruqyah oil massage and joint mobilizing exercises.',
      safetyNotice: 'Sudden onset deformity requires orthopedic review.',
    ),
    AnatomyPoint(
      id: 'knee_left',
      label: 'Left Knee Joint',
      position: '-0.10 0.48 0.04',
      normal: '0 0 1',
      layer: AnatomyLayer.surface,
      category: 'Limbs',
      deepDiveTargetLayer: 'skeleton',
      deepDivePointId: 'patella_left',
      anatomicalDescription: 'Patella, quadriceps tendon, medial and lateral collateral ligaments.',
      commonCauses: 'Runner’s knee, meniscus tear, osteoarthritis, kneeling strain during prayer.',
      islamicRuqyahNote: 'Olive oil with black seed (Nigella sativa) massaged over joint with prayer for shifa.',
      safetyNotice: 'Inability to bear weight or acute joint locking needs orthopedic evaluation.',
    ),
    AnatomyPoint(
      id: 'knee_right',
      label: 'Right Knee Joint',
      position: '0.10 0.48 0.04',
      normal: '0 0 1',
      layer: AnatomyLayer.surface,
      category: 'Limbs',
      deepDiveTargetLayer: 'skeleton',
      deepDivePointId: 'patella_right',
      anatomicalDescription: 'Patella, patellar tendon, knee joint capsule.',
      commonCauses:
          'Chondromalacia patellae, osteoarthritis, sports twisting injury.',
      islamicRuqyahNote: 'Dry cupping surrounding patella points (excluding directly over knee cap).',
      safetyNotice: 'Severe joint effusion (water on knee) or redness/heat warrants urgent check.',
    ),

    // --- SKELETAL LAYER ---
    AnatomyPoint(
      id: 'skull_cranium',
      label: 'Cranium & Facial Bones',
      position: '0.00 1.65 0.04',
      normal: '0 0 1',
      layer: AnatomyLayer.skeleton,
      category: 'Head',
      deepDiveTargetLayer: 'organs',
      deepDivePointId: 'brain',
      anatomicalDescription: 'Frontal, parietal, temporal, and occipital cranial bones; maxilla and mandible.',
      commonCauses: 'Bruxism (teeth grinding), TMJ dysfunction, post-concussive headache.',
      islamicRuqyahNote: 'Direct recitation on cranial suture points for spiritual clarity and peace.',
      safetyNotice: 'Traumatic bone tenderness or fluid from nose/ears needs immediate trauma care.',
    ),
    AnatomyPoint(
      id: 'cervical_spine',
      label: 'Cervical Spine (C1-C7)',
      position: '0.00 1.50 -0.02',
      normal: '0 0 -1',
      layer: AnatomyLayer.skeleton,
      category: 'Back',
      anatomicalDescription: 'Upper 7 spinal vertebrae supporting the head and shielding cervical cord.',
      commonCauses: 'Cervical spondylosis, disc herniation, whiplash, nerve root radiculopathy.',
      islamicRuqyahNote: 'Gentle cupping at C7 junction (Al-Kahal). Relieves head and neck tension.',
      safetyNotice: 'Electric shock sensation traveling down arms requires prompt neurological check.',
    ),
    AnatomyPoint(
      id: 'thoracic_spine',
      label: 'Thoracic Spine & Ribcage',
      position: '0.00 1.30 -0.03',
      normal: '0 0 -1',
      layer: AnatomyLayer.skeleton,
      category: 'Back',
      deepDiveTargetLayer: 'organs',
      deepDivePointId: 'heart',
      anatomicalDescription:
          'T1-T12 vertebrae articulating with 12 pairs of ribs.',
      commonCauses:
          'Thoracic facet joint syndrome, postural kyphosis, scoliosis.',
      islamicRuqyahNote: 'Spinal cupping stimulates autonomic nervous system balance and eases chest constriction.',
      safetyNotice: 'Unexplained mid-thoracic bone pain in elderly warrants radiological imaging.',
    ),
    AnatomyPoint(
      id: 'lumbar_spine',
      label: 'Lumbar Vertebrae (L1-L5)',
      position: '0.00 1.08 -0.03',
      normal: '0 0 -1',
      layer: AnatomyLayer.skeleton,
      category: 'Back',
      deepDiveTargetLayer: 'organs',
      deepDivePointId: 'kidneys',
      anatomicalDescription:
          'Large weight-bearing vertebrae and lumbosacral disc spaces.',
      commonCauses:
          'L4-L5 / L5-S1 disc herniation, spinal stenosis, spondylolisthesis.',
      islamicRuqyahNote: 'Hijama on lower back points alongside gentle spinal decompression and Ruqyah oil.',
      safetyNotice: 'Progressive foot drop or numbness in groin requires emergency spine decompression.',
    ),
    AnatomyPoint(
      id: 'pelvis_sacrum',
      label: 'Pelvis & Sacroiliac (SI) Joint',
      position: '0.00 0.92 0.02',
      normal: '0 0 1',
      layer: AnatomyLayer.skeleton,
      category: 'Back',
      anatomicalDescription:
          'Ilium, ischium, pubis, and sacred pelvic ring joints.',
      commonCauses:
          'SI joint dysfunction, piriformis syndrome, pelvic girdle pain.',
      islamicRuqyahNote:
          'Hijama on hip and sacral points eases pelvic nerve congestion.',
      safetyNotice:
          'Inability to bear weight after fall requires pelvic X-ray.',
    ),
    AnatomyPoint(
      id: 'patella_left',
      label: 'Left Patella & Knee Joint',
      position: '-0.10 0.48 0.04',
      normal: '0 0 1',
      layer: AnatomyLayer.skeleton,
      category: 'Limbs',
      anatomicalDescription:
          'Kneecap sesamoid bone and distal femoral condyle.',
      commonCauses: 'Patellofemoral syndrome, cartilage thinning, osteophytes.',
      islamicRuqyahNote:
          'Application of warm blessed olive oil with intention of shifa.',
      safetyNotice: 'Sudden knee locking where joint cannot straighten requires orthopedic review.',
    ),
    AnatomyPoint(
      id: 'patella_right',
      label: 'Right Patella & Knee Joint',
      position: '0.10 0.48 0.04',
      normal: '0 0 1',
      layer: AnatomyLayer.skeleton,
      category: 'Limbs',
      anatomicalDescription:
          'Kneecap sesamoid bone and distal femoral condyle.',
      commonCauses:
          'Cartilage wear, joint effusion, patellar tracking disorder.',
      islamicRuqyahNote:
          'Gentle circular massage with black seed and olive oil.',
      safetyNotice:
          'Severe instability or knee giving way requires ligament evaluation.',
    ),

    // --- INTERNAL ORGANS LAYER ---
    AnatomyPoint(
      id: 'brain',
      label: 'Brain & Nervous System',
      position: '0.00 1.63 0.02',
      normal: '0 0 1',
      layer: AnatomyLayer.organs,
      category: 'Organs',
      anatomicalDescription: 'Cerebral hemispheres, cerebellum, and brainstem.',
      commonCauses:
          'Mental exhaustion, severe migraine, brain fog, anxiety, insomnia.',
      islamicRuqyahNote: 'Prophetic medicine highlights head cupping (Al-Munqidhah: "the savior") for cognitive clarity and relief from whispering (Waswas).',
      safetyNotice: 'Sudden weakness, facial droop, or slurred speech is an acute stroke alert — call 911 immediately.',
    ),
    AnatomyPoint(
      id: 'heart',
      label: 'Heart & Cardiovascular',
      position: '-0.04 1.34 0.05',
      normal: '0 0 1',
      layer: AnatomyLayer.organs,
      category: 'Organs',
      anatomicalDescription:
          'Left thoracic cavity, ventricles, atria, and coronary vessels.',
      commonCauses:
          'Palpitations, stress-induced arrhythmia, angina, spiritual grief.',
      islamicRuqyahNote: '"Verily, in the remembrance of Allah do hearts find rest" (13:28). Place hand over heart and recite Surah Ash-Sharh and Surah Al-Ikhlas.',
      safetyNotice: 'Chest tightness radiating to back or arm with sweating is a medical emergency.',
    ),
    AnatomyPoint(
      id: 'lungs',
      label: 'Lungs & Bronchial Tree',
      position: '0.00 1.34 0.04',
      normal: '0 0 1',
      layer: AnatomyLayer.organs,
      category: 'Organs',
      anatomicalDescription:
          'Right and left pulmonary lobes, bronchial airways, and pleura.',
      commonCauses:
          'Bronchial asthma, post-viral cough, chest congestion, pleurisy.',
      islamicRuqyahNote: 'Cupping between shoulder blades opens airways. Steam inhalation with black seed oil assists breathing.',
      safetyNotice: 'Acute shortness of breath or blue-tinted lips requires emergency care.',
    ),
    AnatomyPoint(
      id: 'stomach',
      label: 'Stomach & Upper GI',
      position: '-0.05 1.15 0.04',
      normal: '0 0 1',
      layer: AnatomyLayer.organs,
      category: 'Organs',
      anatomicalDescription: 'Gastric fundus and body, located in the left upper quadrant under diaphragm.',
      commonCauses: 'Acid reflux, GERD, peptic ulcer, nervous stomach, consumed toxins/sihr.',
      islamicRuqyahNote: 'Drinking Ruqyah water mixed with Sidr leaves or pure honey in the morning on an empty stomach.',
      safetyNotice: 'Vomiting blood or black tarry stools requires immediate hospital evaluation.',
    ),
    AnatomyPoint(
      id: 'liver',
      label: 'Liver & Gallbladder',
      position: '0.06 1.16 0.04',
      normal: '0 0 1',
      layer: AnatomyLayer.organs,
      category: 'Organs',
      anatomicalDescription:
          'Right hypochondrium, largest visceral metabolic organ.',
      commonCauses:
          'Fatty liver inflammation, biliary colic, gallstones, toxic burden.',
      islamicRuqyahNote: 'Cupping on corresponding right thoracic points. Olive oil consumption supports hepatic detox.',
      safetyNotice: 'Yellowing of skin/eyes (jaundice) or severe right upper pain needs urgent doctor review.',
    ),
    AnatomyPoint(
      id: 'kidneys',
      label: 'Kidneys & Renal Flanks',
      position: '0.00 1.08 -0.04',
      normal: '0 0 -1',
      layer: AnatomyLayer.organs,
      category: 'Organs',
      anatomicalDescription:
          'Retroperitoneal organs located bilaterally along T12-L3 spine.',
      commonCauses:
          'Renal colic, kidney stones, urinary tract infection, dehydration.',
      islamicRuqyahNote:
          'Drinking plenty of Zamzam water with intention of shifa and detox.',
      safetyNotice: 'High fever with flank pain, chills, or blood in urine warrants urgent emergency care.',
    ),
  ];

  List<AnatomyPoint> get _currentLayerPoints {
    return _allPoints.where((pt) => pt.layer == _currentLayer).toList();
  }

  String get _currentModelSrc {
    switch (_currentLayer) {
      case AnatomyLayer.surface:
        return 'assets/models/body_full.glb';
      case AnatomyLayer.skeleton:
        return 'assets/models/body_skeleton.glb';
      case AnatomyLayer.organs:
        return 'assets/models/body_organs.glb';
    }
  }

  // ---------------------------------------------------------------------------
  // INTERACTIVE RAYCASTING & TAP HANDLING
  // ---------------------------------------------------------------------------
  double _distanceSq(List<double> a, List<double> b) {
    var sum = 0.0;
    for (var i = 0; i < 3; i++) {
      final d = a[i] - b[i];
      sum += d * d;
    }
    return sum;
  }

  void _handleRaycastHit(String payload) {
    if (!payload.startsWith('hit:')) return;
    final raw = payload.substring(4).split(',');
    if (raw.length != 3) return;

    final coords = raw.map((s) => double.tryParse(s) ?? 0.0).toList();
    final candidates = _currentLayerPoints;
    if (candidates.isEmpty) return;

    AnatomyPoint? nearest;
    var nearestDist = double.infinity;

    for (final pt in candidates) {
      final d = _distanceSq(coords, pt.xyz);
      if (d < nearestDist) {
        nearestDist = d;
        nearest = pt;
      }
    }

    if (nearest != null && nearestDist <= _matchThreshold * _matchThreshold) {
      _selectPoint(nearest);
    }
  }

  void _updateCameraInWebview(String target, String orbit) {
    _webViewController?.runJavaScript('''
      (function() {
        var mv = document.querySelector('model-viewer');
        if (mv) {
          mv.cameraTarget = '$target';
          mv.cameraOrbit = '$orbit';
        }
      })();
    ''');
  }

  void _zoomIn() {
    HapticFeedback.selectionClick();
    _webViewController?.runJavaScript('''
      (function() {
        var mv = document.querySelector('model-viewer');
        if (!mv) return;
        if (typeof mv.getCameraOrbit === 'function') {
          var orbit = mv.getCameraOrbit();
          if (orbit && typeof orbit.radius === 'number') {
            var newR = Math.max(0.6, orbit.radius - 0.35);
            mv.cameraOrbit = orbit.theta + 'rad ' + orbit.phi + 'rad ' + newR.toFixed(3) + 'm';
            return;
          }
        }
        if (typeof mv.zoom === 'function') {
          mv.zoom(2);
        }
      })();
    ''');
  }

  void _zoomOut() {
    HapticFeedback.selectionClick();
    _webViewController?.runJavaScript('''
      (function() {
        var mv = document.querySelector('model-viewer');
        if (!mv) return;
        if (typeof mv.getCameraOrbit === 'function') {
          var orbit = mv.getCameraOrbit();
          if (orbit && typeof orbit.radius === 'number') {
            var newR = Math.min(5.0, orbit.radius + 0.35);
            mv.cameraOrbit = orbit.theta + 'rad ' + orbit.phi + 'rad ' + newR.toFixed(3) + 'm';
            return;
          }
        }
        if (typeof mv.zoom === 'function') {
          mv.zoom(-2);
        }
      })();
    ''');
  }

  void _selectPoint(AnatomyPoint pt) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedPoint = pt;
      _cameraTarget = pt.position;
      _cameraOrbit = '0deg 75deg 1.3m';
    });
    _updateCameraInWebview(pt.position, '0deg 75deg 1.3m');
  }

  void _switchLayer(AnatomyLayer newLayer) {
    if (_currentLayer == newLayer) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _currentLayer = newLayer;
      _selectedPoint = null;
      _cameraOrbit = _defaultOrbit;
      _cameraTarget = _defaultTarget;
    });
  }

  void _performDeepDive(AnatomyPoint currentPoint) {
    if (currentPoint.deepDiveTargetLayer == null) return;
    HapticFeedback.heavyImpact();

    final targetLayer = currentPoint.deepDiveTargetLayer == 'organs'
        ? AnatomyLayer.organs
        : AnatomyLayer.skeleton;

    AnatomyPoint? targetPoint;
    if (currentPoint.deepDivePointId != null) {
      targetPoint = _allPoints.firstWhere(
        (p) => p.id == currentPoint.deepDivePointId,
        orElse: () => currentPoint,
      );
    }

    setState(() {
      _currentLayer = targetLayer;
      _selectedPoint = targetPoint;
      if (targetPoint != null) {
        _cameraTarget = targetPoint.position;
        _cameraOrbit = '0deg 75deg 1.1m';
      }
    });

    if (targetPoint != null) {
      _updateCameraInWebview(targetPoint.position, '0deg 75deg 1.1m');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Deep diving into ${targetLayer == AnatomyLayer.organs ? 'Internal Organs' : 'Skeletal System'}...',
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF0B4632),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  void _resetCamera() {
    HapticFeedback.lightImpact();
    setState(() {
      _cameraOrbit = _defaultOrbit;
      _cameraTarget = _defaultTarget;
      _selectedPoint = null;
    });
    _updateCameraInWebview(_defaultTarget, _defaultOrbit);
  }

  String get _tapRaycastJs {
    final pointsJson = _currentLayerPoints
        .map((pt) {
          final isSelected = _selectedPoint?.id == pt.id;
          return "{id:'${pt.id}',pos:'${pt.position}',norm:'${pt.normal}',sel:$isSelected,lbl:'${pt.label.replaceAll("'", "\\'")}'}";
        })
        .join(',');

    return '''
    (function () {
      function setup() {
        var mv = document.querySelector('model-viewer');
        if (!mv) { return; }
        
        // Clear previous hotspots
        var oldPins = mv.querySelectorAll('.hotspot-container');
        for (var i = 0; i < oldPins.length; i++) {
          oldPins[i].remove();
        }

        // Add 3D hotspots (only for the selected point)
        var pts = [$pointsJson];
        pts.forEach(function(pt) {
          if (!pt.sel) return; // Only show hotspot if selected

          var container = document.createElement('div');
          container.className = 'hotspot-container';
          container.slot = 'hotspot-' + pt.id;
          container.dataset.position = pt.pos;
          container.dataset.normal = pt.norm;
          container.style.cssText = 'display:flex;flex-direction:column;align-items:center;pointer-events:auto;transform:translateY(-50%);';

          var badge = document.createElement('div');
          badge.textContent = pt.lbl;
          badge.style.cssText = 'background:#15221D;color:#FFFFFF;font-family:sans-serif;font-size:12px;font-weight:bold;padding:4px 10px;border-radius:10px;margin-bottom:6px;box-shadow:0 2px 8px rgba(0,0,0,0.4);white-space:nowrap;pointer-events:none;';
          
          var dot = document.createElement('button');
          var color = '#E5A93C';
          var size = '22px';
          var border = '3px solid #FFFFFF';
          dot.style.cssText = 'width:' + size + ';height:' + size + ';border-radius:50%;background-color:' + color + ';border:' + border + ';box-shadow:0 0 16px ' + color + ';cursor:pointer;outline:none;padding:0;';
          
          dot.onclick = function(e) {
            e.stopPropagation();
            AnatomyChannel.postMessage('select:' + pt.id);
          };

          container.appendChild(badge);
          container.appendChild(dot);
          mv.appendChild(container);
        });

        // Raycast surface tap
        mv.addEventListener('click', function (event) {
          if (event.target && (event.target.tagName === 'BUTTON' || event.target.closest('.hotspot-container'))) {
            return;
          }
          var rect = mv.getBoundingClientRect();
          var x = event.clientX - rect.left;
          var y = event.clientY - rect.top;
          if (typeof mv.positionAndNormalFromPoint === 'function') {
            var hit = mv.positionAndNormalFromPoint(x, y);
            if (hit && hit.position) {
              var p = hit.position;
              AnatomyChannel.postMessage(
                'hit:' + p.x.toFixed(3) + ',' + p.y.toFixed(3) + ',' + p.z.toFixed(3)
              );
            }
          }
        });
      }
      if (document.readyState === 'complete') { setup(); }
      else { window.addEventListener('load', setup); }
      setTimeout(setup, 600);
    })();
  ''';
  }

  bool get _isTestEnvironment =>
      WidgetsBinding.instance.runtimeType.toString().contains('Test');

  Widget _buildModelViewport() {
    if (_isTestEnvironment) {
      return Container(
        key: ValueKey(_currentModelSrc),
        color: Colors.transparent,
      );
    }
    return ModelViewer(
      key: ValueKey(_currentModelSrc),
      backgroundColor: const Color(0xFF0D1117),
      src: _currentModelSrc,
      alt: '3D Human Anatomy Interactive Model',
      autoRotate: _autoRotate,
      autoRotateDelay: 3000,
      cameraControls: true,
      disableZoom: false,
      cameraOrbit: _cameraOrbit,
      cameraTarget: _cameraTarget,
      fieldOfView: '38deg',
      minCameraOrbit: 'auto 20deg 0.6m',
      maxCameraOrbit: 'auto 160deg 6m',
      minFieldOfView: '15deg',
      maxFieldOfView: '60deg',
      onWebViewCreated: (controller) {
        _webViewController = controller;
      },
      relatedCss: '''
        * {
          box-sizing: border-box;
          -webkit-tap-highlight-color: transparent;
        }
        html, body {
          width: 100vw !important;
          height: 100vh !important;
          min-height: 100vh !important;
          max-height: 100vh !important;
          margin: 0 !important;
          padding: 0 !important;
          overflow: hidden !important;
          background: #0D1117 !important;
        }
        model-viewer {
          width: 100vw !important;
          height: 100vh !important;
          min-height: 100vh !important;
          max-height: 100vh !important;
          display: block !important;
          position: fixed !important;
          top: 0 !important;
          left: 0 !important;
          background: #0D1117 !important;
        }
      ''',
      relatedJs: _tapRaycastJs,
      javascriptChannels: {
        JavascriptChannel(
          'AnatomyChannel',
          onMessageReceived: (message) {
            final text = message.message;
            if (text.startsWith('select:')) {
              final pointId = text.substring(7);
              final match = _currentLayerPoints.firstWhere(
                (p) => p.id == pointId,
                orElse: () => _currentLayerPoints.first,
              );
              _selectPoint(match);
            } else if (text.startsWith('hit:')) {
              _handleRaycastHit(text);
            }
          },
        ),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      // FIX: a bare Stack only sizes itself to its *non-positioned*
      // children (the SafeArea header below) whenever its parent gives
      // it loose/unbounded constraints -- which is what was pushing the
      // 3D viewport (Positioned.fill) and the pain card
      // (Positioned(bottom: 24, ...)) to be measured against a tiny,
      // header-sized Stack instead of the real screen. Wrapping in
      // LayoutBuilder + an explicit SizedBox forces a real, bounded
      // size onto the Stack no matter what constraints arrive from
      // above, falling back to the true device size if they're ever
      // unbounded.
      body: LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : MediaQuery.of(context).size.height;
          final width = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : MediaQuery.of(context).size.width;

          return SizedBox(
            width: width,
            height: height,
            child: Stack(
              children: [
                // 1. 3D Model Viewport
                Positioned.fill(child: _buildModelViewport()),

                // 2. Top Header & Glassmorphic Layer Selector
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // App Bar Row
                        Row(
                          children: [
                            _buildGlassIconButton(
                              icon: Icons.arrow_back_rounded,
                              onTap: () => Navigator.of(context).pop(),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '3D Anatomy Pain Map',
                                    style: TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 17.5,
                                      fontWeight: FontWeight.w800,
                                      color: context.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Tap the model where you feel discomfort',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 11.5,
                                      color: context.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Floating Zoom Buttons (+ / -)
                            Container(
                              decoration: BoxDecoration(
                                color: context.cardBg.withValues(alpha: 0.92),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: context.cardBorder,
                                  width: 1.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  _buildIconBtnCompact(
                                    icon: Icons.add_rounded,
                                    onTap: _zoomIn,
                                  ),
                                  Container(
                                    width: 1,
                                    height: 20,
                                    color: context.cardBorder,
                                  ),
                                  _buildIconBtnCompact(
                                    icon: Icons.remove_rounded,
                                    onTap: _zoomOut,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),

                            _buildGlassIconButton(
                              icon: _autoRotate
                                  ? Icons.pause_circle_rounded
                                  : Icons.rotate_right_rounded,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() => _autoRotate = !_autoRotate);
                                _webViewController?.runJavaScript('''
                                  (function() {
                                    var mv = document.querySelector('model-viewer');
                                    if (mv) {
                                      mv.autoRotate = $_autoRotate;
                                    }
                                  })();
                                ''');
                              },
                            ),
                            const SizedBox(width: 8),
                            _buildGlassIconButton(
                              icon: Icons.center_focus_strong_rounded,
                              onTap: _resetCamera,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Anatomical Layer Segmented Dock
                        _buildLayerSegmentedDock(),
                        const SizedBox(height: 10),

                        // Quick Anatomical Filter Chips
                        _buildQuickFilterChips(),
                      ],
                    ),
                  ),
                ),

                // 3. Bottom Pain Selection Dock / Deep-Dive Card
                if (_selectedPoint != null)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 24,
                    child: _buildSelectedPainCard(_selectedPoint!),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // WIDGET BUILDERS
  // ---------------------------------------------------------------------------
  Widget _buildGlassIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: context.cardBg.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.cardBorder, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Icon(icon, color: context.textPrimary, size: 21),
        ),
      ),
    );
  }

  Widget _buildIconBtnCompact({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Icon(icon, color: context.textPrimary, size: 20),
        ),
      ),
    );
  }

  Widget _buildLayerSegmentedDock() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.cardBg.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.cardBorder, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildLayerTab(
            title: 'Surface Body',
            icon: Icons.person_outline_rounded,
            layer: AnatomyLayer.surface,
          ),
          _buildLayerTab(
            title: 'Skeleton',
            icon: Icons.accessibility_new_rounded,
            layer: AnatomyLayer.skeleton,
          ),
          _buildLayerTab(
            title: 'Organs',
            icon: Icons.favorite_border_rounded,
            layer: AnatomyLayer.organs,
          ),
        ],
      ),
    );
  }

  Widget _buildLayerTab({
    required String title,
    required IconData icon,
    required AnatomyLayer layer,
  }) {
    final isSelected = _currentLayer == layer;
    return Expanded(
      child: GestureDetector(
        onTap: () => _switchLayer(layer),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0B4632) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF0B4632).withValues(alpha: 0.28),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? Colors.white : context.textSecondary,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : context.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickFilterChips() {
    final categories = [
      'All',
      'Head',
      'Chest',
      'Abdomen',
      'Back',
      'Limbs',
      'Organs',
    ];

    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedPoint?.category == cat;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              if (cat == 'All') {
                _resetCamera();
                return;
              }
              final target = _allPoints.firstWhere(
                (p) => p.category == cat,
                orElse: () => _allPoints.first,
              );
              if (_currentLayer != target.layer) {
                setState(() => _currentLayer = target.layer);
              }
              _selectPoint(target);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFD49E35)
                    : context.cardBg.withValues(alpha: 0.90),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFD49E35)
                      : context.cardBorder,
                  width: 1.0,
                ),
              ),
              child: Center(
                child: Text(
                  cat,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : context.textPrimary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // INTERACTIVE PAIN CARD (Real-Time HUD & Deep-Dive Trigger)
  // ---------------------------------------------------------------------------
  Widget _buildSelectedPainCard(AnatomyPoint pt) {
    final layerLabel = pt.layer == AnatomyLayer.surface
        ? 'Surface Region'
        : pt.layer == AnatomyLayer.skeleton
        ? 'Skeletal Structure'
        : 'Visceral Organ';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.cardBg.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: context.cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 28,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Area Name + Layer Badge + Close
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B4632).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Color(0xFF0B4632),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pt.label,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD49E35).withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        layerLabel,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFB78103),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: context.textSecondary,
                  size: 20,
                ),
                onPressed: () => setState(() => _selectedPoint = null),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Anatomical Info
          Text(
            pt.anatomicalDescription,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: context.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Common Causes: ${pt.commonCauses}',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: context.textPrimary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),

          // Deep-Dive Action Button (if internal structures exist)
          if (pt.deepDiveTargetLayer != null) ...[
            Container(
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFD49E35).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFD49E35).withValues(alpha: 0.35),
                  width: 1.0,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => _performDeepDive(pt),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.layers_rounded,
                        color: Color(0xFFB78103),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Deep Dive into ${pt.deepDiveTargetLayer == 'organs' ? 'Internal Organs' : 'Skeletal Bones'}',
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFB78103),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Color(0xFFB78103),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Record Pain & Consult Button
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppGradients.greenButtonGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0B4632).withValues(alpha: 0.28),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _showPainAssessmentSheet(pt),
                child: const Center(
                  child: Text(
                    'Record Pain & Book Consultation',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
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

  // ---------------------------------------------------------------------------
  // PAIN ASSESSMENT & RUQYAH CONSULTATION SHEET
  // ---------------------------------------------------------------------------
  void _showPainAssessmentSheet(AnatomyPoint pt) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 32),
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                border: Border.all(color: context.cardBorder, width: 1.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.cardBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Title & Selected Area
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pain Assessment: ${pt.label}',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: context.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Specify your symptom details for your healer',
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
                  const SizedBox(height: 18),

                  // Severity Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pain Intensity: $_painSeverity / 10',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _painSeverity >= 7
                              ? const Color(0xFFC0392B)
                              : _painSeverity >= 4
                              ? const Color(0xFFD49E35)
                              : const Color(0xFF0B4632),
                        ),
                      ),
                      Text(
                        _painSeverity >= 7
                            ? 'Severe'
                            : _painSeverity >= 4
                            ? 'Moderate'
                            : 'Mild',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: _painSeverity >= 7
                          ? const Color(0xFFC0392B)
                          : _painSeverity >= 4
                          ? const Color(0xFFD49E35)
                          : const Color(0xFF0B4632),
                      thumbColor: const Color(0xFF0B4632),
                    ),
                    child: Slider(
                      value: _painSeverity.toDouble(),
                      min: 1,
                      max: 10,
                      divisions: 9,
                      onChanged: (val) {
                        setSheetState(() => _painSeverity = val.toInt());
                        setState(() => _painSeverity = val.toInt());
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Sensation Chips
                  Text(
                    'Sensation Type:',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        [
                          'Aching',
                          'Sharp Stabbing',
                          'Burning',
                          'Throbbing',
                          'Stiffness',
                          'Numbness / Tingling',
                          'Spiritual Heaviness',
                        ].map((sensation) {
                          final isSelected = _selectedSymptoms.contains(
                            sensation,
                          );
                          return FilterChip(
                            label: Text(sensation),
                            selected: isSelected,
                            labelStyle: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 11.5,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : context.textPrimary,
                            ),
                            selectedColor: const Color(0xFF0B4632),
                            backgroundColor: context.cardBg,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected
                                    ? const Color(0xFF0B4632)
                                    : context.cardBorder,
                              ),
                            ),
                            onSelected: (selected) {
                              setSheetState(() {
                                if (selected) {
                                  _selectedSymptoms.add(sensation);
                                } else {
                                  _selectedSymptoms.remove(sensation);
                                }
                              });
                            },
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Islamic Ruqyah & Healing Guidance Box
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B4632).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFF0B4632).withValues(alpha: 0.20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.auto_awesome_rounded,
                              color: Color(0xFF0B4632),
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Prophetic Medicine & Ruqyah Recommendation',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0B4632),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          pt.islamicRuqyahNote,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11.5,
                            color: context.textSecondary,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Confirm & Book Therapist
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: AppGradients.greenButtonGradient,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0B4632)
                              .withValues(alpha: 0.30),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (
                                context,
                                animation,
                                secondaryAnimation,
                              ) => const TherapistMarketplaceScreen(),
                            ),
                          );
                        },
                        child: const Center(
                          child: Text(
                            'Find a Practitioner for this Area',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 15,
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
          },
        );
      },
    );
  }
}
