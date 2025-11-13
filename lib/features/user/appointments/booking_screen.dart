import 'package:flutter/material.dart';
import 'package:healthcare/features/user/doctors/doctor_profile_screen.dart';
import 'package:healthcare/models/doctor_model.dart';
import '../../../core/widgets/doctor_card.dart';
import '../../../core/widgets/date_box.dart';
import '../../../core/widgets/time_box.dart';
import 'booking_success.dart';

class BookingScreen extends StatefulWidget {
  final Doctor doctor;

  const BookingScreen({super.key, required this.doctor});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late Doctor doctor;
  Map<String, dynamic>? selectedSlot;
  @override
  void initState() {
    super.initState();
    doctor = widget.doctor;
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> groupedSlots = [];

    if (doctor.slots.isNotEmpty) {
      for (var slot in doctor.slots!) {
        final date = slot.dateLabel;
        final time = slot.startTimeLabel;
        // final timeLabel = "${slot.startTimeLabel} - ${slot.endTimeLabel}";
        final slotEntry = {"id": slot.id, "label": time};

        final existing = groupedSlots.firstWhere(
          (s) => s['date'] == date,
          orElse: () {
            final newGroup = {'date': date, 'times': <Map<String, String>>[]};
            groupedSlots.add(newGroup);
            return newGroup;
          },
        );

        existing['times'].add(slotEntry);
      }
    }
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
              child: DoctorCard(
                doctor: doctor,
                isSelected: true,
                showBackgroundHighlight: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DoctorProfileScreen(doctor: doctor),
                    ),
                  );
                },
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
                                    time: t['label'],
                                    isSelected: selectedSlot?['id'] == t['id'],
                                    onTap: () {
                                      setState(() {
                                        selectedSlot = {
                                          "id": t["id"],
                                          "date": slot["date"],
                                          "label": t["label"],
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
