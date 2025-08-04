import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../services/auth_service.dart';
import '../profile/edit_profile_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  String _selectedGender = 'Male';
  String _selectedCurrency = 'PKR';
  String _selectedCountry = 'Pakistan';
  String _selectedCountryCode = '+92';
  bool _isLoading = false;

  void _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final name = _nameController.text.trim();
        final fullName = _fullNameController.text.trim();
        final email = _emailController.text.trim();
        final password = _passwordController.text.trim();
        final phone =
            '$_selectedCountryCode ${_phoneNumberController.text.trim()}';
        final currency = _selectedCurrency;
        final gender = _selectedGender;
        final country = _selectedCountry;

        final User? user = await _authService.signUpWithEmail(email, password);

        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
                'uid': user.uid,
                'email': email,
                'name': name,
                'fullName': fullName,
                'gender': gender,
                'phoneNumber': phone,
                'currency': currency,
                'country': country,
              });

          if (!mounted) return;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const EditProfileScreen()),
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Signup failed. Please try again.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.toString())));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Sign Up', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Create your SettleEase account',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),

              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Enter your name'
                            : null,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _fullNameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                dropdownColor: Colors.black,
                value: _selectedGender,
                items:
                    ['Male', 'Female', 'Other']
                        .map(
                          (gender) => DropdownMenuItem(
                            value: gender,
                            child: Text(
                              gender,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                        .toList(),
                onChanged:
                    (value) =>
                        setState(() => _selectedGender = value ?? 'Male'),
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Please enter your email'
                            : null,
              ),
              const SizedBox(height: 20),

              IntlPhoneField(
                style: const TextStyle(color: Colors.white),
                dropdownTextStyle: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                initialCountryCode: _selectedCountryCode.replaceAll('+', ''),
                onChanged: (phone) {
                  _selectedCountryCode = '+${phone.countryCode}';
                  _phoneNumberController.text = phone.number;
                },
              ),
              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                dropdownColor: Colors.black,
                value: _selectedCountry,
                items:
                    [
                          'Pakistan',
                          'India',
                          'USA',
                          'UK',
                          'UAE',
                          'Germany',
                          'Canada',
                        ]
                        .map(
                          (country) => DropdownMenuItem(
                            value: country,
                            child: Text(
                              country,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                        .toList(),
                onChanged:
                    (value) =>
                        setState(() => _selectedCountry = value ?? 'Pakistan'),
                decoration: const InputDecoration(
                  labelText: 'Country',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                dropdownColor: Colors.black,
                value: _selectedCurrency,
                items:
                    ['PKR', 'USD', 'EUR', 'INR', 'GBP', 'AED']
                        .map(
                          (currency) => DropdownMenuItem(
                            value: currency,
                            child: Text(
                              currency,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                        .toList(),
                onChanged:
                    (value) =>
                        setState(() => _selectedCurrency = value ?? 'PKR'),
                decoration: const InputDecoration(
                  labelText: 'Preferred Currency',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                validator:
                    (value) =>
                        value != null && value.length < 6
                            ? 'Password must be at least 6 characters'
                            : null,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                validator:
                    (value) =>
                        value != _passwordController.text
                            ? 'Passwords do not match'
                            : null,
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _isLoading ? null : _signup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
