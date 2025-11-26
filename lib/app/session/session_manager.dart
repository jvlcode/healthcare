import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:healthcare/models/user_model.dart';
import 'package:healthcare/services/auth_service.dart';
import 'package:hive/hive.dart';

class SessionManager {
  static final _secureStorage = FlutterSecureStorage();

  /// Flag to mark session invalid if ACCESS_DENIED
  static bool sessionInvalid = false;

  /// Initialize session: validate token if server reachable
  static Future<User?> initializeSession({bool validate = true}) async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    final user = await getCurrentUser();

    if (accessToken == null || user == null) return null;

    // Reset flag
    sessionInvalid = false;

    if (validate) {
      final valid = await _validateToken(refreshToken);
      if (!valid) {
        sessionInvalid = true;
        return null; // Do NOT return user if token invalid
      }
    }

    return user;
  }

  /// Validate token synchronously
  static Future<bool> _validateToken(String? refreshToken) async {
    try {
      final result = await AuthService().validateAccessToken();
      final message = result['message']?.toString().toUpperCase();

      // 1️⃣ Token still valid
      if (result['success'] == true) return true;

      // 2️⃣ Token expired → try refresh
      if (message == 'TOKEN_EXPIRED' && refreshToken != null) {
        final refreshed = await refreshAccessToken();
        return refreshed;
      }

      // 3️⃣ Access denied → clear session
      if (message == 'ACCESS_DENIED' ||
          message == 'INVALID_TOKEN' ||
          message == 'UNAUTHORIZED' ||
          message == 'SESSION_EXPIRED') {
        await clearSession();
        return false;
      }

      // 4️⃣ Other server errors → keep session
      print("⚠️ Token validation failed but not logging out: $message");
      return true;
    } catch (e) {
      print("⚠️ Token validation failed: $e");
      return false;
    }
  }

  /// Save session data
  static Future<void> saveSession(
    Map<String, dynamic> user,
    String accessToken,
    String refreshToken,
  ) async {
    await _secureStorage.write(key: 'access_token', value: accessToken);
    await _secureStorage.write(key: 'refresh_token', value: refreshToken);

    final userBox = await Hive.openBox('userBox');
    await userBox.put('user', user);
  }

  /// Clear session data
  static Future<void> clearSession() async {
    await _secureStorage.deleteAll();
    final userBox = await Hive.openBox('userBox');
    await userBox.clear();
  }

  /// Get access token
  static Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: 'access_token');
  }

  /// Get refresh token
  static Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: 'refresh_token');
  }

  /// Get current user from Hive
  static Future<User?> getCurrentUser() async {
    final userBox = await Hive.openBox('userBox');
    final userJson = userBox.get('user');
    if (userJson != null) {
      return User.fromJson(Map<String, dynamic>.from(userJson));
    }
    return null;
  }

  /// Update user in Hive
  static Future<void> updateUser(User updatedUser) async {
    final userBox = await Hive.openBox('userBox');
    await userBox.put('user', updatedUser.toJson());
  }

  /// Refresh access token
  static Future<bool> refreshAccessToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) return false;

    final authService = AuthService();
    final result = await authService.refreshToken(refreshToken);

    if (result['success'] == true) {
      final data = result['data'];
      final newAccessToken = data['accessToken'];
      final newRefreshToken = data['refreshToken'];
      if (newAccessToken != null) {
        await _secureStorage.write(key: 'access_token', value: newAccessToken);
        if (newRefreshToken != null) {
          await _secureStorage.write(
            key: 'refresh_token',
            value: newRefreshToken,
          );
        }
        return true;
      }
    }

    return false;
  }

  /// Update session tokens manually
  static Future<void> updateSessionTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _secureStorage.write(key: 'access_token', value: accessToken);
    await _secureStorage.write(key: 'refresh_token', value: refreshToken);
  }
}
