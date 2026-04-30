import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'screens/splash_screen.dart';
import 'theme.dart';

void main() {
  // Preserve the native splash screen until SplashScreen widget calls
  // FlutterNativeSplash.remove() — this bridges the gap between engine
  // start and first Flutter frame, eliminating the black screen entirely.
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(const VitaliqApp());
}

class VitaliqApp extends StatelessWidget {
  const VitaliqApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VitalIQ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // ── Entry point ──────────────────────────────────────
      // Flow: SplashScreen → LoginScreen → MainShell
      // SplashScreen handles the timed delay and fade transition to login.
      // In the future, SplashScreen will also check for a stored JWT token:
      //   - Valid token → skip login, go straight to MainShell
      //   - No token / expired → go to LoginScreen
      home: const SplashScreen(),
    );
  }
}
