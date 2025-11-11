import 'package:healthcare/models/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart'; // or isar

class SessionManager {
  static final _secureStorage = FlutterSecureStorage();

  static Future<void> saveSession(
    User user,
    String accessToken,
    String refreshToken,
  ) async {
    // Store tokens securely
    await _secureStorage.write(key: 'access_token', value: accessToken);
    await _secureStorage.write(key: 'refresh_token', value: refreshToken);

    // Store user data in encrypted local DB
    final userBox = await Hive.openBox('userBox');
    await userBox.put(
      'user',
      user.toJson(),
    ); // Ensure `toJson()` is implemented
  }

  static Future<void> clearSession() async {
    await _secureStorage.deleteAll();
    final userBox = await Hive.openBox('userBox');
    await userBox.clear();
  }
}
