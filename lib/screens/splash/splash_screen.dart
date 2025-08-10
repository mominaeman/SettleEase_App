import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF000000), Color(0xFF1A1A1A)], // Dark gradient
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo image
            Image.asset('assets/images/logo.png', width: 120, height: 120),
            const SizedBox(height: 20),

            // App Name
            Text(
              'SettleEase',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            // Loading spinner
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),

            const SizedBox(height: 20),
            const Text(
              'Loading your preferences...',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
