import 'dart:async';

import 'package:flutter/material.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/shape/gf_button_shape.dart';
import 'package:healthcare/app/session/reachability_controller.dart';
import 'package:healthcare/core/helpers/network_helper.dart';
import 'package:healthcare/core/utils/image_util.dart';
import 'package:healthcare/core/widgets/appointment_card.dart';
import 'package:healthcare/core/widgets/server_gaurd.dart';
import 'package:healthcare/features/user/doctors/chat_screen.dart';
import 'package:healthcare/features/user/videocall_history_screen.dart';
import 'package:healthcare/features/videocall/videocall_screen.dart';
import 'package:healthcare/models/appointment_model.dart';
import 'package:healthcare/services/appoinment_service.dart';
import 'package:provider/provider.dart';

class UserAppointmentsScreen extends StatefulWidget {
  const UserAppointmentsScreen({super.key});
  @override
  State<UserAppointmentsScreen> createState() => _UserAppointmentsScreenState();
}

class _UserAppointmentsScreenState extends State<UserAppointmentsScreen> {
  late StreamSubscription<bool> _sub;
  List<Appointment> bookings = [];
  bool _loading = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    _loadAppointments(); // fetch doctors on screen load
    final reach = context.read<ReachabilityController>();
    _sub = reach.reachabilityStream.listen((isReachable) {
      if (isReachable) {
        _loadAppointments(); // fetch doctors on screen load
      }
    });
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await NetworkHelper().safeCall(
        context,
        () => AppointmentService().getUserAppointments(),
        onSuccess: (res) {
          // Assuming res['data'] contains a List of appointment maps
          // cast to List<dynamic> first
          final data = res['data'] as List;
          bookings = data.map((e) => Appointment.fromJson(e)).toList();
          // bookings = res;
          setState(() {
            _loading = false;
          });
        },
        onApiError: (res) {
          setState(() {
            // final map = res as Map<String, dynamic>?; // cast to Map
            _error = "Failed to load appointments";
            _loading = false;
          });
        },
        onException: (e) {
          setState(() {
            _error = e.toString();
            _loading = false;
          });
        },
      );
    } finally {
      if (mounted && _loading) setState(() => _loading = false);
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ServerGuard(onRetry: _loadAppointments, child: _buildMainUI());
  }

  Widget _buildMainUI() {
    // if (_loading) {
    //   return const Scaffold(body: Center(child: CircularProgressIndicator()));
    // }

    if (_error != null || bookings.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text(
            _error ?? "No appointments found",
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F2),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Appointments",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...bookings.map((booking) {
            final statusColor = _statusColor(booking.status);

            return AppointmentCard(
              avatar: CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(
                  ImageUtils.resolve(booking.doctor.profileImage),
                ),
              ),
              title: booking.doctor.application.personalInfo.fullName,
              subtitle: booking.doctor.specialization,
              status: booking.status,
              statusColor: statusColor,
              date: booking.slot.dateLabel,
              timeRange:
                  "${booking.slot.startTimeLabel} - ${booking.slot.endTimeLabel}",
              actionButtons: Row(
                children: [
                  Expanded(
                    child: GFButton(
                      onPressed: booking.status == 'cancelled'
                          ? null
                          : () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ChatScreen()),
                            ),
                      text: "Chat",
                      color: const Color(0xFFFF6B35),
                      shape: GFButtonShape.pills,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GFButton(
                      onPressed: booking.status == 'cancelled'
                          ? null
                          : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VideoCallScreen(
                                  appointmentId: booking.id,
                                  doctorId: booking.doctor.id,
                                  patientId: booking.patient.id,
                                ),
                              ),
                            ),
                      text: "Video Call",
                      color: Colors.green,
                      shape: GFButtonShape.pills,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const VideoCallHistoryScreen()),
        ),
        icon: const Icon(Icons.history, color: Colors.white),
        label: const Text("Video Call History"),
        backgroundColor: const Color(0xFF01312F),
      ),
    );
  }
}
