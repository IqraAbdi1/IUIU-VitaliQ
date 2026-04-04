import 'package:flutter/material.dart';
import 'package:frontend/screens/login_screen.dart';
import 'screens/main_shell.dart';
import '../theme.dart';

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
      theme: AppTheme.lightTheme,
      home: const MainShell(),
    );
  }
}
