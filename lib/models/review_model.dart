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

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    rating: json["rating"],
    comment: json["comment"],
    patientName: json["patientName"],
    patientId: json["patientId"],
    createdAt: DateTime.parse(json["createdAt"]),
  );

  /// Convert Review to JSON
  Map<String, dynamic> toJson() => {
    "rating": rating,
    "comment": comment,
    "patientName": patientName,
    "patientId": patientId,
    "createdAt": createdAt.toIso8601String(),
  };
}
