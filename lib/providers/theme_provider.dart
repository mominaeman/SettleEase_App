// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';

enum FontSizeOption { small, medium, large }

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  FontSizeOption _fontSize = FontSizeOption.medium;

  ThemeMode get themeMode => _themeMode;
  FontSizeOption get fontSize => _fontSize;

  void toggleTheme(bool isDarkMode) {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setFontSize(FontSizeOption size) {
    _fontSize = size;
    notifyListeners();
  }

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
}
