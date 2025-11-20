import 'package:flutter/material.dart';
import 'package:healthcare/core/helpers/network_helper.dart';
import 'package:healthcare/core/utils/navigation_util.dart';
import 'package:healthcare/features/user/doctors/doctor_profile_screen.dart';
import 'package:healthcare/models/doctor_model.dart';
import 'package:healthcare/services/appoinment_service.dart';
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
  final TextEditingController ageController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    doctor = widget.doctor;
  }

  Future<bool?> _showExtraInfoForm() {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Additional Information",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // AGE
              TextField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Age",
                  prefixIcon: const Icon(Icons.cake_outlined),
                  filled: true,
                  fillColor: const Color(0xFFFFF3E9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // REASON
              TextField(
                controller: reasonController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: "Reason for Visit",
                  prefixIcon: const Icon(Icons.medical_services_outlined),
                  filled: true,
                  fillColor: const Color(0xFFFFF3E9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: "Describe your symptoms",
                ),
              ),
              const SizedBox(height: 16),

              // BUTTONS
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (ageController.text.isEmpty ||
                            reasonController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Age & Reason are required"),
                            ),
                          );
                          return;
                        }
                        Navigator.pop(context, true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B35),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "Continue",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleBooking(BuildContext context) async {
    final bool? canProceed = await _showExtraInfoForm();
    if (canProceed != true) return;

    final appointmentService = AppointmentService();

    await NetworkHelper().safeCall(
      context,
      () => appointmentService.createAppointment(
        doctorId: doctor.id,
        slotId: selectedSlot!['id'],
        age: ageController.text,
        reason: reasonController.text,
      ),
      onSuccess: (res) {
        navigateSlideLeft(context, page: BookingSuccessScreen());
      },
      onApiError: (res) {
        final msg = res['message'] ?? 'Booking failed';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $msg")));
      },
      onException: (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Exception: ${e.toString()}")));
      },
    );
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
                  : () => _handleBooking(context),
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
