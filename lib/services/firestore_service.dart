import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreService {
  final CollectionReference users = FirebaseFirestore.instance.collection(
    'users',
  );

  // 📄 Create or Update User
  Future<void> createOrUpdateUser(UserModel user) async {
    await users.doc(user.uid).set(user.toMap(), SetOptions(merge: true));
  }

  // 🔍 Get User by UID
  Future<UserModel?> getUserByUid(String uid) async {
    final snapshot = await users.doc(uid).get();
    if (snapshot.exists) {
      return UserModel.fromMap(snapshot.data() as Map<String, dynamic>);
    }
    return null;
  }

  // 🔔 Save Notification Settings
  Future<void> saveNotificationSettings({
    required String uid,
    required Map<String, bool> settings,
  }) async {
    await users.doc(uid).set({
      'notificationSettings': settings,
    }, SetOptions(merge: true));
  }

  // 🔁 Get Notification Settings
  Future<Map<String, bool>> getNotificationSettings(String uid) async {
    final doc = await users.doc(uid).get();
    final data = doc.data() as Map<String, dynamic>?;

    if (data != null && data['notificationSettings'] != null) {
      final settings = Map<String, dynamic>.from(data['notificationSettings']);
      return settings.map((key, value) => MapEntry(key, value as bool));
    }

    // Default Notification Settings
    return {
      'emailNotifications': true,
      'pushNotifications': true,
      'monthlySummaryEmail': true,
      'groupInvites': true,
    };
  }

  // 🔒 Save Privacy Settings
  Future<void> savePrivacySettings({
    required String uid,
    required Map<String, bool> settings,
  }) async {
    await users.doc(uid).set({
      'privacySettings': settings,
    }, SetOptions(merge: true));
  }

  // 🔍 Get Privacy Settings
  Future<Map<String, bool>> getPrivacySettings(String uid) async {
    final doc = await users.doc(uid).get();
    final data = doc.data() as Map<String, dynamic>?;

    if (data != null && data['privacySettings'] != null) {
      final settings = Map<String, dynamic>.from(data['privacySettings']);
      return settings.map((key, value) => MapEntry(key, value as bool));
    }

    // Default Privacy Settings
    return {
      'profileVisible': true,
      'allowAddByPhoneEmail': true,
      'showActivityStatus': true,
      'shareAnonymously': false,
    };
  }

  // 🌐 Save Language & Region Preferences
  Future<void> saveLanguageRegionSettings({
    required String uid,
    required Map<String, String> settings,
  }) async {
    await users.doc(uid).set({
      'languageRegion': settings,
    }, SetOptions(merge: true));
  }

  // 🌐 Get Language & Region Preferences
  Future<Map<String, String>> getLanguageRegionSettings(String uid) async {
    final doc = await users.doc(uid).get();
    final data = doc.data() as Map<String, dynamic>?;

    if (data != null && data['languageRegion'] != null) {
      final settings = Map<String, dynamic>.from(data['languageRegion']);
      return settings.map((key, value) => MapEntry(key, value.toString()));
    }

    // Default Language & Region Settings
    return {
      'appLanguage': 'English',
      'timezone': 'Auto',
      'numberFormat': '1,000.00',
    };
  }

  // 🎨 Save Theme / Appearance Settings
  Future<void> saveAppearanceSettings({
    required String uid,
    required Map<String, dynamic> settings,
  }) async {
    await users.doc(uid).set({
      'appearanceSettings': settings,
    }, SetOptions(merge: true));
  }

  // 🎨 Get Theme / Appearance Settings
  Future<Map<String, dynamic>> getAppearanceSettings(String uid) async {
    final doc = await users.doc(uid).get();
    final data = doc.data() as Map<String, dynamic>?;

    if (data != null && data['appearanceSettings'] != null) {
      return Map<String, dynamic>.from(data['appearanceSettings']);
    }

    // Default Appearance Settings
    return {'darkMode': false, 'fontSize': 16.0, 'accentColor': '#2196F3'};
  }
}
