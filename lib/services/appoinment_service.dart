// lib/services/appointment_service.dart
import 'package:healthcare/app/session/session_manager.dart';
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
}
