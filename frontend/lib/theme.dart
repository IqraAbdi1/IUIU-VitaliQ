import 'package:flutter/material.dart';

enum AppStatus { ok, warn, err, neutral, accent, urgent }

enum AppInfoVariant { accent, warn, err }

class AppColors {
  // ── Hero stat colours (used in HomeScreen hero header) ──
  static const heroStatBlue = Color(0xFF7ECFF5); // queue count
  static const heroStatAmber = Color(0xFFFFBE50); // estimated wait time

  // Palette
  static const Color bg = Color(0xFFEEF0F4);
  static const Color bg2 = Color(0xFFE6E9EE);
  static const Color surface = Colors.white;
  static const Color surface2 = Color(0xFFF8F9FB);

  // Text
  static const Color ink = Color(0xFF151E2B);
  static const Color ink2 = Color(0xFF44556A);
  static const Color ink3 = Color(0xFF8A9BB0);

  // Border
  static const Color border = Color(0xFFE0E4EB);

  // Accent
  static const Color accent = Color(0xFF1A7FC1);
  static const Color accentDark = Color(0xFF155F94);
  static const Color accentLight = Color(0xFFE8F4FB);
  static const Color accentMid = Color(0xFFA8D4ED);

  // Hero Gradients
  static const Color hero = Color(0xFF0E2035);
  static const Color hero2 = Color(0xFF162C47);
  static const Color hero3 = Color(0xFF1D3A5C);

  // Status — OK
  static const Color ok = Color(0xFF16714A);
  static const Color okBg = Color(0xFFEAFAF2);
  static const Color okBorder = Color(0xFF96DEBB);

  // Status — Warn
  static const Color warn = Color(0xFFA05C00);
  static const Color warnBg = Color(0xFFFFF7EA);
  static const Color warnBorder = Color(0xFFF5C97A);

  // Status — Error
  static const Color err = Color(0xFFB81C24);
  static const Color errBg = Color(0xFFFFF2F2);
  static const Color errBorder = Color(0xFFF5AAAA);

  // Status — Urgent (black set)
  static const Color urgentFg = Color(0xFFFFFFFF);
  static const Color urgentBg = Color(0xFF151E2B); // reuses ink
  static const Color urgentBorder = Color(0xFF2D3F52);
  static const Color urgentAccent = Color(0xFFFF4C4C); // red pip on black

  // ── Status colour helpers (used by AppStatusChip + AppInfoBox) ──
  static Color statusFg(AppStatus status) {
    switch (status) {
      case AppStatus.ok:
        return ok;
      case AppStatus.warn:
        return warn;
      case AppStatus.err:
        return err;
      case AppStatus.neutral:
        return ink2;
      case AppStatus.accent:
        return accent;
      case AppStatus.urgent:
        return urgentFg;
    }
  }

  static Color statusBg(AppStatus status) {
    switch (status) {
      case AppStatus.ok:
        return okBg;
      case AppStatus.warn:
        return warnBg;
      case AppStatus.err:
        return errBg;
      case AppStatus.neutral:
        return bg2;
      case AppStatus.accent:
        return accentLight;
      case AppStatus.urgent:
        return urgentBg;
    }
  }

  static Color statusBorder(AppStatus status) {
    switch (status) {
      case AppStatus.ok:
        return okBorder;
      case AppStatus.warn:
        return warnBorder;
      case AppStatus.err:
        return errBorder;
      case AppStatus.neutral:
        return border;
      case AppStatus.accent:
        return accentMid;
      case AppStatus.urgent:
        return urgentBorder;
    }
  }
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'PlusJakartaSans',
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accent,
        brightness: Brightness.light,
      ).copyWith(surface: AppColors.surface),
    );
  }
}
