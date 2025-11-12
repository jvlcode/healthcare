import 'package:flutter/material.dart';
import 'package:healthcare/models/doctor_model.dart';
import 'package:healthcare/services/doctor_service.dart';
// import 'package:healthcare/features/user/appointments/booking_screen.dart';
import '../../../core/widgets/doctor_card.dart';
import '../../../core/widgets/date_box.dart';
import '../../../core/widgets/time_box.dart';
// import '../../../data/doctor_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedDoctorIndex = 0;
  final DoctorService _doctorService = DoctorService();
  List<Doctor> doctors = [];
  bool isLoading = true;
  Future<void> fetchDoctors() async {
    final response = await _doctorService.getDoctorList();

    if (response['success'] == true && response['data'] is List) {
      final rawList = response['data'] as List;
      setState(() {
        doctors = rawList.map((d) => Doctor.fromJson(d)).toList();
        isLoading = false;
      });
    } else {
      print("Failed to load doctors: ${response['message']}");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDoctors();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (doctors.isEmpty) {
      return const Scaffold(body: Center(child: Text("No doctors available")));
    }

    final doctor = doctors[selectedDoctorIndex];

    List<Map<String, dynamic>> groupedSlots = [];

    if (doctor.slots != null && doctor.slots!.isNotEmpty) {
      for (var slot in doctor.slots!) {
        final date = slot.dateLabel;
        final time = slot.startTimeLabel;

        final existing = groupedSlots.firstWhere(
          (s) => s['date'] == date,
          orElse: () {
            final newGroup = {'date': date, 'times': <String>[]};
            groupedSlots.add(newGroup);
            return newGroup;
          },
        );

        existing['times'].add(time);
      }
    }

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
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (_) =>
                    //         BookingScreen(initialIndex: selectedDoctorIndex),
                    //   ),
                    // );
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
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (_) => BookingScreen(initialIndex: index),
                    //   ),
                    // );
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
                  children: groupedSlots.map<Widget>((slot) {
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
