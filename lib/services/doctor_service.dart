import 'api_client.dart';

class DoctorService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getDoctorList() async {
    return await _apiClient.get("doctors");
  }

  Future<Map<String, dynamic>> updateDoctorInfo(
    Map<String, dynamic> body,
  ) async {
    return await _apiClient.post("doctor/update", body);
  }

  /// 🔹 Get appointments for logged-in doctor
  Future<Map<String, dynamic>> getAppointments() async {
    return await _apiClient.get("appointments", useAuth: true);
  }

  /// 🔹 Update appointment status (Confirm / Cancel)
  Future<Map<String, dynamic>> updateAppointmentStatus({
    required String appointmentId,
    required String status, // "CONFIRMED", "CANCELLED"
  }) async {
    return await _apiClient.patch(
      "appointments/$appointmentId/status",
      data: {"status": status},
      useAuth: true,
    );
  }
}
