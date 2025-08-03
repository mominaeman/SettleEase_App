import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/auth_service.dart';
import '../profile/edit_profile_screen.dart';
import '../settings/notification_settings_screen.dart';
import '../settings/privacy_settings_screen.dart';
import '../settings/language_region_settings_screen.dart';
import '../settings/theme_appearance_settings_screen.dart';
import '../settings/general_preferences_screen.dart'; // ✅ New Import
import '../settings/data_security_settings_screen.dart'; // ✅ New Import

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _pickedImage;

  void _signOut(BuildContext context) {
    AuthService().signOut(context);
  }

  void _goToEditProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
    );
  }

  void _goToNotificationSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationSettingsScreen(),
      ),
    );
  }

  void _goToPrivacySettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrivacySettingsScreen()),
    );
  }

  void _goToLanguageRegionSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LanguageRegionSettingsScreen(),
      ),
    );
  }

  void _goToThemeAppearanceSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ThemeAppearanceSettingsScreen(),
      ),
    );
  }

  void _goToGeneralPreferences(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GeneralPreferencesScreen()),
    );
  }

  void _goToDataSecuritySettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DataSecuritySettingsScreen(),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder:
          (_) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo),
                  title: const Text('Choose from Gallery'),
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
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('SettleEase Home')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.black),
              child: Text(
                'SettleEase Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Edit Profile'),
              onTap: () {
                Navigator.pop(context);
                _goToEditProfile(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('General Preferences'),
              onTap: () {
                Navigator.pop(context);
                _goToGeneralPreferences(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Data & Security Settings'),
              onTap: () {
                Navigator.pop(context);
                _goToDataSecuritySettings(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notification Settings'),
              onTap: () {
                Navigator.pop(context);
                _goToNotificationSettings(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Privacy Settings'),
              onTap: () {
                Navigator.pop(context);
                _goToPrivacySettings(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Language & Region'),
              onTap: () {
                Navigator.pop(context);
                _goToLanguageRegionSettings(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.palette),
              title: const Text('Theme & Appearance'),
              onTap: () {
                Navigator.pop(context);
                _goToThemeAppearanceSettings(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                _signOut(context);
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _showImagePickerOptions,
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    _pickedImage != null
                        ? FileImage(_pickedImage!)
                        : const AssetImage('assets/default_avatar.png')
                            as ImageProvider,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Welcome, ${user?.email ?? "User"}!',
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
