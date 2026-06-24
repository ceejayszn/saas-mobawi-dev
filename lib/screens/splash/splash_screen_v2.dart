import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../dashboard/dashboard_screen_v2.dart';
import 'username_login_screen.dart';

class SplashScreenV2 extends StatefulWidget {
  const SplashScreenV2({super.key});

  @override
  State<SplashScreenV2> createState() => _SplashScreenV2State();
}

class _SplashScreenV2State extends State<SplashScreenV2>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _animController.forward();
    _checkUsernameAndNavigate();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _checkUsernameAndNavigate() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('cashier_username');

    if (mounted) {
      if (username == null || username.isEmpty) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const UsernameLoginScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardScreenV2()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF1A237E)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  // Logo with glow
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.2),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Image.asset('assets/logo.png'),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Euton Hotel',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Point of Sale System',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.75),
                      letterSpacing: 2.0,
                    ),
                  ),
                  const Spacer(flex: 2),
                  // Loading indicator
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      color: Colors.white.withOpacity(0.85),
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Developer credit
                  Text(
                    'Developed by: Mobawi LLC',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.55),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
