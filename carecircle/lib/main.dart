import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'screens/onboarding/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CareCircleApp());
}

class CareCircleApp extends StatelessWidget {
  const CareCircleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CareCircle',
      debugShowCheckedModeBanner: false,
      theme: CareCircleTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}