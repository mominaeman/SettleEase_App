import 'package:flutter/material.dart';
import 'change_password_screen.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:csv/csv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';

class DataSecuritySettingsScreen extends StatefulWidget {
  const DataSecuritySettingsScreen({super.key});

  @override
  State<DataSecuritySettingsScreen> createState() =>
      _DataSecuritySettingsScreenState();
}

class _DataSecuritySettingsScreenState
    extends State<DataSecuritySettingsScreen> {
  void _changePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
    );
  }

  void _downloadData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User not logged in.")));
        return;
      }

      final userData = {
        'uid': user.uid,
        'email': user.email ?? '',
        'displayName': user.displayName ?? '',
        'phoneNumber': user.phoneNumber ?? '',
        'lastSignInTime': user.metadata.lastSignInTime?.toIso8601String() ?? '',
        'creationTime': user.metadata.creationTime?.toIso8601String() ?? '',
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

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Data exported to internal storage:\n\n${jsonFile.path}\n${csvFile.path}",
          ),
          duration: const Duration(seconds: 6),
        ),
      );

      final logger = Logger();
      logger.i("JSON Backup path: ${jsonFile.path}");
      logger.i("CSV Backup path: ${csvFile.path}");
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error exporting data: $e")));
      Logger().e("Error exporting data: $e");
    }
  }

  void _deactivateAccount() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No user is logged in")));
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'deactivated': true},
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account deactivated successfully")),
      );

      await FirebaseAuth.instance.signOut();

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  void _deleteAccountPermanently() {
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
                  Navigator.pop(context);

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

                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Your account has been permanently deleted',
                        ),
                      ),
                    );

                    Navigator.pop(context);
                  } on FirebaseAuthException catch (e) {
                    if (!mounted) return;
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

  void _backupUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User not logged in.")));
        return;
      }

      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (!doc.exists) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User data not found.")));
        return;
      }

      final backupData = doc.data()!;
      final jsonString = jsonEncode(backupData);

      final directory = await getApplicationDocumentsDirectory();
      final backupFile = File('${directory.path}/settleease_backup.json');
      await backupFile.writeAsString(jsonString);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Backup saved to:\n${backupFile.path}"),
          duration: const Duration(seconds: 4),
        ),
      );
      Logger().i("Data backed up to ${backupFile.path}");
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error creating backup: $e")));
    }
  }

  void _restoreUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User not logged in.")));
        return;
      }

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) return;

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final restoredData = jsonDecode(jsonString);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update(restoredData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Data restored successfully")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error restoring backup: $e")));
    }
  }

  void _backupRestoreSettings() {
    showModalBottomSheet(
      context: context,
      builder:
          (ctx) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.backup),
                title: const Text("Create Backup (JSON)"),
                onTap: () {
                  Navigator.pop(ctx);
                  _backupUserData();
                },
              ),
              ListTile(
                leading: const Icon(Icons.restore),
                title: const Text("Restore from Backup (JSON)"),
                onTap: () {
                  Navigator.pop(ctx);
                  _restoreUserData();
                },
              ),
            ],
          ),
    );
  }

  void _showAppInfo() {
    showAboutDialog(
      context: context,
      applicationName: "SettleEase",
      applicationVersion: "v1.0.0",
      applicationLegalese: "© 2025 SettleEase Team",
    );
  }

  void _contactSupport() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'mominaeman2003@gmail.com',
      queryParameters: {
        'subject': 'Support Request - SettleEase App',
        'body': 'Hi Support Team,\n\nI am facing the following issue:\n\n',
      },
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open email client.')),
      );
    }
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
            onTap: _changePassword,
          ),
          ListTile(
            title: const Text("Download My Data"),
            subtitle: const Text("Export in JSON or CSV format"),
            trailing: const Icon(Icons.download),
            onTap: _downloadData,
          ),
          ListTile(
            title: const Text("Deactivate My Account"),
            subtitle: const Text("Temporarily disable account"),
            trailing: const Icon(Icons.block),
            onTap: _deactivateAccount,
          ),
          ListTile(
            title: const Text("Delete My Account Permanently"),
            subtitle: const Text("This action is irreversible"),
            trailing: const Icon(Icons.delete_forever, color: Colors.red),
            onTap: _deleteAccountPermanently,
          ),
          const Divider(),
          ListTile(
            title: const Text("Backup/Restore Settings"),
            trailing: const Icon(Icons.cloud_sync),
            onTap: _backupRestoreSettings,
          ),
          ListTile(
            title: const Text("Session / Device Management"),
            trailing: const Icon(Icons.devices),
            onTap: () {
              Navigator.pushNamed(context, '/session-management');
            },
          ),
          ListTile(
            title: const Text("App Version Info + Feedback"),
            trailing: const Icon(Icons.info_outline),
            onTap: _showAppInfo,
          ),
          ListTile(
            title: const Text("Contact Support"),
            trailing: const Icon(Icons.support_agent),
            onTap: _contactSupport,
          ),
        ],
      ),
    );
  }
}
