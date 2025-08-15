import 'package:firebase_auth/firebase_auth.dart' as firebase;

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String currency;
  final String? fullName;
  final String? gender;
  final String? phoneNumber; // digits only
  final String countryCode; // e.g., +92
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
    required this.countryCode,
    this.country,
    this.photoUrl,
  });

  // From Firebase Auth (basic login info only)
  factory UserModel.fromFirebase(
    firebase.User user, {
    String phoneNumber = '',
    String countryCode = '+92',
  }) {
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      name: '',
      currency: '',
      fullName: null,
      gender: null,
      phoneNumber: phoneNumber, // pass from UI
      countryCode: countryCode, // pass from UI
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
      countryCode: map['countryCode'] ?? '+92',
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
      'countryCode': countryCode,
      'country': country,
      'photoUrl': photoUrl,
    };
  }
}
