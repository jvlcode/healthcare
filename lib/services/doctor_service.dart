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

  /// 🔹 Get doctor verification status
  Future<Map<String, dynamic>> getDoctorStatus(String userId) async {
    return await _apiClient.get("doctor/status/$userId", useAuth: true);
  }

  // 🔹 Submit doctor application
  Future<Map<String, dynamic>> submitApplication({
    required Map<String, dynamic> personalInfo,
    required Map<String, dynamic> clinicInfo,
    required List<Map<String, String>> documents,
  }) async {
    final payload = {
      "personalInfo": personalInfo,
      "clinicInfo": clinicInfo,
      "documents": documents,
    };

    return await _apiClient.post("doctors/apply", payload, useAuth: true);
  }

  Future<Map<String, dynamic>> getApplicationStatus() async {
    return await _apiClient.get("doctors/application/status", useAuth: true);
  }
}
