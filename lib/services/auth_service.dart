// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:settleease/providers/theme_provider.dart';
import 'package:settleease/screens/auth/login_screen.dart';
import 'package:settleease/screens/navigation/main_navigation_screen.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// ✅ Public email validation method
  bool isValidEmail(String email) {
    return RegExp(
      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+$",
    ).hasMatch(email.trim());
  }

  /// ✅ Sign up with email and password
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      if (!isValidEmail(email)) {
        throw FirebaseAuthException(
          code: 'invalid-email',
          message: 'Please enter a valid email address.',
        );
      }
      if (email.isEmpty || password.isEmpty) {
        throw FirebaseAuthException(
          code: 'empty-fields',
          message: 'Email and password are required.',
        );
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
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

  /// ✅ Login user with strict validation
  Future<void> loginUser(
    BuildContext context,
    String email,
    String password,
  ) async {
    if (!isValidEmail(email)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid email format.")));
      return;
    }
    if (email.isEmpty || password.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email and password.")),
      );
      return;
    }

    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (!context.mounted) return;
      await Provider.of<ThemeProvider>(
        context,
        listen: false,
      ).loadUserSettings();

      if (!context.mounted) return; // ✅ added check
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );

      if (!context.mounted) return; // ✅ added check
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Login Successful")));
    } on FirebaseAuthException catch (e) {
      debugPrint("❌ Login error: ${e.code} - ${e.message}");
      if (!context.mounted) return;

      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = "No account found with this email.";
          break;
        case 'wrong-password':
          errorMessage = "Incorrect password.";
          break;
        case 'invalid-email':
          errorMessage = "Invalid email format.";
          break;
        default:
          errorMessage = "Login failed: ${e.message}";
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      debugPrint("❌ Unexpected login error: $e");
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Unexpected error: ${e.toString()}")),
      );
    }
  }

  /// ✅ Auto-login check
  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }

  /// ✅ Password Reset
  Future<void> resetPassword(String email) async {
    if (!isValidEmail(email)) {
      throw FirebaseAuthException(
        code: 'invalid-email',
        message: 'Please enter a valid email address.',
      );
    }
    await _auth.sendPasswordResetEmail(email: email.trim());
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
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // Cancelled by user

      final googleAuth = await googleUser.authentication;

      await _auth.signInWithCredential(
        GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        ),
      );

      debugPrint("✅ Google Sign-In successful");

      if (!context.mounted) return;
      await Provider.of<ThemeProvider>(
        context,
        listen: false,
      ).loadUserSettings();

      if (!context.mounted) return; // ✅ added check
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );

      if (!context.mounted) return; // ✅ added check
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
