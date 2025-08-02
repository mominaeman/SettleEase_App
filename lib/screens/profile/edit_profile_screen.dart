import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';
import '../../models/user_model.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController countryController = TextEditingController();

  String selectedGender = 'Male';
  String selectedCurrency = 'PKR';
  String selectedCountryCode = '+92';

  final FirestoreService _firestoreService = FirestoreService();
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  bool _isDataLoaded = false; // ✅ Added to delay build until data is ready

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userData = await _firestoreService.getUserByUid(user.uid);
    if (userData != null) {
      nameController.text = userData.name ?? '';
      fullNameController.text = userData.fullName ?? '';
      emailController.text = userData.email ?? '';

      final rawPhone = userData.phoneNumber ?? '';
      selectedCountryCode = RegExp(r'^(\+\d+)').stringMatch(rawPhone) ?? '+92';
      phoneNumberController.text = rawPhone.replaceAll(
        RegExp(r'^\+\d+\s*'),
        '',
      );

      selectedGender = userData.gender ?? 'Male';
      selectedCurrency = userData.currency ?? 'PKR';
      countryController.text = userData.country ?? '';
    }

    setState(() {
      _isDataLoaded = true; // ✅ Mark data as loaded
    });
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final updatedUser = UserModel(
      uid: user.uid,
      email: emailController.text.trim(),
      name: nameController.text.trim(),
      fullName: fullNameController.text.trim(),
      gender: selectedGender,
      phoneNumber: '$selectedCountryCode ${phoneNumberController.text.trim()}',
      currency: selectedCurrency,
      country: countryController.text.trim(),
    );

    await _firestoreService.createOrUpdateUser(updatedUser);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
    Navigator.pop(context);
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 75,
    );
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body:
          _isDataLoaded
              ? Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'SettleEase',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder:
                                  (_) => SafeArea(
                                    child: Wrap(
                                      children: [
                                        ListTile(
                                          leading: const Icon(
                                            Icons.photo_library,
                                          ),
                                          title: const Text(
                                            'Choose from Gallery',
                                          ),
                                          onTap: () {
                                            Navigator.pop(context);
                                            _pickImage(ImageSource.gallery);
                                          },
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.camera_alt),
                                          title: const Text('Take a Photo'),
                                          onTap: () {
                                            Navigator.pop(context);
                                            _pickImage(ImageSource.camera);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                            );
                          },
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                _pickedImage != null
                                    ? FileImage(_pickedImage!)
                                    : const AssetImage(
                                          'assets/default_avatar.png',
                                        )
                                        as ImageProvider,
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(4),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(labelText: 'Name'),
                        ),
                        TextField(
                          controller: fullNameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                          ),
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
                              (value) => setState(
                                () => selectedGender = value ?? 'Male',
                              ),
                          decoration: const InputDecoration(
                            labelText: 'Gender',
                          ),
                        ),
                        TextField(
                          controller: emailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                          readOnly: true,
                        ),
                        IntlPhoneField(
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                          ),
                          initialCountryCode: selectedCountryCode.replaceAll(
                            '+',
                            '',
                          ),
                          initialValue: phoneNumberController.text,
                          onChanged: (phone) {
                            setState(() {
                              selectedCountryCode = '+${phone.countryCode}';
                              phoneNumberController.text = phone.number;
                            });
                          },
                        ),
                        TextField(
                          controller: countryController,
                          decoration: const InputDecoration(
                            labelText: 'Country',
                          ),
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
                              (value) => setState(
                                () => selectedCurrency = value ?? 'PKR',
                              ),
                          decoration: const InputDecoration(
                            labelText: 'Preferred Currency',
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _saveProfile,
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              : const Center(
                child: CircularProgressIndicator(),
              ), // 👈 Show loader while data is loading
    );
  }
}
