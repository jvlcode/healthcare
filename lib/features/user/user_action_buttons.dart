import 'package:flutter/material.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/shape/gf_button_shape.dart';
import 'package:healthcare/features/chat/chat_screen.dart';
import 'package:healthcare/features/shared/appointment_manager.dart';
import 'package:healthcare/models/appointment_model.dart';

class UserActionButtons extends StatelessWidget {
  final Appointment appointment;
  final Future<void> Function(Appointment) onCall;

  const UserActionButtons({
    super.key,
    required this.appointment,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    final expired = AppointmentManager.isExpired(appointment);
    final notAllowed = ['PENDING', 'COMPLETED', 'REJECTED', 'EXPIRED'];

    if (!notAllowed.contains(appointment.status.toUpperCase()) && !expired) {
      return GFButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              toUserId: appointment.doctor.user!,
              displayName: appointment.doctor.name,
            ),
          ),
        ),
        text: "Chat",
        color: const Color(0xFFFF6B35),
        shape: GFButtonShape.pills,
      );
    }
    return const SizedBox.shrink();
  }
}
