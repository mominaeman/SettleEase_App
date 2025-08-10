import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// Save settings to Firestore
  Future<void> saveSettings({
    required String theme,
    required String fontSize,
    required bool autoLogin,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _db.collection('users').doc(uid).set({
        'settings': {
          'theme': theme,
          'fontSize': fontSize,
          'autoLogin': autoLogin,
        },
      }, SetOptions(merge: true));
    }
  }

  /// Load settings from Firestore
  Future<Map<String, dynamic>?> loadSettings() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && doc.data()?['settings'] != null) {
        return Map<String, dynamic>.from(doc.data()!['settings']);
      }
    }
    return null;
  }
}
