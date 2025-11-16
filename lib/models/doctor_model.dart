// models/doctor_model.dart

import 'package:healthcare/models/review_model.dart';
import 'package:healthcare/models/slot_model.dart';

class Doctor {
  final String id;
  final String name;
  final String specialization;
  final String profileImageUrl; // ✅ optional
  final double averageRating; // ✅ optional
  final List<Slot> slots; // ✅ optional
  final bool approved;

  final Application application;
  final String bio;
  final List<Review> recentReviews;

  Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.profileImageUrl,
    required this.averageRating,
    required this.application,
    required this.slots,
    required this.bio,
    required this.recentReviews,
    required this.approved,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json["_id"],
      name: json["application"]["personalInfo"]["fullName"],
      specialization: json["specialization"],
      profileImageUrl: json["profileImageUrl"] ?? "", // Injected manually
      averageRating: (json["averageRating"] ?? 0).toDouble(),
      application: Application.fromJson(json["application"]),
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
  factory Doctor.fromAppointmentJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['doctor']["_id"],
      name: json['doctor']["application"]["personalInfo"]["fullName"],
      specialization: json['doctor']["specialization"],
      profileImageUrl: json['user']["profileImage"],
      averageRating: 0,
      slots: [],
      application: Application.fromJson(json['doctor']["application"]),
      bio: json['doctor']["bio"] ?? "",
      recentReviews: [],
      approved: json['doctor']["approved"],
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
      personalInfo: PersonalInfo.fromJson(json['personalInfo']),
      clinicInfo: ClinicInfo.fromJson(json['clinicInfo']),
      documents: (json['documents'] as List)
          .map((d) => DocumentModel.fromJson(d))
          .toList(),
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
    return DocumentModel(name: json["name"], url: json["url"]);
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
