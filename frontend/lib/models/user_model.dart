// file: models/user_model.dart

import 'dart:convert';

class User {
  final String email;
  final String name;

  User({
    required this.email,
    required this.name,
  });

  // Method สำหรับแปลง JSON (Map) มาเป็น Object User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'] as String,
      name: json['name'] as String,
    );
  }

  // Method เสริมสำหรับแปลง JSON String มาเป็น Object User โดยตรง
  factory User.fromString(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return User.fromJson(json);
  }
}