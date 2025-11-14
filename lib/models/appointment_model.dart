import 'package:healthcare/models/doctor_model.dart';

class Appointment {
  final String id;
  final String status;
  final int amount;
  final DateTime createdAt;
  final Doctor doctor;
  final Slot slot;

  Appointment({
    required this.id,
    required this.status,
    required this.amount,
    required this.createdAt,
    required this.doctor,
    required this.slot,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    try {
      return Appointment(
        id: json['_id'],
        status: json['status'],
        amount: json['amount'],
        createdAt: DateTime.parse(json['createdAt']),
        doctor: Doctor.fromAppointmentJson(json),
        slot: Slot.fromJson(json['slot']),
      );
    } catch (e, stack) {
      print('❌ Failed to parse Appointment: $e');
      print('Stack: $stack');
      print('Raw JSON: $json');
      rethrow;
    }
  }
}
