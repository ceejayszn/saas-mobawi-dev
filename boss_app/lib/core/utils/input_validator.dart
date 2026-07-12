import '../constants/app_constants.dart';
import '../security/crypto_utils.dart';

/// Centralized input validation for all form fields in the app.
/// All methods return null on success, or a human-readable error string.
class InputValidator {
  InputValidator._();

  static String? validatePin(String? value) {
    if (value == null || value.isEmpty) return 'PIN is required.';
    final trimmed = value.trim();
    if (trimmed.length < AppConstants.minPinLength) {
      return 'PIN must be at least ${AppConstants.minPinLength} characters.';
    }
    if (trimmed.length > AppConstants.maxPinLength) {
      return 'PIN cannot exceed ${AppConstants.maxPinLength} characters.';
    }
    return null;
  }

  static String? validateBusinessName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Business name is required.';
    final trimmed = value.trim();
    if (trimmed.length > AppConstants.maxBusinessNameLength) {
      return 'Business name is too long.';
    }
    if (!CryptoUtils.isSqlSafe(trimmed)) {
      return 'Business name contains invalid characters.';
    }
    if (RegExp(r'[<>{}]').hasMatch(trimmed)) {
      return 'Business name contains invalid characters.';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Optional
    if (!CryptoUtils.isValidPhone(value.trim())) {
      return 'Enter a valid phone number.';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Optional
    if (!CryptoUtils.isValidEmail(value.trim())) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required.';
    if (value.trim().length > AppConstants.maxInputLength) {
      return '$fieldName is too long.';
    }
    return null;
  }

  static String? validateOptionalText(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length > AppConstants.maxInputLength) {
      return '$fieldName is too long.';
    }
    if (!CryptoUtils.isSqlSafe(value)) {
      return '$fieldName contains invalid characters.';
    }
    return null;
  }

  static String? validateDisplayName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required.';
    if (value.trim().length < 2) return 'Name must be at least 2 characters.';
    if (value.trim().length > 50) return 'Name is too long.';
    if (RegExp(r'[<>{}\/\\]').hasMatch(value)) return 'Name contains invalid characters.';
    return null;
  }

  static String? validateSecurityAnswer(String? value) {
    if (value == null || value.trim().isEmpty) return 'Answer is required.';
    if (value.trim().length < 2) return 'Answer is too short.';
    if (value.trim().length > 100) return 'Answer is too long.';
    return null;
  }

  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Optional
    final url = value.trim().toLowerCase();
    if (!url.startsWith('http://') && !url.startsWith('https://') && !url.contains('.')) {
      return 'Enter a valid website URL.';
    }
    return null;
  }
}
