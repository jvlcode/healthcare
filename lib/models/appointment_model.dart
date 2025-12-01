import 'package:healthcare/models/doctor_model.dart';
import 'package:healthcare/models/slot_model.dart';
import 'package:healthcare/models/user_model.dart';

class Appointment {
  final String id;
  String status;
  final DateTime createdAt;
  final Doctor doctor;
  final Slot slot;
  final User patient;
  final String age;
  final String reason;

  Appointment({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.doctor,
    required this.slot,
    required this.patient,
    required this.age,
    required this.reason,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    try {
      final doctorJson = json['doctor'] ?? {};
      final slotJson = json['slot'] ?? {};
      final userJson = json['user'] ?? {};

      return Appointment(
        id: json['_id']?.toString() ?? '',
        status: json['status'] ?? "Unknown",
        age: json['age']?.toString() ?? "Unknown",
        reason: json['reason'] ?? "Unknown",

        // SAFER DATE PARSING
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
            : DateTime.now(),

        // DOCTOR PARSER (correct json)
        doctor: Doctor.fromAppointmentJson({'doctor': doctorJson}),

        // SAFE SLOT PARSER
        slot: slotJson is Map<String, dynamic>
            ? Slot.fromJson(slotJson)
            : Slot.empty(), // You can define Slot.empty()
        // SAFE USER PARSER
        patient: userJson is Map<String, dynamic>
            ? User.fromJson(userJson)
            : User.empty(), // you can define User.empty()
      );
    } catch (e, stack) {
      print('❌ Failed to parse Appointment: $e');
      print('Stack: $stack');
      print('Raw JSON: $json');
      rethrow;
    }
  }
}
