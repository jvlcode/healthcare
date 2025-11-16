import 'package:healthcare/models/doctor_model.dart';
import 'package:healthcare/models/slot_model.dart';
import 'package:healthcare/services/patient_model.dart';

class Appointment {
  final String id;
  final String status;
  final int amount;
  final DateTime createdAt;
  final Doctor doctor;
  final Slot slot;
  final Patient patient;
  final String age;
  final String reason;

  Appointment({
    required this.id,
    required this.status,
    required this.amount,
    required this.createdAt,
    required this.doctor,
    required this.slot,
    required this.patient,
    required this.age,
    required this.reason,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    try {
      return Appointment(
        id: json['_id'],
        status: json['status'],
        amount: json['amount'],
        age: json['age'] ?? "Unknown",
        reason: json['reason'] ?? "Unknown",
        createdAt: DateTime.parse(json['createdAt']),
        doctor: Doctor.fromAppointmentJson(json),
        slot: Slot.fromJson(json['slot']),
        patient: Patient.fromJson(json['user']),
      );
    } catch (e, stack) {
      print('❌ Failed to parse Appointment: $e');
      print('Stack: $stack');
      print('Raw JSON: $json');
      rethrow;
    }
  }
}
