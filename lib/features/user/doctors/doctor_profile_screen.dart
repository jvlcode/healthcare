import 'package:flutter/material.dart';
import 'package:healthcare/app/session/session_manager.dart';
import 'package:healthcare/core/utils/image_util.dart';
import 'package:healthcare/core/utils/navigation_util.dart';
import 'package:healthcare/core/widgets/book_session_btn.dart';
import 'package:healthcare/features/user/booking/booking_screen.dart';
import 'package:healthcare/models/doctor_model.dart';
import 'package:healthcare/models/review_model.dart';
import 'package:healthcare/models/user_model.dart';
import 'package:healthcare/services/review_service.dart';

class DoctorProfileScreen extends StatefulWidget {
  final Doctor doctor;
  const DoctorProfileScreen({super.key, required this.doctor});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  int selectedRating = 0;
  late Doctor doctor;

  @override
  void initState() {
    super.initState();
    doctor = widget.doctor;
  }

  void _showRatingModal(int initialRating, User user) {
    final TextEditingController commentController = TextEditingController();
    int tempRating = initialRating;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Rate Your Experience",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < tempRating ? Icons.star : Icons.star_border,
                      color: Colors.orange,
                      size: 32,
                    ),
                    onPressed: () {
                      setState(() {
                        tempRating = index + 1;
                      });
                      Navigator.pop(context);
                      _showRatingModal(
                        tempRating,
                        user,
                      ); // reopen with updated rating
                    },
                  );
                }),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Add a comment...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final comment = commentController.text.trim();

                  if (comment.isEmpty) {
                    // Show error if comment is empty
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Please enter a comment before submitting.",
                        ),
                      ),
                    );
                    return; // stop further execution
                  }

                  final reviewService = ReviewService();
                  final newReview = Review(
                    patientId: user.id,
                    patientName: user.name,
                    rating: tempRating,
                    comment: comment,
                    createdAt: DateTime.now(),
                  );

                  final result = await reviewService.submitReview(
                    doctorId: doctor.id,
                    rating: tempRating,
                    comment: comment,
                  );

                  Navigator.pop(context);

                  if (result['success']) {
                    setState(() {
                      selectedRating = tempRating;
                      doctor.recentReviews.insert(0, newReview); // add locally
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Thanks for your review!")),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Failed to submit review: ${result['message']}",
                        ),
                      ),
                    );
                  }
                },

                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF002B25),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Submit",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDEFEF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF002B25),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "${doctor.name} Profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.orange.shade100,
              backgroundImage: NetworkImage(
                ImageUtils.resolve(doctor.profileImage),
              ),
            ),
            const SizedBox(height: 15),
            // Name & Role
            Text(
              doctor.name,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              doctor.specialization,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            // Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  doctor.averageRating.toStringAsFixed(1),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                SizedBox(width: 4),
                ...List.generate(5, (index) {
                  return Icon(
                    index < doctor.averageRating.round()
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.orange,
                    size: 20,
                  );
                }),
              ],
            ),
            const SizedBox(height: 20),
            // Details
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Specialties: ${doctor.application.personalInfo.qualifications}",

                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 5),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Experience: ${doctor.application.personalInfo.experienceYears}+ years",

                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),
            Text(
              doctor.bio,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 25),
            BookSessionButton(
              onPressed: () {
                navigateSlideLeft(context, page: BookingScreen(doctor: doctor));
              },
            ),
            const SizedBox(height: 25),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "How was your experience?",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            // Feedback Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () async {
                    // check if current user has already submitted a review
                    final user = await SessionManager.getCurrentUser();
                    if (user == null) return;
                    if (doctor.recentReviews.any(
                      (r) => r.patientId == user.id,
                    )) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "You have already submitted a review for this doctor.",
                          ),
                        ),
                      );
                      return; // prevent opening modal
                    }

                    _showRatingModal(index + 1, user);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      index < selectedRating ? Icons.star : Icons.star_border,
                      color: Colors.orange,
                      size: 40,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            ...doctor.recentReviews.map((review) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Patient name
                    Text(
                      review.patientName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Star rating
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < review.rating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.orange,
                          size: 18,
                        );
                      }),
                    ),
                    const SizedBox(height: 4),
                    // Comment
                    Text(
                      review.comment ?? "",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
