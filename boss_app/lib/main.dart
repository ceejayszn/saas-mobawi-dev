import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const BossApp());
}

class BossApp extends StatelessWidget {
  const BossApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Executive Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF6C63FF),
          secondary: const Color(0xFF03DAC6),
          surface: const Color(0xFF1E1E2C),
          background: const Color(0xFF12121A),
        ),
        fontFamily: 'Inter',
      ),
      home: const LoginScreen(),
    );
  }
}
