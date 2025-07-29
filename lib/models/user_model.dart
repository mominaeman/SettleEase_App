import 'package:firebase_auth/firebase_auth.dart' as firebase;

class UserModel {
  final String uid;
  final String email;

  UserModel({required this.uid, required this.email});

  factory UserModel.fromFirebase(firebase.User user) {
    return UserModel(uid: user.uid, email: user.email ?? '');
  }
}
