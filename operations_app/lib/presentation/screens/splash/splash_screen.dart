import 'package:flutter/material.dart';
import '../auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Fade animation for logo
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    // Smooth progress animation that goes from 0.0 to 0.96 (96%)
    _progressAnimation = Tween<double>(begin: 0.0, end: 0.96).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.9, curve: Curves.easeInOutCubic),
      ),
    );

    _controller.forward().then((_) {
      // Transition smoothly into the Home/Login screen after progress completes
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Premium centered Hotel Logo
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.15),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/logo.png',
                      width: 140,
                      height: 140,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'EUTON HOTEL',
                    style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 4.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'PREMIUM OPERATIONS SYSTEM',
                    style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade500,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Modern progress loader near the bottom
          Positioned(
            bottom: 80,
            left: 48,
            right: 48,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      final percentage = (_progressAnimation.value * 100).toInt();
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Initializing systems...',
                            style: TextStyle(
                              fontFamily: 'Helvetica',
                              color: Colors.grey.shade500,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '$percentage%',
                            style: TextStyle(
                              fontFamily: 'Helvetica',
                              color: Colors.grey.shade300,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: _progressAnimation.value,
                          backgroundColor: Colors.grey.shade900,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          minHeight: 4,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
