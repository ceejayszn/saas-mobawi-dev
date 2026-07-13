import 'dart:convert';
import '../constants/app_constants.dart';
import '../security/crypto_utils.dart';
import '../storage/secure_storage.dart';

enum AuthResultType { success, wrongPassword, locked, error }

class AuthResult {
  final AuthResultType type;
  final String? message;
  final int? remainingSeconds; // For locked state: seconds until unlock
  final int? remainingAttempts; // For wrongPassword: attempts left

  const AuthResult({
    required this.type,
    this.message,
    this.remainingSeconds,
    this.remainingAttempts,
  });

  bool get isSuccess => type == AuthResultType.success;
  bool get isLocked => type == AuthResultType.locked;
}

/// Secure authentication service.
/// - Passwords are stored as SHA-256 salted hashes (never plain text)
/// - Brute-force protection: 5 attempts → 30s lockout (exponential backoff)
/// - Session tokens with 30-minute inactivity timeout
/// - Security questions for password recovery
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  String? _sessionToken;
  DateTime? _sessionExpiry;
  bool _isInitialized = false;

  /// Initialize the auth service. Call once at app startup.
  /// If no password exists, marks as needing first-run setup.
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    final existingHash = await SecureStorage.getString(AppConstants.keyPasswordHash);
    if (existingHash == null || existingHash.isEmpty) {
      // First run — if a default PIN is configured, hash it.
      // Otherwise, the app must present a first-run PIN setup screen.
      if (AppConstants.defaultAdminPin.isNotEmpty) {
        await _setPasswordInternal(AppConstants.defaultAdminPin, isPrimary: true);
      }
      // When defaultAdminPin is empty, isFirstRun will return true.
    }
  }

  /// Returns true if the user has never set a PIN (first-run state).
  Future<bool> isFirstRun() async {
    final existingHash = await SecureStorage.getString(AppConstants.keyPasswordHash);
    return existingHash == null || existingHash.isEmpty;
  }

  /// Sets the initial PIN during first-run setup. Returns null on success.
  Future<String?> createInitialPin({
    required String newPin,
    required String confirmPin,
  }) async {
    if (newPin.length < AppConstants.minPinLength) {
      return 'PIN must be at least ${AppConstants.minPinLength} digits.';
    }
    if (newPin != confirmPin) {
      return 'PINs do not match.';
    }
    await _setPasswordInternal(newPin, isPrimary: true);
    return null; // Success
  }

  // ── Login ────────────────────────────────────────────────────────────────

  /// Attempts login with the given PIN.
  /// Returns an [AuthResult] describing the outcome.
  Future<AuthResult> attemptLogin(String pin) async {
    // Check lockout
    final lockoutResult = await _checkLockout();
    if (lockoutResult != null) return lockoutResult;

    // Validate input
    final sanitized = CryptoUtils.sanitizeInput(pin);
    if (sanitized.isEmpty || sanitized.length < AppConstants.minPinLength) {
      return const AuthResult(
        type: AuthResultType.wrongPassword,
        message: 'Invalid PIN format.',
        remainingAttempts: AppConstants.maxLoginAttempts,
      );
    }

    // Verify against primary password
    final isPrimary = await _verifyPin(sanitized, isPrimary: true);
    final isSecondary = !isPrimary && await _verifyPin(sanitized, isPrimary: false);

    if (isPrimary || isSecondary) {
      await _onLoginSuccess();
      return const AuthResult(type: AuthResultType.success);
    }

    // Failed attempt
    return await _onLoginFailure();
  }

  Future<AuthResult?> _checkLockout() async {
    final lockoutUntilStr = await SecureStorage.getString(AppConstants.keyLockoutUntil);
    if (lockoutUntilStr != null && lockoutUntilStr.isNotEmpty) {
      final lockoutUntil = DateTime.tryParse(lockoutUntilStr);
      if (lockoutUntil != null && DateTime.now().isBefore(lockoutUntil)) {
        final remaining = lockoutUntil.difference(DateTime.now()).inSeconds;
        return AuthResult(
          type: AuthResultType.locked,
          message: 'Too many failed attempts. Try again in $remaining seconds.',
          remainingSeconds: remaining,
        );
      } else {
        // Lockout expired — clear it
        await SecureStorage.saveString(AppConstants.keyLockoutUntil, '');
        await SecureStorage.saveString(AppConstants.keyFailedAttempts, '0');
      }
    }
    return null;
  }

  Future<bool> _verifyPin(String pin, {required bool isPrimary}) async {
    final hashKey = isPrimary
        ? AppConstants.keyPasswordHash
        : AppConstants.keySecondaryPasswordHash;
    final saltKey = isPrimary
        ? AppConstants.keyPasswordSalt
        : AppConstants.keySecondaryPasswordSalt;

    final storedHash = await SecureStorage.getString(hashKey);
    final salt = await SecureStorage.getString(saltKey);
    if (storedHash == null || salt == null || storedHash.isEmpty || salt.isEmpty) {
      return false;
    }
    return CryptoUtils.verifyPin(pin, storedHash, salt);
  }

  Future<void> _onLoginSuccess() async {
    // Clear failed attempts
    await SecureStorage.saveString(AppConstants.keyFailedAttempts, '0');
    await SecureStorage.saveString(AppConstants.keyLockoutUntil, '');
    // Create session
    _sessionToken = CryptoUtils.generateSessionToken();
    _sessionExpiry = DateTime.now().add(
      const Duration(minutes: AppConstants.sessionTimeoutMinutes),
    );
    await SecureStorage.saveString(AppConstants.keySessionToken, _sessionToken!);
    await SecureStorage.saveString(
      AppConstants.keySessionExpiry,
      _sessionExpiry!.toIso8601String(),
    );
  }

  Future<AuthResult> _onLoginFailure() async {
    final failedStr = await SecureStorage.getString(AppConstants.keyFailedAttempts) ?? '0';
    final failed = (int.tryParse(failedStr) ?? 0) + 1;
    await SecureStorage.saveString(AppConstants.keyFailedAttempts, failed.toString());

    if (failed >= AppConstants.maxLoginAttempts) {
      // Apply exponential backoff: base 30s × 2^(excess over max)
      final excess = failed - AppConstants.maxLoginAttempts;
      final seconds = AppConstants.lockoutDurationSeconds * (1 << excess.clamp(0, 5));
      final lockoutUntil = DateTime.now().add(Duration(seconds: seconds));
      await SecureStorage.saveString(
        AppConstants.keyLockoutUntil,
        lockoutUntil.toIso8601String(),
      );
      return AuthResult(
        type: AuthResultType.locked,
        message: 'Account locked for $seconds seconds.',
        remainingSeconds: seconds,
      );
    }

    final remaining = AppConstants.maxLoginAttempts - failed;
    return AuthResult(
      type: AuthResultType.wrongPassword,
      message: 'Incorrect PIN. $remaining attempt${remaining == 1 ? '' : 's'} remaining.',
      remainingAttempts: remaining,
    );
  }

  // ── Session ───────────────────────────────────────────────────────────────

  /// Returns true if there is a valid active session.
  Future<bool> isSessionValid() async {
    if (_sessionToken == null || _sessionExpiry == null) {
      // Restore from storage
      _sessionToken = await SecureStorage.getString(AppConstants.keySessionToken);
      final expiryStr = await SecureStorage.getString(AppConstants.keySessionExpiry);
      if (expiryStr != null && expiryStr.isNotEmpty) {
        _sessionExpiry = DateTime.tryParse(expiryStr);
      }
    }
    if (_sessionToken == null || _sessionExpiry == null) return false;
    return DateTime.now().isBefore(_sessionExpiry!);
  }

  /// Refreshes the session expiry (call on user interaction).
  Future<void> refreshSession() async {
    if (_sessionToken == null) return;
    _sessionExpiry = DateTime.now().add(
      const Duration(minutes: AppConstants.sessionTimeoutMinutes),
    );
    await SecureStorage.saveString(
      AppConstants.keySessionExpiry,
      _sessionExpiry!.toIso8601String(),
    );
  }

  /// Logs out and clears all session state.
  Future<void> logout() async {
    _sessionToken = null;
    _sessionExpiry = null;
    await SecureStorage.saveString(AppConstants.keySessionToken, '');
    await SecureStorage.saveString(AppConstants.keySessionExpiry, '');
  }

  // ── Password Management ──────────────────────────────────────────────────

  /// Changes the primary or secondary password.
  /// Returns null on success, or an error message string.
  Future<String?> changePassword({
    required String currentPin,
    required String newPin,
    required String confirmPin,
    bool isPrimary = true,
  }) async {
    // Validate new PIN
    if (newPin.length < AppConstants.minPinLength) {
      return 'PIN must be at least ${AppConstants.minPinLength} digits.';
    }
    if (newPin != confirmPin) {
      return 'New PIN and confirmation do not match.';
    }
    // Verify current PIN (only for primary; secondary can be set fresh)
    if (isPrimary) {
      final valid = await _verifyPin(currentPin, isPrimary: true);
      if (!valid) {
        return 'Current PIN is incorrect.';
      }
    }
    await _setPasswordInternal(newPin, isPrimary: isPrimary);
    return null; // Success
  }

  Future<void> _setPasswordInternal(String pin, {required bool isPrimary}) async {
    final salt = CryptoUtils.generateSalt();
    final hash = CryptoUtils.hashPin(pin, salt);
    final hashKey = isPrimary
        ? AppConstants.keyPasswordHash
        : AppConstants.keySecondaryPasswordHash;
    final saltKey = isPrimary
        ? AppConstants.keyPasswordSalt
        : AppConstants.keySecondaryPasswordSalt;
    await SecureStorage.saveString(hashKey, hash);
    await SecureStorage.saveString(saltKey, salt);
  }

  // ── Security Questions ────────────────────────────────────────────────────

  /// Saves security question/answer pairs (answers are hashed).
  Future<void> saveSecurityQuestions(List<MapEntry<String, String>> qaPairs) async {
    final questionsJson = jsonEncode(qaPairs.map((e) => e.key).toList());
    final salt = CryptoUtils.generateSalt();
    final answersJson = jsonEncode(
      qaPairs.map((e) {
        final normalizedAnswer = e.value.toLowerCase().trim();
        return CryptoUtils.hashPin(normalizedAnswer, salt);
      }).toList(),
    );
    await SecureStorage.saveString(AppConstants.keySecurityQuestions, questionsJson);
    await SecureStorage.saveString(AppConstants.keySecurityAnswers, '$salt:$answersJson');
  }

  /// Returns the saved security questions (without answers).
  Future<List<String>> getSecurityQuestions() async {
    final json = await SecureStorage.getString(AppConstants.keySecurityQuestions);
    if (json == null || json.isEmpty) return [];
    try {
      return List<String>.from(jsonDecode(json));
    } catch (_) {
      return [];
    }
  }

  /// Verifies security answers. Returns true if all answers match.
  Future<bool> verifySecurityAnswers(List<String> answers) async {
    final saved = await SecureStorage.getString(AppConstants.keySecurityAnswers);
    if (saved == null || saved.isEmpty) return false;
    try {
      final parts = saved.split(':');
      if (parts.length < 2) return false;
      final salt = parts[0];
      final answersJson = parts.sublist(1).join(':');
      final storedHashes = List<String>.from(jsonDecode(answersJson));
      if (answers.length != storedHashes.length) return false;
      for (int i = 0; i < answers.length; i++) {
        final normalized = answers[i].toLowerCase().trim();
        final hash = CryptoUtils.hashPin(normalized, salt);
        if (hash != storedHashes[i]) return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Resets primary password after successful security question verification.
  Future<String?> resetPasswordWithQuestions({
    required List<String> answers,
    required String newPin,
    required String confirmPin,
  }) async {
    if (newPin != confirmPin) return 'PINs do not match.';
    if (newPin.length < AppConstants.minPinLength) {
      return 'PIN must be at least ${AppConstants.minPinLength} digits.';
    }
    final valid = await verifySecurityAnswers(answers);
    if (!valid) return 'Security answers are incorrect.';
    await _setPasswordInternal(newPin, isPrimary: true);
    // Clear lockout
    await SecureStorage.saveString(AppConstants.keyFailedAttempts, '0');
    await SecureStorage.saveString(AppConstants.keyLockoutUntil, '');
    return null;
  }

  // ── Lockout Info ──────────────────────────────────────────────────────────

  /// Returns remaining lockout seconds, or 0 if not locked.
  Future<int> getLockoutRemainingSeconds() async {
    final lockoutUntilStr = await SecureStorage.getString(AppConstants.keyLockoutUntil);
    if (lockoutUntilStr == null || lockoutUntilStr.isEmpty) return 0;
    final lockoutUntil = DateTime.tryParse(lockoutUntilStr);
    if (lockoutUntil == null || DateTime.now().isAfter(lockoutUntil)) return 0;
    return lockoutUntil.difference(DateTime.now()).inSeconds;
  }
}
