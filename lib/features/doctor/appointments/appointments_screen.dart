import 'package:flutter/material.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/shape/gf_button_shape.dart';
import 'package:healthcare/core/widgets/appointment_card.dart';
import 'package:healthcare/core/widgets/retry_loader.dart';
import 'package:healthcare/features/user/doctors/chat_screen.dart';
import 'package:healthcare/features/user/doctors/videocall_screen.dart';
import 'package:healthcare/models/appointment_model.dart';
import 'package:healthcare/services/appoinment_service.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key});
  @override
  State<DoctorAppointmentsScreen> createState() =>
      _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen> {
  List<Appointment> bookings = [];
  bool isLoading = true;
  String? error;
  final service = AppointmentService();

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
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

  Future<void> handleStatusUpdate(String id, String status) async {
    final ok = await service.updateAppointmentStatus(
      appointmentId: id,
      status: status,
    );
    if (ok) _loadAppointments();
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
    if (bookings.isEmpty) {
      return RetryLoader(
        isLoading: isLoading,
        hasError: true,
        errorMessage: "No appointments available",
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
            "Patient Appointments",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          ...bookings.map((booking) {
            final color = _statusColor(booking.status);

            return AppointmentCard(
              avatar: const CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(
                  'https://cdn-icons-png.flaticon.com/512/847/847969.png',
                ),
              ),

              title: booking.patient.name,
              subtitle:
                  "Age: ${booking.age}|Reason: ${booking.reason}", // doctor view shows only name
              status: booking.status,
              statusColor: color,

              date: booking.slot.dateLabel,
              timeRange:
                  "${booking.slot.startTimeLabel} - ${booking.slot.endTimeLabel}",

              actionButtons: Row(
                children: [
                  if (booking.status.toLowerCase() == 'pending') ...[
                    Expanded(
                      child: GFButton(
                        onPressed: () =>
                            handleStatusUpdate(booking.id, "CONFIRMED"),
                        text: "Accept",
                        color: Colors.green,
                        shape: GFButtonShape.pills,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GFButton(
                        onPressed: () =>
                            handleStatusUpdate(booking.id, "CANCELLED"),
                        text: "Reject",
                        color: Colors.red,
                        shape: GFButtonShape.pills,
                      ),
                    ),
                  ] else if (booking.status.toLowerCase() == 'confirmed') ...[
                    Expanded(
                      child: GFButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ChatScreen()),
                        ),
                        text: "Chat",
                        color: const Color(0xFFFF6B35),
                        shape: GFButtonShape.pills,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GFButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => VideoCallScreen()),
                        ),
                        text: "Start Call",
                        color: Colors.blue,
                        shape: GFButtonShape.pills,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
