import 'package:flutter/material.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/shape/gf_button_shape.dart';
import 'package:healthcare/core/utils/image_util.dart';
import 'package:healthcare/core/widgets/appointment_card.dart';
import 'package:healthcare/core/widgets/retry_loader.dart';
import 'package:healthcare/features/user/appointments/videocall_history_screen.dart';
import 'package:healthcare/features/user/doctors/chat_screen.dart';
import 'package:healthcare/features/user/doctors/videocall_screen.dart';
import 'package:healthcare/models/appointment_model.dart';
import 'package:healthcare/services/appoinment_service.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});
  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  List<Appointment> bookings = [];
  bool isLoading = true;
  String? error;
  @override
  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      final service = AppointmentService();
      final data = await service.getUserAppointments();
      setState(() {
        bookings = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
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
    if (error != null || bookings.isEmpty) {
      return RetryLoader(
        isLoading: isLoading,
        hasError: error != null,
        errorMessage: error ?? "No appointments found",
        onRetry: _loadAppointments,
        child: const SizedBox(),
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
                  ImageUtils.resolve(booking.doctor.profileImageUrl),
                ),
              ),

              title: booking.doctor.application.fullName,
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
                                builder: (_) => VideoCallScreen(),
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
