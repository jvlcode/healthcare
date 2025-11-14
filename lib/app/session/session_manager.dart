import 'package:healthcare/models/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:healthcare/services/auth_service.dart';
import 'package:hive/hive.dart';

class SessionManager {
  static final _secureStorage = FlutterSecureStorage();

  static Future<void> saveSession(
    User user,
    String accessToken,
    String refreshToken,
  ) async {
    await _secureStorage.write(key: 'access_token', value: accessToken);
    await _secureStorage.write(key: 'refresh_token', value: refreshToken);

    final userBox = await Hive.openBox('userBox');
    await userBox.put('user', user.toJson());
  }

  static Future<void> clearSession() async {
    await _secureStorage.deleteAll();
    final userBox = await Hive.openBox('userBox');
    await userBox.clear();
  }

  static Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: 'access_token');
  }

  static Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: 'refresh_token');
  }

  static Future<User?> getCurrentUser() async {
    final userBox = await Hive.openBox('userBox');
    final userJson = userBox.get('user');
    if (userJson != null) {
      return User.fromJson(Map<String, dynamic>.from(userJson));
    }
    return null;
  }

  static Future<bool> refreshAccessToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) return false;

    final authService = AuthService();
    final result = await authService.refreshToken(refreshToken);

    if (result['success'] == true) {
      final data = result['data'];
      final newAccessToken = data['accessToken'];
      if (newAccessToken != null) {
        await _secureStorage.write(key: 'access_token', value: newAccessToken);
        return true;
      }
    }

    return false;
  }

  static Future<User?> initializeSession() async {
    final accessToken = await _secureStorage.read(key: 'access_token');
    final refreshToken = await _secureStorage.read(key: 'refresh_token');

    final userBox = await Hive.openBox('userBox');
    final userJson = userBox.get('user');

    if (accessToken == null || userJson == null) return null;

    final authService = AuthService();
    final result = await authService.validateAccessToken();
    if (result['success'] == true) {
      return User.fromJson(Map<String, dynamic>.from(userJson));
    }

    if (result['message'] == 'TOKEN_EXPIRED' && refreshToken != null) {
      print("Access token expired. Attempting refresh...");
      final refreshResult = await authService.refreshToken(refreshToken);
      if (refreshResult['success'] == true) {
        final newAccessToken = refreshResult['data']['accessToken'];
        final newRefreshToken = refreshResult['data']['refreshToken'];
        if (newAccessToken != null) {
          await _secureStorage.write(
            key: 'access_token',
            value: newAccessToken,
          );
          await _secureStorage.write(
            key: 'refresh_token',
            value: newRefreshToken,
          );
          return User.fromJson(Map<String, dynamic>.from(userJson));
        }
      }
    }

    await SessionManager.clearSession();
    return null;
  }
}
