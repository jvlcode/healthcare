import 'package:flutter/material.dart';
import 'package:healthcare/appointments/booking_screen.dart';
import 'package:healthcare/core/app_header.dart';
import '../core/widgets/doctor_card.dart';
import '../core/widgets/date_box.dart';
import '../core/widgets/time_box.dart';
import '../data/doctor_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedDoctorIndex = 0;

  @override
  Widget build(BuildContext context) {
    final doctor = doctors[selectedDoctorIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F2),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Book Session Button
            Center(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      offset: const Offset(0, 3),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            BookingScreen(initialIndex: selectedDoctorIndex),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Book a Session",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Doctor Cards Carousel
            SizedBox(
              height: 180,
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.55),
                itemCount: doctors.length,
                onPageChanged: (i) {
                  setState(() {
                    selectedDoctorIndex = i;
                  });
                },
                itemBuilder: (context, index) => DoctorCard(
                  doctor: doctors[index],
                  isSelected: index == selectedDoctorIndex,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingScreen(initialIndex: index),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Available Dates & Times (read-only)
            const Text(
              "Available Dates",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: doctor.slots!.map<Widget>((slot) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DateBox(text: slot["date"]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: List<Widget>.from(
                                slot["times"].map<Widget>(
                                  (t) => TimeBox(
                                    time: t,
                                    isSelected: false, // not selectable
                                    onTap: null, // disable tap
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
