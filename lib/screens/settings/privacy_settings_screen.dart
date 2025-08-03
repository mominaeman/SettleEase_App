import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  bool profileVisible = true;
  bool allowAddByPhoneEmail = true;
  bool showActivityStatus = true;
  bool shareAnonymously = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final settings = await _firestoreService.getPrivacySettings(uid);
      setState(() {
        profileVisible = settings['profileVisible'] ?? true;
        allowAddByPhoneEmail = settings['allowAddByPhoneEmail'] ?? true;
        showActivityStatus = settings['showActivityStatus'] ?? true;
        shareAnonymously = settings['shareAnonymously'] ?? false;
        isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await _firestoreService.savePrivacySettings(
        uid: uid,
        settings: {
          'profileVisible': profileVisible,
          'allowAddByPhoneEmail': allowAddByPhoneEmail,
          'showActivityStatus': showActivityStatus,
          'shareAnonymously': shareAnonymously,
        },
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Privacy settings saved.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Settings')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  SwitchListTile(
                    title: const Text('Profile Visibility (Public/Private)'),
                    value: profileVisible,
                    onChanged: (value) {
                      setState(() => profileVisible = value);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Allow Adding Me by Phone/Email'),
                    value: allowAddByPhoneEmail,
                    onChanged: (value) {
                      setState(() => allowAddByPhoneEmail = value);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Show Activity Status (Online/Offline)'),
                    value: showActivityStatus,
                    onChanged: (value) {
                      setState(() => showActivityStatus = value);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Share Expenses Anonymously'),
                    value: shareAnonymously,
                    onChanged: (value) {
                      setState(() => shareAnonymously = value);
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveSettings,
                    child: const Text('Save'),
                  ),
                ],
              ),
    );
  }
}
