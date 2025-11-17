// lib/services/appointment_service.dart
import 'dart:collection';

import 'package:healthcare/models/appointment_model.dart';
import 'package:healthcare/services/api_client.dart';

class AppointmentService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> createAppointment({
    required String doctorId,
    required String slotId,
    required String age,
    required String reason,
  }) async {
    final body = {
      "doctorId": doctorId,
      "slotId": slotId,
      "age": age,
      "reason": reason,
    };

    return await _apiClient.post("appointments", body, useAuth: true);
  }

  Future<Map<String, dynamic>> getUserAppointments() async {
    final res = await _apiClient.get("appointments", useAuth: true);
    // print("[Appointment Service] $res");
    if (res['success'] == true && res['data'] is List) {
      return res;
    } else {
      throw Exception(res['message'] ?? 'Failed to fetch appointments');
    }
  }

  Future<bool> updateAppointmentStatus({
    required String appointmentId,
    required String status, // "CONFIRMED" or "CANCELLED"
  }) async {
    final res = await _apiClient.patch(
      "appointments/$appointmentId/status",
      data: {"status": status},
      useAuth: true,
    );
    return res['success'] == true;
  }
}
