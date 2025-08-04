import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isGoogle;

  const AuthButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isGoogle = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: isGoogle ? Colors.white : Colors.blue,
          foregroundColor: isGoogle ? Colors.black : Colors.white,
        ),
        icon:
            isGoogle
                ? Image.asset(
                  'assets/google_icon.png',
                  height: 24,
                ) // Optional icon
                : const SizedBox.shrink(),
        label: Text(text),
        onPressed: onPressed,
      ),
    );
  }
}
