import 'package:flutter/material.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/shape/gf_button_shape.dart';
import 'package:healthcare/models/appointment_model.dart';

class DoctorActionButtons extends StatelessWidget {
  final Appointment appointment;
  final Future<void> Function(Appointment) onCall;
  final Future<void> Function(Appointment) onChat;
  final Future<void> Function(Appointment) onComplete;
  final Future<void> Function(Appointment) onAccept;
  final Future<void> Function(Appointment) onReject;

  const DoctorActionButtons({
    super.key,
    required this.appointment,
    required this.onCall,
    required this.onChat,
    required this.onComplete,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    // replicate your doctor logic here using appointment.status
    // use GFButton + confirm dialogs as before
    final status = appointment.status.toLowerCase();

    if (status == "pending") {
      return Row(
        children: [
          GFButton(
            onPressed: () => onAccept(appointment),
            text: "Accept",
            icon: const Icon(Icons.check_rounded, color: Colors.white),
            color: Colors.green,
            shape: GFButtonShape.pills,
          ),
          SizedBox(width: 5),
          GFButton(
            shape: GFButtonShape.pills,
            icon: const Icon(Icons.close, color: Colors.white),
            text: "Reject",
            color: const Color(0xFFFF6B35),
            onPressed: () => onReject(appointment),
          ),
        ],
      );
    }

    if (status == "rejected" || status == "completed") {
      return Row();
    }

    return Row(
      children: [
        GFButton(
          onPressed: () => onCall(appointment),
          text: "Call",
          icon: const Icon(Icons.videocam, color: Colors.white),
          color: Colors.blue,
          shape: GFButtonShape.pills,
        ),
        SizedBox(width: 5),
        GFButton(
          shape: GFButtonShape.pills,
          icon: const Icon(Icons.message, color: Colors.white),
          text: "Chat",
          color: const Color(0xFFFF6B35),
          onPressed: () => onChat(appointment),
        ),
        SizedBox(width: 5),
        GFButton(
          shape: GFButtonShape.pills,
          icon: const Icon(Icons.check_rounded, color: Colors.white),
          text: "Complete",
          color: Colors.green,
          onPressed: () => onComplete(appointment),
        ),
      ],
    );
  }
}
