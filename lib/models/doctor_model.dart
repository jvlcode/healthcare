import 'package:healthcare/models/review_model.dart';
import 'package:healthcare/models/slot_model.dart';
import 'package:healthcare/models/user_model.dart';

class Doctor {
  final String id;
  final String name;
  final String specialization;
  final String profileImage;
  final double averageRating;
  final List<Slot> slots;
  final bool approved;

  final Application application;
  final String bio;
  final User? user;
  final List<Review> recentReviews;

  Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.profileImage,
    required this.averageRating,
    required this.application,
    required this.slots,
    required this.bio,
    required this.recentReviews,
    required this.approved,
    this.user,
  });

  // MAIN PARSER
  factory Doctor.fromJson(Map<String, dynamic> json) {
    final appJson = json["application"] ?? {};
    final personalInfo = appJson["personalInfo"] ?? {};

    return Doctor(
      id: json["_id"] ?? "",
      name: personalInfo["fullName"] ?? json["name"] ?? "",
      specialization:
          json["specialization"] ??
          appJson["clinicInfo"]?["specialization"] ??
          "",
      profileImage: json["user"]?["profileImage"] ?? json["profileImage"] ?? "",
      averageRating: (json["averageRating"] ?? 0).toDouble(),

      application: Application.fromJson(appJson),

      slots: json["slots"] is List
          ? (json["slots"] as List)
                .whereType<Map<String, dynamic>>()
                .map(Slot.fromJson)
                .toList()
          : [],

      bio: json["bio"] ?? "",

      recentReviews: json["recentReviews"] is List
          ? (json["recentReviews"] as List)
                .whereType<Map<String, dynamic>>()
                .map(Review.fromJson)
                .toList()
          : [],

      approved: json["approved"] ?? false,

      user: json["user"] != null ? User.fromJson(json["user"]) : null,
    );
  }

  // DOCTOR INSIDE APPOINTMENT API
  factory Doctor.fromAppointmentJson(Map<String, dynamic> json) {
    try {
      final doctorJson = json['doctor'] ?? {};
      final appJson = doctorJson["application"] ?? {};
      final personalInfo = appJson["personalInfo"] ?? {};

      return Doctor(
        id: doctorJson["_id"] ?? "",
        name: personalInfo["fullName"] ?? doctorJson["name"] ?? "",
        specialization: doctorJson["specialization"] ?? "",
        profileImage:
            doctorJson["user"]?["profileImage"] ??
            doctorJson["profileImage"] ??
            "",
        averageRating: (doctorJson["averageRating"] ?? 0).toDouble(),
        application: Application.fromJson(appJson),

        slots: const [], // No slots in appointment response
        bio: doctorJson["bio"] ?? "",
        recentReviews: const [],
        approved: doctorJson["approved"] ?? false,

        user: doctorJson["user"] != null
            ? User.fromJson(doctorJson["user"])
            : null,
      );
    } catch (e, stack) {
      print('❌ Failed to parse Doctor: $e');
      print('Stack: $stack');
      print('Raw JSON: $json');
      rethrow;
    }
  }

  // DOCTOR FROM USER DATA
  factory Doctor.fromUserJson(Map<String, dynamic> userJson) {
    final doctorJson = userJson['doctor'] ?? {};
    final applicationJson = doctorJson['application'] ?? {};
    final personalInfo = applicationJson['personalInfo'] ?? {};
    final clinicInfo = applicationJson['clinicInfo'] ?? {};
    final documents = applicationJson['documents'] ?? [];

    return Doctor(
      id: doctorJson['_id'] ?? '',
      name: personalInfo['fullName'] ?? userJson['name'] ?? '',
      specialization: doctorJson['specialization'] ?? '',
      profileImage: userJson['profileImage'] ?? '',
      averageRating: 0.0,
      approved: doctorJson['approved'] ?? false,
      bio: doctorJson['bio'] ?? '',
      slots: [],
      recentReviews: [],

      application: Application(
        personalInfo: PersonalInfo(
          fullName: personalInfo['fullName'] ?? '',
          email: personalInfo['email'] ?? '',
          phone: personalInfo['phone'] ?? '',
          qualifications: personalInfo['qualifications'] ?? '',
          experienceYears: personalInfo['experienceYears'] is int
              ? personalInfo['experienceYears']
              : int.tryParse(
                      personalInfo['experienceYears']?.toString() ?? '',
                    ) ??
                    0,
        ),
        clinicInfo: ClinicInfo(
          clinicName: clinicInfo['clinicName'] ?? '',
          clinicAddress: clinicInfo['clinicAddress'] ?? '',
        ),
        documents: documents is List
            ? documents
                  .whereType<Map<String, dynamic>>()
                  .map((d) => DocumentModel.fromJson(d))
                  .toList()
            : [],
      ),

      user: User.fromJson(userJson),
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "specialization": specialization,
    "profileImage": profileImage,
    "averageRating": averageRating,
    "approved": approved,
    "bio": bio,
    "slots": slots.map((s) => s.toJson()).toList(),
    "recentReviews": recentReviews.map((r) => r.toJson()).toList(),
    "application": application.toJson(),
    "user": user?.toJson(),
  };
}

class Application {
  final PersonalInfo personalInfo;
  final ClinicInfo clinicInfo;
  final List<DocumentModel> documents;

  Application({
    required this.personalInfo,
    required this.clinicInfo,
    required this.documents,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      personalInfo: PersonalInfo.fromJson(json['personalInfo'] ?? {}),
      clinicInfo: ClinicInfo.fromJson(json['clinicInfo'] ?? {}),
      documents: json['documents'] is List
          ? (json['documents'] as List)
                .whereType<Map<String, dynamic>>()
                .map((d) => DocumentModel.fromJson(d))
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
    "personalInfo": personalInfo.toJson(),
    "clinicInfo": clinicInfo.toJson(),
    "documents": documents.map((d) => d.toJson()).toList(),
  };
}

class PersonalInfo {
  final String fullName;
  final String email;
  final String phone;
  final String qualifications;
  final int experienceYears;

  PersonalInfo({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.qualifications,
    required this.experienceYears,
  });

  factory PersonalInfo.fromJson(Map<String, dynamic> json) {
    return PersonalInfo(
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      qualifications: json['qualifications'] ?? '',
      experienceYears: json['experienceYears'] is int
          ? json['experienceYears']
          : int.tryParse(json['experienceYears']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "fullName": fullName,
    "email": email,
    "phone": phone,
    "qualifications": qualifications,
    "experienceYears": experienceYears,
  };
}

class ClinicInfo {
  final String clinicName;
  final String clinicAddress;

  ClinicInfo({required this.clinicName, required this.clinicAddress});

  factory ClinicInfo.fromJson(Map<String, dynamic> json) {
    return ClinicInfo(
      clinicName: json['clinicName'] ?? '',
      clinicAddress: json['clinicAddress'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    "clinicName": clinicName,
    "clinicAddress": clinicAddress,
  };
}

class DocumentModel {
  final String name;
  final String url;

  DocumentModel({required this.name, required this.url});

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(name: json["name"] ?? '', url: json["url"] ?? '');
  }

  Map<String, dynamic> toJson() => {"name": name, "url": url};
}

class DoctorStatus {
  final bool hasApplied;
  final bool approved;

  DoctorStatus({required this.hasApplied, required this.approved});

  factory DoctorStatus.fromJson(Map<String, dynamic> json) {
    return DoctorStatus(
      hasApplied: json['hasApplied'] ?? false,
      approved: json['approved'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    "hasApplied": hasApplied,
    "approved": approved,
  };
}
