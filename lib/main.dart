import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/groups/groups_screen.dart';
import 'screens/expenses/expenses_screen.dart';
import 'screens/settings/session_management_screen.dart'; // ✅ NEW

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

class SettleEaseApp extends StatelessWidget {
  const SettleEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

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
      home: const AppLauncher(),

      // ✅ Add named routes here
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
    final user = FirebaseAuth.instance.currentUser;
    final prefs = Provider.of<GeneralPreferencesProvider>(context);

    if (user == null) return const LoginScreen();

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
