class Review {
  final int rating;
  final String comment;
  final DateTime createdAt;
  final String patientName;
  final String patientId;

  Review({
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.patientName,
    required this.patientId,
  });

  /// Safe JSON parser with fallbacks
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      rating: json["rating"] is int
          ? json["rating"]
          : int.tryParse(json["rating"]?.toString() ?? "0") ?? 0,

      comment: json["comment"] ?? "",

      patientName: json["patientName"] ?? "",
      patientId: json["patientId"] ?? "",

      createdAt: json["createdAt"] != null
          ? DateTime.tryParse(json["createdAt"]) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Convert Review to JSON
  Map<String, dynamic> toJson() => {
    "rating": rating,
    "comment": comment,
    "patientName": patientName,
    "patientId": patientId,
    "createdAt": createdAt.toIso8601String(),
  };

  /// Empty object constructor (like Slot.empty)
  factory Review.empty() {
    return Review(
      rating: 0,
      comment: "",
      createdAt: DateTime.now(),
      patientName: "",
      patientId: "",
    );
  }
}
