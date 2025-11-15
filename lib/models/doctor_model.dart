// models/doctor_model.dart

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
  final List<ReviewModel> recentReviews;

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
      name: json["application"]["fullName"],
      specialization: json["application"]["specialization"],
      profileImageUrl: json["user"]["profileImageUrl"],
      averageRating: (json["averageRating"] ?? 0).toDouble(),
      application: Application.fromJson(json["application"]),
      slots: (json["slots"] as List).map((s) => Slot.fromJson(s)).toList(),
      bio: json["bio"] ?? "",
      recentReviews: (json["recentReviews"] as List)
          .map((r) => ReviewModel.fromJson(r))
          .toList(),
      approved: json["approved"] ?? false,
    );
  }
  factory Doctor.fromAppointmentJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['doctor']["_id"],
      name: json['doctor']["application"]["fullName"],
      specialization: json['doctor']["application"]["specialization"],
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

class Slot {
  String id;
  DateTime date;
  String startTime;
  String endTime;
  String dateLabel;
  String startTimeLabel;
  String endTimeLabel;
  bool available;

  Slot({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.dateLabel,
    required this.startTimeLabel,
    required this.endTimeLabel,
    required this.available,
  });

  factory Slot.fromJson(Map<String, dynamic> json) {
    return Slot(
      id: json["_id"] ?? json["id"], // support both _id and id
      date: DateTime.parse(json["date"]),
      startTime: json["startTime"],
      endTime: json["endTime"],
      dateLabel: json["dateLabel"],
      startTimeLabel: json["startTimeLabel"],
      endTimeLabel: json["endTimeLabel"],
      available: json["available"] ?? false,
    );
  }
  Slot copyWith({
    String? id,
    String? startTime,
    String? endTime,
    String? startTimeLabel,
    String? endTimeLabel,
  }) {
    return Slot(
      id: id ?? this.id,
      date: date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      startTimeLabel: startTimeLabel ?? this.startTimeLabel,
      endTimeLabel: endTimeLabel ?? this.endTimeLabel,
      dateLabel: dateLabel,
      available: available,
    );
  }
}

class Application {
  final String fullName;
  final String email;
  final String phone;
  final String qualifications;
  final String specialization;
  final int experienceYears;
  final String clinicName;
  final String clinicAddress;
  final List<DocumentModel> documents;

  Application({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.qualifications,
    required this.specialization,
    required this.experienceYears,
    required this.clinicName,
    required this.clinicAddress,
    required this.documents,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      fullName: json["fullName"],
      email: json["email"],
      phone: json["phone"],
      qualifications: json["qualifications"],
      specialization: json["specialization"],
      experienceYears: json["experienceYears"],
      clinicName: json["clinicName"],
      clinicAddress: json["clinicAddress"],
      documents: (json["documents"] as List)
          .map((d) => DocumentModel.fromJson(d))
          .toList(),
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

class ReviewModel {
  final int rating;
  final String patient;
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.patient,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
    rating: json["rating"],
    comment: json["comment"],
    patient: json["patient"],
    createdAt: DateTime.parse(json["createdAt"]),
  );
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
