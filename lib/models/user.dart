import 'dart:convert';
import 'doctor_profile.dart'; // Ensure correct import

class User {
  final int id;
  final String name;
  final String email;
  final String? phone; // Nullable in Laravel, so nullable in Dart
  final String role;
  final bool isActive;
  final DateTime created_at;
  final DoctorProfile? doctorProfile; // Nullable, as not all users are doctors

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    required this.isActive,
    required this.created_at,
    this.doctorProfile,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['user_id'] as int,
      name: map['full_name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String?, // Cast to String?
      role: map['role'] as String,
      isActive: map['is_active'] as bool,
      created_at: DateTime.parse(map['created_at'] as String),
      doctorProfile: map['doctor_profile'] != null
          ? DoctorProfile.fromMap(map['doctor_profile'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'isActive': isActive,
      'created_at': created_at.toIso8601String(),
      'doctorProfile': doctorProfile?.toMap(),
    };
  }

  String toJson() => json.encode(toMap());
  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);
}
