import 'package:flutter/material.dart';
import 'change_password_screen.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:csv/csv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DataSecuritySettingsScreen extends StatelessWidget {
  const DataSecuritySettingsScreen({super.key});

  void _changePassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
    );
  }

  void _downloadData(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User not logged in.")));
        return;
      }

      final userData = {
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName ?? '',
        'phoneNumber': user.phoneNumber ?? '',
        'lastSignInTime': user.metadata.lastSignInTime?.toIso8601String(),
        'creationTime': user.metadata.creationTime?.toIso8601String(),
      };

      final jsonString = jsonEncode(userData);
      final csvData = [
        ['Field', 'Value'],
        ...userData.entries.map((e) => [e.key, e.value]),
      ];
      final csvString = const ListToCsvConverter().convert(csvData);

      final directory = await getApplicationDocumentsDirectory();
      final jsonFile = File('${directory.path}/user_data.json');
      final csvFile = File('${directory.path}/user_data.csv');

      await jsonFile.writeAsString(jsonString);
      await csvFile.writeAsString(csvString);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Data exported:\n${jsonFile.path}\n${csvFile.path}"),
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error exporting data: $e")));
    }
  }

  void _deactivateAccount(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No user is logged in")));
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'deactivated': true},
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account deactivated successfully")),
      );

      await FirebaseAuth.instance.signOut();

      if (!context.mounted) return;
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  void _deleteAccountPermanently(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Confirm Deletion"),
            content: const Text(
              "Are you sure you want to permanently delete your account? This action cannot be undone.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context); // Close the dialog

                  final user = FirebaseAuth.instance.currentUser;
                  final uid = user?.uid;

                  try {
                    if (uid != null) {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .delete();
                      // TODO: delete other user-related collections if necessary
                    }

                    await user?.delete();

                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Your account has been permanently deleted',
                        ),
                      ),
                    );

                    Navigator.pop(context); // Go back after deletion
                  } on FirebaseAuthException catch (e) {
                    if (!context.mounted) return;
                    if (e.code == 'requires-recent-login') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please log in again to delete your account',
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.message}')),
                      );
                    }
                  }
                },
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _backupRestoreSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Backup/Restore feature coming soon...")),
    );
  }

  void _manageSessions(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Session management coming soon...")),
    );
  }

  void _showAppInfo(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: "SettleEase",
      applicationVersion: "v1.0.0",
      applicationLegalese: "© 2025 SettleEase Team",
    );
  }

  void _contactSupport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Support chat/email not yet integrated.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Data & Security Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text("Change Password"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _changePassword(context),
          ),
          ListTile(
            title: const Text("Download My Data"),
            subtitle: const Text("Export in JSON or CSV format"),
            trailing: const Icon(Icons.download),
            onTap: () => _downloadData(context),
          ),
          ListTile(
            title: const Text("Deactivate My Account"),
            subtitle: const Text("Temporarily disable account"),
            trailing: const Icon(Icons.block),
            onTap: () => _deactivateAccount(context),
          ),
          ListTile(
            title: const Text("Delete My Account Permanently"),
            subtitle: const Text("This action is irreversible"),
            trailing: const Icon(Icons.delete_forever, color: Colors.red),
            onTap: () => _deleteAccountPermanently(context),
          ),
          const Divider(),
          ListTile(
            title: const Text("Backup/Restore Settings"),
            trailing: const Icon(Icons.cloud_sync),
            onTap: () => _backupRestoreSettings(context),
          ),
          ListTile(
            title: const Text("Session / Device Management"),
            trailing: const Icon(Icons.devices),
            onTap: () => _manageSessions(context),
          ),
          ListTile(
            title: const Text("App Version Info + Feedback"),
            trailing: const Icon(Icons.info_outline),
            onTap: () => _showAppInfo(context),
          ),
          ListTile(
            title: const Text("Contact Support"),
            trailing: const Icon(Icons.support_agent),
            onTap: () => _contactSupport(context),
          ),
        ],
      ),
    );
  }
}
