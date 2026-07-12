import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/storage/secure_storage.dart';

/// Theme provider managing light/dark mode state.
/// Default is always Light Mode. Users can manually toggle to Dark Mode.
/// Preference is persisted across app restarts.
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false; // Always starts as light mode

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  /// Load saved theme preference. Call once at startup.
  Future<void> loadTheme() async {
    _isDarkMode = await SecureStorage.getBool(
      AppConstants.keyIsDarkMode,
      defaultValue: false, // Default: always Light Mode
    );
    notifyListeners();
  }

  /// Toggle between light and dark mode.
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await SecureStorage.saveBool(AppConstants.keyIsDarkMode, _isDarkMode);
    notifyListeners();
  }

  /// Set a specific theme mode.
  Future<void> setDarkMode(bool value) async {
    if (_isDarkMode == value) return;
    _isDarkMode = value;
    await SecureStorage.saveBool(AppConstants.keyIsDarkMode, _isDarkMode);
    notifyListeners();
  }
}
