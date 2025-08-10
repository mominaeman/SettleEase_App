import 'package:flutter/material.dart';
import 'package:settleease/services/settings_service.dart';

enum FontSizeOption { small, medium, large }

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  FontSizeOption _fontSize = FontSizeOption.medium;
  bool _autoLogin = false;

  ThemeMode get themeMode => _themeMode;
  FontSizeOption get fontSize => _fontSize;
  bool get autoLogin => _autoLogin;

  // Load settings from Firestore
  Future<void> loadUserSettings() async {
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
      notifyListeners();
    }
  }

  // Change theme + save
  Future<void> toggleTheme(bool isDarkMode) async {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    await _saveSettings();
    notifyListeners();
  }

  // Change font size + save
  Future<void> setFontSize(FontSizeOption size) async {
    _fontSize = size;
    await _saveSettings();
    notifyListeners();
  }

  // Change auto-login + save
  Future<void> setAutoLogin(bool value) async {
    _autoLogin = value;
    await _saveSettings();
    notifyListeners();
  }

  // Get scale factor for UI
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

  // Save current settings to Firestore
  Future<void> _saveSettings() async {
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
