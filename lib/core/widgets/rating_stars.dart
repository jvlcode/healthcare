import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  const RatingStars({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    const totalStars = 5;
    List<Widget> stars = [];

    for (int i = 0; i < totalStars; i++) {
      if (rating >= i + 1) {
        stars.add(const Icon(Icons.star, color: Colors.orange, size: 16));
      } else if (rating > i && rating < i + 1) {
        stars.add(const Icon(Icons.star_half, color: Colors.orange, size: 16));
      } else {
        stars.add(
          const Icon(Icons.star_border, color: Colors.orange, size: 16),
        );
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...stars,
        const SizedBox(width: 6),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
