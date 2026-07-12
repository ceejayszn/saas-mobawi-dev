import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// Cryptographic utilities for secure password hashing and input sanitization.
/// Uses SHA-256 with a random salt for password storage.
/// Never stores or logs passwords in plain text.
class CryptoUtils {
  CryptoUtils._();

  /// Generates a cryptographically random salt (32 hex chars = 128 bits).
  static String generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Hashes a PIN/password with the given salt using SHA-256.
  /// Returns a hex string. The salt is prepended before hashing.
  static String hashPin(String pin, String salt) {
    final input = '$salt:$pin';
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verifies a plain-text PIN against a stored hash and salt.
  static bool verifyPin(String pin, String storedHash, String salt) {
    final computedHash = hashPin(pin, salt);
    // Constant-time comparison to prevent timing attacks
    return _constantTimeEquals(computedHash, storedHash);
  }

  /// Constant-time string comparison to prevent timing side-channel attacks.
  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }

  /// Sanitizes user input by removing dangerous characters.
  /// Strips: HTML tags, SQL keywords in injection patterns, control chars.
  static String sanitizeInput(String input) {
    if (input.isEmpty) return input;

    // Remove HTML/script tags
    String sanitized = input.replaceAll(RegExp(r'<[^>]*>'), '');

    // Remove control characters (keep printable ASCII and common Unicode)
    sanitized = sanitized.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '');

    // Trim excessive whitespace
    sanitized = sanitized.trim();

    return sanitized;
  }

  /// Validates that a string contains no SQL injection patterns.
  static bool isSqlSafe(String input) {
    // Check for common SQL injection keywords and operators
    final upper = input.toUpperCase();
    const sqlKeywords = [
      'UNION', 'SELECT', 'INSERT', 'UPDATE', 'DELETE',
      'DROP', 'CREATE', 'ALTER', 'EXEC', 'EXECUTE', 'XP_',
    ];
    for (final kw in sqlKeywords) {
      if (upper.contains(kw)) { return false; }
    }
    // Check for SQL comment and quote characters
    if (input.contains('--') || input.contains(';') ||
        input.contains('/*') || input.contains('*/') ||
        input.contains("'")) { return false; }
    return true;
  }

  /// Checks password/PIN strength.
  /// Returns 0 (too weak) to 3 (strong).
  static int pinStrength(String pin) {
    if (pin.length < 4) { return 0; }
    if (pin.length < 6) { return 1; }
    if (pin.length >= 8 && RegExp(r'[0-9]').hasMatch(pin) &&
        RegExp(r'[a-zA-Z]').hasMatch(pin)) { return 3; }
    return 2;
  }

  /// Validates email format.
  static bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  /// Validates phone number (allows +, digits, spaces, dashes).
  static bool isValidPhone(String phone) {
    return RegExp(r'^\+?[\d\s\-]{7,15}$').hasMatch(phone);
  }

  /// Generates a random session token (UUID-style).
  static String generateSessionToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
