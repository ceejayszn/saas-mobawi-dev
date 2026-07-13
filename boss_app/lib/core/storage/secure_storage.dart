import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure local storage using platform-native encryption.
/// - Android: AES-256 via Android Keystore
/// - iOS: Keychain Services
/// - Windows: Windows Credential Manager (via DPAPI)
/// - Linux: libsecret
/// - macOS: Keychain
///
/// All string values are encrypted at rest.
/// Non-string values (bool, int) are stored as encrypted strings.
class SecureStorage {
  SecureStorage._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // ── String ────────────────────────────────────────────────────────────────

  static Future<void> saveString(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  static Future<String?> getString(String key) async {
    return await _storage.read(key: key);
  }

  // ── Bool ──────────────────────────────────────────────────────────────────

  static Future<void> saveBool(String key, bool value) async {
    await _storage.write(key: key, value: value.toString());
  }

  static Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final raw = await _storage.read(key: key);
    if (raw == null) return defaultValue;
    return raw == 'true';
  }

  // ── Int ───────────────────────────────────────────────────────────────────

  static Future<void> saveInt(String key, int value) async {
    await _storage.write(key: key, value: value.toString());
  }

  static Future<int> getInt(String key, {int defaultValue = 0}) async {
    final raw = await _storage.read(key: key);
    if (raw == null) return defaultValue;
    return int.tryParse(raw) ?? defaultValue;
  }

  // ── Clear ─────────────────────────────────────────────────────────────────

  static Future<void> remove(String key) async {
    await _storage.delete(key: key);
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
