import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; // Make sure this path matches your folder structure!

void main() {
  runApp(const VitaliqApp());
}

class VitaliqApp extends StatelessWidget {
  const VitaliqApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vitaliq',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // Add your custom theme settings here if you have them in theme.dart
      ),
      home:
          const HomeScreen(), // Point this to YOUR class name in home_screen.dart
    );
  }
}
