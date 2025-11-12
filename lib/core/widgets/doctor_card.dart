import 'package:flutter/material.dart';
import '../../models/doctor_model.dart';
import 'rating_stars.dart';

class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool showBackgroundHighlight;

  const DoctorCard({
    super.key,
    required this.doctor,
    this.isSelected = false,
    this.onTap,
    this.showBackgroundHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: showBackgroundHighlight
              ? (isSelected ? Colors.white : Colors.grey[200])
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(doctor.profileImageUrl, width: 60, height: 60),
            const SizedBox(height: 8),
            Text(
              doctor.name,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Text(
              doctor.specialization,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 6),
            RatingStars(rating: doctor.averageRating),
          ],
        ),
      ),
    );
  }
}
