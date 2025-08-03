import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  bool emailNotifications = true;
  bool pushNotifications = true;
  bool monthlySummaryEmail = true;
  bool groupInvites = true;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final settings = await _firestoreService.getNotificationSettings(uid);
      setState(() {
        emailNotifications = settings['emailNotifications'] ?? true;
        pushNotifications = settings['pushNotifications'] ?? true;
        monthlySummaryEmail = settings['monthlySummaryEmail'] ?? true;
        groupInvites = settings['groupInvites'] ?? true;
        isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await _firestoreService.saveNotificationSettings(
        uid: uid,
        settings: {
          'emailNotifications': emailNotifications,
          'pushNotifications': pushNotifications,
          'monthlySummaryEmail': monthlySummaryEmail,
          'groupInvites': groupInvites,
        },
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification settings saved.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Settings')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  SwitchListTile(
                    title: const Text('Email Notifications'),
                    value: emailNotifications,
                    onChanged: (value) {
                      setState(() => emailNotifications = value);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Push Notifications'),
                    value: pushNotifications,
                    onChanged: (value) {
                      setState(() => pushNotifications = value);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Monthly Expense Summary Email'),
                    value: monthlySummaryEmail,
                    onChanged: (value) {
                      setState(() => monthlySummaryEmail = value);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('New Group Invites'),
                    value: groupInvites,
                    onChanged: (value) {
                      setState(() => groupInvites = value);
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
