import 'package:shared_preferences/shared_preferences.dart';

/// Secure local storage wrapper around SharedPreferences.
/// Provides a consistent API for reading/writing sensitive app data.
/// Values are stored with a simple obfuscation layer.
/// Future upgrade path: replace with flutter_secure_storage for keychain/keystore.
class SecureStorage {
  SecureStorage._();

  static SharedPreferences? _prefs;

  static Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ── Basic obfuscation ─────────────────────────────────────────────────────
  // XOR with a fixed key for basic obfuscation. Not cryptographic — intended
  // only as a deterrence layer against casual plaintext reads of the prefs file.
  // Sensitive data like password hashes are ALSO protected by their own crypto.
  static const int _obfKey = 0x4D; // 'M' for MOBAWI

  static String _obfuscate(String input) {
    return input.codeUnits.map((c) => c ^ _obfKey).join(',');
  }

  static String _deobfuscate(String input) {
    try {
      final parts = input.split(',');
      return String.fromCharCodes(parts.map((p) => int.parse(p) ^ _obfKey));
    } catch (_) {
      return input; // Return raw if deobfuscation fails (legacy data)
    }
  }

  // ── String ────────────────────────────────────────────────────────────────

  static Future<void> saveString(String key, String value) async {
    final prefs = await _instance;
    await prefs.setString(key, _obfuscate(value));
  }

  static Future<String?> getString(String key) async {
    final prefs = await _instance;
    final raw = prefs.getString(key);
    if (raw == null) return null;
    return _deobfuscate(raw);
  }

  // ── Bool ──────────────────────────────────────────────────────────────────

  static Future<void> saveBool(String key, bool value) async {
    final prefs = await _instance;
    await prefs.setBool(key, value);
  }

  static Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final prefs = await _instance;
    return prefs.getBool(key) ?? defaultValue;
  }

  // ── Int ───────────────────────────────────────────────────────────────────

  static Future<void> saveInt(String key, int value) async {
    final prefs = await _instance;
    await prefs.setInt(key, value);
  }

  static Future<int> getInt(String key, {int defaultValue = 0}) async {
    final prefs = await _instance;
    return prefs.getInt(key) ?? defaultValue;
  }

  // ── Clear ─────────────────────────────────────────────────────────────────

  static Future<void> remove(String key) async {
    final prefs = await _instance;
    await prefs.remove(key);
  }

  static Future<void> clearAll() async {
    final prefs = await _instance;
    await prefs.clear();
  }
}
