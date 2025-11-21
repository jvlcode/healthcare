import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:healthcare/core/utils/navigation_util.dart';
import 'package:healthcare/core/utils/toast_util.dart';
import 'package:healthcare/models/appointment_model.dart';
import 'package:intl/intl.dart';

class BookingSuccessScreen extends StatelessWidget {
  final Appointment booking;
  const BookingSuccessScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    // Format date and time
    final dateString = booking.slot.dateLabel;
    final timeString =
        "${booking.slot.startTimeLabel} – ${booking.slot.endTimeLabel}";

    return Scaffold(
      backgroundColor: const Color(0xFFFBEFEF),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// Success Icon
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFDFF5E1),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: const Icon(Icons.check, size: 50, color: Colors.green),
                ),
                const SizedBox(height: 24),

                /// Title
                const Text(
                  'Your session is booked!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                /// Dynamic Date + Time + Doctor
                Text(
                  "$dateString\n$timeString\nwith ${booking.doctor.name}",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                /// DOCTOR CARD
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      /// Doctor Image
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFCCE6F4),
                          image: booking.doctor.profileImage.isNotEmpty
                              ? DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                    booking.doctor.profileImage,
                                  ),
                                )
                              : null,
                        ),
                        child: booking.doctor.profileImage.isEmpty
                            ? const Icon(
                                Icons.person,
                                size: 40,
                                color: Color(0xFF064273),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),

                      /// Doctor Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.doctor.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              booking.doctor.specialization,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Row(
                            //   children: [
                            //     const Icon(
                            //       Icons.star,
                            //       color: Colors.orange,
                            //       size: 16,
                            //     ),
                            //     const SizedBox(width: 4),
                            //     Text(
                            //       booking.doctor.averageRating.toString(),
                            //       style: const TextStyle(
                            //         fontWeight: FontWeight.bold,
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            const SizedBox(height: 8),

                            /// Mini doctor bio
                            Text(
                              booking.doctor.bio.isNotEmpty
                                  ? booking.doctor.bio
                                  : "Doctor profile details available.",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                /// DONE BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ToastUtil.success(
                        "Booking Successfully Completed",
                        gravity: ToastGravity.TOP,
                      );

                      navigateSlideLeft(
                        context,
                        routeName: "/user",
                        removeAllPrevious: true,
                        type: SlideNavType.pushAndRemoveUntil,
                        arguments: 1,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
