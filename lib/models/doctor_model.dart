class Doctor {
  final String name;
  final String role;
  final double rating;
  final String image;
  final List<Map<String, dynamic>>? slots;

  Doctor({
    required this.name,
    required this.role,
    required this.rating,
    required this.image,
    this.slots,
  });
}
