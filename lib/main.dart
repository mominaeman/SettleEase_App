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
import 'services/settings_service.dart'; // ✅ Added to access SettingsService
import 'dart:developer' as developer;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final generalPrefsProvider = GeneralPreferencesProvider();
  await generalPrefsProvider.loadPreferences();

  // Initialize ThemeProvider and wait for saved settings
  final themeProvider = ThemeProvider();
  await themeProvider
      .loadUserSettings(); // ensures theme & font are loaded before app start

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ChangeNotifierProvider<GeneralPreferencesProvider>.value(
          value: generalPrefsProvider,
        ),
      ],
      child: const SettleEaseApp(),
    ),
  );
}

class SettleEaseApp extends StatelessWidget {
  const SettleEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      // ✅ Listens for theme & font changes instantly
      builder: (context, themeProvider, child) {
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
          home: const SplashWrapper(),
          routes: {
            '/session-management': (context) => const SessionManagementScreen(),
          },
        );
      },
    );
  }
}

/// SplashWrapper shows splash screen first, then navigates to AuthWrapper
class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  @override
  void initState() {
    super.initState();
    _navigateAfterSplash();
  }

  Future<void> _navigateAfterSplash() async {
    // Load theme & font settings from Firebase before showing AuthWrapper
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    if (!themeProvider.isLoaded) {
      await themeProvider.loadUserSettings(); // ensures persistent theme/font

      // ✅ Debug log: print loaded settings
      final settings = await SettingsService().loadSettings();
      developer.log(
        'Loaded theme: ${settings?['theme']}, font: ${settings?['fontSize']}',
      );
    }

    // Keep splash visible at least 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthWrapper()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen(); // your splash UI remains unchanged
  }
}

/// Handles authentication state changes
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<GeneralPreferencesProvider>(context);

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        switch (prefs.defaultHomeScreen) {
          case 'Groups':
            return const GroupsScreen();
          case 'Expenses':
            return const ExpensesScreen();
          case 'Dashboard':
          default:
            return const HomeScreen();
        }
      },
    );
  }
}
