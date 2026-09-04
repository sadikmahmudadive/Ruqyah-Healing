import 'package:flutter/material.dart';

class AppGradients {
  /// Deep rich forest green to luminous emerald green gradient
  /// #082F21 -> #0F593D
  static const LinearGradient greenHeaderGradient = LinearGradient(
    colors: [
      Color(0xFF082F21),
      Color(0xFF0F593D),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Dark Mode Header Gradient
  static const LinearGradient darkHeaderGradient = LinearGradient(
    colors: [
      Color(0xFF051C14),
      Color(0xFF0B3B28),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient greenButtonGradient = LinearGradient(
    colors: [
      Color(0xFF082F21),
      Color(0xFF0F593D),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static LinearGradient headerGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkHeaderGradient : greenHeaderGradient;
  }
}
