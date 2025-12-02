import 'package:flutter/material.dart';
import 'package:healthcare/models/appointment_model.dart';

class AppointmentManager {
  static bool isExpired(Appointment a) =>
      DateTime.now().isAfter(a.slot.startAt);

  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static String displayStatus(String status, {bool expired = false}) {
    if (expired) return "EXPIRED";

    switch (status.toUpperCase()) {
      case 'CALL_STARTED':
        return "Ringing...";
      case 'CALL_ACCEPTED':
        return "Call in progress";
      case 'CALL_REJECTED':
        return "You rejected the call";
      case 'CALL_MISSED':
        return "You missed the call";
      case 'CALL_DISCONNECTED':
        return "Call disconnected";
      case 'COMPLETED':
        return "Completed";
      default:
        return status;
    }
  }
}
