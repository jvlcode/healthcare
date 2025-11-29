import 'package:healthcare/models/user_model.dart';

import 'api_client.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  // 1️⃣ The single instance stored privately
  static final AuthService _instance = AuthService._internal();

  // 2️⃣ Factory constructor returns the same instance
  factory AuthService() => _instance;

  // 3️⃣ Private named constructor prevents external instantiation
  AuthService._internal();

  Future<Map<String, dynamic>> register(User user, String password) async {
    final body = user.toJson()..addAll({'password': password});
    return await _apiClient.post("auth/register", body);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    return await _apiClient.post("auth/login", {
      'email': email,
      'password': password,
    });
  }

  Future<Map<String, dynamic>> sendOtp(String phone) async {
    return await _apiClient.post("auth/send-otp", {'phone': phone});
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    return await _apiClient.post("auth/verify-otp", {
      'phone': phone,
      'otp': otp,
    });
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    return await _apiClient.post("auth/forgot-password", {'email': email});
  }

  Future<Map<String, dynamic>> resetPassword(
    String token,
    String newPassword,
  ) async {
    return await _apiClient.post("auth/reset-password", {
      'token': token,
      'newPassword': newPassword,
    });
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    return await _apiClient.post("auth/refresh", {
      "refreshToken": refreshToken,
    });
  }

  Future<Map<String, dynamic>> validateAccessToken() async {
    print("validateAccessToken");
    return await _apiClient.get("users/me", useAuth: true);
  }

  Future<bool> isServerReachable() async {
    try {
      final result = await _apiClient
          .get("ping", useAuth: false)
          .timeout(const Duration(seconds: 2));

      return result['success'] == true &&
          result['data'] is Map &&
          result['data']['status'] == 'ok';
    } catch (e) {
      print("❌ Server reachability check failed: $e");
      return false;
    }
  }

  Future<bool> checkEmailExists(String email) async {
    try {
      final res = await _apiClient.get(
        "auth/check-email",
        queryParams: {"email": email},
      );
      final data = res['data'];
      return data['exists'] == true;
    } catch (e) {
      print("checkEmailExists error: $e");
      return false;
    }
  }

  Future<bool> checkPhoneExists(String phone) async {
    try {
      final res = await _apiClient.get(
        "auth/check-phone",
        queryParams: {"phone": phone},
      );
      print("RES $res");
      final data = res['data'];
      return data['exists'] == true;
    } catch (e) {
      print("checkPhoneExists error: $e");
      return false;
    }
  }
}
