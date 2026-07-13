import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure local storage using platform-native encryption.
/// Mirrors the API from boss_app's SecureStorage for consistency.
class SecureStorage {
  SecureStorage._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  static Future<void> saveString(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  static Future<String?> getString(String key) async {
    return await _storage.read(key: key);
  }

  static Future<void> saveBool(String key, bool value) async {
    await _storage.write(key: key, value: value.toString());
  }

  static Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final raw = await _storage.read(key: key);
    if (raw == null) return defaultValue;
    return raw == 'true';
  }

  static Future<void> remove(String key) async {
    await _storage.delete(key: key);
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
