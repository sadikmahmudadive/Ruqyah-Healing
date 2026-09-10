import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'localization/app_localizations.dart';
import 'screens/splash_screen.dart';
import 'services/firebase_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await FirebaseService.initialize();
  } catch (e) {
    debugPrint('Initialization note: $e');
  }
  runApp(const RuqyahHealingApp());
}

class RuqyahHealingApp extends StatelessWidget {
  const RuqyahHealingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.themeModeNotifier,
      builder: (context, mode, child) {
        return ValueListenableBuilder<Locale>(
          valueListenable: AppLocalizations.currentLocaleNotifier,
          builder: (context, locale, child) {
            return MaterialApp(
              title: 'Ruqyah Healing',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: mode,
              locale: locale,
              supportedLocales: const [
                Locale('en'),
                Locale('bn'),
                Locale('ar'),
                Locale('ur'),
              ],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }
}
