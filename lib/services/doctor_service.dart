import 'api_client.dart';

class DoctorService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getDoctorList() async {
    return await _apiClient.get("doctor/list");
  }

  Future<Map<String, dynamic>> updateDoctorInfo(
    Map<String, dynamic> body,
  ) async {
    return await _apiClient.post("doctor/update", body);
  }
}
