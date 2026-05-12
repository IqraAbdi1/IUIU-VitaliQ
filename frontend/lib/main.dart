import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'theme.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
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
      home: const SplashScreen(),
      routes: {'/login': (context) => const LoginScreen()},
    );
  }
}
