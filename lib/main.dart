import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/groups/groups_screen.dart';
import 'screens/expenses/expenses_screen.dart';
import 'screens/settings/session_management_screen.dart';
import 'screens/splash/splash_screen.dart';

import 'providers/general_preferences_provider.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final generalPrefsProvider = GeneralPreferencesProvider();
  await generalPrefsProvider.loadPreferences();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider<GeneralPreferencesProvider>.value(
          value: generalPrefsProvider,
        ),
      ],
      child: const SettleEaseApp(),
    ),
  );
}

class SettleEaseApp extends StatefulWidget {
  const SettleEaseApp({super.key});

  @override
  State<SettleEaseApp> createState() => _SettleEaseAppState();
}

class _SettleEaseAppState extends State<SettleEaseApp> {
  bool _initialized = false;
  bool _isLoggedIn = false;
  bool _autoLogin = false;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    // Load theme & user settings from Firestore
    await themeProvider.loadUserSettings();

    final user = FirebaseAuth.instance.currentUser;
    _isLoggedIn = user != null;
    _autoLogin = themeProvider.autoLogin;

    // Simulate splash delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (!_initialized) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      );
    }

    return MaterialApp(
      title: 'SettleEase',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        primaryColor: Colors.black,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          labelStyle: TextStyle(color: Colors.black),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black87),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.white,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          labelStyle: TextStyle(color: Colors.white),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(themeProvider.textScaleFactor),
          ),
          child: child!,
        );
      },
      home:
          (_isLoggedIn && _autoLogin)
              ? const AppLauncher()
              : const LoginScreen(),
      routes: {
        '/session-management': (context) => const SessionManagementScreen(),
      },
    );
  }
}

class AppLauncher extends StatelessWidget {
  const AppLauncher({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<GeneralPreferencesProvider>(context);

    switch (prefs.defaultHomeScreen) {
      case 'Groups':
        return const GroupsScreen();
      case 'Expenses':
        return const ExpensesScreen();
      case 'Dashboard':
      default:
        return const HomeScreen();
    }
  }
}
