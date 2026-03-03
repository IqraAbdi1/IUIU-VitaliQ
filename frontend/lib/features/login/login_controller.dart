import 'package:flutter/material.dart';

class LoginController extends ChangeNotifier {
  String registrationNumber = '';
  String password = '';
  String errorMessage = '';

  void login() {
    if (registrationNumber.isEmpty || password.isEmpty) {
      errorMessage = "Please fill in all fields";
    } else if (registrationNumber != "12345" || password != "password") {
      errorMessage = "Invalid credentials";
    } else {
      errorMessage = "Login successful!";
    }
    notifyListeners(); // tells the UI to update
  }

  void updateRegistration(String value) {
    registrationNumber = value;
    errorMessage = '';
    notifyListeners();
  }

  void updatePassword(String value) {
    password = value;
    errorMessage = '';
    notifyListeners();
  }
}