import 'package:healthcare/models/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
}
