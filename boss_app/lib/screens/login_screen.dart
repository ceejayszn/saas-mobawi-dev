import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_constants.dart';
import '../core/security/auth_service.dart';
import '../theme/app_colors.dart';
import 'main_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocus = FocusNode();

  bool _isLoading = false;
  String _errorMessage = '';
  bool _isLocked = false;
  int _lockoutSeconds = 0;
  Timer? _lockoutTimer;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticOut),
    );
    _checkInitialLockout();
    // Auto-focus PIN field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pinFocus.requestFocus();
    });
  }

  Future<void> _checkInitialLockout() async {
    final remaining = await AuthService.instance.getLockoutRemainingSeconds();
    if (remaining > 0) {
      _startLockoutTimer(remaining);
    }
  }

  void _startLockoutTimer(int seconds) {
    setState(() {
      _isLocked = true;
      _lockoutSeconds = seconds;
      _errorMessage = 'Too many attempts. Locked for $_lockoutSeconds seconds.';
    });
    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _lockoutSeconds--;
        _errorMessage = 'Too many attempts. Try again in $_lockoutSeconds seconds.';
        if (_lockoutSeconds <= 0) {
          _isLocked = false;
          _errorMessage = '';
          timer.cancel();
        }
      });
    });
  }

  Future<void> _attemptLogin() async {
    if (_isLocked || _isLoading) return;

    final pin = _pinController.text.trim();
    if (pin.isEmpty) {
      _showError('Please enter your PIN.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final result = await AuthService.instance.attemptLogin(pin);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result.isSuccess) {
      // Clear PIN before navigating (security)
      _pinController.clear();
      HapticFeedback.lightImpact();
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => const MainDashboard(),
          transitionsBuilder: (_, anim, _, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    } else if (result.isLocked) {
      _pinController.clear();
      _startLockoutTimer(result.remainingSeconds ?? 30);
      _triggerShake();
    } else {
      _pinController.clear();
      _showError(result.message ?? 'Incorrect PIN.');
      _triggerShake();
      HapticFeedback.heavyImpact();
    }
  }

  void _showError(String message) {
    setState(() => _errorMessage = message);
  }

  void _triggerShake() {
    _shakeController.reset();
    _shakeController.forward();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocus.dispose();
    _shakeController.dispose();
    _lockoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    // Hotel Logo
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGreen.withValues(alpha: 0.2),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(26),
                        child: Image.asset(
                          'assets/images/hotel_logo.jpg',
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.hotel,
                            color: AppColors.primaryGreen,
                            size: 64,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Removed app name and subtitle to simplify login screen
                    const SizedBox(height: 60),
                    // PIN Field with shake animation
                    AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (_, child) {
                        final offset = _shakeController.isAnimating
                            ? 12 * (0.5 - (_shakeAnimation.value - 0.5).abs()) * 2
                            : 0.0;
                        return Transform.translate(
                          offset: Offset(offset, 0),
                          child: child,
                        );
                      },
                      child: _buildPinField(isDark),
                    ),
                    // Error message
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      child: _errorMessage.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Row(
                                children: [
                                  Icon(
                                    _isLocked
                                        ? Icons.lock_clock_outlined
                                        : Icons.error_outline_rounded,
                                    color: _isLocked ? AppColors.warning : AppColors.error,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorMessage,
                                      style: TextStyle(
                                        color: _isLocked ? AppColors.warning : AppColors.error,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),

                    // Footer
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Text(
                        'Developed by ${AppConstants.developerName}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textHint,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinField(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: _errorMessage.isNotEmpty && !_isLocked
              ? AppColors.error.withValues(alpha: 0.5)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: _pinController,
        focusNode: _pinFocus,
        obscureText: true,
        obscuringCharacter: '*',
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(AppConstants.maxPinLength),
        ],
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _attemptLogin(),
        onChanged: (val) {
          if (val.length == AppConstants.maxPinLength) {
            _attemptLogin();
          }
        },
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          letterSpacing: 8,
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: '* * * * * *',
          hintStyle: TextStyle(
            color: isDark ? AppColors.darkTextHint : AppColors.textHint,
            fontSize: 22,
            letterSpacing: 6,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.asset(
                'assets/images/hotel_logo.jpg',
                width: 24,
                height: 24,
                fit: BoxFit.contain,
              ),
            ),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
      ),
    );
  }
}
