// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:settleease/screens/home/home_screen.dart';
import 'package:settleease/screens/auth/login_screen.dart';
import 'package:settleease/providers/theme_provider.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// ✅ Sign up with email and password
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        throw FirebaseAuthException(
          code: 'empty-fields',
          message: 'Email and password are required.',
        );
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw FirebaseAuthException(
          code: 'null-user',
          message: 'Signup failed. User is null.',
        );
      }

      debugPrint("✅ Signed up: ${credential.user!.email}");
      return credential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint("❌ Signup error: ${e.code} - ${e.message}");
      throw Exception(_getSignupErrorMessage(e));
    } catch (e) {
      debugPrint("❌ Unexpected signup error: $e");
      throw Exception("Unexpected signup error: ${e.toString()}");
    }
  }

  /// ✅ Login user
  Future<void> loginUser(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        throw FirebaseAuthException(
          code: 'empty-fields',
          message: 'Email and password are required.',
        );
      }

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null || credential.user!.email == null) {
        throw FirebaseAuthException(
          code: 'null-user',
          message: 'Login failed. User is null.',
        );
      }

      debugPrint("✅ Logged in: ${credential.user!.email}");

      // Load user settings
      await Provider.of<ThemeProvider>(
        context,
        listen: false,
      ).loadUserSettings();

      if (!context.mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Login Successful")));
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_getLoginErrorMessage(e))));
    } catch (e) {
      debugPrint("❌ Unexpected login error: $e");
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Unexpected error: ${e.toString()}")),
      );
    }
  }

  /// ✅ Password Reset
  Future<void> resetPassword(String email) async {
    if (email.isEmpty) {
      throw FirebaseAuthException(
        code: 'empty-email',
        message: 'Email is required to reset password.',
      );
    }

    await _auth.sendPasswordResetEmail(email: email);
    debugPrint("📧 Password reset email sent to: $email");
  }

  /// ✅ Sign out
  Future<void> signOut(BuildContext context) async {
    await _auth.signOut();
    debugPrint("👋 User signed out");

    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  /// ✅ Google Sign-In
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // Cancelled by user

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);

      debugPrint("✅ Google Sign-In successful");

      // Load user settings
      await Provider.of<ThemeProvider>(
        context,
        listen: false,
      ).loadUserSettings();

      if (!context.mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login with Google Successful")),
      );
    } catch (e) {
      debugPrint("❌ Google Sign-In error: $e");
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Sign-In failed: ${e.toString()}")),
      );
    }
  }

  /// ✅ Login error messages
  String _getLoginErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return "No user found with this email.";
      case 'wrong-password':
        return "Incorrect password.";
      case 'invalid-credential':
        return "Invalid login credentials.";
      case 'empty-fields':
        return "Please enter email and password.";
      default:
        return "Login failed: ${e.message}";
    }
  }

  /// ✅ Signup error messages
  String _getSignupErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return "Email already in use.";
      case 'invalid-email':
        return "Invalid email format.";
      case 'weak-password':
        return "Password should be at least 6 characters.";
      case 'empty-fields':
        return "Please enter email and password.";
      default:
        return "Signup failed: ${e.message}";
    }
  }
}
