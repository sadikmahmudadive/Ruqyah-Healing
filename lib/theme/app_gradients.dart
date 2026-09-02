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

  static const LinearGradient greenButtonGradient = LinearGradient(
    colors: [
      Color(0xFF082F21),
      Color(0xFF0F593D),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
