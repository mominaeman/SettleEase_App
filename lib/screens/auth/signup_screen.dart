import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../home/home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  String selectedGender = 'Male';
  String selectedCurrency = 'PKR';
  String selectedCountry = 'Pakistan';
  String selectedCountryCode = '+92';

  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  void _signup() async {
    if (_formKey.currentState!.validate()) {
      if (passwordController.text != confirmPasswordController.text) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
        return;
      }

      final user = await _authService.registerUser(
        context,
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (user != null) {
        final userModel = UserModel(
          uid: user.uid,
          email: emailController.text.trim(),
          name: nameController.text.trim(),
          currency: selectedCurrency,
          fullName: fullNameController.text.trim(),
          gender: selectedGender,
          phoneNumber:
              '$selectedCountryCode ${phoneNumberController.text.trim()}',
          country: selectedCountry, // ✅ Added
          photoUrl: null, // ✅ Optional: If you're adding profile pictures later
        );

        await _firestoreService.createOrUpdateUser(userModel);

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'SettleEase',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: fullNameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedGender,
                    items:
                        ['Male', 'Female', 'Other']
                            .map(
                              (gender) => DropdownMenuItem(
                                value: gender,
                                child: Text(gender),
                              ),
                            )
                            .toList(),
                    onChanged:
                        (value) => setState(() => selectedGender = value!),
                    decoration: const InputDecoration(labelText: 'Gender'),
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator:
                        (value) =>
                            value!.isEmpty || !value.contains('@')
                                ? 'Enter valid email'
                                : null,
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          value: selectedCountryCode,
                          items:
                              ['+92', '+91', '+1', '+44']
                                  .map(
                                    (code) => DropdownMenuItem(
                                      value: code,
                                      child: Text(code),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (value) =>
                                  setState(() => selectedCountryCode = value!),
                          decoration: const InputDecoration(labelText: 'Code'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 5,
                        child: TextFormField(
                          controller: phoneNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                          ),
                          validator:
                              (value) =>
                                  value!.isEmpty ? 'Enter phone number' : null,
                        ),
                      ),
                    ],
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedCountry,
                    items:
                        ['Pakistan', 'India', 'USA', 'UK', 'UAE']
                            .map(
                              (country) => DropdownMenuItem(
                                value: country,
                                child: Text(country),
                              ),
                            )
                            .toList(),
                    onChanged:
                        (value) => setState(() => selectedCountry = value!),
                    decoration: const InputDecoration(labelText: 'Country'),
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedCurrency,
                    items:
                        ['PKR', 'USD', 'EUR', 'INR', 'GBP', 'AED']
                            .map(
                              (currency) => DropdownMenuItem(
                                value: currency,
                                child: Text(currency),
                              ),
                            )
                            .toList(),
                    onChanged:
                        (value) => setState(() => selectedCurrency = value!),
                    decoration: const InputDecoration(
                      labelText: 'Preferred Currency',
                    ),
                  ),
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator:
                        (value) =>
                            value!.length < 6 ? 'Minimum 6 characters' : null,
                  ),
                  TextFormField(
                    controller: confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                    ),
                    obscureText: true,
                    validator:
                        (value) => value!.isEmpty ? 'Re-enter password' : null,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _signup,
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
