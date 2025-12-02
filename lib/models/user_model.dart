import 'package:healthcare/models/doctor_model.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? profileImage;
  final String? bio;
  Doctor? doctor; // optional

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.profileImage,
    this.bio,
    this.doctor,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      return User(
        id: json['_id'] ?? json['id'] ?? "",
        name: json['name'] ?? "",
        email: json['email'] ?? "",
        phone: json['phone'] ?? "",
        role: json['role'] ?? "",
        profileImage: json['profileImage'],
        bio: json['bio'],
        doctor: json['doctor'] != null
            ? Doctor.fromUserJson(
                Map<String, dynamic>.from(json['doctor']),
              ) // ✅ FIXED
            : null,
      );
    } catch (e, stack) {
      print('❌ Failed to parse User: $e');
      print('Stack: $stack');
      print('Raw JSON: $json');
      rethrow;
    }
  }

  User copyWith({Doctor? doctor}) {
    return User(
      id: id,
      name: name,
      email: email,
      phone: phone,
      role: role,
      profileImage: profileImage,
      bio: bio,
      doctor: doctor ?? this.doctor,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'role': role,
    'profileImage': profileImage,
    'bio': bio,
    'doctor': doctor?.toJson(), // ✅ FIXED for Hive storage
  };

  factory User.empty() {
    return User(
      id: "",
      name: "",
      email: "",
      phone: "",
      role: "",
      profileImage: null,
      bio: null,
      doctor: null,
    );
  }
}
