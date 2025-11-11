import 'api_client.dart';

class UserService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getProfile() async {
    return await _apiClient.get("user/profile");
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> body) async {
    return await _apiClient.post("user/update", body);
  }
}
