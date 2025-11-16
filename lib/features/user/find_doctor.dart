import 'dart:async';
import 'package:flutter/material.dart';
import 'package:healthcare/app/session/reachability_controller.dart';
import 'package:healthcare/core/widgets/book_session_btn.dart';
import 'package:healthcare/core/widgets/server_gaurd.dart';
import 'package:healthcare/features/user/booking/booking_screen.dart';
import 'package:healthcare/features/user/doctors/doctor_profile_screen.dart';
import 'package:healthcare/models/doctor_model.dart';
import 'package:healthcare/services/doctor_service.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/doctor_card.dart';
import '../../../core/widgets/time_box.dart';

class FindDoctor extends StatefulWidget {
  const FindDoctor({super.key});

  @override
  State<FindDoctor> createState() => _FindDoctorState();
}

class _FindDoctorState extends State<FindDoctor> {
  int selectedDoctorIndex = 0;
  final DoctorService _doctorService = DoctorService();
  List<Doctor> doctors = [];
  bool _loading = true;
  String? _error;
  late StreamSubscription<bool> _sub;

  @override
  void initState() {
    super.initState();
    _fetchDoctors(); // fetch doctors on screen load
    final reach = context.read<ReachabilityController>();
    _sub = reach.reachabilityStream.listen((isReachable) {
      if (isReachable) {
        _fetchDoctors(); // 🔥 auto fetch when server comes back
      }
    });
  }

  Future<void> _fetchDoctors() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await _doctorService.getDoctorList();
      if (response['success'] == true && response['data'] is List) {
        final rawList = response['data'] as List;
        setState(() {
          doctors = rawList.map((d) => Doctor.fromJson(d)).toList();
          _loading = false;
        });
      } else {
        setState(() {
          _error = response['message'] ?? "Failed to load doctors";
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ServerGuard(onRetry: _fetchDoctors, child: _buildMainUI());
  }

  Widget _buildMainUI() {
    if (_error != null || doctors.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text(
            "No doctors available",
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ),
      );
    }

    final doctor = doctors[selectedDoctorIndex];

    // Group slots by date
    final Map<String, List<String>> slotsByDate = {};
    for (var slot in doctor.slots) {
      slotsByDate
          .putIfAbsent(slot.dateLabel, () => [])
          .add(slot.startTimeLabel);
    }

    final sortedDates = slotsByDate.keys.toList()..sort();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F2),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BookSessionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookingScreen(doctor: doctor),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
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
                        builder: (_) =>
                            DoctorProfileScreen(doctor: doctors[index]),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              "Available Dates",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Slot list similar to DoctorSlotManagementScreen
            Expanded(
              child: ListView.builder(
                itemCount: sortedDates.length,
                itemBuilder: (context, index) {
                  final date = sortedDates[index];
                  final times = slotsByDate[date]!;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            date,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF01312F),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: times
                                .map(
                                  (t) => TimeBox(
                                    time: t,
                                    isSelected: false,
                                    onTap: null,
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
