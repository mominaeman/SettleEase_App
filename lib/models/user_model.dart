import 'package:firebase_auth/firebase_auth.dart' as firebase;

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String currency;
  final String? fullName;
  final String? gender;
  final String? phoneNumber;
  final String? country;
  final String? photoUrl;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.currency,
    this.fullName,
    this.gender,
    this.phoneNumber,
    this.country,
    this.photoUrl,
  });

  // From Firebase Auth (basic login info only)
  factory UserModel.fromFirebase(firebase.User user) {
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      name: '',
      currency: '',
      fullName: null,
      gender: null,
      phoneNumber: null,
      country: null,
      photoUrl: null,
    );
  }

  // From Firestore
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      currency: map['currency'] ?? '',
      fullName: map['fullName'],
      gender: map['gender'],
      phoneNumber: map['phoneNumber'],
      country: map['country'],
      photoUrl: map['photoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'currency': currency,
      'fullName': fullName,
      'gender': gender,
      'phoneNumber': phoneNumber,
      'country': country,
      'photoUrl': photoUrl,
    };
  }
}
