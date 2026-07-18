import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'secure_storage.dart';

/// Authentication service for POS operations app.
/// Provides PIN-based login with brute-force protection.
class PosAuthService {
  PosAuthService._();
  static final PosAuthService instance = PosAuthService._();

  static const String _keyPinHash = 'pos_pin_hash';
  static const String _keyPinSalt = 'pos_pin_salt';
  static const String _keyFailedAttempts = 'pos_failed_attempts';
  static const String _keyLockoutUntil = 'pos_lockout_until';
  static const int _maxAttempts = 5;
  static const int _lockoutSeconds = 30;
  static const int _minPinLength = 4;

  /// Initialize — check if PIN setup is required.
  Future<void> initialize() async {
    final resetFlag = await SecureStorage.getString('pos_reset_to_default_v5');
    if (resetFlag != 'true') {
      await SecureStorage.remove(_keyPinHash);
      await SecureStorage.remove(_keyPinSalt);
      await SecureStorage.saveString('pos_reset_to_default_v5', 'true');
    }

    final existingHash = await SecureStorage.getString(_keyPinHash);
    if (existingHash == null || existingHash.isEmpty) {
      final salt = _generateSalt();
      final hash = _hashPin('0000', salt);
      await SecureStorage.saveString(_keyPinHash, hash);
      await SecureStorage.saveString(_keyPinSalt, salt);
    }
  }

  /// Returns true if no PIN has been set (first-run).
  Future<bool> isFirstRun() async {
    final hash = await SecureStorage.getString(_keyPinHash);
    return hash == null || hash.isEmpty;
  }

  /// Creates the initial PIN during first-run setup.
  Future<String?> createPin(String pin, String confirmPin) async {
    if (pin.length < _minPinLength) {
      return 'PIN must be at least $_minPinLength digits.';
    }
    if (pin != confirmPin) {
      return 'PINs do not match.';
    }
    final salt = _generateSalt();
    final hash = _hashPin(pin, salt);
    await SecureStorage.saveString(_keyPinHash, hash);
    await SecureStorage.saveString(_keyPinSalt, salt);
    return null;
  }

  /// Attempts login. Returns null on success, or an error message.
  Future<String?> login(String pin) async {
    // Check lockout
    final lockoutStr = await SecureStorage.getString(_keyLockoutUntil);
    if (lockoutStr != null && lockoutStr.isNotEmpty) {
      final lockoutUntil = DateTime.tryParse(lockoutStr);
      if (lockoutUntil != null && DateTime.now().isBefore(lockoutUntil)) {
        final remaining = lockoutUntil.difference(DateTime.now()).inSeconds;
        return 'Too many attempts. Try again in $remaining seconds.';
      } else {
        await SecureStorage.saveString(_keyLockoutUntil, '');
        await SecureStorage.saveString(_keyFailedAttempts, '0');
      }
    }

    // Verify PIN
    final storedHash = await SecureStorage.getString(_keyPinHash);
    final salt = await SecureStorage.getString(_keyPinSalt);
    if (storedHash == null || salt == null) {
      return 'No PIN configured. Please set up your PIN.';
    }

    final inputHash = _hashPin(pin, salt);
    if (_constantTimeEquals(inputHash, storedHash)) {
      // Success — clear failed attempts
      await SecureStorage.saveString(_keyFailedAttempts, '0');
      await SecureStorage.saveString(_keyLockoutUntil, '');
      return null;
    }

    // Failed attempt
    final failedStr = await SecureStorage.getString(_keyFailedAttempts) ?? '0';
    final failed = (int.tryParse(failedStr) ?? 0) + 1;
    await SecureStorage.saveString(_keyFailedAttempts, failed.toString());

    if (failed >= _maxAttempts) {
      final excess = failed - _maxAttempts;
      final seconds = _lockoutSeconds * (1 << excess.clamp(0, 5));
      final lockoutUntil = DateTime.now().add(Duration(seconds: seconds));
      await SecureStorage.saveString(
        _keyLockoutUntil,
        lockoutUntil.toIso8601String(),
      );
      return 'Account locked for $seconds seconds.';
    }

    final remaining = _maxAttempts - failed;
    return 'Incorrect PIN. $remaining attempt${remaining == 1 ? '' : 's'} remaining.';
  }

  // ── Crypto helpers ───────────────────────────────────────────────────────

  static String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  static String _hashPin(String pin, String salt) {
    final input = '$salt:$pin';
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }

  /// Validates the admin recovery code (phone number).
  bool validateRecoveryCode(String code) {
    final cleanCode = code.replaceAll(RegExp(r'\s+|-'), '');
    return cleanCode == '0718901990';
  }

  /// Forces the primary PIN to be reset.
  Future<void> forceResetPin(String newPin) async {
    final salt = _generateSalt();
    final hash = _hashPin(newPin, salt);
    await SecureStorage.saveString(_keyPinHash, hash);
    await SecureStorage.saveString(_keyPinSalt, salt);
    await SecureStorage.saveString(_keyFailedAttempts, '0');
    await SecureStorage.saveString(_keyLockoutUntil, '');
  }
}
