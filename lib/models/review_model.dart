class Review {
  final int rating;
  final String patient;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.patient,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    rating: json["rating"],
    comment: json["comment"],
    patient: json["patient"],
    createdAt: DateTime.parse(json["createdAt"]),
  );
}
