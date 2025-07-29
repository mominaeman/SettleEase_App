import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/auth_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final AuthService _authService = AuthService();

  void _resetPassword() {
    _authService.resetPassword(context, emailController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Reset Password', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 30),
              CustomTextField(controller: emailController, hintText: 'Email'),
              const SizedBox(height: 20),
              AuthButton(text: 'Send Reset Email', onPressed: _resetPassword),
            ],
          ),
        ),
      ),
    );
  }
}
