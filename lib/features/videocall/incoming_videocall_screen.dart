import 'dart:async';
import 'package:flutter/material.dart';
import 'package:healthcare/models/appointment_model.dart';
import 'package:healthcare/services/appoinment_service.dart';

class IncomingCallScreen extends StatefulWidget {
  final String doctorName;
  final String doctorId;
  final String patientId;
  final String appointmentId;
  final VoidCallback onAcceptCall;
  final VoidCallback onRejectCall;

  const IncomingCallScreen({
    super.key,
    required this.doctorName,
    required this.doctorId,
    required this.patientId,
    required this.appointmentId,
    required this.onAcceptCall,
    required this.onRejectCall,
  });

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startStatusPolling();
  }

  void _startStatusPolling() {
    _timer = Timer.periodic(const Duration(seconds: 2), (_) async {
      try {
        final res = await AppointmentService().getUserAppointment(
          widget.appointmentId,
        );
        final appointment = Appointment.fromJson(res['data']);
        final status = appointment.status.toLowerCase();
        print("POLLING $status");
        print(appointment);
        if (status == 'call_disconnected' || status == 'call_missed') {
          Navigator.pop(context, status);
        }
      } catch (e) {
        debugPrint("Error polling appointment status: $e");
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.call, color: Colors.green, size: 70),
            const SizedBox(height: 24),
            Text(
              widget.doctorName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "is calling you...",
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 60),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _button(
                  icon: Icons.call_end,
                  color: Colors.red,
                  text: "Decline",
                  onTap: widget.onRejectCall,
                ),
                _button(
                  icon: Icons.call,
                  color: Colors.green,
                  text: "Answer",
                  onTap: widget.onAcceptCall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _button({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            radius: 32,
            backgroundColor: color,
            child: Icon(icon, size: 28, color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        Text(text, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
