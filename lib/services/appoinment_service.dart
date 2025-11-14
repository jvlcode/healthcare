// lib/services/appointment_service.dart
import 'package:healthcare/models/appointment_model.dart';
import 'package:healthcare/services/api_client.dart';

class AppointmentService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> createAppointment({
    required String doctorId,
    required String slotId,
  }) async {
    final body = {"doctorId": doctorId, "slotId": slotId};

    return await _apiClient.post("appointments", body, useAuth: true);
  }

  Future<List<Appointment>> getUserAppointments() async {
    final res = await _apiClient.get("appointments", useAuth: true);
    print(res);
    if (res['success'] == true && res['data'] is List) {
      return (res['data'] as List)
          .map((json) => Appointment.fromJson(json))
          .toList();
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
