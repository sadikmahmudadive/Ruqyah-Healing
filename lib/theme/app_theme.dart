import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Brand palette + semantic surface tokens used across the app.
class AppColors {
  // Brand Colors
  static const Color primaryGreen = Color(0xFF0B4632);
  static const Color primaryDarkGreen = Color(0xFF082F21);
  static const Color secondaryGreen = Color(0xFF0F593D);
  static const Color accentGold = Color(0xFFD49E35);
  static const Color accentGoldSoft = Color(0xFFE5B860);
  static const Color lightMint = Color(0xFF81C784);

  // Semantic (status) colors
  static const Color success = Color(0xFF2F7D5B);
  static const Color warning = Color(0xFFD9923F);
  static const Color danger = Color(0xFFC4604F);
  static const Color info = Color(0xFF4A8DB0);

  // Calm category tints + matching accents. Low saturation on purpose, so a
  // row of different services reads as one quiet family, not a rainbow.
  static const Color tintMint = Color(0xFFE9F3EC);
  static const Color tintSand = Color(0xFFF6EEE2);
  static const Color tintMist = Color(0xFFE6EFF1);
  static const Color tintSage = Color(0xFFE8F1E4);
  static const Color tintLilac = Color(0xFFF0EBF2);
  static const Color tintRose = Color(0xFFF6E9E5);
  static const Color accentSage = Color(0xFF4E8F62);
  static const Color accentLilac = Color(0xFF7D5C93);

  // Light Mode Colors
  static const Color lightBackground = Color(0xFFF4F6F1);
  static const Color lightSurface = Color(0xFFF9FAF6);
  static const Color lightCardBg = Color(0xFFFCFDFA);
  static const Color lightCardBorder = Color(0xFFE5EAE3);
  static const Color lightCardBorderStrong = Color(0xFFCFD8D0);
  static const Color lightTextPrimary = Color(0xFF1F2D27);
  static const Color lightTextSecondary = Color(0xFF576760);
  static const Color lightTextMuted = Color(0xFF74847D);
  static const Color lightContainerBg = Color(0xFFE9F3EC);

  // Dark Mode Colors (Onyx Emerald)
  static const Color darkBackground = Color(0xFF08120E);
  static const Color darkSurface = Color(0xFF0B1813);
  static const Color darkCardBg = Color(0xFF0F1F1A);
  static const Color darkCardBorder = Color(0xFF1C362C);
  static const Color darkCardBorderStrong = Color(0xFF27493B);
  static const Color darkTextPrimary = Color(0xFFE9F0EC);
  static const Color darkTextSecondary = Color(0xFF9DB3AA);
  static const Color darkTextMuted = Color(0xFF7E948B);
  static const Color darkContainerBg = Color(0xFF162E25);
  static const Color darkIconCircleBg = Color(0xFF132620);
}

/// Type scale. One place for the sizes, weights, tracking and line heights so
/// new screens read as one family: a small tracked eyebrow, a tight display
/// size for the one big thing on a screen, and a roomy 1.5 body.
/// Colour is left off on purpose; add it with `copyWith(color: ...)`.
class AppType {
  AppType._();

  static const TextStyle eyebrow = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 11.5,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.4,
    height: 1.2,
  );

  static const TextStyle display = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.08,
  );

  static const TextStyle title = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.1,
    height: 1.25,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle body = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
}

/// Convenience accessors on BuildContext that resolve to the right
/// token for the current theme.
extension AppThemeContext on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get pageBg =>
      isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
  Color get surfaceBg =>
      isDarkMode ? AppColors.darkSurface : AppColors.lightSurface;
  Color get cardBg => isDarkMode ? AppColors.darkCardBg : AppColors.lightCardBg;
  Color get cardBorder =>
      isDarkMode ? AppColors.darkCardBorder : AppColors.lightCardBorder;
  Color get cardBorderStrong => isDarkMode
      ? AppColors.darkCardBorderStrong
      : AppColors.lightCardBorderStrong;
  Color get textPrimary =>
      isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  Color get textSecondary =>
      isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  Color get textMuted =>
      isDarkMode ? AppColors.darkTextMuted : AppColors.lightTextMuted;
  Color get containerBg =>
      isDarkMode ? AppColors.darkContainerBg : AppColors.lightContainerBg;
  Color get iconCircleBg =>
      isDarkMode ? AppColors.darkIconCircleBg : AppColors.lightContainerBg;

  SystemUiOverlayStyle get systemOverlayStyle {
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: isDarkMode
          ? Brightness.light
          : Brightness.dark,
    );
  }

  SystemUiOverlayStyle get darkHeaderOverlayStyle {
    return const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    );
  }
}

class AppTheme {
  /// Roomier body text and slightly tighter large headings across the app.
  static TextTheme _refine(TextTheme t) => t.copyWith(
    displayLarge: t.displayLarge?.copyWith(letterSpacing: -0.5, height: 1.1),
    displayMedium: t.displayMedium?.copyWith(letterSpacing: -0.4, height: 1.1),
    headlineMedium: t.headlineMedium?.copyWith(
      letterSpacing: -0.3,
      height: 1.2,
    ),
    titleLarge: t.titleLarge?.copyWith(letterSpacing: -0.1, height: 1.25),
    bodyLarge: t.bodyLarge?.copyWith(height: 1.5),
    bodyMedium: t.bodyMedium?.copyWith(height: 1.5),
    bodySmall: t.bodySmall?.copyWith(height: 1.4),
  );

  static final ValueNotifier<ThemeMode> themeModeNotifier =
      ValueNotifier<ThemeMode>(ThemeMode.system);

  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primaryGreen,
      scaffoldBackgroundColor: AppColors.lightBackground,
      fontFamily: 'PlusJakartaSans',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryGreen,
        brightness: Brightness.light,
        surface: AppColors.lightCardBg,
        onSurface: AppColors.lightTextPrimary,
        primary: AppColors.primaryGreen,
        secondary: AppColors.accentGold,
      ),
      splashFactory: InkRipple.splashFactory,
      splashColor: AppColors.primaryGreen.withValues(alpha: 0.08),
      highlightColor: AppColors.primaryGreen.withValues(alpha: 0.04),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.lightTextPrimary),
        titleTextStyle: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.lightTextPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.lightCardBorder, width: 1),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
    return base.copyWith(
      textTheme: _refine(
        base.textTheme.apply(
          bodyColor: AppColors.lightTextPrimary,
          displayColor: AppColors.lightTextPrimary,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryGreen,
      scaffoldBackgroundColor: AppColors.darkBackground,
      fontFamily: 'PlusJakartaSans',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryGreen,
        brightness: Brightness.dark,
        surface: AppColors.darkCardBg,
        onSurface: AppColors.darkTextPrimary,
        primary: AppColors.primaryGreen,
        secondary: AppColors.accentGold,
      ),
      splashFactory: InkRipple.splashFactory,
      splashColor: AppColors.accentGold.withValues(alpha: 0.08),
      highlightColor: AppColors.accentGold.withValues(alpha: 0.04),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
        titleTextStyle: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.darkTextPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.darkCardBorder, width: 1),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
    return base.copyWith(
      textTheme: _refine(
        base.textTheme.apply(
          bodyColor: AppColors.darkTextPrimary,
          displayColor: AppColors.darkTextPrimary,
        ),
      ),
    );
  }
}
