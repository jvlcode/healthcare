// models/doctor_model.dart

import 'package:healthcare/models/review_model.dart';
import 'package:healthcare/models/slot_model.dart';
import 'package:healthcare/models/user_model.dart';

class Doctor {
  final String id;
  final String name;
  final String specialization;
  final String profileImage; // from user.profileImageUrl
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

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json["_id"] ?? "",
      name: json["application"]?["personalInfo"]?["fullName"] ?? "",
      specialization: json["specialization"] ?? "",
      profileImage:
          json["user"]?["profileImage"] ??
          json["profileImage"] ??
          "", // fallback to user or root
      averageRating: (json["averageRating"] ?? 0).toDouble(),
      application: Application.fromJson(json["application"] ?? {}),
      slots: (json["slots"] is List)
          ? (json["slots"] as List).map((s) => Slot.fromJson(s)).toList()
          : [],
      bio: json["bio"] ?? "",
      recentReviews: (json["recentReviews"] is List)
          ? (json["recentReviews"] as List)
                .map((r) => Review.fromJson(r))
                .toList()
          : [],
      approved: json["approved"] ?? false,
    );
  }

  // For mapping doctor inside an appointment response
  factory Doctor.fromAppointmentJson(Map<String, dynamic> json) {
    try {
      final doctorJson = json['doctor'] ?? {};

      return Doctor(
        id: doctorJson["_id"] ?? "",
        name: doctorJson["application"]?["personalInfo"]?["fullName"] ?? "",
        specialization: doctorJson["specialization"] ?? "",
        profileImage: doctorJson["user"]?["profileImage"] ?? "",
        averageRating: (doctorJson["averageRating"] ?? 0).toDouble(),
        application: Application.fromJson(doctorJson["application"] ?? {}),
        slots: [],
        bio: doctorJson["bio"] ?? "",
        recentReviews: [],
        approved: doctorJson["approved"] ?? false,
        user: User.fromJson(doctorJson["user"]),
      );
    } catch (e, stack) {
      print('❌ Failed to parse Doctor: $e');
      print('Stack: $stack');
      print('Raw JSON: $json');
      rethrow;
    }
  }

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
      averageRating: 0.0, // not present in login response
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
        documents: (documents is List)
            ? documents
                  .whereType<Map<String, dynamic>>()
                  .map((d) => DocumentModel.fromJson(d))
                  .toList()
            : [],
      ),
    );
  }
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
      documents: (json['documents'] is List)
          ? (json['documents'] as List)
                .map((d) => DocumentModel.fromJson(d))
                .toList()
          : [],
    );
  }
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
      experienceYears: json['experienceYears'] ?? 0,
    );
  }
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
}

class DocumentModel {
  final String name;
  final String url;

  DocumentModel({required this.name, required this.url});

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(name: json["name"] ?? '', url: json["url"] ?? '');
  }
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
}
