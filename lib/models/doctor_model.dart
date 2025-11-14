// models/doctor_model.dart

class Doctor {
  final String id;
  final String name;
  final String specialization;
  final String profileImageUrl; // ✅ optional
  final double averageRating; // ✅ optional
  final List<Slot> slots; // ✅ optional

  final DoctorApplication application;
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
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json["_id"],
      name: json["application"]["fullName"],
      specialization: json["application"]["specialization"],
      profileImageUrl: json["user"]["profileImageUrl"],
      averageRating: (json["averageRating"] ?? 0).toDouble(),
      application: DoctorApplication.fromJson(json["application"]),
      slots: (json["slots"] as List).map((s) => Slot.fromJson(s)).toList(),
      bio: json["bio"] ?? "",
      recentReviews: (json["recentReviews"] as List)
          .map((r) => ReviewModel.fromJson(r))
          .toList(),
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
      application: DoctorApplication.fromJson(json['doctor']["application"]),
      bio: json['doctor']["bio"] ?? "",
      recentReviews: [],
    );
  }
}

class Slot {
  final String id;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String dateLabel;
  final String startTimeLabel;
  final String endTimeLabel;

  Slot({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.dateLabel,
    required this.startTimeLabel,
    required this.endTimeLabel,
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
    );
  }
}

class DoctorApplication {
  final String fullName;
  final String email;
  final String phone;
  final String qualifications;
  final String specialization;
  final int experienceYears;
  final String clinicName;
  final String clinicAddress;
  final List<DocumentModel> documents;

  DoctorApplication({
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

  factory DoctorApplication.fromJson(Map<String, dynamic> json) {
    return DoctorApplication(
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
