// models/doctor_model.dart
class Doctor {
  final String id;
  final String name;
  final String specialization;
  final String profileImageUrl;
  final double averageRating;
  final List<SlotModel> slots;

  Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.profileImageUrl,
    required this.averageRating,
    required this.slots,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json["_id"],
      name: json["application"]["fullName"],
      specialization: json["application"]["specialization"],
      profileImageUrl: json["user"]["profileImageUrl"],
      averageRating: (json["averageRating"] ?? 0).toDouble(),
      slots: (json["slots"] as List).map((s) => SlotModel.fromJson(s)).toList(),
    );
  }
}

class SlotModel {
  final String dateLabel;
  final String startTimeLabel;

  SlotModel({required this.dateLabel, required this.startTimeLabel});

  factory SlotModel.fromJson(Map<String, dynamic> json) {
    return SlotModel(
      dateLabel: json["dateLabel"],
      startTimeLabel: json["startTimeLabel"],
    );
  }
}
