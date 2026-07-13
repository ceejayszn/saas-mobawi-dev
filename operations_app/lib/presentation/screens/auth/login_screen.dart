import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/security/pos_auth_service.dart';
import '../../theme/app_colors.dart';
import '../dashboard/dashboard_screen.dart';

/// POS authentication gate.
/// - First run: prompts user to create a PIN.
/// - Subsequent runs: requires PIN entry to access the dashboard.
/// - Brute-force protection: locks out after 5 failed attempts.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _focusNode = FocusNode();

  bool _isFirstRun = false;
  bool _isLoading = true;
  bool _obscurePin = true;
  String? _errorMessage;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 12)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);
    _initialize();
  }

  Future<void> _initialize() async {
    await PosAuthService.instance.initialize();
    final firstRun = await PosAuthService.instance.isFirstRun();
    if (mounted) {
      setState(() {
        _isFirstRun = firstRun;
        _isLoading = false;
      });
      _focusNode.requestFocus();
    }
  }

  Future<void> _handleSubmit() async {
    final pin = _pinController.text.trim();
    if (pin.isEmpty) return;

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    String? result;

    if (_isFirstRun) {
      final confirmPin = _confirmPinController.text.trim();
      result = await PosAuthService.instance.createPin(pin, confirmPin);
    } else {
      result = await PosAuthService.instance.login(pin);
    }

    if (!mounted) return;

    if (result == null) {
      // Success — navigate to dashboard
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      // Error — show message and shake
      setState(() {
        _errorMessage = result;
        _isLoading = false;
      });
      _shakeController.forward(from: 0);
      _pinController.clear();
      _confirmPinController.clear();
      _focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    _focusNode.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _isFirstRun == false && _errorMessage == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF4F6F4),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    _shakeController.isAnimating
                        ? _shakeAnimation.value *
                            ((_shakeController.value * 10).toInt().isEven
                                ? 1
                                : -1)
                        : 0,
                    0,
                  ),
                  child: child,
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.point_of_sale_rounded,
                      size: 48,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    _isFirstRun ? 'Create Your PIN' : 'Enter PIN',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isFirstRun
                        ? 'Set a secure PIN to protect your POS terminal.'
                        : 'Enter your PIN to access the POS terminal.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textHint,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // PIN field
                  _buildPinField(
                    controller: _pinController,
                    label: _isFirstRun ? 'New PIN' : 'PIN',
                    focusNode: _focusNode,
                    onSubmitted: _isFirstRun ? null : (_) => _handleSubmit(),
                  ),

                  // Confirm PIN field (first-run only)
                  if (_isFirstRun) ...[
                    const SizedBox(height: 16),
                    _buildPinField(
                      controller: _confirmPinController,
                      label: 'Confirm PIN',
                      onSubmitted: (_) => _handleSubmit(),
                    ),
                  ],

                  // Error message
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.redAccent.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.redAccent.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppColors.redAccent, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: AppColors.redAccent,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _isFirstRun ? 'Create PIN' : 'Unlock',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Branding
                  Text(
                    'Secured by MOBAWI',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textHint.withValues(alpha: 0.6),
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinField({
    required TextEditingController controller,
    required String label,
    FocusNode? focusNode,
    ValueChanged<String>? onSubmitted,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: _obscurePin,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(12),
      ],
      onSubmitted: onSubmitted,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 8,
        color: AppColors.textPrimary,
      ),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textHint),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePin ? Icons.visibility_off : Icons.visibility,
            color: AppColors.textHint,
          ),
          onPressed: () {
            setState(() {
              _obscurePin = !_obscurePin;
            });
          },
        ),
      ),
    );
  }
}
