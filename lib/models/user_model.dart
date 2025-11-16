import 'package:healthcare/models/doctor_model.dart';

class User {
  final String? id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? profileImage;
  final String? bio;
  final Doctor? doctor; // optional

  User({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.profileImage,
    this.bio,
    this.doctor,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['_id'],
    name: json['name'],
    email: json['email'],
    phone: json['phone'] ?? "",
    role: json['role'],
    profileImage: json['profileImage'],
    bio: json['bio'],
    doctor: json['doctor'] != null ? Doctor.fromJson(json['doctor']) : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'role': role,
    'profileImage': profileImage,
    'bio': bio,
    'doctor': doctor,
  };
}
