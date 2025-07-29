class Validators {
  static bool isValidEmail(String email) {
    return RegExp(r'\S+@\S+\.\S+').hasMatch(email);
  }

  static bool isValidPassword(String password) {
    return password.length >= 6;
  }
}
