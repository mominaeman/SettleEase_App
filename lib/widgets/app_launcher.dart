import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../screens/auth/login_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/groups/groups_screen.dart';
import '../screens/expenses/expenses_screen.dart';

import '../providers/general_preferences_provider.dart';

class AppLauncher extends StatelessWidget {
  const AppLauncher({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final prefs = Provider.of<GeneralPreferencesProvider>(
      context,
      listen: true,
    );

    if (user == null) {
      return const LoginScreen();
    }

    final homeScreen = prefs.defaultHomeScreen;

    switch (homeScreen) {
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
