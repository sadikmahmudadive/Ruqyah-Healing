import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruqyahhealing/screens/acupressure_hub_screen.dart';
import 'package:ruqyahhealing/screens/acupuncture_hub_screen.dart';
import 'package:ruqyahhealing/screens/ai_symptom_guide_screen.dart';
import 'package:ruqyahhealing/screens/audio_library_screen.dart';
import 'package:ruqyahhealing/screens/ayurvedic_hub_screen.dart';
import 'package:ruqyahhealing/screens/book_appointment_screen.dart';
import 'package:ruqyahhealing/screens/community_screen.dart';
import 'package:ruqyahhealing/screens/daily_salah_screen.dart';
import 'package:ruqyahhealing/screens/emergency_ruqyah_screen.dart';
import 'package:ruqyahhealing/screens/guidance_results_screen.dart';
import 'package:ruqyahhealing/screens/health_profile_detail_screen.dart';
import 'package:ruqyahhealing/screens/hijama_hub_screen.dart';
import 'package:ruqyahhealing/screens/hijama_session_detail_screen.dart';
import 'package:ruqyahhealing/screens/medicine_hub_screen.dart';
import 'package:ruqyahhealing/screens/notification_screen.dart';
import 'package:ruqyahhealing/screens/notification_settings_screen.dart';
import 'package:ruqyahhealing/screens/order_tracking_screen.dart';
import 'package:ruqyahhealing/screens/pain_stress_monitor_screen.dart';
import 'package:ruqyahhealing/screens/pathology_hub_screen.dart';
import 'package:ruqyahhealing/screens/quiz_certificate_screen.dart';
import 'package:ruqyahhealing/screens/ruqyah_hub_screen.dart';
import 'package:ruqyahhealing/screens/ruqyah_progress_screen.dart';
import 'package:ruqyahhealing/screens/secure_messages_screen.dart';
import 'package:ruqyahhealing/screens/settings_screen.dart';
import 'package:ruqyahhealing/screens/signin_screen.dart';
import 'package:ruqyahhealing/screens/signup_screen.dart';
import 'package:ruqyahhealing/screens/subscription_plans_screen.dart';
import 'package:ruqyahhealing/screens/tabs/home_tab.dart';
import 'package:ruqyahhealing/screens/tabs/learn_tab.dart';
import 'package:ruqyahhealing/screens/tabs/profile_tab.dart';
import 'package:ruqyahhealing/screens/tabs/services_tab.dart';
import 'package:ruqyahhealing/screens/therapist_marketplace_screen.dart';
import 'package:ruqyahhealing/screens/therapist_profile_screen.dart';
import 'package:ruqyahhealing/screens/toast_showcase_screen.dart';
import 'package:ruqyahhealing/screens/unani_hub_screen.dart';
import 'package:ruqyahhealing/screens/video_consultation_screen.dart';
import 'package:ruqyahhealing/theme/app_theme.dart';

/// One way of making the app uncomfortable.
class _Scenario {
  final String name;
  final Size size;
  final double textScale;
  final bool dark;
  final bool rtl;
  const _Scenario(this.name, this.size, this.textScale, this.dark, this.rtl);
}

const _scenarios = [
  _Scenario('small phone 320x640', Size(320, 640), 1.0, false, false),
  _Scenario('large text x1.6 on 360x740', Size(360, 740), 1.6, false, false),
  _Scenario('dark + right-to-left 390x844', Size(390, 844), 1.0, true, true),
  _Scenario('largest text x2.0 on 360x780', Size(360, 780), 2.0, false, false),
  _Scenario('tablet 800x1200', Size(800, 1200), 1.0, false, false),
];

/// Screens that take no required arguments. Each is built under every
/// scenario; any layout overflow or thrown error fails that screen.
final Map<String, Widget Function()> _screens = {
  'AcupressureHub': () => const AcupressureHubScreen(),
  'AcupunctureHub': () => const AcupunctureHubScreen(),
  'AISymptomGuide': () => const AISymptomGuideScreen(),
  'AudioLibrary': () => const AudioLibraryScreen(),
  'AyurvedicHub': () => const AyurvedicHubScreen(),
  'BookAppointment': () => const BookAppointmentScreen(),
  'Community': () => const CommunityScreen(),
  'DailySalah': () => const DailySalahScreen(),
  'EmergencyRuqyah': () => const EmergencyRuqyahScreen(),
  'GuidanceResults': () => const GuidanceResultsScreen(),
  'HealthProfileDetail': () => const HealthProfileDetailScreen(),
  'HijamaHub': () => const HijamaHubScreen(),
  'HijamaSessionDetail': () => const HijamaSessionDetailScreen(),
  'MedicineHub': () => const MedicineHubScreen(),
  'NotificationSettings': () => const NotificationSettingsScreen(),
  'OrderTracking': () => const OrderTrackingScreen(),
  'PainStressMonitor': () => const PainStressMonitorScreen(),
  'PathologyHub': () => const PathologyHubScreen(),
  'QuizCertificate': () => const QuizCertificateScreen(),
  'RuqyahHub': () => const RuqyahHubScreen(),
  'RuqyahProgress': () => const RuqyahProgressScreen(),
  'SecureMessages': () => const SecureMessagesScreen(),
  'Settings': () => const SettingsScreen(),
  'SignIn': () => const SignInScreen(),
  'SignUp': () => const SignUpScreen(),
  'SubscriptionPlans': () => const SubscriptionPlansScreen(),
  'HomeTab': () => const HomeTab(),
  'LearnTab': () => const LearnTab(),
  'ProfileTab': () => const ProfileTab(),
  'ServicesTab': () => const ServicesTab(),
  'TherapistMarketplace': () => const TherapistMarketplaceScreen(),
  'TherapistProfile': () => const TherapistProfileScreen(),
  'ToastShowcase': () => const ToastShowcaseScreen(),
  'UnaniHub': () => const UnaniHubScreen(),
  'VideoConsultation': () => const VideoConsultationScreen(),
};

/// The default test font (Ahem) makes every letter a full square, far wider
/// than real text, so layouts that fit on a phone would overflow here. Load the
/// app's real fonts instead so widths are realistic.
Future<void> _loadAppFonts() async {
  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final f in files) {
      loader.addFont(rootBundle.load('assets/fonts/$f'));
    }
    await loader.load();
  }

  await load('PlusJakartaSans', [
    'PlusJakartaSans-VariableFont_wght.ttf',
    'PlusJakartaSans-Italic-VariableFont_wght.ttf',
  ]);
  await load('Inter', [
    'Inter-VariableFont_opsz,wght.ttf',
    'Inter-Italic-VariableFont_opsz,wght.ttf',
  ]);
  await load('Cinzel', ['Cinzel-VariableFont_wght.ttf']);
}

/// First line of an error that points into the app's own code, to say where.
String _where(FlutterErrorDetails e) {
  final m = RegExp(r'lib/[A-Za-z0-9_/]+\.dart:\d+')
      .firstMatch(e.toDiagnosticsNode().toStringDeep());
  return m == null ? '' : '@ ${m.group(0)}';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(_loadAppFonts);

  for (final entry in _screens.entries) {
    testWidgets('${entry.key} holds up under stress', (tester) async {
      final problems = <String>[];
      // With semantics on, the accessibility tree is built too, which turns
      // malformed Semantics (missing values, bad actions) into errors.
      final semantics = tester.ensureSemantics();

      for (final s in _scenarios) {
        tester.view.physicalSize = s.size;
        tester.view.devicePixelRatio = 1;

        final errors = <FlutterErrorDetails>[];
        final previous = FlutterError.onError;
        FlutterError.onError = errors.add;

        await tester.pumpWidget(
          MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: s.dark ? AppTheme.darkTheme : AppTheme.lightTheme,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(s.textScale)),
              child: Directionality(
                textDirection: s.rtl ? TextDirection.rtl : TextDirection.ltr,
                child: child!,
              ),
            ),
            home: entry.value(),
          ),
        );
        // Let entrances and first-frame work run. Some screens loop an
        // animation forever, so never use pumpAndSettle here.
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pump(const Duration(milliseconds: 1400));

        FlutterError.onError = previous;
        for (final e in errors) {
          final text = e.exceptionAsString().split('\n').first;
          problems.add('[${s.name}] $text ${_where(e)}');
        }
        // Tear the screen down before the next scenario.
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 50));
        tester.takeException();
      }

      expect(
        problems.toSet().toList(),
        isEmpty,
        reason: '${entry.key}:\n${problems.toSet().join('\n')}',
      );
      semantics.dispose();
      addTearDown(tester.view.reset);
    });
  }

  // These need arguments, so they are built with sample values.
  testWidgets('NotificationScreen builds', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(builder: (_) => const NotificationScreen()),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
  });
}
