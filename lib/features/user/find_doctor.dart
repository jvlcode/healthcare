import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:healthcare/core/helpers/network_helper.dart';
import 'package:healthcare/core/utils/navigation_util.dart';
import 'package:healthcare/core/widgets/book_session_btn.dart';
import 'package:healthcare/core/widgets/network_aware_scaffold.dart';
import 'package:healthcare/features/user/booking/booking_screen.dart';
import 'package:healthcare/features/user/doctors/doctor_profile_screen.dart';
import 'package:healthcare/models/doctor_model.dart';
import 'package:healthcare/services/doctor_service.dart';
import '../../../core/widgets/doctor_card.dart';
import '../../../core/widgets/time_box.dart';

class FindDoctor extends StatefulWidget {
  const FindDoctor({super.key});

  @override
  State<FindDoctor> createState() => _FindDoctorState();
}

class _FindDoctorState extends State<FindDoctor> {
  final DoctorService _doctorService = DoctorService();

  int selectedDoctorIndex = 0;
  List<Doctor> doctors = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await NetworkHelper().safeCall(
        context,
        () => _doctorService.getDoctorList(),
        onSuccess: (res) {
          final raw = (res['data'] as List<dynamic>? ?? []);
          doctors = raw.map((d) => Doctor.fromJson(d)).toList();
        },
        onApiError: (res) {
          final map = res as Map<String, dynamic>?;
          _error = map?['message'] ?? "Failed to load doctors";
        },
        onException: (e) => _error = e.toString(),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _refreshDoctors() async {
    await _fetchDoctors();
    Fluttertoast.showToast(
      msg: "Information updated!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return NetworkAwareScaffold(
      loading: _loading,
      error: _error,
      onRetry: _refreshDoctors,
      child: _buildUI(),
    );
  }

  Widget _buildUI() {
    if (_error != null || doctors.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshDoctors,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: const Center(
                child: Text(
                  "No doctors available",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
            ),
          ],
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
                navigateSlideLeft(context, page: BookingScreen(doctor: doctor));
              },
            ),
            const SizedBox(height: 20),

            /// Doctors carousel
            SizedBox(
              height: 180,
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.55),
                itemCount: doctors.length,
                onPageChanged: (i) => setState(() => selectedDoctorIndex = i),
                itemBuilder: (context, index) => DoctorCard(
                  doctor: doctors[index],
                  isSelected: index == selectedDoctorIndex,
                  onTap: () {
                    navigateSlideLeft(
                      context,
                      page: DoctorProfileScreen(doctor: doctors[index]),
                    );
                    ;
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

            /// Slots
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
                            children: times.map((t) {
                              return TimeBox(
                                time: t,
                                isSelected: false,
                                onTap: null,
                              );
                            }).toList(),
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
