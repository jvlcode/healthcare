import 'package:flutter/material.dart';
import 'package:healthcare/doctors/doctor_profile_screen.dart';
import '../widgets/doctor_card.dart';
import '../widgets/date_box.dart';
import '../widgets/time_box.dart';
import '../data/doctor_data.dart';
import 'booking_success.dart';

class BookingScreen extends StatefulWidget {
  final int initialIndex;
  const BookingScreen({super.key, this.initialIndex = 0});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int selectedDoctorIndex = 0;
  Map<String, String>? selectedSlot;

  @override
  void initState() {
    super.initState();
    selectedDoctorIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final doctor = doctors[selectedDoctorIndex];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF01312F),
        title: const Text(
          "Book Session",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFFFF3E9),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 180,
              child: PageView.builder(
                controller: PageController(
                  initialPage: selectedDoctorIndex,
                  viewportFraction: 0.75,
                ),
                itemCount: doctors.length,
                onPageChanged: (i) => setState(() => selectedDoctorIndex = i),
                itemBuilder: (context, index) => DoctorCard(
                  doctor: doctors[index],
                  isSelected: index == selectedDoctorIndex,
                  showBackgroundHighlight: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DoctorProfileScreen()),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Available Dates",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
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
                                    isSelected:
                                        selectedSlot?["time"] == t &&
                                        selectedSlot?["date"] == slot["date"],
                                    onTap: () {
                                      setState(() {
                                        selectedSlot = {
                                          "date": slot["date"],
                                          "time": t,
                                        };
                                      });
                                    },
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
            ElevatedButton(
              onPressed: selectedSlot == null
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BookingSuccessScreen(),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Center(
                child: Text(
                  "Book Now",
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
    );
  }
}
