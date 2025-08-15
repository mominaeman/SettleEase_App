import 'package:flutter/material.dart';
import 'package:settleease/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ Added

enum FontSizeOption { small, medium, large }

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  FontSizeOption _fontSize = FontSizeOption.medium;
  bool _autoLogin = false;
  bool _isLoaded = false; // ✅ Tracks if settings have been loaded

  ThemeMode get themeMode => _themeMode;
  FontSizeOption get fontSize => _fontSize;
  bool get autoLogin => _autoLogin;
  bool get isLoaded => _isLoaded; // ✅ Expose loading state

  /// Load settings from local storage first, then Firestore
  Future<void> loadUserSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // ✅ Load from local cache first
    final localTheme = prefs.getString('themeMode');
    final localFont = prefs.getString('fontSize');
    final localAutoLogin = prefs.getBool('autoLogin');

    if (localTheme != null) {
      _themeMode = localTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
    }
    if (localFont != null) {
      switch (localFont) {
        case 'small':
          _fontSize = FontSizeOption.small;
          break;
        case 'large':
          _fontSize = FontSizeOption.large;
          break;
        default:
          _fontSize = FontSizeOption.medium;
      }
    }
    if (localAutoLogin != null) {
      _autoLogin = localAutoLogin;
    }

    // ✅ Load from Firestore to sync latest
    final settings = await SettingsService().loadSettings();
    if (settings != null) {
      _themeMode =
          settings['theme'] == 'dark' ? ThemeMode.dark : ThemeMode.light;

      switch (settings['fontSize']) {
        case 'small':
          _fontSize = FontSizeOption.small;
          break;
        case 'large':
          _fontSize = FontSizeOption.large;
          break;
        default:
          _fontSize = FontSizeOption.medium;
      }

      _autoLogin = settings['autoLogin'] ?? false;
    }

    _isLoaded = true;
    notifyListeners();
  }

  /// Toggle between light and dark theme
  Future<void> toggleTheme(bool isDarkMode) async {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    await _saveSettings();
  }

  /// Update font size
  Future<void> setFontSize(FontSizeOption size) async {
    _fontSize = size;
    notifyListeners();
    await _saveSettings();
  }

  /// ✅ New method to match drawer call
  void setTextScaleFactor(double scale) {
    if (scale <= 0.9) {
      _fontSize = FontSizeOption.small;
    } else if (scale >= 1.1) {
      _fontSize = FontSizeOption.large;
    } else {
      _fontSize = FontSizeOption.medium;
    }
    notifyListeners();
    _saveSettings();
  }

  /// Update auto-login preference
  Future<void> setAutoLogin(bool value) async {
    _autoLogin = value;
    notifyListeners();
    await _saveSettings();
  }

  /// Get text scaling factor
  double get textScaleFactor {
    switch (_fontSize) {
      case FontSizeOption.small:
        return 0.8;
      case FontSizeOption.medium:
        return 1.0;
      case FontSizeOption.large:
        return 1.2;
    }
  }

  /// Save current settings permanently to Firestore & local storage
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // ✅ Save to local storage
    await prefs.setString(
      'themeMode',
      _themeMode == ThemeMode.dark ? 'dark' : 'light',
    );
    await prefs.setString(
      'fontSize',
      _fontSize == FontSizeOption.small
          ? 'small'
          : _fontSize == FontSizeOption.large
          ? 'large'
          : 'medium',
    );
    await prefs.setBool('autoLogin', _autoLogin);

    // ✅ Save to Firestore
    await SettingsService().saveSettings(
      theme: _themeMode == ThemeMode.dark ? 'dark' : 'light',
      fontSize:
          _fontSize == FontSizeOption.small
              ? 'small'
              : _fontSize == FontSizeOption.large
              ? 'large'
              : 'medium',
      autoLogin: _autoLogin,
    );
  }
}
