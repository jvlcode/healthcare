import 'dart:io';

import 'api_client.dart';

class UserService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getProfile() async {
    return await _apiClient.get("user/profile");
  }

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String bio,
    File? profileImage,
  }) async {
    final fields = {'name': name, 'email': email, 'phone': phone, 'bio': bio};

    return await _apiClient.multipartPut(
      'users/me',
      fields: fields,
      file: profileImage,
      useAuth: true,
    );
  }

  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    return await _apiClient.patch(
      'users/change-password',
      data: {'oldPassword': oldPassword, 'newPassword': newPassword},
      useAuth: true,
    );
  }
}
