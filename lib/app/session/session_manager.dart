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

  static Future<void> updateUser(User updatedUser) async {
    final userBox = await Hive.openBox('userBox');
    await userBox.put('user', updatedUser.toJson());
  }

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

  /// Fast startup: returns cached user immediately.
  /// Validates token in background unless [validateInBackground] is false.
  static Future<User?> initializeSession({
    bool validateInBackground = true,
  }) async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    final user = await getCurrentUser();

    if (accessToken == null || user == null) return null;

    if (validateInBackground) {
      Future.microtask(() async {
        final authService = AuthService();
        final reachable = await authService.isServerReachable();

        if (!reachable) {
          print("⚠️ Skipping token validation — server unreachable");
          return;
        }

        try {
          final result = await authService.validateAccessToken();

          if (result['success'] == true) return;

          if (result['message'] == 'TOKEN_EXPIRED' && refreshToken != null) {
            final refreshed = await refreshAccessToken();
            if (refreshed) return;
          }

          await clearSession(); // only if token is invalid
        } catch (e) {
          print("⚠️ Token validation failed: $e");
        }
      });

      return user;
    }

    // Strict validation (e.g. protected screens)
    final authService = AuthService();
    final reachable = await authService.isServerReachable();

    if (!reachable) {
      print(
        "⚠️ Server unreachable during strict validation — using cached session",
      );
      return user;
    }

    try {
      final result = await authService.validateAccessToken();

      if (result['success'] == true) return user;

      if (result['message'] == 'TOKEN_EXPIRED' && refreshToken != null) {
        final refreshed = await refreshAccessToken();
        if (refreshed) return user;
      }

      await clearSession();
      return null;
    } catch (e) {
      print("⚠️ Token validation failed: $e");
      return user;
    }
  }
}
