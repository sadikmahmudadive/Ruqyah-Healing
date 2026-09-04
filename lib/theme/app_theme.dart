import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primaryGreen = Color(0xFF0B4632);
  static const Color primaryDarkGreen = Color(0xFF082F21);
  static const Color secondaryGreen = Color(0xFF0F593D);
  static const Color accentGold = Color(0xFFD49E35);
  static const Color lightMint = Color(0xFF81C784);

  // Light Mode Colors
  static const Color lightBackground = Color(0xFFF5F7F6);
  static const Color lightCardBg = Colors.white;
  static const Color lightCardBorder = Color(0xFFE2E8E5);
  static const Color lightTextPrimary = Color(0xFF15221D);
  static const Color lightTextSecondary = Color(0xFF6E7E77);
  static const Color lightTextMuted = Color(0xFF90A4AE);
  static const Color lightContainerBg = Color(0xFFEBF7F0);

  // Dark Mode Colors (Onyx Emerald)
  static const Color darkBackground = Color(0xFF0B0F12);
  static const Color darkCardBg = Color(0xFF121B17);
  static const Color darkCardBorder = Color(0xFF1E302A);
  static const Color darkTextPrimary = Color(0xFFF5F7F6);
  static const Color darkTextSecondary = Color(0xFF92A89F);
  static const Color darkTextMuted = Color(0xFF627870);
  static const Color darkContainerBg = Color(0xFF182E25);
}

extension AppThemeContext on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get pageBg =>
      isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
  Color get cardBg =>
      isDarkMode ? AppColors.darkCardBg : AppColors.lightCardBg;
  Color get cardBorder =>
      isDarkMode ? AppColors.darkCardBorder : AppColors.lightCardBorder;
  Color get textPrimary =>
      isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  Color get textSecondary =>
      isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  Color get textMuted =>
      isDarkMode ? AppColors.darkTextMuted : AppColors.lightTextMuted;
  Color get containerBg =>
      isDarkMode ? AppColors.darkContainerBg : AppColors.lightContainerBg;
}

class AppTheme {
  static final ValueNotifier<ThemeMode> themeModeNotifier =
      ValueNotifier<ThemeMode>(ThemeMode.system);

  static ThemeData get lightTheme {
    return ThemeData(
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
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.lightTextPrimary),
        titleTextStyle: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.lightTextPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.lightCardBorder, width: 1),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
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
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
        titleTextStyle: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.darkTextPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.darkCardBorder, width: 1),
        ),
      ),
    );
  }
}
