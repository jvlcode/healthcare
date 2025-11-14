class User {
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? profileImage;
  final String? bio;

  User({
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.profileImage,
    this.bio,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'role': role,
    'profileImage': profileImage,
    'bio': bio,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    name: json['name'],
    email: json['email'],
    phone: json['phone'] ?? "",
    role: json['role'],
    profileImage: json['profileImage'],
    bio: json['bio'],
  );
}
