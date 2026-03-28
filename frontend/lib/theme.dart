import 'package:flutter/material.dart';

class AppColors {
  // Palette from CSS :root
  static const Color bg = Color(0xFFEEF0F4);
  static const Color surface = Colors.white;
  static const Color ink = Color(0xFF151E2B);
  static const Color ink2 = Color(0xFF44556A);
  static const Color ink3 = Color(0xFF8A9BB0);

  // Accents
  static const Color accent = Color(0xFF1A7FC1);
  static const Color accentDark = Color(0xFF155F94);
  static const Color accentLight = Color(0xFFE8F4FB);

  // Hero Gradients
  static const Color hero = Color(0xFF0E2035);
  static const Color hero2 = Color(0xFF162C47);
  static const Color hero3 = Color(0xFF1D3A5C);

  // Status
  static const Color ok = Color(0xFF16714A);
  static const Color err = Color(0xFFB81C24);
  static const Color warn = Color(0xFFA05C00);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'PlusJakartaSans',
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accent,
        surface: AppColors.surface,
      ),
    );
  }
}
