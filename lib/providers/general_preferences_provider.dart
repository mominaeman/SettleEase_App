import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum HomeScreenOption { dashboard, groups, expenses }

class GeneralPreferencesProvider with ChangeNotifier {
  HomeScreenOption _defaultHome = HomeScreenOption.dashboard;
  bool _autoLogin = false;
  bool _biometricLogin = false;

  // Getter used in main.dart & app_launcher.dart

  String get defaultHomeScreen {
    switch (_defaultHome) {
      case HomeScreenOption.groups:
        return 'Groups';
      case HomeScreenOption.expenses:
        return 'Expenses';
      case HomeScreenOption.dashboard:
        return 'Dashboard';
    }
  }

  HomeScreenOption get defaultHome => _defaultHome;
  bool get autoLogin => _autoLogin;
  bool get biometricLogin => _biometricLogin;

  GeneralPreferencesProvider() {
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _defaultHome = HomeScreenOption.values[prefs.getInt('defaultHome') ?? 0];
    _autoLogin = prefs.getBool('autoLogin') ?? false;
    _biometricLogin = prefs.getBool('biometricLogin') ?? false;
    notifyListeners();
  }

  Future<void> setDefaultHome(HomeScreenOption option) async {
    _defaultHome = option;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('defaultHome', option.index);
    notifyListeners();
  }

  Future<void> toggleAutoLogin(bool value) async {
    _autoLogin = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoLogin', value);
    notifyListeners();
  }

  Future<void> toggleBiometricLogin(bool value) async {
    _biometricLogin = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometricLogin', value);
    notifyListeners();
  }
}
