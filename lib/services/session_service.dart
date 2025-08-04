import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:device_info_plus/device_info_plus.dart';

class SessionService {
  static Future<void> saveSessionToFirestore(User user) async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;

    final sessionData = {
      'device': androidInfo.model, // ✅ No fallback needed
      'platform': 'Android',
      'loginTime': DateTime.now().toIso8601String(),
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('sessions')
        .add(sessionData);
  }
}
